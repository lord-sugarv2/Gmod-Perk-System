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