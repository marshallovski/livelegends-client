-- showing message box using loveframes
return function(title, message, closable, loveframes, box_size)
    if not loveframes then
        error('No loveframes provided!')
    end

    if box_size and type(box_size) ~= 'table' then
        error("expected argument of type table, got " .. type(box_size))
    end

    local size = {}

    if not box_size then
        size.w = 150
        size.h = 50
    else
        size.w = box_size.w
        size.h = box_size.h
    end

    local messageframe = loveframes.Create("frame")
    messageframe:SetName(title)
    messageframe:SetSize(size.w or 150, size.h or 50)
    messageframe:Center()
    messageframe:SetDraggable(false)
    messageframe:SetModal(true)

    if closable then
        messageframe:ShowCloseButton(true)
    else
        messageframe:ShowCloseButton(false)
    end

    local messageframe_text = loveframes.Create("text", messageframe)
    messageframe_text:SetSize(size.w or 100, size.h - 50 or 50)
    messageframe_text:Center()
    messageframe_text:SetText(message)
end
