-- game config
require("conf")

local log = require("utils.logger")

local get_local_user = require("utils/getlocaluser")
local write_json_file = require("utils/writejsonfile")
local set_key_json = require("utils/setkeyjson")
local localizations_count = require("utils/localizationscount")
local get_localizations = require("utils/getlocalizations")
local change_game_language = require("utils/change_game_language")
local i18n = require("utils/i18n")
local play_sound = require('utils/play_sound')
local show_message = require('utils/show_messagebox')
local switch_scene = require('utils/switch_scene')

local Gamestate = require('assets/lib/hump.gamestate')
local json = require("assets/lib/json")
local loveframes = require("assets/lib/loveframes")
local tween = require("assets/lib/tween")
local http = require("socket.http")
local mime = require("mime")

registermenu = {}

function registermenu:enter()
    log("registermenu/load", 'loaded "registermenu" scene')

    font = love.graphics.newFont(config.loveframes.font, 13)
    love.graphics.setFont(font)

    client_lang = get_local_user().lang

    local imagebuttonfont = love.graphics.newFont(config.loveframes.font, 15)

    -- Change fonts on all registered skins
    for _, skin in pairs(loveframes.skins) do
        skin.controls.smallfont = font
        skin.controls.imagebuttonfont = imagebuttonfont
    end

    play_sound('menubg.ogg', true)

    -- Setting skin
    loveframes.config["ACTIVESKIN"] = config.loveframes.skin

    loveframes.GetActiveSkin().directives.text_default_font = font
    local title = i18n('registermenu_title', client_lang, love)
    local message = i18n("registermenu_registerframe-registersuccess_desc", client_lang, love)

    ll_logobig = love.graphics.newImage(config.path.textures .. "llLogoBig.ltx")

    local frame = loveframes.Create("frame")
    frame:SetName(i18n("registermenu_title", client_lang, love))
    frame:SetSize(500, 180)
    frame:SetPos(150, 300)
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)

    -- username label
    local username_label = loveframes.Create("text", frame)
    username_label:SetPos(5, 35)
    username_label:SetText(i18n("registermenu_registerframe-username_label", client_lang, love))

    -- username input
    local username_input = loveframes.Create("textinput", frame)
    username_input:SetPos(125, 30)
    username_input:SetWidth(370)
    username_input:SetFont(font)

    -- password label
    local password_label = loveframes.Create("text", frame)
    password_label:SetPos(5, 70)
    password_label:SetText(i18n("registermenu_registerframe-password_label", client_lang, love))

    -- password input
    local password_input = loveframes.Create("textinput", frame)
    password_input:SetPos(125, 65)
    password_input:SetWidth(370)
    password_input:SetFont(font)

    -- reg button
    local donebutton = loveframes.Create("button", frame)
    donebutton:SetPos(5, 150)
    donebutton:SetWidth(243)
    donebutton:SetText(i18n("registermenu_registerframe-regbtn_label", client_lang, love))

    donebutton.OnClick = function()
        local username = username_input:GetValue()
        local password = password_input:GetValue()

        if string.len(username) == 0 or string.len(password) == 0 then
            return nil
        end

        -- registering
        local b, c, h = http.request(string.format("%s/api/register/?username=%s&password=%s&clientVersion=%s",
            config.server.hostname, username, password, config.project.version))

        if b then
            local res = json.decode(b)

            -- client version mismatch
            if res.reason and res.reason == 'll_version-mismatch' then
                log('loginmenu/login-version_mismatch', string.format('[%s], %s', res.priority, res.message))
            end

            -- if server's respond with no "ok" - creating error message
            if not res.ok then
                -- user already registered
                if res.llcode == 21 then
                    local error_title = i18n("registermenu_registerframe-errorframe_title", client_lang)
                    local error_message = i18n('registermenu_registerframe-errorframe_account_registered-desc',
                        client_lang)

                    return show_message(error_title, error_message, true, loveframes, {
                        w = 300,
                        h = 85
                    })
                end

                -- username is too short
                if res.llcode == 33 then
                    local error_title = i18n("registermenu_registerframe-errorframe_title", client_lang)

                    local error_message = i18n('registermenu_registerframe-errorframe_username_short-desc-p1',
                        client_lang) .. res.nicknameMinLength ..
                                              i18n('registermenu_registerframe-errorframe_username_short-desc-p2',
                            client_lang)

                    return show_message(error_title, error_message, true, loveframes, {
                        w = 300,
                        h = 85
                    })
                end

                -- username is too long
                if res.llcode == 34 then
                    local error_title = i18n("registermenu_registerframe-errorframe_title", client_lang)

                    local erroreturn r_message = i18n('registermenu_registerframe-errorframe_username_long-desc-p1',
                        client_lang) .. res.nicknameMaxLength ..
                                              i18n('registermenu_registerframe-errorframe_username_long-desc-p2',
                            client_lang)

                    return show_message(error_title, error_message, true, loveframes, {
                        w = 300,
                        h = 85
                    })
                end

                -- password is too short
                if res.llcode == 35 then
                    local error_title = i18n("registermenu_registerframe-errorframe_title", client_lang)

                    local error_message = i18n('registermenu_registerframe-errorframe_password_short-desc-p1',
                        client_lang) .. res.pswMinLength ..
                                              i18n('registermenu_registerframe-errorframe_password_short-desc-p2',
                            client_lang)

                    return show_message(error_title, error_message, true, loveframes, {
                        w = 300,
                        h = 85
                    })
                end

                -- password is too long
                if res.llcode == 36 then
                    local error_title = i18n("registermenu_registerframe-errorframe_title", client_lang)

                    local error_message = i18n('registermenu_registerframe-errorframe_password_long-desc-p1',
                        client_lang) .. res.pswMaxLength ..
                                              i18n('registermenu_registerframe-errorframe_password_long-desc-p2',
                            client_lang)

                    return show_message(error_title, error_message, true, loveframes, {
                        w = 300,
                        h = 85
                    })
                end

                local error_title = i18n("registermenu_registerframe-errorframe_title", client_lang)
                local error_message = i18n('registermenu_registerframe-errorframe_desc', client_lang)

                return show_message(error_title, error_message, true, loveframes, {
                    w = 300,
                    h = 85
                })
            else
                log("registermenu/register", "registered as " .. username)

                local title = i18n('registermenu_title', client_lang)
                local message = i18n("registermenu_registerframe-registersuccess_desc", client_lang)
                show_message(title, message, true, loveframes, {
                    w = 300,
                    h = 100
                })

                log("registermenu/register", 'switching to "loginmenu" scene')

                switch_scene('loginmenu', Gamestate)
            end

            -- if server's not responding/off for maintenance
        else
            show_message(i18n("registermenu_registerframe-errorframe_title", client_lang),
                i18n("registermenu_serveroffline", client_lang), true, loveframes)
        end

    end

    -- checking for server availaibility
    local server_status = http.request(string.format("%s/api/server/status", config.server.hostname))
    local server_status_json = json.decode(server_status or '{}')

    if server_status then
        log('registermenu/server_status',
            string.format('server: %s, server load: %i%% (%s), server RAM load: %s (%s)', config.server.hostname,
                server_status_json.ram.loadPercent, server_status_json.ram.loadAdapted,
                server_status_json.server.loadAdapted, server_status_json.server.loadInMB))

    else
        log('registermenu/server_status', string.format('server %s is offline', config.server.hostname))
        frame:Remove()

        local error_message = i18n("registermenu_serveroffline", client_lang)
        show_message(error_message, error_message, false, loveframes)
    end

    -- button for switching scene to login menu
    local loginbutton = loveframes.Create("button", frame)
    loginbutton:SetPos(252, 150)
    loginbutton:SetWidth(243)
    loginbutton:SetText(i18n("registermenu_loginbtn-title", client_lang))
    loginbutton.OnClick = function()
        love.audio.stop()
        switch_scene('loginmenu', Gamestate)
    end
end

function registermenu:update(dt)
    loveframes.update(dt)
    
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
                log("registermenu/exit", "exiting")

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

function registermenu:draw()
    loveframes.draw()

    -- drawing LiveLegends logo
    love.graphics.draw(ll_logobig, 100, 100, 0, 0.5, 0.5)
end

return registermenu
