--[Made by Jozeni00]--
print("Jozeni00\'s Data Serializer 2.0 loaded.")

--[[

	[API]

	----------------------------------------------------------------------------------
	--[DataSerializer]--

	PROPERTIES:

	*dictionary* DataSerializer.DataStores
	A dictionary list of DataStores in use.

	METHODS:

	*DataStore* DataSerializer:GetStore(name: string, options: DataStoreOptions)
	Gets the data store from DataStoreService.

	name: string (optional) (Default: "") The name of the Data Store.
	options: DataStoreOptions (optional)

	Returns a DataStore table with usable functions.

	*dictionary* DataSerializer:ListStores()
	Returns a single dictionary of GlobalDataStores currently in use.
		{
			[Name] = GlobalDataStore;
		}

	*void* DataSerializer:SetRetries(retries: int, delay: double)
	Sets the number of retries and the time of delay (in seconds) in between retries.

	retries: int (optional) (Default: 3)
	delay: double (optional) (Default: 2.0)

	----------------------------------------------------------------------------------
	--[DataStore]--

	PROPERTIES:

	*GlobalDataStore* DataStore.GlobalDataStore
	The GlobalDataStore currently being used.

	METHODS:

	*folder*, *dictionary*, *variant* DataStore:Get(plr: player, key: string, userids: array, options: DataStoreSetOptions)
	Initializes/gets the data store folder for the player. If the folder does not exist, it will be parented to the player.
	If the player does not have old data, then PresetPlayerData will be set as the new default data for the player.
	plr:SetAttribute("DataStoreLoaded", folderName: string) is called after the player finishes loading, returns the name of Folder.

	plr: player
	Key: string
	userids: array (optional) Array of UserIds. Recommended for handling GDPR. i.e. {Player.UserId} or {123456}.
	options: DataStoreSetOptions (optional) DataStoreSetOptions object. Part of DataStore v2, metadata options.

	Returns the Folder of PlayerData that is parented to the player, a dictionary of serialized PlayerData,
		and DataStoreKeyInfo object if the player has played before, or Version Identifier object if the player is new.
		If an error occured while retrieving Player data, then only the Folder will be returned.

	*void* DataStore:Update(plr: Player, key: string)
	Serializes the folder, then sends it to the Data Store.
	plr:SetAttribute("IsSaving", true) is called first, while DataStore is updating data.
	plr:SetAttribute("IsSaving", false) is called after the DataStore finishes updating data.

	plr: player
	Key: string

	*void* DataStore:CleanUpdate(plr: Player, key: string)
	Serializes the folder, then sends it to the Data Store. Also, cleans up debris.
		This is only recommended to use when the player leaves.
	plr:SetAttribute("IsSaving", true) is called first, while DataStore is updating data.
	plr:SetAttribute("IsSaving", false) is called after the DataStore finishes updating data.

	plr: player
	Key: string

	*dictionary*, *DataStoreKeyInfo* DataStore:Remove(key: string)
	Deletes the key associated with this DataStore.

	Key: string

	Returns a dictionary of the old deleted data, and DataStoreKeyInfo object.

]]

--[[

	How To Use:

	Insert a folder named "PresetPlayerData" into ServerStorage.
	Any instance under the folder will be serialized sent to DataStore.

	If any instance was added into PresetPlayerData from Studio, copy and paste this code below into the command bar in studio to add GUIDs.

--{COPY CODE - TO ADD GUID's}--

local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local PresetPlayerData = ServerStorage:FindFirstChild("PresetPlayerData")

if not PresetPlayerData then
	PresetPlayerData = Instance.new("Folder")
	PresetPlayerData.Name = "PresetPlayerData"
	PresetPlayerData.Parent = ServerStorage
end

local function setUniqueId(object)
	local aName = "GUID"
	if not object:GetAttribute(aName) then
		object:SetAttribute(aName, HttpService:GenerateGUID(false))
	end
end

setUniqueId(PresetPlayerData)
for i, v in pairs(PresetPlayerData:GetDescendants()) do
	setUniqueId(v)
end
--{COPY CODE (END)}--



[To remove GUID]
If wanting to remove GUID's copy and paste this code into the command bar in studio.

--[COPY CODE - TO DELETE GUID's]--

local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local PresetPlayerData = ServerStorage:FindFirstChild("PresetPlayerData")

if not PresetPlayerData then
    PresetPlayerData = Instance.new("Folder")
    PresetPlayerData.Name = "PresetPlayerData"
    PresetPlayerData.Parent = ServerStorage
end

local function setUniqueId(object)
    local aName = "GUID"
    if object:GetAttribute(aName) then
        object:SetAttribute(aName, nil)
    end
end

setUniqueId(PresetPlayerData)
for i, v in pairs(PresetPlayerData:GetDescendants()) do
    setUniqueId(v)
end
--[COPY CODE (END)]--

]]

--[[
Prebuilt Script that utilizes this module:

--[Made by Jozeni00]--
--settings
local DataSettings = {
	--{DATA}--
	--Any changes made below are susceptible to a clean data wipe, or revert data to its previous.
	["Name"] = "DS_Test2V0-0-0"; --DataStore name for the entire game.
	["Key"] = "Plr_"; --prefix for key. Example: "Player_" is used for "Player_123456".

	--{FEATURES}--
	["AutoSave"] = true; --set to true to enable auto saving.
	["SaveTime"] = 1; --time (in minutes) how often it should automatically save.

	["UseStudioScope"] = true; --set to true to use a different Scope for Studio only.
	["DevName"] = "DEV/DS_Test2V0-0-0"; --Name of the Data Store for Studio if UseStudioScope is true.
	["DevKey"] = "Dev_"; --Key of the Data Store for Studio, if UseStudioScope is true.
}

--scripts
local ServerScriptService = game:GetService("ServerScriptService")
local dataModule = ServerScriptService:FindFirstChild("DataSerializer") -- DataSerializer Module Script.
local DataSerializer = require(dataModule)

--players
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--set scope
if DataSettings.UseStudioScope then
	if RunService:IsStudio() then
		DataSettings.Name = DataSettings.DevName
		DataSettings.Key = DataSettings.DevKey
	end
end

local DataStore = DataSerializer:GetStore(DataSettings.Name)

--on entered
function onPlayerEntered(Player)
	local key = DataSettings.Key .. Player.UserId

	--player data
	local PlayerData = DataStore:Get(Player, key, {Player.UserId})

	if DataStore and DataSettings.AutoSave then
		local isGame = true
		local plrRemove = nil
		if DataSettings.SaveTime < 1 then
			DataSettings.SaveTime = 1
		end
		local saveTimer = DataSettings.SaveTime * 60

		plrRemove = Players.PlayerRemoving:Connect(function(plr)
			if plr == Player then
				isGame = false
			end
		end)

		while Player and isGame do
			task.wait(saveTimer)

			--update
			DataStore:Update(Player, key)
		end

		if plrRemove and plrRemove.Connected then
			plrRemove:Disconnect()
		end
	end
end

--on removing
function onPlayerRemoving(Player)
	local key = DataSettings.Key .. Player.UserId
	DataStore:CleanUpdate(Player, key)
end

for i, v in pairs(Players:GetPlayers()) do
	if v:IsA("Player") then
		local onEnter = coroutine.wrap(function()
			onPlayerEntered(v)
		end)
		onEnter()
	end
end

--events
Players.PlayerAdded:Connect(onPlayerEntered)
Players.PlayerRemoving:Connect(onPlayerRemoving)

game:BindToClose(function()
	print("Closing...")
	for i, v in pairs(Players:GetPlayers()) do
		if v:IsA("Player") then
			v:Kick()
		end
	end
	task.wait(3)
	print("Name:", DataSettings.Name)
end)
--[Made by Jozeni00]--
]]

local loadData = script:FindFirstChild("LoadData")
local saveData = script:FindFirstChild("SaveData")

local LoadModule = require(loadData)
local SaveModule = require(saveData)

local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local DataStoreService = game:GetService("DataStoreService")
local DataSerializer = {
	["DataStores"] = {};
	["FileName"] = "PlayerData"; -- new name of PresetPlayerData when it gets cloned to the Player. 
	["LoadedName"] = "DSLoaded"; -- name of attribute that fires on player when PlayerData is loaded
	["IsSavingName"] = "IsSaving"; -- name of attribute that fires on player when data is saving
	["RetryCount"] = 3; -- number of failed save attempts before cancelling
	["RetryDelay"] = 2; -- time (in seconds) between failed save attempts
	["DebugInfo"] = true; -- show aditional save details when a player saves data
}

--make folders
local DataTempFile = ReplicatedStorage:FindFirstChild("DataTempFile")
if not DataTempFile then
	DataTempFile = Instance.new("Folder")
	DataTempFile.Name = "DataTempFile"
	DataTempFile.Parent = ReplicatedStorage
end

local PresetPlayerData = ServerStorage:FindFirstChild("PresetPlayerData")
if not PresetPlayerData then
	PresetPlayerData = Instance.new("Folder")
	PresetPlayerData.Name = "PresetPlayerData"
	PresetPlayerData.Parent = ServerStorage
end

function DataSerializer:GetStore(name, options)
	if not name then
		name = ""
	end

	local DataStore = DataSerializer.DataStores[name]

	if not DataStore then
		DataSerializer.DataStores[name] = {}
		DataStore = DataSerializer.DataStores[name]

		local success, DataStoreResult = pcall(function()
			DataStore["GlobalDataStore"] = DataStoreService:GetDataStore(name, options)
			return DataStore["GlobalDataStore"]
		end)

		if not success then
			print(DataStoreResult)
		end

		--functions
		function DataStore:Get(plr, key, userids, dataOptions)
			--check for loaded data
			local PlayerData = nil
			if plr:GetAttribute(DataSerializer.LoadedName) then
				PlayerData = plr:FindFirstChild(plr:GetAttribute(DataSerializer.LoadedName))
			else
				PlayerData = PresetPlayerData:Clone()
				PlayerData.Name = DataSerializer.FileName
				PlayerData.Parent = plr

				for i, v in pairs(PlayerData:GetDescendants()) do
					if v:IsA("ObjectValue") then
						if v.Value then
							--clone object
							local newObject = v.Value:Clone()
							newObject.Parent = DataTempFile
	
							--set new value
							v.Value = newObject
						end
					end
				end
			end

			local GlobalDataStore = DataStore.GlobalDataStore
			local data = nil
			local keyInfo = nil

			if GlobalDataStore then

				for i = 0, DataSerializer.RetryCount do
					local success, DataResult, info = pcall(function()
						--get data
						local Data, keyInfo = GlobalDataStore:GetAsync(key)

						--set data
						if not Data then
							print(plr.Name .. " is a new player, creating new save...")

							Data = SaveModule:CompileDataTable(PlayerData)
							local versionId = GlobalDataStore:SetAsync(key, Data, userids, dataOptions)
							keyInfo = versionId
						end

						return Data, keyInfo
					end)

					if success then
						data = DataResult
						keyInfo = info

						LoadModule:Load(plr, PlayerData, DataResult)
						print(plr.Name .. " loaded in the experience.")
						break
					else
						if DataResult:match("Studio access to APIs is not allowed.") then
							print(plr.Name .. " loaded in without Data Store API access.")
							break
						else
							if i == DataSerializer.RetryCount then
								warn(DataResult)
								plr:Kick("Internal server error, please rejoin.")
								break
							end
						end
					end

					task.wait(DataSerializer.RetryDelay)
				end
			else
				print(plr.Name .. " loaded in offline mode.")
			end

			plr:SetAttribute(DataSerializer.LoadedName, DataSerializer.FileName)
			return PlayerData, data, keyInfo
		end

		function DataStore:Update(plr, key)
			local GlobalDataStore = DataStore.GlobalDataStore
			if GlobalDataStore and plr:GetAttribute(DataSerializer.LoadedName) and not plr:GetAttribute(DataSerializer.IsSavingName) then
				plr:SetAttribute(DataSerializer.IsSavingName, true)

				--player data
				local PlayerData = plr:FindFirstChild(DataSerializer.FileName)
				local serialize = SaveModule:CompileDataTable(PlayerData)

				local maxCache = 4000000 -- Max data is 4,000,000
				local dataCache = HttpService:JSONEncode(serialize)

				for i = 0, DataSerializer.RetryCount do

					--update data
					local success, result = pcall(function()
						GlobalDataStore:UpdateAsync(key, function(oldValue, keyInfo)
							local newValue = serialize or oldValue

							local userIDs = keyInfo:GetUserIds()
							local metadata = keyInfo:GetMetadata()
							return newValue, userIDs, metadata
						end)
					end)

					if not success then
						--if failed
						if i == DataSerializer.RetryCount then
							warn(result)
							break
						end
					else
						if DataSerializer.DebugInfo then
							--print results
							print(plr.Name .. " saved:")
							print(DataSerializer.FileName, serialize)
							print("Cache:", #dataCache .. " /" .. maxCache)
							if #dataCache > maxCache then
								warn("Cache exceeds limit, data may throttle.")
							end
							print("Key: " .. key)
						else
							print(plr.Name .. " successfully updated.")
						end
						break
					end

					task.wait(DataSerializer.RetryDelay)
				end

				--task.wait(6)
				plr:SetAttribute(DataSerializer.IsSavingName, false)
			end
		end

		--the final save
		function DataStore:CleanUpdate(plr, key)

			local timeToRemove = DataSerializer.RetryCount * DataSerializer.RetryDelay + 2

			if plr:GetAttribute(DataSerializer.LoadedName) then
				local PlayerData = plr:FindFirstChild(DataSerializer.FileName)

				for i, v in pairs(PlayerData:GetDescendants()) do
					if v:IsA("ObjectValue") then
						if v.Value then
							Debris:AddItem(v.Value, timeToRemove)
						end
					end
				end
			end

			DataStore:Update(plr, key)
		end

		--remove data
		function DataStore:Remove(key)
			local GlobalDataStore = DataStore.GlobalDataStore

			for i = 0, DataSerializer.RetryCount do

				--update data
				local success, result, keyInfo = pcall(function()
					local oldData, keyInfo =  GlobalDataStore:RemoveAsync(key)
					return oldData, keyInfo
				end)

				if not success then
					--if failed
					if i == DataSerializer.RetryCount then
						warn(result)
						return nil
					end
				else
					--print results
					print("Old Data:", result)
					print("Key: " .. key .. " was successfully removed.")
					return result, keyInfo
				end

				task.wait(DataSerializer.RetryDelay)
			end
		end
	end

	return DataStore
end

function DataSerializer:ListStores()
	local list = {}

	for i, v in pairs(DataSerializer.DataStores) do
		if v.GlobalDataStore then
			list[i] = v.GlobalDataStore
		end
	end

	return list
end

return DataSerializer
--[Made by Jozeni00]--
