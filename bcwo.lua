-- BCWO.lua  —  Balanced Craftwars Overhaul  |  HyperionUI edition
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

local Hyperion = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/phobiaalwaysinmyheart-dot/HBui/refs/heads/main/HyperionUI.lua"
))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService  = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer      = Players.LocalPlayer

if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end

local ORE_FILTER_MIN_X = -3000
local ORE_FILTER_MAX_Y = 500
local VERSION = "2.0"
local _menuKeybind = Enum.KeyCode.Insert

local currentIndex = 1
local autoFarming = false
local selectedOres = {}
local fullbrightEnabled = false
local originalBrightness, originalAmbient, originalOutdoorAmbient
local currentOrePart = nil
local teleportConnection = nil

local HESP = {
    Enabled=false, MaxDistance=5000, AliveCheck=true,
    BoxEnabled=true, BoxMode="Corner",
    BoxColor=Color3.fromRGB(255,255,255), BoxThickness=1, BoxFilled=false,
    NameEnabled=true, DistanceEnabled=true,
    TextColor=Color3.fromRGB(255,255,255), TextSize=14, TextFont=2,
    TracerEnabled=false, TracerColor=Color3.fromRGB(255,255,255),
    TracerThickness=1, TracerOrigin="Bottom",
    HealthBarEnabled=true, HealthBarThickness=2, HealthBarMode="Periwinkle",
    HeadDotEnabled=false, HeadDotColor=Color3.fromRGB(255,255,255), HeadDotFilled=true,
    SkeletonEnabled=false, SkeletonColor=Color3.fromRGB(255,255,255), SkeletonThickness=1,
    HighlightEnabled=false,
    HighlightFillColor=Color3.fromRGB(128,0,255), HighlightFillTransparency=0.75,
    HighlightOutlineColor=Color3.fromRGB(255,255,255), HighlightOutlineTransparency=0,
    RainbowEnabled=false, RainbowSpeed=1,
}
local ESPObjects     = {}
local HighlightCache = {}
local espConnection  = nil
local _espFrame      = 0
local _rainbowColor  = Color3.new(1,1,1)
local HB_SEGS        = 20
local MAX_BONES_ESP  = 14

local npcCache = {}
local npcCacheConn1, npcCacheConn2

local oreEspEnabled = false
local oreEspDrawings = {}
local oreEspConnection = nil
local oreEspMaxDist = 300
local selectedOreEsp = {}
local oreCache = {}
local oreCacheConn1, oreCacheConn2

local walkSpeedValue = 16
local jumpPowerValue = 50
local flightEnabled = false
local flightSpeed = 60
local flightConnection = nil
local flightBodyVelocity = nil
local flightBodyGyro = nil
local flightKeybind = Enum.KeyCode.F
local noclipConnection = nil

local bladeActive = false
local bladeConnection = nil
local swingSpeedValue = 99
local bowActive = false
local bowConnection = nil
local projectileAmount = 1
local phantomBoltAmount = 1

local hitboxActive = false
local hitboxConnection = nil
local hitboxSize = 10
local originalSizes = {}

local totemActive = false
local totemSpamAbility = "1"
local totemDelay = 0.1
local totemThread = nil

local raidActive = false
local raidConnection = nil
local raidStep = 0
local raidStepTime = 0

local autoSummonActive = false
local autoSummonDelay = 0.5
local summonCurrentIndex = 1
local summonNextFireTime = 0
local autoSummonConnection = nil

local eggFarmActive = false
local eggFarmConnection = nil
local eggFarmDelay = 0.5

local fpsUnlocked = false
local fpsCap = 240

local miningActive = false
local antiAfkConnection = nil

local godmodeActive = false
local godmodeConn = nil

local biomeHopActive = false
local biomeHopTargets = {}
local biomeHopWaitTime = 20
local biomeHopJoinDelay = 45
local currentBiome = "Grasslands"
local biomeDetectConnection = nil
local webhookUrl = ""
local targetBiomeActive = false

local BIOME_ENEMIES = {
    ["Grasslands"]          = {"Hollow","Poisonous Slime","Large Slime","Abandoned Scavenger"},
    ["Night"]               = {"Smooth Criminal","Trapped Soul","Huntsman","Nightseer"},
    ["Blizzard"]            = {"Frigid Slime","Frigid Spirit"},
    ["Stormsurge"]          = {"Sunken Priest","Strider","Demergat"},
    ["Flare"]               = {"Flare Slime","Flare Spirit"},
    ["Nature"]              = {"Woodland Hunter","Man Eater","Wind Spirit"},
    ["Starry Night"]        = {"Starry Slime","Glitterman","Starry"},
    ["Irradiated"]          = {"Irradiated Sludge","Scavenger"},
    ["Pure vs Corrupt War"] = {"Pure Ranger","Pure Warrior","Corrupt Ranger","Corrupt Warrior"},
    ["Holy vs Unholy War"]  = {"Holy Knight","Holy Archer","Unholy Warrior","Unholy Archer"},
    ["Void Infiltration"]   = {"Voidmite","Void Dweller","Void Watcher"},
    ["Angel's Descent"]     = {"Angel","Fat Heavenly Spirit","Heavenly Spirit"},
    ["Shrouding Darkness"]  = {"Astaroth, the Lord of Darkness"},
    ["Blinding Light"]      = {"Benedictus"},
    ["Cultist Legion"]      = {"Cultist","Cultist Rider","Cultist Musketeer","Cultist Knight","Cultist Assassin","Cultist Mage"},
}

local BIOME_CHECK_ORDER = {
    "Blinding Light","Shrouding Darkness","Cultist Legion",
    "Angel's Descent","Void Infiltration","Holy vs Unholy War",
    "Pure vs Corrupt War","Irradiated","Starry Night",
    "Nature","Flare","Stormsurge","Blizzard","Night","Grasslands",
}

local BIOME_LIST = {
    "Grasslands","Night","Blizzard","Flare","Nature","Stormsurge",
    "Starry Night","Irradiated","Pure vs Corrupt War","Holy vs Unholy War",
    "Angel's Descent","Void Infiltration","Cultist Legion",
    "Shrouding Darkness","Blinding Light",
}

local summonerWeapons = {
    "Slime Staff","Necromancer Staff","Spider Staff","Nightseer Scepter",
    "Titanstone Spellbook","Spirit of the Elements","Lava Turret",
    "Winter Fairy Staff","Crab Staff","Explosive Puppet",
    "Pure Cross","Ripper Glyph","Holy Crystal","Blob of Flesh",
    "Angelic Cross","Void Watcher's Relic","Maw of the Void",
    "Synodic Energy Reactor","Synodic Protector","Synodic Transfigurator",
    "Huntsman Queen Staff","Scroll of Summoning","Sigil of Evocation",
    "Servant Calling Bell","Pocket Sun","Starfish Bomber",
    "Unknown Signal Emitter","The Aeriastra","The Petridish",
    "The Shadowdancer","Trepid Terror","Ocean's Authority",
    "Voidmite Plushie","Smelly Cheese","Special Steak","Parrot Cracker",
    "Ominous Dark Egg","Soldier Egg","Unlucky Yarnball",
    "Equinox Seal","Seraphim Ring","Summoner's Insignia","Spirit Core",
    "Thunder Sprite","Aqua Sprite","Gale Sprite","Nature Sprite",
    "Flare Sprite","Frost Sprite",
}

local oreList = {
    "Lead","Iron","Crystal","Gold","Diamond","Cobalt","Oureclasium","Viridis",
    "Tungsten","Titanium","Mithril","Adamantine","Titanstone",
    "Gemstone of Purity","Gemstone of Hatred","Astral Silver",
    "Irradium","Uranium","Plutonium","Purite","Hatrite","Aurium",
    "Duranite","Hevenite","Hellite","Lanite","Moonstone","Forbidden Crystal"
}
local oreSet = {}
for _,n in ipairs(oreList) do oreSet[n]=true end

local oreColors = {
    Lead=Color3.fromRGB(160,160,180),Iron=Color3.fromRGB(200,190,180),
    Crystal=Color3.fromRGB(180,230,255),Gold=Color3.fromRGB(255,210,0),
    Diamond=Color3.fromRGB(100,230,255),Cobalt=Color3.fromRGB(80,120,255),
    Oureclasium=Color3.fromRGB(200,80,255),Viridis=Color3.fromRGB(60,220,120),
    Tungsten=Color3.fromRGB(140,140,150),Titanium=Color3.fromRGB(180,200,220),
    Mithril=Color3.fromRGB(120,180,255),Adamantine=Color3.fromRGB(80,255,180),
    Titanstone=Color3.fromRGB(160,180,200),
    ["Gemstone of Purity"]=Color3.fromRGB(255,255,200),
    ["Gemstone of Hatred"]=Color3.fromRGB(255,60,60),
    ["Astral Silver"]=Color3.fromRGB(200,210,255),
    Irradium=Color3.fromRGB(120,255,60),Uranium=Color3.fromRGB(100,255,80),
    Plutonium=Color3.fromRGB(160,255,100),Purite=Color3.fromRGB(255,200,255),
    Hatrite=Color3.fromRGB(255,80,120),Aurium=Color3.fromRGB(255,230,80),
    Duranite=Color3.fromRGB(140,160,180),Hevenite=Color3.fromRGB(200,240,255),
    Hellite=Color3.fromRGB(255,80,40),Lanite=Color3.fromRGB(180,255,200),
    Moonstone=Color3.fromRGB(220,220,255),
    ["Forbidden Crystal"]=Color3.fromRGB(180,0,255),
}

local pickaxeNames = {
    "Iron Pickaxe","Gold Pickaxe","Diamond Pickaxe",
    "Cobalt Pickaxe","Darksteel Pickaxe","Viridis Pickaxe","Pickaxe of Balance"
}
local pickaxeSet = {}
for _,n in ipairs(pickaxeNames) do pickaxeSet[n]=true end

-- ===================== FORWARD API REFS =====================
local _AutoSummonAPI, _TotemAPI, _RaidAPI, _BladeAPI, _BowAPI, _OreMultiAPI, _FlightAPI, _BiomeHopAPI, _EggFarmAPI
local _uiReady = false

-- ===================== NOTIFY HELPER =====================
local function Notify(title, content, ntype, duration)
    Hyperion:Notify({ Title=title, Content=content, Type=ntype or "Info", Duration=duration or 3 })
end

-- ===================== HELPERS =====================
local function getChar() return LocalPlayer.Character end
local function getHum() local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function getHRP() local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function isPickaxeName(n) return pickaxeSet[n]==true end

local function isNPCModel(model)
    if not model:IsA("Model") then return false end
    if model==getChar() then return false end
    for _,p in ipairs(Players:GetPlayers()) do if p.Character==model then return false end end
    return model:FindFirstChild("EnemyMain")~=nil or model:FindFirstChildOfClass("Humanoid")~=nil
end

local function findBlade()
    local function scan(c)
        if not c then return nil end
        for _,t in ipairs(c:GetChildren()) do
            if t:IsA("Tool") and not isPickaxeName(t.Name) and t:FindFirstChild("PhysicalSwingSpeed") then return t end
        end
    end
    local c=getChar() local bp=LocalPlayer:FindFirstChild("Backpack")
    return (c and scan(c)) or (bp and scan(bp))
end

local function findCrossbow()
    local function scan(c)
        if not c then return nil end
        for _,t in ipairs(c:GetChildren()) do
            if t:IsA("Tool") and not isPickaxeName(t.Name) then
                if t:FindFirstChild("RangedProjectileAmount") or t:FindFirstChild("PhantomBolts") then return t end
            end
        end
    end
    local c=getChar() local bp=LocalPlayer:FindFirstChild("Backpack")
    return (c and scan(c)) or (bp and scan(bp))
end

-- ===================== WEBHOOK =====================
local function sendWebhook(title, description, color)
    if not webhookUrl or webhookUrl=="" then return end
    task.spawn(function()
        pcall(function()
            local data = HttpService:JSONEncode({
                embeds = {{
                    title = title,
                    description = description,
                    color = color or 7506394,
                    footer = { text = "Hyperion v"..VERSION.." | BCWO" },
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                }}
            })
            local result = syn and syn.request or (http and http.request) or request
            if result then
                result({ Url=webhookUrl, Method="POST",
                    Headers={ ["Content-Type"]="application/json" }, Body=data })
            end
        end)
    end)
end

-- ===================== TELEPORT LOCK =====================
local function startTeleportLock(part)
    currentOrePart=part
    if teleportConnection then teleportConnection:Disconnect() end
    teleportConnection=RunService.Heartbeat:Connect(function()
        if not currentOrePart or not currentOrePart.Parent then
            if teleportConnection then teleportConnection:Disconnect() teleportConnection=nil end
            currentOrePart=nil return
        end
        local hrp=getHRP() if not hrp then return end
        hrp.CFrame=CFrame.new(currentOrePart.Position+Vector3.new(4,3,0),currentOrePart.Position)
    end)
end

local function stopTeleportLock()
    currentOrePart=nil
    if teleportConnection then teleportConnection:Disconnect() teleportConnection=nil end
end

-- ===================== ORE/NPC CACHES =====================
local function getOrePart(obj)
    if obj:IsA("BasePart") or obj:IsA("MeshPart") then return obj end
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("MeshPart") or obj:FindFirstChildWhichIsA("BasePart")
    end
    return nil
end

local function rebuildNpcCache()
    npcCache={}
    pcall(function()
        for _,obj in ipairs(workspace:GetDescendants()) do
            pcall(function() if isNPCModel(obj) then npcCache[obj]=true end end)
        end
    end)
end

local function rebuildOreCache()
    oreCache={}
    pcall(function()
        for _,obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if oreSet[obj.Name] and (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("MeshPart")) then
                    local part=getOrePart(obj)
                    if part then
                        local pos=part.Position
                        if pos.X>ORE_FILTER_MIN_X and pos.Y<ORE_FILTER_MAX_Y then
                            oreCache[obj]={part=part,name=obj.Name}
                        end
                    end
                end
            end)
        end
    end)
end

local function startCaches()
    rebuildNpcCache() rebuildOreCache()
    if npcCacheConn1 then npcCacheConn1:Disconnect() end
    if npcCacheConn2 then npcCacheConn2:Disconnect() end
    if oreCacheConn1 then oreCacheConn1:Disconnect() end
    if oreCacheConn2 then oreCacheConn2:Disconnect() end
    npcCacheConn1=workspace.DescendantAdded:Connect(function(obj)
        pcall(function() if isNPCModel(obj) then npcCache[obj]=true end end)
    end)
    npcCacheConn2=workspace.DescendantRemoving:Connect(function(obj) npcCache[obj]=nil end)
    oreCacheConn1=workspace.DescendantAdded:Connect(function(obj)
        task.defer(function()
            pcall(function()
                if not obj or not obj.Parent then return end
                if oreSet[obj.Name] and (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("MeshPart")) then
                    local part=getOrePart(obj)
                    if part then
                        local pos=part.Position
                        if pos.X>ORE_FILTER_MIN_X and pos.Y<ORE_FILTER_MAX_Y then
                            oreCache[obj]={part=part,name=obj.Name}
                        end
                    end
                end
            end)
        end)
    end)
    oreCacheConn2=workspace.DescendantRemoving:Connect(function(obj) oreCache[obj]=nil end)
end
startCaches()
local function V2n(x,y) return Vector2.new(x,y) end

local startESP, stopESP
-- ===================== NPC ESP (Drawing System) =====================
do
local function updateRainbow()
    _rainbowColor = Color3.fromHSV(tick() % HESP.RainbowSpeed / HESP.RainbowSpeed, 1, 1)
end
local function getRainbow() return _rainbowColor end

local function healthGradient(t)
    local m = HESP.HealthBarMode
    if m == "Periwinkle" then return Color3.fromRGB(math.floor(t*128),0,255)
    elseif m == "Emerald" then return Color3.fromRGB(0,math.floor((1-t)*201),math.floor(t*255+(1-t)*87))
    elseif m == "Peach"   then return Color3.fromRGB(255,math.floor(t*255+(1-t)*179),math.floor((1-t)*128))
    else return Color3.new(1,1,1) end
end
local function healthColSimple(hp,mx)
    local r=math.clamp(hp/mx,0,1)
    return Color3.fromRGB(255-math.floor(r*255),math.floor(r*255),0)
end

local function NL2(z) local l=Drawing.new("Line") l.Visible=false l.Transparency=1 pcall(function() l.ZIndex=z end) return l end
local function NSq2(z) local s=Drawing.new("Square") s.Visible=false s.Filled=false s.Transparency=1 pcall(function() s.ZIndex=z end) return s end
local function NCir2(z) local c2=Drawing.new("Circle") c2.Visible=false c2.NumSides=30 c2.Transparency=1 pcall(function() c2.ZIndex=z end) return c2 end
local function NTxt2(z) local t=Drawing.new("Text") t.Visible=false t.Center=true t.Outline=true pcall(function() t.ZIndex=z end) return t end

local R15BonesESP = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local R6BonesESP = {
    {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"},
}

local function makeNPCESPObj(model)
    if ESPObjects[model] then return end
    local o = {}
    o.Box=NSq2(2) o.Box.Thickness=1
    o.CornersOut={} o.Corners={}
    for i=1,8 do o.CornersOut[i]=NL2(1) o.CornersOut[i].Color=Color3.new(0,0,0) o.Corners[i]=NL2(2) o.Corners[i].Thickness=1 end
    o.QuadLinesOut={} o.QuadLines={}
    for i=1,8 do o.QuadLinesOut[i]=NL2(1) o.QuadLinesOut[i].Color=Color3.new(0,0,0) o.QuadLines[i]=NL2(2) o.QuadLines[i].Thickness=1 end
    o.Tracer=NL2(2)
    o.HBSegs={}
    for i=1,HB_SEGS do o.HBSegs[i]=NL2(2) o.HBSegs[i].Thickness=2 end
    o.Dot=NCir2(2) o.Dot.Filled=true
    o.BonesOut={} o.Bones={}
    for i=1,MAX_BONES_ESP do o.BonesOut[i]=NL2(1) o.BonesOut[i].Color=Color3.new(0,0,0) o.Bones[i]=NL2(2) end
    o.Name=NTxt2(3) o.Name.Size=14 o.Name.Font=2
    o.Dist=NTxt2(3) o.Dist.Size=14 o.Dist.Font=2
    ESPObjects[model]=o
end

local function destroyNPCESPObj(model)
    local o=ESPObjects[model] if not o then return end
    for _,v in pairs(o) do
        if type(v)=="table" then for _,d in pairs(v) do pcall(function() d:Remove() end) end
        else pcall(function() v:Remove() end) end
    end
    ESPObjects[model]=nil
    if HighlightCache[model] then pcall(function() HighlightCache[model]:Destroy() end) HighlightCache[model]=nil end
end

local function hideAllESPObj(o)
    for _,v in pairs(o) do
        if type(v)=="table" then for _,d in pairs(v) do pcall(function() d.Visible=false end) end
        else pcall(function() v.Visible=false end) end
    end
end

local function drawCornersESP(c2,co,ps,sz,col,thk,vis)
    if not vis then for i=1,8 do c2[i].Visible=false co[i].Visible=false end return end
    local x,y,w,h=ps.X,ps.Y,sz.X,sz.Y
    local L=math.floor(math.min(w,h)/3)
    c2[1].From=V2n(x,y)     c2[1].To=V2n(x+L,y)
    c2[2].From=V2n(x,y)     c2[2].To=V2n(x,y+L)
    c2[3].From=V2n(x+w,y)   c2[3].To=V2n(x+w-L,y)
    c2[4].From=V2n(x+w,y)   c2[4].To=V2n(x+w,y+L)
    c2[5].From=V2n(x,y+h)   c2[5].To=V2n(x+L,y+h)
    c2[6].From=V2n(x,y+h)   c2[6].To=V2n(x,y+h-L)
    c2[7].From=V2n(x+w,y+h) c2[7].To=V2n(x+w-L,y+h)
    c2[8].From=V2n(x+w,y+h) c2[8].To=V2n(x+w,y+h-L)
    for i=1,8 do c2[i].Color=col c2[i].Thickness=thk c2[i].Visible=true co[i].Visible=false end
end

local function draw3DBoxESP(ql,qlo,ps,sz,col,thk,vis)
    if not vis then for i=1,8 do ql[i].Visible=false qlo[i].Visible=false end return end
    local x,y,w,h=ps.X,ps.Y,sz.X,sz.Y
    local dx,dy=math.floor(w*0.25),math.floor(h*0.18)
    ql[1].From=V2n(x,y)     ql[1].To=V2n(x+w,y)
    ql[2].From=V2n(x,y+h)   ql[2].To=V2n(x+w,y+h)
    ql[3].From=V2n(x,y)     ql[3].To=V2n(x,y+h)
    ql[4].From=V2n(x+w,y)   ql[4].To=V2n(x+w,y+h)
    ql[5].From=V2n(x,y)     ql[5].To=V2n(x+dx,y-dy)
    ql[6].From=V2n(x+w,y)   ql[6].To=V2n(x+w+dx,y-dy)
    ql[7].From=V2n(x,y+h)   ql[7].To=V2n(x+dx,y+h-dy)
    ql[8].From=V2n(x+w,y+h) ql[8].To=V2n(x+w+dx,y+h-dy)
    for i=1,8 do ql[i].Color=col ql[i].Thickness=thk ql[i].Visible=true qlo[i].Visible=false end
end

local function updateHighlight(model,ch,en,fc,ft,oc,ot,dm)
    if not en or not ch then
        if HighlightCache[model] then pcall(function() HighlightCache[model]:Destroy() end) HighlightCache[model]=nil end return
    end
    if not HighlightCache[model] or not HighlightCache[model].Parent then
        local h=Instance.new("Highlight") h.Adornee=ch h.Parent=ch
        pcall(function() h.DepthMode=Enum.HighlightDepthMode[dm or "AlwaysOnTop"] end)
        HighlightCache[model]=h
    end
    local h=HighlightCache[model]
    h.FillColor=fc h.FillTransparency=ft h.OutlineColor=oc h.OutlineTransparency=ot h.Adornee=ch
    pcall(function() h.DepthMode=Enum.HighlightDepthMode[dm or "AlwaysOnTop"] end)
end

local function updateAllESP()
    _espFrame=_espFrame+1
    if HESP.RainbowEnabled then updateRainbow() end
    local cam=workspace.CurrentCamera
    local lrp=getHRP()
    local lpos=lrp and lrp.Position

    if _espFrame % 30 == 0 then
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and not ESPObjects[p.Character] then
                makeNPCESPObj(p.Character)
            end
        end
        for _,obj in ipairs(workspace:GetDescendants()) do
            if isNPCModel(obj) and not ESPObjects[obj] then
                makeNPCESPObj(obj)
            end
        end
        for model in pairs(ESPObjects) do
            if not model or not model.Parent then destroyNPCESPObj(model) end
        end
    end

    for model,o in pairs(ESPObjects) do
        if not model or not model.Parent then hideAllESPObj(o) continue end
        local hum=model:FindFirstChildOfClass("Humanoid")
        local rp=model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChildWhichIsA("BasePart")
        if not hum or not rp then hideAllESPObj(o) continue end
        if HESP.AliveCheck and hum.Health<=0 then hideAllESPObj(o) updateHighlight(model,nil,false,Color3.new(),1,Color3.new(),1) continue end

        local dist=lpos and (rp.Position-lpos).Magnitude or 0
        if dist>HESP.MaxDistance then hideAllESPObj(o) continue end

        local r6=model:FindFirstChild("Torso")~=nil
        local cf=rp.CFrame local up=cf.UpVector local cu=cam.CFrame.UpVector
        local camLook=cam.CFrame.LookVector
        if (rp.Position-cam.CFrame.Position):Dot(camLook)<-50 then hideAllESPObj(o) continue end

        local ts,to2=cam:WorldToViewportPoint(rp.Position+up*(r6 and 0.5 or 1.8)+cu)
        local bs,bo2=cam:WorldToViewportPoint(rp.Position-up*(r6 and 4 or 2.5)-cu)
        if not to2 and not bo2 then hideAllESPObj(o) continue end

        local tp=V2n(ts.X,ts.Y) local bp=V2n(bs.X,bs.Y)
        local h2=math.max(math.abs(bp.Y-tp.Y),3)
        local w2=math.max(math.floor(h2/1.8),3)
        local sz2=V2n(w2,h2)
        local ps2=V2n(math.floor((tp.X+bp.X)/2-w2/2),math.floor(math.min(tp.Y,bp.Y)))
        local ec=HESP.RainbowEnabled and getRainbow() or HESP.BoxColor
        local tc=HESP.RainbowEnabled and getRainbow() or HESP.TextColor
        local hp2=math.clamp(hum.Health,0,hum.MaxHealth)
        local hpPct=hp2/math.max(hum.MaxHealth,1)

        -- BOX
        o.Box.Visible=false
        for i=1,8 do o.Corners[i].Visible=false o.CornersOut[i].Visible=false end
        for i=1,8 do o.QuadLines[i].Visible=false o.QuadLinesOut[i].Visible=false end
        if HESP.BoxEnabled then
            if HESP.BoxMode=="Square" then
                o.Box.Size=sz2 o.Box.Position=ps2 o.Box.Color=ec
                o.Box.Thickness=HESP.BoxThickness o.Box.Filled=HESP.BoxFilled o.Box.Visible=true
            elseif HESP.BoxMode=="Corner" then
                drawCornersESP(o.Corners,o.CornersOut,ps2,sz2,ec,HESP.BoxThickness,true)
            elseif HESP.BoxMode=="3D" then
                draw3DBoxESP(o.QuadLines,o.QuadLinesOut,ps2,sz2,ec,HESP.BoxThickness,true)
            end
        end

        -- NAME
        if HESP.NameEnabled then
            local nm=model.Name
            for _,p in ipairs(Players:GetPlayers()) do
                if p.Character==model then nm=p.Name break end
            end
            o.Name.Text=string.format("[%d/%d] %s",math.floor(hp2),math.floor(hum.MaxHealth),nm)
            o.Name.Position=V2n(ps2.X+sz2.X/2,ps2.Y-18)
            o.Name.Color=tc o.Name.Size=HESP.TextSize o.Name.Font=HESP.TextFont o.Name.Visible=true
        else o.Name.Visible=false end

        -- DISTANCE
        if HESP.DistanceEnabled then
            o.Dist.Text=string.format("[%d studs]",math.floor(dist))
            o.Dist.Position=V2n(ps2.X+sz2.X/2,ps2.Y+sz2.Y+2)
            o.Dist.Color=tc o.Dist.Size=HESP.TextSize o.Dist.Font=HESP.TextFont o.Dist.Visible=true
        else o.Dist.Visible=false end

        -- TRACER
        if HESP.TracerEnabled then
            local vp=cam.ViewportSize
            local from=HESP.TracerOrigin=="Bottom" and V2n(vp.X/2,vp.Y) or HESP.TracerOrigin=="Center" and V2n(vp.X/2,vp.Y/2) or game:GetService("UserInputService"):GetMouseLocation()
            o.Tracer.From=from o.Tracer.To=V2n(ps2.X+sz2.X/2,ps2.Y+sz2.Y)
            o.Tracer.Color=HESP.RainbowEnabled and getRainbow() or HESP.TracerColor
            o.Tracer.Thickness=HESP.TracerThickness o.Tracer.Visible=true
        else o.Tracer.Visible=false end

        -- HEALTH BAR
        if HESP.HealthBarEnabled then
            local barBottom=ps2.Y+sz2.Y local barFill=ps2.Y+sz2.Y-hpPct*sz2.Y local bx=ps2.X-4
            if HESP.HealthBarMode~="Normal" then
                local invSegs=1/HB_SEGS local invMax=1/math.max(HB_SEGS-1,1)
                for i=1,HB_SEGS do
                    local seg=o.HBSegs[i] local segT=barBottom-i*invSegs*sz2.Y
                    if segT>=barFill-0.5 then
                        seg.From=V2n(bx,barBottom-(i-1)*invSegs*sz2.Y) seg.To=V2n(bx,segT)
                        seg.Color=healthGradient((i-1)*invMax) seg.Thickness=HESP.HealthBarThickness seg.Visible=true
                    else seg.Visible=false end
                end
            else
                for i=2,HB_SEGS do o.HBSegs[i].Visible=false end
                local seg=o.HBSegs[1]
                seg.From=V2n(bx,barBottom) seg.To=V2n(bx,barFill)
                seg.Color=healthColSimple(hp2,hum.MaxHealth) seg.Thickness=HESP.HealthBarThickness seg.Visible=true
            end
        else for i=1,HB_SEGS do o.HBSegs[i].Visible=false end end

        -- HEAD DOT
        local hd=model:FindFirstChild("Head")
        if HESP.HeadDotEnabled and hd then
            local hs,ho=cam:WorldToViewportPoint(hd.Position)
            if ho then
                local ht2=cam:WorldToViewportPoint((hd.CFrame*CFrame.new(0,hd.Size.Y/2,0)).Position)
                local hb3=cam:WorldToViewportPoint((hd.CFrame*CFrame.new(0,-hd.Size.Y/2,0)).Position)
                local rad=math.max(math.abs(ht2.Y-hb3.Y)/2,2)
                o.Dot.Position=V2n(hs.X,hs.Y) o.Dot.Radius=rad
                o.Dot.Color=HESP.RainbowEnabled and getRainbow() or HESP.HeadDotColor
                o.Dot.Filled=HESP.HeadDotFilled o.Dot.Visible=true
            else o.Dot.Visible=false end
        else o.Dot.Visible=false end

        -- SKELETON
        if HESP.SkeletonEnabled then
            local boneList=r6 and R6BonesESP or R15BonesESP
            local skC=HESP.RainbowEnabled and getRainbow() or HESP.SkeletonColor
            for i,pair in ipairs(boneList) do
                local p1=model:FindFirstChild(pair[1]) local p2=model:FindFirstChild(pair[2])
                if p1 and p2 then
                    local s1,on1=cam:WorldToViewportPoint(p1.Position)
                    local s2,on2=cam:WorldToViewportPoint(p2.Position)
                    if on1 and on2 then
                        o.Bones[i].From=V2n(s1.X,s1.Y) o.Bones[i].To=V2n(s2.X,s2.Y)
                        o.Bones[i].Color=skC o.Bones[i].Thickness=HESP.SkeletonThickness o.Bones[i].Visible=true
                        o.BonesOut[i].Visible=false
                    else o.Bones[i].Visible=false o.BonesOut[i].Visible=false end
                else o.Bones[i].Visible=false o.BonesOut[i].Visible=false end
            end
            for i=#boneList+1,MAX_BONES_ESP do o.Bones[i].Visible=false o.BonesOut[i].Visible=false end
        else for i=1,MAX_BONES_ESP do o.Bones[i].Visible=false o.BonesOut[i].Visible=false end end

        -- HIGHLIGHTS (throttled)
        if _espFrame%3==0 then
            local hlFill=HESP.RainbowEnabled and getRainbow() or HESP.HighlightFillColor
            local hlOut=HESP.RainbowEnabled and getRainbow() or HESP.HighlightOutlineColor
            updateHighlight(model,model,HESP.HighlightEnabled,hlFill,HESP.HighlightFillTransparency,hlOut,HESP.HighlightOutlineTransparency)
        end
    end
end

startESP = function()
    if espConnection then espConnection:Disconnect() end
    espConnection=RunService.RenderStepped:Connect(function() pcall(updateAllESP) end)
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then makeNPCESPObj(p.Character) end
    end
end

stopESP = function()
    if espConnection then espConnection:Disconnect() espConnection=nil end
    for model in pairs(ESPObjects) do destroyNPCESPObj(model) end
    ESPObjects={}
    for model in pairs(HighlightCache) do
        pcall(function() HighlightCache[model]:Destroy() end)
    end
    HighlightCache={}
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(ch)
        if HESP.Enabled then makeNPCESPObj(ch) end
    end)
end)
Players.PlayerRemoving:Connect(function(p)
    if p.Character then destroyNPCESPObj(p.Character) end
end)
end -- NPC ESP

local startOreESP, stopOreESP, clearAllOreESP, _OreEspFilterAPI
-- ===================== ORE ESP =====================
do
local function shouldShowOreESP(n)
    if not next(selectedOreEsp) then return true end
    return selectedOreEsp[n]==true
end

local function createOreESPDrawing(obj,part,name)
    if oreEspDrawings[obj] then return end
    local color=oreColors[name] or Color3.fromRGB(255,255,255)
    local box=Drawing.new("Square")
    box.Visible=false box.Filled=false box.Thickness=1 box.Color=color box.Transparency=1
    local label=Drawing.new("Text")
    label.Visible=false label.Center=true label.Outline=true
    label.Size=13 label.Font=2 label.Color=color label.OutlineColor=Color3.new(0,0,0)
    oreEspDrawings[obj]={box=box,label=label,part=part,name=name}
end

local function removeOreESPDrawing(obj)
    local d=oreEspDrawings[obj] if not d then return end
    pcall(function() d.box:Remove() end)
    pcall(function() d.label:Remove() end)
    oreEspDrawings[obj]=nil
end

clearAllOreESP = function()
    for obj in pairs(oreEspDrawings) do removeOreESPDrawing(obj) end
    oreEspDrawings={}
end

local oreEspTicker=0
local function updateOreESP()
    if not oreEspEnabled then return end
    oreEspTicker+=1
    local cam=workspace.CurrentCamera
    local hrp=getHRP()
    local lpos=hrp and hrp.Position

    -- Every 30 ticks: scan workspace directly (same pattern as NPC ESP)
    if oreEspTicker%30==0 then
        local found={}
        for _,obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if oreSet[obj.Name] and (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("MeshPart")) then
                    if not shouldShowOreESP(obj.Name) then return end
                    local part=getOrePart(obj)
                    if not part then return end
                    local pos=part.Position
                    if pos.X<=ORE_FILTER_MIN_X or pos.Y>=ORE_FILTER_MAX_Y then return end
                    found[obj]=true
                    oreCache[obj]={part=part,name=obj.Name}
                    if not oreEspDrawings[obj] then
                        createOreESPDrawing(obj,part,obj.Name)
                    end
                end
            end)
        end
        for obj in pairs(oreEspDrawings) do
            if not found[obj] or not obj or not obj.Parent then
                removeOreESPDrawing(obj)
            end
        end
    end

    -- Every frame: update screen positions of existing drawings
    for obj,d in pairs(oreEspDrawings) do
        if not obj or not obj.Parent or not d.part or not d.part.Parent then
            removeOreESPDrawing(obj) continue
        end
        local dist=lpos and (d.part.Position-lpos).Magnitude or 9999
        if dist>oreEspMaxDist then d.box.Visible=false d.label.Visible=false continue end
        local pos3,onScreen=cam:WorldToViewportPoint(d.part.Position)
        if not onScreen or pos3.Z<=0 then d.box.Visible=false d.label.Visible=false continue end
        local screenPos=V2n(pos3.X,pos3.Y)
        local boxSize=math.clamp(1200/math.max(dist,1),8,60)
        local half=boxSize/2
        d.box.Size=V2n(boxSize,boxSize)
        d.box.Position=V2n(screenPos.X-half,screenPos.Y-half)
        d.box.Visible=true
        d.label.Text=d.name.." ["..math.floor(dist).."m]"
        d.label.Position=V2n(screenPos.X,screenPos.Y-half-14)
        d.label.Visible=true
    end
end

startOreESP = function()
    if oreEspConnection then oreEspConnection:Disconnect() end
    oreEspTicker=29  -- trigger immediate scan on first frame
    oreEspConnection=RunService.RenderStepped:Connect(function() pcall(updateOreESP) end)
end

stopOreESP = function()
    if oreEspConnection then oreEspConnection:Disconnect() oreEspConnection=nil end
    clearAllOreESP()
end
end -- OreESP

local startBiomeHop, stopBiomeHop
-- ===================== BIOME DETECTION =====================
do
local function detectBiomeFromEnemies()
    local present={}
    pcall(function()
        for _,obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("Model") and obj:FindFirstChild("EnemyMain") then present[obj.Name]=true end
            end)
        end
    end)
    local detectedBiome="Grasslands"
    for _,biome in ipairs(BIOME_CHECK_ORDER) do
        local enemies=BIOME_ENEMIES[biome]
        if enemies then
            for _,enemyName in ipairs(enemies) do
                if present[enemyName] then detectedBiome=biome break end
            end
            if detectedBiome~="Grasslands" then break end
        end
    end
    if detectedBiome~=currentBiome then
        local prevBiome=currentBiome
        currentBiome=detectedBiome
        if biomeHopActive and targetBiomeActive and not biomeHopTargets[detectedBiome] then
            targetBiomeActive=false
            if _uiReady then Notify("Biome Ended",prevBiome.." ended, resuming rejoin...","Info",4) end
            sendWebhook("Target Biome Ended","**"..prevBiome.."** has ended.\nResuming server hopping...",15158332)
        end
        if biomeHopActive and biomeHopTargets[detectedBiome] then
            targetBiomeActive=true
            if _uiReady then Notify("Target Biome Found!",detectedBiome.." is active! Staying...","Success",8) end
            sendWebhook("Target Biome Found!","**"..detectedBiome.."** is now active!\nStaying in server!",5763719)
        end
    end
    return detectedBiome
end

local function startBiomeDetect()
    if biomeDetectConnection then biomeDetectConnection:Disconnect() end
    local lastScan=0
    biomeDetectConnection=RunService.Heartbeat:Connect(function()
        local now=tick()
        if now-lastScan>=0.05 then lastScan=now pcall(detectBiomeFromEnemies) end
    end)
end

local function stopBiomeDetect()
    if biomeDetectConnection then biomeDetectConnection:Disconnect() biomeDetectConnection=nil end
end

startBiomeHop = function()
    targetBiomeActive=false
    startBiomeDetect()
    task.spawn(function()
        -- Wait for the server to fully initialize its biome before starting countdown
        if _uiReady then Notify("Biome Hop","Waiting "..biomeHopJoinDelay.."s for server to load...","Info",4) end
        local joinWait=0
        while biomeHopActive and joinWait<biomeHopJoinDelay do
            task.wait(1) joinWait+=1
        end
        if not biomeHopActive then return end
        local elapsed=0
        while biomeHopActive do
            task.wait(1)
            if targetBiomeActive then elapsed=0 continue end
            elapsed+=1
            if elapsed>=biomeHopWaitTime then
                elapsed=0
                if biomeHopActive and not targetBiomeActive then
                    if _uiReady then Notify("Biome Hop","No match, hopping server...","Info",2) end
                    sendWebhook("Rejoining","No target biome after **"..biomeHopWaitTime.."s**.\nHopping to new server...",16776960)
                    -- IY rejoin (verbatim)
                    if #game:GetService("Players"):GetPlayers() <= 1 then
                        LocalPlayer:Kick("\nRejoining...")
                        task.wait()
                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    else
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                    end
                end
            end
        end
    end)
end

stopBiomeHop = function()
    biomeHopActive=false targetBiomeActive=false stopBiomeDetect()
end
end -- Biome

local startAutoSummon, stopAutoSummon, findSummonerWeapons
-- ===================== AUTO SUMMON =====================
do
local summonerWeaponSet={}
for _,n in ipairs(summonerWeapons) do summonerWeaponSet[n]=true end

findSummonerWeapons = function()
    local found={} local c=getChar()
    local containers={} local _bp=LocalPlayer:FindFirstChild("Backpack")
    if _bp then table.insert(containers,_bp) end
    if c then table.insert(containers,c) end
    for _,container in ipairs(containers) do
        for _,tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") and summonerWeaponSet[tool.Name] then table.insert(found,tool) end
        end
    end
    return found
end

local function activateSummon(tool)
    local h=getHum() if not h or h.Health<=0 then return end
    local c=getChar() if not c then return end
    if not c:FindFirstChild(tool.Name) then h:EquipTool(tool) task.wait(0.3) end
    local rf=tool:FindFirstChild("RemoteFunction") local re=tool:FindFirstChild("RemoteEvent")
    if rf then
        pcall(function() rf:InvokeServer("summon") end)
        pcall(function() rf:InvokeServer("activate") end)
        pcall(function() rf:InvokeServer("place") end)
    end
    if re then
        pcall(function() re:FireServer("summon") end)
        pcall(function() re:FireServer("activate") end)
    end
    pcall(function() tool:Activate() end)
end

startAutoSummon = function()
    if autoSummonConnection then autoSummonConnection:Disconnect() end
    summonCurrentIndex=1 summonNextFireTime=0
    autoSummonConnection=RunService.Heartbeat:Connect(function()
        if not autoSummonActive then return end
        local h=getHum() if not h or h.Health<=0 then return end
        local now=tick() if now<summonNextFireTime then return end
        local weapons=findSummonerWeapons() if #weapons==0 then return end
        if summonCurrentIndex>#weapons then summonCurrentIndex=1 end
        local tool=weapons[summonCurrentIndex] summonCurrentIndex+=1
        summonNextFireTime=now+autoSummonDelay
        task.spawn(function() pcall(activateSummon,tool) end)
    end)
end

stopAutoSummon = function()
    autoSummonActive=false
    if autoSummonConnection then autoSummonConnection:Disconnect() autoSummonConnection=nil end
    summonCurrentIndex=1 summonNextFireTime=0
end
end -- AutoSummon

local startRaid, stopRaid
-- ===================== AUTO RAID =====================
do
local function getPartyFunction()
    local RS=game:GetService("ReplicatedStorage")
    local rem=RS:FindFirstChild("Remotes") if not rem then return nil end
    local ps=rem:FindFirstChild("PartySystem") if not ps then return nil end
    return ps:FindFirstChild("PartyFunction")
end

local function getMysteriousArtifact()
    local c=getChar() if not c then return nil end
    local _bp=LocalPlayer:FindFirstChild("Backpack")
    return c:FindFirstChild("Mysterious Artifact") or (_bp and _bp:FindFirstChild("Mysterious Artifact"))
end

local function isInParty()
    local gui=LocalPlayer.PlayerGui:FindFirstChild("PartySystem") if not gui then return false end
    local ok,result=pcall(function() return gui:GetAttribute("CurrentParty") end)
    return ok and result~=nil and result~=false
end

local function createParty()
    local pf=getPartyFunction()
    if not pf then Notify("Auto Raid","PartyFunction remote not found!","Warning",3) return false end
    pcall(function() pf:InvokeServer("createParty",{FriendsOnly=false,Visual=true,subplace="Equinox Stronghold"}) end)
    return true
end

local function startDungeon()
    local pf=getPartyFunction() if not pf then return end
    pcall(function() pf:InvokeServer("joinSubplace",{}) end)
end

startRaid = function()
    if raidConnection then raidConnection:Disconnect() end
    raidStep=0 raidStepTime=0
    raidConnection=RunService.Heartbeat:Connect(function()
        if not raidActive then return end
        pcall(function()
            local h=getHum() if not h or h.Health<=0 then return end
            local now=tick() if now<raidStepTime then return end
            if raidStep==0 then
                local tool=getMysteriousArtifact()
                if not tool then
                    Notify("Auto Raid","Mysterious Artifact not found!","Warning",3)
                    raidActive=false if _RaidAPI then _RaidAPI:Set(false) end return
                end
                local c=getChar()
                if c and not c:FindFirstChild("Mysterious Artifact") then h:EquipTool(tool) raidStepTime=now+0.5 return end
                local re=tool:FindFirstChild("WeaponRemote")
                if re then pcall(function() re:FireServer("use",{}) end) end
                raidStep=1 raidStepTime=now+1.5
            elseif raidStep==1 then
                if isInParty() then raidStep=2 raidStepTime=now+0.5 return end
                createParty() raidStep=2 raidStepTime=now+2
            elseif raidStep==2 then
                if not isInParty() then raidStep=1 raidStepTime=now+1 return end
                startDungeon() raidStep=3 raidStepTime=now+5
                Notify("Auto Raid","Dungeon starting!","Success",3)
            elseif raidStep==3 then
                if not isInParty() then
                    raidStep=0 raidStepTime=now+2
                    Notify("Auto Raid","Dungeon complete! Restarting...","Info",3)
                else raidStepTime=now+2 end
            end
        end)
    end)
end

stopRaid = function()
    raidActive=false raidStep=0
    if raidConnection then raidConnection:Disconnect() raidConnection=nil end
end
end -- AutoRaid

local startEggFarm, stopEggFarm
-- ===================== EGG FARM =====================
do
local function findEggs()
    local eggs={}
    pcall(function()
        for _,obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("MeshPart") then
                    local n=obj.Name:lower()
                    if n:find("egg") and obj:FindFirstChild("EggMain") then table.insert(eggs,{part=obj}) end
                end
            end)
        end
    end)
    return eggs
end

startEggFarm = function()
    if eggFarmConnection then eggFarmConnection:Disconnect() end
    local lastCollect=0
    eggFarmConnection=RunService.Heartbeat:Connect(function()
        if not eggFarmActive then return end
        local now=tick() if now-lastCollect<eggFarmDelay then return end
        lastCollect=now
        local hrp=getHRP() if not hrp then return end
        local eggs=findEggs() if #eggs==0 then return end
        local nearest,nearestDist=nil,math.huge
        for _,e in ipairs(eggs) do
            local d=(e.part.Position-hrp.Position).Magnitude
            if d<nearestDist then nearest=e nearestDist=d end
        end
        if nearest then hrp.CFrame=CFrame.new(nearest.part.Position+Vector3.new(0,2,0)) end
    end)
end

stopEggFarm = function()
    eggFarmActive=false
    if eggFarmConnection then eggFarmConnection:Disconnect() eggFarmConnection=nil end
end
end -- EggFarm

local startTotem, stopTotem
-- ===================== ANCIENT TOTEM =====================
do
local function getTotemRemote()
    local c=getChar() if not c then return nil end
    local _bp=LocalPlayer:FindFirstChild("Backpack")
    local tool=c:FindFirstChild("Ancient Totem") or (_bp and _bp:FindFirstChild("Ancient Totem"))
    if not tool then return nil end
    return tool:FindFirstChild("RemoteFunction")
end

local function bypassTotemCooldown()
    local c=getChar() if not c then return end
    local cd=c:FindFirstChild("TotemSwitchCD")
    if cd then pcall(function() cd:Destroy() end) end
    local _bp2=LocalPlayer:FindFirstChild("Backpack")
    local tool=c:FindFirstChild("Ancient Totem") or (_bp2 and _bp2:FindFirstChild("Ancient Totem"))
    if not tool then return end
    for _,v in ipairs(tool:GetDescendants()) do
        if v:IsA("BoolValue") then
            local n=v.Name:lower()
            if n:find("cool") or n:find("ready") or n:find("active") or n:find("placed") then v.Value=false end
        elseif v:IsA("NumberValue") or v:IsA("IntValue") then
            local n=v.Name:lower()
            if n:find("cool") or n:find("timer") or n:find("duration") then v.Value=0 end
        end
    end
end

startTotem = function()
    if totemThread then task.cancel(totemThread) end
    totemThread=task.spawn(function()
        while totemActive do
            local rf=getTotemRemote()
            if rf then
                bypassTotemCooldown()
                pcall(function() rf:InvokeServer("place") end)
                task.wait(0.05)
                pcall(function() rf:InvokeServer(totemSpamAbility) end)
            else
                Notify("Totem","Ancient Totem not found!","Warning",3)
                totemActive=false if _TotemAPI then _TotemAPI:Set(false) end break
            end
            task.wait(totemDelay)
        end
    end)
end

stopTotem = function()
    totemActive=false
    if totemThread then task.cancel(totemThread) totemThread=nil end
end
end -- Totem

local startHitbox, stopHitbox
-- ===================== HITBOX =====================
do
local function expandModel(model)
    local hrp=model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
    if hrp then
        if not originalSizes[hrp] then originalSizes[hrp]=hrp.Size end
        hrp.Size=Vector3.new(hitboxSize,hitboxSize,hitboxSize)
    end
end

stopHitbox = function()
    hitboxActive=false
    if hitboxConnection then hitboxConnection:Disconnect() hitboxConnection=nil end
    for part,size in pairs(originalSizes) do pcall(function() part.Size=size end) end
    originalSizes={}
end

startHitbox = function()
    if hitboxConnection then hitboxConnection:Disconnect() end
    local ticker=0
    hitboxConnection=RunService.Heartbeat:Connect(function()
        if not hitboxActive then return end
        ticker+=1 if ticker%5~=0 then return end
        for model in pairs(npcCache) do
            if model and model.Parent then pcall(function() expandModel(model) end) end
        end
    end)
end
end -- Hitbox

-- ===================== BLADE =====================
local function startBlade()
    if bladeConnection then bladeConnection:Disconnect() end
    local ticker=0
    bladeConnection=RunService.Heartbeat:Connect(function()
        if not bladeActive then return end
        ticker+=1 if ticker%10~=0 then return end
        local tool=findBlade() if not tool then return end
        local pss=tool:FindFirstChild("PhysicalSwingSpeed")
        if pss and pss.Value~=swingSpeedValue then pss.Value=swingSpeedValue end
    end)
end

local function stopBlade()
    bladeActive=false
    if bladeConnection then bladeConnection:Disconnect() bladeConnection=nil end
    local tool=findBlade()
    if tool then local pss=tool:FindFirstChild("PhysicalSwingSpeed") if pss then pss.Value=1 end end
end

-- ===================== BOW =====================
local function applyBowStats()
    local tool=findCrossbow()
    if not tool then Notify("Bow","No ranged weapon found!","Warning",3) return false end
    local rpa=tool:FindFirstChild("RangedProjectileAmount") local pb=tool:FindFirstChild("PhantomBolts")
    if rpa then rpa.Value=projectileAmount end if pb then pb.Value=phantomBoltAmount end
    return true
end

local function startBow()
    if bowConnection then bowConnection:Disconnect() end
    local ticker=0
    bowConnection=RunService.Heartbeat:Connect(function()
        if not bowActive then return end
        ticker+=1 if ticker%10~=0 then return end
        local tool=findCrossbow() if not tool then return end
        local rpa=tool:FindFirstChild("RangedProjectileAmount") local pb=tool:FindFirstChild("PhantomBolts")
        if rpa and rpa.Value~=projectileAmount then rpa.Value=projectileAmount end
        if pb and pb.Value~=phantomBoltAmount then pb.Value=phantomBoltAmount end
    end)
end

local function stopBow()
    bowActive=false
    if bowConnection then bowConnection:Disconnect() bowConnection=nil end
    local tool=findCrossbow()
    if tool then
        local rpa=tool:FindFirstChild("RangedProjectileAmount") local pb=tool:FindFirstChild("PhantomBolts")
        if rpa then rpa.Value=1 end if pb then pb.Value=1 end
    end
end

-- ===================== NOCLIP =====================
local function startNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection=RunService.Stepped:Connect(function()
        local c=getChar() if not c then return end
        for _,part in ipairs(c:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=false end end
    end)
end

local function stopNoclip()
    if noclipConnection then noclipConnection:Disconnect() noclipConnection=nil end
    local c=getChar()
    if c then for _,part in ipairs(c:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=true end end end
end

-- ===================== FLIGHT =====================
local function startFlight()
    local hrp=getHRP() local hum=getHum()
    if not hrp or not hum then return end
    hum.PlatformStand=true
    flightBodyVelocity=Instance.new("BodyVelocity")
    flightBodyVelocity.Velocity=Vector3.zero
    flightBodyVelocity.MaxForce=Vector3.new(1e6,1e6,1e6)
    flightBodyVelocity.Parent=hrp
    flightBodyGyro=Instance.new("BodyGyro")
    flightBodyGyro.MaxTorque=Vector3.new(1e6,1e6,1e6)
    flightBodyGyro.P=1e4
    flightBodyGyro.CFrame=hrp.CFrame
    flightBodyGyro.Parent=hrp
    local camera=workspace.CurrentCamera
    flightConnection=RunService.Heartbeat:Connect(function()
        if not flightEnabled then return end
        local hrp2=getHRP() if not hrp2 then return end
        local camCF=camera.CFrame local moveDir=Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir+=camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir-=camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir-=camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir+=camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir+=Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir-=Vector3.new(0,1,0) end
        if moveDir.Magnitude>0 then moveDir=moveDir.Unit end
        flightBodyVelocity.Velocity=moveDir*flightSpeed
        flightBodyGyro.CFrame=camCF
    end)
    startNoclip()
end

local function stopFlight()
    if flightConnection then flightConnection:Disconnect() flightConnection=nil end
    if flightBodyVelocity then pcall(function() flightBodyVelocity:Destroy() end) flightBodyVelocity=nil end
    if flightBodyGyro then pcall(function() flightBodyGyro:Destroy() end) flightBodyGyro=nil end
    local c=getChar()
    if c then
        local hum=c:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.PlatformStand=false end) end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BodyVelocity") or p:IsA("BodyGyro") then pcall(function() p:Destroy() end) end
        end
    end
    stopNoclip()
end

local _flightSyncLock = false
local function toggleFlight()
    flightEnabled=not flightEnabled
    if flightEnabled then
        startFlight()
        Notify("Flight ON","Press F to disable.","Success",2)
    else
        stopFlight()
        Notify("Flight OFF","Press F to enable.","Info",2)
    end
    if _FlightAPI then
        _flightSyncLock = true
        _FlightAPI:Set(flightEnabled)
        _flightSyncLock = false
    end
end

-- ===================== MOVEMENT HELPERS =====================
local function applyWalkSpeed() local h=getHum() if h then h.WalkSpeed=walkSpeedValue end end
local function applyJumpPower()
    local h=getHum() if not h then return end
    if h:GetAttribute("UseJumpPower")==false then
        pcall(function() h.JumpHeight=jumpPowerValue*0.5 end)
    else
        pcall(function() h.JumpPower=jumpPowerValue end)
    end
end

-- ===================== AUTO DASH (godmode) =====================
local DASH_CD_NAMES = {"DashCD","DashCooldown","DashSwitchCD","DashTC","DashTimer"}

local function startGodmode()
    if godmodeConn then godmodeConn:Disconnect() end
    local vim2=game:GetService("VirtualInputManager")
    godmodeConn=RunService.Heartbeat:Connect(function()
        if not godmodeActive then return end
        local c=getChar() if not c then return end
        for _,name in ipairs(DASH_CD_NAMES) do
            local cd=c:FindFirstChild(name)
            if cd then pcall(function() cd:Destroy() end) end
        end
        pcall(function()
            vim2:SendKeyEvent(true,"Q",false,game)
            vim2:SendKeyEvent(false,"Q",false,game)
        end)
    end)
end

local function stopGodmode()
    godmodeActive=false
    if godmodeConn then godmodeConn:Disconnect() godmodeConn=nil end
end

-- ===================== ANTI-AFK =====================
local function startAntiAfk()
    if antiAfkConnection then antiAfkConnection:Disconnect() end
    local lastAction=tick()
    antiAfkConnection=RunService.Heartbeat:Connect(function()
        if tick()-lastAction>=180 then
            lastAction=tick()
            local h=getHum()
            if h then
                pcall(function() h.Jump=true end)
                pcall(function()
                    local vu=game:GetService("VirtualUser")
                    vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                    task.wait(0.1)
                    vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                end)
            end
        end
    end)
end

local function stopAntiAfk()
    if antiAfkConnection then antiAfkConnection:Disconnect() antiAfkConnection=nil end
end

-- ===================== FULLBRIGHT =====================
local function setFullbright(enabled)
    local lighting=game:GetService("Lighting")
    if enabled then
        originalBrightness=lighting.Brightness
        originalAmbient=lighting.Ambient
        originalOutdoorAmbient=lighting.OutdoorAmbient
        lighting.Brightness=2
        lighting.Ambient=Color3.fromRGB(178,178,178)
        lighting.OutdoorAmbient=Color3.fromRGB(178,178,178)
    else
        if originalBrightness then lighting.Brightness=originalBrightness end
        if originalAmbient then lighting.Ambient=originalAmbient end
        if originalOutdoorAmbient then lighting.OutdoorAmbient=originalOutdoorAmbient end
    end
end

-- ===================== MINING =====================
local function findPickaxe()
    local c=getChar() local _bp=LocalPlayer:FindFirstChild("Backpack")
    for _,tool in ipairs(_bp and _bp:GetChildren() or {}) do
        if pickaxeSet[tool.Name] then return tool end
    end
    if c then
        for _,tool in ipairs(c:GetChildren()) do
            if tool:IsA("Tool") and pickaxeSet[tool.Name] then return tool end
        end
    end
    return nil
end

local function equipPickaxe()
    local tool=findPickaxe() if not tool then return nil end
    local h=getHum() if not h then return nil end
    h:EquipTool(tool)
    local c=getChar() if not c then return nil end
    local deadline=tick()+2
    repeat
        task.wait(0.05)
        for _,t in ipairs(c:GetChildren()) do
            if t:IsA("Tool") then return t end
        end
    until tick()>=deadline
    return tool
end

local function scanWorkspaceForOres()
    for _,obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if oreSet[obj.Name] and (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("MeshPart")) then
                if not oreCache[obj] then
                    local part=getOrePart(obj)
                    if part then
                        local pos=part.Position
                        if pos.X>ORE_FILTER_MIN_X and pos.Y<ORE_FILTER_MAX_Y then
                            oreCache[obj]={part=part,name=obj.Name}
                        end
                    end
                end
            end
        end)
    end
end

local function findOres()
    local ores={}
    -- Always scan workspace directly so we never depend on stale cache
    for _,obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if oreSet[obj.Name] and (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("MeshPart")) then
                if not next(selectedOres) or selectedOres[obj.Name] then
                    local part=getOrePart(obj)
                    if part then
                        local pos=part.Position
                        if pos.X>ORE_FILTER_MIN_X and pos.Y<ORE_FILTER_MAX_Y then
                            oreCache[obj]={part=part,name=obj.Name}
                            table.insert(ores,{model=obj,part=part,name=obj.Name})
                        end
                    end
                end
            end
        end)
    end
    return ores
end

local function teleportToSide(part)
    local c=getChar() if not c or not c:FindFirstChild("HumanoidRootPart") then return end
    local orePos=part.Position
    local sides={Vector3.new(4,0,0),Vector3.new(-4,0,0),Vector3.new(0,0,4),Vector3.new(0,0,-4)}
    local bestPos=orePos+sides[1]+Vector3.new(0,3,0)
    local rayParams=RaycastParams.new()
    rayParams.FilterType=Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances={c}
    for _,side in ipairs(sides) do
        local candidate=orePos+side
        local result=workspace:Raycast(candidate+Vector3.new(0,5,0),Vector3.new(0,-10,0),rayParams)
        if result then bestPos=candidate+Vector3.new(0,3,0) break end
    end
    c.HumanoidRootPart.CFrame=CFrame.new(bestPos,orePos)
end

local function startMining(tool)
    miningActive=true
    task.spawn(function()
        local rf=tool:FindFirstChild("RemoteFunction")
        local speed=tool:FindFirstChild("Speed") and tool.Speed.Value or 1
        if not rf then
            local re=tool:FindFirstChild("PickaxeControl")
            if re then while miningActive do re:FireServer("mine") task.wait(speed) end end
            return
        end
        while miningActive do
            pcall(function() rf:InvokeServer("mine") end)
            task.wait(speed)
        end
    end)
end

local function stopMining() miningActive=false end

local function waitForOreMined(oreModel, timeout)
    local mined=false
    local conn=oreModel.AncestryChanged:Connect(function()
        if not oreModel.Parent then mined=true end
    end)
    local elapsed=0
    while not mined and elapsed<timeout do
        if not oreModel or not oreModel.Parent then mined=true break end
        task.wait(0.1) elapsed+=0.1
    end
    pcall(function() conn:Disconnect() end)
    return mined
end

-- ===================== TELEPORT =====================
local function teleportToBeneath()
    local hrp=getHRP() if not hrp then return end
    local tp=workspace:FindFirstChild("BeneathTeleporter",true)
    if tp then
        hrp.CFrame=CFrame.new(tp.Position+Vector3.new(0,5,0))
        Notify("Teleport","Teleported to Beneath.","Success",2)
    else
        Notify("Teleport","BeneathTeleporter not found!","Warning",3)
    end
end

local function teleportToNull()
    local hrp=getHRP() if not hrp then return end
    hrp.CFrame=CFrame.new(-1195,49.7,-810)
    Notify("Teleport","Teleported to Null area.","Success",2)
end

-- ===================== FPS UNLOCK =====================
local function setFpsCap(cap)
    pcall(function()
        local rs=game:GetService("RunService")
        if fpsUnlocked then
            settings().Rendering.FrameRateManager=Enum.FrameRateManagerMode.Disabled
            pcall(function() rs:Set60Fps(false) end)
        end
        pcall(function()
            game:GetService("UserSettings"):GetService("UserGameSettings").SavedQualityLevel=Enum.SavedQualitySetting.Automatic
        end)
    end)
end

-- ===================== RESPAWN HANDLER =====================
LocalPlayer.CharacterAdded:Connect(function(char)
    local h=char:WaitForChild("Humanoid",10)
    if not h then return end
    task.wait(0.5)
    applyWalkSpeed()
    applyJumpPower()
    if autoFarming then stopMining() stopTeleportLock() end
    if flightEnabled then
        stopFlight()
        flightEnabled=false
        if _FlightAPI then _FlightAPI:Set(false) end
    end
    startCaches()
end)

-- ===================== UI =====================
local Window = Hyperion:CreateWindow({
    Title          = "Hyperion",
    Logo           = "rbxassetid://134963728913547",
    ConfigSystem   = true,
    ConfigAutoLoad = true,
    AutoLoadName   = "bcwo_default",
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == _menuKeybind then
        pcall(function() Window:Toggle() end)
    end
end)

-- TABS
local MainTab     = Window:AddTab({ Name = "Main",      Icon = Hyperion.Lucide.Home     })
local MovementTab = Window:AddTab({ Name = "Movement",  Icon = Hyperion.Lucide.Zap      })
local CombatTab   = Window:AddTab({ Name = "Combat",    Icon = Hyperion.Lucide.Target   })
local MineTab     = Window:AddTab({ Name = "Mine",      Icon = Hyperion.Lucide.Wrench   })
local BiomeTab    = Window:AddTab({ Name = "Biome",     Icon = Hyperion.Lucide.Globe    })
local RaidTab     = Window:AddTab({ Name = "Raid",      Icon = Hyperion.Lucide.Shield   })
local EspTab      = Window:AddTab({ Name = "ESP",       Icon = Hyperion.Lucide.Eye      })
local SettingsTab = Window:AddTab({ Name = "Settings",  Icon = Hyperion.Lucide.Settings })

-- ── MAIN TAB ──────────────────────────────────────────────────────────
do
local MainL  = MainTab:AddSection({ Name = "General",       Side = "Left",  Group = "Utility" })
local MainR  = MainTab:AddSection({ Name = "Summoner",      Side = "Right", Group = "Utility" })
local TotemL = MainTab:AddSection({ Name = "Ancient Totem", Side = "Left",  Group = "Totem"   })
local TotemR = MainTab:AddSection({ Name = "Totem Info",    Side = "Right", Group = "Totem"   })

MainL:AddToggle({
    Name = "Anti-AFK", Default = true, Flag = "bc_antiafk",
    Callback = function(v)
        if v then startAntiAfk() else stopAntiAfk() end
    end,
})

_AutoSummonAPI = MainR:AddToggle({
    Name = "Auto Summon", Default = false, Flag = "bc_autosummon",
    Callback = function(v)
        autoSummonActive = v
        if v then
            local weapons = findSummonerWeapons()
            if #weapons > 0 then
                startAutoSummon()
            else
                autoSummonActive = false
                if _AutoSummonAPI then _AutoSummonAPI:Set(false) end
                Notify("Auto Summon", "No summoner weapons found in backpack.", "Warning", 4)
            end
        else
            stopAutoSummon()
        end
    end,
})
MainR:AddSlider({
    Name = "Summon Delay", Min = 0.1, Max = 5, Default = 0.5,
    Decimals = 1, Suffix = " s", Flag = "bc_summondelay",
    Callback = function(v) autoSummonDelay = v end,
})
MainR:AddButton({
    Name = "List Detected Weapons",
    Icon = Hyperion.Lucide.List,
    Callback = function()
        local weapons = findSummonerWeapons()
        if #weapons == 0 then
            Notify("Summon Scan", "No summoner weapons found.", "Info", 4)
        else
            local names = {}
            for _,t in ipairs(weapons) do table.insert(names, t.Name) end
            Notify("Found "..#weapons.." weapon(s)", table.concat(names, ", "), "Success", 6)
        end
    end,
})

_TotemAPI = TotemL:AddToggle({
    Name = "Totem Spam", Default = false, Flag = "bc_totem",
    Callback = function(v)
        totemActive = v
        if v then
            local rf = getTotemRemote()
            if rf then
                startTotem()
            else
                totemActive = false
                if _TotemAPI then _TotemAPI:Set(false) end
                Notify("Totem", "Ancient Totem not found! Equip it first.", "Warning", 3)
            end
        else
            stopTotem()
        end
    end,
})
TotemL:AddDropdown({
    Name = "Totem Ability", Values = {"1","2","3","place"}, Default = "1",
    Flag = "bc_totemability",
    Callback = function(v) totemSpamAbility = v end,
})
TotemL:AddSlider({
    Name = "Fire Rate", Min = 0.05, Max = 2, Default = 0.1,
    Decimals = 2, Suffix = " s", Flag = "bc_totemdelay",
    Callback = function(v) totemDelay = v end,
})

TotemR:AddInfobox({
    Title = "Ancient Totem",
    Text  = "Spams Ancient Totem abilities. Equip the totem before enabling. Ability 'place' spawns the totem on the ground.",
    Type  = "Info",
    Icon  = Hyperion.Lucide.Info,
})
end -- Main tab

-- ── MOVEMENT TAB ──────────────────────────────────────────────────────
do
local FlightL  = MovementTab:AddSection({ Name = "Flight", Side = "Left",  Group = "Movement" })
local PlayerR  = MovementTab:AddSection({ Name = "Player", Side = "Right", Group = "Movement" })
local MiscMovL = MovementTab:AddSection({ Name = "Misc",   Side = "Left",  Group = "Utility"  })

_FlightAPI = FlightL:AddToggle({
    Name = "Enable Flight", Default = false, Flag = "bc_flight",
    Callback = function(v)
        if _flightSyncLock then return end
        flightEnabled = v
        if v then startFlight() else stopFlight() end
    end,
})
FlightL:AddKeybind({
    Name = "Flight Toggle", Default = Enum.KeyCode.F, Flag = "bc_flightkey",
    Callback = function() toggleFlight() end,
})
FlightL:AddSlider({
    Name = "Flight Speed", Min = 10, Max = 300, Default = 60,
    Decimals = 0, Suffix = " u/s", Flag = "bc_flightspeed",
    Callback = function(v) flightSpeed = v end,
})

PlayerR:AddSlider({
    Name = "Walk Speed", Min = 16, Max = 200, Default = 16,
    Decimals = 0, Suffix = " u/s", Flag = "bc_walkspeed",
    Callback = function(v)
        walkSpeedValue = v
        if _uiReady then applyWalkSpeed() end
    end,
})
PlayerR:AddSlider({
    Name = "Jump Power", Min = 50, Max = 300, Default = 50,
    Decimals = 0, Flag = "bc_jumppower",
    Callback = function(v)
        jumpPowerValue = v
        if _uiReady then applyJumpPower() end
    end,
})
PlayerR:AddToggle({
    Name = "Noclip", Default = false, Flag = "bc_noclip",
    Callback = function(v)
        if v then startNoclip() else stopNoclip() end
    end,
})
end -- Movement tab

-- ── COMBAT TAB ────────────────────────────────────────────────────────
do
local MeleeL  = CombatTab:AddSection({ Name = "Melee",  Side = "Left",  Group = "Combat" })
local RangedR = CombatTab:AddSection({ Name = "Ranged", Side = "Right", Group = "Combat" })

_BladeAPI = MeleeL:AddToggle({
    Name = "Blade Speed", Default = false, Flag = "bc_blade",
    Callback = function(v)
        bladeActive = v
        if v then
            local tool = findBlade()
            if tool then
                startBlade()
            else
                bladeActive = false
                if _BladeAPI then _BladeAPI:Set(false) end
                Notify("Blade", "No blade found! Equip your melee weapon.", "Warning", 3)
            end
        else
            stopBlade()
        end
    end,
})
MeleeL:AddSlider({
    Name = "Swing Speed", Min = 1, Max = 999, Default = 99,
    Decimals = 0, Flag = "bc_swingspeed",
    Callback = function(v)
        swingSpeedValue = v
        if bladeActive then
            local tool = findBlade()
            if tool then
                local pss = tool:FindFirstChild("PhysicalSwingSpeed")
                if pss then pss.Value = v end
            end
        end
    end,
})
MeleeL:AddToggle({
    Name = "Hitbox Expander", Default = false, Flag = "bc_hitbox",
    Callback = function(v)
        hitboxActive = v
        if v then startHitbox() else stopHitbox() end
    end,
})
MeleeL:AddSlider({
    Name = "Hitbox Size", Min = 1, Max = 100, Default = 10,
    Decimals = 0, Suffix = " st", Flag = "bc_hitboxsize",
    Callback = function(v)
        hitboxSize = v
        if hitboxActive then originalSizes = {} end
    end,
})

_BowAPI = RangedR:AddToggle({
    Name = "Bow / Crossbow", Default = false, Flag = "bc_bow",
    Callback = function(v)
        bowActive = v
        if v then
            if applyBowStats() then
                startBow()
            else
                bowActive = false
                if _BowAPI then _BowAPI:Set(false) end
            end
        else
            stopBow()
        end
    end,
})
RangedR:AddSlider({
    Name = "Projectile Amount", Min = 1, Max = 500, Default = 1,
    Decimals = 0, Flag = "bc_projectiles",
    Callback = function(v)
        projectileAmount = v
        if bowActive then applyBowStats() end
    end,
})
RangedR:AddSlider({
    Name = "Phantom Bolts", Min = 1, Max = 500, Default = 1,
    Decimals = 0, Flag = "bc_phantombolts",
    Callback = function(v)
        phantomBoltAmount = v
        if bowActive then applyBowStats() end
    end,
})
end -- Combat tab

-- ── MINE TAB ──────────────────────────────────────────────────────────
do
local FarmL   = MineTab:AddSection({ Name = "Farm",    Side = "Left",  Group = "Mining" })
local OreR    = MineTab:AddSection({ Name = "Ores",    Side = "Right", Group = "Mining" })
local OreEspL = MineTab:AddSection({ Name = "Ore ESP",    Side = "Left",  Group = "OreESP" })
local OreEspR = MineTab:AddSection({ Name = "ESP Filter", Side = "Right", Group = "OreESP" })

FarmL:AddToggle({
    Name = "Fullbright", Default = false, Flag = "bc_fullbright",
    Callback = function(v)
        fullbrightEnabled = v
        setFullbright(v)
        Notify(v and "Fullbright ON" or "Fullbright OFF",
               v and "Caves are lit up." or "Lighting restored.", "Info", 2)
    end,
})
FarmL:AddToggle({
    Name = "Auto Farm", Default = false, Flag = "bc_autofarm",
    Callback = function(v)
        autoFarming = v
        if v then
            task.spawn(function()
                while autoFarming do
                    if not getChar() or not getHRP() then
                        stopMining() stopTeleportLock() task.wait(1) continue
                    end
                    local ores = findOres()
                    if #ores == 0 then
                        stopMining() stopTeleportLock() task.wait(2)
                    else
                        if currentIndex > #ores then currentIndex = 1 end
                        local ore = ores[currentIndex] currentIndex+=1
                        teleportToSide(ore.part)
                        local tool = equipPickaxe()
                        if not tool then stopTeleportLock() task.wait(1) continue end
                        task.wait(0.3)
                        startTeleportLock(ore.part)
                        startMining(tool)
                        waitForOreMined(ore.model, 60)
                        stopMining() stopTeleportLock() task.wait(0.2)
                    end
                end
                stopMining() stopTeleportLock()
            end)
        else
            stopMining() stopTeleportLock()
        end
    end,
})
FarmL:AddButton({
    Name = "Select All",
    Icon = Hyperion.Lucide.Check,
    Callback = function()
        selectedOres = {}
        for _,n in ipairs(oreList) do selectedOres[n] = true end
        if _OreMultiAPI then
            local sel = {}
            for _,n in ipairs(oreList) do sel[n] = true end
            _OreMultiAPI:Set(sel)
        end
        Notify("Ores", "All "..#oreList.." ores selected.", "Success", 2)
    end,
})
FarmL:AddButton({
    Name = "Deselect All",
    Icon = Hyperion.Lucide.X,
    Callback = function()
        selectedOres = {}
        if _OreMultiAPI then _OreMultiAPI:Set({}) end
        Notify("Ores", "All ores deselected.", "Info", 2)
    end,
})

_OreMultiAPI = OreR:AddMultiDropdown({
    Name     = "Select Ores",
    Values   = oreList,
    Default  = {},
    Flag     = "bc_ores",
    Callback = function(sel)
        selectedOres = {}
        -- sel is an array: {"Lead","Iron",...}
        for _,name in ipairs(sel) do selectedOres[name] = true end
        Notify("Ores", #sel.." ore(s) selected for farming.", "Info", 2)
    end,
})

OreEspL:AddToggle({
    Name = "Enable Ore ESP", Default = false, Flag = "bc_oreespenabled",
    Callback = function(v)
        oreEspEnabled = v
        if v then startOreESP() else stopOreESP() end
    end,
})
OreEspL:AddSlider({
    Name = "Max Distance", Min = 0, Max = 5000, Default = 300,
    Decimals = 0, Suffix = " st", Flag = "bc_orespdist",
    Callback = function(v) oreEspMaxDist = v end,
})
OreEspL:AddButton({
    Name = "ESP All Ores",
    Icon = Hyperion.Lucide.Eye,
    Callback = function()
        selectedOreEsp = {}
        local all = {}
        for _,n in ipairs(oreList) do all[n]=true end
        if _OreEspFilterAPI then _OreEspFilterAPI:Set(all) end
        if oreEspEnabled then clearAllOreESP() rebuildOreCache() end
        Notify("Ore ESP", "Showing all "..#oreList.." ore types.", "Success", 2)
    end,
})
OreEspL:AddButton({
    Name = "Clear ESP Filter",
    Icon = Hyperion.Lucide.X,
    Callback = function()
        selectedOreEsp = {}
        if _OreEspFilterAPI then _OreEspFilterAPI:Set({}) end
        if oreEspEnabled then clearAllOreESP() rebuildOreCache() end
        Notify("Ore ESP", "Filter cleared — showing all.", "Info", 2)
    end,
})

_OreEspFilterAPI = OreEspR:AddMultiDropdown({
    Name     = "Ore ESP Filter",
    Values   = oreList,
    Default  = {},
    Flag     = "bc_oreespfilter",
    Callback = function(sel)
        selectedOreEsp = {}
        -- sel is an array: {"Lead","Iron",...}
        for _,name in ipairs(sel) do selectedOreEsp[name] = true end
        if oreEspEnabled then clearAllOreESP() end
    end,
})

end -- Mine tab

-- ── BIOME TAB ─────────────────────────────────────────────────────────
do
local BiomeL = BiomeTab:AddSection({ Name = "Settings", Side = "Left",  Group = "Biome Hop" })
local BiomeR = BiomeTab:AddSection({ Name = "Targets",  Side = "Right", Group = "Biome Hop" })

_BiomeHopAPI = BiomeL:AddToggle({
    Name = "Biome Hop", Default = false, Flag = "bc_biomehop",
    Callback = function(v)
        biomeHopActive = v
        if v then startBiomeHop() else stopBiomeHop() end
    end,
})
BiomeL:AddSlider({
    Name = "Wait Time", Min = 1, Max = 240, Default = 20,
    Decimals = 0, Suffix = " s", Flag = "bc_biomewait",
    Callback = function(v) biomeHopWaitTime = v end,
})
BiomeL:AddSlider({
    Name = "Join Delay", Min = 1, Max = 120, Default = 45,
    Decimals = 0, Suffix = " s", Flag = "bc_biomejoin",
    Callback = function(v) biomeHopJoinDelay = v end,
})
BiomeL:AddTextbox({
    Name = "Webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Default = "",
    Flag = "bc_webhook",
    Callback = function(v) webhookUrl = v end,
})
_EggFarmAPI = BiomeL:AddToggle({
    Name = "Egg Farm", Default = false, Flag = "bc_eggfarm",
    Callback = function(v)
        eggFarmActive = v
        if v then startEggFarm() else stopEggFarm() end
    end,
})
BiomeL:AddSlider({
    Name = "Egg Farm Delay", Min = 0.1, Max = 5, Default = 0.5,
    Decimals = 1, Suffix = " s", Flag = "bc_eggdelay",
    Callback = function(v) eggFarmDelay = v end,
})

BiomeR:AddMultiDropdown({
    Name     = "Target Biomes",
    Values   = BIOME_LIST,
    Default  = {},
    Flag     = "bc_biometargets",
    Callback = function(sel)
        biomeHopTargets = {}
        -- sel is an array: {"Night","Grasslands",...}
        for _,name in ipairs(sel) do biomeHopTargets[name] = true end
    end,
})
end -- Biome tab

-- ── RAID TAB ──────────────────────────────────────────────────────────
do
local RaidL = RaidTab:AddSection({ Name = "Auto Raid", Side = "Left",  Group = "Raid" })

_RaidAPI = RaidL:AddToggle({
    Name = "Auto Raid", Default = false, Flag = "bc_autoraid",
    Callback = function(v)
        raidActive = v
        if v then startRaid() else stopRaid() end
    end,
})
RaidL:AddInfobox({
    Title = "Do Not Use",
    Text  = "Auto Raid is non-functional. Using it may cause you to be kicked or banned. Do not enable it.",
    Type  = "Error",
    Icon  = Hyperion.Lucide.XCircle,
})
end -- Raid tab

-- ── ESP TAB ───────────────────────────────────────────────────────────
do
local EspToggleL = EspTab:AddSection({ Name = "NPC ESP",  Side = "Left",  Group = "ESP"       })
local EspCfgR    = EspTab:AddSection({ Name = "Settings", Side = "Right", Group = "ESP"       })
local EspVisualL = EspTab:AddSection({ Name = "Visual",   Side = "Left",  Group = "ESP Settings" })
local EspVisualR = EspTab:AddSection({ Name = "Colors",   Side = "Right", Group = "ESP Settings" })

EspToggleL:AddToggle({ Name = "Enable NPC ESP", Default = false, Flag = "bc_esp",
    Callback = function(v) HESP.Enabled = v if v then startESP() else stopESP() end end })
EspToggleL:AddToggle({ Name = "Boxes",     Default = true,  Flag = "bc_espboxes",
    Callback = function(v) HESP.BoxEnabled = v end })
EspToggleL:AddToggle({ Name = "Names",     Default = true,  Flag = "bc_espnames",
    Callback = function(v) HESP.NameEnabled = v end })
EspToggleL:AddToggle({ Name = "HP Bar",    Default = true,  Flag = "bc_esphp",
    Callback = function(v) HESP.HealthBarEnabled = v end })
EspToggleL:AddToggle({ Name = "Distance",  Default = true,  Flag = "bc_espdist",
    Callback = function(v) HESP.DistanceEnabled = v end })
EspToggleL:AddToggle({ Name = "Tracers",   Default = false, Flag = "bc_esptracers",
    Callback = function(v) HESP.TracerEnabled = v end })
EspToggleL:AddToggle({ Name = "Head Dot",  Default = false, Flag = "bc_espheaddot",
    Callback = function(v) HESP.HeadDotEnabled = v end })
EspToggleL:AddToggle({ Name = "Skeleton",  Default = false, Flag = "bc_espbones",
    Callback = function(v) HESP.SkeletonEnabled = v end })
EspToggleL:AddToggle({ Name = "Highlight", Default = false, Flag = "bc_esphighlight",
    Callback = function(v) HESP.HighlightEnabled = v end })
EspToggleL:AddToggle({ Name = "Rainbow",   Default = false, Flag = "bc_esprainbow",
    Callback = function(v) HESP.RainbowEnabled = v end })

EspCfgR:AddDropdown({ Name = "Box Mode",
    Values = {"Square","Corner","3D"}, Default = "Corner", Flag = "bc_espboxmode",
    Callback = function(v) HESP.BoxMode = v end })
EspCfgR:AddDropdown({ Name = "HP Bar Style",
    Values = {"Periwinkle","Emerald","Peach","Normal"}, Default = "Periwinkle", Flag = "bc_esphpmode",
    Callback = function(v) HESP.HealthBarMode = v end })
EspCfgR:AddDropdown({ Name = "Tracer Origin",
    Values = {"Bottom","Center","Mouse"}, Default = "Bottom", Flag = "bc_esptracerorigin",
    Callback = function(v) HESP.TracerOrigin = v end })
EspCfgR:AddSlider({ Name = "Text Size", Min = 8, Max = 24, Default = 14,
    Decimals = 0, Suffix = " px", Flag = "bc_esptextsize",
    Callback = function(v) HESP.TextSize = v end })
EspCfgR:AddSlider({ Name = "Box Thickness", Min = 1, Max = 5, Default = 1,
    Decimals = 0, Flag = "bc_espboxthick",
    Callback = function(v) HESP.BoxThickness = v end })
EspCfgR:AddSlider({ Name = "HP Bar Thickness", Min = 1, Max = 6, Default = 2,
    Decimals = 0, Flag = "bc_esphbthick",
    Callback = function(v) HESP.HealthBarThickness = v end })
EspCfgR:AddSlider({ Name = "Tracer Thickness", Min = 1, Max = 5, Default = 1,
    Decimals = 0, Flag = "bc_esptracerthick",
    Callback = function(v) HESP.TracerThickness = v end })
EspCfgR:AddSlider({ Name = "Skeleton Thickness", Min = 1, Max = 5, Default = 1,
    Decimals = 0, Flag = "bc_espskelthick",
    Callback = function(v) HESP.SkeletonThickness = v end })
EspCfgR:AddSlider({ Name = "Max NPC Distance", Min = 100, Max = 10000, Default = 5000,
    Decimals = 0, Suffix = " st", Flag = "bc_espmaxdist",
    Callback = function(v) HESP.MaxDistance = v end })
EspCfgR:AddSlider({ Name = "Rainbow Speed", Min = 0.5, Max = 5, Default = 1,
    Decimals = 1, Flag = "bc_esprainbowspd",
    Callback = function(v) HESP.RainbowSpeed = v end })

EspVisualL:AddColorPicker({ Name = "Box / Text Color",
    Default = Color3.fromRGB(255,255,255), Flag = "bc_espboxcolor",
    Callback = function(c) HESP.BoxColor = c HESP.TextColor = c end })
EspVisualL:AddColorPicker({ Name = "Tracer Color",
    Default = Color3.fromRGB(255,255,255), Flag = "bc_esptracercolor",
    Callback = function(c) HESP.TracerColor = c end })
EspVisualR:AddColorPicker({ Name = "Highlight Fill",
    Default = Color3.fromRGB(128,0,255), Flag = "bc_esphlfill",
    Callback = function(c) HESP.HighlightFillColor = c end })
EspVisualR:AddColorPicker({ Name = "Highlight Outline",
    Default = Color3.fromRGB(255,255,255), Flag = "bc_esphlouline",
    Callback = function(c) HESP.HighlightOutlineColor = c end })
EspVisualR:AddSlider({ Name = "HL Fill Transparency", Min = 0, Max = 1, Default = 0.75,
    Decimals = 2, Flag = "bc_esphlfilltrans",
    Callback = function(v) HESP.HighlightFillTransparency = v end })
end -- ESP tab

-- ── SETTINGS TAB ──────────────────────────────────────────────────────
do
local ThemeL  = SettingsTab:AddSection({ Name = "Theme",  Side = "Left",  Group = "Config" })
local SystemR = SettingsTab:AddSection({ Name = "System", Side = "Right", Group = "Config" })

ThemeL:AddDropdown({
    Name    = "Color Theme",
    Values  = {"Purple","Midnight","Rose","Crimson","Sunset","Sakura","StarryNight","Aurora","Nebula","Ocean"},
    Default = "Purple",
    Flag    = "bc_theme",
    Callback = function(v)
        pcall(function() Hyperion:SetTheme(v) end)
        Notify("Theme", "Applied: "..v, "Success", 2)
    end,
})
ThemeL:AddKeybind({
    Name    = "Toggle Menu",
    Default = Enum.KeyCode.Insert,
    Flag    = "bc_menukeybind",
    Callback = function(v)
        if typeof(v) == "EnumItem" then
            _menuKeybind = v
        end
    end,
})

SystemR:AddButton({ Name = "Unload Script", Icon = Hyperion.Lucide.Power,
    Callback = function()
        -- Stop all active features
        autoFarming = false
        stopMining() stopTeleportLock()
        stopOreESP()
        stopESP()
        stopFlight()
        stopNoclip()
        stopBiomeHop()
        stopEggFarm()
        pcall(function() stopGodmode() end)
        pcall(function() stopBlade() end)
        pcall(function() stopBow() end)
        pcall(function() stopHitbox() end)
        pcall(function() stopAntiAfk() end)
        Notify("Hyperion", "Unloaded.", "Info", 2)
        task.wait(1)
        pcall(function() Window:Destroy() end)
    end,
})
SystemR:AddButton({ Name = "Server Info", Icon = Hyperion.Lucide.Users,
    Callback = function()
        Notify("Server", "Players: "..#Players:GetPlayers().."  |  PlaceId: "..game.PlaceId, "Info", 5)
    end,
})
SystemR:AddButton({ Name = "Rejoin", Icon = Hyperion.Lucide.RefreshCw,
    Callback = function()
        if #Players:GetPlayers() <= 1 then
            LocalPlayer:Kick("\nRejoining...")
            task.wait()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end,
})
end -- Settings tab

-- ===================== STARTUP =====================
_uiReady = true
startAntiAfk()
Notify("Hyperion", "Loaded! v"..VERSION, "Success", 4)
