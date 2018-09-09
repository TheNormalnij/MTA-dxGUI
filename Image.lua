dxGUI.baseClass:subclass{
	type                  = 'image';
	rotation              = 0;
	rotationCenterOffsetX = 0;
	rotationCenterOffsetY = 0;
	color                 = 0xFFFFFFFF;
	postGUI               = false;

	draw = function( self )
		dxDrawImage( self.x, self.y, self.w, self.h, self.image, self.rotation,
			self.rotationCenterOffsetX,	self.rotationCenterOffsetY, self.color, self.postGUI )
	end;

}
