
local myname, ns = ...


_G["SLASH_".. myname:upper().."1"] = GetAddOnMetadata(myname, "X-LoadOn-Slash")
SlashCmdList[myname:upper()] = function(msg)
  if msg ~= "" then
    ns.dbpc.recipient = msg
    self.Print("Now mailing BOE greens to " .. recipient .. ".")
  end
end
