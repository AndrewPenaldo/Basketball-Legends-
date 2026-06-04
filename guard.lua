-- ====================================================================
-- AUTO GUARD MOBILE - VERSÃO PRO 2 STUDS (MOVIMENTO NATURAL E SEM LOCK)
-- ====================================================================

local screenGui = Instance.new("ScreenGui")
local mainButton = Instance.new("TextButton")
local uiCorner = Instance.new("UICorner")

screenGui.Name = "AutoGuardMobileNaturalPro"
screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Aparência do Botão Flutuante
mainButton.Size = UDim2.new(0, 140, 0, 45)
mainButton.Position = UDim2.new(0.85, 0, 0.15, 0)
mainButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainButton.TextColor3 = Color3.fromRGB(255, 100, 100)
mainButton.Text = "Auto Guard: OFF"
mainButton.Font = Enum.Font.SourceSansBold
mainButton.TextSize = 18
mainButton.Active = true
mainButton.Draggable = true
mainButton.Parent = screenGui

uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainButton

-- Sistema móvel para arrastar o botão
local dragging, dragInput, dragStart, startPos
mainButton.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
dragStart = input.Position
startPos = mainButton.Position
end
end)
mainButton.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
dragInput = input
end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
if input == dragInput and dragging then
local delta = input.Position - dragStart
mainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
end)
game:GetService("UserInputService").InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = false
end
end)

-- SISTEMA DE INTERCEPTAÇÃO FRONTAL SUAVE
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local runService = game:GetService("RunService")
local autoGuardLigado = false

-- CONFIGURAÇÃO RECALIBRADA (A SEU PEDIDO)
local DISTANCIA_NA_FRENTE = 2.7 -- Distância perfeita para marcar sem bugar e sem dar bandeira

local function obterInimigoMaisProximo()
local menorDistancia = math.huge
local alvoMaisProximo = nil

local meuChar = localPlayer.Character
if not meuChar or not meuChar:FindFirstChild("HumanoidRootPart") then return nil end
local minhaPos = meuChar.HumanoidRootPart.Position

for _, p in pairs(players:GetPlayers()) do
if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then

local mesmoTime = false
if localPlayer.Team and p.Team then
if localPlayer.Team == p.Team then mesmoTime = true end
end

if not mesmoTime then
local distancia = (p.Character.HumanoidRootPart.Position - minhaPos).Magnitude
if distancia < menorDistancia then
menorDistancia = distancia
alvoMaisProximo = p.Character
end
end
end
end
return alvoMaisProximo
end

-- Loop de Movimentação Legítima (60 FPS)
runService.RenderStepped:Connect(function()
if autoGuardLigado then
pcall(function()
local meuChar = localPlayer.Character
if not meuChar or not meuChar:FindFirstChild("Humanoid") or not meuChar:FindFirstChild("HumanoidRootPart") then return end

-- O SEGREDO DO VISUAL NATURAL: Destrava a rotação do corpo do boneco
-- Isso impede que ele fique encarando o cara de lado ou de costas igual um robô travado
meuChar.Humanoid.AutoRotate = true

local inimigo = obterInimigoMaisProximo()
if inimigo and inimigo:FindFirstChild("HumanoidRootPart") then
local minhaPos = meuChar.HumanoidRootPart.Position
local posicaoInimigo = inimigo.HumanoidRootPart.Position

-- Pega a direção para onde o oponente está olhando
local direcaoOlharInimigo = inimigo.HumanoidRootPart.CFrame.LookVector
local direcaoOlharPlana = Vector3.new(direcaoOlharInimigo.X, 0, direcaoOlharInimigo.Z).Unit

-- Ponto alvo a 2 studs na frente da linha de visão dele
local posicaoAlvoNaFrente = posicaoInimigo + (direcaoOlharPlana * DISTANCIA_NA_FRENTE)

local direcaoAteAlvo = (posicaoAlvoNaFrente - minhaPos)
local vetorAutoGuard = Vector3.new(direcaoAteAlvo.X, 0, direcaoAteAlvo.Z)
if vetorAutoGuard.Magnitude > 0 then vetorAutoGuard = vetorAutoGuard.Unit end

-- Pega a direção do seu analógico móvel
local vetorDoJoystick = meuChar.Humanoid.MoveDirection

-- Sistema híbrido livre calibrado para predicts suaves
if vetorDoJoystick.Magnitude > 0 then
local direcaoInimigoDireta = (posicaoInimigo - minhaPos).Unit
local produtoEscalar = vetorDoJoystick:Dot(direcaoInimigoDireta)
if produtoEscalar < 0.2 then
vetorAutoGuard = vetorAutoGuard * 0.35
end
end

-- Soma as forças e move o personagem de forma 100% legítima
local vetorFinal = (vetorAutoGuard + (vetorDoJoystick * 1.2))
if vetorFinal.Magnitude > 0 then vetorFinal = vetorFinal.Unit end

meuChar.Humanoid:Move(vetorFinal, false)
end
end)
end
end)

mainButton.MouseButton1Click:Connect(function()
autoGuardLigado = not autoGuardLigado
mainButton.Text = autoGuardLigado and "Auto Guard: ON" or "Auto Guard: OFF"
mainButton.TextColor3 = autoGuardLigado and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
mainButton.BackgroundColor3 = autoGuardLigado and Color3.fromRGB(20, 40, 20) or Color3.fromRGB(30, 30, 40)
end)


