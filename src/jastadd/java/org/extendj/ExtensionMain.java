package org.extendj;

import org.extendj.ast.CompilationUnit;
import org.extendj.ast.Modifier;
import org.extendj.ast.TypeDecl;
import org.extendj.parser.*;
import org.extendj.ast.TypestateDecl;
import org.extendj.ast.Program;
import org.extendj.ast.BytecodeReader;
import org.extendj.ast.AbstractClassfileParser;
import java.util.*;
import java.io.*;

public class ExtensionMain extends JavaChecker {

    public static void main(String args[]) {
        int exitCode = new ExtensionMain().run(args);
        if (exitCode != 0) {
            System.exit(exitCode);
        }
    }

    /**
     * Override Frontend.run(String[] args, BytecodeReader reader, JavaParser parser)
     * All protocol files need to be parsed and checked before processing java source 
     * compilation units
     */
    @Override
    public int run(String[] args, BytecodeReader reader, org.extendj.ast.JavaParser parser) {

        super.program.resetStatistics();
        super.program.initBytecodeReader(reader);
        super.program.initJavaParser(parser);

        initOptions();
        int argResult = processArgs(args);
        if (argResult != 0) {
            return argResult;
        }

        Collection<String> files = super.program.options().files();

        if (super.program.options().hasOption("-version")) {
            printVersion();
            return EXIT_SUCCESS;
        }

        if (super.program.options().hasOption("-help") || files.isEmpty()) {
            printUsage();
            return EXIT_SUCCESS;
        }

        Collection<CompilationUnit> work = new LinkedList<CompilationUnit>();

        try {
            for (String file : files) {
                super.program.addSourceFile(file);
            }

            TypeDecl object = super.program.lookupType("java.lang", "Object");
            if (object.isUnknown()) {
                // If we try to continue without java.lang.Object, we'll just get a stack overflow
                // in member lookups because the unknown (Object) type would be treated as circular.
                System.err.println("Error: java.lang.Object is missing."
                + " The Java standard library was not found.");
                return EXIT_UNHANDLED_ERROR;
            }

            int compileResult = EXIT_SUCCESS;

            // Parse all protocol files and perform sematic checking for them
            int exitCode = 0;
            // Parse protocol
            Iterator<CompilationUnit> preIter = super.program.compilationUnitIterator();
            while (preIter.hasNext()) {
                CompilationUnit unit = preIter.next();
                if (unit != null && unit.fromSource()) {
                    try {
                        LinkedList<Modifier> ms = unit.collectTypestateAnnotations();
                        ms = removeDuplicate(ms);
                        String sourcePath = unit.pathName();
                
                        if (ms.size() > 0) {
                            for (Modifier m: ms) {
                                String protocolFileName = m.getID() + ".protocol";
                                // debug
                                // printProtocolFile(protocolFileName, sourcePath);
                                // Typestate protocol file is parsed here
                                CompilationUnit cu = parseProtocol(protocolFileName, sourcePath);
                                //cu.setProtocolName(m.getID());
                                if (cu != null){
                                    // Add the new compilation unit to program before protocol semantic checking
                                    // As semantic checking need inforamtion from whole Java AST
                                    super.program.addCompilationUnit(cu);
                                    for (TypeDecl td: cu.getTypeDecls()){
                                        if (td instanceof TypestateDecl){
                                            TypestateDecl tsd = (TypestateDecl) td;
                                        }
                                    }
                                }                        
                            }                    
                        }
                    } catch (FileNotFoundException e){
                        System.err.println("Cannot find protocol file");
                    } catch (Error e) {
                        System.err.println("Encountered error while processing " + unit.pathName());
                        throw e;
                    }
                }
            }

            Iterator<CompilationUnit> protocolIter = super.program.compilationUnitIterator();
            while (protocolIter.hasNext()) {
                CompilationUnit unit = protocolIter.next();
                if (unit.isTypestateCompilationUnit()) {
                    exitCode = super.processCompilationUnitForTypestate(unit);
                    // Sematic errors found in protocol
                    if (exitCode != 0) {
                        unit.setDereferenced(true);
                        return exitCode;
                    }
                }
            }
            // End of protocol parsing and sematic checking

            // Same as original Frontend run method
            // Process source compilation units.
            Iterator<CompilationUnit> iter = super.program.compilationUnitIterator();
            while (iter.hasNext()) {
                CompilationUnit unit = iter.next();
                work.add(unit);
                int result = processCompilationUnit(unit);
                switch (result) {
                    case EXIT_SUCCESS:
                        break;
                    case EXIT_UNHANDLED_ERROR:
                        return result;
                    default:
                compileResult = result;
                }
            }

            // Process library compilation units.
            Iterator<CompilationUnit> libraryIterator = super.program.libraryCompilationUnitIterator();
            while (libraryIterator.hasNext()) {
                CompilationUnit unit = libraryIterator.next();
                work.add(unit);
                int result = processCompilationUnit(unit);
                switch (result) {
                    case EXIT_SUCCESS:
                        break;
                    case EXIT_UNHANDLED_ERROR:
                        return result;
                    default:
                        compileResult = result;
                }
            }

            if (compileResult != EXIT_SUCCESS) {
                return compileResult;
            }

            for (CompilationUnit unit : work) {
                if (unit != null && unit.fromSource()) {
                    long start = System.nanoTime();
                    processNoErrors(unit);
                    super.program.codeGenTime += System.nanoTime() - start;
                }
            }

        } catch (AbstractClassfileParser.ClassfileFormatError e) {
            System.err.println(e.getMessage());
            return EXIT_UNHANDLED_ERROR;
        } catch (Throwable t) {
            System.err.println("Fatal exception:");
            t.printStackTrace(System.err);
            return EXIT_UNHANDLED_ERROR;
        } finally {
            if (super.program.options().hasOption("-profile")) {
                super.program.printStatistics(System.out);
            }
        }
        return EXIT_SUCCESS;
    }

    @Override
    protected int processCompilationUnit(CompilationUnit unit) throws Error {
        int typestateSematicCheckCode = 0;
        // Checking referencing Typestate Compilation unit vaild or not
        int javaCheckCode = 0;
        for (CompilationUnit c: super.program.getCompilationUnitList()) {
            if (c.isDereferenced()) {
                javaCheckCode = EXIT_ERROR;
                return javaCheckCode;
            }
        }
        // TypestateSematicCheck OK, checking Java syntax.
        unit.preprocess(); // Label special statements first, might causes some error.
        javaCheckCode = super.processCompilationUnit(unit);
        if (javaCheckCode == 0) {
            // check end of programme, all Variables should be in end state
            javaCheckCode = super.processCompilationUnitForEndChecking(unit);
        }
        return javaCheckCode;
    }

    /** Called by processCompilationUnit when there are no errors in the argument unit.  */  
    @Override
    protected void processNoErrors(CompilationUnit unit) {
        unit.process();
    }

    /**
     * Parse protocol files into a CompilationUnit
     */
    private CompilationUnit parseProtocol(String protocolFileName, String sourcePath) throws FileNotFoundException{
        int lastIdx = sourcePath.lastIndexOf('/');
        String dir = sourcePath.substring(0, lastIdx + 1);
        String path = dir + protocolFileName;
        JavaParser parser = new JavaParser();
        CompilationUnit u = null;
        try{
            FileInputStream fileStream = new FileInputStream(path);
            u = (CompilationUnit) parser.parse(fileStream, path);
            System.out.println("Typestate protocol file " + protocolFileName + " is successfully parsed");
        } catch(FileNotFoundException e) {
            throw e;
        } catch(IOException e) {
            System.out.println("IOException");
            return null;
        } catch(Exception e){
            System.out.println("cannot parse");
            return null;
        }
        return u;       
    }

    private LinkedList<Modifier> removeDuplicate(LinkedList<Modifier> list) {
        LinkedList<Modifier> result = new LinkedList<Modifier>();
        for (Modifier m: list) {
            if (!result.contains(m)) {
                result.add(m);
            }
        }
        return result;
    }

    /**
     * Debug only - print protocol file content before processing CompilationUnit checking
     * Used for looking up the approprate point of parsing typstate protocol
     */
    private void printProtocolFile(String protocolFileName, String sourcePath){
        int lastIdx = sourcePath.lastIndexOf('/');
        String dir = sourcePath.substring(0, lastIdx + 1);
        System.out.println("Path: " + dir);
        String protocolFile =  dir + protocolFileName;
        String line = null;
        try {
            FileReader fileReader = new FileReader(protocolFile);
            BufferedReader bufferedReader = new BufferedReader(fileReader);
            while((line = bufferedReader.readLine()) != null) {
                System.out.println(line);
            }   
            bufferedReader.close();         
        } catch(FileNotFoundException ex) {
            System.out.println("Unable to open file '" + protocolFile + "'");                
        } catch(IOException ex) { 
            System.out.println("Error reading file '" + protocolFile + "'");                  
        }
    }
  
}
