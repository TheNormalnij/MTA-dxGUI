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
    local r g, b, shadowAlpha = color.HEXtoRGB( self.shadowColor )
    shadowAlpha = shadowAlpha * alpha / 255

    local subbedText = string.gsub(self.text, '#%x%x%x%x%x%x', '')
    local right = self.x + self.w
    local bottom = self.y + self.h
    local shadowColor = tocolor(r, g, b, shadowAlpha)

    dxDrawText (subbedText, self.x - self.outline, self.y - self.outline, right - self.outline, bottom - self.outline, shadowColor, self.scale, self.font, self.alignX, self.alignY, self.clip, self.wordBreak, self.postGUI, false)
    dxDrawText (subbedText, self.x + self.outline, self.y - self.outline, right + self.outline, bottom - self.outline, shadowColor, self.scale, self.font, self.alignX, self.alignY, self.clip, self.wordBreak, self.postGUI, false)
    dxDrawText (subbedText, self.x - self.outline, self.y + self.outline, right - self.outline, bottom + self.outline, shadowColor, self.scale, self.font, self.alignX, self.alignY, self.clip, self.wordBreak, self.postGUI, false)
    dxDrawText (subbedText, self.x + self.outline, self.y + self.outline, right + self.outline, bottom + self.outline, shadowColor, self.scale, self.font, self.alignX, self.alignY, self.clip, self.wordBreak, self.postGUI, false)
    dxDrawText (subbedText, self.x - self.outline, self.y, right - self.outline, bottom, shadowColor, self.scale, self.font, self.alignX, self.alignY, self.clip, self.wordBreak, self.postGUI, false)
    dxDrawText (subbedText, self.x + self.outline, self.y, right + self.outline, bottom, shadowColor, self.scale, self.font, self.alignX, self.alignY, self.clip, self.wordBreak, self.postGUI, false)
    dxDrawText (subbedText, self.x, self.y - self.outline, right, bottom - self.outline, shadowColor, self.scale, self.font, self.alignX, self.alignY, self.clip, self.wordBreak, self.postGUI, false)
    dxDrawText (subbedText, self.x, self.y + self.outline, right, bottom + self.outline, shadowColor, self.scale, self.font, self.alignX, self.alignY, self.clip, self.wordBreak, self.postGUI, false)
    dxDrawText (self.text, self.x, self.y, right, bottom, self.color, self.scale, self.font, self.alignX, self.alignY, self.clip, self.wordBreak, self.postGUI, self.colorCoded)
  end;
}
