# JozeniDS 2.0
Data serializer created using Roblox Studio. The goal is to save everything under a single folder. Version 2.0 is aimed for hardcore games that rely on objects with matching names.

# Saving Features
- Object attributes.
- All insertable objects from Roblox Studio's Insert Object widget. Everything, including scripts and meshparts, not kidding.
- Ability to manipulate data with ease, especially if using a DataStore editor plugin.
- Auto saving, but is not recommended because of DataStore throttling (may cause data losses).
- Offline data testing supported.
- Studio-only DataStore Scope support.

# Use case examples
Unique to 2.0:
- Inventory systems; where the player has multiple swords named "Steel Sword", but have different configurations or stats/attributes.

General unique purposes:
- A player building a custom house at any position of the workspace. 
- The player creating and selling their in-game custom weapon to the game's marketplace feature for other players to purchase and keep.

# Installation
1. Get the model here: https://www.roblox.com/library/9229642410/Jozeni-Data-Serializer-2-0
2. Insert the script in ServerScriptService.

# Instructions
For setting up player data.

1. Insert a folder named "PresetPlayerData" in ServerStorage. Insert as many objects as prefered under the folder, set their attributes and go crazy with it. During gameplay, this folder will be renamed to the folder name you set in the script. By default, the folder is renamed to "PlayerData" because it is in the settings of the script, so use `ServerStorage:WaitForChild("PlayerData")` in scripts. For the player's data, use `Player:WaitForChild("PlayerData")`.
* However, for best results, this code sample will wait for the Player's data to be loaded, and it provides an attribute with the name of the folder:
```
-- check if DataStoreLoaded is an attribute of Player.
if not Player:GetAttribute("DataStoreLoaded") then
	Player:GetAttributeChangedSignal("DataStoreLoaded"):Wait() -- waits for data to be loaded, returns string "PlayerData".
end

--Player data
local PlayerData = Player:WaitForChild(Player:GetAttribute("DataStoreLoaded")) -- returns folder named "PlayerData".
```
2. After finished changing up PresetPlayerData, copy and paste this code into the command bar:
```
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local PresetPlayerData = ServerStorage:FindFirstChild("PresetPlayerData")

if not PresetPlayerData then
	PresetPlayerData = Instance.new("Folder")
	PresetPlayerData.Name = "PresetPlayerData"
	PresetPlayerData.Parent = ServerStorage
end

local function setUniqueId(object)
	local aName = "DataUniqueKeyId"
	if not object:GetAttribute(aName) then
		object:SetAttribute(aName, HttpService:GenerateGUID(false))
	end
end

setUniqueId(PresetPlayerData)
for i, v in pairs(PresetPlayerData:GetDescendants()) do
	setUniqueId(v)
end
```
3. To live test DataStores, be sure to enable Studio API Services.
4. Change up the player's PlayerData in-game, then rejoin to see if it saved.
5. If later you feel like removing unique identifiers (GUID or UUID), copy and paste this code into the command bar in Studio:
```
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
```

# Limitations
- Adding new instances to PresetPlayerData will require you to copy code and paste into the command bar in Roblox Studio. This is because Roblox does not allow developers readable access to Instance's unique identifiers, as of April 2022. 
- If you copy-paste instances with an existing GUID attribute under PresetPlayerData, then you must enter the commands to remove and re-add the GUID attributes.
- For objects containing references (i.e. Beam.Attachment0, BillboardGui.Adornee, WeldConstraint.Part1, etc.), it is recommended to utilize unique naming schemes for better results.
- To save a script, a copy of it with the same name and sourceId must be present within ServerStorage.
- To save a MeshPart or SurfaceAppearance, a copy of it must be present within ServerStorage.
- Deprecated objects are not fully supported, but there may be some that are superseded carrying the same type. (i.e. Hat is superseded by Accessory, both are Accoutrements.)

# Repositories
JozeniDS Legacy: https://github.com/DragencryptedSE/JozeniDS-Legacy
