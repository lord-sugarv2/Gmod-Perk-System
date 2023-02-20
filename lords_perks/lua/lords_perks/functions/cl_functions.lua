LPerks.PerkPoints = LPerks.PerkPoints or 0
LPerks.PlayerPerks = LPerks.PlayerPerks or {}
net.Receive("LPerks:NetworkPerks", function()
    LPerks.PerkPoints = net.ReadUInt(32)
    local bool = net.ReadBool()
    if bool then
        local int = net.ReadUInt(32)
        for i = 1, int do
            LPerks.PlayerPerks[net.ReadString()] = net.ReadUInt(32)
        end
    end
end)

net.Receive("LPerks:NetworkChange", function()
    local id, amount = net.ReadString(), net.ReadUInt(32)
    LPerks.PlayerPerks[id] = amount
end)

net.Receive("LPerks:PerkPointsChange", function()
    LPerks.PerkPoints = net.ReadUInt(32)
end)

function LPerks:OpenMenu()
    if IsValid(LPerks.Menu) then LPerks.Menu:Remove() end
    LPerks.Menu = vgui.Create("PIXEL.Frame")
    LPerks.Menu:SetTitle("Perk Points: "..LocalPlayer():GetNWInt("LPerks:PerkPoints"))
    LPerks.Menu:MakePopup()
	LPerks.Menu:SetSize(800, 500)
    LPerks.Menu:Center()
    LPerks.Menu.Think = function(s)
        s:SetTitle("Perk Points: "..LPerks.PerkPoints)
    end

    local panel = LPerks.Menu:Add("LPerks:PerkMenu")
    panel:Dock(FILL)
end

function LPerks:GetXP()
    return LocalPlayer():GetNWInt("LPerks:XP") or 0
end

function LPerks:NextLevelXP()
    return LPerks:GetLevel()*LPerks.AddXPLevel
end

function LPerks:GetLevel()
    return LocalPlayer():GetNWInt("LPerks:Level") == 0 and 1 or LocalPlayer():GetNWInt("LPerks:Level")
end

concommand.Add("lords_perks", function()
    LPerks:OpenMenu()
end)

hook.Add("HUDPaint", "LPerks:PerkBar", function()
    local w, h = ScrW(), ScrH()
    local w2, h2 = ScrW() * .75, 20
    local x, y = (w/2)-(w2/2), 20

    local percentage = (LPerks:GetXP()/LPerks:NextLevelXP())*100
    percentage = math.Round(percentage)
    draw.SimpleTextOutlined(LPerks:GetXP().."XP / "..LPerks:NextLevelXP().."XP [ "..(percentage).."% ]", PIXEL.GetRealFont("LPerks:20"), w/2, 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)

    surface.SetDrawColor(PIXEL.Colors.Background)
    surface.DrawRect(x, y, w2, h2)

    local neww = w2-8
    neww = (neww/LPerks:NextLevelXP())*LPerks:GetXP()
    surface.SetDrawColor(PIXEL.Colors.Primary)
    surface.DrawRect(x+4, y+4, neww, h2-8)

    draw.SimpleTextOutlined(LPerks:GetLevel(), PIXEL.GetRealFont("LPerks:20"), x-5, y+(h2/2), color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, color_black)
    draw.SimpleTextOutlined(LPerks:GetLevel()+1, PIXEL.GetRealFont("LPerks:20"), x+w2+5, y+(h2/2), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black)
end)