dxGUI.text:subclass{
  type       = 'textBordered';
  outline    = 2;
  color      = 0xFFFFFFFF;
  alignX     = 'center';
  alignY     = 'center';
  clip       = false;
  wordBreak  = false;
  postGUI    = false;
  colorCoded = false;
  unicodeText = false;
  shadowColor = tocolor(0, 0, 0, 225);

  draw = function( self )
    local _, _, _, alpha = color.HEXtoRGB( self.color )
    local r, g, b, shadowAlpha = color.HEXtoRGB( self.shadowColor )
    shadowColor = tocolor(r, g, b, shadowAlpha * alpha / 255)
    for oX = (self.outline * -1), self.outline do
			for oY = (self.outline * -1), self.outline do
				dxDrawText(string.gsub(self.text, '#%x%x%x%x%x%x', ''), self.x + oX, self.y + oY, self.x + self.w + oX, self.y + self.h + oY, shadowColor, self.scale, self.font, self.alignX, self.alignY, self.clip, self.wordBreak, self.postGUI, false)
	 		end
		end
		dxDrawText(self.text, self.x, self.y, self.x + self.w, self.y + self.h, self.color, self.scale, self.font, self.alignX, self.alignY, self.clip, self.wordBreak, self.postGUI, self.colorCoded)
  end;
}
