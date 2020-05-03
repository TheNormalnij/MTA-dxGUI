
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
			return i, data
		end
	end
	return false
end

function table.getSize( t )
	local i = 0
	local key =  next( t )
	while key do
		i = i + 1
		key = next( t, key )
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

	if recursive then
		for key, value in pairs( table2 ) do
			if type( value ) == 'table' then
				table1[key] = table.unite( table1[key] or {}, value, true )
			else
				table1[key] = value;
			end
		end		
	else
		for key, value in pairs( table2 ) do
			table1[key] = value;
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
		local size = math.random( table.getSize( t ) )
		if size ~= 0 then
			local key, value = next( t )
			for i = 2, size do
				key, value = next( t, key )
			end
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
	local size = #t
	for i = 1, math.floor( size / 2 ) do
		t[i], t[size - i + 1] = t[size - i + 1], t[i]
	end
end

function table.erase( t )
	if type( t ) ~= 'table' then
		error( 'Bad argument #1, got ' .. type( t ), 2 )
	end
	for k in pairs( t ) do
		t[k] = nil
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

----

do
	local PI = math.pi
	local PI2 = 2 * math.pi
	local atan2 = math.atan2
	local abs = math.abs
	function math.isInViewRange( x1, y1, x2, y2, rot1, halfViewAngle )
		x2 = ( PI - atan2( ( x1 - x2 ), ( y1 - y2 ) ) )  % PI2
		x1 = abs( rot1 - x2 )
		if x1 > PI then
			x1 = PI2 - x1
		end
		return x1 < halfViewAngle
	end
end

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
	if from < to then
		return from <= val and val <= to
	else
		return to <= val and val <= from
	end
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

function math.getMilliseconds( ms, sec, min, hours )
	ms = ms or 0
	sec = sec or 0
	min = min or 0
	hours = hours or 0
	return ((((hours * 60) + min) * 60) + sec) * 1000 + ms
end;

function math.getChekedValueInRange( from, to, checkFun )
	if from > to then
		error( "Wrong range", 2 )
	end

	local half
	local floor = math.floor

	local function checkInstance( )
		if from == to then
			return
		end
		if from + 1 == to then
			from = checkFun( to ) and to or from
			return
		end
		half = floor( from + ( to - from ) / 2 )
		if checkFun( half ) then
			from = half
		else
			to = half
		end
		return checkInstance( )
	end
	checkInstance()
	return from
end

-----

local tocolor = tocolor

color = {

	HEXtoRGB = function( color )
		local b = color % 2^8
		local g = math.floor( ( ( color - b ) % 2^16 ) / 2^8 )
		local r = math.floor( ( ( color - b - g * 2^8 ) % 2^24 ) / 2^16 )
		local a = math.floor( ( ( color - b - g * 2^8 - r * 2^16 ) % 2^32 ) / 2^24 )
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
 
function Timer.createAttachedToTime( _func, secondsFromStartDay, interval, count, callBack )
	local rt = getRealTime()
	local thisDayStart = rt.timestamp - rt.hour * 60 * 60 - rt.minute * 60 - rt.second
	local timeToStart
	if rt.timestamp > thisDayStart + secondsFromStartDay then
		local executesCount = math.ceil( (rt.timestamp - thisDayStart - secondsFromStartDay) / interval )
		timeToStart = thisDayStart - rt.timestamp + (secondsFromStartDay + interval * executesCount)   
	else
		timeToStart = (thisDayStart + secondsFromStartDay) - rt.timestamp
	end

	local firstFunction = function( )
		count = count - 1
		_func()
		if count ~= 0 then
			local timer = Timer( _func, interval * 1000, count == -1 and 0 or count )
			if callBack then
				callBack( timer )
			end
		end
	end

	Timer( firstFunction, timeToStart * 1000, 1 )
end