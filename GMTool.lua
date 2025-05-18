local GMTool = {}
local tabs = {}

-- Main Frame
GMToolMainFrame = CreateFrame("Frame", "GMToolMainFrame", UIParent, "BasicFrameTemplateWithInset")
GMToolMainFrame:SetSize(600, 400)  -- Breiter gemacht (von 400 auf 600)
GMToolMainFrame:SetPoint("CENTER")
GMToolMainFrame.title = GMToolMainFrame:CreateFontString(nil, "OVERLAY")
GMToolMainFrame.title:SetFontObject("GameFontHighlightLarge")
GMToolMainFrame.title:SetPoint("TOP", GMToolMainFrame, "TOP", 0, -10)
GMToolMainFrame.title:SetText("GMTool by Pikaachaan")  -- hier geändert


-- Tabs (hier nur erweitert: neuer Tab "Extras" angehängt)
local tabNames = { "Teleport", "NPC", "Player", "Tickets", "Cheats", "Extras" }
local tabButtons = {}

for i, name in ipairs(tabNames) do
    local btn = CreateFrame("Button", "GMToolTabButton"..name, GMToolMainFrame, "UIPanelButtonTemplate")
    btn:SetSize(90, 25)  -- Breiter, damit mehr Platz (von 70 auf 90)
    btn:SetPoint("TOPLEFT", GMToolMainFrame, "TOPLEFT", 15 + (i-1)*95, -40)  -- Abstand entsprechend vergrößert
    btn:SetText(name)
    tabButtons[name] = btn

    local content = CreateFrame("Frame", "GMTool"..name.."Tab", GMToolMainFrame)
    content:SetSize(570, 310)  -- Breiter (von 370 auf 570)
    content:SetPoint("TOPLEFT", GMToolMainFrame, "TOPLEFT", 15, -70)
    content:Hide()

    tabs[i] = { name = name, button = btn, content = content }
end

local function ShowTab(name)
    for _, t in ipairs(tabs) do
        if t.name == name then
            t.content:Show()
            t.button:Disable()
        else
            t.content:Hide()
            t.button:Enable()
        end
    end
end

for _, t in ipairs(tabs) do
    t.button:SetScript("OnClick", function()
        ShowTab(t.name)
    end)
end

ShowTab("Teleport")

-- ==== TELEPORT TAB ====  
do
    local content = tabs[1].content

    local zones = {
        {name = "Boralus", command = ".tele Boralus"},
        {name = "Dalaran", command = ".tele Dalaran"},
        {name = "Dalaran Legion", command = ".tele Dalaranlegion"},
        {name = "Darnassus", command = ".tele Darnassus"},
        {name = "Dazar'alor", command = ".tele Dazaralor"},
        {name = "Ironforge", command = ".tele Ironforge"},
        {name = "Orgrimmar", command = ".tele Orgrimmar"},
        {name = "Oribos", command = ".tele Oribos"},
        {name = "Shattrath", command = ".tele Shattrath"},
        {name = "Shrine of Seven Stars", command = ".tele Shrineofsevenstars"},
        {name = "Silvermoon", command = ".tele Silvermoon"},
        {name = "Stormwind", command = ".tele Stormwind"},
        {name = "Stormshield - PvP Map (Ashran)", command = ".tele Stormshield"},
        {name = "The Exodar", command = ".tele Theexodar"},
        {name = "Thunder Bluff", command = ".tele Thunderbluff"},
        {name = "Undercity", command = ".tele Undercity"},
    }

    local dropdown = CreateFrame("Frame", "GMToolTeleportDropDown", content, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", 10, -10)
    UIDropDownMenu_SetWidth(dropdown, 200)
    UIDropDownMenu_SetText(dropdown, zones[1].name)

    local selectedZone = zones[1]

    UIDropDownMenu_Initialize(dropdown, function(self, level)
        for _, zone in ipairs(zones) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = zone.name
            info.func = function()
                selectedZone = zone
                UIDropDownMenu_SetText(dropdown, zone.name)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    local teleportBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    teleportBtn:SetSize(150, 25)
    teleportBtn:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 0, -10)
    teleportBtn:SetText("Teleport")
    teleportBtn:SetScript("OnClick", function()
        SendChatMessage(selectedZone.command, "SAY")
    end)
end

-- ==== NPC TAB ====  
do
    local content = tabs[2].content

    local npcInput = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
    npcInput:SetSize(100, 25)
    npcInput:SetPoint("TOPLEFT", 10, -10)
    npcInput:SetAutoFocus(false)
    npcInput:SetNumeric(true)
    npcInput:SetText("")
    npcInput:ClearFocus()

    -- Label über dem Eingabefeld
    local npcLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    npcLabel:SetPoint("BOTTOMLEFT", npcInput, "TOPLEFT", 0, 2)
    npcLabel:SetText("NPC ID:")

    local function getNpcID()
        local text = npcInput:GetText()
        if text and text ~= "" then
            return text
        else
            print("❌ Bitte eine gültige NPC-ID eingeben.")
            return nil
        end
    end

    local spawnBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    spawnBtn:SetSize(100, 25)
    spawnBtn:SetPoint("TOPLEFT", npcInput, "BOTTOMLEFT", 0, -10)
    spawnBtn:SetText("Spawn")
    spawnBtn:SetScript("OnClick", function()
        local npcID = getNpcID()
        if npcID then
            SendChatMessage(".npc add temp " .. npcID, "SAY")
            print("✅ Spawne NPC mit ID: " .. npcID)
        end
    end)

    local deleteBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    deleteBtn:SetSize(100, 25)
    deleteBtn:SetPoint("LEFT", spawnBtn, "RIGHT", 10, 0)
    deleteBtn:SetText("Lösche Ziel")
    deleteBtn:SetScript("OnClick", function()
        SendChatMessage(".npc delete", "SAY")
        print("🗑️ Ziel-NPC gelöscht.")
    end)

    local infoBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    infoBtn:SetSize(100, 25)
    infoBtn:SetPoint("TOPLEFT", spawnBtn, "BOTTOMLEFT", 0, -10)
    infoBtn:SetText("NPC Info")
    infoBtn:SetScript("OnClick", function()
        SendChatMessage(".npc info", "SAY")
        print("ℹ️ NPC-Info gesendet.")
    end)
end


-- ==== PLAYER TAB ====  
do
    local content = tabs[3].content

    local reviveBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    reviveBtn:SetSize(120, 25)
    reviveBtn:SetPoint("TOPLEFT", 10, -10)
    reviveBtn:SetText("Revive")
    reviveBtn:SetScript("OnClick", function()
        SendChatMessage(".revive", "SAY")
        print("💀 Spieler wurde wiederbelebt.")
    end)

    -- Gold Eingabe
    local goldInput = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
    goldInput:SetSize(100, 25)
    goldInput:SetPoint("TOPLEFT", reviveBtn, "BOTTOMLEFT", 0, -20)
    goldInput:SetAutoFocus(false)
    goldInput:SetNumeric(true)
    goldInput:SetText("")
    goldInput:SetMaxLetters(9)

    local goldLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    goldLabel:SetPoint("BOTTOMLEFT", goldInput, "TOPLEFT", 0, 2)
    goldLabel:SetText("Gold Menge:")

    local giveGoldBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    giveGoldBtn:SetSize(120, 25)
    giveGoldBtn:SetPoint("LEFT", goldInput, "RIGHT", 10, 0)
    giveGoldBtn:SetText("Gold geben")
    giveGoldBtn:SetScript("OnClick", function()
        local amount = goldInput:GetText()
        if amount ~= nil and amount ~= "" and tonumber(amount) then
            SendChatMessage(".modify money " .. amount, "SAY")
            print("💰 Gold gegeben: " .. amount)
        else
            print("❌ Bitte eine gültige Goldzahl eingeben.")
        end
    end)

    -- ===== Quest hinzufügen =====
    local questAddInput = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
    questAddInput:SetSize(100, 25)
    questAddInput:SetPoint("TOPLEFT", goldInput, "BOTTOMLEFT", 0, -40)
    questAddInput:SetAutoFocus(false)
    questAddInput:SetNumeric(true)
    questAddInput:SetText("")

    local questAddLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    questAddLabel:SetPoint("BOTTOMLEFT", questAddInput, "TOPLEFT", 0, 2)
    questAddLabel:SetText("Quest-ID (Add):")

    local questAddBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    questAddBtn:SetSize(120, 25)
    questAddBtn:SetPoint("LEFT", questAddInput, "RIGHT", 10, 0)
    questAddBtn:SetText("Quest add")
    questAddBtn:SetScript("OnClick", function()
        local questID = questAddInput:GetText()
        if questID and questID ~= "" and tonumber(questID) then
            SendChatMessage(".quest add " .. questID, "SAY")
            print("🧾 Quest hinzugefügt: " .. questID)
        else
            print("❌ Bitte eine gültige Quest-ID eingeben.")
        end
    end)

local content = tabs[3].content




end


-- ==== TICKETS TAB ====  
do
    local content = tabs[4].content

    local ticketListBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    ticketListBtn:SetSize(150, 25)
    ticketListBtn:SetPoint("TOPLEFT", 10, -10)
    ticketListBtn:SetText("Liste Tickets")
    ticketListBtn:SetScript("OnClick", function()
        SendChatMessage(".ticket list", "SAY")
        print("📋 Ticketliste abgerufen.")
    end)

    local ticketCloseBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    ticketCloseBtn:SetSize(150, 25)
    ticketCloseBtn:SetPoint("TOPLEFT", ticketListBtn, "BOTTOMLEFT", 0, -10)
    ticketCloseBtn:SetText("Ticket schließen")
    ticketCloseBtn:SetScript("OnClick", function()
        SendChatMessage(".ticket close", "SAY")
        print("✅ Ticket geschlossen.")
    end)

    -- Weitere Ticket Buttons
    local ticketBugBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    ticketBugBtn:SetSize(150, 25)
    ticketBugBtn:SetPoint("TOPLEFT", ticketCloseBtn, "BOTTOMLEFT", 0, -10)
    ticketBugBtn:SetText("Ticket Bug")
    ticketBugBtn:SetScript("OnClick", function()
        SendChatMessage(".ticket bug", "SAY")
        print("🐞 Ticket Bug erstellt.")
    end)

    local ticketComplaintBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    ticketComplaintBtn:SetSize(150, 25)
    ticketComplaintBtn:SetPoint("TOPLEFT", ticketBugBtn, "BOTTOMLEFT", 0, -10)
    ticketComplaintBtn:SetText("Ticket Complaint")
    ticketComplaintBtn:SetScript("OnClick", function()
        SendChatMessage(".ticket complaint", "SAY")
        print("⚠️ Ticket Beschwerde erstellt.")
    end)

    local ticketResetBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    ticketResetBtn:SetSize(150, 25)
    ticketResetBtn:SetPoint("TOPLEFT", ticketComplaintBtn, "BOTTOMLEFT", 0, -10)
    ticketResetBtn:SetText("Ticket Reset")
    ticketResetBtn:SetScript("OnClick", function()
        SendChatMessage(".ticket reset", "SAY")
        print("🔄 Ticket zurückgesetzt.")
    end)

    local ticketSuggestionBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    ticketSuggestionBtn:SetSize(150, 25)
    ticketSuggestionBtn:SetPoint("TOPLEFT", ticketResetBtn, "BOTTOMLEFT", 0, -10)
    ticketSuggestionBtn:SetText("Ticket Suggestion")
    ticketSuggestionBtn:SetScript("OnClick", function()
        SendChatMessage(".ticket suggestion", "SAY")
        print("💡 Ticket Vorschlag erstellt.")
    end)

    local ticketToggleSystemBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    ticketToggleSystemBtn:SetSize(150, 25)
    ticketToggleSystemBtn:SetPoint("TOPLEFT", ticketSuggestionBtn, "BOTTOMLEFT", 0, -10)
    ticketToggleSystemBtn:SetText("Toggle System")
    ticketToggleSystemBtn:SetScript("OnClick", function()
        SendChatMessage(".ticket togglesystem", "SAY")
        print("🔄 Ticket System umgeschaltet.")
    end)
end

-- ==== CHEATS TAB ====  
do
    local content = tabs[5].content

    local flyOnBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    flyOnBtn:SetSize(100, 25)
    flyOnBtn:SetPoint("TOPLEFT", 10, -10)
    flyOnBtn:SetText("Fly ON")
    flyOnBtn:SetScript("OnClick", function()
        SendChatMessage(".gm fly on", "SAY")
        print("✈️ Flugmodus aktiviert.")
    end)

    local flyOffBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    flyOffBtn:SetSize(100, 25)
    flyOffBtn:SetPoint("LEFT", flyOnBtn, "RIGHT", 10, 0)
    flyOffBtn:SetText("Fly OFF")
    flyOffBtn:SetScript("OnClick", function()
        SendChatMessage(".gm fly off", "SAY")
        print("🛬 Flugmodus deaktiviert.")
    end)

    local gmOnBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    gmOnBtn:SetSize(100, 25)
    gmOnBtn:SetPoint("TOPLEFT", flyOnBtn, "BOTTOMLEFT", 0, -10)
    gmOnBtn:SetText("GM ON")
    gmOnBtn:SetScript("OnClick", function()
        SendChatMessage(".gm on", "SAY")
        print("💪 GM Modus aktiviert.")
    end)

    local gmOffBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    gmOffBtn:SetSize(100, 25)
    gmOffBtn:SetPoint("LEFT", gmOnBtn, "RIGHT", 10, 0)
    gmOffBtn:SetText("GM OFF")
    gmOffBtn:SetScript("OnClick", function()
        SendChatMessage(".gm off", "SAY")
        print("🛑 GM Modus deaktiviert.")
    end)

    -- Neue Buttons für learn commands
    local btnTexts = {
        {text = "Learn All Crafts", cmd = ".learn all crafts"},
        {text = "Learn All Default", cmd = ".learn all default"},
        {text = "Learn All recipes", cmd = ".learn all recipes"},
        {text = "Learn All debug", cmd = ".learn all debug"},
        {text = "Learn All Talents", cmd = ".learn all talents"},
        {text = "Learn Blizzard", cmd = ".learn all blizzard"},
    }

    local lastBtn = gmOnBtn
    local rowOffset = 40  -- Abstand zwischen den Button-Reihen

    for i, info in ipairs(btnTexts) do
        local btn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
        btn:SetSize(150, 25)

        -- Zwei Buttons pro Reihe
        local xOffset = ((i-1) % 2) * 160
        local yOffset = math.floor((i-1) / 2) * rowOffset

        btn:SetPoint("TOPLEFT", lastBtn, "BOTTOMLEFT", xOffset, -10 - yOffset)
        btn:SetText(info.text)
        btn:SetScript("OnClick", function()
            SendChatMessage(info.cmd, "SAY")
            print("✅ Befehl gesendet: " .. info.cmd)
        end)
    end
end



-- ==== EXTRAS TAB ====  
do
    local content = tabs[6].content

    -- Item geben
    local itemInput = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
    itemInput:SetSize(100, 25)
    itemInput:SetPoint("TOPLEFT", 10, -10)
    itemInput:SetAutoFocus(false)
    itemInput:SetNumeric(true)
    itemInput:SetText("")

    local itemLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    itemLabel:SetPoint("BOTTOMLEFT", itemInput, "TOPLEFT", 0, 2)
    itemLabel:SetText("Item ID:")

    local giveItemBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    giveItemBtn:SetSize(100, 25)
    giveItemBtn:SetPoint("LEFT", itemInput, "RIGHT", 10, 0)
    giveItemBtn:SetText("Item geben")
    giveItemBtn:SetScript("OnClick", function()
        local itemID = itemInput:GetText()
        if itemID ~= nil and itemID ~= "" and tonumber(itemID) then
            SendChatMessage(".additem " .. itemID, "SAY")
            print("🎁 Item gegeben: " .. itemID)
        else
            print("❌ Bitte eine gültige Item-ID eingeben.")
        end
    end)

    -- Level ändern
    local levelInput = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
    levelInput:SetSize(100, 25)
    levelInput:SetPoint("TOPLEFT", itemInput, "BOTTOMLEFT", 0, -50)
    levelInput:SetAutoFocus(false)
    levelInput:SetNumeric(true)
    levelInput:SetText("")

    local levelLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    levelLabel:SetPoint("BOTTOMLEFT", levelInput, "TOPLEFT", 0, 2)
    levelLabel:SetText("Neues Level:")

    local setLevelBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    setLevelBtn:SetSize(100, 25)
    setLevelBtn:SetPoint("LEFT", levelInput, "RIGHT", 10, 0)
    setLevelBtn:SetText("Level ändern")
    setLevelBtn:SetScript("OnClick", function()
        local level = levelInput:GetText()
        if level ~= nil and level ~= "" and tonumber(level) then
            SendChatMessage(".level " .. level, "SAY")
            print("📈 Level geändert auf: " .. level)
        else
            print("❌ Bitte ein gültiges Level eingeben.")
        end
    end)

    -- Zu Spieler teleportieren
    local playerInput = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
    playerInput:SetSize(150, 25)
    playerInput:SetPoint("TOPLEFT", levelInput, "BOTTOMLEFT", 0, -50)
    playerInput:SetAutoFocus(false)
    playerInput:SetText("")

    local playerLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    playerLabel:SetPoint("BOTTOMLEFT", playerInput, "TOPLEFT", 0, 2)
    playerLabel:SetText("Spielername:")

    local tpPlayerBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    tpPlayerBtn:SetSize(150, 25)
    tpPlayerBtn:SetPoint("TOPLEFT", playerInput, "BOTTOMLEFT", 0, -10)
    tpPlayerBtn:SetText("Zu Spieler teleportieren")
    tpPlayerBtn:SetScript("OnClick", function()
        local playerName = playerInput:GetText()
        if playerName ~= nil and playerName ~= "" then
            SendChatMessage(".appear " .. playerName, "SAY")
            print("🚀 Teleportiere zu Spieler: " .. playerName)
        else
            print("❌ Bitte einen gültigen Spielernamen eingeben.")
        end
    end)

    -- Unsichtbar-Modus mit zwei Buttons nebeneinander, breiter
    local invisibleOnBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    invisibleOnBtn:SetSize(110, 30)  -- breiter und höher
    invisibleOnBtn:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 10, 10)
    invisibleOnBtn:SetText("Unsichtbar AN")
    invisibleOnBtn:SetScript("OnClick", function()
        SendChatMessage(".gm visible off", "SAY")
        print("👻 Unsichtbar-Modus aktiviert.")
    end)

    local invisibleOffBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    invisibleOffBtn:SetSize(110, 30)  -- gleiche Größe
    invisibleOffBtn:SetPoint("LEFT", invisibleOnBtn, "RIGHT", 15, 0) -- mit etwas Abstand
    invisibleOffBtn:SetText("Unsichtbar AUS")
    invisibleOffBtn:SetScript("OnClick", function()
        SendChatMessage(".gm visible on", "SAY")
        print("👻 Unsichtbar-Modus deaktiviert.")
    end)
end

GMToolMainFrame:SetMovable(true)
GMToolMainFrame:EnableMouse(true)
GMToolMainFrame:RegisterForDrag("LeftButton")
GMToolMainFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
GMToolMainFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

-- Slash Command /gmtool registrieren
SLASH_GMTOOL1 = "/gmtool"
SlashCmdList["GMTOOL"] = function()
    if GMToolMainFrame:IsShown() then
        GMToolMainFrame:Hide()
    else
        GMToolMainFrame:Show()
    end
end