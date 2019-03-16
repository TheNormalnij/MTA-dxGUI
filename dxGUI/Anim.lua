local anims = {}

Anim = class{
	
	create = function( self, newAnim )
		newAnim = class( newAnim )
		if newAnim.name then
			anims[ newAnim.name ] = newAnim
		end
		return newAnim
	end;

	find = function( name )
		return anims[name] or false
	end;

}

local getTickCount = getTickCount
local prevTick = getTickCount()
local thisTick = prevTick
function getAnimTicks()
	return prevTick, thisTick
end

addEventHandler( 'onClientRender', root, function()
	prevTick = thisTick
	thisTick = getTickCount()
end, true, 'high' )

----------------

Anim{
	name = 'change-color';
	time = 1000;
	easing = 'Linear';

	create = function( self, gui, time, toColor, easing, fromColor )
		for id, anim in pairs( preAnims .anims ) do
			if anim.name == self.name then
				gui:removeAnim( id )
			end
		end
		fromColor = fromColor or gui:getColor()
		self.from = { color.RGBtoHSL( color.HEXtoRGB( fromColor ) ) }
		self.to = { color.RGBtoHSL( color.HEXtoRGB( toColor ) ) }
		self.time = time or self.time
		self.easting = easting or self.easting
		self.startTime = getAnimTicks()
		return self
	end;

	update = function( self, gui )
		local currtime = getAnimTicks()
		local k = getEasingValue( ( currtime - self.startTime ) / self.time, self.easting )
		gui:setColor( 
			color.HSLtoRGB(
				self.from[1] + ( self.to[1] - self.from[1] ) * k,
				self.from[2] + ( self.to[2] - self.from[2] ) * k,
				self.from[3] + ( self.to[3] - self.from[3] ) * k,
				self.from[4] + ( self.to[4] - self.from[4] ) * k
			)
		)
		if currtime < ( self.startTime + self.time ) then
			return true
		else
			return false
		end
	end;

	onStop = function( self, gui )
		gui:setColor(
			color.HSLtoRGB( 
				self.to[1],
				self.to[2],
				self.to[3],
				self.to[4]
			)
		)
	end;
}

-------------------

Anim{
	name = 'move';
	eastingX = 'Linear';
	eastingY = 'Linear';

	create = function( self, gui, time, x, y, eastingX, eastingY, fromX, fromY )
		for id, anim in pairs( gui.preAnims ) do
			if anim.name == self.name then
				gui:removeAnim( id )
			end
		end
		local guiX, guiY = gui:getPosition()
		self.from = { fromX or guiX, fromY or guiY }
		self.to = { x or guiX, y or guiY }
		self.time = time
		self.eastingX = eastingX or self.eastingX
		self.eastingY = eastingY or self.eastingY
		self.startTime = getTickCount()
		return self
	end;

	update = function( self, gui )
		local currtime = getTickCount()
		local kX = getEasingValue( ( currtime - self.startTime ) / self.time, self.eastingX )
		local kY = getEasingValue( ( currtime - self.startTime ) / self.time, self.eastingY )
		gui:setPosition( self.from[1] + ( self.to[1] - self.from[1] ) * kX, self.from[2] + ( self.to[2] - self.from[2] ) * kY )
		if currtime < ( self.startTime + self.time ) then
			return true
		else
			gui:setPosition( self.to[1], self.to[2] )
			return false
		end
	end;

	onStop = function( self, gui )
		gui:setPosition( self.to[1], self.to[2] )
	end;
}

------------------

Anim{
	name = 'gui-out-cursor-moving';

	create = function( self, gui )
		self.onGuiClick = gui.onClick
		gui.onClick = function( gui, button, state, cX, cY )
			self.state = true
			self.onGuiClick( gui, button, state, cX, cY )
		end
		return self
	end;

	update = function( self, gui )
		if self.state then
			if getKeyState( 'mouse1' ) then
				local cX, cY = getCursorPosition( )
				if cX then
					local sX, sY = guiGetScreenSize()
					gui:onCursorMove( false, cX * sX, cY * sY )
				else
					self.state = false
				end
			else
				self.state = false
			end
		end
		return true
	end;
}

-- All

Anim{
	name = 'softShow';

	create = function( self, gui, timeIn, timeOut )
		self.timeIn = timeIn
		self.timeOut = timeOut or timeIn
		self.originalSetShow = gui.setShow
		self.originalIsShow = gui.isShow
		self.state = 'default'
		self.show = gui.show
		
		gui.setShow = function( gui, state )
			local startTick = getTickCount()
			if self.show ~= state then
				if state then
					if self.state == 'out' then
						startTick = startTick - self.timeIn * ( 1 - gui:getAlpha() / 255 )
					else
						gui:setAlpha( 0 )
					end
					self.originalSetShow( gui, true )
					self.state = 'in'
				else
					if self.state == 'in' then
						startTick = startTick - self.timeOut * ( 1 - gui:getAlpha() / 255 )
					end
					self.state = 'out'
				end
				self.show = state
			end
			self.startTick = startTick
		end;

		gui.isShow = function( gui )
			return self.show
		end

		return self
	end;

	update = function( self, gui )
		local thisTick = getTickCount()
		if self.state == 'out' then
			local progress = ( thisTick - self.startTick ) / self.timeOut
			if progress > 1 then
				self.originalSetShow( gui, false )
				gui:setAlpha( 255 )
				self.state = 'default'
				self.startTick = thisTick
			else
				gui:setAlpha( 255 * ( 1 - progress ) )
			end
		elseif self.state == 'in' then
			local progress = ( thisTick - self.startTick ) / self.timeIn
			if progress > 1 then
				gui:setAlpha( 255 )
				self.state = 'default'
			else
				gui:setAlpha( 255 * progress )
			end
		end
		return true
	end;

	onStop = function ( self, gui )
		gui.setShow = self.originalSetShow
		gui.isShow = self.originalIsShow
	end;
}

-- Text

Anim{
	name = 'hoppingText';

	create = function( self, gui, time, scaleCount )
		self.time = time
		self.scaleCount = scaleCount
		self.startScale = gui.scale
		return self
	end;

	update = function( self, gui )
		gui.scale = self.startScale + math.sin( ( getTickCount() % self.time / self.time ) * math.pi ) * self.scaleCount
		return true
	end;

	onStop = function ( self, gui )
	end;
}

Anim{
	name = 'by_letter_adding';

	create = function( self, gui )

		gui.setText = function( gui, text )
			text = tostring( text )
			self.toText = text
			self.currentLetter = 0
			self.letterCount = utf8.len( text )
			gui.text = ''
			return true
		end;

		return self
	end;

	update = function( self, gui )
		if self.letterCount > self.currentLetter then
			self.currentLetter = self.currentLetter + 1
			gui.text = utf8.sub( self.toText, 1, self.currentLetter )
		end
		
		return true
	end;

	onStop = function ( self, gui )
	end;
}

-- editField
Anim{
	name = 'maskedText';

	create = function( self, gui, time )
		self.text = gui.objects.text:getText()

		self.setTextOriginal = gui.setText
		self.getTextOriginal = gui.getText

		gui.setText = function( gui, text )
			self.text = text
			gui.objects.text:setText( string.rep( "*", utfLen(text) ) )
		end;

		gui.getText = function( gui )
			return self.text
		end;

		return self
	end;

	update = function( self, gui )
		return true
	end;

	onStop = function ( self, gui )
		gui.setText = self.setTextOriginal
		gui.getText = self.getTextOriginal
	end;
}

Anim{
	name = 'Carete';

	create = function( self, gui, time, r, g, b )
		self.time = time
		self.vColor = { r, g, b }

		local caret = gui:initObject{ type = 'rectangle', x = 0, y = 0, w = 2 }
		gui:addObject( caret, 'caret' )
		return self
	end;

	update = function( self, gui )
		local textObject = gui.objects.text

		gui.objects.caret.show = gui.input == Input.get()

		local offsetX
		local caret = gui.caret
		if textObject.alignX == 'left' then
			offsetX = dxGetTextWidth( utfSub( gui.objects.text.text, 1, caret ), textObject.scale, textObject.font )
		elseif textObject.alignX == 'right' then
			local textSize = utfLen( gui.objects.text.text )
			offsetX = math.max( 0,
				textObject.w - dxGetTextWidth( utfSub( gui.objects.text.text, caret + 1, textSize ), textObject.scale, textObject.font )
			)
		else
			local textSize = dxGetTextWidth( gui.objects.text.text, textObject.scale, textObject.font )
			offsetX = dxGetTextWidth( utfSub( gui.objects.text.text, 1, caret ), textObject.scale, textObject.font ) + (textObject.w - textSize) / 2
		end

		local tH = dxGetFontHeight( textObject.scale, textObject.font )

		local alpha = math.sin( ( getTickCount() % self.time / self.time ) * math.pi ) * 255

		gui.objects.caret.x = textObject.x + offsetX
		gui.objects.caret.color = tocolor( self.vColor[1], self.vColor[2], self.vColor[3], alpha )
		gui.objects.caret.y = gui.objects.text.y + ( gui.objects.text.h - tH ) / 2
		gui.objects.caret.h = tH

		return true
	end;
}

-- List
Anim{
	name = 'softItemMoved';

	create = function( self, gui, time, easing )
		self.time = time
		self.moveOriginal = gui.move
		self.originalUpdateAnims = gui.updateAnims
		self.state = 'default'

		gui.move = function( gui, countX, countY )

			local itemCount = #gui.items
			local maxOffsetX = gui.maxVerticalItems and ( math.ceil( itemCount / gui.maxVerticalItems ) * gui.construction.w - gui.w ) or 0
			local maxOffsetY = gui.maxHorizontalItems and ( math.ceil( itemCount / gui.maxHorizontalItems ) * gui.construction.h - gui.h ) or 0
			
			if self.state == 'default' then

				self.from = { gui.offsetX, gui.offsetY }

				local toX
				if countX and countX ~= 0 and maxOffsetX > 0 then
					if gui.offsetX + countX > maxOffsetX then
						toX = maxOffsetX
					elseif gui.offsetX + countX < 0 then
						toX = 0
					else
						toX = gui.offsetX + countX
					end
				else
					toX = gui.offsetX
				end

				local toY
				if countY and countY ~= 0 and maxOffsetY > 0 then
					if gui.offsetY + countY > maxOffsetY then
						toY = maxOffsetY
					elseif gui.offsetY + countY < 0 then
						toY = 0
					else
						toY = gui.offsetY + countY
					end
				else
					toY = gui.offsetY
				end

				if toX ~= gui.offsetX or toY ~= gui.offsetY then
					self.to = { toX, toY }
					self.state = 'move'
					self.startTick = getTickCount( )
				end
			else
				local toX
				if countX and countX ~= 0 and maxOffsetX > 0 then
					if self.to[1] + countX > maxOffsetX then
						toX = maxOffsetX
					elseif self.to[1] + countX < 0 then
						toX = 0
					else
						toX = self.to[1] + countX
					end
				else
					toX = self.to[1]
				end

				local toY
				if countY and countY ~= 0 and maxOffsetY > 0 then
					if self.to[2] + countY > maxOffsetY then
						toY = maxOffsetY
					elseif self.to[2] + countY < 0 then
						toY = 0
					else
						toY = self.to[2] + countY
					end
				else
					toY = self.to[2]
				end

				if toX ~= self.to[1] or toY ~= self.to[2] then
					self.to = { toX, toY }
					self.state = 'move'
					--self.startTick = getTickCount( )
				end
			end
		end;

		return self
	end;

	update = function( self, gui )
		local thisTick = getTickCount()
		if self.state == 'move' then
			local progress = ( thisTick - self.startTick ) / self.time
			if progress > 1 then
				gui.offsetX, gui.offsetY = self.to[1], self.to[2]
				self.to = nil
				self.from = nil
				self.state = 'default'
				return true
			end
			gui.offsetX, gui.offsetY = self.from[1] + ( self.to[1] - self.from[1] ) * progress,
				self.from[2] + ( self.to[2] - self.from[2] ) * progress
		end
		return true
	end;

	onStop = function ( self, gui )
		gui.move = self.moveOriginal
	end;
}

-- TextLines
Anim{
	name = 'softTextLinesMoved';

	create = function( self, gui, time, easing )
		self.time = time
		self.moveOriginal = gui.move
		self.originalUpdateAnims = gui.updateAnims
		self.state = 'default'

		gui.move = function( gui, countY )
			local maxOffsetY = (#gui.lines - 1) * gui.fontSize * gui.lineSpacing - gui.h
			
			if self.state == 'default' then

				self.from = gui.offsetY

				local toY
				if countY and countY ~= 0 and maxOffsetY > 0 then
					if gui.offsetY + countY > maxOffsetY then
						toY = maxOffsetY
					elseif gui.offsetY + countY < 0 then
						toY = 0
					else
						toY = gui.offsetY + countY
					end
				else
					toY = gui.offsetY
				end

				if toY ~= gui.offsetY then
					self.to = toY
					self.state = 'move'
					self.startTick = getTickCount( )
				end
			else

				local toY
				if countY and countY ~= 0 and maxOffsetY > 0 then
					if self.to + countY > maxOffsetY then
						toY = maxOffsetY
					elseif self.to + countY < 0 then
						toY = 0
					else
						toY = self.to + countY
					end
				else
					toY = self.to
				end

				if toY ~= self.to then
					self.to = toY
					self.state = 'move'
					--self.startTick = getTickCount( )
				end
			end
		end;

		return self
	end;

	update = function( self, gui )
		local thisTick = getTickCount()
		if self.state == 'move' then
			local progress = ( thisTick - self.startTick ) / self.time
			if progress > 1 then
				gui.offsetY = self.to
				self.to = nil
				self.from = nil
				self.state = 'default'
				return true
			end
			gui.offsetY = self.from + ( self.to - self.from ) * progress
		end
		return true
	end;

	onStop = function ( self, gui )
		gui.move = self.moveOriginal
	end;
}

-- Tab

Anim{
	name = 'softTabChange';

	create = function( self, gui, time )
		self.time = time
		self.setActiveTabOriginal = gui.setActiveTab
		self.state = 'default'
		
		gui.setActiveTab = function( gui, newTab )
			self.startTick = getTickCount()
			self.state = 'out'
			self.toTab = newTab
		end;

		return self
	end;

	update = function( self, gui )
		local thisTick = getTickCount()
		if self.state == 'out' then
			local progress = ( thisTick - self.startTick ) / self.time
			if progress > 1 then
				self.setActiveTabOriginal( gui, self.toTab )
				gui:setAlpha( 0 )
				self.state = 'in'
				self.startTick = thisTick
			else
				gui:setAlpha( 255 * ( 1 - progress ) )
			end
		elseif self.state == 'in' then
			local progress = ( thisTick - self.startTick ) / self.time
			if progress > 1 then
				gui:setAlpha( 255 )
				self.state = 'default'
			else
				gui:setAlpha( 255 * progress )
			end
		end
		return true
	end;

	onStop = function ( self, gui )
		gui.setActiveTab = self.setActiveTabOriginal
	end;
};

Anim{
	name = 'extremeHiding';
	time = 500;

	create = function( self, gui, time )
		self.time = time
		self.originalSetShow = gui.setShow
		self.originalDraw = gui.draw
		self.state = 'default'
		self.show = gui.show
		
		gui.setShow = function( gui, state )
			self.startTick = getTickCount()
			if self.show ~= state then
				if state then
					self.originalSetShow( gui, true )
					self.state = 'in'
					self.progress = 0
				else
					self.state = 'out'
					self.progress = 1
				end
				self.show = state
				gui.renderTarget = DxRenderTarget( gui.w, gui.h, true )
				gui.draw = function( gui )
					if gui.show then
						local x, y = gui:getPosition()
						gui:setPosition( 0, 0 )
						self.originalDraw( gui )
						dxSetRenderTarget( )
						gui:setPosition( x, y )
						local w, h =  gui.w * self.progress, gui.h * self.progress
						local offX = (gui.w - w) / 2
						local offY = (gui.h - h) / 2
						dxDrawImageSection( x + offX, y + offY, w, h, offX, offY, w, h, gui.renderTarget, 0, 0, 0, tocolor( 255, 255, 255 ), gui.postGUI )
					end
				end
			end
		end;

		gui.isShow = function( gui )
			return self.show
		end

		return self
	end;

	update = function( self, gui )
		local thisTick = getTickCount()
		if self.state ~= 'default' then
			local timeProgress = ( thisTick - self.startTick ) / self.time
			self.progress =  ( self.state == 'in' and timeProgress ) or ( 1 - timeProgress )
			if timeProgress >= 1 then
			--	gui.draw = self.originalDraw
			--	gui.renderTarget:destroy()
				if self.progress <= 0 then
					self.originalSetShow( gui, false )
				end
				self.progress = 1
			end
		end
		return true
	end;

	onStop = function ( self, gui )
		gui.setShow = self.originalSetShow
	end;
}

-- All
-- Переписать так, чтобы клик обрабатывался только на меню
Anim{
	name = 'mouseMoving';
	key = 'mouse1';

	create = function( self, gui, key, attachGUI )
		self.key = key
		self.attachGUI = attachGUI or gui

		self.isMove = false

		self.sX, self.sY = guiGetScreenSize()

		return self
	end;

	update = function( self, gui )
		local isOnCursor = self.attachGUI:isOnCursor()
		local isClick = getKeyState( self.key )

		if self.isMove then
			if isClick then
				local x, y = getCursorPosition( )
				x, y = x * self.sX, y * self.sY

				local gX, gY = gui:getPosition()
				gui:setPosition( gX + x - self.x, gY + y - self.y )

				self.x, self.y = x, y
			else
				self.isMove = false
			end
		else
			if isOnCursor and isClick then
				self.x, self.y = getCursorPosition( )
				self.x, self.y = self.x * self.sX, self.y * self.sY
				self.isMove = true
			end
		end
		return true
	end;

	onStop = function( self, gui )
		-- body
	end;
}

Anim{
	name = 'attach';

	create = function( self, gui, attachTo, offX, offY )
		self.attachTo = attachTo
		local gX, gY = gui:getPosition()
		local tX, tY = attachTo:getPosition()
		self.offX = offX or ( gX - tX )
		self.offY = offY or ( gY - tY )
		return self
	end;

	update = function( self, gui )
		local x, y = self.attachTo:getPosition()
		gui:setPosition( x + self.offX, y + self.offY )
		return true
	end;

}
