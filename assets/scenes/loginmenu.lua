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

loginmenu = {}

function loginmenu:enter()
    log("loginmenu/load", 'loaded "loginmenu" scene')

    local font = love.graphics.newFont(config.loveframes.font, 13)
    love.graphics.setFont(font)

    play_sound('menubg.ogg', true)

    client_lang = get_local_user(love).lang

    local imagebuttonfont = love.graphics.newFont(config.loveframes.font, 15)

    -- Change fonts on all registered skins
    for _, skin in pairs(loveframes.skins) do
        skin.controls.smallfont = font
        skin.controls.imagebuttonfont = imagebuttonfont
    end

    -- Setting skin
    loveframes.config["ACTIVESKIN"] = config.loveframes.skin

    loveframes.GetActiveSkin().directives.text_default_font = font

    love.graphics.setBackgroundColor(65 / 255, 65 / 255, 65 / 255)

    ll_logobig = love.graphics.newImage(config.path.textures .. "llLogoBig.ltx")

    -- change language selector (multichoice)
    local change_lang_frame = loveframes.Create("frame")
    change_lang_frame:SetName(i18n("loginmenu_changelang-title", client_lang))
    change_lang_frame:SetSize(210, 60)
    change_lang_frame:SetPos(585, 530)
    change_lang_frame:ShowCloseButton(false)
    change_lang_frame:SetDraggable(false)

    -- selector 
    local change_lang_multichoice = loveframes.Create("multichoice", change_lang_frame)
    change_lang_multichoice:SetPos(5, 30)

    for i = 1, localizations_count() do
        change_lang_multichoice:AddChoice(get_localizations(i))
    end

    change_lang_multichoice.OnChoiceSelected = function()
        local selected_lang = change_lang_multichoice:GetValue()

        change_game_language(selected_lang)

        log("loginmenu/change_lang_multichoice", string.format("changed language to %s, exiting now", selected_lang))
        love.window.close()
    end

    -- main frame
    local frame = loveframes.Create("frame")
    frame:SetName(i18n("loginmenu_title", client_lang))
    frame:SetSize(500, 180)
    frame:SetPos(150, 300)
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)

    -- username label
    local username_label = loveframes.Create("text", frame)
    username_label:SetPos(5, 35)
    username_label:SetText(i18n("loginmenu_loginframe_username-label", client_lang))

    -- username input
    local username_input = loveframes.Create("textinput", frame)
    username_input:SetPos(125, 30)
    username_input:SetWidth(370)
    username_input:SetFont(font)

    -- password label
    local password_label = loveframes.Create("text", frame)
    password_label:SetPos(5, 70)
    password_label:SetText(i18n("loginmenu_loginframe_password-label", client_lang))

    -- password input
    local password_input = loveframes.Create("textinput", frame)
    password_input:SetPos(125, 65)
    password_input:SetWidth(370)
    password_input:SetFont(font)

    -- login button
    local donebutton = loveframes.Create("button", frame)
    donebutton:SetPos(5, 150)
    donebutton:SetWidth(243)
    donebutton:SetText(i18n("loginmenu_loginframe_loginbtn", client_lang))

    local b, c, h = http.request(string.format("%s/api/server/status", config.server.hostname))

    donebutton.OnClick = function()
        local username = username_input:GetValue()
        local password = password_input:GetValue()

        if string.len(username) == 0 or string.len(password) == 0 then
            return nil
        end

        -- logging in
        local login_response = http.request(string.format("%s/api/login/?username=%s&password=%s&clientVersion=%s",
            config.server.hostname, username, password, config.project.version))

        if login_response then
            local res = json.decode(login_response)

            -- if server's respond with no "ok" - creating error message
            if not res.ok then
                -- if user is not found
                if res.llcode == 11 then
                    local error_title = i18n("loginmenu_loginerrorframe_title", client_lang)
                    local error_message = i18n("loginmenu_usernotfound", client_lang)
                    return show_message(error_title, error_message, true, loveframes, {
                        w = 300,
                        h = 70
                    })
                end

                -- if user is banned
                if res.llcode == 14 then
                    local error_title = i18n("loginmenu_loginerrorframe_title", client_lang)
                    local error_message = i18n("loginmenu_userbanned", client_lang)
                    return show_message(error_title, error_message, true, loveframes, {
                        w = 300,
                        h = 70
                    })
                end

                -- if username or password are wrong
                if res.llcode == 12 then
                    local error_title = i18n("loginmenu_loginerrorframe_title", client_lang)
                    local error_message = i18n("loginmenu_accountdetailswrong", client_lang)
                    return show_message(error_title, error_message, true, loveframes, {
                        w = 300,
                        h = 70
                    })
                end

                local error_title = i18n("loginmenu_loginerrorframe_title", client_lang)
                local error_message = i18n("loginmenu_loginframe-errorframe_desc", client_lang)

                log('loginmenu/login', res.message)
                return show_message(error_title, error_message, true, loveframes)
            else
                if res.ok then
                    -- logging in, writing user's login and password to file

                    if res.reason and res.reason == 'll_version-mismatch' then
                        log('loginmenu/login-version_mismatch', string.format('[%s], %s', res.priority, res.message))

                        local error_message = username .. ', ' ..
                                                  i18n('loginmenu_versionmismatch-desc-p1', client_lang) ..
                                                  res.clientVersion .. ', ' ..
                                                  i18n('loginmenu_versionmismatch-desc-p2', client_lang) ..
                                                  res.clientVersionLatest

                        show_message(i18n("loginmenu_versionmismatch-title", client_lang), error_message, true,
                            loveframes, {
                                w = 300,
                                h = 150
                            })
                    end

                    log("loginmenu/login", "logged in as " .. username)

                    local player_data_file = config.path.playerdatafile
                    local player_lang = client_lang

                    -- clearing player data file content before writing new data
                    write_json_file(player_data_file, "{}")

                    local player_new_data = {
                        ll_username = mime.b64(username),
                        ll_password = mime.b64(password),
                        lang = player_lang
                    }

                    -- writing player data (username, password)
                    write_json_file(player_data_file, player_new_data, true)

                    local welcome_title = i18n('loginmenu_loginsuccess-title', client_lang)
                    local welcome_message = i18n('loginmenu_loginsuccess-desc', client_lang) .. res.username ..
                                                '!'
                    show_message(welcome_title, welcome_message, true, loveframes, {
                        w = 350,
                        h = 70
                    })

                    love.audio.stop()
                    loveframes.RemoveAll()

                    switch_scene('selectservermenu', Gamestate)
                end
            end

            -- if server's not responding/off for maintenance
        else
            local errorframe = loveframes.Create("frame")
            errorframe:SetName(i18n("loginmenu_loginerrorframe_title", client_lang))
            errorframe:SetSize(250, 50)
            errorframe:Center()
            errorframe:SetModal(true)

            local errorframe_errortext = loveframes.Create("text", errorframe)
            errorframe_errortext:SetSize(150, 50)
            errorframe_errortext:Center()
            errorframe_errortext:SetText(i18n("loginmenu_serveroffline", client_lang))
        end
    end

    -- button for switching scene to register menu
    local regbutton = loveframes.Create("button", frame)
    regbutton:SetPos(252, 150)
    regbutton:SetWidth(243)
    regbutton:SetText(i18n("loginmenu_regbtn", client_lang))
    regbutton.OnClick = function()
        love.audio.stop()
        
        switch_scene('registermenu', Gamestate)
    end

    -- checking for server availaibility
    local server_status = http.request(string.format("%s/api/server/status", config.server.hostname))
    local server_status_json = json.decode(server_status or '{}')

    if server_status then
        log('loginmenu/server_status',
            string.format('server: %s, server load: %i%% (%s), server RAM load: %s (%s)', config.server.hostname,
                server_status_json.ram.loadPercent, server_status_json.ram.loadAdapted,
                server_status_json.server.loadAdapted, server_status_json.server.loadInMB))

    else
        log('loginmenu/server_status', string.format('server %s is offline', config.server.hostname))
        frame:Remove()

        local error_message = i18n("loginmenu_serveroffline", client_lang)
        show_message(error_message, error_message, false, loveframes)
    end
end

function loginmenu:update(dt)
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
                log("loginmenu/exit", "exiting")

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

function loginmenu:draw()
    loveframes.draw()

    -- drawing LiveLegends logo
    love.graphics.draw(ll_logobig, 100, 100, 0, 0.5, 0.5)
end

return loginmenu
