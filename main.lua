local Players = game:GetService("Players")  
local UIS = game:GetService("UserInputService")  
local StarterGui = game:GetService("StarterGui")  
local VirtualUser = game:GetService("VirtualUser")  
local HttpService = game:GetService("HttpService")  
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer  
local DISCORD = "https://discord.gg/tfXf5W6WCw"  
local WHATSAPP = "https://whatsapp.com/channel/0029Vb9IS0P5K3zLIVZzsv3W"  
local CONFIG_FILE = "kayeshiHUB_config.json"  
local FAR = 1e6  
local PANEL_W, PANEL_H = 560, 380

local function notify(text)  
pcall(function()  
StarterGui:SetCore("SendNotification", {Title = "kayeshiHUB", Text = string.sub(tostring(text), 1, 200), Duration = 4})  
end)  
end

notify("kayeshiHUB memuat...")

local C = {  
Panel = Color3.fromRGB(17, 17, 21),  
Side = Color3.fromRGB(24, 24, 30),  
Card = Color3.fromRGB(32, 32, 40),  
Row = Color3.fromRGB(42, 42, 52),  
Dark = Color3.fromRGB(58, 58, 70),  
Light = Color3.fromRGB(238, 238, 244),  
Accent = Color3.fromRGB(99, 110, 255),  
Blue = Color3.fromRGB(30, 144, 255),  
DeepBlue = Color3.fromRGB(0, 60, 110),  
Text = Color3.fromRGB(245, 245, 248),  
Ink = Color3.fromRGB(16, 16, 20),  
Muted = Color3.fromRGB(154, 154, 168),  
}

local EGG_LIST = {  
{"Common Egg", "1"}, {"Coral Egg", "20"}, {"Reef Egg", "400"}, {"Tidal Egg", "8K"}, {"Deep Egg", "160K"},  
{"Abyss Egg", "3M"}, {"Trench Egg", "60M"}, {"Sovereign Egg", "1B"}, {"Celestial Egg", "20B"},  
{"Kraken Glory Egg", "24B-140B"}, {"Eternal Egg", "70B"}, {"Admin Abuse Seraph Egg", "80B-2T"},  
{"Coral Reef Egg", "90B"}, {"Glacial Spiral Egg", "115B"}, {"KingKalolo Egg", "130B-400B"},  
{"Amethyst Spiral Egg", "140B"}, {"Azure Crown Egg", "170B"}, {"Solar Orbit Egg", "200B"},  
{"Spikey Egg", "250B"}, {"Mamba Egg", "300B"}, {"Inferno Egg", "350B"}, {"Golem Egg", "500B-1T"},  
{"Astral Vortex", "5T"},  
}

local EGG, EGG_KEYS = {}, {}  
for i, e in ipairs(EGG_LIST) do  
local key = string.lower(e[1])  
EGG[key] = {name = e[1], luck = e[2], rank = i, key = key}  
table.insert(EGG_KEYS, key)  
end  
EGG["kingkolo egg"] = EGG["kingkalolo egg"]  
table.insert(EGG_KEYS, "kingkolo egg")  
table.sort(EGG_KEYS, function(a, b)  
return #a > #b  
end)

local MIN_STEPS = {  
{"Semua", 0},  
{"Sovereign+", EGG["sovereign egg"].rank},  
{"Celestial+", EGG["celestial egg"].rank},  
{"Kraken+", EGG["kraken glory egg"].rank},  
{"Golem+", EGG["golem egg"].rank},  
}

local BAD_NAME = {"hatch", "place", "plant", "incubat", "inventor", "shop", "machine", "npc", "sell", "buy", "tukar"}  
local BAD_ANCESTOR = {"hatch", "place", "plant", "incubat", "machine", "shop", "npc", "display", "showcase", "inventory", "mudagen", "mudargen", "reward"}  
local BAD_PROMPT = {"inventory", "place", "plant", "incubat", "hatch", "shop", "buy", "sell", "tukar"}  
local BAD_CHAIN = {"generator", "shop", "npc", "citadel", "merchant", "tukar", "swap", "event", "halloween", "pumpkins"}  
local MACHINE_WORDS = {"place", "plant", "incubat", "hatch", "inventory"}  
local LOW_OFF = {  
ParticleEmitter = true, Trail = true, Beam = true, Smoke = true, Fire = true, Sparkles = true,  
PointLight = true, SpotLight = true, SurfaceLight = true, Clouds = true,  
}

local CFG = {  
AutoSteal = true, RarityFirst = false, MinRank = 0, StealWait = 1.2, BossAvoid = 20, IgnoreTime = 6,  
MachineClear = 25, ReturnRadius = 6, SafeTrail = true, SafeSide = 4,  
AutoInv = true, InvCd = 1.5, InvTries = 3,  
AutoPlace = false, PlaceReturn = true, MachineCd = 2,  
AutoHatch = false, HatchCd = 3,  
CollectToken = false, CollectPumpkin = false, CollectDelay = 1.5, CollectStand = 1,  
AutoBoss = false, Dodge = true, DodgeRadius = 3, DodgeStep = 14, DodgeCd = 0.5,  
FireRange = 150, FireInterval = 0.15, FireTool = "",  
EggESP = false, XRay = false,  
LowGraphics = false, Walk = false, WalkSpeed = 16, Jump = false, JumpPower = 50,  
AntiAFK = true, AfkIdle = 300, AutoSave = true,  
}  
local DEFAULT = {}  
for k, v in pairs(CFG) do  
DEFAULT[k] = v  
end

local idx = {egg = {}, token = {}, pumpkin = {}, prompt = {}, trail = {}, boss = {}}  
local eggSel, espSel = {}, {}  
local visuals, ignored, cooldown, waterCache = {}, {}, {}, {}  
local machCache, machAt = {}, 0  
local S = {status = "Memuat...", steal = 0, inv = 0, place = 0, hatch = 0, collect = 0, shots = 0, dodge = 0, errors = 0, config = "-", held = "-", low = 0, lowErr = 0}  
local zone  
local busy = false  
local paints, uiRefs = {}, {}  
local layout = {main = Vector2.new(0, 0), logo = Vector2.new(0, 0), ready = false}  
local orderSeq = 0  
local lastActive = os.clock()  
local baseWalk, baseJump = 16, 50  
local nextInv, nextPlace, nextHatch, nextCollect, nextDodge, nextFire = 0, 0, 0, 0, 0, 0  
local invFails = 0  
local lastJson  
local minIdx = 1

local function refresh()  
for _, f in ipairs(paints) do  
pcall(f)  
end  
end

local function nextOrder()  
orderSeq += 1  
return orderSeq  
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

local function streamAround(pos)  
if pos then  
pcall(function()  
player:RequestStreamAroundAsync(pos, 1024)  
end)  
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

local function chainOf(inst)  
local names, node = {}, inst  
while node and node ~= workspace do  
table.insert(names, string.lower(node.Name))  
node = node.Parent  
end  
return table.concat(names, " / ")  
end

local function eggOf(text)  
local l = string.lower(text or "")  
if EGG[l] then  
return EGG[l]  
end  
for _, k in ipairs(EGG_KEYS) do  
if string.find(l, k, 1, true) then  
return EGG[k]  
end  
end  
return nil  
end

local function selOn(sel, key)  
return sel[key] ~= false  
end

local function partOf(obj)  
if obj:IsA("BasePart") then  
return obj  
end  
return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)  
end

local function textOf(p)  
return string.lower(p.ActionText .. " " .. p.ObjectText)  
end

local function promptPos(p)  
local node = p.Parent  
if node and node:IsA("Attachment") then  
node = node.Parent  
end  
if node and node:IsA("BasePart") then  
return node.Position  
end  
if node and node:IsA("Model") then  
return node:GetPivot().Position  
end  
return nil  
end

local function dropVisual(obj)  
local item = visuals[obj]  
if item then  
pcall(function()  
item.hl:Destroy()  
item.bb:Destroy()  
end)  
visuals[obj] = nil  
end  
end

local function clearVisuals()  
for obj in pairs(visuals) do  
dropVisual(obj)  
end  
end

local function kindOf(obj)  
if obj:IsA("ProximityPrompt") then  
return "prompt"  
end  
if not (obj:IsA("Model") or obj:IsA("BasePart")) then  
return nil  
end  
local n = string.lower(obj.Name)  
if n == "trail shop" or n == "trailshop" then  
return "trail"  
end  
if eggOf(obj.Name) then  
if hasAny(n, BAD_NAME) then  
return nil  
end  
if obj:IsA("BasePart") and obj.Parent and eggOf(obj.Parent.Name) then  
return nil  
end  
return "egg"  
end  
if obj:IsA("Model") and (string.find(n, "boss", 1, true) or string.find(n, "kraken", 1, true)) then  
return "boss"  
end  
if string.find(n, "token", 1, true) then  
if string.find(n, "generator", 1, true) then  
return nil  
end  
if obj:IsA("BasePart") and obj.Parent and string.find(string.lower(obj.Parent.Name), "token", 1, true) then  
return nil  
end  
return "token"  
end  
if string.find(n, "pumpkin", 1, true) then  
if string.find(n, "citadel", 1, true) then  
return nil  
end  
if obj:IsA("BasePart") and obj.Parent and string.find(string.lower(obj.Parent.Name), "pumpkin", 1, true) then  
return nil  
end  
return "pumpkin"  
end  
return nil  
end

local function track(obj)  
local k = kindOf(obj)  
if k then  
idx[k][obj] = true  
end  
end

local function untrack(obj)  
for _, set in pairs(idx) do  
set[obj] = nil  
end  
dropVisual(obj)  
end

for _, d in ipairs(workspace:GetDescendants()) do  
track(d)  
end  
workspace.DescendantAdded:Connect(track)  
workspace.DescendantRemoving:Connect(untrack)

local function nearestPrompt(pos, pred)  
local best, bestD  
for p in pairs(idx.prompt) do  
if p:IsDescendantOf(workspace) and (not pred or pred(p)) then  
local pp = promptPos(p)  
if pp then  
local d = (pp - pos).Magnitude  
if not bestD or d < bestD then  
best, bestD = p, d  
end  
end  
end  
end  
return best, bestD  
end

local function machinePositions()  
if os.clock() - machAt < 1 then  
return machCache  
end  
machAt = os.clock()  
machCache = {}  
for p in pairs(idx.prompt) do  
if p:IsDescendantOf(workspace) and hasAny(textOf(p), MACHINE_WORDS) then  
local pp = promptPos(p)  
if pp then  
table.insert(machCache, pp)  
end  
end  
end  
return machCache  
end

local function nearMachine(pos)  
for _, mp in ipairs(machinePositions()) do  
if (mp - pos).Magnitude <= CFG.MachineClear then  
return true  
end  
end  
return false  
end

local function eggPromptOf(model)  
local own = model:FindFirstChildWhichIsA("ProximityPrompt", true)  
if own and not hasAny(textOf(own), BAD_PROMPT) then  
return own  
end  
local part = partOf(model)  
if not part then  
return nil  
end  
local best, bestD  
for p in pairs(idx.prompt) do  
if p:IsDescendantOf(workspace) and not hasAny(textOf(p), BAD_PROMPT) and not hasAny(chainOf(p), BAD_CHAIN) then  
local pp = promptPos(p)  
if pp then  
local d = (pp - part.Position).Magnitude  
if d <= 8 and (not bestD or d < bestD) then  
best, bestD = p, d  
end  
end  
end  
end  
return best  
end

local function firePrompt(p)  
if typeof(fireproximityprompt) == "function" then  
local dist, hold = p.MaxActivationDistance, p.HoldDuration  
pcall(function()  
p.MaxActivationDistance = FAR  
p.HoldDuration = 0  
end)  
pcall(fireproximityprompt, p)  
pcall(function()  
p.MaxActivationDistance = dist  
p.HoldDuration = hold  
end)  
return  
end  
pcall(function()  
p:InputHoldBegin()  
task.wait(p.HoldDuration + 0.05)  
p:InputHoldEnd()  
end)  
end

local function touchPart(part)  
local root = getRoot()  
if root and part and typeof(firetouchinterest) == "function" then  
pcall(firetouchinterest, root, part, 0)  
task.wait(0.05)  
pcall(firetouchinterest, root, part, 1)  
end  
end

local function waitFor(pred, secs)  
local deadline = os.clock() + secs  
repeat  
if pred() then  
return true  
end  
task.wait(0.05)  
until os.clock() >= deadline  
return pred() and true or false  
end

local function eggsIn(c, out)  
if c then  
for _, x in ipairs(c:GetChildren()) do  
if (x:IsA("Tool") or x:IsA("Model")) and eggOf(x.Name) and not hasAny(string.lower(x.Name), BAD_NAME) then  
table.insert(out, x.Name)  
end  
end  
end  
return out  
end

local function handEggs()  
return eggsIn(player.Character, {})  
end

local function bagEggs()  
return eggsIn(player:FindFirstChildOfClass("Backpack"), {})  
end

local function totalEggs()  
return #handEggs() + #bagEggs()  
end

local function safePos()  
if CFG.SafeTrail then  
for t in pairs(idx.trail) do  
if t:IsDescendantOf(workspace) then  
local cf, size  
if t:IsA("Model") then  
cf, size = t:GetBoundingBox(), t:GetExtentsSize()  
else  
cf, size = t.CFrame, t.Size  
end  
local side = cf.Position + cf.RightVector * (size.X / 2 + CFG.SafeSide)  
local params = RaycastParams.new()  
params.FilterType = Enum.RaycastFilterType.Exclude  
params.FilterDescendantsInstances = {t}  
local hit = workspace:Raycast(Vector3.new(side.X, side.Y + 40, side.Z), Vector3.new(0, -160, 0), params)  
return hit and hit.Position or side  
end  
end  
end  
return zone  
end

local function backToSafe()  
local p = safePos()  
local r = getRoot()  
if p and r and (r.Position - p).Magnitude > CFG.ReturnRadius then  
tpTo(p)  
end  
end

local function livingBossPositions()  
local out = {}  
for m in pairs(idx.boss) do  
local hum = m:FindFirstChildOfClass("Humanoid")  
local part = m:FindFirstChild("HumanoidRootPart") or partOf(m)  
if part and m:IsDescendantOf(workspace) and (not hum or hum.Health > 0) then  
table.insert(out, part.Position)  
end  
end  
return out  
end

local function nearBoss(pos, list)  
for _, bp in ipairs(list) do  
if (bp - pos).Magnitude <= CFG.BossAvoid then  
return true  
end  
end  
return false  
end

local function bossNear(pos, range)  
for _, bp in ipairs(livingBossPositions()) do  
if (bp - pos).Magnitude <= range then  
return true  
end  
end  
return false  
end

local function pickEgg()  
local r = getRoot()  
if not r then  
return nil  
end  
local now = os.clock()  
local bosses = livingBossPositions()  
local best  
for obj in pairs(idx.egg) do  
if obj:IsDescendantOf(workspace) and not (player.Character and obj:IsDescendantOf(player.Character)) and (ignored[obj] or 0) < now then  
local info = eggOf(obj.Name)  
local part = partOf(obj)  
if info and part and selOn(eggSel, info.key) and info.rank >= CFG.MinRank  
and not hasAny(chainOf(obj), BAD_ANCESTOR)  
and not nearMachine(part.Position)  
and not nearBoss(part.Position, bosses) then  
local cand = {model = obj, part = part, info = info, dist = (part.Position - r.Position).Magnitude}  
if not best then  
best = cand  
elseif CFG.RarityFirst then  
if cand.info.rank > best.info.rank or (cand.info.rank == best.info.rank and cand.dist < best.dist) then  
best = cand  
end  
elseif cand.dist < best.dist then  
best = cand  
end  
end  
end  
end  
return best  
end

local function steal(e)  
local before = totalEggs()  
for _ = 1, 2 do  
if not CFG.AutoSteal or not e.model:IsDescendantOf(workspace) then  
break  
end  
streamAround(e.part.Position)  
tpTo(e.part.Position)  
task.wait(0.15)  
local p  
local t0 = os.clock()  
repeat  
p = eggPromptOf(e.model)  
if p and p.Enabled then  
break  
end  
task.wait(0.1)  
until os.clock() - t0 > 1.5  
if p then  
firePrompt(p)  
end  
touchPart(e.part)  
if waitFor(function()  
return not e.model:IsDescendantOf(workspace) or totalEggs() > before  
end, CFG.StealWait) then  
backToSafe()  
return true  
end  
task.wait(0.2)  
end  
backToSafe()  
return false  
end

local function findPromptNearest(words)  
local r = getRoot()  
if not r then  
return nil  
end  
local now = os.clock()  
return (nearestPrompt(r.Position, function(p)  
return hasAny(textOf(p), words) and (cooldown[p] or 0) < now  
end))  
end

local function ensurePrompt(words)  
local p = findPromptNearest(words)  
if not p then  
local r = getRoot()  
streamAround(zone or (r and r.Position))  
waitFor(function()  
p = findPromptNearest(words)  
return p ~= nil  
end, 1.5)  
end  
return p  
end

local function useMachine(p)  
local pos = promptPos(p)  
if pos then  
streamAround(pos)  
tpTo(pos)  
end  
task.wait(0.1)  
firePrompt(p)  
task.wait(0.15)  
end

local function putInventory()  
local p = ensurePrompt({"put to inventory"})  
if not p then  
S.status = "Prompt Put To Inventory tidak ketemu"  
return false  
end  
local beforeHand, beforeAll = #handEggs(), totalEggs()  
cooldown[p] = os.clock() + CFG.InvCd  
useMachine(p)  
backToSafe()  
if waitFor(function()  
return #handEggs() < beforeHand or totalEggs() < beforeAll  
end, 2) then  
S.inv += 1  
S.status = "Masuk inventory"  
return true  
end  
S.status = "Egg belum masuk inventory, dicoba lagi"  
return false  
end

local function placeEgg()  
local p = ensurePrompt({"place", "plant", "incubat"})  
if not p then  
S.status = "Mesin place tidak ketemu"  
return false  
end  
local beforeHand = #handEggs()  
cooldown[p] = os.clock() + CFG.MachineCd  
local pos = promptPos(p)  
if pos then  
streamAround(pos)  
tpTo(pos)  
end  
task.wait(0.1)  
firePrompt(p)  
local ok = waitFor(function()  
return #handEggs() < beforeHand  
end, 1.5)  
local safe = safePos()  
if CFG.PlaceReturn and safe then  
tpTo(safe)  
else  
backToSafe()  
end  
if ok then  
S.place += 1  
S.status = "Egg ditaruh ke mesin"  
return true  
end  
S.status = "Place belum berhasil, dicoba lagi"  
return false  
end

local function hatchOnce()  
local p = ensurePrompt({"hatch"})  
if not p then  
return false  
end  
cooldown[p] = os.clock() + CFG.HatchCd  
useMachine(p)  
backToSafe()  
S.hatch += 1  
S.status = "Hatch dijalankan"  
return true  
end

local function collectTarget(kind)  
local r = getRoot()  
if not r then  
return nil  
end  
local now = os.clock()  
local best, bestD  
for obj in pairs(idx[kind]) do  
if obj:IsDescendantOf(workspace) and (ignored[obj] or 0) < now and not hasAny(chainOf(obj), BAD_CHAIN) then  
local part = partOf(obj)  
if part then  
local d = (part.Position - r.Position).Magnitude  
if not bestD or d < bestD then  
best, bestD = obj, d  
end  
end  
end  
end  
return best  
end

local function collectOne(obj)  
local part = partOf(obj)  
if not part then  
return false  
end  
local p = obj:FindFirstChildWhichIsA("ProximityPrompt", true) or nearestPrompt(part.Position)  
streamAround(part.Position)  
tpTo(part.Position)  
if p and p.Enabled then  
firePrompt(p)  
end  
local stop = os.clock() + CFG.CollectStand  
repeat  
touchPart(part)  
task.wait(0.1)  
until os.clock() >= stop or not obj:IsDescendantOf(workspace)  
task.wait(0.2)  
backToSafe()  
return not obj:IsDescendantOf(workspace)  
end

local function collectTick()  
if os.clock() < nextCollect then  
return false  
end  
for _, kind in ipairs({"token", "pumpkin"}) do  
if (kind == "token" and CFG.CollectToken) or (kind == "pumpkin" and CFG.CollectPumpkin) then  
local obj = collectTarget(kind)  
if obj then  
S.status = "Ambil " .. kind  
busy = true  
local got = collectOne(obj)  
busy = false  
nextCollect = os.clock() + CFG.CollectDelay  
if got then  
S.collect += 1  
S.status = "Diambil " .. kind  
else  
ignored[obj] = os.clock() + CFG.IgnoreTime  
S.status = "Belum terambil " .. kind  
end  
return true  
end  
end  
end  
nextCollect = os.clock() + 0.5  
return false  
end

local function findBoss()  
local root = getRoot()  
if not root then  
return nil  
end  
local best, bestD  
for m in pairs(idx.boss) do  
local hum = m:FindFirstChildOfClass("Humanoid")  
local part = m:FindFirstChild("HumanoidRootPart") or partOf(m)  
if (not hum or hum.Health > 0) and part and m:IsDescendantOf(workspace) then  
local d = (part.Position - root.Position).Magnitude  
if d <= CFG.FireRange and (not bestD or d < bestD) then  
best, bestD = {model = m, part = part}, d  
end  
end  
end  
return best  
end

local function fireTool()  
local ch = player.Character  
local hum = humanoid()  
if not ch or not hum then  
return nil  
end  
local want = string.lower(CFG.FireTool or "")  
local function matches(t)  
if eggOf(t.Name) then  
return false  
end  
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

local function shootTick()  
if not CFG.AutoBoss or busy then  
return  
end  
local root = getRoot()  
if not root or os.clock() < nextFire then  
return  
end  
local boss = findBoss()  
if not boss then  
return  
end  
local tool = fireTool()  
if not tool then  
S.status = "Tool tembak tidak ketemu (isi namanya di tab Boss)"  
return  
end  
local flat = Vector3.new(boss.part.Position.X, root.Position.Y, boss.part.Position.Z)  
if (flat - root.Position).Magnitude > 0.5 then  
root.CFrame = CFrame.lookAt(root.Position, flat)  
end  
nextFire = os.clock() + CFG.FireInterval  
S.shots += 1  
S.status = "Menembak " .. boss.model.Name  
pcall(function()  
tool:Activate()  
end)  
end

local function redThreat(root)  
local ch = player.Character  
local params = OverlapParams.new()  
params.FilterType = Enum.RaycastFilterType.Exclude  
params.FilterDescendantsInstances = ch and {ch} or {}  
for _, p in ipairs(workspace:GetPartBoundsInRadius(root.Position - Vector3.new(0, 5, 0), CFG.DodgeRadius, params)) do  
local c = p.Color  
if p.Transparency < 0.8 and c.R > 0.6 and c.G < 0.35 and c.B < 0.35 and p.Size.Y <= 2 then  
return p  
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

local function dodgeTick()  
if not CFG.Dodge then  
return  
end  
local root = getRoot()  
if not root or os.clock() < nextDodge or not bossNear(root.Position, 300) then  
return  
end  
local threat = redThreat(root)  
if threat then  
nextDodge = os.clock() + CFG.DodgeCd  
S.dodge += 1  
S.status = "Hindari indikator merah"  
dodgeFrom(root, threat)  
end  
end

local function ensureInventoryStep()  
if os.clock() < nextInv then  
return  
end  
nextInv = os.clock() + CFG.InvCd  
busy = true  
local ok = putInventory()  
busy = false  
if ok then  
invFails = 0  
return  
end  
invFails += 1  
if invFails >= CFG.InvTries then  
invFails = 0  
local hum = humanoid()  
if hum then  
pcall(function()  
hum:UnequipTools()  
end)  
end  
S.status = "Egg dipindah dari tangan, coba inventory lagi"  
end  
end

local function mainTick()  
if not getRoot() then  
S.status = "Menunggu karakter"  
return  
end  
local hand = #handEggs()  
S.held = hand .. " di tangan, " .. #bagEggs() .. " di tas"

if hand > 0 then  
if CFG.AutoInv then  
ensureInventoryStep()  
return  
end  
if CFG.AutoPlace and os.clock() >= nextPlace then  
nextPlace = os.clock() + CFG.MachineCd  
busy = true  
placeEgg()  
busy = false  
return  
end  
S.status = CFG.AutoPlace and "Egg di tangan, menunggu Auto Place" or "Egg di tangan. Nyalakan Auto Inventory atau Auto Place"  
return  
end

if CFG.AutoHatch and os.clock() >= nextHatch then  
nextHatch = os.clock() + CFG.HatchCd  
busy = true  
local did = hatchOnce()  
busy = false  
if did then  
return  
end  
end  
if collectTick() then  
return  
end  
if not CFG.AutoSteal then  
S.status = "Auto steal mati (tekan F untuk nyala)"  
return  
end

local target = pickEgg()  
if not target then  
if #livingBossPositions() > 0 then  
S.status = "Boss hidup, egg dekat boss dilewati"  
else  
S.status = "Tidak ada egg yang dipilih di luar area mesin"  
end  
return  
end  
S.status = "Steal " .. target.info.name .. " (Luck " .. target.info.luck .. ")"  
busy = true  
local ok = steal(target)  
busy = false  
if ok then  
S.steal += 1  
S.status = "Dapat " .. target.info.name  
else  
ignored[target.model] = os.clock() + CFG.IgnoreTime  
S.status = "Gagal steal " .. target.info.name  
end  
end

local function isWater(pos)  
local ok, res = pcall(function()  
local region = Region3.new(pos - Vector3.new(3, 3, 3), pos + Vector3.new(3, 3, 3)):ExpandToGrid(4)  
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
return ok and res or false  
end

local function collectVisuals()  
local want = {}  
local root = getRoot()  
local ch = player.Character  
if not root then  
return want  
end  
local rp = root.Position  
local checks = 0  
local now = os.clock()  
for obj in pairs(idx.egg) do  
local info = eggOf(obj.Name)  
local part = obj:IsDescendantOf(workspace) and not (ch and obj:IsDescendantOf(ch)) and partOf(obj)  
if info and part and selOn(espSel, info.key) and not hasAny(chainOf(obj), BAD_ANCESTOR) then  
local d = math.floor((part.Position - rp).Magnitude)  
if CFG.EggESP then  
want[obj] = {part = part, text = string.format("%s | %d m", info.name, d), mode = "esp"}  
elseif CFG.XRay then  
local c = waterCache[obj]  
local inWater  
if c and now - c.at < 4 then  
inWater = c.v  
elseif checks < 30 then  
checks += 1  
inWater = isWater(part.Position)  
waterCache[obj] = {v = inWater, at = now}  
end  
if inWater then  
want[obj] = {part = part, text = "Luck " .. info.luck, mode = "xray"}  
end  
end  
end  
end  
if CFG.XRay then  
for _, kind in ipairs({"token", "pumpkin"}) do  
local label = kind == "token" and "Token" or "Pumpkin"  
for obj in pairs(idx[kind]) do  
local part = obj:IsDescendantOf(workspace) and partOf(obj)  
if part and not hasAny(chainOf(obj), BAD_CHAIN) then  
want[obj] = {part = part, text = label .. " | " .. math.floor((part.Position - rp).Magnitude) .. " m", mode = "xray"}  
end  
end  
end  
end  
return want  
end

local function makeVisual(obj, w)  
local xray = w.mode == "xray"  
local color = xray and C.Blue or C.Light  
local hl = Instance.new("Highlight")  
hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop  
hl.FillColor = color  
hl.FillTransparency = 0.6  
hl.OutlineColor = color  
hl.Parent = obj  
local bb = Instance.new("BillboardGui")  
bb.Size = UDim2.fromOffset(xray and 130 or 210, 20)  
bb.StudsOffset = Vector3.new(0, 3, 0)  
bb.AlwaysOnTop = true  
bb.Adornee = w.part  
bb.Parent = w.part  
local lb = Instance.new("TextLabel")  
lb.Size = UDim2.fromScale(1, 1)  
lb.BackgroundColor3 = xray and C.DeepBlue or C.Panel  
lb.BackgroundTransparency = 0.15  
lb.TextColor3 = C.Text  
lb.Font = Enum.Font.GothamSemibold  
lb.TextSize = 11  
lb.Parent = bb  
Instance.new("UICorner", lb).CornerRadius = UDim.new(0, 6)  
return {hl = hl, bb = bb, lb = lb, mode = w.mode}  
end

local function applyVisuals(want)  
for obj, item in pairs(visuals) do  
local w = want[obj]  
if not w or w.mode ~= item.mode or not obj:IsDescendantOf(workspace) then  
dropVisual(obj)  
end  
end  
for obj, w in pairs(want) do  
local item = visuals[obj]  
if not item then  
item = makeVisual(obj, w)  
visuals[obj] = item  
end  
item.lb.Text = w.text  
end  
end

local low = {on = false, saved = {}, queue = {}, seen = {}, quality = nil}

local function remember(obj, prop)  
local rec = low.saved[obj]  
if not rec then  
rec = {}  
low.saved[obj] = rec  
end  
if rec[prop] == nil then  
local ok, val = pcall(function()  
return obj[prop]  
end)  
if ok and val ~= nil then  
rec[prop] = val  
end  
end  
end

local function setLow(obj, prop, value)  
remember(obj, prop)  
pcall(function()  
obj[prop] = value  
end)  
end

local function lowApply(d)  
if d:IsA("Terrain") then  
return  
end  
local ok = pcall(function()  
if d:IsA("PostEffect") or LOW_OFF[d.ClassName] then  
setLow(d, "Enabled", false)  
elseif d:IsA("Atmosphere") then  
setLow(d, "Density", 0)  
setLow(d, "Haze", 0)  
setLow(d, "Glare", 0)  
elseif d:IsA("Decal") or d:IsA("Texture") then  
setLow(d, "Transparency", 1)  
elseif d:IsA("BasePart") then  
setLow(d, "CastShadow", false)  
setLow(d, "Material", Enum.Material.SmoothPlastic)  
end  
end)  
if ok then  
S.low += 1  
else  
S.lowErr += 1  
end  
end

local function lowSweep()  
for _, d in ipairs(Lighting:GetDescendants()) do  
table.insert(low.queue, d)  
end  
for _, d in ipairs(workspace:GetDescendants()) do  
table.insert(low.queue, d)  
end  
end

local function lowPump()  
local n = 0  
while #low.queue > 0 and n < 250 do  
local d = table.remove(low.queue)  
if d and d.Parent and not low.seen[d] then  
low.seen[d] = true  
lowApply(d)  
end  
n += 1  
end  
end

local function lowStopAnimations()  
for _, pl in ipairs(Players:GetPlayers()) do  
local ch = pl.Character  
local hum = ch and ch:FindFirstChildOfClass("Humanoid")  
local an = hum and hum:FindFirstChildOfClass("Animator")  
if an then  
for _, tr in ipairs(an:GetPlayingAnimationTracks()) do  
pcall(function()  
tr:Stop(0)  
end)  
end  
end  
end  
end

local function lowRestore()  
for obj, rec in pairs(low.saved) do  
for prop, val in pairs(rec) do  
pcall(function()  
obj[prop] = val  
end)  
end  
end  
low.saved, low.queue, low.seen = {}, {}, {}  
pcall(function()  
settings().Rendering.QualityLevel = low.quality or Enum.QualityLevel.Automatic  
end)  
low.quality = nil  
S.low, S.lowErr = 0, 0  
end

local function lowSet(on)  
low.on = on  
if on then  
if low.quality == nil then  
pcall(function()  
low.quality = settings().Rendering.QualityLevel  
end)  
end  
pcall(function()  
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01  
end)  
setLow(Lighting, "GlobalShadows", false)  
setLow(Lighting, "EnvironmentDiffuseScale", 0)  
setLow(Lighting, "EnvironmentSpecularScale", 0)  
setLow(workspace.Terrain, "Decoration", false)  
setLow(workspace.Terrain, "WaterWaveSize", 0)  
setLow(workspace.Terrain, "WaterWaveSpeed", 0)  
setLow(workspace.Terrain, "WaterReflectance", 0)  
lowSweep()  
S.status = "Low Graphics aktif"  
else  
lowRestore()  
S.status = "Low Graphics mati, efek dikembalikan"  
end  
end

workspace.DescendantAdded:Connect(function(d)  
if low.on then  
table.insert(low.queue, d)  
end  
end)  
Lighting.DescendantAdded:Connect(function(d)  
if low.on then  
table.insert(low.queue, d)  
end  
end)

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
local data = {cfg = {}, eggs = eggSel, esp = espSel}  
for k, v in pairs(CFG) do  
local t = typeof(v)  
if t == "boolean" or t == "number" or t == "string" then  
data.cfg[k] = v  
end  
end  
return HttpService:JSONEncode(data)  
end

local function applySettings(raw)  
local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)  
if not ok or type(data) ~= "table" or type(data.cfg) ~= "table" then  
return false  
end  
for k, v in pairs(data.cfg) do  
if CFG[k] ~= nil and typeof(CFG[k]) == typeof(v) then  
CFG[k] = v  
end  
end  
for k, v in pairs(data.eggs or {}) do  
if EGG[k] and type(v) == "boolean" then  
eggSel[k] = v  
end  
end  
for k, v in pairs(data.esp or {}) do  
if EGG[k] and type(v) == "boolean" then  
espSel[k] = v  
end  
end  
return true  
end

local function saveConfig(force)  
if typeof(writefile) ~= "function" then  
S.config = "writefile tidak ada"  
return  
end  
local json = buildData()  
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
S.config = applySettings(raw) and "dimuat" or "config rusak"  
end

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
make("UICorner", {CornerRadius = UDim.new(0, r or 8)}, o)  
end

local function btn(parent, text, color, h)  
local b = make("TextButton", {  
Size = UDim2.new(1, 0, 0, h or 30), BackgroundColor3 = color, BorderSizePixel = 0, Text = text,  
TextColor3 = C.Text, Font = Enum.Font.GothamSemibold, TextSize = 12,  
TextTruncate = Enum.TextTruncate.AtEnd, AutoButtonColor = false,  
}, parent)  
corner(b, 8)  
return b  
end

local function section(page, text)  
make("TextLabel", {  
Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = string.upper(text),  
TextColor3 = C.Accent, Font = Enum.Font.GothamBold, TextSize = 11,  
TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrder(),  
}, page)  
end

local function note(page, text)  
make("TextLabel", {  
Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,  
TextWrapped = true, Text = text, TextColor3 = C.Muted, Font = Enum.Font.Gotham, TextSize = 11,  
TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,  
LayoutOrder = nextOrder(),  
}, page)  
end

local function switch(page, label, key, onChange)  
local row = make("TextButton", {  
Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = C.Card, BorderSizePixel = 0,  
AutoButtonColor = false, Text = "", LayoutOrder = nextOrder(),  
}, page)  
corner(row, 8)  
make("TextLabel", {  
Size = UDim2.new(1, -70, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1,  
Text = label, TextColor3 = C.Text, Font = Enum.Font.GothamSemibold, TextSize = 12,  
TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,  
}, row)  
local track = make("Frame", {  
Size = UDim2.fromOffset(40, 20), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),  
BackgroundColor3 = C.Dark, BorderSizePixel = 0,  
}, row)  
corner(track, 10)  
local knob = make("Frame", {  
Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(2, 2),  
BackgroundColor3 = C.Text, BorderSizePixel = 0,  
}, track)  
corner(knob, 8)  
table.insert(paints, function()  
local on = CFG[key] == true  
track.BackgroundColor3 = on and C.Accent or C.Dark  
knob.Position = on and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2)  
end)  
row.MouseButton1Click:Connect(function()  
CFG[key] = not CFG[key]  
if onChange then  
onChange(CFG[key])  
end  
refresh()  
end)  
end

local function stepper(page, label, key, step, lo, hi)  
local r = make("Frame", {  
Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = C.Card, BorderSizePixel = 0, LayoutOrder = nextOrder(),  
}, page)  
corner(r, 8)  
make("TextLabel", {  
Size = UDim2.new(1, -140, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1,  
Text = label, TextColor3 = C.Muted, Font = Enum.Font.GothamSemibold, TextSize = 12,  
TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,  
}, r)  
local value = make("TextLabel", {  
Size = UDim2.fromOffset(44, 34), Position = UDim2.new(1, -98, 0, 0), BackgroundTransparency = 1,  
TextColor3 = C.Text, Font = Enum.Font.GothamBold, TextSize = 13,  
}, r)  
local minus = btn(r, "-", C.Row, 24)  
minus.Size = UDim2.fromOffset(26, 24)  
minus.Position = UDim2.new(1, -48, 0.5, -12)  
local plus = btn(r, "+", C.Row, 24)  
plus.Size = UDim2.fromOffset(26, 24)  
plus.Position = UDim2.new(1, -18, 0.5, -12)  
minus.MouseButton1Click:Connect(function()  
CFG[key] = math.clamp(math.floor((CFG[key] - step) / step + 0.5) * step, lo, hi)  
refresh()  
end)  
plus.MouseButton1Click:Connect(function()  
CFG[key] = math.clamp(math.floor((CFG[key] + step) / step + 0.5) * step, lo, hi)  
refresh()  
end)  
table.insert(paints, function()  
value.Text = string.format("%g", CFG[key])  
end)  
end

local function eggRow(page, sel, e)  
local key = string.lower(e[1])  
local b = btn(page, "", C.Row, 28)  
b.LayoutOrder = nextOrder()  
b.Font = Enum.Font.Gotham  
b.TextSize = 11  
b.TextXAlignment = Enum.TextXAlignment.Left  
make("UIPadding", {PaddingLeft = UDim.new(0, 10)}, b)  
table.insert(paints, function()  
local on = selOn(sel, key)  
b.Text = (on and "[x]  " or "[ ]  ") .. e[1] .. "   |   Luck " .. e[2]  
b.BackgroundColor3 = on and C.Light or C.Row  
b.TextColor3 = on and C.Ink or C.Muted  
end)  
b.MouseButton1Click:Connect(function()  
sel[key] = not selOn(sel, key)  
refresh()  
end)  
end

local function eggList(page, sel, withMin)  
local r = make("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = nextOrder()}, page)  
local all = btn(r, "Pilih semua", C.Dark, 30)  
all.Size = UDim2.new(withMin and 0.34 or 0.5, -4, 1, 0)  
all.MouseButton1Click:Connect(function()  
for _, e in ipairs(EGG_LIST) do  
sel[string.lower(e[1])] = true  
end  
refresh()  
end)  
local none = btn(r, "Kosongkan", C.Dark, 30)  
none.Size = UDim2.new(withMin and 0.33 or 0.5, -4, 1, 0)  
none.Position = UDim2.new(withMin and 0.34 or 0.5, 4, 0, 0)  
none.MouseButton1Click:Connect(function()  
for _, e in ipairs(EGG_LIST) do  
sel[string.lower(e[1])] = false  
end  
refresh()  
end)  
if withMin then  
local minB = btn(r, "", C.Dark, 30)  
minB.Size = UDim2.new(0.33, -4, 1, 0)  
minB.Position = UDim2.new(0.67, 4, 0, 0)  
minB.MouseButton1Click:Connect(function()  
minIdx = minIdx % #MIN_STEPS + 1  
CFG.MinRank = MIN_STEPS[minIdx][2]  
refresh()  
end)  
table.insert(paints, function()  
minB.Text = "Min: " .. MIN_STEPS[minIdx][1]  
end)  
end  
for _, e in ipairs(EGG_LIST) do  
eggRow(page, sel, e)  
end  
end

local function viewportSize()  
local cam = workspace.CurrentCamera  
local v = cam and cam.ViewportSize or Vector2.new(900, 600)  
if v.X < 1 or v.Y < 1 then  
v = Vector2.new(900, 600)  
end  
return v  
end

local function applyLayout()  
local main = uiRefs.main  
if not main then  
return  
end  
local v = viewportSize()  
local s = math.clamp(math.min((v.X - 20) / PANEL_W, (v.Y - 20) / PANEL_H, 1), 0.45, 1)  
uiRefs.scale.Scale = s  
local w, h = PANEL_W * s, PANEL_H * s  
if not layout.ready then  
layout.main = Vector2.new(v.X / 2, v.Y / 2)  
layout.logo = Vector2.new(v.X - 36, v.Y / 2)  
layout.ready = true  
end  
local mx = math.max(w / 2, math.min(v.X - w / 2, layout.main.X))  
local my = math.max(h / 2, math.min(v.Y - h / 2, layout.main.Y))  
layout.main = Vector2.new(mx, my)  
main.Position = UDim2.fromOffset(mx, my)  
if uiRefs.logo then  
local lx = math.max(26, math.min(v.X - 26, layout.logo.X))  
local ly = math.max(26, math.min(v.Y - 26, layout.logo.Y))  
layout.logo = Vector2.new(lx, ly)  
uiRefs.logo.Position = UDim2.fromOffset(lx, ly)  
end  
end

local function drag(handle, getPos, setPos, onTap)  
local dragging, moved = false, false  
local start, origin  
handle.InputBegan:Connect(function(input)  
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
dragging, moved = true, false  
start = input.Position  
origin = getPos()  
end  
end)  
handle.InputEnded:Connect(function(input)  
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
if dragging and not moved and onTap then  
onTap()  
end  
dragging = false  
end  
end)  
UIS.InputChanged:Connect(function(input)  
if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then  
local d = input.Position - start  
if d.Magnitude > 5 then  
moved = true  
end  
if moved then  
setPos(origin.X + d.X, origin.Y + d.Y)  
end  
end  
end)  
end

local function copyLink(url)  
return pcall(function()  
assert(type(setclipboard) == "function", "Clipboard tidak didukung")  
setclipboard(url)  
end)  
end

local function buildUI()  
local host = player:WaitForChild("PlayerGui")  
local okH, hui = pcall(gethui)  
if okH and typeof(hui) == "Instance" then  
host = hui  
end  
local old = host:FindFirstChild("kayeshiHUB")  
if old then  
old:Destroy()  
end

local gui = make("ScreenGui", {Name = "kayeshiHUB", ResetOnSpawn = false, DisplayOrder = 999, IgnoreGuiInset = true}, host)

local main = make("Frame", {  
AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(PANEL_W, PANEL_H),  
BackgroundColor3 = C.Panel, BorderSizePixel = 0,  
}, gui)  
corner(main, 14)  
make("UIStroke", {Color = C.Dark, Thickness = 1}, main)  
uiRefs.main = main  
uiRefs.scale = make("UIScale", {Scale = 1}, main)

local header = make("Frame", {Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = C.Side, BorderSizePixel = 0}, main)  
corner(header, 14)  
make("TextLabel", {  
Size = UDim2.new(0, 200, 0, 20), Position = UDim2.fromOffset(16, 7), BackgroundTransparency = 1,  
Text = "kayeshiHUB", TextColor3 = C.Text, Font = Enum.Font.GothamBold, TextSize = 16,  
TextXAlignment = Enum.TextXAlignment.Left,  
}, header)  
local subtitle = make("TextLabel", {  
Size = UDim2.new(1, -110, 0, 14), Position = UDim2.fromOffset(16, 26), BackgroundTransparency = 1,  
TextColor3 = C.Muted, Font = Enum.Font.Gotham, TextSize = 10,  
TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,  
}, header)  
local minBtn = btn(header, "Sembunyi", C.Dark, 26)  
minBtn.Size = UDim2.fromOffset(84, 26)  
minBtn.Position = UDim2.new(1, -94, 0, 9)  
minBtn.TextSize = 11

local side = make("Frame", {  
Position = UDim2.fromOffset(10, 52), Size = UDim2.new(0, 126, 1, -110),  
BackgroundColor3 = C.Side, BorderSizePixel = 0,  
}, main)  
corner(side, 10)  
make("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)}, side)  
make("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, side)

local content = make("Frame", {  
Position = UDim2.fromOffset(144, 52), Size = UDim2.new(1, -154, 1, -110),  
BackgroundColor3 = C.Side, BorderSizePixel = 0,  
}, main)  
corner(content, 10)

local footer = make("Frame", {  
Position = UDim2.new(0, 10, 1, -50), Size = UDim2.new(1, -20, 0, 40),  
BackgroundColor3 = C.Side, BorderSizePixel = 0,  
}, main)  
corner(footer, 10)  
local statusLbl = make("TextLabel", {  
Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1,  
TextColor3 = C.Muted, Font = Enum.Font.Gotham, TextSize = 11,  
TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,  
}, footer)

local TABS = {  
{"main", "Utama"}, {"egg", "Filter Egg"}, {"auto", "Auto"}, {"collect", "Token & Pumpkin"},  
{"boss", "Boss"}, {"esp", "ESP & X-Ray"}, {"grafik", "Grafik"}, {"discord", "Komunitas"},  
}  
local pages, tabs = {}, {}  
for i, t in ipairs(TABS) do  
local page = make("ScrollingFrame", {  
Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 1, -16), BackgroundTransparency = 1,  
BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = C.Muted,  
CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,  
}, content)  
make("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, page)  
make("UIPadding", {PaddingRight = UDim.new(0, 8)}, page)  
pages[t[1]] = page  
local b = btn(side, t[2], C.Card, 28)  
b.LayoutOrder = i  
b.TextSize = 11  
tabs[t[1]] = b  
end

local mp, ep, ap, cp, bp, esp, gp, dp = pages.main, pages.egg, pages.auto, pages.collect, pages.boss, pages.esp, pages.grafik, pages.discord

section(mp, "Auto steal")  
note(mp, "Steal egg terpilih di seluruh map, kecuali egg di sekitar mesin place, incubat, hatch, dan inventory. Tekan F untuk nyala atau mati.")  
switch(mp, "Auto Steal", "AutoSteal")  
switch(mp, "Rarity tertinggi dulu (mati = terdekat dulu)", "RarityFirst")  
stepper(mp, "Tunggu prompt (detik)", "StealWait", 0.1, 0.5, 3)  
stepper(mp, "Jarak aman dari mesin (studs)", "MachineClear", 5, 5, 80)  
stepper(mp, "Jarak aman dari boss (studs)", "BossAvoid", 5, 0, 100)

section(mp, "Safe zone")  
local zr = make("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = nextOrder()}, mp)  
local zoneBtn = btn(zr, "Set safe zone di sini", C.Dark, 30)  
zoneBtn.Size = UDim2.new(0.5, -4, 1, 0)  
local tpBtn = btn(zr, "Teleport ke safe zone", C.Dark, 30)  
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
local p = safePos()  
if p then  
tpTo(p)  
S.status = "Teleport ke safe zone"  
else  
S.status = "Safe zone belum di-set"  
end  
refresh()  
end)  
switch(mp, "Pakai safe zone dekat Trail Shop", "SafeTrail")

section(mp, "Anti AFK dan gerak")  
switch(mp, "Anti AFK", "AntiAFK", function()  
lastActive = os.clock()  
end)  
stepper(mp, "Lompat setelah diam (detik)", "AfkIdle", 30, 60, 900)  
switch(mp, "WalkSpeed", "Walk", function(on)  
local hum = humanoid()  
if hum and not on then  
hum.WalkSpeed = baseWalk  
end  
end)  
stepper(mp, "Kecepatan jalan", "WalkSpeed", 5, 16, 250)  
switch(mp, "JumpPower", "Jump", function(on)  
local hum = humanoid()  
if hum and not on then  
hum.JumpPower = baseJump  
end  
end)  
stepper(mp, "Kekuatan lompat", "JumpPower", 10, 50, 300)

section(mp, "Config")  
switch(mp, "Simpan config otomatis", "AutoSave")  
local cr = make("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = nextOrder()}, mp)  
local saveBtn = btn(cr, "Simpan sekarang", C.Dark, 30)  
saveBtn.Size = UDim2.new(0.5, -4, 1, 0)  
local loadBtn = btn(cr, "Muat config", C.Dark, 30)  
loadBtn.Size = UDim2.new(0.5, -4, 1, 0)  
loadBtn.Position = UDim2.new(0.5, 4, 0, 0)  
saveBtn.MouseButton1Click:Connect(function()  
saveConfig(true)  
refresh()  
end)  
loadBtn.MouseButton1Click:Connect(function()  
loadConfig()  
refresh()  
end)  
local resetBtn = btn(mp, "Reset semua settingan ke default", C.Dark, 30)  
resetBtn.LayoutOrder = nextOrder()  
resetBtn.MouseButton1Click:Connect(function()  
for k, v in pairs(DEFAULT) do  
CFG[k] = v  
end  
for _, e in ipairs(EGG_LIST) do  
local key = string.lower(e[1])  
eggSel[key] = true  
espSel[key] = true  
end  
minIdx = 1  
clearVisuals()  
lowSet(false)  
saveConfig(true)  
S.status = "Settingan dikembalikan ke default"  
refresh()  
end)

section(ep, "Filter egg untuk steal")  
note(ep, "Egg yang tidak dicentang tidak akan di-steal, di-place, atau di-hatch.")  
eggList(ep, eggSel, true)

section(ap, "Auto Inventory")  
note(ap, "Saat egg di tangan, script menekan Put To Inventory di seluruh map lalu menunggu egg masuk. Egg di tas tidak menghentikan steal.")  
switch(ap, "Auto Inventory", "AutoInv")  
stepper(ap, "Cooldown inventory (detik)", "InvCd", 0.5, 0.5, 10)  
stepper(ap, "Gagal berapa kali sebelum pindah", "InvTries", 1, 1, 10)  
section(ap, "Auto Place")  
note(ap, "Dipakai jika Auto Inventory mati. Saat memegang egg, teleport ke mesin place lalu tekan prompt.")  
switch(ap, "Auto Place", "AutoPlace")  
switch(ap, "Balik ke safe zone setelah place", "PlaceReturn")  
stepper(ap, "Cooldown place (detik)", "MachineCd", 0.5, 0.5, 10)  
section(ap, "Auto Hatch")  
note(ap, "Saat tidak memegang egg, teleport ke mesin hatch lalu tekan prompt.")  
switch(ap, "Auto Hatch", "AutoHatch")  
stepper(ap, "Cooldown hatch (detik)", "HatchCd", 0.5, 0.5, 30)

section(cp, "Collect Token")  
note(cp, "Teleport ke objek bernama token, di seluruh map. Token generator diabaikan.")  
switch(cp, "Collect Token", "CollectToken")  
section(cp, "Collect Pumpkin")  
note(cp, "Teleport ke objek bernama pumpkin, di seluruh map. Ember Pumpkin Citadel dan area event diabaikan.")  
switch(cp, "Collect Pumpkin", "CollectPumpkin")  
section(cp, "Jeda ambil")  
note(cp, "Token dan pumpkin punya jeda sendiri dan tidak menghalangi steal egg.")  
stepper(cp, "Jeda antar ambil (detik)", "CollectDelay", 0.5, 0, 10)  
stepper(cp, "Diam di objek (detik)", "CollectStand", 0.5, 0.5, 5)

section(bp, "Auto Boss")  
note(bp, "Menembak boss (nama mengandung boss atau kraken). Steal egg tetap jalan, dan egg dekat boss dilewati.")  
switch(bp, "Auto tembak boss", "AutoBoss")  
switch(bp, "Hindari indikator merah", "Dodge")  
stepper(bp, "Jarak tembak (studs)", "FireRange", 10, 20, 400)  
stepper(bp, "Jarak hindar (studs)", "DodgeStep", 2, 4, 40)  
local toolRow = make("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = C.Card, BorderSizePixel = 0, LayoutOrder = nextOrder()}, bp)  
corner(toolRow, 8)  
local toolBox = make("TextBox", {  
Size = UDim2.new(1, -20, 0, 26), Position = UDim2.fromOffset(10, 4), BackgroundColor3 = C.Row, BorderSizePixel = 0,  
Text = CFG.FireTool, PlaceholderText = "Nama tool tembak (kosong = tool apa saja)", PlaceholderColor3 = C.Muted,  
TextColor3 = C.Text, Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false,  
TextXAlignment = Enum.TextXAlignment.Left,  
}, toolRow)  
corner(toolBox, 6)  
make("UIPadding", {PaddingLeft = UDim.new(0, 8)}, toolBox)  
toolBox.FocusLost:Connect(function()  
CFG.FireTool = toolBox.Text  
refresh()  
end)

section(esp, "Egg ESP")  
note(esp, "Menandai egg yang dicentang dengan nama dan jarak, di seluruh map.")  
switch(esp, "Egg ESP (nama dan jarak)", "EggESP")  
section(esp, "X-Ray")  
note(esp, "Hanya menampilkan luck egg yang ada di air, plus token dan pumpkin, di seluruh map.")  
switch(esp, "X-Ray (luck egg di air, token, pumpkin)", "XRay")  
section(esp, "Filter ESP")  
eggList(esp, espSel, false)

section(gp, "Low Graphics")  
note(gp, "Mematikan efek post-process, atmosfer, partikel, trail, beam, cahaya, decal, bayangan, pantulan air, dan refleksi lingkungan. Animasi pemain lain dihentikan. Semua nilai asli dikembalikan saat dimatikan.")  
switch(gp, "Low Graphics", "LowGraphics", function(on)  
lowSet(on)  
end)  
local reapply = btn(gp, "Terapkan ulang ke objek baru", C.Dark, 30)  
reapply.LayoutOrder = nextOrder()  
reapply.MouseButton1Click:Connect(function()  
if low.on then  
low.seen = {}  
lowSweep()  
S.status = "Low Graphics diterapkan ulang"  
end  
refresh()  
end)  
local lowInfo = make("TextLabel", {  
Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,  
TextColor3 = C.Muted, Font = Enum.Font.Gotham, TextSize = 11,  
TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrder(),  
}, gp)  
table.insert(paints, function()  
lowInfo.Text = string.format("Objek diproses: %d  |  Error: %d  |  Antrian: %d", S.low, S.lowErr, #low.queue)  
end)

section(dp, "Discord")  
note(dp, "Info, update script, dan saran fitur ada di komunitas kayeshiHUB.")  
local discordCopy = btn(dp, "Salin link Discord", C.Accent, 34)  
discordCopy.LayoutOrder = nextOrder()  
discordCopy.MouseButton1Click:Connect(function()  
local ok = copyLink(DISCORD)  
notify(ok and "Link Discord disalin" or DISCORD)  
end)  
note(dp, DISCORD)  
section(dp, "WhatsApp")  
note(dp, "Saluran WhatsApp kayeshiHUB untuk update dan info terbaru.")  
local waCopy = btn(dp, "Salin link saluran WhatsApp", C.Accent, 34)  
waCopy.LayoutOrder = nextOrder()  
waCopy.MouseButton1Click:Connect(function()  
local ok = copyLink(WHATSAPP)  
notify(ok and "Link saluran WhatsApp disalin" or WHATSAPP)  
end)  
note(dp, WHATSAPP)

table.insert(paints, function()  
local n = 0  
for _ in pairs(idx.egg) do  
n += 1  
end  
subtitle.Text = string.format("Steal %d  |  Inventory %d  |  Place %d  |  Hatch %d  |  Ambil %d  |  Tembakan %d",  
S.steal, S.inv, S.place, S.hatch, S.collect, S.shots)  
statusLbl.Text = string.format("%s  |  Egg %d  |  Boss %d  |  Config %s  |  Error %d",  
S.status, n, #livingBossPositions(), S.config, S.errors)  
end)

local logo = make("TextButton", {  
AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(48, 48),  
BackgroundColor3 = C.Ink, BorderSizePixel = 0, AutoButtonColor = false, Visible = false,  
Text = "K", TextColor3 = C.Text, Font = Enum.Font.GothamBold, TextSize = 20, ZIndex = 5,  
}, gui)  
corner(logo, 24)  
make("UIStroke", {Color = C.Accent, Thickness = 2}, logo)  
uiRefs.logo = logo

local function setMenu(open)  
main.Visible = open  
logo.Visible = not open  
applyLayout()  
end  
uiRefs.setMenu = setMenu

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
minBtn.MouseButton1Click:Connect(function()  
setMenu(false)  
end)

drag(logo,  
function()  
return layout.logo  
end,  
function(x, y)  
layout.logo = Vector2.new(x, y)  
applyLayout()  
end,  
function()  
setMenu(true)  
end)  
drag(header,  
function()  
return layout.main  
end,  
function(x, y)  
layout.main = Vector2.new(x, y)  
applyLayout()  
end)

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(applyLayout)  
if workspace.CurrentCamera then  
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyLayout)  
end

setPage("main")  
refresh()  
applyLayout()  
end

for _, e in ipairs(EGG_LIST) do  
local key = string.lower(e[1])  
if eggSel[key] == nil then  
eggSel[key] = true  
end  
if espSel[key] == nil then  
espSel[key] = true  
end  
end

loadConfig()  
local okUI, errUI = pcall(buildUI)  
if not okUI then  
warn("kayeshiHUB menu: " .. tostring(errUI))  
notify("Menu gagal: " .. string.sub(tostring(errUI), 1, 150))  
end

UIS.InputBegan:Connect(function(input, gameProcessed)  
lastActive = os.clock()  
if gameProcessed then  
return  
end  
if input.KeyCode == Enum.KeyCode.F then  
CFG.AutoSteal = not CFG.AutoSteal  
S.status = CFG.AutoSteal and "Auto steal nyala" or "Auto steal mati"  
refresh()  
elseif input.KeyCode == Enum.KeyCode.K or input.KeyCode == Enum.KeyCode.RightShift then  
if uiRefs.setMenu then  
uiRefs.setMenu(not uiRefs.main.Visible)  
end  
end  
end)

if CFG.LowGraphics then  
lowSet(true)  
end

if player.Character then  
task.spawn(captureBase, player.Character)  
end  
player.CharacterAdded:Connect(captureBase)

task.spawn(function()  
local ch = player.Character or player.CharacterAdded:Wait()  
local r = ch:WaitForChild("HumanoidRootPart", 10)  
if r and not zone then  
zone = r.Position  
S.status = "Safe zone otomatis di posisi awal"  
end  
end)

player.Idled:Connect(function()  
if CFG.AntiAFK then  
antiAfkClick()  
antiAfkJump()  
end  
end)

local function loop(name, interval, fn)  
task.spawn(function()  
while true do  
local ok, err = pcall(fn)  
if not ok then  
S.errors += 1  
S.status = name .. ": " .. string.sub(tostring(err), 1, 60)  
warn("kayeshiHUB " .. name .. ": " .. tostring(err))  
task.wait(0.5)  
end  
task.wait(interval)  
end  
end)  
end

loop("utama", 0.12, mainTick)  
loop("hindar", 0.1, dodgeTick)  
loop("boss", 0.15, shootTick)  
loop("visual", 0.5, function()  
if CFG.EggESP or CFG.XRay then  
applyVisuals(collectVisuals())  
elseif next(visuals) then  
clearVisuals()  
end  
end)  
loop("grafik", 0.05, function()  
if low.on then  
lowPump()  
end  
end)  
loop("animasi", 1, function()  
if low.on then  
lowStopAnimations()  
end  
end)  
loop("stream", 4, function()  
local r = getRoot()  
if r then  
streamAround(r.Position)  
end  
end)  
loop("gerak", 0.25, applyMove)  
loop("afk", 1, function()  
if CFG.AntiAFK and os.clock() - lastActive >= CFG.AfkIdle then  
lastActive = os.clock()  
antiAfkJump()  
S.status = "Anti AFK: lompat setelah diam"  
end  
end)  
loop("autosave", 3, function()  
if CFG.AutoSave then  
saveConfig(false)  
end  
end)  
loop("ui", 0.4, refresh)

notify("kayeshiHUB aktif. K = menu, F = auto steal.")  
