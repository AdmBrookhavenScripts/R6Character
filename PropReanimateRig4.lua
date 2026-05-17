local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Founded = {}
local Size = 2.5
local DownAngle = CFrame.new(0,-1.25,0)
local Offsets = {
    [1] = {"Torso", CFrame.new(-1.25, 1.25, 0)},
    [2] = {"Torso", CFrame.new(1.25, 1.25, 0)},
    [3] = {"Torso", CFrame.new(-1.25,-1.25, 0)},
    [4] = {"Torso", CFrame.new(1.25,-1.25, 0)},

    [5] = {"Right Arm", CFrame.new(0, 1.25, 0)},
    [6] = {"Right Arm", CFrame.new(0,-1.25, 0)},

    [7] = {"Left Arm", CFrame.new(0, 1.25, 0)},
    [8] = {"Left Arm", CFrame.new(0,-1.25, 0)},

    [9] = {"Left Leg", CFrame.new(0, 1.25, 0)},
    [10] = {"Left Leg", CFrame.new(0,-1.25, 0)},

    [11] = {"Right Leg", CFrame.new(0, 1.25, 0)},
    [12] = {"Right Leg", CFrame.new(0,-1.25, 0)},

    [13] = {"Head", CFrame.new()},
    [14] = {"Head", CFrame.new(0, 0, -1.2) * CFrame.Angles(0, math.rad(180), 0)}
}

task.spawn(function()
    loadstring(game:HttpGet("https://github.com/AdmBrookhavenScripts/R6Character/raw/refs/heads/main/ReanimateCharacter.lua"))()
end)

repeat task.wait() until workspace:FindFirstChild("ReanimateCharacter")
local Player = Players.LocalPlayer
local Character = workspace.CurrentCamera.CameraSubject.Parent
local Folder = workspace.WorkspaceCom["001_TrafficCones"]
Character:PivotTo(Character:GetPivot() + Vector3.new(0,100,0))
Character:ScaleTo(2.5)
for _,v in ipairs(Character:GetDescendants()) do
    if v:IsA("BasePart") or v:IsA("Decal") then
        v.Transparency = 1
    end
end

for _,v in ipairs(Folder:GetChildren()) do
    if v:IsA("Model") and string.find(v.Name, Player.Name) then
        table.insert(Founded, v)
    end
end

table.sort(Founded,function(a,b)
    return a:GetDebugId() < b:GetDebugId()
end)

local VF = Instance.new("Folder", workspace)
VF.Name = "ClientSideClones"
local Clones = {}
for _,v in ipairs(Founded) do
    local Clone = v:Clone()
    Clone.Parent = VF
    local Remote = Clone:FindFirstChild("SetCurrentCFrame")
    if Remote then
        Remote:Destroy()
    end
    table.insert(Clones, Clone)
    for _,d in ipairs(v:GetDescendants()) do
        if d:IsA("BasePart") or d:IsA("Decal") then
            d.Transparency = 1
        end
    end
end

RunService.Heartbeat:Connect(function()
    local Char = workspace:FindFirstChild("(C) Uhhhhhh V1.0.9 BETA")
    if not Char then return end

    local MaxParts = #Clones >= 14 and 14 or 13

    for i = 1, MaxParts do
        local Clone = Clones[i]
        local Info = Offsets[i]
        if Clone and Info then
            local Target = Char:FindFirstChild(Info[1])
            if Target then
                if i == 14 then
                    Clone:PivotTo(Target.CFrame * Info[2])
                else
                    Clone:PivotTo(Target.CFrame * Info[2] * DownAngle)
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    for i = 1, (#Clones >= 14 and 14 or 13) do
        local Prop = Founded[i]
        local Clone = Clones[i]

        if Prop and Clone then
            task.delay(0,function()
                local Remote = Prop:FindFirstChild("SetCurrentCFrame")
                if Remote then
                    Remote:InvokeServer(Clone:GetPivot())
                end
            end)
        end
    end
end)

for _, Clone in ipairs(Clones) do
    for _, v in ipairs(Clone:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end

for _, Prop in ipairs(Founded) do
    for _, v in ipairs(Prop:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
        if v:IsA("SurfaceGui") then
        v:Destroy()
        end
        if v:IsA("BillboardGui") then
        v:Destroy()
        end
    end
end