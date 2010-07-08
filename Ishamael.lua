
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
	self.dbpc.warned = nil
	self:FlushDB()
	-- Do anything you need to do as the player logs out
end


function ns:MAIL_SHOW()
	if self.dbpc.recipient then
		self:MailUndisenchantableItems(self.dbpc.recipient)
	elseif not self.dbpc.warned then
		self.Print("Ishamael doesn't have a recipient yet!\nSet one with \"/ishamael <recipient>\"")
		self.dbpc.warned = true
	end
end


function ns:GetUnDisenchantableItems()
  local items, maxLevel = {}, self.GetHighestDisenchantLevel()
	self.Debug("Max ilevel can disenchant: " .. maxLevel)
  for bagId=1,NUM_BAG_SLOTS do
    items[bagId] = {}
    for slotId=1,GetContainerNumSlots(bagId) do
      local link = GetContainerItemLink(bagId, slotId)
			if link then
				local _, _, quality, itemLevel, _, itemType = GetItemInfo(link)
				if (quality == 2 and itemLevel > maxLevel and (itemType == "Armor" or itemType == "Weapon") and link_FindSearchInTooltip(link, ITEM_BIND_ON_EQUIP)) then
					self.Print("BOE Green found: " .. link)
					tinsert(items[bagId], slotId)
				end
			end
    end
  end
  return items
end


function ns:MailUndisenchantableItems(target)
	if not target then return end
  local attachments, items = 0, self:GetUnDisenchantableItems()
  for bagId, itemIds in pairs(items) do
    while #(itemIds) > 0 do
      local itemId = tremove(itemIds)
      PickupContainerItem(bagId, itemId)
      attachments = attachments + 1
      ClickSendMailItemButton(attachments)
      if attachments >= ATTACHMENTS_MAX_SEND and GetMoney() > GetSendMailPrice() then
				self.Print("Mailing " .. attachments .. " items to your recipient.")
				self.Debug(target)
        SendMail(target, "Disenchantable greens", "Please find attached 1 or more Uncommon items that can be disenchanted for materials.\n\nThanks.")
        attachments = 0
				return
      end
    end
  end
	if attachments > 0 then
		self.Print("Mailing " .. attachments .. " items to your recipient.")
		self.Debug(target)
		SendMail(target, "Disenchantable greens", "Please find attached 1 or more Uncommon items that can be disenchanted for materials.\n\nThanks.")
	end
end

-- All of the below was borrowed from LibItemSearch-1.0 included with BagSync 3.6 by Derkyle
-- http://wow.curseforge.com/addons/bagsync/

local tooltipCache = setmetatable({}, {__index = function(t, k) local v = {} t[k] = v return v end})
local tooltipScanner = _G['LibItemSearchTooltipScanner'] or CreateFrame('GameTooltip', 'LibItemSearchTooltipScanner', UIParent, 'GameTooltipTemplate')

local function link_FindSearchInTooltip(itemLink, search)
	--look in the cache for the result
	local itemID = itemLink:match('item:(%d+)')
	local cachedResult = tooltipCache[search][itemID]
	if cachedResult ~= nil then
		return cachedResult
	end

	--no match?, pull in the resut from tooltip parsing
	tooltipScanner:SetOwner(UIParent, 'ANCHOR_NONE')
	tooltipScanner:SetHyperlink(itemLink)

	local result = false
	if tooltipScanner:NumLines() > 1 and _G[tooltipScanner:GetName() .. 'TextLeft2']:GetText() == search then
		result = true
	elseif tooltipScanner:NumLines() > 2 and _G[tooltipScanner:GetName() .. 'TextLeft3']:GetText() == search then
		result = true
	end
	tooltipScanner:Hide()

	tooltipCache[search][itemID] = result
	return result
end