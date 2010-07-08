
local myname, ns = ...


local myfullname = GetAddOnMetadata(myname, "Title")
function ns.Print(...) print("|cFF33FF99".. myfullname.. "|r:", ...) end

local debugf = tekDebug and tekDebug:GetFrame(myname)
function ns.Debug(...) if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end end

-- Should return the numeric value (or 0) for characters Enchanting skill level
function ns.GetEnchantingSkill()
  local skill, reSearch = 0, true

  while reSearch do
    reSearch = false
    for i=1,GetNumSkillLines() do
      local name, header, expanded, rank = GetSkillLineInfo(i)
      if name == "Enchanting" then
        skill = rank
        break
      elseif header and not expanded then
        ExpandSkillHeader(i)
        reSearch = true
        break
      end
    end
  end

  return skill
end

-- Currently only valid for Uncommon items
function ns.GetHighestDisenchantLevel()
  local skill = ns.GetEnchantingSkill()
  if skill == 0 then return 0
  elseif skill >= 350 then return 182
  elseif skill >= 325 then return 150
  elseif skill >= 275 then return 120
  elseif skill >= 225 then return 99
  elseif skill >= 200 then return 60
  elseif skill >= 175 then return 55
  elseif skill >= 150 then return 50
  elseif skill >= 125 then return 45
  elseif skill >= 100 then return 40
  elseif skill >= 75 then return 35
  elseif skill >= 50 then return 30
  elseif skill >= 25 then return 25
  elseif skill >= 1 then return 20
  end
end