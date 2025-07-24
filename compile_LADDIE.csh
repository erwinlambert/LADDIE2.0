#! /bin/csh -f

# Compile all the LADDIE code.
#
# Usage: ./compile_LADDIE.csh  [VERSION]  [SELECTION]
#
#   [VERSION]: dev, perf
#
#     dev : developer's version; extra compiler flags (see Makefile_include, COMPILER_FLAGS_CHECK),
#           plus run-time assertions (i.e. DO_ASSERTIONS = true) and resource tracking (i.e.
#           DO_RESOURCE_TRACKING = true). Useful for tracking coding errors, but slow.
#
#     perf: performance version; all of the above disabled. Coding errors will much more often
#           simply result in segmentation faults, but runs much faster.
#
#   [SELECTION]: changed, clean
#
#     changed: (re)compile only changed modules. Works 99% of the time, fails when you change the
#              definition of a derived type without recompiling all of the modules thst use that
#              type. In that case, better to just do a clean compilation.
#
#     clean: recompile all modules. Always works, but slower.
#

# Safety
if ($#argv != 1) goto usage

echo ""

set selection = $argv[1]
if ($selection == 'changed') then
  echo "changed: (re)compiling changed modules only"
else if ($selection == 'clean') then
  echo "clean: recompiling all modules"
else
  goto usage
endif

echo ""

# If no build directory exists, create it
if (! -d build) mkdir build

# For a "clean" build, remove all build files first
if ($selection == 'clean') rm -rf build/*

# For a "changed" build, remove only the CMake cache file
if ($selection == 'changed') rm -f build/CMakeCache.txt

# Use CMake to build LADDIE, with Ninja to determine module dependencies;
# use different compiler flags for the development/performance build
cd build


cmake -G Ninja -DPETSC_DIR=`brew --prefix petsc` \
  -DDO_ASSERTIONS=OFF \
  -DDO_RESOURCE_TRACKING=OFF \
  -DEXTRA_Fortran_FLAGS="\
    -fdiagnostics-color=always;\
    -O3;\
    -Wall;\
    -ffree-line-length-none;\
    -cpp;\
    -fimplicit-none;\
    -g;\
    -march=native" ..

ninja -v
cd ..

# Copy compiled program
rm -f LADDIE_program
mv build/LADDIE_program LADDIE_program

exit 0

usage:

echo ""
echo "Usage: ./compile_LADDIE.csh  [VERSION]  [SELECTION]"
echo ""
echo "  [VERSION]: dev, perf"
echo ""
echo "    dev : developer's version; extra compiler flags (see Makefile_include, COMPILER_FLAGS_CHECK),"
echo "          plus run-time assertions (i.e. DO_ASSERTIONS = true) and resource tracking (i.e."
echo "          DO_RESOURCE_TRACKING = true). Useful for tracking coding errors, but slow."
echo ""
echo "    perf: performance version; all of the above disabled. Coding errors will much more often"
echo "          simply result in segmentation faults, but runs much faster."
echo ""
echo "  [SELECTION]: changed, clean"
echo ""
echo "    changed: (re)compile only changed modules. Works 99% of the time, fails when you change the"
echo "             definition of a derived type without recompiling all of the modules thst use that"
echo "             type. In that case, better to just do a clean compilation."
echo ""
echo "    clean: recompile all modules. Always works, but slower."
echo ""

exit 1
