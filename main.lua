local Players = game:GetService("Players")  
local UIS = game:GetService("UserInputService")  
local StarterGui = game:GetService("StarterGui")  
local RunService = game:GetService("RunService")  
local VirtualUser = game:GetService("VirtualUser")  
local HttpService = game:GetService("HttpService")  
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer  
local DISCORD_LINK = "https://discord.gg/tfXf5W6WCw"  
local CONFIG_FILE = "kayeshiHUB_config.json"  
local SETTING_PREFIX = "kayeshi:"  
local MAIN_W, MAIN_H = 600, 430  
local FAR = 1e6  
local HUGE = math.huge

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
	Dark = Color3.fromRGB(56, 56, 68),  
	Light = Color3.fromRGB(238, 238, 244),  
	Accent = Color3.fromRGB(99, 110, 255),  
	Text = Color3.fromRGB(245, 245, 248),  
	Ink = Color3.fromRGB(16, 16, 20),  
	Muted = Color3.fromRGB(154, 154, 168),  
}

local EGG_LIST = {  
	{"Common Egg", "1"}, {"Coral Egg", "20"}, {"Reef Egg", "400"}, {"Tidal Egg", "8K"}, {"Deep Egg", "160K"},  
	{"Abyss Egg", "3M"}, {"Trench Egg", "60M"}, {"Sovereign Egg", "1B"}, {"Celestial Egg", "20B"},  
	{"Kraken Glory Egg", "24B–140B"}, {"Eternal Egg", "70B"}, {"Admin Abuse Seraph Egg", "80B–2T"},  
	{"Coral Reef Egg", "90B"}, {"Glacial Spiral Egg", "115B"}, {"KingKalolo Egg", "130B–400B"},  
	{"Amethyst Spiral Egg", "140B"}, {"Azure Crown Egg", "170B"}, {"Solar Orbit Egg", "200B"},  
	{"Spikey Egg", "250B"}, {"Mamba Egg", "300B"}, {"Inferno Egg", "350B"}, {"Golem Egg", "500B–1T"},  
	{"Astral Vortex", "5T"},  
}

local EGG, EGG_KEYS = {}, {}  
for i, e in ipairs(EGG_LIST) do  
	local key = string.lower(e[1])  
	EGG[key] = {name = e[1], luck = e[2], rank = i, key = key}  
	table.insert(EGG_KEYS, key)  
end  
table.sort(EGG_KEYS, function(a, b)  
	return #a > #b  
end)

local MIN_STEPS = {  
	{"Semua", 0},  
	{"Sovereign+", "Sovereign Egg"},  
	{"Celestial+", "Celestial Egg"},  
	{"Kraken+", "Kraken Glory Egg"},  
	{"Golem+", "Golem Egg"},  
}  
for _, st in ipairs(MIN_STEPS) do  
	if type(st[2]) == "string" then  
		st[2] = EGG[string.lower(st[2])].rank  
	end  
end

local BAD_NAME = {"hatch", "place", "plant", "incubat", "inventor", "shop", "machine", "npc", "sell", "buy", "tukar"}  
local BAD_ANCESTOR = {"hatch", "place", "plant", "incubat", "machine", "shop", "npc", "display", "showcase", "inventory", "mudagen", "mudargen", "reward"}  
local BAD_PROMPT = {"inventory", "place", "plant", "incubat", "hatch", "shop", "buy", "sell", "tukar"}  
local BAD_CHAIN = {"generator", "shop", "npc", "citadel", "merchant", "tukar", "swap", "event", "halloween"}  
local MACHINE_WORDS = {"place", "plant", "incubat", "hatch", "inventory"}  
local LOW_CLASSES = {  
	ParticleEmitter = true, Trail = true, Beam = true, Smoke = true, Fire = true, Sparkles = true,  
	PointLight = true, SpotLight = true, SurfaceLight = true, Clouds = true,  
}

local CFG = {  
	AutoSteal = true, RarityFirst = true, MinRank = 0, StealWait = 1.2, IgnoreTime = 6,  
	ReturnRadius = 6, MachineClear = 25, ShopZone = true, ShopSide = 4,  
	AutoInv = true, InvCd = 1.5, InvTries = 3,  
	AutoPlace = false, PlaceReturn = true, MachineCd = 2,  
	AutoHatch = false, HatchCd = 3,  
	CollectToken = false, CollectPumpkin = false, CollectDelay = 1.5, CollectStand = 1,  
	AutoBoss = false, Dodge = true, FireRange = 150, FireInterval = 0.15, DodgeRadius = 3,  
	DodgeStep = 14, DodgeCd = 0.5, FireTool = "",  
	EggESP = false, LowGraphics = false,  
	ShopRadar = false, ShopFeed = false, ShopCd = 12,  
	Walk = false, WalkSpeed = 16, Jump = false, JumpPower = 50,  
	AntiAFK = true, AfkIdle = 300, AutoSave = true,  
}  
local DEFAULT = {}  
for k, v in pairs(CFG) do  
	DEFAULT[k] = v  
end

local idx = {egg = {}, token = {}, pumpkin = {}, prompt = {}, trail = {}, boss = {}}  
local eggSel, espSel = {}, {}  
local espItems, ignored, cooldown = {}, {}, {}  
local S = {status = "Memuat...", steal = 0, inv = 0, place = 0, hatch = 0, collect = 0, shop = 0, dodge = 0, shots = 0, errors = 0, config = "-"}  
local zone  
local paints, uiRefs = {}, {}  
local layout = {main = Vector2.new(0, 0), logo = Vector2.new(0, 0), ready = false}  
local orderSeq = 0  
local lastActive = os.clock()  
local baseWalk, baseJump = 16, 50  
local nextInv, nextPlace, nextHatch, nextCollect, nextShop, nextDodge, nextFire = 0, 0, 0, 0, 0, 0, 0  
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
			player:RequestStreamAroundAsync(pos, 1)  
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
	if eggOf(obj.Name) and not hasAny(n, BAD_NAME) then  
		if obj:IsA("BasePart") and obj.Parent and eggOf(obj.Parent.Name) then  
			return nil  
		end  
		return "egg"  
	end  
	if string.find(n, "token", 1, true) and not string.find(n, "generator", 1, true) then  
		return "token"  
	end  
	if string.find(n, "pumpkin", 1, true) and not string.find(n, "citadel", 1, true) then  
		if obj:IsA("BasePart") and obj.Parent and string.lower(obj.Parent.Name) == "pumpkin" then  
			return nil  
		end  
		return "pumpkin"  
	end  
	if obj:IsA("Model") and string.find(n, "boss", 1, true) then  
		return "boss"  
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
	espItems[obj] = nil  
end

for _, d in ipairs(workspace:GetDescendants()) do  
	track(d)  
end  
workspace.DescendantAdded:Connect(track)  
workspace.DescendantRemoving:Connect(untrack)

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

local function nearestPrompt(pos, range, pred)  
	local best, bestD = nil, range or HUGE  
	for p in pairs(idx.prompt) do  
		if p:IsDescendantOf(workspace) and (not pred or pred(p)) then  
			local pp = promptPos(p)  
			if pp then  
				local d = (pp - pos).Magnitude  
				if d <= bestD then  
					best, bestD = p, d  
				end  
			end  
		end  
	end  
	return best, bestD  
end

local machCache, machAt = {}, 0  
local function machineSpots()  
	if os.clock() - machAt < 1 then  
		return machCache  
	end  
	machAt = os.clock()  
	machCache = {}  
	for p in pairs(idx.prompt) do  
		if p:IsDescendantOf(workspace) and hasAny(textOf(p), MACHINE_WORDS) then  
			local pos = promptPos(p)  
			if pos then  
				table.insert(machCache, pos)  
			end  
		end  
	end  
	return machCache  
end

local function nearMachine(pos)  
	for _, mp in ipairs(machineSpots()) do  
		if (mp - pos).Magnitude < CFG.MachineClear then  
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
	return (nearestPrompt(part.Position, 8, function(p)  
		return not hasAny(textOf(p), BAD_PROMPT) and not hasAny(chainOf(p), BAD_CHAIN)  
	end))  
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
		return true  
	end  
	pcall(function()  
		p:InputHoldBegin()  
		task.wait(p.HoldDuration + 0.05)  
		p:InputHoldEnd()  
	end)  
	return true  
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

local function eggCandidate(obj, r, now)  
	if not obj:IsDescendantOf(workspace) then  
		return nil  
	end  
	if player.Character and obj:IsDescendantOf(player.Character) then  
		return nil  
	end  
	if (ignored[obj] or 0) >= now then  
		return nil  
	end  
	local info = eggOf(obj.Name)  
	if not info or not selOn(eggSel, info.key) or info.rank < CFG.MinRank then  
		return nil  
	end  
	local part = partOf(obj)  
	if not part then  
		return nil  
	end  
	if hasAny(chainOf(obj), BAD_ANCESTOR) then  
		return nil  
	end  
	if nearMachine(part.Position) then  
		return nil  
	end  
	return {model = obj, part = part, info = info, dist = (part.Position - r.Position).Magnitude}  
end

local function pickEgg()  
	local r = getRoot()  
	if not r then  
		return nil  
	end  
	local now = os.clock()  
	local best  
	for obj in pairs(idx.egg) do  
		local cand = eggCandidate(obj, r, now)  
		if cand then  
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
	return best  
end

local function safePos()  
	if CFG.ShopZone then  
		for t in pairs(idx.trail) do  
			if t:IsDescendantOf(workspace) then  
				local cf, size  
				if t:IsA("Model") then  
					cf, size = t:GetBoundingBox()  
				else  
					cf, size = t.CFrame, t.Size  
				end  
				local side = cf.Position + cf.RightVector * (size.X / 2 + CFG.ShopSide)  
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

local function steal(e)  
	local before = totalEggs()  
	for attempt = 1, 3 do  
		if not CFG.AutoSteal or not e.model:IsDescendantOf(workspace) then  
			break  
		end  
		streamAround(e.part.Position)  
		tpTo(e.part.Position)  
		task.wait(0.15)  
		local p = eggPromptOf(e.model)  
		if p then  
			local t0 = os.clock()  
			while not p.Enabled and p:IsDescendantOf(workspace) and os.clock() - t0 < 1.5 do  
				task.wait(0.1)  
			end  
			firePrompt(p)  
		end  
		touchPart(e.part)  
		local got = waitFor(function()  
			return not e.model:IsDescendantOf(workspace) or totalEggs() > before  
		end, CFG.StealWait)  
		if got then  
			backToSafe()  
			return true  
		end  
		task.wait(0.2 * attempt)  
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
	return (nearestPrompt(r.Position, HUGE, function(p)  
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
		S.status = "Egg ditaruh, balik ke safe zone"  
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

local function openNpc(keys)  
	local r = getRoot()  
	if not r then  
		return false  
	end  
	local now = os.clock()  
	local p = nearestPrompt(r.Position, HUGE, function(pr)  
		return hasAny(chainOf(pr), keys) and (cooldown[pr] or 0) < now  
	end)  
	if not p then  
		S.status = "NPC shop tidak ketemu"  
		return false  
	end  
	cooldown[p] = now + 3  
	useMachine(p)  
	backToSafe()  
	S.shop += 1  
	S.status = "Buka shop NPC"  
	return true  
end

local function shopTick()  
	if not (CFG.ShopRadar or CFG.ShopFeed) or os.clock() < nextShop then  
		return false  
	end  
	nextShop = os.clock() + CFG.ShopCd  
	local keys = {}  
	if CFG.ShopRadar then  
		table.insert(keys, "mudagen")  
		table.insert(keys, "mudargen")  
	end  
	if CFG.ShopFeed then  
		table.insert(keys, "alex")  
	end  
	return openNpc(keys)  
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
	local p = obj:FindFirstChildWhichIsA("ProximityPrompt", true) or nearestPrompt(part.Position, 6)  
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
				local got = collectOne(obj)  
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
		if hum and hum.Health > 0 and part and m:IsDescendantOf(workspace) then  
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

local function bossTick()  
	local root = getRoot()  
	if not root then  
		return false  
	end  
	local now = os.clock()  
	if CFG.Dodge and now >= nextDodge then  
		local threat = redThreat(root)  
		if threat then  
			nextDodge = now + CFG.DodgeCd  
			S.dodge += 1  
			S.status = "Hindari indikator merah"  
			dodgeFrom(root, threat)  
			return true  
		end  
	end  
	if not CFG.AutoBoss then  
		return false  
	end  
	local boss = findBoss()  
	if not boss then  
		return false  
	end  
	local tool = fireTool()  
	if not tool then  
		S.status = "Tool tembak tidak ditemukan"  
		return true  
	end  
	local flat = Vector3.new(boss.part.Position.X, root.Position.Y, boss.part.Position.Z)  
	if (flat - root.Position).Magnitude > 0.5 then  
		root.CFrame = CFrame.lookAt(root.Position, flat)  
	end  
	S.status = "Menembak " .. boss.model.Name  
	if now >= nextFire then  
		nextFire = now + CFG.FireInterval  
		S.shots += 1  
		pcall(function()  
			tool:Activate()  
		end)  
	end  
	return true  
end

local function mainTick()  
	if not getRoot() then  
		S.status = "Menunggu karakter"  
		return  
	end  
	local hand, bag = #handEggs(), #bagEggs()

	if hand > 0 or bag > 0 then  
		if CFG.AutoInv and os.clock() >= nextInv then  
			nextInv = os.clock() + CFG.InvCd  
			if putInventory() then  
				invFails = 0  
				return  
			end  
			invFails += 1  
			if invFails >= CFG.InvTries and hand > 0 then  
				local hum = humanoid()  
				if hum then  
					pcall(function()  
						hum:UnequipTools()  
					end)  
				end  
				invFails = 0  
				S.status = "Egg dipindah dari tangan, coba inventory lagi"  
				return  
			end  
		end  
		if hand > 0 and CFG.AutoPlace and os.clock() >= nextPlace and (not CFG.AutoInv or invFails > 0) then  
			nextPlace = os.clock() + CFG.MachineCd  
			placeEgg()  
			return  
		end  
		if not CFG.AutoInv and not CFG.AutoPlace then  
			S.status = "Egg di tangan/tas. Nyalakan Auto Inventory atau Auto Place"  
		elseif CFG.AutoInv and invFails == 0 and os.clock() < nextInv then  
			S.status = "Egg masih dipegang, steal ditunda"  
		else  
			S.status = "Menunggu egg masuk inventory, steal ditunda"  
		end  
		return  
	end

	if CFG.AutoHatch and os.clock() >= nextHatch then  
		nextHatch = os.clock() + CFG.HatchCd  
		if hatchOnce() then  
			return  
		end  
	end  
	if collectTick() then  
		return  
	end  
	if shopTick() then  
		return  
	end  
	if not CFG.AutoSteal then  
		S.status = "Auto steal mati"  
		return  
	end

	local target = pickEgg()  
	if not target then  
		S.status = "Tidak ada egg yang lolos filter"  
		return  
	end  
	S.status = "Steal " .. target.info.name .. " (Luck " .. target.info.luck .. ")"  
	if steal(target) then  
		S.steal += 1  
		S.status = "Dapat " .. target.info.name .. ", menunggu inventory"  
	else  
		ignored[target.model] = os.clock() + CFG.IgnoreTime  
		S.status = "Gagal steal " .. target.info.name  
	end  
end

local function clearEsp()  
	for obj, item in pairs(espItems) do  
		pcall(function()  
			item.hl:Destroy()  
			item.bb:Destroy()  
		end)  
		espItems[obj] = nil  
	end  
end

local function updateEsp()  
	if not CFG.EggESP then  
		if next(espItems) then  
			clearEsp()  
		end  
		return  
	end  
	local root = getRoot()  
	local ch = player.Character  
	local keep = {}  
	for obj in pairs(idx.egg) do  
		local info = eggOf(obj.Name)  
		local part = obj:IsDescendantOf(workspace) and not (ch and obj:IsDescendantOf(ch)) and partOf(obj)  
		if info and part and selOn(espSel, info.key) then  
			keep[obj] = true  
			local item = espItems[obj]  
			if not item then  
				local hl = Instance.new("Highlight")  
				hl.FillColor = C.Light  
				hl.FillTransparency = 0.6  
				hl.OutlineColor = C.Text  
				hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop  
				hl.Parent = obj  
				local bb = Instance.new("BillboardGui")  
				bb.Size = UDim2.fromOffset(200, 20)  
				bb.StudsOffset = Vector3.new(0, 3, 0)  
				bb.AlwaysOnTop = true  
				bb.Adornee = part  
				bb.Parent = part  
				local lb = Instance.new("TextLabel")  
				lb.Size = UDim2.fromScale(1, 1)  
				lb.BackgroundColor3 = C.Panel  
				lb.BackgroundTransparency = 0.2  
				lb.TextColor3 = C.Text  
				lb.Font = Enum.Font.GothamSemibold  
				lb.TextSize = 11  
				lb.Parent = bb  
				Instance.new("UICorner", lb).CornerRadius = UDim.new(0, 6)  
				item = {hl = hl, bb = bb, lb = lb}  
				espItems[obj] = item  
			end  
			local dist = root and math.floor((part.Position - root.Position).Magnitude) or 0  
			item.lb.Text = string.format("%s | Luck %s | %d m", info.name, info.luck, dist)  
		end  
	end  
	for obj, item in pairs(espItems) do  
		if not keep[obj] then  
			pcall(function()  
				item.hl:Destroy()  
				item.bb:Destroy()  
			end)  
			espItems[obj] = nil  
		end  
	end  
end

local low = {on = false, orig = {}, queue = {}, seen = {}, shadows = nil, decor = nil, count = 0, errors = 0}

local function setProp(obj, prop, value)  
	local rec = low.orig[obj]  
	if not rec then  
		rec = {}  
		low.orig[obj] = rec  
	end  
	if rec[prop] == nil then  
		rec[prop] = obj[prop]  
	end  
	obj[prop] = value  
end

local function lowApply(d)  
	if d:IsA("Terrain") then  
		return  
	end  
	local ok = pcall(function()  
		if d:IsA("PostEffect") or LOW_CLASSES[d.ClassName] then  
			setProp(d, "Enabled", false)  
		elseif d:IsA("Atmosphere") then  
			setProp(d, "Density", 0)  
			setProp(d, "Haze", 0)  
			setProp(d, "Glare", 0)  
		elseif d:IsA("Decal") or d:IsA("Texture") then  
			setProp(d, "Transparency", 1)  
		elseif d:IsA("BasePart") then  
			setProp(d, "Material", Enum.Material.SmoothPlastic)  
			setProp(d, "CastShadow", false)  
		end  
	end)  
	if ok then  
		low.count += 1  
	else  
		low.errors += 1  
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
	while #low.queue > 0 and n < 300 do  
		local d = table.remove(low.queue)  
		if d and d.Parent and not low.seen[d] then  
			low.seen[d] = true  
			lowApply(d)  
		end  
		n += 1  
	end  
	S.low = low.count  
	S.lowErr = low.errors  
end

local function lowRestore()  
	for obj, rec in pairs(low.orig) do  
		for prop, val in pairs(rec) do  
			pcall(function()  
				obj[prop] = val  
			end)  
		end  
	end  
	low.orig, low.queue, low.seen = {}, {}, {}  
end

local function lowSet(on)  
	low.on = on  
	if on then  
		pcall(function()  
			if low.shadows == nil then  
				low.shadows = Lighting.GlobalShadows  
			end  
			Lighting.GlobalShadows = false  
		end)  
		pcall(function()  
			if low.decor == nil then  
				low.decor = workspace.Terrain.Decoration  
			end  
			workspace.Terrain.Decoration = false  
		end)  
		pcall(function()  
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01  
		end)  
		lowSweep()  
		S.status = "Low Graphics aktif"  
	else  
		lowRestore()  
		pcall(function()  
			if low.shadows ~= nil then  
				Lighting.GlobalShadows = low.shadows  
			end  
		end)  
		pcall(function()  
			if low.decor ~= nil then  
				workspace.Terrain.Decoration = low.decor  
			end  
		end)  
		low.shadows, low.decor = nil, nil  
		pcall(function()  
			settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic  
		end)  
		low.count, low.errors = 0, 0  
		S.low, S.lowErr = 0, 0  
		S.status = "Low Graphics mati, efek dikembalikan"  
	end  
end

local function lowReapply()  
	if low.on then  
		low.seen = {}  
		lowSweep()  
		S.status = "Low Graphics diterapkan ulang"  
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

local function trim(s)  
	return (string.gsub(s or "", "^%s*(.-)%s*$", "%1"))  
end

local function applySettings(text)  
	local raw = trim(text)  
	if string.sub(raw, 1, #SETTING_PREFIX) == SETTING_PREFIX then  
		raw = trim(string.sub(raw, #SETTING_PREFIX + 1))  
	end  
	if raw == "" then  
		return false, "kotak kosong"  
	end  
	local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)  
	if not ok or type(data) ~= "table" or type(data.cfg) ~= "table" then  
		return false, "format tidak valid"  
	end  
	local n = 0  
	for k, v in pairs(data.cfg) do  
		if CFG[k] ~= nil and typeof(CFG[k]) == typeof(v) then  
			CFG[k] = v  
			n += 1  
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
	return true, n  
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
	local okA = applySettings(raw)  
	S.config = okA and "dimuat" or "config rusak"  
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
	make("UICorner", {CornerRadius = UDim.new(0, r)}, o)  
end

local function btn(parent, text, color, h)  
	local b = make("TextButton", {  
		Size = UDim2.new(1, 0, 0, h or 28), BackgroundColor3 = color, BorderSizePixel = 0, Text = text,  
		TextColor3 = C.Text, Font = Enum.Font.GothamSemibold, TextSize = 12,  
		TextTruncate = Enum.TextTruncate.AtEnd, AutoButtonColor = false,  
	}, parent)  
	corner(b, 7)  
	return b  
end

local function section(page, text)  
	make("TextLabel", {  
		Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = string.upper(text),  
		TextColor3 = C.Accent, Font = Enum.Font.GothamBold, TextSize = 11,  
		TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrder(),  
	}, page)  
end

local function note(page, text)  
	make("TextLabel", {  
		Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, TextWrapped = true, Text = text,  
		TextColor3 = C.Muted, Font = Enum.Font.Gotham, TextSize = 11,  
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,  
		LayoutOrder = nextOrder(),  
	}, page)  
end

local function row(page)  
	return make("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = nextOrder()}, page)  
end

local function toggle(page, label, key, onFlip)  
	local b = btn(page, "", C.Dark, 30)  
	b.LayoutOrder = nextOrder()  
	table.insert(paints, function()  
		local on = CFG[key] == true  
		b.Text = (on and "●  " or "○  ") .. label .. "   " .. (on and "ON" or "OFF")  
		b.BackgroundColor3 = on and C.Accent or C.Dark  
		b.TextColor3 = on and C.Text or C.Muted  
	end)  
	b.MouseButton1Click:Connect(function()  
		CFG[key] = not CFG[key]  
		if onFlip then  
			onFlip(CFG[key])  
		end  
		refresh()  
	end)  
	return b  
end

local function stepper(page, label, key, step, lo, hi)  
	local r = make("Frame", {  
		Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.Card, BorderSizePixel = 0, LayoutOrder = nextOrder(),  
	}, page)  
	corner(r, 7)  
	make("TextLabel", {  
		Size = UDim2.new(1, -130, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1,  
		Text = label, TextColor3 = C.Muted, Font = Enum.Font.GothamSemibold, TextSize = 12,  
		TextXAlignment = Enum.TextXAlignment.Left,  
	}, r)  
	local value = make("TextLabel", {  
		Size = UDim2.fromOffset(44, 30), Position = UDim2.new(1, -92, 0, 0), BackgroundTransparency = 1,  
		TextColor3 = C.Text, Font = Enum.Font.GothamBold, TextSize = 13,  
	}, r)  
	local minus = btn(r, "-", C.Row, 24)  
	minus.Size = UDim2.fromOffset(28, 24)  
	minus.Position = UDim2.new(1, -124, 0, 3)  
	local plus = btn(r, "+", C.Row, 24)  
	plus.Size = UDim2.fromOffset(28, 24)  
	plus.Position = UDim2.new(1, -36, 0, 3)  
	local function bump(d)  
		local v = CFG[key] + d * step  
		v = math.floor(v / step + 0.5) * step  
		CFG[key] = math.clamp(v, lo, hi)  
		refresh()  
	end  
	minus.MouseButton1Click:Connect(function()  
		bump(-1)  
	end)  
	plus.MouseButton1Click:Connect(function()  
		bump(1)  
	end)  
	table.insert(paints, function()  
		value.Text = string.format("%g", CFG[key])  
	end)  
end

local function eggGrid(page, sel)  
	for _, e in ipairs(EGG_LIST) do  
		local key = string.lower(e[1])  
		local b = btn(page, "", C.Row, 26)  
		b.LayoutOrder = nextOrder()  
		b.Font = Enum.Font.Gotham  
		b.TextSize = 11  
		b.TextXAlignment = Enum.TextXAlignment.Left  
		make("UIPadding", {PaddingLeft = UDim.new(0, 8)}, b)  
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
end

local function setAll(sel, value)  
	for _, e in ipairs(EGG_LIST) do  
		sel[string.lower(e[1])] = value  
	end  
	refresh()  
end

local function eggButtons(page, sel, withMin)  
	local r = row(page)  
	local all = btn(r, "Pilih semua", C.Dark, 28)  
	all.Size = UDim2.new(withMin and 0.34 or 0.5, -4, 1, 0)  
	all.MouseButton1Click:Connect(function()  
		setAll(sel, true)  
	end)  
	local none = btn(r, "Kosongkan", C.Dark, 28)  
	none.Size = UDim2.new(withMin and 0.33 or 0.5, -4, 1, 0)  
	none.Position = UDim2.new(withMin and 0.34 or 0.5, 4, 0, 0)  
	none.MouseButton1Click:Connect(function()  
		setAll(sel, false)  
	end)  
	if withMin then  
		local minB = btn(r, "", C.Dark, 28)  
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
	local s = math.clamp(math.min((v.X - 16) / MAIN_W, (v.Y - 16) / MAIN_H), 0.4, 1)  
	uiRefs.scale.Scale = s  
	local w, h = MAIN_W * s, MAIN_H * s  
	if not layout.ready then  
		layout.main = Vector2.new(v.X / 2, v.Y / 2)  
		layout.logo = Vector2.new(v.X - 34, v.Y / 2)  
		layout.ready = true  
	end  
	local mx = math.max(w / 2, math.min(v.X - w / 2, layout.main.X))  
	local my = math.max(h / 2, math.min(v.Y - h / 2, layout.main.Y))  
	layout.main = Vector2.new(mx, my)  
	main.Position = UDim2.fromOffset(mx, my)  
	if uiRefs.logo then  
		local lx = math.max(24, math.min(v.X - 24, layout.logo.X))  
		local ly = math.max(24, math.min(v.Y - 24, layout.logo.Y))  
		layout.logo = Vector2.new(lx, ly)  
		uiRefs.logo.Position = UDim2.fromOffset(lx, ly)  
	end  
end

local function copyDiscord()  
	return pcall(function()  
		assert(type(setclipboard) == "function", "Clipboard tidak didukung")  
		setclipboard(DISCORD_LINK)  
	end)  
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
		Size = UDim2.new(0.92, 0, 0, 200), BackgroundColor3 = C.Panel, BorderSizePixel = 0,  
	}, bg)  
	make("UISizeConstraint", {MaxSize = Vector2.new(340, 200)}, panel)  
	corner(panel, 14)  
	make("TextLabel", {  
		Size = UDim2.new(1, -90, 0, 30), Position = UDim2.fromOffset(15, 14), BackgroundTransparency = 1,  
		Text = "Join Discord kayeshiHUB", TextColor3 = C.Text, Font = Enum.Font.GothamBold, TextSize = 15,  
		TextXAlignment = Enum.TextXAlignment.Left,  
	}, panel)  
	make("TextLabel", {  
		Size = UDim2.new(1, -30, 0, 50), Position = UDim2.fromOffset(15, 48), BackgroundTransparency = 1,  
		Text = "Info, update script, dan saran fitur ada di komunitas.", TextWrapped = true,  
		TextColor3 = C.Muted, Font = Enum.Font.Gotham, TextSize = 13,  
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,  
	}, panel)  
	local close = btn(panel, "Tutup", C.Dark, 30)  
	close.Size = UDim2.fromOffset(80, 30)  
	close.Position = UDim2.new(1, -95, 0, 8)  
	local join = btn(panel, "Salin link Discord", C.Accent, 36)  
	join.Size = UDim2.new(1, -30, 0, 36)  
	join.Position = UDim2.fromOffset(15, 110)  
	join.MouseButton1Click:Connect(function()  
		local ok = copyDiscord()  
		notify(ok and "Link Discord disalin" or DISCORD_LINK)  
	end)  
	close.MouseButton1Click:Connect(function()  
		gui:Destroy()  
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
		AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(MAIN_W, MAIN_H),  
		BackgroundColor3 = C.Panel, BorderSizePixel = 0,  
	}, gui)  
	corner(main, 12)  
	make("UIStroke", {Color = C.Dark, Thickness = 1}, main)  
	uiRefs.main = main  
	uiRefs.scale = make("UIScale", {Scale = 1}, main)

	local header = make("Frame", {Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = C.Side, BorderSizePixel = 0}, main)  
	corner(header, 12)  
	make("TextLabel", {  
		Size = UDim2.new(0, 260, 0, 20), Position = UDim2.fromOffset(16, 6), BackgroundTransparency = 1,  
		Text = "kayeshiHUB", TextColor3 = C.Text, Font = Enum.Font.GothamBold, TextSize = 16,  
		TextXAlignment = Enum.TextXAlignment.Left,  
	}, header)  
	local subtitle = make("TextLabel", {  
		Size = UDim2.new(1, -150, 0, 16), Position = UDim2.fromOffset(16, 26), BackgroundTransparency = 1,  
		TextColor3 = C.Muted, Font = Enum.Font.Gotham, TextSize = 11,  
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,  
	}, header)  
	local hideBtn = btn(header, "Sembunyikan", C.Dark, 28)  
	hideBtn.Size = UDim2.fromOffset(112, 28)  
	hideBtn.Position = UDim2.new(1, -124, 0, 9)  
	hideBtn.TextSize = 11

	local side = make("Frame", {  
		Position = UDim2.fromOffset(10, 54), Size = UDim2.new(0, 130, 1, -108),  
		BackgroundColor3 = C.Side, BorderSizePixel = 0,  
	}, main)  
	corner(side, 10)  
	make("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, side)  
	make("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, side)

	local content = make("Frame", {  
		Position = UDim2.fromOffset(150, 54), Size = UDim2.new(1, -160, 1, -108),  
		BackgroundColor3 = C.Side, BorderSizePixel = 0,  
	}, main)  
	corner(content, 10)

	local footer = make("Frame", {  
		Position = UDim2.new(0, 10, 1, -46), Size = UDim2.new(1, -20, 0, 36),  
		BackgroundColor3 = C.Side, BorderSizePixel = 0,  
	}, main)  
	corner(footer, 10)  
	local statusLbl = make("TextLabel", {  
		Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1,  
		TextColor3 = C.Muted, Font = Enum.Font.Gotham, TextSize = 11,  
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,  
	}, footer)

	local TABS = {  
		{"main", "Utama"}, {"filter", "Filter Egg"}, {"auto", "Auto"}, {"collect", "Collect"}, {"boss", "Boss"},  
		{"esp", "ESP"}, {"grafik", "Grafik"}, {"shop", "Shop"}, {"discord", "Discord"},  
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
		b.TextSize = 12  
		tabs[t[1]] = b  
	end

	local mp, fp, ap, cp, bp, ep, gp, sp, dp = pages.main, pages.filter, pages.auto, pages.collect, pages.boss, pages.esp, pages.grafik, pages.shop, pages.discord

	section(mp, "Auto Steal")  
	note(mp, "Steal egg terpilih, rarity tertinggi dulu. Steal ditunda selama egg masih di tangan atau di tas. Tekan F untuk nyala atau mati.")  
	toggle(mp, "Auto Steal", "AutoSteal")  
	toggle(mp, "Rarity tertinggi dulu", "RarityFirst")  
	stepper(mp, "Tunggu prompt (detik)", "StealWait", 0.1, 0.5, 3)  
	stepper(mp, "Jarak aman dari mesin", "MachineClear", 5, 10, 80)

	section(mp, "Safe Zone")  
	local zr = row(mp)  
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
	toggle(mp, "Safe zone dekat Trail Shop", "ShopZone")

	section(mp, "Anti AFK dan Gerak")  
	toggle(mp, "Anti AFK", "AntiAFK", function()  
		lastActive = os.clock()  
	end)  
	stepper(mp, "Lompat setelah diam (detik)", "AfkIdle", 30, 60, 900)  
	toggle(mp, "WalkSpeed", "Walk", function(on)  
		local hum = humanoid()  
		if hum and not on then  
			hum.WalkSpeed = baseWalk  
		end  
	end)  
	stepper(mp, "Kecepatan jalan", "WalkSpeed", 5, 16, 250)  
	toggle(mp, "JumpPower", "Jump", function(on)  
		local hum = humanoid()  
		if hum and not on then  
			hum.JumpPower = baseJump  
		end  
	end)  
	stepper(mp, "Kekuatan lompat", "JumpPower", 10, 50, 300)

	section(mp, "Config")  
	toggle(mp, "Auto save config", "AutoSave")  
	local cr = row(mp)  
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
		clearEsp()  
		lowSet(false)  
		saveConfig(true)  
		S.status = "Settingan dikembalikan ke default"  
		refresh()  
	end)

	section(mp, "Export / Import Settingan")  
	note(mp, "Export mengisi kotak dan menyalin settingan. Tempel string di kotak lalu tekan Import.")  
	local transferBox = make("TextBox", {  
		Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = C.Card, BorderSizePixel = 0, Text = "",  
		PlaceholderText = "Tempel string settingan di sini", PlaceholderColor3 = C.Muted,  
		TextColor3 = C.Text, Font = Enum.Font.Gotham, TextSize = 11, ClearTextOnFocus = false,  
		MultiLine = true, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,  
		TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = nextOrder(),  
	}, mp)  
	corner(transferBox, 7)  
	make("UIPadding", {PaddingLeft = UDim.new(0, 6), PaddingTop = UDim.new(0, 4)}, transferBox)  
	local tr = row(mp)  
	local exportBtn = btn(tr, "Export settingan", C.Accent, 30)  
	exportBtn.Size = UDim2.new(0.5, -4, 1, 0)  
	local importBtn = btn(tr, "Import settingan", C.Dark, 30)  
	importBtn.Size = UDim2.new(0.5, -4, 1, 0)  
	importBtn.Position = UDim2.new(0.5, 4, 0, 0)  
	exportBtn.MouseButton1Click:Connect(function()  
		local text = SETTING_PREFIX .. buildData()  
		transferBox.Text = text  
		local copied = pcall(function()  
			assert(type(setclipboard) == "function", "Clipboard tidak didukung")  
			setclipboard(text)  
		end)  
		S.status = copied and "Settingan diexport dan disalin" or "Settingan diexport (salin manual dari kotak)"  
		refresh()  
	end)  
	importBtn.MouseButton1Click:Connect(function()  
		local ok, res = applySettings(transferBox.Text)  
		if ok then  
			saveConfig(true)  
			S.status = "Import berhasil (" .. tostring(res) .. " pengaturan)"  
		else  
			S.status = "Import gagal: " .. tostring(res)  
		end  
		refresh()  
	end)

	section(fp, "Filter egg untuk steal dan auto")  
	note(fp, "Egg yang tidak dicentang tidak akan di-steal, di-place, atau di-hatch.")  
	eggButtons(fp, eggSel, true)  
	eggGrid(fp, eggSel)

	section(ap, "Auto Inventory")  
	note(ap, "Saat egg di tangan atau di tas, script menekan prompt Put To Inventory di seluruh map dan menunggu egg masuk sebelum steal lagi.")  
	toggle(ap, "Auto Inventory", "AutoInv")  
	stepper(ap, "Cooldown inventory (detik)", "InvCd", 0.5, 0.5, 10)  
	stepper(ap, "Gagal berapa kali sebelum pindah dari tangan", "InvTries", 1, 1, 10)  
	section(ap, "Auto Place")  
	note(ap, "Saat memegang egg, teleport ke mesin place atau incubat lalu tekan prompt. Dipakai jika Auto Inventory mati atau gagal.")  
	toggle(ap, "Auto Place", "AutoPlace")  
	toggle(ap, "Balik ke safe zone setelah place", "PlaceReturn")  
	stepper(ap, "Cooldown place (detik)", "MachineCd", 0.5, 0.5, 10)  
	section(ap, "Auto Hatch")  
	note(ap, "Saat tidak memegang egg, teleport ke mesin hatch terdekat lalu tekan prompt.")  
	toggle(ap, "Auto Hatch", "AutoHatch")  
	stepper(ap, "Cooldown hatch (detik)", "HatchCd", 0.5, 0.5, 30)

	section(cp, "Collect Token")  
	note(cp, "Teleport ke objek bernama token. Token generator diabaikan.")  
	toggle(cp, "Collect Token", "CollectToken")  
	section(cp, "Collect Pumpkin")  
	note(cp, "Teleport ke objek bernama pumpkin. Ember Pumpkin Citadel dan area event diabaikan.")  
	toggle(cp, "Collect Pumpkin", "CollectPumpkin")  
	section(cp, "Jeda Ambil")  
	stepper(cp, "Jeda antar ambil (detik)", "CollectDelay", 0.5, 0, 10)  
	stepper(cp, "Diam di objek (detik)", "CollectStand", 0.5, 0.5, 5)

	section(bp, "Auto Boss")  
	note(bp, "Menembak boss (nama mengandung 'boss'). Dodge menghindari indikator merah di bawah player.")  
	toggle(bp, "Auto Tembak Boss", "AutoBoss")  
	toggle(bp, "Hindari Indikator Merah", "Dodge")  
	stepper(bp, "Jarak tembak (studs)", "FireRange", 10, 20, 400)  
	stepper(bp, "Jarak hindar (studs)", "DodgeStep", 2, 4, 40)  
	local toolRow = make("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.Card, BorderSizePixel = 0, LayoutOrder = nextOrder()}, bp)  
	corner(toolRow, 7)  
	local toolBox = make("TextBox", {  
		Size = UDim2.new(1, -16, 1, -6), Position = UDim2.fromOffset(8, 3), BackgroundColor3 = C.Row, BorderSizePixel = 0,  
		Text = CFG.FireTool, PlaceholderText = "Nama tool (kosong = tool apa saja)", PlaceholderColor3 = C.Muted,  
		TextColor3 = C.Text, Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false,  
		TextXAlignment = Enum.TextXAlignment.Left,  
	}, toolRow)  
	corner(toolBox, 6)  
	make("UIPadding", {PaddingLeft = UDim.new(0, 8)}, toolBox)  
	toolBox.FocusLost:Connect(function()  
		CFG.FireTool = toolBox.Text  
		refresh()  
	end)

	section(ep, "Egg ESP")  
	note(ep, "Menandai egg yang dicentang dengan nama, luck, dan jarak. Tidak ada batas radius.")  
	toggle(ep, "Egg ESP", "EggESP", function(on)  
		if not on then  
			clearEsp()  
		end  
	end)  
	section(ep, "Filter ESP")  
	eggButtons(ep, espSel, false)  
	eggGrid(ep, espSel)

	section(gp, "Low Graphics")  
	note(gp, "Mematikan post-effect, atmosfer, awan, partikel, trail, beam, cahaya, decal, dan bayangan. Nilai asli disimpan dan dikembalikan saat dimatikan.")  
	toggle(gp, "Low Graphics", "LowGraphics", function(on)  
		lowSet(on)  
	end)  
	local reapply = btn(gp, "Terapkan ulang ke objek baru", C.Dark, 30)  
	reapply.LayoutOrder = nextOrder()  
	reapply.MouseButton1Click:Connect(function()  
		lowReapply()  
		refresh()  
	end)  
	local lowInfo = make("TextLabel", {  
		Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,  
		TextColor3 = C.Muted, Font = Enum.Font.Gotham, TextSize = 11,  
		TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrder(),  
	}, gp)  
	table.insert(paints, function()  
		lowInfo.Text = string.format("Objek diproses: %d  |  Error: %d  |  Antrian: %d", S.low or 0, S.lowErr or 0, #low.queue)  
	end)

	section(sp, "Auto Buka Shop NPC")  
	note(sp, "Radar Shop lewat NPC Mudagen, Feed Shop lewat NPC Alex. Tidak dibuka saat memegang egg.")  
	toggle(sp, "Auto Buka Radar Shop", "ShopRadar")  
	toggle(sp, "Auto Buka Feed Shop", "ShopFeed")  
	stepper(sp, "Jeda cek buka (detik)", "ShopCd", 1, 3, 60)  
	section(sp, "Buka Manual")  
	local manualRow = row(sp)  
	local radarBtn = btn(manualRow, "Buka Radar Shop", C.Accent, 30)  
	radarBtn.Size = UDim2.new(0.5, -4, 1, 0)  
	radarBtn.MouseButton1Click:Connect(function()  
		openNpc({"mudagen", "mudargen"})  
		refresh()  
	end)  
	local feedBtn = btn(manualRow, "Buka Feed Shop", C.Accent, 30)  
	feedBtn.Size = UDim2.new(0.5, -4, 1, 0)  
	feedBtn.Position = UDim2.new(0.5, 4, 0, 0)  
	feedBtn.MouseButton1Click:Connect(function()  
		openNpc({"alex"})  
		refresh()  
	end)

	section(dp, "Komunitas")  
	note(dp, "Info, update script, dan saran fitur ada di komunitas kayeshiHUB.")  
	local discordCopy = btn(dp, "Salin link Discord", C.Accent, 32)  
	discordCopy.LayoutOrder = nextOrder()  
	discordCopy.MouseButton1Click:Connect(function()  
		local ok = copyDiscord()  
		notify(ok and "Link berhasil disalin" or DISCORD_LINK)  
	end)  
	note(dp, DISCORD_LINK)

	table.insert(paints, function()  
		local n = 0  
		for _ in pairs(idx.egg) do  
			n += 1  
		end  
		subtitle.Text = string.format("Steal %d  |  Inventory %d  |  Place %d  |  Hatch %d  |  Ambil %d  |  Shop %d",  
			S.steal, S.inv, S.place, S.hatch, S.collect, S.shop)  
		statusLbl.Text = string.format("%s  |  Egg %d  |  Config %s  |  Error %d", S.status, n, S.config, S.errors)  
	end)

	local logo = make("Frame", {  
		AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(48, 48),  
		BackgroundColor3 = C.Ink, BorderSizePixel = 0, Visible = false, ZIndex = 5,  
	}, gui)  
	corner(logo, 24)  
	make("UIStroke", {Color = C.Accent, Thickness = 2}, logo)  
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
	hideBtn.MouseButton1Click:Connect(function()  
		setMenu(false)  
	end)  
	draggable(logoBtn,  
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
	draggable(header,  
		function()  
			return layout.main  
		end,  
		function(x, y)  
			layout.main = Vector2.new(x, y)  
			applyLayout()  
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

for _, e in ipairs(EGG_LIST) do  
	local key = string.lower(e[1])  
	if eggSel[key] == nil then  
		eggSel[key] = true  
	end  
	if espSel[key] == nil then  
		espSel[key] = true  
	end  
end

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

loadConfig()  
if CFG.LowGraphics then  
	lowSet(true)  
end  
refresh()

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
				task.wait(0.5)  
			end  
			task.wait(interval)  
		end  
	end)  
end

loop("utama", 0.12, function()  
	if (CFG.AutoBoss or CFG.Dodge) and bossTick() then  
		return  
	end  
	mainTick()  
end)  
loop("esp", 0.5, updateEsp)  
loop("grafik", 0.05, function()  
	if low.on then  
		lowPump()  
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

task.delay(1, function()  
	pcall(showDiscordPopup)  
end)

notify("kayeshiHUB aktif. Tekan F untuk auto steal.")  
