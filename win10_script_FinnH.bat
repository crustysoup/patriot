@echo off
:: Run the script as administrator if not already
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~0' -Verb RunAs"
    exit /b
)

echo Setting minimum password length to 10...
net accounts /minpwlen:10

echo Setting account lockout threshold to 10...
net accounts /lockoutthreshold:10

echo Enforcing password complexity...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PasswordComplexity /t REG_DWORD /d 1 /f
echo.

echo Enabling Windows Firewall...
netsh advfirewall set allprofiles state on

echo Disabling AutoPlay for all drives...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 255 /f
echo.

echo Enabling Windows SmartScreen...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SmartScreenEnabled" /v Warn /t REG_SZ /d Block /f
echo.

echo Disabling FTP service...
sc qc ftpsvc > nul 2>&1
if %errorlevel% equ 0 (
    sc config ftpsvc start= disabled
    sc stop ftpsvc
) else (
    echo FTP service is not installed.
)
echo.

echo Disabling World Wide Web Publishing service...
sc qc w3svc > nul 2>&1
if %errorlevel% equ 0 (
    sc config w3svc start= disabled
    sc stop w3svc
) else (
    echo WWW Publishing service is not installed.
)
echo.


echo Enabling RDP and Network Level Authentication...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 1 /f
echo.

echo Setting RDP Security Layer to SSL...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v SecurityLayer /t REG_DWORD /d 2 /f
echo.

echo.
echo All tasks completed!
pause
