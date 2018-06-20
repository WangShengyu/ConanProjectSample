from conans import ConanFile, CMake
from os import listdir
from os.path import isfile, join
import os

class ProjectConan(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    generators = "cmake", "gcc", "txt"
    options = {"develop": [True, False]}
    default_options = "develop=False"
    requires = "boost/1.66.0@conan/stable", "eigen/3.3.4@conan/stable", "opencv/3.1.0@lasote/vcpkg"
    dev_requires = ["gtest/1.8.0@bincrafters/stable"]

    def config_options(self):
      if self.options.develop == True:
        for dev_req in self.dev_requires:
          self.requires.add(dev_req)

    def imports(self):
        self.copy("*.dll", dst="bin", src="bin")
        self.copy("*.pdb", dst ="bin", src = "bin")

    def build(self):
        cmake = CMake(self)
        cmake.configure(["-DDEVELOP=" + str(self.options.develop)])
        cmake.build()

    def package (self):
        self.copy("*.h", dst ="include", src = "public")
        self.copy("*.lib", dst ="lib", src = "lib")
        self.copy("*.dll", dst ="bin", src = "bin")
        self.copy("*.pdb", dst ="bin", src = "bin")

    def package_info(self):
        libpath = os.path.join(self.package_folder, "lib")
        if os.path.exists(libpath):
            onlyfiles = [f for f in listdir(libpath) if isfile(join(libpath, f))]
            self.cpp_info.libs = [libname.split(".")[0] for libname in onlyfiles]
    
