-- game config
require("conf")

local log = require("utils.logger")

local get_local_user = require("utils/getlocaluser")
local write_json_file = require("utils/writejsonfile")
local set_key_json = require("utils/setkeyjson")
local i18n = require("utils/i18n")
local play_sound = require('utils/play_sound')
local show_message = require('utils/show_messagebox')

local Gamestate = require('assets/lib/hump.gamestate')
local json = require("assets/lib/json")
local loveframes = require("assets/lib/loveframes")
local tween = require("assets/lib/tween")
local http = require("socket.http")

empty_scene = {}

function empty_scene:enter()
    log("empty_scene/load", 'loaded "empty_scene" scene');

    font = love.graphics.newFont(config.loveframes.font, 13)
    love.graphics.setFont(font)

    client_lang = get_local_user(love).lang

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
end

function empty_scene:update(dt)
    loveframes.update(dt)
    if empty_scene.tween then
        if empty_scene.tween:update(dt) then
            empty_scene.tween = nil
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
                log("empty_scene/exit", "exiting")

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

function empty_scene:draw()
    loveframes.draw()
end

return empty_scene