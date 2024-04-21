-- game config
require("conf")

local log = require("utils.logger")

local Gamestate = require("assets/lib/hump.gamestate")
local json = require("assets/lib/json")

local switch_scene = require('utils/switch_scene')
local get_local_user = require("utils/getlocaluser")
local write_json_file = require("utils/writejsonfile")

local function set_game_language()

    -- if player's data file is empty
    if love.filesystem.getInfo(config.path.playerdatafile).size <= 0 then
        write_json_file(config.path.playerdatafile, "{}")
    end

    -- if no default language set
    if not get_local_user(love).lang then
        log("main/set_game_language", "no default language set, setting language...")

        local playerdata_jsonfile = love.filesystem.read(config.path.playerdatafile)
        local player_data = json.decode(playerdata_jsonfile)

        player_data.lang = config.project.lang

        write_json_file(config.path.playerdatafile, json.encode(player_data))

        log("main/set_game_language", 'set language to ' .. config.project.lang)

    else
        local playerdata_jsonfile = love.filesystem.read(config.path.playerdatafile)
        local player_data = json.decode(playerdata_jsonfile)

        log("main/set_game_language", "game language is " .. player_data.lang)
    end
end

local function initgame()
    -- setting game icon
    local gameIcon = love.image.newImageData(config.project.icon)
    love.window.setIcon(gameIcon)

    love.window.setTitle(config.project.name)

    log("main/initgame", "starting " .. config.project.name)

    set_game_language()
end

function love.load()
    initgame()

    log("main/love.load", 'loading "loginmenu" scene')

    Gamestate.registerEvents()
    switch_scene('loginmenu', Gamestate)
end
