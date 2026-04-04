-- R6 Character
task.spawn(function()
loadstring(game:HttpGet("https://github.com/AdmBrookhavenScripts/R6Character/raw/refs/heads/main/ReanimateCharacter.lua"))()
end)
task.wait(3)
task.spawn(function()
workspace.CurrentCamera.CameraSubject.Parent:PivotTo(workspace.CurrentCamera.CameraSubject.Parent:GetPivot() + Vector3.new(0,100,0))
workspace.CurrentCamera.CameraSubject.Parent:ScaleTo(6)
for _,v in pairs(workspace.CurrentCamera.CameraSubject.Parent:GetDescendants()) do
	if v:IsA("Accessory") then
		v:Destroy()
	end
end
for _,v in pairs(workspace.CurrentCamera.CameraSubject.Parent:GetDescendants()) do
	if v:IsA("BasePart") or v:IsA("Decal") then
		v.Transparency=1
	end
end
end)
task.wait(1)
local p = game.Players.LocalPlayer
local c = workspace.CurrentCamera.CameraSubject.Parent
local rs = game:GetService("RunService")
local folder = workspace.WorkspaceCom["001_TrafficCones"]

local order = {
	"Torso",
	"Right Arm",
	"Left Arm",
	"Right Leg",
	"Left Leg",
	"Head",
	"Face"
}

local offsets = {
	["Torso"] = CFrame.new(0, 0, 0),
	["Head"] = CFrame.Angles(0, math.rad(180), 0),
	["Right Arm"] = CFrame.Angles(math.rad(180),0,0),
	["Left Arm"] = CFrame.Angles(math.rad(180),0,0),
	["Right Leg"] = CFrame.Angles(math.rad(180),0,0),
	["Left Leg"] = CFrame.Angles(math.rad(180),0,0),
	["Face"] = CFrame.new(0, 2.5, -0.05) * CFrame.Angles(0, math.rad(180), 0)
}

local founded = {}

for _,v in ipairs(folder:GetChildren()) do
	if v:IsA("Model") and string.find(v.Name, p.Name) then
		table.insert(founded, v)
	end
end

table.sort(founded, function(a,b)
	return a:GetDebugId() < b:GetDebugId()
end)

for i,v in ipairs(founded) do
	if order[i] then
		v.Name = order[i]
	end
end

local VF = Instance.new("Folder")
VF.Name = "VisualClones"
VF.Parent = workspace

local clones = {}

for _,v in ipairs(founded) do
	local clone = v:Clone()
	clone.Name = v.Name
	clone.Parent = VF

	local remote = clone:FindFirstChild("SetCurrentCFrame")
	if remote then
		remote:Destroy()
	end

	table.insert(clones, clone)
	
	for _,d in ipairs(v:GetDescendants()) do
		if d:IsA("BasePart") or d:IsA("Decal") then
			d.Transparency = 1
		end
	end
end

rs.PostSimulation:Connect(function()
	local char = workspace.CurrentCamera.CameraSubject.Parent
	if not char then return end

	for i,v in ipairs(clones) do
	local original = founded[i]
	local target
if v.Name == "Face" then
	target = char:FindFirstChild("Head")
else
	target = char:FindFirstChild(v.Name)
end
		if target and target:IsA("BasePart") then
			

			task.delay(0, function()
				local cf = target.CFrame * offsets[v.Name]

				if v.Name == "Torso" then
					cf = cf * CFrame.new(0, -13, 0)
				end
				if v.Name == "Right Arm" then
					cf = cf * CFrame.new(0, -2.5, 0)
				end
				if v.Name == "Left Arm" then
					cf = cf * CFrame.new(0, -2.5, 0)
				end
           
				v:PivotTo(cf)
			end)
		end
	end
end)

rs.PreSimulation:Connect(function()
	local char = workspace.CurrentCamera.CameraSubject.Parent
	if not char then return end

	for _,v in ipairs(founded) do
		local target
if v.Name == "Face" then
	target = char:FindFirstChild("Head")
else
	target = char:FindFirstChild(v.Name)
end
		if target and target:IsA("BasePart") then
			

			task.delay(0, function()
				local cf = target.CFrame * offsets[v.Name]

				if v.Name == "Torso" then
					cf = cf * CFrame.new(0, -13, 0)
				end
				if v.Name == "Right Arm" then
					cf = cf * CFrame.new(0, -2.5, 0)
				end
				if v.Name == "Left Arm" then
					cf = cf * CFrame.new(0, -2.5, 0)
				end
				
				v:PivotTo(cf)

				local remote = v:FindFirstChild("SetCurrentCFrame")
				if remote then
					remote:InvokeServer(cf)
				end
			end)
		end
	end
end)

workspace.CurrentCamera.CameraSubject.Parent:FindFirstChild("Humanoid").HipHeight=6
workspace.CurrentCamera.CameraSubject.Parent:FindFirstChild("Torso").Neck.C0 *= CFrame.new(0,0,-6)
workspace.CurrentCamera.CameraSubject.Parent:FindFirstChild("Torso")["Left Shoulder"].C0 *= CFrame.new(0,0,-1.5)
workspace.CurrentCamera.CameraSubject.Parent:FindFirstChild("Torso")["Right Shoulder"].C0 *= CFrame.new(0,0,-1.5)