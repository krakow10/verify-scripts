lighting = game:GetService("Lighting")
local defaultLighting = script:WaitForChild("DefaultLightingValues")
local defaultSky = script:WaitForChild("Blue")
local camera = workspace.CurrentCamera
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")

local AudioPlayer = script:FindFirstChildWhichIsA("Sound")
local mapName = script:WaitForChild("MapName").Value
local mapModel = workspace:WaitForChild(mapName)
local player = script.Parent.Parent
local defaultAudio = mapModel.MusicZones.DefaultAudio

mapModel.Destroying:Connect(function()
	print("Map deleted, destroying PlayerScript + AudioPlayer")
	-- Without reverting, the settings set by other maps will get overridden by this script
	lighting.Ambient = Color3.fromRGB(0,0,0)
	lighting.Brightness = 2
	lighting.ColorShift_Bottom = Color3.fromRGB(0,0,0)
	lighting.ColorShift_Top = Color3.fromRGB(0,0,0)
	lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	lighting.ClockTime = 14
	lighting.GeographicLatitude = 41.733
	lighting.FogColor = Color3.fromRGB(192,192,192)
	lighting.FogEnd = 100000
	lighting.FogStart = 0
	lighting.GlobalShadows = true
	lighting:ClearAllChildren()	
end)

for _, v in pairs(mapModel.MusicZones.Zones:GetChildren()) do
	if v:IsA("BasePart") then
		v.Transparency = 1
	end
end

local mute = false
local originalVolume
for _, button in pairs(mapModel.MusicZones.MuteButtons:GetChildren()) do
	button.Mute:FindFirstChild("ClickDetector").MouseClick:Connect(function()
		local sound = script:FindFirstChildWhichIsA("Sound")
		if not mute then
			mute = true
			originalVolume = sound.Volume
			sound.Volume = 0
			for _, v in pairs(mapModel.MusicZones.MuteButtons:GetChildren()) do
				v:FindFirstChild("Mute").Color = Color3.fromRGB(170, 100, 100)
				v:FindFirstChild("Mute").Decal.Texture = "rbxassetid://1066885247"
			end
		elseif mute then
			mute = false
			sound.Volume = originalVolume
			for _, v in pairs(mapModel.MusicZones.MuteButtons:GetChildren()) do
				v:FindFirstChild("Mute").Color = Color3.fromRGB(152, 184, 109)
				v:FindFirstChild("Mute").Decal.Texture = "rbxassetid://1066885395"
			end
		end
	end)
end

local function search(value, name) 
	if value.Name == name then
		return value
	end
end

local debounce = false
local function changeAudio(audio)
	local sound = script:FindFirstChildWhichIsA("Sound")
	if sound then
		local soundBpId = search(sound, sound.Name).SoundId
		if audio.SoundId ~= soundBpId and not mute and not debounce then
			debounce = true
			local tweenLength = 1
			local values = {}
			values.Volume = 0
			local tweenInfo = TweenInfo.new(tweenLength)
			local tween = tweenService:Create(sound, tweenInfo, values)
			tween:Play()
			wait(tweenLength)
			for _, v in pairs(script:GetChildren()) do
				if v:IsA("Sound") then
					v:Destroy()
				end
			end
			if not script:FindFirstChildWhichIsA("Sound") then
				local clonedAudio = audio:Clone()
				local soundObjects = 0
				local soundId = clonedAudio.SoundId
				local newSoundId = string.gsub(soundId, "rbxassetid://", "")
				for _, v in pairs(mapModel.MusicZones.MuteButtons:GetDescendants()) do
					if v:IsA("BasePart") and v.Name == "AudioName" then
						if v:FindFirstChild("SurfaceGui") then
							v.SurfaceGui:FindFirstChild("TextLabel").Text = game:GetService("MarketplaceService"):GetProductInfo(tonumber(newSoundId)).Name
						end
					end
				end
				local ogVolume = clonedAudio.Volume
				clonedAudio.Volume = 0
				clonedAudio.Parent = script
				clonedAudio:Play()
				for _, s in pairs(script:GetChildren()) do
					if s:IsA("Sound") then
						soundObjects = soundObjects + 1
					end
				end
				if soundObjects > 1 then
					for count = soundObjects, 1, -1 do
						--print(script:FindFirstChildWhichIsA("Sound").Name)
						script:FindFirstChildWhichIsA("Sound"):Destroy()
					end
				end
				local values2 = {}
				values2.Volume = ogVolume
				local tweenInfo2 = TweenInfo.new(tweenLength)
				local tween2 = tweenService:Create(clonedAudio, tweenInfo2, values2)
				tween2:Play()
				wait(tweenLength)
				debounce = false
			end
		elseif audio.SoundId ~= soundBpId and mute then
			for _, v in pairs(script:GetChildren()) do
				if v:IsA("Sound") then
					v:Destroy()
				end
			end
			if not script:FindFirstChildWhichIsA("Sound") then
				local clonedAudio = audio:Clone()
				clonedAudio.Parent = script
				originalVolume = clonedAudio.Volume
				clonedAudio.Volume = 0
				clonedAudio:Play()
				local soundId = clonedAudio.SoundId
				local newSoundId = string.gsub(soundId, "rbxassetid://", "")
				for _, v in pairs(mapModel.MusicZones.MuteButtons:GetDescendants()) do
					if v:IsA("BasePart") and v.Name == "AudioName" then
						if v:FindFirstChild("SurfaceGui") then
							v.SurfaceGui:FindFirstChild("TextLabel").Text = game:GetService("MarketplaceService"):GetProductInfo(tonumber(newSoundId)).Name
						end
					end
				end
			end
		end
	elseif not sound then
		local clonedAudio = audio:Clone()
		clonedAudio.Parent = script
		clonedAudio:Play()
	end
end

local rayHeight = 500
local bRayHeight = 7.5
local lRayHeight = 500

local isDefaultAudio = true
changeAudio(defaultAudio)

local zones = mapModel:FindFirstChild("MusicZones").Zones
local bZones = mapModel:FindFirstChild("Buttons").Zones
local lZones = mapModel:FindFirstChild("LightingChangers").Zones

local db = false
runService.RenderStepped:Connect(function(step)
	-- Update ray and search to see if we are under any parts in MusicZones.Zones
	local ray = Ray.new(camera.CFrame.Position, Vector3.new(0, rayHeight, 0))
	local hit = workspace:FindPartOnRayWithWhitelist(ray, {zones})
	if hit then
		-- Try to locate the audio
		local NewAudio = hit:FindFirstChildWhichIsA("Sound")
		if NewAudio and not db then
			db = true
			isDefaultAudio = false
			changeAudio(NewAudio)
			wait(0.1)
			db = false
		end
	else
		-- Revert to defaults
		if not isDefaultAudio then changeAudio(defaultAudio) end
		isDefaultAudio = true
	end
end)

local bFolder = bZones.Parent
local db2 = false
runService.RenderStepped:Connect(function(step)
	local ray = Ray.new(camera.CFrame.Position, Vector3.new(0, bRayHeight, 0))
	local hit = workspace:FindPartOnRayWithWhitelist(ray, {bZones})
	if hit then
		if hit.Name == "R" then
			for _, v in pairs(bFolder.ButtonPlatforms:GetChildren()) do
				if v:IsA("BasePart") then
					v.Material = Enum.Material.Concrete
					if v:FindFirstChildWhichIsA("Decal") then
						v:FindFirstChildWhichIsA("Decal").Transparency = 0.9
					end
					if v:FindFirstChildWhichIsA("SpecialMesh") then
						v:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
					end
				end
			end
		else
			for _, v in pairs(bFolder.ButtonPlatforms:GetChildren()) do
				if v:IsA("BasePart") and v.Name == hit.Name then
					v.Material = Enum.Material.ForceField
					if not v:FindFirstChildWhichIsA("SpecialMesh") then
						local mesh = Instance.new("SpecialMesh", v)
						mesh.TextureId = "http://www.roblox.com/asset/?id=459487304"
						mesh.VertexColor = Vector3.new(.5, .5, .5)
						mesh.Scale = Vector3.new(v.Size.X, v.Size.Y, v.Size.Z)
					end
					if v:FindFirstChildWhichIsA("Decal") then
						v:FindFirstChildWhichIsA("Decal").Transparency = 1
					end
				elseif v:IsA("BasePart") and v.Name ~= hit.Name then
					v.Material = Enum.Material.Concrete
					if v:FindFirstChildWhichIsA("SpecialMesh") then
						v:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
					end
					if v:FindFirstChildWhichIsA("Decal") then
						v:FindFirstChildWhichIsA("Decal").Transparency = 0.9
					end
				end
			end
		end
	end
end)

local lFolder = lZones.Parent
runService.RenderStepped:Connect(function(step)
	local ray = Ray.new(camera.CFrame.Position, Vector3.new(0, lRayHeight, 0))
	local hit = workspace:FindPartOnRayWithWhitelist(ray, {lZones})
	if hit then
		local lValues = hit:FindFirstChild("LightingValues")
		-- Sky Values
		for _, v in pairs(lighting:GetChildren()) do
			if v.Name ~= hit:FindFirstChildWhichIsA("Sky").Name then
				v:Destroy()
				local newSky = hit:FindFirstChildWhichIsA("Sky"):Clone()
				newSky.Parent = lighting
			end
		end
		-- Lighting Values
		lighting.Ambient = lValues.Ambient.Value
		lighting.Brightness = lValues.Brightness.Value
		lighting.ClockTime = lValues.ClockTime.Value
		lighting.ColorShift_Bottom = lValues.ColorShift_Bottom.Value
		lighting.ColorShift_Top = lValues.ColorShift_Top.Value
		lighting.FogColor = lValues.FogColor.Value
		lighting.FogEnd = lValues.FogEnd.Value
		lighting.FogStart = lValues.FogStart.Value
		lighting.GeographicLatitude = lValues.GeographicLatitude.Value
		lighting.OutdoorAmbient = lValues.OutdoorAmbient.Value
		lighting.GlobalShadows = lValues.GlobalShadows.Value
	else
		-- Sky Values
		for i, v in pairs(lighting:GetChildren()) do
			if v.Name ~= defaultSky.Name then
				v:Destroy()
				local newSky = defaultSky:Clone()
				newSky.Parent = lighting
			end
		end
		if not lighting:FindFirstChildWhichIsA("Sky") then
			local newSky = defaultSky:Clone()
			newSky.Parent = lighting
		end
		-- Lighting Values
		lighting.Ambient = defaultLighting.Ambient.Value
		lighting.Brightness = defaultLighting.Brightness.Value
		lighting.ClockTime = defaultLighting.ClockTime.Value
		lighting.ColorShift_Bottom = defaultLighting.ColorShift_Bottom.Value
		lighting.ColorShift_Top = defaultLighting.ColorShift_Top.Value
		lighting.FogColor = defaultLighting.FogColor.Value
		lighting.FogEnd = defaultLighting.FogEnd.Value
		lighting.FogStart = defaultLighting.FogStart.Value
		lighting.GeographicLatitude = defaultLighting.GeographicLatitude.Value
		lighting.OutdoorAmbient = defaultLighting.OutdoorAmbient.Value
		lighting.GlobalShadows = defaultLighting.GlobalShadows.Value
	end
end)

for _, v in pairs(mapModel.MusicZones.MuteButtons:GetChildren()) do
	v.AudioName.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("SurfaceGui") then
			local text = descendant:WaitForChild("TextLabel")
			if script:FindFirstChildWhichIsA("Sound") then
				local sound = script:FindFirstChildWhichIsA("Sound")
				local soundId = sound.SoundId
				local newSoundId = string.gsub(soundId, "rbxassetid://", "")
				text.Text = game:GetService("MarketplaceService"):GetProductInfo(tonumber(newSoundId)).Name
			end
		end
	end)
end

wait(5)
for _, v in pairs(mapModel.MusicZones.MuteButtons:GetChildren()) do
	local audioName = v:FindFirstChild("AudioName")
	local sGui = Instance.new("SurfaceGui", audioName)
	local tLabel = Instance.new("TextLabel", sGui)
	sGui.Face = "Front"
	sGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	tLabel.TextScaled = true
	tLabel.TextWrapped = true
	tLabel.BackgroundTransparency = 1
	tLabel.TextStrokeTransparency = 0
	tLabel.BorderSizePixel = 0
	tLabel.Size = UDim2.new(1, 0, 1, 0)
	tLabel.Font = Enum.Font.GothamBold
	tLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
end