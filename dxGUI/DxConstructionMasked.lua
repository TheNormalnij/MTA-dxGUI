
local maskShader

dxConstruction:subclass{
	type = 'constructionMasked';

	create = function( self, isGlobal )

		self.newRenderTarget = self.newRenderTarget or { withAlpha = true }

		if not dxConstruction.create( self ) then
			return false
		end

		if not self.mask then
			outputDebugString( 'This construction must have mask', 2 )
			return false
		end

		if not maskShader then
			maskShader = dxCreateShader( "dxGUI/shaders/hud_mask.fx" )
		end
		self.maskShader = maskShader

		self.mask.x = self.mask.x or 0
		self.mask.y = self.mask.y or 0

		self.mask.w = self.mask.w or self.w
		self.mask.h = self.mask.h or self.h
		self.mask.style = self.style


		self.mask.show = true

		local maskType = self.mask.type

		if not maskType then
			outputDebugString( 'Mask does not has type', 2 )
			return false
		end

		if self.style[maskType] or dxGUI[maskType] then
			self.mask.renderTarget = dxCreateRenderTarget( self.mask.w, self.mask.h, true )

			self:initObject( self.mask )
		else
			outputDebugString( 'Unknow type for mask ' .. tostring( maskType ), 2 )
			return false
		end

		return self
	end;

	draw = function( self )
		if self.show == true then
			self.mask.renderTarget:setAsTarget( true )
			self.mask:updateAnims()
			self.mask:draw()
			self.renderTarget:setAsTarget( true, self.x, self.y )
			for _, object in ipairs( self.plane ) do
				if object.show == true then
					object:updateAnims()
					object:draw()
				end
			end
			dxSetRenderTarget()
			DxRenderTarget.setDrawingOffset()
			self.maskShader:setValue( "sPicTexture", self.renderTarget )
			self.maskShader:setValue( "sMaskTexture", self.mask.renderTarget )
			dxDrawImage( self.x, self.y, self.w, self.h, self.maskShader )
		end
	end;

	setScale = function( self, scale, scaleY )
		dxConstruction.setScale( self, scale, scaleY )

		self.mask:setPosition( self.mask.x * scale, self.mask.y * scaleY )
		if self.mask.setScale then
			self.mask:setScale( scale, scaleY )
		else
			self.mask.w, self.mask.h = self.mask.w * scale, self.mask.h * scaleY
		end

		if self.mask.renderTarget then
			self.mask.renderTarget:destroy()
			self.mask.renderTarget = dxCreateRenderTarget( self.mask.w, self.mask.h, true )
		end
	end;
}
