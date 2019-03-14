dxGUI.baseClass:subclass{
	type        = 'list';
	reguestScreen = true;
	postGUI = false;
	offsetX		= 0;
	offsetY		= 0;
	active		= 0;
	scrolling = 'vertical';
	maxHorizontalItems = 1;
	selectionType = 'single';
	keyboardInput = false;
	autofolding = true;

	create = function( self )
		if self.scrolling == 'vertical' then
			self.maxHorizontalItems = self.maxHorizontalItems or 1
		elseif self.scrolling == 'horizontal' then
			self.maxVerticalItems = self.maxVerticalItems or 1
		elseif not ( self.maxHorizontalItems or self.maxVerticalItems ) then
			error( 'No item count', 2 )
			return false
		end
		local items = self.items or {}
		self.items = {}
		for i, item in ipairs( items ) do
			self:addItem( item, i )
		end
		
		self.input = Input{ }

		if self.maxHorizontalItems ~= 1 then
			self.input:bind( 'arrow_l', true, self.moveActive, self, -1, 0 )
			self.input:bind( 'arrow_r', true, self.moveActive, self, 1, 0 )
		end
		self.input:bind( 'arrow_u', true, self.moveActive, self, 0, -1 )
		self.input:bind( 'arrow_d', true, self.moveActive, self, 0, 1 )

		return self
	end;

	addItem = function( self, item, pos )
		if type( item ) ~= 'table' then
			return false
		end
		local newItem = {
			x = 0;
			y = 0;
			w = self.construction.w / ( self.scale and self.scale[1] or 1 );
			h = self.construction.h / ( self.scale and self.scale[2] or 1 );
			objects = table.copy( self.construction.objects, true );
			anims = table.copy( self.construction.anims or {}, true );
			style = self.style;
			show = true;
		}
		table.unite( newItem.objects, item, true )
		dxConstruction( newItem, false )

		newItem.screen = self
		self:setItemSelect( newItem, false )

		if self.postGUI and not self.renderTarget then
			newItem:setPostGUI( true )
		end

		pos = pos or #self.items + 1
		if self.autofolding then
			table.insert( self.items, pos, newItem )
		elseif not self.items[pos] then
			self.items[pos] = newItem
		else
			return false
		end
		self:setItemStatus( pos, 'default' )

		-- сделать скалинг по конструкции
		if self.scale then
			newItem:setScale( self.scale[1], self.scale[2] )
		end
		return newItem, pos
	end;

	removeItem = function( self, pos )
		if self.items[pos] then
			local value
			if self.autofolding then
				value = table.remove( self.items, pos )
			else
				value = self.items[pos]
				self.items[pos] = nil
			end
			if not self.items[ self.active ] then
				self:setActiveItem( self.active - 1 )
			end

			if self.scrolling == 'vertical' then
				if pos / self.maxHorizontalItems * self.construction.h < self.offsetY then
					self:move( 0, -self.construction.h )
				end
			else
				if pos / self.maxVerticalItems * self.construction.w < self.offsetX then
					self:move( -self.construction.w, 0 )
				end
			end
			local itemCount = #self.items
			local maxOffsetX = self.maxVerticalItems and ( math.floor( itemCount / self.maxVerticalItems ) * self.construction.w - self.w ) or 0
			local maxOffsetY = self.maxHorizontalItems and ( math.ceil( itemCount / self.maxHorizontalItems ) * self.construction.h - self.h ) or 0

			if self.offsetX > maxOffsetX and maxOffsetX >= 0 then
				self.offsetX = maxOffsetX
			end
			if self.offsetY > maxOffsetY and maxOffsetY >= 0 then
				self.offsetY = maxOffsetY
			end
			return value
		end
		return false
	end;

	getItemsCount = function( self )
		return #self.items
	end;

	clean = function( self )
		self.items = {}
		self.active = 0
		self.offsetX = 0
		self.offsetY = 0
	end;

	draw = function( self )
		local offX, offY = self.offsetX % self.construction.w, self.offsetY % self.construction.h
		local itemOffsetX = self.offsetX / self.construction.w
		local itemOffsetY = self.offsetY / self.construction.h

		if offX == 0 and offY == 0 and self.w % self.construction.w == 0 and self.h % self.construction.h == 0 then
			if self.renderTarget then
				self.renderTarget:destroy()
				self.renderTarget = nil
				for i = 1, #self.items do
					self.items[i]:setPostGUI( self.postGUI )
				end
			end
			for iItemY = itemOffsetY, itemOffsetY + ( self.maxVerticalItems or math.ceil( self.h / self.construction.h ) ) - 1 do
				for iItemX = itemOffsetX + 1, itemOffsetX + ( self.maxHorizontalItems or self.w / self.construction.w ) do
					local item = self.items[ iItemY * self.maxHorizontalItems + iItemX ]
					if item then
						item:setPosition( self.x + ( iItemX - itemOffsetX - 1 ) * self.construction.w, self.y + ( iItemY - itemOffsetY ) * self.construction.h )
						item:updateAnims()
						item:draw()
					end
				end
			end
		else
			if not self.renderTarget then
				self.renderTarget = DxRenderTarget( self.w, self.h, true )
				for i = 1, #self.items do
					self.items[i]:setPostGUI( false )
				end
			end
			if self.renderTarget then
				local prevRenderTarget = DxRenderTarget.getCurrentTarget()
				self.renderTarget:setAsTarget( true )
				dxSetBlendMode( 'modulate_add' )

				for iItemY = math.floor( itemOffsetY ), math.floor( itemOffsetY ) + ( self.maxVerticalItems or math.ceil( self.h / self.construction.h ) ) + 1 do
					for iItemX = math.floor( itemOffsetX ) + 1, math.ceil( itemOffsetX ) + ( self.maxHorizontalItems or self.w / self.construction.w ) do
						local item = self.items[ iItemY * self.maxHorizontalItems + iItemX ]
						if item then
							item:setPosition( ( iItemX - math.floor( itemOffsetX ) - 1 ) * self.construction.w - offX,  ( iItemY - math.floor( itemOffsetY ) ) * self.construction.h - offY  )
							item:updateAnims()
							item:draw()
						end
					end
				end

				dxSetBlendMode( 'add' )
				DxRenderTarget.setAsTarget( prevRenderTarget )
				dxDrawImage( self.x, self.y, self.w, self.h, self.renderTarget, 0,
					0, 0, 0xFFFFFFFF, self.postGUI )
				dxSetBlendMode( 'blend' )
			else
				dxDrawText( 'NO VIDEO MEMORY FOR CREATE RENDERTARGET', self.x, self.y, self.x + self.w, self.y + self.h, 5 )
			end
		end
	end;

	setAlpha = function( self, alpha )
		for i = 1, #self.items do
			self.items[i]:setAlpha( alpha )
		end
	end;

	cleanSelect = function( self )
		for pos, item in pairs( self.items ) do
			if item.select then
				self:setItemSelect( pos, false )
			end
		end
		return true
	end;

	setSelectionType = function( self, newType )
		if newType == 'single' or newType == 'multi' then
			if self.selectionType ~= newType then
				self:cleanSelect()
				self.selectionType = newType
			else
				return true
			end
		else
			return false
		end
	end;

	setItemSelect = function( self, index, selected )
		if not index or not self.items[index] then
			return false
		end
		if self.selectionType == 'single' and selected == true then
			self:cleanSelect()
		end
		if ( self:getActiveItem() == index and 'active' ) then
			if not self:setItemStatus( index, 'active' ) then
				self:setItemStatus( index, ( selected and 'selected' ) or 'default' )
			end
		else
			self:setItemStatus( index, ( selected and 'selected' ) or 'default' )
		end
		self.items[index].select = selected
		if self.onItemSelect then
			self:onItemSelect( index, self.items[index] )
		end
		return true
	end;

	getItem = function( self, index )
		return index and self.items[index]
	end;

	getSelectedItems = function( self )
		local resul = {}
		for i = 1, #self.items do
			if self.items[i].select then
				table.insert( resul, { i, self.items[i] } )
			end
		end
		return resul
	end;

	setItemStatus = function( self, index, status )
		if self.stats and self.stats[status] and self.items[index] then
			table.unite( self.items[index].objects, self.stats[status], true )
			self.items[index].status = status
			return true
		end
		return false
	end;

	getItemStatus = function( self, index )
		if self.items[index] then
			return self.items[index].status
		end
		return false
	end;

	setActiveItem = function( self, index )
		if not self.items[index] then return false; end
		self:setItemStatus( index, 'active' )
		if self.active ~= index and self.items[self.active] then
			self:setItemStatus( self.active, self.items[self.active].select and 'selected' or 'default' )
		end
		self.active = index

		local reqOffX = self.maxVerticalItems and ( math.floor( ( self.active - 1 ) / self.maxVerticalItems ) * self.construction.w )
		local reqOffY = self.maxHorizontalItems and ( math.floor( ( self.active - 1 ) / self.maxHorizontalItems ) * self.construction.h )
		if reqOffX then
			local minOffX = reqOffX - self.w + self.construction.w 
			if self.offsetX < minOffX then
				self:move( minOffX - self.offsetX, 0 )
			elseif self.offsetX > reqOffX then
				self:move( reqOffX - self.offsetX, 0 )
			end
		end
		if reqOffY then
			local minOffY = reqOffY - self.h + self.construction.h 
			if self.offsetY < minOffY then
				self:move( 0, minOffY - self.offsetY )
			elseif self.offsetY > reqOffY then
				self:move( 0, reqOffY - self.offsetY )
			end
		end
		return true
	end;

	getActiveItem = function( self )
		return self.active
	end;

	getItemIndexFromPosition = function( self, x, y )
		local cItemX = math.ceil( ( x - self.x + self.offsetX ) / self.construction.w )
		local cItemY = math.ceil( ( y - self.y + self.offsetY ) / self.construction.h )
		if cItemX < 1 or cItemY < 1 then
			return false
		end
		return ( cItemY - 1 ) * self.maxHorizontalItems + cItemX

	end;

	getItemInPosition = function( self, x, y )
		local cItem = self:getItemIndexFromPosition( x, y )
		if self.items[cItem] then
			return cItem, self.items[cItem]
		else
			return false
		end
	end;

	onCursorMove = function( self, inBox, cX, cY, lastX, lastY, lastTree, tree, level )
		local cItem = inBox and self:getItemInPosition( cX, cY )

		if self.prevCurorMovedItem and ( self.prevCurorMovedItem ~= cItem or not cItem ) then
			local oldItem = self.items[ self.prevCurorMovedItem ]
			if oldItem then
				if oldItem.onCursorMove then
					oldItem:onCursorMove( false, cX, cY, lastX, lastY, lastTree, tree, level )
				end
				if self.active == self.prevCurorMovedItem then
					self:setItemStatus( self.prevCurorMovedItem, 'active' )
				elseif oldItem.select then
					self:setItemStatus( self.prevCurorMovedItem, 'selected' )
				else
					self:setItemStatus( self.prevCurorMovedItem, 'default' )
				end
			end
		end

		if not cItem then return; end
		self:setItemStatus( cItem, 'oncursor' )

		local item = self.items[cItem]
		if item.onCursorMove then
			item:onCursorMove( inBox, cX, cY, lastX, lastY, lastTree, tree, level )
		end

		if getKeyState( 'mouse1' ) then
			self:setActiveItem( cItem )
		end

		self.prevCurorMovedItem = cItem
	end;

	setScale = function( self, scale, scaleY )
		self.construction.w = self.construction.w * scale
		self.construction.h = self.construction.h * scaleY

		self.w, self.h = self.w * scale, self.h * scaleY
		for i = 1, #self.items do
			self.items[i]:setScale( scale, scaleY )
		end
		self.scale = { scale, scaleY }
	end;

	setPostGUI = function( self, state )
		if state == true or state == false then
			self.postGUI = state
			if self.renderTarget then
				for i = 1, #self.items do
					self.items[i]:setPostGUI( false )
				end
			else
				for i = 1, #self.items do
					self.items[i]:setPostGUI( state )
				end
			end
		end
		return false
	end;

	onClick = function( self, button, state, cX, cY )
		local cItem = self:getItemInPosition( cX, cY )
		if not cItem then return; end
		local item = self.items[cItem]

		if self.renderTarget then
			item:onClick( button, state, cX - self.x, cY - self.y )
		else
			item:onClick( button, state, cX, cY )
		end

		if button == 'left' then
			if state == 'up' then
				self:setActiveItem( cItem )
				self:setItemSelect( cItem, not item.selected )
			else
				self:setActiveItem( cItem )
				self:setItemSelect( cItem, not item.selected )
			end
		end
		if self.onItemClick then
			self:onItemClick( cItem, item, button, state, cX, cY )
		end
		return true
	end;

	onWheel = function( self, upOrDown )
		if self.scrolling == 'vertical' then
			self:move( 0, -upOrDown * self.construction.h )
		else
			self:move( -upOrDown * self.construction.w, 0 )
		end
	end;

	move = function( self, countX, countY )

		local itemCount = #self.items
		local maxOffsetX = self.maxVerticalItems and ( math.ceil( itemCount / self.maxVerticalItems ) * self.construction.w - self.w ) or 0
		local maxOffsetY = self.maxHorizontalItems and ( math.ceil( itemCount / self.maxHorizontalItems ) * self.construction.h - self.h ) or 0

		if countX and countX ~= 0 and maxOffsetX > 0 then
			if self.offsetX + countX > maxOffsetX then
				self.offsetX = maxOffsetX
			elseif self.offsetX + countX < 0 then
				self.offsetX = 0
			else
				self.offsetX = self.offsetX + countX
			end
		end

		if countY and countY ~= 0 and maxOffsetY > 0 then
			if self.offsetY + countY > maxOffsetY then
				self.offsetY = maxOffsetY
			elseif self.offsetY + countY < 0 then
				self.offsetY = 0
			else
				self.offsetY = self.offsetY + countY
			end
		end
	
		return true
	end;

	moveActive = function( self, countX, countY )
		local count
		if self.maxHorizontalItems then
			count = self.maxHorizontalItems * countY + countX
		else
			count = self.maxVerticalItems * countX + countY
		end
		local newActive = self.active + count
		-- if newActive > 1 and not self.items[newActive] then
		-- 	local maxCount = #self.items
		-- 	newActive = #self.items
		-- end
		return self:setActiveItem( newActive )
	end;

	-- переписать
	sortByText = function( self, reverse )
		local t = {}
		for id, item in pairs( self.items ) do
			t[id] = { utf8.lower( item.objects.text.text ), id }
		end
		table.sort( t, function( a, b )
			local lA, lB = utf8.len( a[1] ), utf8.len( b[1] )
			for  i = 1, lA < lB and lA or lB do
				local bA = utf8.byte( a[1], i, i + 1 )
				local bB = utf8.byte( b[1], i, i + 1 )
				if bA and bB then
					if bA < bB then
						return true
					elseif bA > bB then
						return false
					end
				else
					return true
				end
			end
			return true
		end )
		local oldItems = self.items
		self.items = {}
		for i = ( reverse and #t or 1 ), ( reverse and 1 or #t ), ( reverse and -1 or 1 ) do
			self.items[i] = oldItems[ t[i][2] ]
		end
		return true
	end;

	find = function( self, itemDataName, value )
		return table.findIn( self.items, itemDataName, value )
	end;

	setKeyboardInputEnabled = function( self, state )
		if state then
			local buffer = ''
			local timer
			self.input.onCharacter = function( input, character )
				if timer and isTimer( timer ) then
					timer:destroy()
				end
				buffer = buffer .. character
				timer = Timer( function()
					buffer = ''
				end, 1000, 1 )
				for i = 1, #self.items do
					if utf8.lower( self.items[i].objects.text.text ):find( buffer ) then
						self:setActiveItem( i )
						return
					end
				end
			end
		else
			self.input.onCharacter = nil
		end
		self.keyboardInput = state
		return true
	end;

	objectPairs = function( self )
		return next, self.items
	end;
}
