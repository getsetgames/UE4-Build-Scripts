@echo off

goto comment

This script builds a UE4 game project using the github engine. It does so by performing the following 3 steps:

1. Clone a fresh copy of the engine from github.
2. Extract the required files provided by Epic to the engine directory.
3. Run Unreal Automation Tool to build the game, cook the content and package it.

Arguments:

1. The full path to your .uproject file.
2. Which platform to build (eg. Android, Win32).
3. Which configuration to build (eg. Development, Shipping).
4. The url of the git repository that contains the engine you would like to package the project with (eg. git@github.com:EpicGames/UnrealEngine.git).
5. This allows you to specify a branch or specific commit to use to package the project. You can pass in a branch name or a commit hash.
6. The directory where the engine will be cloned to.
7. The path to Required_1of2.zip provided by Epic.
8. The path to Required_2of2.zip provided by Epic.
9. The path to Optional.zip provided by Epic.
10. The directory where the final product will be saved.

:comment

set PROJECT=%1
set PLATFORM=%2
set CLIENT_CONFIG=%3
set ENGINE_URL=%4
set ENGINE_CHECKOUT=%5
set ENGINE_DIRECTORY=%6
set REQUIRED_FILES_1=%7
set REQUIRED_FILES_2=%8
set REQUIRED_FILES_OPT=%9
shift
set ARCHIVE_DIRECTORY=%9

echo PROJECT=%PROJECT%
echo PLATFORM=%PLATFORM%
echo CLIENT_CONFIG=%CLIENT_CONFIG%
echo ENGINE_URL=%ENGINE_URL%
echo ENGINE_CHECKOUT=%ENGINE_CHECKOUT%
echo ENGINE_DIRECTORY=%ENGINE_DIRECTORY%
echo REQUIRED_FILES_1=%REQUIRED_FILES_1%
echo REQUIRED_FILES_2=%REQUIRED_FILES_2%
echo REQUIRED_FILES_OPT=%REQUIRED_FILES_OPT%
echo ARCHIVE_DIRECTORY=%ARCHIVE_DIRECTORY%

if exist %ENGINE_DIRECTORY% (
	echo Removing the old engine...
	rmdir /s /q %ENGINE_DIRECTORY%
)

echo Cloning the engine from git...
git clone %ENGINE_URL% %ENGINE_DIRECTORY%

echo Checking out the requested commit...
cd %ENGINE_DIRECTORY%
git checkout %ENGINE_CHECKOUT%
git submodule update --init --recursive

echo Extracting the Required files 1 of 2...
jar xf %REQUIRED_FILES_1%

echo Extracting the Required files 2 of 2...
jar xf %REQUIRED_FILES_2%

echo Extracting the Optional files...
jar xf %REQUIRED_FILES_OPT%

%ENGINE_DIRECTORY%/Engine/Build/BatchFiles/RunUAT.bat BuildCookRun -project=%PROJECT% -build -%PLATFORM% -clientconfig=%CLIENT_CONFIG% -distribution -cook -stage -package -archive -archivedirectory=%ARCHIVE_DIRECTORY%
