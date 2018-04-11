# A sample of a project whose package is managed by conan.

## Usage
### Configure
1. Modify CMakeLists as you wish
2. Change project name in get_package_name.py
3. Change the required package in conanfile.py
4. config conan. Reference: http://wiki.51hitech.com/pages/viewpage.action?pageId=28905405

### Generate solution
1. .\sln_generator_x86_64_release.bat

### Upload package
1. Add tag on current commit like VERSION_0_1
2. .\conan_upload.bat

