local lightning = game:GetService'Lighting'
script.Parent.Atmosphere.Parent = lightning
script.Parent.Parent = lightning
lightning.Brightness = 0
lightning.Ambient = Color3.new(0.27451, 0.27451, 0.27451)
lightning.ColorShift_Bottom  = Color3.new(0,0,0)
lightning.ColorShift_Top = Color3.new(0,0,0)
lightning.EnvironmentDiffuseScale = 1
lightning.EnvironmentSpecularScale = 1
lightning.GlobalShadows = false
lightning.OutdoorAmbient = Color3.new(0.27451, 0.27451, 0.27451)
lightning.ShadowSoftness = 0
lightning.ClockTime = 14.5
lightning.FogColor = Color3.new(0.74902, 0.74902, 0.74902)
lightning.FogEnd = 100000
lightning.FogStart = 0
