dxGUI.baseClass:subclass{
	type  = 'rectangle';
	color = 0xFF000000;
	postGUI = false;

	draw = function( self )
		dxDrawRectangle( self.x, self.y, self.w, self.h, self.color, self.postGUI )
	end;

	setPostGUI = function( self, state )
		if state == true or state == false then
			self.postGUI = state
		end
	end;
}