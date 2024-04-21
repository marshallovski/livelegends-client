require('conf')

return function(filename, Gamestate, scene_args)
    assert(type(filename) == "string", "parameter must be a string, received: " .. type(filename))

    local path = config.path.scenes .. filename

    if love.filesystem.getInfo(path .. ".lua") then
        Gamestate.switch(require(path), scene_args or nil)
    else
        return error(string.format('Scene "%s" is not found on path "%s"', filename, config.path.scenes))
    end
end
