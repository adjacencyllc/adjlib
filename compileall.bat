@echo off
cls
echo ADJLIB Master Compile Script
echo.
choice /M "Recompile all programs in ADJLIB? "
IF ERRORLEVEL == 2 GOTO END

:: get the git branch we are building from and store in a file
del .\bin\*.plc
del .\bin\*.sdb
del .\bin\*.lst

:: compile all pls files in the src directory tree
for /f %%f in ('dir src\*.pls /s /b /on') do (plbcon.exe plbcmp %%f -ZG,ZT,S,WS,E,X,VGIT=1,P "adjlib mass compile")

echo.
echo Recompile complete.
echo.

for %%f in ('dir .\bin\*.plc /b /on') do if %%~zf==0 ( echo Compile Error: %%~nf )

echo.

choice /M "Delete all LST and PLBM files? "
IF ERRORLEVEL == 2 GOTO END

del .\bin\*.lst
del .\bin\*.plbm

:END
