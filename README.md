ExtendJ Extension Base
======================

This is a base project for building extensions to ExtendJ.

The project is built using [Gradle][1] and the [JastAdd Gradle plugin][2]. A
short description of the build script is included in this README. Info about
cloning the project with Git is in the next section.

Cloning the Project
-------------------

Use these commands to clone the project and build it the first time:

    git clone --recursive git@bitbucket.org:extendj/extension-base.git
    cd extension-base
    gradle jar

Make sure to include the `--recursive` in the clone command to get the ExtendJ
submodule.

If you forgot the `--recursive` flag, don't worry, just go into the newly cloned
project and run these commands:

    git submodule init
    git submodule update --depth 1

That should download the ExtendJ git repository into the local directory `extendj`.

Build and Run
-------------

If you have [Gradle][1] installed you can issue the following commands to
build and test the extension-base tool:

    gradle jar
    java -jar extension-base.jar Test.java


If you don't have Gradle installed you can use the `gradlew.bat` (on Windows)
or `gradlew` (Unix) script instead. For example to build on Windows run the
following in a command prompt:

    gradlew jar

The `gradlew` scripts are wrapper scripts that will download a specific version
of Gradle locally and run it.

File Overview
-------------

Here is a short explanation of what each file in the project base directory contains:

* `build.gradle` - the main Gradle build script. There is more info about this below!
* `settings.gradle` - only contains the project name, if this did not exist the
  project name would be the name of the directory containing `build.gradle`.
The project name affects the generated Jar filename.
*  `jastadd_modules` - this file contains module definitions for the JastAdd build tool. This
  defines things such as which ExtendJ modules to include in the build, and where
additional JastAdd source files are located.
* `README.md` - this file
* `gradlew.bat` - windows Gradle wrapper script (explained above)
* `gradlew` - Unix Gradle wrapper script
* `src/java/org/extendj/ExtensionMain.java` - main class for the base extension.
* `src/jastadd/ExtensionBase.jrag` - simple aspect containing a single inter-type declaration,
  declaring the `CompilationUnit.process()` method.

Explanation of Files
--------------------


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
specific settings needed to build the project:


    jastadd {
        modules 'jastadd_modules'

        module = 'extension-base'

        astPackage = 'AST'
        genDir = 'src/gen/java'
        parser.name = 'JavaParser'
    }

The `modules 'jastadd_modules'` line tells the JastAdd plugin where to find
module specification files. The list only contains one item: our own
`jastadd_modules` file.

Each module specification file can define several modules, however our
`jastadd_modules` file defines only one module named `extension-base`.  The
`include` construct is used in the module specification to include the ExtendJ
modules that our module depends on.

The `module = 'extension-base'` line specifies the target module, i.e., the module
that the JastAdd plugin should build. If the target module is not found in
the list of module specifications then the build fails with an error message.

The next part of the build script has some simpler configuration things, such
as main class name, source and target Java versions, and the destination
directory for the Jar file:

    mainClassName = 'org.extendj.ExtensionMain'
    jar.manifest.attributes 'Main-Class': mainClassName
    jar.destinationDir = projectDir

    sourceCompatibility = '1.7'
    targetCompatibility = '1.7'

Additional Resources
--------------------

More examples about how to use the [JastAdd Gradle plugin][2] to build ExtendJ-like projects can be found here:

* [JastAdd Example: GradleBuild](http://jastadd.org/web/examples.php?example=GradleBuild)

[1]:https://gradle.org/
[2]:https://bitbucket.org/joqvist/jastaddgradle/overview
