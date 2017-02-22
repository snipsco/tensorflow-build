# Documentation: http://docs.brew.sh/Formula-Cookbook.html
#                http://www.rubydoc.info/github/Homebrew/brew/master/Formula

class TensorflowC < Formula
  desc ""
  homepage ""
  url "https://github.com/tensorflow/tensorflow", :tag  => "v1.0.0", :using => :git
  version "1.0.0"
  sha256 ""

  depends_on "bazel" => :build
  depends_on "pkg-config" => :run

  def install
    system 'echo "\n\n\n\n\n\n\n\n\n" | ./configure'
    system "bazel", "build", "--compilation_mode=opt", "tensorflow:libtensorflow_c.so"
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
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test tensorflow_c`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
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
