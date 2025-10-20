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

-- Variables globales aimbot
local rageBotEnabled = false
local smoothness = 3
local predictionEnabled = false
local predictionAmount = 0.13
local targetPart = "Head"
local fovSize = 200
local fovVisible = true

local rageBotConnection = nil
local aimbotMobileEnabled = false
local fovCircle = nil

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Créer le cercle FOV AU CENTRE (non rempli)
local function createFOVCircle()
    pcall(function()
        if fovCircle then
            fovCircle:Remove()
        end
        
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 2
        fovCircle.NumSides = 50
        fovCircle.Radius = fovSize
        fovCircle.Filled = false -- PAS REMPLI
        fovCircle.Transparency = 1
        fovCircle.Color = Color3.fromRGB(255, 0, 0)
        fovCircle.Visible = fovVisible
        fovCircle.ZIndex = 999
    end)
end

-- Update position du cercle AU CENTRE DE L'ÉCRAN
spawn(function()
    RunService.RenderStepped:Connect(function()
        pcall(function()
            if fovCircle then
                local screenSize = Camera.ViewportSize
                fovCircle.Position = Vector2.new(screenSize.X / 2, screenSize.Y / 2) -- CENTRE!
                fovCircle.Radius = fovSize
                fovCircle.Visible = fovVisible and rageBotEnabled
            end
        end)
    end)
end)

-- Fonction pour trouver la cible la plus proche DANS LE FOV (depuis le centre)
local function getClosestPlayerRageBot()
    local closestPlayer = nil
    local shortestDistance = fovSize
    
    local screenSize = Camera.ViewportSize
    local screenCenter = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local targetPartObj = character:FindFirstChild(targetPart)
            
            if not targetPartObj then continue end
            if not humanoid or humanoid.Health <= 0 then continue end
            
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

-- Rage Bot (tir automatique avec smoothness)
local function startRageBot()
    if rageBotConnection then
        rageBotConnection:Disconnect()
    end
    
    rageBotConnection = RunService.Heartbeat:Connect(function()
        if not rageBotEnabled then return end
        
        local target = getClosestPlayerRageBot()
        if target and target.Character then
            local targetPartObj = target.Character:FindFirstChild(targetPart)
            if targetPartObj then
                local targetPos = targetPartObj.Position
                
                -- Prédiction
                if predictionEnabled then
                    local targetVelocity = target.Character.HumanoidRootPart.Velocity
                    targetPos = targetPos + (targetVelocity * predictionAmount)
                end
                
                -- Smoothness: 1 = très smooth, 5 = instantané
                local smoothFactor = smoothness / 10
                
                local currentCFrame = Camera.CFrame
                local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
                Camera.CFrame = currentCFrame:Lerp(targetCFrame, smoothFactor)
                
                -- Tirer automatiquement
                pcall(function()
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        for _, v in pairs(tool:GetDescendants()) do
                            if v:IsA("RemoteEvent") and (v.Name:lower():find("shoot") or v.Name:lower():find("fire")) then
                                v:FireServer(targetPos, targetPartObj)
                                break
                            end
                        end
                    end
                end)
            end
        end
    end)
end

-- Calcul auto de la prédiction
local function calculateAutoPrediction()
    Rayfield:Notify({
        Title = "Auto Prediction",
        Content = "Analyzing... Please wait",
        Duration = 2,
        Image = 4483362458,
    })
    
    spawn(function()
        local samples = {}
        local target = getClosestPlayerRageBot()
        
        if not target or not target.Character then
            Rayfield:Notify({
                Title = "Error",
                Content = "No target found!",
                Duration = 3,
                Image = 4483362458,
            })
            return
        end
        
        for i = 1, 10 do
            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local velocity = target.Character.HumanoidRootPart.Velocity.Magnitude
                table.insert(samples, velocity)
                wait(0.1)
            end
        end
        
        local avgVelocity = 0
        for _, v in pairs(samples) do
            avgVelocity = avgVelocity + v
        end
        avgVelocity = avgVelocity / #samples
        
        local distance = (target.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
        local bulletSpeed = 1000
        local travelTime = distance / bulletSpeed
        
        predictionAmount = travelTime * (avgVelocity / 100)
        
        Rayfield:Notify({
            Title = "Auto Prediction",
            Content = "Prediction set to: " .. string.format("%.2f", predictionAmount),
            Duration = 3,
            Image = 4483362458,
        })
    end)
end

createFOVCircle()

-- UI Rage Bot
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

local RageBotKeybind = Tab:CreateKeybind({
    Name = "Rage Bot Keybind",
    CurrentKeybind = "Q",
    HoldToInteract = false,
    Flag = "rage_keybind",
    Callback = function(Keybind)
        rageBotEnabled = not rageBotEnabled
        RageBotToggle:Set(rageBotEnabled)
        if rageBotEnabled then
            startRageBot()
        else
            if rageBotConnection then
                rageBotConnection:Disconnect()
            end
        end
    end,
})

local Section1_5 = Tab:CreateSection("FOV Settings")

local FOVToggle = Tab:CreateToggle({
    Name = "Show FOV",
    CurrentValue = true,
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
    CurrentValue = 200,
    Flag = "fov_size",
    Callback = function(Value)
        fovSize = Value
    end,
})

local FOVColorPicker = Tab:CreateColorPicker({
    Name = "FOV Color",
    Color = Color3.fromRGB(255,0,0),
    Flag = "fov_color",
    Callback = function(Value)
        pcall(function()
            if fovCircle then
                fovCircle.Color = Value
            end
        end)
    end
})

local SmoothnessSlider = Tab:CreateSlider({
    Name = "Smoothness",
    Range = {1, 5},
    Increment = 1,
    Suffix = "",
    CurrentValue = 3,
    Flag = "smoothness",
    Callback = function(Value)
        smoothness = Value
    end,
})

local Section2 = Tab:CreateSection("Prediction")

local PredictionToggle = Tab:CreateToggle({
    Name = "Prediction",
    CurrentValue = false,
    Flag = "prediction",
    Callback = function(Value)
        predictionEnabled = Value
    end,
})

local PredictionSlider = Tab:CreateSlider({
    Name = "Prediction Amount",
    Range = {0, 50},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 13,
    Flag = "prediction_amount",
    Callback = function(Value)
        predictionAmount = Value / 100
    end,
})

local AutoPredictionButton = Tab:CreateButton({
    Name = "Adjust Prediction Auto",
    Callback = function()
        calculateAutoPrediction()
    end,
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

-- AIMBOT MOBILE (Mini GUI) - CORRIGÉ
local Section3 = Tab:CreateSection("Mobile")

local mobileGui = nil

local function createMobileGui()
    task.spawn(function()
        wait(0.5) -- Délai pour que le GUI charge
        
        pcall(function()
            if mobileGui then
                mobileGui:Destroy()
            end
            
            mobileGui = Instance.new("ScreenGui")
            mobileGui.Name = "LuxenMobileAimbot"
            mobileGui.ResetOnSpawn = false
            mobileGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            
            -- Essayer game.CoreGui d'abord, sinon Players.LocalPlayer:WaitForChild("PlayerGui")
            local success = pcall(function()
                mobileGui.Parent = game:GetService("CoreGui")
            end)
            
            if not success then
                mobileGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
            end
            
            local mobileButton = Instance.new("TextButton")
            mobileButton.Size = UDim2.new(0, 80, 0, 80)
            mobileButton.Position = UDim2.new(1, -100, 0.5, -40)
            mobileButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            mobileButton.Text = "AIM\nOFF"
            mobileButton.TextColor3 = Color3.white
            mobileButton.TextSize = 16
            mobileButton.Font = Enum.Font.GothamBold
            mobileButton.ZIndex = 10000
            mobileButton.Parent = mobileGui
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = mobileButton
            
            -- Rendre draggable
            local dragging = false
            local dragInput, dragStart, startPos
            
            mobileButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startPos = mobileButton.Position
                    
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end)
                end
            end)
            
            mobileButton.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    dragInput = input
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if input == dragInput and dragging then
                    local delta = input.Position - dragStart
                    mobileButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
            
            mobileButton.MouseButton1Click:Connect(function()
                aimbotMobileEnabled = not aimbotMobileEnabled
                rageBotEnabled = aimbotMobileEnabled
                
                if aimbotMobileEnabled then
                    mobileButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
                    mobileButton.Text = "AIM\nON"
                    RageBotToggle:Set(true)
                    startRageBot()
                else
                    mobileButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                    mobileButton.Text = "AIM\nOFF"
                    RageBotToggle:Set(false)
                    if rageBotConnection then
                        rageBotConnection:Disconnect()
                    end
                end
            end)
            
            print("Mobile GUI created successfully!")
        end)
    end)
end

local MobileAimbotButton = Tab:CreateButton({
    Name = "Show Mobile Aimbot Button",
    Callback = function()
        createMobileGui()
        Rayfield:Notify({
            Title = "Mobile Aimbot",
            Content = "Button shown! Tap to toggle",
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

-- ===============================
-- SILENT AIM (TAB SÉPARÉ) - CORRIGÉ
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

-- MOBILE SILENT AIM BUTTON
local mobileSilentGui = nil

local function createMobileSilentGui()
    task.spawn(function()
        wait(0.5)
        
        pcall(function()
            if mobileSilentGui then
                mobileSilentGui:Destroy()
            end
            
            mobileSilentGui = Instance.new("ScreenGui")
            mobileSilentGui.Name = "LuxenMobileSilent"
            mobileSilentGui.ResetOnSpawn = false
            mobileSilentGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            
            local success = pcall(function()
                mobileSilentGui.Parent = game:GetService("CoreGui")
            end)
            
            if not success then
                mobileSilentGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
            end
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 80, 0, 80)
            btn.Position = UDim2.new(1, -100, 0.5, 60)
            btn.BackgroundColor3 = Color3.fromRGB(255, 255, 50)
            btn.Text = "SILENT\nOFF"
            btn.TextColor3 = Color3.black
            btn.TextSize = 14
            btn.Font = Enum.Font.GothamBold
            btn.ZIndex = 10000
            btn.Parent = mobileSilentGui
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = btn
            
            -- Draggable
            local dragging = false
            local dragInput, dragStart, startPos
            
            btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startPos = btn.Position
                    
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end)
                end
            end)
            
            btn.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    dragInput = input
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if input == dragInput and dragging then
                    local delta = input.Position - dragStart
                    btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
            
            btn.MouseButton1Click:Connect(function()
                silentAimEnabled = not silentAimEnabled
                SilentToggle:Set(silentAimEnabled)
                
                if silentAimEnabled then
                    btn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                    btn.Text = "SILENT\nON"
                else
                    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 50)
                    btn.Text = "SILENT\nOFF"
                end
            end)
        end)
    end)
end

local MobileSilentButton = SilentTab:CreateButton({
    Name = "Show Mobile Silent Aim Button",
    Callback = function()
        createMobileSilentGui()
        Rayfield:Notify({
            Title = "Mobile Silent Aim",
            Content = "Button shown! Tap to toggle",
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
    Suffix = "km/h",
    CurrentValue = 200,
    Flag = "car_max_speed",
    Callback = function(Value)
    end,
})

local CarAccel = Tab:CreateSlider({
    Name = "Car Acceleration",
    Range = {0, 10000},
    Increment = 30,
    Suffix = "acceleration",
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



local Label = Tab:CreateLabel("Created & owned by Azfa & Vamp 🧛", 0, Color3.fromRGB(255, 255, 255), false) -- Title, Icon, Color, IgnoreTheme

Rayfield:LoadConfiguration()
