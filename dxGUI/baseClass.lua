dxGUI = {

	baseClass = class{

		__call = function( self, newObject, ... )
			setmetatable( newObject, self )
			return newObject:create( ... )
		end;

		create = function( self )
			if not ( self.x or self.y or self.w or self.h ) then
				return false
			end
			return self
		end;

		subclass = function( self, newClass )
			newClass.__index = newClass
			self.__call = self.__call
			setmetatable( newClass, self )
			if newClass.type then
				dxGUI[ newClass.type ] = newClass
			end
			return newClass
		end;

		setPosition = function( self, x, y )
			if not ( x or y ) then
				return false
			end
			self.x, self.y = x, y
			return true
		end;

		getPosition = function( self )
			return self.x, self.y
		end;

		setSize = function( self, w, h )
			if type( w ) == 'number' then
				self.w = w
			end
			if type( h ) == 'number' then
				self.h = h
			end
		end;

		getSize = function( self )
			return self.w, self.h
		end;

		setShow = function( self, show )
			if type( show ) == 'boolean' then
				self.show = show
				return true
			end
			return false
		end;

		isShow = function( self )
			return self.show
		end;

		isOnCursor = function( self )
			local cX, cY = getCursorPosition( )
			if not cX then return false; end
			local sX, sY = guiGetScreenSize()
			cX, cY = cX * sX, cY * sY -- To absolute value
			if self.x < cX and self.x + self.w > cX and self.y < cY and self.y + self.h > cY then
				return true
			end
			return false
		end;

		setColor = function( self, ... )
			local arg = { ... }
			local color
			if #arg == 1 then
				color = ...
			else
				color = tocolor( ... )
			end
			if not color then
				return false
			end
			self.color = color
			return true
		end;

		getColor = function( self )
			return self.color or 0xFFFFFFFF
		end;

		setAlpha = function( self, alpha )
			if type( alpha ) ~= 'number' then
				return false
			end
			alpha = math.ceil( alpha )
			if self.color then
				local r, g, b = color.HEXtoRGB( self:getColor() )
				self.color = tocolor( r, g, b, alpha )
				return true
			elseif self.alpha then
				self.alpha = alpha
				return true
			else
				return false
			end
		end;

		getAlpha = function( self )
			if self.getColor then
				-- math.floor( self:getColor() / 2^24 )
				return bitExtract( self:getColor(), 24, 8 )
			elseif self.alpha then
				return self.alpha
			else
				return 255
			end
		end;

		setPostGUI = function( self, state )
			if state == true or state == false then
				self.postGUI = state
				return true
			end
			return false
		end;

		getPostGUI = function( self )
			return self.postGUI == true
		end;

		addAnim = function( self, anim, ... )
			self.preAnims = self.preAnims or {}
			local loadedAnim = anim( self, ... )
			if loadedAnim then
				table.insert( self.preAnims, loadedAnim )
				return loadedAnim
			else
				self:errorHandler( 'Can not load anim "' .. tostring( anim.name ) .. '"' )
				return false
			end
		end;

		removeAnim = function( self, id, reason )
			local anim = self.preAnims[id]
			if anim then
				if anim.onStop then
					anim:onStop( self, reason )
				end
				self.preAnims[id] = nil
			end
		end;

		removeAllAnims = function( self )
			if self.preAnims then
				for i = 1, #self.preAnims do
					self:removeAnim( i, 'removed' )
				end
				return true
			end
			return false
		end;

		updateAnims = function( self )
			if not self.preAnims then return false; end
			for i, anim in pairs( self.preAnims ) do
				if not anim:update( self ) then
					self:removeAnim( i, 'finished' )
				end
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
				table.unite( self.objects, self.stats[status], true )
				return true
			end
			return false
		end;

		getStatus = function( self, status )
			return self.status or 'default'
		end;

		createTexture = function( self, callback )
			local render = DxRenderTarget( self.w, self.h, true )
			if not render then
				callback( false )
				return false
			end

			local draw = self.draw

			local skipFrame = false
			self.draw = function( self )
				if skipFrame then
					local pixels = dxGetTexturePixels( render )
					dxDrawImage( self.x, self.y, self.w, self.h, render )
					destroyElement( render )

					self.draw = draw

					callback( dxCreateTexture( pixels ) )
				else
					local x, y = self:getPosition()
					local show = self.show

					self.show = true
					
					render:setAsTarget( true, x, y )
					dxSetBlendMode( 'modulate_add' )
					
					draw( self )

					dxSetBlendMode( 'blend' )
					dxSetRenderTarget( )

					if show then
						dxSetBlendMode( 'add' )
						dxDrawImage( self.x, self.y, self.w, self.h, render )
						dxSetBlendMode( 'blend' )
					end

					self.show = show
					skipFrame = true
				end
			end
			
			return true
		end;

		toImage = function( self )
			return self:createTexture(
				function( texture )
					self.image = texture
					self.type = 'image'
					self.draw = dxGUI.image.draw
					setmetatable( self, dxGUI.image )
				end
			)
		end;

		errorHandler = function( self, message )
			iprint( 'dxGUI:', message )
		end;

	};

}
