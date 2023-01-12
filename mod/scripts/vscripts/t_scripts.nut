#if SERVER
globalize_all_functions

array<entity> function GetChildren( entity p )
{
    entity child = p.FirstMoveChild()
    array<entity> children = [ child ]

    while ( child )
    {
        children.append( child)
        child = child.NextMovePeer()
    }

    return children
}
#elseif CLIENT
globalize_all_functions

void function ctest()
{
	for( int i; i < 139; i++ )
	{
		// void functionref(var) a = void function(var p){ printt("hallo", p) }
		RegisterButtonPressedCallback( i, void function(var b){print(">>>>>>>>>>>>>>")} )
	}
}
#elseif UI
globalize_all_functions
#endif