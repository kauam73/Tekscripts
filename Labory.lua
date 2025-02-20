-- Biblioteca de Interface 5.0  
-- Sistema modular em português com componentes flexíveis  

local BibliotecaUI = {  
    Temas = {},  
    Janelas = {},  
    Componentes = {}  
}

--#region Núcleo Principal  
local ServicoTween = game:GetService("TweenService")  
local ServicoEntrada = game:GetService("UserInputService")  
local ServicoExecucao = game:GetService("RunService")  
local Jogadores = game:GetService("Players")  

function BibliotecaUI:Inicializar()  
    if self.Inicializada then return end  
    self.Inicializada = true  

    self:RegistrarTema("Padrao", {    
        Principal = Color3.fromRGB(28, 28, 28),    
        Secundario = Color3.fromRGB(40, 40, 40),    
        Destaque = Color3.fromRGB(0, 145, 255),    
        CorTexto = Color3.fromRGB(240, 240, 240),    
        Fonte = Enum.Font.GothamMedium,    
        RaioBorda = UDim.new(0, 6),    
        CorBorda = Color3.fromRGB(60, 60, 60),    
        Escala = 1,    
        Espacamento = 3,    
        AlturaElemento = 28,    
        BreakpointMobile = 600  
    })    

    self:AplicarTema("Padrao")    
    self:ConfigurarResponsividade()  
end  
--#endregion  

--#region Sistema de Temas  
function BibliotecaUI:RegistrarTema(nome, dadosTema)  
    self.Temas[nome] = setmetatable(dadosTema, {__index = self.Temas["Padrao"]})  
end  

function BibliotecaUI:AplicarTema(nomeTema)  
    self.TemaAtual = self.Temas[nomeTema] or self.Temas["Padrao"]  
    for _, janela in pairs(self.Janelas) do  
        janela:AtualizarTema(self.TemaAtual)  
    end  
end  
--#endregion  

--#region Sistema Responsivo  
function BibliotecaUI:ConfigurarResponsividade()  
    local function atualizar()  
        local viewport = workspace.CurrentCamera.ViewportSize  
        self.EhMobile = viewport.X <= self.TemaAtual.BreakpointMobile  
        self.TemaAtual.Escala = math.clamp(math.min(viewport.X/1920, viewport.Y/1080), 0.8, 1.2)  

        for _, janela in pairs(self.Janelas) do    
            janela:AtualizarLayout()    
        end    
    end  

    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(atualizar)    
    atualizar()  
end  
--#endregion  

--#region Classe Janela  
local Janela = {}  
Janela.__index = Janela  

function Janela.nova(titulo)  
    local self = setmetatable({}, Janela)  
    self.GUI = Instance.new("ScreenGui")  
    self.GUI.Parent = Jogadores.LocalPlayer:WaitForChild("PlayerGui")  

    self.Minimizado = false  -- Estado para minimizar/maximizar

    self:ConstruirEstrutura(titulo)    
    self:AdicionarControles()    
    BibliotecaUI.Janelas[self.GUI] = self    
    return self  
end  

function Janela:ConstruirEstrutura(titulo)  
    self.FramePrincipal = Instance.new("Frame")  
    self.FramePrincipal.Size = UDim2.new(0.3, 0, 0, 40)  
    self.FramePrincipal.Position = UDim2.new(0.35, 0, 0.3, 0)  
    self.FramePrincipal.BackgroundTransparency = 1  
    self.FramePrincipal.Parent = self.GUI  

    self.Conteudo = Instance.new("ScrollingFrame")    
    self.Conteudo.Size = UDim2.new(1, 0, 1, -40)    
    self.Conteudo.Position = UDim2.new(0, 0, 0, 40)    
    self.Conteudo.AutomaticCanvasSize = Enum.AutomaticSize.Y    
    self.Conteudo.ScrollBarThickness = 4    
    self.Conteudo.Parent = self.FramePrincipal  

    self.Layout = Instance.new("UIListLayout")    
    self.Layout.Padding = UDim.new(0, BibliotecaUI.TemaAtual.Espacamento)    
    self.Layout.SortOrder = Enum.SortOrder.LayoutOrder    
    self.Layout.Parent = self.Conteudo  

    self:CriarCabecalho(titulo)  
end  

function Janela:CriarCabecalho(titulo)  
    self.Cabecalho = Instance.new("Frame")  
    self.Cabecalho.Size = UDim2.new(1, 0, 0, 40)  
    self.Cabecalho.BackgroundColor3 = BibliotecaUI.TemaAtual.Principal  

    self.RotuloTitulo = Instance.new("TextLabel")    
    self.RotuloTitulo.Text = titulo    
    self.RotuloTitulo.Size = UDim2.new(1, -80, 1, 0)    
    self.RotuloTitulo.Position = UDim2.new(0, 10, 0, 0)    
    self.RotuloTitulo.Font = BibliotecaUI.TemaAtual.Fonte    
    self.RotuloTitulo.TextColor3 = BibliotecaUI.TemaAtual.CorTexto    
    self.RotuloTitulo.BackgroundTransparency = 1    
    self.RotuloTitulo.Parent = self.Cabecalho    

    self.Cabecalho.Parent = self.FramePrincipal  
end  

function Janela:AdicionarControles()  
    self.BotaoFechar = Instance.new("TextButton")  
    self.BotaoFechar.Text = "×"  
    self.BotaoFechar.Size = UDim2.new(0, 30, 0, 30)  
    self.BotaoFechar.Position = UDim2.new(1, -35, 0.5, -15)  
    self.BotaoFechar.Font = Enum.Font.GothamBold  
    self.BotaoFechar.TextColor3 = BibliotecaUI.TemaAtual.CorTexto  
    self.BotaoFechar.BackgroundColor3 = BibliotecaUI.TemaAtual.Secundario  
    self.BotaoFechar.AutoButtonColor = false  

    self.BotaoFechar.MouseButton1Click:Connect(function()    
        self:ToggleMinimizar()  
    end)    

    self.BotaoFechar.Parent = self.Cabecalho  
end  

function Janela:ToggleMinimizar()  
    self.Minimizado = not self.Minimizado  
    if self.Minimizado then  
        -- Minimiza: oculta o conteúdo e define o tamanho para o cabeçalho  
        ServicoTween:Create(self.FramePrincipal, TweenInfo.new(0.2), {Size = UDim2.new(self.FramePrincipal.Size.X.Scale, self.FramePrincipal.Size.X.Offset, 0, 40)}):Play()  
        self.Conteudo.Visible = false  
        self.BotaoFechar.Text = "▢"  -- símbolo para maximizar  
    else  
        -- Maximiza: mostra o conteúdo e atualiza o layout  
        self.Conteudo.Visible = true  
        self:AtualizarLayout()  
        self.BotaoFechar.Text = "×"  -- volta ao símbolo original  
    end  
end  

--#region Componentes  
function Janela:AdicionarBotao(config)  
    assert(config and type(config) == "table", "Configuração do botão inválida!")  
    assert(config.Funcao, "Função de callback necessária!")  

    local botao = Instance.new("TextButton")    
    botao.Text = config.Texto or "Botão"    
    botao.Size = UDim2.new(1, -10, 0, BibliotecaUI.TemaAtual.AlturaElemento)    
    botao.Font = BibliotecaUI.TemaAtual.Fonte    
    botao.TextColor3 = BibliotecaUI.TemaAtual.CorTexto    
    botao.BackgroundColor3 = BibliotecaUI.TemaAtual.Secundario    
    botao.AutoButtonColor = false    
    botao.LayoutOrder = #self.Conteudo:GetChildren()    
    botao.Parent = self.Conteudo    

    local canto = Instance.new("UICorner")    
    canto.CornerRadius = BibliotecaUI.TemaAtual.RaioBorda    
    canto.Parent = botao    

    botao.MouseEnter:Connect(function()    
        ServicoTween:Create(botao, TweenInfo.new(0.15), {    
            BackgroundColor3 = BibliotecaUI.TemaAtual.Destaque    
        }):Play()    
    end)    

    botao.MouseLeave:Connect(function()    
        ServicoTween:Create(botao, TweenInfo.new(0.15), {    
            BackgroundColor3 = BibliotecaUI.TemaAtual.Secundario    
        }):Play()    
    end)    

    botao.MouseButton1Click:Connect(config.Funcao)    

    return botao  
end  

function Janela:AdicionarSlider(config)  
    assert(config and type(config) == "table", "Configuração do slider inválida!")  
    assert(config.Min and config.Max, "Valores mínimo e máximo necessários!")  
    assert(config.Funcao, "Função de callback necessária!")  

    local container = Instance.new("Frame")    
    container.Size = UDim2.new(1, -10, 0, BibliotecaUI.TemaAtual.AlturaElemento)    
    container.BackgroundTransparency = 1    
    container.LayoutOrder = #self.Conteudo:GetChildren()    
    container.Parent = self.Conteudo    

    local trilha = Instance.new("Frame")    
    trilha.Size = UDim2.new(1, 0, 0, 4)    
    trilha.Position = UDim2.new(0, 0, 0.5, -2)    
    trilha.BackgroundColor3 = BibliotecaUI.TemaAtual.Secundario    
    trilha.Parent = container    

    local marcador = Instance.new("Frame")    
    marcador.Size = UDim2.new(0, 12, 0, 12)    
    marcador.AnchorPoint = Vector2.new(0.5, 0.5)    
    marcador.Position = UDim2.new(0, 0, 0.5, 0)    
    marcador.BackgroundColor3 = BibliotecaUI.TemaAtual.Destaque    
    marcador.Parent = trilha    

    local rotuloValor = Instance.new("TextLabel")    
    rotuloValor.Text = tostring(config.Min or 0)    
    rotuloValor.Size = UDim2.new(0, 50, 1, 0)    
    rotuloValor.Position = UDim2.new(1, 5, 0, 0)    
    rotuloValor.Font = BibliotecaUI.TemaAtual.Fonte    
    rotuloValor.TextColor3 = BibliotecaUI.TemaAtual.CorTexto    
    rotuloValor.BackgroundTransparency = 1    
    rotuloValor.Parent = container    

    Instance.new("UICorner", trilha).CornerRadius = BibliotecaUI.TemaAtual.RaioBorda    
    Instance.new("UICorner", marcador).CornerRadius = UDim.new(1, 0)    

    local min = config.Min    
    local max = config.Max    
    local valor = math.clamp(config.Valor or min, min, max)    

    local function atualizar(input)    
        local posX = (input.Position.X - trilha.AbsolutePosition.X) / trilha.AbsoluteSize.X    
        valor = math.floor(min + (posX * (max - min)))    
        marcador.Position = UDim2.new(posX, 0, 0.5, 0)    
        rotuloValor.Text = tostring(valor)    
        config.Funcao(valor)    
    end    

    trilha.InputBegan:Connect(function(input)    
        if input.UserInputType == Enum.UserInputType.MouseButton1 then    
            atualizar(input)    
        end    
    end)    

    return container  
end  

function Janela:AdicionarAlternador(config)  
    assert(config and type(config) == "table", "Configuração do alternador inválida!")  
    assert(config.Funcao, "Função de callback necessária!")  

    local alternador = Instance.new("TextButton")    
    alternador.Text = config.Texto or "Alternador"    
    alternador.Size = UDim2.new(1, -10, 0, BibliotecaUI.TemaAtual.AlturaElemento)    
    alternador.Font = BibliotecaUI.TemaAtual.Fonte    
    alternador.TextColor3 = BibliotecaUI.TemaAtual.CorTexto    
    alternador.BackgroundColor3 = BibliotecaUI.TemaAtual.Secundario    
    alternador.AutoButtonColor = false    
    alternador.LayoutOrder = #self.Conteudo:GetChildren()    
    alternador.Parent = self.Conteudo    

    local indicador = Instance.new("Frame")    
    indicador.Size = UDim2.new(0, 20, 0, 20)    
    indicador.Position = UDim2.new(1, -25, 0.5, -10)    
    indicador.BackgroundColor3 = BibliotecaUI.TemaAtual.Principal    
    indicador.Parent = alternador    

    local estado = config.Padrao or false    
    Instance.new("UICorner", alternador).CornerRadius = BibliotecaUI.TemaAtual.RaioBorda    
    Instance.new("UICorner", indicador).CornerRadius = UDim.new(1, 0)    

    local function alternar()    
        estado = not estado    
        ServicoTween:Create(indicador, TweenInfo.new(0.2), {    
            BackgroundColor3 = estado and BibliotecaUI.TemaAtual.Destaque or BibliotecaUI.TemaAtual.Principal    
        }):Play()    
        config.Funcao(estado)    
    end    

    alternador.MouseButton1Click:Connect(alternar)    
    return alternador  
end  

function Janela:AdicionarLista(config)  
    assert(config and type(config) == "table", "Configuração da lista inválida!")  
    assert(config.Opcoes, "Lista de opções necessária!")  
    assert(config.Funcao, "Função de callback necessária!")  

    local lista = Instance.new("TextButton")    
    lista.Text = config.Texto or "Selecione..."    
    lista.Size = UDim2.new(1, -10, 0, BibliotecaUI.TemaAtual.AlturaElemento)    
    lista.Font = BibliotecaUI.TemaAtual.Fonte    
    lista.TextColor3 = BibliotecaUI.TemaAtual.CorTexto    
    lista.BackgroundColor3 = BibliotecaUI.TemaAtual.Secundario    
    lista.AutoButtonColor = false    
    lista.LayoutOrder = #self.Conteudo:GetChildren()    
    lista.Parent = self.Conteudo    

    local painelOpcoes = Instance.new("Frame")    
    painelOpcoes.Size = UDim2.new(1, 0, 0, 0)    
    painelOpcoes.Position = UDim2.new(0, 0, 1, 5)    
    painelOpcoes.BackgroundColor3 = BibliotecaUI.TemaAtual.Secundario    
    painelOpcoes.Visible = false    
    painelOpcoes.Parent = lista    

    Instance.new("UICorner", lista).CornerRadius = BibliotecaUI.TemaAtual.RaioBorda    
    Instance.new("UICorner", painelOpcoes).CornerRadius = BibliotecaUI.TemaAtual.RaioBorda    

    local aberto = false    
    local alturaOpcao = BibliotecaUI.TemaAtual.AlturaElemento - 5    

    local function alternar()    
        aberto = not aberto    
        painelOpcoes.Visible = aberto    
        ServicoTween:Create(painelOpcoes, TweenInfo.new(0.2), {    
            Size = aberto and UDim2.new(1, 0, 0, #config.Opcoes * alturaOpcao) or UDim2.new(1, 0, 0, 0)    
        }):Play()    
    end    

    for i, opcao in pairs(config.Opcoes) do    
        local botaoOpcao = Instance.new("TextButton")    
        botaoOpcao.Text = opcao    
        botaoOpcao.Size = UDim2.new(1, -10, 0, alturaOpcao)    
        botaoOpcao.Position = UDim2.new(0, 5, 0, (i-1)*alturaOpcao)    
        botaoOpcao.Font = BibliotecaUI.TemaAtual.Fonte    
        botaoOpcao.TextColor3 = BibliotecaUI.TemaAtual.CorTexto    
        botaoOpcao.BackgroundColor3 = BibliotecaUI.TemaAtual.Principal    
        botaoOpcao.AutoButtonColor = false    
        botaoOpcao.Parent = painelOpcoes    

        botaoOpcao.MouseButton1Click:Connect(function()    
            lista.Text = opcao    
            alternar()    
            config.Funcao(opcao)    
        end)    
    end    

    lista.MouseButton1Click:Connect(alternar)    
    return lista  
end  
--#endregion  

function Janela:AtualizarLayout()  
    local tema = BibliotecaUI.TemaAtual  
    if self.Minimizado then  
        if BibliotecaUI.EhMobile then  
            self.FramePrincipal.Size = UDim2.new(1, -20, 0, 40)  
            self.FramePrincipal.Position = UDim2.new(0.5, 0, 0.5, 0)  
            self.FramePrincipal.AnchorPoint = Vector2.new(0.5, 0.5)  
        else  
            self.FramePrincipal.Size = UDim2.new(math.clamp(0.3 * tema.Escala, 0.25, 0.4), 0, 0, 40)  
        end  
    else  
        if BibliotecaUI.EhMobile then  
            self.FramePrincipal.Size = UDim2.new(1, -20, 0, 40 + self.Conteudo.AbsoluteContentSize.Y)  
            self.FramePrincipal.Position = UDim2.new(0.5, 0, 0.5, 0)  
            self.FramePrincipal.AnchorPoint = Vector2.new(0.5, 0.5)  
        else  
            self.FramePrincipal.Size = UDim2.new(math.clamp(0.3 * tema.Escala, 0.25, 0.4), 0, 0, self.Conteudo.AbsoluteContentSize.Y + 40)  
        end  
    end  
end  

function Janela:AtualizarTema(tema)  
    self.Cabecalho.BackgroundColor3 = tema.Principal  
    self.RotuloTitulo.TextColor3 = tema.CorTexto  
    self.Conteudo.BackgroundColor3 = tema.Secundario  
end  
--#endregion  

--#region API Pública  
function BibliotecaUI:CriarJanela(titulo)  
    self:Inicializar()  
    return Janela.nova(titulo)  
end  

function BibliotecaUI:DestruirTudo()  
    for _, janela in pairs(self.Janelas) do  
        janela.GUI:Destroy()  
    end  
    table.clear(self.Janelas)  
end  
--#endregion  

return BibliotecaUI
