local Players = game:GetService("Players")  
local UIS = game:GetService("UserInputService")  
local StarterGui = game:GetService("StarterGui")  
local RunService = game:GetService("RunService")  
local VirtualUser = game:GetService("VirtualUser")  
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer  
local DISCORD_LINK = "https://discord.gg/tfXf5W6WCw"  
local CONFIG_FILE = "kayeshiHUB_config.json"  
local SETTING_PREFIX = "kayeshi:"  
local FAR = 1e6  
local MAIN_W, MAIN_H = 600, 360

local function notify(text)  
pcall(function()  
StarterGui:SetCore("SendNotification", {Title = "kayeshiHUB", Text = string.sub(tostring(text), 1, 200), Duration = 4})  
end)  
end

notify("kayeshiHUB memuat...")

local C = {  
Panel = Color3.fromRGB(17, 17, 21), Side = Color3.fromRGB(24, 24, 30), Card = Color3.fromRGB(32, 32, 40),  
Row = Color3.fromRGB(42, 42, 52), Dark = Color3.fromRGB(56, 56, 68), Light = Color3.fromRGB(238, 238, 244),  
Accent = Color3.fromRGB(99, 110, 255), Text = Color3.fromRGB(245, 245, 248), Ink = Color3.fromRGB(16, 16, 20),  
Muted = Color3.fromRGB(154, 154, 168),  
}

local function make(class, props, parent)  
local o = Instance.new(class)  
for k, v in pairs(props or {}) do  
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
Size = UDim2.new(1, 0, 0, h or 26), BackgroundColor3 = color, BorderSizePixel = 0, Text = text,  
TextColor3 = C.Text, Font = Enum.Font.GothamSemibold, TextSize = 11,  
TextTruncate = Enum.TextTruncate.AtEnd, AutoButtonColor = false,  
}, parent)  
corner(b, 7)  
return b  
end

-- Urutan dari luck terendah (tier 1) ke tertinggi. Hanya egg di daftar ini yang dikenali.  
local EGG_LIST = {  
{"Common Egg", "1"},  
{"Coral Egg", "20"},  
{"Reef Egg", "400"},  
{"Tidal Egg", "8K"},  
{"Deep Egg", "160K"},  
{"Abyss Egg", "3M"},  
{"Trench Egg", "60M"},  
{"Sovereign Egg", "1B"},  
{"Celestial Egg", "20B"},  
{"Kraken Glory Egg", "24B–140B"},  
{"Eternal Egg", "70B"},  
{"Admin Abuse Seraph Egg", "80B–2T"},  
{"Coral Reef Egg", "90B"},  
{"Glacial Spiral Egg", "115B"},  
{"KingKalolo Egg", "130B–400B"},  
{"Amethyst Spiral Egg", "140B"},  
{"Azure Crown Egg", "170B"},  
{"Solar Orbit Egg", "200B"},  
{"Spikey Egg", "250B"},  
{"Mamba Egg", "300B"},  
{"Inferno Egg", "350B"},  
{"Golem Egg", "500B–1T"},  
{"Astral Vortex", "5T"},  
}  
local EGG_NAMES, EGG_LOWER, EGG_TIER, EGG_LUCK, EGG_CANON = {}, {}, {}, {}, {}  
for i, e in ipairs(EGG_LIST) do  
local key = string.lower(e[1])  
EGG_NAMES[i] = e[1]  
EGG_LOWER[key] = true  
EGG_TIER[key] = i  
EGG_LUCK[key] = e[2]  
EGG_CANON[key] = e[1]  
end  
local EGG_KEYS = {}  
for k in pairs(EGG_LOWER) do  
table.insert(EGG_KEYS, k)  
end  
table.sort(EGG_KEYS, function(a, b)  
return #a > #b  
end)

local function eggKeyOf(name)  
local n = string.lower(name or "")  
if EGG_LOWER[n] then  
return n  
end  
for _, k in ipairs(EGG_KEYS) do  
if string.find(n, k, 1, true) then  
return k  
end  
end  
return nil  
end

local MIN_STEPS = {{"Semua", 0}, {"Sovereign+", 8}, {"Celestial+", 9}, {"Kraken+", 10}, {"Golem+", 22}}  
local BAD_EGG = {  
"hatch", "incubat", "place", "plant", "shop", "inventory", "inventori", "simpan", "backpack",  
"machine", "npc", "penjaga", "tukar", "exchange", "buy", "beli",  
}  
local ESP_BAD = {"shop", "npc", "inventory", "backpack", "mudagen", "mudargen"}  
local TOKEN_WORDS = {"token"}  
local PUMPKIN_WORDS = {"pumpkin"}  
local PUMPKIN_BAD = {"ember pumpkin citadel"}  
local COLLECT_BAD = {  
"generator", "shop", "tukar", "exchange", "trade", "swap", "sell", "buy", "npc", "machine", "merchant",  
}  
local PLACE_WORDS = {"place", "plant", "incubat"}  
local HATCH_WORDS = {"hatch"}  
local INVENTORY_WORDS = {"put to inventory"}

local SHOPS = {  
{id = "radar", label = "Radar Shop", kw = "radar", auto = "AutoRadar", npc = {"mudagen", "mudargen"}, items = {  
"Basic Radar", "Improved Radar", "Advanced Radar", "Superior Radar", "Elite Radar",  
"Legendary Radar", "Royal Crystal Radar", "Ascendant Crystal Radar",  
}},  
{id = "feed", label = "Feed Shop", kw = "feed", auto = "AutoFeed", npc = {"alex"}, items = {  
"Fish Flakes", "Bloodworms", "Krill", "Squid Bits", "Golden Pellets", "Abyssal Feast",  
}},  
}  
local SHOP_ITEMS = {}  
for _, shop in ipairs(SHOPS) do  
for _, name in ipairs(shop.items) do  
table.insert(SHOP_ITEMS, {key = string.lower(name), shop = shop.id})  
end  
end

local CFG = {  
Farm = true, RarityFirst = true, MinRank = 0, StealWait = 0.8, IgnoreTime = 8, HoldTimeout = 6,  
AntiAFK = true, AfkIdle = 300, AutoSave = true,  
CollectToken = false, CollectPumpkin = false, CollectDelay = 1.5, CollectStand = 1,  
EggESP = false,  
Place = false, PlaceCd = 2,  
AutoInv = true, InvCd = 2, InvWindow = 6,  
Hatch = false, HatchCd = 3,  
AutoRadar = false, AutoFeed = false, OpenCd = 12,  
Boss = false, Dodge = true, FireRange = 150, FireInterval = 0.15, DodgeRadius = 3, DodgeStep = 14, FireTool = "",  
Walk = false, WalkSpeed = 16, Jump = false, JumpPower = 50,  
}

local S = {  
status = "Memuat...", steal = 0, place = 0, hatch = 0, collect = 0, inv = 0,  
shop = 0, dodge = 0, shots = 0, detected = 0, errors = 0, config = "-",  
}

local eggSel, espSel = {}, {}  
local eggList, eggKeys, eggGrids, paints = {}, {}, {}, {}  
local ignored, cooldowns = {}, {}  
local espItems = {}  
local caches = {prompts = {list = {}, at = 0}, eggs = {list = {}, at = 0}, collect = {list = {}, at = 0}, boss = {val = nil, at = 0}}  
local espCache, espAt = {}, 0  
local heldCache, heldAt = nil, 0  
local lastStealAt, lastStealName = 0, nil  
local shopNext = {radar = 0, feed = 0}  
local shopBusy = false  
local shopCheckAt = 0  
local dodgeNext, fireNext = 0, 0  
local holdSince = 0  
local collectNext = 0  
local minIdx = 1  
local orderSeq = 0  
local zone = nil  
local baseWalk, baseJump = 16, 50  
local lastJson = nil  
local lastActive = os.clock()

local uiRefs = {}  
local layoutState = {main = Vector2.new(0, 0), ready = false}

local function refresh()  
for _, f in ipairs(paints) do  
pcall(f)  
end  
end

local function nextOrder()  
orderSeq += 1  
return orderSeq  
end

local function fail(where, err)  
S.errors += 1  
S.status = where .. ": " .. string.sub(tostring(err), 1, 70)  
end

local function loop(name, interval, fn)  
task.spawn(function()  
while true do  
local ok, err = pcall(fn)  
if not ok then  
fail(name, err)  
task.wait(0.5)  
end  
task.wait(interval)  
end  
end)  
end

local function farmOn()  
return CFG.Farm == true  
end

local function getRoot()  
local ch = player.Character  
return ch and ch:FindFirstChild("HumanoidRootPart")  
end

local function humanoid()  
local ch = player.Character  
return ch and ch:FindFirstChildOfClass("Humanoid")  
end

local function tpTo(pos)  
local ch = player.Character  
local r = ch and ch:FindFirstChild("HumanoidRootPart")  
if r then  
r.AssemblyLinearVelocity = Vector3.zero  
ch:PivotTo(CFrame.new(pos + Vector3.new(0, 3, 0)))  
end  
end

local function backToZone()  
if zone then  
tpTo(zone)  
end  
end

local function hasAny(text, words)  
for _, w in ipairs(words) do  
if string.find(text, w, 1, true) then  
return true  
end  
end  
return false  
end

local function norm(s)  
return string.lower((string.gsub(s or "", "^%s*(.-)%s*$", "%1")))  
end

local function chainOf(inst)  
local names, node = {}, inst  
while node and node ~= workspace do  
table.insert(names, string.lower(node.Name))  
node = node.Parent  
end  
return table.concat(names, " / ")  
end

local function promptPart(prompt)  
local p = prompt.Parent  
if p and p:IsA("Attachment") then  
p = p.Parent  
end  
if p and p:IsA("BasePart") then  
return p  
end  
if p and p:IsA("Model") then  
return p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart", true)  
end  
return nil  
end

local promptsDirty = true  
workspace.DescendantAdded:Connect(function(obj)  
if obj:IsA("ProximityPrompt") or obj:IsA("BasePart") or obj:IsA("Model") then  
promptsDirty = true  
caches.eggs.at = 0  
caches.collect.at = 0  
espAt = 0  
for k in pairs(ignored) do  
ignored[k] = nil  
end  
end  
end)

local function getPrompts()  
local c = caches.prompts  
if not promptsDirty and os.clock() - c.at < 0.25 then  
return c.list  
end  
promptsDirty = false  
c.at = os.clock()  
local out = {}  
for _, obj in ipairs(workspace:GetDescendants()) do  
if obj:IsA("ProximityPrompt") then  
local part = promptPart(obj)  
if part then  
table.insert(out, {  
prompt = obj, part = part, enabled = obj.Enabled,  
text = string.lower(obj.ActionText .. " " .. obj.ObjectText),  
chain = chainOf(obj),  
})  
end  
end  
end  
c.list = out  
return out  
end

local function shopOfPrompt(en)  
for _, shop in ipairs(SHOPS) do  
for _, key in ipairs(shop.npc) do  
if string.find(en.chain, key, 1, true) or string.find(en.text, key, 1, true) then  
return shop  
end  
end  
end  
return nil  
end

local function findPrompt(words)  
local r = getRoot()  
if not r then  
return nil  
end  
local now = os.clock()  
local best  
for _, en in ipairs(getPrompts()) do  
if en.enabled and hasAny(en.text, words) and not shopOfPrompt(en) and (cooldowns[en.prompt] or 0) < now then  
en.dist = (en.part.Position - r.Position).Magnitude  
if not best or en.dist < best.dist then  
best = en  
end  
end  
end  
return best  
end

local function waitFor(pred, seconds)  
local deadline = os.clock() + seconds  
repeat  
if pred() then  
return true  
end  
RunService.Heartbeat:Wait()  
until os.clock() >= deadline  
return pred() and true or false  
end

local function fireAt(prompt)  
if typeof(fireproximityprompt) ~= "function" then  
S.status = "Executor tidak punya fireproximityprompt"  
return false  
end  
local origDist, origHold = prompt.MaxActivationDistance, prompt.HoldDuration  
pcall(function()  
prompt.MaxActivationDistance = FAR  
prompt.HoldDuration = 0  
end)  
local ok = pcall(fireproximityprompt, prompt)  
pcall(function()  
prompt.MaxActivationDistance = origDist  
prompt.HoldDuration = origHold  
end)  
return ok  
end

local function eggOnKey(sel, key)  
return sel[key] ~= false  
end

local function paintEgg(en)  
for _, rec in ipairs(en.btns) do  
local on = rec.sel[en.key] ~= false  
local text = (on and "[x] " or "[ ] ") .. en.name  
if en.rarity and rec.showRarity then  
text = text .. " | " .. en.rarity  
end  
rec.button.Text = text  
rec.button.BackgroundColor3 = on and C.Light or C.Row  
rec.button.TextColor3 = on and C.Ink or C.Muted  
end  
end

local function attachEgg(en, grid, sel)  
local b = btn(grid, "", C.Row, 24)  
b.Font = Enum.Font.Gotham  
b.TextSize = 10  
b.TextXAlignment = Enum.TextXAlignment.Left  
b.LayoutOrder = en.order  
make("UIPadding", {PaddingLeft = UDim.new(0, 7)}, b)  
b.MouseButton1Click:Connect(function()  
sel[en.key] = not (sel[en.key] ~= false)  
refresh()  
end)  
table.insert(en.btns, {button = b, sel = sel, showRarity = sel == eggSel})  
paintEgg(en)  
end

local function addEgg(name)  
local key = string.lower(name)  
local en = eggKeys[key]  
if en then  
return en  
end  
en = {name = name, key = key, btns = {}, order = #eggList + 1}  
eggKeys[key] = en  
table.insert(eggList, en)  
for _, g in ipairs(eggGrids) do  
attachEgg(en, g.frame, g.sel)  
end  
return en  
end

local function setEggs(sel, value)  
for _, en in ipairs(eggList) do  
sel[en.key] = value  
end  
refresh()  
end

local function eggModelOf(prompt)  
local node = prompt.Parent  
while node and node ~= workspace do  
if node:FindFirstChildOfClass("Humanoid") then  
return nil  
end  
if (node:IsA("Model") or node:IsA("BasePart")) and eggKeyOf(node.Name) then  
return node  
end  
node = node.Parent  
end  
return nil  
end

local function scanEggs(force)  
local c = caches.eggs  
if not force and os.clock() - c.at < 0.2 then  
return c.list  
end  
c.at = os.clock()  
local out, seen = {}, {}  
for _, en in ipairs(getPrompts()) do  
if not hasAny(en.text, BAD_EGG) and not shopOfPrompt(en) then  
local model = eggModelOf(en.prompt)  
if model and not seen[model] then  
seen[model] = true  
local key = eggKeyOf(model.Name)  
local canon = EGG_CANON[key]  
local egg = addEgg(canon)  
egg.rarity = "Luck " .. EGG_LUCK[key]  
local part = partOf and partOf(model, en.prompt) or en.part  
table.insert(out, {  
model = model, prompt = en.prompt, part = en.part,  
name = canon, key = key, rarity = egg.rarity, rank = EGG_TIER[key],  
})  
end  
end  
end  
S.detected = #out  
c.list = out  
return out  
end

local function scanEsp()  
if os.clock() - espAt < 0.5 then  
return espCache  
end  
espAt = os.clock()  
local out, seen = {}, {}  
local ch = player.Character  
for _, obj in ipairs(workspace:GetDescendants()) do  
if (obj:IsA("Model") or obj:IsA("BasePart")) and not seen[obj] then  
local key = eggKeyOf(obj.Name)  
local parentIsEgg = obj:IsA("BasePart") and obj.Parent and eggKeyOf(obj.Parent.Name)  
if key and not parentIsEgg and not (ch and obj:IsDescendantOf(ch)) and not hasAny(chainOf(obj), ESP_BAD) then  
seen[obj] = true  
local part = obj:IsA("BasePart") and obj or (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true))  
if part then  
table.insert(out, {model = obj, part = part, name = EGG_CANON[key], key = key, luck = EGG_LUCK[key]})  
end  
end  
end  
end  
espCache = out  
return out  
end

local function clearEggEsp()  
for model, item in pairs(espItems) do  
pcall(function()  
item.hl:Destroy()  
item.bb:Destroy()  
end)  
espItems[model] = nil  
end  
end

local function updateEggEsp()  
if not CFG.EggESP then  
if next(espItems) then  
clearEggEsp()  
end  
return  
end  
local root = getRoot()  
local keep = {}  
for _, e in ipairs(scanEsp()) do  
if e.model.Parent and e.part.Parent and eggOnKey(espSel, e.key) then  
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
Size = UDim2.fromOffset(220, 22),  
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
local dist = root and math.floor((e.part.Position - root.Position).Magnitude) or 0  
item.lb.Text = e.name .. " | Luck " .. e.luck .. " | " .. dist .. " m"  
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

local function pickEgg(list)  
local r = getRoot()  
if not r then  
return nil  
end  
local best  
local now = os.clock()  
for _, e in ipairs(list) do  
e.dist = (e.part.Position - r.Position).Magnitude  
if eggOnKey(eggSel, e.key) and e.rank >= CFG.MinRank and (ignored[e.model] or 0) < now then  
if not best then  
best = e  
elseif CFG.RarityFirst and e.rank ~= best.rank then  
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

local function heldEgg(force)  
if not force and os.clock() - heldAt < 0.1 then  
return heldCache  
end  
heldAt = os.clock()  
heldCache = nil  
local ch = player.Character  
if not ch then  
return nil  
end  
for _, d in ipairs(ch:GetDescendants()) do  
local key = eggKeyOf(d.Name)  
if key then  
heldCache = EGG_CANON[key]  
break  
end  
end  
return heldCache  
end

local function useMachine(en)  
tpTo(en.part.Position)  
RunService.Heartbeat:Wait()  
local ok = fireAt(en.prompt)  
RunService.Heartbeat:Wait()  
backToZone()  
return ok  
end

local function inventoryTick(egg)  
if not CFG.AutoInv then  
return false  
end  
local en = findPrompt(INVENTORY_WORDS)  
if not en then  
if os.clock() - lastStealAt < CFG.InvWindow then  
S.status = "Prompt Put To Inventory tidak ketemu"  
end  
return false  
end  
cooldowns[en.prompt] = os.clock() + CFG.InvCd  
lastStealAt = 0  
S.status = "Put to inventory " .. tostring(egg)  
useMachine(en)  
S.inv += 1  
return true  
end

local function placeEgg(egg)  
if not CFG.Place then  
return false  
end  
local en = findPrompt(PLACE_WORDS)  
if not en then  
S.status = "Mesin place tidak ditemukan"  
return false  
end  
cooldowns[en.prompt] = os.clock() + CFG.PlaceCd  
S.status = "Place " .. egg  
useMachine(en)  
if not heldEgg(true) then  
S.place += 1  
end  
return true  
end

local function holdingTick()  
local egg = heldEgg(true)  
local recent = CFG.AutoInv and lastStealName ~= nil and os.clock() - lastStealAt < CFG.InvWindow  
if not egg and not recent then  
holdSince = 0  
return false  
end  
egg = egg or lastStealName  
if holdSince == 0 then  
holdSince = os.clock()  
end  
if (recent or os.clock() - holdSince < CFG.HoldTimeout) and inventoryTick(egg) then  
return true  
end  
if not heldEgg(true) then  
return false  
end  
if placeEgg(egg) then  
return true  
end  
if os.clock() - holdSince < CFG.HoldTimeout then  
S.status = "Bawa " .. egg .. " (tier " .. tostring(EGG_TIER[string.lower(egg)]) .. ") ke safe zone"  
local r = getRoot()  
if zone and r and (r.Position - zone).Magnitude > 6 then  
tpTo(zone)  
end  
return true  
end  
S.status = "Egg masih dipegang, lanjut steal"  
return false  
end

local function stealEgg(e)  
if not farmOn() then  
return false  
end  
if not e.prompt.Enabled then  
S.status = "Menunggu " .. e.name .. " siap"  
waitFor(function()  
return not farmOn() or e.prompt.Enabled or not e.prompt:IsDescendantOf(workspace)  
end, 3)  
if not farmOn() or not e.prompt.Enabled then  
return false  
end  
end  
local had = heldEgg(true) ~= nil  
local function picked()  
return not e.prompt:IsDescendantOf(workspace) or not e.prompt.Enabled or (not had and heldEgg(true) ~= nil)  
end  
local function stop()  
return not farmOn() or picked()  
end  
tpTo(e.part.Position)  
RunService.Heartbeat:Wait()  
RunService.Heartbeat:Wait()  
if not farmOn() then  
backToZone()  
return false  
end  
fireAt(e.prompt)  
local done = waitFor(stop, CFG.StealWait) and farmOn() and picked()  
if not done and farmOn() then  
tpTo(e.part.Position)  
RunService.Heartbeat:Wait()  
fireAt(e.prompt)  
done = waitFor(stop, CFG.StealWait) and farmOn() and picked()  
end  
backToZone()  
return done  
end

local function hatchTick()  
if not CFG.Hatch then  
return false  
end  
local en = findPrompt(HATCH_WORDS)  
if not en then  
return false  
end  
cooldowns[en.prompt] = os.clock() + CFG.HatchCd  
S.status = "Hatch"  
useMachine(en)  
S.hatch += 1  
return true  
end

local function kindOf(name)  
local lower = string.lower(name or "")  
if hasAny(lower, TOKEN_WORDS) then  
return "token"  
end  
if hasAny(lower, PUMPKIN_WORDS) then  
return "pumpkin"  
end  
return nil  
end

local function collectOk(kind, chain, text)  
if kind == "token" then  
return not hasAny(chain, COLLECT_BAD) and not hasAny(text, COLLECT_BAD)  
end  
return not hasAny(chain, PUMPKIN_BAD) and not hasAny(chain, COLLECT_BAD) and not hasAny(text, PUMPKIN_BAD)  
end

local function collectTargets()  
local c = caches.collect  
if os.clock() - c.at < 0.5 then  
return c.list  
end  
c.at = os.clock()  
local out, seen = {}, {}  
local ch = player.Character  
for _, en in ipairs(getPrompts()) do  
local kind = kindOf(en.text) or kindOf(en.chain)  
if kind and collectOk(kind, en.chain, en.text) then  
seen[en.prompt] = true  
table.insert(out, {  
prompt = en.prompt, part = en.part, key = en.prompt, kind = kind,  
name = en.prompt.ObjectText ~= "" and en.prompt.ObjectText or (kind == "token" and "Token" or "Pumpkin"),  
})  
end  
end  
for _, obj in ipairs(workspace:GetDescendants()) do  
if (obj:IsA("BasePart") or obj:IsA("Model")) and not (ch and obj:IsDescendantOf(ch)) then  
local kind = kindOf(obj.Name)  
if kind then  
local chain = chainOf(obj)  
if collectOk(kind, chain, string.lower(obj.Name)) then  
local part = obj:IsA("BasePart") and obj or (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true))  
local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)  
if part and not seen[obj] and not (prompt and seen[prompt]) then  
seen[obj] = true  
table.insert(out, {model = obj, part = part, prompt = prompt, key = obj, kind = kind, name = obj.Name})  
end  
end  
end  
end  
end  
c.list = out  
return out  
end

local function targetAlive(c)  
local inst = c.model or c.prompt  
return inst ~= nil and inst:IsDescendantOf(workspace)  
end

local function collectOn(kind)  
if kind == "token" then  
return CFG.CollectToken  
end  
return CFG.CollectPumpkin  
end

local function pickCollect()  
local r = getRoot()  
if not r then  
return nil  
end  
local now = os.clock()  
local best  
for _, c in ipairs(collectTargets()) do  
if collectOn(c.kind) and targetAlive(c) and (ignored[c.key] or 0) < now then  
c.dist = (c.part.Position - r.Position).Magnitude  
if not best or c.dist < best.dist then  
best = c  
end  
end  
end  
return best  
end

local function collectOne(c)  
local standUntil = os.clock() + CFG.CollectStand  
repeat  
tpTo(c.part.Position)  
local root = getRoot()  
if c.prompt and c.prompt.Enabled then  
fireAt(c.prompt)  
elseif typeof(firetouchinterest) == "function" and root then  
pcall(firetouchinterest, root, c.part, 0)  
pcall(firetouchinterest, root, c.part, 1)  
end  
if not targetAlive(c) then  
break  
end  
task.wait(0.1)  
until os.clock() >= standUntil  
task.wait(0.2)  
backToZone()  
return not targetAlive(c)  
end

local function findBoss()  
local c = caches.boss  
if os.clock() - c.at < 0.25 then  
return c.val  
end  
c.at = os.clock()  
c.val = nil  
local root = getRoot()  
if not root then  
return nil  
end  
local ch = player.Character  
local best  
for _, obj in ipairs(workspace:GetDescendants()) do  
if obj:IsA("Humanoid") and obj.Health > 0 then  
local m = obj.Parent  
if m and m:IsA("Model") and m ~= ch and not Players:GetPlayerFromCharacter(m) then  
local isBoss = string.find(string.lower(m.Name), "boss", 1, true) ~= nil or m:GetAttribute("IsBoss") == true  
local part = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart  
if isBoss and part then  
local d = (part.Position - root.Position).Magnitude  
if d <= CFG.FireRange and (not best or d < best.dist) then  
best = {model = m, part = part, dist = d}  
end  
end  
end  
end  
end  
c.val = best  
return best  
end

local function bossActive()  
return CFG.Boss and findBoss() ~= nil  
end

local function fireTool()  
local ch = player.Character  
local hum = humanoid()  
if not ch or not hum then  
return nil  
end  
local want = string.lower(CFG.FireTool or "")  
local function matches(t)  
return want == "" or string.find(string.lower(t.Name), want, 1, true) ~= nil  
end  
local held = ch:FindFirstChildOfClass("Tool")  
if held and matches(held) then  
return held  
end  
local bp = player:FindFirstChildOfClass("Backpack")  
if bp then  
for _, t in ipairs(bp:GetChildren()) do  
if t:IsA("Tool") and matches(t) then  
hum:EquipTool(t)  
return t  
end  
end  
end  
return nil  
end

local function redThreat(root)  
local ch = player.Character  
local params = OverlapParams.new()  
params.FilterType = Enum.RaycastFilterType.Exclude  
params.FilterDescendantsInstances = ch and {ch} or {}  
local probe = root.Position - Vector3.new(0, 5, 0)  
for _, p in ipairs(workspace:GetPartBoundsInRadius(probe, CFG.DodgeRadius, params)) do  
local c = p.Color  
if p.Transparency < 0.8 and c.R > 0.6 and c.G < 0.35 and c.B < 0.35 and p.Size.Y <= 2 then  
local owner = p:FindFirstAncestorWhichIsA("Model")  
if not (owner and Players:GetPlayerFromCharacter(owner)) then  
return p  
end  
end  
end  
return nil  
end

local function dodgeFrom(root, threat)  
local away = Vector3.new(root.Position.X - threat.Position.X, 0, root.Position.Z - threat.Position.Z)  
if away.Magnitude < 0.1 then  
local a = math.random() * math.pi * 2  
away = Vector3.new(math.cos(a), 0, math.sin(a))  
end  
local dir = away.Unit  
local ch = player.Character  
local rp = RaycastParams.new()  
rp.FilterType = Enum.RaycastFilterType.Exclude  
rp.FilterDescendantsInstances = ch and {ch} or {}  
local hit = workspace:Raycast(root.Position, dir * CFG.DodgeStep, rp)  
local dist = hit and math.max(hit.Distance - 2, 0) or CFG.DodgeStep  
tpTo(root.Position + dir * dist - Vector3.new(0, 3, 0))  
end

local function bossTick()  
if not CFG.Boss and not CFG.Dodge then  
return  
end  
local root = getRoot()  
if not root then  
return  
end  
local now = os.clock()  
if CFG.Dodge and now >= dodgeNext then  
local threat = redThreat(root)  
if threat then  
dodgeNext = now + 0.5  
S.dodge += 1  
S.status = "Hindari serangan merah"  
dodgeFrom(root, threat)  
return  
end  
end  
if CFG.Boss then  
local boss = findBoss()  
if not boss then  
return  
end  
local tool = fireTool()  
if not tool then  
S.status = "Tool tembak tidak ditemukan"  
return  
end  
local flat = Vector3.new(boss.part.Position.X, root.Position.Y, boss.part.Position.Z)  
if (flat - root.Position).Magnitude > 0.5 then  
root.CFrame = CFrame.lookAt(root.Position, flat)  
end  
S.status = "Tembak " .. boss.model.Name  
if now >= fireNext then  
fireNext = now + CFG.FireInterval  
S.shots += 1  
pcall(function()  
tool:Activate()  
end)  
end  
end  
end

local function isShown(obj)  
if not obj.Visible or obj.AbsoluteSize.X <= 0 or obj.AbsoluteSize.Y <= 0 then  
return false  
end  
local node = obj.Parent  
while node do  
if node:IsA("GuiObject") and not node.Visible then  
return false  
end  
if node:IsA("LayerCollector") and not node.Enabled then  
return false  
end  
node = node.Parent  
end  
return true  
end

local function ownGui(inst)  
local g = inst:FindFirstAncestorWhichIsA("ScreenGui")  
return g ~= nil and (g.Name == "kayeshiHUB" or g.Name == "kayeshiDiscordPopup")  
end

local function clickableFor(d)  
if d:IsA("GuiButton") then  
return d  
end  
local node = d.Parent  
for _ = 1, 3 do  
if not node then  
return nil  
end  
if node:IsA("GuiButton") then  
return node  
end  
node = node.Parent  
end  
return nil  
end

local function scanUI()  
local out = {}  
local roots = {}  
local pg = player:FindFirstChildOfClass("PlayerGui")  
if pg then  
table.insert(roots, pg)  
end  
local okH, h = pcall(gethui)  
if okH and typeof(h) == "Instance" then  
table.insert(roots, h)  
end  
for _, root in ipairs(roots) do  
for _, d in ipairs(root:GetDescendants()) do  
if (d:IsA("TextButton") or d:IsA("TextLabel")) and d.Text ~= "" and not ownGui(d) and isShown(d) then  
table.insert(out, {text = norm(d.Text), btn = clickableFor(d)})  
end  
end  
end  
return out  
end

local function itemShop(text)  
for _, it in ipairs(SHOP_ITEMS) do  
if string.find(text, it.key, 1, true) then  
return it.shop  
end  
end  
return nil  
end

local function shopOpen(shop)  
for _, e in ipairs(scanUI()) do  
if itemShop(e.text) == shop.id then  
return true  
end  
end  
return false  
end

local function shopOptions(shop)  
local out = {}  
for _, e in ipairs(scanUI()) do  
if e.btn and itemShop(e.text) == nil and #e.text <= 40 and string.find(e.text, shop.kw, 1, true) then  
table.insert(out, e)  
end  
end  
return out  
end

local function clickBtn(target)  
if not target then  
return false  
end  
if typeof(firesignal) == "function" then  
if pcall(firesignal, target.MouseButton1Click) then  
return true  
end  
end  
if typeof(getconnections) == "function" then  
local fired = false  
for _, c in ipairs(getconnections(target.MouseButton1Click)) do  
if pcall(function()  
c:Fire()  
end) then  
fired = true  
end  
end  
return fired  
end  
return false  
end

local function openShop(shop)  
if shopOpen(shop) then  
return true  
end  
for _, e in ipairs(shopOptions(shop)) do  
if clickBtn(e.btn) and waitFor(function()  
return shopOpen(shop)  
end, 2) then  
return true  
end  
end  
local r = getRoot()  
if not r then  
return false  
end  
local best  
for _, en in ipairs(getPrompts()) do  
if en.prompt.Enabled and shopOfPrompt(en) == shop then  
en.dist = (en.part.Position - r.Position).Magnitude  
if not best or en.dist < best.dist then  
best = en  
end  
end  
end  
if not best then  
S.status = shop.label .. ": NPC tidak ditemukan"  
return false  
end  
S.status = "Buka " .. shop.label  
tpTo(best.part.Position)  
RunService.Heartbeat:Wait()  
fireAt(best.prompt)  
waitFor(function()  
return shopOpen(shop) or #shopOptions(shop) > 0  
end, 2.5)  
if not shopOpen(shop) then  
for _, e in ipairs(shopOptions(shop)) do  
if clickBtn(e.btn) and waitFor(function()  
return shopOpen(shop)  
end, 2) then  
break  
end  
end  
end  
local ok = shopOpen(shop)  
backToZone()  
return ok  
end

local function runShop(shop)  
if shopBusy then  
return  
end  
shopBusy = true  
shopNext[shop.id] = os.clock() + CFG.OpenCd  
local ok, res = pcall(openShop, shop)  
shopBusy = false  
if not ok then  
fail("Shop", res)  
elseif res then  
S.shop += 1  
S.status = shop.label .. " terbuka"  
else  
S.status = shop.label .. " belum terbuka"  
end  
end

local function autoShopDue()  
for _, shop in ipairs(SHOPS) do  
if CFG[shop.auto] and os.clock() >= shopNext[shop.id] and not shopOpen(shop) then  
return shop  
end  
end  
return nil  
end

local function mainTick()  
if shopBusy or bossActive() then  
return  
end  
if not getRoot() then  
S.status = "Menunggu karakter"  
return  
end  
if (CFG.CollectToken or CFG.CollectPumpkin) and os.clock() >= collectNext then  
local c = pickCollect()  
if c then  
S.status = "Ambil " .. c.name  
local ok = collectOne(c)  
collectNext = os.clock() + CFG.CollectDelay  
if ok then  
S.collect += 1  
S.status = "Diambil " .. c.name  
else  
ignored[c.key] = os.clock() + CFG.IgnoreTime  
S.status = "Belum terambil " .. c.name  
end  
return  
end  
elseif CFG.CollectToken or CFG.CollectPumpkin then  
S.status = string.format("Jeda ambil %.1f detik", collectNext - os.clock())  
return  
end  
if holdingTick() then  
return  
end  
if hatchTick() then  
return  
end  
if os.clock() >= shopCheckAt then  
shopCheckAt = os.clock() + 1  
local due = autoShopDue()  
if due then  
runShop(due)  
return  
end  
end  
if farmOn() then  
local target = pickEgg(scanEggs())  
if target then  
local tag = target.rarity and (" (" .. target.rarity .. ")") or ""  
S.status = "Steal " .. target.name .. tag  
if stealEgg(target) then  
S.steal += 1  
lastStealAt = os.clock()  
lastStealName = target.name  
S.status = "Dapat " .. target.name .. tag  
elseif farmOn() then  
ignored[target.model] = os.clock() + (target.prompt.Enabled and CFG.IgnoreTime or 1)  
S.status = "Gagal steal " .. target.name  
end  
return  
end  
S.status = S.detected == 0 and "Tidak ada egg terdeteksi" or "Tidak ada egg yang lolos filter"  
else  
S.status = "Auto steal mati"  
end  
end

local function antiAfkClick()  
pcall(function()  
VirtualUser:CaptureController()  
VirtualUser:ClickButton2(Vector2.new())  
end)  
end

local function antiAfkJump()  
local hum = humanoid()  
if hum and hum.Health > 0 then  
hum:ChangeState(Enum.HumanoidStateType.Jumping)  
end  
end

local function applyMove()  
local hum = humanoid()  
if not hum then  
return  
end  
if CFG.Walk and hum.WalkSpeed ~= CFG.WalkSpeed then  
hum.WalkSpeed = CFG.WalkSpeed  
end  
if CFG.Jump then  
hum.UseJumpPower = true  
if hum.JumpPower ~= CFG.JumpPower then  
hum.JumpPower = CFG.JumpPower  
end  
end  
end

local function captureBase(ch)  
local hum = ch:WaitForChild("Humanoid", 10)  
if hum then  
baseWalk = hum.WalkSpeed  
baseJump = hum.JumpPower  
end  
end

local function buildData()  
local data = {cfg = {}, eggs = {}, esp = {}}  
for k, v in pairs(CFG) do  
local t = typeof(v)  
if t == "boolean" or t == "number" or t == "string" then  
data.cfg[k] = v  
end  
end  
for k, v in pairs(eggSel) do  
data.eggs[k] = v  
end  
for k, v in pairs(espSel) do  
data.esp[k] = v  
end  
return HttpService:JSONEncode(data)  
end

local function syncMinIdx()  
for i, m in ipairs(MIN_STEPS) do  
if m[2] == CFG.MinRank then  
minIdx = i  
return  
end  
end  
end

local function applySettings(text)  
local raw = norm(text or "")  
raw = string.gsub(raw, "^" .. SETTING_PREFIX, "")  
raw = norm(raw)  
if raw == "" then  
return false, "kotak kosong"  
end  
local okD, data = pcall(HttpService.JSONDecode, HttpService, raw)  
if not okD or type(data) ~= "table" then  
return false, "format tidak valid, export ulang lalu salin utuh"  
end  
local applied = 0  
for k, v in pairs(data.cfg or {}) do  
if CFG[k] ~= nil and typeof(CFG[k]) == typeof(v) then  
CFG[k] = v  
applied += 1  
end  
end  
for k, v in pairs(data.eggs or {}) do  
if type(v) == "boolean" and EGG_LOWER[k] then  
eggSel[k] = v  
end  
end  
for k, v in pairs(data.esp or {}) do  
if type(v) == "boolean" and EGG_LOWER[k] then  
espSel[k] = v  
end  
end  
syncMinIdx()  
return true, applied  
end

local function saveConfig(force)  
if typeof(writefile) ~= "function" then  
S.config = "writefile tidak ada"  
return  
end  
local ok, json = pcall(buildData)  
if not ok then  
S.config = "gagal encode"  
return  
end  
if not force and json == lastJson then  
return  
end  
if pcall(writefile, CONFIG_FILE, json) then  
lastJson = json  
S.config = "tersimpan"  
else  
S.config = "gagal simpan"  
end  
end

local function loadConfig()  
if typeof(readfile) ~= "function" then  
S.config = "readfile tidak ada"  
return  
end  
if typeof(isfile) == "function" and not isfile(CONFIG_FILE) then  
S.config = "belum ada config"  
return  
end  
local ok, raw = pcall(readfile, CONFIG_FILE)  
if not ok or type(raw) ~= "string" then  
S.config = "gagal baca"  
return  
end  
local okA = applySettings(raw)  
S.config = okA and "dimuat" or "config rusak"  
end

local function viewportSize()  
local cam = workspace.CurrentCamera  
local v = cam and cam.ViewportSize or Vector2.new(900, 600)  
if v.X < 1 or v.Y < 1 then  
v = Vector2.new(900, 600)  
end  
return v  
end

local function uiScaleFor(v)  
return math.clamp(math.min((v.X - 16) / MAIN_W, (v.Y - 16) / MAIN_H), 0.35, 1)  
end

local function clampCenter(x, y, w, h, v)  
x = math.max(w / 2, math.min(v.X - w / 2, x))  
y = math.max(h / 2, math.min(v.Y - h / 2, y))  
return x, y  
end

local function applyLayout()  
if not uiRefs.main then  
return  
end  
local v = viewportSize()  
local s = uiScaleFor(v)  
uiRefs.scale.Scale = s  
local w, h = MAIN_W * s, MAIN_H * s  
if not layoutState.ready then  
layoutState.main = Vector2.new(v.X / 2, v.Y / 2)  
layoutState.logo = Vector2.new(v.X - 36, v.Y / 2)  
layoutState.ready = true  
end  
local mx, my = clampCenter(layoutState.main.X, layoutState.main.Y, w, h, v)  
layoutState.main = Vector2.new(mx, my)  
uiRefs.main.Position = UDim2.fromOffset(mx, my)  
if uiRefs.logo then  
local lx, ly = clampCenter(layoutState.logo.X, layoutState.logo.Y, 44, 44, v)  
layoutState.logo = Vector2.new(lx, ly)  
uiRefs.logo.Position = UDim2.fromOffset(lx, ly)  
end  
end

local function draggable(handle, getCenter, setCenter, onTap)  
local dragging, moved = false, false  
local start, startCenter  
handle.InputBegan:Connect(function(input)  
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
dragging = true  
moved = false  
start = input.Position  
startCenter = getCenter()  
end  
end)  
UIS.InputChanged:Connect(function(input)  
if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then  
local d = input.Position - start  
if d.Magnitude > 6 then  
moved = true  
end  
if moved then  
setCenter(startCenter.X + d.X, startCenter.Y + d.Y)  
end  
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

local function eggGrid(page, sel)  
local rows = math.ceil(#EGG_LIST / 2)  
local grid = make("Frame", {  
Size = UDim2.new(1, 0, 0, rows * 30), BackgroundTransparency = 1, LayoutOrder = nextOrder(),  
}, page)  
make("UIGridLayout", {  
CellSize = UDim2.new(0.5, -4, 0, 24), CellPadding = UDim2.fromOffset(8, 6),  
SortOrder = Enum.SortOrder.LayoutOrder,  
}, grid)  
table.insert(eggGrids, {frame = grid, sel = sel})  
for _, en in ipairs(eggList) do  
attachEgg(en, grid, sel)  
end  
end

local function showDiscordPopup()  
local playerGui = player:WaitForChild("PlayerGui")  
local old = playerGui:FindFirstChild("kayeshiDiscordPopup")  
if old then  
old:Destroy()  
end  
local gui = make("ScreenGui", {Name = "kayeshiDiscordPopup", ResetOnSpawn = false, DisplayOrder = 10000, IgnoreGuiInset = true}, playerGui)  
local bg = make("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.4, BorderSizePixel = 0}, gui)  
local panel = make("Frame", {  
AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),  
Size = UDim2.new(0.92, 0, 0, 220), BackgroundColor3 = C.Panel, BorderSizePixel = 0,  
}, bg)  
make("UISizeConstraint", {MaxSize = Vector2.new(340, 220)}, panel)  
corner(panel, 14)  
make("TextLabel", {  
Size = UDim2.new(1, -70, 0, 30), Position = UDim2.fromOffset(15, 14), BackgroundTransparency = 1,  
Text = "JOIN DISCORD COMMUNITY", TextColor3 = Color3.fromRGB(170, 180, 255),  
Font = Enum.Font.GothamBold, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left,  
}, panel)  
make("TextLabel", {  
Size = UDim2.new(1, -30, 0, 50), Position = UDim2.fromOffset(15, 48), BackgroundTransparency = 1,  
Text = "Join komunitas kayeshiHUB untuk info, update script, dan saran fitur terbaru.",  
TextWrapped = true, TextColor3 = Color3.fromRGB(220, 222, 230), Font = Enum.Font.Gotham,  
TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,  
}, panel)  
local close = btn(panel, "X", C.Dark, 30)  
close.Size = UDim2.fromOffset(30, 30)  
close.Position = UDim2.new(1, -40, 0, 8)  
local join = btn(panel, "COPY INVITE LINK", C.Accent, 36)  
join.Size = UDim2.new(1, -30, 0, 36)  
join.Position = UDim2.fromOffset(15, 120)  
join.MouseButton1Click:Connect(function()  
local ok = pcall(function()  
assert(type(setclipboard) == "function", "Clipboard tidak didukung")  
setclipboard(DISCORD_LINK)  
end)  
notify(ok and "Link Discord disalin!" or DISCORD_LINK)  
end)  
close.MouseButton1Click:Connect(function()  
gui:Destroy()  
end)  
end

local function buildUI()  
local host = player:WaitForChild("PlayerGui")  
local okHui, hui = pcall(gethui)  
if okHui and typeof(hui) == "Instance" then  
host = hui  
end  
local old = host:FindFirstChild("kayeshiHUB")  
if old then  
old:Destroy()  
end

local gui = make("ScreenGui", {Name = "kayeshiHUB", ResetOnSpawn = false, DisplayOrder = 999, IgnoreGuiInset = true}, host)

local main = make("Frame", {  
AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(0, 0),  
Size = UDim2.fromOffset(MAIN_W, MAIN_H), BackgroundColor3 = C.Panel, BorderSizePixel = 0,  
}, gui)  
corner(main, 12)  
local uiScale = make("UIScale", {Scale = 1}, main)  
uiRefs.main = main  
uiRefs.scale = uiScale

local header = make("Frame", {Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = C.Side, BorderSizePixel = 0}, main)  
corner(header, 12)  
make("TextLabel", {  
Size = UDim2.new(0, 220, 0, 20), Position = UDim2.fromOffset(16, 6), BackgroundTransparency = 1,  
Text = "kayeshiHUB", TextColor3 = C.Text, Font = Enum.Font.GothamBold, TextSize = 16,  
TextXAlignment = Enum.TextXAlignment.Left,  
}, header)  
local subtitle = make("TextLabel", {  
Size = UDim2.new(1, -140, 0, 16), Position = UDim2.fromOffset(16, 26), BackgroundTransparency = 1,  
TextColor3 = C.Muted, Font = Enum.Font.Gotham, TextSize = 10,  
TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,  
}, header)  
local hideBtn = btn(header, "Sembunyikan", C.Dark, 26)  
hideBtn.Size = UDim2.fromOffset(106, 26)  
hideBtn.Position = UDim2.new(1, -116, 0, 10)  
hideBtn.TextSize = 10

local side = make("Frame", {  
Position = UDim2.fromOffset(10, 56), Size = UDim2.new(0, 130, 1, -110), BackgroundColor3 = C.Side, BorderSizePixel = 0,  
}, main)  
corner(side, 10)  
make("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, side)  
make("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, side)  
local tabs = {}  
local TABS = {{"main", "Main"}, {"auto", "Auto"}, {"shop", "Shop"}, {"esp", "ESP"}, {"event", "Event"}, {"discord", "Discord"}}  
for i, t in ipairs(TABS) do  
local b = btn(side, t[2], C.Card, 30)  
b.LayoutOrder = i  
b.TextSize = 12  
tabs[t[1]] = b  
end

local content = make("Frame", {  
Position = UDim2.fromOffset(150, 56), Size = UDim2.new(1, -160, 1, -110),  
BackgroundColor3 = C.Side, BorderSizePixel = 0,  
}, main)  
corner(content, 10)

local footer = make("Frame", {  
Position = UDim2.new(0, 10, 1, -46), Size = UDim2.new(1, -20, 0, 36), BackgroundColor3 = C.Side, BorderSizePixel = 0,  
}, main)  
corner(footer, 10)  
local statusLbl = make("TextLabel", {  
Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1,  
TextColor3 = C.Muted, Font = Enum.Font.Gotham, TextSize = 10,  
TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,  
}, footer)

local function newPage()  
local page = make("ScrollingFrame", {  
Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 1, -16), BackgroundTransparency = 1,  
BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = C.Muted, CanvasSize = UDim2.new(),  
AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,  
}, content)  
make("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, page)  
make("UIPadding", {PaddingRight = UDim.new(0, 8)}, page)  
return page  
end  
local pages = {main = newPage(), auto = newPage(), shop = newPage(), esp = newPage(), event = newPage(), discord = newPage()}

local function row(page)  
return make("Frame", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, LayoutOrder = nextOrder()}, page)  
end

local function section(page, text)  
make("TextLabel", {  
Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = string.upper(text),  
TextColor3 = C.Muted, Font = Enum.Font.GothamBold, TextSize = 10,  
TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrder(),  
}, page)  
end

local function note(page, text)  
make("TextLabel", {  
Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, TextWrapped = true, Text = text,  
TextColor3 = C.Muted, Font = Enum.Font.Gotham, TextSize = 10,  
TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,  
LayoutOrder = nextOrder(),  
}, page)  
end

local function toggle(page, label, key, onFlip)  
local b = btn(page, "", C.Dark, 28)  
b.LayoutOrder = nextOrder()  
paints[#paints + 1] = function()  
local on = CFG[key] == true  
b.Text = label .. (on and "   ON" or "   OFF")  
b.BackgroundColor3 = on and C.Light or C.Dark  
b.TextColor3 = on and C.Ink or C.Text  
end  
b.MouseButton1Click:Connect(function()  
CFG[key] = not CFG[key]  
if onFlip then  
onFlip()  
end  
refresh()  
end)  
return b  
end

local function stepper(page, label, key, step, lo, hi)  
local r = make("Frame", {  
Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = C.Card, BorderSizePixel = 0, LayoutOrder = nextOrder(),  
}, page)  
corner(r, 7)  
make("TextLabel", {  
Size = UDim2.new(1, -130, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1,  
Text = label, TextColor3 = C.Muted, Font = Enum.Font.GothamSemibold, TextSize = 11,  
TextXAlignment = Enum.TextXAlignment.Left,  
}, r)  
local value = make("TextLabel", {  
Size = UDim2.fromOffset(44, 28), Position = UDim2.new(1, -92, 0, 0), BackgroundTransparency = 1,  
TextColor3 = C.Text, Font = Enum.Font.GothamBold, TextSize = 12,  
}, r)  
local minus = btn(r, "-", C.Row, 22)  
minus.Size = UDim2.fromOffset(28, 22)  
minus.Position = UDim2.new(1, -124, 0, 3)  
local plus = btn(r, "+", C.Row, 22)  
plus.Size = UDim2.fromOffset(28, 22)  
plus.Position = UDim2.new(1, -36, 0, 3)  
local function bump(d)  
local v = CFG[key] + d * step  
CFG[key] = math.clamp(math.floor(v / step + 0.5) * step, lo, hi)  
refresh()  
end  
minus.MouseButton1Click:Connect(function()  
bump(-1)  
end)  
plus.MouseButton1Click:Connect(function()  
bump(1)  
end)  
paints[#paints + 1] = function()  
value.Text = string.format("%g", CFG[key])  
end  
end

local function eggControls(page, sel, minButton)  
local r = row(page)  
local all = btn(r, "Pilih semua", C.Dark, 28)  
all.Size = UDim2.new(0.34, -4, 1, 0)  
local none = btn(r, "Kosongkan", C.Dark, 28)  
none.Size = UDim2.new(0.33, -4, 1, 0)  
none.Position = UDim2.new(0.34, 3, 0, 0)  
all.MouseButton1Click:Connect(function()  
setEggs(sel, true)  
end)  
none.MouseButton1Click:Connect(function()  
setEggs(sel, false)  
end)  
if minButton then  
local minB = btn(r, "", C.Dark, 28)  
minB.Size = UDim2.new(0.33, -4, 1, 0)  
minB.Position = UDim2.new(0.67, 4, 0, 0)  
minB.MouseButton1Click:Connect(function()  
minIdx = minIdx % #MIN_STEPS + 1  
CFG.MinRank = MIN_STEPS[minIdx][2]  
refresh()  
end)  
paints[#paints + 1] = function()  
minB.Text = "Min: " .. MIN_STEPS[minIdx][1]  
end  
end  
eggGrid(page, sel)  
end

local mp, ap, sp, esp, ep, dp = pages.main, pages.auto, pages.shop, pages.esp, pages.event, pages.discord

section(mp, "Auto steal")  
note(mp, "Teleport ke egg, tekan prompt, lalu kembali ke safe zone. Tier tertinggi dulu.")  
toggle(mp, "Auto steal", "Farm")  
toggle(mp, "Tier tertinggi dulu", "RarityFirst")  
stepper(mp, "Tunggu steal (detik)", "StealWait", 0.1, 0.1, 2)  
stepper(mp, "Batas bawa egg (detik)", "HoldTimeout", 1, 1, 30)

section(mp, "Anti AFK")  
note(mp, "Anti AFK melompat setelah karakter tidak menerima input selama waktu di bawah.")  
toggle(mp, "Anti AFK", "AntiAFK", function()  
lastActive = os.clock()  
end)  
stepper(mp, "Lompat setelah diam (detik)", "AfkIdle", 30, 60, 900)

section(mp, "Safe zone")  
local zr = row(mp)  
local zoneBtn = btn(zr, "Set safe zone di sini", C.Dark, 28)  
zoneBtn.Size = UDim2.new(0.5, -4, 1, 0)  
local tpBtn = btn(zr, "Teleport ke safe zone", C.Dark, 28)  
tpBtn.Size = UDim2.new(0.5, -4, 1, 0)  
tpBtn.Position = UDim2.new(0.5, 4, 0, 0)  
zoneBtn.MouseButton1Click:Connect(function()  
local r = getRoot()  
if r then  
zone = r.Position  
S.status = "Safe zone disimpan"  
else  
S.status = "Karakter belum siap"  
end  
refresh()  
end)  
tpBtn.MouseButton1Click:Connect(function()  
if zone then  
tpTo(zone)  
S.status = "Teleport ke safe zone"  
else  
S.status = "Safe zone belum di-set"  
end  
refresh()  
end)

section(mp, "Player")  
toggle(mp, "WalkSpeed", "Walk", function()  
local hum = humanoid()  
if hum and not CFG.Walk then  
hum.WalkSpeed = baseWalk  
end  
end)  
stepper(mp, "Kecepatan jalan", "WalkSpeed", 5, 16, 250)  
toggle(mp, "JumpPower", "Jump", function()  
local hum = humanoid()  
if hum and not CFG.Jump then  
hum.JumpPower = baseJump  
end  
end)  
stepper(mp, "Kekuatan lompat", "JumpPower", 10, 50, 300)

section(mp, "Config")  
toggle(mp, "Auto save config", "AutoSave")  
local cr = row(mp)  
local saveBtn = btn(cr, "Simpan sekarang", C.Dark, 28)  
saveBtn.Size = UDim2.new(0.5, -4, 1, 0)  
local loadBtn = btn(cr, "Muat config", C.Dark, 28)  
loadBtn.Size = UDim2.new(0.5, -4, 1, 0)  
loadBtn.Position = UDim2.new(0.5, 4, 0, 0)  
saveBtn.MouseButton1Click:Connect(function()  
saveConfig(true)  
refresh()  
end)  
loadBtn.MouseButton1Click:Connect(function()  
loadConfig()  
syncMinIdx()  
refresh()  
end)

section(mp, "Export / Import settingan")  
note(mp, "Export mengisi kotak dan menyalin settingan. Bagikan teksnya, lalu tempel di kotak dan tekan Import.")  
local transferBox = make("TextBox", {  
Size = UDim2.new(1, 0, 0, 58), BackgroundColor3 = C.Card, BorderSizePixel = 0, Text = "",  
PlaceholderText = "Tempel string settingan di sini", PlaceholderColor3 = C.Muted,  
TextColor3 = C.Text, Font = Enum.Font.Gotham, TextSize = 10, ClearTextOnFocus = false,  
MultiLine = true, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,  
TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = nextOrder(),  
}, mp)  
corner(transferBox, 7)  
make("UIPadding", {PaddingLeft = UDim.new(0, 6), PaddingTop = UDim.new(0, 4)}, transferBox)  
local tr = row(mp)  
local exportBtn = btn(tr, "Export settingan", C.Accent, 28)  
exportBtn.Size = UDim2.new(0.5, -4, 1, 0)  
local importBtn = btn(tr, "Import settingan", C.Dark, 28)  
importBtn.Size = UDim2.new(0.5, -4, 1, 0)  
importBtn.Position = UDim2.new(0.5, 4, 0, 0)  
exportBtn.MouseButton1Click:Connect(function()  
local ok, json = pcall(buildData)  
if not ok then  
S.status = "Export gagal"  
refresh()  
return  
end  
local text = SETTING_PREFIX .. json  
transferBox.Text = text  
local copied = pcall(function()  
assert(type(setclipboard) == "function", "Clipboard tidak didukung")  
setclipboard(text)  
end)  
S.status = copied and "Settingan diexport dan disalin" or "Settingan diexport (salin manual dari kotak)"  
notify(S.status)  
refresh()  
end)  
importBtn.MouseButton1Click:Connect(function()  
local ok, res = applySettings(transferBox.Text)  
if ok then  
saveConfig(true)  
S.status = "Import berhasil (" .. tostring(res) .. " pengaturan)"  
notify(S.status)  
else  
S.status = "Import gagal: " .. tostring(res)  
end  
refresh()  
end)

section(mp, "Cek")  
local probeBtn = btn(mp, "Cek egg terdekat (luck)", C.Dark, 28)  
probeBtn.LayoutOrder = nextOrder()  
probeBtn.MouseButton1Click:Connect(function()  
local r = getRoot()  
local best  
for _, e in ipairs(scanEggs(true)) do  
if not best or (r and (e.part.Position - r.Position).Magnitude < (best.part.Position - r.Position).Magnitude) then  
best = e  
end  
end  
if best then  
S.status = best.name .. " | " .. best.rarity .. " | tier " .. tostring(best.rank)  
notify(S.status)  
else  
S.status = "Tidak ada egg dari daftar terdeteksi"  
end  
refresh()  
end)

section(ap, "Filter egg untuk steal, place, dan inventory")  
note(ap, "Egg yang tidak dicentang tidak akan di-steal atau di-place.")  
section(ap, "Auto inventory")  
note(ap, "Setelah steal, atau saat memegang egg, teleport ke prompt 'Put To Inventory' lalu tekan. Dijalankan sebelum Auto Place.")  
toggle(ap, "Auto Inventory", "AutoInv")  
stepper(ap, "Cooldown inventory (detik)", "InvCd", 0.5, 0.5, 10)  
section(ap, "Auto place")  
note(ap, "Auto Place hanya berjalan saat karakter memegang egg. Teleport ke mesin place lalu tekan prompt.")  
toggle(ap, "Auto Place", "Place")  
stepper(ap, "Cooldown place (detik)", "PlaceCd", 0.5, 0.5, 10)  
section(ap, "Auto hatch")  
note(ap, "Saat tidak pegang egg, teleport ke mesin hatch terdekat lalu tekan prompt.")  
toggle(ap, "Auto Hatch", "Hatch")  
stepper(ap, "Cooldown hatch (detik)", "HatchCd", 0.5, 0.5, 30)  
eggControls(ap, eggSel, false)

section(sp, "Auto buka shop")  
note(sp, "Radar Shop lewat NPC Mudagen, Feed Shop lewat NPC Alex. Auto beli sudah dihapus.")  
toggle(sp, "Auto buka Radar Shop", "AutoRadar")  
toggle(sp, "Auto buka Feed Shop", "AutoFeed")  
stepper(sp, "Jeda cek buka (detik)", "OpenCd", 1, 3, 60)  
section(sp, "Buka manual")  
local manualRow = row(sp)  
for i, shop in ipairs(SHOPS) do  
local b = btn(manualRow, "Buka " .. shop.label, C.Accent, 28)  
b.Size = UDim2.new(0.5, -4, 1, 0)  
b.Position = UDim2.new(0.5 * (i - 1), (i == 1) and 0 or 4, 0, 0)  
b.MouseButton1Click:Connect(function()  
S.status = "Membuka " .. shop.label .. "..."  
refresh()  
task.spawn(runShop, shop)  
end)  
end  
local scanBtn = btn(sp, "Cek tombol shop yang terlihat", C.Dark, 28)  
scanBtn.LayoutOrder = nextOrder()  
scanBtn.MouseButton1Click:Connect(function()  
local menus, items = 0, 0  
for _, e in ipairs(scanUI()) do  
if itemShop(e.text) then  
items += 1  
elseif string.find(e.text, "shop", 1, true) or string.find(e.text, "radar", 1, true) or string.find(e.text, "feed", 1, true) then  
menus += 1  
end  
end  
S.status = string.format("Menu shop: %d | Item shop: %d", menus, items)  
notify(S.status)  
refresh()  
end)

section(esp, "Egg ESP")  
note(esp, "Menandai egg yang dicentang di bawah dengan nama, luck, dan jarak. Egg yang baru spawn ikut terdeteksi.")  
toggle(esp, "Egg ESP", "EggESP", function()  
if not CFG.EggESP then  
clearEggEsp()  
end  
end)  
section(esp, "Filter ESP")  
eggControls(esp, espSel, false)

section(ep, "Auto collect token")  
note(ep, "Teleport ke objek atau prompt yang namanya mengandung 'token'. Area token generator diabaikan.")  
toggle(ep, "Collect token", "CollectToken")  
section(ep, "Auto collect pumpkin")  
note(ep, "Teleport ke objek atau prompt yang namanya mengandung 'pumpkin'. Ember Pumpkin Citadel diabaikan.")  
toggle(ep, "Collect pumpkin", "CollectPumpkin")  
section(ep, "Jeda ambil")  
note(ep, "Jeda ini berlaku di antara setiap pengambilan token maupun pumpkin.")  
stepper(ep, "Jeda antar ambil (detik)", "CollectDelay", 0.5, 0, 10)  
stepper(ep, "Diam di objek (detik)", "CollectStand", 0.5, 0.5, 5)  
section(ep, "Auto fire boss")  
note(ep, "Menembak boss (nama mengandung 'boss' atau atribut IsBoss). Menghindar dari indikator merah di bawah player.")  
toggle(ep, "Auto tembak boss", "Boss")  
toggle(ep, "Hindari indikator merah", "Dodge")  
stepper(ep, "Jarak tembak (studs)", "FireRange", 10, 20, 400)  
stepper(ep, "Radius deteksi merah", "DodgeRadius", 1, 2, 20)  
stepper(ep, "Jarak hindar (studs)", "DodgeStep", 2, 4, 40)  
local toolRow = make("Frame", {Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = C.Card, BorderSizePixel = 0, LayoutOrder = nextOrder()}, ep)  
corner(toolRow, 7)  
local toolBox = make("TextBox", {  
Size = UDim2.new(1, -16, 1, -6), Position = UDim2.fromOffset(8, 3), BackgroundColor3 = C.Row, BorderSizePixel = 0,  
Text = CFG.FireTool, PlaceholderText = "Nama tool (kosong = tool apa saja)", PlaceholderColor3 = C.Muted,  
TextColor3 = C.Text, Font = Enum.Font.Gotham, TextSize = 11, ClearTextOnFocus = false,  
TextXAlignment = Enum.TextXAlignment.Left,  
}, toolRow)  
corner(toolBox, 6)  
make("UIPadding", {PaddingLeft = UDim.new(0, 8)}, toolBox)  
toolBox.FocusLost:Connect(function()  
CFG.FireTool = toolBox.Text  
refresh()  
end)  
paints[#paints + 1] = function()  
if not toolBox:IsFocused() then  
toolBox.Text = CFG.FireTool  
end  
end

section(dp, "Komunitas")  
note(dp, "Join komunitas kayeshiHUB untuk info, update script, dan saran fitur terbaru.")  
local discordCopy = btn(dp, "Salin link Discord", C.Accent, 30)  
discordCopy.LayoutOrder = nextOrder()  
discordCopy.MouseButton1Click:Connect(function()  
local ok = pcall(function()  
assert(type(setclipboard) == "function", "Clipboard tidak didukung")  
setclipboard(DISCORD_LINK)  
end)  
notify(ok and "Link berhasil disalin!" or DISCORD_LINK)  
end)  
note(dp, DISCORD_LINK)

paints[#paints + 1] = function()  
for _, en in ipairs(eggList) do  
paintEgg(en)  
end  
end  
paints[#paints + 1] = function()  
subtitle.Text = string.format("Steal %d | Collect %d | Place %d | Inv %d | Hatch %d | Shop %d | Boss %d | Hindar %d",  
S.steal, S.collect, S.place, S.inv, S.hatch, S.shop, S.shots, S.dodge)  
statusLbl.Text = string.format("%s | Terdeteksi %d | Config %s | Error %d", S.status, S.detected, S.config, S.errors)  
end

local logo = make("Frame", {  
AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(44, 44),  
BackgroundColor3 = C.Ink, BorderSizePixel = 0, Visible = false, ZIndex = 5,  
}, gui)  
corner(logo, 12)  
make("UIStroke", {Color = C.Light, Thickness = 1.5}, logo)  
local logoBtn = make("TextButton", {  
Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,  
AutoButtonColor = false, Text = "K", TextColor3 = C.Text, Font = Enum.Font.GothamBold, TextSize = 20, ZIndex = 6,  
}, logo)  
uiRefs.logo = logo

local function setMenu(open)  
main.Visible = open  
logo.Visible = not open  
applyLayout()  
end

hideBtn.MouseButton1Click:Connect(function()  
setMenu(false)  
end)

draggable(logoBtn,  
function()  
return layoutState.logo  
end,  
function(x, y)  
layoutState.logo = Vector2.new(x, y)  
applyLayout()  
end,  
function()  
setMenu(true)  
end)

local function setPage(name)  
for key, p in pairs(pages) do  
p.Visible = key == name  
end  
for key, b in pairs(tabs) do  
local active = key == name  
b.BackgroundColor3 = active and C.Light or C.Card  
b.TextColor3 = active and C.Ink or C.Text  
end  
end

for key, b in pairs(tabs) do  
b.MouseButton1Click:Connect(function()  
setPage(key)  
end)  
end

draggable(header,  
function()  
return layoutState.main  
end,  
function(x, y)  
layoutState.main = Vector2.new(x, y)  
applyLayout()  
end)

UIS.InputBegan:Connect(function(input, gameProcessed)  
if gameProcessed then  
return  
end  
if input.KeyCode == Enum.KeyCode.F then  
CFG.Farm = not CFG.Farm  
S.status = CFG.Farm and "Auto steal nyala" or "Auto steal mati"  
refresh()  
end  
end)

local cam = workspace.CurrentCamera  
if cam then  
cam:GetPropertyChangedSignal("ViewportSize"):Connect(applyLayout)  
end  
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()  
local newCam = workspace.CurrentCamera  
if newCam then  
newCam:GetPropertyChangedSignal("ViewportSize"):Connect(applyLayout)  
end  
applyLayout()  
end)

setPage("main")  
refresh()  
applyLayout()  
end

for _, name in ipairs(EGG_NAMES) do  
addEgg(name)  
end

local okUI, errUI = pcall(buildUI)  
if not okUI then  
warn("kayeshiHUB menu: " .. tostring(errUI))  
notify("Menu gagal: " .. string.sub(tostring(errUI), 1, 150))  
end

pcall(loadConfig)  
syncMinIdx()  
refresh()

UIS.InputBegan:Connect(function()  
lastActive = os.clock()  
end)  
UIS.InputChanged:Connect(function()  
lastActive = os.clock()  
end)

if player.Character then  
task.spawn(captureBase, player.Character)  
end  
player.CharacterAdded:Connect(captureBase)

player.Idled:Connect(function()  
if CFG.AntiAFK then  
antiAfkClick()  
antiAfkJump()  
end  
end)

RunService.Heartbeat:Connect(function()  
pcall(applyMove)  
end)

task.spawn(function()  
local ch = player.Character or player.CharacterAdded:Wait()  
local r = ch:WaitForChild("HumanoidRootPart", 10)  
if r and not zone then  
zone = r.Position  
S.status = "Safe zone otomatis di posisi awal"  
end  
end)

loop("utama", 0.05, mainTick)  
loop("boss", 0.05, bossTick)  
loop("egg esp", 0.6, updateEggEsp)  
loop("afk", 1, function()  
if CFG.AntiAFK and os.clock() - lastActive >= CFG.AfkIdle then  
lastActive = os.clock()  
antiAfkJump()  
S.status = "Anti AFK: lompat setelah diam"  
end  
end)  
loop("autosave", 2, function()  
if CFG.AutoSave then  
saveConfig(false)  
end  
end)  
loop("ui", 0.4, refresh)

task.delay(1, function()  
pcall(showDiscordPopup)  
end)

notify("kayeshiHUB aktif. Tekan F untuk auto steal.")  
