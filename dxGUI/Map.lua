dxGUI.baseClass:subclass{
	type = 'map';
	reguestScreen = true;

	useRenderTarget = false;

	camRootRad = 0;

	minZoom = 0.5;
	maxZoom = 5;
	zoom = 2;

	restrictMovement = false;

	-- World map border
	leftX = -3000;
	rightX = 3000;
	topY = -3000;
	bottomY = 3000;

	mapIsCircle = false;

	drawBlips = false;
	drawOutBlips = true;
	checkBlipDistance = false;
	blipZoom = 1;

	drawPlayersNames = false;
	drawPlayersNamesDistance = 100;

	drawLocalPlayer = false;

	drawNorth = false;

	borderColor = 0xFFFFFFFF;

	create = function( self )

		self.radarW = self.radarW or self.w
		self.radarH = self.radarH or self.h

		self.map = self.map or DxTexture( self.mapPath )

		if not self.map then
			self:errorHandler( 'Failed to load map' )
			return false
		end

		self.mapW, self.mapH = self.map:getSize()

		self.mapCenterX = self.mapCenterX or self.mapW / 2 
		self.mapCenterY = self.mapCenterY or self.mapH / 2

		local offsetX = ( self.mapW / 2 - self.mapCenterX )
		if offsetX ~= 0 then
			self.worldOffsetFromCenterX = ( self.rightX - self.leftX ) / ( self.mapW / 2 - self.mapCenterX ) * 4
		else
			self.worldOffsetFromCenterX = 0
		end

		local offsetY = ( self.mapCenterY - self.mapH / 2 )
		if offsetY ~= 0 then
			self.worldOffsetFromCenterY = ( self.topY - self.bottomY ) / offsetY * 4
		else
			self.worldOffsetFromCenterY = 0
		end

		self.UVPosition = { 0, 0 }

		if self.playerIconPath then
			self.playerIcon = DxTexture( self.playerIconPath )

			if not self.playerIcon then
				self:errorHandler( 'Failed to load player icon' )
				self.drawLocalPlayer = false
			end

		end

		if self.mapMaskPath then
			self.mapMask = DxTexture( self.mapMaskPath )

			if not self.mapMask then
				self:errorHandler( 'Failed to load map mask' )
				return false
			end

		else
			self.radarMask = DxTexture( self.w, self.h )
		end

		if self.blipsRootPath then
			self:loadBlips( self.blipsRootPath )

			if not self.playerIcon and self.drawLocalPlayer then
				self.playerIcon = self.blips[2]
			end
		elseif not self.blips then
			self.drawBlips = false
		end

		if self.blipObject then
			self.blipObjects = {}
			self:addEventHandler( 'onElementDestroy', root, self.onElementDestroy )
		end

		self.shader = dxCreateShader( "dxGUI/shaders/hud_mask.fx" )

		self:setDrawType( self.useRenderTarget )

		--dxSetShaderValue( self.shader, "sPicTexture", self.map )
		if self.mapMask then
			dxSetShaderValue( self.shader, "sMaskTexture", self.mapMask );
		end

		if self.mapIsCircle then
			self.mapRadius = self.mapRadius or self.w / 2
		end

		dxSetShaderValue( self.shader, "gUVPosition", 0, 0 )
		dxSetShaderValue( self.shader, "gUVRotAngle", 0 )
		dxSetShaderValue( self.shader, "gUVRotCenter", 0.5, 0.5 )
		dxSetShaderValue( self.shader, "gUVScale", 1, 1 )
		dxSetShaderValue( self.shader, "gUVScaleCenter", 0.5, 0.5 )
		dxSetShaderValue( self.shader, "borderColor", self.borderColor )

		return self
	end;

	loadBlips = function( self, blipsRootPath )
		local blips = self.blips
		if blips then
			for key, blipTexture in pairs( blips ) do
				blipTexture:destroy()
			end
		else
			blips = {}
			self.blips = blips
		end

		for i = 0, 63 do
			blips[i] = DxTexture( blipsRootPath .. i .. '.png' )
		end
		return true
	end;

	setDrawType = function( self, isRenderTargerType )
		if isRenderTargerType then
			if not self.renderTarget then
				self.renderTarget = DxRenderTarget( self.mapW, self.mapH )
				dxSetShaderValue( self.shader, "sPicTexture", self.renderTarget )
				self.draw = self.drawInRenderTarget
				return true
			end
			return false
		else
			if self.renderTarget then
				self.renderTarget:destroy()
				self.renderTarget = nil
			end
			dxSetShaderValue( self.shader, "sPicTexture", self.map )
			self.draw = self.drawOnShader
			return true
		end
	end;

	drawOnShader = function ( self )

		local camRootRad = self.camRootRad
		dxSetShaderValue( self.shader, "gUVRotAngle", -camRootRad )

		local shaderZoom = 1/self.zoom
		dxSetShaderValue( self.shader, "gUVScale", shaderZoom, shaderZoom * self.w/self.h )
		dxSetShaderValue( self.shader, "gUVPosition", self.UVPosition[1], self.UVPosition[2] )

		dxDrawImage( self.x, self.y, self.w, self.h, self.shader )

		if self.drawPlayerNames then

			local mapOffsetX = ( self.w - self.radarW ) / 2
			local mapOffsetY = ( self.h - self.radarH ) / 2

			local function drawPlayerName( player, pos )
				local x = drawCenterX + pos.x / 6000 * screenW  * self.zoom
				local y = drawCenterY + pos.y / -6000 * screenW * self.zoom + 10
				dxDrawText( player:getName(), x, y, x, y, tocolor( 0, 0, 0 ), self.zoom + 0.2,
					 "default-bold", "center", "top", false, false, false, true )
			end

			if self.mapPlayerNameMode == 1 then
				for _, player in pairs( getElementsByType( 'player' ) ) do
					drawPlayerName( player, player:getPosition() )
				end
			elseif self.mapPlayerNameMode == 2 then
				for _, player in pairs( getElementsByType( 'player' ) ) do
					local pPos = player:getPosition()
					if ( pPos - vPos ):getLength() < 100 then
						drawPlayerName( player, pPos )
					end
				end
			end

		end

		local lpPos = localPlayer:getPosition()
		local pX = lpPos.x
		local pY = lpPos.y


		local blipSizeMod = 32 / 4 * self.blipZoom

		local mapOffsetX = ( self.w - self.radarW ) / 2
		local mapOffsetY = ( self.h - self.radarH ) / 2

		local drawCenterX = self.x + self.w / 2
		local drawCenterY = self.y + self.h / 2

		if self.drawBlips then

			local bS, halfBS

			if self.mapIsCircle then
				local radius = self.mapRadius

				for _, blip in pairs( getElementsByType( 'blip' ) ) do

					local blipX, blipY, blipZ = getElementPosition( blip )
					local distance = ( ( lpPos.x - blipX )^2 + ( lpPos.y - blipY )^2 ) ^ 0.5
					local blipRot = math.atan2( blipX - pX, blipY - pY ) + camRootRad
					local attached = getElementAttachedTo( blip )
					if distance <= blip:getVisibleDistance() and attached ~= localPlayer then

						local pixelDistance = distance / self.bottomY * self.zoom * self.w / 2
						local iconID = blip:getIcon()

						local bcR, bcG, bcB, bcA = getBlipColor( blip )
						if iconID ~= 0 then
							bcR, bcG, bcB = 255, 255, 255
						end
						bS = blip:getSize() * blipSizeMod
						halfBS = bS / 2

						if pixelDistance < radius then
							dxDrawImage( 
								drawCenterX + pixelDistance * math.cos( blipRot - math.pi/2 ) - halfBS,
								drawCenterY + pixelDistance * math.sin( blipRot - math.pi/2 ) - halfBS,
								bS, bS, self.blips[iconID], 0, 0, 0, tocolor(bcR, bcG, bcB, bcA)
							)
						elseif self.drawOutBlips then
							dxDrawImage( 
								drawCenterX + radius * math.cos( blipRot - math.pi/2 ) - halfBS,
								drawCenterY + radius * math.sin( blipRot - math.pi/2 ) - halfBS,
								bS, bS, self.blips[iconID], 0, 0, 0, tocolor(bcR, bcG, bcB, bcA)
							)
						end

					end
				end
			else

				for _, blip in pairs( getElementsByType( 'blip' ) ) do

					local blipX, blipY, blipZ = getElementPosition( blip )
					local distance = ( ( lpPos.x - blipX )^2 + ( lpPos.y - blipY )^2 ) ^ 0.5
					local blipRot = math.atan2( blipX - pX, blipY - pY ) + camRootRad
					local attached = getElementAttachedTo( blip )
					if distance <= blip:getVisibleDistance() and attached ~= localPlayer then

						local pixelDistance = distance / self.bottomY * self.zoom * self.w / 2
						local iconID = blip:getIcon()

						local bcR, bcG, bcB, bcA = getBlipColor( blip )
						if iconID ~= 0 then
							bcR, bcG, bcB = 255, 255, 255
						end
						bS = blip:getSize() * blipSizeMod
						halfBS = bS / 2
						
						local drawBlipX = drawCenterX + pixelDistance * math.cos( blipRot - math.pi/2 ) - halfBS
						local drawBlipY = drawCenterY + pixelDistance * math.sin( blipRot - math.pi/2 ) - halfBS

						local clampX = math.clamp( self.x - halfBS + mapOffsetX, drawBlipX, self.x + self.w - halfBS - mapOffsetX )
						local clampY = math.clamp( self.y - halfBS + mapOffsetY, drawBlipY, self.y + self.h - halfBS - mapOffsetY )

						if self.drawOutBlips or ( clampX == drawBlipX and clampY == drawBlipY ) then
							dxDrawImage( clampX, clampY, bS, bS, self.blips[iconID], 0, 0, 0, tocolor(bcR, bcG, bcB, bcA) )
						end

					end
				end

			end

		end

		if self.drawNorth then
			if self.mapIsCircle then
				local bS = 2.5 * blipSizeMod
				local halfBS = bS / 2
				local blipRot = self.camRootRad
				dxDrawImage(
					drawCenterX + self.mapRadius * math.cos( blipRot - math.pi/2 ) - halfBS,
					drawCenterY + self.mapRadius * math.sin( blipRot - math.pi/2 ) - halfBS,
					bS, bS, self.blips[4], 0, 0, 0
				)
			else
				local radarRadius = ( (self.radarW/2)^2 + (self.radarH/2)^2 )^0.5
				dxDrawImage( mapOffsetX + self.x + math.max( 0, self.radarW / 2 + math.min( self.radarW / 2, math.cos( self.camRootRad - math.pi/2 ) * radarRadius ) ) - 1.25 * blipSizeMod,
					mapOffsetY + self.y + math.max( 0, self.radarH / 2 +  math.min( self.radarH / 2, math.sin( self.camRootRad - math.pi/2 ) * radarRadius ) ) - 1.25 * blipSizeMod,
					2.5 * blipSizeMod, 2.5 * blipSizeMod, self.blips[4] )
			end
		end

		if self.drawLocalPlayer then
			local _,_, rz = getElementRotation( localPlayer )
			dxDrawImage( self.x - 1.25 * blipSizeMod + self.w / 2 , self.y - 1.25 * blipSizeMod + self.h / 2, 2.5 * blipSizeMod, 2.5 * blipSizeMod, self.playerIcon, -rz + math.deg( camRootRad ), 0, 0 )
		end

	end;

	drawInRenderTarget = function( self )

		dxSetShaderValue( self.shader, "gUVScale", 1/self.zoom, 1/self.zoom * self.h/self.w * self.mapW / self.mapH )
		dxSetShaderValue( self.shader, "gUVPosition", self.UVPosition[1], self.UVPosition[2] )

		self.renderTarget:setAsTarget()

		dxDrawImage( 0, 0, self.mapW, self.mapH, self.map )

		local lpPos = localPlayer:getPosition()

		if self.drawBlips then

			local mapOffsetX = ( self.w - self.radarW ) / 2
			local mapOffsetY = ( self.h - self.radarH ) / 2

			for _, blip in pairs( getElementsByType( 'blip' ) ) do

				local blipX, blipY, blipZ = getElementPosition( blip )

				if not self.checkBlipDistance
					or ( ( lpPos.x - blipX )^2 + ( lpPos.y - blipY )^2 ) ^ 0.5 <= blip:getVisibleDistance()
				then
					local drawBlipX = self.mapW / ( -self.leftX + self.rightX ) * ( blipX - self.leftX )
					local drawBlipY = self.mapH / ( -self.topY + self.bottomY ) * ( -blipY - self.topY )

					self:drawBlip( blip, drawBlipX, drawBlipY )
				end

			end
		end

		dxSetRenderTarget()

		dxDrawImage( self.x, self.y, self.w, self.h, self.shader, 0, 0, 0, self.color )
	end;

	drawBlip = function( self, blip, x, y )
		if self.blipObject then
			local blipObject = self.blipObjects[blip]
			if not blipObject then
				blipObject = {
					x = 0;
					y = 0;
					w = self.blipObject.w / ( self.scale and self.scale[1] or 1 );
					h = self.blipObject.h / ( self.scale and self.scale[2] or 1 );
					objects = table.copy( self.blipObject.objects, true );
					anims = table.copy( self.blipObject.anims or {}, true );
					style = self.style;
					show = true;

					blip = blip;

					setBlipDrawPosition = self.blipObject.setBlipDrawPosition;
					onCreate = self.blipObject.onCreate;
					updateAnims = self.blipObject.updateAnims;

				}
				self.blipObjects[blip] = blipObject
				dxConstruction( blipObject, false )

				if blipObject.onCreate then
					blipObject:onCreate( )
				end

				self:addEventHandler( 'onClientElementDestroy', blip, function()
					self.blipObjects[blip] = nil
				end )

			end
			blipObject:setBlipDrawPosition( x, y )

			blipObject:updateAnims()
			blipObject:draw()
		else
			local iconID = blip:getIcon()

			local bcR, bcG, bcB, bcA = getBlipColor( blip )
			if iconID ~= 0 then
				bcR, bcG, bcB = 255, 255, 255
			end

			local bS = blip:getSize() * self.blipZoom
			dxDrawImage( x - 32 * 0.5 * bS, y - 32 * 0.5 * bS, 32 * bS, 32 * bS, self.blips[iconID], 0, 0, 0, tocolor(bcR, bcG, bcB, bcA) )
		end
	end;

	onClick = function( self, button, state, cX, cY )
		local dcX, dcY = self:getDrawCenter()
		-- cX = drawCenterX + vPos.x / 6000 * screenW  * self.zoom - 16
		if self.onMapClick then
			local x = ( cX - dcX ) * ( self.rightX - self.leftX ) / self.w / self.zoom + self.worldOffsetFromCenterX * 1.25
			local y = ( cY - dcY ) * -( self.bottomY - self.topY ) / self.h / self.zoom * self.h/self.w * self.mapW / self.mapH + self.worldOffsetFromCenterY * 1.25
			self:onMapClick( button, state, cX, cY, x, y )
		end
	end;

	getDrawCenter = function( self )
		return self.x + self.w / 2 - self.w * self.UVPosition[1] * self.zoom,
			self.y + self.h / 2 - self.h * self.UVPosition[2] * self.zoom * self.w/self.h * self.mapH / self.mapW
	end;

	getOffScreenSize = function( self )
		local offscreenSizeX, offscreenSizeY
		if self.offscreenSizeX then
			offscreenSizeX = self.offscreenSizeX
		else
			offscreenSizeX = ( 1 - 1/self.zoom ) / 2
		end
		if self.offscreenSizeY then
			offscreenSizeY = self.offscreenSizeX
		else
			offscreenSizeY = ( 1 - 1/self.zoom * self.h/self.w ) / 2
		end

		return offscreenSizeX, offscreenSizeY
	end;

	setZoom = function( self, zoom )
		self.zoom = math.clamp( self.minZoom, zoom, self.maxZoom )
		if self.restrictMovement then
			local offscreenSizeX, offscreenSizeY = self:getOffScreenSize()
			self.UVPosition[1] = math.clamp( -offscreenSizeX, self.UVPosition[1], offscreenSizeX )
			self.UVPosition[2] = math.clamp( -offscreenSizeY, self.UVPosition[2], offscreenSizeY )
		end
	end;

	getZoom = function( self )
		return self.zoom
	end;

	move = function( self, moveX, moveY )
		if self.restrictMovement then
			local offscreenSizeX, offscreenSizeY = self:getOffScreenSize()
			self.UVPosition[1] = math.clamp( -offscreenSizeX, self.UVPosition[1] + moveX, offscreenSizeX )
			self.UVPosition[2] = math.clamp( -offscreenSizeY, self.UVPosition[2] + moveY, offscreenSizeY )
		else
			self.UVPosition[1] = self.UVPosition[1] + moveX
			self.UVPosition[2] = self.UVPosition[2] + moveY
		end
	end;

	setMapCenterPosition = function( self, x, y )
		self.UVPosition[1] = -0.5 + ( x - self.leftX ) / ( self.rightX - self.leftX )
		self.UVPosition[2] = -0.5 + ( y - self.bottomY ) / ( self.topY - self.bottomY )
	end;

	onElementDestroy = function( self )
		local blipObject = self.blipObjects[source]
		if blipObject then
			--blipObject:destroy()
			self.blipObjects[source] = nil
		end
	end;

	setScale = function( self, scale, scaleY )
		scaleY = scaleY or scale
		self.w, self.h = self.w * scale, self.h * scaleY
		if self.mapRadius then
			self.mapRadius = self.mapRadius * scale
		end
		self.blipZoom = self.blipZoom * scale
		self.radarW = self.radarW * scale
		self.radarH = self.radarH * scaleY
		self.blipZoom = self.blipZoom * scale
	end;
}

Anim{
	name = 'map_dynamicZoom';

	create = function( self, gui )
		return self
	end;

	update = function( self, gui )
		local vehicle = localPlayer:getOccupiedVehicle()
		local velocity = vehicle and vehicle:getVelocity() or localPlayer:getVelocity()
		gui.zoom = math.min( gui.minZoom/velocity:getLength(), gui.maxZoom )
		return true
	end;
}

Anim{
	name = 'map_dynamicRot';

	create = function( self, gui )
		return self
	end;

	update = function( self, gui )
		local _,_,camrot = getElementRotation( getCamera() )
		gui.camRootRad  = math.rad(camrot)
		return true
	end;
}

Anim{
	name = 'map_dynamicPosition';

	create = function( self, gui, element )
		self.element = element
		return self
	end;

	update = function( self, gui )
		local vPos = self.element:getPosition()
		gui:setMapCenterPosition( vPos.x, vPos.y )
		return true
	end;
}

Anim{
	name = 'map_wheelZoom';

	zoomFactor = 0.2;

	create = function( self, gui, zoomFactor )
		self.zoomFactor = zoomFactor or self.zoomFactor
		return self
	end;
}

Anim{
	name = 'map_softMove';
	speedFactor = 0.25;

	create = function( self, gui, speedFactor )
		self.move = gui.move
		self.speedFactor = speedFactor or self.speedFactor

		self.moveBuffer = { 0, 0 }

		gui.move = function( gui, x, y )
			self.moveBuffer[1] = self.moveBuffer[1] + x
			self.moveBuffer[2] = self.moveBuffer[2] + y
		end

		return self
	end;

	update = function( self, gui )
		if self.moveBuffer[1] ~= 0 or self.moveBuffer[2] ~= 0 then
			local x = self.moveBuffer[1] * self.speedFactor / gui.zoom
			local y = self.moveBuffer[2] * self.speedFactor / gui.zoom
			self.move( gui, x, y )
			self.moveBuffer[1] = self.moveBuffer[1] - x
			self.moveBuffer[2] = self.moveBuffer[2] - y
		end
		return true
	end;
}
