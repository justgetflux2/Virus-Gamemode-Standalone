GM.Name = "Virus"
GM.Author = "Raphy"

VIRUS = {};
VIRUS.RequiredPlayers = 1;  //Required players to start the game
VIRUS.DebugMode = 2;        //Debug mode. Enable for debugging, different informations will print in Server and Client console. (1= No loop debug. 2= Loop Debug)
VIRUS.StandbyTime = 10      //Standby time until the round begins. (In seconds)
VIRUS.RoundTime = 120       //Round time. (In seconds)
VIRUS.ResultsTime = 10;     //Results time. (In seconds)

function PrintDebug(msg, lvl)
    if(VIRUS.DebugMode >= lvl) then
        print("[DEBUG LV." .. lvl .."]" .. msg);
    end
end