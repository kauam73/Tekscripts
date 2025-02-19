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
    MobileBreakpoint = 600,
    TextSize = 14,
    WindowPadding = 10
}

--------------------------------------------------
-- Sistema de Notificações
--------------------------------------------------
local Notifications = {
    ActiveNotifications = {},
    MaxNotifications = 5
}

function Notifications:UpdatePositions()
    for i, notification in ipairs(self.ActiveNotifications) do
        -- Posiciona as notificações empilhadas na parte inferior da tela
        notification.Position = UDim2.new(0.5, 0, 1, -((i-1) * (notification.Size.Y.Offset + 10)) - 10)
    end
end

function Notifications:DestroyNotification(notification)
    for i, v in ipairs(self.ActiveNotifications) do
        if v == notification then
            table.remove(self.ActiveNotifications, i)
            break
        end
    end
    notification:Destroy()
    self:UpdatePositions()
end

function Notifications:Notify(title, message, options)
    options = options or {}
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.BackgroundColor3 = Theme.Primary
    notification.Size = UDim2.new(0.9, 0, 0, 60)
    notification.AnchorPoint = Vector2.new(0.5, 1)
    notification.Position = UDim2.new(0.5, 0, 1, 0)
    notification.BorderSizePixel = 0
    notification.Parent = game.CoreGui  -- Defina o pai adequado para o seu projeto

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Text = title
    titleLabel.Font = Theme.Font
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = options.Color or Theme.Accent
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.Parent = notification

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "MessageLabel"
    messageLabel.Text = message
    messageLabel.Font = Theme.Font
    messageLabel.TextSize = 14
    messageLabel.TextColor3 = Theme.TextColor
    messageLabel.BackgroundTransparency = 1
    messageLabel.Size = UDim2.new(1, -20, 0, 30)
    messageLabel.Position = UDim2.new(0, 10, 0, 30)
    messageLabel.Parent = notification

    table.insert(self.ActiveNotifications, notification)
    self:UpdatePositions()

    task.delay(options.Duration or 5, function()
        self:DestroyNotification(notification)
    end)
end

--------------------------------------------------
-- Criação da Janela Principal
--------------------------------------------------
function UILibrary:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UILibrary"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.Parent = game.CoreGui  -- Defina o pai adequado

    local Container = Instance.new("Frame")
    Container.Name = "WindowContainer"
    Container.Size = UDim2.new(0.3, 0, 0.4, 0)
    Container.Position = UDim2.new(0.35, 0, 0.3, 0)
    Container.BackgroundColor3 = Theme.Primary
    Container.BorderSizePixel = 0
    Container.ClipsDescendants = true
    Container.Parent = ScreenGui

    -- Layout automático para os elementos
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.FillDirection = Enum.FillDirection.Vertical
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = Container

    local Window = {
        Gui = ScreenGui,
        Container = Container,
        Elements = {},
        MobileAdapted = false,
        Layout = UIListLayout
    }

    function Window:AdaptForMobile()
        if UserInputService.TouchEnabled and not self.MobileAdapted then
            self.Container.Size = UDim2.new(1, -20, 1, -20)
            self.Container.Position = UDim2.new(0.5, 0, 0.5, 0)
            self.Container.AnchorPoint = Vector2.new(0.5, 0.5)
            self.MobileAdapted = true
        end
    end

    -- Atualiza a ordem dos elementos (útil caso não use o UIListLayout ou para ajustes adicionais)
    function Window:UpdateLayout()
        for i, element in ipairs(self.Elements) do
            element.LayoutOrder = i
        end
    end

    function Window:CreateButton(config)
        config = config or {}
        local Button = Instance.new("TextButton")
        Button.Name = config.Name or "Button"
        Button.Size = UDim2.new(1, -20, 0, 40)
        Button.BackgroundColor3 = config.BackgroundColor or Theme.Secondary
        Button.TextColor3 = config.TextColor or Theme.TextColor
        Button.Font = Theme.Font
        Button.TextSize = config.TextSize or 16
        Button.Text = config.Text or "Button"
        Button.Parent = self.Container

        table.insert(self.Elements, Button)
        self:UpdateLayout()
        return Button
    end

    function Window:CreateToggle(config)
        config = config or {}
        local Toggle = Instance.new("Frame")
        Toggle.Name = config.Name or "Toggle"
        Toggle.Size = UDim2.new(1, -20, 0, 30)
        Toggle.BackgroundColor3 = config.BackgroundColor or Theme.Secondary
        Toggle.Parent = self.Container

        -- Cria o label do toggle
        local Label = Instance.new("TextLabel")
        Label.Name = "ToggleLabel"
        Label.Text = config.Text or "Toggle"
        Label.Font = Theme.Font
        Label.TextSize = config.TextSize or 16
        Label.TextColor3 = config.TextColor or Theme.TextColor
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Parent = Toggle

        -- Cria o botão do toggle
        local Button = Instance.new("TextButton")
        Button.Name = "ToggleButton"
        Button.Size = UDim2.new(0.3, -5, 1, 0)
        Button.Position = UDim2.new(0.7, 5, 0, 0)
        Button.Text = config.DefaultState and "On" or "Off"
        Button.BackgroundColor3 = Theme.Accent
        Button.TextColor3 = Theme.TextColor
        Button.Font = Theme.Font
        Button.TextSize = config.TextSize or 16
        Button.Parent = Toggle

        table.insert(self.Elements, Toggle)
        self:UpdateLayout()
        return Toggle
    end

    -- Outros componentes (Slider, Label, etc) podem ser implementados aqui

    function Window:Destroy()
        self.Gui:Destroy()
    end

    Window:AdaptForMobile()
    return Window
end

--------------------------------------------------
-- Sistema de Loading Screen
--------------------------------------------------
function UILibrary:CreateLoadingScreen(config)
    config = config or {}
    local LoadingGui = Instance.new("ScreenGui")
    LoadingGui.Name = "LoadingScreen"
    LoadingGui.ResetOnSpawn = false
    LoadingGui.IgnoreGuiInset = true
    LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    LoadingGui.Parent = game.CoreGui  -- Defina o pai adequado

    local Container = Instance.new("Frame")
    Container.Name = "LoadingContainer"
    Container.Size = UDim2.new(1, 0, 1, 0)
    Container.BackgroundColor3 = Theme.Primary
    Container.Parent = LoadingGui

    local ProgressBarBackground = Instance.new("Frame")
    ProgressBarBackground.Name = "ProgressBarBackground"
    ProgressBarBackground.Size = UDim2.new(0.8, 0, 0, 10)
    ProgressBarBackground.Position = UDim2.new(0.1, 0, 0.9, 0)
    ProgressBarBackground.BackgroundColor3 = Theme.Secondary
    ProgressBarBackground.BorderSizePixel = 0
    ProgressBarBackground.Parent = Container

    local ProgressBar = Instance.new("Frame")
    ProgressBar.Name = "ProgressBar"
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    ProgressBar.BackgroundColor3 = Theme.Accent
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = ProgressBarBackground

    local LoadingScreen = {
        UpdateProgress = function(progress)
            -- 'progress' deve ser um número entre 0 e 1
            ProgressBar:TweenSize(UDim2.new(progress, 0, 1, 0), "Out", "Quad", 0.5, true)
        end,
        Destroy = function()
            LoadingGui:Destroy()
        end
    }

    return LoadingScreen
end

--------------------------------------------------
-- Ajustes para Dispositivos Móveis
--------------------------------------------------
if UserInputService.TouchEnabled then
    Theme.TextSize = 18
    Theme.WindowPadding = 15
end

UILibrary.Notifications = Notifications

return UILibrary
