
local currentRT

local drawingOffsetsEnabled = false

local dxSetRenderTarget = dxSetRenderTarget

local _dxDrawImage = dxDrawImage

local function setDrawingOffset( offX, offY )
	if offX and offY then
		dxDrawImage = function( x, y, ... )
			_dxDrawImage( x - offX, y - offY, ... )
		end
		drawingOffsetsEnabled = true
	else
		dxDrawImage = _dxDrawImage
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