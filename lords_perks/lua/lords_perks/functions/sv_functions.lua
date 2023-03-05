util.AddNetworkString("LPerks:PurchasePerk")
net.Receive("LPerks:PurchasePerk", function(len, ply)
    local id = net.ReadString()
    if LPerks:GetPerkAmount(id, ply:SteamID()) >= LPerks.Perks[id].Amount then DarkRP.notify(ply, 1, 3, "Already maxed") return end
    if LPerks:GetPerkPoints(ply:SteamID()) < 1 then DarkRP.notify(ply, 1, 3, "You cannot afford this") return end
    LPerks:AddPerk(id, ply:SteamID())
    LPerks:AddPerkPoints(ply:SteamID(), -1)
    DarkRP.notify(ply, 1, 3, "Successfully purchased!")
    LPerks.Perks[id].OnBuy(ply)
end)

util.AddNetworkString("LPerks:NetworkPerks")
hook.Add("PlayerInitialSpawn", "LPerks:PlayerJoined", function(ply)
    local data = sql.Query("SELECT * FROM LPerks WHERE steamid = "..sql.SQLStr(ply:SteamID())..";")
    net.Start("LPerks:NetworkPerks")
    net.WriteUInt(LPerks:GetPerkPoints(ply:SteamID()), 32)
    net.WriteBool(data and true or false)
    if data then
        net.WriteUInt(#data, 32)
        for k, v in ipairs(data) do
            net.WriteString(v.id)
            net.WriteUInt(v.amount, 32)
        end
        net.Send(ply)
    end

    ply:SetNWInt("LPerks:XP", LPerks:GetXP(ply:SteamID()))
    ply:SetNWInt("LPerks:Level", LPerks:GetLevel(ply:SteamID()))
end)

-- Thanks to king_of_the_squirt#0667
function AddXPCommand(ply, text, teamChat)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    local args = string.Split(text, " ")
    if #args ~= 3 or args[1] ~= "!addxp" then return end
    local target = nil

    for _, v in ipairs(player.GetAll()) do
        if v:SteamID() == args[2] or v:Nick() == args[2] then
            target = v
            break
        end
    end

    if not IsValid(target) then return end
    local amount = tonumber(args[3]) or 0
    Perks:AddXP(target:SteamID(), amount)
end

hook.Add("PlayerSay", "AddXPCommand", AddXPCommand)
