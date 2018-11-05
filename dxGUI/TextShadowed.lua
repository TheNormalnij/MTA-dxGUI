dxGUI.text:subclass{
	type                = 'textShadowed';
	off                 = 2;
	shadowColor         = tocolor( 0, 0, 0, 50 );

	draw = function( self )
		local r, g, b, a = color.HEXtoRGB( self.shadowColor )
		local _, _, _, ta = color.HEXtoRGB( self.color )
		local shadowColor = tocolor( r, g, b, a * ta / 255 )
		dxDrawText( self.text, self.x + self.off, self.y + self.off, self.x + self.w + self.off, self.y + self.h + self.off, shadowColor, self.scale, self.font, self.alignX, self.alignY,
			self.clip, self.wordBreak, self.postGUI, self.colorCoded, self.subPixelPositioning )
		dxDrawText( self.text, self.x + self.off, self.y - self.off, self.x + self.w + self.off, self.y + self.h - self.off, shadowColor, self.scale, self.font, self.alignX, self.alignY,
			self.clip, self.wordBreak, self.postGUI, self.colorCoded, self.subPixelPositioning )
		dxDrawText( self.text, self.x - self.off, self.y - self.off, self.x + self.w - self.off, self.y + self.h - self.off, shadowColor, self.scale, self.font, self.alignX, self.alignY,
			self.clip, self.wordBreak, self.postGUI, self.colorCoded, self.subPixelPositioning )
		dxDrawText( self.text, self.x - self.off, self.y + self.off, self.x + self.w - self.off, self.y + self.h + self.off, shadowColor, self.scale, self.font, self.alignX, self.alignY,
			self.clip, self.wordBreak, self.postGUI, self.colorCoded, self.subPixelPositioning )
		dxDrawText( self.text, self.x, self.y, self.x + self.w, self.y + self.h, self.color, self.scale, self.font, self.alignX, self.alignY,
			self.clip, self.wordBreak, self.postGUI, self.colorCoded, self.subPixelPositioning )
	end;

}
