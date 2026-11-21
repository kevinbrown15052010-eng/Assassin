--[[ Assassin Script | UI (visual part only, no functions yet) ]]
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

local FOLDER = "AssassinScript" -- folder with logo.png, hands.png and icons/ inside the executor workspace

local TITLE = "Assassin Script"
local REFRESH_SECONDS = 120 -- Players Online refresh: every 2 minutes
local FONT = Enum.Font.Merriweather

local C = {
	text = Color3.fromRGB(242, 242, 243),
	muted = Color3.fromRGB(154, 155, 161),
	win = Color3.fromRGB(13, 14, 17),
	white = Color3.new(1, 1, 1),
}

----------------------------------------------------------------- assets
local function fileAsset(path)
	local ok, res = pcall(function()
		if isfile and isfile(path) then
			return (getcustomasset or getsynasset)(path)
		end
	end)
	return ok and res or ""
end

local logoImg = fileAsset(FOLDER .. "/logo.png")
local handsImg = fileAsset(FOLDER .. "/hands.png")
local iconCache = {}
local function iconAsset(name)
	if iconCache[name] == nil then iconCache[name] = fileAsset(FOLDER .. "/icons/" .. name .. ".png") end
	return iconCache[name]
end

----------------------------------------------------------------- helpers
local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end

local function corner(o, r) return new("UICorner", { CornerRadius = UDim.new(0, r) }, o) end
local function stroke(o, t) return new("UIStroke", { Color = C.white, Transparency = t, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, o) end
local function tween(o, t, props) TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad), props):Play() end

local function icon(parent, name, px, pos, color)
	return new("ImageLabel", {
		BackgroundTransparency = 1, Image = iconAsset(name), ImageColor3 = color or C.text,
		Size = UDim2.fromOffset(px, px), Position = pos,
	}, parent)
end

local function text(parent, t, size, color, pos, sz, align)
	return new("TextLabel", {
		BackgroundTransparency = 1, Text = t, Font = FONT, TextSize = size, TextColor3 = color,
		Position = pos, Size = sz, TextXAlignment = align or Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, parent)
end

local function line(parent, pos, sz)
	return new("Frame", { BackgroundColor3 = C.white, BackgroundTransparency = 0.94, BorderSizePixel = 0, Position = pos, Size = sz }, parent)
end

local function card(parent, pos, sz)
	local f = new("Frame", { BackgroundColor3 = C.white, BackgroundTransparency = 0.965, BorderSizePixel = 0, Position = pos, Size = sz }, parent)
	corner(f, 16); stroke(f, 0.91)
	new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(0, 0.5) }, f)
	return f
end

----------------------------------------------------------------- gui root
local function cleanup(p) pcall(function() local o = p:FindFirstChild("AssassinScript"); if o then o:Destroy() end end) end
cleanup(LP:WaitForChild("PlayerGui"))
pcall(function() cleanup(game:GetService("CoreGui")) end)
pcall(function() if gethui then cleanup(gethui()) end end)

local gui = new("ScreenGui", { Name = "AssassinScript", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 100, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
local okParent = pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not okParent or not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

local W, H, TOP, SIDE = 600, 360, 56, 160

local win = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(W, H),
	BackgroundColor3 = C.win, BackgroundTransparency = 0.06, BorderSizePixel = 0, ClipsDescendants = true,
}, gui)
corner(win, 22); stroke(win, 0.88)
new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(205, 205, 210)) }, win)

local scaleObj = new("UIScale", {}, win)
local function fit()
	local cam = workspace.CurrentCamera
	if not cam then return end
	local vp = cam.ViewportSize
	scaleObj.Scale = math.clamp(math.min(vp.X / (W + 40), vp.Y / (H + 40)), 0.5, 1)
end
fit()

----------------------------------------------------------------- top bar
local top = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, TOP) }, win)
line(top, UDim2.new(0, 0, 1, -1), UDim2.new(1, 0, 0, 1))
line(top, UDim2.new(0, SIDE, 0, 0), UDim2.new(0, 1, 1, 0))
new("ImageLabel", { BackgroundTransparency = 1, Image = logoImg, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(SIDE / 2, TOP / 2), Size = UDim2.fromOffset(38, 26), ScaleType = Enum.ScaleType.Fit }, top)
if logoImg == "" then text(top, "▲", 22, C.text, UDim2.fromOffset(0, 0), UDim2.fromOffset(SIDE, TOP), Enum.TextXAlignment.Center) end
text(top, TITLE, 22, C.text, UDim2.fromOffset(SIDE + 18, 0), UDim2.new(1, -SIDE - 120, 1, 0))

local function winBtn(name, xOff)
	local b = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = C.white, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(1, xOff, 0.5, 0), Size = UDim2.fromOffset(34, 34) }, top)
	corner(b, 10)
	icon(b, name, 18, UDim2.fromOffset(8, 8))
	b.MouseEnter:Connect(function() tween(b, 0.12, { BackgroundTransparency = 0.9 }) end)
	b.MouseLeave:Connect(function() tween(b, 0.12, { BackgroundTransparency = 1 }) end)
	return b
end
local minBtn, closeBtn = winBtn("minus", -84), winBtn("x", -46)

----------------------------------------------------------------- body
local body = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, TOP), Size = UDim2.new(1, 0, 1, -TOP) }, win)

-- sidebar
local side = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0, SIDE, 1, 0) }, body)
line(side, UDim2.new(1, -1, 0, 0), UDim2.new(0, 1, 1, 0))

local homePage = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(SIDE, 0), Size = UDim2.new(1, -SIDE, 1, 0) }, body)
local otherPage = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(SIDE, 0), Size = UDim2.new(1, -SIDE, 1, 0), Visible = false }, body)
icon(otherPage, "clock", 34, UDim2.new(0.5, -17, 0.5, -34), C.muted)
local otherText = text(otherPage, "", 16, C.muted, UDim2.new(0, 0, 0.5, 8), UDim2.new(1, 0, 0, 24), Enum.TextXAlignment.Center)

local navButtons = {}
local function showPage(name)
	for n, b in pairs(navButtons) do
		local on = (n == name)
		tween(b.btn, 0.15, { BackgroundTransparency = on and 0.9 or 1 })
		b.label.TextColor3 = on and C.text or C.muted
		b.icon.ImageColor3 = on and C.text or C.muted
	end
	homePage.Visible = (name == "Home")
	otherPage.Visible = (name ~= "Home")
	otherText.Text = name .. " is coming soon"
end

for i, it in ipairs({ { "Home", "home" }, { "Functions", "zap" }, { "Player", "user" }, { "Settings", "sliders" }, { "About", "info" } }) do
	local btn = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = C.white, BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 10 + (i - 1) * 44), Size = UDim2.new(1, -20, 0, 40) }, side)
	corner(btn, 12)
	local ic = icon(btn, it[2], 20, UDim2.fromOffset(14, 10), C.muted)
	local lb = text(btn, it[1], 15, C.muted, UDim2.fromOffset(46, 0), UDim2.new(1, -52, 1, 0))
	navButtons[it[1]] = { btn = btn, label = lb, icon = ic }
	btn.MouseButton1Click:Connect(function() showPage(it[1]) end)
end

-- home: artwork behind the cards
local HANDS_H = 160
local hands = new("ImageLabel", {
	BackgroundTransparency = 1, Image = handsImg, ImageColor3 = Color3.fromRGB(205, 205, 208),
	Position = UDim2.new(0, 0, 1, -HANDS_H), Size = UDim2.new(1, 0, 0, HANDS_H), ScaleType = Enum.ScaleType.Crop,
}, homePage)
new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.28, 0.25), NumberSequenceKeypoint.new(1, 0.05),
}) }, hands)
local fade = new("Frame", { BackgroundColor3 = C.win, BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -HANDS_H), Size = UDim2.fromOffset(70, HANDS_H) }, homePage)
new("UIGradient", { Transparency = NumberSequence.new(0, 1) }, fade)

-- home: stats card
local stats = card(homePage, UDim2.fromOffset(14, 14), UDim2.fromOffset(224, 142))
icon(stats, "user", 46, UDim2.fromOffset(18, 20), Color3.fromRGB(230, 230, 232))
text(stats, "Username", 12, C.muted, UDim2.fromOffset(76, 18), UDim2.new(1, -90, 0, 16))
text(stats, LP.Name, 20, C.text, UDim2.fromOffset(76, 36), UDim2.new(1, -90, 0, 28))
line(stats, UDim2.fromOffset(18, 74), UDim2.new(1, -36, 0, 1))

local function statRow(parent, y, ic, label)
	icon(parent, ic, 16, UDim2.fromOffset(18, y + 2), C.muted)
	text(parent, label, 12, C.muted, UDim2.fromOffset(42, y), UDim2.new(0.5, -30, 0, 20))
	return text(parent, "", 13, C.text, UDim2.new(0.5, 0, 0, y), UDim2.new(0.5, -18, 0, 20), Enum.TextXAlignment.Right)
end
statRow(stats, 86, "user", "Player name").Text = LP.DisplayName
local timeLabel = statRow(stats, 112, "clock", "Playing Time")
timeLabel.Text = "00:00:00"

-- home: players card
local pc = card(homePage, UDim2.fromOffset(250, 14), UDim2.fromOffset(176, 142))
icon(pc, "users", 44, UDim2.fromOffset(18, 20), Color3.fromRGB(230, 230, 232))
text(pc, "Players Online", 12, C.muted, UDim2.fromOffset(72, 18), UDim2.new(1, -80, 0, 16))
local countLabel = text(pc, "–", 40, C.text, UDim2.fromOffset(72, 34), UDim2.new(1, -80, 0, 44))
line(pc, UDim2.fromOffset(18, 82), UDim2.new(1, -36, 0, 1))
icon(pc, "users", 14, UDim2.fromOffset(18, 94), C.muted)
text(pc, "In this experience", 12, C.muted, UDim2.fromOffset(40, 92), UDim2.new(1, -50, 0, 18))
icon(pc, "clock", 14, UDim2.fromOffset(18, 114), C.muted)
text(pc, "Updates every 2 min", 12, C.muted, UDim2.fromOffset(40, 112), UDim2.new(1, -50, 0, 18))

----------------------------------------------------------------- logic (visual data only)
local alive = true
local started = os.time()

local function updatePlayers() countLabel.Text = tostring(#Players:GetPlayers()) end
updatePlayers()
task.spawn(function()
	while alive do
		task.wait(REFRESH_SECONDS)
		if not alive then break end
		updatePlayers()
	end
end)
task.spawn(function()
	while alive do
		local s = os.time() - started
		timeLabel.Text = string.format("%02d:%02d:%02d", s // 3600, s % 3600 // 60, s % 60)
		task.wait(1)
	end
end)

-- minimize / close
local minimized = false
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	body.Visible = not minimized
	tween(win, 0.18, { Size = UDim2.fromOffset(W, minimized and TOP or H) })
end)
closeBtn.MouseButton1Click:Connect(function() alive = false; gui:Destroy() end)

-- drag by the top bar
local dragging, dragStart, startPos
top.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		dragging, dragStart, startPos = true, i.Position, win.Position
		i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
	end
end)
UIS.InputChanged:Connect(function(i)
	if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
		local d = (i.Position - dragStart) / scaleObj.Scale
		win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)

showPage("Home")
