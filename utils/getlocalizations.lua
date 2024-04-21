require("conf")

return function(index)
    local localizations_folder = config.path.localizations

    local files = love.filesystem.getDirectoryItems(localizations_folder)

    -- replacing ".json" with empty space
    -- returns like "uk-UA"
    return string.gsub(files[index], ".json", "")
end
