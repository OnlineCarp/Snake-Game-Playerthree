--this module script controls anything that happens to the player on the server side
local CharacterAttributes = {}

local RepStorage = game:GetService("ReplicatedStorage")
local PlayerStats = RepStorage.PlayerStats
local Players = game:GetService("Players")

local Player_Dead_Remote = RepStorage.Remotes.Player_Dead
local Player_UI_Remote = RepStorage.Remotes.Trigger_Player_UI

Player_Dead_Remote.Event:Connect(function(playerName)
	
	print("Event received")
	CharacterAttributes.LeaveBehindFood(playerName)
	
end)




function CharacterAttributes.SetInitialLength(playerName)
	
	local PlayerCharacter = game.Workspace:FindFirstChild(playerName)
	local HumanoidRootPart = PlayerCharacter:FindFirstChild("HumanoidRootPart")
	
	
	local FirstPart = RepStorage.Assets:FindFirstChild("BodyPart1"):Clone()

	FirstPart.Parent = PlayerCharacter; FirstPart.Anchored = false --prevent player from being stationary
	
	FirstPart.CFrame = HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0,0,3))
	
	local Weld = Instance.new("WeldConstraint", HumanoidRootPart)
	Weld.Part0 = HumanoidRootPart
	Weld.Part1 = FirstPart
	
	
end

function CharacterAttributes.AddLength(playerName, Type)
	
	local PlayerCharacter = game.Workspace:FindFirstChild(playerName)
	if not PlayerCharacter then return end 
	local Current_Length = RepStorage.PlayerStats:FindFirstChild(playerName)
	if not Current_Length then return end
	local First_Part = PlayerCharacter:FindFirstChild("BodyPart"..tostring(Current_Length.Value))
	if not First_Part then return end
	local Player = game:GetService("Players"):GetPlayerFromCharacter(PlayerCharacter)
	
	
	local EndLoop
	if Type == "Small" then
		EndLoop = 1
	elseif Type == "Medium" then
		EndLoop = 2
	else
		EndLoop = 5
	end
	
	
	
	for i = 1, EndLoop do
		Current_Length.Value += 1
		local NewPart = RepStorage.Assets:FindFirstChild("BodyPart1"):Clone()
		local offset = -5 
		NewPart.Anchored = true
		NewPart.Name = "BodyPart"..tostring(Current_Length.Value)
		NewPart.Parent = PlayerCharacter
		
		if Current_Length == 2 then
			offset = -1
		end
		NewPart.CFrame = First_Part.CFrame:ToWorldSpace(CFrame.new(0,0,offset)) -- initialises offset
		NewPart.CFrame = CFrame.lookAt(NewPart.Position, PlayerCharacter.HumanoidRootPart.Position)
		Player.leaderstats.length.Value += 1
	end
	
	local CurrentSkin = Current_Length:GetAttribute("CurrentSkin")
	CharacterAttributes.SkinChange(playerName, CurrentSkin)
	
end


function CharacterAttributes.RemovePlayerVals(playerName)
	
	wait()
	print(playerName)
	local player = game:GetService("Players"):GetPlayerFromCharacter(game.Workspace:FindFirstChild(playerName))
	if player then
		if player:FindFirstChild("leaderstats") then
			print("leaderstats found")
			player.leaderstats:Destroy()
		else
			print("leaderstats not found")
		end
	else
		print("PLAYER AIN TOUFND")
	end
	local Statistics = RepStorage.PlayerStats
	
	for i,v in pairs(Statistics:GetChildren()) do
		
		if v.Name:match(playerName) then
			v:Destroy()
			return true
		end
		
	end
	
	return false
end


function CharacterAttributes.CheckHeadOnCollision(player1, player2)
	
	local player = {}
	local PlayerStatistics = RepStorage.PlayerStats
	
	local p1Humanoid = game.Workspace:FindFirstChild(player1):FindFirstChild("Humanoid")
	local p2Humanoid = game.Workspace:FindFirstChild(player2):FindFirstChild("Humanoid")
	
	player[1] = PlayerStatistics:FindFirstChild(player1).Value
	player[2] = PlayerStatistics:FindFirstChild(player2).Value
	
	local Player_Dead 
	
	if player[1] > player[2] then
		--kill player 2
		p2Humanoid.Health = 0
		Player_Dead = player2

	elseif player[1] < player[2] then
		--kill player1
		p1Humanoid.Health = 0
		Player_Dead = player1
	else
		--kill both since both are same lengths
		p1Humanoid.Health = 0
		p2Humanoid.Health = 0
	
	end
	

	
end

function CharacterAttributes.AddHeadOnCollisionPart(playerName)
	
	local playerCharacter = game.Workspace:FindFirstChild(playerName)
	local CollisionPart = RepStorage.Assets.HeadCollision:Clone()
	local Offset = CFrame.new(0,0,-1.7)
	
	CollisionPart.Parent = playerCharacter
	CollisionPart.CFrame = playerCharacter.HumanoidRootPart.CFrame:ToWorldSpace(Offset)
	
	
	local Weld = Instance.new("WeldConstraint", playerCharacter.HumanoidRootPart)
	Weld.Part0 = playerCharacter.HumanoidRootPart
    Weld.Part1 = CollisionPart	
	
end


function CharacterAttributes.LeaveBehindFood(playerName)
	--this function spawns in food when a player dies
	--no. of food = length of snake
	
		

		local playerLength = RepStorage.PlayerStats:FindFirstChild(playerName).Value
	
		local playerCharacter = game.Workspace:FindFirstChild(playerName)



		local Trigger_Food_Drop_Remote = RepStorage.Remotes.Trigger_Food_Drop
		
		
		for i = 1, playerLength do
		
		print("RUNNING")
			local Food = RepStorage.Assets.Food:Clone()
			Food:SetAttribute("Type", "Small")
			Food.Size =  Vector3.new(5,5,5)
			Food.Color = Color3.new(0.915587, 0.890333, 0.875059)

		
			playerCharacter["BodyPart"..i]:Destroy() --removes player snake model for space
		wait(1)
		
		Food.Parent = game.Workspace
		Food.Position = playerCharacter["BodyPart"..i].Position + Vector3.new(5,0,0)
		Trigger_Food_Drop_Remote:Fire()
		
		end

end

function CharacterAttributes.SkinChange(playerName, choice)
	
--	print("Choice is ".. choice)
	
	local TableOfSkin = {
		
		["Default"] = "rbxassetid://10362828",
		["Dark"] = "rbxassetid://6875611485",
		["Rock"] = "rbxassetid://8674027232",
		["Fire"] = {"rbxassetid://8694485972",
			         RepStorage.Assets.ParticleEffects.Fire
		},
		["Ice"] = {"rbxassetid://7359385507",
			        RepStorage.Assets.ParticleEffects.Ice
		},
		["Skull"] = {"",
			         RepStorage.Assets.ParticleEffects.Skull
		}
	}
	
	--print("LENGTH OF FIRE IS ".. tostring(#TableOfSkin["Fire"]))
	
	local playerCharacter = game.Workspace:FindFirstChild(playerName)
	if playerCharacter then
		
		for i, v in pairs(playerCharacter:GetChildren()) do
			
			local NameOfPart = v.Name:match("BodyPart")
			if NameOfPart ~= nil then
				for x,y in pairs(v:GetChildren()) do
					if y:IsA("ParticleEmitter") then
						y:Destroy()
					end
					if y:IsA("Decal")  then
						
						if #TableOfSkin[choice] == 2 then
							y.Texture = TableOfSkin[choice][1]
							for w, _ in pairs(TableOfSkin[choice][2]:GetChildren()) do
								local Emitter = _:Clone()
								Emitter.Parent = v

							end
						else
							y.Texture = TableOfSkin[choice]
						end

					end
					
					
				end
			end
			
			
		end
	
	end	
	
	local playerVal = RepStorage.PlayerStats:FindFirstChild(playerName)
	if playerVal then
		playerVal:SetAttribute("CurrentSkin", choice)
	end
end


function CharacterAttributes.SetSkinAttributeAfterPurchase(playerName, Skin)
	
	local playerVal = RepStorage.PlayerStats:FindFirstChild(playerName)
	if playerVal then
		
		playerVal:SetAttribute(Skin, true)

	end
	
end

function CharacterAttributes.KillConfirmed(playerName, Length)
	
	local Local_Player = game:GetService("Players"):GetPlayerFromCharacter(game.Workspace:FindFirstChild(playerName))
	local final_money = (Length * 5) + 10
	Player_UI_Remote:FireClient(Local_Player, "Money"..tostring(final_money))
	Local_Player.leaderstats.cash.Value += final_money
	
	
end



return CharacterAttributes

