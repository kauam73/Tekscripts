-- UILibrary.lua
local UILibrary = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Configuração do tema
local Theme = {
    Primary = Color3.fromRGB(30, 30, 30),
    Secondary = Color3.fromRGB(50, 50, 50),
    Accent = Color3.fromRGB(0, 120, 215),
    TextColor = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.Gotham,
    MobileBreakpoint = 600
}

-- Sistema de notificações
local Notifications = {
    ActiveNotifications = {},
    MaxNotifications = 5
}

function Notifications:Notify(title, message, options)
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.BackgroundColor3 = Theme.Primary
    notification.Size = UDim2.new(0.9, 0, 0, 60)
    notification.Position = UDim2.new(0.5, 0, 1, 0)
    notification.AnchorPoint = Vector2.new(0.5, 1)
    notification.BorderSizePixel = 0
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.Font = Theme.Font
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = options and options.Color or Theme.Accent
    -- ... (código completo da notificação)

    table.insert(self.ActiveNotifications, notification)
    self:UpdatePositions()
    
    task.delay(options and options.Duration or 5, function()
        self:DestroyNotification(notification)
    end)
end

-- Componentes principais
function UILibrary:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UILibrary"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local Container = Instance.new("Frame")
    Container.Name = "WindowContainer"
    Container.Size = UDim2.new(0.3, 0, 0.4, 0)
    Container.Position = UDim2.new(0.35, 0, 0.3, 0)
    Container.BackgroundColor3 = Theme.Primary
    Container.BorderSizePixel = 0
    Container.ClipsDescendants = true
    -- ... (código de inicialização completo)

    local Window = {
        Gui = ScreenGui,
        Container = Container,
        Elements = {},
        MobileAdapted = false
    }

    function Window:AdaptForMobile()
        if UserInputService.TouchEnabled and not self.MobileAdapted then
            self.Container.Size = UDim2.new(1, -20, 1, -20)
            self.Container.Position = UDim2.new(0.5, 0, 0.5, 0)
            self.Container.AnchorPoint = Vector2.new(0.5, 0.5)
            self.MobileAdapted = true
        end
    end

    function Window:CreateButton(config)
        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.Size = UDim2.new(1, -20, 0, 40)
        Button.Position = UDim2.new(0, 10, 0, #self.Elements * 50 + 40)
        -- ... (configuração completa do botão)
        
        table.insert(self.Elements, Button)
        self:UpdateLayout()
        return Button
    end

    function Window:CreateToggle(config)
        local Toggle = Instance.new("Frame")
        Toggle.Name = "Toggle"
        Toggle.Size = UDim2.new(1, -20, 0, 30)
        -- ... (código completo do toggle)
        return Toggle
    end

    -- Métodos adicionais para outros componentes (Slider, Label, etc)

    function Window:Destroy()
        self.Gui:Destroy()
    end

    Window:AdaptForMobile()
    return Window
end

-- Sistema de loading screen
function UILibrary:CreateLoadingScreen(config)
    config = config or {}
    local LoadingGui = Instance.new("ScreenGui")
    LoadingGui.Name = "LoadingScreen"
    LoadingGui.IgnoreGuiInset = true
    LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 1, 0)
    Container.BackgroundColor3 = Theme.Primary
    -- ... (código completo da loading screen)

    local LoadingScreen = {
        UpdateProgress = function(progress)
            ProgressBar.Size = UDim2.new(progress, 0, 0, 4)
        end,
        Destroy = function()
            LoadingGui:Destroy()
        end
    }

    return LoadingScreen
end

-- Inicialização móvel
if UserInputService.TouchEnabled then
    Theme.TextSize = 18
    Theme.WindowPadding = 15
end

return UILibrary
