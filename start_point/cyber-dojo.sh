#!/bin/bash

# ScalaTest finds your tests for you. Every class in the compiled output that
# extends one of its Suite types is run, wherever its source file sits, and
# whether or not anything else mentions it. There is no list to add a new test
# file to.
#
# Scala does not tie a class to the name of the file holding it, so you can
# rename these files, or put several classes in one, and everything still runs.
# The one name that matters is the extension: a file has to end .scala to be
# compiled at all, and one that does not is left where it is.

# ScalaTest, and the Scala standard library your compiled code runs against.
# Both were resolved into this container when its image was built. There is no
# internet access here, so these are all there is.
CLASSPATH_JARS=$(ls /scala/*.jar /scalatest/*.jar | tr '\n' ':')
CLASSPATH=${CLASSPATH_JARS%:}

# Compiled classes go here rather than beside your source, so that a .class
# file never turns up among your own files.
CLASSES=/tmp/classes
mkdir -p "${CLASSES}"

# Both JVMs below replay an ahead-of-time cache recorded when this image was
# built. Reading one back is a fraction of the cost of loading the same classes
# from the jars again, which is what a fresh container would otherwise do on
# every test run. Cache logging is off because a JVM that cannot use a cache
# says so on stdout, and that belongs in a build log rather than in front of
# you. Nothing is lost when a cache cannot be used; the run is only slower.
#
# Your own classes are in neither cache, so editing them cannot spoil one.

COMPILER_JVM_OPTS=()
COMPILER_JVM_OPTS+=(-Xmx768m)                              # the heap the scalac launcher gives itself
COMPILER_JVM_OPTS+=(-Xms768m)                              # taking it up front saves growing it
COMPILER_JVM_OPTS+=(-XX:TieredStopAtLevel=1)               # a run is under a second; later tiers never repay
COMPILER_JVM_OPTS+=(-XX:+UseSerialGC)                      # a JVM this short-lived collects almost nothing
COMPILER_JVM_OPTS+=(--sun-misc-unsafe-memory-access=allow) # the standard library still calls sun.misc.Unsafe
COMPILER_JVM_OPTS+=(-XX:AOTCache=/aot/scalac.aot)          # the compiler's own classes
COMPILER_JVM_OPTS+=(-Xlog:aot*=off)                        # a refused cache is not your problem to read about

TEST_JVM_OPTS=()
TEST_JVM_OPTS+=(-Xmx768m)                                  # as above, for the JVM running your tests
TEST_JVM_OPTS+=(-Xms768m)                                  # as above
TEST_JVM_OPTS+=(-XX:TieredStopAtLevel=1)                   # as above
TEST_JVM_OPTS+=(-XX:+UseSerialGC)                          # as above
TEST_JVM_OPTS+=(--sun-misc-unsafe-memory-access=allow)     # as above
TEST_JVM_OPTS+=(-XX:AOTCache=/aot/scalatest.aot)           # ScalaTest's classes
TEST_JVM_OPTS+=(-Xlog:aot*=off)                            # as above

# Every .scala file is compiled, however deep it sits, so a file you add is
# checked whether or not anything else refers to it yet. One that will not
# compile stops the run and says why, rather than being passed over in silence.
shopt -s globstar nullglob
SOURCES=(**/*.scala)

SCALAC_OPTS=()
SCALAC_OPTS+=(-color:never)              # an error is read here, not in a terminal that draws colours
SCALAC_OPTS+=(-classpath "${CLASSPATH}") # what your code may import
SCALAC_OPTS+=(-d "${CLASSES}")           # where the compiled classes go

# scalac reads JAVA_OPTS to decide how to start its own JVM. Its own options,
# above, are a separate thing from that JVM's.
JAVA_OPTS="${COMPILER_JVM_OPTS[*]}" \
  scalac "${SCALAC_OPTS[@]}" "${SOURCES[@]}"
compiled=$?
if [ ${compiled} -ne 0 ]; then
  exit ${compiled}
fi

# -R is the runpath ScalaTest searches for suites to run, and -oW writes the
# results to stdout without the colour codes a terminal would need.
java "${TEST_JVM_OPTS[@]}" \
  -classpath "${CLASSPATH}" \
  org.scalatest.tools.Runner \
  -R "${CLASSES}" \
  -oW
