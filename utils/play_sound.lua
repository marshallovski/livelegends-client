require('conf')
local log = require('utils/logger')

return function(path, repeatSound)
    if not path then
        error('No path to sound file provided!')
    end

    if not love then
        error('No love provided!')
    end

    if not config.dev.disableSound then
        local sound = love.audio.newSource(config.path.sounds .. path, "stream")

        if repeatSound then
            sound:setLooping(true)
        end

        love.audio.play(sound)

    else 
        log('utils/play_sound', '`config.dev.disableSound` is active, disabled all sound')
    end 
    
end
