--[[ Blue Lock: Rivals | Ball Trajectory + Distance | Delta-compatible ]]
local env = (getgenv and getgenv()) or _G
if type(env.__BLR_TRAJ) == "table" and type(env.__BLR_TRAJ.Unload) == "function" then
	pcall(env.__BLR_TRAJ.Unload)
end
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

---------------------------------------------------------------- settings
local S = {
	trajectory = true, distance = true, horizontal = false, marker = true,
	range = 300, minSpeed = 35, thickness = 0.35, opacity = 0.85, colorIndex = 1,
	labelSize = 20, gravityScale = 1, fadeDelay = 3, updateRate = 30,
	bubble = true, menuKey = Enum.KeyCode.RightShift,
}
local COLORS = {
	{"Violet", Color3.fromRGB(176, 120, 255)},
	{"Pink", Color3.fromRGB(255, 100, 200)},
	{"Cyan", Color3.fromRGB(80, 230, 255)},
	{"Lime", Color3.fromRGB(150, 255, 90)},
	{"Orange", Color3.fromRGB(255, 170, 60)},
	{"White", Color3.fromRGB(255, 255, 255)},
}
local C = {
	bg = Color3.fromRGB(24, 15, 42), element = Color3.fromRGB(46, 31, 78),
	elementHover = Color3.fromRGB(62, 42, 100), accent = Color3.fromRGB(139, 92, 246),
	accent2 = Color3.fromRGB(196, 168, 255), off = Color3.fromRGB(78, 62, 112),
	text = Color3.fromRGB(240, 235, 255), sub = Color3.fromRGB(165, 152, 200),
	danger = Color3.fromRGB(190, 60, 110),
}
local KICK_DELTA, MAX_SEG = 18, 56

---------------------------------------------------------------- helpers / state
local alive = true
local conns = {}
local shot, fade, fadeTarget, usedSegs, markerOn = nil, 0, 0, 0, false
local samples, lastPos, lastT = {}, nil, nil
local current, manualBall = nil, nil
local pickMode, pickUntil = false, 0
local candidates = {}
local statusLabel, Unload, setMenu, selectTab

local function bind(signal, fn)
	local c = signal:Connect(fn)
	conns[#conns + 1] = c
	return c
end
local function tween(obj, t, props, style, dir)
	local tw = TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end
local function new(class, props, parent)
	local inst = Instance.new(class)
	if props then for k, v in pairs(props) do inst[k] = v end end
	if parent then inst.Parent = parent end
	return inst
end
local function corner(inst, r) return new("UICorner", {CornerRadius = UDim.new(0, r)}, inst) end

---------------------------------------------------------------- world visuals
local folder = new("Folder", {Name = "BLRT"})
local function ensureFolder()
	local target = Workspace.CurrentCamera or Workspace
	if folder.Parent ~= target then folder.Parent = target end
end
ensureFolder()

local function makePart(name, size)
	return new("Part", {
		Name = name, Anchored = true, CanCollide = false, CanTouch = false, CanQuery = false,
		CastShadow = false, Locked = true, Material = Enum.Material.Neon, Transparency = 1,
		Size = size, Color = COLORS[S.colorIndex][2],
	}, folder)
end
local segs = table.create(MAX_SEG)
for i = 1, MAX_SEG do segs[i] = makePart("s", Vector3.new(0.3, 0.3, 1)) end
local marker = makePart("m", Vector3.new(0.15, 3.4, 3.4))
marker.Shape = Enum.PartType.Cylinder
local anchor = makePart("a", Vector3.new(0.2, 0.2, 0.2))

local bb = new("BillboardGui", {
	Name = "L", Adornee = anchor, AlwaysOnTop = true, Size = UDim2.fromOffset(170, 36),
	StudsOffset = Vector3.new(0, 2.4, 0), LightInfluence = 0, Enabled = false,
}, anchor)
local bbBg = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.bg, BackgroundTransparency = 1, BorderSizePixel = 0}, bb)
corner(bbBg, 10)
local bbStroke = new("UIStroke", {Color = C.accent2, Thickness = 1.6, Transparency = 1}, bbBg)
local bbText = new("TextLabel", {
	Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
	TextSize = S.labelSize, TextColor3 = Color3.new(1, 1, 1), Text = "", TextTransparency = 1,
}, bbBg)
local bbScale = new("UIScale", {Scale = 1}, bbBg)

local labelShown = false
local function showLabel(text)
	bbText.Text = text
	bb.Enabled = true
	if not labelShown then bbScale.Scale = 0.6 end
	labelShown = true
	tween(bbScale, 0.28, {Scale = 1}, Enum.EasingStyle.Back)
	tween(bbBg, 0.25, {BackgroundTransparency = 0.2})
	tween(bbStroke, 0.25, {Transparency = 0.15})
	tween(bbText, 0.25, {TextTransparency = 0})
end
local function hideLabel()
	if not labelShown then return end
	labelShown = false
	tween(bbBg, 0.3, {BackgroundTransparency = 1})
	tween(bbStroke, 0.3, {Transparency = 1})
	tween(bbText, 0.3, {TextTransparency = 1})
	task.delay(0.32, function() if not labelShown then bb.Enabled = false end end)
end

local function applyTransparency()
	local tr = 1 - S.opacity * fade
	for i = 1, usedSegs do segs[i].Transparency = tr end
	marker.Transparency = (markerOn and S.marker) and (1 - 0.7 * fade) or 1
end
local function setUsed(n)
	for i = n + 1, usedSegs do segs[i].Transparency = 1 end
	usedSegs = n
	applyTransparency()
end

---------------------------------------------------------------- raycast filter / helpers
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.RespectCanCollide = true
rayParams.IgnoreWater = true
local nextFilter, filterBall = 0, nil
local function refreshFilter(ball, now)
	if now < nextFilter and filterBall == ball then return end
	nextFilter, filterBall = now + 1.5, ball
	local list = {ball}
	for _, pl in ipairs(Players:GetPlayers()) do
		if pl.Character then list[#list + 1] = pl.Character end
	end
	rayParams.FilterDescendantsInstances = list
end

local function inCharacter(part)
	local m = part:FindFirstAncestorOfClass("Model")
	while m do
		if m:FindFirstChildOfClass("Humanoid") then return true end
		m = m.Parent and m.Parent:FindFirstAncestorOfClass("Model") or nil
	end
	return false
end
local function validBall(p) return p ~= nil and p.Parent ~= nil and p:IsDescendantOf(Workspace) end

---------------------------------------------------------------- ball detection
local NAME_HINTS = {"ball", "soccer", "bola"}
local BAD_HINTS = {"goal", "net", "field", "pitch", "spawn", "zone", "stadium", "grass", "wall", "floor", "ground", "teleport", "bench", "ballroom", "rack", "sign"}

local function updateStatus()
	if not statusLabel then return end
	local txt
	if pickMode then txt = "Tap the ball in the world..."
	elseif current then txt = "Ball: " .. current.Name .. ((manualBall and current == manualBall) and " (manual)" or " (auto)")
	else txt = "Ball: searching..." end
	if statusLabel.Text ~= txt then statusLabel.Text = txt end
end

local function scorePart(p)
	local sz = p.Size
	local ms, mn = math.max(sz.X, sz.Y, sz.Z), math.min(sz.X, sz.Y, sz.Z)
	if ms > 14 or ms < 0.8 then return 0 end
	local lname = p.Name:lower()
	local pname = p.Parent and p.Parent.Name:lower() or ""
	local score, named = 0, false
	for _, h in ipairs(NAME_HINTS) do
		if lname:find(h, 1, true) then score += 60; named = true; break end
	end
	if not named then
		for _, h in ipairs(NAME_HINTS) do
			if pname:find(h, 1, true) then score += 35; named = true; break end
		end
	end
	if named then
		for _, h in ipairs(BAD_HINTS) do
			if lname:find(h, 1, true) or pname:find(h, 1, true) then return 0 end
		end
	end
	local isRound = false
	if p:IsA("Part") and p.Shape == Enum.PartType.Ball then
		isRound = true; score += 25
	elseif mn > 0.01 and ms / mn < 1.25 then
		isRound = true; score += 10
	end
	if not named then
		if not (isRound and not p.Anchored and p.CanCollide and ms >= 1.5 and ms <= 8) then return 0 end
	end
	if not p.Anchored then score += 15 end
	if p.CanCollide then score += 5 end
	return score + 1
end

local function consider(inst)
	if not inst:IsA("BasePart") then return end
	local cam = Workspace.CurrentCamera
	if inst:IsDescendantOf(folder) or (cam and inst:IsDescendantOf(cam)) then return end
	local sc = scorePart(inst)
	if sc > 0 and not inCharacter(inst) then candidates[inst] = sc end
end

local scanning = false
local nextSelect = 0
local function scan()
	if scanning then return end
	scanning = true
	task.spawn(function()
		local list = Workspace:GetDescendants()
		for i = 1, #list do
			if not alive then break end
			consider(list[i])
			if i % 500 == 0 then task.wait() end
		end
		scanning = false
		nextSelect = 0
	end)
end

local function reselect()
	local best, bestScore = nil, -1e9
	for part, base in pairs(candidates) do
		if validBall(part) then
			local sc = base + math.min(part.AssemblyLinearVelocity.Magnitude, 60) * 0.5
			if part == current then sc += 15 end
			if sc > bestScore then best, bestScore = part, sc end
		else
			candidates[part] = nil
		end
	end
	current = best
	updateStatus()
end

local function getBall(now)
	if manualBall and validBall(manualBall) then
		if current ~= manualBall then current = manualBall; updateStatus() end
		return current
	end
	if now >= nextSelect or not validBall(current) then
		nextSelect = now + 0.4
		reselect()
	end
	if validBall(current) then return current end
	return nil
end

---------------------------------------------------------------- path math + drawing
local function pointAt(pts, cum, target)
	local n, j = #pts, 1
	while j < n - 1 and cum[j + 1] < target do j += 1 end
	local seglen = cum[j + 1] - cum[j]
	local f = seglen > 1e-6 and math.clamp((target - cum[j]) / seglen, 0, 1) or 1
	return pts[j]:Lerp(pts[j + 1], f)
end

local function placeSeg(part, a, b, th)
	local d = b - a
	local len = d.Magnitude
	if len < 1e-3 then
		part.Size = Vector3.new(th, th, 0.05)
		part.CFrame = CFrame.new(a)
		return
	end
	local up = (math.abs(d.Y) / len > 0.98) and Vector3.xAxis or Vector3.yAxis
	part.Size = Vector3.new(th, th, len + th * 0.5)
	part.CFrame = CFrame.lookAt((a + b) * 0.5, b, up)
end

local function drawPath(pts)
	local n = #pts
	if n < 2 then setUsed(0) return nil end
	local cum = table.create(n)
	cum[1] = 0
	for i = 2, n do cum[i] = cum[i - 1] + (pts[i] - pts[i - 1]).Magnitude end
	local total = cum[n]
	if total < 0.75 then setUsed(0) return nil end
	local count = math.clamp(math.floor(total / 2.2), 3, MAX_SEG)
	local th = S.thickness
	local prev, j = pts[1], 1
	for i = 1, count do
		local target = total * i / count
		while j < n - 1 and cum[j + 1] < target do j += 1 end
		local seglen = cum[j + 1] - cum[j]
		local f = seglen > 1e-6 and math.clamp((target - cum[j]) / seglen, 0, 1) or 1
		local nxt = pts[j]:Lerp(pts[j + 1], f)
		placeSeg(segs[i], prev, nxt, th)
		prev = nxt
	end
	setUsed(count)
	return total, cum
end

local function predictPath(p, v, g, radius, range)
	local pts = {p}
	local acc = Vector3.new(0, -g, 0)
	local dt, travelled = 0.07, 0
	local voidY = Workspace.FallenPartsDestroyHeight
	for _ = 1, 150 do
		local np = p + v * dt + acc * (0.5 * dt * dt)
		local nv = v + acc * dt
		local d = np - p
		local len = d.Magnitude
		if len > 1e-4 then
			local dir = d / len
			local res = Workspace:Raycast(p, dir * (len + radius), rayParams)
			if res and res.Distance - radius <= len then
				local landing = p + dir * math.max(res.Distance - radius, 0)
				pts[#pts + 1] = landing
				return pts, landing, res
			end
		end
		travelled += len
		pts[#pts + 1] = np
		if travelled >= range or np.Y < voidY then break end
		p, v = np, nv
	end
	return pts, nil, nil
end

local function applyStyle()
	local col = COLORS[S.colorIndex][2]
	for i = 1, MAX_SEG do segs[i].Color = col end
	marker.Color = col
	bbText.TextSize = S.labelSize
	bb.Size = UDim2.fromOffset(math.floor(S.labelSize * 8.5), math.floor(S.labelSize * 1.8))
	if shot and shot.state == "landed" and shot.poly then drawPath(shot.poly) end
	applyTransparency()
end

---------------------------------------------------------------- shot logic
local function cancelShot(immediate)
	shot = nil
	fadeTarget = 0
	hideLabel()
	if immediate then
		fade = 0
		markerOn = false
		setUsed(0)
	end
end

local function distText(s)
	local a, b = s.start, s.land
	local d = S.horizontal and Vector3.new(b.X - a.X, 0, b.Z - a.Z).Magnitude or (b - a).Magnitude
	return string.format("%.1f studs", d)
end

local function startShot(pos, vel, now)
	local startPos = pos
	for i = 1, #samples do
		if now - samples[i][1] <= 0.15 then startPos = samples[i][2]; break end
	end
	hideLabel()
	shot = {state = "flight", start = startPos, hist = {startPos}, lastH = startPos, t0 = now, air = 0, still = 0, prevVy = vel.Y}
	fadeTarget = 1
end

local function finishShot(pos, groundPos, radius)
	local s = shot
	if not s or s.state ~= "flight" then return end
	local poly = {}
	for i = 1, #s.hist do poly[i] = s.hist[i] end
	poly[#poly + 1] = pos
	local gp = groundPos or (pos - Vector3.new(0, radius, 0))
	markerOn = S.marker
	marker.CFrame = CFrame.new(gp + Vector3.new(0, 0.08, 0)) * CFrame.Angles(0, 0, math.rad(90))
	fadeTarget = 1
	local total, cum = drawPath(poly)
	if not total or total < 4 then cancelShot(false) return end
	s.state, s.doneAt, s.poly, s.land = "landed", os.clock(), poly, pos
	s.mid = pointAt(poly, cum, total * 0.5)
	if S.distance then
		anchor.CFrame = CFrame.new(s.mid)
		showLabel(distText(s))
	end
end

local function updateFlight(pos, vel, speed, g, radius, dt, now)
	local s = shot
	if (pos - s.lastH).Magnitude >= 1.5 and #s.hist < 400 then
		s.hist[#s.hist + 1] = pos
		s.lastH = pos
	end
	local probe = radius + 0.8 + math.max(math.abs(vel.Y), math.abs(s.prevVy)) * dt
	local gr = Workspace:Raycast(pos, Vector3.new(0, -probe, 0), rayParams)
	s.prevVy = vel.Y
	if not gr then s.air += dt end
	if speed < 4 then s.still += dt else s.still = 0 end
	if (s.air >= 0.2 and gr) or s.still >= 0.3 or now - s.t0 > 15 then
		finishShot(pos, gr and gr.Position or nil, radius)
		return
	end
	local pts, landing, res
	if not (gr and vel.Y < 3) then
		pts, landing, res = predictPath(pos, vel, g, radius, S.range)
	end
	markerOn = (landing ~= nil) and S.marker
	if markerOn then
		marker.CFrame = CFrame.new(res.Position + Vector3.new(0, 0.08, 0)) * CFrame.Angles(0, 0, math.rad(90))
	end
	local poly = {}
	local hist = s.hist
	for i = 1, #hist do poly[i] = hist[i] end
	poly[#poly + 1] = pos
	if pts then for i = 2, #pts do poly[#poly + 1] = pts[i] end end
	drawPath(poly)
end

local function resetSamples() samples, lastPos, lastT = {}, nil, nil end

local function tick(dt)
	ensureFolder()
	if not S.trajectory then
		if shot then cancelShot(true) end
		return
	end
	local now = os.clock()
	local ball = getBall(now)
	if not ball then
		if shot and shot.state == "flight" then cancelShot(false) end
		resetSamples()
		return
	end
	refreshFilter(ball, now)

	local pos = ball.Position
	local vel = ball.AssemblyLinearVelocity
	local meas = Vector3.zero
	if lastPos and lastT and now > lastT then meas = (pos - lastPos) / (now - lastT) end
	if meas.Magnitude > 900 then -- teleport / ball reset
		resetSamples()
		if shot and shot.state == "flight" then cancelShot(false) end
		lastPos, lastT = pos, now
		return
	end
	if vel.Magnitude < 1 then vel = meas end
	local speed = vel.Magnitude
	local g = Workspace.Gravity * S.gravityScale
	local sz = ball.Size
	local radius = math.max(sz.X, sz.Y, sz.Z) * 0.5

	local minRecent = speed
	for i = 1, #samples do
		if samples[i][3] < minRecent then minRecent = samples[i][3] end
	end
	local kick = (speed - minRecent) >= KICK_DELTA
	local held = inCharacter(ball)

	if held then
		if shot and shot.state == "flight" then finishShot(pos, nil, radius) end
	elseif not shot then
		if speed >= S.minSpeed then
			local airborne = Workspace:Raycast(pos, Vector3.new(0, -(radius + 1.5), 0), rayParams) == nil
			if kick or airborne then startShot(pos, vel, now) end
		end
	elseif shot.state == "landed" then
		if speed >= S.minSpeed and kick then
			cancelShot(true)
			startShot(pos, vel, now)
		end
	end
	if shot and shot.state == "flight" and not held then
		updateFlight(pos, vel, speed, g, radius, dt, now)
	end

	samples[#samples + 1] = {now, pos, speed}
	while #samples > 1 and now - samples[1][1] > 0.3 do table.remove(samples, 1) end
	lastPos, lastT = pos, now
end

---------------------------------------------------------------- UI helpers
local function guiParent()
	local ok, h = pcall(function() return gethui and gethui() end)
	if ok and typeof(h) == "Instance" then return h end
	local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
	if ok2 and cg then
		local probe = Instance.new("Folder")
		local okp = pcall(function() probe.Parent = cg end)
		probe:Destroy()
		if okp then return cg end
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local gui = new("ScreenGui", {
	Name = "BLRTraj", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	IgnoreGuiInset = true, DisplayOrder = 999,
}, guiParent())

local order = 0
local function nextOrder() order += 1 return order end
local function isPress(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end

local function makeDraggable(handle, target, onTap)
	local dragging, startInput, startPos, moved = false, nil, nil, false
	bind(handle.InputBegan, function(input)
		if isPress(input) then
			dragging, moved = true, false
			startInput, startPos = input.Position, target.Position
			local c
			c = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					c:Disconnect()
					if not moved and onTap then onTap() end
				end
			end)
		end
	end)
	bind(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - startInput
			if delta.Magnitude > 5 then moved = true end
			if moved then
				target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end
	end)
end

local function hoverFx(btn, sc, base, hover)
	bind(btn.MouseEnter, function() tween(btn, 0.12, {BackgroundColor3 = hover}) end)
	bind(btn.MouseLeave, function()
		tween(btn, 0.12, {BackgroundColor3 = base})
		tween(sc, 0.1, {Scale = 1})
	end)
	bind(btn.InputBegan, function(i) if isPress(i) then tween(sc, 0.07, {Scale = 0.95}) end end)
	bind(btn.InputEnded, function(i) if isPress(i) then tween(sc, 0.14, {Scale = 1}, Enum.EasingStyle.Back) end end)
end

---------------------------------------------------------------- window
local window = new("CanvasGroup", {
	Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 142, 0, 150),
	Size = UDim2.fromOffset(256, 252), BackgroundColor3 = Color3.new(1, 1, 1),
	BorderSizePixel = 0, GroupTransparency = 1, Visible = false,
}, gui)
corner(window, 14)
new("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(38, 22, 66), Color3.fromRGB(17, 10, 31)), Rotation = 90}, window)
new("UIStroke", {Color = C.accent, Thickness = 1.5, Transparency = 0.35}, window)
local winScale = new("UIScale", {Scale = 0.85}, window)

local header = new("Frame", {Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1}, window)
new("TextLabel", {
	BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -52, 1, 0),
	Text = "BLUE LOCK  |  TRAJECTORY", Font = Enum.Font.GothamBold, TextSize = 12,
	TextColor3 = C.accent2, TextXAlignment = Enum.TextXAlignment.Left,
}, header)
local hideBtn = new("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(24, 22),
	BackgroundColor3 = C.element, AutoButtonColor = false, Text = "-", Font = Enum.Font.GothamBold,
	TextSize = 16, TextColor3 = C.text,
}, header)
corner(hideBtn, 7)
local hideScale = new("UIScale", {Scale = 1}, hideBtn)
hoverFx(hideBtn, hideScale, C.element, C.elementHover)
makeDraggable(header, window)

local tabBar = new("Frame", {Position = UDim2.fromOffset(8, 34), Size = UDim2.new(1, -16, 0, 26), BackgroundTransparency = 1}, window)
new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, tabBar)
local pageHolder = new("Frame", {Position = UDim2.fromOffset(0, 64), Size = UDim2.new(1, 0, 1, -64), BackgroundTransparency = 1, ClipsDescendants = true}, window)

local tabs, currentTab = {}, nil

function selectTab(name)
	if currentTab == name then return end
	local old = currentTab
	currentTab = name
	for n, t in pairs(tabs) do
		local active = n == name
		tween(t.btn, 0.18, {BackgroundColor3 = active and C.accent or C.element, TextColor3 = active and Color3.new(1, 1, 1) or C.sub})
	end
	if old and tabs[old] then
		local og = tabs[old].group
		tween(og, 0.12, {GroupTransparency = 1})
		task.delay(0.13, function() if currentTab ~= old then og.Visible = false end end)
	end
	local g = tabs[name].group
	g.Visible = true
	g.GroupTransparency = 1
	g.Position = UDim2.fromOffset(14, 0)
	tween(g, 0.22, {GroupTransparency = 0, Position = UDim2.fromOffset(0, 0)})
end

local function addTab(name)
	local btn = new("TextButton", {
		Size = UDim2.new(1 / 3, -4, 1, 0), BackgroundColor3 = C.element, AutoButtonColor = false,
		Text = name, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = C.sub, LayoutOrder = nextOrder(),
	}, tabBar)
	corner(btn, 8)
	local group = new("CanvasGroup", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, GroupTransparency = 1}, pageHolder)
	local scroll = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.accent, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, group)
	new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, scroll)
	new("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 8)}, scroll)
	tabs[name] = {btn = btn, group = group}
	bind(btn.Activated, function() selectTab(name) end)
	bind(btn.MouseEnter, function() if currentTab ~= name then tween(btn, 0.12, {BackgroundColor3 = C.elementHover}) end end)
	bind(btn.MouseLeave, function() if currentTab ~= name then tween(btn, 0.12, {BackgroundColor3 = C.element}) end end)
	return scroll
end

local function addToggle(page, text, initial, callback)
	local row = new("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.element, AutoButtonColor = false, Text = "", LayoutOrder = nextOrder()}, page)
	corner(row, 8)
	local sc = new("UIScale", {Scale = 1}, row)
	new("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -62, 1, 0),
		Text = text, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = C.text,
	}, row)
	local state = initial
	local track = new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(38, 18),
		BackgroundColor3 = state and C.accent or C.off, BorderSizePixel = 0,
	}, row)
	corner(track, 9)
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
		Position = state and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
	}, track)
	corner(knob, 7)
	hoverFx(row, sc, C.element, C.elementHover)
	bind(row.Activated, function()
		state = not state
		tween(track, 0.18, {BackgroundColor3 = state and C.accent or C.off})
		tween(knob, 0.2, {Position = state and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}, Enum.EasingStyle.Back)
		callback(state)
	end)
end

local function addSlider(page, text, min, max, step, initial, fmt, callback)
	local row = new("Frame", {Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = C.element, LayoutOrder = nextOrder()}, page)
	corner(row, 8)
	new("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 4), Size = UDim2.new(1, -80, 0, 16), Text = text,
		Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	local valLbl = new("TextLabel", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 4), Size = UDim2.fromOffset(70, 16),
		Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = C.accent2, TextXAlignment = Enum.TextXAlignment.Right, Text = "",
	}, row)
	local track = new("Frame", {Position = UDim2.new(0, 10, 0, 31), Size = UDim2.new(1, -20, 0, 6), BackgroundColor3 = C.off, BorderSizePixel = 0}, row)
	corner(track, 3)
	local fill = new("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.accent, BorderSizePixel = 0}, track)
	corner(fill, 3)
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 2, BorderSizePixel = 0,
	}, track)
	corner(knob, 7)
	local hit = new("TextButton", {BackgroundTransparency = 1, Text = "", Position = UDim2.fromOffset(0, 20), Size = UDim2.new(1, 0, 0, 24), ZIndex = 3}, row)
	local value = initial
	local function render()
		local a = (value - min) / (max - min)
		fill.Size = UDim2.fromScale(a, 1)
		knob.Position = UDim2.fromScale(a, 0.5)
		valLbl.Text = fmt(value)
	end
	render()
	local function fromX(x)
		local a = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		local v = math.clamp(math.floor((min + a * (max - min)) / step + 0.5) * step, min, max)
		if v ~= value then
			value = v
			render()
			callback(v)
		end
	end
	local dragging = false
	bind(hit.InputBegan, function(i)
		if isPress(i) then
			dragging = true
			page.ScrollingEnabled = false
			tween(knob, 0.1, {Size = UDim2.fromOffset(18, 18)})
			fromX(i.Position.X)
		end
	end)
	bind(UserInputService.InputChanged, function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			fromX(i.Position.X)
		end
	end)
	bind(UserInputService.InputEnded, function(i)
		if dragging and isPress(i) then
			dragging = false
			page.ScrollingEnabled = true
			tween(knob, 0.1, {Size = UDim2.fromOffset(14, 14)})
		end
	end)
end

local function addButton(page, text, callback, base)
	base = base or C.accent
	local hover = base:Lerp(Color3.new(1, 1, 1), 0.18)
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = base, AutoButtonColor = false, Text = text,
		Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.new(1, 1, 1), LayoutOrder = nextOrder(),
	}, page)
	corner(b, 8)
	local sc = new("UIScale", {Scale = 1}, b)
	hoverFx(b, sc, base, hover)
	bind(b.Activated, function() callback(b) end)
	return b
end

local function addInfo(page, text)
	return new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = text,
		TextWrapped = true, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = C.sub,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = nextOrder(),
	}, page)
end

---------------------------------------------------------------- bubble + menu open/close
local menuOpen = false
local bubble = new("TextButton", {
	Name = "Bubble", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 28, 0.5, 0), Size = UDim2.fromOffset(34, 34),
	BackgroundColor3 = C.accent, BackgroundTransparency = 0.25, AutoButtonColor = false, Text = "BL",
	Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.new(1, 1, 1), Visible = false,
}, gui)
corner(bubble, 17)
new("UIStroke", {Color = C.accent2, Thickness = 1.2, Transparency = 0.4}, bubble)
local bubbleScale = new("UIScale", {Scale = 1}, bubble)
makeDraggable(bubble, bubble, function() setMenu(true) end)

local function refreshBubble()
	if (not menuOpen) and S.bubble then
		if not bubble.Visible then
			bubble.Visible = true
			bubbleScale.Scale = 0
			tween(bubbleScale, 0.22, {Scale = 1}, Enum.EasingStyle.Back)
		end
	else
		bubble.Visible = false
	end
end

function setMenu(open)
	menuOpen = open
	if open then
		window.Visible = true
		winScale.Scale = 0.85
		tween(winScale, 0.28, {Scale = 1}, Enum.EasingStyle.Back)
		tween(window, 0.2, {GroupTransparency = 0})
	else
		tween(winScale, 0.16, {Scale = 0.9}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		tween(window, 0.16, {GroupTransparency = 1})
		task.delay(0.18, function() if not menuOpen then window.Visible = false end end)
	end
	refreshBubble()
end
bind(hideBtn.Activated, function() setMenu(false) end)

---------------------------------------------------------------- pages
local ballPage = addTab("Ball")
local visPage = addTab("Visuals")
local setPage = addTab("Settings")

-- Ball
addToggle(ballPage, "Ball Trajectory", S.trajectory, function(v)
	S.trajectory = v
	if not v then cancelShot(true) end
end)
addToggle(ballPage, "Distance (studs)", S.distance, function(v)
	S.distance = v
	if not v then
		hideLabel()
	elseif shot and shot.state == "landed" and shot.mid then
		anchor.CFrame = CFrame.new(shot.mid)
		showLabel(distText(shot))
	end
end)
addSlider(ballPage, "Prediction range", 40, 800, 10, S.range, function(v) return string.format("%d st", v) end, function(v) S.range = v end)
addSlider(ballPage, "Min kick speed", 10, 100, 1, S.minSpeed, function(v) return string.format("%d st/s", v) end, function(v) S.minSpeed = v end)
statusLabel = addInfo(ballPage, "Ball: searching...")
statusLabel.TextColor3 = C.accent2
statusLabel.Font = Enum.Font.GothamMedium
addButton(ballPage, "Pick ball (tap it)", function()
	pickMode = true
	pickUntil = os.clock() + 12
	updateStatus()
end)
addButton(ballPage, "Auto-detect ball", function()
	manualBall = nil
	pickMode = false
	scan()
	nextSelect = 0
	updateStatus()
end, C.element)

-- Visuals
addSlider(visPage, "Line thickness", 0.1, 1.5, 0.05, S.thickness, function(v) return string.format("%.2f", v) end, function(v) S.thickness = v; applyStyle() end)
addSlider(visPage, "Line opacity", 0.2, 1, 0.05, S.opacity, function(v) return string.format("%d%%", math.floor(v * 100 + 0.5)) end, function(v) S.opacity = v; applyTransparency() end)
addButton(visPage, "Color: " .. COLORS[S.colorIndex][1], function(b)
	S.colorIndex = S.colorIndex % #COLORS + 1
	b.Text = "Color: " .. COLORS[S.colorIndex][1]
	applyStyle()
end)
addToggle(visPage, "Landing marker", S.marker, function(v) S.marker = v; applyTransparency() end)
addSlider(visPage, "Label size", 14, 32, 1, S.labelSize, function(v) return string.format("%d", v) end, function(v) S.labelSize = v; applyStyle() end)

-- Settings
local keyBtn
local listening = false
keyBtn = addButton(setPage, "Menu key: " .. S.menuKey.Name, function()
	listening = true
	keyBtn.Text = "Press a key... (Esc = cancel)"
end, C.element)
addToggle(setPage, "Floating button", S.bubble, function(v) S.bubble = v; refreshBubble() end)
addSlider(setPage, "Fade delay", 1, 10, 0.5, S.fadeDelay, function(v) return string.format("%.1f s", v) end, function(v) S.fadeDelay = v end)
addSlider(setPage, "Update rate", 15, 60, 5, S.updateRate, function(v) return string.format("%d Hz", v) end, function(v) S.updateRate = v end)
addSlider(setPage, "Gravity scale", 0.5, 1.5, 0.05, S.gravityScale, function(v) return string.format("%.2f", v) end, function(v) S.gravityScale = v end)
addToggle(setPage, "Horizontal distance only", S.horizontal, function(v)
	S.horizontal = v
	if shot and shot.state == "landed" and S.distance and labelShown then showLabel(distText(shot)) end
end)
addInfo(setPage, "Hide the menu with the '-' button. Reopen: menu key or the floating button.")
addButton(setPage, "Unload script", function() Unload() end, C.danger)

---------------------------------------------------------------- input
local function maxDim(p) local s = p.Size return math.max(s.X, s.Y, s.Z) end

local function tryPick(input)
	local camera = Workspace.CurrentCamera
	if not camera then return end
	local ray
	if input.UserInputType == Enum.UserInputType.Touch then
		ray = camera:ScreenPointToRay(input.Position.X, input.Position.Y)
	else
		local m = UserInputService:GetMouseLocation()
		ray = camera:ViewportPointToRay(m.X, m.Y)
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ex = {folder}
	if LocalPlayer.Character then ex[#ex + 1] = LocalPlayer.Character end
	params.FilterDescendantsInstances = ex
	local res = Workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
	if not res then return end
	local target
	local inst = res.Instance
	if inst:IsA("BasePart") and not inst:IsA("Terrain") and maxDim(inst) <= 14 then
		target = inst
	else
		local bestD = 10
		for part in pairs(candidates) do
			if validBall(part) then
				local d = (part.Position - res.Position).Magnitude
				if d < bestD then bestD, target = d, part end
			end
		end
	end
	if target then
		manualBall, current, pickMode = target, target, false
		updateStatus()
	else
		statusLabel.Text = "That's not the ball - tap closer"
	end
end

bind(UserInputService.InputBegan, function(input, gpe)
	if listening then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode ~= Enum.KeyCode.Escape then S.menuKey = input.KeyCode end
			listening = false
			keyBtn.Text = "Menu key: " .. S.menuKey.Name
		end
		return
	end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == S.menuKey and not UserInputService:GetFocusedTextBox() then
			setMenu(not menuOpen)
		end
	elseif pickMode and not gpe and isPress(input) then
		tryPick(input)
	end
end)

---------------------------------------------------------------- main loop
local acc, errCount = 0, 0
bind(RunService.Heartbeat, function(dt)
	if not alive then return end
	acc += dt
	if acc >= 1 / S.updateRate then
		local step = acc
		acc = 0
		local ok, err = pcall(tick, step)
		if not ok then
			errCount += 1
			if errCount <= 3 then warn("[BLR Trajectory] " .. tostring(err)) end
		end
	end
	if shot and shot.state == "landed" and os.clock() - shot.doneAt >= S.fadeDelay then
		cancelShot(false)
	end
	if fade ~= fadeTarget then
		if fadeTarget > fade then fade = math.min(fadeTarget, fade + dt * 6)
		else fade = math.max(fadeTarget, fade - dt * 2.5) end
		if fade <= 0 then markerOn = false end
		applyTransparency()
	end
	if pickMode and os.clock() > pickUntil then
		pickMode = false
		updateStatus()
	end
end)

bind(Workspace.DescendantAdded, consider)

---------------------------------------------------------------- unload / init
function Unload()
	if not alive then return end
	alive = false
	for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	pcall(function() folder:Destroy() end)
	pcall(function() gui:Destroy() end)
	candidates = {}
	if env.__BLR_TRAJ and env.__BLR_TRAJ.Unload == Unload then env.__BLR_TRAJ = nil end
end
env.__BLR_TRAJ = {Unload = Unload}

applyStyle()
scan()
selectTab("Ball")
setMenu(true)
