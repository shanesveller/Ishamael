
local myname, ns = ...

local ItemSearch = LibStub:GetLibrary("LibItemSearch-1.0")

ns:RegisterEvent("ADDON_LOADED")
function ns:ADDON_LOADED(event, addon)
	if addon ~= myname then return end
	self:InitDB()

	-- Do anything you need to do after addon has loaded

	LibStub("tekKonfig-AboutPanel").new(myfullname, myname) -- Make first arg nil if no parent config panel

	self:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil

	if IsLoggedIn() then self:PLAYER_LOGIN() else self:RegisterEvent("PLAYER_LOGIN") end
end


function ns:PLAYER_LOGIN()
	self:RegisterEvent("PLAYER_LOGOUT")
	self:RegisterEvents("MAIL_SHOW","MAIL_CLOSED")

	-- Do anything you need to do after the player has entered the world

	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end


function ns:PLAYER_LOGOUT()
	self:FlushDB()
	-- Do anything you need to do as the player logs out
end


function ns:MAIL_SHOW()
  self:MailUndisenchantableItems(self.dbpc.recipient)
end


function ns:GetUnDisenchantableItems()
  local items, maxLevel = {}, self.GetHighestDisenchantLevel()
  for bagId=1,NUM_BAG_SLOTS do
    items[bagId] = {}
    for slotId=1,GetContainerNumSlots(bagId) do
      local link = GetContainerItemLink(bagId, slotId)
      local _, _, quality, itemLevel, _, itemType = GetItemInfo(link)
      if (quality == 2 and itemLevel > maxLevel and (itemType == "Armor" or itemType == "Weapon") and ItemSearch:Find(link, "boe")) then
        self.Print("BOE Green found: " .. link)
        tinsert(items[bagId], slotId)
      end
    end
  end
  return items
end


function ns:MailUndisenchantableItems(recipient)
  local attachments, items = 0, self:GetUnDisenchantableItems()
  ClearSendMail()
  for bagId, itemIds in pairs(items) do
    while #(itemIds) > 0 do
      local itemId = tremove(itemIds)
      PickupContainerItem(bagId, itemId)
      attachments = attachments + 1
      ClickSendMailItemButton(attachments)
      if attachments >= ATTACHMENTS_MAX_SEND and GetMoney() > GetSendMailPrice() then
        SendMail(recipient, "Disenchantable greens", "Please find attached 1 or more Uncommon items that can be disenchanted for materials.\n\nThanks.")
        attachments = 0
      end
    end
  end
end


Ishamael = ns