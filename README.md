# Koi

Библиотека интерфейса для Roblox в одном файле. Тёмная тема, табы колонкой слева, окно перетаскивается мышью или пальцем.

## Загрузка

```lua
local Crest = loadstring(game:HttpGet("https://raw.githubusercontent.com/Siidodirnfb/KoiUi/main/Koi.lua"))()
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
