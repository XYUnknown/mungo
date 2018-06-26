package org.extendj;

import org.extendj.ast.CompilationUnit;
import org.extendj.ast.Modifier;
import org.extendj.ast.TypeDecl;
import org.extendj.parser.*;
import org.extendj.ast.TypestateDecl;
import java.util.*;
import java.io.*;

public class ExtensionMain extends JavaChecker {

    public static void main(String args[]) {
        int exitCode = new ExtensionMain().run(args);
        if (exitCode != 0) {
            System.exit(exitCode);
        }
    }

    @Override
    protected int processCompilationUnit(CompilationUnit unit) throws Error {
        int typestateSematicCheckCode = 0;
        if (unit != null && unit.fromSource()) {
            try {
                LinkedList<Modifier> ms = unit.collectTypestateAnnotations();
                System.out.println("collected annotations:" + ms.size());
                if (ms.size() > 0) {
                    // At this point we can assume that there is only one typestate annotation for one java file.
                    // TODO Checking duplication OF typestate annotation
                    String protocolFileName = ms.get(0).getID() + ".protocol";
                    printProtocolFile(protocolFileName);
                    // Typestate protocol file is parsed here
                    CompilationUnit cu = parseProtocol(protocolFileName);
                    cu.setProtocolName(ms.get(0).getID());
                    // Cannot do traversal, which means that the AST of protocol file is broken.
                    for (TypeDecl td: cu.getTypeDecls()){
                        if (td instanceof TypestateDecl){
                            System.out.println("This is a TypestateDecl " + td.name());
                            TypestateDecl tsd = (TypestateDecl) td;
                            System.out.println(tsd.getInitState());
                        }
                    }
                    // TODO: fix it after linked together
                    // cu.doPrintFullTraversal();
                    // TODO sematic check of typestate protocol and update typestateSematicCheckCode
                    typestateSematicCheckCode = super.processCompilationUnitForTypestate(cu);
                    //System.out.println(typestateSematicCheckCode);
                    // Sematic errors found in protocol
                    if (typestateSematicCheckCode != 0) {
                        return typestateSematicCheckCode;
                    }
                    // pass the sematic checking add new Compilation Unit to program. 
                    super.program.addCompilationUnit(cu);
                }
            } catch (Error e) {
                System.err.println("Encountered error while processing " + unit.pathName());
                throw e;
            }
        }
        int javaSematicCheckCode = super.processCompilationUnit(unit);
        int exitCode = javaSematicCheckCode & typestateSematicCheckCode;
        return exitCode;
    }

    /** Called by processCompilationUnit when there are no errors in the argument unit.  */  
    @Override
    protected void processNoErrors(CompilationUnit unit) {
        unit.process();
    }

    /**
     * Debug only - print protocol file content before processing CompilationUnit checking
     * Used for looking up the approprate point of parsing typstate protocol
     */
    private void printProtocolFile(String protocolFileName){
        String testPath = "testfiles/collection/";
        String protocolFile =  testPath + protocolFileName;
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

    private CompilationUnit parseProtocol(String protocolFileName){
        String testPath = "testfiles/collection/";
        String path = testPath + protocolFileName;
        JavaParser parser = new JavaParser();
        CompilationUnit u = null;
        try{
            FileInputStream fileStream = new FileInputStream(path);
            u = (CompilationUnit) parser.parse(fileStream, path);
            System.out.println("Typestate Protocol file is successfully parsed");
        } catch(FileNotFoundException e) {
            System.out.println("FileNotFoundException");
            return null;
        } catch(IOException e) {
            System.out.println("IOException");
            return null;
        } catch(Exception e){
            System.out.println("cannot parse");
            return null;
        }
        return u;       
    }

  
}
