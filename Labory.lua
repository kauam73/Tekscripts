--[[
    UILibrary v2.0
    Biblioteca de UI Roblox com componentes modernos e organização modular
    Recursos principais:
    - Sistema de importação seguro
    - Tratamento de erros detalhado
    - Componentes responsivos
    - Suporte móvel nativo
    - Sistema de temas unificado
    - Documentação integrada
--]]

local UILibrary = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Verificação de ambiente seguro
if not RunService:IsClient() then
    error("A UILibrary deve ser utilizada no lado do cliente!")
end

-- Sistema de erros personalizado
local function throwError(errorType, message)
    local errorMessages = {
        import = "Erro na importação: "..message,
        component = "Erro no componente: "..message,
        layout = "Erro de layout: "..message,
        mobile = "Erro mobile: "..message
    }
    error(errorMessages[errorType] or message)
end

-- Sistema de temas avançado
local Theme = {
    Primary = Color3.fromRGB(30, 30, 30),
    Secondary = Color3.fromRGB(50, 50, 50),
    Accent = Color3.fromRGB(0, 120, 215),
    TextColor = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.Gotham,
    MobileBreakpoint = 600,
    TextSize = 14,
    CornerRadius = UDim.new(0, 8),
    StrokeColor = Color3.fromRGB(70, 70, 70)
}

-- Componentes base
local BaseComponents = {
    createFrame = function(name, size, parent)
        local frame = Instance.new("Frame")
        frame.Name = name
        frame.BackgroundColor3 = Theme.Primary
        frame.Size = size
        frame.BorderSizePixel = 0
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = Theme.CornerRadius
        corner.Parent = frame
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Theme.StrokeColor
        stroke.Thickness = 1
        stroke.Parent = frame
        
        if parent then frame.Parent = parent end
        return frame
    end,
    
    createText = function(name, text, parent)
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = name
        textLabel.Text = text
        textLabel.Font = Theme.Font
        textLabel.TextColor3 = Theme.TextColor
        textLabel.BackgroundTransparency = 1
        textLabel.TextSize = Theme.TextSize
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        if parent then textLabel.Parent = parent end
        return textLabel
    end
}

--------------------------------------------------
-- Sistema de Notificações Melhorado
--------------------------------------------------
local Notifications = {
    ActiveNotifications = {},
    MaxStack = 5,
    NotificationLife = 5
}

function Notifications:show(title, message, options)
    -- Validação de entrada
    if not title or not message then
        throwError("component", "Título e mensagem são obrigatórios para notificações!")
    end
    
    local notification = BaseComponents.createFrame("Notification", UDim2.new(0.9, 0, 0, 80))
    notification.Position = UDim2.new(0.5, 0, 1, 0)
    notification.AnchorPoint = Vector2.new(0.5, 1)
    notification.ZIndex = 100
    
    local titleLabel = BaseComponents.createText("Title", title, notification)
    titleLabel.TextSize = Theme.TextSize + 2
    titleLabel.TextColor3 = options and options.Color or Theme.Accent
    titleLabel.Size = UDim2.new(1, -20, 0.4, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    
    local messageLabel = BaseComponents.createText("Message", message, notification)
    messageLabel.Size = UDim2.new(1, -20, 0.6, 0)
    messageLabel.Position = UDim2.new(0, 10, 0.4, 0)
    messageLabel.TextWrapped = true
    
    notification.Parent = game.CoreGui
    table.insert(self.ActiveNotifications, notification)
    
    -- Animação de entrada
    TweenService:Create(notification, TweenInfo.new(0.3), {Position = UDim2.new(0.5, 0, 1, -10)}):Play()
    
    -- Gerenciamento de stack
    if #self.ActiveNotifications > self.MaxStack then
        self:remove(self.ActiveNotifications[1])
    end
    
    -- Remoção automática
    task.delay(self.NotificationLife, function()
        self:remove(notification)
    end)
end

function Notifications:remove(notification)
    TweenService:Create(notification, TweenInfo.new(0.3), {Position = UDim2.new(0.5, 0, 1, 0)}):Play()
    task.wait(0.3)
    notification:Destroy()
    table.remove(self.ActiveNotifications, table.find(self.ActiveNotifications, notification))
end

--------------------------------------------------
-- Sistema de Janelas Principal
--------------------------------------------------
function UILibrary:CreateWindow(title)
    local window = {
        Elements = {},
        MobileAdapted = false,
        ActiveComponents = {}
    }
    
    -- Configuração do GUI principal
    window.ScreenGui = Instance.new("ScreenGui")
    window.ScreenGui.Name = "UILibrary_Window"
    window.ScreenGui.ResetOnSpawn = false
    window.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    window.ScreenGui.Parent = game.CoreGui
    
    -- Container principal
    window.MainFrame = BaseComponents.createFrame("MainFrame", UDim2.new(0.3, 0, 0.4, 0), window.ScreenGui)
    window.MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
    
    -- Layout responsivo
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, Theme.WindowPadding)
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = window.MainFrame
    
    -- Título da janela
    if title then
        local titleBar = BaseComponents.createFrame("TitleBar", UDim2.new(1, 0, 0, 30), window.MainFrame)
        local titleText = BaseComponents.createText("TitleText", title, titleBar)
        titleText.Size = UDim2.new(1, -20, 1, 0)
        titleText.Position = UDim2.new(0, 10, 0, 0)
        titleText.TextXAlignment = Enum.TextXAlignment.Center
    end
    
    -- Sistema de adaptação mobile
    function window:adaptForMobile()
        if UserInputService.TouchEnabled and not self.MobileAdapted then
            self.MainFrame.Size = UDim2.new(1, -20, 1, -20)
            self.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
            Theme.TextSize = 18
            self.MobileAdapted = true
        end
    end
    
    -- Componentes da janela
    function window:addButton(config)
        -- Validação de configuração
        if not config or type(config) ~= "table" then
            throwError("component", "Configuração do botão inválida!")
        end
        
        local button = BaseComponents.createFrame("Button", UDim2.new(1, -20, 0, 40), self.MainFrame)
        button.BackgroundColor3 = Theme.Secondary
        
        local buttonText = BaseComponents.createText("ButtonText", config.Text or "Botão", button)
        buttonText.Size = UDim2.new(1, 0, 1, 0)
        buttonText.TextXAlignment = Enum.TextXAlignment.Center
        
        -- Interatividade
        local hoverTween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent})
        local clickTween = TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(0.95, -20, 0, 38)})
        
        button.MouseEnter:Connect(function()
            hoverTween:Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Secondary}):Play()
        end)
        
        button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                clickTween:Play()
                if config.Callback then config.Callback() end
            end
        end)
        
        button.InputEnded:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(1, -20, 0, 40)}):Play()
        end)
        
        table.insert(self.ActiveComponents, button)
        return button
    end
    
    function window:addSlider(config)
        -- Validação do slider
        assert(config.Min and config.Max, "Configuração do slider deve conter Min e Max!")
        assert(config.Callback and type(config.Callback) == "function", "Callback do slider inválido!")
        
        local slider = BaseComponents.createFrame("Slider", UDim2.new(1, -20, 0, 60), self.MainFrame)
        local track = BaseComponents.createFrame("Track", UDim2.new(1, -20, 0, 4), slider)
        track.Position = UDim2.new(0, 10, 0.5, 0)
        track.AnchorPoint = Vector2.new(0, 0.5)
        
        local thumb = BaseComponents.createFrame("Thumb", UDim2.new(0, 16, 0, 16), track)
        thumb.AnchorPoint = Vector2.new(0.5, 0.5)
        thumb.Position = UDim2.new(0, 0, 0.5, 0)
        thumb.BackgroundColor3 = Theme.Accent
        
        local valueLabel = BaseComponents.createText("Value", config.Min, slider)
        valueLabel.Size = UDim2.new(1, -20, 0.5, 0)
        valueLabel.Position = UDim2.new(0, 10, 0, 5)
        
        -- Lógica de interação
        local function updateValue(input)
            local relativeX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            local value = math.clamp(config.Min + (relativeX * (config.Max - config.Min)), config.Min, config.Max)
            thumb.Position = UDim2.new(relativeX, 0, 0.5, 0)
            valueLabel.Text = string.format("%.1f", value)
            config.Callback(value)
        end
        
        thumb.InputBegan:Connect(function(input)
            if input.UserInputType.Name:match("Mouse") or input.UserInputType.Name:match("Touch") then
                updateValue(input)
            end
        end)
        
        track.InputBegan:Connect(function(input)
            if input.UserInputType.Name:match("Mouse") or input.UserInputType.Name:match("Touch") then
                updateValue(input)
            end
        end)
        
        table.insert(self.ActiveComponents, slider)
        return slider
    end
    
    function window:destroy()
        self.ScreenGui:Destroy()
        table.clear(self)
    end
    
    window:adaptForMobile()
    return window
end

--------------------------------------------------
-- Sistema de Importação Segura
--------------------------------------------------
local function safeImport(module)
    if typeof(module) ~= "table" then
        throwError("import", "Formato de importação inválido! Use require(script.UILibrary)")
    end
    return setmetatable({}, {
        __index = function(_, key)
            if module[key] then
                return module[key]
            else
                throwError("import", "Componente '"..key.."' não encontrado!")
            end
        end
    })
end

return safeImport(UILibrary)
