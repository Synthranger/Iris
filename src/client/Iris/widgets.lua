--[[
    This file contains the classes for all widgets included in Iris. This file is large.
]]

local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local ICONS = {
    RIGHT_POINTING_TRIANGLE = "\u{25BA}",
    DOWN_POINTING_TRIANGLE = "\u{25BC}",
    MULTIPLICATION_SIGN = "\u{00D7}", -- best approximation for a close X which roblox supports, needs to be scaled about 2x
    BOTTOM_RIGHT_CORNER = "\u{25E2}", -- used in window resize icon in bottom right
    CHECK_MARK = "\u{2713}" -- curved shape, closest we can get to ImGui Checkmarks
}

local function extend(superClass, subClass)
    local newClass = table.clone(superClass)
    for i, v in subClass do
        newClass[i] = v
    end
    return newClass
end

local function UIPadding(Parent, PxPadding)
    local UIPaddingInstance = Instance.new("UIPadding")
    UIPaddingInstance.PaddingLeft = UDim.new(0, PxPadding.X)
    UIPaddingInstance.PaddingRight = UDim.new(0, PxPadding.X)
    UIPaddingInstance.PaddingTop = UDim.new(0, PxPadding.Y)
    UIPaddingInstance.PaddingBottom = UDim.new(0, PxPadding.Y)
    UIPaddingInstance.Parent = Parent
    return UIPaddingInstance
end

local function UIListLayout(Parent, FillDirection, Padding)
    local UIListLayoutInstance = Instance.new("UIListLayout")
    UIListLayoutInstance.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayoutInstance.Padding = Padding
    UIListLayoutInstance.FillDirection = FillDirection
    UIListLayoutInstance.Parent = Parent
    return UIListLayoutInstance
end

local function UIStroke(Parent, Thickness, Color, Transparency)
    local UIStrokeInstance = Instance.new("UIStroke")
    UIStrokeInstance.Thickness = Thickness
    UIStrokeInstance.Color = Color
    UIStrokeInstance.Transparency = Transparency
    UIStrokeInstance.Parent = Parent
    return UIStrokeInstance
end

local function UICorner(Parent, PxRounding)
    local UICornerInstance = Instance.new("UICorner")
    UICornerInstance.CornerRadius = UDim.new(PxRounding ~= nil and 0 or 1, PxRounding or 0)
    UICornerInstance.Parent = Parent
    return UICornerInstance
end

local function UISizeConstraint(Parent, MinSize, MaxSize)
    local UISizeConstraintInstance = Instance.new("UISizeConstraint")
    UISizeConstraintInstance.MinSize = MinSize
    UISizeConstraintInstance.MaxSize = MaxSize
    UISizeConstraintInstance.Parent = Parent
    return UISizeConstraintInstance
end

return function(Iris)

local function applyTextStyle(thisInstance)
    thisInstance.Font = Iris._config.TextFont
    thisInstance.TextSize = Iris._config.TextSize
    thisInstance.TextColor3 = Iris._config.TextColor
    thisInstance.TextTransparency = Iris._config.TextTransparency
    thisInstance.TextXAlignment = Enum.TextXAlignment.Left

    thisInstance.AutoLocalize = false
    thisInstance.RichText = false
end

local function applyInteractionHighlights(Button, Highlightee, Colors)
    local exitedButton = false
    Button.MouseEnter:Connect(function()
        Highlightee.BackgroundColor3 = Colors.ButtonHoveredColor
        Highlightee.BackgroundTransparency = Colors.ButtonHoveredTransparency

        exitedButton = false
    end)

    Button.MouseLeave:Connect(function()
        Highlightee.BackgroundColor3 = Colors.ButtonColor
        Highlightee.BackgroundTransparency = Colors.ButtonTransparency

        exitedButton = true
    end)

    Button.InputBegan:Connect(function(input)
        if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) then
            return
        end
        Highlightee.BackgroundColor3 = Colors.ButtonActiveColor
        Highlightee.BackgroundTransparency = Colors.ButtonActiveTransparency
    end)

    Button.InputEnded:Connect(function(input)
        if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) or exitedButton then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Highlightee.BackgroundColor3 = Colors.ButtonHoveredColor
            Highlightee.BackgroundTransparency = Colors.ButtonHoveredTransparency
        end
        if input.UserInputType == Enum.UserInputType.Gamepad1 then
            Highlightee.BackgroundColor3 = Colors.ButtonColor
            Highlightee.BackgroundTransparency = Colors.ButtonTransparency
        end
    end)
    
    Button.SelectionImageObject = Iris.SelectionImageObject
end

local function applyTextInteractionHighlights(Button, Highlightee, Colors)
    local exitedButton = false
    Button.MouseEnter:Connect(function()
        Highlightee.TextColor3 = Colors.ButtonHoveredColor
        Highlightee.TextTransparency = Colors.ButtonHoveredTransparency

        exitedButton = false
    end)

    Button.MouseLeave:Connect(function()
        Highlightee.TextColor3 = Colors.ButtonColor
        Highlightee.TextTransparency = Colors.ButtonTransparency

        exitedButton = true
    end)

    Button.InputBegan:Connect(function(input)
        if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) then
            return
        end
        Highlightee.TextColor3 = Colors.ButtonActiveColor
        Highlightee.TextTransparency = Colors.ButtonActiveTransparency
    end)

    Button.InputEnded:Connect(function(input)
        if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1) or exitedButton then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Highlightee.TextColor3 = Colors.ButtonHoveredColor
            Highlightee.TextTransparency = Colors.ButtonHoveredTransparency
        end
        if input.UserInputType == Enum.UserInputType.Gamepad1 then
            Highlightee.TextColor3 = Colors.ButtonColor
            Highlightee.TextTransparency = Colors.ButtonTransparency
        end
    end)
    
    Button.SelectionImageObject = Iris.SelectionImageObject
end

local function applyFrameStyle(thisInstance, forceNoPadding, doubleyNoPadding)
    -- padding, border, and rounding
    -- optimized to only use what instances are needed, based on style
    local FramePadding = Iris._config.FramePadding
    local FrameBorderTransparency = Iris._config.ButtonTransparency
    local FrameBorderSize = Iris._config.FrameBorderSize
    local FrameBorderColor = Iris._config.BorderColor
    local FrameRounding = Iris._config.FrameRounding
    
    if FrameBorderSize > 0 and FrameRounding > 0 then
        thisInstance.BorderSizePixel = 0

        local uiStroke = Instance.new("UIStroke")
        uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        uiStroke.LineJoinMode = Enum.LineJoinMode.Round
        uiStroke.Transparency = FrameBorderTransparency
        uiStroke.Thickness = FrameBorderSize
        uiStroke.Color = FrameBorderColor

        UICorner(thisInstance, FrameRounding)
        uiStroke.Parent = thisInstance

        if not forceNoPadding then
            UIPadding(thisInstance, Iris._config.FramePadding)
        end
    elseif FrameBorderSize < 1 and FrameRounding > 0 then
        thisInstance.BorderSizePixel = 0

        UICorner(thisInstance, FrameRounding)
        if not forceNoPadding then
            UIPadding(thisInstance, Iris._config.FramePadding)
        end
    elseif FrameRounding < 1 then
        thisInstance.BorderSizePixel = FrameBorderSize
        thisInstance.BorderColor3 = FrameBorderColor
        thisInstance.BorderMode = Enum.BorderMode.Inset

        if not forceNoPadding then
            UIPadding(thisInstance, FramePadding - Vector2.new(FrameBorderSize, FrameBorderSize))
        elseif not doubleyNoPadding then
            UIPadding(thisInstance, -Vector2.new(FrameBorderSize, FrameBorderSize))
        end
    end
end

local function hoverEvent(pathToHovered)
    return {
        ["Init"] = function(thisWidget)
            local hoveredGuiObject = pathToHovered(thisWidget)
            hoveredGuiObject.MouseEnter:Connect(function()
                thisWidget.isHoveredEvent = true
            end)
            hoveredGuiObject.MouseLeave:Connect(function()
                thisWidget.isHoveredEvent = false
            end)
            thisWidget.isHoveredEvent = false
        end,
        ["Get"] = function(thisWidget)
            return thisWidget.isHoveredEvent
        end
    }
end

local function discardState(thisWidget)
    for _, state in thisWidget.state do
        state.ConnectedWidgets[thisWidget.ID] = nil
    end
end

do -- Root
    local NumNonWindowChildren = 0
    Iris.WidgetConstructor("Root", {
        hasState = false,
        hasChildren = true,
        Args = {

        },
        Events = {
        
        },
        Generate = function(thisWidget)
            local Root = Instance.new("Folder")
            Root.Name = "Iris_Root"

            local PseudoWindowScreenGui
            if Iris._config.UseScreenGUIs then
                PseudoWindowScreenGui = Instance.new("ScreenGui")
                PseudoWindowScreenGui.ResetOnSpawn = false
                PseudoWindowScreenGui.DisplayOrder = Iris._config.DisplayOrderOffset
            else
                PseudoWindowScreenGui = Instance.new("Folder")
            end
            PseudoWindowScreenGui.Name = "PseudoWindowScreenGui"
            PseudoWindowScreenGui.Parent = Root

            local PopupScreenGui
            if Iris._config.UseScreenGUIs then
                PopupScreenGui = Instance.new("ScreenGui")
                PopupScreenGui.ResetOnSpawn = false
                PopupScreenGui.DisplayOrder = Iris._config.DisplayOrderOffset + 1024 -- room for 1024 regular windows before overlap

                local TooltipContainer = Instance.new("Frame")
                TooltipContainer.Name = "TooltipContainer"
                TooltipContainer.AutomaticSize = Enum.AutomaticSize.XY
                TooltipContainer.Size = UDim2.fromOffset(0, 0)
                TooltipContainer.BackgroundTransparency = 1
                TooltipContainer.BorderSizePixel = 0

                UIListLayout(TooltipContainer, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.FrameBorderSize))

                TooltipContainer.Parent = PopupScreenGui
            else
                PopupScreenGui = Instance.new("Folder")
            end
            PopupScreenGui.Name = "PopupScreenGui"
            PopupScreenGui.Parent = Root
            
            local PseudoWindow = Instance.new("Frame")
            PseudoWindow.Name = "PseudoWindow"
            PseudoWindow.Size = UDim2.new(0, 0, 0, 0)
            PseudoWindow.Position = UDim2.fromOffset(0, 22)
            PseudoWindow.BorderSizePixel = Iris._config.WindowBorderSize
            PseudoWindow.BorderColor3 = Iris._config.BorderColor
            PseudoWindow.BackgroundTransparency = Iris._config.WindowBgTransparency
            PseudoWindow.BackgroundColor3 = Iris._config.WindowBgColor
            PseudoWindow.AutomaticSize = Enum.AutomaticSize.XY

            PseudoWindow.Selectable = false
            PseudoWindow.SelectionGroup = true
            PseudoWindow.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
            PseudoWindow.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
            PseudoWindow.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
            PseudoWindow.SelectionBehaviorRight = Enum.SelectionBehavior.Stop

            PseudoWindow.Visible = false
            UIPadding(PseudoWindow, Iris._config.WindowPadding)

            UIListLayout(PseudoWindow, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))

            PseudoWindow.Parent = PseudoWindowScreenGui
            
            return Root
        end,
        Update = function(thisWidget)
            if NumNonWindowChildren > 0 then
                thisWidget.Instance.PseudoWindowScreenGui.PseudoWindow.Visible = true
            end
        end,
        Discard = function(thisWidget)
            NumNonWindowChildren = 0
            thisWidget.Instance:Destroy()
        end,
        ChildAdded = function(thisWidget, childWidget)
            if childWidget.type == "Window" then
                return thisWidget.Instance
            elseif childWidget.type == "Tooltip" then
                return thisWidget.Instance.PopupScreenGui.TooltipContainer
            else
                NumNonWindowChildren += 1
                thisWidget.Instance.PseudoWindowScreenGui.PseudoWindow.Visible = true

                return thisWidget.Instance.PseudoWindowScreenGui.PseudoWindow
            end
        end,
        ChildDiscarded = function(thisWidget, childWidget)
            if childWidget.type ~= "Window" then
                NumNonWindowChildren -= 1
                if NumNonWindowChildren == 0 then
                    thisWidget.Instance.PseudoWindowScreenGui.PseudoWindow.Visible = false
                end
            end
        end
    })
end

local abstractText = {
    hasState = false,
    hasChildren = false,
    Args = {
        ["Text"] = 1
    },
    Events = {
        ["hovered"] = hoverEvent(function(thisWidget)
            return thisWidget.Instance
        end)
    },
    Generate = function(thisWidget)
        local Text = Instance.new("TextLabel")
        Text.Size = UDim2.fromOffset(0, 0)
        Text.BackgroundTransparency = 1
        Text.BorderSizePixel = 0
        Text.ZIndex = thisWidget.ZIndex
        Text.LayoutOrder = thisWidget.ZIndex
        Text.AutomaticSize = Enum.AutomaticSize.XY

        applyTextStyle(Text)
        UIPadding(Text, Vector2.new(0, 2))

        return Text
    end,
    Update = function(thisWidget)
        local Text = thisWidget.Instance
        if thisWidget.arguments.Text == nil then
            error("Iris.Text Text Argument is required", 5)
        end
        Text.Text = thisWidget.arguments.Text
    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
    end
}

Iris.WidgetConstructor("Text", extend(abstractText, {
    Generate = function(thisWidget)
        local Text = abstractText.Generate(thisWidget)
        Text.Name = "Iris_Text"

        return Text
    end
}))

Iris.WidgetConstructor("TextColored", extend(abstractText, {
    Args = {
        ["Text"] = 1,
        ["Color"] = 2
    },
    Generate = function(thisWidget)
        local Text = abstractText.Generate(thisWidget)
        Text.Name = "Iris_TextColored"

        return Text
    end,
    Update = function(thisWidget)
        local Text = thisWidget.Instance
        if thisWidget.arguments.Text == nil then
            error("Iris.Text Text Argument is required", 5)
        end
        Text.Text = thisWidget.arguments.Text
        if thisWidget.arguments.Color == nil then
            error("Iris.TextColored Color argument is required", 5)
        end 
        Text.TextColor3 = thisWidget.arguments.Color
    end
}))

Iris.WidgetConstructor("TextWrapped", extend(abstractText, {
    Generate = function(thisWidget)
        local TextWrapped = abstractText.Generate(thisWidget)
        TextWrapped.Name = "Iris_TextWrapped"
        TextWrapped.TextWrapped = true

        return TextWrapped
    end
}))

local abstractButton = {
    hasState = false,
    hasChildren = false,
    Args = {
        ["Text"] = 1
    },
    Events = {
        ["clicked"] = {
            ["Init"] = function(thisWidget)
                thisWidget.lastClickTick = -1
                thisWidget.Instance.MouseButton1Click:Connect(function()
                    thisWidget.lastClickTick = Iris._cycleTick + 1
                end)
            end,
            ["Get"] = function(thisWidget)
                return  thisWidget.lastClickTick == Iris._cycleTick
            end
        },
        ["hovered"] = hoverEvent(function(thisWidget)
            return thisWidget.Instance
        end)
    },
    Generate = function(thisWidget)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.fromOffset(0, 0)
        Button.BackgroundColor3 = Iris._config.ButtonColor
        Button.BackgroundTransparency = Iris._config.ButtonTransparency
        Button.AutoButtonColor = false
    
        applyTextStyle(Button)
        Button.AutomaticSize = Enum.AutomaticSize.XY
    
        applyFrameStyle(Button)
    
        applyInteractionHighlights(Button, Button, {
            ButtonColor = Iris._config.ButtonColor,
            ButtonTransparency = Iris._config.ButtonTransparency,
            ButtonHoveredColor = Iris._config.ButtonHoveredColor,
            ButtonHoveredTransparency = Iris._config.ButtonHoveredTransparency,
            ButtonActiveColor = Iris._config.ButtonActiveColor,
            ButtonActiveTransparency = Iris._config.ButtonActiveTransparency,
        })

        Button.ZIndex = thisWidget.ZIndex
        Button.LayoutOrder = thisWidget.ZIndex

        return Button
    end,
    Update = function(thisWidget)
        local Button = thisWidget.Instance
        Button.Text = thisWidget.arguments.Text or "Button"
    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
    end
}

Iris.WidgetConstructor("Button", extend(abstractButton, {
    Generate = function(thisWidget)
        local Button = abstractButton.Generate(thisWidget)
        Button.Name = "Iris_Button"

        return Button
    end
}))

Iris.WidgetConstructor("SmallButton", extend(abstractButton, {
    Generate = function(thisWidget)
        local SmallButton = abstractButton.Generate(thisWidget)
        SmallButton.Name = "Iris_SmallButton"

        local uiPadding = SmallButton.UIPadding
        uiPadding.PaddingLeft = UDim.new(0, 2)
        uiPadding.PaddingRight = UDim.new(0, 2)
        uiPadding.PaddingTop = UDim.new(0, 0)
        uiPadding.PaddingBottom = UDim.new(0, 0)

        return SmallButton
    end
}))

Iris.WidgetConstructor("Separator", {
    hasState = false,
    hasChildren = false,
    Args = {

    },
    Events = {
        
    },
    Generate = function(thisWidget)
        local Separator = Instance.new("Frame")
        Separator.Name = "Iris_Separator"
        Separator.BorderSizePixel = 0
        if thisWidget.parentWidget.type == "SameLine" then
            Separator.Size = UDim2.new(0, 1, 1, 0)
        else
            Separator.Size = UDim2.new(1, 0, 0, 1)
        end
        Separator.ZIndex = thisWidget.ZIndex
        Separator.LayoutOrder = thisWidget.ZIndex

        Separator.BackgroundColor3 = Iris._config.SeparatorColor
        Separator.BackgroundTransparency = Iris._config.SeparatorTransparency

        UIListLayout(Separator, Enum.FillDirection.Vertical, UDim.new(0,0))
        -- this is to prevent a bug of AutomaticLayout edge case when its parent has automaticLayout enabled

        return Separator
    end,
    Update = function(thisWidget)

    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
    end
})

Iris.WidgetConstructor("Indent", {
    hasState = false,
    hasChildren = true,
    Args = {
        ["Width"] = 1,
    },
    Events = {
        
    },
    Generate = function(thisWidget)
        local Indent = Instance.new("Frame")
        Indent.Name = "Iris_Indent"
        Indent.BackgroundTransparency = 1
        Indent.BorderSizePixel = 0
        Indent.ZIndex = thisWidget.ZIndex
        Indent.LayoutOrder = thisWidget.ZIndex
        Indent.Size = UDim2.fromScale(1, 0)
        Indent.AutomaticSize = Enum.AutomaticSize.Y

        UIListLayout(Indent, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))
        UIPadding(Indent, Vector2.new(0, 0))

        return Indent
    end,
    Update = function(thisWidget)
        local indentWidth
        if thisWidget.arguments.Width then
            indentWidth = thisWidget.arguments.Width
        else
            indentWidth = Iris._config.IndentSpacing
        end
        thisWidget.Instance.UIPadding.PaddingLeft = UDim.new(0, indentWidth)
    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
    end,
    ChildAdded = function(thisWidget)
        return thisWidget.Instance
    end
})

Iris.WidgetConstructor("SameLine", {
    hasState = false,
    hasChildren = true,
    Args = {
        ["Width"] = 1,
        ["VerticalAlignment"] = 2
    },
    Events = {
        
    },
    Generate = function(thisWidget)
        local SameLine = Instance.new("Frame")
        SameLine.Name = "Iris_SameLine"
        SameLine.BackgroundTransparency = 1
        SameLine.BorderSizePixel = 0
        SameLine.ZIndex = thisWidget.ZIndex
        SameLine.LayoutOrder = thisWidget.ZIndex
        SameLine.Size = UDim2.fromScale(1, 0)
        SameLine.AutomaticSize = Enum.AutomaticSize.Y

        UIListLayout(SameLine, Enum.FillDirection.Horizontal, UDim.new(0, 0))

        return SameLine
    end,
    Update = function(thisWidget)
        local itemWidth
        local uiListLayout = thisWidget.Instance.UIListLayout
        if thisWidget.arguments.Width then
            itemWidth = thisWidget.arguments.Width
        else
            itemWidth = Iris._config.ItemSpacing.X
        end
        uiListLayout.Padding = UDim.new(0, itemWidth)
        if thisWidget.arguments.VerticalAlignment then
            uiListLayout.VerticalAlignment = thisWidget.arguments.VerticalAlignment
        else
            uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        end
    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
    end,
    ChildAdded = function(thisWidget)
        return thisWidget.Instance
    end
})

Iris.WidgetConstructor("Group", {
    hasState = false,
    hasChildren = true,
    Args = {

    },
    Events = {
        
    },
    Generate = function(thisWidget)
        local Group = Instance.new("Frame")
        Group.Name = "Iris_Group"
        Group.Size = UDim2.fromOffset(0, 0)
        Group.BackgroundTransparency = 1
        Group.BorderSizePixel = 0
        Group.ZIndex = thisWidget.ZIndex
        Group.LayoutOrder = thisWidget.ZIndex
        Group.AutomaticSize = Enum.AutomaticSize.XY
		Group.ClipsDescendants = true

        local uiListLayout = UIListLayout(Group, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.X))

        return Group
    end,
    Update = function(thisWidget)

    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
    end,
    ChildAdded = function(thisWidget)
        return thisWidget.Instance
    end
})

Iris.WidgetConstructor("Checkbox", {
    hasState = true,
    hasChildren = false,
    Args = {
        ["Text"] = 1
    },
    Events = {
        ["checked"] = {
            ["Init"] = function(thisWidget)

            end,
            ["Get"] = function(thisWidget)
                return thisWidget.lastCheckedTick == Iris._cycleTick
            end
        },
        ["unchecked"] = {
            ["Init"] = function(thisWidget)

            end,
            ["Get"] = function(thisWidget)
                return thisWidget.lastUncheckedTick == Iris._cycleTick
            end
        },
        ["hovered"] = hoverEvent(function(thisWidget)
            return thisWidget.Instance
        end)
    },
    Generate = function(thisWidget)
        local Checkbox = Instance.new("TextButton")
        Checkbox.Name = "Iris_Checkbox"
        Checkbox.BackgroundTransparency = 1
        Checkbox.BorderSizePixel = 0
        Checkbox.Size = UDim2.fromOffset(0, 0)
        Checkbox.Text = ""
        Checkbox.AutomaticSize = Enum.AutomaticSize.XY
        Checkbox.ZIndex = thisWidget.ZIndex
        Checkbox.AutoButtonColor = false
        Checkbox.LayoutOrder = thisWidget.ZIndex

        local CheckboxBox = Instance.new("TextLabel")
        CheckboxBox.Name = "CheckboxBox"
        CheckboxBox.AutomaticSize = Enum.AutomaticSize.None
        local checkboxSize = Iris._config.TextSize + 2 * Iris._config.FramePadding.Y
        CheckboxBox.Size = UDim2.fromOffset(checkboxSize, checkboxSize)
        CheckboxBox.TextSize = checkboxSize
        CheckboxBox.LineHeight = 1.1
        CheckboxBox.ZIndex = thisWidget.ZIndex + 1
        CheckboxBox.LayoutOrder = thisWidget.ZIndex + 1
        CheckboxBox.Parent = Checkbox
        CheckboxBox.TextColor3 = Iris._config.CheckMarkColor
        CheckboxBox.TextTransparency = Iris._config.CheckMarkTransparency
        CheckboxBox.BackgroundColor3 = Iris._config.FrameBgColor
        CheckboxBox.BackgroundTransparency = Iris._config.FrameBgTransparency
        applyFrameStyle(CheckboxBox, true)

        applyInteractionHighlights(Checkbox, CheckboxBox, {
            ButtonColor = Iris._config.FrameBgColor,
            ButtonTransparency = Iris._config.FrameBgTransparency,
            ButtonHoveredColor = Iris._config.FrameBgHoveredColor,
            ButtonHoveredTransparency = Iris._config.FrameBgHoveredTransparency,
            ButtonActiveColor = Iris._config.FrameBgActiveColor,
            ButtonActiveTransparency = Iris._config.FrameBgActiveTransparency,
        })

        Checkbox.MouseButton1Click:Connect(function()
            local wasChecked = thisWidget.state.isChecked.value
            thisWidget.state.isChecked:set(not wasChecked)
        end)

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Name = "TextLabel"
        applyTextStyle(TextLabel)
        TextLabel.Position = UDim2.new(0,checkboxSize + Iris._config.ItemInnerSpacing.X, 0.5, 0)
        TextLabel.ZIndex = thisWidget.ZIndex + 1
        TextLabel.LayoutOrder = thisWidget.ZIndex + 1
        TextLabel.AutomaticSize = Enum.AutomaticSize.XY
        TextLabel.AnchorPoint = Vector2.new(0, 0.5)
        TextLabel.BackgroundTransparency = 1
        TextLabel.BorderSizePixel = 0
        TextLabel.Parent = Checkbox

        return Checkbox
    end,
    Update = function(thisWidget)
        thisWidget.Instance.TextLabel.Text = thisWidget.arguments.Text or "Checkbox"
    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
        discardState(thisWidget)
    end,
    GenerateState = function(thisWidget)
        if thisWidget.state.isChecked == nil then
            thisWidget.state.isChecked = Iris._widgetState(thisWidget, "checked", false)
        end
    end,
    UpdateState = function(thisWidget)
        local Checkbox = thisWidget.Instance.CheckboxBox
        if thisWidget.state.isChecked.value then
            Checkbox.Text = ICONS.CHECK_MARK
            thisWidget.lastCheckedTick = Iris._cycleTick + 1
        else
            Checkbox.Text = ""
            thisWidget.lastUncheckedTick = Iris._cycleTick + 1
        end
    end
})

Iris.WidgetConstructor("RadioButton", {
	hasState = true,
	hasChildren = false,
	Args = {
		["Text"] = 1,
		["Value"] = 2
	},
	Events = {
		["activated"] = {
			["Init"] = function(thisWidget)
				
			end,
			["Get"] = function(thisWidget)
				return thisWidget.lastActiveTick == Iris._cycleTick
			end
		},
		["deactivated"] = {
			["Init"] = function(thisWidget)
				
			end,
			["Get"] = function(thisWidget)
				return thisWidget.lastDeactiveTick == Iris._cycleTick
			end
		},
		["hovered"] = hoverEvent(function(thisWidget)
			return thisWidget.Instance
		end)
	},
	Generate = function(thisWidget)
		local RadioButton = Instance.new("TextButton")
        RadioButton.Name = "Iris_RadioButton"
        RadioButton.BackgroundTransparency = 1
        RadioButton.BorderSizePixel = 0
        RadioButton.Size = UDim2.fromOffset(0, 0)
        RadioButton.Text = ""
        RadioButton.AutomaticSize = Enum.AutomaticSize.XY
        RadioButton.ZIndex = thisWidget.ZIndex
        RadioButton.AutoButtonColor = false
        RadioButton.LayoutOrder = thisWidget.ZIndex

		local buttonSize = Iris._config.TextSize + 2 * Iris._config.FramePadding.Y
		local Button = Instance.new("Frame")
        Button.Name = "Button"
        Button.Size = UDim2.fromOffset(buttonSize, buttonSize)
        Button.ZIndex = thisWidget.ZIndex + 1
        Button.LayoutOrder = thisWidget.ZIndex + 1
        Button.Parent = RadioButton
        Button.BackgroundColor3 = Iris._config.FrameBgColor
        Button.BackgroundTransparency = Iris._config.FrameBgTransparency

		UICorner(Button)

		local Circle = Instance.new("Frame")
		Circle.Name = "Circle"
		Circle.Position = UDim2.fromOffset(Iris._config.FramePadding.Y, Iris._config.FramePadding.Y)
        Circle.Size = UDim2.fromOffset(Iris._config.TextSize, Iris._config.TextSize)
        Circle.ZIndex = thisWidget.ZIndex + 1
        Circle.LayoutOrder = thisWidget.ZIndex + 1
        Circle.Parent = Button
        Circle.BackgroundColor3 = Iris._config.CheckMarkColor
        Circle.BackgroundTransparency = Iris._config.CheckMarkTransparency
		UICorner(Circle)

        applyInteractionHighlights(RadioButton, Button, {
            ButtonColor = Iris._config.FrameBgColor,
            ButtonTransparency = Iris._config.FrameBgTransparency,
            ButtonHoveredColor = Iris._config.FrameBgHoveredColor,
            ButtonHoveredTransparency = Iris._config.FrameBgHoveredTransparency,
            ButtonActiveColor = Iris._config.FrameBgActiveColor,
            ButtonActiveTransparency = Iris._config.FrameBgActiveTransparency,
        })

        RadioButton.MouseButton1Click:Connect(function()
            thisWidget.state.value:set(thisWidget.arguments.Value)
        end)

		local TextLabel = Instance.new("TextLabel")
		TextLabel.Name = "TextLabel"
        applyTextStyle(TextLabel)
        TextLabel.Position = UDim2.new(0,buttonSize + Iris._config.ItemInnerSpacing.X, 0.5, 0)
        TextLabel.ZIndex = thisWidget.ZIndex + 1
        TextLabel.LayoutOrder = thisWidget.ZIndex + 1
        TextLabel.AutomaticSize = Enum.AutomaticSize.XY
        TextLabel.AnchorPoint = Vector2.new(0, 0.5)
        TextLabel.BackgroundTransparency = 1
        TextLabel.BorderSizePixel = 0
        TextLabel.Parent = RadioButton

		return RadioButton
	end,
	Update = function(thisWidget)
		thisWidget.Instance.TextLabel.Text = thisWidget.arguments.Text or "Radio Button"
	end,
	Discard = function(thisWidget)
		thisWidget.Instance:Destroy()
		discardState(thisWidget)
	end,
	GenerateState = function(thisWidget)
		if thisWidget.state.value == nil then
			thisWidget.state.value = Iris._widgetState(thisWidget, "value", thisWidget.arguments.Value)
		end
	end,
	UpdateState = function(thisWidget)
		local Circle = thisWidget.Instance.Button.Circle
		if thisWidget.state.value.value == thisWidget.arguments.Value then
			-- only need to hide the circle
			Circle.BackgroundTransparency = Iris._config.CheckMarkTransparency
			thisWidget.lastActiveTick = Iris._cycleTick + 1
		else
			Circle.BackgroundTransparency = 1
			thisWidget.lastDeactiveTick = Iris._cycleTick + 1
		end
	end
})

Iris.WidgetConstructor("Tree", {
    hasState = true,
    hasChildren = true,
    Args = {
        ["Text"] = 1,
        ["SpanAvailWidth"] = 2,
        ["NoIndent"] = 3
    },
    Events = {
        ["collasped"] = {
            ["Init"] = function(thisWidget)

            end,
            ["Get"] = function(thisWidget)
                return thisWidget._lastCollapsedTick == Iris._cycleTick
            end
        },
        ["uncollapsed"] = {
            ["Init"] = function(thisWidget)

            end,
            ["Get"] = function(thisWidget)
                return thisWidget._lastUncollapsedTick == Iris._cycleTick
            end
        },
        ["hovered"] = hoverEvent(function(thisWidget)
            return thisWidget.Instance
        end)
    },
    Generate = function(thisWidget)
        local Tree = Instance.new("Frame")
        Tree.Name = "Iris_Tree"
        Tree.BackgroundTransparency = 1
        Tree.BorderSizePixel = 0
        Tree.ZIndex = thisWidget.ZIndex
        Tree.LayoutOrder = thisWidget.ZIndex
        Tree.Size = UDim2.new(Iris._config.ItemWidth, UDim.new(0, 0))
        Tree.AutomaticSize = Enum.AutomaticSize.Y

        thisWidget.hasChildren = false

        UIListLayout(Tree, Enum.FillDirection.Vertical, UDim.new(0, 0))

        local ChildContainer = Instance.new("Frame")
        ChildContainer.Name = "ChildContainer"
        ChildContainer.BackgroundTransparency = 1
        ChildContainer.BorderSizePixel = 0
        ChildContainer.ZIndex = thisWidget.ZIndex + 1
        ChildContainer.LayoutOrder = thisWidget.ZIndex + 1
        ChildContainer.Size = UDim2.fromScale(1, 0)
        ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
        ChildContainer.Visible = false
        ChildContainer.Parent = Tree

        UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))
        
        local ChildContainerPadding = UIPadding(ChildContainer, Vector2.new(0, 0))
        ChildContainerPadding.PaddingTop = UDim.new(0, Iris._config.ItemSpacing.Y)

        local Header = Instance.new("Frame")
        Header.Name = "Header"
        Header.BackgroundTransparency = 1
        Header.BorderSizePixel = 0
        Header.ZIndex = thisWidget.ZIndex
        Header.LayoutOrder = thisWidget.ZIndex
        Header.Size = UDim2.fromScale(1, 0)
        Header.AutomaticSize = Enum.AutomaticSize.Y
        Header.Parent = Tree

        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.BackgroundTransparency = 1
        Button.BorderSizePixel = 0
        Button.ZIndex = thisWidget.ZIndex
        Button.LayoutOrder = thisWidget.ZIndex
        Button.AutoButtonColor = false
        Button.Text = ""
        Button.Parent = Header

        applyInteractionHighlights(Button, Header, {
            ButtonColor = Color3.fromRGB(0, 0, 0),
            ButtonTransparency = 1,
            ButtonHoveredColor = Iris._config.HeaderHoveredColor,
            ButtonHoveredTransparency = Iris._config.HeaderHoveredTransparency,
            ButtonActiveColor = Iris._config.HeaderActiveColor,
            ButtonActiveTransparency = Iris._config.HeaderActiveTransparency,
        })

		local uiPadding = UIPadding(Button, Vector2.zero)
		uiPadding.PaddingLeft = UDim.new(0, Iris._config.FramePadding.X)
        local ButtonUIListLayout = UIListLayout(Button, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.FramePadding.X))
        ButtonUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

        local Arrow = Instance.new("TextLabel")
        Arrow.Name = "Arrow"
        Arrow.Size = UDim2.fromOffset(Iris._config.TextSize, 0)
        Arrow.BackgroundTransparency = 1
        Arrow.BorderSizePixel = 0
        Arrow.ZIndex = thisWidget.ZIndex
        Arrow.LayoutOrder = thisWidget.ZIndex
        Arrow.AutomaticSize = Enum.AutomaticSize.Y

        applyTextStyle(Arrow)
        Arrow.TextXAlignment = Enum.TextXAlignment.Center
        Arrow.TextSize = Iris._config.TextSize - 4
        Arrow.Text = ICONS.RIGHT_POINTING_TRIANGLE

        Arrow.Parent = Button

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Name = "TextLabel"
        TextLabel.Size = UDim2.fromOffset(0, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.BorderSizePixel = 0
        TextLabel.ZIndex = thisWidget.ZIndex
        TextLabel.LayoutOrder = thisWidget.ZIndex
        TextLabel.AutomaticSize = Enum.AutomaticSize.XY
        TextLabel.Parent = Button
        local TextPadding = UIPadding(TextLabel,Vector2.new(0, 0))
        TextPadding.PaddingRight = UDim.new(0, 21)

        applyTextStyle(TextLabel)

        Button.MouseButton1Click:Connect(function()
            thisWidget.state.isUncollapsed:set(not thisWidget.state.isUncollapsed.value)
        end)

        return Tree
    end,
    Update = function(thisWidget)
        local Button = thisWidget.Instance.Header.Button
        local ChildContainer = thisWidget.Instance.ChildContainer
        Button.TextLabel.Text = thisWidget.arguments.Text or "Tree"
        if thisWidget.arguments.SpanAvailWidth then
            Button.AutomaticSize = Enum.AutomaticSize.Y
            Button.Size = UDim2.fromScale(1, 0)
        else
            Button.AutomaticSize = Enum.AutomaticSize.XY
            Button.Size = UDim2.fromScale(0, 0)
        end

        if thisWidget.arguments.NoIndent then
            ChildContainer.UIPadding.PaddingLeft = UDim.new(0, 0)
        else
            ChildContainer.UIPadding.PaddingLeft = UDim.new(0, Iris._config.IndentSpacing)
        end

    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
        discardState(thisWidget)
    end,
    ChildAdded = function(thisWidget)
        local ChildContainer = thisWidget.Instance.ChildContainer
        local isUncollapsed = thisWidget.state.isUncollapsed.value

        thisWidget.hasChildren = true
        ChildContainer.Visible = isUncollapsed and thisWidget.hasChildren

        return thisWidget.Instance.ChildContainer
    end,
    UpdateState = function(thisWidget)
        local isUncollapsed = thisWidget.state.isUncollapsed.value
        local Arrow = thisWidget.Instance.Header.Button.Arrow
        local ChildContainer = thisWidget.Instance.ChildContainer
        Arrow.Text = (isUncollapsed and ICONS.DOWN_POINTING_TRIANGLE or ICONS.RIGHT_POINTING_TRIANGLE)

        if isUncollapsed then
            thisWidget.lastUncollaspedTick = Iris._cycleTick + 1
        else
            thisWidget.lastCollapsedTick = Iris._cycleTick + 1
        end

        ChildContainer.Visible = isUncollapsed and thisWidget.hasChildren
    end,
    GenerateState = function(thisWidget)
        if thisWidget.state.isUncollapsed == nil then
            thisWidget.state.isUncollapsed = Iris._widgetState(thisWidget, "isUncollapsed", false)
        end
    end
})

Iris.WidgetConstructor("CollapsingHeader", {
    hasState = true,
    hasChildren = true,
    Args = {
        ["Text"] = 1,
    },
    Events = {
        ["collasped"] = {
            ["Init"] = function(thisWidget)

            end,
            ["Get"] = function(thisWidget)
                return thisWidget._lastCollapsedTick == Iris._cycleTick
            end
        },
        ["uncollapsed"] = {
            ["Init"] = function(thisWidget)

            end,
            ["Get"] = function(thisWidget)
                return thisWidget._lastUncollapsedTick == Iris._cycleTick
            end
        },
        ["hovered"] = hoverEvent(function(thisWidget)
            return thisWidget.Instance
        end)
    },
    Generate = function(thisWidget)
        local CollapsingHeader = Instance.new("Frame")
        CollapsingHeader.Name = "Iris_CollapsingHeader"
        CollapsingHeader.BackgroundTransparency = 1
        CollapsingHeader.BorderSizePixel = 0
        CollapsingHeader.ZIndex = thisWidget.ZIndex
        CollapsingHeader.LayoutOrder = thisWidget.ZIndex
        CollapsingHeader.Size = UDim2.new(Iris._config.ItemWidth, UDim.new(0, 0))
        CollapsingHeader.AutomaticSize = Enum.AutomaticSize.Y

        thisWidget.hasChildren = false

        UIListLayout(CollapsingHeader, Enum.FillDirection.Vertical, UDim.new(0, 0))

        local ChildContainer = Instance.new("Frame")
        ChildContainer.Name = "ChildContainer"
        ChildContainer.BackgroundTransparency = 1
        ChildContainer.BorderSizePixel = 0
        ChildContainer.ZIndex = thisWidget.ZIndex + 1
        ChildContainer.LayoutOrder = thisWidget.ZIndex + 1
        ChildContainer.Size = UDim2.fromScale(1, 0)
        ChildContainer.AutomaticSize = Enum.AutomaticSize.Y
        ChildContainer.Visible = false
        ChildContainer.Parent = CollapsingHeader

        UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))
        
        local ChildContainerPadding = UIPadding(ChildContainer, Vector2.new(0, 0))
        ChildContainerPadding.PaddingTop = UDim.new(0, Iris._config.ItemSpacing.Y)

        local Header = Instance.new("Frame")
        Header.Name = "Header"
        Header.BackgroundTransparency = 1
        Header.BorderSizePixel = 0
        Header.ZIndex = thisWidget.ZIndex
        Header.LayoutOrder = thisWidget.ZIndex
        Header.Size = UDim2.fromScale(1, 0)
        Header.AutomaticSize = Enum.AutomaticSize.Y
        Header.Parent = CollapsingHeader

		local Collapse = Instance.new("TextButton")
		Collapse.Name = "Collapse"
		Collapse.BackgroundColor3 = Iris._config.HeaderColor
		Collapse.BackgroundTransparency = Iris._config.HeaderTransparency
		Collapse.BorderSizePixel = 0
		Collapse.ZIndex = thisWidget.ZIndex
		Collapse.LayoutOrder = thisWidget.ZIndex
		Collapse.Size = UDim2.new(1, 2 * Iris._config.FramePadding.X, 0, 0)
		Collapse.Position = UDim2.fromOffset(-4, 0)
		Collapse.AutomaticSize = Enum.AutomaticSize.Y
		Collapse.Text = ""
		Collapse.AutoButtonColor = false
		Collapse.Parent = Header

		UIPadding(Collapse, Vector2.new(2 * Iris._config.FramePadding.X, Iris._config.FramePadding.Y)) -- we add a custom padding because it extends on both sides
		applyFrameStyle(Collapse, true, true)

        applyInteractionHighlights(Collapse, Collapse, {
            ButtonColor = Iris._config.HeaderColor,
            ButtonTransparency = Iris._config.HeaderTransparency,
            ButtonHoveredColor = Iris._config.HeaderHoveredColor,
            ButtonHoveredTransparency = Iris._config.HeaderHoveredTransparency,
            ButtonActiveColor = Iris._config.HeaderActiveColor,
            ButtonActiveTransparency = Iris._config.HeaderActiveTransparency,
        })

        local ButtonUIListLayout = UIListLayout(Collapse, Enum.FillDirection.Horizontal, UDim.new(0, 2 * Iris._config.FramePadding.X))
        ButtonUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

        local Arrow = Instance.new("TextLabel")
        Arrow.Name = "Arrow"
        Arrow.Size = UDim2.fromOffset(Iris._config.TextSize, 0)
        Arrow.BackgroundTransparency = 1
        Arrow.BorderSizePixel = 0
        Arrow.ZIndex = thisWidget.ZIndex
        Arrow.LayoutOrder = thisWidget.ZIndex
        Arrow.AutomaticSize = Enum.AutomaticSize.Y

        applyTextStyle(Arrow)
        Arrow.TextXAlignment = Enum.TextXAlignment.Center
        Arrow.TextSize = Iris._config.TextSize - 4
        Arrow.Text = ICONS.RIGHT_POINTING_TRIANGLE

        Arrow.Parent = Collapse

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Name = "TextLabel"
        TextLabel.Size = UDim2.fromOffset(0, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.BorderSizePixel = 0
        TextLabel.ZIndex = thisWidget.ZIndex
        TextLabel.LayoutOrder = thisWidget.ZIndex
        TextLabel.AutomaticSize = Enum.AutomaticSize.XY
        TextLabel.Parent = Collapse
        local TextPadding = UIPadding(TextLabel,Vector2.new(0, 0))
        TextPadding.PaddingRight = UDim.new(0, 21)

        applyTextStyle(TextLabel)

        Collapse.MouseButton1Click:Connect(function()
            thisWidget.state.isUncollapsed:set(not thisWidget.state.isUncollapsed.value)
        end)

        return CollapsingHeader
    end,
    Update = function(thisWidget)
        local Collapse = thisWidget.Instance.Header.Collapse
        Collapse.TextLabel.Text = thisWidget.arguments.Text or "Collapsing Header"
    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
        discardState(thisWidget)
    end,
    ChildAdded = function(thisWidget)
        local ChildContainer = thisWidget.Instance.ChildContainer
        local isUncollapsed = thisWidget.state.isUncollapsed.value

        thisWidget.hasChildren = true
        ChildContainer.Visible = isUncollapsed and thisWidget.hasChildren

        return thisWidget.Instance.ChildContainer
    end,
    UpdateState = function(thisWidget)
        local isUncollapsed = thisWidget.state.isUncollapsed.value
        local Arrow = thisWidget.Instance.Header.Collapse.Arrow
        local ChildContainer = thisWidget.Instance.ChildContainer
        Arrow.Text = (isUncollapsed and ICONS.DOWN_POINTING_TRIANGLE or ICONS.RIGHT_POINTING_TRIANGLE)

        if isUncollapsed then
            thisWidget.lastUncollaspedTick = Iris._cycleTick + 1
        else
            thisWidget.lastCollapsedTick = Iris._cycleTick + 1
        end

        ChildContainer.Visible = isUncollapsed and thisWidget.hasChildren
    end,
    GenerateState = function(thisWidget)
        if thisWidget.state.isUncollapsed == nil then
            thisWidget.state.isUncollapsed = Iris._widgetState(thisWidget, "isUncollapsed", false)
        end
    end
})


Iris.WidgetConstructor("InputNum", {
    hasState = true,
    hasChildren = false,
    Args = {
        ["Text"] = 1,
        ["Increment"] = 2,
        ["Min"] = 3,
        ["Max"] = 4,
        ["Format"] = 5,
        ["NoButtons"] = 6,
        ["NoField"] = 7
    },
    Events = {
        ["numberChanged"] = {
            ["Init"] = function(thisWidget)

            end,
            ["Get"] = function(thisWidget)
                return thisWidget.lastNumchangeTick == Iris._cycleTick
            end
        },
        ["hovered"] = hoverEvent(function(thisWidget)
            return thisWidget.Instance
        end)
    },
    Generate = function(thisWidget)
        local InputNum = Instance.new("Frame")
        InputNum.Name = "Iris_InputNum"
        InputNum.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(0, 0))
        InputNum.BackgroundTransparency = 1
        InputNum.BorderSizePixel = 0
        InputNum.ZIndex = thisWidget.ZIndex
        InputNum.LayoutOrder = thisWidget.ZIndex
        InputNum.AutomaticSize = Enum.AutomaticSize.Y
        UIListLayout(InputNum, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X))

        local inputButtonsWidth = Iris._config.TextSize
        local textLabelHeight = inputButtonsWidth + Iris._config.FramePadding.Y * 2

        local InputField = Instance.new("TextBox")
        InputField.Name = "InputField"
        applyFrameStyle(InputField)
        applyTextStyle(InputField)
        InputField.UIPadding.PaddingLeft = UDim.new(0, Iris._config.ItemInnerSpacing.X)
        InputField.ZIndex = thisWidget.ZIndex + 1
        InputField.LayoutOrder = thisWidget.ZIndex + 1
        InputField.AutomaticSize = Enum.AutomaticSize.Y
        InputField.BackgroundColor3 = Iris._config.FrameBgColor
        InputField.BackgroundTransparency = Iris._config.FrameBgTransparency
        InputField.ClearTextOnFocus = false
        InputField.TextTruncate = Enum.TextTruncate.AtEnd
        InputField.Parent = InputNum

        InputField.FocusLost:Connect(function()
            local newValue = tonumber(InputField.Text)
            if newValue ~= nil then
                newValue = math.clamp(newValue, thisWidget.arguments.Min or -math.huge, thisWidget.arguments.Max or math.huge)
                thisWidget.state.number:set(newValue)
                thisWidget.lastNumchangeTick = Iris._cycleTick + 1
            else
                InputField.Text = thisWidget.state.number.value
            end
        end)

        InputField.Focused:Connect(function()
            InputField.SelectionStart = 1
        end)

        local SubButton = abstractButton.Generate(thisWidget)
        SubButton.Name = "SubButton"
        SubButton.ZIndex = thisWidget.ZIndex + 2
        SubButton.LayoutOrder = thisWidget.ZIndex + 2
        SubButton.TextXAlignment = Enum.TextXAlignment.Center
        SubButton.Text = "-"
        SubButton.Size = UDim2.fromOffset(inputButtonsWidth - 2, inputButtonsWidth)
        SubButton.Parent = InputNum

        SubButton.MouseButton1Click:Connect(function()
            local newValue = thisWidget.state.number.value - (thisWidget.arguments.Increment or 1)
            newValue = math.clamp(newValue, thisWidget.arguments.Min or -math.huge, thisWidget.arguments.Max or math.huge)
            thisWidget.state.number:set(newValue)
            thisWidget.lastNumchangeTick = Iris._cycleTick + 1
        end)

        local AddButton = abstractButton.Generate(thisWidget)
        AddButton.Name = "AddButton"
        AddButton.ZIndex = thisWidget.ZIndex + 3
        AddButton.LayoutOrder = thisWidget.ZIndex + 3
        AddButton.TextXAlignment = Enum.TextXAlignment.Center
        AddButton.Text = "+"
        AddButton.Size = UDim2.fromOffset(inputButtonsWidth - 2, inputButtonsWidth)
        AddButton.Parent = InputNum

        AddButton.MouseButton1Click:Connect(function()
            local newValue = thisWidget.state.number.value + (thisWidget.arguments.Increment or 1)
            newValue = math.clamp(newValue, thisWidget.arguments.Min or -math.huge, thisWidget.arguments.Max or math.huge)
            thisWidget.state.number:set(newValue)
            thisWidget.lastNumchangeTick = Iris._cycleTick + 1
        end)

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Name = "TextLabel"
        TextLabel.Size = UDim2.fromOffset(0, textLabelHeight)
        TextLabel.BackgroundTransparency = 1
        TextLabel.BorderSizePixel = 0
        TextLabel.ZIndex = thisWidget.ZIndex + 4
        TextLabel.LayoutOrder = thisWidget.ZIndex + 4
        TextLabel.AutomaticSize = Enum.AutomaticSize.X
        applyTextStyle(TextLabel)
        TextLabel.Parent = InputNum

        return InputNum
    end,
    Update = function(thisWidget)
        local TextLabel = thisWidget.Instance.TextLabel
        TextLabel.Text = thisWidget.arguments.Text or "Input Num"

        thisWidget.Instance.SubButton.Visible = not thisWidget.arguments.NoButtons
        thisWidget.Instance.AddButton.Visible = not thisWidget.arguments.NoButtons
        local InputField = thisWidget.Instance.InputField
        InputField.Visible = not thisWidget.arguments.NoField

        local inputButtonsTotalWidth = Iris._config.TextSize * 2 + Iris._config.ItemInnerSpacing.X * 2 + Iris._config.WindowPadding.X + 4
        if thisWidget.arguments.NoButtons then
            InputField.Size = UDim2.new(1, 0, 0, 0)
        else
            InputField.Size = UDim2.new(1, -inputButtonsTotalWidth, 0, 0)
        end
    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
        discardState(thisWidget)
    end,
    GenerateState = function(thisWidget)
        if thisWidget.state.number == nil then
            thisWidget.state.number = Iris._widgetState(thisWidget, "number", 0)
        end
    end,
    UpdateState = function(thisWidget)
        local InputField = thisWidget.Instance.InputField
        InputField.Text = string.format(thisWidget.arguments.Format or "%f", thisWidget.state.number.value)
    end
})

Iris.WidgetConstructor("InputText", {
    hasState = true,
    hasChildren = false,
    Args = {
        ["Text"] = 1,
        ["TextHint"] = 2
    },
    Events = {
        ["textChanged"] = {
            ["Init"] = function(thisWidget)

            end,
            ["Get"] = function(thisWidget)
                return thisWidget.lastTextchangeTick == Iris._cycleTick
            end
        },
        ["hovered"] = hoverEvent(function(thisWidget)
            return thisWidget.Instance
        end)
    },
    Generate = function(thisWidget)
        local textLabelHeight = Iris._config.TextSize

        local InputText = Instance.new("Frame")
        InputText.Name = "Iris_InputText"
        InputText.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(0, 0))
        InputText.BackgroundTransparency = 1
        InputText.BorderSizePixel = 0
        InputText.ZIndex = thisWidget.ZIndex
        InputText.LayoutOrder = thisWidget.ZIndex
        InputText.AutomaticSize = Enum.AutomaticSize.Y
        UIListLayout(InputText, Enum.FillDirection.Horizontal, UDim.new(0, Iris._config.ItemInnerSpacing.X))

        local InputField = Instance.new("TextBox")
        InputField.Name = "InputField"
        applyFrameStyle(InputField)
        applyTextStyle(InputField)
        InputField.UIPadding.PaddingLeft = UDim.new(0, Iris._config.ItemInnerSpacing.X)
        InputField.UIPadding.PaddingRight = UDim.new(0, 0)
        InputField.ZIndex = thisWidget.ZIndex + 1
        InputField.LayoutOrder = thisWidget.ZIndex + 1
        InputField.AutomaticSize = Enum.AutomaticSize.Y
        InputField.Size = UDim2.new(Iris._config.ContentWidth, UDim.new(0, 0))
        InputField.BackgroundColor3 = Iris._config.FrameBgColor
        InputField.BackgroundTransparency = Iris._config.FrameBgTransparency
        InputField.ClearTextOnFocus = false
        InputField.Text = ""
        InputField.PlaceholderColor3 = Iris._config.TextDisabledColor
        InputField.TextTruncate = Enum.TextTruncate.AtEnd

        InputField.FocusLost:Connect(function()
            thisWidget.state.text:set(InputField.Text)
            thisWidget.lastTextchangeTick = Iris._cycleTick
        end)

        InputField.Parent = InputText

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Name = "TextLabel"
        TextLabel.Position = UDim2.new(1, Iris._config.ItemInnerSpacing.X, 0, 0)
        TextLabel.Size = UDim2.fromOffset(0, textLabelHeight)
        TextLabel.BackgroundTransparency = 1
        TextLabel.BorderSizePixel = 0
        TextLabel.ZIndex = thisWidget.ZIndex + 2
        TextLabel.LayoutOrder = thisWidget.ZIndex + 2
        TextLabel.AutomaticSize = Enum.AutomaticSize.X
        applyTextStyle(TextLabel)
        TextLabel.Parent = InputText

        return InputText
    end,
    Update = function(thisWidget)
        local TextLabel = thisWidget.Instance.TextLabel
        TextLabel.Text = thisWidget.arguments.Text or "Input Text"

        thisWidget.Instance.InputField.PlaceholderText = thisWidget.arguments.TextHint or ""
    end,
    Discard = function(thisWidget)
        thisWidget.Instance:Destroy()
        discardState(thisWidget)
    end,
    GenerateState = function(thisWidget)
        if thisWidget.state.text == nil then
            thisWidget.state.text = Iris._widgetState(thisWidget, "text", "")
        end
    end,
    UpdateState = function(thisWidget)
        thisWidget.Instance.InputField.Text = thisWidget.state.text.value
    end
})

do -- Iris.Tooltip
    local function findBestWindowPosForPopup(refPos, size, outerMin, outerMax)
        local CURSOR_OFFSET_DIST = 20
        
        if refPos.X + size.X + CURSOR_OFFSET_DIST > outerMax.X then
            if refPos.Y + size.Y + CURSOR_OFFSET_DIST > outerMax.Y then
                -- placed to the top
                refPos += Vector2.new(0, - (CURSOR_OFFSET_DIST + size.Y))
            else
                -- placed to the bottom
                refPos += Vector2.new(0, CURSOR_OFFSET_DIST)
            end
        else
            -- placed to the right
            refPos += Vector2.new(CURSOR_OFFSET_DIST, 0)
        end

        local clampedPos = Vector2.new(
            math.max(math.min(refPos.X + size.X, outerMax.X) - size.X, outerMin.X),
            math.max(math.min(refPos.Y + size.Y, outerMax.Y) - size.Y, outerMin.Y)
        )
        return clampedPos
    end

    local function relocateTooltips()
        if Iris._rootInstance == nil then
            return
        end
        local PopupScreenGui = Iris._rootInstance.PopupScreenGui
        local TooltipContainer = PopupScreenGui.TooltipContainer
        local mouseLocation = UserInputService:GetMouseLocation() - Vector2.new(0, 36)
        local newPosition = findBestWindowPosForPopup(mouseLocation, TooltipContainer.AbsoluteSize, Vector2.new(Iris._config.DisplaySafeAreaPadding, Iris._config.DisplaySafeAreaPadding), PopupScreenGui.AbsoluteSize)
        TooltipContainer.Position = UDim2.fromOffset(newPosition.X, newPosition.Y)
    end

    UserInputService.InputChanged:Connect(relocateTooltips)

    Iris.WidgetConstructor("Tooltip", { 
        hasState = false,
        hasChildren = false,
        Args = {
            ["Text"] = 1
        },
        Events = {

        },
        Generate = function(thisWidget)
            thisWidget.parentWidget = Iris._rootWidget -- only allow root as parent

            local Tooltip = Instance.new("TextLabel")
            Tooltip.Name = "Iris_Tooltip"
            Tooltip.Size = UDim2.fromOffset(0, 0)
            Tooltip.ZIndex = thisWidget.ZIndex + 1
            Tooltip.LayoutOrder = thisWidget.ZIndex + 1
            Tooltip.AutomaticSize = Enum.AutomaticSize.XY
    
            applyTextStyle(Tooltip)
            Tooltip.BackgroundColor3 = Iris._config.WindowBgColor
            Tooltip.BackgroundTransparency = Iris._config.WindowBgTransparency
            Tooltip.BorderSizePixel = Iris._config.WindowBorderSize
            Tooltip.TextWrapped = true

            local uiStroke = Instance.new("UIStroke")
            uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            uiStroke.LineJoinMode = Enum.LineJoinMode.Round
            uiStroke.Thickness = Iris._config.WindowBorderSize
            uiStroke.Color = Iris._config.BorderActiveColor
            uiStroke.Parent = Tooltip
            UIPadding(Tooltip, Iris._config.FramePadding)
            UISizeConstraint(Tooltip, Vector2.new(0, 0), Vector2.new(Iris._config.ContentWidth.Offset, 1e9))
            
            return Tooltip
        end,
        Update = function(thisWidget)
            local Tooltip = thisWidget.Instance
            if thisWidget.arguments.Text == nil then
                error("Iris.Text Text Argument is required", 5)
            end
            Tooltip.Text = thisWidget.arguments.Text
            relocateTooltips()
        end,
        Discard = function(thisWidget)
            thisWidget.Instance:Destroy()
        end
    })
end

do -- Iris.Table
    local tableWidgets = {}

    table.insert(Iris._postCycleCallbacks, function()
        for _, v in tableWidgets do
            v.RowColumnIndex = 0
        end
    end)

    Iris.NextColumn = function()
        Iris._GetParentWidget().RowColumnIndex += 1
    end
    Iris.SetColumnIndex = function(ColumnIndex)
        local ParentWidget = Iris._GetParentWidget()
        assert(ColumnIndex >= ParentWidget.InitialNumColumns, "Iris.SetColumnIndex Argument must be in column range")
        ParentWidget.RowColumnIndex = math.floor(ParentWidget.RowColumnIndex / ParentWidget.InitialNumColumns) + (ColumnIndex - 1)
    end
    Iris.NextRow = function()
        -- sets column Index back to 0, increments Row
        local ParentWidget = Iris._GetParentWidget()
        local InitialNumColumns = ParentWidget.InitialNumColumns
        local nextRow = math.floor((ParentWidget.RowColumnIndex + 1) / InitialNumColumns) * InitialNumColumns
        ParentWidget.RowColumnIndex = nextRow
    end

    Iris.WidgetConstructor("Table", {
        hasState = false,
        hasChildren = true,
        Args = {
            ["NumColumns"] = 1,
            ["RowBg"] = 2,
            ["BordersOuter"] = 3,
            ["BordersInner"] = 4
        },
        Events = {
            ["hovered"] = hoverEvent(function(thisWidget)
                return thisWidget.Instance
            end)
        },
        Generate = function(thisWidget)
            tableWidgets[thisWidget.ID] = thisWidget

            thisWidget.InitialNumColumns = -1
            thisWidget.RowColumnIndex = 0
            -- reference to these is stored as an optimization
            thisWidget.ColumnInstances = {}
            thisWidget.CellInstances = {}

            local Table = Instance.new("Frame")
            Table.Name = "Iris_Table"
            Table.Size = UDim2.new(Iris._config.ItemWidth, UDim.new(0, 0))
            Table.BackgroundTransparency = 1
            Table.BorderSizePixel = 0
            Table.ZIndex = thisWidget.ZIndex + 1024 -- allocate room for 1024 cells, because Table UIStroke has to appear above cell UIStroke
            Table.LayoutOrder = thisWidget.ZIndex
            Table.AutomaticSize = Enum.AutomaticSize.Y
			Table.ClipsDescendants = true

            UIListLayout(Table, Enum.FillDirection.Horizontal, UDim.new(0, 0))

            UIStroke(Table, 1, Iris._config.TableBorderStrongColor, Iris._config.TableBorderStrongTransparency)


            return Table
        end,
        Update = function(thisWidget)
            local thisWidgetInstance = thisWidget.Instance
            local ColumnInstances = thisWidget.ColumnInstances

            if thisWidget.arguments.BordersOuter == false then
                thisWidgetInstance.UIStroke.Thickness = 0
            else
                thisWidget.Instance.UIStroke.Thickness = 1
            end

            if thisWidget.InitialNumColumns == -1 then
                if thisWidget.arguments.NumColumns == nil then
                    error("Iris.Table NumColumns argument is required", 5)
                end
                thisWidget.InitialNumColumns = thisWidget.arguments.NumColumns

                for i = 1, thisWidget.InitialNumColumns do
                    local column = Instance.new("Frame")
                    column.Name = `Column_{i}`
                    column.BackgroundTransparency = 1
                    column.BorderSizePixel = 0
                    local ColumnZIndex = thisWidget.ZIndex + 1 + i
                    column.ZIndex = ColumnZIndex
                    column.LayoutOrder = ColumnZIndex
                    column.AutomaticSize = Enum.AutomaticSize.Y
                    column.Size = UDim2.new(1 / thisWidget.InitialNumColumns, 0, 0, 0)
					column.ClipsDescendants = true

                    UIListLayout(column, Enum.FillDirection.Vertical, UDim.new(0, 0))

                    ColumnInstances[i] = column
                    column.Parent = thisWidgetInstance
                end

            elseif thisWidget.arguments.NumColumns ~= thisWidget.InitialNumColumns then
                -- its possible to make it so that the NumColumns can increase,
                -- but decreasing it would interfere with child widget instances
                error("Iris.Table NumColumns Argument must be static")
            end

            if thisWidget.arguments.RowBg == false then
                for _,v in thisWidget.CellInstances do
                    v.BackgroundTransparency = 1
                end
            else
                for rowColumnIndex, v in thisWidget.CellInstances do
                    local currentRow = math.ceil((rowColumnIndex) / thisWidget.InitialNumColumns)
                    v.BackgroundTransparency = if currentRow % 2 == 0 then Iris._config.TableRowBgAltTransparency else Iris._config.TableRowBgTransparency
                end
            end

            if thisWidget.arguments.BordersInner == false then
                for _,v in thisWidget.CellInstances do
                    v.UIStroke.Thickness = 0
                end
            else
                for _,v in thisWidget.CellInstances do
                    v.UIStroke.Thickness = 0.5
                end
            end
        end,
        Discard = function(thisWidget)
            tableWidgets[thisWidget.ID] = nil
            thisWidget.Instance:Destroy()
        end,
        ChildAdded = function(thisWidget)
            if thisWidget.RowColumnIndex == 0 then
                thisWidget.RowColumnIndex = 1
            end
            local potentialCellParent = thisWidget.CellInstances[thisWidget.RowColumnIndex]
            if potentialCellParent then
                return potentialCellParent
            end
            local cell = Instance.new("Frame")
            cell.AutomaticSize = Enum.AutomaticSize.Y
            cell.Size = UDim2.new(1, 0, 0, 0)
            cell.BackgroundTransparency = 1
            cell.BorderSizePixel = 0
            UIPadding(cell, Iris._config.CellPadding)
            local selectedParent = thisWidget.ColumnInstances[((thisWidget.RowColumnIndex - 1) % thisWidget.InitialNumColumns) + 1]
            local newZIndex = selectedParent.ZIndex + thisWidget.RowColumnIndex
            cell.ZIndex = newZIndex
            cell.LayoutOrder = newZIndex
            cell.Name = `Cell_{thisWidget.RowColumnIndex}`

            UIListLayout(cell, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))

            if thisWidget.arguments.BordersInner == false then
                UIStroke(cell, 0, Iris._config.TableBorderLightColor, Iris._config.TableBorderLightTransparency)
            else
                UIStroke(cell, 0.5, Iris._config.TableBorderLightColor, Iris._config.TableBorderLightTransparency)
                -- this takes advantage of unintended behavior when UIStroke is set to 0.5 to render cell borders,
                -- at 0.5, only the top and left side of the cell will be rendered with a border.
            end

            if thisWidget.arguments.RowBg ~= false then
                local currentRow = math.ceil((thisWidget.RowColumnIndex) / thisWidget.InitialNumColumns)
                local color = if currentRow % 2 == 0 then Iris._config.TableRowBgAltColor else Iris._config.TableRowBgColor
                local transparency = if currentRow % 2 == 0 then Iris._config.TableRowBgAltTransparency else Iris._config.TableRowBgTransparency

                cell.BackgroundColor3 = color
                cell.BackgroundTransparency = transparency
            end

            thisWidget.CellInstances[thisWidget.RowColumnIndex] = cell
            cell.Parent = selectedParent
            return cell
        end
    })
end

do -- Iris.Window
    local windowDisplayOrder = 0 -- incremental count which is used for determining focused windows ZIndex
    local dragWindow -- window being dragged, may be nil
    local isDragging = false
    local moveDeltaCursorPosition -- cursor offset from drag origin (top left of window)

    local resizeWindow -- window being resized, may be nil
    local isResizing = false
    local isInsideResize = false -- is cursor inside of the focused window resize outer padding
    local isInsideWindow = false -- is cursor inside of the focused window
    local resizeFromTopBottom = Enum.TopBottom.Top
    local resizeFromLeftRight = Enum.LeftRight.Left

    local lastCursorPosition

    local focusedWindow -- window with focus, may be nil
    local anyFocusedWindow = false -- is there any focused window?

    local windowWidgets = {} -- array of widget objects of type window

    local function getAbsoluteSize(thisWidget) -- possible parents are GuiBase2d, CoreGui, PlayerGui
        -- possibly the stupidest function ever written
        local size
        if thisWidget.usesScreenGUI then
            size = thisWidget.Instance.AbsoluteSize
        else
            local rootParent = thisWidget.Instance.Parent
            if rootParent:IsA("GuiBase2d") then
                size = rootParent.AbsoluteSize
            else
                if rootParent.Parent:IsA("GuiBase2d") then
                    size = rootParent.AbsoluteSize
                else
                    size = workspace.CurrentCamera.ViewportSize
                end
            end
        end
        return size
    end

    local function quickSwapWindows()
        -- ctrl + tab swapping functionality
        if Iris._config.UseScreenGUIs == false then
            return
        end

        local lowest = 0xFFFF
        local lowestWidget

        for _, widget in windowWidgets do
            if widget.state.isOpened.value and (not widget.arguments.NoNav) then
                local value = widget.Instance.DisplayOrder
                if value < lowest then
                    lowest = value
                    lowestWidget = widget
                end
            end
        end

        if lowestWidget.state.isUncollapsed.value == false then
            lowestWidget.state.isUncollapsed:set(true)
        end
        Iris.SetFocusedWindow(lowestWidget)
    end

    local function fitSizeToWindowBounds(thisWidget, intentedSize)
        local windowSize = Vector2.new(thisWidget.state.position.value.X, thisWidget.state.position.value.Y)
        local minWindowSize = (Iris._config.TextSize + Iris._config.FramePadding.Y * 2) * 2
        local usableSize = getAbsoluteSize(thisWidget)
        local safeAreaPadding = Vector2.new(Iris._config.WindowBorderSize + Iris._config.DisplaySafeAreaPadding.X, Iris._config.WindowBorderSize + Iris._config.DisplaySafeAreaPadding.Y)

        local maxWindowSize = (
            usableSize -
            windowSize -
            safeAreaPadding
        )
        return Vector2.new(
            math.clamp(intentedSize.X, minWindowSize, math.max(maxWindowSize.X, minWindowSize)),
            math.clamp(intentedSize.Y, minWindowSize, math.max(maxWindowSize.Y, minWindowSize))
        )
    end

    local function fitPositionToWindowBounds(thisWidget, intendedPosition)
        local thisWidgetInstance = thisWidget.Instance
        local usableSize = getAbsoluteSize(thisWidget)
        local safeAreaPadding = Vector2.new(Iris._config.WindowBorderSize + Iris._config.DisplaySafeAreaPadding.X, Iris._config.WindowBorderSize + Iris._config.DisplaySafeAreaPadding.Y)

        return Vector2.new(
            math.clamp(
                intendedPosition.X,
                safeAreaPadding.X,
                math.max(safeAreaPadding.X, usableSize.X - thisWidgetInstance.WindowButton.AbsoluteSize.X - safeAreaPadding.X)
            ),
            math.clamp(
                intendedPosition.Y,
                safeAreaPadding.Y, 
                math.max(safeAreaPadding.Y, usableSize.Y - thisWidgetInstance.WindowButton.AbsoluteSize.Y - safeAreaPadding.Y)
            )
        )
    end

    Iris.SetFocusedWindow = function(thisWidget: { [any]: any } | nil)
        if focusedWindow == thisWidget then return end

        if anyFocusedWindow then
            if windowWidgets[focusedWindow.ID] ~= nil then
                -- update appearance to unfocus
                local TitleBar = focusedWindow.Instance.WindowButton.TitleBar
                if focusedWindow.state.isUncollapsed.value then
                    TitleBar.BackgroundColor3 = Iris._config.TitleBgColor
                    TitleBar.BackgroundTransparency = Iris._config.TitleBgTransparency
                else
                    TitleBar.BackgroundColor3 = Iris._config.TitleBgCollapsedColor
                    TitleBar.BackgroundTransparency = Iris._config.TitleBgCollapsedTransparency
                end
                focusedWindow.Instance.WindowButton.UIStroke.Color = Iris._config.BorderColor
            end

            anyFocusedWindow = false
            focusedWindow = nil
        end

        if thisWidget ~= nil then
            -- update appearance to focus
            anyFocusedWindow = true
            focusedWindow = thisWidget
            local TitleBar = focusedWindow.Instance.WindowButton.TitleBar
            TitleBar.BackgroundColor3 = Iris._config.TitleBgActiveColor
            TitleBar.BackgroundTransparency = Iris._config.TitleBgActiveTransparency
            focusedWindow.Instance.WindowButton.UIStroke.Color = Iris._config.BorderActiveColor
            
            windowDisplayOrder += 1
            if thisWidget.usesScreenGUI then
                focusedWindow.Instance.DisplayOrder = windowDisplayOrder + Iris._config.DisplayOrderOffset
            end

            if thisWidget.state.isUncollapsed.value == false then
                thisWidget.state.isUncollapsed:set(true)
            end

            local firstSelectedObject = GuiService.SelectedObject
            if firstSelectedObject then
                if focusedWindow.Instance.TitleBar.Visible then
                    GuiService:Select(focusedWindow.Instance.TitleBar)
                else
                    GuiService:Select(focusedWindow.Instance.ChildContainer)
                end
            end
        end
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if not gameProcessedEvent and input.UserInputType == Enum.UserInputType.MouseButton1 then
            Iris.SetFocusedWindow(nil)
        end

        if input.KeyCode == Enum.KeyCode.Tab and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
            quickSwapWindows()
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if isInsideResize and not isInsideWindow and anyFocusedWindow then
                local midWindow = focusedWindow.state.position.value + (focusedWindow.state.size.value / 2)
                local cursorPosition = UserInputService:GetMouseLocation() - Vector2.new(0, 36) - midWindow

                -- check which axis its closest to, then check which side is closest with math.sign
                if math.abs(cursorPosition.X) * focusedWindow.state.size.value.Y >= math.abs(cursorPosition.Y) * focusedWindow.state.size.value.X then
                    resizeFromTopBottom = Enum.TopBottom.Center
                    resizeFromLeftRight = if math.sign(cursorPosition.X) == -1 then Enum.LeftRight.Left else Enum.LeftRight.Right
                else
                    resizeFromLeftRight = Enum.LeftRight.Center
                    resizeFromTopBottom = if math.sign(cursorPosition.Y) == -1 then Enum.TopBottom.Top else Enum.TopBottom.Bottom
                end
                isResizing = true
                resizeWindow = focusedWindow
            end
        end
    end)

    UserInputService.TouchTapInWorld:Connect(function(_, gameProcessedEvent)
        if not gameProcessedEvent then
            Iris.SetFocusedWindow(nil)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging then
            local mouseLocation
            if input.UserInputType == Enum.UserInputType.Touch then
                local location = input.Position
                mouseLocation = Vector2.new(location.X, location.Y)
            else
                mouseLocation = UserInputService:getMouseLocation()
            end
            local dragInstance = dragWindow.Instance.WindowButton
            local intendedPosition = mouseLocation - moveDeltaCursorPosition
            local newPos = fitPositionToWindowBounds(dragWindow, intendedPosition)

            -- state shouldnt be used like this, but calling :set would run the entire UpdateState function for the window, which is slow.
            dragInstance.Position = UDim2.fromOffset(newPos.X, newPos.Y)
            dragWindow.state.position.value = newPos
        end
        if isResizing then
            local resizeInstance = resizeWindow.Instance.WindowButton
            local windowPosition = Vector2.new(resizeInstance.Position.X.Offset, resizeInstance.Position.Y.Offset)
            local windowSize = Vector2.new(resizeInstance.Size.X.Offset, resizeInstance.Size.Y.Offset)

            local mouseDelta
            if input.UserInputType == Enum.UserInputType.Touch then
                mouseDelta = input.Delta
            else
                mouseDelta = UserInputService:GetMouseLocation() - lastCursorPosition
            end

            local intendedPosition = windowPosition + Vector2.new(
                if resizeFromLeftRight == Enum.LeftRight.Left then mouseDelta.X else 0,
                if resizeFromTopBottom == Enum.TopBottom.Top then mouseDelta.Y else 0
            )

            local intendedSize = windowSize + Vector2.new(
                if resizeFromLeftRight == Enum.LeftRight.Left then -mouseDelta.X elseif resizeFromLeftRight == Enum.LeftRight.Right then mouseDelta.X else 0,
                if resizeFromTopBottom == Enum.TopBottom.Top then -mouseDelta.Y elseif resizeFromTopBottom == Enum.TopBottom.Bottom then mouseDelta.Y else 0
            )

            local newSize = fitSizeToWindowBounds(resizeWindow, intendedSize)
            local newPosition = fitPositionToWindowBounds(resizeWindow, intendedPosition)

            resizeInstance.Size = UDim2.fromOffset(newSize.X, newSize.Y)
            resizeWindow.state.size.value = newSize
            resizeInstance.Position = UDim2.fromOffset(newPosition.X, newPosition.Y)
            resizeWindow.state.position.value = newPosition
        end

        lastCursorPosition = UserInputService:getMouseLocation()
    end)

    UserInputService.InputEnded:Connect(function(input, _)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isDragging then
            local dragInstance = dragWindow.Instance.WindowButton
            isDragging = false
            dragWindow.state.position:set(Vector2.new(dragInstance.Position.X.Offset, dragInstance.Position.Y.Offset))
        end
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isResizing then
            isResizing = false
            resizeWindow.state.size:set(resizeWindow.Instance.WindowButton.AbsoluteSize)
        end

        if input.KeyCode == Enum.KeyCode.ButtonX then
            quickSwapWindows()
        end
    end)

    Iris.WidgetConstructor("Window", {
        hasState = true,
        hasChildren = true,
        Args = {
            ["Title"] = 1,
            ["NoTitleBar"] = 2,
            ["NoBackground"] = 3,
            ["NoCollapse"] = 4,
            ["NoClose"] = 5,
            ["NoMove"] = 6,
            ["NoScrollbar"] = 7,
            ["NoResize"] = 8,
            ["NoNav"] = 9,
        },
        Events = {
            ["closed"] = {
                ["Init"] = function(thisWidget)

                end,
                ["Get"] = function(thisWidget)
                    return thisWidget.lastClosedTick == Iris._cycleTick
                end
            },
            ["opened"] = {
                ["Init"] = function(thisWidget)

                end,
                ["Get"] = function(thisWidget)
                    return thisWidget.lastOpenedTick == Iris._cycleTick
                end
            },
            ["collapsed"] = {
                ["Init"] = function(thisWidget)

                end,
                ["Get"] = function(thisWidget)
                    return thisWidget.lastCollapsedTick == Iris._cycleTick
                end
            },
            ["uncollapsed"] = {
                ["Init"] = function(thisWidget)

                end,
                ["Get"] = function(thisWidget)
                    return thisWidget.lastUncollapsedTick == Iris._cycleTick
                end
            },
            ["hovered"] = hoverEvent(function(thisWidget)
                return thisWidget.Instance.WindowButton
            end)
        },
        Generate = function(thisWidget)
            thisWidget.parentWidget = Iris._rootWidget -- only allow root as parent

            thisWidget.usesScreenGUI = Iris._config.UseScreenGUIs
            windowWidgets[thisWidget.ID] = thisWidget

            local Window
            if thisWidget.usesScreenGUI then
                Window = Instance.new("ScreenGui")
                Window.ResetOnSpawn = false
                Window.DisplayOrder = Iris._config.DisplayOrderOffset
            else
                Window = Instance.new("Folder")
            end
            Window.Name = "Iris_Window"

            local WindowButton = Instance.new("TextButton")
            WindowButton.Name = "WindowButton"
            WindowButton.BackgroundTransparency = 1
            WindowButton.BorderSizePixel = 0
            WindowButton.ZIndex = thisWidget.ZIndex + 1
            WindowButton.LayoutOrder = thisWidget.ZIndex + 1
            WindowButton.Size = UDim2.fromOffset(0, 0)
            WindowButton.AutomaticSize = Enum.AutomaticSize.None
            WindowButton.ClipsDescendants = false
            WindowButton.Text = ""
            WindowButton.AutoButtonColor = false
            WindowButton.Active = false
            WindowButton.Selectable = false
            WindowButton.SelectionImageObject = Iris.SelectionImageObject
            WindowButton.Parent = Window

            WindowButton.SelectionGroup = true
            WindowButton.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
            WindowButton.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
            WindowButton.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
            WindowButton.SelectionBehaviorRight = Enum.SelectionBehavior.Stop
            
            WindowButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Keyboard then return end
                if thisWidget.state.isUncollapsed.value then
                    Iris.SetFocusedWindow(thisWidget)
                end
                if not thisWidget.arguments.NoMove and input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragWindow = thisWidget
                    isDragging = true
                    moveDeltaCursorPosition = UserInputService:GetMouseLocation() - thisWidget.state.position.value
                end
            end)

            local uiStroke = Instance.new("UIStroke")
            uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            uiStroke.LineJoinMode = Enum.LineJoinMode.Miter
            uiStroke.Color = Iris._config.BorderColor
            uiStroke.Thickness = Iris._config.WindowBorderSize

            uiStroke.Parent = WindowButton

            local ChildContainer = Instance.new("ScrollingFrame")
            ChildContainer.Name = "ChildContainer"
            ChildContainer.Position = UDim2.fromOffset(0, 0)
            ChildContainer.BorderSizePixel = 0
            ChildContainer.ZIndex = thisWidget.ZIndex + 2
            ChildContainer.LayoutOrder = thisWidget.ZIndex + 2
            ChildContainer.AutomaticSize = Enum.AutomaticSize.None
            ChildContainer.Size = UDim2.fromScale(1, 1)
            ChildContainer.Selectable = false

            ChildContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
            ChildContainer.ScrollBarImageTransparency = Iris._config.ScrollbarGrabTransparency
            ChildContainer.ScrollBarImageColor3 = Iris._config.ScrollbarGrabColor
            ChildContainer.CanvasSize = UDim2.fromScale(0, 1)
            
            ChildContainer.BackgroundColor3 = Iris._config.WindowBgColor
            ChildContainer.BackgroundTransparency = Iris._config.WindowBgTransparency
            ChildContainer.Parent = WindowButton

            UIPadding(ChildContainer, Iris._config.WindowPadding)

            ChildContainer:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                -- "wrong" use of state here, for optimization
                thisWidget.state.scrollDistance.value = ChildContainer.CanvasPosition.Y
            end)

            ChildContainer.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Keyboard then return end
                if thisWidget.state.isUncollapsed.value then
                    Iris.SetFocusedWindow(thisWidget)
                end
            end)

            local TerminatingFrame = Instance.new("Frame")
            TerminatingFrame.Name = "TerminatingFrame"
            TerminatingFrame.BackgroundTransparency = 1
            TerminatingFrame.LayoutOrder = 0x7FFFFFF0
            TerminatingFrame.BorderSizePixel = 0
            TerminatingFrame.Size = UDim2.fromOffset(0, Iris._config.WindowPadding.Y + Iris._config.FramePadding.Y)
            TerminatingFrame.Parent = ChildContainer

            local ChildContainerUIListLayout = UIListLayout(ChildContainer, Enum.FillDirection.Vertical, UDim.new(0, Iris._config.ItemSpacing.Y))
            ChildContainerUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

            local TitleBar = Instance.new("Frame")
            TitleBar.Name = "TitleBar"
            TitleBar.BorderSizePixel = 0
            TitleBar.ZIndex = thisWidget.ZIndex + 1
            TitleBar.LayoutOrder = thisWidget.ZIndex + 1
            TitleBar.AutomaticSize = Enum.AutomaticSize.Y
            TitleBar.Size = UDim2.fromScale(1, 0)
            TitleBar.ClipsDescendants = true
            TitleBar.Parent = WindowButton

            TitleBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    if not thisWidget.arguments.NoMove then
                        dragWindow = thisWidget
                        isDragging = true
                        local location = input.Position
                        moveDeltaCursorPosition = Vector2.new(location.X, location.Y) - thisWidget.state.position.value
                    end
                end
            end)

            local TitleButtonSize = Iris._config.TextSize + ((Iris._config.FramePadding.Y - 1) * 2)

            local CollapseArrow = Instance.new("TextButton")
            CollapseArrow.Name = "CollapseArrow"
            CollapseArrow.Size = UDim2.fromOffset(TitleButtonSize,TitleButtonSize)
            CollapseArrow.Position = UDim2.new(0, Iris._config.FramePadding.X + 1, 0.5, 0)
            CollapseArrow.AnchorPoint = Vector2.new(0, 0.5)
            CollapseArrow.AutoButtonColor = false
            CollapseArrow.BackgroundTransparency = 1
            CollapseArrow.BorderSizePixel = 0
            CollapseArrow.ZIndex = thisWidget.ZIndex + 4
            CollapseArrow.AutomaticSize = Enum.AutomaticSize.None
            applyTextStyle(CollapseArrow)
            CollapseArrow.TextXAlignment = Enum.TextXAlignment.Center
            CollapseArrow.TextSize = Iris._config.TextSize
            CollapseArrow.Parent = TitleBar

            CollapseArrow.MouseButton1Click:Connect(function()
                thisWidget.state.isUncollapsed:set(not thisWidget.state.isUncollapsed.value)
            end)

            UICorner(CollapseArrow, 1e9)

            applyInteractionHighlights(CollapseArrow, CollapseArrow, {
                ButtonColor = Iris._config.ButtonColor,
                ButtonTransparency = 1,
                ButtonHoveredColor = Iris._config.ButtonHoveredColor,
                ButtonHoveredTransparency = Iris._config.ButtonHoveredTransparency,
                ButtonActiveColor = Iris._config.ButtonActiveColor,
                ButtonActiveTransparency = Iris._config.ButtonActiveTransparency,
            })

            local CloseIcon = Instance.new("TextButton")
            CloseIcon.Name = "CloseIcon"
            CloseIcon.Size = UDim2.fromOffset(TitleButtonSize, TitleButtonSize)
            CloseIcon.Position = UDim2.new(1, -(Iris._config.FramePadding.X + 1), 0.5, 0)
            CloseIcon.AnchorPoint = Vector2.new(1, 0.5)
            CloseIcon.AutoButtonColor = false
            CloseIcon.BackgroundTransparency = 1
            CloseIcon.BorderSizePixel = 0
            CloseIcon.ZIndex = thisWidget.ZIndex + 4
            CloseIcon.AutomaticSize = Enum.AutomaticSize.None
            applyTextStyle(CloseIcon)
            CloseIcon.TextXAlignment = Enum.TextXAlignment.Center
            CloseIcon.Font = Enum.Font.Code
            CloseIcon.TextSize = Iris._config.TextSize * 2
            CloseIcon.Text = ICONS.MULTIPLICATION_SIGN
            CloseIcon.Parent = TitleBar

            UICorner(CloseIcon, 1e9)

            CloseIcon.MouseButton1Click:Connect(function()
                thisWidget.state.isOpened:set(false)
            end)

            applyInteractionHighlights(CloseIcon, CloseIcon, {
                ButtonColor = Iris._config.ButtonColor,
                ButtonTransparency = 1,
                ButtonHoveredColor = Iris._config.ButtonHoveredColor,
                ButtonHoveredTransparency = Iris._config.ButtonHoveredTransparency,
                ButtonActiveColor = Iris._config.ButtonActiveColor,
                ButtonActiveTransparency = Iris._config.ButtonActiveTransparency,
            })

            -- allowing fractional titlebar title location dosent seem useful, as opposed to Enum.LeftRight.

            local Title = Instance.new("TextLabel")
            Title.Name = "Title"
            Title.BorderSizePixel = 0
            Title.BackgroundTransparency = 1
            Title.ZIndex = thisWidget.ZIndex + 3
            Title.AutomaticSize = Enum.AutomaticSize.XY
            applyTextStyle(Title)
            Title.Parent = TitleBar
            local TitleAlign
            if Iris._config.WindowTitleAlign == Enum.LeftRight.Left then
                TitleAlign = 0
            elseif Iris._config.WindowTitleAlign == Enum.LeftRight.Center then
                TitleAlign = 0.5
            else
                TitleAlign = 1
            end
            Title.Position = UDim2.fromScale(TitleAlign, 0)
            Title.AnchorPoint = Vector2.new(TitleAlign, 0)

            UIPadding(Title, Iris._config.FramePadding)

            local ResizeButtonSize = Iris._config.TextSize + Iris._config.FramePadding.X

            local ResizeGrip = Instance.new("TextButton")
            ResizeGrip.Name = "ResizeGrip"
            ResizeGrip.AnchorPoint = Vector2.new(1, 1)
            ResizeGrip.Size = UDim2.fromOffset(ResizeButtonSize, ResizeButtonSize)
            ResizeGrip.AutoButtonColor = false
            ResizeGrip.BorderSizePixel = 0
            ResizeGrip.BackgroundTransparency = 1
            ResizeGrip.Text = ICONS.BOTTOM_RIGHT_CORNER
            ResizeGrip.ZIndex = thisWidget.ZIndex + 3
            ResizeGrip.Position = UDim2.fromScale(1, 1)
            ResizeGrip.TextSize = ResizeButtonSize
            ResizeGrip.TextColor3 = Iris._config.ButtonColor
            ResizeGrip.TextTransparency = Iris._config.ButtonTransparency
            ResizeGrip.LineHeight = 1.10 -- fix mild rendering issue
            ResizeGrip.Selectable = false
            
            applyTextInteractionHighlights(ResizeGrip, ResizeGrip, {
                ButtonColor = Iris._config.ButtonColor,
                ButtonTransparency = Iris._config.ButtonTransparency,
                ButtonHoveredColor = Iris._config.ButtonHoveredColor,
                ButtonHoveredTransparency = Iris._config.ButtonHoveredTransparency,
                ButtonActiveColor = Iris._config.ButtonActiveColor,
                ButtonActiveTransparency = Iris._config.ButtonActiveTransparency,
            })

            ResizeGrip.MouseButton1Down:Connect(function()
                if not anyFocusedWindow or not (focusedWindow == thisWidget) then
                    Iris.SetFocusedWindow(thisWidget)
                    -- mitigating wrong focus when clicking on buttons inside of a window without clicking the window itself
                end
                isResizing = true
                resizeFromTopBottom = Enum.TopBottom.Bottom
                resizeFromLeftRight = Enum.LeftRight.Right
                resizeWindow = thisWidget
            end)

            local ResizeBorder = Instance.new("TextButton")
            ResizeBorder.Name = "ResizeBorder"
            ResizeBorder.BackgroundTransparency = 1
            ResizeBorder.BorderSizePixel = 0
            ResizeBorder.ZIndex = thisWidget.ZIndex
            ResizeBorder.LayoutOrder = thisWidget.ZIndex
            ResizeBorder.Size = UDim2.new(1, Iris._config.WindowResizePadding.X * 2, 1, Iris._config.WindowResizePadding.Y * 2)
            ResizeBorder.Position = UDim2.fromOffset(-Iris._config.WindowResizePadding.X, -Iris._config.WindowResizePadding.Y)
            WindowButton.AutomaticSize = Enum.AutomaticSize.None
            ResizeBorder.ClipsDescendants = false
            ResizeBorder.Text = ""
            ResizeBorder.AutoButtonColor = false
            ResizeBorder.Active = true
            ResizeBorder.Selectable = false
            ResizeBorder.Parent = WindowButton

            ResizeBorder.MouseEnter:Connect(function()
                if focusedWindow == thisWidget then
                    isInsideResize = true
                end
            end)
            ResizeBorder.MouseLeave:Connect(function()
                if focusedWindow == thisWidget then
                    isInsideResize = false
                end
            end)

            WindowButton.MouseEnter:Connect(function()
                if focusedWindow == thisWidget then
                    isInsideWindow = true
                end
            end)
            WindowButton.MouseLeave:Connect(function()
                if focusedWindow == thisWidget then
                    isInsideWindow = false
                end
            end)

            ResizeGrip.Parent = WindowButton

            return Window
        end,
        Update = function(thisWidget)
            local WindowButton = thisWidget.Instance.WindowButton
            local TitleBar = WindowButton.TitleBar
            local Title = TitleBar.Title
            local ChildContainer = WindowButton.ChildContainer
            local ResizeGrip = WindowButton.ResizeGrip
            local TitleBarWidth = Iris._config.TextSize + Iris._config.FramePadding.Y * 2

            ResizeGrip.Visible = not thisWidget.arguments.NoResize
            if thisWidget.arguments.NoScrollbar then
                ChildContainer.ScrollBarThickness = 0
            else
                ChildContainer.ScrollBarThickness = Iris._config.ScrollbarSize
            end
            if thisWidget.arguments.NoTitleBar then
                TitleBar.Visible = false
                ChildContainer.Size = UDim2.new(1, 0, 1, 0)
                ChildContainer.CanvasSize = UDim2.new(0, 0, 1, 0)
                ChildContainer.Position = UDim2.fromOffset(0, 0)
            else
                TitleBar.Visible = true
                ChildContainer.Size = UDim2.new(1, 0, 1, -TitleBarWidth)
                ChildContainer.CanvasSize = UDim2.new(0, 0, 1, -TitleBarWidth)
                ChildContainer.Position = UDim2.fromOffset(0, TitleBarWidth)
            end
            if thisWidget.arguments.NoBackground then
                ChildContainer.BackgroundTransparency = 1
            else
                ChildContainer.BackgroundTransparency = Iris._config.WindowBgTransparency
            end
            local TitleButtonPaddingSize = Iris._config.FramePadding.X + Iris._config.TextSize + Iris._config.FramePadding.X * 2
            if thisWidget.arguments.NoCollapse then
                TitleBar.CollapseArrow.Visible = false
                TitleBar.Title.UIPadding.PaddingLeft = UDim.new(0, Iris._config.FramePadding.X)
            else
                TitleBar.CollapseArrow.Visible = true
                TitleBar.Title.UIPadding.PaddingLeft = UDim.new(0, TitleButtonPaddingSize)
            end
            if thisWidget.arguments.NoClose then
                TitleBar.CloseIcon.Visible = false
                TitleBar.Title.UIPadding.PaddingRight = UDim.new(0, Iris._config.FramePadding.X)
            else
                TitleBar.CloseIcon.Visible = true
                TitleBar.Title.UIPadding.PaddingRight = UDim.new(0, TitleButtonPaddingSize)
            end

            Title.Text = thisWidget.arguments.Title or ""
        end,
        Discard = function(thisWidget)
            if focusedWindow == thisWidget then
                focusedWindow = nil
                anyFocusedWindow = false
            end
            if dragWindow == thisWidget then
                dragWindow = nil
                isDragging = false
            end
            if resizeWindow == thisWidget then
                resizeWindow = nil
                isResizing = false
            end
            windowWidgets[thisWidget.ID] = nil
            thisWidget.Instance:Destroy()
            discardState(thisWidget)
        end,
        ChildAdded = function(thisWidget)
            return thisWidget.Instance.WindowButton.ChildContainer
        end,
        UpdateState = function(thisWidget)
            local stateSize = thisWidget.state.size.value
            local statePosition = thisWidget.state.position.value
            local stateIsUncollapsed = thisWidget.state.isUncollapsed.value
            local stateIsOpened = thisWidget.state.isOpened.value
            local stateScrollDistance = thisWidget.state.scrollDistance.value

            local WindowButton = thisWidget.Instance.WindowButton

            WindowButton.Size = UDim2.fromOffset(stateSize.X, stateSize.Y)
            WindowButton.Position = UDim2.fromOffset(statePosition.X, statePosition.Y)

            local TitleBar = WindowButton.TitleBar
            local ChildContainer = WindowButton.ChildContainer
            local ResizeGrip = WindowButton.ResizeGrip

            if stateIsOpened then
                if thisWidget.usesScreenGUI then
                    thisWidget.Instance.Enabled = true
                    WindowButton.Visible = true
                else
                    WindowButton.Visible = true
                end
                thisWidget.lastOpenedTick = Iris._cycleTick + 1
            else
                if thisWidget.usesScreenGUI then
                    thisWidget.Instance.Enabled = false
                    WindowButton.Visible = false
                else
                    WindowButton.Visible = false
                end
                thisWidget.lastClosedTick = Iris._cycleTick + 1
            end

            if stateIsUncollapsed then
                TitleBar.CollapseArrow.Text = ICONS.DOWN_POINTING_TRIANGLE
                ChildContainer.Visible = true
                if thisWidget.arguments.NoResize == false then
                    ResizeGrip.Visible = true
                end
                WindowButton.AutomaticSize = Enum.AutomaticSize.None
                thisWidget.lastUncollapsedTick = Iris._cycleTick + 1
            else
                local collapsedHeight = Iris._config.TextSize + Iris._config.FramePadding.Y * 2
                TitleBar.CollapseArrow.Text = ICONS.RIGHT_POINTING_TRIANGLE

                ChildContainer.Visible = false
                ResizeGrip.Visible = false
                WindowButton.Size = UDim2.fromOffset(stateSize.X, collapsedHeight)
                thisWidget.lastCollapsedTick = Iris._cycleTick + 1
            end

            if stateIsOpened and stateIsUncollapsed then
                Iris.SetFocusedWindow(thisWidget)
            else
                TitleBar.BackgroundColor3 = Iris._config.TitleBgCollapsedColor
                TitleBar.BackgroundTransparency = Iris._config.TitleBgCollapsedTransparency
                WindowButton.UIStroke.Color = Iris._config.BorderColor

                Iris.SetFocusedWindow(nil)
            end

            -- cant update canvasPosition in this cycle because scrollingframe isint ready to be changed
            if stateScrollDistance and stateScrollDistance ~= 0 then
                local callbackIndex = #Iris._postCycleCallbacks + 1
                local desiredCycleTick = Iris._cycleTick + 1
                Iris._postCycleCallbacks[callbackIndex] = function()
                    if Iris._cycleTick == desiredCycleTick then
                        ChildContainer.CanvasPosition = Vector2.new(0, stateScrollDistance)
                        Iris._postCycleCallbacks[callbackIndex] = nil
                    end
                end
            end
        end,
        GenerateState = function(thisWidget)
            if thisWidget.state.size == nil then
                thisWidget.state.size = Iris._widgetState(thisWidget, "size", Vector2.new(400, 300))
            end
            if thisWidget.state.position == nil then
                thisWidget.state.position = Iris._widgetState(
                    thisWidget,
                    "position",
                    if anyFocusedWindow then focusedWindow.state.position.value + Vector2.new(15, 45) else Vector2.new(150, 250)
                )
            end
            thisWidget.state.position.value = fitPositionToWindowBounds(thisWidget, thisWidget.state.position.value)
            thisWidget.state.size.value = fitSizeToWindowBounds(thisWidget, thisWidget.state.size.value)

            if thisWidget.state.isUncollapsed == nil then
                thisWidget.state.isUncollapsed = Iris._widgetState(thisWidget, "isUncollapsed", true)
            end
            if thisWidget.state.isOpened == nil then
                thisWidget.state.isOpened = Iris._widgetState(thisWidget, "isOpened", true)
            end
            if thisWidget.state.scrollDistance == nil then
                thisWidget.state.scrollDistance = Iris._widgetState(thisWidget, "scrollDistance", 0)
            end
        end
    })
end

end