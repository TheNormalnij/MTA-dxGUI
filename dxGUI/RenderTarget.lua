
local currentRT 

local dxSetRenderTarget = dxSetRenderTarget

function DxRenderTarget:setAsTarget( clean )
	dxSetRenderTarget( self, clean )
	currentRT = self
end

function DxRenderTarget.getCurrentTarget( )
	return currentRT
end