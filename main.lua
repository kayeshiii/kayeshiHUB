local Players = game:GetService("Players")  
local UIS = game:GetService("UserInputService")  
local StarterGui = game:GetService("StarterGui")  
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local function notify(text)  
pcall(function()  
StarterGui:SetCore("SendNotification", {Title = "kayeshiHUB", Text = text, Duration = 4})  
end)  
end

-- kayeshiHUB | Discord Popup
local DISCORD_LINK = "https://discord.gg/tfXf5W6WCw"

local function showDiscordPopup()
    local playerGui = player:WaitForChild("PlayerGui")

    local old = playerGui:FindFirstChild("kayeshiDiscordPopup")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "kayeshiDiscordPopup"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 10000
    gui.IgnoreGuiInset = true
    gui.Parent = playerGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.4
    bg.BorderSizePixel = 0
    bg.Parent = gui

    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0.86, 0, 0, 230)
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.fromScale(0.5, 0.5)
    panel.BackgroundColor3 = Color3.fromRGB(24, 27, 35)
    panel.BorderSizePixel = 0
    panel.Parent = bg

    local sizeLimit = Instance.new("UISizeConstraint")
    sizeLimit.MaxSize = Vector2.new(420, 260)
    sizeLimit.MinSize = Vector2.new(260, 210)
    sizeLimit.Parent = panel

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = panel

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(88, 101, 242)
    stroke.Thickness = 2
    stroke.Parent = panel

    local function makeLabel(text, size, position, font, color)
        local label = Instance.new("TextLabel")
        label.Size = size
        label.Position = position
        label.BackgroundTransparency = 1
        label.Text = text
        label.Font = font
        label.TextSize = 14
        label.TextColor3 = color
        label.TextWrapped = true
        label.Parent = panel
        return label
    end

    makeLabel(
        "kayeshiHUB",
        UDim2.new(1, -60, 0, 35),
        UDim2.fromOffset(18, 18),
        Enum.Font.GothamBold,
        Color3.fromRGB(255, 255, 255)
    ).TextSize = 22

    local close = Instance.new("TextButton")
    close.Size = UDim2.fromOffset(34, 34)
    close.Position = UDim2.new(1, -46, 0, 10)
    close.BackgroundColor3 = Color3.fromRGB(55, 59, 70)
    close.Text = "X"
    close.TextColor3 = Color3.new(1, 1, 1)
    close.TextSize = 18
    close.Font = Enum.Font.GothamBold
    close.Parent = panel
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)

    makeLabel(
        "JOIN DISCORD COMMUNITY",
        UDim2.new(1, -30, 0, 30),
        UDim2.fromOffset(15, 62),
        Enum.Font.GothamBold,
        Color3.fromRGB(170, 180, 255)
    ).TextSize = 15

    makeLabel(
        "Join komunitas kayeshiHUB untuk info, update script, dan saran fitur terbaru.",
        UDim2.new(1, -36, 0, 52),
        UDim2.fromOffset(18, 95),
        Enum.Font.Gotham,
        Color3.fromRGB(220, 222, 230)
    ).TextSize = 13

    local function makeButton(text, y, color)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -36, 0, 36)
        button.Position = UDim2.fromOffset(18, y)
        button.BackgroundColor3 = color
        button.Text = text
        button.TextColor3 = Color3.new(1, 1, 1)
        button.TextSize = 13
        button.Font = Enum.Font.GothamBold
        button.Parent = panel
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
        return button
    end

    local join = makeButton(
        "JOIN DISCORD",
        155,
        Color3.fromRGB(88, 101, 242)
    )

    local copy = makeButton(
        "COPY INVITE LINK",
        198,
        Color3.fromRGB(55, 59, 70)
    )

    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    join.MouseButton1Click:Connect(function()
        if setclipboard then
            pcall(setclipboard, DISCORD_LINK)
        end
        StarterGui:SetCore("SendNotification", {
            Title = "kayeshiHUB",
            Text = "Link Discord disalin. Paste di browser untuk bergabung.",
            Duration = 5
        })
    end)

    copy.MouseButton1Click:Connect(function()
        local ok = pcall(function()
            assert(type(setclipboard) == "function", "Clipboard tidak didukung")
            setclipboard(DISCORD_LINK)
        end)

        StarterGui:SetCore("SendNotification", {
            Title = "kayeshiHUB",
            Text = ok and "Link berhasil disalin!" or DISCORD_LINK,
            Duration = 5
        })
    end)
end

task.spawn(function()
    task.wait(1)
    pcall(showDiscordPopup)
end)


local EGG_NAMES = {  
"Common Egg", "Coral Egg", "Reef Egg", "Tidal Egg", "Deep Egg", "Abyss Egg",  
"Trench Egg", "Sovereign Egg", "Celestial Egg", "Eternal Egg", "Coral Reef Egg",  
"Glacial Spiral Egg", "Amethyst Spiral Egg", "Azure Crown Egg", "Solar Orbit Egg",  
"Spikey Egg", "Mamba Egg", "Inferno Egg", "Kraken Glory Egg",  
"Admin Abuse Seraph Egg", "KingKalolo Egg", "Golem Egg",  
}

local EGG_LOWER = {}  
for _, name in ipairs(EGG_NAMES) do  
EGG_LOWER[string.lower(name)] = true  
end

local RARITY_RANK = {  
common = 1, uncommon = 2, rare = 3, epic = 4, legendary = 5,  
mythic = 6, mythical = 6, divine = 7, secret = 8, exotic = 8,  
}

local BAD_WORDS = {"hatch", "incubat", "shop", "sell", "display", "showcase", "inventory", "machine"}

local CFG = {
    Farming = false,
    ReturnToZone = false,
    BestFirst = false,
    ZoneRadiusOn = false,
    ZoneRadius = 250,
    ESP = false,
    ESPMode = "Nama",
    WalkOn = false,
    WalkSpeed = 16,
    JumpOn = false,
    JumpPower = 50,
    SwimOn = false,
    SwimSpeed = 50,
    Offset = Vector3.new(0, 3, 0),
    ActionDelay = 0.35,
    ESPDelay = 0.6,
    PickupWait = 1.5,
    IgnoreTime = 8,
    ReturnRadius = 8,
}

local C = {  
Panel = Color3.fromRGB(18, 18, 18),  
Head = Color3.fromRGB(30, 30, 30),  
Row = Color3.fromRGB(42, 42, 42),  
Dark = Color3.fromRGB(64, 64, 64),  
Light = Color3.fromRGB(236, 236, 236),  
Text = Color3.fromRGB(245, 245, 245),  
Ink = Color3.fromRGB(16, 16, 16),  
Muted = Color3.fromRGB(160, 160, 160),  
}

local lists = {  
farm = {sel = {}, order = {}, buttons = {}},  
esp = {sel = {}, order = {}, buttons = {}},  
}  
local ignored, espItems = {}, {}  
local ui, tabs = {}, {}  
local farmed, detected = 0, 0  
local status = "Siap"  
local zone = nil  
local carryUntil = 0  
local baseWalk, baseJump = 16, 50  
local forcedWalk = false  
local inWaterNow = false  
local refresh = function() end

local function make(class, props, parent)  
local o = Instance.new(class)  
for k, v in pairs(props) do  
o[k] = v  
end  
if parent then  
o.Parent = parent  
end  
return o  
end

local function corner(o, r)  
make("UICorner", {CornerRadius = UDim.new(0, r)}, o)  
end

local function btn(parent, text, color, h)  
local b = make("TextButton", {  
Size = UDim2.new(1, 0, 0, h or 30),  
BackgroundColor3 = color,  
BorderSizePixel = 0,  
Text = text,  
TextColor3 = C.Text,  
Font = Enum.Font.GothamSemibold,  
TextSize = 12,  
TextTruncate = Enum.TextTruncate.AtEnd,  
AutoButtonColor = false,  
}, parent)  
corner(b, 7)  
return b  
end

local function hasBad(s)  
s = string.lower(s or "")  
for _, w in ipairs(BAD_WORDS) do  
if string.find(s, w) then  
return true  
end  
end  
return false  
end

local function getRoot()  
local ch = player.Character  
return ch and ch:FindFirstChild("HumanoidRootPart")  
end

local function humanoid()  
local ch = player.Character  
return ch and ch:FindFirstChildOfClass("Humanoid")  
end

local function moveTo(pos)  
local ch = player.Character  
local r = ch and ch:FindFirstChild("HumanoidRootPart")  
if not r then  
return  
end  
r.AssemblyLinearVelocity = Vector3.zero  
ch:PivotTo(CFrame.new(pos))  
end

local function holdingEgg()  
local ch = player.Character  
if not ch then  
return false  
end  
for _, d in ipairs(ch:GetDescendants()) do  
if string.find(string.lower(d.Name), "egg") and not hasBad(d.Name) then  
return true  
end  
end  
return false  
end

local function carrying()  
if holdingEgg() then  
carryUntil = os.clock() + 2  
end  
return os.clock() < carryUntil  
end

local function rarityOf(model)  
local raw = model:GetAttribute("Rarity")  
if raw == nil then  
local v = model:FindFirstChild("Rarity", true)  
if v and v:IsA("ValueBase") then  
raw = v.Value  
end  
end  
if raw == nil then  
return nil, 0  
end  
local text = tostring(raw)  
return text, RARITY_RANK[string.lower(text)] or 0  
end

local function eggOf(prompt)  
if hasBad(prompt.ActionText) or hasBad(prompt.ObjectText) then  
return nil  
end  
local exact, outer  
local node = prompt.Parent  
while node and node ~= workspace do  
if hasBad(node.Name) then  
return nil  
end  
if node:IsA("Model") or node:IsA("BasePart") then  
local n = string.lower(node.Name)  
if EGG_LOWER[n] and not exact then  
exact = node  
end  
if node:IsA("Model") and string.find(n, "egg") then  
outer = node  
end  
end  
node = node.Parent  
end  
return exact or outer  
end

local function partOf(model, prompt)  
local p = prompt.Parent  
if p and p:IsA("Attachment") and p.Parent and p.Parent:IsA("BasePart") then  
return p.Parent  
end  
if p and p:IsA("BasePart") then  
return p  
end  
if model:IsA("BasePart") then  
return model  
end  
return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)  
end

local function countSel(L)  
local n = 0  
for _, name in ipairs(L.order) do  
if L.sel[name] then  
n += 1  
end  
end  
return n  
end

local function paintEgg(L, name)  
local b = L.buttons[name]  
if not b then  
return  
end  
local on = L.sel[name]  
b.Text = (on and "[x]  " or "[ ]  ") .. name  
b.BackgroundColor3 = on and C.Light or C.Row  
b.TextColor3 = on and C.Ink or C.Muted  
end

local function makeEggButton(L, name)  
local b = btn(L.box, "", C.Row, 24)  
b.Font = Enum.Font.Gotham  
b.TextSize = 11  
b.TextXAlignment = Enum.TextXAlignment.Left  
b.LayoutOrder = #L.order  
make("UIPadding", {PaddingLeft = UDim.new(0, 8)}, b)  
L.buttons[name] = b  
b.MouseButton1Click:Connect(function()  
L.sel[name] = not L.sel[name]  
paintEgg(L, name)  
refresh()  
end)  
paintEgg(L, name)  
end

local function addName(name)  
for _, L in pairs(lists) do  
if L.sel[name] == nil then  
L.sel[name] = true  
table.insert(L.order, name)  
if L.box then  
makeEggButton(L, name)  
end  
end  
end  
end

local function setAll(L, value)  
for _, name in ipairs(L.order) do  
L.sel[name] = value  
paintEgg(L, name)  
end  
refresh()  
end

local function scan()  
local found, seen = {}, {}  
for _, prompt in ipairs(workspace:GetDescendants()) do  
if prompt:IsA("ProximityPrompt") and prompt.Enabled then  
local model = eggOf(prompt)  
if model and not seen[model] then  
local part = partOf(model, prompt)  
if part then  
seen[model] = true  
addName(model.Name)  
local rarity, rank = rarityOf(model)  
table.insert(found, {  
model = model, prompt = prompt, part = part,  
name = model.Name, rarity = rarity, rank = rank,  
})  
end  
end  
end  
end  
detected = #found  
return found  
end

local function pickTarget(list, root)  
local now = os.clock()  
local best  
for _, e in ipairs(list) do  
e.dist = (e.part.Position - root.Position).Magnitude  
local inZone = not (CFG.ZoneRadiusOn and zone) or (e.part.Position - zone).Magnitude <= CFG.ZoneRadius  
if lists.farm.sel[e.name] and inZone and (ignored[e.model] or 0) < now then  
if not best then  
best = e  
elseif CFG.BestFirst and e.rank ~= best.rank then  
if e.rank > best.rank then  
best = e  
end  
elseif e.dist < best.dist then  
best = e  
end  
end  
end  
return best  
end

local function collect(e)  
if not getRoot() then  
return false  
end  
moveTo(e.part.Position + CFG.Offset)  
task.wait(0.2)  
if typeof(fireproximityprompt) == "function" then  
fireproximityprompt(e.prompt)  
else  
e.prompt:InputHoldBegin()  
task.wait(e.prompt.HoldDuration + 0.2)  
e.prompt:InputHoldEnd()  
end  
local deadline = os.clock() + CFG.PickupWait  
repeat  
task.wait(0.1)  
until holdingEgg() or not e.prompt:IsDescendantOf(workspace) or os.clock() > deadline  
return holdingEgg() or not e.prompt:IsDescendantOf(workspace)  
end

local function step()  
local r = getRoot()  
if not r then  
status = "Menunggu karakter"  
return  
end  
if carrying() then  
status = "Membawa egg, balik ke zona"  
return  
end  
local target = pickTarget(scan(), r)  
if not target then  
status = detected == 0 and "Tidak ada egg di area ini" or "Tidak ada egg yang lolos filter"  
return  
end  
status = "Ambil " .. target.name .. (target.rarity and (" (" .. target.rarity .. ")") or "")  
refresh()  
if collect(target) then  
farmed += 1  
carryUntil = os.clock() + 5  
status = "Diambil " .. target.name  
if CFG.ReturnToZone and zone then  
moveTo(zone)  
end  
else  
ignored[target.model] = os.clock() + CFG.IgnoreTime  
status = "Gagal ambil " .. target.name  
end  
end

local function probe()  
local r = getRoot()  
local best  
for _, e in ipairs(scan()) do  
if not best then  
best = e  
elseif r and (e.part.Position - r.Position).Magnitude < (best.part.Position - r.Position).Magnitude then  
best = e  
end  
end  
if not best then  
status = "Tidak ada egg terdeteksi"  
notify(status)  
return  
end  
local parts = {}  
for k, v in pairs(best.model:GetAttributes()) do  
table.insert(parts, k .. "=" .. tostring(v))  
end  
for _, c in ipairs(best.model:GetChildren()) do  
table.insert(parts, c.Name .. ":" .. c.ClassName)  
end  
local text = table.concat(parts, ", ")  
status = "Info: " .. string.sub(text, 1, 90)  
notify(string.sub(best.name .. " -> " .. text, 1, 200))  
end

local function checkWater()  
local r = getRoot()  
if not r then  
inWaterNow = false  
return  
end  
local ok, res = pcall(function()  
local p = r.Position  
local region = Region3.new(p - Vector3.new(2, 3, 2), p + Vector3.new(2, 3, 2)):ExpandToGrid(4)  
local mats, occs = workspace.Terrain:ReadVoxels(region, 4)  
for x = 1, #mats do  
for y = 1, #mats[x] do  
for z = 1, #mats[x][y] do  
if mats[x][y][z] == Enum.Material.Water and occs[x][y][z] > 0.5 then  
return true  
end  
end  
end  
end  
return false  
end)  
inWaterNow = ok and res or false  
end

local function applyMove()  
local hum = humanoid()  
if not hum then  
return  
end  
local swimming = CFG.SwimOn and (hum:GetState() == Enum.HumanoidStateType.Swimming or inWaterNow)  
if swimming or CFG.WalkOn then  
forcedWalk = true  
local target = swimming and CFG.SwimSpeed or CFG.WalkSpeed  
if hum.WalkSpeed ~= target then  
hum.WalkSpeed = target  
end  
elseif forcedWalk then  
forcedWalk = false  
hum.WalkSpeed = baseWalk  
end  
if CFG.JumpOn and hum.JumpPower ~= CFG.JumpPower then  
hum.UseJumpPower = true  
hum.JumpPower = CFG.JumpPower  
end  
end

local function espAllowed(name)  
return CFG.ESPMode == "Semua" or lists.esp.sel[name] == true  
end

local function labelFor(e, root)  
local dist = root and math.floor((e.part.Position - root.Position).Magnitude) or 0  
local parts = {e.name}  
if e.rarity then  
table.insert(parts, e.rarity)  
end  
table.insert(parts, dist .. " m")  
return table.concat(parts, " | ")  
end

local function updateESP(list)  
local root = getRoot()  
local keep = {}  
for _, e in ipairs(list) do  
if espAllowed(e.name) and e.model.Parent then  
keep[e.model] = true  
local item = espItems[e.model]  
if not item then  
local hl = make("Highlight", {  
FillColor = C.Light,  
FillTransparency = 0.6,  
OutlineColor = C.Text,  
DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,  
}, e.model)  
local bb = make("BillboardGui", {  
Size = UDim2.fromOffset(200, 22),  
StudsOffset = Vector3.new(0, 3, 0),  
AlwaysOnTop = true,  
Adornee = e.part,  
}, e.part)  
local lb = make("TextLabel", {  
Size = UDim2.fromScale(1, 1),  
BackgroundColor3 = C.Panel,  
BackgroundTransparency = 0.2,  
TextColor3 = C.Text,  
Font = Enum.Font.GothamSemibold,  
TextSize = 11,  
}, bb)  
corner(lb, 6)  
item = {hl = hl, bb = bb, lb = lb}  
espItems[e.model] = item  
end  
item.lb.Text = labelFor(e, root)  
end  
end  
for model, item in pairs(espItems) do  
if not keep[model] or not model.Parent then  
pcall(function()  
item.hl:Destroy()  
item.bb:Destroy()  
end)  
espItems[model] = nil  
end  
end  
end

local function paintToggle(b, label, on)  
b.Text = label .. (on and ": ON" or ": OFF")  
b.BackgroundColor3 = on and C.Light or C.Dark  
b.TextColor3 = on and C.Ink or C.Text  
end

local function stepper(parent, y, label, onStep)  
local row = make("Frame", {  
Position = UDim2.fromOffset(0, y),  
Size = UDim2.new(1, 0, 0, 26),  
BackgroundTransparency = 1,  
}, parent)  
make("TextLabel", {  
Size = UDim2.new(1, -120, 1, 0),  
BackgroundTransparency = 1,  
Text = label,  
TextColor3 = C.Muted,  
Font = Enum.Font.GothamSemibold,  
TextSize = 12,  
TextXAlignment = Enum.TextXAlignment.Left,  
}, row)  
local minus = btn(row, "-", C.Dark, 26)  
minus.Size = UDim2.fromOffset(30, 26)  
minus.Position = UDim2.new(1, -112, 0, 0)  
local value = make("TextLabel", {  
Size = UDim2.fromOffset(42, 26),  
Position = UDim2.new(1, -78, 0, 0),  
BackgroundTransparency = 1,  
TextColor3 = C.Text,  
Font = Enum.Font.GothamBold,  
TextSize = 13,  
}, row)  
local plus = btn(row, "+", C.Dark, 26)  
plus.Size = UDim2.fromOffset(30, 26)  
plus.Position = UDim2.new(1, -30, 0, 0)  
minus.MouseButton1Click:Connect(function()  
onStep(-1)  
end)  
plus.MouseButton1Click:Connect(function()  
onStep(1)  
end)  
return value  
end

local function newList(parent, yOff)  
local scroll = make("ScrollingFrame", {  
Position = UDim2.fromOffset(0, yOff),  
Size = UDim2.new(1, 0, 1, -yOff),  
BackgroundTransparency = 1,  
BorderSizePixel = 0,  
ScrollBarThickness = 3,  
ScrollBarImageColor3 = C.Muted,  
CanvasSize = UDim2.new(),  
AutomaticCanvasSize = Enum.AutomaticSize.Y,  
}, parent)  
make("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, scroll)  
return scroll  
end

local function parentGui()  
local okHui, hui = pcall(gethui)  
if okHui and typeof(hui) == "Instance" then  
return hui  
end  
return player:WaitForChild("PlayerGui")  
end

local function draggable(handle, target, onTap)  
local dragging, moved = false, false  
local start, startPos  
handle.InputBegan:Connect(function(input)  
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
dragging = true  
moved = false  
start = input.Position  
startPos = target.Position  
end  
end)  
UIS.InputChanged:Connect(function(input)  
if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then  
local d = input.Position - start  
if d.Magnitude > 6 then  
moved = true  
end  
target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)  
end  
end)  
UIS.InputEnded:Connect(function(input)  
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
if dragging and not moved and onTap then  
onTap()  
end  
dragging = false  
end  
end)  
end

local function buildUI()  
local host = parentGui()  
local old = host:FindFirstChild("kayeshiHUB")  
if old then  
old:Destroy()  
end

local cam = workspace.CurrentCamera  
local vp = cam and cam.ViewportSize or Vector2.new(800, 400)  
if vp.X < 1 or vp.Y < 1 then  
vp = Vector2.new(800, 400)  
end  
local scale = math.clamp(math.min(vp.X / 560, vp.Y / 330), 0.5, 1)

local gui = make("ScreenGui", {  
Name = "kayeshiHUB",  
ResetOnSpawn = false,  
DisplayOrder = 999,  
IgnoreGuiInset = true,  
}, host)

local main = make("Frame", {  
AnchorPoint = Vector2.new(0.5, 0.5),  
Position = UDim2.fromScale(0.5, 0.5),  
Size = UDim2.fromOffset(520, 300),  
BackgroundColor3 = C.Panel,  
BorderSizePixel = 0,  
}, gui)  
corner(main, 10)  
make("UIScale", {Scale = scale}, main)

local header = make("Frame", {  
Size = UDim2.new(1, 0, 0, 32),  
BackgroundColor3 = C.Head,  
BorderSizePixel = 0,  
}, main)  
corner(header, 10)  
make("TextLabel", {  
Size = UDim2.new(1, -110, 1, 0),  
Position = UDim2.fromOffset(12, 0),  
BackgroundTransparency = 1,  
Text = "kayeshiHUB",  
TextColor3 = C.Text,  
Font = Enum.Font.GothamBold,  
TextSize = 14,  
TextXAlignment = Enum.TextXAlignment.Left,  
}, header)  
local hideBtn = btn(header, "Sembunyi", C.Dark, 24)  
hideBtn.Size = UDim2.fromOffset(92, 24)  
hideBtn.Position = UDim2.new(1, -100, 0, 4)  
hideBtn.TextSize = 11

local left = make("Frame", {  
Position = UDim2.fromOffset(8, 40),  
Size = UDim2.new(0, 172, 1, -48),  
BackgroundColor3 = C.Row,  
BorderSizePixel = 0,  
}, main)  
corner(left, 8)  
make("UIPadding", {  
PaddingTop = UDim.new(0, 8),  
PaddingLeft = UDim.new(0, 8),  
PaddingRight = UDim.new(0, 8),  
}, left)  
make("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, left)

ui.stat = make("TextLabel", {  
Size = UDim2.new(1, 0, 0, 18),  
BackgroundTransparency = 1,  
TextColor3 = C.Text,  
Font = Enum.Font.GothamBold,  
TextSize = 12,  
TextXAlignment = Enum.TextXAlignment.Left,  
LayoutOrder = 1,  
}, left)  
ui.info = make("TextLabel", {  
Size = UDim2.new(1, 0, 0, 26),  
BackgroundTransparency = 1,  
TextColor3 = C.Muted,  
Font = Enum.Font.Gotham,  
TextSize = 10,  
TextWrapped = true,  
TextXAlignment = Enum.TextXAlignment.Left,  
TextYAlignment = Enum.TextYAlignment.Top,  
LayoutOrder = 2,  
}, left)  
ui.farm = btn(left, "", C.Dark, 26)  
ui.farm.LayoutOrder = 3  
ui.best = btn(left, "", C.Dark, 26)  
ui.best.LayoutOrder = 4  
ui.ret = btn(left, "", C.Dark, 26)  
ui.ret.LayoutOrder = 5  
local zoneBtn = btn(left, "Set zona aman di sini", C.Dark, 26)  
zoneBtn.LayoutOrder = 6  
local tpBtn = btn(left, "Teleport ke zona aman", C.Dark, 26)  
tpBtn.LayoutOrder = 7  
make("TextLabel", {  
Size = UDim2.new(1, 0, 0, 24),  
BackgroundTransparency = 1,  
TextColor3 = C.Muted,  
Font = Enum.Font.Gotham,  
TextSize = 10,  
TextXAlignment = Enum.TextXAlignment.Left,  
Text = "F: farm  |  K: menu",  
LayoutOrder = 8,  
}, left)

local right = make("Frame", {  
Position = UDim2.fromOffset(188, 40),  
Size = UDim2.new(1, -196, 1, -48),  
BackgroundColor3 = C.Row,  
BorderSizePixel = 0,  
}, main)  
corner(right, 8)

local tabDefs = {{"egg", "Egg"}, {"esp", "ESP"}, {"player", "Player"}}  
for i, t in ipairs(tabDefs) do  
local b = btn(right, t[2], C.Dark, 26)  
b.Size = UDim2.new(1 / 3, -8, 0, 26)  
b.Position = UDim2.new((i - 1) / 3, 4, 0, 6)  
tabs[t[1]] = b  
end

local function newPage()  
return make("Frame", {  
Position = UDim2.fromOffset(6, 38),  
Size = UDim2.new(1, -12, 1, -44),  
BackgroundTransparency = 1,  
Visible = false,  
}, right)  
end  
local pageEgg, pageESP, pagePlayer = newPage(), newPage(), newPage()

local eggAll = btn(pageEgg, "Semua", C.Dark, 26)  
eggAll.Size = UDim2.new(1 / 3, -4, 0, 26)  
local eggNone = btn(pageEgg, "Kosong", C.Dark, 26)  
eggNone.Size = UDim2.new(1 / 3, -4, 0, 26)  
eggNone.Position = UDim2.new(1 / 3, 2, 0, 0)  
local probeBtn = btn(pageEgg, "Info egg", C.Dark, 26)  
probeBtn.Size = UDim2.new(1 / 3, -4, 0, 26)  
probeBtn.Position = UDim2.new(2 / 3, 4, 0, 0)  
ui.radius = btn(pageEgg, "", C.Dark, 26)  
ui.radius.Position = UDim2.fromOffset(0, 30)  
lists.farm.box = newList(pageEgg, 60)

ui.espToggle = btn(pageESP, "", C.Dark, 26)  
ui.espToggle.Size = UDim2.new(0.5, -3, 0, 26)  
ui.espMode = btn(pageESP, "", C.Dark, 26)  
ui.espMode.Size = UDim2.new(0.5, -3, 0, 26)  
ui.espMode.Position = UDim2.new(0.5, 3, 0, 0)  
local espAll = btn(pageESP, "Semua", C.Dark, 26)  
espAll.Size = UDim2.new(0.5, -3, 0, 26)  
espAll.Position = UDim2.fromOffset(0, 30)  
local espNone = btn(pageESP, "Kosong", C.Dark, 26)  
espNone.Size = UDim2.new(0.5, -3, 0, 26)  
espNone.Position = UDim2.new(0.5, 3, 0, 30)  
lists.esp.box = newList(pageESP, 60)

ui.walk = btn(pagePlayer, "", C.Dark, 26)  
ui.walk.Position = UDim2.fromOffset(0, 0)  
ui.speedVal = stepper(pagePlayer, 30, "WalkSpeed", function(d)  
CFG.WalkSpeed = math.clamp(CFG.WalkSpeed + d * 5, 16, 250)  
refresh()  
end)  
ui.jump = btn(pagePlayer, "", C.Dark, 26)  
ui.jump.Position = UDim2.fromOffset(0, 60)  
ui.jumpVal = stepper(pagePlayer, 90, "JumpPower", function(d)  
CFG.JumpPower = math.clamp(CFG.JumpPower + d * 10, 50, 300)  
refresh()  
end)  
ui.swim = btn(pagePlayer, "", C.Dark, 26)  
ui.swim.Position = UDim2.fromOffset(0, 120)  
ui.swimVal = stepper(pagePlayer, 150, "SwimSpeed", function(d)  
CFG.SwimSpeed = math.clamp(CFG.SwimSpeed + d * 10, 16, 300)  
refresh()  
end)

local logo = make("Frame", {  
Position = UDim2.new(0, 10, 0.5, -22),  
Size = UDim2.fromOffset(44, 44),  
BackgroundColor3 = C.Ink,  
BorderSizePixel = 0,  
Visible = false,  
ZIndex = 5,  
}, gui)  
corner(logo, 12)  
make("UIStroke", {Color = C.Text, Thickness = 1.5}, logo)  
local logoBtn = make("TextButton", {  
Size = UDim2.fromScale(1, 1),  
BackgroundTransparency = 1,  
BorderSizePixel = 0,  
AutoButtonColor = false,  
Text = "K",  
TextColor3 = C.Text,  
Font = Enum.Font.GothamBold,  
TextSize = 20,  
ZIndex = 6,  
}, logo)

local function setMenu(open)  
main.Visible = open  
logo.Visible = not open  
end

local function setPage(name)  
pageEgg.Visible = name == "egg"  
pageESP.Visible = name == "esp"  
pagePlayer.Visible = name == "player"  
for key, b in pairs(tabs) do  
local active = key == name  
b.BackgroundColor3 = active and C.Light or C.Dark  
b.TextColor3 = active and C.Ink or C.Text  
end  
end

refresh = function()  
ui.stat.Text = string.format("Auto Farm %s  |  Diambil %d", CFG.Farming and "ON" or "OFF", farmed)  
ui.info.Text = string.format("Terdeteksi %d  |  %s", detected, status)  
paintToggle(ui.farm, "Auto Farm", CFG.Farming)  
paintToggle(ui.best, "Rarity tertinggi", CFG.BestFirst)  
paintToggle(ui.ret, "Balik ke zona", CFG.ReturnToZone)  
paintToggle(ui.radius, "Hanya dekat zona", CFG.ZoneRadiusOn)  
paintToggle(ui.espToggle, "ESP", CFG.ESP)  
ui.espMode.Text = "Mode: " .. CFG.ESPMode  
ui.espMode.BackgroundColor3 = C.Dark  
ui.espMode.TextColor3 = C.Text  
paintToggle(ui.walk, "WalkSpeed", CFG.WalkOn)  
paintToggle(ui.jump, "JumpPower", CFG.JumpOn)  
paintToggle(ui.swim, "SwimSpeed", CFG.SwimOn)  
ui.speedVal.Text = tostring(CFG.WalkSpeed)  
ui.jumpVal.Text = tostring(CFG.JumpPower)  
ui.swimVal.Text = tostring(CFG.SwimSpeed)  
tabs.egg.Text = string.format("Egg %d/%d", countSel(lists.farm), #lists.farm.order)  
tabs.esp.Text = string.format("ESP %d/%d", countSel(lists.esp), #lists.esp.order)  
end

draggable(header, main)  
draggable(logoBtn, logo, function()  
setMenu(true)  
end)

ui.farm.MouseButton1Click:Connect(function()  
CFG.Farming = not CFG.Farming  
status = CFG.Farming and "Auto Farm nyala" or "Auto Farm mati"  
refresh()  
end)  
ui.best.MouseButton1Click:Connect(function()  
CFG.BestFirst = not CFG.BestFirst  
refresh()  
end)  
ui.ret.MouseButton1Click:Connect(function()  
CFG.ReturnToZone = not CFG.ReturnToZone  
refresh()  
end)  
ui.radius.MouseButton1Click:Connect(function()  
CFG.ZoneRadiusOn = not CFG.ZoneRadiusOn  
refresh()  
end)  
zoneBtn.MouseButton1Click:Connect(function()  
local r = getRoot()  
if r then  
zone = r.Position + CFG.Offset  
status = "Zona aman disimpan"  
else  
status = "Karakter belum siap"  
end  
refresh()  
end)  
tpBtn.MouseButton1Click:Connect(function()  
local r = getRoot()  
if r and zone then  
moveTo(zone)  
status = "Teleport ke zona aman"  
else  
status = "Zona aman belum di-set"  
end  
refresh()  
end)

tabs.egg.MouseButton1Click:Connect(function()  
setPage("egg")  
end)  
tabs.esp.MouseButton1Click:Connect(function()  
setPage("esp")  
end)  
tabs.player.MouseButton1Click:Connect(function()  
setPage("player")  
end)

eggAll.MouseButton1Click:Connect(function()  
setAll(lists.farm, true)  
end)  
eggNone.MouseButton1Click:Connect(function()  
setAll(lists.farm, false)  
end)  
probeBtn.MouseButton1Click:Connect(function()  
probe()  
refresh()  
end)

ui.espToggle.MouseButton1Click:Connect(function()  
CFG.ESP = not CFG.ESP  
refresh()  
end)  
ui.espMode.MouseButton1Click:Connect(function()  
CFG.ESPMode = CFG.ESPMode == "Nama" and "Semua" or "Nama"  
refresh()  
end)  
espAll.MouseButton1Click:Connect(function()  
setAll(lists.esp, true)  
end)  
espNone.MouseButton1Click:Connect(function()  
setAll(lists.esp, false)  
end)

ui.walk.MouseButton1Click:Connect(function()  
CFG.WalkOn = not CFG.WalkOn  
applyMove()  
refresh()  
end)  
ui.jump.MouseButton1Click:Connect(function()  
CFG.JumpOn = not CFG.JumpOn  
local hum = humanoid()  
if hum and not CFG.JumpOn then  
hum.JumpPower = baseJump  
end  
applyMove()  
refresh()  
end)  
ui.swim.MouseButton1Click:Connect(function()  
CFG.SwimOn = not CFG.SwimOn  
applyMove()  
refresh()  
end)

hideBtn.MouseButton1Click:Connect(function()  
setMenu(false)  
end)

UIS.InputBegan:Connect(function(input, gameProcessed)  
if gameProcessed then  
return  
end  
if input.KeyCode == Enum.KeyCode.F then  
CFG.Farming = not CFG.Farming  
status = CFG.Farming and "Auto Farm nyala" or "Auto Farm mati"  
refresh()  
elseif input.KeyCode == Enum.KeyCode.K or input.KeyCode == Enum.KeyCode.RightShift then  
setMenu(not main.Visible)  
end  
end)

for _, name in ipairs(EGG_NAMES) do  
addName(name)  
end

setPage("egg")  
refresh()  
end

local okBuild, buildErr = pcall(buildUI)  
if not okBuild then  
notify("Menu gagal: " .. tostring(buildErr))  
return  
end

local function captureBase(ch)  
local hum = ch:WaitForChild("Humanoid", 10)  
if hum then  
baseWalk = hum.WalkSpeed  
baseJump = hum.JumpPower  
end  
end

if player.Character then  
task.spawn(captureBase, player.Character)  
end  
player.CharacterAdded:Connect(function(ch)  
captureBase(ch)  
end)

task.spawn(function()  
local ch = player.Character or player.CharacterAdded:Wait()  
local r = ch:WaitForChild("HumanoidRootPart", 10)  
if r and not zone then  
zone = r.Position + CFG.Offset  
status = "Zona aman otomatis di posisi awal"  
end  
pcall(refresh)  
end)

RunService.Heartbeat:Connect(function()  
pcall(applyMove)  
end)

task.spawn(function()  
while true do  
task.wait(0.25)  
pcall(checkWater)  
end  
end)

task.spawn(function()  
while true do  
task.wait(0.2)  
pcall(function()  
if CFG.ReturnToZone and zone and carrying() then  
local r = getRoot()  
if r and (r.Position - zone).Magnitude > CFG.ReturnRadius then  
moveTo(zone)  
end  
end  
end)  
end  
end)

task.spawn(function()  
while true do  
task.wait(CFG.ActionDelay)  
if CFG.Farming then  
local ok, err = pcall(step)  
if not ok then  
status = "Error: " .. tostring(err)  
end  
end  
pcall(refresh)  
end  
end)

task.spawn(function()  
while true do  
task.wait(CFG.ESPDelay)  
local ok, err = pcall(function()  
if CFG.ESP then  
updateESP(scan())  
elseif next(espItems) then  
updateESP({})  
end  
end)  
if not ok then  
status = "ESP error: " .. tostring(err)  
end  
end  
end)

notify("kayeshiHUB aktif. Tekan K untuk menu.")
