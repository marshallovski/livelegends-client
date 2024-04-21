local json = require("assets/lib/json")
require("conf")

return function()
    if not love then
        return error("No love provided!")
    end

    local localuser = json.decode(love.filesystem.read(config.path.playerdatafile))
    return localuser
end
