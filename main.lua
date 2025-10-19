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
local Toggle = Tab:CreateToggle({
   Name = "Walk speed",
   CurrentValue = false,
   Flag = "walk_boost", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   -- The function that takes place when the toggle is pressed
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local Slider = Tab:CreateSlider({
   Name = "Walk speed",
   Range = {0, 25},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 10,
   Flag = "walk_speed", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   -- The function that takes place when the slider changes
   -- The variable (Value) is a number which correlates to the value the slider is currently at
   end,
})

local Toggle = Tab:CreateToggle({
   Name = "Infinite Stamina",
   CurrentValue = false,
   Flag = "inf_stamina", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   -- The function that takes place when the toggle is pressed
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local Toggle = Tab:CreateToggle({
   Name = "Infinite jump",
   CurrentValue = false,
   Flag = "inf_jump", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   -- The function that takes place when the toggle is pressed
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local Tab = Window:CreateTab("🛡️｜Aimbot", 0)

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

local Toggle = Tab:CreateToggle({
   Name = "ESP distance (stunds)",
   CurrentValue = false,
   Flag = "esp_distance", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   -- The function that takes place when the toggle is pressed
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

local Tab = Window:CreateTab("🏎️｜Car Mods", 0)

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

Rayfield:LoadConfiguration()
