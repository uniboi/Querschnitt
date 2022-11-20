#if CLIENT || UI || SERVER
global entity executor
#endif
#if SERVER
global function DebugCommandsInit

void function DebugCommandsInit()
{
	AddClientCommandCallback( "ss", SERVERScriptSafeCallback )
	AddClientCommandCallback( "sc", CLIENTScriptSafeCallback )
	AddClientCommandCallback( "su", UIScriptSafeCallback )
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
#endif