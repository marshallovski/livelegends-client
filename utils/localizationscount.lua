local json = require("assets/lib/json")
require("conf")

return function()
    local localizations_folder = config.path.localizations

    if love.filesystem.getInfo(localizations_folder) then
        local localizations = love.filesystem.getDirectoryItems(localizations_folder)

        return table.getn(localizations)
    end
end