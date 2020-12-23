
local PLUGIN = PLUGIN

function PLUGIN:PrecacheArc(cx, cy, radius, thickness, startang, endang, roughness)
	local triarc = {}

	roughness = math.max(roughness or 1, 1)
	startang, endang = startang or 0, endang or 0

	local step = roughness

	if startang > endang then
		step = math.abs(step) * -1
	end

	-- Create the inner circle's points.
	local inner = {}
	local r = radius - thickness

	for deg = startang, endang, step do
		local rad = math.rad(deg)
		-- local rad = deg2rad * deg
		local ox, oy = cx + (math.cos(rad) * r), cy + (-math.sin(rad) * r)

		table.insert(inner, {
			x = ox,
			y = oy,
			u = (ox - cx) / radius + .5,
			v = (oy - cy) / radius + .5
		})
	end

	-- Create the outer circle's points.
	local outer = {}

	for deg = startang, endang, step do
		local rad = math.rad(deg)
		-- local rad = deg2rad * deg
		local ox, oy = cx + (math.cos(rad) * radius), cy + (-math.sin(rad) * radius)

		table.insert(outer, {
			x = ox,
			y = oy,
			u = (ox - cx) / radius + .5,
			v = (oy - cy) / radius + .5
		})
	end

	-- Triangulize the points.
	for tri = 1, #inner * 2 do
		local p1, p2, p3
		p1 = outer[math.floor(tri / 2) + 1]
		p3 = inner[math.floor((tri + 1) / 2) + 1]

		if tri % 2 == 0 then
			p2 = outer[math.floor((tri + 1) / 2)]
		else
			p2 = inner[math.floor((tri + 1) / 2)]
		end --if the number is even use outer.

		table.insert(triarc, {p1, p2, p3})
	end -- twice as many triangles as there are degrees.

	-- Return a table of triangles to draw.
	return triarc
end

function PLUGIN:DrawPrecached(arc)
	for _, v in ipairs(arc) do
		surface.DrawPoly(v)
	end
end

function PLUGIN:DrawArc(cx, cy, radius, thickness, startang, endang, roughness, color)
	surface.SetDrawColor(color)
	self:DrawPrecached(self:PrecacheArc(cx, cy, radius, thickness, startang, endang, roughness))
end

