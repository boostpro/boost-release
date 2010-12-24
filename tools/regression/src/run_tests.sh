#!/bin/sh
#
# shell script for running the boost regression test suite and generating
# a html table of results.

# Set the following variables to configure the operation. Variables you
# should set, i.e. usually required are listed first. Optional variables
# have reasonable defaults for most situations.


### THESE SHOULD BE CHANGED!

#
# "boost_root" points to the root of you boost installation:
# This can be either a non-exitent directory or an already complete Boost
# source tree.
#
boost_root="/usr/src/redhat/BUILD/boost_1_34_1"

#
# Wether to fetch the most current Boost code from CVS (yes/no):
# There are two contexts to use this script in: on an active Boost CVS
# tree, and on a fresh Boost CVS tree. If "yes" is specified here an attempt
# to fetch the latest CVS Boost files is made. For an active Boost CVS
# the CVS connection information is used. If an empty tree is detected
# the code is fetched with the anonymous read only information.
#
cvs_update=no

#
# "test_tools" are the Boost.Build toolsets to use for building and running the
# regression tests. Specify a space separated list, of the Boost.Build toolsets.
# Each will be built and tested in sequence.
#
test_tools=gcc

#
# "toolset" is the Boost.Build toolset to use for building the helper programs.
# This is usually different than the toolsets one is testing. And this is
# normally a toolset that corresponds to the compiler built into your platform.
#
toolset=gcc

#
# "test_dir" is the relative path to the directory to run the tests in,
# defaults to "status" and runs all the tests, but could be a sub-directory
# for example "libs/regex/test" to run the regex tests alone.
#
test_dir="status"

#
# "comment_path" is the path to an html-file describing the test environment.
# The content of this file will be embedded in the status pages being produced.
#
comment_path="$boost_root/$test_dir/regression_comment.html"


### DEFAULTS ARE OK FOR THESE.

#
# "exe_suffix" the suffix used by exectable files:
# In case your platform requires use of a special suffix for executables specify
# it here, including the "." if needed. This should not be needed even in Windows
# like platforms as they will execute without the suffix anyway.
#
exe_suffix=

#
# "bjam" points to your built bjam executable:
# The location of the binary for running bjam. The default should work
# under most circumstances.
#
bjam="$boost_root/tools/jam/src/bin/bjam$exe_suffix"

# bjam options
bjam_flags="--layout=system variant=release -sICU_PATH=/usr --user-config=$boost_root/user-config.jam"

#
# "process_jam_log", and "compiler_status" paths to built helper programs:
# The location of the executables of the regression help programs. These
# are built locally so the default should work in most situations.
#
process_jam_log="$boost_root/dist/bin/process_jam_log$exe_suffix"
compiler_status="$boost_root/dist/bin/compiler_status$exe_suffix"

#
# "boost_build_path" can point to additional locations to find toolset files.
#
boost_build_path="$HOME/.boost-build"


### NO MORE CONFIGURABLE PARTS.

#
# Some setup.
#
boost_dir=`basename "$boost_root"`
if test -n "${BOOST_BUILD_PATH}" ; then
    BOOST_BUILD_PATH="$boost_build_path:$BOOST_BUILD_PATH"
else
    BOOST_BUILD_PATH="$boost_build_path"
fi
export BOOST_BUILD_PATH

# For shared objects.
old_ld_library_path=$LD_LIBRARY_PATH
old_ld_run_path=$LD_RUN_PATH
LD_LIBRARY_PATH="$boost_root/stage/lib:$old_ld_library_path"
LD_RUN_PATH="$boost_root/stage/lib:$old_ld_run_path"
export LD_LIBRARY_PATH
export LD_RUN_PATH

#
# STEP 0:
#
# Get the source code:
#
if test ! -d "$boost_root" ; then
    mkdir -p "$boost_root"
    if test $? -ne 0 ; then
        echo "creation of $boost_root directory failed."
        exit 256
    fi
fi
if test $cvs_update = yes ; then
    echo fetching Boost:
    echo "/1 :pserver:anonymous@cvs.sourceforge.net:2401/cvsroot/boost A" >> "$HOME/.cvspass"
    cat "$HOME/.cvspass" | sort | uniq > "$HOME/.cvspass"
    cd `dirname "$boost_root"`
    if test -f boost/CVS/Root ; then
        cvs -z3 -d `cat "$boost_dir/CVS/Root"` co -d "$boost_dir" boost
    else
        cvs -z3 -d :pserver:anonymous@cvs.sourceforge.net:2401/cvsroot/boost co -d "$boost_dir" boost
    fi
fi

#
# STEP 1:
# rebuild bjam if required:
#
echo "finding or building bjam":
if test ! -f "$bjam" ; then
  echo "building bjam":
    cd "$boost_root/tools/jam/src" && \
    LOCATE_TARGET=bin sh ./build.sh
    if test $? != 0 ; then
      echo "bjam build failed."
      exit 256
    fi
fi

#
# STEP 2:
# rebuild the regression test helper programs if required:
#
echo building regression test helper programs:
cd "$boost_root/tools/regression/build" && "$bjam" $bjam_flags $toolset
if test $? != 0 ; then
    echo "helper program build failed."
    exit 256
fi

#
# STEP 5:
# repeat steps 3 and 4 for each additional toolset:
#
for tool in $test_tools ; do

#
# STEP 3:
# run the regression tests:
#
echo running the $tool regression tests:
cd "$boost_root/$test_dir"
echo "<p> begin time: " `date` "</p>" >> "$comment_path"
"$bjam" $bjam_flags $tool --dump-tests 2>&1 | tee regress.log
echo "<p> end time: " `date` "</p>" >> "$comment_path"

#
# STEP 4:
# post process the results:
#
echo processing the regression test results for $tool:
cat regress.log | "$process_jam_log" --v2
if test $? != 0 ; then
    echo "Failed regression log post processing."
    exit 256
fi

done

#
# STEP 6:
# create the html table:
#
uname=`uname`
echo generating html tables:
"$compiler_status" --v2  --comment "$comment_path" "$boost_root" cs-$uname.html cs-$uname-links.html
if test $? != 0 ; then
    echo "Failed HTML result table generation."
    exit 256
fi

# cleanup
LD_LIBRARY_PATH="$old_ld_library_path"
LD_RUN_PATH="$old_ld_run_path"
export LD_LIBRARY_PATH
export LD_RUN_PATH

echo "done!"



