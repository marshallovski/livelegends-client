local json = require("assets/lib/json")
require("conf")

return function(token, lang)
    if not token then
        return error("No token provided!")
    end
    
    if not lang then
        return token
    end

    if not love then
        return error("No love provided!")
    end

    -- if localization file is exists
    local localization_file = config.path.localizations .. lang .. ".json"

    if love.filesystem.getInfo(localization_file) then
        local strings = json.decode(love.filesystem.read(localization_file))

        return strings.tokens[token] or token
    end
end
