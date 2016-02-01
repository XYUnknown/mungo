#!/bin/bash
set -eu
JFLEX="java -jar extendj/tools/jflex-1.6.1.jar"
BEAVER="java -jar tools/beaver-cc-0.9.11.jar"
JASTADDPARSER="java -jar extendj/tools/JastAddParser.jar"
JASTADD="java -jar extendj/tools/jastadd2.jar"
EXTRA_JASTADD_SOURCES=""
EXTRA_JAVA_SOURCES="extendj/src/frontend-main/org/extendj/JavaChecker.java extendj/src/frontend-main/org/extendj/ExtendJVersion.java extendj/java8/src/org/extendj/scanner/JavaScanner.java"
