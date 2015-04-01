#!/bin/sh

# This script builds a UE4 game project using the github engine. It does so by performing the following 3 steps:
#
# 1. Clone a fresh copy of the engine from github.
# 2. Run Setup.command to download the dependencies provided by Epic to the engine directory.
# 3. Run Unreal Automation Tool to build the game, cook the content and package it.

# Arguments:
#
# -project          : The full path to your .uproject file.
# -platform         : Which platform to build (eg. IOS, Mac).
# -clientconfig     : Which configuration to build (eg. Development, Shipping).
# -engineurl        : The url of the git repository that contains the engine you'd like to package the project with (eg. git@github.com:EpicGames/UnrealEngine.git).
# -enginecheckout   : This allows you to specify a branch or specific commit to use to package the project. You can pass in a branch name or a commit hash.
# -enginedirectory  : The directory where the engine will be cloned to.
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
echo ARCHIVE_DIRECTORY=$ARCHIVE_DIRECTORY

if [ -d "$ENGINE_DIRECTORY" ]; then
	echo "Updating the engine..."
	cd "$ENGINE_DIRECTORY"
	git fetch origin 
	git pull origin $ENGINE_CHECKOUT
	git submodule update --init --recursive
	$ENGINE_DIRECTORY/Setup.sh --force
else
	echo "Cloning the engine from git..."
	git clone "$ENGINE_URL" "$ENGINE_DIRECTORY"

	echo "Checking out the requested commit..."
	cd "$ENGINE_DIRECTORY"
	git checkout $ENGINE_CHECKOUT
	git submodule update --init --recursive

	echo "Adding dependencies..."
	$ENGINE_DIRECTORY/Setup.command
fi

echo "Packaging the project..."
"$ENGINE_DIRECTORY/Engine/Build/BatchFiles/RunUAT.sh" BuildCookRun -project="$PROJECT" -build -$PLATFORM -clientconfig=$CLIENT_CONFIG -distribution -cook -stage -package -archive -archivedirectory="$ARCHIVE_DIRECTORY"
