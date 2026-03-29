-- R6 Character
task.spawn(function()
loadstring(game:HttpGet("https://github.com/AdmBrookhavenScripts/R6Character/raw/refs/heads/main/R6Character.lua"))()
end)
task.wait(3)
task.spawn(function()
game.Players.LocalPlayer.Character:ScaleTo(6)
end)
task.wait(1)
local p = game.Players.LocalPlayer
local c = p.Character or p.CharacterAdded:Wait()
local rs = game:GetService("RunService")
local folder = workspace.WorkspaceCom["001_TrafficCones"]

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
	["Right Arm"] = CFrame.Angles(math.rad(180),0,0),
	["Left Arm"] = CFrame.Angles(math.rad(180),0,0),
	["Right Leg"] = CFrame.Angles(math.rad(180),0,0),
	["Left Leg"] = CFrame.Angles(math.rad(180),0,0)
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
	local char = p.Character
	if not char then return end

	for _,v in ipairs(founded) do
		local target = char:FindFirstChild(v.Name)
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
				if v.Name == "Head" then
					cf = cf * CFrame.new(0, -6, 0)
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
	local char = p.Character
	if not char then return end

	for _,v in ipairs(founded) do
		local target = char:FindFirstChild(v.Name)
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
				if v.Name == "Head" then
					cf = cf * CFrame.new(0, -6, 0)
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

game.Players.LocalPlayer.Character.Humanoid.HipHeight=6
