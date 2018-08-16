# A Type Checking Tool Extending ExtendJ 

This project uses project `Extension Base` as a starting point.

Source code of revious version Mungo can be found at: https://github.com/Dimitris-Kouzapas/javatypestate

## Cloning and Building this Project
To clone this project, use this command:

`git clone --recursive https://github.com/XYUnknown/mungo.git`

To build this project, use this command:

`gradle build`

## Running the Typechecker
Format of command to run the typechecker:

`java -jar Typestate.jar [filepath]`

Notice that all relevant java source files should be passed into command line, similar as using java compiler `javac *.java`.

An example command to run the typechecker:

`java -jar Typestate.jar testfiles/collection/*.java`

## Upgrading ExtendJ

If you want to update to the latest ExtendJ version, you can use these commands:

    cd extendj
    git fetch origin
    git reset --hard origin/master


This may be necessary if a bugfix that you need was committed to ExtendJ in a version
later than the version that this repository links to.

It is recommended that you use a test suite to ensure that your extension
functionality is preserved after upgrading the core ExtendJ compiler.


## README Documentation from Extension Base
This project is a minimal working example of an extension to the extensible Java compiler ExtendJ. This should provide a useful base for creating your own extensions.
### License

Obviously this stuff is just simple template code that is meant to be copied,
and I give anyone permission to use it without attribution.  If you copy this
code to create your own project, you can delete the LICENSE file.  The license
is there just to make it possible to use this project if your employer is
strict about Open Source licensing.


### Cloning this Project

To clone this project you will need [Git][3] installed.

Use this command to clone the project using Git:

    git clone --recursive https://bitbucket.org/extendj/extension-base.git

The `--recursive` flag makes Git also clone the ExtendJ submodule while cloning
the `extension-base` repository.

If you forgot the `--recursive` flag you can manually clone the ExtendJ
submodule using these commands:

    cd extension-base
    git submodule init
    git submodule update

This should download the ExtendJ Git repository into a local directory named
`extendj`.


### Build and Run

This project is built with [Gradle][1].  Don't worry, you do not
need to install Gradle. You just need a Java installation. If you have Java installed,
run the following commands to build the project:

    ./gradlew jar
    java -jar checker.jar testfiles/Test.java


If you are on Windows, replace `./gradlew` by just `gradlew`.

If everything went well, you should see this output:

    testfiles/Test.java contained no errors


### Backend Extensions

This project is set up to build a frontend extension, i.e., static analysis tools.

To build a backend extension, i.e., a full compiler, you should apply the following
changes in the file `build.gradle`:

* In the java block in sourceSets.main: add a line `srcDir' 'extendj/src/backend-main'`
* Change the Main-Class Jar attribute from `org.extendj.ExtensionMain` to `org.extendj.JavaCompiler`
* Change the line `imports "java8 frontend"` to `imports "java8 backend"`


### File Overview

Here is a short description of some notable files in this project:

* `build.gradle` - the main Gradle build script. More about this below.
* `gradlew.bat` - script for building on Windows.
* `gradlew` - script for building on Unix-likes.
* `src/java/org/extendj/ExtensionMain.java` - main class for the base extension. Parses
  Java files supplied on the command-line and runs the `process()` method on each parsed AST.
* `src/jastadd/ExtensionBase.jrag` - simple aspect containing a single inter-type declaration:
  the `CompilationUnit.process()` method.
* `testfiles/Test.java` - simple Java file to test the generated compiler.
* `settings.gradle` - configures the Gradle project name.
* `checker.jar` - the generated compiler Jar file (based on project name).


### How this Extension Works

This extension builds a compiler that prints out the filenames of Java files
you supply to the compiler. This is obviously super simple to do, but the compiler
does error-check each file for semantic errors first before printing the file
name, so it can be used as a simple Java error checker.

The `src/java/org/extendj/ExtensionMain.java` class is the entry-point for the
compiler. This is where command-line arguments are processed. The
`ExtensionMain` class is very small because it extends the
`org.jastadd.extendj.JavaChecker` class from ExtendJ.

The `processNoErrors` method in `ExtensionMain` is called for each
`CompilationUnit`, i.e. each Java source file, that contained no semantic
errors.

    @Override
    protected void processNoErrors(CompilationUnit unit) {
      // Called when there were no errors in the compilation unit.
      unit.process();
    }

The `process` method is defined in `src/jastadd/ExtensionBase.jrag`:

    aspect ExtensionBase {
      /** Called by ExtensionMain.processNoErrors() after error-checking a compilation unit. */
      public void CompilationUnit.process() {
        System.out.println(pathName());
      }
    }


### Extension Architecture

This section explains how the module system in the JastAdd Gradle plugin works.

A module definition usually starts like this:

    include("extendj/jastadd_modules")


This includes the core ExtendJ modules by loading the file with the path
`extendj/jastadd_modules`. That file is a module specification which in turn
includes modules from subdirectories in the `extendj` directory.

Each `jastadd_modules` file can define multiple JastAdd modules. In the build script,
there is just one module named `extension-base`:

    module "extension-base", {

        imports "java8 frontend"

        java {
            basedir "src/java/"
            include "**/*.java"
        }

        jastadd {
            basedir "src/jastadd/"
            include "**/*.ast"
            include "**/*.jadd"
            include "**/*.jrag"
        }
    }


The module has some comments to show how to add parser or scanner files, but we
don't use that and it is likely that you wont need to either if you just want to
parse Java code.

The module uses an `imports` statement to import all of the JastAdd files from
the core ExtendJ module `java8 frontend`. Each supported Java version in
ExtendJ has a frontend and backend module. The frontend module is used if you don't
need to generate bytecode.

JastAdd only uses `.ast`, `.jadd`, and `.jrag` files to generate Java code, but a
JastAdd compiler needs some supporting code to run the compiler, so our module has
a Java class `src/java/org/extendj/ExtensionMain.java` to run the compiler, and
ExtendJ includes some Java code and scanner/parser code that is not generated by JastAdd.

The Java code generated by JastAdd is output to the `src/gen` directory.


### Gradle Build Walkthrough

The build script `build.gradle` may need an introduction even if you are
already familiar with [Gradle][1]. The first part of the build script declares
which plugins will be used. We use the [JastAdd Gradle plugin][2] to generate
code with JastAdd:

    plugins {
      id 'java'
      id 'org.jastadd' version '1.12.0'
    }


Next comes the `jastadd {...}` configuration. This part provides information about
the JastAdd modules that you want to build:

    jastadd {
      configureModuleBuild()

      modules {
        include("extendj/jastadd_modules") // Include the core ExtendJ modules.

        module "extension-base", {
          imports "java8 frontend" // This module depends on "java8 frontend" from ExtendJ.

          java {
            basedir "src/java/"
            include "**/*.java"
          }

          jastadd {
            basedir "src/jastadd/"
            include "**/*.ast"
            include "**/*.jadd"
            include "**/*.jrag"
          }

          //scanner {
          // TODO List your scanner specification additions here.
          //}

          //parser {
          // TODO List your parser specification additions here.
          //}
        }
      }

      // Target module to build:
      module = 'extension-base'

      astPackage = 'org.extendj.ast'
      buildInfoDir = 'src/gen-res'
      parser.name = 'JavaParser'
      scanner.name = 'OriginalScanner'
    }


ExtendJ is organized into a modular structure where each Java version of the
compiler has its own module.  Each Java version also has a frontend and backend
module. The backend modules add bytecode generation to the corresponding
frontend.

The `modules {...}` block above declares the modules that will be visible to
the JastAdd Gradle plugin. Then, the `module = ...` line tells the plugin
which module you want to build. The JastAdd Gradle plugin will include all
source files in the module, plus the source files from modules that your module
depends on (recursively).

The next part of the build script specifies source and resource directories for the build.
We need to do this here to include a few Java files from ExtendJ that will be used by
`src/java/org/extendj/ExtensionMain.java':

    sourceSets.main {
      java {
        srcDir 'extendj/src/frontend-main'
      }
      resources {
        srcDir 'extendj/src/res'
        srcDir jastadd.buildInfoDir
      }
    }


The remaining parts of the build script are not very interesting.


### Rebuilding

Although the Gradle plugin can handle some automatic rebuilding when a source
file changes, it does not handle all possible cases. In some situations you
will need to force Gradle to rebuild your project. This can be done passing the
`--rerun-tasks` option to Gradle:

    ./gradlew --rerun-tasks


### Upgrading ExtendJ

If you want to update to the latest ExtendJ version, you can use these commands:

    cd extendj
    git fetch origin
    git reset --hard origin/master


This may be necessary if a bugfix that you need was committed to ExtendJ in a version
later than the version that this repository links to.

It is recommended that you use a test suite to ensure that your extension
functionality is preserved after upgrading the core ExtendJ compiler.

### Additional Resources

More examples on how to build ExtendJ-like projects with the [JastAdd Gradle
plugin][2] can be found here:

* [JastAdd Example: GradleBuild](http://jastadd.org/web/examples.php?example=GradleBuild)

[1]:https://gradle.org/
[2]:https://github.com/jastadd/jastaddgradle
[3]:https://git-scm.com/
