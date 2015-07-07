     _    _                                 _____
    | |  | |                               / ____|
    | |__| |_   _ _ __   __ _ _ __ _   _  | |  __  __ _ _ __ ___   ___  ___
    |  __  | | | | '_ \ / _` | '__| | | | | | |_ |/ _` | '_ ` _ \ / _ \/ __|
    | |  | | |_| | | | | (_| | |  | |_| | | |__| | (_| | | | | | |  __/\__ \
    |_|  |_|\__,_|_| |_|\__, |_|   \__, |  \_____|\__,_|_| |_| |_|\___||___/
                         __/ |      __/ |
                        |___/      |___/

By Splizard.

For a full list of contributors, see [this page](https://github.com/Splizard/hungry_games/graphs/contributors).

GitHub: https://github.com/GunshipPenguin/hungry_games

Installation
============

Place this folder in your Minetest games folder.

Gameplay
========

You will spawn in an arena in which there is no way out, you must collect items
found in chests scattered in the arena and use them to defeat other players and
you must eat and drink to survive. The last surviving player is the winner.

Details
=======

The game is round-based. Once you have died, won, or you just entered the
server, you have to wait until the next round starts. When you play a map with
this game a glass wall is created which is (by default) 400×400 blocks around
the center of the map, it is an indestructable wall and players will always
spawn inside the arena. There are also chests scattered randomly around the
arena which contain useful weapons and items. When you die you drop all your
items and start spectating or get teleported to a lobby where combat is
disabled. You will become hungry and thirsty over time. When your hunger or
thirst bar reaches 100%, you have to find food or a drink quickly, otherwise
you will die from starvation or dehydration.

Attention, server admins
========================

When hosting a hungry games server please edit the hungry_games mod files for configuring
the game, this is the Minetest/games/hungry_games/mods/hungry_games/init.lua file. The file is meant to document itself but if you need help understanding the configuration, just ask.
The Hungry Games should, however, already work well with the default settings.

Quick start guide for setting up a server
=========================================

The usual way to set up a server goes like this:


** Linux users will find the games folder in `~/.minetest/games/`.

________________________________________________________________________________

1. Create a new world and use the v6 map generator
2. Join this world
3. Obtain the hg_admin and hg_maker privileges
4. Set the starting positions (at least 2) by using the server command “/hg set player_#” (see below).
   Make sure all starting positions are within the boundaries of the glass arena.
5. Set the lobby and spawn positions using “/hg set lobby” and “/hg set spawn”.
   Also make sure those positions are sealed from the main combat area.
6. Now your server is ready, wait for other players to join and let them vote to start the first match

Optional steps and hints
------------------------

- You can design the world to your liking by using the “HG Maker” tab in your inventory menu. Use the Admin Pickaxe to break blocks
- You can build additional chests, they will be automatically filled in the next match
- The lobby is supposed a closed area which is sealed from the main arena; it is usually a spectator room
- Both lobby and spawn positions must not be neccessarily inside the arena
- If you are lazy, you can set the lobby and spawn position at the same place
- Configure the Hungry Games server to your liking (see above)
- The number of possible players in a match is limited by the number of starting positions.

The more spawn positions you have, the more players can play.


Privileges
==========

`hg_admin`    Allows to manage the Hungry Games with the “hg” server command (see below).  
`hg_maker`    Adds the “HG Maker” tab (you can get almost any item here, but you
              must rejoin the server first) into the inventory menu and allows
              to use the “build” server command.  
`vote`        Reserved for internal use.  
`register`    Reserved for internal use.

Server commands
===============

Commands for everyone
---------------------

`/vote`        Vote to start the match
`/register`    Register to take part in the next match

Commands requiring hg_maker privilege
-------------------------------------

`/build`    Grants yourself these privileges: interact, fly, fast. Works only if no game is currently in progress.

Commands requiring hg_admin privilege
-------------------------------------

`/hg start`                         Starts the match (if not already running)  
`/hg restart`                       Restarts the match  
`/hg r`                             Restarts the match  
`/hg stop`                          Stops the current match  
`/hg set <posname>`[<x> <y> <z>]    Set a spawn position  
`/hg unset <posname>`               Unset/delete a spawn position  
`/hg maintenance [on|off]`          Enable/disable or toggle maintenance mode.  


### Detailed command description

#### Maintenance mode

The maintenance mode is a simple tool for server operators to disable the starting of new games.
Maintenance mode can be used to manually build the map without being disturbed by a game.

While in maintenance mode, voting is disabled and the game can also not be started with `/hg start` or `/hg restart`.

The maintenance mode is always disabled when the server has just been started, it must always be enabled manually.

Use `/hg maintenance` to toggle maintenance mode.

#### Setting and deleting spawn positions

The `/hg set` command works like this: `/hg set <posname> [<x> <y> <z>]`

`<posname>`    is a required argument and is one of:  
`spawn`        Where players respawn after death  
`lobby`        Where the players spawn when they join the server  
`player_#`     Where players start the match, replace `#` with a whole number,
               starting from 1. You must not skip numbers.

`<x>`, `<y>` and `<z>` are optional and set the position of the spawn point. If omitted, the position is set to your current position

Example: `/hg set player_1 0 0 0` sets the first starting position to (0,0,0).

The `/hg unset` command works like `/hg set`, but it does not have the optional position arguments.
