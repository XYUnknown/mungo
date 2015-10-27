package org.extendj;

import org.extendj.ast.CompilationUnit;

public class ExtensionMain extends JavaChecker {

  public static void main(String args[]) {
    int exitCode = new ExtensionMain().run(args);
    if (exitCode != 0) {
      System.exit(exitCode);
    }
  }

  @Override
  protected void processNoErrors(CompilationUnit unit) {
    // Called when there were no errors in the compilation unit.
    unit.process();
  }
}
