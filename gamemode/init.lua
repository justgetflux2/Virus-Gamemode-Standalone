//CS Lua file
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua")

//Includes
include("player_classes/infected.lua");
include("player_classes/neutral.lua");
include("player_classes/spectator.lua");
include("player_classes/survivor.lua");
include("sv_meta.lua");
include("sv_rounds.lua");

include("shared.lua");

function GM:Initialize()
    
end

function GM:PlayerInitialSpawn(ply)
    timer.Simple(0.1, function()
        ply:KillSilent();
        ply:SetCustomCollisionCheck(true)
        InitialSpawnCheck(ply);
    end)
end

//Shouldn't be local tbh but eh, kinda lazy right now. Should be part of a VIRUS table
function InitialSpawnCheck(ply)
    //========
    //Round checking to see if we spawn the player or not
    //========
    //Check if there's a round in progress
    if(Round.GetState() == WAITING_FOR_PLAYERS || Round.GetState() == STANDBY) then
        //A round hasn't started yet, make the player neutral and spawn
        player_manager.SetPlayerClass(ply, "player_neutral");
        ply:Spawn();
        PrintDebug("Spawning " .. ply:Name() .. " as a neutral player.", 1)

    else
        //A round is in progress, make the player a spectator
        player_manager.SetPlayerClass(ply, "player_spectator");
        PrintDebug("Setting " .. ply:Name() .. " as a spectator.", 1)
    end
    //TODO: Add an hook here about round checking

    //========
    //Checking if we can start the round
    //========
    if(Round.CanStart()) then
        //We have enough players, let's start a new round
        PrintDebug("Reached required players, trying to start the game.", 1);
        Round.Start();
    end
end

function GM:PlayerDeathThink(ply)
    //Not allowing respawn for now
    //TODO: Check if the player is able to respawn, basically if the player is infected, but there should be a timer automatically respawning the player.
    return false
end