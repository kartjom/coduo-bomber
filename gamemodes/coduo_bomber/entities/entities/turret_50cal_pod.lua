AddCSLuaFile()

ENT.Type = "anim"
ENT.Spawnable = true

if (SERVER) then

    ENT.Owner = nil
    ENT.AllowCrouch = true

    function ENT:Initialize()
        self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)

        self:SetUseType(SIMPLE_USE)

        self.Gun = ents.Create("turret_50cal_gun")
        self.Gun:SetParent(self)
        self.Gun:SetLocalPos(self.Gun.PositionOffset)
        self.Gun:SetLocalAngles(Angle())
        self.Gun:Spawn()
    end

    function ENT:DistanceFromTurret(pos)
        return self:GetPos():DistToSqr( pos )
    end

    function ENT:HandleUse()
        if ( !IsValid(self.Owner) ) then return end

        self.Owner:GetViewModel():SetNoDraw(true)
        self:EmitSound("Func_Tank.BeginUse")
    end

    function ENT:HandleDismantle()
        if ( !IsValid(self.Owner) ) then return end

        self.Owner:GetViewModel():SetNoDraw(false)
        self:EmitSound("Func_Tank.BeginUse")
        self.Owner = nil
    end

    function ENT:OnUse(user)
        if (self.Owner != NULL && self.Owner != user) then
            return
        end

        if (self.Owner == user) then
            self:HandleDismantle()
            return
        end

        if ( self:DistanceFromTurret( user:GetPos() ) < self.Gun.UseDistance ) then
            self.Owner = user
            self:HandleUse()
        end
    end

    function ENT:ValidateUser()
        if (self.Owner == nil) then
            return false
        end

        if (self.Owner != nil && !IsValid(self.Owner)) then
            self.Owner = nil
            return false
        end

        if ( self:DistanceFromTurret( self.Owner:GetPos() ) >= self.Gun.UseDistance) then
            self:HandleDismantle()
            return false
        end

        if ( !self.Owner:Alive() ) then
            self:HandleDismantle()
            return false
        end

        if ( !self.AllowCrouch && self.Owner:Crouching() ) then
            self:HandleDismantle()
            return false
        end

        return true
    end

    function ENT:PreventWeaponFire()
        if ( self.Owner:GetActiveWeapon():IsValid() ) then
			self.Owner:GetActiveWeapon():SetNextPrimaryFire( CurTime() + 1 )
			self.Owner:GetActiveWeapon():SetNextSecondaryFire( CurTime() + 1 )
		end
    end

    function ENT:HandleShooting()
        if ( self.Owner:KeyDown(IN_ATTACK) ) then
			self.Gun:ShootSequence()
		else
            self.Gun.CurrentSpread = 0
        end
    end

    function ENT:HandleRotation()
        local data = {}
		data.start = self.Gun:GetPos()
		data.endpos = data.start + (self.Owner:GetAimVector() * 10000)
		data.filter = { self, self.Gun, self.Owner }

		local trace = util.TraceLine(data)

        local gunPos = self:GetPos() + self.Gun.PositionOffset
        local angle = (gunPos - trace.HitPos):Angle()
        
        angle = self:WorldToLocalAngles(angle)
        angle:RotateAroundAxis(angle:Up(), 180)

        local hCap = self.Gun.HorizontalCap
        local vCap = self.Gun.VerticalCap

        angle.x = math.Clamp(angle.x, -vCap, vCap)
        angle.y = math.Clamp(angle.y, -hCap, hCap)
        self.Gun.SmoothAngle = LerpAngle( 5 * FrameTime(), self.Gun.SmoothAngle, angle )
        self.Gun:SetLocalAngles(self.Gun.SmoothAngle)
    end

    function ENT:Think()
        if ( !self:ValidateUser() ) then return end

        self:HandleRotation()
        self:PreventWeaponFire()
        self:HandleShooting()

        if (!self.Owner:GetViewModel():GetNoDraw()) then
            self.Owner:GetViewModel():SetNoDraw(true) // in case we switch weapons
        end

        self:NextThink(CurTime())
		return true
    end

    function ENT:OnRemove()
        self:HandleDismantle()
    end

end

if (CLIENT) then

    function ENT:Draw() 
        //self:DrawModel()
    end

end