#!/bin/bash
set -eu
source config.sh # Configure the build with this file.
mkdir -p "build/tmp"
echo "Generating scanner..."
cat \
    'extendj/java4/scanner/Header.flex' \
    'extendj/java8/scanner/Preamble.flex' \
    'extendj/java7/scanner/Macros.flex' \
    'extendj/java4/scanner/RulesPreamble.flex' \
    'extendj/java4/scanner/WhiteSpace.flex' \
    'extendj/java4/scanner/Comments.flex' \
    'extendj/java4/scanner/Keywords.flex' \
    'extendj/java4/scanner/Operators.flex' \
    'extendj/java4/scanner/Separators.flex' \
    'extendj/java5/scanner/Operators.flex' \
    'extendj/java5/scanner/Keywords.flex' \
    'extendj/java7/scanner/Literals.flex' \
    'extendj/java8/scanner/Separators.flex' \
    'extendj/java8/scanner/Operators.flex' \
    'extendj/java5/scanner/Identifiers.flex' \
    'extendj/java4/scanner/Postamble.flex' \
    > "build/tmp/JavaScanner.flex"
mkdir -p "src/gen/java/scanner"
${JFLEX} -d "src/gen/java/scanner" --nobak "build/tmp/JavaScanner.flex"
echo "Generating parser..."
cat \
    'extendj/java4/parser/Header.parser' \
    'extendj/java4/parser/Preamble.parser' \
    'extendj/java4/parser/Java1.4.parser' \
    'extendj/java5/parser/java14fix.parser' \
    'extendj/java5/parser/VariableArityParameters.parser' \
    'extendj/java5/parser/StaticImports.parser' \
    'extendj/java5/parser/Annotations.parser' \
    'extendj/java5/parser/EnhancedFor.parser' \
    'extendj/java5/parser/Enums.parser' \
    'extendj/java5/parser/GenericMethods.parser' \
    'extendj/java5/parser/Generics.parser' \
    'extendj/java7/parser/MultiCatch.parser' \
    'extendj/java7/parser/Diamond.parser' \
    'extendj/java7/parser/Literals.parser' \
    'extendj/java7/parser/TryWithResources.parser' \
    'extendj/java8/parser/PackageModifier.parser' \
    'extendj/java8/parser/NonGenericTypes.parser' \
    'extendj/java8/parser/InterfaceMethods.parser' \
    'extendj/java8/parser/MethodReference.parser' \
    'extendj/java8/parser/IntersectionCasts.parser' \
    'extendj/java8/parser/ConstructorReference.parser' \
    'extendj/java8/parser/Lambda.parser' \
    > "build/tmp/JavaParser.all"
${JASTADDPARSER} "build/tmp/JavaParser.all" "build/tmp/JavaParser.beaver"
mkdir -p "src/gen/java/parser"
${BEAVER} -d "src/gen/java/parser" -t -c -w "build/tmp/JavaParser.beaver"
echo "Generating node types and weaving aspects..."
mkdir -p "src/gen/java"
${JASTADD} \
    --package="org.extendj.ast" \
    --o="src/gen/java" \
    --rewrite=regular \
    --beaver \
    --visitCheck=false \
    --cacheCycle=false \
    'extendj/java4/grammar/NTAFinally.ast' \
    'extendj/java4/grammar/Java.ast' \
    'extendj/java4/grammar/BoundNames.ast' \
    'extendj/java4/frontend/DocumentationComments.jadd' \
    'extendj/java4/frontend/PrettyPrint.jadd' \
    'extendj/java4/frontend/PathPart.jadd' \
    'extendj/java4/frontend/DumpTree.jadd' \
    'extendj/java4/frontend/Options.jadd' \
    'extendj/java4/frontend/StructuredPrettyPrint.jadd' \
    'extendj/java4/frontend/LibCompilationUnits.jadd' \
    'extendj/java4/frontend/ResolveAmbiguousNames.jrag' \
    'extendj/java4/frontend/LookupType.jrag' \
    'extendj/java4/frontend/Arrays.jrag' \
    'extendj/java4/frontend/LookupConstructor.jrag' \
    'extendj/java4/frontend/MonitorExit.jrag' \
    'extendj/java4/frontend/BytecodeCONSTANT.jrag' \
    'extendj/java4/frontend/ClassfileParser.jrag' \
    'extendj/java4/frontend/NameCheck.jrag' \
    'extendj/java4/frontend/TypeAnalysis.jrag' \
    'extendj/java4/frontend/DataStructures.jrag' \
    'extendj/java4/frontend/NodeConstructors.jrag' \
    'extendj/java4/frontend/TypeCheck.jrag' \
    'extendj/java4/frontend/VariableDeclaration.jrag' \
    'extendj/java4/frontend/QualifiedNames.jrag' \
    'extendj/java4/frontend/SyntacticClassification.jrag' \
    'extendj/java4/frontend/UnreachableStatements.jrag' \
    'extendj/java4/frontend/PrettyPrintUtil.jrag' \
    'extendj/java4/frontend/ExceptionHandling.jrag' \
    'extendj/java4/frontend/BoundNames.jrag' \
    'extendj/java4/frontend/PositiveLiterals.jrag' \
    'extendj/java4/frontend/AccessControl.jrag' \
    'extendj/java4/frontend/ConstantExpression.jrag' \
    'extendj/java4/frontend/PrimitiveTypes.jrag' \
    'extendj/java4/frontend/AnonymousClasses.jrag' \
    'extendj/java4/frontend/NTAFinally.jrag' \
    'extendj/java4/frontend/ErrorCheck.jrag' \
    'extendj/java4/frontend/BranchTarget.jrag' \
    'extendj/java4/frontend/LookupMethod.jrag' \
    'extendj/java4/frontend/DefiniteAssignment.jrag' \
    'extendj/java4/frontend/LookupVariable.jrag' \
    'extendj/java4/frontend/TypeHierarchyCheck.jrag' \
    'extendj/java4/frontend/FrontendMain.jrag' \
    'extendj/java4/frontend/ClassPath.jrag' \
    'extendj/java4/frontend/DeclareBeforeUse.jrag' \
    'extendj/java4/frontend/Modifiers.jrag' \
    'extendj/java5/grammar/Generics.ast' \
    'extendj/java5/grammar/VariableArityParameters.ast' \
    'extendj/java5/grammar/EnhancedFor.ast' \
    'extendj/java5/grammar/Annotations.ast' \
    'extendj/java5/grammar/Enums.ast' \
    'extendj/java5/grammar/GenericMethods.ast' \
    'extendj/java5/grammar/StaticImports.ast' \
    'extendj/java5/frontend/PrettyPrint.jadd' \
    'extendj/java5/frontend/GLBTypeFactory.jadd' \
    'extendj/java5/frontend/StaticImports.jrag' \
    'extendj/java5/frontend/ReifiableTypes.jrag' \
    'extendj/java5/frontend/Enums.jrag' \
    'extendj/java5/frontend/GenericsArrays.jrag' \
    'extendj/java5/frontend/BytecodeSignatures.jrag' \
    'extendj/java5/frontend/Annotations.jrag' \
    'extendj/java5/frontend/BytecodeDescriptor.jrag' \
    'extendj/java5/frontend/VariableArityParameters.jrag' \
    'extendj/java5/frontend/Generics.jrag' \
    'extendj/java5/frontend/GenericMethodsInference.jrag' \
    'extendj/java5/frontend/GenericsParTypeDecl.jrag' \
    'extendj/java5/frontend/MethodSignature.jrag' \
    'extendj/java5/frontend/GenericsSubtype.jrag' \
    'extendj/java5/frontend/GenericTypeVariables.jrag' \
    'extendj/java5/frontend/GenericMethods.jrag' \
    'extendj/java5/frontend/EnhancedFor.jrag' \
    'extendj/java5/frontend/BytecodeAttributes.jrag' \
    'extendj/java5/frontend/GenericBoundCheck.jrag' \
    'extendj/java5/frontend/AutoBoxing.jrag' \
    'extendj/java6/frontend/Override.jrag' \
    'extendj/java7/grammar/Diamond.ast' \
    'extendj/java7/grammar/MultiCatch.ast' \
    'extendj/java7/grammar/Literals.ast' \
    'extendj/java7/grammar/TryWithResources.ast' \
    'extendj/java7/frontend/PrettyPrint.jadd' \
    'extendj/java7/frontend/Constant.jadd' \
    'extendj/java7/frontend/Warnings.jadd' \
    'extendj/java7/frontend/Diamond.jrag' \
    'extendj/java7/frontend/MultiCatch.jrag' \
    'extendj/java7/frontend/SuppressWarnings.jrag' \
    'extendj/java7/frontend/PreciseRethrow.jrag' \
    'extendj/java7/frontend/StringsInSwitch.jrag' \
    'extendj/java7/frontend/SafeVarargs.jrag' \
    'extendj/java7/frontend/UncheckedConversion.jrag' \
    'extendj/java7/frontend/PrettyPrint.jrag' \
    'extendj/java7/frontend/Literals.jrag' \
    'extendj/java7/frontend/TryWithResources.jrag' \
    'extendj/java8/grammar/LambdaAnonymousDecl.ast' \
    'extendj/java8/grammar/MethodReference.ast' \
    'extendj/java8/grammar/ConstructorReference.ast' \
    'extendj/java8/grammar/Lambda.ast' \
    'extendj/java8/grammar/IntersectionCasts.ast' \
    'extendj/java8/frontend/PrettyPrint.jadd' \
    'extendj/java8/frontend/Variable.jadd' \
    'extendj/java8/frontend/LookupType.jrag' \
    'extendj/java8/frontend/TypeVariablePositions.jrag' \
    'extendj/java8/frontend/FunctionalInterface.jrag' \
    'extendj/java8/frontend/Annotations.jrag' \
    'extendj/java8/frontend/FunctionDescriptor.jrag' \
    'extendj/java8/frontend/NameCheck.jrag' \
    'extendj/java8/frontend/VariableArityParameters.jrag' \
    'extendj/java8/frontend/DataStructures.jrag' \
    'extendj/java8/frontend/EnclosingLambda.jrag' \
    'extendj/java8/frontend/TypeCheck.jrag' \
    'extendj/java8/frontend/VariableDeclaration.jrag' \
    'extendj/java8/frontend/LambdaExpr.jrag' \
    'extendj/java8/frontend/BytecodeReader.jrag' \
    'extendj/java8/frontend/EffectivelyFinal.jrag' \
    'extendj/java8/frontend/ConstructorReference.jrag' \
    'extendj/java8/frontend/QualifiedNames.jrag' \
    'extendj/java8/frontend/MethodSignature.jrag' \
    'extendj/java8/frontend/UnreachableStatements.jrag' \
    'extendj/java8/frontend/GenericsSubtype.jrag' \
    'extendj/java8/frontend/LambdaBody.jrag' \
    'extendj/java8/frontend/TargetType.jrag' \
    'extendj/java8/frontend/ExtraInheritedEqs.jrag' \
    'extendj/java8/frontend/PolyExpressions.jrag' \
    'extendj/java8/frontend/LookupVariable.jrag' \
    'extendj/java8/frontend/TypeHierarchyCheck.jrag' \
    'extendj/java8/frontend/Modifiers.jrag' \
    'extendj/java8/frontend/MethodReference.jrag' \
    'src/jastadd/ExtensionBase.jrag' ${EXTRA_JASTADD_SOURCES}
echo "Compiling Java code..."
mkdir -p build/classes/main
javac -d build/classes/main $(find src/java -name '*.java') \
    $(find src/gen -name '*.java') \
    $(find extendj/src/frontend -name '*.java') ${EXTRA_JAVA_SOURCES}
mkdir -p src/gen-res
echo "moduleName: Java SE 8" > src/gen-res/BuildInfo.properties
echo "moduleVariant: frontend" >> src/gen-res/BuildInfo.properties
echo "timestamp: 2016-02-01T16:01Z" >> src/gen-res/BuildInfo.properties
echo "build.date: 2016-02-01" >> src/gen-res/BuildInfo.properties
jar cef "org.extendj.ExtensionMain" "extension-base.jar" \
    -C build/classes/main . \
    -C src/gen-res BuildInfo.properties \
    -C extendj/src/res Version.properties
