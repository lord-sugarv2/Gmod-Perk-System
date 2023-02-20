function LPerks:GetLevel(steamid)
    local data = sql.Query("SELECT * FROM LPerksLevel WHERE steamid = "..sql.SQLStr(steamid)..";")
    return data and tonumber(data[1].level) or 1
end

function LPerks:GetXP(steamid)
    local data = sql.Query("SELECT * FROM LPerksLevel WHERE steamid = "..sql.SQLStr(steamid)..";")
    return data and tonumber(data[1].xp) or 0
end

function LPerks:AddLevel(steamid)
    local data = sql.Query("SELECT * FROM LPerksLevel WHERE steamid = "..sql.SQLStr(steamid)..";")
	if data then
        local level = LPerks:GetLevel(steamid)+1
		sql.Query("UPDATE LPerksLevel SET level = "..level.." WHERE steamid = "..sql.SQLStr(steamid)..";")
    else
		sql.Query("INSERT INTO LPerksLevel (steamid, level, xp) VALUES("..sql.SQLStr(steamid)..", 1, 0)")
	end
    LPerks:AddPerkPoints(steamid, 1)

    local ply = player.GetBySteamID(steamid)
    if not IsValid(ply) then return end
    ply:SetNWInt("LPerks:Level", LPerks:GetLevel(steamid))
end

function LPerks:AddXP(steamid, amount)
    local data = sql.Query("SELECT * FROM LPerksLevel WHERE steamid = "..sql.SQLStr(steamid)..";")
	if data then
        local add = LPerks:GetXP(steamid)+amount
        local nextlvlxp = LPerks.AddXPLevel*LPerks:GetLevel(steamid)
		sql.Query("UPDATE LPerksLevel SET xp = "..math.min(nextlvlxp, add).." WHERE steamid = "..sql.SQLStr(steamid)..";")
        if add >= nextlvlxp then
            -- we have flowover
            sql.Query("UPDATE LPerksLevel SET xp = 0 WHERE steamid = "..sql.SQLStr(steamid)..";")

            LPerks:AddLevel(steamid)
            LPerks:AddXP(steamid, add-nextlvlxp)
        end
    else
		sql.Query("INSERT INTO LPerksLevel (steamid, level, xp) VALUES("..sql.SQLStr(steamid)..", 1, "..amount..")")
        local add = LPerks:GetXP(steamid)+amount
        local nextlvlxp = LPerks.AddXPLevel*LPerks:GetLevel(steamid)
        if addxp >= nextlvlxp then
            -- we have flowover
            LPerks:AddLevel(steamid)
            LPerks:AddXP(steamid, addxp-nextlvlxp)
        end
	end

    local ply = player.GetBySteamID(steamid)
    if not IsValid(ply) then return end
    ply:SetNWInt("LPerks:XP", LPerks:GetXP(steamid))
end