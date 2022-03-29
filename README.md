# JozeniDS 2.0
Data serializer created using Roblox Studio. The goal is to save everything under a single folder. Version 2.0 is aimed for hardcore games that rely on objects with matching names.

# Saving Features
- Object attributes.
- All insertable objects from Roblox Studio's Insert Object widget. Everything, including scripts and meshparts, not kidding.
- Ability to manipulate data with ease, especially if using a DataStore editor plugin.
- Auto saving.

# Use case examples
Unique to 2.0:
- Inventory systems; where the player has multiple swords named "Steel Sword", but have different configurations or stats/attributes.

General unique purposes:
- A player building a custom house at any position of the workspace. 
- The player creating and selling their in-game custom weapon to the game's marketplace feature for other players to purchase and keep.

# Instructions
For setting up player data.

1. Insert a folder named "PresetPlayerData" in ServerStorage. Insert as many objects as prefered under the folder, set their attributes and go crazy with it. During gameplay, this folder will be renamed to the "Scope" you set in the script. By default, the folder is renamed to "PlayerData" because it is the name of the DataStore's scope, so use `ServerStorage:WaitForChild("PlayerData")` in scripts. For the player's data, use `Player:WaitForChild("PlayerData")`.
2. To live test DataStores, be sure to enable Studio API Services.
3. Change up the player's PlayerData in-game, then rejoin to see if it saved.

# Limitations
- Updating PresetPlayerData will not update old saves, but it will for fresh-new saves. (If you are in need of this functionality, it is recommended to use the JozeniDS Legacy version instead.)
- For objects containing references (i.e. Beam.Attachment0, BillboardGui.Adornee, WeldConstraint.Part1, etc.), it is recommended to utilize unique naming schemes for better results.
- To save a script, a copy of it with the same name and sourceId must be present within ServerStorage.
- To save a MeshPart or SurfaceAppearance, a copy of it must be present within ServerStorage.
- Deprecated objects are not fully supported, but there may be some that are superseded carrying the same type. (i.e. Hat is superseded by Accessory, both are Accoutrements.)

# Repositories
JozeniDS Legacy: https://github.com/DragencryptedSE/JozeniDS-Legacy
