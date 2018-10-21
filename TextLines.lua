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
	offsetY             = 0;

	invert = false;

	create = function( self )
		self.lines = {}
		self.fontSize = dxGetFontHeight( self.scale, self.font )
		self:setText( self.text )

		return self
	end;

	draw = function( self )
		local lineSpace = self.fontSize * self.lineSpacing
		if self.invert then
			for i = 1, math.min( #self.lines - self.offsetY, math.ceil( self.h / lineSpace ) ) do
				dxDrawText( self.lines[i + self.offsetY], self.x, self.y + self.h - lineSpace * i, self.x + self.w, self.y + self.h - lineSpace * (i - 1), self.color, self.scale, self.font, self.alignX, self.alignY,
					self.clip, self.wordBreak, self.postGUI, self.colorCoded, self.subPixelPositioning )
			end
		else
			for i = 1, math.min( #self.lines - self.offsetY, math.ceil( self.h / lineSpace ) ) do
				dxDrawText( self.lines[i + self.offsetY], self.x, self.y + lineSpace * (i - 1), self.x + self.w, self.y + lineSpace * i, self.color, self.scale, self.font, self.alignX, self.alignY,
					self.clip, self.wordBreak, self.postGUI, self.colorCoded, self.subPixelPositioning )
			end
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

			self.lines = self:splitText( text )
			return true
		end

		return false
	end;

	addText = function( self, text )
		if type( text ) == 'number' then
			text = tostring( text )
		end
		if type( text ) == 'string' then
			self.text = self.text .. '\n' .. text
			local currentLines = self.lines
			local newLines = self:splitText( text )
			if self.invert then
				table.reverse( newLines )
			end
			local offset = #newLines
			for i = 1, #currentLines do
				newLines[i + offset] = currentLines[i]
			end
			self.lines = newLines
			return true
		end

		return false		
	end;

	splitText = function( self, text )
		local spaceSize = dxGetTextWidth( ' ', self.scale, self.font, self.colorCoded )

		local lines = { [1] = '' }
		local currentLine = 1
		local currnetLineSize = 0
		local lastColor

		local function splitWord( word )
			if currnetLineSize ~= 0 then
				currentLine = currentLine + 1
				lines[currentLine] = self.colorCoded and lastColor or ''
				currnetLineSize = 0
			end

			local wordSize = #word
			for i = wordSize, 1, -1 do
				local subWord = word:sub( 1, i )
				if dxGetTextWidth( subWord, self.scale, self.font, self.colorCoded ) <= self.w then
					lines[currentLine] = ( currnetLineSize == 0 and word ) or ( lines[currentLine] .. ' ' .. word )
					if self.colorCoded then
						local _, _, findColor = subWord:reverse():find( '(%x%x%x%x%x%x#)' )
						lastColor = findColor and findColor:reverse() or lastColor
					end
					local word2 = word:sub( i, wordSize )
					local word2Size = dxGetTextWidth( word2, self.scale, self.font, self.colorCoded )
					if word2Size <= self.w then
						if currnetLineSize == 0 then
							if self.colorCoded and lastColor then
								lines[currentLine] = word
							else
								lines[currentLine] = word
							end
						else
							lines[currentLine] = lines[currentLine] .. ' ' .. word 
						end
						currnetLineSize = word2Size + spaceSize
					else
						splitWord( word2 )
					end
				end
			end
		end
		for block in utf8.gmatch( text, '([%w%p ]+\n?)' ) do
			for word in utf8.gmatch( block, '([%w%p]+)' ) do
				local wordSize = dxGetTextWidth( word, self.scale, self.font, self.colorCoded )
				if wordSize + currnetLineSize <= self.w then
					lines[currentLine] = ( currnetLineSize == 0 and word ) or ( lines[currentLine] .. ' ' .. word )

					currnetLineSize = wordSize + currnetLineSize + spaceSize
				elseif wordSize <= self.w then

					currentLine = currentLine + 1
					lines[currentLine] = self.colorCoded and lastColor or ''
					currnetLineSize = 0

					lines[currentLine] = ( currnetLineSize == 0 and word ) or ( lines[currentLine] .. ' ' .. word )
					currnetLineSize = wordSize + currnetLineSize + spaceSize
				else
					splitWord( word )
				end
			end
		end
		-- currentLine = currentLine + 1
		-- lines[currentLine] = ''
		-- currnetLineSize = 0
		return lines
	end;

	move = function( self, countY )
		local linesCount = #self.lines
		local maxOffsetY = -(math.ceil( self.h / (self.fontSize * self.lineSpacing) ) - linesCount) - 1

		if countY and countY ~= 0 and maxOffsetY > 0 then
			if self.offsetY + countY > maxOffsetY then
				self.offsetY = maxOffsetY
			elseif self.offsetY + countY < 0 then
				self.offsetY = 0
			else
				self.offsetY = self.offsetY + countY
			end
		end
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