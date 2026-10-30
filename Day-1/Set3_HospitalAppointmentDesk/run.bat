@echo off
setlocal
cd /d "%~dp0"
echo ===================================================
echo  Compiling Set 3 - Hospital Appointment Suite...
echo ===================================================
if not exist "bin" mkdir "bin"

set JAVAC="C:\Program Files\Java\jdk-25.0.5.0.3\bin\javac.exe"
set JAVA="C:\Program Files\Java\jdk-25.0.5.0.3\bin\java.exe"

%JAVAC% -d bin -sourcepath src src\com\hexaware\hospital\Main.java
if %errorlevel% neq 0 (
    echo Compilation failed!
    exit /b %errorlevel%
)

echo.
echo ===================================================
echo  Running Set 3 - Hospital Appointment Suite...
echo ===================================================
%JAVA% -cp bin com.hexaware.hospital.Main
pause
