function love.conf(t)
    t.releases = {
        version = "11.5",
        title = "Live Legends",
        package = "net.emberlive.livelegends",
        loveVersion = "11.5",
        author = "EmberLive UA",
        email = nil,
        description = "Live Legends - The best growing MMORPG!",
        homepage = nil,
        identifier = nil, -- The project Uniform Type Identifier (string)
        excludeFileList = {"dist", "tips"},
        releaseDirectory = "dist/"
    }
end

config = {
    project = {
        name = "Live Legends",
        icon = "assets/textures/llLogosmall.ltx",
        version = "ll_indev-private",
        lang = "en-US" -- default language, don't change it
    },
    dev = {
        disableSound = true
    },
    server = {
        hostname = "http://localhost:3110"
    },
    path = {
        textures = "assets/textures/",
        sounds = "assets/sounds/",
        scenes = "assets/scenes/",
        data = "assets/data/",
        playerdatafile = "assets/data/playerdata.json",
        localizations = "assets/data/i18n/"
    },
    loveframes = {
        font = "assets/fonts/OpenSans-Regular.ttf",
        skin = "Default"
    }
}

