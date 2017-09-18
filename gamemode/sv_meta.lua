local PLAYER = FindMetaTable("Player");

function PLAYER:GetVirusClass()
    return player_manager.GetPlayerClass(self)
end

function PLAYER:IsInfected()
    if(self:GetVirusClass() == "player_infected") then
        return true;
    else
        return false;
    end
end

function PLAYER:IsSurvivor()
    if(self:GetVirusClass() == "player_survivor") then
        return true;
    else
        return false;
    end
end

function PLAYER:IsNeutral()
    if(self:GetVirusClass() == "player_neutral") then
        return true;
    else
        return false;
    end
end

function PLAYER:IsSpectator()
    if(self:GetVirusClass() == "player_spectator") then
        return true;
    else
        return false;
    end
end