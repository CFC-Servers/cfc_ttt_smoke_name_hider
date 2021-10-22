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

hook.Add("HUDDrawTargetID", "CFC_SmokeNameHider_HideTargetID", function()
	for i, smoke in pairs(smokes) do
		
		local radius = smoke.radius
		local smokeOrigin = smoke.origin

		local trace = LocalPlayer():GetEyeTrace()
		local closest = closestPoint(smokeOrigin, trace.StartPos, trace.HitPos)
		
		local isInside = closest:Distance(smokeOrigin) < radius
			
		if os.clock() > smoke.expiresAt then
			table.remove(smokes, i)
		end
		

		if isInside then return false end	
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



