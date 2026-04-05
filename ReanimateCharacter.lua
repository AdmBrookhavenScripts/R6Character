game.Players.LocalPlayer.PlayerGui.MainGUIHandler.MainButtons.Buttons.House.Visible = false
game.Players.LocalPlayer.PlayerGui.MainGUIHandler.MainButtons.Buttons.House.Active = false
game.Players.LocalPlayer.PlayerGui.MainGUIHandler.MainButtons.Buttons.House.ImageTransparency = 1
game.Players.LocalPlayer.PlayerGui.MainGUIHandler.MainButtons.Buttons.AvatarEditor.Visible = false
game.Players.LocalPlayer.PlayerGui.MainGUIHandler.MainButtons.Buttons.AvatarEditor.Active = false
game.Players.LocalPlayer.PlayerGui.MainGUIHandler.MainButtons.Buttons.AvatarEditor.ImageTransparency = 1
game.Players.LocalPlayer.PlayerGui.NoResetGUIHandler.TopCornerDetails.Frame.CamOpen.Visible = false
game.Players.LocalPlayer.PlayerGui.NoResetGUIHandler.TopCornerDetails.Frame.CamOpen.Active = false
game.Players.LocalPlayer.PlayerGui.NoResetGUIHandler.TopCornerDetails.Frame.CamOpen.ImageTransparency = 1
-- Warning: This system was made by stevetherealone/uhhhhhh reanimate
local Players = game.Players
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local GameCamera = workspace.CurrentCamera
local GameSettings = UserSettings():GetService("UserGameSettings")

local AntiflingHumanoids = {}
	local AntiflingBaseParts = {}
	
	RunService.PreAnimation:Connect(function()
		for i,v in AntiflingBaseParts do
			if v:IsDescendantOf(workspace) then
				v.CanCollide = false
				v.AssemblyLinearVelocity, v.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
			else
				table.remove(AntiflingBaseParts, i)
			end
		end
		for i,v in AntiflingHumanoids do
			if v:IsDescendantOf(workspace) then
				v.EvaluateStateMachine = false
			else
				table.remove(AntiflingHumanoids, i)
			end
		end
	end)
	local OnBasePart = function(v)
		if v:IsA("BasePart") then
			v.CanCollide = false
			if not table.find(AntiflingBaseParts, v) then
				table.insert(AntiflingBaseParts, v)
			end
		end
		if v:IsA("Humanoid") then
			v.EvaluateStateMachine = false
			if not table.find(AntiflingHumanoids, v) then
				table.insert(AntiflingHumanoids, v)
			end
		end
	end
	local OnCharacter = function(character)
		character.DescendantAdded:Connect(OnBasePart)
		for _,v in character:GetDescendants() do
			OnBasePart(v)
		end
	end
	local OnPlayer = function(player)
		if player == Player then return end
		player.CharacterAdded:Connect(OnCharacter)
		if player.Character then OnCharacter(player.Character) end
	end
	Players.PlayerAdded:Connect(OnPlayer)
	for _,player in Players:GetPlayers() do
		OnPlayer(player)
	end

local SCREENGUI = Instance.new("ScreenGui")
SCREENGUI.Parent = Player:WaitForChild("PlayerGui")
local FallenPartsDestroyHeight = workspace.FallenPartsDestroyHeight or -500
local Reanimate = {
	Camera = nil,
	Control = nil,
	Character = nil,
	CharacterLTMs = {},
	CharacterScale = 1,
	Shiftlocked = false,
	ShiftlockEnabled = false,
	Noclip = false,
	SmoothCam = true,
	InfiniteJump = false,
	ScaleGravity = true,
	SeatSit = true,
	ToolGrab = true
}
local Camera = {
    CFrame = CFrame.identity,
    Focus = CFrame.identity,
    Scriptable = false,
    Zoom = 16,
    FieldOfView = 70,
    Input = Vector3.zero,
    _Zoom = 16,

    OnReset = function(self)
        self.Zoom = (self.Focus.Position - self.CFrame.Position).Magnitude
        self._Zoom = self.Zoom
        self.Scriptable = false
        self.FieldOfView = 70
        self.Inputs:Reset()
    end,

    OnPanInput = function(self, vec, accum)
        if accum then
            self.Input += Vector3.new(vec.X, vec.Y, 0)
        else
            self.Input = Vector3.new(vec.X, vec.Y, self.Input.Z)
        end
    end,

    OnZoomInput = function(self, zoom)
        self.Input += Vector3.new(0, 0, zoom)
    end,

    Inputs = {
        KB = {
            Left = false,
            Right = false,
        },
        MS = {
            RMB = false,
        },
        TC = {
            DJ = nil,
            Touch = {},
            LP = nil,
        },
        Reset = function(self)
            self.KB.Left = false
            self.KB.Right = false
            self.MS.RMB = false
            self.TC.DJ = nil
            table.clear(self.TC.Touch)
            self.TC.LP = nil
        end,
    },

    LocalTransparencyModifier = 0,

    Control = {
        Move = Vector3.zero,
        Jump = false,
        Inputs = {
            KB = {
                Up = false,
                Down = false,
                Left = false,
                Right = false,
                Space = false,
            },
            TC = {
                DJ = nil,
                LP = nil,
                JB = nil,
            },
            Reset = function(self)
                self.KB.Up = false
                self.KB.Down = false
                self.KB.Left = false
                self.KB.Right = false
                self.KB.Space = false
                self.TC.DJ = nil
                self.TC.LP = nil
                self.TC.JB = nil
            end,
        }
    }
}

Reanimate.Camera = Camera
Reanimate.Control = Camera.Control
local function AddToRenderStep(func)
	RunService:BindToRenderStep("CustomRender_"..tostring(math.random()), Enum.RenderPriority.Last.Value, func)
end
local Util = {}

function Util.GetScreenSize()
	return workspace.CurrentCamera.ViewportSize
end

function Util.LinkDestroyI2C(obj, conn)
	obj.Destroying:Connect(function()
		conn:Disconnect()
	end)
end
local function CreateHumanoidCharacter()
	local userId = Player.UserId

	local desc = Players:GetHumanoidDescriptionFromUserId(userId)
	local model = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)

	model.Name = "ReanimateCharacter"
	model.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	model.Parent = workspace
	
	return model
end
function Reanimate.Camera:IsFirstPerson()
	return self._Zoom <= 1
end
Reanimate.Camera.IsMouseLocked = function(self)
	return self:IsFirstPerson() or Reanimate.Shiftlocked
end
Reanimate.Camera.IsMousePanning = function(self)
	return self:IsMouseLocked() or self.Inputs.MS.RMB
end
do
	local function IsInThumbstickArea(pos)
		local playerGui = Player:FindFirstChildOfClass("PlayerGui")
		local touchGui = playerGui and playerGui:FindFirstChild("TouchGui")
		if not touchGui.Enabled then
			return false
		end
		local touchFrame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
		local thumbstickFrame = touchFrame and (touchFrame:FindFirstChild("DynamicThumbstickFrame") or touchFrame:FindFirstChild("ThumbstickFrame"))
		if not thumbstickFrame then
			return false
		end
		local posTopLeft = thumbstickFrame.AbsolutePosition
		local posBottomRight = posTopLeft + thumbstickFrame.AbsoluteSize
		return pos.X >= posTopLeft.X and pos.Y >= posTopLeft.Y and pos.X <= posBottomRight.X and pos.Y <= posBottomRight.Y
	end
	local function IsInJumpButtonArea(pos)
		local playerGui = Player:FindFirstChildOfClass("PlayerGui")
		local touchGui = playerGui and playerGui:FindFirstChild("TouchGui")
		if not touchGui.Enabled then
			return false
		end
		local touchFrame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
		local jumpButton = touchFrame and touchFrame:FindFirstChild("JumpButton")
		if not jumpButton then
			return false
		end
		local posTopLeft = jumpButton.AbsolutePosition
		local posBottomRight = posTopLeft + jumpButton.AbsoluteSize
		return pos.X >= posTopLeft.X and pos.Y >= posTopLeft.Y and pos.X <= posBottomRight.X and pos.Y <= posBottomRight.Y
	end
	do
		local self = Reanimate.Control
		UserInputService.InputBegan:Connect(function(input, gpe)
			if GuiService.MenuIsOpen then return end
			if UserInputService:GetFocusedTextBox() then return end
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.W then
					self.Inputs.KB.Up = true
				end
				if input.KeyCode == Enum.KeyCode.S then
					self.Inputs.KB.Down = true
				end
				if input.KeyCode == Enum.KeyCode.Up then
					self.Inputs.KB.Up = true
				end
				if input.KeyCode == Enum.KeyCode.Down then
					self.Inputs.KB.Down = true
				end
				if input.KeyCode == Enum.KeyCode.A then
					self.Inputs.KB.Left = true
				end
				if input.KeyCode == Enum.KeyCode.D then
					self.Inputs.KB.Right = true
				end
				if input.KeyCode == Enum.KeyCode.Space then
					self.Inputs.KB.Space = true
				end
			end
			if input.UserInputType == Enum.UserInputType.Touch then
				if self.Inputs.TC.DJ == nil and IsInThumbstickArea(input.Position) then
					self.Inputs.TC.DJ = input
					self.Inputs.TC.LP = input.Position
					return
				end
				if self.Inputs.TC.JB == nil and IsInJumpButtonArea(input.Position) then
					self.Inputs.TC.JB = input
					return
				end
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if GuiService.MenuIsOpen then return end
			if UserInputService:GetFocusedTextBox() then return end
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.W then
					self.Inputs.KB.Up = false
				end
				if input.KeyCode == Enum.KeyCode.S then
					self.Inputs.KB.Down = false
				end
				if input.KeyCode == Enum.KeyCode.Up then
					self.Inputs.KB.Up = false
				end
				if input.KeyCode == Enum.KeyCode.Down then
					self.Inputs.KB.Down = false
				end
				if input.KeyCode == Enum.KeyCode.A then
					self.Inputs.KB.Left = false
				end
				if input.KeyCode == Enum.KeyCode.D then
					self.Inputs.KB.Right = false
				end
				if input.KeyCode == Enum.KeyCode.Space then
					self.Inputs.KB.Space = false
				end
			end
			if input.UserInputType == Enum.UserInputType.Touch then
				if self.Inputs.TC.DJ == input then
					self.Inputs.TC.DJ = nil
					self.Inputs.TC.LP = nil
				elseif self.Inputs.TC.JB == input then
					self.Inputs.TC.JB = nil
				end
			end
		end)
		local function resetInputDevices()
			self.Inputs:Reset()
		end
		UserInputService.WindowFocused:Connect(resetInputDevices)
		UserInputService.WindowFocusReleased:Connect(resetInputDevices)
		UserInputService.TextBoxFocusReleased:Connect(resetInputDevices)
		GuiService.MenuOpened:Connect(resetInputDevices)
		RunService:BindToRenderStep("Uhhhhhh_Control", Enum.RenderPriority.Input.Value + 1, function(dt)
		if UserInputService:GetFocusedTextBox() then
	self.Inputs:Reset()
	self.Move = Vector3.zero
	self.Jump = false
	return
end
			local screensize = Util.GetScreenSize()
			self.Move = Vector3.zero
			if self.Inputs.KB.Up then
				self.Move += Vector3.new(0, 0, -1)
			end
			if self.Inputs.KB.Down then
				self.Move += Vector3.new(0, 0, 1)
			end
			if self.Inputs.KB.Left then
				self.Move += Vector3.new(-1, 0, 0)
			end
			if self.Inputs.KB.Right then
				self.Move += Vector3.new(1, 0, 0)
			end
			if self.Inputs.TC.DJ and self.Inputs.TC.LP then
				local stickrad = 40
				if math.min(screensize.X, screensize.Y) < 500 then
					stickrad = 20
				end
				local dir = (self.Inputs.TC.DJ.Position - self.Inputs.TC.LP) / stickrad
				if dir.Magnitude > 0.05 then
					dir = dir.Unit * math.min(1, (dir.Magnitude - 0.05) / (1 - 0.05))
					self.Move = Vector3.new(dir.X, 0, dir.Y)
				end
			end
			if self.Move.Magnitude > 1 then self.Move = self.Move.Unit end
			self.Jump = false
			if self.Inputs.KB.Space then
				self.Jump = true
			end
			if self.Inputs.TC.JB then
				self.Jump = true
			end
		end)
	end
	do -- Camera
		local self = Reanimate.Camera
		local function AdjustTouchPitchSensitivity(delta)
			local pitch = Camera.CFrame:ToEulerAnglesYXZ()
			if delta.Y * pitch >= 0 then
				return delta
			end
			local curveY = 1 - (2 * math.abs(pitch) / math.pi) ^ 0.75
			local sensitivity = curveY * 0.75 + 0.25
			return Vector2.new(1, sensitivity) * delta
		end
		UserInputService.InputBegan:Connect(function(input, gpe)
			if GuiService.MenuIsOpen then return end
			if UserInputService:GetFocusedTextBox() then return end
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
					Reanimate.Shiftlocked = Reanimate.ShiftlockEnabled and not Reanimate.Shiftlocked
				end
				if input.KeyCode == Enum.KeyCode.Left then
					self.Inputs.KB.Left = true
				end
				if input.KeyCode == Enum.KeyCode.Right then
					self.Inputs.KB.Right = true
				end
			end
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				if gpe then return end
				self.Inputs.MS.RMB = true
			end
			if input.UserInputType == Enum.UserInputType.Touch then
				if gpe then return end
				if self.Inputs.TC.DJ == nil and IsInThumbstickArea(input.Position) then
					self.Inputs.TC.DJ = input
					return
				end
				self.Inputs.TC.Touch[input] = true
			end
		end)
		UserInputService.InputChanged:Connect(function(input, gpe)
			if GuiService.MenuIsOpen then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				if self:IsMousePanning() then
					self:OnPanInput(Vector2.new(input.Delta.X, input.Delta.Y) * Vector2.new(1, 0.77) * math.rad(0.5), false)
				end
			end
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				if gpe and not self:IsMousePanning() then return end
				local zoom = math.clamp(-input.Position.Z, -1, 1)
				self:OnZoomInput(zoom)
			end
			if input.UserInputType == Enum.UserInputType.Touch then
				if self.Inputs.TC.DJ == input then
					return
				end
				local touches = {}
				for touch,exist in self.Inputs.TC.Touch do
					if exist then table.insert(touches, touch) end
				end
				if #touches == 1 then
					if touches[1] == input then
						self:OnPanInput(Vector2.new(input.Delta.X, input.Delta.Y) * Vector2.new(1, 0.66) * math.rad(1), true)
					end
				end
				if #touches == 2 then
					local pinch = (touches[1].Position - touches[2].Position).Magnitude
					if self.Inputs.TC.LP then
						local zoom = (self.Inputs.TC.LP - pinch) * 0.04
						self:OnZoomInput(zoom)
					end
					self.Inputs.TC.LP = pinch
				else
					self.Inputs.TC.LP = nil
				end
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if GuiService.MenuIsOpen then return end
			if UserInputService:GetFocusedTextBox() then return end
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Left then
					self.Inputs.KB.Left = false
				end
				if input.KeyCode == Enum.KeyCode.Right then
					self.Inputs.KB.Right = false
				end
			end
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				self.Inputs.MS.RMB = false
			end
			if input.UserInputType == Enum.UserInputType.Touch then
				if self.Inputs.TC.DJ == input then
					self.Inputs.TC.DJ = nil
					return
				end
				self.Inputs.TC.LP = nil
				self.Inputs.TC.Touch[input] = false
			end
		end)
		UserInputService.PointerAction:Connect(function(wheel, pan, pinch, gpe)
			if not gpe then
				self:OnPanInput(pan * Vector2.new(1, 0.77) * math.rad(7), false)
				self:OnZoomInput(-wheel - pinch)
			end
		end)
		local function resetInputDevices()
			self.Inputs:Reset()
		end
		UserInputService.WindowFocused:Connect(resetInputDevices)
		UserInputService.WindowFocusReleased:Connect(resetInputDevices)
		UserInputService.TextBoxFocusReleased:Connect(resetInputDevices)
		GuiService.MenuOpened:Connect(resetInputDevices)
		local states = {
			[false] = "rbxasset://textures/ui/mouseLock_off@2x.png",
			[true] = "rbxasset://textures/ui/mouseLock_on@2x.png"
		}
		local MobileShiftlock = Instance.new("ImageButton")
		MobileShiftlock.Parent = SCREENGUI
		MobileShiftlock.BackgroundTransparency = 1
		MobileShiftlock.Position = UDim2.new(1, -190, 1, -60)
		MobileShiftlock.Size = UDim2.new(0, 40, 0, 40)
		MobileShiftlock.Image = states[false]
		MobileShiftlock.Visible = false
		MobileShiftlock.Active = false
		MobileShiftlock.ImageTransparency = 1
		local state = false
		AddToRenderStep(function()
			if state ~= Reanimate.Shiftlocked then
				state = Reanimate.Shiftlocked
				MobileShiftlock.Image = states[state]
			end
			MobileShiftlock.Visible = not not (Reanimate.Character and UserInputService.TouchEnabled)
		end)
		MobileShiftlock.Activated:Connect(function()
			Reanimate.Shiftlocked = Reanimate.ShiftlockEnabled and not Reanimate.Shiftlocked
		end)
		RunService:BindToRenderStep("Uhhhhhh_Camera", Enum.RenderPriority.Camera.Value + 1, function(dt)
		self.Zoom = self.Zoom or 16
        self._Zoom = self._Zoom or self.Zoom
        
			if self.Inputs.KB.Left then
				self:OnPanInput(Vector2.new(math.rad(-120) * dt, 0), true)
			end
			if self.Inputs.KB.Right then
				self:OnPanInput(Vector2.new(math.rad(120) * dt, 0), true)
			end
			local ltm = Reanimate.LocalTransparencyModifier or 0
local tltm = 0
local sltm = (dt or 0) * 3
			if not self.Scriptable then
				if self:IsFirstPerson() then
    tltm = 0 
elseif self.Zoom < 1.5 * Reanimate.CharacterScale then
    tltm = 0.2
end
			end
			if math.abs(ltm - tltm) <= sltm then
				ltm = tltm
			elseif ltm < tltm then
				ltm += sltm
			else
				ltm -= sltm
			end
			Reanimate.LocalTransparencyModifier = ltm
			if not Reanimate.ShiftlockEnabled and Reanimate.Shiftlocked then
				Reanimate.Shiftlocked = false
			end
			if Reanimate.Character then
				local targetMouseBehavior = Enum.MouseBehavior.Default
				if self:IsMousePanning() then
					if self:IsMouseLocked() then
						if UserInputService.TouchEnabled then
							targetMouseBehavior = Enum.MouseBehavior.LockCurrentPosition
						else
							targetMouseBehavior = Enum.MouseBehavior.LockCenter
						end
					else
						targetMouseBehavior = Enum.MouseBehavior.LockCurrentPosition
					end
				end
				if UserInputService.MouseBehavior ~= targetMouseBehavior then
					UserInputService.MouseBehavior = targetMouseBehavior
				end
				local targetMouseIcon = ""
				if Reanimate.Shiftlocked then
					targetMouseIcon = "rbxasset://textures/Cursors/CrossMouseIcon.png"
				end
				if UserInputService.MouseIcon ~= targetMouseIcon then
					UserInputService.MouseIcon = targetMouseIcon
				end
				if GameSettings.RotationType ~= Enum.RotationType.MovementRelative then
					GameSettings.RotationType = Enum.RotationType.MovementRelative
				end
				local Humanoid = Reanimate.Character:FindFirstChildOfClass("Humanoid")
				local RootPart = Reanimate.Character:FindFirstChild("HumanoidRootPart")
				if Humanoid and RootPart and GameCamera.CameraSubject == Humanoid then
					if self.Scriptable then
						Camera.FieldOfView = self.FieldOfView
						Camera.FieldOfViewMode = "Vertical"
					else
						Camera.FieldOfView = 70
						Camera.FieldOfViewMode = "Vertical"
						local newCameraCFrame, newCameraFocus = self.CFrame, self.Focus
						local subjectPosition = RootPart.Position + RootPart.CFrame.UpVector * 1.5
						subjectPosition += RootPart.CFrame.Rotation * Humanoid.CameraOffset
						local input = self.Input * Vector3.new(1, GameSettings:GetCameraYInvertValue(), 1)
						self.Input = Vector3.zero
						local zoomDelta = input.Z
						if math.abs(zoomDelta) > 0 then
							if zoomDelta > 0 then
								self.Zoom += zoomDelta * (1 + self.Zoom * 0.5)
							else
								self.Zoom = (self.Zoom + zoomDelta) / (1 - zoomDelta * 0.5)
							end
						end
						if self.Zoom < 0.5 then
							self.Zoom = 0.5
						end
						self._Zoom = self.Zoom + (self._Zoom - self.Zoom) * math.exp(-32 * dt)
						local currLookVector = newCameraCFrame.LookVector
						local currPitchAngle = math.asin(currLookVector.Y)
						local constrainedRotateInput = Vector2.new(input.X, math.clamp(input.Y, math.rad(-80) + currPitchAngle, math.rad(80) + currPitchAngle))
						local startCFrame = CFrame.lookAt(Vector3.zero, currLookVector)
						local newLookCFrame = CFrame.Angles(0, -constrainedRotateInput.X, 0) * startCFrame * CFrame.Angles(-constrainedRotateInput.Y, 0, 0)
						local newLookVector = newLookCFrame.LookVector
						if self:IsMouseLocked() and not self:IsFirstPerson() then
							local cameraRelativeOffset = newLookCFrame * Vector3.new(1.7, 0, 0)
							if cameraRelativeOffset == cameraRelativeOffset then
								subjectPosition += cameraRelativeOffset
							end
						end
						newCameraFocus = CFrame.new(subjectPosition)
						local cameraFocusP = newCameraFocus.Position
						newCameraCFrame = CFrame.lookAt(cameraFocusP - newLookVector * self._Zoom, cameraFocusP)
						self.CFrame, self.Focus = newCameraCFrame, newCameraFocus
					end
					GameCamera.CFrame = self.CFrame
GameCamera.Focus = self.Focus
				end
				for _,v in Reanimate.CharacterLTMs do
					v.LocalTransparencyModifier = ltm
				end
			end
			pcall(function() CoreGui.TopBarApp.TopBarApp.FullScreenFrame.HurtOverlay.Visible = false end)
		end)
	end
end
Reanimate.CreateCharacter = function(InitCFrame)
	local RC = Reanimate.Character
	local cf = CFrame.new(Camera.Focus.Position)
	if RC then
		local r = RC:FindFirstChild("HumanoidRootPart")
		if r then
			cf = r.CFrame
		end
		RC:Destroy()
	elseif Player.Character then
		local r = Player.Character:FindFirstChild("HumanoidRootPart")
		if r then
			cf = r.CFrame
		end
	end
	if InitCFrame then
		cf = InitCFrame
	end
	Reanimate.Camera.CFrame, Reanimate.Camera.Focus = Camera.CFrame, Camera.Focus
	Reanimate.Camera:OnReset()
	RC = CreateHumanoidCharacter()
	local ltmparts = Reanimate.CharacterLTMs
	table.clear(ltmparts)
	local function OnDescendant(v)
		local exist = pcall(function()
			return v.LocalTransparencyModifier
		end)
		if exist then
			table.insert(ltmparts, v)
			local conn = nil
			conn = v.AncestryChanged:Connect(function()
				if not v:IsDescendantOf(RC) then
					local i = table.find(ltmparts, v)
					if i then
						table.remove(ltmparts, i)
					end
					conn:Disconnect()
				end
			end)
		end
	end
	RC.DescendantAdded:Connect(OnDescendant)
	for _,v in RC:GetDescendants() do
		task.spawn(OnDescendant, v)
	end
	RC:ScaleTo(Reanimate.CharacterScale)
	local RCHumanoid, RCRootPart = RC.Humanoid, RC.HumanoidRootPart
	local RCHead = RC.Head
	--[[local Anchor = Instance.new("Part", RCRootPart)
	Anchor.Name = "i can take explosions >:3"
	Anchor.Transparency = 1
	Anchor.Anchored = false
	Anchor.CanCollide = false
	Anchor.CanQuery = false
	Anchor.CanTouch = false
	Anchor.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0, 0, 0)
	Anchor.Size = Vector3.new(2048, 2048, 2048)
	local AnchorWeld = Instance.new("Weld")]]
	RC.Parent = workspace
	Reanimate.Character = RC
	RCRootPart.CFrame = cf
	local SeatWeld = nil
	local LastJumpOffSeat = 0
	local LastJump = false
	local RCP = RaycastParams.new()
	RCP.RespectCanCollide = true
	RCP.FilterType = Enum.RaycastFilterType.Exclude
	RCP.FilterDescendantsInstances = {RC}
	local noclipStates = {"Running", "Jumping", "Freefall", "Landed", "Climbing", "Swimming"}
	local fallingStates = {"Jumping", "Freefall", "PlatformStanding", "Physics", "Ragdoll", "GettingUp", "Seated", "Flying", "FallingDown"}
	local LastSafest = RCRootPart.CFrame
	Util.LinkDestroyI2C(RC, RunService.PreAnimation:Connect(function(dt)
		local CMove, CJump = Reanimate.Control.Move, Reanimate.Control.Jump
		local camCF = workspace.CurrentCamera.CFrame

local forward = camCF.LookVector
local right = camCF.RightVector

forward = Vector3.new(forward.X, 0, forward.Z)
right = Vector3.new(right.X, 0, right.Z)

if forward.Magnitude > 0 then forward = forward.Unit end
if right.Magnitude > 0 then right = right.Unit end

local moveDir = (right * CMove.X) + (forward * -CMove.Z)

if moveDir.Magnitude > 0 then
    moveDir = moveDir.Unit
end

		pcall(sethiddenproperty, RCRootPart, "PhysicsRepRootPart", nil)
		local RCHumanoidState = RCHumanoid:GetState().Name
		local clip = not table.find(noclipStates, RCHumanoidState)
		local gravaff = not not table.find(fallingStates, RCHumanoidState)
		for _,v in RC:GetChildren() do
			if v:IsA("BasePart") then
				v.CanCollide = clip or (not Reanimate.Noclip and v == RCRootPart)
			end
		end
		if gravaff then
			if Reanimate.ScaleGravity and not RCRootPart:IsGrounded() then
				RCRootPart.AssemblyLinearVelocity += Vector3.new(0, -workspace.Gravity * (Reanimate.CharacterScale - 1) * 0.25 * dt, 0)
			end
		end
		if LastJump ~= CJump then
			if CJump then
				if Reanimate.InfiniteJump and RCHumanoid:GetState() == Enum.HumanoidStateType.Freefall then
					RCRootPart.Velocity = Vector3.new(
						RCRootPart.Velocity.X, math.max(50, RCHumanoid.JumpPower), RCRootPart.Velocity.Z
					)
				end
			end
		end
		LastJump = CJump
		local TargetCameraOffset = (RCRootPart.CFrame * CFrame.new(0, 1.5, 0)):PointToObjectSpace(RCHead.Position)
		if not Reanimate.SmoothCam then
			TargetCameraOffset = Vector3.new(0, -1.5, 0) + Vector3.new(0, 1.5, 0) * RC:GetScale()
		end
		RCHumanoid.CameraOffset = TargetCameraOffset:Lerp(RCHumanoid.CameraOffset, math.exp(-9.8 * dt))
		local isFirstPerson = Reanimate.Camera:IsFirstPerson()
if Reanimate.Shiftlocked or isFirstPerson then
	local camLook = workspace.CurrentCamera.CFrame.LookVector
	local flatLook = Vector3.new(camLook.X, 0, camLook.Z)

	if flatLook.Magnitude > 0 then
		flatLook = flatLook.Unit
	
		if Reanimate.Shiftlocked then
			RCRootPart.CFrame = CFrame.lookAt(
				RCRootPart.Position,
				RCRootPart.Position + flatLook
			)
		else
			RCRootPart.CFrame = RCRootPart.CFrame:Lerp(
				CFrame.lookAt(
					RCRootPart.Position,
					RCRootPart.Position + flatLook
				),
				0.25
			)
		end
	end
end
		if RCHumanoidState == "Swimming" then
    RCHumanoid:Move(Reanimate.Camera.CFrame:VectorToWorldSpace(CMove))
else
    RCHumanoid:Move(moveDir)
end
		RCHumanoid.Jump = CJump
		if RCRootPart.Position.Y < FallenPartsDestroyHeight + 3 * Reanimate.CharacterScale then
			RCRootPart.CFrame = LastSafest
			RCRootPart.Velocity = Vector3.new(0, 50, 0)
			RCRootPart.RotVelocity = Vector3.zero
		end
		local safe = true
		for i=1, 8 do
			local off = CFrame.Angles(0, (i / 4) * math.pi, 0):VectorToWorldSpace(Vector3.new(0, 0, -0.5))
			if not workspace:Raycast(RCRootPart.Position + off, Vector3.new(0, -(3 * Reanimate.CharacterScale + 8 + RCHumanoid.HipHeight), 0), RCP) then
				safe = false
			end
		end
		if safe then
			LastSafest = RCRootPart.CFrame
		end
	end))
	end

function oof()
    local player = game:GetService("Players").LocalPlayer
    local char = player.Character
    Reanimate.CreateCharacter()
    GameCamera.CameraSubject = Reanimate.Character:WaitForChild("Humanoid")
    GameCamera.CameraType = Enum.CameraType.Scriptable
    Reanimate.Camera.Zoom = 16
    Reanimate.Camera._Zoom = 16
    task.wait(2)
local Figure = Reanimate.Character
repeat task.wait() until Figure
    and Figure:FindFirstChild("Torso")
    and Figure.Torso:FindFirstChild("Right Shoulder")
    and Figure.Torso:FindFirstChild("Left Shoulder")
    and Figure.Torso:FindFirstChild("Right Hip")
    and Figure.Torso:FindFirstChild("Left Hip")
    and Figure.Torso:FindFirstChild("Neck")
local Torso = Figure:WaitForChild("Torso")
local RightShoulder = Torso:WaitForChild("Right Shoulder")
local LeftShoulder = Torso:WaitForChild("Left Shoulder")
local RightHip = Torso:WaitForChild("Right Hip")
local LeftHip = Torso:WaitForChild("Left Hip")
local Neck = Torso:WaitForChild("Neck")
local Humanoid = Figure:WaitForChild("Humanoid")
local pose = "Standing"
task.wait()
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0,1e30,0) task.wait(3) game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored=true

local currentAnim = ""
local currentAnimInstance = nil
local currentAnimTrack = nil
local currentAnimKeyframeHandler = nil
local currentAnimSpeed = 1.0
local animTable = {}
local animNames = {
idle = {
{ id = "http://www.roblox.com/asset/?id=180435571", weight = 9 },
{ id = "http://www.roblox.com/asset/?id=180435792", weight = 1 }
},
walk = {
{ id = "http://www.roblox.com/asset/?id=180426354", weight = 10 }
},
run = {
{ id = "run.xml", weight = 10 }
},
jump = {
{ id = "http://www.roblox.com/asset/?id=125750702", weight = 10 }
},
fall = {
{ id = "http://www.roblox.com/asset/?id=180436148", weight = 10 }
},
climb = {
{ id = "http://www.roblox.com/asset/?id=180436334", weight = 10 }
},
sit = {
{ id = "http://www.roblox.com/asset/?id=178130996", weight = 10 }
},
toolnone = {
{ id = "http://www.roblox.com/asset/?id=182393478", weight = 10 }
},
toolslash = {
{ id = "http://www.roblox.com/asset/?id=129967390", weight = 10 }
-- { id = "slash.xml", weight = 10 }
},
toollunge = {
{ id = "http://www.roblox.com/asset/?id=129967478", weight = 10 }
},
wave = {
{ id = "http://www.roblox.com/asset/?id=128777973", weight = 10 }
},
point = {
{ id = "http://www.roblox.com/asset/?id=128853357", weight = 10 }
},
dance1 = {
{ id = "http://www.roblox.com/asset/?id=182435998", weight = 10 },
{ id = "http://www.roblox.com/asset/?id=182491037", weight = 10 },
{ id = "http://www.roblox.com/asset/?id=182491065", weight = 10 }
},
dance2 = {
{ id = "http://www.roblox.com/asset/?id=182436842", weight = 10 },
{ id = "http://www.roblox.com/asset/?id=182491248", weight = 10 },
{ id = "http://www.roblox.com/asset/?id=182491277", weight = 10 }
},
dance3 = {
{ id = "http://www.roblox.com/asset/?id=182436935", weight = 10 },
{ id = "http://www.roblox.com/asset/?id=182491368", weight = 10 },
{ id = "http://www.roblox.com/asset/?id=182491423", weight = 10 }
},
laugh = {
{ id = "http://www.roblox.com/asset/?id=129423131", weight = 10 }
},
cheer = {
{ id = "http://www.roblox.com/asset/?id=129423030", weight = 10 }
},
}
local dances = {"dance1", "dance2", "dance3"}

-- Existance in this list signifies that it is an emote, the value indicates if it is a looping emote
local emoteNames = { wave = false, point = false, dance1 = true, dance2 = true, dance3 = true, laugh = false, cheer = false}

function configureAnimationSet(name, fileList)
if (animTable[name] ~= nil) then
for _, connection in pairs(animTable[name].connections) do
connection:disconnect()
end
end
animTable[name] = {}
animTable[name].count = 0
animTable[name].totalWeight = 0
animTable[name].connections = {}

-- check for config values
local config = workspace.ReanimateCharacter.Animate:FindFirstChild(name)
if (config ~= nil) then
-- print("Loading anims " .. name)
table.insert(animTable[name].connections, config.ChildAdded:connect(function(child) configureAnimationSet(name, fileList) end))
table.insert(animTable[name].connections, config.ChildRemoved:connect(function(child) configureAnimationSet(name, fileList) end))
local idx = 1
for _, childPart in pairs(config:GetChildren()) do
if (childPart:IsA("Animation")) then
table.insert(animTable[name].connections, childPart.Changed:connect(function(property) configureAnimationSet(name, fileList) end))
animTable[name][idx] = {}
animTable[name][idx].anim = childPart
local weightObject = childPart:FindFirstChild("Weight")
if (weightObject == nil) then
animTable[name][idx].weight = 1
else
animTable[name][idx].weight = weightObject.Value
end
animTable[name].count = animTable[name].count + 1
animTable[name].totalWeight = animTable[name].totalWeight + animTable[name][idx].weight
-- print(name .. " [" .. idx .. "] " .. animTable[name][idx].anim.AnimationId .. " (" .. animTable[name][idx].weight .. ")")
idx = idx + 1
end
end
end

-- fallback to defaults
if (animTable[name].count <= 0) then
for idx, anim in pairs(fileList) do
animTable[name][idx] = {}
animTable[name][idx].anim = Instance.new("Animation")
animTable[name][idx].anim.Name = name
animTable[name][idx].anim.AnimationId = anim.id
animTable[name][idx].weight = anim.weight
animTable[name].count = animTable[name].count + 1
animTable[name].totalWeight = animTable[name].totalWeight + anim.weight
-- print(name .. " [" .. idx .. "] " .. anim.id .. " (" .. anim.weight .. ")")
end
end
end

-- Setup animation objects
function scriptChildModified(child)
local fileList = animNames[child.Name]
if (fileList ~= nil) then
configureAnimationSet(child.Name, fileList)
end
end

game.Players.LocalPlayer.Character.Animate.ChildAdded:connect(scriptChildModified)
game.Players.LocalPlayer.Character.Animate.ChildRemoved:connect(scriptChildModified)


for name, fileList in pairs(animNames) do
configureAnimationSet(name, fileList)
end

-- ANIMATION

-- declarations
local toolAnim = "None"
local toolAnimTime = 0

local jumpAnimTime = 0
local jumpAnimDuration = 0.3

local toolTransitionTime = 0.1
local fallTransitionTime = 0.3
local jumpMaxLimbVelocity = 0.75

-- functions

function stopAllAnimations()
local oldAnim = currentAnim

-- return to idle if finishing an emote
if (emoteNames[oldAnim] ~= nil and emoteNames[oldAnim] == false) then
oldAnim = "idle"
end

currentAnim = ""
currentAnimInstance = nil
if (currentAnimKeyframeHandler ~= nil) then
currentAnimKeyframeHandler:disconnect()
end

if (currentAnimTrack ~= nil) then
currentAnimTrack:Stop()
currentAnimTrack:Destroy()
currentAnimTrack = nil
end
return oldAnim
end

function setAnimationSpeed(speed)
if speed ~= currentAnimSpeed then
currentAnimSpeed = speed
currentAnimTrack:AdjustSpeed(currentAnimSpeed)
end
end

function keyFrameReachedFunc(frameName)
if (frameName == "End") then

local repeatAnim = currentAnim
-- return to idle if finishing an emote
if (emoteNames[repeatAnim] ~= nil and emoteNames[repeatAnim] == false) then
repeatAnim = "idle"
end

local animSpeed = currentAnimSpeed
playAnimation(repeatAnim, 0.0, Humanoid)
setAnimationSpeed(animSpeed)
end
end

-- Preload animations
function playAnimation(animName, transitionTime, humanoid)

local roll = math.random(1, animTable[animName].totalWeight)
local origRoll = roll
local idx = 1
while (roll > animTable[animName][idx].weight) do
roll = roll - animTable[animName][idx].weight
idx = idx + 1
end
-- print(animName .. " " .. idx .. " [" .. origRoll .. "]")
local anim = animTable[animName][idx].anim

-- switch animation
if (anim ~= currentAnimInstance) then

if (currentAnimTrack ~= nil) then
currentAnimTrack:Stop(transitionTime)
currentAnimTrack:Destroy()
end

currentAnimSpeed = 1.0

-- load it to the humanoid; get AnimationTrack
currentAnimTrack = humanoid:LoadAnimation(anim)
currentAnimTrack.Priority = Enum.AnimationPriority.Core

-- play the animation
currentAnimTrack:Play(transitionTime)
currentAnim = animName
currentAnimInstance = anim

-- set up keyframe name triggers
if (currentAnimKeyframeHandler ~= nil) then
currentAnimKeyframeHandler:disconnect()
end
currentAnimKeyframeHandler = currentAnimTrack.KeyframeReached:connect(keyFrameReachedFunc)

end

end

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

local toolAnimName = ""
local toolAnimTrack = nil
local toolAnimInstance = nil
local currentToolAnimKeyframeHandler = nil

function toolKeyFrameReachedFunc(frameName)
if (frameName == "End") then
-- print("Keyframe : ".. frameName)
playToolAnimation(toolAnimName, 0.0, Humanoid)
end
end


function playToolAnimation(animName, transitionTime, humanoid, priority)

local roll = math.random(1, animTable[animName].totalWeight)
local origRoll = roll
local idx = 1
while (roll > animTable[animName][idx].weight) do
roll = roll - animTable[animName][idx].weight
idx = idx + 1
end
-- print(animName .. " * " .. idx .. " [" .. origRoll .. "]")
local anim = animTable[animName][idx].anim

if (toolAnimInstance ~= anim) then

if (toolAnimTrack ~= nil) then
toolAnimTrack:Stop()
toolAnimTrack:Destroy()
transitionTime = 0
end

-- load it to the humanoid; get AnimationTrack
toolAnimTrack = humanoid:LoadAnimation(anim)
if priority then
toolAnimTrack.Priority = priority
end

-- play the animation
toolAnimTrack:Play(transitionTime)
toolAnimName = animName
toolAnimInstance = anim

currentToolAnimKeyframeHandler = toolAnimTrack.KeyframeReached:connect(toolKeyFrameReachedFunc)
end
end

function stopToolAnimations()
local oldAnim = toolAnimName

if (currentToolAnimKeyframeHandler ~= nil) then
currentToolAnimKeyframeHandler:disconnect()
end

toolAnimName = ""
toolAnimInstance = nil
if (toolAnimTrack ~= nil) then
toolAnimTrack:Stop()
toolAnimTrack:Destroy()
toolAnimTrack = nil
end


return oldAnim
end

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------


function onRunning(speed)
if speed > 0.01 then
playAnimation("walk", 0.1, Humanoid)
if currentAnimInstance and currentAnimInstance.AnimationId == "http://www.roblox.com/asset/?id=180426354" then
setAnimationSpeed(speed / 14.5)
end
pose = "Running"
else
if emoteNames[currentAnim] == nil then
playAnimation("idle", 0.1, Humanoid)
pose = "Standing"
end
end
end

function onDied()
pose = "Dead"
end

function onJumping()
playAnimation("jump", 0.1, Humanoid)
jumpAnimTime = jumpAnimDuration
pose = "Jumping"
end

function onClimbing(speed)
playAnimation("climb", 0.1, Humanoid)
setAnimationSpeed(speed / 12.0)
pose = "Climbing"
end

function onGettingUp()
pose = "GettingUp"
end

function onFreeFall()
if (jumpAnimTime <= 0) then
playAnimation("fall", fallTransitionTime, Humanoid)
end
pose = "FreeFall"
end

function onFallingDown()
pose = "FallingDown"
end

function onSeated()
pose = "Seated"
end

function onPlatformStanding()
pose = "PlatformStanding"
end

function onSwimming(speed)
if speed > 0 then
pose = "Running"
else
pose = "Standing"
end
end

function getTool()
for _, kid in ipairs(Figure:GetChildren()) do
if kid.className == "Tool" then return kid end
end
return nil
end

function getToolAnim(tool)
for _, c in ipairs(tool:GetChildren()) do
if c.Name == "toolanim" and c.className == "StringValue" then
return c
end
end
return nil
end

function animateTool()

if (toolAnim == "None") then
playToolAnimation("toolnone", toolTransitionTime, Humanoid, Enum.AnimationPriority.Idle)
return
end

if (toolAnim == "Slash") then
playToolAnimation("toolslash", 0, Humanoid, Enum.AnimationPriority.Action)
return
end

if (toolAnim == "Lunge") then
playToolAnimation("toollunge", 0, Humanoid, Enum.AnimationPriority.Action)
return
end
end

function moveSit()
RightShoulder.MaxVelocity = 0.15
LeftShoulder.MaxVelocity = 0.15
RightShoulder:SetDesiredAngle(3.14 /2)
LeftShoulder:SetDesiredAngle(-3.14 /2)
RightHip:SetDesiredAngle(3.14 /2)
LeftHip:SetDesiredAngle(-3.14 /2)
end

local lastTick = 0

function move(time)
local amplitude = 1
local frequency = 1
  local deltaTime = time - lastTick
  lastTick = time

local climbFudge = 0
local setAngles = false

  if (jumpAnimTime > 0) then
  jumpAnimTime = jumpAnimTime - deltaTime
  end

if (pose == "FreeFall" and jumpAnimTime <= 0) then
playAnimation("fall", fallTransitionTime, Humanoid)
elseif (pose == "Seated") then
playAnimation("sit", 0.5, Humanoid)
return
elseif (pose == "Running") then
playAnimation("walk", 0.1, Humanoid)
elseif (pose == "Dead" or pose == "GettingUp" or pose == "FallingDown" or pose == "Seated" or pose == "PlatformStanding") then
-- print("Wha " .. pose)
stopAllAnimations()
amplitude = 0.1
frequency = 1
setAngles = true
end

if (setAngles) then
local desiredAngle = amplitude * math.sin(time * frequency)

RightShoulder:SetDesiredAngle(desiredAngle + climbFudge)
LeftShoulder:SetDesiredAngle(desiredAngle - climbFudge)
RightHip:SetDesiredAngle(-desiredAngle)
LeftHip:SetDesiredAngle(-desiredAngle)
end

-- Tool Animation handling
local tool = getTool()
if tool and tool:FindFirstChild("Handle") then

local animStringValueObject = getToolAnim(tool)

if animStringValueObject then
toolAnim = animStringValueObject.Value
-- message recieved, delete StringValue
animStringValueObject.Parent = nil
toolAnimTime = time + .3
end

if time > toolAnimTime then
toolAnimTime = 0
toolAnim = "None"
end

animateTool()
else
stopToolAnimations()
toolAnim = "None"
toolAnimInstance = nil
toolAnimTime = 0
end
end

-- connect events
Humanoid.Died:connect(onDied)
Humanoid.Running:connect(onRunning)
Humanoid.Jumping:connect(onJumping)
Humanoid.Climbing:connect(onClimbing)
Humanoid.GettingUp:connect(onGettingUp)
Humanoid.FreeFalling:connect(onFreeFall)
Humanoid.FallingDown:connect(onFallingDown)
Humanoid.Seated:connect(onSeated)
Humanoid.PlatformStanding:connect(onPlatformStanding)
Humanoid.Swimming:connect(onSwimming)

-- setup emote chat hook
game:GetService("Players").LocalPlayer.Chatted:connect(function(msg)
local emote = ""
if msg == "/e dance" then
emote = dances[math.random(1, #dances)]
elseif (string.sub(msg, 1, 3) == "/e ") then
emote = string.sub(msg, 4)
elseif (string.sub(msg, 1, 7) == "/emote ") then
emote = string.sub(msg, 8)
end

if (pose == "Standing" and emoteNames[emote] ~= nil) then
playAnimation(emote, 0.1, Humanoid)
end

end)


-- main program

-- initialize to idle
playAnimation("idle", 0.1, Humanoid)
pose = "Standing"

while Figure.Parent ~= nil do
local _, time = wait(0.1)
move(time)
end

if Humanoid.Health == 0
then
print("death occured, waiting for respawn")
Figure:WaitForChild("Humanoid")
return
end
end
oof()
