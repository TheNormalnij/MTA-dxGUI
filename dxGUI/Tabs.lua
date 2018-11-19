dxGUI.tabs = dxConstruction:subclass{
	type = 'tabs';
	active = 1;

	create = function( self )
		self.objects = {}
		if self.head then
			-- TODO
		end
		dxConstruction.create( self, false )

		for i = 1, #self.items do
			local thistabItems = self.items[i]
			if self.active == i then
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

	setPosition = function( self, x, y )
		x, y = math.floor( x ), math.floor( y )
		for key, object in next, self.objects do
			object:setPosition( x + object.x - self.x, y + object.y - self.y )
		end
		self.x, self.y = x, y
	end;

	setActiveTab = function( self, id )
		if self.items[id] then
			for guiID, data in pairs( self.items[ self.active ] ) do
				self:removeObject( guiID )
			end
			for guiID, data in pairs( self.items[id] ) do
				self:addObject( data, guiID )
			end
			self.active = id
			return true
		end
		return false
	end;

	getActiveTab = function( self, id )
		return self.active
	end;

	objectPairs = function( self )
		local t = {}
		if self.head then

		end
		for i = 1, #self.items do
			for guiID, data in pairs( self.items[i] ) do
				table.insert( t, data )
			end
		end
		return next, t
	end;
}
