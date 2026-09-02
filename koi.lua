local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local Theme = {
	Background = Color3.fromRGB(22, 23, 27),
	Topbar = Color3.fromRGB(27, 29, 33),
	Sidebar = Color3.fromRGB(27, 29, 33),
	Element = Color3.fromRGB(34, 36, 41),
	ElementHover = Color3.fromRGB(41, 44, 50),
	Stroke = Color3.fromRGB(49, 52, 59),
	Text = Color3.fromRGB(235, 236, 240),
	SubText = Color3.fromRGB(146, 150, 159),
	Accent = Color3.fromRGB(94, 190, 148),
	Track = Color3.fromRGB(49, 52, 59),
	Info = Color3.fromRGB(96, 165, 232),
	Warning = Color3.fromRGB(232, 176, 78),
	Danger = Color3.fromRGB(228, 92, 92),
}

local Crest = {}
Crest.__index = Crest

local root
local notifyHolder
local activeWindow

local function create(class, props)
	local inst = Instance.new(class)
	local parent = props.Parent
	for key, value in pairs(props) do
		if key ~= "Parent" then
			inst[key] = value
		end
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function round(inst, px)
	return create("UICorner", { CornerRadius = UDim.new(0, px), Parent = inst })
end

local function circle(inst)
	return create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = inst })
end

local function addStroke(inst, color, transparency)
	return create("UIStroke", {
		Color = color or Theme.Stroke,
		Thickness = 1,
		Transparency = transparency or 0.25,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = inst,
	})
end

local function tween(inst, time, props)
	local t = TweenService:Create(inst, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function fire(fn, ...)
	if type(fn) == "function" then
		task.spawn(fn, ...)
	end
end

local function getGuiParent()
	local ok, holder = pcall(function()
		return LocalPlayer.PlayerGui
	end)
	if ok and holder then
		return holder
	end
	return game:GetService("CoreGui")
end

local function ensureGui()
	if root and root.Parent then
		return root
	end
	root = create("ScreenGui", {
		Name = "Crest_" .. tostring(math.floor(tick() % 100000)),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
		Parent = getGuiParent(),
	})
	return root
end

local function makeDraggable(handle, target)
	local dragging = false
	local startInput, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startInput = input.Position
			startPos = target.Position
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - startInput
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local function chevron(parent, size, color)
	local holder = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(size, size),
		Parent = parent,
	})
	local thickness = math.max(2, math.floor(size * 0.2))
	local length = math.floor(size * 0.65)
	create("Frame", {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.3, 0.5),
		Size = UDim2.fromOffset(length, thickness),
		Rotation = 45,
		Parent = holder,
	})
	create("Frame", {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.7, 0.5),
		Size = UDim2.fromOffset(length, thickness),
		Rotation = -45,
		Parent = holder,
	})
	return holder
end

local NotifyColors = {
	Info = Theme.Info,
	Warning = Theme.Warning,
	Danger = Theme.Danger,
}

local function getNotifyHolder()
	local gui = ensureGui()
	if not notifyHolder or not notifyHolder.Parent then
		notifyHolder = create("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -14, 0, 14),
			Size = UDim2.fromOffset(300, 0),
			Parent = gui,
		})
		create("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = notifyHolder,
		})
	end
	return notifyHolder
end

function Crest:Notify(cfg)
	cfg = cfg or {}
	local holder = getNotifyHolder()
	local color = NotifyColors[cfg.Type] or Theme.Accent

	local toast = create("CanvasGroup", {
		BackgroundColor3 = Theme.Element,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		GroupTransparency = 1,
		Parent = holder,
	})
	round(toast, 8)
	addStroke(toast)
	local bar = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.new(0, 3, 1, -20),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Parent = toast,
	})
	round(bar, 2)
	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(22, 10),
		Size = UDim2.new(1, -34, 0, 16),
		Font = Enum.Font.GothamBold,
		Text = cfg.Title or "Crest",
		TextSize = 13,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = toast,
	})
	if cfg.Content and cfg.Content ~= "" then
		create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(22, 30),
			Size = UDim2.new(1, -34, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Font = Enum.Font.Gotham,
			Text = cfg.Content,
			TextSize = 12,
			TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			Parent = toast,
		})
	end
	create("UIPadding", {
		PaddingBottom = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 12),
		Parent = toast,
	})
	create("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = toast,
	})
	local closed = false
	local function close()
		if closed then
			return
		end
		closed = true
		local out = tween(toast, 0.25, { GroupTransparency = 1 })
		out.Completed:Connect(function()
			toast:Destroy()
		end)
	end
	toast.TextButton.Activated:Connect(close)
	tween(toast, 0.25, { GroupTransparency = 0 })
	task.delay(cfg.Duration or 4, close)
	return { Close = close }
end

local makeHost

makeHost = function(container, startOrder)
	local host = {}
	local order = startOrder or 0

	local function nextOrder()
		order = order + 1
		return order
	end

	local function baseRow(height, auto)
		local row = create("Frame", {
			BackgroundColor3 = Theme.Element,
			BorderSizePixel = 0,
			Size = auto and UDim2.new(1, 0, 0, 0) or UDim2.new(1, 0, 0, height),
			AutomaticSize = auto and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
			LayoutOrder = nextOrder(),
			Parent = container,
		})
		round(row, 6)
		addStroke(row)
		return row
	end

	local function rowTitle(row, text)
		return create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -28, 1, 0),
			Font = Enum.Font.GothamMedium,
			Text = text,
			TextSize = 13,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = row,
		})
	end

	local function addHitbox(row, onClick)
		local hit = create("TextButton", {
			Text = "",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Parent = row,
		})
		hit.MouseEnter:Connect(function()
			tween(row, 0.1, { BackgroundColor3 = Theme.ElementHover })
		end)
		hit.MouseLeave:Connect(function()
			tween(row, 0.1, { BackgroundColor3 = Theme.Element })
		end)
		hit.Activated:Connect(onClick)
		return hit
	end

	function host:AddSection(cfg)
		cfg = cfg or {}
		local frame = create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = nextOrder(),
			Parent = container,
		})
		create("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = frame,
		})
		create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			Font = Enum.Font.GothamBold,
			Text = string.upper(cfg.Name or "Section"),
			TextSize = 11,
			TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			LayoutOrder = 1,
			Parent = frame,
		})
		create("Frame", {
			BackgroundColor3 = Theme.Stroke,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 1),
			LayoutOrder = 2,
			Parent = frame,
		})
		return makeHost(frame, 2)
	end

	function host:AddButton(cfg)
		cfg = cfg or {}
		local row = create("TextButton", {
			Text = "",
			AutoButtonColor = false,
			BackgroundColor3 = Theme.Element,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 38),
			LayoutOrder = nextOrder(),
			Parent = container,
		})
		round(row, 6)
		addStroke(row)
		local label = rowTitle(row, cfg.Name or "Button")
		row.MouseEnter:Connect(function()
			tween(row, 0.1, { BackgroundColor3 = Theme.ElementHover })
		end)
		row.MouseLeave:Connect(function()
			tween(row, 0.1, { BackgroundColor3 = Theme.Element })
		end)
		row.Activated:Connect(function()
			fire(cfg.Callback)
		end)
		local object = {}
		function object:Set(text)
			label.Text = tostring(text)
		end
		return object
	end

	function host:AddToggle(cfg)
		cfg = cfg or {}
		local state = cfg.Default == true
		local row = baseRow(38)
		rowTitle(row, cfg.Name or "Toggle")
		local switch = create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(38, 20),
			BackgroundColor3 = state and Theme.Accent or Theme.Track,
			BorderSizePixel = 0,
			Parent = row,
		})
		circle(switch)
		local knob = create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, state and 20 or 3, 0.5, 0),
			Size = UDim2.fromOffset(14, 14),
			BackgroundColor3 = Color3.fromRGB(235, 236, 240),
			BorderSizePixel = 0,
			Parent = switch,
		})
		circle(knob)
		local function render()
			tween(switch, 0.15, { BackgroundColor3 = state and Theme.Accent or Theme.Track })
			tween(knob, 0.15, { Position = UDim2.new(0, state and 20 or 3, 0.5, 0) })
		end
		local function set(value)
			local newValue = value == true
			if newValue == state then
				return
			end
			state = newValue
			render()
			fire(cfg.Callback, state)
		end
		addHitbox(row, function()
			set(not state)
		end)
		local object = {}
		function object:Set(value)
			set(value == true)
		end
		function object:Get()
			return state
		end
		return object
	end

	function host:AddSlider(cfg)
		cfg = cfg or {}
		local min = cfg.Min or 0
		local max = cfg.Max or 100
		local inc = cfg.Increment or 1
		if inc <= 0 then
			inc = 1
		end
		local decimals = 0
		local _, dot = tostring(inc):find("%.")
		if dot then
			decimals = #tostring(inc) - dot
		end
		local value = math.clamp(cfg.Default or min, min, max)
		local row = baseRow(58)
		create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 9),
			Size = UDim2.new(1, -100, 0, 16),
			Font = Enum.Font.GothamMedium,
			Text = cfg.Name or "Slider",
			TextSize = 13,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = row,
		})
		local valueLabel = create("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -14, 9, 0),
			Size = UDim2.fromOffset(80, 16),
			Font = Enum.Font.GothamBold,
			Text = string.format("%." .. decimals .. "f", value),
			TextSize = 12,
			TextColor3 = Theme.Accent,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = row,
		})
		local track = create("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 14, 1, -12),
			Size = UDim2.new(1, -28, 0, 6),
			BackgroundColor3 = Theme.Track,
			BorderSizePixel = 0,
			Active = true,
			Parent = row,
		})
		round(track, 3)
		local fill = create("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			Parent = track,
		})
		round(fill, 3)
		local knob = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromOffset(14, 14),
			BackgroundColor3 = Color3.fromRGB(235, 236, 240),
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = track,
		})
		circle(knob)
		addStroke(knob, Theme.Accent, 0.4)

		local function render()
			local alpha = (value - min) / math.max(max - min, 1e-6)
			fill.Size = UDim2.fromScale(alpha, 1)
			knob.Position = UDim2.fromScale(alpha, 0.5)
			valueLabel.Text = string.format("%." .. decimals .. "f", value)
		end

		local function apply(raw)
			raw = math.floor(raw / inc + 0.5) * inc
			raw = math.clamp(raw, min, max)
			raw = tonumber(string.format("%." .. decimals .. "f", raw))
			if raw ~= value then
				value = raw
				render()
				fire(cfg.Callback, value)
			end
		end

		local function updateFromInput(input)
			local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
			apply(min + (max - min) * rel)
		end

		local sliding = false
		track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				sliding = true
				updateFromInput(input)
			end
		end)
		track.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				sliding = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateFromInput(input)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				sliding = false
			end
		end)
		render()
		local object = {}
		function object:Set(newValue)
			apply(tonumber(newValue) or value)
		end
		function object:Get()
			return value
		end
		return object
	end

	function host:AddDropdown(cfg)
		cfg = cfg or {}
		local options = cfg.Options or {}
		local current = cfg.Default
		local isOpen = false
		local row = create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = nextOrder(),
			Parent = container,
		})
		create("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = row,
		})
		local header = create("TextButton", {
			Text = "",
			AutoButtonColor = false,
			BackgroundColor3 = Theme.Element,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 38),
			LayoutOrder = 1,
			Parent = row,
		})
		round(header, 6)
		addStroke(header)
		create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -160, 1, 0),
			Font = Enum.Font.GothamMedium,
			Text = cfg.Name or "Dropdown",
			TextSize = 13,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = header,
		})
		local valueLabel = create("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -34, 0, 0),
			Size = UDim2.fromOffset(110, 38),
			Font = Enum.Font.Gotham,
			Text = current ~= nil and tostring(current) or "",
			TextSize = 12,
			TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = header,
		})
		local arrow = chevron(header, 10, Theme.SubText)
		arrow.AnchorPoint = Vector2.new(1, 0.5)
		arrow.Position = UDim2.new(1, -12, 0.5, 0)
		local panel = create("Frame", {
			BackgroundColor3 = Theme.Background,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Visible = false,
			LayoutOrder = 2,
			Parent = row,
		})
		round(panel, 6)
		addStroke(panel)
		create("UIListLayout", {
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = panel,
		})
		create("UIPadding", {
			PaddingTop = UDim.new(0, 6),
			PaddingBottom = UDim.new(0, 6),
			PaddingLeft = UDim.new(0, 6),
			PaddingRight = UDim.new(0, 6),
			Parent = panel,
		})

		local function setOpen(state)
			isOpen = state == true
			panel.Visible = isOpen
			arrow.Rotation = isOpen and 180 or 0
		end

		local buttons = {}
		local function rebuild()
			for _, btn in ipairs(buttons) do
				btn:Destroy()
			end
			buttons = {}
			for i, opt in ipairs(options) do
				local btn = create("TextButton", {
					Text = "",
					AutoButtonColor = false,
					BackgroundColor3 = Theme.Element,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 28),
					LayoutOrder = i,
					Parent = panel,
				})
				round(btn, 4)
				create("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(10, 0),
					Size = UDim2.new(1, -20, 1, 0),
					Font = Enum.Font.Gotham,
					Text = tostring(opt),
					TextSize = 13,
					TextColor3 = opt == current and Theme.Accent or Theme.SubText,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Parent = btn,
				})
				if opt == current then
					local dotMark = create("Frame", {
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(1, -10, 0.5, 0),
						Size = UDim2.fromOffset(6, 6),
						BackgroundColor3 = Theme.Accent,
						BorderSizePixel = 0,
						Parent = btn,
					})
					circle(dotMark)
				end
				btn.MouseEnter:Connect(function()
					tween(btn, 0.1, { BackgroundColor3 = Theme.ElementHover })
				end)
				btn.MouseLeave:Connect(function()
					tween(btn, 0.1, { BackgroundColor3 = Theme.Element })
				end)
				btn.Activated:Connect(function()
					setOpen(false)
					if opt ~= current then
						current = opt
						valueLabel.Text = tostring(current)
						rebuild()
						fire(cfg.Callback, current)
					end
				end)
				table.insert(buttons, btn)
			end
		end

		header.Activated:Connect(function()
			setOpen(not isOpen)
		end)
		local object = {}
		function object:Set(value)
			for _, opt in ipairs(options) do
				if opt == value then
					if opt ~= current then
						current = value
						valueLabel.Text = tostring(current)
						rebuild()
						fire(cfg.Callback, current)
					end
					return
				end
			end
		end
		function object:Get()
			return current
		end
		function object:Refresh(newOptions, keepSelection)
			options = newOptions or {}
			if keepSelection then
				local stillThere = false
				for _, opt in ipairs(options) do
					if opt == current then
						stillThere = true
					end
				end
				if not stillThere then
					current = nil
					valueLabel.Text = ""
				end
			else
				current = nil
				valueLabel.Text = ""
			end
			rebuild()
		end
		rebuild()
		return object
	end

	function host:AddKeybind(cfg)
		cfg = cfg or {}
		local key = cfg.Default
		local listening = false
		local row = baseRow(38)
		rowTitle(row, cfg.Name or "Keybind")
		addHitbox(row, function() end)
		local chip = create("TextButton", {
			Text = "",
			AutoButtonColor = false,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 0, 24),
			BackgroundColor3 = Theme.Track,
			BorderSizePixel = 0,
			Parent = row,
		})
		round(chip, 5)
		create("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			Parent = chip,
		})
		local chipLabel = create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Font = Enum.Font.GothamBold,
			Text = key and key.Name or "None",
			TextSize = 12,
			TextColor3 = Theme.SubText,
			Parent = chip,
		})
		local function stopListen()
			listening = false
			chipLabel.Text = key and key.Name or "None"
			chipLabel.TextColor3 = Theme.SubText
		end
		chip.Activated:Connect(function()
			if listening then
				stopListen()
				return
			end
			listening = true
			chipLabel.Text = "..."
			chipLabel.TextColor3 = Theme.Accent
		end)
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if listening then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					if input.KeyCode == Enum.KeyCode.Escape then
						stopListen()
					elseif input.KeyCode == Enum.KeyCode.Backspace then
						key = nil
						stopListen()
					else
						key = input.KeyCode
						stopListen()
					end
				end
				return
			end
			if key and input.KeyCode == key and not gameProcessed then
				fire(cfg.Callback, key)
			end
		end)
		local object = {}
		function object:Set(newKey)
			key = newKey
			chipLabel.Text = key and key.Name or "None"
		end
		function object:Get()
			return key
		end
		return object
	end

	function host:AddTextbox(cfg)
		cfg = cfg or {}
		local row = baseRow(38)
		rowTitle(row, cfg.Name or "Textbox")
		local box = create("TextBox", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(160, 26),
			BackgroundColor3 = Theme.Background,
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Text = cfg.Default or "",
			PlaceholderText = cfg.Placeholder or "",
			PlaceholderColor3 = Theme.SubText,
			TextSize = 13,
			TextColor3 = Theme.Text,
			ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
		round(box, 5)
		create("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			Parent = box,
		})
		box.FocusLost:Connect(function()
			fire(cfg.Callback, box.Text)
		end)
		local object = {}
		function object:Set(text)
			box.Text = tostring(text)
		end
		function object:Get()
			return box.Text
		end
		return object
	end

	function host:AddLabel(cfg)
		cfg = cfg or {}
		local label = create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 20),
			LayoutOrder = nextOrder(),
			Font = Enum.Font.Gotham,
			Text = cfg.Text or cfg.Name or "Label",
			TextSize = 13,
			TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = container,
		})
		local object = {}
		function object:Set(text)
			label.Text = tostring(text)
		end
		return object
	end

	function host:AddParagraph(cfg)
		cfg = cfg or {}
		local row = baseRow(0, true)
		create("UIListLayout", {
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = row,
		})
		create("UIPadding", {
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			Parent = row,
		})
		local title = create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 16),
			Font = Enum.Font.GothamBold,
			Text = cfg.Title or cfg.Name or "Paragraph",
			TextSize = 13,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			LayoutOrder = 1,
			Parent = row,
		})
		local content = create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Font = Enum.Font.Gotham,
			Text = cfg.Content or "",
			TextSize = 13,
			TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			LayoutOrder = 2,
			Parent = row,
		})
		local object = {}
		function object:Set(newTitle, newContent)
			title.Text = tostring(newTitle)
			if newContent ~= nil then
				content.Text = tostring(newContent)
			end
		end
		return object
	end

	function host:AddDivider()
		local line = create("Frame", {
			BackgroundColor3 = Theme.Stroke,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 1),
			LayoutOrder = nextOrder(),
			Parent = container,
		})
		return line
	end

	function host:AddColorPicker(cfg)
		cfg = cfg or {}
		local color = cfg.Default or Theme.Accent
		local h, s, v = Color3.toHSV(color)
		local isOpen = false
		local row = create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = nextOrder(),
			Parent = container,
		})
		create("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = row,
		})
		local header = create("TextButton", {
			Text = "",
			AutoButtonColor = false,
			BackgroundColor3 = Theme.Element,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 38),
			LayoutOrder = 1,
			Parent = row,
		})
		round(header, 6)
		addStroke(header)
		create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -100, 1, 0),
			Font = Enum.Font.GothamMedium,
			Text = cfg.Name or "Color",
			TextSize = 13,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = header,
		})
		local swatch = create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(30, 18),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Parent = header,
		})
		round(swatch, 4)
		addStroke(swatch)
		local arrow = chevron(header, 10, Theme.SubText)
		arrow.AnchorPoint = Vector2.new(1, 0.5)
		arrow.Position = UDim2.new(1, -50, 0.5, 0)
		local panel = create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Visible = false,
			LayoutOrder = 2,
			Parent = row,
		})
		create("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = panel,
		})
		local sv = create("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 110),
			Active = true,
			LayoutOrder = 1,
			Parent = panel,
		})
		round(sv, 6)
		addStroke(sv, Theme.Stroke, 0.5)
		local satGradient = create("UIGradient", {
			Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(255, 0, 0)),
			Parent = sv,
		})
		local valueOverlay = create("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			Parent = sv,
		})
		round(valueOverlay, 6)
		create("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 0),
			}),
			Parent = valueOverlay,
		})
		local svCursor = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(s, 1 - v),
			Size = UDim2.fromOffset(10, 10),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 3,
			Parent = sv,
		})
		circle(svCursor)
		addStroke(svCursor, Color3.new(0, 0, 0), 0.5)
		local hue = create("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 10),
			Active = true,
			LayoutOrder = 2,
			Parent = panel,
		})
		round(hue, 5)
		create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
				ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
			}),
			Parent = hue,
		})
		local hueCursor = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(h, 0.5),
			Size = UDim2.fromOffset(4, 16),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 3,
			Parent = hue,
		})
		round(hueCursor, 2)
		addStroke(hueCursor)
		local hexLabel = create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 14),
			Font = Enum.Font.Gotham,
			Text = "",
			TextSize = 12,
			TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Right,
			LayoutOrder = 3,
			Parent = panel,
		})

		local function render()
			color = Color3.fromHSV(h, s, v)
			satGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h, 1, 1))
			svCursor.Position = UDim2.fromScale(s, 1 - v)
			hueCursor.Position = UDim2.fromScale(h, 0.5)
			swatch.BackgroundColor3 = color
			hexLabel.Text = string.format("#%02X%02X%02X", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
		end

		local function updateSV(input)
			local relX = math.clamp((input.Position.X - sv.AbsolutePosition.X) / math.max(sv.AbsoluteSize.X, 1), 0, 1)
			local relY = math.clamp((input.Position.Y - sv.AbsolutePosition.Y) / math.max(sv.AbsoluteSize.Y, 1), 0, 1)
			if relX ~= s or (1 - relY) ~= v then
				s = relX
				v = 1 - relY
				render()
				fire(cfg.Callback, color)
			end
		end

		local function updateHue(input)
			local rel = math.clamp((input.Position.X - hue.AbsolutePosition.X) / math.max(hue.AbsoluteSize.X, 1), 0, 1)
			if rel ~= h then
				h = rel
				render()
				fire(cfg.Callback, color)
			end
		end

		local function setOpen(state)
			isOpen = state == true
			panel.Visible = isOpen
			arrow.Rotation = isOpen and 180 or 0
		end

		header.Activated:Connect(function()
			setOpen(not isOpen)
		end)
		local svDragging, hueDragging = false, false
		sv.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				svDragging = true
				updateSV(input)
			end
		end)
		sv.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				svDragging = false
			end
		end)
		hue.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				hueDragging = true
				updateHue(input)
			end
		end)
		hue.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				hueDragging = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				if svDragging then
					updateSV(input)
				end
				if hueDragging then
					updateHue(input)
				end
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				svDragging = false
				hueDragging = false
			end
		end)
		render()
		local object = {}
		function object:Set(newColor)
			if typeof(newColor) == "Color3" then
				h, s, v = Color3.toHSV(newColor)
				render()
				fire(cfg.Callback, color)
			end
		end
		function object:Get()
			return color
		end
		return object
	end

	return host
end

function Crest:CreateWindow(cfg)
	cfg = cfg or {}
	if activeWindow then
		activeWindow:Destroy()
	end
	local gui = ensureGui()

	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local width = math.clamp(cfg.Width or 600, 280, viewport.X - 24)
	local height = math.clamp(cfg.Height or 430, 240, viewport.Y - 24)
	local sidebarWidth = width < 480 and 128 or 164

	local main = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(math.floor(width * 0.94), math.floor(height * 0.94)),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Parent = gui,
	})
	round(main, 10)
	addStroke(main, Theme.Stroke, 0.1)
	tween(main, 0.2, { Size = UDim2.fromOffset(width, height) })

	local topbar = create("Frame", {
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundColor3 = Theme.Topbar,
		BorderSizePixel = 0,
		Active = true,
		Parent = main,
	})
	round(topbar, 10)
	create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 10),
		BackgroundColor3 = Theme.Topbar,
		BorderSizePixel = 0,
		Parent = topbar,
	})
	create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Theme.Stroke,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Parent = topbar,
	})
	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 8),
		Size = UDim2.new(1, -80, 0, 18),
		Font = Enum.Font.GothamBold,
		Text = cfg.Name or "Crest",
		TextSize = 15,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = topbar,
	})
	if cfg.SubTitle then
		create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(16, 28),
			Size = UDim2.new(1, -80, 0, 14),
			Font = Enum.Font.Gotham,
			Text = cfg.SubTitle,
			TextSize = 12,
			TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = topbar,
		})
	end
	local close = create("TextButton", {
		Text = "×",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = Theme.Element,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = Theme.SubText,
		Parent = topbar,
	})
	round(close, 6)
	close.MouseEnter:Connect(function()
		tween(close, 0.12, { BackgroundColor3 = Theme.Danger, BackgroundTransparency = 0, TextColor3 = Color3.new(1, 1, 1) })
	end)
	close.MouseLeave:Connect(function()
		tween(close, 0.12, { BackgroundColor3 = Theme.Element, BackgroundTransparency = 0.5, TextColor3 = Theme.SubText })
	end)

	local showBtn = create("TextButton", {
		Text = "Show",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 8),
		Size = UDim2.fromOffset(64, 26),
		BackgroundColor3 = Theme.Element,
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Theme.Text,
		Visible = false,
		Parent = gui,
	})
	round(showBtn, 6)
	addStroke(showBtn, Theme.Stroke, 0.4)

	local visible = true
	local function setVisible(state)
		visible = state == true
		main.Visible = visible
		showBtn.Visible = not visible
	end
	close.Activated:Connect(function()
		setVisible(false)
	end)
	showBtn.Activated:Connect(function()
		setVisible(true)
	end)

	local sidebar = create("Frame", {
		Position = UDim2.fromOffset(0, 52),
		Size = UDim2.new(0, sidebarWidth, 1, -52),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		Parent = main,
	})
	create("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = Theme.Stroke,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Parent = sidebar,
	})
	local tabList = create("ScrollingFrame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(10, 10),
		Size = UDim2.new(1, -20, 1, -20),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Accent,
		ScrollBarImageTransparency = 0.5,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		BorderSizePixel = 0,
		Parent = sidebar,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = tabList,
	})

	local content = create("ScrollingFrame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(sidebarWidth, 52),
		Size = UDim2.new(1, -sidebarWidth, 1, -52),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Stroke,
		BorderSizePixel = 0,
		Parent = main,
	})
	create("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent = content,
	})

	makeDraggable(topbar, main)

	local tabs = {}
	local Window = {}

	function Window:SelectTab(tab)
		if type(tab) ~= "table" or not tab.Page then
			return
		end
		for _, t in ipairs(tabs) do
			local active = t == tab
			t.Page.Visible = active
			t.Indicator.BackgroundTransparency = active and 0 or 1
			t.Label.TextColor3 = active and Theme.Text or Theme.SubText
			t.Button.BackgroundColor3 = Theme.Element
			t.Button.BackgroundTransparency = active and 0 or 1
		end
	end

	function Window:AddTab(tabCfg)
		tabCfg = tabCfg or {}
		local tab = {}
		local button = create("TextButton", {
			Text = "",
			AutoButtonColor = false,
			BackgroundColor3 = Theme.Element,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 34),
			LayoutOrder = #tabs + 1,
			Parent = tabList,
		})
		round(button, 6)
		local indicator = create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 6, 0.5, 0),
			Size = UDim2.fromOffset(3, 16),
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = button,
		})
		round(indicator, 2)
		local iconOffset = 0
		if tabCfg.Icon then
			create("ImageLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(14, 8),
				Size = UDim2.fromOffset(18, 18),
				Image = tabCfg.Icon,
				ImageColor3 = Theme.SubText,
				Parent = button,
			})
			iconOffset = 24
		end
		local label = create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14 + iconOffset, 0),
			Size = UDim2.new(1, -26 - iconOffset, 1, 0),
			Font = Enum.Font.GothamMedium,
			Text = tabCfg.Name or "Tab",
			TextSize = 13,
			TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = button,
		})
		local page = create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Visible = false,
			Parent = content,
		})
		create("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = page,
		})
		tab.Button = button
		tab.Page = page
		tab.Label = label
		tab.Indicator = indicator
		function tab:Select()
			Window:SelectTab(tab)
		end
		button.MouseEnter:Connect(function()
			if not page.Visible then
				button.BackgroundTransparency = 0.5
			end
		end)
		button.MouseLeave:Connect(function()
			if not page.Visible then
				button.BackgroundTransparency = 1
			end
		end)
		button.Activated:Connect(function()
			Window:SelectTab(tab)
		end)
		local elements = makeHost(page, 0)
		for key, value in pairs(elements) do
			tab[key] = value
		end
		table.insert(tabs, tab)
		if #tabs == 1 then
			Window:SelectTab(tab)
		end
		return tab
	end

	function Window:Toggle()
		setVisible(not visible)
	end

	function Window:Destroy()
		if main and main.Parent then
			main:Destroy()
		end
		if showBtn and showBtn.Parent then
			showBtn:Destroy()
		end
		activeWindow = nil
	end

	activeWindow = Window
	return Window
end

return Crest
