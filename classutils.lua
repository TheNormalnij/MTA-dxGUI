
local rawget = rawget
local setmetatable = setmetatable

local class_mt = {}

function class_mt:inherit( newClass )
	newClass = newClass or {}
	newClass.__parent = self
	return setmetatable( newClass, class_mt )
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
		self:error( 'Can not find constructor for class', 2 )
		return false
	end
	return child:create( ... )
end

function class_mt:error( str, level )
	outputDebugString( str, level or 3 )
	outputDebugString( debug.traceback() )
end

function class( newClass )
	newClass = newClass or {}
	newClass.__index = newClass
	newClass.__parent = class_mt
	return setmetatable( newClass, class_mt )
end

-- Event interfeace

-- Метатаблица таблиц со слабыми ключами
local weakMetatable = { __mode = 'k' }

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
	if removeEventHandler( eventName, element, self.__bindetFunctions[_function] ) then
	else
		self:error( 'Can not remove event handler', 2 )
	end
end

-- RPC interfeace

addEvent( 'RPC', true ) -- server ==> client, client ==> server with out callback
addEvent( 'RPCC', true ) -- server ==> client, client ==> server with callback
addEvent( 'RPCR', true ) -- callback event

function class_mt:createRPC( element )

	if self.__RPC then
		self:error( 'Unexpected creation of a new calling interfeace' )
		return false
	else
		element = element or createElement( 'RPC' )
		self.__RPC = element
	end

	self:addEventHandler( 'RPC', element, self.__RPC_Handler )
	self:addEventHandler( 'RPCC', element, self.__RPCC_Handler )
	self:addEventHandler( 'RPCR', element, self.__RPCR_Handler )

	return self.__RPC
end

function class_mt:__RPC_Handler( functionName, ... )
	self[functionName]( self, ... )
end

function class_mt:__RPCR_Handler( callID, ... )
	local callHandlers = self.__callHandlers
	if callHandlers then
		for i = #callHandlers, 1, -1 do
			if callHandlers[i][1] == callID then
				callHandlers[i][2]( ... )
			end			
		end
	end
end

if triggerServerEvent then
	-- Client side

	function class_mt:RPC( functionName, ... )
		triggerServerEvent( 'RPC', self.__RPC, functionName, ... )
	end

	function class_mt:RPCC( callID, functionName, ... )
		triggerServerEvent( 'RPCC', self.__RPC, callID, functionName, ... )
	end

	function class_mt:__RPCC_Handler( callID, functionName, ... )
		triggerServerEvent( 'RPCR', self.__RPC, callID, self[functionName]( self, ... ) )
	end

else
	-- Server side

	function class_mt:RPC( players, functionName, ... )
		triggerClientEvent( players, 'RPC', self.__RPC, functionName, ... )
	end

	function class_mt:RPCC( callID, players, functionName, ... )
		triggerClientEvent( players, 'RPC', self.__RPC, callID, functionName, ... )
	end

	function class_mt:__RPCC_Handler( callID, functionName, ... )
		triggerClientEvent( client, 'RPCR', self.__RPC, callID, self[functionName]( self, ... ) )
	end

end

function class_mt:addCallHandler( callID, _funct )
	local callHandlers = self.__callHandlers
	if callHandlers then
	else
		callHandlers = {}
		self.__callHandlers = callHandlers
	end
	table.insert( callHandlers, { callID, _funct } )
	return true
end

function class_mt:removeCallHandler( callID, _funct )
	local callHandlers = self.__callHandlers
	if callHandlers then
	else
		return false
	end
	if _funct then
		for i = #callHandlers, 1, -1 do
			if callHandlers[i][1] == callID and callHandlers[i][2] == _funct then
				table.remove( callHandlers, i )
			end
		end
	else
		for i = #callHandlers, 1, -1 do
			if callHandlers[i][1] == callID then
				table.remove( callHandlers, i )
			end
		end
	end
	return true
end

function class_mt:removeRPC()
	if self.__RPC then
		self:removeEventHandler( 'RPC', self.__RPC, self.__RPC_Handler )
		self:removeEventHandler( 'RPCC', self.__RPC, self.__RPCC_Handler )
		self:removeEventHandler( 'RPCR', self.__RPC, self.__RPCR_Handler )

		self.__RPC = nil
		return true
	end
	return false
end

function class_mt:destroyRPC( )
	self.__RPC:destroy()
	self.__RPC = nil
end

--