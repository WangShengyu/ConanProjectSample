@pushd %~dp0
mkdir build\x86_64\Release
cd build\x86_64\Release
conan install ../../.. -s arch=x86_64 -s build_type=Release -s os=Windows -s compiler="Visual Studio" -s compiler.version=14 -s compiler.runtime=MD -o develop=True
@if errorlevel 1 goto error
conan build ../../..
@if errorlevel 1 goto error

goto success
:error
@popd
pause
exit /B 1
:success
@popd
