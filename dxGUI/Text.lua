dxGUI.baseClass:subclass{
	type                = 'text';
	text                = '';
	w                   = 0;
	h                   = 0;
	color               = 0xFF000000;
	scale               = 1;
	font                = 'default';
	alignX              = 'left'; -- Can be "left", "center" or "right"
	alignY              = 'top';  -- Can be "top", "center" or "bottom"
	clip                = false;
	wordBreak           = false;
	postGUI             = false;
	colorCoded          = false;
	subPixelPositioning = false;

	draw = function( self )
		dxDrawText( self.text, self.x, self.y, self.x + self.w, self.y + self.h, self.color, self.scale, self.font, self.alignX, self.alignY,
			self.clip, self.wordBreak, self.postGUI, self.colorCoded, self.subPixelPositioning )
	end;

	getText = function( self )
		return self.text
	end;

	setText = function( self, text )
		if type( text ) == 'number' then
			self.text = tostring( text )
			return true
		end
		if type( text ) == 'string' then
			self.text = text
			return true
		end
		return false
	end;

	getRealSize = function( self )
		return dxGetTextWidth( self.text, self.scale, self.font, self.colorCoded ),
			dxGetFontHeight( self.scale, self.font )
	end;

	setRealSize = function( self )
		self.w, self.h = self:getRealSize()
	end;
	
	setScale = function( self, scaleX, scaleY )
		self.w, self.h = self.w * scaleX, self.h * ( scaleY or scaleX )
		self.scale = scaleX * self.scale
	end;

}