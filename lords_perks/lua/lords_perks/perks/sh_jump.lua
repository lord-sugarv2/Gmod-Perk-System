local PERK = {}
PERK.ID = "jump"
PERK.Name = "Jump"
PERK.Description = "Increases jump height."
PERK.Amount = 5
PERK.Icon = "Rqlc59F"
PERK.OnBuy = function(ply)
    local amount = LPerks:GetPerkAmount(PERK.ID, ply:SteamID())
    if amount == 0 then return end
    ply:SetJumpPower(ply:GetJumpPower()+(amount*100))
end

LPerks.Perks[PERK.ID] = PERK

hook.Add("PlayerSpawn", "LPerks:PlayerJump", function(ply)
    PERK.OnBuy(ply)
end)