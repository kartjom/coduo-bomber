hook.Add("PlayerInitialSpawn", "HookCheckGamemodeBomber", function(ply)

	if (ply:IsListenServerHost()) then
		if (game.GetMap() == "coduo_bomber" && engine.ActiveGamemode() != "coduo_bomber") then
			PrintMessage(HUD_PRINTTALK, "Wrong gamemode! Reloading in 10 seconds..")
			timer.Create("BomberChangeGamemode", 10, 1, function()		
				RunConsoleCommand("gamemode", "coduo_bomber")
				RunConsoleCommand("changelevel", "coduo_bomber")
			end)
		else
			hook.Remove("PlayerInitialSpawn", "HookCheckGamemodeBomber")
		end
	else
		hook.Remove("PlayerInitialSpawn", "HookCheckGamemodeBomber")
	end

end)