untyped
global function InitUeberblick2

struct {
	var originalPrint
} file

void function InitUeberblick2()
{
	#if !CLIENT_HAS_UEBERBLICK
	table root = getroottable()
	file.originalPrint = root.print
	root.print = function(var s, var stacklevel = 2) {
		var stack = getstackinfos( expect int( stacklevel ) )
		var src = stack ? stack.src : "unknown"
		var line = stack ? stack.line : -1
		file.originalPrint(format("[%s:%i] %s",src,line,s.tostring()))
	}
	setroottable(root)
	#endif
}