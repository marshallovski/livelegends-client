-- game config
require("conf")

local log = require("utils.logger")

local get_local_user = require("utils/getlocaluser")
local write_json_file = require("utils/writejsonfile")
local set_key_json = require("utils/setkeyjson")
local i18n = require("utils/i18n")
local play_sound = require('utils/play_sound')
local show_message = require('utils/show_messagebox')
local switch_scene = require('utils/switch_scene')

local Gamestate = require('assets/lib/hump.gamestate')
local json = require("assets/lib/json")
local loveframes = require("assets/lib/loveframes")
local tween = require("assets/lib/tween")
local http = require("socket.http")

selectservermenu = {}

function selectservermenu:enter()
    log("selectservermenu/load", 'loaded "selectservermenu" scene');

    font = love.graphics.newFont(config.loveframes.font, 13)
    love.graphics.setFont(font)

    client_lang = get_local_user(love).lang

    play_sound('menubg.ogg', true)

    local imagebuttonfont = love.graphics.newFont(config.loveframes.font, 15)

    -- Setting skin
    loveframes.config["ACTIVESKIN"] = config.loveframes.skin

    -- Change fonts on all registered skins
    for _, skin in pairs(loveframes.skins) do
        skin.controls.smallfont = font
        skin.controls.imagebuttonfont = imagebuttonfont
    end

    loveframes.GetActiveSkin().directives.text_default_font = font

    love.graphics.setBackgroundColor(65 / 255, 65 / 255, 65 / 255)

    local master_server_req = http.request(string.format("%s/api/server/status", config.server.hostname))
    local master_server_res = json.decode(master_server_req)

    if master_server_res.ok then
        local function refresh_servers_list()
            list:Clear()

            local servers_list_req = http.request(string.format("%s/api/server/list", config.server.hostname))
            local servers_list_res = json.decode(servers_list_req)

            if servers_list_res.ok then
                for _, server in ipairs(servers_list_res.servers) do
                    local players = server.playersCurrent .. '/' .. server.playersMax

                    list:AddRow(server.region, server.name, players, server.url)
                end

            else
                show_message('error', servers_list_res.message, true, loveframes)
            end
        end

        -- servers list container
        list = loveframes.Create("columnlist")
        list:SetPos(5, 30)
        list:SetSize(490, 265)
        list:AddColumn("Region")
        list:AddColumn("Name")
        list:AddColumn("Players")
        list:AddColumn("Join")
        list:Center()

        list.OnRowClicked = function(parent, row, rowdata)
            love.audio.stop()
            loveframes.RemoveAll()
            switch_scene('sps_scene', Gamestate, string.format('server=%s|init_scene=lobby|init_args={"clientVersion": "%s"}', rowdata[4], config.project.version))
        end

        refresh_servers_list()

        -- refresh button
        local refresh_servers_button = loveframes.Create('button', list)
        refresh_servers_button:SetText('Refresh')
        refresh_servers_button.OnClick = function()
            refresh_servers_list()
        end

    else
        show_message(i18n('selectservermenu_masterserveroffline-title', client_lang),
            i18n('selectservermenu_masterserveroffline-desc', client_lang), true, loveframes, {
                w = 300,
                h = 70
            })
    end
end

function selectservermenu:update(dt)
    loveframes.update(dt)
    if selectservermenu.tween then
        if selectservermenu.tween:update(dt) then
            selectservermenu.tween = nil
        end
    end

    function love.mousepressed(x, y, button)
        loveframes.mousepressed(x, y, button)
        local menu = loveframes.hoverobject and loveframes.hoverobject.menu_example
        if menu and button == 2 then
            menu:SetPos(x, y)
            menu:SetVisible(true)
            menu:MoveToTop()
        end
    end

    function love.mousereleased(x, y, button)
        loveframes.mousereleased(x, y, button)
    end

    function love.wheelmoved(x, y)
        loveframes.wheelmoved(x, y)
    end

    function love.keypressed(key, isrepeat)
        loveframes.keypressed(key, isrepeat)

        if key == "f1" then
            local debug = loveframes.config["DEBUG"]
            loveframes.config["DEBUG"] = not debug
        end

        if key == "escape" then
            if loveframes.config["DEBUG"] then
                log("selectservermenu/exit", "exiting")

                love.window.close()
            end
        end
    end

    function love.keyreleased(key)
        loveframes.keyreleased(key)
    end

    function love.textinput(text)
        loveframes.textinput(text)
    end
end

function selectservermenu:draw()
    loveframes.draw()
end

return selectservermenu
