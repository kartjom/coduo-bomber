AddCSLuaFile()

ENT.Type = "anim"

/* Fire sound */
sound.Add({
    channel = CHAN_WEAPON,
    volume = 1,
    soundlevel = 180,
    pitch = 100,
    name = "ME109.Single",
    sound = "coduo/fire/bar.mp3"
})

if (SERVER) then

    ENT.Durability = 215

    ENT.Speed = 37
    ENT.Target = nil
    
    ENT.WaypointTable = nil
    ENT.WaypointIndex = 1
    ENT.SpawnAtWaypoint = false

    /* Movement states */
    ENT.FollowingWaypoint = false
    ENT.IsHunting = false
    ENT.IsAttackingPlayerBomber = false

    ENT.OnFire = false
    ENT.Inertia = false
    ENT.ShouldSpin = false

    ENT.AlreadyFired = false
    ENT.ShootUntil = 0
    ENT.ShootTime = 2
    ENT.Damage = 27
    ENT.DummyDamage = 12

    ENT.ShootDelay = 0.2
    ENT.NextShoot = CurTime()
    ENT.CurrentSpread = 0
    ENT.SpreadAmount = 0.0000250

    ENT.Lifetime = 25
    ENT.KilledByLifetime = false

    function ENT:Initialize()
        self:SetModel("models/coduo/bomber/me109.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetCollisionGroup(COLLISION_GROUP_WORLD)

        self.SpawnTime = CurTime()

        if (self.SpawnAtWaypoint && self.WaypointTable != nil) then
            self:SetPos(self.WaypointTable[1])
            self:SetAngles( self:GetRotationTowardsTarget(self.WaypointTable[2]) )
        end

        self.mz1 = ents.Create("prop_dynamic")
        self.mz1:SetModel("models/hunter/plates/plate.mdl")
        self.mz1:PhysicsInit(SOLID_NONE)
        self.mz1:SetParent(self)
        self.mz1:SetNoDraw(true)
        self.mz1:SetLocalPos(Vector(-140.189667, 139.955658, -14.508179))
        self.mz1:SetLocalAngles(Angle())
        self.mz1:Spawn()
        
        self.mz2 = ents.Create("prop_dynamic")
        self.mz2:SetModel("models/hunter/plates/plate.mdl")
        self.mz2:PhysicsInit(SOLID_NONE)
        self.mz2:SetParent(self)
        self.mz2:SetNoDraw(true)
        self.mz2:SetLocalPos(Vector(-140.189667, -139.094849, -14.508179))
        self.mz2:SetLocalAngles(Angle())
        self.mz2:Spawn()
    end

    function ENT:Think()
        self:TickCheckLifetime() /* Ignites plane when it lives too long (prevents from flying in loop) */

        /* If able to control the plane */ 
        if ( !self.Inertia ) then
            if ( self.FollowingWaypoint ) then
                self:TickWaypointNavigation(self.WaypointTable) /* Follow the waypoints one by one */
            end
            self:TickLookTowardsTarget(self.Target) /* Gradually rotate to face the target */
            
            if (self.IsHunting && !self.OnFire) then
                self:TickHuntTarget(self.Target) /* For planes that attack friendly bombers, never targets player's bomber */
            end
        end

        if (self.ShouldSpin) then
            self:TickSpinPlane() /* For planes that lose control when on fire */
        end

        if ( !self.OnFire && self.ShootUntil > CurTime() ) then
            /* Shoots the cannons for 'ENT.ShootTime' seconds, not able to fire again */
            if (self.IsAttackingPlayerBomber) then self:FireNoseCannons() else self:FireCannons() end
        end

        self:TickMove() /* Just fly forward */

        if (self.OnFire) then
            self:TickTakeDamageFromFire() /* Take damage when set on fire */
        end

        self:NextThink(CurTime())
        return true
    end

    /* Tick methods */

    function ENT:TickCheckLifetime()
        if (!self.OnFire && !self.KilledByLifetime && CurTime() >= self.SpawnTime + self.Lifetime) then
            self.KilledByLifetime = true
            self:TakeDamage(160)
        end
    end

    function ENT:TickMove()
        self:SetPos( self:GetPos() - self:GetForward() * self.Speed )

        if ( !self:IsInWorld() ) then self:Remove() end
    end

    function ENT:TickLookTowardsTarget(target)
        if ( !target || target == NULL ) then return end

        local angle = self:GetRotationTowardsTarget(target)
        local smoothAngle = LerpAngle(0.025, self:GetAngles(), angle)

        self:SetAngles(smoothAngle)
    end

    function ENT:TickWaypointNavigation(waypoint)
        if ( !waypoint ) then return end

        if (self.WaypointIndex > #waypoint) then
            self:StopFollowingWaypoints()
            return
        end

        if (self.Target != waypoint[self.WaypointIndex]) then
            self.Target = waypoint[self.WaypointIndex]
        end

        if (self:GetPos():DistToSqr(self.Target) <= 100000) then
            self.WaypointIndex = self.WaypointIndex + 1
            //PrintMessage(HUD_PRINTTALK, tostring(self).." | "..(self.WaypointIndex-1).." / "..#self.WaypointTable)
        end

        if (self.IsAttackingPlayerBomber) then
            if (self:GetPos():DistToSqr(Vector()) <= 51763788) then
                self:StartShooting()
            end
        end
    end

    function ENT:TickHuntTarget(target)
        if ( !IsEntity(target) || !target || target == NULL ) then
            self:StopHunting()
            return
        end

        local distance = self:GetPos():DistToSqr(target:GetPos())

        if (distance <= 100047344) then
            self:StartShooting()
        end

        if (distance <= 15472741) then
            local offset = Vector()
            if (self:GetPos().x <= target:GetPos().x) then
                offset.x = -2000 else offset.x = 2000
            end
            
            if (self:GetPos().z <= target:GetPos().z) then
                offset.z = -1000 else offset.z = 1000
            end

            local tr = util.TraceLine( {
                start = self:GetPos(),
                endpos = self:GetPos() + (-self:GetForward()) * 5000 + offset,
                mask = MASK_SOLID_BRUSHONLY
            } )

            local escapePos = { tr.HitPos }

            self:FollowWaypoints(escapePos)
        end
    end

    function ENT:TickTakeDamageFromFire()
        if (!self.NextFireDamage) then self.NextFireDamage = CurTime() + 0.5 end
        if (CurTime() < self.NextFireDamage) then return end

        self:TakeDamage(10)
        self.NextFireDamage = CurTime() + 1
    end

    function ENT:TickSpinPlane()
        local angle = self:GetAngles()
        angle.z = angle.z + self.RollAmount
        angle.x = self.PitchAmount

        local smoothAngle = LerpAngle(0.050, self:GetAngles(), angle)

        self:SetAngles(smoothAngle)
    end

    /* Setters */

    function ENT:SetOnFire()
        self.OnFire = true
        ParticleEffectAttach("fighter_plane_fire", PATTACH_ABSORIGIN_FOLLOW, self, 0)
    end

    function ENT:StartSpinning()
        self.Inertia = true
        self.ShouldSpin = true

        self.PitchAmount = math.random(-30, -15)
        self.RollAmount = math.random(-75, 75)
    end

    function ENT:StartShooting()
        if (self.AlreadyFired) then return end
        self.AlreadyFired = true

        self.ShootUntil = CurTime() + self.ShootTime
        self.NextShoot = CurTime() + self.ShootDelay
    end

    function ENT:StartHunting(target)
        self:StopFollowingWaypoints()

        self.IsHunting = true
        self.Target = target
    end

    function ENT:StopHunting()
        self.IsHunting = false
        self.Target = nil
    end

    function ENT:FollowWaypoints(waypointsTable, index, spawnAtWaypoint)
        self:StopHunting()

        self.WaypointTable = waypointsTable
        self.WaypointIndex = index or 1
        self.FollowingWaypoint = true

        if (spawnAtWaypoint != nil) then
            self.SpawnAtWaypoint = spawnAtWaypoint
        end
    end

    function ENT:StopFollowingWaypoints()
        self.WaypointTable = nil
        self.WaypointIndex = 1
        self.FollowingWaypoint = false
        self.Target = nil
    end

    function ENT:AttackPlayerBomber()
        self:StopHunting()

        self.IsAttackingPlayerBomber = true
        self.ShootDelay = 0.135
        self.ShootTime = 1.75
        self.SpreadAmount = 0.0015
    end

    /* Hooks */

    function ENT:OnTakeDamage(dmginfo)
        self.Durability = self.Durability - dmginfo:GetDamage()

        if (!self.OnFire && self.Durability <= 75) then
            self:SetOnFire()

            local attacker = dmginfo:GetAttacker()
            if (attacker:IsPlayer()) then
                attacker:AddFrags(1)
                hook.Run("OnEnemyFighterKill", attacker)
            end

            if ( math.random(0, 100) >= 33 ) then
                self:StartSpinning()
            end
        end

        if (self.Durability <= 0) then
            self:Remove()
            self:CreateWreck()
        end
    end

    /* Utility */

    function ENT:GetRotationTowardsTarget(target)
        if ( !target || target == NULL ) then return self:GetAngles() end

        local pos = nil
        if ( IsEntity(target) ) then pos = target:GetPos() else pos = target end

        return (self:GetPos() - pos):AngleEx(Vector(0, 0, 1))
    end

    function ENT:CreateWreck()
        local wreckPartNames = {
            "me109_wreck_body",
            "me109_wreck_lwing",
            "me109_wreck_rwing",
            "me109_wreck_tail_lwing",
            "me109_wreck_tail_rwing",

            "human_gib_"..math.random(1, 3),
        }

        local igniteParts = {
            ["me109_wreck_body"] = true,
            ["me109_wreck_lwing"] = true
        }

        local wreckParts = {}

        for k,v in pairs(wreckPartNames) do
            local part = ents.Create("prop_physics")
            part:SetModel("models/coduo/bomber/"..v..".mdl")
            part:SetPos(self:GetPos())
            part:SetAngles(self:GetAngles())
            part:Spawn()
            
            if ( igniteParts[v] ) then
                ParticleEffectAttach("bomber_engine_smoke_big", PATTACH_ABSORIGIN_FOLLOW, part, 0)
                ParticleEffectAttach("bomber_engine_fire", PATTACH_ABSORIGIN_FOLLOW, part, 0)
            end

            table.insert(wreckParts, part)
        end

        for k,v in pairs(wreckParts) do
            if (v:GetClass() == "prop_physics") then
                local movingDir = (-self:GetForward() * self.Speed)

                v:PhysWake()
                v:GetPhysicsObject():SetVelocity( movingDir * 50 )
            end
        end

        TimerAdd("TIMER_REMOVE_WRECK_ME109_"..self:EntIndex().."_"..CurTime(), 6, 1, function()
            for k,v in pairs(wreckParts) do
                if (IsValid(v)) then
                    v:Remove()
                end
            end
        end)
    end

    function ENT:EmitMuzzleFlash()
        local offset = Vector(-75, 0, 0)

        local e = EffectData()
		e:SetOrigin( self:LocalToWorld(self.mz1:GetLocalPos() + offset) )
		e:SetNormal( -self:GetForward() )
        e:SetAngles( self:GetAngles() )
        e:SetScale(5)
		util.Effect("MuzzleEffect", e)

        e:SetOrigin( self:LocalToWorld(self.mz2:GetLocalPos() + offset) )
        util.Effect("MuzzleEffect", e)
    end

    function ENT:FireCannons()
        if (CurTime() < self.NextShoot) then return end
        self:StopSound("ME109.Single")

        local bullet = {}
		bullet.Num    = 1
		bullet.Src    = self:LocalToWorld(self.mz1:GetLocalPos())
		bullet.Dir    = -self.mz1:GetForward()
		bullet.Spread = Vector( self.CurrentSpread, self.CurrentSpread, 0 )
		bullet.Tracer = 1
		bullet.TracerName = "AR2Tracer"
		bullet.Force  = 0
		bullet.Damage = self.DummyDamage
        bullet.IgnoreEntity = self
		self.mz1:FireBullets(bullet)

        bullet.Src = self:LocalToWorld(self.mz2:GetLocalPos())
        bullet.Dir = -self.mz2:GetForward()
        self.mz2:FireBullets(bullet)

        self:EmitSound("ME109.Single")
        self:EmitMuzzleFlash()

		self.CurrentSpread = math.Clamp(self.CurrentSpread + self.SpreadAmount, 0, 0.025)

        self.NextShoot = CurTime() + self.ShootDelay
    end

    function ENT:FireNoseCannons()
        if (CurTime() < self.NextShoot) then return end
        self:StopSound("ME109.Single")

        local bullet = {}
		bullet.Num    = 2
		bullet.Src    = self:GetPos()
		bullet.Dir    = -self:GetForward()
		bullet.Spread = Vector( self.CurrentSpread, self.CurrentSpread, 0 )
		bullet.Tracer = 1
		bullet.TracerName = "AR2Tracer"
		bullet.Force  = 0
		bullet.Damage = self.Damage
        bullet.IgnoreEntity = self
		self:FireBullets(bullet)

        self:EmitSound("ME109.Single")
        self:EmitMuzzleFlash()

		self.CurrentSpread = math.Clamp(self.CurrentSpread + self.SpreadAmount, 0, 0.025)

        self.NextShoot = CurTime() + self.ShootDelay
    end

end

if (CLIENT) then
    function ENT:Draw()
        self:DrawModel()
    end
end