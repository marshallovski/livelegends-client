local json = require("assets/lib/json")

return function(file, content, encode_to_json)
    if not file then
        return error("No JSON file provided!")
    end

    local json_data

    if encode_to_json then
        json_data = json.encode(content)
    else
        json_data = content
    end

    local json_file = io.open(file, "w")
    json_file:write(json_data)
    json_file:close()
end
