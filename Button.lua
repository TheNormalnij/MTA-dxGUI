dxConstruction:subclass{
	type = 'button';
	enabled = true;

	create = function( self )
		dxConstruction.create( self, false )
		
		self:setText( self.text )

		self.input = Input:create{ }
		--self.input:bind( 'enter', true, self.onClick, self )

		self:setEnabled( self.enabled )
		return self
	end;

	setText = function( self, text )
		if self.objects.text then
			return self.objects.text:setText( text )
		end
		return false
	end;

	setShow = function( self, show )
		if type( show ) == 'boolean' then
			self:setStatus( 'default' )
			self.show = show
			return true
		end
		return false
	end;

	setEnabled = function( self, enabled )
		if type( enabled ) == 'boolean' then
			self.enabled = enabled
			if enabled then
				self:setStatus( 'default' )
			else
				self:setStatus( 'disabled' )
			end
			return true
		else
			error( 'Bad argument #1, got ' .. type( enabled ), 2 )
		end
	end;

	isEnabled = function( self )
		return self.enabled
	end;

	_onClick = function( self, button, state )
		if self.enabled then
			if self.enabled and button == 'left' and state == 'down' then
				self:setStatus( 'clicked' )
			elseif self.enabled and button == 'left' and state == 'up' then
				if self.onClick then
					self:onClick( )
				end
				self:setStatus( self:isOnCursor() and 'oncursor' or 'default' )
			end
		end
	end;

	onCursorMove = function( self, inStatus )
		if self.enabled then
			local currentStatus = self:getStatus()
			if inStatus and currentStatus == 'default' then
				self:setStatus( 'oncursor' )
			elseif inStatus and currentStatus == 'oncursor' then
				-- oncursor is now
			else
				self:setStatus( inStatus and getKeyState( 'mouse1' ) and 'clicked' or 'default' )
			end
		end
	end;
}
