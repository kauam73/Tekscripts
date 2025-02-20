-- UILibrary 4.0
-- Sistema completo com múltiplos componentes e layout otimizado

local UILibrary = {
    Themes = {},
    Windows = {},
    Components = {}
}

--#region Engine Core
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

function UILibrary:Initialize()
    if self.Initialized then return end
    self.Initialized = true
    
    self:RegisterTheme("Compact", {
        Primary = Color3.fromRGB(28, 28, 28),
        Secondary = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(0, 145, 255),
        TextColor = Color3.fromRGB(240, 240, 240),
        Font = Enum.Font.GothamMedium,
        CornerRadius = UDim.new(0, 6),
        StrokeColor = Color3.fromRGB(60, 60, 60),
        Scaling = 1,
        Spacing = 3,
        ElementHeight = 30,
        MobileBreakpoint = 600
    })
    
    self:ApplyTheme("Compact")
    self:SetupResponsiveSystem()
end

--#endregion

--#region Theme System
function UILibrary:RegisterTheme(name, themeData)
    self.Themes[name] = setmetatable(themeData, {__index = self.Themes["Compact"]})
end

function UILibrary:ApplyTheme(themeName)
    self.CurrentTheme = self.Themes[themeName] or self.Themes["Compact"]
    for _, window in pairs(self.Windows) do
        window:RefreshTheme(self.CurrentTheme)
    end
end
--#endregion

--#region Responsive System
function UILibrary:SetupResponsiveSystem()
    local function update()
        local viewport = workspace.CurrentCamera.ViewportSize
        self.IsMobile = viewport.X <= self.CurrentTheme.MobileBreakpoint
        self.CurrentTheme.Scaling = math.clamp(math.min(viewport.X/1920, viewport.Y/1080), 0.8, 1.2)
        
        for _, window in pairs(self.Windows) do
            window:UpdateLayout()
        end
    end

    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
    update()
end
--#endregion

--#region Window Class
local Window = {}
Window.__index = Window

function Window.new(title)
    local self = setmetatable({}, Window)
    self.GUI = Instance.new("ScreenGui")
    self.GUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    self:BuildStructure(title)
    self:AddControls()
    UILibrary.Windows[self.GUI] = self
    return self
end

function Window:BuildStructure(title)
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0.3, 0, 0, 40)
    self.MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
    self.MainFrame.BackgroundTransparency = 1
    self.MainFrame.Parent = self.GUI

    self.ContentHolder = Instance.new("ScrollingFrame")
    self.ContentHolder.Size = UDim2.new(1, 0, 1, -40)
    self.ContentHolder.Position = UDim2.new(0, 0, 0, 40)
    self.ContentHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.ContentHolder.ScrollBarThickness = 4
    self.ContentHolder.CanvasSize = UDim2.new()
    self.ContentHolder.Parent = self.MainFrame

    self.Layout = Instance.new("UIListLayout")
    self.Layout.Padding = UDim.new(0, UILibrary.CurrentTheme.Spacing)
    self.Layout.SortOrder = Enum.SortOrder.LayoutOrder
    self.Layout.Parent = self.ContentHolder

    self:CreateTitleBar(title)
end

function Window:CreateTitleBar(title)
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Size = UDim2.new(1, 0, 0, 40)
    self.TitleBar.BackgroundColor3 = UILibrary.CurrentTheme.Primary
    
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Text = title
    self.TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    self.TitleLabel.Font = UILibrary.CurrentTheme.Font
    self.TitleLabel.TextColor3 = UILibrary.CurrentTheme.TextColor
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Parent = self.TitleBar
    
    self.TitleBar.Parent = self.MainFrame
end

function Window:AddControls()
    -- Botão de Fechar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "×"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextColor3 = UILibrary.CurrentTheme.TextColor
    closeBtn.BackgroundColor3 = UILibrary.CurrentTheme.Secondary
    closeBtn.AutoButtonColor = false
    
    closeBtn.MouseButton1Click:Connect(function()
        self.GUI.Enabled = false
    end)
    
    closeBtn.Parent = self.TitleBar
end

--#region Componentes
function Window:AddButton(config)
    local button = Instance.new("TextButton")
    button.Text = config.Text or "Button"
    button.Size = UDim2.new(1, -10, 0, UILibrary.CurrentTheme.ElementHeight)
    button.Font = UILibrary.CurrentTheme.Font
    button.TextColor3 = UILibrary.CurrentTheme.TextColor
    button.BackgroundColor3 = UILibrary.CurrentTheme.Secondary
    button.AutoButtonColor = false
    button.LayoutOrder = #self.ContentHolder:GetChildren()
    button.Parent = self.ContentHolder

    -- Estilização
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UILibrary.CurrentTheme.CornerRadius
    corner.Parent = button

    -- Interatividade
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = UILibrary.CurrentTheme.Accent}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = UILibrary.CurrentTheme.Secondary}):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        if config.Callback then config.Callback() end
    end)
    
    return button
end

function Window:AddSlider(config)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, UILibrary.CurrentTheme.ElementHeight)
    container.BackgroundTransparency = 1
    container.LayoutOrder = #self.ContentHolder:GetChildren()
    container.Parent = self.ContentHolder

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 0.5, -2)
    track.BackgroundColor3 = UILibrary.CurrentTheme.Secondary
    track.Parent = container

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 12, 0, 12)
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(0, 0, 0.5, 0)
    thumb.BackgroundColor3 = UILibrary.CurrentTheme.Accent
    thumb.Parent = track

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = tostring(config.Min or 0)
    valueLabel.Size = UDim2.new(0, 50, 1, 0)
    valueLabel.Position = UDim2.new(1, 5, 0, 0)
    valueLabel.Font = UILibrary.CurrentTheme.Font
    valueLabel.TextColor3 = UILibrary.CurrentTheme.TextColor
    valueLabel.BackgroundTransparency = 1
    valueLabel.Parent = container

    UICorner.new(track, UILibrary.CurrentTheme.CornerRadius)
    UICorner.new(thumb, UDim.new(1, 0))

    -- Lógica do Slider
    local min = config.Min or 0
    local max = config.Max or 100
    local value = math.clamp(config.Value or min, min, max)

    local function update(input)
        local relativeX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
        value = math.floor(min + (relativeX * (max - min)))
        thumb.Position = UDim2.new(relativeX, 0, 0.5, 0)
        valueLabel.Text = tostring(value)
        if config.Callback then config.Callback(value) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            update(input)
        end
    end)

    return container
end

function Window:AddToggle(config)
    local toggle = Instance.new("TextButton")
    toggle.Text = config.Text or "Toggle"
    toggle.Size = UDim2.new(1, -10, 0, UILibrary.CurrentTheme.ElementHeight)
    toggle.Font = UILibrary.CurrentTheme.Font
    toggle.TextColor3 = UILibrary.CurrentTheme.TextColor
    toggle.BackgroundColor3 = UILibrary.CurrentTheme.Secondary
    toggle.AutoButtonColor = false
    toggle.LayoutOrder = #self.ContentHolder:GetChildren()
    toggle.Parent = self.ContentHolder

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 20, 0, 20)
    indicator.Position = UDim2.new(1, -25, 0.5, -10)
    indicator.BackgroundColor3 = UILibrary.CurrentTheme.Primary
    indicator.Parent = toggle

    local state = config.Default or false
    UICorner.new(toggle, UILibrary.CurrentTheme.CornerRadius)
    UICorner.new(indicator, UDim.new(1, 0))

    local function update()
        state = not state
        TweenService:Create(indicator, TweenInfo.new(0.2), {
            BackgroundColor3 = state and UILibrary.CurrentTheme.Accent or UILibrary.CurrentTheme.Primary
        }):Play()
        if config.Callback then config.Callback(state) end
    end

    toggle.MouseButton1Click:Connect(update)
    return toggle
end

function Window:AddDropdown(config)
    local dropdown = Instance.new("TextButton")
    dropdown.Text = config.Text or "Select..."
    dropdown.Size = UDim2.new(1, -10, 0, UILibrary.CurrentTheme.ElementHeight)
    dropdown.Font = UILibrary.CurrentTheme.Font
    dropdown.TextColor3 = UILibrary.CurrentTheme.TextColor
    dropdown.BackgroundColor3 = UILibrary.CurrentTheme.Secondary
    dropdown.AutoButtonColor = false
    dropdown.LayoutOrder = #self.ContentHolder:GetChildren()
    dropdown.Parent = self.ContentHolder

    local optionsFrame = Instance.new("Frame")
    optionsFrame.Size = UDim2.new(1, 0, 0, 0)
    optionsFrame.Position = UDim2.new(0, 0, 1, 5)
    optionsFrame.BackgroundColor3 = UILibrary.CurrentTheme.Secondary
    optionsFrame.Visible = false
    optionsFrame.Parent = dropdown

    UICorner.new(dropdown, UILibrary.CurrentTheme.CornerRadius)
    UICorner.new(optionsFrame, UILibrary.CurrentTheme.CornerRadius)

    local isOpen = false
    local optionHeight = UILibrary.CurrentTheme.ElementHeight - 5

    local function toggleMenu()
        isOpen = not isOpen
        optionsFrame.Visible = isOpen
        TweenService:Create(optionsFrame, TweenInfo.new(0.2), {
            Size = isOpen and UDim2.new(1, 0, 0, #config.Options * optionHeight) or UDim2.new(1, 0, 0, 0)
        }):Play()
    end

    for i, option in pairs(config.Options) do
        local optionBtn = Instance.new("TextButton")
        optionBtn.Text = option
        optionBtn.Size = UDim2.new(1, -10, 0, optionHeight)
        optionBtn.Position = UDim2.new(0, 5, 0, (i-1)*optionHeight)
        optionBtn.Font = UILibrary.CurrentTheme.Font
        optionBtn.TextColor3 = UILibrary.CurrentTheme.TextColor
        optionBtn.BackgroundColor3 = UILibrary.CurrentTheme.Primary
        optionBtn.AutoButtonColor = false
        optionBtn.Parent = optionsFrame

        optionBtn.MouseButton1Click:Connect(function()
            dropdown.Text = option
            toggleMenu()
            if config.Callback then config.Callback(option) end
        end)
    end

    dropdown.MouseButton1Click:Connect(toggleMenu)
    return dropdown
end
--#endregion

function Window:UpdateLayout()
    local theme = UILibrary.CurrentTheme
    if UILibrary.IsMobile then
        self.MainFrame.Size = UDim2.new(1, -20, 0, 40)
        self.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    else
        self.MainFrame.Size = UDim2.new(
            math.clamp(0.3 * theme.Scaling, 0.25, 0.4),
            0,
            0, self.ContentHolder.AbsoluteContentSize.Y + 40
        )
    end
end

function Window:RefreshTheme(theme)
    self.TitleBar.BackgroundColor3 = theme.Primary
    self.TitleLabel.TextColor3 = theme.TextColor
    self.ContentHolder.BackgroundColor3 = theme.Secondary
end
--#endregion

--#region Public API
function UILibrary:CreateWindow(title)
    self:Initialize()
    return Window.new(title)
end

function UILibrary:Destroy()
    for _, window in pairs(self.Windows) do
        window.GUI:Destroy()
    end
    table.clear(self.Windows)
end
--#endregion

return UILibrary
