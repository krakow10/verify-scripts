--print('LightingChanger localscript start')

local mapName = script:WaitForChild("MapName").Value
local mapModel = workspace:WaitForChild(mapName)
local lighting = game:GetService("Lighting")
local CC = lighting:WaitForChild("ColorCorrection")
local sky = lighting:WaitForChild("Sky")
local terrain = workspace.Terrain

local defaultCC = script:WaitForChild("DefaultColorCorrectionValues")
local defaultLighting = script:WaitForChild("DefaultLightingValues")
local defaultSky = script:WaitForChild("DefaultSkyValues")
local defaultTerrain = script:WaitForChild("DefaultTerrainValues")

--reset lighting settings when the map is removed/rtv'd
--(Yes this logic is still re qui red even though we fixed the putting it in backpack thing cause otherwise it persists for 1 map change)
--                         ^^^^^^^^^^ L map tool
script.Parent = workspace
mapModel.Destroying:Connect(function()
	--print("Map deleted, destroying PlayerScript")
	--without setting lighting back to default sometimes custom lighting set by other maps will get overridden by this script
	lighting.Ambient = Color3.fromRGB(0,0,0)
	lighting.Brightness = 1
	lighting.ColorShift_Bottom = Color3.fromRGB(0,0,0)
	lighting.ColorShift_Top = Color3.fromRGB(0,0,0)
	lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	lighting.ClockTime = 14
	lighting.GeographicLatitude = 41.733
	lighting.FogColor = Color3.fromRGB(192,192,192)
	lighting.FogEnd = 100000
	lighting.FogStart = 0
	terrain.WaterWaveSize = 10
	terrain.WaterColor = Color3.fromRGB(12, 84, 92)
	terrain.WaterReflectance = 1
	terrain.WaterTransparency = 0.3
	terrain.WaterWaveSize = 0.15
	terrain.WaterWaveSpeed = 10
	script:Destroy()
end)

local function search(valuesTable, name) 
	for _, value in pairs(valuesTable) do
		if value.Name == name then
			return value
		end
	end
end

--try to change CC/lighting/sky values to those included in the table otherwise use default values
--if passed an empty table this will set everything to the default values
local function changeCC(valuesTable)
	local Brightness = search(valuesTable, "Brightness") or defaultCC.Brightness
	local Contrast = search(valuesTable, "Contrast") or defaultCC.Contrast
	local Saturation = search(valuesTable, "Saturation") or defaultCC.Saturation
	local TintColor = search(valuesTable, "TintColor") or defaultCC.TintColor
	CC.Brightness = Brightness.Value
	CC.Contrast = Contrast.Value
	CC.Saturation = Saturation.Value
	CC.TintColor = TintColor.Value
end

local function changeLighting(valuesTable)
	local Ambient = search(valuesTable, "Ambient") or defaultLighting.Ambient
	local Brightness = search(valuesTable, "Brightness") or defaultLighting.Brightness
	local ClockTime = search(valuesTable, "ClockTime") or defaultLighting.ClockTime
	local ColorShift_Top = search(valuesTable, "ColorShift_Top") or defaultLighting.ColorShift_Top
	local ColorShift_Bottom = search(valuesTable, "ColorShift_Bottom") or defaultLighting.ColorShift_Bottom
	local FogColor = search(valuesTable, "FogColor") or defaultLighting.FogColor
	local FogEnd = search(valuesTable, "FogEnd") or defaultLighting.FogEnd
	local FogStart = search(valuesTable, "FogStart") or defaultLighting.FogStart
	local GeographicLatitude = search(valuesTable, "GeographicLatitude") or defaultLighting.GeographicLatitude
	local OutdoorAmbient = search(valuesTable, "OutdoorAmbient") or defaultLighting.OutdoorAmbient
	lighting.Ambient = Ambient.Value
	lighting.Brightness = Brightness.Value
	lighting.ClockTime = ClockTime.Value
	lighting.ColorShift_Top = ColorShift_Top.Value
	lighting.ColorShift_Bottom = ColorShift_Bottom.Value
	lighting.FogColor = FogColor.Value
	lighting.FogEnd = FogEnd.Value
	lighting.FogStart = FogStart.Value
	lighting.GeographicLatitude = GeographicLatitude.Value
	lighting.OutdoorAmbient = OutdoorAmbient.Value
end

local function changeSky(valuesTable)
	local CelestialBodiesShown = search(valuesTable, "CelestialBodiesShown") or defaultSky.CelestialBodiesShown
	local SkyboxBk = search(valuesTable, "SkyboxBk") or defaultSky.SkyboxBk
	local SkyboxDn = search(valuesTable, "SkyboxDn") or defaultSky.SkyboxDn
	local SkyboxFt = search(valuesTable, "SkyboxFt") or defaultSky.SkyboxFt
	local SkyboxLf = search(valuesTable, "SkyboxLf") or defaultSky.SkyboxLf
	local SkyboxRt = search(valuesTable, "SkyboxRt") or defaultSky.SkyboxRt
	local SkyboxUp = search(valuesTable, "SkyboxUp") or defaultSky.SkyboxUp
	sky.CelestialBodiesShown = CelestialBodiesShown.Value
	sky.SkyboxBk = SkyboxBk.Value
	sky.SkyboxDn = SkyboxDn.Value
	sky.SkyboxFt = SkyboxFt.Value
	sky.SkyboxLf = SkyboxLf.Value
	sky.SkyboxRt = SkyboxRt.Value
	sky.SkyboxUp = SkyboxUp.Value
end

local function changeTerrain(valuesTable)
	local WaterColor = search(valuesTable, "WaterColor") or defaultTerrain.WaterColor
	local WaterReflectance = search(valuesTable, "WaterReflectance") or defaultTerrain.WaterReflectance
	local WaterTransparency = search(valuesTable, "WaterTransparency") or defaultTerrain.WaterTransparency
	local WaterWaveSize = search(valuesTable, "WaterWaveSize") or defaultTerrain.WaterWaveSize
	local WaterWaveSpeed = search(valuesTable, "WaterWaveSpeed") or defaultTerrain.WaterWaveSpeed
	terrain.WaterColor = WaterColor.Value
	terrain.WaterReflectance = WaterReflectance.Value
	terrain.WaterTransparency = WaterTransparency.Value
	terrain.WaterWaveSize = WaterWaveSize.Value
	terrain.WaterWaveSpeed = WaterWaveSpeed.Value
end

local camera = workspace.CurrentCamera
local rayHeight = 500
local empty = {} --for default values
--to improve performance, store if the default values have already been set
--if true, then don't run the function relating to that set of values
local isDefaultCC = true
local isDefaultLighting = true
local isDefaultSky = true
local isDefaultTerrain = true
changeCC(empty)
changeLighting(empty)
changeSky(empty)
changeTerrain(empty)

local parts = {mapModel:FindFirstChild("LightingChanger", true).Parts}

--print("LightingChanger localscript startup done")

local Connection = game:GetService("RunService").Heartbeat:Connect(function(step)
	--update ray and search to see if we are under any parts in LightingChanger.Parts
	local ray = Ray.new(camera.CFrame.Position, Vector3.new(0, rayHeight, 0))
	local hit = workspace:FindPartOnRayWithWhitelist(ray, parts)
	if hit then
		--try to locate values folders, if they don't exist pass empty table (default values)
		local CCValues = hit:FindFirstChild("ColorCorrectionValues") and hit:FindFirstChild("ColorCorrectionValues"):GetChildren()
		local LightingValues = hit:FindFirstChild("LightingValues") and hit:FindFirstChild("LightingValues"):GetChildren()
		local SkyValues = hit:FindFirstChild("SkyValues") and hit:FindFirstChild("SkyValues"):GetChildren()
		local TerrainValues = hit:FindFirstChild("TerrainValues") and hit:FindFirstChild("TerrainValues"):GetChildren()
		if CCValues then 
			isDefaultCC = false 
			changeCC(CCValues) 
		end
		if LightingValues then 
			isDefaultLighting = false 
			changeLighting(LightingValues) 
		end
		if SkyValues then 
			isDefaultSky = false 
			changeSky(SkyValues) 
		end
		if TerrainValues then 
			isDefaultTerrain = false 
			changeTerrain(TerrainValues) 
		end
	else
		--revert to defaults
		if not isDefaultCC then changeCC(empty) end
		if not isDefaultLighting then changeLighting(empty) end
		if not isDefaultSky then changeSky(empty) end
		if not isDefaultTerrain then changeTerrain(empty) end
		isDefaultCC = true
		isDefaultLighting = true
		isDefaultSky = true
		isDefaultTerrain = true
	end
end)