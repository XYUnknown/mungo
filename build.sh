#!/bin/bash
set -eu
source config.sh
mkdir -p "build/tmp"
echo "Generating scanner..."
cat \
    /Users/jesper/git/extension-base/extendj/java4/scanner/Header.flex \
    /Users/jesper/git/extension-base/extendj/java8/scanner/Preamble.flex \
    /Users/jesper/git/extension-base/extendj/java7/scanner/Macros.flex \
    /Users/jesper/git/extension-base/extendj/java4/scanner/RulesPreamble.flex \
    /Users/jesper/git/extension-base/extendj/java4/scanner/WhiteSpace.flex \
    /Users/jesper/git/extension-base/extendj/java4/scanner/Comments.flex \
    /Users/jesper/git/extension-base/extendj/java4/scanner/Keywords.flex \
    /Users/jesper/git/extension-base/extendj/java4/scanner/Operators.flex \
    /Users/jesper/git/extension-base/extendj/java4/scanner/Separators.flex \
    /Users/jesper/git/extension-base/extendj/java5/scanner/Operators.flex \
    /Users/jesper/git/extension-base/extendj/java5/scanner/Keywords.flex \
    /Users/jesper/git/extension-base/extendj/java7/scanner/Literals.flex \
    /Users/jesper/git/extension-base/extendj/java8/scanner/Separators.flex \
    /Users/jesper/git/extension-base/extendj/java8/scanner/Operators.flex \
    /Users/jesper/git/extension-base/extendj/java5/scanner/Identifiers.flex \
    /Users/jesper/git/extension-base/extendj/java4/scanner/Postamble.flex \
    > "build/tmp/JavaScanner.flex"
mkdir -p "src/gen/java/scanner"
${JFLEX} -d "src/gen/java/scanner" --nobak "build/tmp/JavaScanner.flex"
echo "Generating parser..."
cat \
    /Users/jesper/git/extension-base/extendj/java4/parser/Header.parser \
    /Users/jesper/git/extension-base/extendj/java4/parser/Preamble.parser \
    /Users/jesper/git/extension-base/extendj/java4/parser/Java1.4.parser \
    /Users/jesper/git/extension-base/extendj/java5/parser/Annotations.parser \
    /Users/jesper/git/extension-base/extendj/java5/parser/EnhancedFor.parser \
    /Users/jesper/git/extension-base/extendj/java5/parser/Enums.parser \
    /Users/jesper/git/extension-base/extendj/java5/parser/GenericMethods.parser \
    /Users/jesper/git/extension-base/extendj/java5/parser/Generics.parser \
    /Users/jesper/git/extension-base/extendj/java5/parser/java14fix.parser \
    /Users/jesper/git/extension-base/extendj/java5/parser/StaticImports.parser \
    /Users/jesper/git/extension-base/extendj/java5/parser/VariableArityParameters.parser \
    /Users/jesper/git/extension-base/extendj/java7/parser/Diamond.parser \
    /Users/jesper/git/extension-base/extendj/java7/parser/Literals.parser \
    /Users/jesper/git/extension-base/extendj/java7/parser/MultiCatch.parser \
    /Users/jesper/git/extension-base/extendj/java7/parser/TryWithResources.parser \
    /Users/jesper/git/extension-base/extendj/java8/parser/ConstructorReference.parser \
    /Users/jesper/git/extension-base/extendj/java8/parser/InterfaceMethods.parser \
    /Users/jesper/git/extension-base/extendj/java8/parser/IntersectionCasts.parser \
    /Users/jesper/git/extension-base/extendj/java8/parser/Lambda.parser \
    /Users/jesper/git/extension-base/extendj/java8/parser/MethodReference.parser \
    /Users/jesper/git/extension-base/extendj/java8/parser/NonGenericTypes.parser \
    /Users/jesper/git/extension-base/extendj/java8/parser/PackageModifier.parser \
    > "build/tmp/JavaParser.all"
${JASTADDPARSER} "build/tmp/JavaParser.all" "build/tmp/JavaParser.beaver"
mkdir -p "src/gen/java/parser"
${BEAVER} -d "src/gen/java/parser" -t -c -w "build/tmp/JavaParser.beaver"
echo "Generating node types and weaving aspects..."
mkdir -p "src/gen/java"
${JASTADD} --package="org.extendj.ast" \
    --o="src/gen/java" \
    --rewrite=regular --beaver \
    --visitCheck=false --cacheCycle=false \
    --defaultMap="new org.jastadd.util.RobustMap(new java.util.HashMap())" \
    /Users/jesper/git/extension-base/extendj/java4/grammar/BoundNames.ast \
    /Users/jesper/git/extension-base/extendj/java4/grammar/Java.ast \
    /Users/jesper/git/extension-base/extendj/java4/grammar/NTAFinally.ast \
    /Users/jesper/git/extension-base/extendj/java4/frontend/DocumentationComments.jadd \
    /Users/jesper/git/extension-base/extendj/java4/frontend/DumpTree.jadd \
    /Users/jesper/git/extension-base/extendj/java4/frontend/LibCompilationUnits.jadd \
    /Users/jesper/git/extension-base/extendj/java4/frontend/Options.jadd \
    /Users/jesper/git/extension-base/extendj/java4/frontend/PathPart.jadd \
    /Users/jesper/git/extension-base/extendj/java4/frontend/PrettyPrint.jadd \
    /Users/jesper/git/extension-base/extendj/java4/frontend/StructuredPrettyPrint.jadd \
    /Users/jesper/git/extension-base/extendj/java4/frontend/AccessControl.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/AnonymousClasses.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/Arrays.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/BoundNames.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/BranchTarget.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/BytecodeCONSTANT.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/ClassfileParser.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/ClassPath.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/ConstantExpression.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/DataStructures.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/DeclareBeforeUse.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/DefiniteAssignment.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/ErrorCheck.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/ExceptionHandling.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/FrontendMain.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/LookupConstructor.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/LookupMethod.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/LookupType.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/LookupVariable.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/Modifiers.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/MonitorExit.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/NameCheck.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/NodeConstructors.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/NTAFinally.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/PositiveLiterals.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/PrettyPrintUtil.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/PrimitiveTypes.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/QualifiedNames.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/ResolveAmbiguousNames.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/SyntacticClassification.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/TypeAnalysis.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/TypeCheck.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/TypeHierarchyCheck.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/UnreachableStatements.jrag \
    /Users/jesper/git/extension-base/extendj/java4/frontend/VariableDeclaration.jrag \
    /Users/jesper/git/extension-base/extendj/java5/grammar/Annotations.ast \
    /Users/jesper/git/extension-base/extendj/java5/grammar/EnhancedFor.ast \
    /Users/jesper/git/extension-base/extendj/java5/grammar/Enums.ast \
    /Users/jesper/git/extension-base/extendj/java5/grammar/GenericMethods.ast \
    /Users/jesper/git/extension-base/extendj/java5/grammar/Generics.ast \
    /Users/jesper/git/extension-base/extendj/java5/grammar/StaticImports.ast \
    /Users/jesper/git/extension-base/extendj/java5/grammar/VariableArityParameters.ast \
    /Users/jesper/git/extension-base/extendj/java5/frontend/GLBTypeFactory.jadd \
    /Users/jesper/git/extension-base/extendj/java5/frontend/PrettyPrint.jadd \
    /Users/jesper/git/extension-base/extendj/java5/frontend/Annotations.jrag \
    /Users/jesper/git/extension-base/extendj/java5/frontend/AutoBoxing.jrag \
    /Users/jesper/git/extension-base/extendj/java5/frontend/BytecodeAttributes.jrag \
    /Users/jesper/git/extension-base/extendj/java5/frontend/BytecodeDescriptor.jrag \
    /Users/jesper/git/extension-base/extendj/java5/frontend/BytecodeSignatures.jrag \
    /Users/jesper/git/extension-base/extendj/java5/frontend/EnhancedFor.jrag \
    /Users/jesper/git/extension-base/extendj/java5/frontend/Enums.jrag \
    /Users/jesper/git/extension-base/extendj/java5/frontend/GenericBoundCheck.jrag \
    /Users/jesper/git/extension-base/extendj/java5/frontend/GenericMethods.jrag \
    /Users/jesper/git/extension-base/extendj/java5/frontend/GenericMethodsInference.jrag \
    /Users/jesper/git/extension-base/extendj/java5/frontend/Generics.jrag \
    /Users/jesper/git/extension-base/extendj/java5/frontend/GenericsArrays.jrag \
    /Users/jesper/git/extension-base/extendj/java5/frontend/GenericsParTypeDecl.jrag \
    /Users/jesper/git/extension-base/extendj/java5/frontend/GenericsSubtype.jrag \
    /Users/jesper/git/extension-base/extendj/java5/frontend/GenericTypeVariables.jrag \
    /Users/jesper/git/extension-base/extendj/java5/frontend/MethodSignature.jrag \
    /Users/jesper/git/extension-base/extendj/java5/frontend/ReifiableTypes.jrag \
    /Users/jesper/git/extension-base/extendj/java5/frontend/StaticImports.jrag \
    /Users/jesper/git/extension-base/extendj/java5/frontend/VariableArityParameters.jrag \
    /Users/jesper/git/extension-base/extendj/java6/frontend/Override.jrag \
    /Users/jesper/git/extension-base/extendj/java7/grammar/Diamond.ast \
    /Users/jesper/git/extension-base/extendj/java7/grammar/Literals.ast \
    /Users/jesper/git/extension-base/extendj/java7/grammar/MultiCatch.ast \
    /Users/jesper/git/extension-base/extendj/java7/grammar/TryWithResources.ast \
    /Users/jesper/git/extension-base/extendj/java7/frontend/Constant.jadd \
    /Users/jesper/git/extension-base/extendj/java7/frontend/PrettyPrint.jadd \
    /Users/jesper/git/extension-base/extendj/java7/frontend/Warnings.jadd \
    /Users/jesper/git/extension-base/extendj/java7/frontend/Diamond.jrag \
    /Users/jesper/git/extension-base/extendj/java7/frontend/Literals.jrag \
    /Users/jesper/git/extension-base/extendj/java7/frontend/MultiCatch.jrag \
    /Users/jesper/git/extension-base/extendj/java7/frontend/PreciseRethrow.jrag \
    /Users/jesper/git/extension-base/extendj/java7/frontend/PrettyPrint.jrag \
    /Users/jesper/git/extension-base/extendj/java7/frontend/SafeVarargs.jrag \
    /Users/jesper/git/extension-base/extendj/java7/frontend/StringsInSwitch.jrag \
    /Users/jesper/git/extension-base/extendj/java7/frontend/SuppressWarnings.jrag \
    /Users/jesper/git/extension-base/extendj/java7/frontend/TryWithResources.jrag \
    /Users/jesper/git/extension-base/extendj/java7/frontend/UncheckedConversion.jrag \
    /Users/jesper/git/extension-base/extendj/java8/grammar/ConstructorReference.ast \
    /Users/jesper/git/extension-base/extendj/java8/grammar/IntersectionCasts.ast \
    /Users/jesper/git/extension-base/extendj/java8/grammar/Lambda.ast \
    /Users/jesper/git/extension-base/extendj/java8/grammar/LambdaAnonymousDecl.ast \
    /Users/jesper/git/extension-base/extendj/java8/grammar/MethodReference.ast \
    /Users/jesper/git/extension-base/extendj/java8/frontend/PrettyPrint.jadd \
    /Users/jesper/git/extension-base/extendj/java8/frontend/Variable.jadd \
    /Users/jesper/git/extension-base/extendj/java8/frontend/Annotations.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/BytecodeReader.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/ConstructorReference.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/DataStructures.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/EffectivelyFinal.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/EnclosingLambda.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/ExtraInheritedEqs.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/FunctionalInterface.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/FunctionDescriptor.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/GenericsSubtype.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/LambdaBody.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/LambdaExpr.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/LookupType.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/LookupVariable.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/MethodReference.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/MethodSignature.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/Modifiers.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/NameCheck.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/PolyExpressions.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/QualifiedNames.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/TargetType.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/TypeCheck.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/TypeHierarchyCheck.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/TypeVariablePositions.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/UnreachableStatements.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/VariableArityParameters.jrag \
    /Users/jesper/git/extension-base/extendj/java8/frontend/VariableDeclaration.jrag \
    /Users/jesper/git/extension-base/src/jastadd/ExtensionBase.jrag
echo "Compiling Java code..."
mkdir -p build/classes/main
javac -d build/classes/main $(find src/java -name '*.java') \
    $(find src/gen -name '*.java') \
    $(find extendj/src/frontend -name '*.java') \
    extendj/src/frontend-main//org/extendj/ExtendJVersion.java \
    extendj/src/frontend-main//org/extendj/JavaChecker.java \
    extendj/src/frontend-main//org/extendj/JavaDumpFrontendErrors.java \
    extendj/src/frontend-main//org/extendj/JavaDumpTree.java \
    extendj/src/frontend-main//org/extendj/JavaPrettyPrinter.java \
    extendj/src/frontend-main//org/extendj/TokenCounter.java \
    extendj/java8/src/org/extendj/scanner/JavaScanner.java
mkdir -p src/gen-res
echo "moduleName: Java SE 8" > src/gen-res/BuildInfo.properties
echo "moduleVariant: frontend" >> src/gen-res/BuildInfo.properties
echo "timestamp: 2015-10-30T01:25Z" >> src/gen-res/BuildInfo.properties
echo "build.date: 2015-10-30" >> src/gen-res/BuildInfo.properties
jar cef org.extendj.ExtensionMain extension-base.jar -C build/classes/main $(find build/classes/main/ -name '*.class') \
    -C src/gen-res BuildInfo.properties \
    -C extendj/src/res Version.properties
