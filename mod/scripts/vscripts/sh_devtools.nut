untyped
globalize_all_functions

void function errcall( string script, entity initiator = null )
{
	var result
	try {
		result = compilestring( script )()
	} catch( e ) {
		result = "ERROR:" + e + "\n[PREPROCESSED] " + script 
	}
	printinexplicit( result )
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