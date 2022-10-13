global function DevInfoGunInit
global function OnDevInfoGunFire
global function sel

#if SERVER

struct {
	table<entity, entity> cachedProps
} file

#elseif CLIENT

struct {
	var rui
	float destroyTime
	entity clientProp
	table<entity, entity> cachedProps
} file

void function DestroyInfoRUIAfterTime()
{
	while ( 1 )
	{
		if ( Time() >= file.destroyTime && file.rui )
		{
			RuiDestroyIfAlive( file.rui )
			if ( IsValid( file.clientProp ) )
				file.clientProp.Destroy()
		}
			
		WaitFrame()
	}
}

#endif

entity function sel( entity owner )
{
	return file.cachedProps[owner]
}

void function DevInfoGunInit()
{
	PrecacheWeapon( "mp_dev_info_gun" )

	#if CLIENT
	thread DestroyInfoRUIAfterTime()
	#endif
}

var function OnDevInfoGunFire( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )

	TraceResults traceResults = TraceLineHighDetail( weapon.GetOwner().EyePosition(),
	weapon.GetOwner().EyePosition() + weapon.GetOwner().GetViewVector() * 10000,
	weapon.GetOwner(), TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
	entity e = traceResults.hitEnt
	entity owner = weapon.GetWeaponOwner()
	if( owner in file.cachedProps )
		file.cachedProps[owner] = e
	else
		file.cachedProps[owner] <- e

	#if SERVER

	#elseif CLIENT
		if ( file.rui )
		{
			RuiDestroyIfAlive( file.rui )
			file.destroyTime = Time() + 10.0
		}

		if ( e )
		{
			string[2] infos = GetPropInfo( e )

			string rui_info = infos[0]
			string console_info = infos[1]

			if ( e.GetParent() )
			{
				string[2] parentInfos = GetPropInfo( e.GetParent() )
				rui_info += "\n\n --- PARENT ---\n\n" + parentInfos[0]
				console_info += "\n|\n| --- PARENT ---\n|\n|" + parentInfos[1]
			}

			file.rui = RuiCreate($"ui/cockpit_console_text_top_left.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 15)
			RuiSetFloat(file.rui, "msgFontSize", 20)
			RuiSetFloat3(file.rui, "msgColor", <1,1,1>)
			RuiSetFloat(file.rui, "msgAlpha", 1)

			RuiSetString(file.rui, "msgText", rui_info )

			printt( format( "\n========== PROP INFO ==========\n%s\n===============================", console_info ) )

			if ( IsValid( file.clientProp ) )
				file.clientProp.Destroy()

			if ( e.GetModelName().tostring().find("$\"*") != 0 && !e.IsWorld() )
			{
				file.clientProp = CreateClientSidePropDynamic( e.GetOrigin(), e.GetAngles(), e.GetModelName() )
				file.clientProp.SetParent( e )

				SonarViewModelHighlight( file.clientProp, HIGHLIGHT_COLOR_NEUTRAL )
			}
		}

	#endif

	return 1
}

// var function OnDevInfoGunFire( entity weapon, WeaponPrimaryAttackParams attackParams )
// {
// 	array<entity> hits
// 	entity e

// 	do {
// 		TraceResults traceResults = TraceLineHighDetail( weapon.GetOwner().EyePosition(),
// 		weapon.GetOwner().EyePosition() + weapon.GetOwner().GetViewVector() * 10000,
// 		hits, TRACE_MASK_PLAYERSOLID | TRACE_MASK_TITANSOLID | TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_PLAYER  )
// 		e = traceResults.hitEnt
// 		hits.append( traceResults.hitEnt )
// 	} while( e )

// 	#if CLIENT
// 	foreach( entity hit in hits )
// 	{
// 		printt( hit )
// 	}
// 	#endif
// }

string[2] function GetPropInfo( entity e )
{
	string[2] infos

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

	infos[0] = format("%s \n%s\norigin %s\nangles %s\n%s\n%s",scriptName ,className ,origin ,angles ,assetName, team )
	infos[1] = format("|script name: %s \n|class: %s\n|origin: %s\n|angles: %s\n|model: %s\n|team: %s",scriptName ,className ,origin ,angles ,assetName,team )

	return infos
}