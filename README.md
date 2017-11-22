# tensorflow-build

A set of scripts to (cross-)build the Tensorflow C lib for various architectures / OS

**The goal of this repo is to provide packages containing the `libtensorflow_c.so` file as well as a corresponding `pc` file so that is `.so` can be used with `pkg-config`** (one use of this is linking tensorflow with rust programs, see the bonus at the end)

We're using these scripts on Ubuntu and Archlinux, the commands given below assume that you're on a fairly recent Ubuntu box.

Theses script are a WIP but a good starting point on how to cross compile tensorflow. Expect to have to edit and tweak them to fit your needs.

Supported OS / Arch: 

OS | Available archs
---|---
Debian Like | `armhf` [[deb]](https://s3.amazonaws.com/snips/tensorflow-deb/libtensorflow_1.3.1-snips-2_armhf.deb) (raspbian, crosscompiled, tested on Raspberry Pi 0, 2 & 3) <br> `amd64` [[deb]](https://s3.amazonaws.com/snips/tensorflow-deb/libtensorflow_1.3.1-snips-2_amd64.deb)
Android | `armeabi-v7a` [[sysroot overlay]](https://s3.amazonaws.com/snips/tensorflow-android/tensorflow-android-armeabi-v7a-1.3.1-snips-2.tar.gz) <br> `arm64-v8a` [[sysroot overlay]](https://s3.amazonaws.com/snips/tensorflow-android/tensorflow-android-arm64-v8a-1.3.1-snips-2.tar.gz) <br> `x86` [[sysroot overlay]](https://s3.amazonaws.com/snips/tensorflow-android/tensorflow-android-x86-1.3.1-snips-2.tar.gz) <br> `x86_64` [[sysroot overlay]](https://s3.amazonaws.com/snips/tensorflow-android/tensorflow-android-x86_64-1.3.1-snips-2.tar.gz)
iOS | [[sysroot overlay]](https://s3.amazonaws.com/snips/tensorflow-android/tensorflow-ios-1.3.1-snips-2.tar.gz)
Archlinux | `i686` / `x86_64` use this aur [[PKGBUILD]](https://aur.archlinux.org/packages/tensorflow-git/)
macOS | `x86_64` `brew install libtensorflow`


## Installing the dependencies

### Installing bazel
Before runing these scripts, you need to have `bazel`

```
$ echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
$ curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -
$ sudo apt-get update
$ sudo apt-get install bazel
```

### Other build dependencies

You'll also need numpy 

```
$ sudo apt-get install python3-numpy
```

## Using the scripts

Here is a small description of interesting scripts in this repo

Script | Description
--- | ---
`compile.sh` | Clones and build tensorflow for current machine. Takes the tensorflow version as a parameter
`cross-compile.sh` | Generic script for cloning and building tensorflow using a cross toolchain. Launch it without args for usage
`compile-arm.sh` | Clones the `raspberry/tools` repository an launches a cross compilation using the toolchain in it. Takes the tensorflow version as a parameter
`compile-android.sh` | Download Android NDK and launch a crosscompilation for android using it. Takes the tensorflow version, android arch and package version as parameters
`compile-ios.sh` | Clone and build tensorflow for iOS with the C API.
`create-pkgconfig.sh` | Generic script for creating a pc. Launch it without args for usage

### Building a deb
```
$ cd debian
$ ./create-deb-native.sh # or ./create-deb-armhf.sh then go grab a cup of coffee
$ sudo dpkg -i target/libtensorflow_1.0.0-snips-5_amd64.deb

```

## Bonus : Using with Rust

You can use tensorflow with your rust projects using the `tensorflow` crate, its dependency `tensorflow-sys` will seek the `libtensorflow_c.so` using pkgconfig and build it if it doesn't find it, which can take some time...

### Native build

Install the package then `cargo build` should find the lib \o/


### Cross compile build

For cross compilation, you need a few more steps, the examples below are for a building for a Raspberry Pi 2/3 from a linux box

First, you need the rust target for the Pi

```
$ rustup target install armv7-unknown-linux-gnueabihf
```

Then you need a toolchain for the pi, let's use the one provided by RaspberryPi 

```
$ git clone https://github.com/raspberrypi/tools
```

Configure cargo to use the toochain by adding this snippet to you `~/.cargo/config`

```
[target.armv7-unknown-linux-gnueabihf]
linker = "/path/to/raspberrypi/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf-gcc"

```

We now need the `.so` file of tensorflow for the target arch, let's build the 1.0.0

```
$ ./compile-arm.sh v1.0.0
```

The `.so` is located in `target/tensorflow/bazel-bin/tensorflow/libtensorflow.so` you may want to move it somewhere else

Let's then generate the `.pc` file

```
$ ./create-pkgconfig.sh tensorflow_c /folder/where/the/so/is 1.0.0 "Tensorflow C Library" > /path/to/pc/file
```

Now that all is done, we can use cargo to crossbuild the app

```
$ PKG_CONFIG_LIBDIR=/folder/where/the/pcfile/is PKG_CONFIG_ALLOW_CROSS=1 cargo build
```

Enjoy!
