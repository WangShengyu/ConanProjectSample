call .\sln_generator_x86_64_release.bat
@if errorlevel 1 goto error
.\build\x86_64\Release\bin\unit_tests.exe
@if errorlevel 1 goto error
goto success
:error
pause
exit /B 1
:success

