AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "turret_50cal_gun"

ENT.SmoothAngle = Angle()

ENT.DefaultAngle = Angle(90, 0, 0)
ENT.PositionOffset = Vector(0, 0, -103)

ENT.MuzzlePos = Vector(104.965820, 19.191986, -3)
ENT.MuzzlePos2 = Vector(104.965820, -19.191986, -3)

ENT.HorizontalCap = 360
ENT.VerticalCap = -35

ENT.UseDistance = 6000

if (SERVER) then

    function ENT:Initialize()
        self:SetModel("models/coduo/bomber/50cal_ball_gun.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

        self:SetUseType(SIMPLE_USE)

        /* Bullet tracers emit from the shooting entity
        we must create two dummies serving as origins */

        self.mz1 = ents.Create("prop_dynamic")
        self.mz1:SetModel("models/hunter/plates/plate.mdl")
        self.mz1:SetParent(self)
        self.mz1:SetNoDraw(true)
        self.mz1:SetLocalPos(self.MuzzlePos)
        self.mz1:SetLocalAngles(Angle())
        self.mz1:Spawn()
        
        self.mz2 = ents.Create("prop_dynamic")
        self.mz2:SetModel("models/hunter/plates/plate.mdl")
        self.mz2:SetParent(self)
        self.mz2:SetNoDraw(true)
        self.mz2:SetLocalPos(self.MuzzlePos2)
        self.mz2:SetLocalAngles(Angle())
        self.mz2:Spawn()
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
		bullet.Dir    = self.mz1:GetForward()
		bullet.Spread = Vector( self.Primary.Spread + self.CurrentSpread, self.Primary.Spread + self.CurrentSpread, 0 )
		bullet.Tracer = 1
		bullet.TracerName = "AR2Tracer"
		bullet.Force  = 10
		bullet.Damage = self.Primary.Damage
		self.mz1:FireBullets(bullet)
        
        bullet.Src = self:LocalToWorld(self.MuzzlePos2)
        bullet.Dir = self.mz2:GetForward()
        self.mz2:FireBullets(bullet)

        self:EmitMuzzleFlash()

		self.CurrentSpread = math.Clamp(self.CurrentSpread + self.SpreadAmount, 0, 0.025)
    end

    function ENT:EmitMuzzleFlash()
        local e = EffectData()
		e:SetOrigin( self:LocalToWorld(self.MuzzlePos) )
		e:SetNormal( self:GetForward() )
        e:SetAngles( self:GetAngles() )
        e:SetScale(4)
		util.Effect("MuzzleEffect", e)

        e:SetOrigin( self:LocalToWorld(self.MuzzlePos2) )
        util.Effect("MuzzleEffect", e)
    end
end

if (CLIENT) then

    function ENT:Draw() 
        self:DrawModel()
    end

end