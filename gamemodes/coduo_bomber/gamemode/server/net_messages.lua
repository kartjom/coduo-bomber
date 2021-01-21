/* Syncing sequences between server and clients */
util.AddNetworkString("NET_ANIM_RESET")

function PlayAnimation(ent, anim)
    net.Start("NET_ANIM_RESET")
        net.WriteEntity(ent)
        net.WriteInt(anim, 4)
    net.Broadcast()

    ent:ResetSequence(anim)
    ent:SetCycle(0)
end

/* Q menu things */

util.AddNetworkString("FLAK_REQUEST")
net.Receive("FLAK_REQUEST", function()
    if (BOMBER_FLAK_BARRAGE) then StopFlakBarrage() else StartFlakBarrage() end
end)

util.AddNetworkString("FIGHTERS_REQUEST")
net.Receive("FIGHTERS_REQUEST", function()
    if (BOMBER_ENEMY_FIGHTERS) then StopEnemyFighters() else StartEnemyFighters() end
end)

util.AddNetworkString("ATTACK_BOMBER_REQUEST")
net.Receive("ATTACK_BOMBER_REQUEST", function()
    FighterAttackPlayer()
end)

util.AddNetworkString("ATTACK_FRIENDLIES_REQUEST")
net.Receive("ATTACK_FRIENDLIES_REQUEST", function()
    FighterAttackFriendlies()
end)

util.AddNetworkString("TOGGLE_SANDBOX")
net.Receive("TOGGLE_SANDBOX", function()
    local currentState = GetGlobalBool("BOMBER_SANDBOX_TOGGLED")
    SetGlobalBool("BOMBER_SANDBOX_TOGGLED", !currentState)
end)