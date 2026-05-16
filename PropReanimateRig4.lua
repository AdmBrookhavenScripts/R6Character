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

    [13] = {"Head", CFrame.new()}
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
    local Char = workspace.CurrentCamera.CameraSubject.Parent
    if not Char then return end
    for i,Clone in ipairs(Clones) do
        local Info = Offsets[i]
        local Target = Char:FindFirstChild(Info[1])
        if Target then
                local CF = Target.CFrame * Info[2] * DownAngle
                Clone:PivotTo(CF)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    for i,Prop in ipairs(Founded) do
        local Clone = Clones[i]
        if Clone then
            task.delay(0,function()
                local CF = Clone:GetPivot()
                local Remote = Prop:FindFirstChild("SetCurrentCFrame")
                if Remote then
                    Remote:InvokeServer(CF)
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
    end
end