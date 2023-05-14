
wait()
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local OFFSET = 3
local Character_Attributes = require(RepStorage.ModuleScripts.CharacterAttributes)
local Global_Length
wait(2)


local function Check_Collision(playerName, current_part_no)
	

	local playerCharacter = game.Workspace:FindFirstChild(playerName)
	if not playerCharacter then return end
	
	for i, v in pairs(game:GetService("Players"):GetChildren()) do
		if v.Name ~= playerName then
			--check distance of player relative to current part's position
			local BodyPos = playerCharacter["BodyPart"..current_part_no].Position
			local EnemyChar = game.Workspace:FindFirstChild(v.Name)
			if not EnemyChar then return end
			local Humanoid = EnemyChar:FindFirstChild("Humanoid")
			local HrpPos = EnemyChar:FindFirstChild("HumanoidRootPart").Position
			
			local Distance = (HrpPos - BodyPos).Magnitude
			if Distance <= 2 then
				Humanoid.Health = 0
				Character_Attributes.KillConfirmed(playerName, Global_Length )
			end
			
			
			
		end
	end
	--coroutine.yield()
	

end




local function Move_Body(playerName)
	
	local Current_Length = RepStorage.PlayerStats[playerName].Value
	if not Current_Length then return end
	local playerCharacter = game.Workspace:FindFirstChild(playerName)
	if not playerCharacter then return end
	Global_Length = Current_Length
	
	if playerCharacter and Current_Length ~= 1 then
		
		for i = 2, Current_Length  do
			
			if i == 2 then
				OFFSET = 1
			else
				OFFSET = 3
			end
			
			local Body_Part = playerCharacter["BodyPart"..i]
			local Target_Part = playerCharacter["BodyPart".. i -1 ]
		
			
			local Distance = Body_Part.Position - Target_Part.Position --get distance between two points
		
			local Final_Pos = Target_Part.Position + (Distance.Unit * OFFSET)
		
		    Body_Part:PivotTo(CFrame.lookAt(Final_Pos, Target_Part.Position))
			
			
		    Check_Collision(playerName, i)
			
			
			
			
		end
	end
	
	
	
end

local player = script.Parent.Name

RunService.Stepped:Connect(function()
	Move_Body(player)
end)




