dxGUI.tabs = dxConstruction:subclass{
	type = 'tabs';
	active = 1;

	create = function( self )

		if self.body then
			self.objects = table.copy( self.body, false )
		else
			self.objects = {}
		end

		if not self.items then
			self.items = {}
		end

		dxConstruction.create( self, false )

		for id, thistabItems in pairs( self.items ) do
			if self.active == id then
				for guiID, data in pairs( thistabItems ) do
					self:initObject( data, guiID )
					self:addObject( data, guiID )
				end
			else
				for guiID, data in pairs( thistabItems ) do
					self:initObject( data, guiID )
				end
			end
		end

		return self
	end;

	addItem = function( self, item, id )
		id = id or #self.items + 1

		for guiID, data in pairs( item ) do
			self:initObject( data, guiID )
		end

		self.items[id] = item
		return id
	end;

	setPosition = function( self, x, y )
		x, y = math.floor( x ), math.floor( y )
		for key, object in pairs( self.objects ) do
			object:setPosition( x + object.x - self.x, y + object.y - self.y )
		end
		self.x, self.y = x, y
	end;

	setActiveTab = function( self, id )
		if self.items[ self.active ] then
			for guiID, data in pairs( self.items[ self.active ] ) do
				self:removeObject( guiID )
			end
		end
		if id and self.items[id] then
			for guiID, data in pairs( self.items[id] ) do
				self:addObject( data, guiID )
			end
			self.active = id
			return true
		else
			self.active = nil
		end
		return false
	end;

	getActiveTab = function( self, id )
		return self.active
	end;

	objectPairs = function( self )
		local t = {}
		if self.body then
			for guiID, data in pairs( self.body ) do
				table.insert( t, data )
			end			
		end
		for i = 1, #self.items do
			for guiID, data in pairs( self.items[i] ) do
				table.insert( t, data )
			end
		end
		return next, t
	end;
}
