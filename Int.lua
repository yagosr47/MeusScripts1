-- ==========================================
-- SCRIPT DE GRÁFICOS ULTRA (RTX MODE)
-- Melhora Iluminação, Cores e Sombras
-- ==========================================

local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Terrain = workspace.Terrain

-- Evita duplicar a interface
if CoreGui:FindFirstChild("UltraGraphicsMenu") then
    CoreGui.UltraGraphicsMenu:Destroy()
end

-- ==========================================
-- 1. INTERFACE MODERNA E BONITA
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UltraGraphicsMenu"
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 90)
frame.Position = UDim2.new(0.5, -110, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Arredondamento da borda (UI moderna)
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = frame

-- Contorno brilhante
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(0, 170, 255)
uiStroke.Thickness = 2
uiStroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "✨ Gráficos Ultra"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 16
title.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8, 0, 0, 35)
toggleButton.Position = UDim2.new(0.1, 0, 0.45, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleButton.Text = "Ativar Modo RTX"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleButton

-- ==========================================
-- 2. LÓGICA DOS GRÁFICOS (EFEITOS VISUAIS)
-- ==========================================
local isGraphicsOn = false

-- Variáveis para guardar as configurações originais do jogo
local originalLighting = {
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    ColorShift_Bottom = Lighting.ColorShift_Bottom,
    ColorShift_Top = Lighting.ColorShift_Top,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ShadowSoftness = Lighting.ShadowSoftness,
    EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
}

local originalTerrain = {
    WaterColor = Terrain.WaterColor,
    WaterWaveSize = Terrain.WaterWaveSize,
    WaterWaveSpeed = Terrain.WaterWaveSpeed,
    WaterReflectance = Terrain.WaterReflectance,
}

local customEffects = {}

local function toggleGraphics(state)
    if state then
        -- Tentar forçar o nível de qualidade máxima da engine (Funciona em alguns executores)
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level21
        end)

        -- 1. MELHORAR A ILUMINAÇÃO BASE
        Lighting.GlobalShadows = true
        Lighting.Brightness = 2.5
        Lighting.ShadowSoftness = 0.1
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 1 -- Melhora reflexos em metais e plásticos
        Lighting.Ambient = Color3.fromRGB(60, 60, 60)
        Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)

        -- 2. MELHORAR A ÁGUA DO TERRENO
        Terrain.WaterColor = Color3.fromRGB(15, 125, 175)
        Terrain.WaterWaveSize = 0.15
        Terrain.WaterWaveSpeed = 12
        Terrain.WaterReflectance = 1

        -- 3. ADICIONAR EFEITOS DE PÓS-PROCESSAMENTO (CORES VIBRANTES)
        local colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Name = "RTX_ColorCorrection"
        colorCorrection.Brightness = 0.05
        colorCorrection.Contrast = 0.2     -- Aumenta a diferença entre claro e escuro
        colorCorrection.Saturation = 0.4   -- Deixa as cores muito mais vibrantes e vivas
        colorCorrection.TintColor = Color3.fromRGB(255, 250, 245) -- Tom levemente quente
        colorCorrection.Parent = Lighting
        table.insert(customEffects, colorCorrection)

        local bloom = Instance.new("BloomEffect")
        bloom.Name = "RTX_Bloom"
        bloom.Intensity = 0.6 -- Brilho em coisas claras (neon, sol, luzes)
        bloom.Size = 20
        bloom.Threshold = 0.9
        bloom.Parent = Lighting
        table.insert(customEffects, bloom)

        local sunRays = Instance.new("SunRaysEffect")
        sunRays.Name = "RTX_SunRays"
        sunRays.Intensity = 0.15
        sunRays.Spread = 0.8
        sunRays.Parent = Lighting
        table.insert(customEffects, sunRays)

    else
        -- RESTAURAR GRÁFICOS ORIGINAIS
        Lighting.Ambient = originalLighting.Ambient
        Lighting.Brightness = originalLighting.Brightness
        Lighting.ColorShift_Bottom = originalLighting.ColorShift_Bottom
        Lighting.ColorShift_Top = originalLighting.ColorShift_Top
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.ShadowSoftness = originalLighting.ShadowSoftness
        Lighting.EnvironmentDiffuseScale = originalLighting.EnvironmentDiffuseScale
        Lighting.EnvironmentSpecularScale = originalLighting.EnvironmentSpecularScale

        Terrain.WaterColor = originalTerrain.WaterColor
        Terrain.WaterWaveSize = originalTerrain.WaterWaveSize
        Terrain.WaterWaveSpeed = originalTerrain.WaterWaveSpeed
        Terrain.WaterReflectance = originalTerrain.WaterReflectance

        -- Deletar os efeitos customizados que criamos
        for _, effect in pairs(customEffects) do
            if effect and effect.Parent then
                effect:Destroy()
            end
        end
        customEffects = {}
    end
end

-- ==========================================
-- 3. AÇÃO DO BOTÃO
-- ==========================================
toggleButton.MouseButton1Click:Connect(function()
    isGraphicsOn = not isGraphicsOn
    
    if isGraphicsOn then
        toggleButton.Text = "Desativar RTX"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        uiStroke.Color = Color3.fromRGB(255, 50, 50)
        toggleGraphics(true)
    else
        toggleButton.Text = "Ativar Modo RTX"
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        uiStroke.Color = Color3.fromRGB(0, 170, 255)
        toggleGraphics(false)
    end
end)
