# Querschnitt

Adds some utilities for testing and developing mods.

## Features

### ss / sc / su

Execute a script on the SERVER / CLIENT / UI vm. All locals will be printed as well as runtime errors and expressions that evaluate to no action.

You can use macros. To get a list of all usable macros, type `qs ss`

### Macros

- `@me` - The player executing the command
- `@us` - All players in the team of the player executing the command
- `@all` - All players connected
- `@there` - Returns a vector of the position the executor looks at
- `@here` - Returns a vector of the position of the executor
- `@trace` - Returns a `TraceResult` from the callee eye position to the point the callee is looking at
- `@cache` - Returns the entity last shot with the dev gun by the callee

### Examples

- `ss @me.Die()`
	Kills the person executing the command
- `ss foreach(e in @all){e.SetOrigin(@there)}`
	Set the origin of every player to the position the person executing the command looks at

### grunt

Spawn a grunt at the position the executor looks at. You can pass an expression to the `--team` option or spawn a titan with `-titan`

#### Examples

- `grunt --team TEAM_MILITIA`
- `grunt --team 0 -titan`

### clear

Clear the console

### qs

Print help about Querschnitt commands

Pass a command to receive more info about it.

### Dev Gun

Displays some useful info of the entity shot in the HUD. You can get the entity you shot with `@cache` in `ss` and `sc`

You can obtain it with the command `give mp_dev_info_gun`