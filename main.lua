local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "LUXEN - Emergency Hamburg",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Luxen is loading...",
   LoadingSubtitle = "by Azfa & Vamp 🧛",
   ShowText = "Luxen", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "AmberGlow", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

Rayfield:Notify({
   Title = "Welcome on Luxen",
   Content = "Enjoy !",
   Duration = 3.5,
   Image = 4483362458,
})


local Tab = Window:CreateTab("👤｜Player", 0) -- Title, Image

local Section = Tab:CreateSection("Fly")

-- Variables pour le Fly (version ultra furtive - CORRIGEE)
local flyEnabled = false
local flySpeed = 10
local flyConnection = nil
local shiftlockEnabled = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Fonction pour activer/desactiver le shiftlock
local function setShiftlock(enabled)
    pcall(function()
        if enabled then
            LocalPlayer.DevEnableMouseLock = true
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            shiftlockEnabled = true
        else
            LocalPlayer.DevEnableMouseLock = false
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            shiftlockEnabled = false
        end
    end)
end

-- Methode ultra furtive avec direction corrigee
local function toggleFly(enabled)
    flyEnabled = enabled
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    if enabled then
        setShiftlock(true)
        
        -- Creer une partie invisible pour "marcher" dessus
        local flyPart = Instance.new("Part")
        flyPart.Name = "FlyPart"
        flyPart.Size = Vector3.new(10, 0.5, 10)
        flyPart.Transparency = 1
        flyPart.CanCollide = true
        flyPart.Anchored = true
        flyPart.CFrame = CFrame.new(rootPart.Position - Vector3.new(0, 3, 0))
        flyPart.Parent = workspace
        
        -- Boucle de vol
        flyConnection = RunService.Heartbeat:Connect(function(deltaTime)
            if not flyEnabled or not rootPart or not rootPart.Parent then return end
            
            local camera = workspace.CurrentCamera
            if not camera then return end
            
            local moveDirection = Vector3.new(0, 0, 0)
            local verticalMove = 0
            
            -- Detection des touches PC (separation horizontal et vertical)
            local horizontalMove = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Z) then
                horizontalMove = horizontalMove + Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                horizontalMove = horizontalMove - Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                horizontalMove = horizontalMove - Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                horizontalMove = horizontalMove + Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)
            end
            
            -- Mouvement vertical separe
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                verticalMove = 1
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                verticalMove = -1
            end
            
            -- Support mobile (horizontal seulement)
            if humanoid.MoveDirection.Magnitude > 0 then
                local moveDir = humanoid.MoveDirection
                horizontalMove = horizontalMove + Vector3.new(camera.CFrame.LookVector.X * moveDir.Z, 0, camera.CFrame.LookVector.Z * moveDir.Z)
                horizontalMove = horizontalMove + Vector3.new(camera.CFrame.RightVector.X * moveDir.X, 0, camera.CFrame.RightVector.Z * moveDir.X)
            end
            
            -- Combiner horizontal et vertical
            if horizontalMove.Magnitude > 0 then
                horizontalMove = horizontalMove.Unit
            end
            
            moveDirection = horizontalMove + Vector3.new(0, verticalMove, 0)
            
            -- Appliquer le mouvement
            if moveDirection.Magnitude > 0 then
                local targetPosition = rootPart.Position + (moveDirection * flySpeed * deltaTime)
                
                -- Deplacer la partie invisible exactement sous le joueur
                if flyPart and flyPart.Parent then
                    flyPart.CFrame = CFrame.new(targetPosition.X, targetPosition.Y - 3, targetPosition.Z)
                end
                
                -- Teleportation furtive par petits increments
                rootPart.CFrame = CFrame.new(targetPosition)
            end
            
            -- Orienter le personnage vers la direction de la camera (horizontal seulement)
            local lookVector = camera.CFrame.LookVector
            local targetCFrame = CFrame.new(rootPart.Position, rootPart.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
            rootPart.CFrame = CFrame.new(rootPart.Position) * targetCFrame.Rotation
            
            -- Annuler les velocites
            rootPart.Velocity = Vector3.new(0, 0, 0)
            rootPart.RotVelocity = Vector3.new(0, 0, 0)
        end)
        
    else
        -- Desactiver le fly
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        
        setShiftlock(false)
        
        -- Supprimer la partie invisible
        local flyPart = workspace:FindFirstChild("FlyPart")
        if flyPart then
            flyPart:Destroy()
        end
        
        -- Reset
        if rootPart then
            rootPart.Velocity = Vector3.new(0, 0, 0)
            rootPart.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
end

-- Toggle Fly
local Toggle = Tab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "fly",
    Callback = function(Value)
        pcall(function()
            toggleFly(Value)
        end)
    end,
})

-- Slider vitesse
local Slider = Tab:CreateSlider({
    Name = "Fly speed",
    Range = {5, 50},
    Increment = 5,
    Suffix = "speed",
    CurrentValue = 20,
    Flag = "fly_speed",
    Callback = function(Value)
        flySpeed = Value
    end,
})

-- Keybind pour toggle
local Keybind = Tab:CreateKeybind({
    Name = "Fly keybind",
    CurrentKeybind = "F",
    HoldToInteract = false,
    Flag = "fly_bind",
    Callback = function()
        pcall(function()
            flyEnabled = not flyEnabled
            Toggle:Set(flyEnabled)
            toggleFly(flyEnabled)
        end)
    end,
})

-- Reset si respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(0.1)
    if flyEnabled then
        pcall(function()
            toggleFly(false)
            flyEnabled = false
            Toggle:Set(false)
        end)
    end
end)

local Section = Tab:CreateSection("Utils")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Variables
local walkSpeedEnabled = false
local walkSpeedValue = 16
local originalWalkSpeed = 16

-- Connexions
local walkSpeedConnection = nil


-- WALK SPEED (Methode ultra furtive - manipulation de CFrame)
local walkSpeedEnabled = false
local walkSpeedValue = 16
local originalWalkSpeed = 16
local walkSpeedConnection = nil

local function setWalkSpeed(enabled, speed)
    walkSpeedEnabled = enabled
    walkSpeedValue = speed
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    
    if enabled then
        -- NE PAS toucher WalkSpeed directement (detecte!)
        -- A la place, on accelere le mouvement via CFrame
        
        if walkSpeedConnection then
            walkSpeedConnection:Disconnect()
        end
        
        walkSpeedConnection = RunService.Heartbeat:Connect(function(deltaTime)
            if not walkSpeedEnabled then return end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if not hum or not root then return end
            
            -- Detecter si le joueur bouge
            if hum.MoveDirection.Magnitude > 0 then
                -- Calculer le boost (difference entre vitesse voulue et vitesse normale)
                local boost = (walkSpeedValue - 16) / 16
                
                -- Appliquer un leger deplacement additionnel dans la direction du mouvement
                local moveDirection = hum.MoveDirection
                local additionalMove = moveDirection * boost * deltaTime * 16
                
                -- Deplacer via CFrame (plus furtif que WalkSpeed)
                root.CFrame = root.CFrame + additionalMove
            end
        end)
    else
        -- Desactiver
        if walkSpeedConnection then
            walkSpeedConnection:Disconnect()
            walkSpeedConnection = nil
        end
    end
end

local WalkSpeedToggle = Tab:CreateToggle({
    Name = "Walk speed",
    CurrentValue = false,
    Flag = "walk_boost",
    Callback = function(Value)
        pcall(function()
            setWalkSpeed(Value, walkSpeedValue)
        end)
    end,
})

local WalkSpeedSlider = Tab:CreateSlider({
    Name = "Walk speed",
    Range = {16, 25},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "walk_speed",
    Callback = function(Value)
        walkSpeedValue = Value
        if walkSpeedEnabled then
            pcall(function()
                setWalkSpeed(true, Value)
            end)
        end
    end,
})

-- INFINITE STAMINA (Version hookfunction - basée sur leur code)
local infStaminaEnabled = false
local staminaHooked = false

local function hookStamina()
    if staminaHooked then return end
    
    pcall(function()
        -- Chercher la fonction setStamina dans le garbage collector
        local setStaminaFunc = nil
        
        for i, v in pairs(getgc(true)) do
            if type(v) == "function" then
                local info = debug.getinfo(v)
                if info and info.name == "setStamina" then
                    setStaminaFunc = v
                    break
                end
            end
        end
        
        if setStaminaFunc then
            -- Hook la fonction pour toujours mettre la stamina au max
            hookfunction(setStaminaFunc, function(self, value)
                if infStaminaEnabled then
                    -- Toujours mettre 1 (max stamina)
                    return setStaminaFunc(self, 1)
                else
                    -- Comportement normal
                    return setStaminaFunc(self, value)
                end
            end)
            
            staminaHooked = true
            print("Stamina hooked successfully!")
        else
            warn("setStamina function not found!")
        end
    end)
end

local function setInfiniteStamina(enabled)
    infStaminaEnabled = enabled
    
    if enabled and not staminaHooked then
        hookStamina()
    end
end

local InfStaminaToggle = Tab:CreateButton({
    Name = "Infinite Stamina",
    Callback = function(Value)
        pcall(function()
            setInfiniteStamina(Value)
        end)
    end,
})

-- Hook aussi useStamina pour empecher la consommation
spawn(function()
    wait(2) -- Attendre que le jeu charge
    
    pcall(function()
        local useStaminaFunc = nil
        
        for i, v in pairs(getgc(true)) do
            if type(v) == "function" then
                local info = debug.getinfo(v)
                if info and info.name == "useStamina" then
                    useStaminaFunc = v
                    break
                end
            end
        end
        
        if useStaminaFunc then
            hookfunction(useStaminaFunc, function(self, amount)
                if infStaminaEnabled then
                    -- Ne jamais consommer de stamina, toujours retourner true
                    return true
                else
                    return useStaminaFunc(self, amount)
                end
            end)
            
            print("useStamina hooked successfully!")
        end
    end)
end)

-- INFINITE JUMP (Version corrigee - retire seulement le cooldown)
local infJumpEnabled = false
local jumpConnection = nil
local canJump = true

local function setInfiniteJump(enabled)
    infJumpEnabled = enabled
    
    if enabled then
        if jumpConnection then
            jumpConnection:Disconnect()
        end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        -- Methode: Empecher le cooldown du saut
        jumpConnection = humanoid.StateChanged:Connect(function(old, new)
            if not infJumpEnabled then return end
            
            -- Si on vient de sauter, retirer immediatement le cooldown
            if new == Enum.HumanoidStateType.Jumping or new == Enum.HumanoidStateType.Freefall then
                wait(0.1) -- Petit delai pour que le saut s'execute
                -- Forcer l'etat a "Landed" pour permettre un nouveau saut
                if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                end
            end
        end)
        
        -- Activer en permanence la capacite de sauter
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        
    else
        if jumpConnection then
            jumpConnection:Disconnect()
            jumpConnection = nil
        end
    end
end

local InfJumpToggle = Tab:CreateButton({
    Name = "Infinite jump",
    Callback = function(Value)
        pcall(function()
            setInfiniteJump(Value)
        end)
    end,
})

-- Reset si respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(0.5)
    
    if infStaminaEnabled then
        setInfiniteStamina(false)
        wait(0.1)
        setInfiniteStamina(true)
    end
    
    if infJumpEnabled then
        setInfiniteJump(false)
        wait(0.1)
        setInfiniteJump(true)
    end
end)

local Tab = Window:CreateTab("🛡️｜Aimbot", 0)
local Section = Tab:CreateSection("Aimbot Settings")

-- Charger Aimbot V3 d'Exunys
local AimbotLoaded = false
local AimbotModule = nil

local function LoadAimbotV3()
    if not AimbotLoaded then
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Aimbot-V3/main/src/Aimbot.lua"))()
            AimbotModule = getgenv().ExunysDeveloperAimbot
            AimbotLoaded = true
            
            -- Configuration par défaut
            AimbotModule.Settings.Enabled = false
            AimbotModule.Settings.TeamCheck = true
            AimbotModule.Settings.AliveCheck = true
            AimbotModule.Settings.WallCheck = false
            AimbotModule.Settings.Sensitivity = 0.1
            AimbotModule.Settings.LockMode = 1 -- CFrame mode
            AimbotModule.Settings.LockPart = "Head"
            AimbotModule.Settings.TriggerKey = Enum.UserInputType.MouseButton2
            AimbotModule.Settings.Toggle = false
            
            -- FOV Settings
            AimbotModule.FOVSettings.Enabled = true
            AimbotModule.FOVSettings.Visible = true
            AimbotModule.FOVSettings.Radius = 200
            AimbotModule.FOVSettings.Filled = false
            AimbotModule.FOVSettings.Color = Color3.fromRGB(255, 0, 0)
            AimbotModule.FOVSettings.Transparency = 1
            
            Rayfield:Notify({
                Title = "Aimbot V3",
                Content = "Loaded successfully!",
                Duration = 3,
                Image = 4483362458,
            })
        end)
    end
end

-- Charger au démarrage
LoadAimbotV3()

-- UI Controls
local AimbotToggle = Tab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Flag = "aimbot_enabled",
    Callback = function(Value)
        if AimbotModule then
            AimbotModule.Settings.Enabled = Value
        end
    end,
})

local Section1_5 = Tab:CreateSection("FOV Settings")

local FOVToggle = Tab:CreateToggle({
    Name = "Show FOV",
    CurrentValue = true,
    Flag = "fov_visible",
    Callback = function(Value)
        if AimbotModule then
            AimbotModule.FOVSettings.Visible = Value
        end
    end,
})

local FOVSlider = Tab:CreateSlider({
    Name = "FOV Size",
    Range = {50, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 200,
    Flag = "fov_size",
    Callback = function(Value)
        if AimbotModule then
            AimbotModule.FOVSettings.Radius = Value
        end
    end,
})

local FOVColorPicker = Tab:CreateColorPicker({
    Name = "FOV Color",
    Color = Color3.fromRGB(255,0,0),
    Flag = "fov_color",
    Callback = function(Value)
        if AimbotModule then
            AimbotModule.FOVSettings.Color = Value
        end
    end
})

local FOVFilledToggle = Tab:CreateToggle({
    Name = "FOV Filled",
    CurrentValue = false,
    Flag = "fov_filled",
    Callback = function(Value)
        if AimbotModule then
            AimbotModule.FOVSettings.Filled = Value
        end
    end,
})

local Section2 = Tab:CreateSection("Aimbot Settings")

local SmoothnessSlider = Tab:CreateSlider({
    Name = "Smoothness",
    Range = {0, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 10,
    Flag = "smoothness",
    Callback = function(Value)
        if AimbotModule then
            AimbotModule.Settings.Sensitivity = Value / 100
        end
    end,
})

local LockModeDropdown = Tab:CreateDropdown({
    Name = "Lock Mode",
    Options = {"CFrame (Smooth)", "MouseMove (Snap)"},
    CurrentOption = "CFrame (Smooth)",
    Flag = "lock_mode",
    Callback = function(Option)
        if AimbotModule then
            if Option == "CFrame (Smooth)" then
                AimbotModule.Settings.LockMode = 1
            else
                AimbotModule.Settings.LockMode = 2
            end
        end
    end,
})

local TargetPartDropdown = Tab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head","UpperTorso","HumanoidRootPart","LowerTorso"},
    CurrentOption = "Head",
    Flag = "target_part",
    Callback = function(Option)
        if AimbotModule then
            AimbotModule.Settings.LockPart = Option
        end
    end,
})

local TeamCheckToggle = Tab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Flag = "team_check",
    Callback = function(Value)
        if AimbotModule then
            AimbotModule.Settings.TeamCheck = Value
        end
    end,
})

local AliveCheckToggle = Tab:CreateToggle({
    Name = "Alive Check",
    CurrentValue = true,
    Flag = "alive_check",
    Callback = function(Value)
        if AimbotModule then
            AimbotModule.Settings.AliveCheck = Value
        end
    end,
})

local WallCheckToggle = Tab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = false,
    Flag = "wall_check",
    Callback = function(Value)
        if AimbotModule then
            AimbotModule.Settings.WallCheck = Value
        end
    end,
})

local Section3 = Tab:CreateSection("Prediction")

local PredictionToggle = Tab:CreateToggle({
    Name = "Prediction",
    CurrentValue = false,
    Flag = "prediction",
    Callback = function(Value)
        if AimbotModule then
            AimbotModule.Settings.OffsetToMoveDirection = Value
        end
    end,
})

local PredictionSlider = Tab:CreateSlider({
    Name = "Prediction Strength",
    Range = {1, 30},
    Increment = 1,
    Suffix = "",
    CurrentValue = 15,
    Flag = "prediction_strength",
    Callback = function(Value)
        if AimbotModule then
            AimbotModule.Settings.OffsetIncrement = Value
        end
    end,
})

local Section4 = Tab:CreateSection("Keybinds")

local AimbotKeybind = Tab:CreateKeybind({
    Name = "Aimbot Hold Key",
    CurrentKeybind = "MouseButton2",
    HoldToInteract = false,
    Flag = "aimbot_keybind",
    Callback = function()
        -- Le keybind est géré par le module lui-même via TriggerKey
    end,
})

local ToggleModeToggle = Tab:CreateToggle({
    Name = "Toggle Mode (instead of Hold)",
    CurrentValue = false,
    Flag = "toggle_mode",
    Callback = function(Value)
        if AimbotModule then
            AimbotModule.Settings.Toggle = Value
        end
    end,
})

local Section5 = Tab:CreateSection("Mobile")

-- Mobile Button pour Aimbot V3
local MobileAimbotButton = Tab:CreateButton({
    Name = "Show Mobile Aimbot Button",
    Callback = function()
        local mobileGui = Instance.new("ScreenGui")
        mobileGui.Name = "LuxenMobileAimbot"
        mobileGui.ResetOnSpawn = false
        mobileGui.IgnoreGuiInset = true
        mobileGui.Parent = game.Players.LocalPlayer.PlayerGui
        
        local mobileButton = Instance.new("TextButton")
        mobileButton.Size = UDim2.new(0, 80, 0, 80)
        mobileButton.Position = UDim2.new(0, 20, 0.5, -40)
        mobileButton.AnchorPoint = Vector2.new(0, 0.5)
        mobileButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        mobileButton.Text = "AIM\nOFF"
        mobileButton.TextColor3 = Color3.white
        mobileButton.TextSize = 18
        mobileButton.Font = Enum.Font.GothamBold
        mobileButton.Parent = mobileGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 15)
        corner.Parent = mobileButton
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.white
        stroke.Thickness = 2
        stroke.Parent = mobileButton
        
        mobileButton.MouseButton1Click:Connect(function()
            if AimbotModule then
                AimbotModule.Settings.Enabled = not AimbotModule.Settings.Enabled
                AimbotToggle:Set(AimbotModule.Settings.Enabled)
                
                if AimbotModule.Settings.Enabled then
                    mobileButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
                    mobileButton.Text = "AIM\nON"
                else
                    mobileButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                    mobileButton.Text = "AIM\nOFF"
                end
            end
        end)
        
        Rayfield:Notify({
            Title = "Mobile Aimbot",
            Content = "Button visible on left side!",
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

-- Informations
local Section6 = Tab:CreateSection("Info")

local InfoLabel = Tab:CreateLabel("Using Aimbot V3 by Exunys", 4483362458, Color3.fromRGB(255, 255, 255), false)
local InfoLabel2 = Tab:CreateLabel("Hold Right Click to lock", 4483362458, Color3.fromRGB(200, 200, 200), false)

-- ===============================
-- SILENT AIM (GARDE TON CODE ACTUEL)
-- ===============================
-- [Ton code Silent Aim ici, inchangé]
-- ===============================
-- SILENT AIM (TAB SÉPARÉ) - SANS LE TEXTE
-- ===============================

local SilentTab = Window:CreateTab("🎯｜Silent Aim", 0)
local SilentSection = SilentTab:CreateSection("Silent Aim")

local silentAimEnabled = false
local silentFovSize = 150
local silentFovVisible = false
local silentTeamCheck = true
local silentAliveCheck = true
local silentFovCircle = nil
local silentStatusLabel = nil

-- Créer le cercle FOV Silent REMPLI AU CENTRE
local function createSilentFOVCircle()
    pcall(function()
        if silentFovCircle then
            silentFovCircle:Remove()
        end
        
        silentFovCircle = Drawing.new("Circle")
        silentFovCircle.Thickness = 2
        silentFovCircle.NumSides = 50
        silentFovCircle.Radius = silentFovSize
        silentFovCircle.Filled = true -- REMPLI
        silentFovCircle.Transparency = 0.15 -- Semi-transparent
        silentFovCircle.Color = Color3.fromRGB(255, 255, 0)
        silentFovCircle.Visible = silentFovVisible
        silentFovCircle.ZIndex = 998
    end)
end

-- Créer le label de statut AU CENTRE
local function createSilentStatusLabel()
    pcall(function()
        if silentStatusLabel then
            silentStatusLabel:Remove()
        end
        
        silentStatusLabel = Drawing.new("Text")
        silentStatusLabel.Text = "INACTIVE"
        silentStatusLabel.Size = 18
        silentStatusLabel.Center = true
        silentStatusLabel.Outline = true
        silentStatusLabel.Color = Color3.fromRGB(255, 0, 0)
        silentStatusLabel.Visible = false
        silentStatusLabel.ZIndex = 1000
        silentStatusLabel.Font = 2
    end)
end

-- Update position du cercle Silent AU CENTRE
spawn(function()
    RunService.RenderStepped:Connect(function()
        pcall(function()
            local screenSize = Camera.ViewportSize
            local centerPos = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
            
            if silentFovCircle then
                silentFovCircle.Position = centerPos
                silentFovCircle.Radius = silentFovSize
                silentFovCircle.Visible = silentFovVisible
            end
            
            if silentStatusLabel then
                silentStatusLabel.Position = Vector2.new(centerPos.X, centerPos.Y + 30)
                silentStatusLabel.Visible = silentFovVisible
                
                if silentAimEnabled then
                    silentStatusLabel.Text = "ACTIVE"
                    silentStatusLabel.Color = Color3.fromRGB(0, 255, 0)
                else
                    silentStatusLabel.Text = "INACTIVE"
                    silentStatusLabel.Color = Color3.fromRGB(255, 0, 0)
                end
            end
        end)
    end)
end)

-- Fonction pour trouver la cible la plus proche (Silent Aim) depuis le centre
local function getClosestPlayerSilent()
    local closestPlayer = nil
    local shortestDistance = silentFovSize
    
    local screenSize = Camera.ViewportSize
    local screenCenter = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if silentTeamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local targetPartObj = character:FindFirstChild("Head")
            
            if not targetPartObj then continue end
            
            if silentAliveCheck and (not humanoid or humanoid.Health <= 0) then
                continue
            end
            
            local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPartObj.Position)
            
            if onScreen then
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
                
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer
end

-- Silent Aim Hook
local oldNamecallSilent
oldNamecallSilent = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if silentAimEnabled and method == "FireServer" then
        local selfName = tostring(self):lower()
        if selfName:find("shoot") or selfName:find("fire") or selfName:find("gun") or selfName:find("bullet") then
            local target = getClosestPlayerSilent()
            if target and target.Character then
                local targetPartObj = target.Character:FindFirstChild("Head")
                if targetPartObj then
                    args[1] = targetPartObj.Position
                    if args[2] then
                        args[2] = targetPartObj
                    end
                    if args[3] then
                        args[3] = targetPartObj.Position
                    end
                end
            end
        end
    end
    
    return oldNamecallSilent(self, unpack(args))
end)

createSilentFOVCircle()
createSilentStatusLabel()

-- UI Silent Aim
local SilentToggle = SilentTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Flag = "silent_aim",
    Callback = function(Value)
        silentAimEnabled = Value
    end,
})

local SilentKeybind = SilentTab:CreateKeybind({
    Name = "Silent Aim Toggle Keybind",
    CurrentKeybind = "T",
    HoldToInteract = false,
    Flag = "silent_keybind",
    Callback = function()
        silentAimEnabled = not silentAimEnabled
        SilentToggle:Set(silentAimEnabled)
    end,
})

-- MOBILE SILENT AIM BUTTON - VERSION SIMPLIFIÉE
local MobileSilentButton = SilentTab:CreateButton({
    Name = "Show Mobile Silent Aim Button",
    Callback = function()
        local mobileSilentGui = Instance.new("ScreenGui")
        mobileSilentGui.Name = "LuxenMobileSilent"
        mobileSilentGui.ResetOnSpawn = false
        mobileSilentGui.IgnoreGuiInset = true
        mobileSilentGui.Parent = LocalPlayer.PlayerGui
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 80, 0, 80)
        btn.Position = UDim2.new(0, 20, 0.5, 60)
        btn.AnchorPoint = Vector2.new(0, 0.5)
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 50)
        btn.Text = "SILENT\nOFF"
        btn.TextColor3 = Color3.black
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamBold
        btn.Parent = mobileSilentGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 15)
        corner.Parent = btn
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.white
        stroke.Thickness = 2
        stroke.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            silentAimEnabled = not silentAimEnabled
            SilentToggle:Set(silentAimEnabled)
            
            if silentAimEnabled then
                btn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                btn.Text = "SILENT\nON"
                btn.TextColor3 = Color3.white
            else
                btn.BackgroundColor3 = Color3.fromRGB(255, 255, 50)
                btn.Text = "SILENT\nOFF"
                btn.TextColor3 = Color3.black
            end
        end)
        
        Rayfield:Notify({
            Title = "Mobile Silent Aim",
            Content = "Button visible on left side!",
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

local SilentFOVToggle = SilentTab:CreateToggle({
    Name = "Show Silent Aim FOV",
    CurrentValue = false,
    Flag = "silent_fov_visible",
    Callback = function(Value)
        silentFovVisible = Value
    end,
})

local SilentFOVSlider = SilentTab:CreateSlider({
    Name = "FOV Size",
    Range = {50, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 150,
    Flag = "silent_fov_size",
    Callback = function(Value)
        silentFovSize = Value
    end,
})

local SilentFOVColorPicker = SilentTab:CreateColorPicker({
    Name = "FOV Color",
    Color = Color3.fromRGB(255,255,0),
    Flag = "silent_fov_color",
    Callback = function(Value)
        pcall(function()
            if silentFovCircle then
                silentFovCircle.Color = Value
            end
        end)
    end
})

local SilentTeamCheckToggle = SilentTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Flag = "silent_team_check",
    Callback = function(Value)
        silentTeamCheck = Value
    end,
})

local SilentAliveCheckToggle = SilentTab:CreateToggle({
    Name = "Alive Check",
    CurrentValue = true,
    Flag = "silent_alive_check",
    Callback = function(Value)
        silentAliveCheck = Value
    end,
})

local Tab = Window:CreateTab("👀｜Visuals", 0)
local Section = Tab:CreateSection("ESP")
local Toggle = Tab:CreateToggle({
   Name = "ESP names",
   CurrentValue = false,
   Flag = "esp_names", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   -- The function that takes place when the toggle is pressed
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local NamesColorPicker = Tab:CreateColorPicker({
    Name = "Names Color",
    Color = Color3.fromRGB(255,255,255),
    Flag = "names_color",
    Callback = function(Value)
    end
})

local Toggle = Tab:CreateToggle({
   Name = "ESP distance (stunds)",
   CurrentValue = false,
   Flag = "esp_distance", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   -- The function that takes place when the toggle is pressed
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local DistanceColorPicker = Tab:CreateColorPicker({
    Name = "Distance Color",
    Color = Color3.fromRGB(255,255,255),
    Flag = "distance_color",
    Callback = function(Value)
    end
})

local Toggle = Tab:CreateToggle({
   Name = "ESP Lines",
   CurrentValue = false,
   Flag = "esp_line", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   -- The function that takes place when the toggle is pressed
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local LinesColorPicker = Tab:CreateColorPicker({
    Name = "Lines Color",
    Color = Color3.fromRGB(255,255,255),
    Flag = "lines_color",
    Callback = function(Value)
    end
})

local Toggle = Tab:CreateToggle({
   Name = "ESP Skeleton",
   CurrentValue = false,
   Flag = "esp_skeleton", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   -- The function that takes place when the toggle is pressed
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local SKEColorPicker = Tab:CreateColorPicker({
    Name = "Skeleton Color",
    Color = Color3.fromRGB(255,255,255),
    Flag = "skeleton_color",
    Callback = function(Value)
    end
})

local Tab = Window:CreateTab("🏎️｜Car Mods", 0)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Variables globales
local carAccelEnabled = false
local carAccelValue = 0
local carMaxSpeedValue = 200
local antiCrashEnabled = false

-- Fonction pour trouver le véhicule du joueur
local function findPlayerVehicle()
    local vehiclesFolder = workspace:FindFirstChild("Vehicles")
    if not vehiclesFolder then
        return nil
    end
    
    local playerVehicle = vehiclesFolder:FindFirstChild(LocalPlayer.Name)
    if playerVehicle then
        return playerVehicle
    end
    
    for _, vehicle in pairs(vehiclesFolder:GetChildren()) do
        if vehicle:IsA("Model") then
            local driveSeat = vehicle:FindFirstChild("DriveSeat")
            if driveSeat and driveSeat.Occupant then
                local humanoid = driveSeat.Occupant
                if humanoid.Parent == LocalPlayer.Character then
                    return vehicle
                end
            end
        end
    end
    
    return nil
end

-- Section Car Boost
local Section = Tab:CreateSection("Car boost")

local speedConnection = nil

local function applyCarMods()
    if speedConnection then
        speedConnection:Disconnect()
    end
    
    speedConnection = RunService.Heartbeat:Connect(function()
        local vehicle = findPlayerVehicle()
        if not vehicle then return end
        
        local vehicleStats = vehicle:FindFirstChild("Stats")
        if vehicleStats then
            -- Modifier la vitesse max
            local maxSpeed = vehicleStats:FindFirstChild("MaxSpeed")
            if maxSpeed then
                maxSpeed.Value = carMaxSpeedValue
            end
            
            -- Modifier l'accélération si activée
            if carAccelEnabled then
                local accel = vehicleStats:FindFirstChild("Acceleration")
                if accel then
                    accel.Value = carAccelValue
                end
            end
        end
    end)
end

local CarMaxSpeed = Tab:CreateSlider({
    Name = "Car Max Speed",
    Range = {10, 480},
    Increment = 10,
    Suffix = " km/h",
    CurrentValue = 200,
    Flag = "car_max_speed",
    Callback = function(Value)
        carMaxSpeedValue = Value
        applyCarMods()
    end,
})

local CarAccel = Tab:CreateSlider({
    Name = "Car Acceleration",
    Range = {0, 10000},
    Increment = 30,
    Suffix = " acceleration",
    CurrentValue = 0,
    Flag = "car_accel",
    Callback = function(Value)
        carAccelValue = Value
        if carAccelEnabled then
            applyCarMods()
        end
    end,
})

local AccelToggle = Tab:CreateToggle({
   Name = "Enable Acceleration",
   CurrentValue = false,
   Flag = "car_accel_toggle",
   Callback = function(Value)
       carAccelEnabled = Value
       if Value then
           applyCarMods()
       end
   end,
})

-- Section Car Tuning
local Section2 = Tab:CreateSection("Car tuning")

local CarColorPicker = Tab:CreateColorPicker({
    Name = "Car Color",
    Color = Color3.fromRGB(255,255,255),
    Flag = "car_color",
    Callback = function(Value)
        pcall(function()
            local remote = ReplicatedStorage.Bnl["a57a7cba-6681-43f3-bfe3-72e368ea953e"]
            remote:FireServer(Value)
            
            Rayfield:Notify({
                Title = "Car Color",
                Content = "Color changed!",
                Duration = 2,
                Image = 4483362458,
            })
        end)
    end
})

local RimsColorPicker = Tab:CreateColorPicker({
    Name = "Rims Color",
    Color = Color3.fromRGB(255,255,255),
    Flag = "rims_color",
    Callback = function(Value)
        pcall(function()
            local remote = ReplicatedStorage.Bnl["97634261-49f5-4f76-ae3e-c14da26b609f"]
            remote:FireServer(Value)
            
            Rayfield:Notify({
                Title = "Rims Color",
                Content = "Color changed!",
                Duration = 2,
                Image = 4483362458,
            })
        end)
    end
})

local Section3 = Tab:CreateSection("Car upgrades")

local EngineSlider = Tab:CreateSlider({
    Name = "Engine Level",
    Range = {1, 6},
    Increment = 1,
    Suffix = " level",
    CurrentValue = 1,
    Flag = "engine_level",
    Callback = function(Value)
        pcall(function()
            local remote = ReplicatedStorage.Bnl["742ec593-0e80-4fbe-987c-b53c8a45efb1"]
            remote:FireServer(Value)
            
            Rayfield:Notify({
                Title = "Engine Level",
                Content = "Set to level " .. Value,
                Duration = 2,
                Image = 4483362458,
            })
        end)
    end,
})

local BrakesSlider = Tab:CreateSlider({
    Name = "Brakes Level",
    Range = {1, 6},
    Increment = 1,
    Suffix = " level",
    CurrentValue = 1,
    Flag = "brakes_level",
    Callback = function(Value)
        pcall(function()
            local remote = ReplicatedStorage.Bnl["ae7cdaff-0ba0-4647-8cf1-a3c7e8f30228"]
            remote:FireServer(Value)
            
            Rayfield:Notify({
                Title = "Brakes Level",
                Content = "Set to level " .. Value,
                Duration = 2,
                Image = 4483362458,
            })
        end)
    end,
})

local ArmorSlider = Tab:CreateSlider({
    Name = "Armor Level",
    Range = {1, 6},
    Increment = 1,
    Suffix = " level",
    CurrentValue = 1,
    Flag = "armor_level",
    Callback = function(Value)
        pcall(function()
            local remote = ReplicatedStorage.Bnl["6b043f6c-0b28-46df-a735-73ee58d66ca0"]
            remote:FireServer(Value)
            
            Rayfield:Notify({
                Title = "Armor Level",
                Content = "Set to level " .. Value,
                Duration = 2,
                Image = 4483362458,
            })
        end)
    end,
})

local Section4 = Tab:CreateSection("License Plate")

local LicensePlateInput = Tab:CreateInput({
    Name = "License Plate Text",
    PlaceholderText = "Enter plate (max 6 chars)",
    RemoveTextAfterFocusLost = false,
    Flag = "license_plate_input",
    Callback = function(Text)
        -- Sauvegarder le texte mais ne pas l'appliquer automatiquement
    end,
})

Tab:CreateButton({
    Name = "Apply License Plate",
    Callback = function()
        local plateText = Rayfield.Flags["license_plate_input"].CurrentValue or ""
        
        if plateText == "" then
            Rayfield:Notify({
                Title = "Error",
                Content = "Please enter a plate text!",
                Duration = 3,
                Image = 4483362458,
            })
            return
        end
        
        -- Limiter à 6 caractères max
        plateText = string.upper(plateText:sub(1, 6))
        
        -- Diviser le texte en 3 parties (2-2-2 caractères)
        local part1 = plateText:sub(1, 2)
        local part2 = plateText:sub(3, 4)
        local part3 = plateText:sub(5, 6)
        
        -- Remplir avec des espaces si nécessaire
        if #part1 < 2 then part1 = part1 .. string.rep(" ", 2 - #part1) end
        if #part2 < 2 then part2 = part2 .. string.rep(" ", 2 - #part2) end
        if #part3 < 2 then part3 = part3 .. string.rep(" ", 2 - #part3) end
        
        pcall(function()
            local remote = ReplicatedStorage["6WP"]["43a9ce6a-daff-47f3-a3f0-3fdcee2fea1c"]
            remote:FireServer(1, part1, part2, part3)
            
            Rayfield:Notify({
                Title = "License Plate",
                Content = "Plate changed to: " .. plateText,
                Duration = 3,
                Image = 4483362458,
            })
        end)
    end,
})

local Section5 = Tab:CreateSection("Car repair")

Tab:CreateButton({
    Name = "Repair Car",
    Callback = function()
        pcall(function()
            local remote = ReplicatedStorage.Bnl["f0a778c6-ce1d-4d62-b34f-de692b648aca"]
            remote:FireServer()
            
            Rayfield:Notify({
                Title = "Repair",
                Content = "Car repaired!",
                Duration = 2,
                Image = 4483362458,
            })
        end)
    end,
})

-- Auto Repair Toggle
local autoRepairConnection = nil

Tab:CreateToggle({
   Name = "Auto Repair",
   CurrentValue = false,
   Flag = "auto_repair_toggle",
   Callback = function(Value)
       if Value then
           autoRepairConnection = RunService.Heartbeat:Connect(function()
               local vehicle = findPlayerVehicle()
               if vehicle then
                   pcall(function()
                       local remote = ReplicatedStorage.Bnl["f0a778c6-ce1d-4d62-b34f-de692b648aca"]
                       remote:FireServer()
                   end)
               end
               wait(0.5) -- Réparer toutes les 0.5 secondes
           end)
           
           Rayfield:Notify({
               Title = "Auto Repair",
               Content = "Activated!",
               Duration = 2,
               Image = 4483362458,
           })
       else
           if autoRepairConnection then
               autoRepairConnection:Disconnect()
               autoRepairConnection = nil
           end
       end
   end,
})

-- Anti Crash Damage
local Section6 = Tab:CreateSection("Protection")

local antiCrashConnection = nil

Tab:CreateToggle({
   Name = "Anti crash damage",
   CurrentValue = false,
   Flag = "car_anti_crash_toggle",
   Callback = function(Value)
       antiCrashEnabled = Value
       
       if Value then
           antiCrashConnection = RunService.Heartbeat:Connect(function()
               local vehicle = findPlayerVehicle()
               if not vehicle then return end
               
               local health = vehicle:FindFirstChild("Health")
               if health and health.Value then
                   health.Value = health.MaxValue or 100
               end
               
               -- Limiter les vitesses pour éviter les crashs
               for _, part in pairs(vehicle:GetDescendants()) do
                   if part:IsA("BasePart") then
                       local velocity = part.AssemblyLinearVelocity
                       if velocity.Magnitude > 300 then
                           part.AssemblyLinearVelocity = velocity.Unit * 300
                       end
                   end
               end
           end)
           
           Rayfield:Notify({
               Title = "Anti Crash",
               Content = "Activated!",
               Duration = 2,
               Image = 4483362458,
           })
       else
           if antiCrashConnection then
               antiCrashConnection:Disconnect()
               antiCrashConnection = nil
           end
       end
   end,
})

-- Cleanup
LocalPlayer.CharacterRemoving:Connect(function()
    if speedConnection then speedConnection:Disconnect() end
    if antiCrashConnection then antiCrashConnection:Disconnect() end
    if autoRepairConnection then autoRepairConnection:Disconnect() end
end)

local Tab = Window:CreateTab("🧨｜Weapon Mods", 0)

local Tab = Window:CreateTab("🚀｜Teleports", 0)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Section Vehicle
local Section = Tab:CreateSection("Vehicle")

-- Fonction pour trouver le véhicule du joueur
local function findPlayerVehicle()
    local vehiclesFolder = workspace:FindFirstChild("Vehicles")
    if not vehiclesFolder then
        return nil
    end
    
    local playerVehicle = vehiclesFolder:FindFirstChild(LocalPlayer.Name)
    if playerVehicle then
        return playerVehicle
    end
    
    for _, vehicle in pairs(vehiclesFolder:GetChildren()) do
        if vehicle:IsA("Model") then
            return vehicle
        end
    end
    
    return nil
end

-- Fonction pour entrer dans le véhicule
local function enterVehicle()
    local vehicle = findPlayerVehicle()
    
    if not vehicle then
        Rayfield:Notify({
            Title = "Error",
            Content = "Vehicle not found!",
            Duration = 3,
            Image = 4483362458,
        })
        return false
    end
    
    local driveSeat = vehicle:FindFirstChild("DriveSeat")
    
    if not driveSeat then
        Rayfield:Notify({
            Title = "Error",
            Content = "DriveSeat not found!",
            Duration = 3,
            Image = 4483362458,
        })
        return false
    end
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    humanoidRootPart.CFrame = CFrame.new(driveSeat.Position + Vector3.new(0, 3, 0))
    
    wait(0.1)
    
    local success = pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("Bnl")
        if remote then
            local fireRemote = remote:FindFirstChild("fdffc7c3-4c83-4693-8a33-380ed2d60083")
            if fireRemote then
                fireRemote:FireServer(driveSeat, "Oj2", false)
            end
        end
    end)
    
    wait(0.3)
    return success
end

-- Fonction pour sortir du véhicule
local function exitVehicle()
    local vehicle = findPlayerVehicle()
    if not vehicle then return end
    
    local driveSeat = vehicle:FindFirstChild("DriveSeat")
    if not driveSeat then return end
    
    pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("Bnl")
        if remote then
            local fireRemote = remote:FindFirstChild("fdffc7c3-4c83-4693-8a33-380ed2d60083")
            if fireRemote then
                fireRemote:FireServer(driveSeat, "Oj2", true)
            end
        end
    end)
end

-- Téléportation sécurisée en voiture (VERSION AMÉLIORÉE)
local isTeleporting = false

local function safeCarTeleport(targetPosition)
    if isTeleporting then
        Rayfield:Notify({
            Title = "Warning",
            Content = "Already teleporting!",
            Duration = 2,
            Image = 4483362458,
        })
        return
    end
    
    isTeleporting = true
    
    Rayfield:Notify({
        Title = "Teleporting",
        Content = "Entering vehicle...",
        Duration = 2,
        Image = 4483362458,
    })
    
    local enteredCar = enterVehicle()
    
    if not enteredCar then
        isTeleporting = false
        Rayfield:Notify({
            Title = "Error",
            Content = "Could not enter vehicle!",
            Duration = 3,
            Image = 4483362458,
        })
        return
    end
    
    wait(0.5)
    
    local vehicle = findPlayerVehicle()
    if not vehicle then
        isTeleporting = false
        Rayfield:Notify({
            Title = "Error",
            Content = "Vehicle lost!",
            Duration = 3,
            Image = 4483362458,
        })
        return
    end
    
    local primaryPart = vehicle.PrimaryPart or vehicle:FindFirstChild("DriveSeat") or vehicle:FindFirstChildWhichIsA("BasePart")
    
    if not primaryPart then
        isTeleporting = false
        exitVehicle()
        return
    end
    
    Rayfield:Notify({
        Title = "Teleporting",
        Content = "Driving to location...",
        Duration = 2,
        Image = 4483362458,
    })
    
    -- Trouver le sol exact à la destination
    local rayOriginDest = targetPosition + Vector3.new(0, 100, 0)
    local rayDirectionDest = Vector3.new(0, -200, 0)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {vehicle, LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local destRayResult = workspace:Raycast(rayOriginDest, rayDirectionDest, raycastParams)
    
    -- Ajuster la position de destination au niveau du sol (légèrement dans le sol)
    if destRayResult then
        targetPosition = Vector3.new(targetPosition.X, destRayResult.Position.Y + 0.5, targetPosition.Z)
    end
    
    local startPos = primaryPart.Position
    local distance = (targetPosition - startPos).Magnitude
    local speed = 580
    local speedInStuds = speed * 0.277778
    local duration = distance / speedInStuds
    
    local connection
    local elapsed = 0
    
    connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not isTeleporting then
            connection:Disconnect()
            return
        end
        
        elapsed = elapsed + deltaTime
        local alpha = math.min(elapsed / duration, 1)
        
        local currentPos = startPos:Lerp(targetPosition, alpha)
        
        -- Raycast pour suivre le sol UNIQUEMENT sur le terrain
        local rayOrigin = currentPos + Vector3.new(0, 50, 0)
        local rayDirection = Vector3.new(0, -100, 0)
        
        local raycastParamsGround = RaycastParams.new()
        raycastParamsGround.FilterDescendantsInstances = {vehicle, LocalPlayer.Character}
        raycastParamsGround.FilterType = Enum.RaycastFilterType.Blacklist
        
        local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParamsGround)
        
        if rayResult then
            local hitPart = rayResult.Instance
            
            -- Vérifier si c'est du terrain naturel (pas un bâtiment)
            local isNaturalGround = false
            
            -- Si c'est le Terrain de Roblox
            if hitPart:IsA("Terrain") then
                isNaturalGround = true
            -- Si c'est une partie nommée "Ground", "Road", "Terrain", etc.
            elseif hitPart.Name:lower():match("ground") or 
                   hitPart.Name:lower():match("road") or 
                   hitPart.Name:lower():match("terrain") or
                   hitPart.Name:lower():match("floor") or
                   hitPart.Name:lower():match("baseplate") then
                isNaturalGround = true
            -- Si la partie est proche du niveau Y de départ (tolérance)
            elseif math.abs(rayResult.Position.Y - startPos.Y) < 15 then
                isNaturalGround = true
            end
            
            -- Suivre le sol uniquement si c'est du terrain naturel (légèrement dans le sol)
            if isNaturalGround then
                currentPos = Vector3.new(currentPos.X, rayResult.Position.Y + 0.5, currentPos.Z)
            else
                -- Sinon, maintenir l'altitude d'origine
                currentPos = Vector3.new(currentPos.X, startPos.Y, currentPos.Z)
            end
        end
        
        if vehicle and vehicle.Parent then
            for _, part in pairs(vehicle:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.Velocity = Vector3.new(0, 0, 0)
                    part.RotVelocity = Vector3.new(0, 0, 0)
                end
            end
            
            local direction = (targetPosition - currentPos).Unit
            local lookAt = CFrame.new(currentPos, currentPos + direction)
            
            primaryPart.CFrame = lookAt
        else
            connection:Disconnect()
            isTeleporting = false
            return
        end
        
        if alpha >= 1 then
            connection:Disconnect()
            
            -- Descendre directement au sol à l'arrivée (légèrement dans le sol)
            wait(0.1)
            if vehicle and vehicle.Parent then
                local finalRayOrigin = targetPosition + Vector3.new(0, 50, 0)
                local finalRayDirection = Vector3.new(0, -100, 0)
                
                local finalRayResult = workspace:Raycast(finalRayOrigin, finalRayDirection, raycastParamsGround)
                
                if finalRayResult then
                    local finalPos = Vector3.new(targetPosition.X, finalRayResult.Position.Y + 0.5, targetPosition.Z)
                    primaryPart.CFrame = CFrame.new(finalPos)
                end
            end
            
            wait(0.2)
            for _, part in pairs(vehicle:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
            
            isTeleporting = false
            
            Rayfield:Notify({
                Title = "Success",
                Content = "Arrived at destination!",
                Duration = 3,
                Image = 4483362458,
            })
        end
    end)
end

local TeleportToVehicleButton = Tab:CreateButton({
    Name = "Teleport to Vehicle",
    Callback = function()
        enterVehicle()
    end,
})

local ExitVehicleButton = Tab:CreateButton({
    Name = "Exit Vehicle",
    Callback = function()
        exitVehicle()
    end,
})

-- ILLEGAL
local Section2 = Tab:CreateSection("Illegal")

Tab:CreateButton({
    Name = "Smugler",
    Callback = function()
        safeCarTeleport(Vector3.new(806.52, -22.27, -1509.20))
    end,
})

Tab:CreateButton({
    Name = "Dealer port",
    Callback = function()
        safeCarTeleport(Vector3.new(472.37, 5.47, 2332.09))
    end,
})

-- JOBS
local Section3 = Tab:CreateSection("Jobs")

Tab:CreateButton({
    Name = "Fire station",
    Callback = function()
        safeCarTeleport(Vector3.new(-966.18, 5.89, 3893.51))
    end,
})

Tab:CreateButton({
    Name = "Police station",
    Callback = function()
        safeCarTeleport(Vector3.new(-1709.80, 5.47, 2745.59))
    end,
})

Tab:CreateButton({
    Name = "Bus",
    Callback = function()
        safeCarTeleport(Vector3.new(-1695.07, 5.89, -1276.51))
    end,
})

Tab:CreateButton({
    Name = "Truck",
    Callback = function()
        safeCarTeleport(Vector3.new(701.12, 6.89, 1456.35))
    end,
})

-- ROBBERY
local Section4 = Tab:CreateSection("Robbery")

Tab:CreateButton({
    Name = "Bank (out)",
    Callback = function()
        safeCarTeleport(Vector3.new(-1132.52, 5.47, 3163.31))
    end,
})

Tab:CreateButton({
    Name = "Bank (in)",
    Callback = function()
        safeCarTeleport(Vector3.new(-1232.90, 7.85, 3162.99))
    end,
})

Tab:CreateButton({
    Name = "Bijou",
    Callback = function()
        safeCarTeleport(Vector3.new(-342.34, 5.47, 3540.93))
    end,
})

Tab:CreateButton({
    Name = "Nightclub",
    Callback = function()
        safeCarTeleport(Vector3.new(-1858.91, 5.68, 3012.52))
    end,
})

Tab:CreateButton({
    Name = "Farm shop",
    Callback = function()
        safeCarTeleport(Vector3.new(-909.49, 5.38, -1171.52))
    end,
})

Tab:CreateButton({
    Name = "Tools shop",
    Callback = function()
        safeCarTeleport(Vector3.new(-748.87, 5.79, 659.88))
    end,
})

Tab:CreateButton({
    Name = "Clothes shop",
    Callback = function()
        safeCarTeleport(Vector3.new(470.93, 5.56, -1447.42))
    end,
})

Tab:CreateButton({
    Name = "Yellow container",
    Callback = function()
        safeCarTeleport(Vector3.new(1120.20, 28.67, 2330.81))
    end,
})

Tab:CreateButton({
    Name = "Green container",
    Callback = function()
        safeCarTeleport(Vector3.new(1166.88, 28.67, 2153.92))
    end,
})

-- GAS STATIONS
local Section5 = Tab:CreateSection("Gas Stations")

Tab:CreateButton({
    Name = "Ares",
    Callback = function()
        safeCarTeleport(Vector3.new(-867.67, 5.22, 1509.24))
    end,
})

Tab:CreateButton({
    Name = "Osso",
    Callback = function()
        safeCarTeleport(Vector3.new(-39.14, 7.15, -757.37))
    end,
})

Tab:CreateButton({
    Name = "GAS n go",
    Callback = function()
        safeCarTeleport(Vector3.new(-1544.44, 5.70, 3802.51))
    end,
})

-- OTHERS
local Section6 = Tab:CreateSection("Others")

Tab:CreateButton({
    Name = "Hospital",
    Callback = function()
        safeCarTeleport(Vector3.new(-264.18, 5.47, 1075.02))
    end,
})

Tab:CreateButton({
    Name = "Dealership",
    Callback = function()
        safeCarTeleport(Vector3.new(-1401.72, 5.48, 951.35))
    end,
})

Tab:CreateButton({
    Name = "Prison (out)",
    Callback = function()
        safeCarTeleport(Vector3.new(-568.37, 5.48, 2852.52))
    end,
})

Tab:CreateButton({
    Name = "Prison (in)",
    Callback = function()
        safeCarTeleport(Vector3.new(-503.99, 7.98, 3048.56))
    end,
})

Tab:CreateButton({
    Name = "ADAC",
    Callback = function()
        safeCarTeleport(Vector3.new(-326.70, 5.64, 508.42))
    end,
})

Tab:CreateButton({
    Name = "Tuning garage",
    Callback = function()
        safeCarTeleport(Vector3.new(-1445.57, 5.63, 96.19))
    end,
})

-- EMERGENCY
local Section7 = Tab:CreateSection("Emergency")

Tab:CreateButton({
    Name = "STOP Teleport",
    Callback = function()
        isTeleporting = false
        
        local vehicle = findPlayerVehicle()
        if vehicle then
            for _, part in pairs(vehicle:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                    part.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end
        
        Rayfield:Notify({
            Title = "Stopped",
            Content = "Teleportation stopped!",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

local Tab = Window:CreateTab("💶｜Auto Farm", 0)

local Tab = Window:CreateTab("👮｜Police", 0)

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Remote
local DamageRemote = ReplicatedStorage.Bnl["91af7f12-cf3e-46cd-955f-87212cb5a1a9"]

-- Variables
local spinConnection
local antiDamageConnection
local originalFireServer = DamageRemote.FireServer
local selectedPlayer = nil

-- Fonction pour trouver le véhicule du joueur
local function findPlayerVehicle(playerName)
    playerName = playerName or LocalPlayer.Name
    local vehiclesFolder = workspace:FindFirstChild("Vehicles")
    if not vehiclesFolder then return nil end
    
    local playerVehicle = vehiclesFolder:FindFirstChild(playerName)
    return playerVehicle
end

-- Fonction pour obtenir la liste des joueurs
local function getPlayerList()
    local playerList = {}
    for _, player in pairs(Players:GetPlayers()) do
        table.insert(playerList, player.Name)
    end
    return playerList
end

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Remote
local DamageRemote = ReplicatedStorage.Bnl["91af7f12-cf3e-46cd-955f-87212cb5a1a9"]

-- Variables
local spinConnection
local originalFireServer
local originalNamecall
local selectedPlayer = nil

-- Fonction pour trouver le véhicule du joueur
local function findPlayerVehicle(playerName)
    playerName = playerName or LocalPlayer.Name
    local vehiclesFolder = workspace:FindFirstChild("Vehicles")
    if not vehiclesFolder then return nil end
    
    local playerVehicle = vehiclesFolder:FindFirstChild(playerName)
    return playerVehicle
end

-- Fonction pour obtenir la liste des joueurs
local function getPlayerList()
    local playerList = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name ~= LocalPlayer.Name then -- Exclure soi-même
            table.insert(playerList, player.Name)
        end
    end
    return playerList
end

local Tab = Window:CreateTab("🤡｜Troll", 0)

local Section = Tab:CreateSection("Spin")

-- Variables pour le spin
local spinEnabled = false
local spinSpeed = 10

local Toggle = Tab:CreateToggle({
   Name = "Spin",
   CurrentValue = false,
   Flag = "spin_toggle",
   Callback = function(Value)
       spinEnabled = Value
       
       if Value then
           spinConnection = RunService.Heartbeat:Connect(function()
               local vehicle = findPlayerVehicle()
               if not vehicle then return end
               
               -- Appel direct au remote
               pcall(function()
                   DamageRemote:FireServer(vehicle, spinSpeed)
               end)
           end)
           
           Rayfield:Notify({
               Title = "Spin",
               Content = "Activated!",
               Duration = 2,
               Image = 4483362458,
           })
       else
           if spinConnection then
               spinConnection:Disconnect()
               spinConnection = nil
           end
       end
   end,
})

local Slider = Tab:CreateSlider({
   Name = "Spin speed",
   Range = {10, 500},
   Increment = 10,
   Suffix = "speed",
   CurrentValue = 10,
   Flag = "spin_speed",
   Callback = function(Value)
       spinSpeed = Value
   end,
})

-- Section Kill Car
local Section3 = Tab:CreateSection("Kill Car")

local Dropdown = Tab:CreateDropdown({
   Name = "Select Player",
   Options = getPlayerList(),
   CurrentOption = getPlayerList()[1] and {getPlayerList()[1]} or {"No players"},
   MultipleOptions = false,
   Flag = "player_dropdown",
   Callback = function(Options)
       selectedPlayer = Options[1]
   end,
})

-- Mettre à jour la liste des joueurs
Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    Dropdown:Refresh(getPlayerList(), true)
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    Dropdown:Refresh(getPlayerList(), true)
end)

local Button = Tab:CreateButton({
   Name = "Kill Car (18x)",
   Callback = function()
       if not selectedPlayer or selectedPlayer == "No players" then
           Rayfield:Notify({
               Title = "Error",
               Content = "No player selected!",
               Duration = 2,
               Image = 4483362458,
           })
           return
       end
       
       local targetVehicle = findPlayerVehicle(selectedPlayer)
       if not targetVehicle then
           Rayfield:Notify({
               Title = "Error",
               Content = selectedPlayer .. " has no vehicle!",
               Duration = 2,
               Image = 4483362458,
           })
           return
       end
       
       -- Spam le remote 18 fois
       task.spawn(function()
           for i = 1, 18 do
               pcall(function()
                   DamageRemote:FireServer(targetVehicle, 2601.1297832362407)
               end)
               task.wait(0.1)
           end
           
           Rayfield:Notify({
               Title = "Kill Car",
               Content = "Sent 18 packets to " .. selectedPlayer .. "'s car!",
               Duration = 3,
               Image = 4483362458,
           })
       end)
   end,
})

-- Section Anti Damage
local Section2 = Tab:CreateSection("Protection")

local antiDamageEnabled = false

Tab:CreateToggle({
   Name = "Anti crash damage",
   CurrentValue = false,
   Flag = "car_anti_crash_toggle",
   Callback = function(Value)
       antiDamageEnabled = Value
       
       if Value then
           -- Hook avec __namecall (plus fiable)
           originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
               local method = getnamecallmethod()
               local args = {...}
               
               if self == DamageRemote and method == "FireServer" then
                   local vehicle = findPlayerVehicle()
                   
                   -- Bloquer si c'est notre véhicule ET pas notre appel
                   if args[1] == vehicle and not spinEnabled then
                       return -- Bloque l'appel
                   end
               end
               
               return originalNamecall(self, ...)
           end)
           
           Rayfield:Notify({
               Title = "Anti Damage",
               Content = "Protection enabled!",
               Duration = 2,
               Image = 4483362458,
           })
       else
           if originalNamecall then
               hookmetamethod(game, "__namecall", originalNamecall)
           end
           
           Rayfield:Notify({
               Title = "Anti Damage",
               Content = "Deactivated",
               Duration = 2,
               Image = 4483362458,
           })
       end
   end,
})

-- Cleanup
LocalPlayer.CharacterRemoving:Connect(function()
    if spinConnection then spinConnection:Disconnect() end
    if originalNamecall then
        hookmetamethod(game, "__namecall", originalNamecall)
    end
end)

local Tab = Window:CreateTab("📦｜Miscs", 0)

local Tab = Window:CreateTab("✏️｜Credits", 0)



local Label = Tab:CreateLabel("Created & owned by Azfa & Vamp 🧛", 0, Color3.fromRGB(255, 255, 255), false) -- Title, Icon, Color, IgnoreTheme

Rayfield:LoadConfiguration()
