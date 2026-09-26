local DataAltService = {}
--------datastores
local DataAltStores:{{any}} = {}
local GlobalAltStores:{DataStore} = {}
local OrderedAltStores:{OrderedDataStore} = {}
--------metatables
local DataAltMeta = {}
DataAltMeta.__index = DataAltMeta
local GlobalAltMeta = {}
GlobalAltMeta.__index = GlobalAltMeta
local OrderedAltMeta = {}
OrderedAltMeta.__index = OrderedAltMeta
--------local
local DataStoreService = game:GetService("DataStoreService")
--------export type
export type DataAltStore = {
	Name:string,
	Synchronize:(self:DataAltStore)->(),
	GetAsync:(key:string)->...any,
	SetAsync:(key:string, value:any)->(),
	UpdateAsync:(key:string, transformFunction:(...any)->...any)->...any,
}
export type GlobalAltStore = {
	Name:string,
	GlobalDataStore:DataStore,
	GetAsync:(key:string)->...any,
	SetAsync:(key:string, value:any)->(),
	UpdateAsync:(key:string, transformFunction:(...any)->...any)->...any,
}
export type OrderedAltStore = {
	Name:string,
	OrderedDataStore:OrderedDataStore,
	GetAsync:(ascending:boolean, pageSize:number, minValue:any, maxValue:any)->DataStorePages,
	SetAsync:(key:string, value:number)->(),
}
--------Synchronize
function DataAltMeta:Synchronize(key:string)
	local value = self:GetAsync(key)
	local GlobalAltStore:GlobalAltStore = DataAltService:GetDataStore(self.Name)
	GlobalAltStore:SetAsync(key, value)
end
--------GetAsync
function DataAltMeta:GetAsync(key:string):(key:string)->GlobalAltStore
	local value = DataAltStores[self.Name]
	return value
end
function GlobalAltMeta:GetAsync(key:string):(key:string)->...any
	local GlobalDataStore:DataStore = self.GlobalDataStore
	local s,r = pcall(function()
		return GlobalDataStore:GetAsync(key)
	end)
	if not s then return error(r) end
	return r
end
function OrderedAltMeta:GetAsync(ascending:boolean, pageSize:number, minValue:any, maxValue:any):(ascending:boolean, pageSize:number, minValue:any, maxValue:any)->DataStorePages
	local GlobalDataStore:OrderedDataStore = self.GlobalDataStore
	local s,r = pcall(function()
		return GlobalDataStore:GetSortedAsync(ascending, pageSize, minValue, maxValue)
	end)
	if not s then return error(r) end
	return r
end
--------SetAsync
function DataAltMeta:SetAsync(key:string, value:any):(key:string, value:any)->()
	DataAltStores[key] = value
end
function GlobalAltMeta:SetAsync()
end
function OrderedAltMeta:SetAsync()
end
--------UpdateAsync
function DataAltMeta:UpdateAsync(key:string, transformFunction:(...any)->...any):(key:string, transformFunction:(...any)->...any)->...any
	local value = self:GetAsync(key)
	local s,r = pcall(transformFunction, value)
	if not s then return error(r) end
	return self:GetAsync(key)
end
function GlobalAltMeta:UpdateAsync()
end
function OrderedAltMeta:UpdateAsync()
end
--------GetDataStore
function DataAltService:GetDataStore(name:string):(name:string)->DataAltStore
	local DataAltStore:DataAltStore = DataAltStores[name]
	if not DataAltStore then
		DataAltStore = setmetatable({},DataAltMeta)
		DataAltStore.Name = name
		DataAltStores[name] = DataAltStore
	end
	return DataAltStore
end
function DataAltService:GetGlobalDataStore(name:string):(name: string)->GlobalAltStore
	local GlobalAltStore:DataStore = GlobalAltStores[name]
	if not GlobalAltStore then
		local s,r = pcall(function()
			return GlobalAltStore:GetDataStore(name) or {}
		end)
		if not s then return error(r) end
		local GlobalAltStore = setmetatable({},GlobalAltMeta)
		GlobalAltStore.GlobalDataStore = r
		GlobalAltStore.Name = name
		GlobalAltStores[name] = GlobalAltStore
	end
	return GlobalAltStore
end
function DataAltService:GetOrderedDataStore(name:string):(name:string)->OrderedAltStore
	local OrderedAltStore:OrderedDataStore = OrderedAltStores[name]
	if not OrderedAltStore then
		local s,r = pcall(function()
			return OrderedAltStore:GetOrderedDataStore(name) or {}
		end)
		if not s then return error(r) end
		local OrderedAltStore = setmetatable({},OrderedAltMeta)
		OrderedAltStore.OrderedDataStore = r
		OrderedAltStore.Name = name
		OrderedAltStores[name] = OrderedAltStore
	end
	return OrderedAltStore
end
--------
return DataAltService
