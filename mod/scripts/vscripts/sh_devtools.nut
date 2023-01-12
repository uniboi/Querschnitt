untyped
globalize_all_functions

struct MacroInfo {
	string script,
	string desc,
}

MacroInfo function _MacroInfo( string script, string desc )
{
	MacroInfo m
	m.script = script
	m.desc = desc
	return m
}

table<string, MacroInfo> macros

void function InitQuerschnittMacros()
{
	macros["@me"] <- _MacroInfo( "executor", "the player that executed the command" )
	macros["@all"] <- _MacroInfo( "GetPlayerArray()", "all connected players" )
	macros["@us"] <- _MacroInfo( "GetPlayerArrayOfTeam(executor.GetTeam())", "all players that share a team with the callee" )
	macros["@here"] <- _MacroInfo( "executor.GetOrigin()", "the executing players position" )
	macros["@that"] <- _MacroInfo( "TraceFromEnt(executor).hitEnt", "the first entity the callee looks at" )
	macros["@there"] <- _MacroInfo( "TraceFromEnt(executor).endPos", "the position the callee looks at" )
	macros["@trace"] <- _MacroInfo( "TraceFromEnt(executor)", "TraceResults from where the callee is looking" )
	macros["@cache"] <- _MacroInfo( "sel(executor)", "the last entity the callee shot with an info gun" )
	macros["#"] <- _MacroInfo( "GetEntByScriptName", "shorthand for GetEntByScriptName" )
	macros["_ "] <- _MacroInfo( "return", "shorthand for return" )
}

void function PrintQuerschnittHelp( string category )
{
	switch( category )
	{
		case "safeScript":
		print( "the commands \"ss\", \"sc\" and \"su\" execute in SERVER, CLIENT or UI context." )

		foreach( string k, MacroInfo q in macros )
		{
			print( format( "%s : %s", k, q.desc ) )
		}
		
		print( "=== SYNTAX ===")
		print( "Strings: Instead of\" to declare strings, use '" )
		print( "Statements: instead of ; to seperate statements, use .," )
		break
	}
}

string function ReplacedCommand( string cmd, bool noStack = false )
{
	string msg = cmd

	foreach( string macro, MacroInfo info in macros )
	{
		while( msg.find( macro ) != null )
			msg = StringReplace( msg, macro, info.script )
	}
	
	if( !noStack )
		msg += ";return getstackinfos(1)"

	return msg
}

string function PreProcessQuerScriptArgs( array<string> args )
{
	return ReplacedCommand( CombineArgs( args ) )
}

void function ExecutePreProcessedScript( string script, bool noStack = false )
{
	if( script == "help ;return getstackinfos(1)" )
	{
		PrintQuerschnittHelp( "safeScript" )
		return
	}
	try {
		var buffered = compilestring( script )()
		if( "locals" in buffered && buffered.locals.len() > 1 )
		{
			table safeTable
			foreach( k, v in buffered.locals )
			{
				safeTable[ string( k ) ] <- string( v )
			}

			delete safeTable[ "this" ]

			printt( safeTable )
		} else {
			if( buffered )
				printt( format( "[INEXPLICIT] %s", allcontents( buffered ) ) )
		}
	} catch( e ) {
		PrintPreProcessorError( e, script )
		if( e == "Expression evaluates to a value that doesn't do anything" )
		{
			ExecutePreProcessedScript( "return " + script, true )
		}
	}
}

void function PrintPreProcessorError( var error, string pre )
{
	printt( format( "ERROR: %s\n[PREPROCESSED] %s", string( error ), pre ) )
}

void function errcall( string script, entity initiator = null )
{
	var result
	try {
		result = compilestring( script )()
		printinexplicit( result )
	} catch( e ) {
		PrintPreProcessorError( e, script )
	}
}

string function allcontents( var v, string pre = "" )
{
	switch ( type( v ) )
	{
		case "table":
			return tablecontents( expect table( v ), pre )
		case "array":
			return arraycontents( expect array( v ), pre )
		case "entity":
			return entitycontents( expect entity( v ), pre )
		default:
			return pre + v
	}
	unreachable
}

string function arraycontents( array arr, string pre = "" )
{
	string msg = format( "%s (%i)", arr.tostring(), arr.len() )
	foreach(int i, var val in arr )
		msg += format( "\n%s%i: %s", pre, i, strip( allcontents( val, pre + " " ) ) )
	return msg
}

string function tablecontents( table tbl, string pre = "" )
{
	string msg = format( "%s (%i)", tbl.tostring(), tbl.len() )
	foreach(var k, var val in tbl)
		msg += format( "\n%s%s: %s", pre, k, strip( allcontents( val, pre + " " ) ) )
	return msg
}

string function entitycontents( entity e, string pre = "" )
{
	int LONGEST_KEY_LEN

	table<string, string> contents
	#if UI

	#else
	contents.name <- e.GetScriptName()
	contents["class"] <- e.GetClassName()
	contents.origin <- e.GetOrigin().tostring()
	contents.angles <- e.GetAngles().tostring()
	contents.team <- GetFormattedTeam( e.GetTeam() )

	if ( !contents.name.len() )
		contents.name = "( NO SCRIPT NAME )"
	#endif


	foreach( k, v in contents )
	{
		int l = k.len()
		if( l > LONGEST_KEY_LEN )
			LONGEST_KEY_LEN = l
	}

	string result = expect string( e.tostring() )

	foreach( k, v in contents )
	{
		string padding
		for( int i = k.len(); i < LONGEST_KEY_LEN; i++ )
		{
			padding += " "
		}
		result += format( "\n%s# %s%s : %s", pre, k, padding, v )
	}
	return result
}

string function GetFormattedTeam( int team )
{
	switch ( team )
	{
		case TEAM_MILITIA:
			return format( "militia (%i)", TEAM_MILITIA )
		case TEAM_IMC:
			return format( "imc (%i)", TEAM_IMC )
		case TEAM_UNASSIGNED:
			return format( "neutral (%i)", TEAM_UNASSIGNED )
			break
		default:
			return format( "ffa %i", team )
	}
	unreachable
}

void function printall( ... )
{
	if ( vargc <= 0 )
		return
	
	if ( vargc == 1 )
		printt( allcontents( vargv[0] ) )

	else
	{
		array args
		for ( int i; i < vargc; i++)
			args.append( vargv[i] )
		printt( allcontents( args ) )
	}
}

void function printinexplicit( var v )
{
	if ( v != null )
		print( "[Expression evaluates to a value that doesn't do anything]\n[INEXPLICIT] " + allcontents( v ) )
}

string function CombineArgs( array<string> args )
{
	string msg
	foreach( int i, string arg in args )
		if ( arg == "$" || arg == "(" || arg == ")" || arg == "{" || arg == "}" || arg == "[" || arg == "]" || arg == ">" || arg == "<" || arg == "|" || arg == "&" || arg == "%" || arg == "'" || arg == "\"" )
			msg += arg
		else
			if ( i < args.len() - 1 && args[ i + 1 ] == "\"" )
				msg += arg
			else
				msg += arg + " "
		
	return msg
}

bool function StringIsNumber( string s )
{
	foreach( c in s )
	{
		if ( c != 46 && ( c < 48 || c > 57 ) )
			return false
	}
	return true
}