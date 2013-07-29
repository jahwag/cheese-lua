function widget:GetInfo()
  return {
    name      = "Ingame Metal Spot Placement Mapping Tool",
    desc      = "Alt+M to toggle/export lua file. Use mouse to place spots. Alt+C to draw boxes, Alt+X to increase box width, Alt+Z to decrease box width.",
    author    = "Cheesecan & GoogleFrog",
    date      = "June 20, 2013",
    license   = "GNU GPL, v2 or later",
    layer     = 0,
    enabled   = false --  loaded by default?
  }
end

include("keysym.h.lua")

local floor = math.floor

------------------------------------------------
-- Variables
------------------------------------------------
local enabled = false
local spots = {}
local displayList 		= 0
local displayListBoxes 	= 0
local metalSpotWidth    = 64
local metalSpotHeight   = 64
local sel = metalSpotWidth/2
local drawBoxesOn = false
local boxWidth = 20

------------------------------------------------
-- Press Handling
------------------------------------------------

function widget:KeyPress(key, modifier, isRepeat)
	if modifier.alt then
		if key == KEYSYMS.M then
			if enabled then
				dump()
			end
			enabled = not enabled
		elseif key == KEYSYMS.C then
			drawBoxesOn = not drawBoxesOn
			Spring.Echo("Toggles drawing boxes on: " .. tostring(drawBoxesOn))
			displayListBoxes = gl.CreateList(drawBoxes)
		elseif key == KEYSYMS.X then
			boxWidth = boxWidth + 1
			Spring.Echo("Box width set to " .. boxWidth .. "%.")
			displayListBoxes = gl.CreateList(drawBoxes)
		elseif key == KEYSYMS.Z then
			boxWidth = boxWidth -1
			Spring.Echo("Box width set to " .. boxWidth .. "%.")
			displayListBoxes = gl.CreateList(drawBoxes)
		end		
	end
end

function dump() 
	local f = io.open("map_metal_layout.lua", "w+")
	if (f) then
		f:write("return { spots = {\n")
			for i = 1, #spots do
				local spot = spots[i]
				f:write("{x = " .. floor(spot.x+0.5) .. ", z = " .. floor(spot.z+0.5) .. ", metal = 1.5},\n")
			end
		f:write("\t}\n")
		f:write("}")
		
		f:close()
	else
		Spring.Echo("Could not open map_metal_layout.lua for writing!")
	end
end

local function legalPos(pos)
	return pos and pos[1] > 0 and pos[3] > 0 and pos[1] < Game.mapSizeX and pos[3] < Game.mapSizeZ
end

function widget:MousePress(mx, my, button)
	if enabled and (not Spring.IsAboveMiniMap(mx, my)) then
		local _, pos = Spring.TraceScreenRay(mx, my, true)
		
		if legalPos(pos) == false then
			return
		end
		
		if button == 1 then
			spots[#spots+1] = {
				x = pos[1],
				z = pos[3],
			}
		elseif button == 3 then
			local selectionIndex = selected(pos[1], pos[3])
			if selectionIndex ~= nil then
				table.remove(spots, selectionIndex)
			end
		end	
			
		displayList = gl.CreateList(drawPatches)
	end
end

function selected(x, z)
	for i = 1, #spots do
		local minx = (spots[i].x - sel)
		local maxx = (spots[i].x + sel)
		local minz = (spots[i].z - sel)
		local maxz = (spots[i].z + sel)
	
		if x >= minx and x <= maxx then
			if z >= minz and z <= maxz  then
				return i
			end
		end
	end
	
	return nil
end

function drawPatches()
   local mSpots = spots

    gl.PolygonOffset(-25, -2)
    gl.Culling(GL.BACK)
    gl.DepthTest(true)
	gl.Texture("LuaUI/images/metal_spot.png" )
	gl.Color(1, 1, 1) -- fix color from other widgets
	
	for i = 1, #mSpots do
	  gl.DrawGroundQuad( mSpots[i].x - metalSpotWidth/2, mSpots[i].z - metalSpotHeight/2, mSpots[i].x + metalSpotWidth/2, mSpots[i].z + metalSpotHeight/2, false, 0, 0, 1, 1)
	end
   
    gl.Texture(false)
    gl.DepthTest(false)
    gl.Culling(false)
    gl.PolygonOffset(false)
end

function drawBoxes() 
	if(drawBoxesOn) then
		gl.PushMatrix()
   
   		local maxx = Game.mapX * 512
   		local maxy = Game.mapY * 512
   		local wx = maxx  * boxWidth/100
   		local wy = maxy  * boxWidth/100
   
		gl.Color(1, 0.33, 0, 0.33)
		
		-- left edge
		gl.DrawGroundQuad(0.0, 0.0, wx, maxx)
		
		-- right edge
		gl.DrawGroundQuad(maxx - wx, 0.0, maxx, maxy)
		
		gl.Color(0.33, 1.0, 0, 0.33)
		
		-- top edge
		gl.DrawGroundQuad(0, 0, maxx, wy)
		
		-- bottom edge
		gl.DrawGroundQuad(0, maxy - wy, maxx, maxy)
		
		gl.PopMatrix()
   end

end

function widget:DrawWorldPreUnit()
   gl.CallList(displayList)
   gl.CallList(displayListBoxes)

end