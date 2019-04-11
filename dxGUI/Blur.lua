
local blurShader

local screenSources = {}

dxGUI.baseClass:subclass{
	type                  = 'blur';
	rotation              = 0;
	rotationCenterOffsetX = 0;
	rotationCenterOffsetY = 0;
	color                 = 0xFFFFFFFF;
	postGUI               = false;

	blurFactor = 0.9;
	screenSourceRes = { 1.0, 1.0 };

	drawScreen = true;
	reguestScreen = true;
	autoUpdate = true;

	create = function( self )

		if not self:loadShaders( )
			or not self:loadScreenSource()
		then
			return false
		end

		if self.autoUpdate then
			self:addAnim( Anim.find( 'blur-autoupdate' ) )
		end

		return self
	end;

	loadShaders = function( self )
		if not blurShader then
			blurShader = dxCreateShader( "dxGUI/shaders/blur.fx" )
		end

		if not blurShader then
			outputDebugString( 'Can`t create blur shaders', 2 )
			return false
		end

		return true
	end;

	loadScreenSource = function( self )
		local ssW = dxConstruction.screen.w * self.screenSourceRes[1]
		local ssH = dxConstruction.screen.h * self.screenSourceRes[2]
		local blurFactor = self.blurFactor

		self.screenSource = nil

		for screenSource, data in pairs( screenSources ) do
			if data[1] == ssW and data[2] == ssH and data[3] == blurFactor then
				self.screenSource = screenSource
				break;
			end
		end

		if not self.screenSource then
			self.screenSource = dxCreateScreenSource( ssW, ssH )
			if not self.screenSource then
				outputDebugString( 'Can`t create screen source', 2 )
				return false
			end
			local renderTarget = DxRenderTarget( ssW, ssH, false )
			if not renderTarget then
				outputDebugString( 'Can`t create render target', 2 )
				return false
			end

			dxUpdateScreenSource( self.screenSource, true )
			screenSources[self.screenSource] = { ssW, ssH, self.blurFactor, true, renderTarget }
		end

		return screenSources[self.screenSource]
	end;

	draw = function( self )
		local screenSourceData = screenSources[self.screenSource] or self:loadScreenSource()

		if screenSourceData then
			screenSourceData[4] = true
			dxDrawImage( self.x, self.y, self.w, self.h, screenSourceData[5], self.rotation,
				self.rotationCenterOffsetX,	self.rotationCenterOffsetY, self.color, self.postGUI )
		end
	end;

	updateBlur = function( self )
		local screenSourceData = screenSources[self.screenSource] or self:loadScreenSource()
		
		if not screenSourceData then
			return false
		end

		if not screenSourceData[4] then
			screenSourceData[4] = true
			dxUpdateScreenSource( self.screenSource, false )
		end	

		local blurRenderTarget = screenSourceData[5]

		blurRenderTarget:setAsTarget( true )

		local ssW = dxConstruction.screen.w * self.screenSourceRes[1]
		local ssH = dxConstruction.screen.h * self.screenSourceRes[2]

		dxDrawImage( 0, 0, ssW, ssH, self.screenSource )

		if self.drawScreen and self.screen then
			local plane = self.screen:getObjectPlane( self )
			for i = 1, plane - 1 do
				self.screen.plane[i]:draw()
			end
		end

		blurShader:setValue( 'texture0', blurRenderTarget )

		for i = 0, 8 do
			blurShader:setValue('factor', 0.0020 * self.blurFactor + (i / 8 * 0.001 * self.blurFactor) )
			dxDrawImage( 0, 0, ssW, ssH, blurShader )
		end

		DxRenderTarget.setAsTarget()
	end;
}

Anim{
	name = 'blur-autoupdate';

	create = function( self )
		return self
	end;

	update = function( self, blur )
		blur:updateBlur()
		return true
	end;
}

addEventHandler( 'onClientRender', root, function()
	local toRemove = {}
	for screenSource, data in pairs( screenSources ) do
		if data[4] then
			data[4] = false
		else
			screenSource:destroy()
			data[5]:destroy()
			table.insert( toRemove, screenSource )
		end
	end
	for i = 1, #toRemove do
		screenSources[ toRemove[i] ] = nil
	end
end, true, 'low-999' )
