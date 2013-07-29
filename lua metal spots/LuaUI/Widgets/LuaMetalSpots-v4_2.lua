--------------------------------------------------------------------------------

--   Changelog:
--   v4.2
--   * random rotation works again
--   * not drawn in f4 (metal mode) anymore
--
--	 v4.1
--   * No longer drawn while in F1 (height) mode.
-- 
--	 v4.0
--	 * Rewrote from scratch using Niobium metal finder available globally in BA.
--
--   v3.3
--   * fixed issues with archive loading
--   v3.2
--   * fixed drawing on sloped terrain
--   * randomness and multiple textures is broken
--
--   v3.1
--   * fixed depth testing issue
--
--   v3
--   * changed to Niobium metal finder with mass metal detection.
--
--   v2
--   * added display lists
--   * added loading metal maps from file
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function widget:GetInfo()
  return {
    name      = "Lua Metal Spots V4.2",
    desc      = "Requires Niobium's metal finder.",
    author    = "Cheesecan",
    date      = "2013-04-24",
    license   = "LGPL v2",
    layer     = 5,
    enabled   = true  --  loaded by default?
  }
end

-- Variables
local displayList 		= 0
local metalSpotWidth    = 64
local metalSpotHeight   = 64
-- End variables

function widget:Initialize()
	if not WG.metalSpots then
		Spring.Echo("<Lua Metal Patches> This widget requires the 'Metalspot Finder' widget to run.")
		widgetHandler:RemoveWidget(self)
	end
	
	displayList = gl.CreateList(drawPatches)
end

function drawPatches()
	local mSpots = WG.metalSpots
	
	-- Switch to texture matrix mode
	gl.MatrixMode(GL.TEXTURE)
	
    gl.PolygonOffset(-25, -2)
    gl.Culling(GL.BACK)
    gl.DepthTest(true)
	gl.Texture("maps/metal.png" )
	gl.Color(1, 1, 1) -- fix color from other widgets
	
	for i = 1, #mSpots do
		local metal_rotation = math.random(0, 360)
		gl.PushMatrix()
		gl.Translate(0.5, 0.5, 0)
		gl.Rotate( metal_rotation, 0, 0, 1)   
		gl.DrawGroundQuad( mSpots[i].x - metalSpotWidth/2, mSpots[i].z - metalSpotHeight/2, mSpots[i].x + metalSpotWidth/2, mSpots[i].z + metalSpotHeight/2, false, -0.5,-0.5, 0.5,0.5)
		gl.PopMatrix()
		
	end
    gl.Texture(false)
    gl.DepthTest(false)
    gl.Culling(false)
    gl.PolygonOffset(false)
	
	-- Restore Modelview matrix
	gl.MatrixMode(GL.MODELVIEW)
end

function widget:DrawWorldPreUnit()
	local mode = Spring.GetMapDrawMode()
	
	if(mode ~= "height" and mode ~= "metal") then
		gl.CallList(displayList)
	end
	
end