AddCSLuaFile()

ENT.Type = "anim"

if (SERVER) then
    ENT.CurrentDamageLevel = 0
    ENT.MaxDamageLevel = 1

    ENT.PartName = ""

    ENT.MaxHealth = 650
    ENT.ShakeOnDamage = true
    ENT.SoundOnDamage = true

    ENT.FilterDamage = {
        ["prop_dynamic"] = true
    }

    function ENT:Initialize()
        self:SetName(self.PartName)
        self:SetModel("models/coduo/bomber/"..self.PartName.."_0.mdl")
        self:SetPos(Vector())
        self:SetAngles(Angle())

        self:PhysicsInit(SOLID_VPHYSICS)
        self:GetPhysicsObject():EnableMotion(false)

        self.CurrentHealth = self.MaxHealth
    end

    function ENT:CanTakeDamage()
        return self.CurrentDamageLevel < self.MaxDamageLevel
    end

    function ENT:OnTakeDamage(hitInfo)
        if ( self:CanTakeDamage() ) then

            /* Negate damage from friendly bombers */
            local attacker = hitInfo:GetAttacker()
            if (attacker != nil && attacker != NULL ) then
                if ( self.FilterDamage[attacker:GetClass()] ) then return end
            end

            local dmg = hitInfo:GetDamage()
            self.CurrentHealth = self.CurrentHealth - dmg

            if (self.CurrentHealth <= 0) then
                self:DamageComponent()
            end
        end
    end

    function ENT:DamageComponent()
        if ( !self:CanTakeDamage() ) then return end

        self.CurrentDamageLevel = self.CurrentDamageLevel + 1
        self.CurrentHealth = self.MaxHealth

        self:SetModel("models/coduo/bomber/"..self.PartName.."_"..self.CurrentDamageLevel..".mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_NONE)
        self:GetPhysicsObject():EnableMotion(false)

        self:PostDamageComponent()

        self:DamageShake()
        self:DamageSound()

        self:CheckForEnding()
    end

    function ENT:DamageShake()
        if ( !self.ShakeOnDamage ) then return end

        util.ScreenShake( Vector(0,0,0), 15, 10, 1, 500 )
    end

    function ENT:DamageSound()
        if ( !self.SoundOnDamage ) then return end

        self:EmitSound("coduo/bomber/flak_hit01.mp3", 120)
    end

    function ENT:PostDamageComponent()
        /* override */
    end

    function ENT:CheckForEnding()
        local parts = ents.FindByClass("bomber_dynamic_part")
        local wings = ents.FindByClass("bomber_dynamic_wing")
        local partsNum = #parts + #wings

        local destroyedParts = 0

        for k,v in pairs(parts) do
            if (v.CurrentDamageLevel > 0 && !self:CanTakeDamage()) then destroyedParts = destroyedParts + 1 end
        end
        for k,v in pairs(wings) do
            if (v.CurrentDamageLevel > 0 && !self:CanTakeDamage()) then destroyedParts = destroyedParts + 1 end
        end

        if (destroyedParts == partsNum) then
            BeginEndingSequence()
        end
    end

end

if (CLIENT) then

    function ENT:Draw()
        self:DrawModel()
    end

end