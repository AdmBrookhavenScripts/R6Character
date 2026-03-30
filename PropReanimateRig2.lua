-- Reanimate Character
task.spawn(function()
loadstring(game:HttpGet("https://github.com/AdmBrookhavenScripts/R6Character/raw/refs/heads/main/ReanimateCharacter.lua"))()
end)
task.wait(3)
task.spawn(function()
workspace.ReanimateCharacter:PivotTo(workspace.ReanimateCharacter:GetPivot() + Vector3.new(0,100,0))
workspace.ReanimateCharacter:ScaleTo(4)
end)
task.wait(1)
local p = game.Players.LocalPlayer
local c = workspace.ReanimateCharacter
local t= workspace.ReanimateCharacter.Torso
local rs = game:GetService("RunService")
local folder = workspace.WorkspaceCom["001_TrafficCones"]

local rot = CFrame.new(0,0,0,
	-0.0422487259, -0.998706996, -0.0282772444,
	 0.999099314, -0.0421187878, -0.00517526921,
	 0.0039775772, -0.0284704193,  0.999586701
)

local fix = CFrame.Angles(math.rad(-90), 0, 0)

local order = {
	"Torso",
	"Right Arm",
	"Left Arm",
	"Right Leg",
	"Left Leg",
	"Head"
}

local offsets = {
	["Torso"] = CFrame.new(0, 0, 0),
	["Head"] = CFrame.Angles(0, math.rad(180), 0),
    ["Right Arm"] = rot * fix,
    ["Left Arm"] = rot * fix * CFrame.Angles(0, math.rad(180), 0),
    ["Right Leg"] = rot * fix,
    ["Left Leg"] = rot * fix * CFrame.Angles(0, math.rad(180), 0),
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

rs.PreSimulation:Connect(function()
	local char = workspace.ReanimateCharacter
	if not char then return end

	for _,v in ipairs(founded) do
		local target = char:FindFirstChild(v.Name)
		if target and target:IsA("BasePart") then
			

			task.delay(0, function()
				local cf = target.CFrame * offsets[v.Name]

				if v.Name == "Torso" then
					cf = cf * CFrame.new(0, -3, 0)
				end
				if v.Name == "Right Arm" then
					cf = cf * CFrame.new(0, -2.5, 0)
				end
				if v.Name == "Left Arm" then
					cf = cf * CFrame.new(0, -2.5, 0)
				end
				if v.Name == "Head" then
					cf = cf * CFrame.new(0, -1, 0)
				end

				local remote = v:FindFirstChild("SetCurrentCFrame")
				if remote then
					remote:InvokeServer(cf)
				end
			end)
		end
	end
end)

rs.RenderStepped:Connect(function()
	local char = workspace.ReanimateCharacter
	if not char then return end

	for _,v in ipairs(founded) do
		local target = char:FindFirstChild(v.Name)
		if target and target:IsA("BasePart") then
			

			task.delay(0, function()
				local cf = target.CFrame * offsets[v.Name]

				if v.Name == "Torso" then
					cf = cf * CFrame.new(0, -3, 0)
				end
				if v.Name == "Right Arm" then
					cf = cf * CFrame.new(0, -2.5, 0)
				end
				if v.Name == "Left Arm" then
					cf = cf * CFrame.new(0, -2.5, 0)
				end
				if v.Name == "Head" then
					cf = cf * CFrame.new(0, -1, 0)
				end

				v:PivotTo(cf)
			end)
		end
	end
end)

for _,v in pairs(c:GetDescendants()) do
	if v:IsA("BasePart") or v:IsA("Decal") then
		v.Transparency=1
	end
end

workspace.ReanimateCharacter.Humanoid.HipHeight=1
t["Left Hip"].C0=t["Left Hip"].C0*CFrame.new(1.5,0,0) t["Right Hip"].C0=t["Right Hip"].C0*CFrame.new(-1.5,0,0)
t["Left Shoulder"].C0=t["Left Shoulder"].C0*CFrame.new(-1.5,0,0) t["Right Shoulder"].C0=t["Right Shoulder"].C0*CFrame.new(1.5,0,0)