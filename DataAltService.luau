local DataAltService = {}
--------datastores
local DataAltStores:{{...}} = {}
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
		UpdateAsync:(key:string, transformFunction:(pastVersion:...)->...any),
}
export type GlobalAltStore = {
		Name:string,
		GlobalDataStore:DataStore,
		GetAsync:(key:string)->...,
		SetAsync:(key:string, value:any)->(),
		UpdateAsync:(key:string, transformFunction:(pastVersion:...)->...any),
}
export type OrderedAltStore = {
		Name:string,
		OrderedDataStore:OrderedDataStore,
		GetAsync:(isAscending:boolean, pageSize:number)->DataStorePages,
  SetAsync:(key:string, value:number)->(),
}
--------Synchronize
function DataAltMeta:Synchronize(key:string)
		local value = self:GetAsync(key)
		local GlobalAltStore:GlobalAltStore = DataAltService:GetDataStore(self.Name)
		GlobalAltService:SetAsync(key, value)
end
--------GetAsync
function DataAltMeta:GetAsync(key:string)::(key:string)->...any
		local value = DataAltStores[self.Name]
		return value
end
function GlobalAltMeta:GetAsync(...)::(key:string)->...any
  local GlobalDataStore = self.GlobalDataStore
		local s,r = pcall(function()
				return GlobalDataStore:GetAsync(...)
		end)
		if not s then return error(r) end
		return r
end
function OrderedAltMeta:GetAsync(...)::(isAscending:boolean, pageSize:number)->DataStorePages
  local GlobalDataStore = self.GlobalDataStore
		local s,r = pcall(function()
				return GlobalDataStore:GetSortedAsync(...)
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
function DataAltMeta:UpdateAsync(key:string, transformFunction:(pastVersion:...any)->...any):(key:string, transformFunction:(pastVersion:...any)->...any)
  local value = self:GetAsync(key)
  local s,r = pcall(transformFunction, value)
  if not s then return error(r) end
  return r
end
function GlobalAltMeta:UpdateAsync()
end
function OrderedAltMeta:UpdateAsync()
end
--------GetDataStore
function DataAltService:GetDataStore(Name:string)::(Name:string)->DataAltStore
  local DataAltStore:DataAltStore = DataAltStores[Name]
  if not DataAltStore then
    DataAltStore = setmetatable({},DataAltMeta)
  		DataAltStore.Name = Name
    DataAltStores[Name] = DataAltStore
  end
  return DataAltStore
end
function DataAltService:GetGlobalDataStore(Name:string)::(Name: string)->GlobalAltStore
  local OrderedAltStore = OrderedAltStores[Name]
  if not OrderedAltStore then
  		local s,r = pcall(function()
    		return DataStoreService:GetDataStore(Name) or {}
  		end)
  		if not s then return error(r) end
  		local GlobalAltStore = setmetatable({},GlobalAltMeta)
  		GlobalAltStore.GlobalDataStore = r
  		GlobalAltStore.Name = Name
  		GlobalAltStores[Name] = GlobalAltStore
  end
  return GlobalAltStore
end
function DataAltService:GetOrderedDataStore(Name:string)::(Name:string)->OrderedAltStore
  local OrderedAltStore = OrderedAltStores[Name]
  if not OrderedAltStore then
    local s,r = pcall(function()
      return DataStoreService:GetOrderedDataStore(Name) or {}
    end)
    if not s then return error(r) end
    local OrderedAltStore = setmetatable({},OrderedAltMeta)
    OrderedAltStore.OrderedDataStore = r
  		OrderedAltStore.Name = Name
    OrderedAltStores[Name] = OrderedAltStore
  end
  return OrderedAltStore
end
--------
return DataAltService