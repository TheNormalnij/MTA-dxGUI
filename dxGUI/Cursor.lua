
dxGUI.baseClass:subclass{
	type                  = 'cursor';
	rotation              = 0;
	rotationCenterOffsetX = 0;
	rotationCenterOffsetY = 0;
	color                 = 0xFFFFFFFF;
	postGUI               = false;

	reguestScreen = true;

	create = function( self )

		self:setStatus( 'default' )
		self.draw = self.drawImage

		return self
	end;

	drawImage = function( self )
		dxDrawImage( self.x, self.y, self.w, self.h, self.image, self.rotation,
			self.rotationCenterOffsetX,	self.rotationCenterOffsetY, self.color, self.postGUI )
	end;

	syncedDraw = function( self )
		local rX, rY = getCursorPosition()
		if rX then
			dxDrawImage( rX * dxConstruction.screen.w, rY * dxConstruction.screen.h, self.w, self.h, self.image, self.rotation,
				self.rotationCenterOffsetX,	self.rotationCenterOffsetY, self.color, self.postGUI )
		end
	end;

	replaceMTACursor = function( self, state )
		if state == true then
			if self.draw == self.drawImage then
				self:addEventHandler( "onClientResourceStop", resourceRoot, self.onResourceStop )
			end
			self.draw = self.syncedDraw
			setCursorAlpha( 0 )
		else
			if self.draw == self.syncedDraw then
				self:removeEventHandler( "onClientResourceStop", resourceRoot, self.onResourceStop )
			end
			self.draw = self.drawImage
			setCursorAlpha( 255 )
		end
	end;

	setStatus = function( self, status )
		if self.status == status then
			return false
		end
		if self.statusSounds and self.statusSounds[status] then
			local sound = Sound( self.statusSounds[status] )
			if sound then
				addEventHandler( 'onClientSoundStopped', sound, function( )
					sound:destroy()
				end )
			end
		end
		if self.stats and self.stats[status] then
			self.status = status
			table.unite( self, self.stats[status], true )
			return true
		end
		return false
	end;

	setShow = function( self, show )
		if type( show ) == 'boolean' then
			if not show then
				for _, object in pairs( self.screen.plane ) do
					if object.needCursor and object:isShow() then
						return false
					end
				end
			end
			self.show = show
			if self.draw == self.syncedDraw then
				showCursor( show )
				setCursorAlpha( show and 0 or 255 )
			end
			return true
		end
		return false
	end;

	onResourceStop = function( self )
		self:setShow( false )
		setCursorAlpha( 255 )
	end;

}

Anim{
	name = 'cursor_aways_on_top';

	create = function( self )
		return self
	end;

	update = function( self, cursor )
		local screenPlane = cursor.screen.plane
		if screenPlane[ #screenPlane ] ~= cursor then
			table.removeValue( screenPlane, cursor )
			table.insert( screenPlane, cursor )
		end
		return true
	end;

}