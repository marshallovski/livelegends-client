local json = require("assets/lib/json")
local set_key_json = require("utils/setkeyjson")
require("conf")

return function(lang)
    if not lang then
        return error("No language provided!")
    end

    set_key_json(config.path.playerdatafile, "lang", lang)
end
