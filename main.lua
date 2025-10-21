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

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Section Car Level
local Section = Tab:CreateSection("Car Level")

-- Fonction pour trouver le vehicule du joueur
local function getPlayerVehicle()
    local vehiclesFolder = game.Workspace:FindFirstChild("Vehicles")
    if not vehiclesFolder then return nil end
    
    local playerVehicle = vehiclesFolder:FindFirstChild(LocalPlayer.Name)
    return playerVehicle
end

-- Fonction pour convertir Color3 en format hexadecimal
local function color3ToHex(color)
    local r = math.floor(color.R * 255)
    local g = math.floor(color.G * 255)
    local b = math.floor(color.B * 255)
    return string.format("%02x%02x%02x", r, g, b)
end

-- Fonction pour convertir hex en Color3
local function hexToColor3(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    return Color3.new(r, g, b)
end

-- Slider Engine Level
local EngineSlider = Tab:CreateSlider({
    Name = "Engine Level",
    Range = {1, 6},
    Increment = 1,
    Suffix = "Level",
    CurrentValue = 1,
    Flag = "EngineLevel",
    Callback = function(Value)
        pcall(function()
            local vehicle = getPlayerVehicle()
            if vehicle then
                vehicle.engineLevel = Value
                OrionLib:MakeNotification({
                    Name = "Engine Level",
                    Content = "Engine level set to " .. Value,
                    Image = "rbxassetid://4483345998",
                    Time = 2
                })
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Vehicle not found!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end)
    end,
})

-- Slider Brakes Level
local BrakesSlider = Tab:CreateSlider({
    Name = "Brakes Level",
    Range = {1, 6},
    Increment = 1,
    Suffix = "Level",
    CurrentValue = 1,
    Flag = "BrakesLevel",
    Callback = function(Value)
        pcall(function()
            local vehicle = getPlayerVehicle()
            if vehicle then
                vehicle.brakesLevel = Value
                OrionLib:MakeNotification({
                    Name = "Brakes Level",
                    Content = "Brakes level set to " .. Value,
                    Image = "rbxassetid://4483345998",
                    Time = 2
                })
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Vehicle not found!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end)
    end,
})

-- Slider Armor Level
local ArmorSlider = Tab:CreateSlider({
    Name = "Armor Level",
    Range = {1, 6},
    Increment = 1,
    Suffix = "Level",
    CurrentValue = 1,
    Flag = "ArmorLevel",
    Callback = function(Value)
        pcall(function()
            local vehicle = getPlayerVehicle()
            if vehicle then
                vehicle.armorLevel = Value
                OrionLib:MakeNotification({
                    Name = "Armor Level",
                    Content = "Armor level set to " .. Value,
                    Image = "rbxassetid://4483345998",
                    Time = 2
                })
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Vehicle not found!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end)
    end,
})

-- ColorPicker Car Color
local CarColorPicker = Tab:CreateColorpicker({
    Name = "Car Color",
    Color = hexToColor3("e1b82d"), -- Couleur par defaut
    Flag = "CarColor",
    Callback = function(Value)
        pcall(function()
            local vehicle = getPlayerVehicle()
            if vehicle then
                local hexColor = color3ToHex(Value)
                vehicle.color = hexColor
                OrionLib:MakeNotification({
                    Name = "Car Color",
                    Content = "Color changed to #" .. hexColor,
                    Image = "rbxassetid://4483345998",
                    Time = 2
                })
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Vehicle not found!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end)
    end
})

-- ColorPicker Rims Color
local RimsColorPicker = Tab:CreateColorpicker({
    Name = "Rims Color",
    Color = hexToColor3("e0e5e5"), -- Couleur par defaut
    Flag = "RimsColor",
    Callback = function(Value)
        pcall(function()
            local vehicle = getPlayerVehicle()
            if vehicle then
                local hexColor = color3ToHex(Value)
                vehicle.rimColor = hexColor
                OrionLib:MakeNotification({
                    Name = "Rims Color",
                    Content = "Rims color changed to #" .. hexColor,
                    Image = "rbxassetid://4483345998",
                    Time = 2
                })
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Vehicle not found!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end)
    end
})

-- Bouton Infinite Fuel
local InfiniteFuelButton = Tab:CreateButton({
    Name = "Infinite Fuel",
    Callback = function()
        pcall(function()
            local vehicle = getPlayerVehicle()
            if vehicle then
                vehicle.currentFuel = 99999999999
                OrionLib:MakeNotification({
                    Name = "Infinite Fuel",
                    Content = "Fuel set to infinite!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Vehicle not found!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end)
    end,
})

-- Bouton Anti Crash Damage
local AntiCrashButton = Tab:CreateButton({
    Name = "Anti Crash Damage",
    Callback = function()
        pcall(function()
            local vehicle = getPlayerVehicle()
            if vehicle then
                vehicle.currentHealth = 9999999999
                OrionLib:MakeNotification({
                    Name = "Anti Crash",
                    Content = "Vehicle health set to max!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Vehicle not found!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end)
    end,
})

-- Auto-refresh des valeurs quand on change de vehicule
spawn(function()
    while wait(2) do
        pcall(function()
            local vehicle = getPlayerVehicle()
            if vehicle then
                -- Mettre a jour les sliders avec les valeurs actuelles
                if vehicle:FindFirstChild("engineLevel") then
                    EngineSlider:Set(vehicle.engineLevel)
                end
                if vehicle:FindFirstChild("brakesLevel") then
                    BrakesSlider:Set(vehicle.brakesLevel)
                end
                if vehicle:FindFirstChild("armorLevel") then
                    ArmorSlider:Set(vehicle.armorLevel)
                end
            end
        end)
    end
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
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Remote
local TaserRemote = ReplicatedStorage.Bnl["c6011f40-2809-4686-a297-33283dd11715"]

-- Variables
local autoTaserConnection
local autoTaserEnabled = false

-- Fonction pour vérifier si le joueur a le taser équipé
local function hasTaserEquipped()
    local character = LocalPlayer.Character
    if not character then return false end
    
    local taser = character:FindFirstChild("Taser")
    return taser ~= nil
end

-- Fonction pour trouver le joueur Wanted le plus proche
local function findClosestWantedPlayer()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local myPosition = character.HumanoidRootPart.Position
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local targetChar = player.Character
            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                -- Vérifier si le joueur est dans l'équipe Wanted
                local humanoid = targetChar:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    -- Vérifier la team (ajuste selon le nom exact dans le jeu)
                    if player.Team and (player.Team.Name == "Wanted" or player.Team.Name == "Criminal" or player.TeamColor == BrickColor.new("Really red")) then
                        local distance = (targetChar.HumanoidRootPart.Position - myPosition).Magnitude
                        
                        -- Seulement si à portée raisonnable (ex: 50 studs)
                        if distance < 50 and distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Section Auto Taser
local Section = Tab:CreateSection("Auto Taser")

local Toggle = Tab:CreateToggle({
   Name = "Auto Taser",
   CurrentValue = false,
   Flag = "auto_taser_toggle",
   Callback = function(Value)
       autoTaserEnabled = Value
       
       if Value then
           autoTaserConnection = RunService.Heartbeat:Connect(function()
               -- Vérifier si on a le taser équipé
               if not hasTaserEquipped() then return end
               
               local character = LocalPlayer.Character
               if not character or not character:FindFirstChild("Taser") then return end
               
               local taser = character.Taser
               local targetPlayer = findClosestWantedPlayer()
               
               if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                   local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
                   local myPosition = character.HumanoidRootPart.Position
                   
                   -- Calculer la direction vers la cible
                   local direction = (targetPosition - myPosition).Unit
                   
                   pcall(function()
                       TaserRemote:FireServer(
                           taser,
                           targetPosition,
                           direction
                       )
                   end)
               end
           end)
           
           Rayfield:Notify({
               Title = "Auto Taser",
               Content = "Activated! Equip taser to use.",
               Duration = 2,
               Image = 4483362458,
           })
       else
           if autoTaserConnection then
               autoTaserConnection:Disconnect()
               autoTaserConnection = nil
           end
           
           Rayfield:Notify({
               Title = "Auto Taser",
               Content = "Deactivated",
               Duration = 2,
               Image = 4483362458,
           })
       end
   end,
})

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Remotes
local CloseGarageRemote = ReplicatedStorage.Bnl["5778d7bc-766f-4bac-a776-90dbae34de81"]
local RepairRemote = ReplicatedStorage.Bnl["82989333-9a1a-4577-8df4-a09797284011"]
local CarColorRemote = ReplicatedStorage.Bnl["a57a7cba-6681-43f3-bfe3-72e368ea953e"]
local LicensePlateRemote = ReplicatedStorage["6WP"]["43a9ce6a-daff-47f3-a3f0-3fdcee2fea1c"]
local EngineRemote = ReplicatedStorage.Bnl["742ec593-0e80-4fbe-987c-b53c8a45efb1"]
local BrakeRemote = ReplicatedStorage.Bnl["ae7cdaff-0ba0-4647-8cf1-a3c7e8f30228"]
local ArmorRemote = ReplicatedStorage.Bnl["6b043f6c-0b28-46df-a735-73ee58d66ca0"]
local WheelColorRemote = ReplicatedStorage.Bnl["97634261-49f5-4f76-ae3e-c14da26b609f"]
local PayRemote = ReplicatedStorage.Bnl["f0a778c6-ce1d-4d62-b34f-de692b648aca"]

-- Variables
local selectedEngine = 6
local selectedBrake = 6
local selectedArmor = 6
local selectedCarColor = Color3.fromRGB(255, 255, 255)
local selectedWheelColor = Color3.fromRGB(255, 255, 255)
local plateText1 = "AA"
local plateText2 = "EN"
local plateText3 = "86"

-- Creer le Tab Garage
local GarageTab = Window:CreateTab("🔧｜Garage", 0)

-- Section Upgrades
local Section1 = GarageTab:CreateSection("Performance Upgrades")

local SLIDERENGINE = GarageTab:CreateSlider({
   Name = "Engine Level",
   Range = {0, 6},
   Increment = 1,
   Suffix = " lvl",
   CurrentValue = 6,
   Flag = "engine_level",
   Callback = function(Value)
       selectedEngine = Value
   end,
})

local BRAKESLIDER = GarageTab:CreateSlider({
   Name = "Brake Level",
   Range = {0, 6},
   Increment = 1,
   Suffix = " lvl",
   CurrentValue = 6,
   Flag = "brake_level",
   Callback = function(Value)
       selectedBrake = Value
   end,
})

local ARMORSLIDER = GarageTab:CreateSlider({
   Name = "Armor Level",
   Range = {0, 6},
   Increment = 1,
   Suffix = " lvl",
   CurrentValue = 6,
   Flag = "armor_level",
   Callback = function(Value)
       selectedArmor = Value
   end,
})

local BUTTONAPPLY = GarageTab:CreateButton({
   Name = "Apply Upgrades (FREE)",
   Callback = function()
       local success = pcall(function()
           EngineRemote:FireServer(selectedEngine)
           task.wait(0.1)
           BrakeRemote:FireServer(selectedBrake)
           task.wait(0.1)
           ArmorRemote:FireServer(selectedArmor)
           task.wait(0.1)
           PayRemote:FireServer()
       end)
       
       if success then
           Rayfield:Notify({
               Title = "Upgrades",
               Content = "Upgrades applied!",
               Duration = 2,
               Image = 4483362458,
           })
       end
   end,
})

local Section2 = GarageTab:CreateSection("Colors")

local INPUTHEX = GarageTab:CreateInput({
   Name = "Car Color (HEX)",
   PlaceholderText = "#FFFFFF",
   RemoveTextAfterFocusLost = false,
   Flag = "car_color_hex",
   Callback = function(Text)
       local hex = Text:gsub("#", "")
       if hex:len() == 6 then
           local r = tonumber(hex:sub(1,2), 16)
           local g = tonumber(hex:sub(3,4), 16)
           local b = tonumber(hex:sub(5,6), 16)
           if r and g and b then
               selectedCarColor = Color3.fromRGB(r, g, b)
           end
       end
   end,
})

local BUTTONAPPLYCOLOR = GarageTab:CreateButton({
   Name = "Apply Car Color",
   Callback = function()
       local success = pcall(function()
           CarColorRemote:FireServer(selectedCarColor)
       end)
       
       if success then
           Rayfield:Notify({
               Title = "Color",
               Content = "Car color changed!",
               Duration = 2,
               Image = 4483362458,
           })
       end
   end,
})

local INPUTWHEEL = GarageTab:CreateInput({
   Name = "Wheel Color (HEX)",
   PlaceholderText = "#FFFFFF",
   RemoveTextAfterFocusLost = false,
   Flag = "wheel_color_hex",
   Callback = function(Text)
       local hex = Text:gsub("#", "")
       if hex:len() == 6 then
           local r = tonumber(hex:sub(1,2), 16)
           local g = tonumber(hex:sub(3,4), 16)
           local b = tonumber(hex:sub(5,6), 16)
           if r and g and b then
               selectedWheelColor = Color3.fromRGB(r, g, b)
           end
       end
   end,
})

local APPLYBUTTONWHEEL = GarageTab:CreateButton({
   Name = "Apply Wheel Color",
   Callback = function()
       local success = pcall(function()
           WheelColorRemote:FireServer(selectedWheelColor)
       end)
       
       if success then
           Rayfield:Notify({
               Title = "Color",
               Content = "Wheel color changed!",
               Duration = 2,
               Image = 4483362458,
           })
       end
   end,
})

-- Section License Plate
local Section3 = GarageTab:CreateSection("License Plate")

local IMMA_1 = GarageTab:CreateInput({
   Name = "Part 1",
   PlaceholderText = "AA",
   RemoveTextAfterFocusLost = false,
   Flag = "plate_1",
   Callback = function(Text)
       plateText1 = Text:upper()
   end,
})

local IMMA_2 = GarageTab:CreateInput({
   Name = "Part 2",
   PlaceholderText = "EN",
   RemoveTextAfterFocusLost = false,
   Flag = "plate_2",
   Callback = function(Text)
       plateText2 = Text:upper()
   end,
})

local IMMA_3 = GarageTab:CreateInput({
   Name = "Part 3",
   PlaceholderText = "86",
   RemoveTextAfterFocusLost = false,
   Flag = "plate_3",
   Callback = function(Text)
       plateText3 = Text:upper()
   end,
})

local APPLY_PLATE = GarageTab:CreateButton({
   Name = "Apply License Plate",
   Callback = function()
       local success = pcall(function()
           LicensePlateRemote:FireServer(0, plateText1, plateText2, plateText3)
       end)
       
       if success then
           Rayfield:Notify({
               Title = "License Plate",
               Content = plateText1 .. " " .. plateText2 .. " " .. plateText3,
               Duration = 2,
               Image = 4483362458,
           })
       end
   end,
})

-- Section Quick Actions
local Section4 = GarageTab:CreateSection("Quick Actions")

local INSTANT_REPAIR = GarageTab:CreateButton({
   Name = "Instant Repair (FREE)",
   Callback = function()
       local success = pcall(function()
           RepairRemote:FireServer()
       end)
       
       if success then
           Rayfield:Notify({
               Title = "Repair",
               Content = "Vehicle repaired!",
               Duration = 2,
               Image = 4483362458,
           })
       end
   end,
})

local MAXALLBUTTON = GarageTab:CreateButton({
   Name = "⚡ Quick Max All",
   Callback = function()
       local success = pcall(function()
           EngineRemote:FireServer(6)
           task.wait(0.05)
           BrakeRemote:FireServer(6)
           task.wait(0.05)
           ArmorRemote:FireServer(6)
           task.wait(0.05)
           PayRemote:FireServer()
       end)
       
       if success then
           Rayfield:Notify({
               Title = "Quick Max",
               Content = "All maxed!",
               Duration = 2,
               Image = 4483362458,
           })
       end
   end,
})


Rayfield:LoadConfiguration()
