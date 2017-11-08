ExtendJ Extension Base
======================

This project is a minimal working example of an extension to the extensible
Java compiler ExtendJ. This should provide a useful base for creating your own
extensions.

Cloning this Project
--------------------

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

Build and Run
-------------

If you have [Gradle][1] installed you can issue the following commands to
build and test the minimal extension:

    gradle jar
    java -jar extension-base.jar testfiles/Test.java

The last command should print

    testfiles/Test.java contained no errors

If you do not have Gradle installed you can use the `gradlew.bat` (on Windows)
or `gradlew` (Mac/Linux) script instead. For example to build on Windows run the
following in a command prompt:

    gradlew jar

The `gradlew` scripts are wrapper scripts that will download Gradle locally and
run it.

Backend Extensions
------------------

This project is set up to build a frontend extension, i.e., static analysis tools.

To build a backend extension, i.e., a full compiler, apply the following patch:

    --- a/build.gradle
    +++ b/build.gradle
    @@ -36,6 +36,8 @@ sourceSets.main {
            java {
                    srcDir 'extendj/src/frontend-main'
    +               srcDir 'extendj/src/backend-main'
            }
            resources {
                    srcDir 'extendj/src/res'
    @@ -43,7 +45,7 @@ sourceSets.main {
                }
     }
     
    -jar.manifest.attributes 'Main-Class': 'org.extendj.ExtensionMain'
    +jar.manifest.attributes 'Main-Class': 'org.extendj.JavaCompiler'
     jar.destinationDir = projectDir
     
     // Java -source and -target version.
    --- a/jastadd_modules
    +++ b/jastadd_modules
    @@ -2,7 +2,7 @@ include("extendj/jastadd_modules") // Include the core ExtendJ modules.
     
     module "extension-base", { // TODO Replace with your own module name.
     
    -       imports "java8 frontend"
    +       imports "java8 backend"
     
            java {
                    basedir "src/java/"



File Overview
-------------

Here is a short explanation of the purpose of each file in the project:

* `build.gradle` - the main Gradle build script. There is more info about this below.
*  `jastadd_modules` - this file contains module definitions for the JastAdd build tool. This
  defines things such as which ExtendJ modules to include in the build, and where
additional JastAdd source files are located.
* `README.md` - this file.
* `gradlew.bat` - Windows Gradle wrapper script (explained above)
* `gradlew` - Unix Gradle wrapper script
* `src/java/org/extendj/ExtensionMain.java` - main class for the base extension. Parses
  Java files supplied on the command-line and runs the `process()` method on each parsed AST.
* `src/jastadd/ExtensionBase.jrag` - simple aspect containing a single inter-type declaration:
  the `CompilationUnit.process()` method.
* `testfiles/Test.java` - simple Java file to test the generated compiler.

How this Extension Works
------------------------

This extension builds a compiler that prints out the filenames of Java files
you supply to the compiler. This obviously super simple to do, but the compiler
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

Extension Architecture
----------------------

This section explains how the module file `jastadd_modules` works, and how the minimal
extension is structured.

The `jastadd_modules` file starts with an include:

    include("extendj/jastadd_modules") // Include the core ExtendJ modules.

This includes the core ExtendJ modules by loading the file with the path
`extendj/jastadd_modules`. That file in turn includes modules from
subdirectories in the `extendj` directory.

Each `jastadd_modules` file can define JastAdd modules. Our file defines one
module named `extension-base`:

    module "extension-base", { // TODO Replace with your own module name.

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

Gradle Build Walkthrough
------------------------

The build script `build.gradle` may need an introduction even if you are
already familiar with [Gradle][1]. The build uses a custom [JastAdd Gradle
plugin][2]. The plugin is available from the Maven Central Repository, so the
first part of the build script adds this repository and a dependency for the
JastAdd plugin:

    buildscript {
        repositories.mavenCentral()
        dependencies {
            classpath group: 'org.jastadd', name: 'jastaddgradle', version: '1.9.6'
        }
    }

The next part is a list of Gradle plugins that we will use:

    apply plugin: 'java'
    apply plugin: 'jastadd'

Next comes the `jastadd` configuration. This part provides the JastAdd plugin
configuration to build the project:


    jastadd {
        modules 'jastadd_modules'

        module = 'extension-base'

        astPackage = 'org.extendj.ast'
        genDir = 'src/gen/java'
        buildInfoDir = 'src/gen-res'
        parser.name = 'JavaParser'
    }

The `modules 'jastadd_modules'` line tells the JastAdd plugin where to find
module specification files. This can be a list of filenames, or a single filename.
In our case it points to the `jastadd_modules` file in the projects base directory.

Each module specification file can define several modules, however our
`jastadd_modules` file defines only one module named `extension-base`.  The
`include` construct is used in the module specification to include the core ExtendJ
modules that our module depends on.

The `module = 'extension-base'` line specifies the target module, i.e., the module
that the JastAdd plugin should build. If the target module is not found in
the list of module specifications then the build fails with an error message.

The next part of the build script specifies source and resource directories for the build.
We need to do this here to include a few Java files from ExtendJ that will be used by
`src/java/org/extendj/ExtensionMain.java':

    sourceSets.main {
        java {
            srcDir 'extendj/src/frontend-main'
            exclude 'org/extendj/PrettyPrintTask.java'
        }
        resources {
            srcDir 'extendj/src/res'
            srcDir jastadd.buildInfoDir
        }
    }


When you modify the `jastadd_modules` file you will need to tell Gradle to rerun
JastAdd re-generates the Java source files. See below for more info on rebuilding
with Gradle.

The last part of the build script has some simpler configuration things, such
as the main class name, source and target Java versions, and the destination
directory for the Jar file:

    jar.manifest.attributes 'Main-Class': 'org.extendj.ExtensionMain'
    jar.destinationDir = projectDir

    sourceCompatibility = '1.7'
    targetCompatibility = '1.7'


## Rebuilding

Although the Gradle plugin can handle some automatic rebuilding when a source file changes,
it does not handle all cases well, so in some cases you will need to force Gradle to
rebuild your project. This can be done passing the `--rerun-tasks` option to Gradle:

    $ gradle --rerun-tasks


Changes to the `jastadd_modules` file always require a rebuild to ensure that everything
is generated from the current sources.


## Upgrading ExtendJ

If you want to update to the latest ExtendJ version, you can use these commands:

    cd extendj
    git fetch origin
    git reset --hard origin/master


This may be necessary if a bugfix that you need was committed to ExtendJ in a version
later than the version that this repository links to.

It is recommended that you use a test suite to ensure that your extension
functionality is preserved after upgrading the core ExtendJ compiler.

Additional Resources
--------------------

More examples on how to build ExtendJ-like projects with the [JastAdd Gradle
plugin][2] can be found here:

* [JastAdd Example: GradleBuild](http://jastadd.org/web/examples.php?example=GradleBuild)

[1]:https://gradle.org/
[2]:https://bitbucket.org/joqvist/jastaddgradle/overview
[3]:https://git-scm.com/
