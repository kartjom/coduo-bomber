local ply = FindMetaTable("Player")

function ply:StartExplosionShock()
    net.Start("NET_START_BLUR")
    net.Send(self)
end

function ply:StopExplosionShock()
    net.Start("NET_STOP_BLUR")
    net.Send(self)
end