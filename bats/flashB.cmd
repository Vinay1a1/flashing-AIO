@echo off
setlocal enabledelayedexpansion

set "FASTBOOT=%~dp0..\adb\fastboot.exe"  

set count=0
for %%f in ("%~dp0..\*.img") do (
    set /a count+=1
    echo !count!: %%f
    set image[!count!]=%%f
)

if %count%==0 (
    echo No image files found in the current directory.
    pause
    exit /b
)

adb get -state 1>nul 2>nul
if %errorlevel% equ 0 (
    echo Rebooting to Fastboot...
    "%ADB%" reboot fastboot 
) else (
GOTO do
)

:do
echo Rebooting into fastbootd mode...
"%FASTBOOT%" reboot fastboot

:select_boot
set /p boot_choice="Select the boot image to flash: "
if not defined image[%boot_choice%] (
    echo Invalid choice. Please try again.
    goto select_boot
)
set boot_image=!image[%boot_choice%]!

echo Flashing selected boot image...
"%FASTBOOT%" flash boot %boot_image%

set /p REBOOT="Flashing complete. Do you want to reboot the device to system now? (Y/N): "
if /i "%REBOOT%"=="Y" (
    "%FASTBOOT%" reboot
    echo Device is rebooting.
) else (
    echo Please reboot the device manually when ready.
)


set /p RECOVERY="Do you want to reboot to recovery? (Y/N): "
if /i "%RECOVERY%"=="Y" (
    "%FASTBOOT%" reboot bootloader
    "%FASTBOOT%" reboot recovery
    echo Rebooting to recovery.
) else (
    echo You can reboot to recovery manually later.
)

pause
