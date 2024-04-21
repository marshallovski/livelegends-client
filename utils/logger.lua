local os = require "os"

return function(invoker, message)
    print(string.format("%s [%s]: %s", os.date("%H:%M:%S"), invoker, message))
end
