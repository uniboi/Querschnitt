#if SERVER
global function trig

void function trig()
{
    if(!IsNewThread())
        throw "must be threaded off"

    array<entity> triggers = [ GetEntByScriptName( "maltaTriggerHangar" ), GetEntByScriptName( "maltaTriggerAngledHangar" ), GetEntByScriptName( "maltaGunDeck03Front" ), GetEntByScriptName( "maltaGunDeck03WestAngle" ), GetEntByScriptName( "maltaGunDeck03EastAngle" ) ]

    // entity ent = GetEntByScriptName( "maltaTriggerAngledHangar" )
    // DrawGlobal( "angles", ent.GetOrigin(), ent.GetAngles(), 15.0 )
    // vector max = ent.GetBoundingMaxs()
    // vector min = ent.GetBoundingMins()
    // vector attachedMax = ent.GetOrigin() + ent.GetForwardVector() * max.x + ent.GetRightVector() * max.y + ent.GetUpVector() * max.z
    // vector attachedMin = ent.GetOrigin() + ent.GetForwardVector() * min.x + ent.GetRightVector() * min.y + ent.GetUpVector() * min.z
    // DrawGlobal( "sphere", attachedMax, 25, 255, 0, 0, true, 15.0 )
    // DrawGlobal( "sphere", attachedMin, 25, 0, 255, 0, true, 15.0 )
    // DrawGlobal( "line", attachedMin, <attachedMax.x, attachedMin.y, attachedMin.z>, 0, 255, 255, true, 15.0 )
    // DrawGlobal( "line", attachedMin, <attachedMin.x, attachedMax.y, attachedMin.z>, 0, 255, 255, true, 15.0 )
    // DrawGlobal( "line", attachedMin, <attachedMin.x, attachedMin.y, attachedMax.z>, 0, 255, 255, true, 15.0 )
    // DrawGlobal( "line", attachedMax, <attachedMin.x, attachedMax.y, attachedMax.z>, 0, 255, 255, true, 15.0 )
    // DrawGlobal( "line", attachedMax, <attachedMax.x, attachedMin.y, attachedMax.z>, 0, 255, 255, true, 15.0 )
    // DrawGlobal( "line", attachedMax, <attachedMax.x, attachedMax.y, attachedMin.z>, 0, 255, 255, true, 15.0 )
    // DrawGlobal( "line", <attachedMax.x, attachedMax.y, attachedMin.z>, <attachedMax.x, attachedMin.y, attachedMin.z>, 0, 255, 255, true, 15.0 )
    // DrawGlobal( "line", <attachedMin.x, attachedMin.y, attachedMax.z>, <attachedMin.x, attachedMax.y, attachedMax.z>, 0, 255, 255, true, 15.0 )
    // DrawGlobal( "line", <attachedMax.x, attachedMax.y, attachedMin.z>, <attachedMin.x, attachedMax.y, attachedMin.z>, 0, 255, 255, true, 15.0 )
    // DrawGlobal( "line", <attachedMin.x, attachedMin.y, attachedMax.z>, <attachedMax.x, attachedMin.y, attachedMax.z>, 0, 255, 255, true, 15.0 )
    // DrawGlobal( "line", <attachedMin.x, attachedMax.y, attachedMin.z>, <attachedMin.x, attachedMax.y, attachedMax.z>, 0, 255, 255, true, 15.0 )
    // DrawGlobal( "line", <attachedMax.x, attachedMin.y, attachedMax.z>, <attachedMax.x, attachedMin.y, attachedMin.z>, 0, 255, 255, true, 15.0 )

    while( 1 )
    {
        foreach( entity ent in triggers )
            DrawGlobal( "rotatedbox", ent.GetOrigin(), ent.GetBoundingMins(), ent.GetBoundingMaxs(), ent.GetAngles(), 0, 255, 255, true, 0.1 )
            // DrawAngledBox(ent.GetOrigin(), ent.GetAngles(), ent.GetBoundingMins(), ent.GetBoundingMaxs(), 0, 255, 255, true, 0.1 )
        WaitFrame()
    }

    // DebugDrawRotatedBox( ent.GetOrigin(), ent.GetBoundingMins(), ent.GetBoundingMaxs(), ent.GetAngles(), 0, 255, 255, true, 15.0 )
}
#elseif CLIENT
global function ctest

void function ctest()
{
	for( int i; i < 139; i++ )
	{
		// void functionref(var) a = void function(var p){ printt("hallo", p) }
		RegisterButtonPressedCallback( i, void function(var b){print(">>>>>>>>>>>>>>")} )
	}
}
#elseif UI
#endif