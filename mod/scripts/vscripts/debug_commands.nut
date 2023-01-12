untyped
#if CLIENT || UI || SERVER
global entity executor
#endif
#if SERVER
global function DebugCommandsInit

global struct QeCommand {
	bool functionref( entity, array<string> ) callback
	array<string> options,
	array<string> flags,
	string description,
}

global table<string, QeCommand> qeCommands

QeCommand function _QeCommand( bool functionref( entity, array<string> ) callback, string description, array<string> options = [], array<string> flags = [] )
{
	QeCommand q
	q.callback = callback
	q.description = description
	q.options = options
	q.flags = flags
	return q
}

void function DebugCommandsInit()
{
	qeCommands["ss"] <- _QeCommand( SERVERScriptSafeCallback, "safe SERVER scripts" )
	qeCommands["sc"] <- _QeCommand( CLIENTScriptSafeCallback, "safe CLIENT scripts" )
	qeCommands["su"] <- _QeCommand( UIScriptSafeCallback, "safe UI scripts" )
	qeCommands["grunt"] <- _QeCommand( SpawnGruntCallback, "spawn an enemy grunt", ["--team"], ["-titan"] )
	qeCommands["qs"] <- _QeCommand( QuerschnittHelpcallback, "command infos", ["--<command>"] )

	foreach( command, ref in qeCommands )
	{
		AddClientCommandCallback( command, ref.callback )
	}
}

bool function SERVERScriptSafeCallback( entity player, array<string> args )
{
	if( !GetConVarBool( "sv_cheats" ) )
		return false

	executor = player
	args = ScriptCommandErrCallReplace( args )
	string script = PreProcessQuerScriptArgs( args )

	ExecutePreProcessedScript( script )

	executor = null
	return true
}

bool function CLIENTScriptSafeCallback( entity player, array<string> args )
{
	if( !GetConVarBool( "sv_cheats" ) )
		return false

	args = ScriptCommandErrCallReplace( args )
	ServerToClientStringCommand( player, "scc " + CombineArgs( args ) )
	return true
}

bool function UIScriptSafeCallback( entity player /*CPlayer*/, array<string> args )
{
	if( !GetConVarBool( "sv_cheats" ) )
		return false

	args = ScriptCommandErrCallReplace( args )
	ServerToClientStringCommand( player, "suc " + CombineArgs( args ) )
	return true
}

array<string> function ScriptCommandErrCallReplace( array<string> args )
{
	foreach( int i, string v in args )
	{
		// args[i] = StringReplace( v, "'", "\"" )
		// args[i] = StringReplace( v, "#", ";" )
		if(v == "'")
			args[i] = "\""
	}
	return args
}

bool function SpawnGruntCallback( entity player, array<string> args )
{
	if( !GetConVarBool( "sv_cheats" ) )
		return false

	int team = TEAM_UNASSIGNED
	table<string, string> options = GetArgsOptions( args, qeCommands["grunt"].options )

	if( options.len() )
	{
		try {
			team = expect int( compilestring( format( "return %s", options["--team"] ) )() )
		} catch( e ) {
			printt( e )
		}
	} else {
		try {
			team = GetOtherTeam( player.GetTeam() )
		} catch( e ) {
			printt( e )
		}
	}

	DispatchSpawn( args.find("-titan") == -1 ? CreateSoldier( team, TraceFromEnt( player ).endPos, <0,0,0> ) : CreateOgre( team, TraceFromEnt( player ).endPos, <0,0,0>) )

	return true
}

bool function QuerschnittHelpcallback( entity player, array<string> args )
{
	if( !GetConVarBool( "sv_cheats" ) )
		return false

	if( !args.len() )
	{
		string msg =
@"=== Querschnit Info ===
execute 'qs --<command>' for more info
=== all commands ==="
		foreach( cmd, info in qeCommands )
		{
			msg += "\n" + cmd
		}
		print( msg )
	}
	
	foreach( arg in args )
	{
		if( arg.find( "--" ) == 0 )
		{
			PrintQEInfo( arg.slice( 2, arg.len() ) )
		}
	}

	return true
}

void function PrintQEInfo( string cmd )
{
	QeCommand qe = qeCommands[ cmd ]
	string msg = format( "%s - %s\n=== options ===", cmd, qe.description )
	foreach( option in qe.options )
	{
		msg += "\n" + option
	}
	msg += "\n=== flags ==="
	foreach( flag in qe.flags )
	{
		msg += "\n" + flag
	}

	print( msg )
}

table<string, string> function GetArgsOptions( array<string> args, array<string> options )
{
	table<string, string> found

	foreach( option in options )
	{
		int idx = args.find( option )
		if( idx == -1 )
			continue
		if( idx + 1 >= args.len())
			throw format( @"option ""%s"" is missing a value (index %i; length %i)", option, idx, args.len() )
		found[ option ] <- args[ idx + 1 ]
	}
	return found
}
#endif