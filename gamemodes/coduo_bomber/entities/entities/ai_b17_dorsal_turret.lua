AddCSLuaFile()

ENT.Type = "anim"

if (SERVER) then

    ENT.Plane = nil
    ENT.Target = nil

    ENT.ShootDelay = 0.1
    ENT.NextShoot = CurTime()

    ENT.CanShootTime = 0
    ENT.NextCanShoot = 0
    ENT.FireDuration = 2

    ENT.Damage = 2
    ENT.Range = 9000

    ENT.RotationSpeed = 0.1

    ENT.vMin = -35
    ENT.vMax = 0

    ENT.StandbyRotation = Angle()
    ENT.StandbyVerticalRotation = -5

    function ENT:Initialize()
        self:SetModel("models/coduo/bomber/b17_dummy_dorsal_turret.mdl")
        self:PhysicsInit(SOLID_NONE)

        self.Guns = ents.Create("prop_dynamic")
        self.Guns:SetModel("models/coduo/bomber/b17_dummy_dorsal_turret_guns.mdl")
        self.Guns:SetParent(self)
        self.Guns:SetLocalPos(Vector())
        self.Guns:SetLocalAngles(Angle(0, self.StandbyVerticalRotation, 0))
        self.Guns:Spawn()
        
        self:SetParent(self.Plane, 1)
        self:SetLocalPos(Vector(80, 100, -430))
        self:SetLocalAngles(Angle())
    end

    function ENT:Think()
        if ( !self:PlaneIsValid() ) then
            self:Remove() return
        end
        
        if ( BOMBER_ENEMY_FIGHTERS && !self:TargetIsValid() ) then
            self:FindNewTarget()
        end

        self:LookAt()

        if ( self:TargetIsValid() ) then
            if ( self.Plane:GetPos():DistToSqr(self.Target:GetPos()) > (self.Range*self.Range) ) then
                self.Target = nil
            end

            if ( CurTime() >= self.NextCanShoot ) then
                self:AllowShooting()
            end

            if ( self:CanShoot() ) then
                self:Shoot()
            end
        end

        self:NextThink(CurTime())
        return true
    end

    function ENT:FilterEnemyPlanes(tbl)
        local fighters = {}
        for k,v in pairs(tbl) do
            if (v:GetClass() == "me109") then table.insert(fighters, v) end
        end
        return fighters
    end

    function ENT:FindNewTarget()
        local objects = ents.FindInSphere(self.Plane:GetPos(), self.Range)
        local filtered = self:FilterEnemyPlanes(objects)
        local target = filtered[math.random(#filtered)]

        if (target != nil && target != NULL) then
            self.Target = target
        end
    end

    function ENT:LookAt()
        local turretAngle = Angle()
        local gunAngle = Angle()

        if ( self:TargetIsValid() ) then
            local lookAtAngle = (self:GetPos() - self.Target:GetPos()):Angle()
            lookAtAngle.y = lookAtAngle.y - 90
            
            turretAngle.x = lookAtAngle.y

            gunAngle.y = math.Clamp(-lookAtAngle.x, self.vMin, self.vMax)

            if ( self:InDeadZone() ) then gunAngle.y = 0 end
        else
            turretAngle = self.StandbyRotation
            gunAngle.y = self.StandbyVerticalRotation
        end

        local smoothTurretAngle = LerpAngle(self.RotationSpeed, self:GetLocalAngles(), turretAngle)
        local smoothGunAngle = LerpAngle(self.RotationSpeed, self.Guns:GetLocalAngles(), gunAngle)

        self:SetLocalAngles(smoothTurretAngle)
        self.Guns:SetLocalAngles(smoothGunAngle)
    end

    /* Shooting */

    function ENT:AllowShooting()
        self.CanShootTime = CurTime() + 2
        self.NextCanShoot = CurTime() + (self.FireDuration * 2) - math.Rand(0, 0.75)
    end

    function ENT:CanShoot()
        local burstTime = (CurTime() <= self.CanShootTime)
        local isAlive = (self.Plane.Durability > 0)

        return (self:TargetIsValid() && burstTime && isAlive)
    end

    function ENT:Shoot()
        if (CurTime() < self.NextShoot) then return end

        local bullet = {}
		bullet.Num    = 1
		bullet.Src    = self.Guns:GetPos()
		bullet.Dir    = -self.Guns:GetForward()
		//bullet.Spread = Vector( self.CurrentSpread, self.CurrentSpread, 0 )
		bullet.Tracer = 2
		bullet.TracerName = "AirboatGunTracer"
		bullet.Force  = 0
		bullet.Damage = self.Damage
        bullet.IgnoreEntity = self.Plane
		self.Guns:FireBullets(bullet)

        self:EmitSound("Turret_50cal.Single")

        self.NextShoot = CurTime() + self.ShootDelay
    end

    /* Utility */

    function ENT:TargetIsValid()
        return (self.Target != nil && self.Target != NULL)
    end

    function ENT:PlaneIsValid()
        return (self.Plane != nil && self.Plane != NULL)
    end

    function ENT:InDeadZone()
        return (self.Target:GetPos().z <= self:GetPos().z)
    end

end

if (CLIENT) then

    function ENT:Draw()
        self:DrawModel()
    end

end