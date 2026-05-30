-- ==============================================================================
-- ORIOLE SYSTEM FRAMEWORK (XENON UNIVERSAL EDITION)
-- ==============================================================================

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local OrioleLib = {}
OrioleLib.__index = OrioleLib

-- Global Environment Registration (Verhindert das "Nichts öffnet sich"-Problem)
if getgenv then
    getgenv().OrioleLib = OrioleLib
end

-- Ultra-Clean Dark Hex Theme
OrioleLib.Theme = {
    Main = {
        Background = Color3.fromRGB(15, 15, 15),
        Stroke = Color3.fromRGB(30, 30, 30),
        CornerRadius = UDim.new(0, 10),
        Font = Enum.Font.SourceSansBold,
        TextSize = 16,
    },
    TitleBar = { Height = 40, Text = Color3.fromRGB(255, 255, 255) },
    Sidebar = { Width = 140, Border = Color3.fromRGB(25, 25, 25) },
    Tabs = {
        Height = 35,
        Padding = UDim.new(0, 5),
        ActiveText = Color3.fromRGB(255, 255, 255),
        InactiveText = Color3.fromRGB(180, 180, 180),
        ActiveBackground = Color3.fromRGB(30, 30, 30),
        CornerRadius = UDim.new(0, 5),
        IconColor = Color3.fromRGB(220, 220, 220),
    },
    Content = { Padding = UDim.new(0, 15), ScrollBarThickness = 4, ScrollBarColor = Color3.fromRGB(80, 80, 80) },
    Elements = {
        DefaultBackground = Color3.fromRGB(20, 20, 20),
        Stroke = Color3.fromRGB(35, 35, 35),
        CornerRadius = UDim.new(0, 5),
        Height = 38,
        Text = Color3.fromRGB(230, 230, 230),
        InteractableHover = Color3.fromRGB(50, 50, 50),
        ToggleActive = Color3.fromRGB(0, 180, 255),
        SliderBar = Color3.fromRGB(0, 180, 255),
        SliderHandle = Color3.fromRGB(255, 255, 255),
    },
}

-- Safe Protected Instance Factory
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties) do instance[k] = v end
    return instance
end

local function ApplyCorner(parent, radius) return CreateInstance("UICorner", { CornerRadius = radius, Parent = parent }) end
local function ApplyStroke(parent, color, thickness) return CreateInstance("UIStroke", { Color = color, Thickness = thickness, Parent = parent }) end

local function AddHoverEffect(element, targetColor, baseColor)
    element.MouseEnter:Connect(function() TweenService:Create(element, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play() end)
    element.MouseLeave:Connect(function() TweenService:Create(element, TweenInfo.new(0.2), {BackgroundColor3 = baseColor}):Play() end)
end

-- High-Performance Drag System
local function MakeDraggable(ui, dragElement)
    local dragging, dragInput, dragStart, startPos
    dragElement.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ui.Position
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if connection then connection:Disconnect() end
                end
            end)
        end
    end)
    dragElement.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            ui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Init Core
function OrioleLib:Init(title)
    local library = setmetatable({}, OrioleLib)
    library.Tabs = {}
    library.CurrentTab = nil

    local TargetParent = RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui
    local oldUI = TargetParent:FindFirstChild("OrioleUI")
    if oldUI then oldUI:Destroy() end

    local ScreenGui = CreateInstance("ScreenGui", { Name = "OrioleUI", Parent = TargetParent, ResetOnSpawn = false, DisplayOrder = 9999 })
    library.ScreenGui = ScreenGui

    local MainFrame = CreateInstance("Frame", { Name = "MainWindow", Size = UDim2.new(0, 520, 0, 360), Position = UDim2.new(0.5, -260, 0.5, -180), BackgroundColor3 = OrioleLib.Theme.Main.Background, BorderSizePixel = 0, Parent = ScreenGui })
    ApplyCorner(MainFrame, OrioleLib.Theme.Main.CornerRadius)
    ApplyStroke(MainFrame, OrioleLib.Theme.Main.Stroke, 1)
    library.MainFrame = MainFrame

    local TitleBar = CreateInstance("Frame", { Name = "TitleBar", Size = UDim2.new(1, 0, 0, OrioleLib.Theme.TitleBar.Height), BackgroundTransparency = 1, Parent = MainFrame })
    MakeDraggable(MainFrame, TitleBar)

    CreateInstance("TextLabel", { Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 15, 0, 0), Text = title or "Oriole UI", TextColor3 = OrioleLib.Theme.TitleBar.Text, TextXAlignment = Enum.TextXAlignment.Left, Font = OrioleLib.Theme.Main.Font, TextSize = OrioleLib.Theme.Main.TextSize, BackgroundTransparency = 1, Parent = TitleBar })

    local CloseButton = CreateInstance("TextButton", { Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -20, 0.5, -10), Text = "✕", TextColor3 = Color3.fromRGB(200, 200, 200), Font = Enum.Font.SourceSansBold, TextSize = 14, BackgroundColor3 = Color3.fromRGB(40, 40, 40), Parent = TitleBar })
    ApplyCorner(CloseButton, UDim.new(0, 5))
    CloseButton.MouseButton1Click:Connect(function() library:Destroy() end)

    local Sidebar = CreateInstance("Frame", { Name = "Sidebar", Size = UDim2.new(0, OrioleLib.Theme.Sidebar.Width, 1, -OrioleLib.Theme.TitleBar.Height), Position = UDim2.new(0, 0, 0, OrioleLib.Theme.TitleBar.Height), BackgroundTransparency = 1, Parent = MainFrame })
    CreateInstance("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BackgroundColor3 = OrioleLib.Theme.Sidebar.Border, BorderSizePixel = 0, Parent = Sidebar })

    local SidebarContainer = CreateInstance("ScrollingFrame", { Size = UDim2.new(1, -10, 1, -40), Position = UDim2.new(0, 5, 0, 5), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, Parent = Sidebar })
    library.SidebarContainer = SidebarContainer
    CreateInstance("UIListLayout", { Padding = OrioleLib.Theme.Tabs.Padding, SortOrder = Enum.SortOrder.LayoutOrder, Parent = SidebarContainer })

    local ProfileFrame = CreateInstance("Frame", { Size = UDim2.new(1, -10, 0, 35), Position = UDim2.new(0, 5, 1, -40), BackgroundColor3 = OrioleLib.Theme.Sidebar.Border, Parent = Sidebar })
    ApplyCorner(ProfileFrame, UDim.new(0, 5))
    local ProfileImage = CreateInstance("ImageLabel", { Size = UDim2.new(0, 25, 0, 25), Position = UDim2.new(0, 5, 0, 5), BackgroundTransparency = 1, Image = "rbxassetid://6044737303", Parent = ProfileFrame })
    ApplyCorner(ProfileImage, UDim.new(1, 0))
    CreateInstance("TextLabel", { Size = UDim2.new(1, -35, 1, 0), Position = UDim2.new(0, 35, 0, 0), Text = Players.LocalPlayer.Name, TextColor3 = Color3.fromRGB(200, 200, 200), Font = Enum.Font.SourceSans, TextSize = 14, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = ProfileFrame })

    local ContentContainer = CreateInstance("Frame", { Name = "ContentContainer", Size = UDim2.new(1, -OrioleLib.Theme.Sidebar.Width - OrioleLib.Theme.Content.Padding.Offset, 1, -OrioleLib.Theme.TitleBar.Height - OrioleLib.Theme.Content.Padding.Offset), Position = UDim2.new(0, OrioleLib.Theme.Sidebar.Width + (OrioleLib.Theme.Content.Padding.Offset/2), 0, OrioleLib.Theme.TitleBar.Height + (OrioleLib.Theme.Content.Padding.Offset/2)), BackgroundTransparency = 1, Parent = MainFrame })
    library.ContentContainer = ContentContainer

    return library
end

-- Tab Management
function OrioleLib:AddTab(name)
    local tab = {Active = false}

    local TabButton = CreateInstance("TextButton", { Name = name .. "Tab", Size = UDim2.new(1, 0, 0, OrioleLib.Theme.Tabs.Height), BackgroundColor3 = OrioleLib.Theme.Tabs.ActiveBackground, BackgroundTransparency = 1, Text = "", Parent = self.SidebarContainer })
    ApplyCorner(TabButton, OrioleLib.Theme.Tabs.CornerRadius)
    CreateInstance("ImageLabel", { Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 8, 0.5, -8), BackgroundTransparency = 1, Image = "rbxassetid://6031094678", ImageColor3 = OrioleLib.Theme.Tabs.IconColor, Parent = TabButton })
    local TabLabel = CreateInstance("TextLabel", { Size = UDim2.new(1, -35, 1, 0), Position = UDim2.new(0, 32, 0, 0), Text = name, TextColor3 = OrioleLib.Theme.Tabs.InactiveText, Font = OrioleLib.Theme.Main.Font, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = TabButton })

    local TabContent = CreateInstance("ScrollingFrame", { Name = name .. "Content", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = OrioleLib.Theme.Content.ScrollBarThickness, ScrollBarImageColor3 = OrioleLib.Theme.Content.ScrollBarColor, Visible = false, Parent = self.ContentContainer })
    local TabListLayout = CreateInstance("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = TabContent })

    TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() TabContent.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y) end)

    function tab:Activate()
        TabButton.BackgroundTransparency = 0
        TabLabel.TextColor3 = OrioleLib.Theme.Tabs.ActiveText
        TabContent.Visible = true
        tab.Active = true
    end

    function tab:Deactivate()
        TabButton.BackgroundTransparency = 1
        TabLabel.TextColor3 = OrioleLib.Theme.Tabs.InactiveText
        TabContent.Visible = false
        tab.Active = false
    end

    TabButton.MouseButton1Click:Connect(function()
        if self.CurrentTab == tab then return end
        if self.CurrentTab then self.CurrentTab:Deactivate() end
        tab:Activate()
        self.CurrentTab = tab
    end)

    if not self.CurrentTab then
        tab:Activate()
        self.CurrentTab = tab
    end

    setmetatable(tab, {__index = function(_, key)
        return function(t, ...) return OrioleLib[key](self, tab, ...) end
    end})

    return tab
end

-- Component Engines
function OrioleLib:AddLabel(tabObj, text)
    local LabelFrame = CreateInstance("Frame", { Size = UDim2.new(1, 0, 0, OrioleLib.Theme.Elements.Height), BackgroundColor3 = OrioleLib.Theme.Elements.DefaultBackground, Parent = tabObj.TabContent })
    ApplyCorner(LabelFrame, OrioleLib.Theme.Elements.CornerRadius)
    ApplyStroke(LabelFrame, OrioleLib.Theme.Elements.Stroke, 1)
    CreateInstance("TextLabel", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), Text = text, TextColor3 = OrioleLib.Theme.Elements.Text, Font = OrioleLib.Theme.Main.Font, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = LabelFrame })
end

function OrioleLib:AddButton(tabObj, text, callback)
    local Button = CreateInstance("TextButton", { Size = UDim2.new(1, 0, 0, OrioleLib.Theme.Elements.Height), BackgroundColor3 = OrioleLib.Theme.Elements.DefaultBackground, Text = "", Parent = tabObj.TabContent })
    ApplyCorner(Button, OrioleLib.Theme.Elements.CornerRadius)
    ApplyStroke(Button, OrioleLib.Theme.Elements.Stroke, 1)
    AddHoverEffect(Button, OrioleLib.Theme.Elements.InteractableHover, OrioleLib.Theme.Elements.DefaultBackground)
    CreateInstance("TextLabel", { Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 10, 0, 0), Text = text, TextColor3 = OrioleLib.Theme.Elements.Text, Font = OrioleLib.Theme.Main.Font, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = Button })
    Button.MouseButton1Click:Connect(function() task.spawn(pcall, callback) end)
end

function OrioleLib:AddToggle(tabObj, text, defaultState, callback)
    local state = defaultState or false
    local ToggleFrame = CreateInstance("Frame", { Size = UDim2.new(1, 0, 0, OrioleLib.Theme.Elements.Height), BackgroundColor3 = OrioleLib.Theme.Elements.DefaultBackground, Parent = tabObj.TabContent })
    ApplyCorner(ToggleFrame, OrioleLib.Theme.Elements.CornerRadius)
    ApplyStroke(ToggleFrame, OrioleLib.Theme.Elements.Stroke, 1)
    local ActionButton = CreateInstance("TextButton", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = ToggleFrame })
    AddHoverEffect(ToggleFrame, OrioleLib.Theme.Elements.InteractableHover, OrioleLib.Theme.Elements.DefaultBackground)
    CreateInstance("TextLabel", { Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 10, 0, 0), Text = text, TextColor3 = OrioleLib.Theme.Elements.Text, Font = OrioleLib.Theme.Main.Font, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = ToggleFrame })
    local Outer = CreateInstance("Frame", { Size = UDim2.new(0, 36, 0, 18), Position = UDim2.new(1, -46, 0.5, -9), BackgroundColor3 = Color3.fromRGB(40, 40, 40), Parent = ToggleFrame })
    ApplyCorner(Outer, UDim.new(1, 0))
    local Handle = CreateInstance("Frame", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = OrioleLib.Theme.Elements.Text, Parent = Outer })
    ApplyCorner(Handle, UDim.new(1, 0))
    local function RenderState()
        TweenService:Create(Handle, TweenInfo.new(0.2), { Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = state and OrioleLib.Theme.Elements.ToggleActive or OrioleLib.Theme.Elements.Text }):Play()
        TweenService:Create(Outer, TweenInfo.new(0.2), { BackgroundColor3 = state and OrioleLib.Theme.Elements.ToggleActive or Color3.fromRGB(40, 40, 40) }):Play()
    end
    RenderState()
    ActionButton.MouseButton1Click:Connect(function() state = not state RenderState() task.spawn(pcall, callback, state) end)
end

function OrioleLib:AddSlider(tabObj, text, min, max, defaultState, callback)
    local val = math.clamp(defaultState or min, min, max)
    local dragging = false
    local SliderFrame = CreateInstance("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = OrioleLib.Theme.Elements.DefaultBackground, Parent = tabObj.TabContent })
    ApplyCorner(SliderFrame, OrioleLib.Theme.Elements.CornerRadius)
    ApplyStroke(SliderFrame, OrioleLib.Theme.Elements.Stroke, 1)
    local Label = CreateInstance("TextLabel", { Size = UDim2.new(1, -20, 0, 25), Position = UDim2.new(0, 10, 0, 3), Text = text, TextColor3 = OrioleLib.Theme.Elements.Text, Font = OrioleLib.Theme.Main.Font, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = SliderFrame })
    local ValLabel = CreateInstance("TextLabel", { Size = UDim2.new(0, 50, 0, 25), Position = UDim2.new(1, -60, 0, 3), Text = tostring(math.floor(val)), TextColor3 = OrioleLib.Theme.Elements.Text, Font = OrioleLib.Theme.Main.Font, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1, Parent = SliderFrame })
    local Track = CreateInstance("Frame", { Size = UDim2.new(1, -30, 0, 4), Position = UDim2.new(0, 15, 0, 34), BackgroundColor3 = Color3.fromRGB(40, 40, 40), Parent = SliderFrame })
    ApplyCorner(Track, UDim.new(1, 0))
    local Bar = CreateInstance("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = OrioleLib.Theme.Elements.SliderBar, Parent = Track })
    ApplyCorner(Bar, UDim.new(1, 0))
    local Handle = CreateInstance("TextButton", { Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, -6, 0.5, -6), BackgroundColor3 = OrioleLib.Theme.Elements.SliderHandle, Text = "", Parent = Track })
    ApplyCorner(Handle, UDim.new(1, 0))
    local function update(inputX)
        local pct = math.clamp((inputX - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        val = min + (pct * (max - min))
        ValLabel.Text = tostring(math.floor(val))
        Bar.Size = UDim2.new(pct, 0, 1, 0)
        Handle.Position = UDim2.new(pct, -6, 0.5, -6)
        task.spawn(pcall, callback, val)
    end
    Handle.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input.Position.X) end end)
    local initPct = (val - min) / (max - min)
    Bar.Size = UDim2.new(initPct, 0, 1, 0)
    Handle.Position = UDim2.new(initPct, -6, 0.5, -6)
end

function OrioleLib:Destroy() if self.ScreenGui then self.ScreenGui:Destroy() end end

return OrioleLib
