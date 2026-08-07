if not game:IsLoaded() then
    game.Loaded:Wait()
end

local exec = string.lower(tostring(identifyexecutor()))
if exec == "xeno" or exec == "solara" then
    if not getgenv().allowpotatoexecutor then
        game:GetService("Players").LocalPlayer:Kick("daydreamer doesnt work on "..exec.." and you were kicked in order to prevent potential bans, as your executor lacks some functions necessary to bypass anticheats.\n    \n to bypass this warning and load daydreamer anyways, add this line of code before the script. it is NOT our fault if you get anticheat banned.\n    \n getgenv().allowpotatoexecutor = true \n(copied to clipboard)\n   ")
        setclipboard("getgenv().allowpotatoexecutor = true")
        error("incompatible executor (" .. exec .. ")")
    elseif getgenv().allowpotatoexecutor then
        warn("your executor (" .. exec .. ") is not supported and probably wont work with daydreamer. do NOT report any bugs, they won't be fixed.")
    end
end

local ps = cloneref(game:GetService'Players')
local lp = ps.LocalPlayer

while not lp do
    task.wait()

    lp = ps.LocalPlayer
end

local current_game_id = game.GameId

while current_game_id == 0 do
    task.wait()

    current_game_id = game.GameId
end

local games = {
    -- sailorpiece
    [9186719164] = {
        script_id = 'f4ed3e2c509c1afa907a0f0545ca3b18',
    },

    -- sell lemons
    [7395930870] = {
        script_id = 'd92c078507b9006e9f194943f5fee191',
    },

    -- noob incremental
    [9965411707] = {
        script_id = '9aa013ea312ff05589f1050b7c1dbf52',
    },

    -- rivals
    [6035872082] = {
        script_id = '5c0fa57251c165aa484cab27a52aa424',
    },

    -- iron soul: dungeon (same validate/save/expire path as rivals)
    [9910245722] = {
        script_id = 'ed269f18e29271b20906a3be3053ed6c',
    },
}

local game_config = games[current_game_id] or games[game.PlaceId]

if game_config then
    local key_file = 'key.daydreamer'

    local function save_key(key)
        if type(writefile) == 'function' then
            pcall(writefile, key_file, key)
        end
    end
    local function clear_key()
        if type(delfile) == 'function' then
            pcall(delfile, key_file)
        elseif type(writefile) == 'function' then
            pcall(writefile, key_file, '')
        end
    end
    local function load_key()
        if type(isfile) == 'function' and isfile(key_file) and type(readfile) == 'function' then
            local success, key_content = pcall(readfile, key_file)

            if success and type(key_content) == 'string' then
                key_content = key_content:gsub('%s+', '')

                if #key_content > 0 then
                    return key_content
                end
            end
        end

        return nil
    end
    local function clear_env_key()
        _G.dd_key = nil
        _G.script_key = nil

        pcall(function()
            getgenv().dd_key = nil
            getgenv().script_key = nil
        end)
    end

    -- luarmor codes that mean this specific key is dead, so the cached file has to go
    local dead_key_codes = {
        KEY_EXPIRED = 'key expired, get a new one',
        KEY_BANNED = 'key is blacklisted',
        KEY_HWID_LOCKED = 'key locked to another hwid',
        KEY_INCORRECT = 'key doesnt exist',
        KEY_INVALID = 'bad key format',
    }

    -- returns is_valid, reason, keep_cached_key
    local function check_key(api_lib, key)
        if type(api_lib.check_key) ~= 'function' then
            -- older library build without the endpoint, let load_script decide
            return true
        end

        local check_success, status = pcall(api_lib.check_key, key)

        if not check_success or type(status) ~= 'table' or type(status.code) ~= 'string' then
            -- api unreachable or shape changed, dont throw away a key over it
            return true
        end

        if status.code == 'KEY_VALID' then
            return true
        end

        local dead_reason = dead_key_codes[status.code]

        if dead_reason then
            return false, dead_reason, false
        end

        -- SCRIPT_ID_*, INVALID_EXECUTOR, SECURITY_ERROR, TIME_ERROR, UNKNOWN_ERROR: not the keys fault
        return false, string.lower(tostring(status.message or status.code)), true
    end

    local function run_loader(key)
        -- Set these before either Luarmor entry path; project loaders read script_key from the env.
        _G.dd_key = key
        getgenv().dd_key = key
        _G.script_key = key
        getgenv().script_key = key

        local api_success, api_lib = pcall(function()
            return loadstring(game:HttpGet'https://sdkapi-public.luarmor.net/library.lua', '@daydreamer.thread')()
        end)

        if not api_success or not api_lib then
            return false, 'api load error'
        end

        api_lib.script_id = game_config.script_id

        local is_valid, reason, keep_cached = check_key(api_lib, key)

        if not is_valid then
            -- a stale key must not linger in the file or the globals, or the prompt never gets a chance
            if not keep_cached then
                clear_key()
            end

            clear_env_key()

            return false, reason or 'invalid key'
        end

        if key and #key > 0 then
            save_key(key)
        end

        task.spawn(function()
            local load_success, load_error = pcall(function()
                api_lib.load_script()
            end)

            if not load_success then
                warn('loader failed for some reason: ' .. tostring(load_error))
            end
        end)

        return true
    end
    local function get_env_key()
        local function validate(candidate_key)
            if typeof(candidate_key) == 'string' and #candidate_key:gsub('%s+', '') > 0 then
                return candidate_key:gsub('%s+', '')
            end

            return nil
        end

        local env_key = _G.script_key or getgenv().script_key

        if validate(env_key) then
            return validate(env_key)
        end
        if typeof(shared) == 'table' and shared.script_key then
            if validate(shared.script_key) then
                return validate(shared.script_key)
            end
        end

        for env_level = 1, 10 do
            local env_success, env_table = pcall(getfenv, env_level)

            if env_success and typeof(env_table) == 'table' and env_table.script_key then
                if validate(env_table.script_key) then
                    return validate(env_table.script_key)
                end
            end
        end

        local fenv_success, fenv_key = pcall(function()
            return key
        end)

        if fenv_success and validate(fenv_key) then
            return validate(fenv_key)
        end

        env_key = _G.dd_key or getgenv().dd_key

        if validate(env_key) then
            return validate(env_key)
        end
        if typeof(shared) == 'table' and shared.dd_key then
            if validate(shared.dd_key) then
                return validate(shared.dd_key)
            end
        end

        for env_level = 1, 10 do
            local env_success, env_table = pcall(getfenv, env_level)

            if env_success and typeof(env_table) == 'table' and env_table.dd_key then
                if validate(env_table.dd_key) then
                    return validate(env_table.dd_key)
                end
            end
        end

        local final_success, final_key = pcall(function()
            return key
        end)

        if final_success and validate(final_key) then
            return validate(final_key)
        end

        return nil
    end


    local function prompt_key(initial_message)
        local ui_font = (pcall(function()
            return Enum.Font.Inter
        end) and Enum.Font.Inter or Enum.Font.Gotham)
        local ui_parent = type(gethui) == 'function' and gethui() or game:GetService('CoreGui')

        -- re-running the loader should replace the previous prompt, not stack a second one
        local genv = (getgenv and getgenv()) or _G
        if genv.dd_loader_prompt_gui then
            pcall(function() genv.dd_loader_prompt_gui:Destroy() end)
        end

        local screen_gui = Instance.new('ScreenGui', ui_parent)
        genv.dd_loader_prompt_gui = screen_gui

        screen_gui.Name = 'daydreamer loader (if ur seeing this dont skid my ui pls) @ [' .. os.time() .. ']'
        screen_gui.ResetOnSpawn = false

        local main_frame = Instance.new'Frame'

        main_frame.AnchorPoint = Vector2.new(0.5, 0.5)
        main_frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        main_frame.Size = UDim2.new(0, 0, 0, 40)
        main_frame.AutomaticSize = Enum.AutomaticSize.X
        main_frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        main_frame.BorderSizePixel = 0
        main_frame.Active = true
        main_frame.Parent = screen_gui

        local frame_corner = Instance.new'UICorner'

        frame_corner.CornerRadius = UDim.new(1, 0)
        frame_corner.Parent = main_frame

        local layout = Instance.new'UIListLayout'

        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)
        layout.Parent = main_frame

        local padding = Instance.new'UIPadding'

        padding.PaddingLeft = UDim.new(0, 18)
        padding.PaddingRight = UDim.new(0, 8)
        padding.Parent = main_frame

        local input_service, is_dragging, drag_input, drag_start_pos, drag_start_frame_pos = (cloneref(game:GetService'UserInputService'))

        main_frame.InputBegan:Connect(function(input_obj)
            if input_obj.UserInputType == Enum.UserInputType.MouseButton1 or input_obj.UserInputType == Enum.UserInputType.Touch then
                is_dragging = true
                drag_start_pos = input_obj.Position
                drag_start_frame_pos = main_frame.Position

                input_obj.Changed:Connect(function()
                    if input_obj.UserInputState == Enum.UserInputState.End then
                        is_dragging = false
                    end
                end)
            end
        end)
        main_frame.InputChanged:Connect(function(input_obj)
            if input_obj.UserInputType == Enum.UserInputType.MouseMovement or input_obj.UserInputType == Enum.UserInputType.Touch then
                drag_input = input_obj
            end
        end)
        input_service.InputChanged:Connect(function(input_obj)
            if input_obj == drag_input and is_dragging then
                local drag_offset = input_obj.Position - drag_start_pos

                main_frame.Position = UDim2.new(drag_start_frame_pos.X.Scale, drag_start_frame_pos.X.Offset + drag_offset.X, drag_start_frame_pos.Y.Scale, drag_start_frame_pos.Y.Offset + drag_offset.Y)
            end
        end)

        local title_label = Instance.new'TextLabel'

        title_label.LayoutOrder = 1
        title_label.Size = UDim2.new(0, 0, 1, 0)
        title_label.AutomaticSize = Enum.AutomaticSize.X
        title_label.BackgroundTransparency = 1
        title_label.RichText = true
        title_label.Text = '<font color="#fbeee6">daydreamer.</font>'
        title_label.TextSize = 14
        title_label.Font = ui_font
        title_label.Parent = main_frame

        local key_input = Instance.new'TextBox'

        key_input.LayoutOrder = 2
        key_input.Size = UDim2.new(0, 140, 0, 26)
        key_input.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        key_input.BorderSizePixel = 0
        key_input.Text = ''
        key_input.PlaceholderText = 'enter key...'
        key_input.TextColor3 = Color3.fromRGB(255, 255, 255)
        key_input.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
        key_input.TextSize = 12
        key_input.Font = ui_font
        key_input.ClearTextOnFocus = false
        key_input.ClipsDescendants = true
        key_input.Parent = main_frame

        local input_corner = Instance.new'UICorner'

        input_corner.CornerRadius = UDim.new(1, 0)
        input_corner.Parent = key_input

        local input_padding = Instance.new'UIPadding'

        input_padding.PaddingLeft = UDim.new(0, 8)
        input_padding.PaddingRight = UDim.new(0, 8)
        input_padding.Parent = key_input

        if initial_message then
            key_input.PlaceholderText = initial_message
            key_input.PlaceholderColor3 = Color3.fromRGB(255, 100, 100)
        end

        local submit_button = Instance.new'TextButton'

        submit_button.LayoutOrder = 3
        submit_button.Size = UDim2.new(0, 90, 0, 22)
        submit_button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        submit_button.BorderSizePixel = 0
        submit_button.Text = 'load'
        submit_button.TextColor3 = Color3.fromRGB(255, 255, 255)
        submit_button.TextSize = 12
        submit_button.Font = ui_font
        submit_button.Parent = main_frame

        local submit_corner = Instance.new'UICorner'

        submit_corner.CornerRadius = UDim.new(1, 0)
        submit_corner.Parent = submit_button

        local discord_button = Instance.new'TextButton'

        discord_button.LayoutOrder = 4
        discord_button.Size = UDim2.new(0, 160, 0, 22)
        discord_button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        discord_button.BorderSizePixel = 0
        discord_button.Text = 'join discord (for key link)'
        discord_button.TextColor3 = Color3.fromRGB(255, 255, 255)
        discord_button.TextSize = 12
        discord_button.Font = ui_font
        discord_button.Parent = main_frame

        local discord_corner = Instance.new'UICorner'

        discord_corner.CornerRadius = UDim.new(1, 0)
        discord_corner.Parent = discord_button

        local function attach_hover(button)
            button.MouseEnter:Connect(function()
                button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            end)
            button.MouseLeave:Connect(function()
                button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            end)
        end

        attach_hover(submit_button)
        attach_hover(discord_button)

        local is_submitting = false

        submit_button.MouseButton1Click:Connect(function()
            if is_submitting then
                return
            end

            local entered_key = key_input.Text:gsub('%s+', '')

            if entered_key and #entered_key > 0 then
                is_submitting = true
                submit_button.Text = 'loading...'

                task.spawn(function()
                    local loader_success, loader_error = run_loader(entered_key)
                    if loader_success then
                        screen_gui:Destroy()
                    else
                        is_submitting = false
                        submit_button.Text = 'load'
                        key_input.Text = ''
                        key_input.PlaceholderText = loader_error or 'invalid key'
                        key_input.PlaceholderColor3 = Color3.fromRGB(255, 100, 100)
                    end
                end)
            else
                key_input.PlaceholderText = 'key cant be empty'
                key_input.PlaceholderColor3 = Color3.fromRGB(255, 100, 100)
            end
        end)
        discord_button.MouseButton1Click:Connect(function()
            local discord_url = 'https://discord.gg/vrvNMmgZ4d'

            if type(setclipboard) == 'function' then
                pcall(setclipboard, discord_url)

                local original_text = discord_button.Text

                discord_button.Text = 'copied to clipboard'

                task.delay(1.5, function()
                    discord_button.Text = original_text
                end)
            else
                local original_text = discord_button.Text

                discord_button.Text = 'copied to box'
                key_input.Text = discord_url

                task.delay(1.5, function()
                    discord_button.Text = original_text
                end)
            end
        end)
    end

    -- key from env or cached file will skip this prompt, unless luarmor rejects it
    local stored_key = get_env_key() or load_key()
    if stored_key then
        task.spawn(function()
            local loader_success, loader_error = run_loader(stored_key)
            if not loader_success then
                prompt_key(loader_error)
            end
        end)
    else
        prompt_key()
    end
else
    local unsupported_message = 'this game is not supported (GameId '
        .. tostring(current_game_id) .. ', PlaceId ' .. tostring(game.PlaceId) .. ')'
    warn(unsupported_message)
    pcall(function()
        cloneref(game:GetService('StarterGui')):SetCore('SendNotification', {
            Title = 'daydreamer',
            Text = 'this game is not supported.',
            Duration = 8,
        })
    end)
end
