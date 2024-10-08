--edited by noob
--How to use:
--[[
	The 'materials' library is all the terrain materials this script supports.
	['Rock']=Enum.Material.Rock means when you name a part 'Rock', Rock terrain will
	be generated on the part. Hence the same with all the other materials.

	deletePartsOnGeneration means when the terrain fills the block it will delete the
	part when set to true and do nothing when set to false.

	For this script to work, you'll need to place this script inside of you map model.
--]]
local terrain=workspace.Terrain
local deletePartsOnGeneration=true

local materials={
	['Rock']=Enum.Material.Rock,
	['Sand']=Enum.Material.Sand,
	['Grass']=Enum.Material.Grass,
	['Water']=Enum.Material.Water,
	['Ground']=Enum.Material.Ground,
	['Sandstone']=Enum.Material.Sandstone,
	['Slate']=Enum.Material.Slate,
	['Snow']=Enum.Material.Snow,
	['Mud']=Enum.Material.Mud,
	['Brick']=Enum.Material.Brick,
	['Concrete']=Enum.Material.Concrete,
	['Glacier']=Enum.Material.Glacier,
	['Planks']=Enum.Material.WoodPlanks,
	['Lava']=Enum.Material.CrackedLava,
	['Basalt']=Enum.Material.Basalt,
	['Ice']=Enum.Material.Ice,
	['Salt']=Enum.Material.Salt,
	['Cobblestone']=Enum.Material.Cobblestone,
	['Limestone']=Enum.Material.Limestone,
	['Asphalt']=Enum.Material.Asphalt,
	['Leafy Grass']=Enum.Material.LeafyGrass,
	['Pavement']=Enum.Material.Pavement,
}

function goThrough(a)
	for i,v in a:GetChildren() do
		if v:IsA("BasePart") then
			local enum=materials[v.Name]
			if enum then
				if v.Shape==Enum.PartType.Block then
					terrain:FillBlock(v.CFrame,v.Size,enum)
				elseif v.Shape==Enum.PartType.Ball then
					terrain:FillBall(v.CFrame.p,v.Size.X,enum)
				end
				if deletePartsOnGeneration==true then
					v:Destroy()
				end
			end
		end
		goThrough(v)
	end
end
goThrough(script.Parent)

terrain.WaterReflectance = 0.2
terrain.WaterTransparency = 1
terrain.WaterColor = Color3.fromRGB(92, 82, 71)
