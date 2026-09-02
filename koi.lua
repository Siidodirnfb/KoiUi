local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local function new(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        inst[k] = v
    end
    return inst
end

local function round(inst, r)
    new("UICorner", { CornerRadius = UDim.new(0, r), Parent = inst })
end

local function border(inst, color, transparency)
    return new("UIStroke", {
        Color = color,
        Transparency = transparency or 0,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = inst,
    })
end

local function tween(inst, seconds, props, style, dir)
    local t = TweenService:Create(inst, TweenInfo.new(seconds or 0.16, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function toHex(c)
    return ("#%02X%02X%02X"):format(math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

local function fromHex(s)
    s = (s:gsub("#", ""):gsub("%s", ""))
    if #s ~= 6 then
        return nil
    end
    local r, g, b = s:match("^(%x%x)(%x%x)(%x%x)$")
    if not r then
        return nil
    end
    return Color3.fromRGB(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16))
end

local function shortKey(key)
    local map = {
        LeftControl = "LCTRL",
        RightControl = "RCTRL",
        LeftShift = "LSHIFT",
        RightShift = "RSHIFT",
        LeftAlt = "LALT",
        RightAlt = "RALT",
    }
    return map[key.Name] or key.Name
end

local function viewportSize()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

local function resolveParent()
    local ok, target = pcall(function()
        if gethui then
            return gethui()
        end
        local cg = game:GetService("CoreGui")
        local probe = Instance.new("Folder")
        probe.Parent = cg
        probe:Destroy()
        return cg
    end)
    if ok and target then
        return target
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local Koi = {}
Koi.__index = Koi

Koi.Themes = {
    Koi = {
        Background = Color3.fromRGB(17, 17, 21),
        Panel = Color3.fromRGB(22, 22, 27),
        Element = Color3.fromRGB(30, 30, 37),
        ElementHover = Color3.fromRGB(38, 38, 46),
        Stroke = Color3.fromRGB(46, 46, 56),
        Text = Color3.fromRGB(233, 231, 227),
        SubText = Color3.fromRGB(139, 138, 146),
        Accent = Color3.fromRGB(230, 106, 94),
        Warning = Color3.fromRGB(224, 172, 82),
        Danger = Color3.fromRGB(206, 62, 54),
    },
    Bone = {
        Background = Color3.fromRGB(243, 242, 238),
        Panel = Color3.fromRGB(250, 249, 246),
        Element = Color3.fromRGB(232, 231, 225),
        ElementHover = Color3.fromRGB(222, 221, 214),
        Stroke = Color3.fromRGB(207, 205, 197),
        Text = Color3.fromRGB(40, 39, 37),
        SubText = Color3.fromRGB(126, 124, 118),
        Accent = Color3.fromRGB(196, 88, 72),
        Warning = Color3.fromRGB(184, 134, 50),
        Danger = Color3.fromRGB(174, 48, 42),
    },
}

local activeDropdown
local bindListener

local notifyGlyph = {
    info = "i",
    warning = "!",
    danger = "×",
}

local notifyTitle = {
    info = "примечание",
    warning = "предупреждение",
    danger = "опасность",
}

function Koi:Notify(cfg)
    cfg = cfg or {}
    local kind = cfg.Type or "info"
    local T = self.Themes[self._lastTheme or "Koi"] or self.Themes.Koi
    local tone = kind == "warning" and T.Warning or kind == "danger" and T.Danger or T.SubText

    if not (self._notifyGui and self._notifyGui.Parent) then
        local gui = new("ScreenGui", {
            Name = "koi_notify",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 200,
            IgnoreGuiInset = true,
        })
        gui.Parent = resolveParent()

        local stack = new("Frame", {
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -14, 1, -14),
            Size = UDim2.new(0, 280, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = gui,
        })
        new("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Parent = stack,
        })
        self._notifyGui = gui
        self._notifyStack = stack
        self._notifyCount = 0
    end

    self._notifyCount += 1
    local dur = cfg.Duration or 4
    local bodyW = 280 - 50
    local bodyH = TextService:GetTextSize(cfg.Text or "", 12, Enum.Font.Gotham, Vector2.new(bodyW, 10000)).Y
    local h = 34 + bodyH + 12

    local toast = new("CanvasGroup", {
        BackgroundColor3 = T.Panel,
        Size = UDim2.fromOffset(280, h),
        LayoutOrder = self._notifyCount,
        GroupTransparency = 1,
        Parent = self._notifyStack,
    })
    round(toast, 6)
    border(toast, T.Stroke, 0.5)

    local chip = new("TextLabel", {
        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.fromOffset(18, 18),
        BackgroundColor3 = tone,
        BackgroundTransparency = 0.85,
        Font = Enum.Font.Code,
        Text = notifyGlyph[kind] or "i",
        TextSize = 12,
        TextColor3 = tone,
        Parent = toast,
    })
    round(chip, 4)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(38, 11),
        Size = UDim2.new(1, -50, 0, 18),
        Font = Enum.Font.GothamMedium,
        Text = cfg.Title or notifyTitle[kind] or "уведомление",
        TextSize = 13,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = toast,
    })
    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(38, 34),
        Size = UDim2.new(1, -50, 0, bodyH),
        Font = Enum.Font.Gotham,
        Text = cfg.Text or "",
        TextSize = 12,
        TextColor3 = T.SubText,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = toast,
    })
    local bar = new("Frame", {
        BackgroundColor3 = tone,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = toast,
    })

    tween(toast, 0.25, { GroupTransparency = 0 })
    tween(bar, dur, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
    task.delay(dur, function()
        tween(toast, 0.25, { GroupTransparency = 1 })
        task.wait(0.3)
        toast:Destroy()
    end)
end

function Koi:Note(title, text, duration)
    return self:Notify({ Type = "info", Title = title, Text = text, Duration = duration })
end

function Koi:Warn(title, text, duration)
    return self:Notify({ Type = "warning", Title = title, Text = text, Duration = duration })
end

function Koi:Danger(title, text, duration)
    return self:Notify({ Type = "danger", Title = title, Text = text, Duration = duration })
end

function Koi:CreateWindow(cfg)
    cfg = cfg or {}

    local themeName = cfg.Theme or "Koi"
    local T = self.Themes[themeName] or self.Themes.Koi
    self._lastTheme = themeName

    local window = { Tabs = {}, Open = true, Minimized = false }
    local flags = {}
    local conns = {}

    local toggleKey = cfg.ToggleKey or Enum.KeyCode.K
    local openSize = cfg.Size or UDim2.fromOffset(640, 430)

    local function connect(signal, fn)
        local c = signal:Connect(fn)
        table.insert(conns, c)
        return c
    end

    local function registerFlag(c, getter, setter)
        if c and c.Flag then
            flags[c.Flag] = { Get = getter, Set = setter }
        end
    end

    local gui = new("ScreenGui", {
        Name = cfg.FolderName or "koi_ui",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 100,
        IgnoreGuiInset = true,
    })
    gui.Parent = resolveParent()

    local vp = viewportSize()
    local basePos = UDim2.fromOffset(math.floor(vp.X / 2), math.floor(vp.Y / 2))

    local main = new("CanvasGroup", {
        Name = "main",
        Size = openSize,
        Position = basePos,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = T.Background,
        GroupTransparency = 1,
        ClipsDescendants = true,
        Parent = gui,
    })
    round(main, 6)
    border(main, T.Stroke, 0.35)
    tween(main, 0.3, { GroupTransparency = 0 })

    local header = new("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = T.Panel,
        BorderSizePixel = 0,
        Active = true,
        Parent = main,
    })
    new("Frame", {
        BackgroundColor3 = T.Stroke,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = header,
    })

    local dot = new("Frame", {
        Position = UDim2.fromOffset(14, 17),
        Size = UDim2.fromOffset(6, 6),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        Parent = header,
    })
    round(dot, 3)
    TweenService:Create(dot, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { BackgroundTransparency = 0.55 }):Play()

    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(30, 0),
        Size = UDim2.fromOffset(220, 40),
        Font = Enum.Font.Code,
        Text = cfg.Title or "koi.ui",
        TextSize = 15,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })
    new("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -84, 0.5, 0),
        Size = UDim2.fromOffset(80, 20),
        Font = Enum.Font.Code,
        Text = cfg.Version or "2.6",
        TextSize = 11,
        TextColor3 = T.SubText,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = header,
    })

    local minBtn = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -42, 0.5, 0),
        Size = UDim2.fromOffset(24, 24),
        BackgroundTransparency = 1,
        Text = "–",
        TextSize = 16,
        Font = Enum.Font.Code,
        TextColor3 = T.SubText,
        AutoButtonColor = false,
        Parent = header,
    })
    round(minBtn, 4)
    minBtn.MouseEnter:Connect(function()
        tween(minBtn, 0.12, { TextColor3 = T.Text })
    end)
    minBtn.MouseLeave:Connect(function()
        tween(minBtn, 0.16, { TextColor3 = T.SubText })
    end)

    local closeBtn = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(24, 24),
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 1,
        Text = "×",
        TextSize = 18,
        Font = Enum.Font.GothamMedium,
        TextColor3 = T.Accent,
        AutoButtonColor = false,
        Parent = header,
    })
    round(closeBtn, 4)
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, 0.12, { BackgroundTransparency = 0.82 })
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, 0.16, { BackgroundTransparency = 1 })
    end)

    local sidebar = new("Frame", {
        Position = UDim2.fromOffset(0, 40),
        Size = UDim2.new(0, 148, 1, -67),
        BackgroundColor3 = T.Background,
        BorderSizePixel = 0,
        Parent = main,
    })
    new("Frame", {
        BackgroundColor3 = T.Stroke,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        Parent = sidebar,
    })
    new("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        Parent = sidebar,
    })
    new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sidebar })
    new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.Code,
        Text = "// tabs",
        TextSize = 11,
        TextColor3 = T.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 0,
        Parent = sidebar,
    })

    new("Frame", {
        BackgroundColor3 = T.Stroke,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -27),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = main,
    })
    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 1, -26),
        Size = UDim2.new(1, -28, 0, 26),
        Font = Enum.Font.Code,
        Text = ("press [%s] to hide · drag header to move"):format(shortKey(toggleKey)),
        TextSize = 11,
        TextColor3 = T.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = main,
    })

    local dragging = false
    local dragStart, dragCenter
    local posTween

    local function clampCenter(c)
        local sz = main.AbsoluteSize
        local vs = viewportSize()
        local minX = sz.X / 2 + 8
        local minY = sz.Y / 2 + 8
        local maxX = math.max(minX, vs.X - sz.X / 2 - 8)
        local maxY = math.max(minY, vs.Y - sz.Y / 2 - 8)
        return Vector2.new(math.clamp(c.X, minX, maxX), math.clamp(c.Y, minY, maxY))
    end

    local function pointerInside(p, root)
        local ap = root.AbsolutePosition
        local as = root.AbsoluteSize
        if p.X >= ap.X and p.X <= ap.X + as.X and p.Y >= ap.Y and p.Y <= ap.Y + as.Y then
            return true
        end
        for _, g in ipairs(UserInputService:GetGuiObjectsAtPosition(p.X, p.Y)) do
            if g:IsDescendantOf(root) then
                return true
            end
        end
        return false
    end

    local show, hide

    local showBtn = new("TextButton", {
        Position = UDim2.new(0.5, -35, 0, 10),
        Size = UDim2.fromOffset(70, 24),
        BackgroundColor3 = T.Element,
        BackgroundTransparency = 0.5,
        Text = "show",
        TextSize = 13,
        Font = Enum.Font.Code,
        TextColor3 = T.Text,
        TextTransparency = 0.35,
        AutoButtonColor = false,
        Visible = false,
        Parent = gui,
    })
    round(showBtn, 6)
    local showStroke = border(showBtn, T.Stroke, 0.75)
    showBtn.MouseEnter:Connect(function()
        tween(showBtn, 0.15, { BackgroundTransparency = 0.2, TextTransparency = 0.05 })
    end)
    showBtn.MouseLeave:Connect(function()
        tween(showBtn, 0.2, { BackgroundTransparency = 0.5, TextTransparency = 0.35 })
    end)
    showBtn.MouseButton1Click:Connect(function()
        show()
    end)

    function hide()
        if not window.Open then
            return
        end
        window.Open = false
        dragging = false
        if activeDropdown then
            activeDropdown.close()
        end
        if posTween then
            posTween:Cancel()
        end
        posTween = tween(main, 0.22, {
            GroupTransparency = 1,
            Position = basePos + UDim2.fromOffset(0, -24),
        })
        task.delay(0.24, function()
            if not window.Open then
                main.Visible = false
            end
        end)
        showBtn.Visible = true
        showBtn.BackgroundTransparency = 1
        showBtn.TextTransparency = 1
        showStroke.Transparency = 1
        tween(showBtn, 0.3, { BackgroundTransparency = 0.5, TextTransparency = 0.35 })
        tween(showStroke, 0.3, { Transparency = 0.75 })
    end

    function show()
        if window.Open then
            return
        end
        window.Open = true
        local c = clampCenter(Vector2.new(basePos.X.Offset, basePos.Y.Offset))
        basePos = UDim2.fromOffset(c.X, c.Y)
        main.Visible = true
        main.Position = basePos + UDim2.fromOffset(0, -24)
        main.GroupTransparency = 1
        if posTween then
            posTween:Cancel()
        end
        posTween = tween(main, 0.26, { GroupTransparency = 0, Position = basePos })
        showBtn.Visible = false
    end

    closeBtn.MouseButton1Click:Connect(hide)

    minBtn.MouseButton1Click:Connect(function()
        window.Minimized = not window.Minimized
        if window.Minimized then
            minBtn.Text = "+"
            tween(main, 0.3, { Size = UDim2.new(openSize.X.Scale, openSize.X.Offset, 0, 40) })
        else
            minBtn.Text = "–"
            tween(main, 0.3, { Size = openSize })
        end
    end)

    connect(header.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            if posTween then
                posTween:Cancel()
                posTween = nil
            end
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            dragCenter = clampCenter(Vector2.new(
                main.AbsolutePosition.X + main.AbsoluteSize.X / 2,
                main.AbsolutePosition.Y + main.AbsoluteSize.Y / 2))
            basePos = UDim2.fromOffset(dragCenter.X, dragCenter.Y)
            main.Position = basePos
        end
    end)

    connect(UserInputService.InputChanged, function(input)
        if not dragging then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local d = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            local c = clampCenter(dragCenter + d)
            basePos = UDim2.fromOffset(c.X, c.Y)
            main.Position = basePos
        end
    end)

    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    connect(UserInputService.InputBegan, function(input, gp)
        if bindListener then
            if input.KeyCode == Enum.KeyCode.Escape then
                bindListener:_cancel()
            elseif input.UserInputType == Enum.UserInputType.Keyboard
                and input.KeyCode ~= Enum.KeyCode.Unknown then
                bindListener:_assign(input.KeyCode)
            end
            return
        end
        if (input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch)
            and activeDropdown then
            if not pointerInside(input.Position, activeDropdown.root) then
                activeDropdown.close()
            end
        end
        if not gp and input.KeyCode == toggleKey then
            if window.Open then
                hide()
            else
                show()
            end
        end
    end)

    local tabs = {}

    local function selectTab(target)
        for _, t in ipairs(tabs) do
            local active = (t == target)
            t.container.Visible = active
            t.indicator.Visible = active
            tween(t.button, 0.14, { BackgroundColor3 = active and T.Element or T.Panel })
            tween(t.stroke, 0.14, {
                Color = active and T.Accent or T.Stroke,
                Transparency = active and 0 or 0.3,
            })
            tween(t.glyph, 0.14, { TextColor3 = active and T.Accent or T.SubText })
            tween(t.name, 0.14, { TextColor3 = active and T.Text or T.SubText })
        end
        if activeDropdown then
            activeDropdown.close()
        end
    end

    function window:AddTab(t)
        t = t or {}
        local tabName = t.Name or "tab"
        local icon = t.Icon or "◇"

        local btn = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = T.Panel,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = #tabs + 1,
            Parent = sidebar,
        })
        round(btn, 5)
        local stroke = border(btn, T.Stroke, 0.3)

        local indicator = new("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.fromOffset(2, 14),
            BackgroundColor3 = T.Accent,
            BorderSizePixel = 0,
            Visible = false,
            Parent = btn,
        })
        round(indicator, 1)

        local glyph = new("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.fromOffset(18, 36),
            Font = Enum.Font.Code,
            Text = icon,
            TextSize = 12,
            TextColor3 = T.SubText,
            Parent = btn,
        })
        local name = new("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(36, 0),
            Size = UDim2.new(1, -44, 1, 0),
            Font = Enum.Font.GothamMedium,
            Text = tabName,
            TextSize = 13,
            TextColor3 = T.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = btn,
        })

        local container = new("ScrollingFrame", {
            Position = UDim2.new(0, 148, 0, 40),
            Size = UDim2.new(1, -148, 1, -67),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = T.Stroke,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = main,
        })
        new("UIPadding", {
            PaddingTop = UDim.new(0, 14),
            PaddingBottom = UDim.new(0, 14),
            PaddingLeft = UDim.new(0, 16),
            PaddingRight = UDim.new(0, 16),
            Parent = container,
        })
        new("UIListLayout", { Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder, Parent = container })

        btn.MouseEnter:Connect(function()
            if not container.Visible then
                tween(btn, 0.12, { BackgroundColor3 = T.Element })
            end
        end)
        btn.MouseLeave:Connect(function()
            if not container.Visible then
                tween(btn, 0.16, { BackgroundColor3 = T.Panel })
            end
        end)

        local tab = {
            Name = tabName,
            container = container,
            button = btn,
            stroke = stroke,
            indicator = indicator,
            glyph = glyph,
            name = name,
        }

        btn.MouseButton1Click:Connect(function()
            selectTab(tab)
        end)
        function tab:Select()
            selectTab(tab)
        end

        local secOrder = 0

        function tab:AddSection(scfg)
            scfg = scfg or {}
            secOrder += 1

            local holder = new("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = secOrder,
                Parent = container,
            })
            new("Frame", {
                BackgroundColor3 = T.Stroke,
                BackgroundTransparency = 0.25,
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(0, 9),
                Size = UDim2.new(1, 0, 0, 1),
                Parent = holder,
            })
            new("TextLabel", {
                BackgroundColor3 = T.Background,
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(2, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.new(0, 0, 0, 18),
                Font = Enum.Font.Code,
                Text = "// " .. string.lower(scfg.Name or "section"),
                TextSize = 12,
                TextColor3 = T.SubText,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = holder,
            })

            local inner = new("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 24),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = holder,
            })
            new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = inner })

            local elOrder = 0
            local function nextOrder()
                elOrder += 1
                return elOrder
            end

            local function makeRow(h)
                local row = new("Frame", {
                    Size = UDim2.new(1, 0, 0, h),
                    BackgroundColor3 = T.Element,
                    BorderSizePixel = 0,
                    LayoutOrder = nextOrder(),
                    Parent = inner,
                })
                round(row, 5)
                local s = border(row, T.Stroke, 1)
                row.MouseEnter:Connect(function()
                    tween(row, 0.12, { BackgroundColor3 = T.ElementHover })
                end)
                row.MouseLeave:Connect(function()
                    tween(row, 0.18, { BackgroundColor3 = T.Element })
                end)
                return row, s
            end

            local function rowLabel(row, text)
                return new("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(12, 0),
                    Size = UDim2.new(1, -110, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextSize = 13,
                    TextColor3 = T.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row,
                })
            end

            local function makeExpander()
                local wrapper = new("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = nextOrder(),
                    Parent = inner,
                })
                local row = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundColor3 = T.Element,
                    BorderSizePixel = 0,
                    Parent = wrapper,
                })
                round(row, 5)
                border(row, T.Stroke, 1)
                row.MouseEnter:Connect(function()
                    tween(row, 0.12, { BackgroundColor3 = T.ElementHover })
                end)
                row.MouseLeave:Connect(function()
                    tween(row, 0.18, { BackgroundColor3 = T.Element })
                end)
                local list = new("Frame", {
                    Position = UDim2.fromOffset(0, 38),
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundColor3 = T.Panel,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Parent = wrapper,
                })
                round(list, 5)
                border(list, T.Stroke, 1)
                return wrapper, row, list
            end

            local section = {}

            function section:AddButton(c)
                c = c or {}
                local row, s = makeRow(34)
                local label = rowLabel(row, c.Name or "button")
                local arrow = new("TextLabel", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -14, 0.5, 0),
                    Size = UDim2.fromOffset(14, 20),
                    Font = Enum.Font.Code,
                    Text = "›",
                    TextSize = 14,
                    TextColor3 = T.SubText,
                    Parent = row,
                })
                local hit = new("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    Text = "",
                    AutoButtonColor = false,
                    Parent = row,
                })
                local callback = c.Callback
                hit.MouseButton1Click:Connect(function()
                    s.Color = T.Accent
                    s.Transparency = 0
                    tween(s, 0.4, { Transparency = 1 })
                    if callback then
                        task.spawn(callback)
                    end
                end)
                hit.MouseEnter:Connect(function()
                    tween(arrow, 0.12, { TextColor3 = T.Accent })
                end)
                hit.MouseLeave:Connect(function()
                    tween(arrow, 0.18, { TextColor3 = T.SubText })
                end)

                local obj = {}
                function obj:SetText(v)
                    label.Text = v
                end
                function obj:SetCallback(f)
                    callback = f
                end
                function obj:Click()
                    if callback then
                        task.spawn(callback)
                    end
                end
                registerFlag(c, function()
                    return true
                end, function() end)
                return obj
            end

            function section:AddToggle(c)
                c = c or {}
                local row = makeRow(34)
                rowLabel(row, c.Name or "toggle")
                local state = c.Default and true or false
                local pill = new("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.fromOffset(36, 20),
                    BackgroundColor3 = state and T.Accent or T.Stroke,
                    BorderSizePixel = 0,
                    Parent = row,
                })
                round(pill, 10)
                local knob = new("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = state and UDim2.new(1, -10, 0.5, 0) or UDim2.new(0, 10, 0.5, 0),
                    Size = UDim2.fromOffset(12, 12),
                    BackgroundColor3 = state and T.Background or T.SubText,
                    BorderSizePixel = 0,
                    Parent = pill,
                })
                round(knob, 6)
                local hit = new("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    Text = "",
                    AutoButtonColor = false,
                    Parent = row,
                })
                local callback = c.Callback
                local function set(v, silent)
                    state = v and true or false
                    tween(pill, 0.18, { BackgroundColor3 = state and T.Accent or T.Stroke })
                    tween(knob, 0.18, {
                        Position = state and UDim2.new(1, -10, 0.5, 0) or UDim2.new(0, 10, 0.5, 0),
                        BackgroundColor3 = state and T.Background or T.SubText,
                    })
                    if not silent and callback then
                        task.spawn(callback, state)
                    end
                end
                hit.MouseButton1Click:Connect(function()
                    set(not state)
                end)

                local obj = {}
                function obj:Set(v)
                    set(v, true)
                end
                function obj:Get()
                    return state
                end
                function obj:SetCallback(f)
                    callback = f
                end
                registerFlag(c, function()
                    return state
                end, function(v)
                    set(v, true)
                end)
                return obj
            end

            function section:AddSlider(c)
                c = c or {}
                local min = c.Min or 0
                local max = c.Max or 100
                local step = c.Step or 1
                if step <= 0 then
                    step = 1
                end
                local suffix = c.Suffix or ""
                local value = math.clamp(c.Default or min, min, max)

                local row = makeRow(46)
                local label = rowLabel(row, c.Name or "slider")
                label.Size = UDim2.new(1, -120, 0, 18)
                label.Position = UDim2.fromOffset(12, 7)
                local valueLabel = new("TextLabel", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -12, 0, 6),
                    Size = UDim2.fromOffset(110, 18),
                    Font = Enum.Font.Code,
                    TextSize = 12,
                    TextColor3 = T.Accent,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = row,
                })
                local bar = new("Frame", {
                    Position = UDim2.fromOffset(12, 31),
                    Size = UDim2.new(1, -24, 0, 6),
                    BackgroundColor3 = T.Stroke,
                    BorderSizePixel = 0,
                    Active = true,
                    Parent = row,
                })
                round(bar, 3)
                local fill = new("Frame", {
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = T.Accent,
                    BorderSizePixel = 0,
                    Parent = bar,
                })
                round(fill, 3)

                local callback = c.Callback
                local function fmt(v)
                    if step < 0.01 then
                        return ("%.2f"):format(v)
                    end
                    if step < 1 then
                        return ("%.1f"):format(v)
                    end
                    return ("%d"):format(v)
                end
                local function set(v, silent)
                    v = math.clamp(v, min, max)
                    v = math.floor(v / step + 0.5) * step
                    v = math.clamp(v, min, max)
                    value = v
                    local range = max - min
                    local alpha = range > 0 and (v - min) / range or 1
                    fill.Size = UDim2.new(alpha, 0, 1, 0)
                    valueLabel.Text = fmt(v) .. suffix
                    if not silent and callback then
                        task.spawn(callback, v)
                    end
                end

                local draggingSlider = false
                local function apply(x)
                    local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
                    set(min + (max - min) * rel)
                end
                bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSlider = true
                        apply(input.Position.X)
                    end
                end)
                connect(UserInputService.InputChanged, function(input)
                    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch) then
                        apply(input.Position.X)
                    end
                end)
                connect(UserInputService.InputEnded, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSlider = false
                    end
                end)
                set(value, true)

                local obj = {}
                function obj:SetValue(v)
                    set(v, true)
                end
                function obj:Get()
                    return value
                end
                function obj:SetCallback(f)
                    callback = f
                end
                registerFlag(c, function()
                    return value
                end, function(v)
                    set(v, true)
                end)
                return obj
            end

            local function makeDropdownBase(rowTitle, heightFn)
                local wrapper, row, list = makeExpander()
                rowLabel(row, rowTitle or "dropdown")
                local valueLabel = new("TextLabel", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -34, 0.5, 0),
                    Size = UDim2.new(0.45, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = T.SubText,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = row,
                })
                local chev = new("TextLabel", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.fromOffset(14, 20),
                    Font = Enum.Font.Code,
                    Text = "▾",
                    TextSize = 13,
                    TextColor3 = T.SubText,
                    Parent = row,
                })
                local scroll = new("ScrollingFrame", {
                    Position = UDim2.fromOffset(5, 5),
                    Size = UDim2.new(1, -10, 1, -10),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = T.Stroke,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Parent = list,
                })
                new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll })

                local open = false
                local lastToggle = 0
                local function closeList()
                    open = false
                    tween(list, 0.18, { Size = UDim2.new(1, 0, 0, 0) })
                    tween(chev, 0.18, { Rotation = 0 })
                    if activeDropdown and activeDropdown.close == closeList then
                        activeDropdown = nil
                    end
                end
                local function openList()
                    if activeDropdown then
                        activeDropdown.close()
                    end
                    open = true
                    tween(list, 0.2, { Size = UDim2.new(1, 0, 0, heightFn()) })
                    tween(chev, 0.2, { Rotation = 180 })
                    activeDropdown = { close = closeList, root = wrapper }
                end
                row.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        local now = os.clock()
                        if now - lastToggle < 0.2 then
                            return
                        end
                        lastToggle = now
                        if open then
                            closeList()
                        else
                            openList()
                        end
                    end
                end)
                return wrapper, scroll, valueLabel, closeList
            end

            local function makeOptionButton(parent, order, text)
                local ob = new("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                    BackgroundColor3 = T.ElementHover,
                    Text = "",
                    AutoButtonColor = false,
                    LayoutOrder = order,
                    Parent = parent,
                })
                round(ob, 4)
                local d = new("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 8, 0.5, 0),
                    Size = UDim2.fromOffset(4, 4),
                    BackgroundColor3 = T.Accent,
                    BorderSizePixel = 0,
                    Visible = false,
                    Parent = ob,
                })
                round(d, 2)
                local lb = new("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(18, 0),
                    Size = UDim2.new(1, -26, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = tostring(text),
                    TextSize = 12,
                    TextColor3 = T.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ob,
                })
                ob.MouseEnter:Connect(function()
                    tween(ob, 0.1, { BackgroundTransparency = 0 })
                end)
                ob.MouseLeave:Connect(function()
                    tween(ob, 0.15, { BackgroundTransparency = 1 })
                end)
                return ob, d, lb
            end

            function section:AddDropdown(c)
                c = c or {}
                local options = c.Options or {}
                local selected = c.Default
                local callback = c.Callback
                local optionButtons = {}

                local wrapper, scroll, valueLabel, closeList = makeDropdownBase(c.Name, function()
                    return math.min(#options, 5) * 28 + 10
                end)

                local function render()
                    valueLabel.Text = selected and tostring(selected) or "—"
                    for k, o in pairs(optionButtons) do
                        local on = (k == tostring(selected))
                        o.dot.Visible = on
                        o.label.TextColor3 = on and T.Accent or T.Text
                    end
                end

                local function build()
                    for _, ch in ipairs(scroll:GetChildren()) do
                        if ch:IsA("TextButton") then
                            ch:Destroy()
                        end
                    end
                    optionButtons = {}
                    for i, opt in ipairs(options) do
                        local ob, d, lb = makeOptionButton(scroll, i, opt)
                        ob.MouseButton1Click:Connect(function()
                            selected = opt
                            render()
                            closeList()
                            if callback then
                                task.spawn(callback, selected)
                            end
                        end)
                        optionButtons[tostring(opt)] = { dot = d, label = lb }
                    end
                    render()
                end
                build()

                local obj = {}
                function obj:Set(v)
                    selected = v
                    render()
                end
                function obj:Get()
                    return selected
                end
                function obj:SetCallback(f)
                    callback = f
                end
                function obj:Refresh(newOpts)
                    options = newOpts or {}
                    if selected and not table.find(options, selected) then
                        selected = nil
                    end
                    build()
                end
                registerFlag(c, function()
                    return selected
                end, function(v)
                    obj:Set(v)
                end)
                return obj
            end

            function section:AddMultiDropdown(c)
                c = c or {}
                local options = c.Options or {}
                local chosen = {}
                if type(c.Default) == "table" then
                    for _, v in ipairs(c.Default) do
                        table.insert(chosen, v)
                    end
                end
                local callback = c.Callback
                local optionButtons = {}

                local wrapper, scroll, valueLabel, closeList = makeDropdownBase(c.Name or "multi", function()
                    return math.min(#options, 5) * 28 + 10
                end)

                local function render()
                    if #chosen == 0 then
                        valueLabel.Text = "—"
                    else
                        local names = {}
                        for _, v in ipairs(chosen) do
                            table.insert(names, tostring(v))
                        end
                        valueLabel.Text = table.concat(names, ", ")
                    end
                    for k, o in pairs(optionButtons) do
                        local on = false
                        for _, v in ipairs(chosen) do
                            if tostring(v) == k then
                                on = true
                                break
                            end
                        end
                        o.dot.Visible = on
                        o.label.TextColor3 = on and T.Accent or T.Text
                    end
                end

                for i, opt in ipairs(options) do
                    local ob, d, lb = makeOptionButton(scroll, i, opt)
                    ob.MouseButton1Click:Connect(function()
                        local idx = table.find(chosen, opt)
                        if idx then
                            table.remove(chosen, idx)
                        else
                            table.insert(chosen, opt)
                        end
                        render()
                        if callback then
                            task.spawn(callback, chosen)
                        end
                    end)
                    optionButtons[tostring(opt)] = { dot = d, label = lb }
                end
                render()

                local obj = {}
                function obj:Set(tbl)
                    chosen = {}
                    if type(tbl) == "table" then
                        for _, v in ipairs(tbl) do
                            table.insert(chosen, v)
                        end
                    end
                    render()
                end
                function obj:Get()
                    return chosen
                end
                function obj:SetCallback(f)
                    callback = f
                end
                registerFlag(c, function()
                    return chosen
                end, function(v)
                    obj:Set(v)
                end)
                return obj
            end

            function section:AddKeybind(c)
                c = c or {}
                local row = makeRow(34)
                rowLabel(row, c.Name or "keybind")
                local key = c.Default
                local cap = new("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.fromOffset(52, 22),
                    BackgroundColor3 = T.Background,
                    Text = key and shortKey(key) or "none",
                    TextSize = 11,
                    Font = Enum.Font.Code,
                    TextColor3 = T.SubText,
                    AutoButtonColor = false,
                    Parent = row,
                })
                round(cap, 4)
                border(cap, T.Stroke, 0.5)

                local callback = c.Callback
                local obj = {}
                function obj:_assign(k)
                    key = k
                    cap.Text = shortKey(k)
                    cap.TextColor3 = T.SubText
                    bindListener = nil
                    if callback then
                        task.spawn(callback, k)
                    end
                end
                function obj:_cancel()
                    cap.Text = key and shortKey(key) or "none"
                    cap.TextColor3 = T.SubText
                    bindListener = nil
                end
                cap.MouseButton1Click:Connect(function()
                    if bindListener == obj then
                        obj:_cancel()
                    else
                        cap.Text = "···"
                        cap.TextColor3 = T.Accent
                        bindListener = obj
                    end
                end)
                function obj:Set(k)
                    key = k
                    cap.Text = k and shortKey(k) or "none"
                end
                function obj:Get()
                    return key
                end
                function obj:SetCallback(f)
                    callback = f
                end
                registerFlag(c, function()
                    return key
                end, function(k)
                    obj:Set(k)
                end)
                return obj
            end

            function section:AddInput(c)
                c = c or {}
                local row = makeRow(34)
                rowLabel(row, c.Name or "input")
                local box = new("TextBox", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.fromOffset(160, 24),
                    BackgroundColor3 = T.Background,
                    Text = c.Default or "",
                    PlaceholderText = c.Placeholder or "...",
                    PlaceholderColor3 = T.SubText,
                    TextColor3 = T.Text,
                    TextSize = 12,
                    Font = Enum.Font.Code,
                    ClearTextOnFocus = false,
                    ClipsDescendants = true,
                    Parent = row,
                })
                round(box, 4)
                border(box, T.Stroke, 0.5)
                new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = box })

                local callback = c.Callback
                box.FocusLost:Connect(function(enter)
                    if c.Numeric then
                        local n = tonumber(box.Text)
                        if not n then
                            box.Text = c.Default or "0"
                            return
                        end
                        box.Text = tostring(n)
                    end
                    if callback then
                        task.spawn(callback, box.Text, enter)
                    end
                end)

                local obj = {}
                function obj:SetText(v)
                    box.Text = v
                end
                function obj:Get()
                    return box.Text
                end
                function obj:SetCallback(f)
                    callback = f
                end
                registerFlag(c, function()
                    return box.Text
                end, function(v)
                    box.Text = v
                end)
                return obj
            end

            function section:AddColorPicker(c)
                c = c or {}
                local current = c.Default or T.Accent
                local callback = c.Callback

                local wrapper, row, list = makeExpander()
                rowLabel(row, c.Name or "color")
                local swatch = new("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.fromOffset(36, 20),
                    BackgroundColor3 = current,
                    BorderSizePixel = 0,
                    Parent = row,
                })
                round(swatch, 4)
                border(swatch, T.Stroke, 0.5)

                local hueBar = new("Frame", {
                    Position = UDim2.fromOffset(6, 6),
                    Size = UDim2.new(1, -12, 0, 12),
                    BorderSizePixel = 0,
                    Active = true,
                    Parent = list,
                })
                round(hueBar, 3)
                new("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
                    }),
                    Parent = hueBar,
                })
                local hueHandle = new("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Size = UDim2.fromOffset(4, 18),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Parent = hueBar,
                })
                round(hueHandle, 2)
                local hexBox = new("TextBox", {
                    Position = UDim2.fromOffset(6, 26),
                    Size = UDim2.new(1, -12, 0, 22),
                    BackgroundColor3 = T.Background,
                    Text = toHex(current),
                    TextColor3 = T.Text,
                    TextSize = 12,
                    Font = Enum.Font.Code,
                    ClearTextOnFocus = false,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Parent = list,
                })
                round(hexBox, 4)
                border(hexBox, T.Stroke, 0.5)

                local h, s, v = current:ToHSV()

                local function setColor(col, silent)
                    current = col
                    h, s, v = col:ToHSV()
                    swatch.BackgroundColor3 = col
                    hueHandle.Position = UDim2.new(h, 0, 0.5, 0)
                    hexBox.Text = toHex(col)
                    if not silent and callback then
                        task.spawn(callback, col)
                    end
                end

                local draggingHue = false
                local function apply(x)
                    hueHandle.Position = UDim2.new(
                        math.clamp((x - hueBar.AbsolutePosition.X) / math.max(hueBar.AbsoluteSize.X, 1), 0, 1), 0, 0.5, 0)
                    setColor(Color3.fromHSV(hueHandle.Position.X.Scale, s, v))
                end
                hueBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        draggingHue = true
                        apply(input.Position.X)
                    end
                end)
                connect(UserInputService.InputChanged, function(input)
                    if draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch) then
                        apply(input.Position.X)
                    end
                end)
                connect(UserInputService.InputEnded, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        draggingHue = false
                    end
                end)
                hexBox.FocusLost:Connect(function()
                    local col = fromHex(hexBox.Text)
                    if col then
                        setColor(col)
                    else
                        hexBox.Text = toHex(current)
                    end
                end)

                local open = false
                local lastToggle = 0
                local function closeList()
                    open = false
                    tween(list, 0.18, { Size = UDim2.new(1, 0, 0, 0) })
                    if activeDropdown and activeDropdown.close == closeList then
                        activeDropdown = nil
                    end
                end
                row.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        local now = os.clock()
                        if now - lastToggle < 0.2 then
                            return
                        end
                        lastToggle = now
                        if open then
                            closeList()
                        else
                            if activeDropdown then
                                activeDropdown.close()
                            end
                            open = true
                            tween(list, 0.2, { Size = UDim2.new(1, 0, 0, 56) })
                            activeDropdown = { close = closeList, root = wrapper }
                        end
                    end
                end)

                setColor(current, true)

                local obj = {}
                function obj:Set(col)
                    setColor(col, true)
                end
                function obj:Get()
                    return current
                end
                function obj:SetCallback(f)
                    callback = f
                end
                registerFlag(c, function()
                    return current
                end, function(col)
                    obj:Set(col)
                end)
                return obj
            end

            function section:AddLabel(c)
                local text = type(c) == "string" and c or (c and c.Text or "label")
                local l = new("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextSize = 13,
                    TextColor3 = T.SubText,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = nextOrder(),
                    Parent = inner,
                })
                local obj = {}
                function obj:SetText(v)
                    l.Text = v
                end
                return obj
            end

            function section:AddParagraph(c)
                c = c or {}
                local holder = new("Frame", {
                    BackgroundColor3 = T.Element,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = nextOrder(),
                    Parent = inner,
                })
                round(holder, 5)
                border(holder, T.Stroke, 1)
                local title = new("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(12, 10),
                    Size = UDim2.new(1, -24, 0, 14),
                    Font = Enum.Font.GothamMedium,
                    Text = c.Title or "",
                    TextSize = 13,
                    TextColor3 = T.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = holder,
                })
                local body = new("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 28),
                    Size = UDim2.new(1, -24, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Font = Enum.Font.Gotham,
                    Text = c.Text or "",
                    TextSize = 12,
                    TextColor3 = T.SubText,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    Parent = holder,
                })
                new("UIPadding", { PaddingBottom = UDim.new(0, 10), Parent = holder })
                local obj = {}
                function obj:SetText(v)
                    body.Text = v
                end
                function obj:SetTitle(v)
                    title.Text = v
                end
                return obj
            end

            function section:AddDivider()
                new("Frame", {
                    BackgroundColor3 = T.Stroke,
                    BackgroundTransparency = 0.3,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 1),
                    LayoutOrder = nextOrder(),
                    Parent = inner,
                })
            end

            return section
        end

        table.insert(tabs, tab)
        table.insert(window.Tabs, tab)
        if #tabs == 1 then
            selectTab(tab)
        end
        return tab
    end

    function window:Toggle()
        if window.Open then
            hide()
        else
            show()
        end
    end
    window.Show = show
    window.Hide = hide
    function window:Get(flag)
        local f = flags[flag]
        return f and f.Get() or nil
    end
    function window:Set(flag, v)
        local f = flags[flag]
        if f then
            f.Set(v)
        end
    end
    function window:Destroy()
        for _, c in ipairs(conns) do
            pcall(function()
                c:Disconnect()
            end)
        end
        gui:Destroy()
    end

    return window
end

return Koi
