# Documentation: http://docs.brew.sh/Formula-Cookbook.html
#                http://www.rubydoc.info/github/Homebrew/brew/master/Formula

class TensorflowC < Formula
  desc "An open-source software library for Machine Intelligence"
  homepage "https://www.tensorflow.org/"
  url "https://github.com/tensorflow/tensorflow", :tag  => "v1.0.0", :using => :git
  version "1.0.0"

  depends_on "bazel" => :build
  depends_on "pkg-config" => :run

  def install
    system 'echo "\n\n\n\n\n\n\n\n\n" | ./configure'
    system "bazel", "build", "--compilation_mode=opt", "--copt=-march=native", "tensorflow:libtensorflow_c.so"
    lib.install "bazel-bin/tensorflow/libtensorflow_c.so"
    system "cp", "tensorflow/c/c_api.h", "tensorflow_c_api.h"
    include.install "tensorflow_c_api.h"
    pc = <<-EOF.gsub(/^\s+/, "")
      Name: tensorflow_c
      Description: Tensorflow c lib
      Version: #{version}
      Libs: -L#{lib} -ltensorflow_c
      Cflags: -I#{include}
    EOF
    FileUtils.mkdir_p(lib/"pkgconfig")
    File.open(lib/"pkgconfig/tensorflow_c.pc", 'w') { |f| f.write(pc) }
  end

  test do
    # test a call on TF_Version(), checking .h, .so, pkg-config setup.
    File.open("test.c", 'w') { |f|
      f.write(<<-EOF.gsub(/^\s+/, ""))
      #include <stdio.h>
      #include <tensorflow_c_api.h>
      int main() {
        printf("%s\\n", TF_Version());
      }
      EOF
    }
    system "sh", "-c", "gcc `pkg-config --libs --cflags tensorflow_c` -o test_tf test.c"
    found_version = `./test_tf`.strip
    assert found_version == version
  end
end
