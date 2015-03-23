# UE4 Build Scripts

These scripts build Unreal Engine 4 game projects using the engine source code provided by Epic on github. They do so by performing the following 3 steps:

1. Clone a fresh copy of the engine from github.
2. Run the Setup script to download the dependencies provided by Epic to the engine directory.
3. Run Unreal Automation Tool to build the game, cook the content and package it.

## Usage (Windows)

```bat
build-ue4-game.bat "<full path to my .uproject file>" "Android" "Development" "git@github.com:EpicGames/UnrealEngine.git" "4.7" "<full path to desired engine location>" "<full path to archive directory>"
```

## Usage (Mac)

```shell
./build-ue4-game.sh -project "<full path to my .uproject file>" -platform "IOS" -clientconfig "Shipping" -engineurl "git@github.com:EpicGames/UnrealEngine.git" -enginecheckout "4.6" -enginedirectory "<full path to desired engine location>" -archivedirectory "<full path to archive directory>"
```
