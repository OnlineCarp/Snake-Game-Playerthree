--this module scripts control what happens whenever a player collides with another player or when they collect food
local CollectionServiceModule = {}

local RepStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local playerAnimations = require(RepStorage.ModuleScripts.CharacterAnimations)
local CharacterAttributes = require(RepStorage.ModuleScripts.CharacterAttributes)
local debounce, debounce2, debounce3 = false, false, false
local Players = game:GetService("Players")


local Food_Drop_Remote = RepStorage.Remotes.Trigger_Food_Drop
local Player_Dead_Remote = RepStorage.Remotes.Player_Dead
local Player_UI_Remote = RepStorage.Remotes:WaitForChild("Trigger_Player_UI")


local function TouchFood(part)
	part.Touched:Connect(function(hit)
		
		local playerDebounce = RepStorage.PlayerStats:FindFirstChild(hit.Parent.Name)
		if not playerDebounce then return end	
		
		if not playerDebounce:GetAttribute("HitFoodDebounce") then
			playerDebounce:SetAttribute("HitFoodDebounce", true)
			
			part.CanTouch = false
			
			local Type = part:GetAttribute("Type")
		
			
			local TweenInf = TweenInfo.new(
				0.3,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.Out,
				0,
				false
			)
			
			local Goal = {}
			Goal.Size = Vector3.new(0,0,0)
			local Anim = TweenService:Create(part, TweenInf, Goal)
			Anim:Play()
			wait(0.3)
			local playerName = hit.Parent.Name
			
				CharacterAttributes.AddLength(playerName, Type)
			
			
			part.Parent = RepStorage.Assets
			wait(0.2)
			playerDebounce:SetAttribute("HitFoodDebounce", false)
			CollectionServiceModule.TriggerCollection()
			
			
		else
		
		end
		
	end)
	
end




local function Invincible(playerName, bool)
	local playerCharacter = game.Workspace:FindFirstChild(playerName)
	for i, v in pairs(playerCharacter:GetChildren()) do
		if (v:isA("BasePart") or v:IsA("Part"))  then
			local check = v.Name:match("BodyPart")
			if not check then 
			
				v.CanTouch = not bool
			end		
		end	
	end	
end



local function DetectPowerUp(part)
	part.Touched:Connect(function(hit)
		local playerCharacter
		local playerDebounce = RepStorage.PlayerStats:FindFirstChild(hit.Parent.Name)
		if not playerDebounce then return end	
	
		if not playerDebounce:GetAttribute("PowerUpDebounce") then
			playerDebounce:SetAttribute("PowerUpDebounce", true)
		
					
			local player = game.Workspace:FindFirstChild(hit.Parent.Name)
			local PLAYER = Players:GetPlayerFromCharacter(player) --to invoke client to perform tween
					
			if player then
		
				local PowerUp = part:GetAttribute("PowerType")
				part:Destroy()
				local Humanoid = player:FindFirstChild("Humanoid")
				
				--------------------POWERUPS------------------------------------------------------
				if PowerUp == "Speed" then
				
					Humanoid.WalkSpeed = 30
					
					Player_UI_Remote:FireClient(PLAYER, "UISpeed")
					wait(15)
					Humanoid.WalkSpeed = 20
					
				elseif PowerUp == "Jump" then
					
					Humanoid.JumpHeight = 70
					Player_UI_Remote:FireClient(PLAYER, "UIJump")

					wait(15)
					Humanoid.JumpHeight = 0
					
				elseif PowerUp == "Immortal" then
				
					
					local ImmortalEmitter = RepStorage.Assets.InvincibleEmitter:Clone()
					local sound = RepStorage.Sounds.Invincible:Clone()
					sound.Parent = player.HumanoidRootPart
					ImmortalEmitter.Parent = player.HumanoidRootPart
					sound.Playing = true
					
					Humanoid.WalkSpeed = 30
					Invincible(player.Name, true)
					Player_UI_Remote:FireClient(PLAYER, "UIImmortal")
					
					wait(15)
					Invincible(player.Name, false)
					sound:Destroy()
					ImmortalEmitter:Destroy()
					Humanoid.WalkSpeed = 20
				end
				
			
			else
				
				print("player not found")
				
			end
			
			wait(1)
			playerDebounce:SetAttribute("PowerUpDebounce", false)
			
		
		end
		
	end)
	
end





function CollectionServiceModule.TriggerCollection()
	for i,v in pairs(CollectionService:GetTagged("Food")) do
		TouchFood(v)
		debounce = false
	end
	
	for i, y in pairs(CollectionService:GetTagged("PowerUp"))  do
		DetectPowerUp(y)
	end
end





Food_Drop_Remote.Event:Connect(function()   --decrepeted 
	
	CollectionServiceModule.TriggerCollection()
	
	
end)





return CollectionServiceModule

