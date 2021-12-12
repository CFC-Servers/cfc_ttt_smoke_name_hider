local function closestPoint(point, lineStart, lineEnd)
    local s = lineEnd - lineStart
    local w = point - lineStart
    local ps = w:Dot(s)
    if ps <= 0 then return lineStart end
        
    local l2 = s:Dot(s)
    if ps > l2 then
        return lineEnd
    end
    
    return lineStart + ps/l2 * s
    
end

local radiusMultiplier = 6
local smokeLifetime = 20
local smokes = {}

function LineIntersectsWithSmoke(startPos, endPos) 
    for i, smoke in pairs(smokes) do
        local radius = smoke.radius
        local smokeOrigin = smoke.origin

        local closest = closestPoint(smokeOrigin, startPos, endPos)
        
        local isInside = closest:Distance(smokeOrigin) < radius

        if os.clock() > smoke.expiresAt then
            table.remove(smokes, i)
        end

        if isInside then return true end	
    end

    return false
end

hook.Add("HUDDrawTargetID", "CFC_SmokeNameHider_HideTargetID", function()
    local trace = LocalPlayer():GetEyeTrace()
    if LineIntersectsWithSmoke(trace.StartPos, trace.HitPos) then
        return false
    end
end)

hook.Add("EntityRemoved", "CFC_SmokeNameHider_TrackSmoke", function(ent)
    if ent:GetClass() == "ttt_smokegrenade_proj" then
        table.insert(smokes, {
            radius = ent:GetRadius() * radiusMultiplier,
            origin = ent:GetPos(),
            expiresAt = os.clock() + smokeLifetime
        })
    end
end)

function RADIO:GetTargetType()
    if not IsValid(LocalPlayer()) then return end
    local trace = LocalPlayer():GetEyeTrace(MASK_SHOT)

    if not trace or (not trace.Hit) or (not IsValid(trace.Entity)) then return end
    if LineIntersectsWithSmoke(trace.StartPos, trace.HitPos) then
        return "quick_nobody", true
    end

    local ent = trace.Entity

    if ent:IsPlayer() and ent:IsTerror() then
        if ent:GetNWBool("disguised", false) then
            return "quick_disg", true
        else
            return ent, false
        end
    elseif ent:GetClass() == "prop_ragdoll" and CORPSE.GetPlayerNick(ent, "") != "" then

        if DetectiveMode() and not CORPSE.GetFound(ent, false) then
            return "quick_corpse", isInside or true
        else
            return ent, false
        end
    end
end


