
local rawget = rawget
local setmetatable = setmetatable

-- Метатаблица таблиц со слабыми ключами
local weakMetatable = { __mode = 'k' }

local class_mt = {}

function class_mt:inherit( newClass )
	newClass = newClass or {}
	newClass.__parent = self
	return setmetatable( newClass, class_mt )
end

function class_mt:addEventHandler( eventName, element, _function, ... )
	-- Таблица будет очищатся сборщиком мусора
	self.__bindetFunctions = self.__bindetFunctions or setmetatable( {}, weakMetatable )
	local bind = self.__bindetFunctions[_function] or function( ... )
		_function( self, ... )
	end
	self.__bindetFunctions[_function] = bind
	addEventHandler( eventName, element, bind, ... )
end

function class_mt:removeEventHandler( eventName, element, _function )
	removeEventHandler( eventName, element, self.__bindetFunctions[_function] )
end

addEvent( 'onCallingInterfeace', true )
addEvent( 'onCallingInterfeaceResul', true )
function class_mt:createClientCallInterfeace( callElement )
	self.callElement = callElement or createElement( 'сallingInterfeace' )
	addEventHandler( 'onCallingInterfeace', self.callElement, function( id, functionName, ... )
		local commandResul = { self[functionName]( self, ... ) }
		if client then
			triggerClientEvent( client, 'onCallingInterfeaceResul', self.callElement, id, unpack( commandResul ) )
		else
			triggerEvent( 'onCallingInterfeaceResul', self.callElement, id, unpack( commandResul ) )
		end
	end )
	return self.callElement
end

addEvent( 'onCC', true )

function class_mt:createRPC( element )

	if self.__RPC then
		self:error( 'Unexpected creation of a new calling interfeace' )
		return false
	else
		self.__RPC = element or createElement( 'RPC' )
	end

	addEventHandler( 'onCC', self.__RPC, function( functionName, ... )
		self[functionName]( self, ... )
	end )

	return self.__RPC
end

if triggerServerEvent then

	function class_mt:RPC( functionName, ... )
		triggerServerEvent( 'onCC', self.__RPC, functionName, ... )
	end

else

	function class_mt:RPC( players, functionName, ... )
		triggerClientEvent( players, 'onCC', self.__RPC, functionName, ... )
	end

end

function class_mt:destroyRPC( )
	self.__RPC:destroy()
end

function class_mt:__index( key )
	local get = rawget( self, key )
	if get == nil then
		return rawget( self, '__parent' )[key]
	else
		return get
	end
end

function class_mt:__call( ... )
	local child = setmetatable( {}, class_mt )
	child.__parent = self
	if not child.create then
		outputDebugString( debug.traceback() )
	end
	return child:create( ... )
end

function class( newClass )
	newClass = newClass or {}
	newClass.__index = newClass
	newClass.__parent = class_mt
	return setmetatable( newClass, class_mt )
end

function class_mt:error( str, level )
	outputDebugString( str, 3 )
	outputDebugString( debug.traceback() )
end
