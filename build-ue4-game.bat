@echo off

goto comment

This script builds a UE4 game project using the github engine. It does so by performing the following 3 steps:

1. Clone a fresh copy of the engine from github.
2. Run Setup.bat to download the dependencies provided by Epic to the engine directory.
3. Run Unreal Automation Tool to build the game, cook the content and package it.

Arguments:

1. The full path to your .uproject file.
2. Which platform to build (eg. Android, Win32).
3. Which configuration to build (eg. Development, Shipping).
4. The url of the git repository that contains the engine you would like to package the project with (eg. git@github.com:EpicGames/UnrealEngine.git).
5. This allows you to specify a branch or specific commit to use to package the project. You can pass in a branch name or a commit hash.
6. The directory where the engine will be cloned to.
7. The directory where the final product will be saved.

:comment

set PROJECT=%1
set PLATFORM=%2
set CLIENT_CONFIG=%3
set ENGINE_URL=%4
set ENGINE_CHECKOUT=%5
set ENGINE_DIRECTORY=%6
set ARCHIVE_DIRECTORY=%7

echo PROJECT=%PROJECT%
echo PLATFORM=%PLATFORM%
echo CLIENT_CONFIG=%CLIENT_CONFIG%
echo ENGINE_URL=%ENGINE_URL%
echo ENGINE_CHECKOUT=%ENGINE_CHECKOUT%
echo ENGINE_DIRECTORY=%ENGINE_DIRECTORY%
echo ARCHIVE_DIRECTORY=%ARCHIVE_DIRECTORY%

if exist %ENGINE_DIRECTORY% (
	echo Updating the engine...
	cd %ENGINE_DIRECTORY%
	git fetch origin
	git pull origin %ENGINE_CHECKOUT%
	git submodule update --init --recursive
) ELSE (
	echo Cloning the engine from git...
	git clone %ENGINE_URL% %ENGINE_DIRECTORY%

	echo Checking out the requested commit...
	cd %ENGINE_DIRECTORY%
	git checkout %ENGINE_CHECKOUT%
	git submodule update --init --recursive

	echo Adding dependencies...
	Setup.bat
)

%ENGINE_DIRECTORY%/Engine/Build/BatchFiles/RunUAT.bat BuildCookRun -project=%PROJECT% -build -%PLATFORM% -clientconfig=%CLIENT_CONFIG% -distribution -cook -stage -package -obbinapk -archive -archivedirectory=%ARCHIVE_DIRECTORY%
