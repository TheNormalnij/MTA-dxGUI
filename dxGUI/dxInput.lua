local stickyTimer

local currentInput

Input = class{
	sticked	= false;
	sticky	= 70; -- ms

	create = function( self )
		self.controll = {}
		return self
	end;

	get = function( )
		return currentInput
	end;

	getBind = function( self, key, state )
		local controll = self.controll
		for i = 1, #controll do
			if controll[i][1] == key and controll[i][2] == state then
				return controll[i], i
			end
		end
		return false
	end;

	bind = function( self, key, state, funct, ... )
		if self:getBind( key, state ) then
			return false
		end
		table.insert( self.controll, { key, state, funct, ... } )
	end;

	unbind = function( self, key, state )
		local bind, pos = self:getBind( key, press )
		if bind then
			table.remove( self.controll, pos )
			return true
		end
		return false
	end;

	onKey = function( self, key, press )
		local bind = self:getBind( key, press )
		if bind then
			bind[3]( unpack( bind, 4 ) )
			if key == 'escape' and press then
				cancelEvent()
			end
		end
	end;

	activate = function( self )
		if currentInput then
			currentInput:deactivate()
		end
		currentInput = self
		if self.onCharacter then
			guiSetInputMode( 'no_binds' )
		end
		if self.onActivate then
			self:onActivate()
		end
	end;

	isActive = function( self )
		return currentInput == self
	end;

	deactivate = function( self )
		currentInput = false
		if self.onDeactivate then
			self:onDeactivate()
		end
		guiSetInputMode( 'allow_binds' )
	end;
}

---------------------------

addEventHandler( 'onClientCharacter', root, function( character )
	if currentInput and currentInput.onCharacter then
		currentInput:onCharacter( character )
	end
end )

addEventHandler( 'onClientKey', root, function( button, press )
	if currentInput then
		if currentInput.sticked then
			if stickyTimer and isTimer( stickyTimer ) then
				killTimer( stickyTimer )
			end
			if press then
				stickyTimer = Timer( function()
					if currentInput then
						currentInput:onKey( button, press )
					else
						killTimer( stickyTimer )
					end
				end, currentInput.sticky, 0 )
			end
		end
		currentInput:onKey( button, press )
	end
end )
