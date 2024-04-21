local write_json_file = require("utils/writejsonfile")
local json = require("assets/lib/json")

return function(file, key, value)
    if not file then
        return error("No file provided!")
    end

    if not key then
        return error("No key provided!")
    end

    local json_file = love.filesystem.read(file)
    local json_data = json.decode(json_file)

    json_data[key] = value

    write_json_file(file, json.encode(json_data))
end
