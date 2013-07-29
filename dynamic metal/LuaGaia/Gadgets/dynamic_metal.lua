function gadget:GetInfo()
	return {
		name      = "Dynamic Metal Map 1.1",
		desc      = "Dynamic Metal Map sets metal spots according to map_metal_layout.lua.",
		author    = "Cheesecan",
		date      = "June 20 2013",
		license   = "LGPL",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

local mm
local mapcfg

if (not gadgetHandler:IsSyncedCode()) then
  return false
end

if (Spring.GetGameFrame() >= 1) then
  return false
end

if VFS.FileExists("mapconfig/map_metal_layout.lua") then
	mm = VFS.Include("mapconfig/map_metal_layout.lua")
	Spring.Echo("Parsing map_metal_layout.lua")
else
	Spring.Echo("missing map_metal_layout.lua - you will probably become out of sync")
end

if(mm and #mm.spots > 0) then
	for i = 1, #mm.spots do
		local x = mm.spots[i].x/16
		local z = mm.spots[i].z/16
		local mAmount = 255 * mm.spots[i].metal
		
		if(x == nil or z == nil) then
			Spring.Echo("FATAL ERROR: x or y was nil for index " .. i)
		end
		
		Spring.SetMetalAmount(x, z, mAmount)
		Spring.SetMetalAmount(x, z+1, mAmount)
		Spring.SetMetalAmount(x+1, z, mAmount)
		Spring.SetMetalAmount(x+1, z+1, mAmount)
	end
	
	Spring.Echo("Dynamic metal gadget was succesfully loaded (synced)")
else 
	Spring.Echo("content of map_metal_layout.lua is illegal - you will probably become out of sync")
end

return false --unload
