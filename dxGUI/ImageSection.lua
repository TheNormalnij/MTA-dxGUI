dxGUI.baseClass:subclass{
	type                  = 'imageSection';
	u                     = 0;
	v                     = 0;

	rotation              = 0;
	rotationCenterOffsetX = 0;
	rotationCenterOffsetY = 0;
	color                 = 0xFFFFFFFF;
	postGUI               = false;

	create = function( self )
		self.us = self.us or self.w
		self.uv = self.vs or self.h
		return self
	end;

	draw = function( self )
		dxDrawImageSection( self.x, self.y, self.w, self.h, self.u, self.v, self.us, self.vs, self.image, self.rotation,
			self.rotationCenterOffsetX,	self.rotationCenterOffsetY, self.color, self.postGUI )
	end;

}
