dxConstruction = dxGUI.baseClass:subclass{ 
	type = 'construction';
	reguestScreen = true;

	create = function( self, isGlobal )
		if self.plane then
			outputDebugString( 'dxConstruction:create: construction is init', 2 )
			return false
		end
		self.plane = {}

		if isGlobal ~= false and self.isGlobal ~= false then
			dxConstruction.screen:addObject( self )
			self.screen = dxConstruction.screen
		end

		if self.newRenderTarget then
			self.renderTarget = dxCreateRenderTarget( self.newRenderTarget.w, self.newRenderTarget.h, self.newRenderTarget.withAlpha or false )
		end
		if not self.objects then
			outputDebugString( 'Construction must have objects', 2 )
			return false
		end
		local objects = {}
		for guiID, data in pairs( self.objects ) do
			if data.p then
				objects[ data.p ] = guiID
			end
		end
		for guiID, data in pairs( self.objects ) do
			if data.p then
				-- do notig
			else
				table.insert( objects, guiID )
			end
		end

		for plane = 1, #objects do
			local guiID = objects[plane]
			local object = self:initObject( self.objects[guiID], guiID )
			if object then
				self:addObject( object )
			end
		end
		
		if self.anims then
			for i = #self.anims, 1, -1 do
				local animData = self.anims[i]
				local anim = Anim.find( animData[1] )
				--outputDebugString( animData[1] )
				self.anims[i] = nil
				if anim then
					self:addAnim( anim, unpack( animData, 2 ) )
				end
			end
		end

		return self
	end;

	inheritStyle = function( self, dataType )
		-- Наследование стилей
		if self.style and self.style[dataType] and not dxGUI[dataType] then
			local parent = self.style[dataType].parent
			local lastDataType = dataType
			while true do
				self.style[lastDataType].type = lastDataType
				local parentClass = dxGUI[parent] or dxGUI[ self.style[parent].parent ]
				if parentClass then
					parentClass:subclass{ type = lastDataType }
					table.uniteWithoutReplace( self.style[lastDataType], self.style[parent] )
					if not parentClass and self.style[parent].parent then
						lastDataType = parent
						parent = self.style[parent].parent
					else
						break;
					end
				else
					self:errorHandler( '"' .. dataType .. '" request "' .. parent .. '" but it not found.'  )
					break;
				end
			end
		end
	end;

	initObject = function( self, data, guiID )
		local dataType = data.type
		self:inheritStyle( dataType )

		if dxGUI[dataType] then
			if self.style and self.style[dataType] then
				-- применение стиля
				table.uniteWithoutReplace( data, self.style[dataType] )
			end

			if not data.x or not data.y then
				error( 'Object with out coordinates ' .. tostring( guiID ) )
			end
			-- Растянуть по размеру
			if not data.w then
				data.w = self.w - data.x
			end
			if not data.h then
				data.h = self.h - data.y
			end
			if dxGUI[dataType].reguestScreen then
				data.style = self.style
			end

			local newObject = dxGUI[dataType]( data )
			if not newObject then
				outputDebugString( 'Can not init object "' .. tostring( guiID ) .. '"[' .. tostring( dataType ) .. ']', 2 )
				return false
			end
			newObject:setShow( newObject.show == nil or newObject.show )

			if newObject.anims then
				for i = #newObject.anims, 1, -1 do
					local animData = newObject.anims[i]
					local anim = Anim.find( animData[1] )
					if anim then
						newObject.anims[i] = nil
						newObject:addAnim( anim, unpack( animData, 2 ) )
					else
						--outputDebugString( 'Anim error in ' .. tostring( guiID ) .. ' with ' .. tostring( animData[1] ) )
					end
				end
			end
			return newObject
		else
			outputDebugString( 'dxGUI.baseClass: unsupportned object type ' .. tostring( data.type ) .. ' guiID ' .. tostring( guiID ) ..', skipping', 2 )
			return false
		end
	end;

	addObject = function( self, data, id )
		if type( data ) ~= 'table' then
			error( 'Bad argumet #1, got ' .. type( data ), 2 )
		end
		if data.reguestScreen then
			data.screen = self
		end
		if id then
			self.objects[id] = data
		end
		--data.x, data.y = data.x + self.x, data.y + self.y
		self:setObjectPosition( data, data.x, data.y )
		table.insert( self.plane, data.p or ( #self.plane + 1 ), data )
		--data.p = nil
	end;

	removeObject = function( self, id )
		local object = self.objects[id]
		if not object then return false; end
		for i = 1, #self.plane do
			if self.plane[i] == object then
				table.remove( self.plane, i )
				self.objects[id] = nil
				--setmetatable( object, nil ) -- HZ -- UPD 25 Juni 2016: реально, зачем это было
				local x, y = object:getPosition( )
				object:setPosition( x - self.x, y - self.y )
				return true
			end
		end
		return false
	end;

	getObjectInPosition = function( self, x, y )
		if not x or not y then
			error( 'Coordinate required', 2 )
		end
		for i = #self.plane, 1, -1 do
			local object = self.plane[i]
			if object:isShow() and object.x < x and object.w + object.x > x and object.y < y and object.h + object.y > y then
				return object, i
			end
		end
		return false
	end;

	setObjectPosition = function( self, object, x, y )
		return object:setPosition( self.x + x, self.y + y )
	end;

	getObjectPosition = function( self, object )
		local x, y = object:getPosition()
		return x - self.x, y - self.y
	end;

	setObjectAlign = function( self, object, alignX, alignY )
		local x, y = self:getObjectPosition( object )
		if alignX == 'left' then
			x = 0
		elseif alignX == 'center' then
			x = ( self.w - object.w ) / 2
		elseif alignX == 'right' then
			x = self.w - object.w
		end
		if alignY == 'top' then
			y = 0
		elseif alignY == 'center' then
			y = ( self.h - object.h ) / 2
		elseif alignY == 'bottom' then
			y = self.h - object.h
		end
		return self:setObjectPosition( object, x, y )
	end;

	setPosition = function( self, x, y )
		x, y = math.floor( x ), math.floor( y )
		for key, object in self:objectPairs() do
			object:setPosition( x + object.x - self.x, y + object.y - self.y )
		end
		self.x, self.y = x, y
	end;

	setAlign = function( self, alignX, alignY )
		local x, y = self.x, self.y
		if alignX == 'left' then
			x = 0
		elseif alignX == 'center' then
			x = ( self.screen.w - self.w ) / 2
		elseif alignX == 'right' then
			x = self.screen.w - self.w
		end
		if alignY == 'top' then
			y = 0
		elseif alignY == 'center' then
			y = ( self.screen.h - self.h ) / 2
		elseif alignY == 'bottom' then
			y = self.screen.h - self.h
		end
		return self:setPosition( x, y )
	end;

	draw = function( self )
		if self.renderTarget then
			self.renderTarget:setAsTarget()
		end
		if self.show == true then
			for _, object in ipairs( self.plane ) do
				if object.show == true then
					object:updateAnims()
					object:draw()
				end
			end
		end
		if self.renderTarget then
			dxSetRenderTarget()
		end
	end;

	onClick = function( self, button, state, cX, cY )
		local gui, pos = self:getObjectInPosition( cX, cY )
		if not gui then return; end
		if gui.input then
			gui.input:activate()
		elseif currentInput ~= nullInput then
			currentInput:deactivate()
		end

		if gui.type == 'construction' then
			table.remove( self.objects, pos )
			table.insert( self.objects, 1 )
		end

		if gui._onClick then
			gui:_onClick( button, state, cX, cY )
		elseif gui.onClick then
			gui:onClick( button, state, cX, cY )
		end

	end;

	onWheel = function( self, upOrDown )
		local cX, cY = getCursorPosition()
		local sX, sY = guiGetScreenSize()

		local gui, pos = self:getObjectInPosition( cX * sX, cY * sY )
		if not gui then return; end

		if gui.onWheel then
			gui:onWheel( upOrDown )
		end
	end;

	onCursorMove = function( self, inBox, cX, cY, lastX, lastY, lastTree, tree, level )
		if inBox then
			local gui = self:getObjectInPosition( cX, cY )
			if lastTree[level] ~= gui then
				for k = #lastTree, level, -1 do
					if lastTree[k].onCursorMove then
						lastTree[k]:onCursorMove( false, cX, cY, lastX, lastY )
					end
				end
			end
			if not gui then return; end
			tree[level] = gui
			if gui.onCursorMove then
				return gui:onCursorMove( true, cX, cY, lastX, lastY, lastTree, tree, level + 1 )
			end
		elseif lastTree then
			for k = #lastTree, level, -1 do
				if lastTree[k].onCursorMove then
					lastTree[k]:onCursorMove( false, cX, cY, lastX, lastY )
				end
			end			
		end
	end;

	showAll = function( self, state )
		for _, object in pairs( self.plane ) do
			object:setShow( state )
		end
		self.show = state
	end;

	getAlpha = function( self )
		return self.alpha
	end;

	setAlpha = function( self, alpha )
		alpha = math.max( 0, math.min( 255, alpha ) )
		for _, object in pairs( self.plane ) do
			if not object.originalAlpha then
				object.originalAlpha = object:getAlpha() or 255
			end
			object:setAlpha( alpha * object.originalAlpha / 255 )
		end
		self.alpha = alpha
	end;

	setPostGUI = function( self, state )
		if state == true or state == false then
			for _, object in self:objectPairs() do
				if object.setPostGUI then
					object:setPostGUI( state )
				end
			end
		end
		return false
	end;

	setScale = function( self, scale, scaleY )
		if self.saveProportions then
			scaleY = scale
		else
			scaleY = scaleY or scale
		end
		local screen = self.screen
		if screen then
			--local x, y = screen:getObjectPosition( self )
			--screen:setObjectPosition( self, x + ( self.w - self.w * scale ) / 2, y + ( self.h - self.h * scaleY ) / 2 )
		end
		self.w, self.h = self.w * scale, self.h * scaleY
		for _, object in self:objectPairs() do
			local x, y = self:getObjectPosition( object )
			self:setObjectPosition( object, x * scale, y * scaleY )
			if object.setScale then
				object:setScale( scale, scaleY )
			else
				--local x, y = object:getPosition()
				--object:setPosition( x * scale, y * scaleY )	
				object.w, object.h = object.w * scale, object.h * scaleY
			end

		end
	end;

	objectPairs = function( self )
		return next, self.plane
	end;
}


---------------------------------------
do
	local sX, sY = guiGetScreenSize()
	dxConstruction.screen = setmetatable(
		{
			x = 0;
			y = 0;
			w = sX;
			h = sY;
			objects = {};
			plane	= {};
			show = true;
			screen = false;
		},
		{
			__index = dxConstruction;
		}
	)

	addEventHandler( 'onClientRender', root, function()
		dxSetAspectRatioAdjustmentEnabled( false )
		dxConstruction.screen:draw()
	end )

	addEventHandler( 'onClientClick', root, function( button, state, cX, cY )
		dxConstruction.screen:onClick( button, state, cX, cY )
	end )


	local lastX, lastY
	local lastTree = {}
	
	addEventHandler( 'onClientCursorMove', root, function( _, _, cX, cY )
		if not isCursorShowing() then return end
		local tree = { }
		dxConstruction.screen:onCursorMove( true, cX, cY, lastX, lastY, lastTree, tree, 1 )

		lastTree = tree
		lastX, lastY = cX, cY
	end )

	addEventHandler( 'onClientKey', root, function( key )
		if isCursorShowing() then
			if key == 'mouse_wheel_up' then
				dxConstruction.screen:onWheel( 1 )
			elseif key == 'mouse_wheel_down' then
				dxConstruction.screen:onWheel( -1 )
			end
		end
	end )

end
