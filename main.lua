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


-- [PARTIE AIMBOT - À ajouter après la ligne "local Tab = Window:CreateTab("🛡️｜Aimbot", 0)"]

local Section = Tab:CreateSection("Aimbot Settings")

-- Variables globales aimbot
local aimbotEnabled = false
local silentAimEnabled = false
local rageBotEnabled = false
local aimbotMobile = false
local fovSize = 150
local fovVisible = false
local teamCheck = true
local aliveCheck = true
local targetPart = "Head"

local fovCircle = nil
local aimbotConnection = nil
local rageBotConnection = nil

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Créer le cercle FOV
local function createFOVCircle()
    if fovCircle then
        fovCircle:Remove()
    end
    
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 2
    fovCircle.NumSides = 50
    fovCircle.Radius = fovSize
    fovCircle.Filled = false
    fovCircle.Transparency = 1
    fovCircle.Color = Color3.fromRGB(255, 255, 255)
    fovCircle.Visible = fovVisible
    fovCircle.ZIndex = 999
end

-- Update position du cercle
spawn(function()
    RunService.RenderStepped:Connect(function()
        if fovCircle then
            fovCircle.Position = UserInputService:GetMouseLocation()
            fovCircle.Radius = fovSize
            fovCircle.Visible = fovVisible and (aimbotEnabled or silentAimEnabled)
        end
    end)
end)

-- Fonction pour trouver la cible la plus proche
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = fovSize
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Team check
            if teamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local targetPartObj = character:FindFirstChild(targetPart)
            
            if not targetPartObj then continue end
            
            -- Alive check
            if aliveCheck and (not humanoid or humanoid.Health <= 0) then
                continue
            end
            
            local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPartObj.Position)
            
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer
end

-- Aimbot classique
local function startAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
    end
    
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not aimbotEnabled then return end
        
        local target = getClosestPlayer()
        if target and target.Character then
            local targetPartObj = target.Character:FindFirstChild(targetPart)
            if targetPartObj then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPartObj.Position)
            end
        end
    end)
end

-- Silent Aim (hook mouse)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if silentAimEnabled and method == "FireServer" and tostring(self) == "ShootEvent" then
        local target = getClosestPlayer()
        if target and target.Character then
            local targetPartObj = target.Character:FindFirstChild(targetPart)
            if targetPartObj then
                args[2] = targetPartObj.Position -- Modifier la position du tir
            end
        end
    end
    
    return oldNamecall(self, unpack(args))
end)

-- Rage Bot (tir automatique)
local function startRageBot()
    if rageBotConnection then
        rageBotConnection:Disconnect()
    end
    
    rageBotConnection = RunService.Heartbeat:Connect(function()
        if not rageBotEnabled then return end
        
        local target = getClosestPlayer()
        if target and target.Character then
            local targetPartObj = target.Character:FindFirstChild(targetPart)
            if targetPartObj then
                -- Viser
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPartObj.Position)
                
                -- Tirer automatiquement
                pcall(function()
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("ShootEvent") then
                        tool.ShootEvent:FireServer(targetPartObj.Position, targetPartObj)
                    end
                end)
            end
        end
    end)
end

createFOVCircle()

-- UI Aimbot
local AimbotToggle = Tab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Flag = "aimbot_enabled",
    Callback = function(Value)
        aimbotEnabled = Value
        if Value then
            startAimbot()
        else
            if aimbotConnection then
                aimbotConnection:Disconnect()
            end
        end
    end,
})

local SilentAimToggle = Tab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Flag = "silent_aim",
    Callback = function(Value)
        silentAimEnabled = Value
    end,
})

local RageBotToggle = Tab:CreateToggle({
    Name = "Rage Bot (Auto Shoot)",
    CurrentValue = false,
    Flag = "rage_bot",
    Callback = function(Value)
        rageBotEnabled = Value
        if Value then
            startRageBot()
        else
            if rageBotConnection then
                rageBotConnection:Disconnect()
            end
        end
    end,
})

local MobileToggle = Tab:CreateToggle({
    Name = "Mobile Aimbot",
    CurrentValue = false,
    Flag = "mobile_aimbot",
    Callback = function(Value)
        aimbotMobile = Value
        -- Pour mobile: activer auto-lock au touch
    end,
})

local TeamCheckToggle = Tab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Flag = "team_check",
    Callback = function(Value)
        teamCheck = Value
    end,
})

local AliveCheckToggle = Tab:CreateToggle({
    Name = "Alive Check",
    CurrentValue = true,
    Flag = "alive_check",
    Callback = function(Value)
        aliveCheck = Value
    end,
})

local FOVToggle = Tab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = false,
    Flag = "fov_visible",
    Callback = function(Value)
        fovVisible = Value
    end,
})

local FOVSlider = Tab:CreateSlider({
    Name = "FOV Size",
    Range = {50, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 150,
    Flag = "fov_size",
    Callback = function(Value)
        fovSize = Value
    end,
})

local FOVColorPicker = Tab:CreateColorPicker({
    Name = "FOV Color",
    Color = Color3.fromRGB(255,255,255),
    Flag = "fov_color",
    Callback = function(Value)
        if fovCircle then
            fovCircle.Color = Value
        end
    end
})

local Dropdown = Tab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head","Torso","HumanoidRootPart"},
    CurrentOption = "Head",
    Flag = "target_part",
    Callback = function(Option)
        targetPart = Option
    end,
})

local AimbotKeybind = Tab:CreateKeybind({
    Name = "Aimbot Keybind",
    CurrentKeybind = "E",
    HoldToInteract = true,
    Flag = "aimbot_keybind",
    Callback = function(Keybind)
        -- Hold E pour aim
        aimbotEnabled = Keybind
        if Keybind then
            startAimbot()
        else
            if aimbotConnection then
                aimbotConnection:Disconnect()
            end
        end
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

local Section = Tab:CreateSection("Car Fly")

local Toggle = Tab:CreateToggle({
   Name = "Car fly",
   CurrentValue = false,
   Flag = "car_fly", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   -- The function that takes place when the toggle is pressed
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local CarFlySpeed = Tab:CreateSlider({
    Name = "Car Fly Speed",
    Range = {50, 500},
    Increment = 10,
    Suffix = "speed",
    CurrentValue = 120,
    Flag = "fly_speed",
    Callback = function(Value)
    end,
})

local CarFlyKeybind = Tab:CreateKeybind({
    Name = "Car Fly Keybind",
    CurrentKeybind = "K",
    HoldToInteract = false,
    Flag = "car_fly_keybind",
    Callback = function(Keybind)
    end,
})

local Section = Tab:CreateSection("Car boost")

local CarMaxSpeed = Tab:CreateSlider({
    Name = "Car Max Speed",
    Range = {10, 480},
    Increment = 10,
    Suffix = "speed",
    CurrentValue = 200,
    Flag = "car_max_speed",
    Callback = function(Value)
    end,
})

local CarAccel = Tab:CreateSlider({
    Name = "Car Acceleration",
    Range = {0, 10000},
    Increment = 30,
    Suffix = "speed",
    CurrentValue = 0,
    Flag = "car_accel",
    Callback = function(Value)
    end,
})

local Toggle = Tab:CreateToggle({
   Name = "Enable Acceleration",
   CurrentValue = false,
   Flag = "car_accel_toggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   -- The function that takes place when the toggle is pressed
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local Section = Tab:CreateSection("Car tuning")

local Tab = Window:CreateTab("🧨｜Weapon Mods", 0)

local Tab = Window:CreateTab("🚀｜Teleports", 0)

local Tab = Window:CreateTab("💶｜Auto Farm", 0)

local Tab = Window:CreateTab("👮｜Police", 0)

local Tab = Window:CreateTab("🤡｜troll", 0)

local Section = Tab:CreateSection("Spin")

local Toggle = Tab:CreateToggle({
   Name = "Spin",
   CurrentValue = false,
   Flag = "spin_toggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   -- The function that takes place when the toggle is pressed
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local Slider = Tab:CreateSlider({
   Name = "Spin speed",
   Range = {10, 500},
   Increment = 10,
   Suffix = "speed",
   CurrentValue = 10,
   Flag = "spin_speed", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   -- The function that takes place when the slider changes
   -- The variable (Value) is a number which correlates to the value the slider is currently at
   end,
})

local Tab = Window:CreateTab("📦｜Miscs", 0)

local Tab = Window:CreateTab("✏️｜Credits", 0)



local Label = Tab:CreateLabel("Created & owned by Azfa & Vamp 🧛", 4483362458, Color3.fromRGB(255, 255, 255), false) -- Title, Icon, Color, IgnoreTheme

Rayfield:LoadConfiguration()
