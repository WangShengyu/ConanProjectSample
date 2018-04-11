@pushd %~dp0
mkdir build\x86_64\Release
cd build\x86_64\Release
conan install ../../.. -s build_type=Release -o develop=True
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
