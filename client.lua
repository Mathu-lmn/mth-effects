-- create a menu for the effects
local effects_menu = RageUI.CreateMenu("Effects", "Effects Menu")
effects_menu:SetStyleSize(200)
effects_menu:DisplayPageCounter(true)
local results_menu = RageUI.CreateSubMenu(effects_menu, "Results", "Results of the search")
results_menu:DisplayPageCounter(true)
local dict_menu = RageUI.CreateSubMenu(effects_menu, "Dictionary", "Effects of the dictionary")
dict_menu:DisplayPageCounter(true)
local settings_menu = RageUI.CreateSubMenu(effects_menu, "Settings", "Effects settings")
local open = false
local results = {}
local dict = nil
effects_menu.Closed = function()
    open = false
end

local path_to_animations = "config.json"

local fileJson = LoadResourceFile(GetCurrentResourceName(), path_to_animations)
if fileJson then
    effects_list = json.decode(fileJson)
end

local x, y, z = 0, 0, 0
local scale = 1.0

RegisterCommand("effects", function()
    OpenEffectsMenu()
end)

function OpenEffectsMenu()
    if open then
        open = false
        RageUI.Visible(effects_menu, false)
        return
    else
        open = true
        x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
        RageUI.Visible(effects_menu, true)
        CreateThread(function()
            while open do
                RageUI.IsVisible(effects_menu, function()
                    -- add a button to search an effect
                    RageUI.Button("Search for an effect", nil, { RightLabel = "→→→" }, true, {
                        onSelected = function()
                            local result = KeyboardInput("Search for an effect")
                            if result then
                                -- when the search is done, display all the results in a list
                                results = {}
                                -- for each sublist, check if any result
                                for k, v in pairs(effects_list) do
                                    for k2, v2 in pairs(v.EffectNames) do
                                        if string.find(string.lower(v2), string.lower(result)) then
                                            table.insert(results, { v.DictionaryName, v2 })
                                        end
                                    end
                                end
                            end
                        end
                    }, results_menu)
                    RageUI.Button("Settings", nil, { RightLabel = "→→→" }, true, {}, settings_menu)
                    RageUI.Separator("List of dictionaries")
                    -- add a button for each effect
                    for k, v in pairs(effects_list) do
                        RageUI.Button(v.DictionaryName, nil, { RightLabel = ">" }, true, {
                            onSelected = function()
                                dict = k
                            end
                        }, dict_menu)
                    end
                end)
                RageUI.IsVisible(results_menu, function()
                    -- add a button for each result
                    if #results > 0 then
                        for k, v in pairs(results) do
                            RageUI.Button(v[2], nil, { RightLabel = ">" }, true, {
                                onSelected = function()
                                    -- when the button is selected, play the effect
                                    PlayEffect(v[1], v[2])
                                end
                            })
                        end
                    else
                        RageUI.Separator("No results found")
                    end
                end)
                RageUI.IsVisible(dict_menu, function()
                    dict_menu:SetSubtitle(effects_list[dict].DictionaryName)
                    -- add a button for each effect
                    for k, v in pairs(effects_list[dict].EffectNames) do
                        RageUI.Button(v, nil, { RightLabel = "→→→" }, true, {
                            onSelected = function()
                                -- when the button is selected, play the effect
                                PlayEffect(effects_list[dict].DictionaryName, v)
                            end
                        })
                    end
                end)
                RageUI.IsVisible(settings_menu, function()
                    -- add a button to set the position of the effect at the player's position
                    RageUI.Button("Set the position", nil, { RightLabel = "→→→" }, true, {
                        onSelected = function()
                            x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
                        end
                    })
                    -- add a button to manage the Z position of the effect
                    RageUI.Button("Z : ".. tonumber(z), "Set the Z position", { RightLabel = "→→→" }, true, {
                        onSelected = function()
                            local result = KeyboardInput("Z position")
                            if result and tonumber(result) then
                                z = tonumber(result) + 0.0
                            end
                        end
                    })
                    -- add a button to set the scale of the effect
                    RageUI.Button("Scale", scale, { RightLabel = "→→→" }, true, {
                        onSelected = function()
                            local result = KeyboardInput("Scale")
                            if result and tonumber(result) then
                                scale = tonumber(result) + 0.0
                            end
                        end
                    })
                    -- show the position of the effect
                    DrawMarker(28, x, y, z, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 255, 0, 0, 255, 0, 0, 0, 0)
                end)
                Wait(0)
            end
        end)
    end
end

function PlayEffect(dict, effect)
    if x == nil or y == nil or z == nil then
        x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
    end
    -- load the effect
    if not HasNamedPtfxAssetLoaded(dict) then
        RequestNamedPtfxAsset(dict)
        while not HasNamedPtfxAssetLoaded(dict) do
            Wait(0)
        end
    end
    UseParticleFxAssetNextCall(dict)
    -- create the effect in front of the player
    local effect_display = StartParticleFxLoopedAtCoord(effect, x, y, z, 0.0, 0.0, 0.0, scale, false, false, false, false)
    -- delete the effect after 10 seconds
    SetTimeout(10000, function()
        StopParticleFxLooped(effect_display, 0)
    end)
end

function KeyboardInput(text)
	local result = nil
	AddTextEntry("CUSTOM_AMOUNT", text)
	DisplayOnscreenKeyboard(1, "CUSTOM_AMOUNT", '', "", '', '', '', 255)
	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Wait(1)
	end
	if UpdateOnscreenKeyboard() ~= 2 then
		result = GetOnscreenKeyboardResult()
		Citizen.Wait(1)
	else
		Citizen.Wait(1)
	end
	return result
end