-- // Chat Utility (can be used for UIs)
-- // Written by: Xsitsu, TheGamer101

local TextService = game:GetService("TextService")

local methods = {}

function methods:GetStringTextBounds(text: string, font: Font, textSize: number, width: number?)
	width = width or workspace.CurrentCamera.ViewportSize.X

	local parameters = Instance.new('GetTextBoundsParams')
	parameters.Text = text
	parameters.Font = font
	parameters.Size = textSize
	parameters.Width = width

	local size = TextService:GetTextBoundsAsync(parameters)
	size = Vector2.new(math.round(size.X), math.round(size.Y))

	return size
end
--// Above was taken directly from Util.GetStringTextBounds() in the old chat corescripts.

function methods:GetMessageHeight(BaseMessage: TextLabel, BaseFrame: GuiObject, xSize: number?)
	xSize = xSize or BaseFrame.AbsoluteSize.X
	local textBoundsSize = self:GetStringTextBounds(BaseMessage.Text, BaseMessage.Font, BaseMessage.TextSize, xSize)
	if textBoundsSize.Y ~= math.floor(textBoundsSize.Y) then
		-- HACK Alert. TODO: Remove this when we switch UDim2 to use float Offsets
		-- This is nessary due to rounding issues on mobile devices when translating between screen pixels and native pixels
		return textBoundsSize.Y + 1
	end
	return textBoundsSize.Y
end

function methods:GetNumberOfSpaces(str: string, font: Font, textSize: number)
	local strSize = self:GetStringTextBounds(str, font, textSize)
	local singleSpaceSize = self:GetStringTextBounds(" ", font, textSize)
	return math.ceil(strSize.X / singleSpaceSize.X)
end

return methods