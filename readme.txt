 _    _                                 _____                           
| |  | |                               / ____|                          
| |__| |_   _ _ __   __ _ _ __ _   _  | |  __  __ _ _ __ ___   ___  ___ 
|  __  | | | | '_ \ / _` | '__| | | | | | |_ |/ _` | '_ ` _ \ / _ \/ __|
| |  | | |_| | | | | (_| | |  | |_| | | |__| | (_| | | | | | |  __/\__ \
|_|  |_|\__,_|_| |_|\__, |_|   \__, |  \_____|\__,_|_| |_| |_|\___||___/
                     __/ |      __/ |                                   
                    |___/      |___/                                    
By Splizard

Github: https://github.com/Splizard/hungry_games
Forum:  http://forum.minetest.net/viewtopic.php?id=4582

INSTALL:
----------
Place this folder in your minetest games folder.

GAMEPLAY:
-----------
You will spawn in an arena which there is no way out, you must collect items
found in chests scattered in the arena and use them to defeat other players.

DETAILS:
----------
When you play a map with this game a glass wall is created which is 200x200 blocks around the center of the map,
it is an indestructable wall and players will always spawn inside the arena.
There are also chests scattered randomly around the arena which contain useful weapons and items.
When you die you drop all you items and start spectating.
After three minutes you get hungry and start starving.

ATTENTION SERVER ADMINS:
--------------------------
When hosting a hungry games server please edit the hungry_games mod for configuring
the game, this is the minetest/games/hungry_games/mods/hungry_games/init.lua file. The file is meant to document itself but if you need help understanding the configuration just ask.

** Linux users will find the games folder in /usr/share/minetest/**

CHAT COMMANDS:
---------------
hg_admin:
/hg restart/start --starts the match
/hg stop --stops the match
/hg set spawn --sets where players respawn on death
/hg set lobby --sets where the players spawn when they join
/hg set player_# --set where players start the match, replace # with number (must be set in order to play a match)

hg_maker: (note after getting this priv you must logout/login to the server to get creative inventory)
/build --grants interact/fly and fast privilege

anyone:
/vote --vote to start the match
/register --register to take part in the next match

UNINSTALL:
------------
Simply delete the folder hungry_games from the games folder.

CHANGELOG:
------------

Version 0.4

    Armour
    Cannon Sound
    Match Countdown
    Cimbable leaves

Version 0.3

    Initial release
