local DataAltService:DataAltService = {}
--------datastores
local DataAltStores:{DataAltStore} = {}
local GlobalAltStores:{GlobalAltStore} = {}
local OrderedAltStores:{OrderedAltStore} = {}
--------metatables
local DataAltMeta = {}
DataAltMeta.__index = DataAltMeta
local GlobalAltMeta = {}
GlobalAltMeta.__index = GlobalAltMeta
local OrderedAltMeta = setmetatable({}, GlobalAltMeta)
OrderedAltMeta.__index = OrderedAltMeta
--------local
local DataStoreService = game:GetService("DataStoreService")
--------export type
export type DataAltService = {
	GetDataStore:(self:DataAltService, name:string)->DataAltStore,
	GetGlobalDataStore:(self:DataAltService, name:string)->GlobalAltStore,
	GetOrderedDataStore:(self:DataAltService, name:string)->OrderedAltStore,
}
export type DataAltStore = {
	Name:string,
	DataStore:DataStore,
	Synchronize:(self:DataAltStore, key:string)->(),
	GetAsync:(self:DataAltStore, key:string)->...any,
	SetAsync:(self:DataAltStore, key:string, value:any)->(),
	UpdateAsync:(self:DataAltStore, key:string, transformFunction:(...any)->...any)->...any,
}
export type GlobalAltStore = {
	Name:string,
	DataStore:{any},
	GetAsync:(self:GlobalAltStore, key:string)->...any,
	SetAsync:(self:GlobalAltStore, key:string, value:any)->(),
	UpdateAsync:(self:GlobalAltStore, key:string, transformFunction:(...any)->...any)->...any,
}
export type OrderedAltStore = {
	Name:string,
	DataStore:OrderedDataStore,
	GetSortedAsync:(self:OrderedAltStore, ascending:boolean, pageSize:number, minValue:any, maxValue:any)->DataStorePages,
	GetAsync:(self:OrderedAltStore, key:string)->...any,
	SetAsync:(self:OrderedAltStore, key:string, value:any)->(),
	UpdateAsync:(self:OrderedAltStore, key:string, transformFunction:(...any)->...any)->...any,
}
--------Synchronize
function DataAltMeta:Synchronize(key:string)
	local value = self:GetAsync(key)
	local GlobalAltStore:GlobalAltStore = DataAltService:GetGlobalDataStore(self.Name)
	GlobalAltStore:SetAsync(key, value)
end
--------GetAsync
function DataAltMeta:GetAsync(key:string)
	local DataStore = self.DataStore
	local value = DataStore[key]
	return value
end
function GlobalAltMeta:GetAsync(key:string)
	local DataStore:DataStore = self.DataStore
	local s,r = pcall(function()
		return DataStore:GetAsync(key)
	end)
	if not s then return error(r) end
	return r
end
function OrderedAltMeta:GetSortedAsync(ascending:boolean, pageSize:number, minValue:any?, maxValue:any?)
	local DataStore:OrderedDataStore = self.DataStore
	local s,r = pcall(function()
		return DataStore:GetSortedAsync(ascending, pageSize, minValue, maxValue)
	end)
	if not s then return error(r) end
	return r
end
--------SetAsync
function DataAltMeta:SetAsync(key:string, value:any)
	local DataStore = self.DataStore
	DataStore[key] = value
end
function GlobalAltMeta:SetAsync(key:string, value:any)
	local DataStore:DataStore = self.DataStore
	local s,r = pcall(function()
		return DataStore:SetAsync(key, value)
	end)
	if not s then return error(r) end
	return r
end
--------UpdateAsync
function DataAltMeta:UpdateAsync(key:string, transformFunction:(...any)->...any)
	local value = self:GetAsync(key)
	local s,r = pcall(transformFunction, value)
	if not s then return error(r) end
	self:SetAsync(key, r)
	return self:GetAsync(key)
end
function GlobalAltMeta:UpdateAsync(key:string, transformFunction:(...any)->...any)
	local DataStore:DataStore = self.DataStore
	local s,r = pcall(function()
		return DataStore:UpdateAsync(key, transformFunction)
	end)
	if not s then return error(r) end
	return r
end
--------GetDataStore
function DataAltService:GetDataStore(name:string):DataAltStore
	local DataAltStore:DataAltStore = DataAltStores[name]
	if not DataAltStore then
		DataAltStore = setmetatable({}, DataAltMeta)
		DataAltStore.Name = name
		DataAltStore.DataStore = {}
		DataAltStores[name] = DataAltStore
	end
	return DataAltStore
end
function DataAltService:GetGlobalDataStore(name:string):GlobalAltStore
	local GlobalAltStore:DataStore = GlobalAltStores[name]
	if not GlobalAltStore then
		local s,r = pcall(function()
			return DataStoreService:GetDataStore(name)
		end)
		if not s then return error(r) end
		local GlobalAltStore = setmetatable({}, GlobalAltMeta)
		GlobalAltStore.DataStore = r
		GlobalAltStore.Name = name
		GlobalAltStores[name] = GlobalAltStore
	end
	return GlobalAltStore
end
function DataAltService:GetOrderedDataStore(name:string):OrderedAltStore
	local OrderedAltStore:OrderedDataStore = OrderedAltStores[name]
	if not OrderedAltStore then
		local s,r = pcall(function()
			return DataStoreService:GetOrderedDataStore(name)
		end)
		if not s then return error(r) end
		local OrderedAltStore = setmetatable({}, OrderedAltMeta)
		OrderedAltStore.DataStore = r
		OrderedAltStore.Name = name
		OrderedAltStores[name] = OrderedAltStore
	end
	return OrderedAltStore
end
--------
return DataAltService
