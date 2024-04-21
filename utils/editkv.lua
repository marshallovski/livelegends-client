return function (str, key, newValue)
    if not str then
        return error("No string provided!")
    end

    if not key then
        return error("No key provided!")
    end

    local newStr = ""
    local found = false

    for k, v in string.gmatch(str, "(%w+)=(%w+)") do
        if k == key then
            v = newValue
            found = true
        end

        newStr = newStr .. k .. "=" .. v .. "|"
    end

    if not found then
        newStr = newStr .. key .. "=" .. newValue .. "|"
    end

    return newStr:sub(1, -2) -- видаляємо останній символ "|"
end


