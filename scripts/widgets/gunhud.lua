local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"


local gunhud = Class(Widget, function(self, owner)
	Widget._ctor(self, "gunhud")
	self.owner = owner
	self:SetPosition(0, 0, 0)
	self:SetScale(1,1,1)
	self:SetClickable(false)

	self.bg = self:AddChild(Image(HUD_ATLAS, "inventory_bg.tex"))
	self.bg:SetPosition(-1156, 0)
	self.bg:SetScale(0.25,1,1)	
	
	self.slot = self.bg:AddChild(Image(HUD_ATLAS, "inv_slot.tex"))
	self.slot2 = self.bg:AddChild(Image(HUD_ATLAS, "inv_slot.tex"))
	self.slot:SetPosition(-480, 64)
	self.slot2:SetPosition(-240, 48)
	self.slot:SetScale(4, 1, 1)
	self.slot2:SetScale(2, 0.5, 0.5)
	
	self.gun = self.slot:AddChild(Image())
	self.gun:SetScale(1, 1, 1)
	self.gun:MoveToFront()
	
	self.reload = self.slot:AddChild(Image())
	self.reload:SetScale(1, 1, 1)
	self.reload:MoveToFront()
	
	self.mode = self.slot2:AddChild(Image())
	self.mode:MoveToFront()
	
	self.name = self.bg:AddChild(Text(BODYTEXTFONT, 40))
	self.name:SetHAlign(ANCHOR_MIDDLE)
	self.name:SetVAlign(ANCHOR_TOP)
	self.name:SetPosition(160, 84)
	self.name:SetScale(4, 1, 1)
	self.name:MoveToFront()
	
	self.num = self.bg:AddChild(Text(BODYTEXTFONT, 28))
	self.num:SetHAlign(ANCHOR_MIDDLE)
	self.num:SetVAlign(ANCHOR_TOP)
	self.num:SetPosition(180, 48)
	self.num:SetScale(4, 1, 1)
	self.num:MoveToFront()
	
	self:StartUpdating()
	self:Hide()

end)

function gunhud:OnUpdate(dt)
	local inv = self.owner.replica.inventory
	local obj = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
	local gunutils = obj and obj.replica.gunutils
	if gunutils ~= nil then
		local str = gunutils._current:value().."/"..gunutils._max:value()
		self.num:SetString(str)
		self.name:SetString(obj.name)
		self.gun:SetTexture(obj.replica.inventoryitem:GetAtlas(), obj.replica.inventoryitem:GetImage())
		if gunutils:GetHudAtlas(gunutils._selector:value()) ~= "" then
			self.mode:SetTexture(gunutils:GetHudAtlas(gunutils._selector:value()), gunutils:GetHudImage(gunutils._selector:value()))
			self.slot2:Show()
			self.mode:Show()
		else
			self.mode:Hide()
			self.slot2:Hide()
		end
		if gunutils:GetHudAtlas(4) ~= "" and self.reload.tex ~= gunutils:GetHudImage(4) then
			self.reload:SetTexture(gunutils:GetHudAtlas(4), gunutils:GetHudImage(4))
		end
		if gunutils._reloading:value() then
			self.reload:Show()
		else
			self.reload:Hide()
		end

		self:Show()
	else
		self:Hide()
	end
end

return gunhud