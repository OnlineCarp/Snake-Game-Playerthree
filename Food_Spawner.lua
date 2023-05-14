--Each food contains an attribute called 'size': Small, Medium, Large
--Small = 1 block
--Medium = 2 blocks
--Large = 5 blocks
local RepStorage = game:GetService("ReplicatedStorage")
local AssetFolder = RepStorage.Assets
local CollectionService = require(RepStorage.ModuleScripts.CollectionServiceModule)
local IsSpawned = false
local FoodCounter = 0

local FoodDetails = {
	
	Size = {
		
		["Small"] = Vector3.new(5,5,5),
		["Medium"] = Vector3.new(7,7,7),
        ["Large"] = Vector3.new(8.5,8.5,8.5)
	},
	
	Colour = {
		["Small"] = Color3.new(0.915587, 0.890333, 0.875059),
		["Medium"] = Color3.new(0, 0.739651, 1),
		["Large"] = Color3.new(0.85597, 0, 1)
	}

}


local PowerUpDetails = {
	
	
	Type = {
		
		[1] = "Speed",
		[2] = "Jump",
		[3] = "Immortal"
		
	}
	
	
}



local function Check_No_Of_Food()
	FoodCounter = 0
	
	for i,v in pairs(game.Workspace:GetChildren()) do
		if v.Name:match("Food") then
			FoodCounter += 1
			print(FoodCounter)
		end
	end
	
	
	if FoodCounter >= 100 then
		
		return true
	else
		return false
	end
	
end



local function Set_Food(Type)
	
	IsSpawned = true
	local Food = AssetFolder.Food:Clone()
	Food.Size = FoodDetails.Size[Type]
	Food.Color = FoodDetails.Colour[Type]
	Food.Parent = game.Workspace
	Food.Position = Vector3.new(math.random(-460,81), 3, math.random(-290,343))
	Food.Name = "Temp_Item"
	Food.CanCollide = false
	
	Food:SetAttribute("Type", Type)
	
	--check the distance this part relative to the others. If it's less than 10 studs then it can't be placed
	
	for i,v in pairs(game.Workspace:GetChildren()) do
		
		local name = v.Name:match("Food")
		if name ~= nil then
			
			local Temp_Distance = (Food.Position - v.Position).Magnitude
			if Temp_Distance <= 13.5 then
				Food:Destroy()
				Set_Food(Type)
				break
			end
			
		end
		
	end
	
	Food.Name = "Food"
	
	if IsSpawned then
		CollectionService.TriggerCollection()
	end

end

local function Set_PowerUp()
	
	local PowerUp = RepStorage.Assets.PowerUp:Clone()
	
	local Num = math.random(1,3) --temporary
	
	PowerUp:SetAttribute("PowerType", PowerUpDetails.Type[Num])
	
	PowerUp.Parent = game.Workspace
	PowerUp.CanCollide = false
	PowerUp.Position = Vector3.new(math.random(-200,300), 3, math.random(-300,300))
	
	
	CollectionService.TriggerCollection()
	
	
end


while true do
	hen
		local Ran_Num = math.random(1,5)
		if Ran_Num <=2 then
			Set_Food("Small")
		elseif Ran_Num ==3 or Ran_Num == 4 then
			Set_Food("Medium")
		else
			Set_Food("Large")
		end
	
	
	local Ran_Num_2 = math.random(1,2)
	if Ran_Num_2 == 1 then
		
	   Set_PowerUp()
	end
	
	
	wait(1.5)
end
