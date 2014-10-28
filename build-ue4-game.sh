#!/bin/sh

# This script builds a UE4 game project using the github engine. It does so by performing the following 3 steps:
#
# 1. Clone a fresh copy of the engine from github.
# 2. Extract the required files provided by Epic to the engine directory.
# 3. Run Unreal Automation Tool to build the game, cook the content and package it.

# Arguments:
#
# -project          : The full path to your .uproject file.
# -platform         : Which platform to build (eg. IOS, Mac).
# -clientconfig     : Which configuration to build (eg. Development, Shipping).
# -engineurl        : The url of the git repository that contains the engine you'd like to package the project with (eg. git@github.com:EpicGames/UnrealEngine.git).
# -enginecheckout   : This allows you to specify a branch or specific commit to use to package the project. You can pass in a branch name or a commit hash.
# -enginedirectory  : The directory where the engine will be cloned to.
# -requiredfiles1   : The path to Required_1of2.zip provided by Epic.
# -requiredfiles2   : The path to Required_2of2.zip provided by Epic.
# -requiredfilesopt : The path to Optional.zip provided by Epic.
# -archivedirectory : The directory where the final product will be saved.

for arg in "$@"
do
	if [[ $arg == -* ]];
	then
		ARG_NAME=$arg
	elif [ -n "$ARG_NAME" ];
	then
		case "$ARG_NAME" in
			"-project") PROJECT=$arg
			;;
			"-platform") PLATFORM=$arg
			;;
			"-clientconfig") CLIENT_CONFIG=$arg
			;;
			"-engineurl") ENGINE_URL=$arg
			;;
			"-enginecheckout") ENGINE_CHECKOUT=$arg
			;;
			"-enginedirectory") ENGINE_DIRECTORY=$arg
			;;
			"-requiredfiles1") REQUIRED_FILES_1=$arg
			;;
			"-requiredfiles2") REQUIRED_FILES_2=$arg
			;;
			"-requiredfilesopt") REQUIRED_FILES_OPT=$arg
			;;
			"-archivedirectory") ARCHIVE_DIRECTORY=$arg
			;;
			*) echo "invalid argument: $ARG_NAME"
			exit 1
			;;
		esac
	fi
done

echo PROJECT=$PROJECT
echo PLATFORM=$PLATFORM
echo CLIENT_CONFIG=$CLIENT_CONFIG
echo ENGINE_URL=$ENGINE_URL
echo ENGINE_CHECKOUT=$ENGINE_CHECKOUT
echo ENGINE_DIRECTORY=$ENGINE_DIRECTORY
echo REQUIRED_FILES_1=$REQUIRED_FILES_1
echo REQUIRED_FILES_2=$REQUIRED_FILES_2
echo REQUIRED_FILES_OPT=$REQUIRED_FILES_OPT
echo ARCHIVE_DIRECTORY=$ARCHIVE_DIRECTORY

if [ -d "$ENGINE_DIRECTORY" ]; then
	echo "Removing the old engine..."
	cd "$ENGINE_DIRECTORY"
	rm -rf *
	rm -rf .git*
fi

echo "Cloning the engine from git..."
git clone "$ENGINE_URL" "$ENGINE_DIRECTORY"

echo "Checking out the requested commit..."
cd "$ENGINE_DIRECTORY"
git checkout $ENGINE_CHECKOUT
git submodule update --init --recursive

echo "Extracting the Required files 1 of 2..."
tar -xf "$REQUIRED_FILES_1" -C "$ENGINE_DIRECTORY"

echo "Extracting the Required files 2 of 2..."
tar -xf "$REQUIRED_FILES_2" -C "$ENGINE_DIRECTORY"

echo "Extracting the Optional files..."
tar -xf "$REQUIRED_FILES_OPT" -C "$ENGINE_DIRECTORY"

echo "Packaging the project..."
"$ENGINE_DIRECTORY/Engine/Build/BatchFiles/RunUAT.sh" BuildCookRun -project="$PROJECT" -build -$PLATFORM -clientconfig=$CLIENT_CONFIG -distribution -cook -stage -package -archive -archivedirectory="$ARCHIVE_DIRECTORY"