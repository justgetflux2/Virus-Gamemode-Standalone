//Round states
WAITING_FOR_PLAYERS = 0;
STANDBY = 1;
IN_PROGRESS = 2;
LAST_SURVIVOR = 3;
ENDING = 4;

ROUND_STATE = WAITING_FOR_PLAYERS; // Default round state whenever the gamemode is initialized (Don't change it tbh)

FIRST_INFECTED = nil;

module("Round", package.seeall);

function GetState()
    return ROUND_STATE
end

//Start the round in standby mode.
function Start()
    //Check if the game is in a state where it's logical to start a new round
    if(ROUND_STATE == WAITING_FOR_PLAYERS || ROUND_STATE == ENDING) then
        PrintDebug("Round started, standby mode.", 1);
        ROUND_STATE = STANDBY;
        //Start the round here
        //Silently killing everyone and respawning them as a neutral player.
        PrintDebug("Setting everyone as neutral, killing them, and respawning them. Loop starting", 1)
        for k,v in pairs(player.GetAll()) do
            player_manager.SetPlayerClass(v, "player_neutral");
            v:KillSilent();
            v:Spawn();
            PrintDebug(v:Name() .. " done.", 2)
        end
        PrintDebug("Loop done", 1);

        hook.Call("VirusRoundStarted");

        //Letting players walk around until standby mode is over
        if(timer.Exists("VirusStandbyTimer")) then
            timer.Start("VirusStandbyTimer");
        else
            timer.Create("VirusStandbyTimer", VIRUS.StandbyTime, 1, function()
                PrintDebug("Beginning new round", 1);
                Begin();
            end)
        end
    else
        print("WARNING : A round start has been triggered while the current state was in standby or progress. Check your code!")
    end
end

//Begin the round with a random infected
function Begin()
    //Checking state to prevent errors
    if(ROUND_STATE == STANDBY) then
        //Pick a random neutral as our first infected.
        local neutrals = {};
        PrintDebug("Retrieving neutrals. Starting loop.", 1)
        for k,v in pairs(player.GetAll()) do
            PrintDebug("Checking " .. v:Name() .. "...", 2)
            if(player_manager.GetPlayerClass(v) == "player_neutral") then
                PrintDebug("Adding " .. v:Name(), 2)
                table.insert(neutrals, v);
            end
        end
        PrintDebug("Loop over. " .. table.Count(neutrals) .. " found.", 1)

        //Set the randomly chosen as our first infected
        local firstInfected = table.Random(neutrals);
        PrintDebug(firstInfected:Name() .. " is the first infected. Setting to infected class.", 1);
        player_manager.SetPlayerClass(firstInfected, "player_infected");
        FIRST_INFECTED = firstInfected;

        //Set everyone else as survivors
        PrintDebug("Setting everyone else as survivors. Starting loop", 1)
        for k,v in pairs(player.GetAll()) do
            PrintDebug("Checking " .. v:Name(), 2);
            if(FIRST_INFECTED != v) then
                PrintDebug("Setting " .. v:Name() .. " as a survivor", 2);
                player_manager.SetPlayerClass(v, "player_survivor");
            end
        end
        PrintDebug("Loop done", 1);
        ROUND_STATE = IN_PROGRESS;
        
        hook.Call("VirusRoundBegan");

        //Start the round timer.
        //TODO: Right now, it's a serverside timer, we want to send a net message to everyone so clients can start counting down as well (Server will be counting, but clients should be counting as well)
        if(timer.Exists("VirusRoundTimer")) then
            timer.Start("VirusRoundTimer");
        else
            timer.Create("VirusRoundTimer", VIRUS.RoundTime, 1, function()
                Finish();
            end)
        end

        //At this point, we should have infected and survivors, so we're just going to wait until the round is over or whatever.
    else
        print("WARNING : A round has tried to begin while the current state wasn't Standby. Check your code!")
    end
end

//Finish the current round and switch to the results. (Finishing a round just end the fight between survivors and infected)
function Finish()
    //Check current state to prevent errors
    if(ROUND_STATE == IN_PROGRESS || ROUND_STATE == LAST_SURVIVOR) then
        PrintDebug("Round finished. Showing results.", 1);
        timer.Stop("VirusRoundTimer")
        //Freeze everyone
        for k, v in pairs( player.GetAll() ) do
            v:Freeze( true );
        end

        ROUND_STATE = ENDING;

        hook.Call("VirusRoundFinished");

        if(timer.Exists("VirusFinishTimer")) then
            timer.Start("VirusFinishTimer");
        else
            timer.Create("VirusFinishTimer", VIRUS.ResultsTime, 1, function()
                End(false);
            end)
        end
    else
        print("WARNING : A round has tried to finish while the current state wasn't in progress. Check your code!")
    end
end

//End the current round and try to start a new one.
function End(forced, ...)
    //We're using vararg here because when the last player on the server disconnect, Round.End is called from the PlayerDisconnected hook and the player count would still be 1.
    //PlayerDisconnected will pass the already calculated number of players, theorically, it should always pass 0.
    local args = {...}
    
    if(forced == true||ROUND_STATE == ENDING) then
        if(forced == true) then
            PrintDebug("Forcing round to end.", 1);
        else
            PrintDebug("Round ended.", 1);
        end
        timer.Stop("VirusStandbyTimer");
        timer.Stop("VirusRoundTimer");
        timer.Stop("VirusFinishTimer");

        hook.Call("VirusRoundEnded");

        if(CanStart()) then
            if(forced != true||(forced == true && args[1] != 0)) then
                PrintDebug("Starting new round.", 1)
                Start();
            end
        else
            PrintDebug("A new round cannot start. Waiting for players.", 1)
            //Put the game in a waiting for players state, respawning and setting everyone back to neutral if there are players on the server.
            ROUND_STATE = WAITING_FOR_PLAYERS;
            if(table.Count(player.GetAll()) != 0) then
                for k,v in pairs(player.GetAll()) do
                    player_manager.SetPlayerClass(v, "player_neutral");
                    v:KillSilent();
                    v:Spawn();
                end
            end
        end
    else
        print("WARNING : A round has tried to end while the current state wasn't ending. Check your code!")
    end
end

//Returns true or false. Checks if we can start a new round.
function CanStart()
    if(Round.GetState() == WAITING_FOR_PLAYERS || Round.GetState() == ENDING) then
        if(table.Count(player.GetAll()) >= VIRUS.RequiredPlayers) then
            return true;
        end
    else
        return false;
    end
end

//PlayerDisconnected hook
hook.Add("PlayerDisconnected", "VirusPlayerDisconnected", function(ply)
    //Check if we still have enough players
    //Note : I added " - 1" because this hook is called before the player actually disconnect, so the player count is still counting the player.
    local playerCount = table.Count(player.GetAll()) - 1;
    if(playerCount < VIRUS.RequiredPlayers) then
        PrintDebug("Not enough players to continue. Forcing the round to end.", 1)
        //Not enough players to continue, going back to waiting for players and ending the round.
        End(true, playerCount);
    else
        //Check if the player who left was the first one who got infected.
        if(ply == FIRST_INFECTED) then
            //We need to find a new infected, going back in standby mode.
            //TODO : ^
        else
            //Check if the one who left was the last survivor
            //TODO: If statement to see who the last survivor is, I don't want to loop through every players again and check everyone's class and count blablabla.
            //      we can just set the last survivor to a variable and check if it's equal to the player who just left or if it's nil.
            //If(variable == ply) then
            //  Infected wins
            //end
        end
    end
end)