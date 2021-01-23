AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "bomber_dynamic_part"

if (SERVER) then
    ENT.CurrentDamageLevel = 0
    ENT.MaxDamageLevel = 1

    ENT.PartName = ""
    ENT.InnerPropellerOffset = Vector()
    ENT.OuterPropellerOffset = Vector()

    ENT.MaxHealth = 4250

    ENT.CanTakeDamage = true
    ENT.OnFire = false

    function ENT:Initialize()
        self:SetName(self.PartName)
        self:SetModel("models/coduo/bomber/"..self.PartName.."_0.mdl")
        self:SetPos(Vector())
        self:SetAngles(Angle())
        self:PhysicsInit(SOLID_VPHYSICS)
        
        self:GetPhysicsObject():EnableMotion(false)

        self.CurrentHealth = self.MaxHealth

        self:CreatePropellers()
    end

    function ENT:GetFuelCrank(location)
        // location == "inner", "outer"
        return ents.FindByName(self.PartName.."_crank_"..location)[1]
    end

    function ENT:GetEmitter(location, effect)
        // location == "inner", "outer"
        // effect = "fire", "smoke"
        return ents.FindByName(self.PartName.."_"..location.."_"..effect)[1]
    end

    function ENT:GetPropeller(location)
        // location == "inner", "outer"
        return ents.FindByName(self.PartName.."_propeller_"..location)[1]
    end

    function ENT:EngineStartFire(location)
        // location == "inner", "outer"
        self:GetEmitter(location, "fire"):Fire("Start")
        self.OnFire = true

        if ( math.random(0, 100) > 50 ) then
            ents.FindByName("radio")[1]:TakeDamage(25000)
        end
        
        self:EmitSound("coduo/bomber/engine_fire.wav", 65)
    end
    
    function ENT:EngineStopFire(location)
        // location == "inner", "outer"
        self:GetEmitter(location, "fire"):Remove()
        self:GetEmitter(location, "smoke"):Fire("Start")

        self.OnFire = false

        self:StopSound("coduo/bomber/engine_fire.wav")
    end

    function ENT:CreatePropellers()
        self.InnerPropeller = ents.Create("prop_dynamic")
        self.InnerPropeller:SetModel("models/coduo/bomber/propeller_0.mdl")
        self.InnerPropeller:SetPos(self.InnerPropellerOffset)
        self.InnerPropeller:SetAngles(Angle(0, 180, 0))
        self.InnerPropeller:SetName(self.PartName.."_propeller_inner")
        self.InnerPropeller:Spawn()
        
        self.OuterPropeller = ents.Create("prop_dynamic")
        self.OuterPropeller:SetModel("models/coduo/bomber/propeller_0.mdl")
        self.OuterPropeller:SetPos(self.OuterPropellerOffset)
        self.OuterPropeller:SetAngles(Angle(0, 180, 0))
        self.OuterPropeller:SetName(self.PartName.."_propeller_outer")
        self.OuterPropeller:Spawn()

        if (self.PartName == "l_wing") then
            self.OuterPropeller.EngineNumber = 1
            self.InnerPropeller.EngineNumber = 2
        else
            self.InnerPropeller.EngineNumber = 3
            self.OuterPropeller.EngineNumber = 4
        end
    end

    function ENT:CanTakeDamage()
        return self.CurrentDamageLevel < self.MaxDamageLevel
    end

    function ENT:DamageEngine(location)
        self:GetPropeller(location):SetModel("models/coduo/bomber/propeller_1.mdl")
        self:EngineStartFire(location)

        local crankEnt = self:GetFuelCrank(location)

        local crankUse = ents.Create("logic_use")
        crankUse:SetPos(crankEnt:GetPos())
        crankUse:Spawn()
        constraint.NoCollide(crankUse, ents.FindByName("radio")[1], 0, 0)

        EntityMakeObjective(crankEnt)

        local wingEnt = self

        function crankUse:Use()
            UseFuelCrank(crankEnt)
            EntityMakeNormal(crankEnt)

            TimerAdd("BOMBER_Extinguish_"..wingEnt.PartName.."_"..location, 2, 1, function()          
                wingEnt:EngineStopFire(location)
            end)

            crankUse:Remove()
        end
    end

    /* Engine Fire Sequence */
    function ENT:PostDamageComponent()
        if (self.CurrentDamageLevel == 1) then
        
            // Randomizing the sequence for some variety
            local engineType = nil
            if (math.random(0, 100) < 50) then
                self:DamageEngine("inner")
                engineType = self.InnerPropeller
            else
                self:DamageEngine("outer")
                engineType = self.OuterPropeller
            end
            
            /* Pilot dialogue */
            if ( !BOMBER_FIRST_ENGINE_DOWN ) then
                TimerAdd("ENGINE_FIRE_"..engineType.EngineNumber, 0.5, 1, function()
                    DialoguePlayScene({
                        { snd = "coduo/voiceovers/engine_fire_"..engineType.EngineNumber..".mp3", delay = 3 },
                        { snd = "coduo/voiceovers/engine_fuel_warning_1.mp3"}
                    })
                end)

                BOMBER_FIRST_ENGINE_DOWN = true
            else
                local dialogue = ""
                if (math.random(0, 100) >= 50) then
                    dialogue = "coduo/voiceovers/engine_fire_"..engineType.EngineNumber..".mp3"
                else
                    dialogue = "coduo/voiceovers/engine_fuel_warning_2.mp3"
                end
                
                TimerAdd("ENGINE_FIRE_"..engineType.EngineNumber, 0.5, 1, function()
                    SendDialogue(dialogue)
                end)
            end
        end
    end

    function ENT:Think()
        if (self.OnFire && self:CanTakeDamage()) then
            self:TakeDamage(125)
        end

        self:NextThink(CurTime() + 1)
        return true
    end

end

if (CLIENT) then

    function ENT:Draw()
        self:DrawModel()
    end

end