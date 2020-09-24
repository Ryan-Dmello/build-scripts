#!/bin/bash

export WORKDIR=`pwd`
export BUILD_VERSION=maistra-2.0

#sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/CentOS-PowerTools.repo
#Install libraries
dnf update -y
dnf install -y hostname git tar zip unzip python3 libtool wget vim patch bzip2 make tcl gettext cmake3 libatomic java-11-openjdk  java-11-openjdk-devel libstdc++ libstdc++-devel libstdc++-static file python2 python2-setuptools automake gcc gcc-c++ golang

#yum install -y gcc-toolset-9 gcc-toolset-9-gcc gcc-toolset-9-gcc-c++ gcc-toolset-9-libatomic-devel gcc-toolset-9-libgccjit gcc-toolset-9-libgccjit-devel pprof binutils-devel clang
#dnf install -y devtoolset-9-gcc devtoolset-9-gcc-c++ devtoolset-9-libgccjit devtoolset-9-libgccjit-devel pprof binutils-devel clang

#scl enable gcc-toolset-9 /bin/bash

export CC=/usr/bin/gcc
export CXX=/usr/bin/g++

#export CC=/opt/rh/gcc-toolset-9/root/usr/bin/gcc
#export CXX=/opt/rh/gcc-toolset-9/root/usr/bin/g++
wget https://github.com/moonjit/moonjit/archive/2.2.0.tar.gz && tar -xf 2.2.0.tar.gz && cd moonjit-2.2.0 && make && make install
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/usr/local/include/moonjit-2.2/

ln -s /usr/bin/python3 /usr/bin/python
# Set java environment
export JAVA_HOME=$(compgen -G '/usr/lib/jvm/java-11-openjdk-*')
export JRE_HOME=${JAVA_HOME}/jre
export PATH=${JAVA_HOME}/bin:$PATH

export BAZEL_VERSION=3.4.1
mkdir bazel_bin && cd bazel_bin
wget https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-dist.zip
unzip bazel-$BAZEL_VERSION-dist.zip
env EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk" bash ./compile.sh
mv output/bazel /usr/local/bin/.
bazel --version

# Install Go
#wget https://dl.google.com/go/go1.13.5.linux-ppc64le.tar.gz
#tar -C /usr/local -xzf go1.13.5.linux-ppc64le.tar.gz
#export GOROOT=/usr/local/go
#export GOPATH=$HOME/go
#export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
#rm -rf go1.13.5.linux-ppc64le.tar.gz
#go get github.com/bazelbuild/bazelisk
#export PATH=$PATH:$(go env GOPATH)/bin

export GOROOT=/usr/lib/golang
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# Compile and install ninja
cd $HOME
git clone git://github.com/ninja-build/ninja.git && cd ninja
git checkout v1.8.2
./configure.py --bootstrap
export PATH=/usr/local/bin:$PATH
ln -sf $HOME/ninja/ninja /usr/local/bin/ninja
ninja --version

# Compile and install gn
cd $HOME
git clone https://gn.googlesource.com/gn
cd gn
git checkout 992e927e217baa8a74e6e2c5d7417cb65cf24824
python build/gen.py
ninja -C out
cd out/
export PATH=$PATH:`pwd`

# download bazel-skylib
#cd $HOME
#git clone https://github.com/bazelbuild/bazel-skylib.git

#git clone https://boringssl.googlesource.com/boringssl
#cd boringssl
#mkdir build
#cd build
#cmake .. && make
#
#cp -r $HOME/boringssl/include/openssl/*.h /usr/include/openssl/.

#Build envoy
cd $HOME
git clone https://github.com/Maistra/envoy.git
cd envoy/
git checkout $BUILD_VERSION
git apply $WORKDIR/patches/envoy.patch
go get -u github.com/bazelbuild/buildtools/buildifier
go get -u github.com/bazelbuild/buildtools/buildozer

export BAZEL_BUILD_ARGS="--host_javabase=@local_jdk//:jdk --verbose_failures --copt \"-DENVOY_IGNORE_GLIBCXX_USE_CXX11_ABI_ERROR=1\"  --copt \"-w\" --cxxopt=-Wimplicit-fallthrough=0 --cxxopt=-std=gnu++0x --host_force_python=PY3"
#bazel build -c opt //source/exe:envoy-static
#--verbose_failures --copt "-DENVOY_IGNORE_GLIBCXX_USE_CXX11_ABI_ERROR=1" --host_force_python=PY3 --cxxopt=-std=gnu++0x

cat $WORKDIR/patches/test_names.txt | xargs bazel test  --test_env=ENVOY_IP_TEST_VERSIONS=v4only
#bazel test //test/... --test_env=ENVOY_IP_TEST_VERSIONS=v4only -
#-test_timeout=3600 --host_javabase=@local_jdk//:jdk --host_force_python=PY3 --copt "-DENVOY_IGNORE_GLIBCXX_USE_CXX11_ABI_ERROR=1"

