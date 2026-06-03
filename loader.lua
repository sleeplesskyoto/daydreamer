local executor = string.lower(tostring(identifyexecutor()))
if executor == "xeno" or executor == "solara" then
    if not getgenv().allowpotatoexecutor then
        game:GetService("Players").LocalPlayer:Kick("daydreamer probably won't work on your executor ("..executor..") and you were kicked in order to prevent potential bans, as your executor lacks some functions necessary to bypass anticheats.\n    \n to bypass this warning and load daydreamer anyways, add this line of code before the script. it is NOT our fault if you get anticheat banned.\n    \n getgenv().allowpotatoexecutor = true \n(copied to clipboard)\n   ")
        setclipboard("getgenv().allowpotatoexecutor = true")
        error("shit executor, hop off " .. executor .. " and get a better one pls")
    elseif getgenv().allowpotatoexecutor then
        warn("your executor (" .. executor .. ") is not supported and probably wont work with daydreamer. do NOT report any bugs, they won't be fixed.")
    end
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local a = game:GetService'Players'
local b = a.LocalPlayer

while not b do
    task.wait()

    b = a.LocalPlayer
end

local c = game.GameId

while c == 0 do
    task.wait()

    c = game.GameId
end

local d = {
    [9186719164] = {
        url = 'https://api.luarmor.net/files/v4/loaders/5e24349f9d412fcbf853e76232898368.lua',
        script_id = '5e24349f9d412fcbf853e76232898368',
    },
}
local e = d[c]

if e then
    local f = 'daydreamer_key.txt'

    local function saveKey(g)
        if type(writefile) == 'function' then
            pcall(writefile, f, g)
        end
    end
    local function loadKey()
        if type(isfile) == 'function' and isfile(f) and type(readfile) == 'function' then
            local g, h = pcall(readfile, f)

            if g then
                return h
            end
        end

        return nil
    end
    local function runLoader(g)
        _G.dd_key = g
        getgenv().dd_key = g
        _G.script_key = g
        getgenv().script_key = g

        local h, i = pcall(function()
            return loadstring(game:HttpGet'https://sdkapi-public.luarmor.net/library.lua')()
        end)

        if not h or not i then
            return false, 'API Load Error'
        end

        i.script_id = e.script_id

        local j
        local k = pcall(function()
            j = i.check_key(g)
        end)

        if not k or not j then
            return false, 'Connection Error'
        end
        if j.code == 'KEY_VALID' then
            saveKey(g)
            task.spawn(function()
                local l, m = pcall(function()
                    i.load_script()
                end)

                if not l then
                    warn('loader failed for some reason: ' .. tostring(m))
                end
            end)

            return true
        elseif j.code == 'KEY_HWID_LOCKED' then
            return false, 'hwid mismatch, reset hwid via bot'
        elseif j.code == 'KEY_INCORRECT' then
            return false, 'key doesnt exist'
        elseif j.code == 'KEY_EXPIRED' then
            return false, 'key expired'
        elseif j.code == 'KEY_BANNED' then
            return false, 'key blacklisted'
        else
            return false, j.message or ('error: ' .. tostring(j.code))
        end
    end
    local function getEnvKey()
        local function validate(g)
            if typeof(g) == 'string' and #g:gsub('%s+', '') > 0 then
                return g:gsub('%s+', '')
            end

            return nil
        end

        local g = _G.script_key or getgenv().script_key

        if validate(g) then
            return validate(g)
        end
        if typeof(shared) == 'table' and shared.script_key then
            if validate(shared.script_key) then
                return validate(shared.script_key)
            end
        end

        for h = 1, 10 do
            local i, j = pcall(getfenv, h)

            if i and typeof(j) == 'table' and j.script_key then
                if validate(j.script_key) then
                    return validate(j.script_key)
                end
            end
        end

        local h, i = pcall(function()
            return script_key
        end)

        if h and validate(i) then
            return validate(i)
        end

        g = _G.dd_key or getgenv().dd_key

        if validate(g) then
            return validate(g)
        end
        if typeof(shared) == 'table' and shared.dd_key then
            if validate(shared.dd_key) then
                return validate(shared.dd_key)
            end
        end

        for j = 1, 10 do
            local k, l = pcall(getfenv, j)

            if k and typeof(l) == 'table' and l.dd_key then
                if validate(l.dd_key) then
                    return validate(l.dd_key)
                end
            end
        end

        local j, k = pcall(function()
            return dd_key
        end)

        if j and validate(k) then
            return validate(k)
        end

        return nil
    end

    local g = getEnvKey()

    if g then
        task.spawn(function()
            runLoader(g)
        end)

        return
    end

    local function promptKey()
        local j, k = pcall(function()
            return Enum.Font.Inter
        end) and Enum.Font.Inter or Enum.Font.Gotham, gethui()
        local l = Instance.new('ScreenGui', k)

        l.Name = 'daydreamer loader (if ur seeing this dont skid my ui pls) @ [' .. os.time() .. ']'
        l.ResetOnSpawn = false

        local m = Instance.new'Frame'

        m.AnchorPoint = Vector2.new(0.5, 0.5)
        m.Position = UDim2.new(0.5, 0, 0.5, 0)
        m.Size = UDim2.new(0, 0, 0, 40)
        m.AutomaticSize = Enum.AutomaticSize.X
        m.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        m.BorderSizePixel = 0
        m.Active = true
        m.Parent = l

        local n = Instance.new'UICorner'

        n.CornerRadius = UDim.new(1, 0)
        n.Parent = m

        local o = Instance.new'UIListLayout'

        o.FillDirection = Enum.FillDirection.Horizontal
        o.VerticalAlignment = Enum.VerticalAlignment.Center
        o.SortOrder = Enum.SortOrder.LayoutOrder
        o.Padding = UDim.new(0, 8)
        o.Parent = m

        local p = Instance.new'UIPadding'

        p.PaddingLeft = UDim.new(0, 18)
        p.PaddingRight = UDim.new(0, 8)
        p.Parent = m

        local q, r, s, t, u = (game:GetService'UserInputService')

        m.InputBegan:Connect(function(v)
            if v.UserInputType == Enum.UserInputType.MouseButton1 or v.UserInputType == Enum.UserInputType.Touch then
                r = true
                t = v.Position
                u = m.Position

                v.Changed:Connect(function()
                    if v.UserInputState == Enum.UserInputState.End then
                        r = false
                    end
                end)
            end
        end)
        m.InputChanged:Connect(function(v)
            if v.UserInputType == Enum.UserInputType.MouseMovement or v.UserInputType == Enum.UserInputType.Touch then
                s = v
            end
        end)
        q.InputChanged:Connect(function(v)
            if v == s and r then
                local w = v.Position - t

                m.Position = UDim2.new(u.X.Scale, u.X.Offset + w.X, u.Y.Scale, u.Y.Offset + w.Y)
            end
        end)

        local v = Instance.new'TextLabel'

        v.LayoutOrder = 1
        v.Size = UDim2.new(0, 0, 1, 0)
        v.AutomaticSize = Enum.AutomaticSize.X
        v.BackgroundTransparency = 1
        v.RichText = true
        v.Text = '<font color="#090d23">day</font><font color="#fbeee6">dreamer.</font>'
        v.TextSize = 14
        v.Font = j
        v.Parent = m

        local w = Instance.new'TextBox'

        w.LayoutOrder = 2
        w.Size = UDim2.new(0, 140, 0, 26)
        w.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        w.BorderSizePixel = 0
        w.Text = ''
        w.PlaceholderText = 'enter key...'
        w.TextColor3 = Color3.fromRGB(255, 255, 255)
        w.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
        w.TextSize = 12
        w.Font = j
        w.ClearTextOnFocus = false
        w.ClipsDescendants = true
        w.Parent = m

        local x = Instance.new'UICorner'

        x.CornerRadius = UDim.new(1, 0)
        x.Parent = w

        local y = Instance.new'UIPadding'

        y.PaddingLeft = UDim.new(0, 8)
        y.PaddingRight = UDim.new(0, 8)
        y.Parent = w

        local z = Instance.new'TextButton'

        z.LayoutOrder = 3
        z.Size = UDim2.new(0, 90, 0, 22)
        z.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        z.BorderSizePixel = 0
        z.Text = 'submit key'
        z.TextColor3 = Color3.fromRGB(255, 255, 255)
        z.TextSize = 12
        z.Font = j
        z.Parent = m

        local A = Instance.new'UICorner'

        A.CornerRadius = UDim.new(1, 0)
        A.Parent = z

        local B = Instance.new'TextButton'

        B.LayoutOrder = 4
        B.Size = UDim2.new(0, 160, 0, 22)
        B.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        B.BorderSizePixel = 0
        B.Text = 'join discord (for key link)'
        B.TextColor3 = Color3.fromRGB(255, 255, 255)
        B.TextSize = 12
        B.Font = j
        B.Parent = m

        local C = Instance.new'UICorner'

        C.CornerRadius = UDim.new(1, 0)
        C.Parent = B

        local function attachHover(D)
            D.MouseEnter:Connect(function()
                D.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            end)
            D.MouseLeave:Connect(function()
                D.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            end)
        end

        attachHover(z)
        attachHover(B)

        local D = false

        z.MouseButton1Click:Connect(function()
            if D then
                return
            end

            local E = w.Text:gsub('%s+', '')

            if E and #E > 0 then
                D = true
                z.Text = 'checking...'

                task.spawn(function()
                    local F, G = runLoader(E)

                    if F then
                        l:Destroy()
                    else
                        D = false
                        z.Text = 'submit key'
                        w.Text = ''
                        w.PlaceholderText = G or 'invalid key'
                        w.PlaceholderColor3 = Color3.fromRGB(255, 100, 100)
                    end
                end)
            else
                w.PlaceholderText = 'key cant be empty'
                w.PlaceholderColor3 = Color3.fromRGB(255, 100, 100)
            end
        end)
        B.MouseButton1Click:Connect(function()
            local E = 'https://discord.gg/vrvNMmgZ4d'

            if type(setclipboard) == 'function' then
                pcall(setclipboard, E)

                local F = B.Text

                B.Text = 'copied to clipboard'

                task.delay(1.5, function()
                    B.Text = F
                end)
            else
                local F = B.Text

                B.Text = 'copied to box'
                w.Text = E

                task.delay(1.5, function()
                    B.Text = F
                end)
            end
        end)
    end

    local j = loadKey()

    if j then
        task.spawn(function()
            local k = runLoader(j)

            if not k then
                promptKey()
            end
        end)
    else
        promptKey()
    end
end
