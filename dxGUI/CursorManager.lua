
local guiWithCursor = {}

CursorManager = {

	addGui = function( guiObject )
		if not CursorManager.isGuiRequireCursor( guiObject ) then
			table.insert( guiWithCursor, guiObject )
		end
		showCursor( true )
	end;

	removeGui = function( guiObject )
		if table.removeValue( guiWithCursor, guiObject )
			and #guiWithCursor == 0
			and isCursorShowing()
		then
			showCursor( false )
		end
	end;

	isGuiRequireCursor = function( guiObject )
		return table.find( guiWithCursor, guiObject )
	end;

}