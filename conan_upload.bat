call .\run_tests_x86_64_release.bat
@if errorlevel 1 goto error

python .\get_package_name.py > package_name.txt
@if errorlevel 1 goto error
set /p PACKAGE_NAME=<package_name.txt

conan export-pkg . %PACKAGE_NAME% -f -s arch=x86_64 -s build_type=Release --build-folder=build/ --source-folder=src/
@if errorlevel 1 goto error
conan upload %PACKAGE_NAME% -r=wsy-pc --all
@if errorlevel 1 goto error
goto success
:error
pause
exit /B 1
:success

