
local currentRT

local drawingOffsetsEnabled = false

local dxSetRenderTarget = dxSetRenderTarget

local _dxDrawImage = dxDrawImage
local _dxDrawText = dxDrawText

local function setDrawingOffset( offX, offY )
	if offX and offY then
		dxDrawImage = function( x, y, ... )
			_dxDrawImage( x - offX, y - offY, ... )
		end
		dxDrawText = function( text, x1, y1, x2, y2, ... )
			_dxDrawText( text, x1 - offX, y1 - offY, x2 - offX, y2 - offY, ... )
		end
		drawingOffsetsEnabled = true
	else
		dxDrawImage = _dxDrawImage
		dxDrawText = _dxDrawText
		drawingOffsetsEnabled = false
	end
end

function DxRenderTarget:setAsTarget( clean, offX, offY )
	dxSetRenderTarget( self, clean )
	currentRT = self
	setDrawingOffset( offX, offY )
end

function DxRenderTarget.setDrawingOffset( offX, offY )
	return setDrawingOffset( offX, offY )
end

function DxRenderTarget.getCurrentTarget( )
	return currentRT
end