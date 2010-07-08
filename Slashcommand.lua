
local myname, ns = ...


_G["SLASH_".. myname:upper().."1"] = GetAddOnMetadata(myname, "X-LoadOn-Slash")
SlashCmdList[myname:upper()] = function(msg)
  if msg ~= "" then
    ns.dbpc.recipient = msg
    ns.Print("Now mailing BOE greens to " .. msg .. ".")
  end
end
