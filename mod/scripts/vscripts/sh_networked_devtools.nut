untyped

#if UI
global function NetworkedServerCommandUIScriptSafeCallback

void function NetworkedServerCommandUIScriptSafeCallback( string script )
{
	executor = GetLocalClientPlayer()
	ExecutePreProcessedScript( script )
	executor = null
}
#elseif CLIENT || SERVER
global function DevTools_Network
global function TraceFromEnt
global function DrawNetwork
#endif

#if CLIENT
global function RegisterDrawParams

struct {
	array<var> drawPassedParams
} file
#elseif SERVER
global function DrawGlobal
#endif

#if CLIENT || SERVER
void function DevTools_Network()
{
	AddCallback_OnRegisteringCustomNetworkVars( RegisterNetworkVars )
}

void function RegisterNetworkVars()
{
    Remote_RegisterFunction( "DrawNetwork" )
	Remote_RegisterFunction( "RegisterDrawParams" )

	#if CLIENT
	AddServerToClientStringCommandCallback( "scc", ServerCommandCLIENTScriptSafeCallback )
	AddServerToClientStringCommandCallback( "suc", ServerCommandUIScriptSafeCallback )
	#endif
}

int function GetDrawID( string type )
{
	switch( type )
	{
		case "DebugDrawCircle":
		case "circle":
			return 0
		case "DebugDrawCylinder":
		case "cylinder":
			return 1
		case "DebugDrawAngles":
		case "angles":
			return 2
		case "DebugDrawSphere":
		case "sphere":
			return 3
		case "DebugDrawText":
		case "text":
			return 4
		case "DebugDrawBox":
		case "box":
			return 5
		case "DebugDrawBoxSimple":
		case "boxsimple":
			return 6
		case "DebugDrawCube":
		case "cube":
			return 7
		case "DebugDrawCircleTillSignal":
		case "circletillsignal":
			return 8
		case "DebugDrawOriginMovement":
		case "originmovement":
			return 9
		case "DebugDrawTrigger":
		case "trigger":
			return 10
		case "DebugDrawMark":
		case "mark":
			return 11
		case "DebugDrawSpawnpoint":
		case "spawnpoint":
			return 12
		case "DebugDrawCircleOnEnt":
		case "circleonent":
			return 13
		case "DebugDrawSphereOnEnt":
		case "sphereonent":
			return 14
		case "DebugDrawCircleOnTag":
		case "circleontag":
			return 15
		case "DebugDrawSphereOnTag":
		case "sphereontag":
			return 16
		case "DebugDrawWeapon":
		case "weapon":
			return 17
		case "DebugDrawMissilePath":
		case "missilepath":
			return 18
		case "DebugDrawRotatedBox":
		case "rotatedbox":
			return 19
		case "DebugDrawLine":
		case "line":
		default:
			return 20
	}
	unreachable
}

TraceResults function TraceFromEnt( entity p )
{
	TraceResults traceResults = TraceLineHighDetail( p.EyePosition(),
	p.EyePosition() + p.GetViewVector() * 10000,
	p, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
	return traceResults
}
#endif

#if SERVER
void function DrawNetwork( entity player, string type, ... )
{
	if ( vargc <= 0 )
		return

	array args = [ this, player, "DrawNetwork", GetDrawID( type ) ]
	for ( int i = 0; i < vargc; i++)
	{
		switch( typeof vargv[i] )
		{
			case "vector":
							Remote_CallFunction_NonReplay( player, "RegisterDrawParams", vargv[i].x, vargv[i].y, vargv[i].z )
				args.append( 0x99999999 )
			break
			case "entity":
				Remote_CallFunction_NonReplay( player, "RegisterDrawParams", vargv[i].GetEncodedEHandle() )
				args.append( 0x99999998 )
			break
			default:
				args.append( vargv[i] )
		}
	}

	Remote_CallFunction_NonReplay.acall( args )
}

void function DrawGlobal( string type, ... )
{
	if ( vargc <= 0 )
		return

	array args = [ type ]
	for ( int i = 0; i < vargc; i++)
		args.append( vargv[i] )

	foreach( entity player in GetPlayerArray() )
	{
		array temp = args
		temp.insert( 0, player )
		temp.insert( 0, this )
		DrawNetwork.acall( temp )
	}
}
#endif

#if CLIENT
void function RegisterDrawParams( float x, float y, float z )
{
	file.drawPassedParams.append( <x,y,z> )
}

void function DrawNetwork( string type, ... )
{
	if ( vargc <= 0 )
		return

	array args = [ this ]
	int networkedVectors
	for ( int i = 0; i < vargc; i++)
	{
		switch( vargv[i] )
		{
			case 0x99999999: // vector
				var param = file.drawPassedParams[ networkedVectors ]
				args.append( param )
				networkedVectors++
			break
			case 0x99999998: // entity
				var param = file.drawPassedParams[ networkedVectors ]
				args.append( GetEntityFromEncodedEHandle( expect int( param ) ) )
				networkedVectors++
			break
			default:
				args.append( vargv[i] )
		}
		// if ( vargv[i] == 0x99999999 )
		// {
		// 	var param = file.drawPassedParams[ networkedVectors ]
		// 	args.append( typeof param == "int" ? GetEntityFromEncodedEHandle( expect int( param ) ) : param )
		// 	networkedVectors++
		// }
		// else
		// 	args.append( vargv[i] )
	}
	file.drawPassedParams.clear()
	switch( type )
		{
			case 0:
				DebugDrawCircle.acall( args )
				break
			case 1:
				DebugDrawCylinder.acall( args )
				break
			case 2:
				DebugDrawAngles.acall( args )
				break
			case 3:
				DebugDrawSphere.acall( args )
				break
			case 4:
				DebugDrawText.acall( args )
				break
			case 5:
				DebugDrawBox.acall( args )
				break
			case 6:
				DebugDrawBoxSimple.acall( args )
				break
			case 7:
				DebugDrawCube.acall( args )
				break
			case 8:
				DebugDrawCircleTillSignal.acall( args )
				break
			case 9:
				DebugDrawOriginMovement.acall( args )
				break
			case 10:
				DebugDrawTrigger.acall( args )
				break
			case 11:
				DebugDrawMark.acall( args )
				break
			case 12:
				DebugDrawSpawnpoint.acall( args )
				break
			case 13:
				DebugDrawCircleOnEnt.acall( args )
				break
			case 14:
				DebugDrawSphereOnEnt.acall( args )
				break
			case 15:
				DebugDrawCircleOnTag.acall( args )
				break
			case 16:
				DebugDrawSphereOnTag.acall( args )
				break
			case 17:
				DebugDrawWeapon.acall( args )
				break
			case 18:
				DebugDrawMissilePath.acall( args )
				break
			case 19:
				DebugDrawRotatedBox.acall( args )
				break
			case 20:
			default:
				DebugDrawLine.acall( args )
				break
		}
}

void function ServerCommandCLIENTScriptSafeCallback( array<string> args )
{
	executor = GetLocalClientPlayer()
	ExecutePreProcessedScript( PreProcessQuerScriptArgs( args ) )
	executor = null
}

void function ServerCommandUIScriptSafeCallback( array<string> args )
{
	string msg = PreProcessQuerScriptArgs( args )
	RunUIScript( "NetworkedServerCommandUIScriptSafeCallback", msg )
}
#endif