


local connected = false
local remote

local luvpos = vectors.vec2(0,0)
local lstv

---@param ray_dir Vector3
---@param plane_dir Vector3
---@param plane_pos Vector3
---@return Vector3?
local function ray2plane(ray_pos, ray_dir, plane_pos, plane_dir)
   ray_dir = ray_dir:normalize()
   plane_dir = plane_dir:normalize()

   local dot = ray_dir:dot(plane_dir)
   if dot < 1e-6 then return nil end

   local t = (plane_pos - ray_pos):dot(plane_dir) / dot
   if t < 0 then return nil end

   local intersection = ray_pos + ray_dir * t
   return intersection
end

local input = {
   primary = keybinds:newKeybind("Interface Primary","key.mouse.left"),
   secondary = keybinds:newKeybind("Interface Secondary","key.mouse.right")
}

input.primary.press = function ()
   host:swingArm()
   if lstv then
      remote.click(false)
      return true
   end
end

input.secondary.press = function ()
   host:swingArm(true)
   if lstv then
      remote.click(true)
      return true
   end
end

local TV = world.avatarVars()["e4b91448-3b58-4c1f-8339-d40f75ecacc4"]
events.TICK:register(function (dt)
   if not connected then -- disconnected
      TV = world.avatarVars()["e4b91448-3b58-4c1f-8339-d40f75ecacc4"]
      if TV.getEveryTV then
         local returned = TV.auth.handshake(client)
         if returned then
            remote = returned
            connected = true
         end
      end
   elseif player:isLoaded() and connected then -- connected
      local eyePos = client:getCameraPos()
      local eyeDir = client:getCameraDir()
      
      local found_tv = false
      for _, tv in pairs(TV.getEveryTV()) do
         local gpos = ray2plane(eyePos,eyeDir,tv.origin,tv.dir)
         if gpos then
            local tvmat = matrices.mat4()
            :translate(
               tv.rect.x  - tv.rect.z + 0.5,
               tv.rect.y - tv.rect.w + 0.5,0)
            :rotateY(tv.rot)
            :translate(tv.origin)
            :invert()
            
            local lpos = tvmat:apply(gpos)
            if  lpos.x > 0 and lpos.y > 0 
            and lpos.x < tv.rect.z and lpos.y < tv.rect.w
            and (gpos-eyePos):length() < 5 then
               if tv.id ~= lstv then
                  remote.setSelectedTV(tv.id)
                  lstv = tv.id
               end
               found_tv = true
               
               local uvpos = vectors.vec2(
                  math.map(lpos.x,tv.rect.z,0,1,0),
                  math.map(lpos.y,tv.rect.w,0,0,1)
               )
               if luvpos ~= uvpos then
                  remote.setCursorPos(uvpos)
                  luvpos = uvpos
               end
               break
               --particles["end_rod"]:pos(gpos):spawn():scale(1):lifetime(0)
            end
         end
      end
      if not found_tv then
         remote.setSelectedTV(nil)
         lstv = nil
      end
   end
end)