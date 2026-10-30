--[[ Project Solar | Blue Lock: Rivals - Trajectory, Highlight, Slow drain, No cutscenes | black/white theme, EN/RU ]]
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local ContextActionService = game:GetService("ContextActionService")
local LocalPlayer = Players.LocalPlayer

---------------------------------------------------------------- settings
local S = {
	trajectory = true, distance = true, horizontal = false, marker = true,
	range = 300, minSpeed = 35, thickness = 0.35, opacity = 0.85, colorIndex = 1,
	labelSize = 20, gravityScale = 1, fadeDelay = 3, updateRate = 30,
	bubble = true, menuKey = Enum.KeyCode.RightShift, menuAlpha = 0.2, btnAlpha = 0.15,
	highlight = true, hlBright = 0.7, hlColor = 4,
	noCutscene = false, blockRemotes = true,
}
local COLORS = {
	{"violet", Color3.fromRGB(176, 120, 255)},
	{"pink", Color3.fromRGB(255, 100, 200)},
	{"cyan", Color3.fromRGB(80, 230, 255)},
	{"lime", Color3.fromRGB(150, 255, 90)},
	{"orange", Color3.fromRGB(255, 170, 60)},
	{"white", Color3.fromRGB(255, 255, 255)},
}
local HL_COLORS = {
	{"white", Color3.fromRGB(255, 255, 255)},
	{"green", Color3.fromRGB(70, 235, 120)},
	{"blue", Color3.fromRGB(70, 150, 255)},
	{"violet", Color3.fromRGB(176, 110, 255)},
	{"red", Color3.fromRGB(255, 70, 70)},
}
local C = {
	black = Color3.fromRGB(0, 0, 0), line = Color3.fromRGB(58, 58, 72),
	element = Color3.fromRGB(240, 240, 247), elementHover = Color3.fromRGB(226, 218, 252),
	accent = Color3.fromRGB(150, 98, 250), accent2 = Color3.fromRGB(112, 64, 214),
	accentLight = Color3.fromRGB(196, 170, 255), off = Color3.fromRGB(176, 176, 194),
	text = Color3.fromRGB(22, 18, 38), sub = Color3.fromRGB(205, 198, 230),
	danger = Color3.fromRGB(214, 62, 118),
	label = Color3.fromRGB(58, 36, 108), labelStroke = Color3.fromRGB(232, 215, 255),
}
local FONT_NAME = Enum.Font.GothamBold
do
	local ok, f = pcall(function() return Enum.Font.FredokaOne end)
	if ok and f then FONT_NAME = f end
end
local KICK_DELTA, MAX_SEG = 18, 56

---------------------------------------------------------------- language
local LANG = "en"
local STR = {
	en = {
		tab_ball = "Ball", tab_player = "Player", tab_visuals = "Visuals", tab_settings = "Settings",
		ball_traj = "Ball Trajectory", ball_dist = "Distance (studs)", ball_range = "Prediction range",
		ball_minspeed = "Min kick speed", ball_hl = "Ball highlight", ball_hlbright = "Highlight brightness",
		ball_hlcolor = "Highlight color", ball_pick = "Pick ball (tap it)", ball_auto = "Auto-detect ball",
		u_st = "%d st", u_sts = "%d st/s", u_s = "%.1f s", u_hz = "%d Hz",
		st_ball = "Ball", st_search = "searching...", st_auto = "auto", st_manual = "manual",
		st_tap = "Tap the ball in the world...", st_notball = "That's not the ball - tap closer",
		cs_main = "No AWK cutscenes", cs_block = "Block cutscene events", cs_names = "Cutscene names",
		cs_st_off = "Cutscenes: off", cs_st_idle = "Cutscenes: waiting", cs_st_active = "Cutscene skipped - you can move",
		cs_st_blocked = "events blocked: %d%s", cs_st_nosupport = "event blocking is not supported here",
		cs_info = "Restores your camera and movement when a cutscene takes the camera. If one still plays, add its name (for example awk) to 'Cutscene names'. Server-side freezes cannot be removed. Keep it off in menus and the lobby.",
		pl_stam = "Slow stamina drain", pl_stamr = "Stamina slowdown", pl_flow = "Slow Flow drain", pl_flowr = "Flow slowdown",
		pl_stamname = "Stamina name", pl_flowname = "Flow name", pl_ph = "name1, name2", pl_rescan = "Rescan values",
		pl_info = "Looks for stamina/Flow in values, attributes and (on rescan) script tables. If it says 'not found', type the real object name above, or use 'Copy debug info' in Settings.",
		dr_stamina = "Stamina", dr_flow = "Flow", dr_scanning = "scanning...",
		dr_notfound = "not found (try another name below)", dr_more = " +%d more",
		vis_thick = "Line thickness", vis_opacity = "Line opacity", vis_color = "Line color",
		vis_marker = "Landing marker", vis_labelsize = "Label size",
		col_violet = "Violet", col_pink = "Pink", col_cyan = "Cyan", col_lime = "Lime", col_orange = "Orange", col_white = "White",
		hl_white = "White", hl_green = "Green", hl_blue = "Blue", hl_violet = "Violet", hl_red = "Red",
		set_lang = "Language", set_alpha = "Menu transparency", set_balpha = "Button transparency",
		set_key = "Menu key", set_keylisten = "Press a key... (Esc = cancel)", set_bubble = "Floating button",
		set_fade = "Fade delay", set_rate = "Update rate", set_grav = "Gravity scale",
		set_horiz = "Horizontal distance only", set_unload = "Unload script",
		dbg_btn = "Copy debug info", dbg_ok = "Copied %d lines - paste them in the chat", dbg_file = "No clipboard - saved to ProjectSolar_debug.txt",
		set_info = "Hide the window with the '-' button. Reopen it with the menu key or the floating PS button. Drag the title bar to move the window and the square in its bottom-right corner to resize it.",
	},
	ru = {
		tab_ball = "Мяч", tab_player = "Игрок", tab_visuals = "Визуал", tab_settings = "Настройки",
		ball_traj = "Траектория мяча", ball_dist = "Дистанция (studs)", ball_range = "Дальность прогноза",
		ball_minspeed = "Мин. скорость удара", ball_hl = "Подсветка мяча", ball_hlbright = "Яркость подсветки",
		ball_hlcolor = "Цвет подсветки", ball_pick = "Выбрать мяч (нажмите на него)", ball_auto = "Автоопределение мяча",
		u_st = "%d st", u_sts = "%d st/с", u_s = "%.1f с", u_hz = "%d Гц",
		st_ball = "Мяч", st_search = "поиск...", st_auto = "авто", st_manual = "вручную",
		st_tap = "Коснитесь мяча в игре...", st_notball = "Это не мяч — коснитесь точнее",
		cs_main = "Без AWK-катсцен", cs_block = "Блокировать события катсцен", cs_names = "Имена катсцен",
		cs_st_off = "Катсцены: выключено", cs_st_idle = "Катсцены: ожидание", cs_st_active = "Катсцена пропущена — вы можете двигаться",
		cs_st_blocked = "заблокировано событий: %d%s", cs_st_nosupport = "блокировка событий здесь не поддерживается",
		cs_info = "Возвращает вам камеру и управление, когда катсцена забирает камеру. Если катсцена всё равно проигрывается, добавьте её имя (например, awk) в «Имена катсцен». Серверную заморозку убрать нельзя. В меню и лобби лучше держать выключенным.",
		pl_stam = "Медленная трата стамины", pl_stamr = "Замедление стамины", pl_flow = "Медленная трата Flow", pl_flowr = "Замедление Flow",
		pl_stamname = "Имя стамины", pl_flowname = "Имя Flow", pl_ph = "имя1, имя2", pl_rescan = "Пересканировать значения",
		pl_info = "Ищет стамину/Flow в значениях, атрибутах и (при пересканировании) таблицах скриптов. Если написано «не найдено», введите настоящее имя объекта выше или нажмите «Скопировать отладочную информацию» в настройках.",
		dr_stamina = "Стамина", dr_flow = "Flow", dr_scanning = "поиск...",
		dr_notfound = "не найдено (введите другое имя ниже)", dr_more = " +ещё %d",
		vis_thick = "Толщина линии", vis_opacity = "Непрозрачность линии", vis_color = "Цвет линии",
		vis_marker = "Маркер падения", vis_labelsize = "Размер надписи",
		col_violet = "Фиолетовый", col_pink = "Розовый", col_cyan = "Голубой", col_lime = "Салатовый", col_orange = "Оранжевый", col_white = "Белый",
		hl_white = "Белый", hl_green = "Зелёный", hl_blue = "Синий", hl_violet = "Фиолетовый", hl_red = "Красный",
		set_lang = "Язык", set_alpha = "Прозрачность меню", set_balpha = "Прозрачность кнопок",
		set_key = "Клавиша меню", set_keylisten = "Нажмите клавишу... (Esc — отмена)", set_bubble = "Плавающая кнопка",
		set_fade = "Задержка исчезновения", set_rate = "Частота обновления", set_grav = "Множитель гравитации",
		set_horiz = "Только горизонтальная дистанция", set_unload = "Выгрузить скрипт",
		dbg_btn = "Скопировать отладочную информацию", dbg_ok = "Скопировано строк: %d — вставьте их в чат", dbg_file = "Буфера обмена нет — сохранено в ProjectSolar_debug.txt",
		set_info = "Окно скрывается кнопкой «-». Открыть его снова можно клавишей меню или плавающей кнопкой PS. Перемещайте окно за заголовок, а размер меняйте квадратом в правом нижнем углу.",
	},
}
local function T(k)
	local t = STR[LANG]
	return (t and t[k]) or STR.en[k] or k
end
local function L(k) return function() return T(k) end end

local textBinds, langHooks = {}, {}
local function bindText(inst, prop, fn)
	textBinds[#textBinds + 1] = {inst, prop, fn}
	inst[prop] = fn()
end
local function onLang(fn) langHooks[#langHooks + 1] = fn end
local function refreshLang()
	for _, b in ipairs(textBinds) do
		pcall(function() b[1][b[2]] = b[3]() end)
	end
	for _, fn in ipairs(langHooks) do pcall(fn) end
end

local themed = {}
local function tint(inst)
	themed[#themed + 1] = inst
	inst.BackgroundTransparency = S.btnAlpha
end

---------------------------------------------------------------- helpers / state
local alive = true
local conns = {}
local shot, fade, fadeTarget, usedSegs, markerOn = nil, 0, 0, 0, false
local samples, lastPos, lastT = {}, nil, nil
local current, manualBall = nil, nil
local pickMode, pickUntil = false, 0
local candidates = {}
local listening = false
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

local hl = new("Highlight", {
	Name = "H", Enabled = false, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
	FillTransparency = 1, OutlineTransparency = 1,
	FillColor = HL_COLORS[S.hlColor][2], OutlineColor = HL_COLORS[S.hlColor][2]:Lerp(Color3.new(1, 1, 1), 0.35),
}, folder)
local glow = new("SphereHandleAdornment", {
	Name = "G", AlwaysOnTop = true, ZIndex = 1, Transparency = 1, Visible = false, Radius = 1.5,
	Color3 = HL_COLORS[S.hlColor][2],
}, folder)

local bb = new("BillboardGui", {
	Name = "L", Adornee = anchor, AlwaysOnTop = true, Size = UDim2.fromOffset(170, 36),
	StudsOffset = Vector3.new(0, 2.4, 0), LightInfluence = 0, Enabled = false,
}, anchor)
local bbBg = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.label, BackgroundTransparency = 1, BorderSizePixel = 0}, bb)
corner(bbBg, 10)
local bbStroke = new("UIStroke", {Color = C.labelStroke, Thickness = 1.6, Transparency = 1}, bbBg)
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
	if pickMode then
		txt = T("st_tap")
	elseif current then
		txt = T("st_ball") .. ": " .. current.Name .. " (" .. ((manualBall and current == manualBall) and T("st_manual") or T("st_auto")) .. ")"
	else
		txt = T("st_ball") .. ": " .. T("st_search")
	end
	if statusLabel.Text ~= txt then statusLabel.Text = txt end
end

local function scorePart(p)
	local sz = p.Size
	local ms, mn = math.max(sz.X, sz.Y, sz.Z), math.min(sz.X, sz.Y, sz.Z)
	if ms > 14 or ms < 0.8 then return 0, false end
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
			if lname:find(h, 1, true) or pname:find(h, 1, true) then return 0, false end
		end
	end
	local isRound = false
	if p:IsA("Part") and p.Shape == Enum.PartType.Ball then
		isRound = true; score += 25
	elseif mn > 0.01 and ms / mn < 1.25 then
		isRound = true; score += 10
	end
	if not named then
		if not (isRound and not p.Anchored and p.CanCollide and ms >= 1.5 and ms <= 8) then return 0, false end
	end
	if not p.Anchored then score += 15 end
	if p.CanCollide then score += 5 end
	return score + 1, named
end

local function consider(inst)
	if not inst:IsA("BasePart") then return end
	local cam = Workspace.CurrentCamera
	if inst:IsDescendantOf(folder) or (cam and inst:IsDescendantOf(cam)) then return end
	local sc, named = scorePart(inst)
	if sc <= 0 then return end
	if inCharacter(inst) then
		if not named or inst:FindFirstAncestorOfClass("Accessory") then return end
		sc -= 10
	end
	candidates[inst] = sc
end

local scanning = false
local nextSelect, nextRescan = 0, 0
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
			local tr = part.Transparency
			if tr >= 0.95 then sc -= 70 elseif tr <= 0.3 then sc += 20 end
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
	if now >= nextRescan then
		nextRescan = now + 4
		scan()
	end
	return nil
end

---------------------------------------------------------------- ball highlight
local hlShown = false
local hlBall, hlTarget, hlNext = nil, nil, 0

local function hlTargets()
	local b = S.hlBright
	return math.clamp(1 - b * 0.75, 0.05, 0.95), math.clamp(1 - b, 0, 0.9), math.clamp(1 - b * 0.55, 0.3, 0.95)
end
local function applyHighlightColor()
	local col = HL_COLORS[S.hlColor][2]
	hl.FillColor = col
	hl.OutlineColor = col:Lerp(Color3.new(1, 1, 1), 0.35)
	glow.Color3 = col
end
local function applyHighlightBrightness()
	if hlShown then
		local f, o, g = hlTargets()
		tween(hl, 0.1, {FillTransparency = f, OutlineTransparency = o})
		tween(glow, 0.1, {Transparency = g})
	end
end
local function pickHlTarget(ball, now)
	if ball == hlBall and now < hlNext then return hlTarget end
	hlBall, hlNext = ball, now + 2
	local t = ball
	local m = ball.Parent
	if m and m.ClassName == "Model" and not inCharacter(ball) then
		local ok, size = pcall(function() return m:GetExtentsSize() end)
		if ok and math.max(size.X, size.Y, size.Z) <= 14 then t = m end
	end
	hlTarget = t
	return t
end
local function updateHighlight(ball, now)
	if S.highlight and ball then
		local target = pickHlTarget(ball, now)
		if hl.Adornee ~= target then hl.Adornee = target end
		if glow.Adornee ~= ball then
			glow.Adornee = ball
			local s = ball.Size
			glow.Radius = math.max(s.X, s.Y, s.Z) * 0.58
		end
		if not hlShown then
			hlShown = true
			hl.Enabled = true
			glow.Visible = true
			hl.FillTransparency, hl.OutlineTransparency, glow.Transparency = 1, 1, 1
			local f, o, g = hlTargets()
			tween(hl, 0.3, {FillTransparency = f, OutlineTransparency = o})
			tween(glow, 0.3, {Transparency = g})
		end
	elseif hlShown then
		hlShown = false
		tween(hl, 0.25, {FillTransparency = 1, OutlineTransparency = 1})
		tween(glow, 0.25, {Transparency = 1})
		task.delay(0.27, function()
			if not hlShown then
				hl.Enabled = false
				glow.Visible = false
			end
		end)
	end
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
	local now = os.clock()
	if not S.trajectory and not S.highlight and not hlShown then
		if shot then cancelShot(true) end
		return
	end
	local ball = getBall(now)
	updateHighlight(ball, now)
	if not S.trajectory then
		if shot then cancelShot(true) end
		return
	end
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

---------------------------------------------------------------- slow drain (stamina / flow)
local DRAINS = {
	stamina = {defaults = {"stamina", "stam", "energy"}, hints = {"stamina", "stam", "energy"}, on = false, ratio = 1.5, targets = {}, fields = {}, conns = {}, scanning = false},
	flow = {defaults = {"flow"}, hints = {"flow"}, on = false, ratio = 1.5, targets = {}, fields = {}, conns = {}, scanning = false},
}
local DRAIN_BAD = {"max", "regen", "rate", "cost", "cooldown", "speed", "mult", "enabled", "bar", "gui", "text", "delay", "limit", "stamp"}

local function nameMatches(name, hints)
	local l = name:lower()
	local ok = false
	for _, h in ipairs(hints) do
		if l:find(h, 1, true) then ok = true; break end
	end
	if not ok then return false end
	for _, b in ipairs(DRAIN_BAD) do
		if l:find(b, 1, true) then return false end
	end
	return true
end

local function mark(seen, inst, key)
	local s = seen[inst]
	if not s then s = {}; seen[inst] = s end
	if s[key] then return false end
	s[key] = true
	return true
end

local function considerInstance(inst, d, found, seen)
	if (inst:IsA("NumberValue") or inst:IsA("IntValue")) and nameMatches(inst.Name, d.hints) then
		if mark(seen, inst, "\0value") then found[#found + 1] = {inst = inst, kind = "value"} end
	end
	for name, val in pairs(inst:GetAttributes()) do
		if type(val) == "number" and nameMatches(name, d.hints) then
			if mark(seen, inst, name) then found[#found + 1] = {inst = inst, kind = "attr", name = name} end
		end
	end
end

local function describeTarget(t)
	if t.kind == "field" then return "table[" .. tostring(t.key) .. "]" end
	return t.inst:GetFullName() .. (t.kind == "attr" and ("@" .. t.name) or "")
end

local function updateDrainStatus(kind)
	local d = DRAINS[kind]
	if not d.statusLabel then return end
	local txt
	if d.scanning then
		txt = T("dr_scanning")
	elseif #d.targets == 0 then
		txt = T("dr_notfound")
	else
		txt = describeTarget(d.targets[1]) .. (#d.targets > 1 and string.format(T("dr_more"), #d.targets - 1) or "")
	end
	d.statusLabel.Text = T("dr_" .. kind) .. ": " .. txt
end

local function detachDrain(d)
	for _, c in ipairs(d.conns) do pcall(function() c:Disconnect() end) end
	d.conns, d.targets, d.fields = {}, {}, {}
end

local function attachTarget(d, t)
	if t.kind == "field" then
		t.last = t.tbl[t.key]
		d.fields[#d.fields + 1] = t
		return
	end
	local function get()
		if t.kind == "value" then return t.inst.Value end
		return t.inst:GetAttribute(t.name)
	end
	local function set(v)
		if t.kind == "value" then t.inst.Value = v else t.inst:SetAttribute(t.name, v) end
	end
	t.last = get()
	local busy = false
	local function onChange()
		if busy then return end
		local v = get()
		if type(v) ~= "number" then return end
		if d.on and t.last and v < t.last then
			local nv = t.last - (t.last - v) / d.ratio
			if t.kind == "value" and t.inst:IsA("IntValue") then nv = math.floor(nv + math.random()) end
			busy = true
			pcall(set, nv)
			busy = false
			t.last = nv
		else
			t.last = v
		end
	end
	local sig
	if t.kind == "value" then sig = t.inst:GetPropertyChangedSignal("Value") else sig = t.inst:GetAttributeChangedSignal(t.name) end
	d.conns[#d.conns + 1] = sig:Connect(onChange)
end

local function pollFields(d)
	for _, t in ipairs(d.fields) do
		local v = t.tbl[t.key]
		if type(v) == "number" then
			if d.on and t.last and v < t.last then
				local nv = t.last - (t.last - v) / d.ratio
				t.tbl[t.key] = nv
				t.last = nv
			else
				t.last = v
			end
		end
	end
end

local function deepScan(d, found)
	if not getgc then return end
	local ok, gc = pcall(getgc, true)
	if not ok or type(gc) ~= "table" then return end
	local added = 0
	for i = 1, #gc do
		local t = gc[i]
		if type(t) == "table" then
			pcall(function()
				local c = 0
				for k, v in next, t do
					c += 1
					if c > 60 then break end
					if type(k) == "string" and type(v) == "number" and nameMatches(k, d.hints) then
						found[#found + 1] = {kind = "field", tbl = t, key = k}
						added += 1
					end
				end
			end)
		end
		if i % 1500 == 0 then task.wait() end
		if added >= 40 or not alive then break end
	end
end

local function scanDrain(kind, deep)
	local d = DRAINS[kind]
	if d.scanning then return end
	d.scanning = true
	detachDrain(d)
	updateDrainStatus(kind)
	task.spawn(function()
		local found, seen, n = {}, {}, 0
		local function walk(root)
			considerInstance(root, d, found, seen)
			for _, inst in ipairs(root:GetDescendants()) do
				considerInstance(inst, d, found, seen)
				n += 1
				if n % 400 == 0 then task.wait() end
			end
		end
		pcall(walk, LocalPlayer)
		if LocalPlayer.Character then pcall(walk, LocalPlayer.Character) end
		pcall(function()
			for _, inst in ipairs(ReplicatedStorage:GetDescendants()) do
				if inst.Name == LocalPlayer.Name or inst.Name == tostring(LocalPlayer.UserId) then walk(inst) end
				n += 1
				if n % 400 == 0 then task.wait() end
			end
		end)
		if deep then pcall(deepScan, d, found) end
		if alive then
			for _, t in ipairs(found) do pcall(attachTarget, d, t) end
			d.targets = found
		end
		d.scanning = false
		updateDrainStatus(kind)
	end)
end

local function parseHints(str, fallback)
	local list = {}
	for token in string.gmatch(str:lower(), "[^,%s]+") do list[#list + 1] = token end
	if #list == 0 then return fallback end
	return list
end

---------------------------------------------------------------- gui root
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
	Name = "ProjectSolar", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	IgnoreGuiInset = true, DisplayOrder = 999,
}, guiParent())

---------------------------------------------------------------- cutscene guard (camera / movement / events)
local CUT = {
	hints = {"cutscene", "cinematic", "awak", "awk"}, remotes = {}, blocked = {}, blockedCount = 0, blockedNames = "",
	unsupported = false, activeUntil = 0, active = false, takeover = false,
	yaw = 0, pitch = 0.4, dist = 12, drag = Vector2.zero,
}
local cutStatusLabel
local lastNormalCF, normalFov = nil, 70
local normalMove = {walk = 16, jp = 50, jh = 7.2}
local controlsObj, nextCtl, nextGui = nil, 0, 0
local hiddenGuis = {}

local function updateCutStatus()
	if not cutStatusLabel then return end
	local txt
	if not S.noCutscene then
		txt = T("cs_st_off")
	else
		txt = CUT.active and T("cs_st_active") or T("cs_st_idle")
		if S.blockRemotes then
			if CUT.unsupported then
				txt = txt .. "; " .. T("cs_st_nosupport")
			else
				txt = txt .. "; " .. string.format(T("cs_st_blocked"), CUT.blockedCount, CUT.blockedNames)
			end
		end
	end
	if cutStatusLabel.Text ~= txt then cutStatusLabel.Text = txt end
end

local function matchesHints(name, hints)
	local l = name:lower()
	for _, h in ipairs(hints) do
		if l:find(h, 1, true) then return true end
	end
	return false
end

local function sigOf(r)
	if r:IsA("RemoteEvent") then return r.OnClientEvent end
	return r.Event
end

local function isEventLike(inst) return inst:IsA("RemoteEvent") or inst:IsA("BindableEvent") end

local function rebuildRemotes()
	CUT.remotes = {}
	pcall(function()
		for _, inst in ipairs(ReplicatedStorage:GetDescendants()) do
			if isEventLike(inst) and matchesHints(inst.Name, CUT.hints) then
				CUT.remotes[#CUT.remotes + 1] = inst
			end
		end
	end)
end

local function blockPass()
	if not getconnections then
		CUT.unsupported = true
		return
	end
	local n, names = 0, {}
	for _, r in ipairs(CUT.remotes) do
		local ok, list = pcall(function() return getconnections(sigOf(r)) end)
		if ok and type(list) == "table" then
			for _, c in ipairs(list) do pcall(function() c:Disable() end) end
			CUT.blocked[r] = true
			n += 1
			if #names < 2 then names[#names + 1] = r.Name end
		end
	end
	CUT.blockedCount = n
	CUT.blockedNames = (#names > 0) and (" (" .. table.concat(names, ", ") .. ")") or ""
end

local function unblockAll()
	if getconnections then
		for r in pairs(CUT.blocked) do
			pcall(function()
				for _, c in ipairs(getconnections(sigOf(r))) do c:Enable() end
			end)
		end
	end
	CUT.blocked, CUT.blockedCount, CUT.blockedNames = {}, 0, ""
end

local function hideCutsceneGuis(now)
	if now < nextGui then return end
	nextGui = now + 0.3
	local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if not pg then return end
	for _, g in ipairs(pg:GetChildren()) do
		if g:IsA("ScreenGui") and g ~= gui and g.Enabled and matchesHints(g.Name, CUT.hints) then
			hiddenGuis[g] = true
			g.Enabled = false
		end
	end
end

local function restoreCutsceneGuis()
	for g in pairs(hiddenGuis) do pcall(function() g.Enabled = true end) end
	hiddenGuis = {}
end

local function getControls()
	if controlsObj then return controlsObj end
	local ps = LocalPlayer:FindFirstChild("PlayerScripts")
	local pm = ps and ps:FindFirstChild("PlayerModule")
	if pm then
		local ok, mod = pcall(require, pm)
		if ok and mod then
			local ok2, c = pcall(function() return mod:GetControls() end)
			if ok2 then controlsObj = c end
		end
	end
	return controlsObj
end

local function recordMovement(hum, cam)
	if hum.WalkSpeed > 0 then normalMove.walk = hum.WalkSpeed end
	if hum.UseJumpPower then
		if hum.JumpPower > 0 then normalMove.jp = hum.JumpPower end
	elseif hum.JumpHeight > 0 then
		normalMove.jh = hum.JumpHeight
	end
	normalFov = cam.FieldOfView
end

local function fixMovement(hum, char, now)
	if hum.WalkSpeed < normalMove.walk * 0.5 then hum.WalkSpeed = normalMove.walk end
	if hum.UseJumpPower then
		if hum.JumpPower <= 0 then hum.JumpPower = normalMove.jp end
	elseif hum.JumpHeight <= 0 then
		hum.JumpHeight = normalMove.jh
	end
	if hum.PlatformStand then hum.PlatformStand = false end
	if not hum.AutoRotate then hum.AutoRotate = true end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp and hrp.Anchored then hrp.Anchored = false end
	if now >= nextCtl then
		nextCtl = now + 0.4
		local c = getControls()
		if c then pcall(function() c:Enable() end) end
		pcall(function()
			for name in pairs(ContextActionService:GetAllBoundActionInfo()) do
				local l = name:lower()
				if l:find("freeze", 1, true) or l:find("cutscene", 1, true) then
					ContextActionService:UnbindAction(name)
				end
			end
		end)
	end
end

-- own third-person camera, used while a script holds the camera (cutscene)
local function emuStart(hrp)
	local focus = hrp.Position + Vector3.new(0, 2, 0)
	local ref = lastNormalCF and lastNormalCF.Position or (focus + Vector3.new(0, 6, 12))
	local off = ref - focus
	local mag = math.max(off.Magnitude, 0.01)
	CUT.dist = math.clamp(mag, 6, 30)
	CUT.yaw = math.atan2(off.X, off.Z)
	CUT.pitch = math.asin(math.clamp(off.Y / mag, -0.9, 0.9))
	CUT.drag = Vector2.zero
end

local function emuStep(cam, hrp)
	local d = CUT.drag
	CUT.drag = Vector2.zero
	CUT.yaw -= d.X * 0.006
	CUT.pitch = math.clamp(CUT.pitch + d.Y * 0.006, -0.2, 1.3)
	local focus = hrp.Position + Vector3.new(0, 2, 0)
	local cp = math.cos(CUT.pitch)
	local pos = focus + Vector3.new(math.sin(CUT.yaw) * cp, math.sin(CUT.pitch), math.cos(CUT.yaw) * cp) * CUT.dist
	cam.CFrame = CFrame.lookAt(pos, focus)
end

local function guardStep()
	if not alive or not S.noCutscene then return end
	local cam = Workspace.CurrentCamera
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not cam or not hum or not hrp or hum.Health <= 0 then return end
	local now = os.clock()
	local sub = cam.CameraSubject
	if sub ~= nil and sub ~= hum and not (sub:IsA("BasePart") and sub:IsDescendantOf(char)) then
		cam.CameraSubject = hum
		CUT.activeUntil = now + 0.5
	end
	if cam.CameraType == Enum.CameraType.Scriptable then
		if not CUT.takeover then
			CUT.takeover = true
			emuStart(hrp)
		end
		CUT.activeUntil = now + 0.5
		emuStep(cam, hrp)
		cam.FieldOfView = normalFov
	else
		CUT.takeover = false
	end
	local inWindow = now < CUT.activeUntil
	if inWindow then
		fixMovement(hum, char, now)
		hideCutsceneGuis(now)
	else
		recordMovement(hum, cam)
	end
	if inWindow ~= CUT.active then
		CUT.active = inWindow
		if not inWindow then restoreCutsceneGuis() end
		updateCutStatus()
	end
end

pcall(function() RunService:UnbindFromRenderStep("PS_CamCapture") end)
pcall(function() RunService:UnbindFromRenderStep("PS_CamGuard") end)
RunService:BindToRenderStep("PS_CamCapture", Enum.RenderPriority.Camera.Value + 1, function()
	if not S.noCutscene then return end
	local cam = Workspace.CurrentCamera
	if cam and cam.CameraType == Enum.CameraType.Custom then lastNormalCF = cam.CFrame end
end)
RunService:BindToRenderStep("PS_CamGuard", Enum.RenderPriority.Last.Value, function()
	pcall(guardStep)
end)

bind(UserInputService.InputChanged, function(input, gpe)
	if not CUT.takeover then return end
	local t = input.UserInputType
	if t == Enum.UserInputType.MouseMovement then
		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
			CUT.drag += Vector2.new(input.Delta.X, input.Delta.Y)
		end
	elseif t == Enum.UserInputType.Touch and not gpe then
		CUT.drag += Vector2.new(input.Delta.X, input.Delta.Y)
	end
end)

bind(ReplicatedStorage.DescendantAdded, function(inst)
	if isEventLike(inst) and matchesHints(inst.Name, CUT.hints) then
		CUT.remotes[#CUT.remotes + 1] = inst
	end
end)
task.spawn(function()
	while alive do
		task.wait(2)
		if alive and S.noCutscene and S.blockRemotes then
			blockPass()
			updateCutStatus()
		end
	end
end)

---------------------------------------------------------------- debug dump
local DUMP_KEYS = {"stam", "flow", "awak", "awk", "energy", "sprint", "meter", "cutscene", "freeze", "stun", "ball"}

local function pathOf(i)
	local ok, p = pcall(function() return i:GetFullName() end)
	return ok and p or tostring(i)
end

local function buildDump()
	local out = {}
	local function add(s) out[#out + 1] = s end
	add("== Project Solar debug == PlaceId " .. game.PlaceId .. " | " .. os.date("%Y-%m-%d %H:%M"))
	add(string.format("exec: getgc=%s getconnections=%s hookmeta=%s setclipboard=%s writefile=%s request=%s",
		tostring(getgc ~= nil), tostring(getconnections ~= nil), tostring(hookmetamethod ~= nil),
		tostring(setclipboard ~= nil), tostring(writefile ~= nil), tostring((request or http_request) ~= nil)))
	local cam = Workspace.CurrentCamera
	if cam then add("camera: " .. tostring(cam.CameraType) .. " subject=" .. (cam.CameraSubject and cam.CameraSubject.ClassName or "nil")) end
	add("-- ball")
	if current then
		add(string.format("current: %s [%s] size=%s transp=%.2f anchored=%s inChar=%s", pathOf(current), current.ClassName,
			tostring(current.Size), current.Transparency, tostring(current.Anchored), tostring(inCharacter(current))))
	else
		add("current: none")
	end
	local list = {}
	for p, sc in pairs(candidates) do
		if validBall(p) then list[#list + 1] = {p, sc} end
	end
	table.sort(list, function(a, b) return a[2] > b[2] end)
	for i = 1, math.min(8, #list) do
		add(string.format("cand %d: %s (%d) transp=%.2f", i, pathOf(list[i][1]), list[i][2], list[i][1].Transparency))
	end
	add("-- values / attributes (player, character)")
	local n = 0
	local function dumpInst(inst)
		if n >= 150 then return end
		if inst:IsA("ValueBase") and matchesHints(inst.Name, DUMP_KEYS) then
			local ok, v = pcall(function() return inst.Value end)
			if ok then n += 1; add(pathOf(inst) .. " = " .. tostring(v)) end
		end
		for k, v in pairs(inst:GetAttributes()) do
			if n < 150 and matchesHints(k, DUMP_KEYS) then n += 1; add(pathOf(inst) .. "@" .. k .. " = " .. tostring(v)) end
		end
	end
	for _, root in ipairs({LocalPlayer, LocalPlayer.Character}) do
		dumpInst(root)
		for _, d in ipairs(root:GetDescendants()) do dumpInst(d) end
	end
	add("-- events in ReplicatedStorage")
	local m = 0
	for _, inst in ipairs(ReplicatedStorage:GetDescendants()) do
		if m < 220 and (inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction") or inst:IsA("BindableEvent")) then
			m += 1
			add((matchesHints(inst.Name, DUMP_KEYS) and "* " or "  ") .. inst.ClassName .. " " .. pathOf(inst))
		end
	end
	add("-- PlayerGui")
	local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if pg then
		for i, g in ipairs(pg:GetChildren()) do
			if i <= 60 then add(g.ClassName .. " " .. g.Name .. (g:IsA("ScreenGui") and (" enabled=" .. tostring(g.Enabled)) or "")) end
		end
	end
	return out
end

local function runDump()
	local ok, lines = pcall(buildDump)
	if not ok then return "error: " .. tostring(lines) end
	local text = table.concat(lines, "\n")
	local copied = false
	if setclipboard then copied = pcall(setclipboard, text) end
	if writefile then pcall(writefile, "ProjectSolar_debug.txt", text) end
	if copied then return string.format(T("dbg_ok"), #lines) end
	return T("dbg_file")
end

---------------------------------------------------------------- user interface (own function: keeps the main chunk under Luau's 200-locals limit)
local avatarFile = nil

local function buildUI()
local order = 0
local function nextOrder() order += 1 return order end
local function isPress(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end
local function isMove(i)
	return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
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
		if dragging and isMove(input) then
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
	bind(btn.InputBegan, function(i) if isPress(i) then tween(sc, 0.07, {Scale = 0.96}) end end)
	bind(btn.InputEnded, function(i) if isPress(i) then tween(sc, 0.14, {Scale = 1}, Enum.EasingStyle.Back) end end)
end

---------------------------------------------------------------- window (desktop style, black)
local WIN_W, WIN_H, SIDE_W, BAR_H = 560, 330, 156, 38
local window = new("CanvasGroup", {
	Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(WIN_W, WIN_H), BackgroundColor3 = C.black, BackgroundTransparency = S.menuAlpha,
	BorderSizePixel = 0, GroupTransparency = 1, Visible = false,
}, gui)
corner(window, 12)
new("UIStroke", {Color = C.accent, Thickness = 2, Transparency = 0.3}, window)
local winScale = new("UIScale", {Scale = 0.85}, window)

local titleBar = new("Frame", {Size = UDim2.new(1, 0, 0, BAR_H), BackgroundColor3 = C.black, BackgroundTransparency = S.menuAlpha, BorderSizePixel = 0}, window)
new("Frame", {AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = C.accent, BorderSizePixel = 0}, titleBar)
new("TextLabel", {
	BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -70, 1, 0),
	Text = "Project Solar", Font = Enum.Font.GothamBold, TextSize = 19,
	TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left,
}, titleBar)
local hideBtn = new("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(32, 24),
	BackgroundColor3 = C.element, AutoButtonColor = false, Text = "-", Font = Enum.Font.GothamBold,
	TextSize = 20, TextColor3 = C.text,
}, titleBar)
corner(hideBtn, 7)
tint(hideBtn)
local hideScale = new("UIScale", {Scale = 1}, hideBtn)
hoverFx(hideBtn, hideScale, C.element, C.elementHover)
makeDraggable(titleBar, window)

local sidebar = new("Frame", {Position = UDim2.fromOffset(0, BAR_H), Size = UDim2.new(0, SIDE_W, 1, -BAR_H), BackgroundColor3 = C.black, BackgroundTransparency = S.menuAlpha, BorderSizePixel = 0}, window)
new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, sidebar)
new("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, sidebar)
new("Frame", {Position = UDim2.fromOffset(SIDE_W - 1, BAR_H), Size = UDim2.new(0, 1, 1, -BAR_H), BackgroundColor3 = C.line, BorderSizePixel = 0}, window)
local pageHolder = new("Frame", {Position = UDim2.fromOffset(SIDE_W, BAR_H), Size = UDim2.new(1, -SIDE_W, 1, -BAR_H), BackgroundTransparency = 1, ClipsDescendants = true}, window)

local function applyTheme()
	window.BackgroundTransparency = S.menuAlpha
	titleBar.BackgroundTransparency = S.menuAlpha
	sidebar.BackgroundTransparency = S.menuAlpha
	for _, e in ipairs(themed) do e.BackgroundTransparency = S.btnAlpha end
end

-- user card: Roblox avatar in a circle + real Roblox username
local userCard = new("Frame", {Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 1, LayoutOrder = nextOrder()}, sidebar)
local avatarBack = new("Frame", {
	AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0), Size = UDim2.fromOffset(42, 42),
	BackgroundColor3 = Color3.fromRGB(28, 28, 36), BorderSizePixel = 0,
}, userCard)
corner(avatarBack, 21)
new("UIStroke", {Color = C.accent, Thickness = 2}, avatarBack)
local letter = new("TextLabel", {
	Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = string.upper(string.sub(LocalPlayer.Name, 1, 1)),
	Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = Color3.new(1, 1, 1),
}, avatarBack)
local avatar = new("ImageLabel", {
	Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScaleType = Enum.ScaleType.Crop,
	ImageTransparency = 1, Image = "",
}, avatarBack)
corner(avatar, 21)
local nameLbl = new("TextLabel", {
	BackgroundTransparency = 1, Position = UDim2.fromOffset(52, 0), Size = UDim2.new(1, -52, 1, 0), Text = LocalPlayer.Name,
	Font = FONT_NAME, TextColor3 = Color3.new(1, 1, 1), TextScaled = true, TextXAlignment = Enum.TextXAlignment.Left,
}, userCard)
new("UITextSizeConstraint", {MaxTextSize = 16, MinTextSize = 8}, nameLbl)
new("Frame", {Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = C.line, BorderSizePixel = 0, LayoutOrder = nextOrder()}, sidebar)

-- avatar loader (Roblox website thumbnails API -> local file -> image)
local avatarShown, avatarUrl = false, nil

local function httpGetRaw(url)
	local req = (syn and syn.request) or (http and http.request) or http_request or request
	if req then
		local ok, res = pcall(req, {Url = url, Method = "GET"})
		if ok and type(res) == "table" and res.Body and (res.StatusCode == nil or res.StatusCode == 200) then return res.Body end
	end
	local ok, body = pcall(function() return game:HttpGet(url) end)
	if ok then return body end
	return nil
end

local function fetchAvatarUrl()
	local api = "https://thumbnails.roblox.com/v1/users/avatar-bust?userIds=" .. LocalPlayer.UserId .. "&size=150x150&format=Png&isCircular=false"
	local body = httpGetRaw(api)
	if not body then return nil end
	local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
	if not ok or type(data) ~= "table" or type(data.data) ~= "table" or not data.data[1] then return nil end
	local entry = data.data[1]
	if entry.state ~= "Completed" or not entry.imageUrl then return nil end
	return entry.imageUrl
end

local function showAvatar()
	avatarShown = true
	tween(avatar, 0.35, {ImageTransparency = 0})
	tween(letter, 0.3, {TextTransparency = 1})
end

local function showWhenLoaded()
	local t0 = os.clock()
	while alive and not avatar.IsLoaded and os.clock() - t0 < 4 do task.wait(0.1) end
	if alive and avatar.IsLoaded then
		showAvatar()
		return true
	end
	return false
end

local function applyAvatarFromWeb()
	local url = fetchAvatarUrl()
	if not url then return false end
	if url == avatarUrl then return true end
	local getAsset = getcustomasset or getsynasset
	if not (writefile and getAsset) then return false end
	local bytes = httpGetRaw(url)
	if not bytes or #bytes < 100 then return false end
	local fname = "ProjectSolar_avatar_" .. LocalPlayer.UserId .. "_" .. os.time() .. ".png"
	if not pcall(writefile, fname, bytes) then return false end
	local ok, asset = pcall(getAsset, fname)
	if not ok or not asset then return false end
	local old = avatarFile
	avatarFile, avatarUrl = fname, url
	avatar.Image = asset
	avatar.ImageTransparency = 1
	local loaded = showWhenLoaded()
	if old and delfile then pcall(delfile, old) end
	if not loaded then avatarUrl = nil end
	return loaded
end

local function loadAvatarInitial()
	for _ = 1, 3 do
		if not alive then return end
		local ok, res = pcall(applyAvatarFromWeb)
		if ok and res then return end
		task.wait(1.5)
	end
	if not alive or avatarShown then return end
	avatar.Image = "rbxthumb://type=AvatarBust&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
	if showWhenLoaded() then return end
	local ok, url = pcall(function()
		return (Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150))
	end)
	if ok and url then
		avatar.Image = url
		showWhenLoaded()
	end
end

task.spawn(function()
	loadAvatarInitial()
	while alive do
		task.wait(45)
		if alive then pcall(applyAvatarFromWeb) end
	end
end)
bind(LocalPlayer.CharacterAppearanceLoaded, function()
	task.delay(3, function()
		if alive then pcall(applyAvatarFromWeb) end
	end)
end)

-- resize grip (bottom-right corner)
local grip = new("TextButton", {
	AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -5, 1, -5), Size = UDim2.fromOffset(18, 18),
	BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.6, AutoButtonColor = false, Text = "", ZIndex = 20,
}, window)
corner(grip, 5)
do
	local MIN_W, MIN_H, MAX_W, MAX_H = 440, 300, 820, 460
	local resizing, rInput, rSize, rPos = false, nil, nil, nil
	bind(grip.InputBegan, function(input)
		if isPress(input) then
			resizing = true
			rInput, rSize, rPos = input.Position, window.Size, window.Position
			tween(grip, 0.1, {BackgroundTransparency = 0.2})
			local c
			c = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizing = false
					tween(grip, 0.15, {BackgroundTransparency = 0.6})
					c:Disconnect()
				end
			end)
		end
	end)
	bind(UserInputService.InputChanged, function(input)
		if resizing and isMove(input) then
			local d = input.Position - rInput
			local w = math.clamp(rSize.X.Offset + d.X, MIN_W, MAX_W)
			local h = math.clamp(rSize.Y.Offset + d.Y, MIN_H, MAX_H)
			window.Size = UDim2.fromOffset(w, h)
			window.Position = UDim2.new(rPos.X.Scale, rPos.X.Offset + (w - rSize.X.Offset) / 2, rPos.Y.Scale, rPos.Y.Offset + (h - rSize.Y.Offset) / 2)
		end
	end)
end

local tabs, currentTab = {}, nil

function selectTab(name)
	if currentTab == name then return end
	local old = currentTab
	currentTab = name
	for n, t in pairs(tabs) do
		local active = n == name
		tween(t.btn, 0.18, {BackgroundColor3 = active and Color3.new(1, 1, 1) or C.element, TextColor3 = active and C.accent2 or C.text})
		tween(t.stroke, 0.18, {Transparency = active and 0 or 1})
	end
	if old and tabs[old] then
		local og = tabs[old].group
		tween(og, 0.12, {GroupTransparency = 1})
		task.delay(0.13, function() if currentTab ~= old then og.Visible = false end end)
	end
	local g = tabs[name].group
	g.Visible = true
	g.GroupTransparency = 1
	g.Position = UDim2.fromOffset(16, 0)
	tween(g, 0.22, {GroupTransparency = 0, Position = UDim2.fromOffset(0, 0)})
end

local function addTab(id)
	local btn = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = C.element, AutoButtonColor = false, Text = "",
		Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = nextOrder(),
	}, sidebar)
	corner(btn, 8)
	tint(btn)
	bindText(btn, "Text", L("tab_" .. id:lower()))
	new("UIPadding", {PaddingLeft = UDim.new(0, 14)}, btn)
	local stroke = new("UIStroke", {Color = C.accent, Thickness = 2, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, btn)
	local group = new("CanvasGroup", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, GroupTransparency = 1}, pageHolder)
	local scroll = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
		ScrollBarImageColor3 = C.accentLight, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, group)
	new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, scroll)
	new("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 30)}, scroll)
	tabs[id] = {btn = btn, group = group, stroke = stroke}
	bind(btn.Activated, function() selectTab(id) end)
	bind(btn.MouseEnter, function() if currentTab ~= id then tween(btn, 0.12, {BackgroundColor3 = C.elementHover}) end end)
	bind(btn.MouseLeave, function() if currentTab ~= id then tween(btn, 0.12, {BackgroundColor3 = C.element}) end end)
	return scroll
end

local function addToggle(page, labelFn, initial, callback)
	local row = new("TextButton", {Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = C.element, AutoButtonColor = false, Text = "", LayoutOrder = nextOrder()}, page)
	corner(row, 8)
	tint(row)
	local sc = new("UIScale", {Scale = 1}, row)
	local lbl = new("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -80, 1, 0), Text = "",
		TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = C.text,
	}, row)
	bindText(lbl, "Text", labelFn)
	local state = initial
	local track = new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(46, 24),
		BackgroundColor3 = state and C.accent or C.off, BorderSizePixel = 0,
	}, row)
	corner(track, 12)
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(18, 18), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
		Position = state and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
	}, track)
	corner(knob, 9)
	hoverFx(row, sc, C.element, C.elementHover)
	bind(row.Activated, function()
		state = not state
		tween(track, 0.18, {BackgroundColor3 = state and C.accent or C.off})
		tween(knob, 0.2, {Position = state and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, Enum.EasingStyle.Back)
		callback(state)
	end)
end

local function addSlider(page, labelFn, min, max, step, initial, fmt, callback)
	local row = new("Frame", {Size = UDim2.new(1, 0, 0, 54), BackgroundColor3 = C.element, LayoutOrder = nextOrder()}, page)
	corner(row, 8)
	tint(row)
	local lbl = new("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 6), Size = UDim2.new(1, -110, 0, 18), Text = "",
		Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	bindText(lbl, "Text", labelFn)
	local valLbl = new("TextLabel", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 6), Size = UDim2.fromOffset(90, 18),
		Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = C.accent2, TextXAlignment = Enum.TextXAlignment.Right, Text = "",
	}, row)
	local track = new("Frame", {Position = UDim2.new(0, 14, 0, 37), Size = UDim2.new(1, -28, 0, 8), BackgroundColor3 = C.off, BorderSizePixel = 0}, row)
	corner(track, 4)
	local fill = new("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.accent, BorderSizePixel = 0}, track)
	corner(fill, 4)
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 2, BorderSizePixel = 0,
	}, track)
	corner(knob, 9)
	new("UIStroke", {Color = C.accent, Thickness = 2}, knob)
	local hit = new("TextButton", {BackgroundTransparency = 1, Text = "", Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, 0, 0, 28), ZIndex = 3}, row)
	local value = initial
	local function render()
		local a = (value - min) / (max - min)
		fill.Size = UDim2.fromScale(a, 1)
		knob.Position = UDim2.fromScale(a, 0.5)
		valLbl.Text = fmt(value)
	end
	render()
	onLang(render)
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
			tween(knob, 0.1, {Size = UDim2.fromOffset(23, 23)})
			fromX(i.Position.X)
		end
	end)
	bind(UserInputService.InputChanged, function(i)
		if dragging and isMove(i) then fromX(i.Position.X) end
	end)
	bind(UserInputService.InputEnded, function(i)
		if dragging and isPress(i) then
			dragging = false
			page.ScrollingEnabled = true
			tween(knob, 0.1, {Size = UDim2.fromOffset(18, 18)})
		end
	end)
end

local function addButton(page, textFn, callback, base)
	base = base or C.element
	local light = (base == C.element)
	local hover = light and C.elementHover or base:Lerp(Color3.new(1, 1, 1), 0.18)
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = base, AutoButtonColor = false, Text = "",
		Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = light and C.text or Color3.new(1, 1, 1),
		LayoutOrder = nextOrder(),
	}, page)
	corner(b, 8)
	if light then tint(b) end
	bindText(b, "Text", textFn)
	local sc = new("UIScale", {Scale = 1}, b)
	hoverFx(b, sc, base, hover)
	bind(b.Activated, function() callback(b) end)
	return b
end

local function addInfo(page, textFn)
	local lbl = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = "",
		TextWrapped = true, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = C.sub,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = nextOrder(),
	}, page)
	if textFn then bindText(lbl, "Text", textFn) end
	return lbl
end

local function addTextInput(page, labelFn, default, phFn, callback)
	local row = new("Frame", {Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = C.element, LayoutOrder = nextOrder()}, page)
	corner(row, 8)
	tint(row)
	local lbl = new("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(0.4, -14, 1, 0), Text = "",
		Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	bindText(lbl, "Text", labelFn)
	local box = new("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0.6, -12, 0, 28),
		BackgroundColor3 = Color3.fromRGB(216, 212, 236), Text = default, PlaceholderText = "", ClearTextOnFocus = false,
		Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = C.text, PlaceholderColor3 = Color3.fromRGB(120, 114, 150),
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)
	corner(box, 6)
	bindText(box, "PlaceholderText", phFn)
	bind(box.FocusLost, function() callback(box.Text) end)
	return box
end

local function addDropdown(page, labelFn, count, nameFn, getIndex, onPick)
	local ROW_H, OPT_H, GAP = 38, 32, 4
	local fullH = ROW_H + GAP + count * (OPT_H + GAP)
	local container = new("Frame", {Size = UDim2.new(1, 0, 0, ROW_H), BackgroundTransparency = 1, ClipsDescendants = true, LayoutOrder = nextOrder()}, page)
	local row = new("TextButton", {Size = UDim2.new(1, 0, 0, ROW_H), BackgroundColor3 = C.element, AutoButtonColor = false, Text = ""}, container)
	corner(row, 8)
	tint(row)
	local sc = new("UIScale", {Scale = 1}, row)
	hoverFx(row, sc, C.element, C.elementHover)
	local lbl = new("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(0.5, -14, 1, 0), Text = "",
		Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	bindText(lbl, "Text", labelFn)
	local cur = new("TextLabel", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 0), Size = UDim2.new(0.5, -14, 1, 0),
		Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = C.accent2, TextXAlignment = Enum.TextXAlignment.Right, Text = "",
	}, row)
	local open = false
	local opts = {}
	local function refresh()
		cur.Text = nameFn(getIndex()) .. (open and " «" or " »")
		for i, b in ipairs(opts) do
			local sel = (i == getIndex())
			b.Text = nameFn(i)
			b.TextColor3 = sel and C.accent2 or C.text
			b.Font = sel and Enum.Font.GothamBold or Enum.Font.GothamMedium
		end
	end
	for i = 1, count do
		local b = new("TextButton", {
			Position = UDim2.fromOffset(0, ROW_H + GAP + (i - 1) * (OPT_H + GAP)), Size = UDim2.new(1, 0, 0, OPT_H),
			BackgroundColor3 = C.element, AutoButtonColor = false, Text = "", Font = Enum.Font.GothamMedium,
			TextSize = 14, TextColor3 = C.text,
		}, container)
		corner(b, 8)
		tint(b)
		local bsc = new("UIScale", {Scale = 1}, b)
		hoverFx(b, bsc, C.element, C.elementHover)
		bind(b.Activated, function()
			onPick(i)
			open = false
			tween(container, 0.2, {Size = UDim2.new(1, 0, 0, ROW_H)})
			refresh()
		end)
		opts[i] = b
	end
	bind(row.Activated, function()
		open = not open
		tween(container, 0.22, {Size = UDim2.new(1, 0, 0, open and fullH or ROW_H)})
		refresh()
	end)
	onLang(refresh)
	refresh()
end

---------------------------------------------------------------- bubble + menu open/close
local menuOpen = false
local bubble = new("TextButton", {
	Name = "Bubble", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 32, 0.5, 0), Size = UDim2.fromOffset(40, 40),
	BackgroundColor3 = C.black, BackgroundTransparency = 0.1, AutoButtonColor = false, Text = "PS",
	Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1, 1, 1), Visible = false,
}, gui)
corner(bubble, 20)
new("UIStroke", {Color = C.accent, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, bubble)
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
local playerPage = addTab("Player")
local visPage = addTab("Visuals")
local setPage = addTab("Settings")

local function stFmt(key) return function(v) return string.format(T(key), v) end end
local function pct(v) return string.format("%d%%", math.floor(v * 100 + 0.5)) end

-- Ball
addToggle(ballPage, L("ball_traj"), S.trajectory, function(v)
	S.trajectory = v
	if not v then cancelShot(true) end
end)
addToggle(ballPage, L("ball_dist"), S.distance, function(v)
	S.distance = v
	if not v then
		hideLabel()
	elseif shot and shot.state == "landed" and shot.mid then
		anchor.CFrame = CFrame.new(shot.mid)
		showLabel(distText(shot))
	end
end)
addSlider(ballPage, L("ball_range"), 40, 800, 10, S.range, stFmt("u_st"), function(v) S.range = v end)
addSlider(ballPage, L("ball_minspeed"), 10, 100, 1, S.minSpeed, stFmt("u_sts"), function(v) S.minSpeed = v end)
addToggle(ballPage, L("ball_hl"), S.highlight, function(v) S.highlight = v end)
addSlider(ballPage, L("ball_hlbright"), 0.1, 1, 0.05, S.hlBright, pct, function(v) S.hlBright = v; applyHighlightBrightness() end)
addDropdown(ballPage, L("ball_hlcolor"), #HL_COLORS,
	function(i) return T("hl_" .. HL_COLORS[i][1]) end,
	function() return S.hlColor end,
	function(i) S.hlColor = i; applyHighlightColor() end)
statusLabel = addInfo(ballPage, nil)
statusLabel.TextColor3 = C.accentLight
statusLabel.Font = Enum.Font.GothamMedium
onLang(updateStatus)
updateStatus()
addButton(ballPage, L("ball_pick"), function()
	pickMode = true
	pickUntil = os.clock() + 12
	updateStatus()
end)
addButton(ballPage, L("ball_auto"), function()
	manualBall = nil
	pickMode = false
	scan()
	nextSelect = 0
	updateStatus()
end)

-- Player: slow drain
local function ratioFmt(v) return string.format("x%.1f", v) end
addToggle(playerPage, L("pl_stam"), DRAINS.stamina.on, function(v)
	DRAINS.stamina.on = v
	if v and #DRAINS.stamina.targets == 0 then scanDrain("stamina", true) end
end)
addSlider(playerPage, L("pl_stamr"), 1.1, 4, 0.1, DRAINS.stamina.ratio, ratioFmt, function(v) DRAINS.stamina.ratio = v end)
addToggle(playerPage, L("pl_flow"), DRAINS.flow.on, function(v)
	DRAINS.flow.on = v
	if v and #DRAINS.flow.targets == 0 then scanDrain("flow", true) end
end)
addSlider(playerPage, L("pl_flowr"), 1.1, 4, 0.1, DRAINS.flow.ratio, ratioFmt, function(v) DRAINS.flow.ratio = v end)
for _, kind in ipairs({"stamina", "flow"}) do
	local d = DRAINS[kind]
	d.statusLabel = addInfo(playerPage, nil)
	d.statusLabel.TextColor3 = C.accentLight
	d.statusLabel.Font = Enum.Font.GothamMedium
	onLang(function() updateDrainStatus(kind) end)
	updateDrainStatus(kind)
end
addTextInput(playerPage, L("pl_stamname"), "stamina", L("pl_ph"), function(txt)
	DRAINS.stamina.hints = parseHints(txt, DRAINS.stamina.defaults)
	scanDrain("stamina", true)
end)
addTextInput(playerPage, L("pl_flowname"), "flow", L("pl_ph"), function(txt)
	DRAINS.flow.hints = parseHints(txt, DRAINS.flow.defaults)
	scanDrain("flow", true)
end)
addButton(playerPage, L("pl_rescan"), function()
	scanDrain("stamina", true)
	scanDrain("flow", true)
end)
addInfo(playerPage, L("pl_info"))

-- Player: cutscenes
addToggle(playerPage, L("cs_main"), S.noCutscene, function(v)
	S.noCutscene = v
	if v then
		if S.blockRemotes then
			rebuildRemotes()
			blockPass()
		end
	else
		unblockAll()
		restoreCutsceneGuis()
		CUT.activeUntil, CUT.active, CUT.takeover = 0, false, false
	end
	updateCutStatus()
end)
addToggle(playerPage, L("cs_block"), S.blockRemotes, function(v)
	S.blockRemotes = v
	if v and S.noCutscene then
		rebuildRemotes()
		blockPass()
	else
		unblockAll()
	end
	updateCutStatus()
end)
addTextInput(playerPage, L("cs_names"), "cutscene, cinematic, awak, awk", L("pl_ph"), function(txt)
	CUT.hints = parseHints(txt, {"cutscene", "cinematic", "awak", "awk"})
	rebuildRemotes()
	if S.noCutscene and S.blockRemotes then
		unblockAll()
		blockPass()
	end
	updateCutStatus()
end)
cutStatusLabel = addInfo(playerPage, nil)
cutStatusLabel.TextColor3 = C.accentLight
cutStatusLabel.Font = Enum.Font.GothamMedium
onLang(updateCutStatus)
updateCutStatus()
addInfo(playerPage, L("cs_info"))

-- Visuals
addSlider(visPage, L("vis_thick"), 0.1, 1.5, 0.05, S.thickness, function(v) return string.format("%.2f", v) end, function(v) S.thickness = v; applyStyle() end)
addSlider(visPage, L("vis_opacity"), 0.2, 1, 0.05, S.opacity, pct, function(v) S.opacity = v; applyTransparency() end)
local function lineColorText() return T("vis_color") .. ": " .. T("col_" .. COLORS[S.colorIndex][1]) end
addButton(visPage, lineColorText, function(b)
	S.colorIndex = S.colorIndex % #COLORS + 1
	b.Text = lineColorText()
	applyStyle()
end)
addToggle(visPage, L("vis_marker"), S.marker, function(v) S.marker = v; applyTransparency() end)
addSlider(visPage, L("vis_labelsize"), 14, 32, 1, S.labelSize, function(v) return string.format("%d", v) end, function(v) S.labelSize = v; applyStyle() end)

-- Settings
addDropdown(setPage, L("set_lang"), 2,
	function(i) return i == 1 and "English" or "Русский" end,
	function() return LANG == "en" and 1 or 2 end,
	function(i) LANG = (i == 1) and "en" or "ru"; refreshLang() end)
addSlider(setPage, L("set_alpha"), 0, 0.7, 0.05, S.menuAlpha, pct, function(v) S.menuAlpha = v; applyTheme() end)
addSlider(setPage, L("set_balpha"), 0, 0.7, 0.05, S.btnAlpha, pct, function(v) S.btnAlpha = v; applyTheme() end)
local function keyText()
	if listening then return T("set_keylisten") end
	return T("set_key") .. ": " .. S.menuKey.Name
end
local keyBtn = addButton(setPage, keyText, function(b)
	listening = true
	b.Text = keyText()
end)
addToggle(setPage, L("set_bubble"), S.bubble, function(v) S.bubble = v; refreshBubble() end)
addSlider(setPage, L("set_fade"), 1, 10, 0.5, S.fadeDelay, stFmt("u_s"), function(v) S.fadeDelay = v end)
addSlider(setPage, L("set_rate"), 15, 60, 5, S.updateRate, stFmt("u_hz"), function(v) S.updateRate = v end)
addSlider(setPage, L("set_grav"), 0.5, 1.5, 0.05, S.gravityScale, function(v) return string.format("%.2f", v) end, function(v) S.gravityScale = v end)
addToggle(setPage, L("set_horiz"), S.horizontal, function(v)
	S.horizontal = v
	if shot and shot.state == "landed" and S.distance and labelShown then showLabel(distText(shot)) end
end)
local dbgLabel
addButton(setPage, L("dbg_btn"), function()
	dbgLabel.Text = runDump()
end)
dbgLabel = addInfo(setPage, nil)
dbgLabel.TextColor3 = C.accentLight
dbgLabel.Font = Enum.Font.GothamMedium
addInfo(setPage, L("set_info"))
addButton(setPage, L("set_unload"), function() Unload() end, C.danger)

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
		statusLabel.Text = T("st_notball")
	end
end

bind(UserInputService.InputBegan, function(input, gpe)
	if listening then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode ~= Enum.KeyCode.Escape then S.menuKey = input.KeyCode end
			listening = false
			keyBtn.Text = keyText()
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
			if errCount <= 3 then warn("[Project Solar] " .. tostring(err)) end
		end
	end
	for _, d in pairs(DRAINS) do
		if #d.fields > 0 then pcall(pollFields, d) end
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

applyTheme()
end
buildUI()

bind(Workspace.DescendantAdded, consider)
bind(LocalPlayer.CharacterAdded, function()
	task.delay(2, function()
		if alive then
			scanDrain("stamina")
			scanDrain("flow")
		end
	end)
end)
task.spawn(function()
	while alive do
		task.wait(15)
		for kind, d in pairs(DRAINS) do
			if alive and d.on and #d.targets == 0 and not d.scanning then scanDrain(kind) end
		end
	end
end)

---------------------------------------------------------------- unload / init
function Unload()
	if not alive then return end
	alive = false
	for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	pcall(function() RunService:UnbindFromRenderStep("PS_CamCapture") end)
	pcall(function() RunService:UnbindFromRenderStep("PS_CamGuard") end)
	unblockAll()
	restoreCutsceneGuis()
	for _, d in pairs(DRAINS) do detachDrain(d) end
	pcall(function() folder:Destroy() end)
	pcall(function() gui:Destroy() end)
	if avatarFile and delfile then pcall(delfile, avatarFile) end
	candidates = {}
	if env.__BLR_TRAJ and env.__BLR_TRAJ.Unload == Unload then env.__BLR_TRAJ = nil end
end
env.__BLR_TRAJ = {Unload = Unload}

applyStyle()
rebuildRemotes()
scan()
scanDrain("stamina")
scanDrain("flow")
selectTab("Ball")
setMenu(true)
