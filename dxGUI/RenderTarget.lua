
local currentRT

local drawingOffsetsEnabled = false

local _dxSetRenderTarget = dxSetRenderTarget

local _dxDrawImage = dxDrawImage
local _dxDrawText = dxDrawText
local _dxDrawImageSection = dxDrawImageSection
local _dxDrawRectangle = dxDrawRectangle

local function setDrawingOffset( offX, offY )
	if offX and offY then
		dxDrawImage = function( x, y, ... )
			_dxDrawImage( x - offX, y - offY, ... )
		end
		dxDrawText = function( text, x1, y1, x2, y2, ... )
			_dxDrawText( text, x1 - offX, y1 - offY, x2 - offX, y2 - offY, ... )
		end
		dxDrawImageSection = function( x, y, ... )
			_dxDrawImageSection( x - offX, y - offY, ... )
		end
		dxDrawRectangle = function( x, y, ... )
			_dxDrawRectangle( x - offX, y - offY, ... )
		end
		drawingOffsetsEnabled = true
	else
		dxDrawImage = _dxDrawImage
		dxDrawText = _dxDrawText
		dxDrawImageSection = _dxDrawImageSection
		dxDrawRectangle = _dxDrawRectangle
		drawingOffsetsEnabled = false
	end
end

function DxRenderTarget:setAsTarget( clean, offX, offY )
	_dxSetRenderTarget( self, clean )
	currentRT = self
	setDrawingOffset( offX, offY )
end

function DxRenderTarget.setDrawingOffset( offX, offY )
	return setDrawingOffset( offX, offY )
end

function DxRenderTarget.getCurrentTarget( )
	return currentRT
end

function dxSetRenderTarget( target, clean )
	_dxSetRenderTarget( target, clean  )
	currentRT = target
	setDrawingOffset( )
end