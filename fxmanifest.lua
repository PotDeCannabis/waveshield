fx_version "adamant"
game "gta5"

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    "configs/config_cl.lua",
    "configs/config_sv.lua",
    "server.lua",
    "config.lua",
}

client_scripts {
    "configs/config_cl.lua",
    "aDetections.lua",
    "client.lua",
}