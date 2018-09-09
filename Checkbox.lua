dxConstruction:subclass{
	type = 'checkbox';
	status = 'active_not_selected';
	selected = false;
	active = true;

	create = function( self )
		dxConstruction.create( self, false )
		
		self:setText( self.text )

		self:setActive( self.active == true )
		return self
	end;

	setText = function( self, text )
		return self.objects.text and self.objects.text:setText( text )
	end;

	setActive = function( self, active )
		if type( active ) == 'boolean' then
			self.active = active
			self:setStatus( ( active and 'active' or 'non_active' ) 
				.. ( self:getSelected() and '_selected' or '_non_selected' ) )
			return true
		end
		error( 'Bad argument #1, got ' .. type( active ), 2 )
	end;

	setStatus = function( self, status )
		if self.stats[status] then
			self.status = status
			table.unite( self.objects, self.stats[status], true )
			return true
		elseif self.stats[ '*' .. status] then
			table.unite( self.objects, self.stats['*' .. status], true )
		end
		return false
	end;

	getSelected = function ( self )
		return self.selected
	end;

	setSelected = function ( self, selected )
		if type( selected ) == 'boolean' then
			self.selected = selected
			self:setStatus( ( self.active and 'active' or 'non_active' ) 
				.. ( self:getSelected() and '_selected' or '_non_selected' ) )
			return true
		end
		error( 'Bad argument #1, got ' .. type( selected ), 2 )
	end;

	onClick = function( self, button, state )
		if self.active and button == 'left' and state == 'down' then
			self:setSelected( not self:getSelected() )
			if self.onChanged then
				self:onChanged( self:getSelected() )
			end
		elseif self.active and button == 'left' and state == 'up' then
			self:setStatus( 'default' )
		end
		return true
	end;

	onCursorMove = function( self, inStatus )
		if inStatus and self.status == 'default' then
			self:setStatus( 'oncursor' )
		elseif inStatus and self.status == 'oncursor' then

		else
			self:setStatus( 'default' )
		end
	end;
}
