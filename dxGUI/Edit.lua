dxConstruction:subclass{
	type       = 'editField';
	isBlocked  = false;
	maxLen     = 255;
	caret      = 0;
	filter = false;

	create = function( self )
		--if not self.objects.text then
		--	return false
		--end
		dxConstruction.create( self, false )

		--self.construction.objects.text.input = Input{
		self.input = Input()
		self.input.sticked = true
		self.input:bind( 'backspace', true, self.remove, self, 1 )
		self.input:bind( 'arrow_l', true, self.moveCarete, self, -1 )
		self.input:bind( 'arrow_r', true, self.moveCarete, self, 1 )
		self.input:bind( 'enter', true, self.input.deactivate, self.input )

		self.input.onCharacter = function( input, character )
			self:add( character )
		end;

		self:setPlaceholderText( self.placeholderText )
		self:setPlaceholderShow( self:getText() == '' )

		self.input.onActivate = function( input )
			self:setPlaceholderShow( false )
			self.beforeActiveText = self:getText()
			self.caret = utfLen( self:getText() )
			if self.isBlocked then
				input:deactivate()
			else
				if self:isOnCursor() then
					self:setStatus( 'oncursor_active' )
				else
					self:setStatus( 'active' )
				end
				if self.onStartEdit then
					self:onStartEdit()
				end
			end
		end;

		self.input.onDeactivate = function( input )
			if self.onFinishEdit then
				self:onFinishEdit( self:getText(), self.beforeActiveText )
			end
			if self:getText() == '' then
				self:setPlaceholderShow( true )
			end
			if self:isOnCursor() then
				self:setStatus( 'oncursor_dective' )
			else
				self:setStatus( 'default' )
			end
		end;

		self.defaultTextAlign = self.objects.text.alignX or 'left'
		self:setText( tostring( self.text or '' ), false )
		self.text = nil
		return self
	end;

	setText = function ( self, text, callEvent )
		local textObject = self.objects.text
		if textObject:setText( text ) then
			if textObject:getRealSize() >= textObject.w then
				textObject.alignX = 'right'
			else
				textObject.alignX = self.defaultTextAlign
			end
			self:setPlaceholderShow( text == '' and Input.get() ~= self.input )
			if self.onChanged and ( callEvent == nil or callEvent ) then
				self:onChanged( text )
			end
		end
	end;

	getText = function( self )
		return self.objects.text:getText( )
	end;

	setPlaceholderText = function( self, text )
		if self.objects.placeholder then
			return self.objects.placeholder:setText( text )
		end
		return true
	end;

	setPlaceholderShow = function( self, state )
		if self.objects.placeholder then
			return self.objects.placeholder:setShow( state )
		end
		return false
	end;

	getPlaceholderShow = function( self )
		if self.objects.placeholder then
			return self.objects.placeholder:isShow( )
		end
		return false
	end;

	setBlocked = function( self, isBlocked )
		if isBlocked == true or isBlocked == false then
			self.isBlocked = isBlocked
			if isBlocked then
				self.input:deactivate()
				self:setStatus( 'disabled' )
			else
				if self:isOnCursor() then
					self:setStatus( 'oncursor_dective' )
				else
					self:setStatus( 'default' )
				end
			end
			return true
		end 
		return false
	end;

	moveCarete = function( self, count )
		local textSize = utfLen( self.objects.text:getText( ) )
		if self.caret + count < 0 then
			self.caret = 0
		elseif self.caret + count > textSize then
			self.caret = textSize
		else
			self.caret = self.caret + count
		end
	end;

	add = function( self, s )
		if type( s ) ~= 'string' then
			error( 'Bad argument #1 to "editField:add" (string expected got ' .. type( s ) .. ')', 2 )
		end

		if self.filter then
			s = s:gsub( self.filter, '' )
		end
		
		if s == '' then return false; end
		if self.isBlocked then return false; end

		local text = self:getText()

		local currentLen = utfLen( text )
		local stringLen	 = utfLen( s )
		if currentLen + stringLen > self.maxLen then
			s = utfSub( s, 0, self.maxLen - currentLen )
			stringLen	 = utfLen( s )
		end
		self:setText( utfSub( text, 0, self.caret ) .. s .. utfSub( text, self.caret + 1, currentLen ) )
		self.caret = self.caret + stringLen
		return true
	end;

	remove = function( self, count )
		if self.caret == 0 then return false; end
		if self.isBlocked then return false; end
		local text = self:getText()

		count = self.caret - count >= 0 and count or self.caret
		self:setText( utfSub( text, 0, self.caret - count ) .. utfSub( text, self.caret + 1, utfLen( text ) ) )
		self.caret = self.caret - count
		return true
	end;

	setShow = function( self, show )
		if type( show ) == 'boolean' then
			if self.isBlocked then
				self:setStatus( 'disabled' )
			else
				if self.input:isActive() then
					if self:isOnCursor() then
						self:setStatus( 'oncursor_active' )
					else
						self:setStatus( 'active' )
					end
				else
					if self:isOnCursor() then
						self:setStatus( 'oncursor_dective' )
					else
						self:setStatus( 'default' )
					end
				end
			end
			self.show = show
			return true
		end
		return false
	end;

	onCursorMove = function( self, inStatus )
		if self.isBlocked then

		else
			if inStatus then
				if self.input:isActive() then
					self:setStatus( 'oncursor_active' )
				else
					self:setStatus( 'oncursor_dective' )
				end
			else
				self:setStatus( 'default' )
			end
		end
	end;
}