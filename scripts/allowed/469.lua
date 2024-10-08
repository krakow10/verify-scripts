local sGui = Instance.new("SurfaceGui", script.Parent)
local tLabel = Instance.new("TextLabel", sGui)

sGui.Face = "Back"
sGui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
sGui.CanvasSize = Vector2.new(600, 300)
tLabel.TextScaled = true
tLabel.Text = script.Parent.Text.Value
tLabel.BackgroundTransparency = 1
tLabel.BorderSizePixel = 0
tLabel.Size = UDim2.new(1, 0, 1, 0)
tLabel.Font = Enum.Font.Highway
tLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
