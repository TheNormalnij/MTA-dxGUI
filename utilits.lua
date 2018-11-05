
local isClient = triggerServerEvent and true
local isServer = triggerClientEvent and true

function table.find( t, value )
	for i, _value in pairs( t ) do
		if _value == value then
			return i
		end
	end
	return false
end

function table.findIn( t, In, value )
	if type( t ) ~= 'table' then
		error( 'Bad argument #1, got ' .. type( t ), 2 )
	end
	if In == nil then
		error( 'Bad argument #2, got nil', 2 )
	end
	for i, data in pairs( t ) do
		if data[In] == value then
			return i
		end
	end
	return false
end

function table.getSize( t )
	local i = 0
	local key =  next( t )
	while key do
		i = i + 1
		key = next( t, i )
	end
	return i
end

function table.allFindIn( t, In, value )
	local resul = {}
	for i, data in pairs( t ) do
		if data[In] == value then
			table.insert( resul, i )
		end
	end
	return #resul ~= 0 and resul or false
end

function table.unite( table1, table2, recursive )
	if type( table1 ) ~= 'table' then
		error( 'Bad argument #1, got ' .. type( table1 ), 2 )
	end
	if type( table2 ) ~= 'table' then
		error( 'Bad argument #2, got ' .. type( table2 ), 2 )
	end
	for key, value in pairs( table2 ) do
		if type( value ) ~= 'table' or not recursive then
			table1[key] = value;
		else
			table1[key] = table.unite( table1[key] or {}, value, true )
		end
	end
	return table1
end

function table.uniteWithoutReplace( table1, table2 )
	if type( table1 ) ~= 'table' then
		error( 'Bad argument #1, got ' .. type( table1 ), 2 )
	end
	if type( table2 ) ~= 'table' then
		error( 'Bad argument #1, got ' .. type( table2 ), 2 )
	end
	for key, value in pairs( table2 ) do
		if type( value ) == 'table' then
			table1[key] = table.uniteWithoutReplace( table1[key] or {}, value )
		else
			table1[key] = table1[key] or value;
		end
	end
	return table1
end

function table.copy( t, recursive )
	if not t then
		error( 'Bad argument #1, got ' .. type( t ), 2 )
	end
	local new = {}
	for key, value in pairs( t ) do
		if type( value ) ~= 'table' or not recursive then
			new[key] = value;
		else
			new[key] = table.copy( value, recursive )
		end
	end
	return new
end

function table.removeValue( t, value )
	for i, _value in pairs( t ) do
		if _value == value then
			table.remove( t, i )
			return i
		end
	end
	return false
end

function table.getRandomValue( t, anyKeys )
	if type( t ) ~= 'table' then
		error( 'Bad argument #1, got ' .. type( t ), 2 )
	end
	if anyKeys then
		local i = math.random( table.getSize( t ) )
		if i ~= 0 then
			local key, value = next( t, i )
			return value, key
		else
			return false
		end
	else
		local size = #t
		if size == 0 then
			return false
		end
		local i = math.random( 1, size )
		if i ~= 0 then
			return t[i], i
		end
	end
end

function table.reverse( t )
	for i = 1, math.floor( #t / 2 ) do
		t[i], t[#t - i + 1] = t[#t - i + 1], t[i]
	end
end



-----

function string:getLineCount( )
	local lineCount = 1
	for _ in text:gmatch( '\n' ) do
		lineCount = lineCount + 1
	end
	return lineCount
end

function string.moneyFormating( money, separator )
	local formatted = tostring( money )
	local formatType = '%1' .. ( separator or ' ' ).. '%2'
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", formatType)
		if (k==0) then
			break
		end
	end
	return formatted
end

-----

function math.round(number, decimals, method)
	decimals = decimals or 0
	local factor = 10 ^ decimals
	if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
	else return tonumber(("%."..decimals.."f"):format(number)) end
end

function math.clamp( min, value, max )
	return math.max( min, math.min( value, max ) )
end

function math.isBetween( from, to, val )
	local min = math.min( from, to )
	local max = from == min and to or from
	return min <= val and val <= max
end

function math.toBitvise( ... )
	local arg = { ... }
	local int = 0x0
	for i = 1, #arg do
		if type( arg[i] ) == 'boolean' then
			if arg[i] then
				int = int + 2^( i - 1 )
			end
		else
			error( 'Wrong argumnet #' .. i .. ' in function math.toBitvise', 2 )
		end
	end
	return int
end

function math.fromBitvise( int, valuesCount )
	if type( int ) ~= 'number' then
		error( 'Wrong argument #1 in function math.toBitvise', level )
	end
	valuesCount = valuesCount or 32
	if type( valuesCount ) ~= 'number' then
		error( 'Wrong argument #2 in function math.toBitvise', level )
	end
	local o = {}
	for i = 1, valuesCount  do
		o[i] = bitTest( int, 2^(i - 1) )
	end
	return unpack( o )
end

-----

local tocolor = tocolor

color = {

	HEXtoRGB = function( color )
		local b = color % 2^8
		local g = ( ( color - b ) % 2^16 ) / 2^8
		local r = ( ( color - b - g * 2^8 ) % 2^24 ) / 2^16
		local a = ( ( color - b - g * 2^8 - r * 2^16 ) % 2^32 ) / 2^24
		return r, g, b, a
	end;

	RGBtoHEX = function( r, g, b, a )
		return tocolor( r, g, b, a )
	end;

	RGBtoHEXstring = function( r, g, b, a )
		if a then
			return string.format( '#%.2X%.2X%.2X%.2X', r, g, b, a )
		else
			return string.format( '#%.2X%.2X%.2X', r, g, b )
		end
	end;

	-- http://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c

	--[[
	 * Converts an RGB color value to HSL. Conversion formula
	 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
	 * Assumes r, g, and b are contained in the set [0, 255] and
	 * returns h, s, and l in the set [0, 1].
	 *
	 * @param   Number  r       The red color value
	 * @param   Number  g       The green color value
	 * @param   Number  b       The blue color value
	 * @return  Array           The HSL representation
	]]
	RGBtoHSL = function (r, g, b, a)
		r, g, b = r / 255, g / 255, b / 255

		local max, min = math.max(r, g, b), math.min(r, g, b)
		local h, s, l

		l = (max + min) / 2

		if max == min then
			h, s = 0, 0 -- achromatic
		else
			local d = max - min
			local s
			if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
			if max == r then
				h = (g - b) / d
				if g < b then h = h + 6 end
			elseif max == g then h = (b - r) / d + 2
			elseif max == b then h = (r - g) / d + 4
			end
			h = h / 6
		end

		return h, s, l, a or 255
	end;

	--[[
	 * Converts an HSL color value to RGB. Conversion formula
	 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
	 * Assumes h, s, and l are contained in the set [0, 1] and
	 * returns r, g, and b in the set [0, 255].
	 *
	 * @param   Number  h       The hue
	 * @param   Number  s       The saturation
	 * @param   Number  l       The lightness
	 * @return  Array           The RGB representation
	]]
	HSLtoRGB = function(h, s, l, a)
		local r, g, b

		if s == 0 then
			r, g, b = l, l, l -- achromatic
		else
			function hue2rgb(p, q, t)
				if t < 0   then t = t + 1 end
				if t > 1   then t = t - 1 end
				if t < 1/6 then return p + (q - p) * 6 * t end
				if t < 1/2 then return q end
				if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
				return p
			end

			local q
			if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
			local p = 2 * l - q

			r = hue2rgb(p, q, h + 1/3)
			g = hue2rgb(p, q, h)
			b = hue2rgb(p, q, h - 1/3)
		end

		return r * 255, g * 255, b * 255, a * 255
	end;

	--[[
	 * Converts an RGB color value to HSV. Conversion formula
	 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
	 * Assumes r, g, and b are contained in the set [0, 255] and
	 * returns h, s, and v in the set [0, 1].
	 *
	 * @param   Number  r       The red color value
	 * @param   Number  g       The green color value
	 * @param   Number  b       The blue color value
	 * @return  Array           The HSV representation
	]]
	RGBtoHSV = function (r, g, b, a)
		r, g, b, a = r / 255, g / 255, b / 255, a / 255
		local max, min = math.max(r, g, b), math.min(r, g, b)
		local h, s, v
		v = max

		local d = max - min
		if max == 0 then s = 0 else s = d / max end

		if max == min then
			h = 0 -- achromatic
		else
			if max == r then
			h = (g - b) / d
			if g < b then h = h + 6 end
			elseif max == g then h = (b - r) / d + 2
			elseif max == b then h = (r - g) / d + 4
			end
			h = h / 6
		end

		return h, s, v, a
	end;

	--[[
	 * Converts an HSV color value to RGB. Conversion formula
	 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
	 * Assumes h, s, and v are contained in the set [0, 1] and
	 * returns r, g, and b in the set [0, 255].
	 *
	 * @param   Number  h       The hue
	 * @param   Number  s       The saturation
	 * @param   Number  v       The value
	 * @return  Array           The RGB representation
	]]
	HSVtoRGB = function(h, s, v, a)
		local r, g, b

		local i = math.floor(h * 6);
		local f = h * 6 - i;
		local p = v * (1 - s);
		local q = v * (1 - f * s);
		local t = v * (1 - (1 - f) * s);

		i = i % 6

		if i == 0 then r, g, b = v, t, p
		elseif i == 1 then r, g, b = q, v, p
		elseif i == 2 then r, g, b = p, v, t
		elseif i == 3 then r, g, b = p, q, v
		elseif i == 4 then r, g, b = t, p, v
		elseif i == 5 then r, g, b = v, p, q
		end

		return r * 255, g * 255, b * 255, a * 255
	end;
}

function Element:getPositionFromOffset( vector )
	local m = self:getMatrix( )
	return m:transformPosition( vector )
end

if isClient then

	local isEscapeBlocked = false
	local handlers = {}

	local keyHandler

	function keyHandler( key, state )
		if key == 'escape' then
			if not state or isEscapeBlocked then
				return
			end
			cancelEvent()
			for _, handler in pairs( handlers ) do
				handler()
			end
			handlers = {}
			isEscapeBlocked = true
			removeEventHandler( 'onClientKey', root, keyHandler )
		else
			isEscapeBlocked = false
		end
	end;

	function bindEscapeOnce( _func )
		if table.find( handlers, _func ) then
			return false
		else
			table.insert( handlers, _func )
			if #handlers == 1 then
				addEventHandler( 'onClientKey', root, keyHandler )
			end
		end
	end

	function unbindEscapeOnce( _func )
		if table.removeValue( handlers, _func ) then
			if #handlers == 0 then
				removeEventHandler( 'onClientKey', root, keyHandler )
			end
		end
	end

end