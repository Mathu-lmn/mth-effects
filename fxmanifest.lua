fx_version 'adamant'
game 'gta5'

name "mth-effects"
description "Developer script to play every GTA effects"
author "Mathu_lmn"
version "1.0.0"

files {'config.json'}

client_scripts {
    'RageUI/RMenu.lua',
    'RageUI/menu/RageUI.lua',
    'RageUI/menu/Menu.lua',
    'RageUI/menu/MenuController.lua',
    'RageUI/components/*.lua',
    'RageUI/menu/elements/*.lua',
    'RageUI/menu/items/*.lua',
    'RageUI/menu/panels/*.lua',
    'RageUI/menu/windows/*.lua',
    'client.lua',
}