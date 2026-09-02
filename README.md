# Koi

## Загрузка

```lua
local Crest = loadstring(game:HttpGet("https://raw.githubusercontent.com/Siidodirnfb/KoiUi/main/koi.lua"))()
```

## Окно

```lua
local Window = Crest:CreateWindow({
	Name = "Crest",
	SubTitle = "главное меню",
})
```

SubTitle необязательно.

## Табы

```lua
local Main = Window:AddTab({ Name = "Главный" })
local Extra = Window:AddTab({ Name = "Разное", Icon = "rbxassetid://0" })
```

Icon необязателен. Первый созданный таб открывается сразу.

## Секции

```lua
local Movement = Main:AddSection({ Name = "Движение" })
```

Имя секции выводится заглавными буквами. Элементы можно добавлять и в секцию, и напрямую в таб.

## Кнопка

```lua
local Kill = Movement:AddButton({
	Name = "Убить всех",
	Callback = function()
		print("нажато")
	end,
})

Kill:Set("Новое название")
```

## Переключатель

```lua
local Fly = Movement:AddToggle({
	Name = "Полёт",
	Default = false,
	Callback = function(value)
		print(value)
	end,
})

Fly:Set(true)
local state = Fly:Get()
```

## Слайдер

```lua
local Speed = Movement:AddSlider({
	Name = "Скорость",
	Min = 16,
	Max = 200,
	Default = 32,
	Increment = 1,
	Callback = function(value)
		print(value)
	end,
})

Speed:Set(64)
local value = Speed:Get()
```

Callback срабатывает при каждом изменении во время перетаскивания.

## Список

```lua
local Weapon = Movement:AddDropdown({
	Name = "Оружие",
	Options = { "Пистолет", "Дробовик", "Снайперка" },
	Default = "Пистолет",
	Callback = function(value)
		print(value)
	end,
})

Weapon:Set("Дробовик")
Weapon:Refresh({ "Нож", "Граната" }, false)
local current = Weapon:Get()
```

Второй аргумент Refresh оставляет выбранный пункт, если он есть в новом списке.

## Клавиша

```lua
local Bind = Movement:AddKeybind({
	Name = "Открыть меню",
	Default = Enum.KeyCode.F,
	Callback = function()
		print("клавиша нажата")
	end,
})

Bind:Set(Enum.KeyCode.G)
```

Кликните по клавише справа, затем нажмите нужную. Backspace очищает привязку, Escape отменяет выбор.

## Поле ввода

```lua
local Nick = Movement:AddTextbox({
	Name = "Ник",
	Default = "",
	Placeholder = "введите текст",
	Callback = function(text)
		print(text)
	end,
})

Nick:Set("текст")
local text = Nick:Get()
```

Callback срабатывает, когда поле теряет фокус.

## Цвет

```lua
local Trail = Extra:AddColorPicker({
	Name = "Цвет трейла",
	Default = Color3.fromRGB(94, 190, 148),
	Callback = function(color)
		print(color)
	end,
})

Trail:Set(Color3.fromRGB(255, 0, 0))
local color = Trail:Get()
```

Клик по плашке справа открывает область выбора цвета.

## Надпись и абзац

```lua
local Info = Main:AddLabel({ Text = "Версия 1.0" })
Info:Set("Версия 1.1")

local Help = Main:AddParagraph({
	Title = "Подсказка",
	Content = "Зажмите верхнюю панель, чтобы передвинуть окно.",
})

Help:Set("Новое", "Новый текст")
```

## Разделитель

```lua
Main:AddDivider()
```

## Уведомления

```lua
Crest:Notify({
	Title = "Готово",
	Content = "Скрипт запущен",
	Type = "Info",
	Duration = 5,
})
```

Type: Info, Warning, Danger. Без Type используется акцентный цвет. Duration в секундах, по умолчанию 4. Клик по уведомлению закрывает его раньше времени, то же самое делает метод Close:

```lua
local Note = Crest:Notify({ Title = "Заголовок", Content = "Текст", Duration = 10 })
task.wait(2)
Note:Close()
```

Примеры вызова разных типов:

```lua
Crest:Notify({ Title = "Примечание", Content = "Настройки сохранены", Type = "Info" })
Crest:Notify({ Title = "Внимание", Content = "Слайдер влияет на скорость", Type = "Warning" })
Crest:Notify({ Title = "Опасно", Content = "Скрипт может кикнуть", Type = "Danger" })
```

Пример использования:
```lua
local Crest = loadstring(game:HttpGet("https://raw.githubusercontent.com/ВАШ_НИК/РЕПО/main/Crest.lua"))()

local Window = Crest:CreateWindow({
	Name = "Koi",
	SubTitle = "v1.0",
})

local Tab1 = Window:AddTab({ Name = "Главный" })
local Tab2 = Window:AddTab({ Name = "Настройки" })

local Section1 = Tab1:AddSection({ Name = "Боевая" })

Section1:AddButton({
	Name = "Убить всех",
	Callback = function()
		print("Кнопка нажата!")
	end,
})

local Fly = Section1:AddToggle({
	Name = "Полёт",
	Default = false,
	Callback = function(value)
		print("Полёт: " .. tostring(value))
	end,
})

local Speed = Section1:AddSlider({
	Name = "Скорость",
	Min = 1,
	Max = 200,
	Default = 32,
	Increment = 1,
	Callback = function(value)
		print("Скорость: " .. value)
	end,
})

local Weapon = Section1:AddDropdown({
	Name = "Оружие",
	Options = { "Пистолет", "Дробовик", "Снайперка" },
	Default = "Пистолет",
	Callback = function(value)
		print("Оружие: " .. value)
	end,
})

local Bind = Section1:AddKeybind({
	Name = "Активировать",
	Default = Enum.KeyCode.F,
	Callback = function()
		print("Клавиша нажата")
	end,
})

local Nick = Section1:AddTextbox({
	Name = "Ник",
	Default = "Игрок",
	Placeholder = "введите ник",
	Callback = function(text)
		print("Ник: " .. text)
	end,
})

local Color = Section1:AddColorPicker({
	Name = "Цвет",
	Default = Color3.fromRGB(94, 190, 148),
	Callback = function(color)
		print("Цвет: " .. color)
	end,
})

local Info = Tab1:AddLabel({ Text = "Просто текст" })
local Para = Tab1:AddParagraph({ Title = "Заголовок", Content = "Длинный текст абзаца" })
Tab1:AddDivider()

local SettingsSec = Tab2:AddSection({ Name = "Вид" })
SettingsSec:AddToggle({ Name = "Скрыть интерфейс игры", Default = false })

-- Получить/поставить значение программно
Fly:Set(true)
Speed:Set(64)
Weapon:Set("Снайперка")
Bind:Set(Enum.KeyCode.G)
Nick:Set "Новый ник"
Color:Set(Color3.fromRGB(255, 0, 0))

-- Уведомления
Crest:Notify({ Title = "Готово", Content = "Скрипт загружен", Type = "Info", Duration = 4 })
Crest:Notify({ Title = "Внимание", Content = "Слайдер влияет на скорость", Type = "Warning" })
Crest:Notify({ Title = "Опасно", Content = "Скрипт может кикнуть", Type = "Danger" })
```

