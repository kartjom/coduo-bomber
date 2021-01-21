include( "create_components.lua" )
include( "flak_barrage.lua" )

util.AddNetworkString("NET_START_BLUR")
util.AddNetworkString("NET_STOP_BLUR")

function InitializeMap()
    CleanUpTimers()
    CleanUpHooks()

    BindEntities()

    CreateTail_Waist()
    CreateWings()
    CreateRadioRoom()

    SpawnChairs()

    CreateWaistTurrets()
    CreateTailTurret()
    CreateDorsalTurret()
    CreateBallTurret()

    CreateLogicEntities()
    CreateFirstAidKits()
    CreateManagers()

    FlakBarrageLogic()
    EnemyFightersLogic()

    SpawnBombs()

    CreateBombersFormation()

    CloudsEmitter()
end

function BindEntities()
    BOMBER_BOMB_BAY = ents.FindByName("bomb_bay_animated")[1]
    BOMBER_BOMB_BAY_CRANK = ents.FindByName("bomb_bay_crank_animated")[1]

    BOMBER_BOMB_BAY_CLOSED = true
    BOMBER_BOMB_BAY_NEXT_USE = 0

    BOMBER_FLAK_BARRAGE = false
    BOMBER_ENEMY_FIGHTERS = false

    SetGlobalBool("BOMBER_SANDBOX_TOGGLED", false)
end

function CleanUpTimers()
    if ( TimersList == nil ) then 
        TimersList = {}
        return
    end

    for k,v in pairs(TimersList) do timer.Destroy(k) end

    TimersList = {} // must be global
end

function CleanUpHooks()
    if ( HooksList == nil ) then 
        HooksList = {}
        return
    end

    for name,event in pairs(HooksList) do hook.Remove(event, name) end

    HooksList = {} // must be global
end