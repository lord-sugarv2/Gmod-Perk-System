function LPerks:CreateDatabase()
    sql.Query("CREATE TABLE IF NOT EXISTS LPerks (id TEXT, steamid TEXT, amount INTEGER)")
    sql.Query("CREATE TABLE IF NOT EXISTS LPerkPoints (steamid TEXT, amount INTEGER)")
    sql.Query("CREATE TABLE IF NOT EXISTS LPerksLevel (steamid TEXT, level INTEGER, xp INTEGER)")
end
LPerks:CreateDatabase()

function LPerks:GetPerkAmount(id, steamid)
    local data = sql.Query("SELECT * FROM LPerks WHERE steamid = "..sql.SQLStr(steamid).." AND id = "..sql.SQLStr(id)..";")
    return data and tonumber(data[1].amount) or 0
end

util.AddNetworkString("LPerks:NetworkChange")
function LPerks:AddPerk(id, steamid)
    local data = sql.Query("SELECT * FROM LPerks WHERE steamid = "..sql.SQLStr(steamid).." AND id = "..sql.SQLStr(id)..";")
	if data then
		sql.Query("UPDATE LPerks SET amount = "..(math.min(LPerks:GetPerkAmount(id, steamid)+1, LPerks.Perks[id].Amount)).." WHERE steamid = "..sql.SQLStr(steamid).." AND id = "..sql.SQLStr(id)..";")
	else
		sql.Query("INSERT INTO LPerks (id, steamid, amount) VALUES("..sql.SQLStr(id)..", "..sql.SQLStr(steamid)..", 1)")
	end

    local ply = player.GetBySteamID(steamid)
    if not IsValid(ply) then return end

    net.Start("LPerks:NetworkChange")
    net.WriteString(id)
    net.WriteUInt(LPerks:GetPerkAmount(id, steamid), 32)
    net.Send(ply)
end

function LPerks:RemovePerk(id, steamid)
    local data = sql.Query("SELECT * FROM LPerks WHERE steamid = "..sql.SQLStr(steamid).." AND id = "..sql.SQLStr(id)..";")
	if not data then return end
	sql.Query("UPDATE LPerks SET amount = "..(math.max(LPerks:GetPerkAmount(id, steamid)-1, 0)).." WHERE steamid = "..sql.SQLStr(steamid).." AND id = "..sql.SQLStr(id)..";")

    local ply = player.GetBySteamID(steamid)
    if not IsValid(ply) then return end

    net.Start("LPerks:NetworkChange")
    net.WriteString(id)
    net.WriteUInt(LPerks:GetPerkAmount(id, steamid), 32)
    net.Send(ply)
end

function LPerks:GetPerkPoints(steamid)
    local data = sql.Query("SELECT * FROM LPerkPoints WHERE steamid = "..sql.SQLStr(steamid)..";")
    return data and tonumber(data[1].amount) or 0
end

util.AddNetworkString("LPerks:PerkPointsChange")
function LPerks:AddPerkPoints(steamid, amt)
    local data = sql.Query("SELECT * FROM LPerkPoints WHERE steamid = "..sql.SQLStr(steamid)..";")
	if data then
        local amount = LPerks:GetPerkPoints(steamid) + amt
		sql.Query("UPDATE LPerkPoints SET amount = "..(math.max(amount, 0)).." WHERE steamid = "..sql.SQLStr(steamid)..";")
	else
		sql.Query("INSERT INTO LPerkPoints (steamid, amount) VALUES("..sql.SQLStr(steamid)..", "..amt..")")
	end

    local ply = player.GetBySteamID(steamid)
    if not IsValid(ply) then return end

    net.Start("LPerks:PerkPointsChange")
    net.WriteUInt(LPerks:GetPerkPoints(steamid), 32)
    net.Send(ply)
end