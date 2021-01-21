function ShowWaypoint(id)
    local color = Color(math.random(1, 254), math.random(1, 254), math.random(1, 254))
    for i=1, #ME109_WAYPOINTS[id] do
        local name = "waypoint_"..id.."_"..i

        local old = ents.FindByName(name)[1]
        if (IsValid(old)) then old:Remove() end

        local w = ents.Create("fx_waypoint")
        w:SetPos(ME109_WAYPOINTS[id][i])
        w:SetName(name)
        w:SetColor(color)
        w:Spawn()
    end
end

function SpawnAt(id)
    local me = ents.Create("ai_me109")
    me:AttackPlayerBomber()
    me:FollowWaypoints(ME109_WAYPOINTS[id], 1, true)
    me:Spawn()
end

concommand.Add("showwaypoint", function(ply, cmd, args)
    ShowWaypoint( tonumber(args[1]) )
end)

concommand.Add("spawn", function(ply, cmd, args)
    SpawnAt( tonumber(args[1]) )
end)

concommand.Add("spawnmany", function(ply, cmd, args)
    local start = tonumber(args[1])
    local count = tonumber(args[2]) - start
    
    for i=0, count do
        SpawnAt(start + i)
    end
end)

concommand.Add("cleanup", function(ply, cmd, args)
    game.CleanUpMap()
end)

/* -------------------------------------- */

function AddWaypointTable(tableID)
    ME109_WAYPOINTS[tableID] = {}
end

function AddWaypoint(ply, tableID, waypointID)
    ME109_WAYPOINTS[tableID][waypointID] = ply:GetPos()
end

concommand.Add("newwaypoint", function(ply, cmd, args)
    AddWaypointTable( tonumber(args[1]) )
end)

concommand.Add("addwaypoint", function(ply, cmd, args)
    AddWaypoint(ply, tonumber(args[1]), tonumber(args[2]))
end)

concommand.Add("copywaypoint", function(ply, cmd, args)
    ME109_WAYPOINTS[tonumber(args[2])] = ME109_WAYPOINTS[tonumber(args[1])]
end)

util.AddNetworkString("SEND_TABLE")
concommand.Add("printwaypoint", function(ply, cmd, args)
    local tbl = ME109_WAYPOINTS[ tonumber(args[1]) ]
    if ( tbl == nil || tbl == NULL) then return end

    net.Start("SEND_TABLE")
        net.WriteInt(tonumber(args[1]), 16)
        net.WriteTable( tbl )
    net.Send(ply)
end)