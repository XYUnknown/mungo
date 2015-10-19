ExtendJ Extension Base
======================

This project is a minimal working example of an extension to the extensible
Java compiler ExtendJ. This should provide a useful base for creating your own
extensions.

Cloning this Project
--------------------

To clone this project you will need [Git][3] installed.

Use this command to clone the project using Git:

    git clone --recursive git@bitbucket.org:extendj/extension-base.git

The `--recursive` flag makes Git also clone the ExtendJ submodule while cloning
the `extension-base` repository.

If you forgot the `--recursive` flag you can manually clone the ExtendJ
submodule using these commands:

    cd extension-base
    git submodule init
    git submodule update --depth 1

This should download the ExtendJ Git repository into a local directory named
`extendj`. The `--depth 1` flag tells Git to only clone the latest commit from
the ExtendJ repository. This might be a preferable cloning method if you
have a slow Internet connection.

Build and Run
-------------

If you have [Gradle][1] installed you can issue the following commands to
build and test the minimal extension:

    gradle jar
    java -jar extension-base.jar src/java/org/extendj/BaseExtension.java


If you do not have Gradle installed you can use the `gradlew.bat` (on Windows)
or `gradlew` (Mac/Linux) script instead. For example to build on Windows run the
following in a command prompt:

    gradlew jar

The `gradlew` scripts are wrapper scripts that will download Gradle locally and
run it.

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

Gradle Build Walkthrough
------------------------

The build script `build.gradle` may need an introduction even if you are already familiar with
[Gradle][1]. The build uses a custom [JastAdd Gradle plugin][2]. The plugin is available from the
Maven repository `http://jastadd.org/mvn/`, so the first part of the build script adds this
maven repository and a dependency for the JastAdd plugin:

    buildscript {
        repositories.mavenLocal()
        repositories.maven {
            url 'http://jastadd.org/mvn/'
        }
        dependencies {
            classpath group: 'org.jastadd', name: 'jastaddgradle', version: '1.9.4'
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

        astPackage = 'AST'
        genDir = 'src/gen/java'
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

The next part of the build script has some simpler configuration things, such
as the main class name, source and target Java versions, and the destination
directory for the Jar file:

    jar.manifest.attributes 'Main-Class': 'org.extendj.ExtensionMain'
    jar.destinationDir = projectDir

    sourceCompatibility = '1.7'
    targetCompatibility = '1.7'

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

Additional Resources
--------------------

More examples on how to build ExtendJ-like projects with the [JastAdd Gradle
plugin][2] can be found here:

* [JastAdd Example: GradleBuild](http://jastadd.org/web/examples.php?example=GradleBuild)

[1]:https://gradle.org/
[2]:https://bitbucket.org/joqvist/jastaddgradle/overview
[3]:https://git-scm.com/
