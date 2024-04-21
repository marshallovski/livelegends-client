return function(content, requestedItem)

    if not requestedItem then
        error('No requested item provided!')
    end

    if not content then
        error('No data provided!')
    end

    local itemsArray = {}

    for item in string.gmatch(content, "[^|]+") do
        table.insert(itemsArray, item)
    end

    for _, item in ipairs(itemsArray) do
        local data = {}

        for k, v in string.gmatch(item, "([^=]+)=([^=]+)") do
            data[k] = v
        end

        if data[requestedItem] then
            return data[requestedItem]
        else
            return nil
        end
    end
end
