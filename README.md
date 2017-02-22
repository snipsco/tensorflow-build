# tensorflow-build

A set of tools to build the tensorflow c lib for various architectures / OS

The goal is to provide packages containing the `libtensorflow_c.so` file as well as a corresponding `pc` file so that is .so can be used with `pkg-config` (one use of this is using tensorflow with rust, see the bonus at the end)

## Installing the dependencies

### Installing bazel
Before runing these scripts, you need to have `bazel` version `0.4.3` in your path **version 0.4.4 will not work** 

Here are some commands to install it on a recent ubuntu machine :

```
$ echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
$ curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -
$ sudo apt-get install bazel=0.4.3
```

### Other build dependencies

You'll also need numpy 

```
$ sudo apt-get install python3-numpy
```

## Using the scripts

Here is a small description of interesing scripts in this repo

Script | Description
--- | ---
compile-arm.sh | clones the `raspberry/tools` repository an launches a cross compilation using the toolchain in it. Takes the tensorflow version as a parameter
compile.sh | clones and build build tensorflow for current machine. Takes the tensorflow version as a parameter
create-deb-armhf.sh | builds tensorflow for `armhf` and pakages it in a `deb` file. You need to be on a debian based system, deb is output in `target` dir
create-deb-native.sh | builds tensorflow for `amd64` and pakages it in a `deb` file. You need to be on a debian based system, deb is output in `target` dir
create-deb.sh | Generic script for creating a deb. Launch it without args for usage
create-pkgconfig.sh | Generic script for creating a pc. Launch it without args for usage
cross-compile.sh | Generic script for cloning and building tensorflow using a cross toolchain. Launch it without args for usage

### Building a deb

Just launch `create-deb-armhf.sh` or `create-deb-native.sh` and go for a cup of coffee, the .deb will be created in the `target` repository 

### Building for archlinux

A `PKGBUILD` is provided in the `archlinux` folder running `makepkg` in in ths folder should be all that you need


## Bonus : Using with Rust

You can use tensorflow with your rust projects using the `tensorflow` crate, its dependency, `tensorflow-sys` will seek the `libtensorflow\_c.so` using pkgconfig and build it if it doesn't find it

### Native build

Install the package then `cargo build` should find the lib \o/


### Cross crompile build

For cross compilation, you need a few more steps, the examples below are for a building for a Raspberry Pi 2/3 from a linux box

First, you need the rust target for the Pi

```
$ rustup target install armv7-unknown-linux-gnueabihf
```

Then you need a toolchain for the pi, let's use the one provided by RaspberryPi 

```
git clone https://github.com/raspberrypi/tools
```

Configure cargo to use the toochain by adding this snippet to you `~/.cargo/config`

```
[target.armv7-unknown-linux-gnueabihf]
linker = "/path/to/raspberrypi/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf-gcc"

```

We now need the `.so` file of tensorflow for the target arch, let's build the 1.0.0

```
./compile-arm.sh v1.0.0
```

The `.so` is located in `target/tensorflow/bazel-bin/tensorflow/libtensorflow_c.so` you may want to move it somewhere else

Let's then generate the `.pc` file

```
./create-pkgconfig.sh tensorflow_c /folder/where/the/so/is 1.0.0 "Tensorflow C Library" > /path/to/pc/file
```

Now that all is done, we can use cargo to crossbuild the app

```
PKG_CONFIG_PATH=/folder/where/the/pcfile/is  PKG_CONFIG_ALLOW_CROSS=1 cargo build
```

Enjoy !



