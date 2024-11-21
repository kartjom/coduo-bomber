AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "turret_50cal_pod"
ENT.Spawnable = true

if (SERVER) then

    ENT.Owner = nil
    ENT.AllowCrouch = false

    function ENT:PlayerPosition()
        return self:LocalToWorld(Vector(0, 0, 43.94))
    end

    function ENT:Initialize()
        self:SetModel("models/props_c17/canister01a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)

        self:SetUseType(SIMPLE_USE)

        self.Gun = ents.Create("turret_50cal_dorsal_gun")
        self.Gun:SetParent(self)
        self.Gun:SetLocalPos(self.Gun.PositionOffset)
        self.Gun:SetLocalAngles(Angle())
        self.Gun:Spawn()

        self.Base = ents.Create("prop_dynamic")
        self.Base:SetModel("models/coduo/bomber/50cal_dorsal_base.mdl")
        self.Base:SetParent(self)
        self.Base:SetLocalPos(self.Gun.PositionOffset)
        self.Base:SetLocalAngles(Angle())
        self.Base:Spawn()
    end

    function ENT:DistanceFromTurret(pos)
        return self.Gun:GetPos():DistToSqr( pos )
    end

    function ENT:HandleUse()
        if ( !IsValid(self.Owner) ) then return end

        self.Owner:SetPos( self:PlayerPosition() )
        self.Owner:GetViewModel():SetNoDraw(true)
        self:EmitSound("Func_Tank.BeginUse")

        self.Owner:SetMoveType(MOVETYPE_NONE)
    end

    function ENT:HandleDismantle()
        if ( !IsValid(self.Owner) ) then return end

        self.Owner:GetViewModel():SetNoDraw(false)
        self:EmitSound("Func_Tank.BeginUse")
        self.Owner:SetMoveType(MOVETYPE_WALK)
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

        self.Owner = user
        self:HandleUse()
    end

    function ENT:Use(user)
        self:OnUse(user)
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

        angle.x = math.Clamp(angle.x, -vCap, 0)
        angle.y = math.Clamp(angle.y, -hCap, hCap)
        self.Gun.SmoothAngle = LerpAngle( 10 * FrameTime(), self.Gun.SmoothAngle, angle )
        self.Gun:SetLocalAngles(self.Gun.SmoothAngle)
        
        local podBaseRotation = Angle(0, self.Gun.SmoothAngle.y, 0)
        self.Base:SetLocalAngles(podBaseRotation)
        
        /* TESTING */
        local posOffset = Vector(0, 0, -self.Gun.SmoothAngle.x / 25)
        self.Owner:SetPos(self:PlayerPosition() + posOffset)
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