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
                ms = removeDuplicate(ms);
                System.out.println("collected annotations:" + ms.size());
                String sourcePath = unit.pathName();
                
                if (ms.size() > 0) {
                    for (Modifier m: ms) {
                        String protocolFileName = m.getID() + ".protocol";
                        printProtocolFile(protocolFileName, sourcePath);
                        // Typestate protocol file is parsed here
                        CompilationUnit cu = parseProtocol(protocolFileName, sourcePath);
                        //cu.setProtocolName(m.getID());
                        if (cu != null){
                            // Add the new compilation unit to program before protocol semantic checking
                            // As semantic checking need inforamtion from whole Java AST
                            super.program.addCompilationUnit(cu);
                            for (TypeDecl td: cu.getTypeDecls()){
                                if (td instanceof TypestateDecl){
                                    System.out.println("This is a TypestateDecl " + td.name());
                                    TypestateDecl tsd = (TypestateDecl) td;
                                    System.out.println(tsd.getInitState());
                                }
                            }
                            //System.out.println("--------Debugging--------");
                            //cu.doPrintFullTraversal();
                            // TODO sematic check of typestate protocol and update typestateSematicCheckCode
                            typestateSematicCheckCode = super.processCompilationUnitForTypestate(cu);
                            // Sematic errors found in protocol
                            if (typestateSematicCheckCode != 0) {
                                return typestateSematicCheckCode;
                            }
                            // Protocol passes the sematic checking
                        }                        
                    }                    
                }
            } catch (FileNotFoundException e){
                System.out.println("Cannot find protocol file");
            } catch (Error e) {
                System.err.println("Encountered error while processing " + unit.pathName());
                throw e;
            }
        }
        // TypstateSematicCheck OK, checking Java syntax.
        int javaCheckCode = super.processCompilationUnit(unit);
        if (javaCheckCode == 0) {
            // check end of programme check
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

    private CompilationUnit parseProtocol(String protocolFileName, String sourcePath) throws FileNotFoundException{
        int lastIdx = sourcePath.lastIndexOf('/');
        String dir = sourcePath.substring(0, lastIdx + 1);
        System.out.println("Path: " + dir);
        String path = dir + protocolFileName;
        JavaParser parser = new JavaParser();
        CompilationUnit u = null;
        try{
            FileInputStream fileStream = new FileInputStream(path);
            u = (CompilationUnit) parser.parse(fileStream, path);
            System.out.println("Typestate Protocol file is successfully parsed");
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
  
}
