@echo off
:: --------------------------------------------
:: Git Auto Push Script (safe version)
:: --------------------------------------------
cd /d "%~dp0"

echo ============================
echo   Checking Git Status
echo ============================
git status
echo.

:: --- Make sure this script is not tracked by Git ---
for /f "tokens=*" %%A in ('git ls-files --error-unmatch "%~nx0" 2^>nul') do (
    echo WARNING: This script is currently tracked by Git!
    echo It will be removed from tracking to keep it local.
    git rm --cached "%~nx0"
    echo push_changes.bat>>.gitignore
    git add .gitignore
    git commit -m "Ignore local push script"
)

:: --- Show message prompt ---
set /p msg=Enter commit message: 

:: --- Add, commit, and push ---
echo.
echo Adding all changes...
git add .

echo Committing changes...
git commit -m "%msg%"

echo.
echo Pushing to GitHub...
git push

echo.
echo ============================
echo       All Done!
echo ============================
pause
