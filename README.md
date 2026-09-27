# 🧩 DataAltService
## About Module
Simpler and better usage of DataStoreService

## Setup
Put [DataAltService.luau](https://github.com/ApplePancake63/DataAltService/blob/main/DataAltService.luau) into your place
## Require
```lua
--Before
local DataStoreService = game:GetService("DataStoreService")
--After
local DataAltService = require(game.ReplicatedStorage.DataAltService)
```
## Learn about Local Data Store
Here, `:GetDataStore()` returns the place's **local** data store

To **Get Local Data Store** we should use `:GetDataStore()` method on the **DataAltService**
```lua
local LocalStore = DataAltService:GetDataStore("LocalStore")
```
It does **not** save any data into the **true DataStore**

To **Get** any data from the **Local Data Store** we should use `:GetAsync()` as usual
```lua
local my_data = LocalStore:GetAsync("my_key")
print(my_data) -- nil
```
**Oops!** We don't have stored data yet!

To **Set** any data in the **Local Data Store** we should use `:SetAsync()` as usual
```lua
local my_data = "hey! I stored locally in your place!"
LocalStore:SetAsync("my_key", my_data)
print(LocalStore:GetAsync("my_key")) -- hey! I stored locally in your place!
```
**Nice work!** Let's **update** our local data

To **Update** any data in the **Local Data Store** we should use `:UpdateAsync()` as usual
```lua
local to_concat = " And I'll disappear forever after the server closes."
local new_data = LocalStore:UpdateAsync("my_key", function(past_data:string)
    return past_data..to_concat
end)
print(new_data) -- hey! I stored locally in your place! And I'll disappear forever after the server closes.
```
Yup! You will... But I have a **solution!**

To **Synchronize** our **Global Data Store** with the **Local Data Store** we should use `:Synchronize()` method on the **local** one
```lua
LocalStore:Synchronize("my_key")
--GlobalStore incoming
local synced = DataAltService:GetGlobalStore("LocalStore"):GetAsync("my_key")
print(synced) -- hey! I stored locally in your place! And I'll disappear forever after the server closes.
```
Okay! You **won't** disappear now... Let's move on to the **Global Data Store**

## Learn about Global Data Store

Well, it actually has nothing to do with `DataStoreService:GetGlobalDataStore()`, it's just `DataStoreService:GetDataStore()`

To **Get Global Data Store** we should use `:GetGlobalDataStore()` on the **DataAltService**
```lua
local GlobalStore = DataAltService:GetGlobalDataStore("GlobalStore")
```
**GlobalStore's** methods are actually pretty **similar** to the **LocalStore's** ones

But the main **difference** is that the **GlobalStore** saves data **straight** to the **DataStoreService** with `pcall()` function

And... We have **another** one **type** of the DataStore!
## Learn about Ordered Data Store
Have you ever had experience with **OrderedDataStores** before? **Leaderboards**, maybe... **matchmaking**?

Well, **DataAltService** has **OrderedDataStores** too!

To **Get Ordered Data Store** we should use `:GetOrderedDataStore()` on **DataAltService**
```lua
local OrderedStore = DataAltService:GetOrderedDataStore("OrderedStore")
```
**OrderedDataStore's** methods are also **similar** to the **GlobalStore's** ones

But it has a **unique method**

To **Get Sorted** data from the **Ordered Data Store** we should use `:GetSortedAsync()` as usual
```lua
--:GetSortedAsync(ascending:boolean, pageSize:number, minValue:any?, maxValue:any?)
local pages:DataStorePages = OrderedStore:GetSortedAsync(false, 8)
print(pages:GetCurrentPage()) -- {...}
```
## Well, that's it for now!
I'm open to your Pull Requests!

Made by [ApplePancake63](https://github.com/ApplePancake63)
