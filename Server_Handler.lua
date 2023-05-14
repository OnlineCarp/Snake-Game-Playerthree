

--SERVER SCRIPT

local DataStoreService = game:GetService("DataStoreService")
local myDataStore = DataStoreService:GetDataStore("myDataStore")
local RepStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local debounce = false
local LengthOfPlayer
local CharacterAttributes = require(RepStorage.ModuleScripts.CharacterAttributes)


--dictionary which contains attributes of possible skins that player can own
local SkinStatistics = {
	
	Dark = {
		Price = 1500,
		MaxLength = "N/A"
	},
	Fire = {
		Price = 3200,
		MaxLength = "N/A"
	},
	Ice = {
		Price = 3600,
		MaxLength = "N/A"
	},
	Rock = {
		Price = 7500,
		MaxLength = "N/A"
	},
	Skull = {
		Price = 5000,
		MaxLength = "N/A"
	}
	
	
	
}





local function UpdateData(playerName) --function which saves the player's stats
	local player = game:GetService("Players"):GetPlayerFromCharacter(game.Workspace:FindFirstChild(playerName))
	local PlayerTable = {
		["money"] = player.leaderstats.cash.Value,
		
		Skins = {
			["Default"] = true,
			["Dark"] = RepStorage.PlayerStats[playerName]:GetAttribute("DarkSkin"),
			["Rock"] = RepStorage.PlayerStats[playerName]:GetAttribute("RockSkin"),
			["Fire"] = RepStorage.PlayerStats[playerName]:GetAttribute("FireSkin"),
			["Ice"] = RepStorage.PlayerStats[playerName]:GetAttribute("IceSkin"),
			["Skull"] = RepStorage.PlayerStats[playerName]:GetAttribute("SkullSkin")
		}

	}
	
	local success, errormessage = pcall(function()
		myDataStore:SetAsync(player.UserId.."-user", {PlayerTable})

	end)
	if success then
		warn("Updated player stats")
	else
		warn("FAIL TO UPDATAE PLAYER STATS AFTER DEATH")
	end

end



		

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(Character)

		CharacterAttributes.RemovePlayerVals(player.Name)
		
		print("player joined is ".. player.Name)
		
	
		
	  
		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
		
		local length = Instance.new("IntValue")
		length.Name = "length"
		length.Parent = leaderstats
		
		local cash = Instance.new("IntValue")
		cash.Name = "cash"
		cash.Parent = leaderstats
		
		LengthOfPlayer = Instance.new("IntValue", RepStorage.PlayerStats)
		LengthOfPlayer.Name = tostring(player.Name)
		
		
		--intializers---------------------------------
		LengthOfPlayer:SetAttribute("Default", false)
		LengthOfPlayer:SetAttribute("DarkSkin", false)
		LengthOfPlayer:SetAttribute("RockSkin", false)
		LengthOfPlayer:SetAttribute("FireSkin", false)
		LengthOfPlayer:SetAttribute("IceSkin", false)
		LengthOfPlayer:SetAttribute("SkullSkin", false)
		--------------------------------------------
		
		local data
        local success, errormessage = pcall(function()
		data = myDataStore:GetAsync(player.UserId.."-user")		
		end)
		
		print(data)
		
		
		
      if success then 
			--TableOfStats = HttpService:JSONDecode(data)
			
			if data ~= nil  then
			
				player.leaderstats.cash.Value = data[1]["money"]
				
				local counter = 1
				local temp_table = {}
				
				table.insert(temp_table, data[1]["Skins"]) 
				
				print(temp_table[1])
		
				for i,v in pairs(temp_table[1]) do   
					if v == true then
						if i ~= "Default" then
						 LengthOfPlayer:SetAttribute(i.."Skin", v)
						end
					end
					counter += 1
					
				end
				 
			  else
				
				warn("it is nil")
			end

			
	else
		warn("DATA COULD NOT BE LOADED IN")
  end

		--intializes

	

		LengthOfPlayer.Value = 1 --initial length of player (excluding HumanoidRootPart and Head)
		LengthOfPlayer:SetAttribute("CurrentSkin", "Default")
		LengthOfPlayer:SetAttribute("PowerUpDebounce", false)
		LengthOfPlayer:SetAttribute("HitSnakeDebounce", false)
		LengthOfPlayer:SetAttribute("HitFoodDebounce", false)
	
	
		player.leaderstats.cash.Value += 1
		
		wait()

		
		local PlayerCharacter = game.Workspace:FindFirstChild(player.Name)
		
		if PlayerCharacter then
			PlayerCharacter.Humanoid.JumpHeight = 0
			PlayerCharacter.Humanoid.WalkSpeed = 20
			
		else  
			print("player not found to initialise stats")
		end
	
	
		wait()
		
		player.leaderstats.length.Value = 1
	 
		CharacterAttributes.AddHeadOnCollisionPart(player.Name)
		
		wait()
	
		local CharacterAnimations = require(RepStorage.ModuleScripts.CharacterAnimations)
		CharacterAttributes.SetInitialLength(player.Name)

		wait(1)
	
		local PlayerCharacter = game.Workspace:FindFirstChild(player.Name)
		
		-----------------------------------------------------------------------------
		
		Character:WaitForChild("Humanoid").Died:Connect(function()
			print(player.Name .. " has died")
			
			UpdateData(player.Name)
			
		end)
		
		
		----------------SECTION BELOW CONTROLS CLIENT-SERVER INTERACTIONS-------------------------------------
		
		
		local Save_Remote = RepStorage.Remotes.Temporary_Save
		
		Save_Remote.OnServerInvoke = function(player)
			UpdateData(player.Name)
		end
		
		
		local Shop_Remote = RepStorage.Remotes.Shop_Remote
		
		Shop_Remote.OnServerInvoke = function(player, choice)
			print("Remote received")
			CharacterAttributes.SkinChange(player.Name, choice)
			
		end
		
		
		local Purchase_Remote = RepStorage.Remotes.Purchase_Remote
		
		Purchase_Remote.OnServerInvoke = function(player, choice)
			
			
			local price = SkinStatistics[choice]["Price"]
			player.leaderstats.cash.Value -= price
			CharacterAttributes.SetSkinAttributeAfterPurchase(player.Name, choice.."Skin")
			UpdateData()
			
			
		local TO_DELETE = RepStorage.Remotes.TO_BE_DELETED
		TO_DELETE.OnServerInvoke = function(player)
			
			RepStorage.PlayerStats[player.Name]:SetAttribute("DarkSkin", false)
			RepStorage.PlayerStats[player.Name]:SetAttribute("RockSkin", false)
			RepStorage.PlayerStats[player.Name]:SetAttribute("FireSkin", false)
			
		end
			
	
		end
		------------------------------------------------------------------------------------------------------------
	end)
	
end)



game.Players.PlayerRemoving:Connect(function(player)  --saves the player data if they leave the server
	
	local success, errormessage = pcall(function()
		UpdateData(player.Name)
		CharacterAttributes.RemovePlayerVals(player.Name) --reset the player stats
		
	end)
	if success then
		print("SAVED DATA")
	else
		warn("DATA COULDNT BE SAVAED")
	end

	
end)
