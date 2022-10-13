untyped
globalize_all_functions

void function errcall( string script, entity initiator = null )
{
	try {
		compilestring( script )()
	} catch( e ) {
		printt( "ERROR:" + e + "\n" + script )
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
	#if UI
	return "( UI doesn't have any info )"
	#else
	string scriptName = e.GetScriptName()
	string className = e.GetClassName()
	string origin = e.GetOrigin().tostring()
	string angles = e.GetAngles().tostring()
	string assetName = e.GetModelName().tostring()
	string team

	switch ( e.GetTeam() )
	{
		case TEAM_MILITIA:
			team = format( "militia (%i)", TEAM_MILITIA )
			break
		case TEAM_IMC:
			team = format( "imc (%i)", TEAM_IMC )
			break
		case TEAM_UNASSIGNED:
			team = format( "neutral (%i)", TEAM_UNASSIGNED )
			break
		default:
			team = format( "ffa %i", e.GetTeam() )
	}

	if ( !scriptName.len() )
		scriptName = "( NO SCRIPT NAME )"

	return e.tostring() +
		"\n" + pre + "# name   : " + scriptName + 
		"\n" + pre + "# class  : " + className +
		"\n" + pre + "# origin : " + origin +
		"\n" + pre + "# angles : " + angles +
		"\n" + pre + "# model  : " + assetName +
		"\n" + pre + "# team   : " + team
	#endif
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