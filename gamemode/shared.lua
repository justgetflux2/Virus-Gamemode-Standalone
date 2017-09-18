GM.Name = "Virus"
GM.Author = "Raphy"

VIRUS = {};
VIRUS.RequiredPlayers = 1;  //Required players to start the game
VIRUS.DebugMode = 2;        //Debug mode. Enable for debugging, different informations will print in Server and Client console. (1= No loop debug. 2= Loop Debug)
VIRUS.StandbyTime = 10      //Standby time until the round begins. (In seconds)
VIRUS.RoundTime = 10       //Round time. (In seconds)
VIRUS.ResultsTime = 10;     //Results time. (In seconds)

function PrintDebug(msg, lvl)
    if(VIRUS.DebugMode >= lvl) then
        print("[DEBUG LV." .. lvl .."]" .. msg);
        PrintMessage( HUD_PRINTTALK, "[DEBUG LV." .. lvl .."]" .. msg)
    end
end

function VirusShouldCollide(ent1, ent2)
    if(ent1:IsPlayer()&&ent2:IsPlayer()) then
        if(ent1:IsInfected() && ent2:IsSurvivor()) then
            if(table.HasValue(ents.FindInSphere(ent2:GetPos(), 30), ent1)) then
                print("INFECTION");
            end
        elseif(ent1:IsSurvivor() && ent2:IsInfected())then
            if(table.HasValue(ents.FindInSphere(ent1:GetPos(), 30), ent2)) then
                print("INFECTION");
            end
        end
    end
    return true;
end
hook.Add("ShouldCollide", "VirusShouldCollideHook", VirusShouldCollide);