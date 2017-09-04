DeriveGamemode("base")
MINIMUM_PLAYER_AMOUNT = 4	//Minimum amount of players to start a game
TimeLimit = 15 * 60		//15 minutes until end of round

GM.Name = "Virus Gamemode"
GM.Author = "Sphere"
GM.Email 	= ""
GM.Website 	= ""

function VirusMusicTest( um )
surface.PlaySound( "gmodtower/virus/roundplay" ..math.random(1,5).. ".mp3")
surface.PlaySound("gmodtower/virus/stinger.mp3")
end
usermessage.Hook("VirusRoundMusic", VirusMusicTest)