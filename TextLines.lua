dxGUI.baseClass:subclass{
	type                = 'textLines';
	text                = '';
	w                   = 0;
	h                   = 0;
	color               = 0xFF000000;
	scale               = 1;
	font                = 'default';
	alignX              = 'left'; -- Can be "left", "center" or "right"
	alignY              = 'top';  -- Can be "top", "center" or "bottom"
	clip                = false;
	wordBreak           = false;
	postGUI             = false;
	colorCoded          = false;
	subPixelPositioning = false;
	lineSpacing         = 1.0;

	create = function( self )
		self.lines = {}
		self.fontSize = dxGetFontHeight( self.scale, self.font )
		self:setText( self.text )

		return self
	end;

	draw = function( self )
		for i = 1, #self.lines do
			dxDrawText( self.lines[i], self.x, self.y + self.fontSize * ( i - 1 ) * self.lineSpacing, self.x + self.w, self.y + self.fontSize + self.fontSize * ( i - 1 ) * self.lineSpacing, self.color, self.scale, self.font, self.alignX, self.alignY,
				self.clip, self.wordBreak, self.postGUI, self.colorCoded, self.subPixelPositioning )
		end
	end;

	getText = function( self )
		return self.text
	end;

	setText = function( self, text )
		if type( text ) == 'number' then
			text = tostring( text )
		end
		if type( text ) == 'string' then
			self.text = text

			local spaceSize = dxGetTextWidth( ' ', self.scale, self.font )

			self.lines = { [1] = '' }
			local currentLine = 1
			local currnetLineSize = 0

			local function splitWord( word )
				if currnetLineSize ~= 0 then
					currentLine = currentLine + 1
					self.lines[currentLine] = ''
					currnetLineSize = 0
				end

				local wordSize = #word
				for i = wordSize, 1, -1 do
					local subWord = word:sub( 1, i )
					if dxGetTextWidth( subWord, self.scale, self.font ) <= self.w then
						self.lines[currentLine] = ( currnetLineSize == 0 and word ) or ( self.lines[currentLine] .. ' ' .. word )

						local word2 = word:sub( i, wordSize )
						local word2Size = dxGetTextWidth( subWord, self.scale, self.font )
						if word2Size <= self.w then
							self.lines[currentLine] = ( currnetLineSize == 0 and word ) or ( self.lines[currentLine] .. ' ' .. word )
							currnetLineSize = word2Size + spaceSize
						else
							splitWord( word2 )
						end
					end
				end
			end
			for block in utf8.gmatch( text, '([%w%p ]+\n?)' ) do
				for word in utf8.gmatch( block, '([%w%p]+)' ) do
					local wordSize = dxGetTextWidth( word, self.scale, self.font )
					if wordSize + currnetLineSize <= self.w then
						self.lines[currentLine] = ( currnetLineSize == 0 and word ) or ( self.lines[currentLine] .. ' ' .. word )

						currnetLineSize = wordSize + currnetLineSize + spaceSize
					elseif wordSize <= self.w then

						currentLine = currentLine + 1
						self.lines[currentLine] = ''
						currnetLineSize = 0

						self.lines[currentLine] = ( currnetLineSize == 0 and word ) or ( self.lines[currentLine] .. ' ' .. word )
						currnetLineSize = wordSize + currnetLineSize + spaceSize
					else
						splitWord( word )
					end
				end
			end
			currentLine = currentLine + 1
			self.lines[currentLine] = ''
			currnetLineSize = 0
		end

		return false
	end;

	getLinesCount = function( self )
		return #self.lines
	end;

	getRealSize = function( self )
		return dxGetTextWidth( self.text, self.scale, self.font ),
			#self.lines * self.fontSize * self.lineSpacing
	end;

	setRealSize = function( self )
		self.w, self.h = self:getRealSize()
	end;
	
	setScale = function( self, scaleX, scaleY )
		self.w, self.h = self.w * scaleX, self.h * ( scaleY or scaleX )
		self.scale = scaleX * self.scale
	end;

	setPostGUI = function( self, state )
		if state == true or state == false then
			self.postGUI = state
		end
	end;
}