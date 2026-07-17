if not game:IsLoaded() then
    game.Loaded:Wait()
end

local executor = string.lower(tostring(identifyexecutor()))
if executor == "xeno" or executor == "solara" then
    if not getgenv().allowpotatoexecutor then
        game:GetService("Players").LocalPlayer:Kick(
            "daydreamer doesnt work on " .. executor
                .. " and you were kicked in order to prevent potential bans, as your executor lacks some functions necessary to bypass anticheats.\n\n"
                .. "to bypass this warning and load daydreamer anyways, add this line of code before the script. it is NOT our fault if you get anticheat banned.\n\n"
                .. "getgenv().allowpotatoexecutor = true\n(copied to clipboard)"
        )
        setclipboard("getgenv().allowpotatoexecutor = true")
        error("incompatible executor (" .. executor .. ")")
    end

    warn("your executor (" .. executor .. ") is not supported and probably wont work with daydreamer. do NOT report any bugs, they won't be fixed.")
end

local players = cloneref(game:GetService("Players"))
local localPlayer = players.LocalPlayer
while not localPlayer do
    task.wait()
    localPlayer = players.LocalPlayer
end

local gameId = game.GameId
while gameId == 0 do
    task.wait()
    gameId = game.GameId
end

local supportedGames = {
    [9186719164] = { script_id = "f4ed3e2c509c1afa907a0f0545ca3b18" },
    [7395930870] = { script_id = "d92c078507b9006e9f194943f5fee191" },
    [9965411707] = { script_id = "9aa013ea312ff05589f1050b7c1dbf52" },
    [10039338037] = { script_id = "8dcaeb073a1d775ba880415322aec8c4" },
    [9272693470] = { script_id = "c153f998000eeeaec6fa26f3dff8bcdb" },
    [6035872082] = { script_id = "5c0fa57251c165aa484cab27a52aa424" },
    [9910245722] = true,
    [117533937949084] = true,
}

if not (supportedGames[gameId] or supportedGames[game.PlaceId]) then
    local message = "this game is not supported (GameId " .. tostring(gameId) .. ", PlaceId " .. tostring(game.PlaceId) .. ")"
    warn(message)
    pcall(function()
        cloneref(game:GetService("StarterGui")):SetCore("SendNotification", {
            Title = "daydreamer",
            Text = "this game is not supported.",
            Duration = 8,
        })
    end)
    return
end

local keyFile = "key.daydreamer"

local function trimKey(value)
    if typeof(value) == "string" then
        local key = value:gsub("%s+", "")
        if #key > 0 then
            return key
        end
    end
end

local function findKey()
    local environment = getgenv()
    local key = trimKey(_G.script_key) or trimKey(environment.script_key)
        or trimKey(_G.dd_key) or trimKey(environment.dd_key)

    if key then
        return key
    end

    if typeof(shared) == "table" then
        key = trimKey(shared.script_key) or trimKey(shared.dd_key)
        if key then
            return key
        end
    end

    if type(isfile) == "function" and isfile(keyFile) and type(readfile) == "function" then
        local ok, savedKey = pcall(readfile, keyFile)
        if ok then
            return trimKey(savedKey)
        end
    end
end

local key = findKey()
if key then
    _G.dd_key = key
    getgenv().dd_key = key
    _G.script_key = key
    getgenv().script_key = key
end

-- Authentication and any required key handling are provided by the API loader.
local ok, err = pcall(function()
    return loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/1a8d82c87bd4c8405eaf98ddcbc89b08.lua"))()
end)

if not ok then
    warn("daydreamer API Load Error: " .. tostring(err))
end
