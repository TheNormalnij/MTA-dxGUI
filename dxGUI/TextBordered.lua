-- from https://wiki.multitheftauto.com/wiki/DxDrawBorderedText
dxGUI.text:subclass{
	type       = 'textBordered';
	outline    = 2;
  color      = 0xFFFFFFFF;
  alignX     = 'center';
  alignY     = 'center';
  clip       = false;
  wordBreak  = false;
  postGUI    = false;

	draw = function( self )
    for oX = (self.outline * -1), self.outline do
      for oY = (self.outline * -1), self.outline do
          dxDrawText (self.text, self.x + oX, self.y + oY, self.x + self.w + oX, self.y + self.h + oY, tocolor(0, 0, 0, 255), self.scale, self.font, self.alignX, self.alignY, self.clip, self.wordBreak, self.postGUI, false)
      end
    end
    dxDrawText (self.text, self.x, self.y, self.x + self.w, self.y + self.h, self.color, self.scale, self.font, self.alignX, self.alignY, self.clip, self.wordBreak, self.postGUI, self.colorCoded)
  end;
}
