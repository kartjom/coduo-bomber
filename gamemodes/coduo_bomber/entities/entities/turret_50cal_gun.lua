AddCSLuaFile()

ENT.Type = "anim"

ENT.Primary = {}
ENT.Primary.Delay = 0.1
ENT.Primary.Recoil = 1
ENT.Primary.Spread = 0.02
ENT.Primary.Damage = 20
ENT.Primary.Sound = Sound("Turret_50cal.Single")

ENT.SmoothAngle = Angle()

ENT.DefaultAngle = Angle(90, 0, 0)
ENT.PositionOffset = Vector(0, 0, 10)
ENT.MuzzlePos = Vector(57, 0, -2)

ENT.HorizontalCap = 35
ENT.VerticalCap = 15

ENT.UseDistance = 5000

ENT.NextFire = 0
ENT.CurrentSpread = 0
ENT.SpreadAmount = 0.0000125

sound.Add({
    channel = CHAN_WEAPON,
    volume = 1,
    soundlevel = 140,
    pitch = 100,
    name = "Turret_50cal.Single",
    sound = "coduo/fire/50cal_cooldown.wav"
})

if (SERVER) then

    function ENT:Initialize()
        self:SetModel("models/coduo/bomber/50cal_nopod.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

        self:SetUseType(SIMPLE_USE)
    end

    function ENT:Use(user)
        self:GetParent():OnUse(user)
    end

    function ENT:ShootSequence()
        if ( CurTime() < self.NextFire ) then return end

        self:EmitSound(self.Primary.Sound)
        self:FireBullet()

        self.NextFire = CurTime() + self.Primary.Delay
    end

    function ENT:FireBullet()
        local bullet = {}
		bullet.Num    = 1
		bullet.Src    = self:LocalToWorld(self.MuzzlePos)
		bullet.Dir    = self:GetForward()
		bullet.Spread = Vector( self.Primary.Spread + self.CurrentSpread, self.Primary.Spread + self.CurrentSpread, 0 )
		bullet.Tracer = 1
		bullet.TracerName = "AR2Tracer"
		bullet.Force  = 10
		bullet.Damage = self.Primary.Damage

        if (self:GetParent().Owner:IsPlayer()) then
            bullet.Attacker = self:GetParent().Owner
        end

		self:FireBullets(bullet)
        self:EmitMuzzleFlash()
        self:EmitShells()

		self.CurrentSpread = math.Clamp(self.CurrentSpread + self.SpreadAmount, 0, 0.025)
    end

    function ENT:EmitMuzzleFlash()
        local e = EffectData()
		e:SetOrigin( self:LocalToWorld(self.MuzzlePos) )
		e:SetNormal( self:GetForward() )
        e:SetAngles( self:GetAngles() )
        e:SetScale(4)
		util.Effect("MuzzleEffect", e)
    end

    function ENT:EmitShells()
        local e = EffectData()
        e:SetEntity(self)
		e:SetOrigin( self:LocalToWorld(Vector(0, 0, 0)) )
        e:SetAngles( self:GetRight():Angle() )
		util.Effect("RifleShellEject", e)
    end
end

if (CLIENT) then

    function ENT:Draw() 
        self:DrawModel()
    end

end