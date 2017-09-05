hook.Add("PlayerBindPress", "AntiCrouch", function(ply, bind)
      if (string.find(bind, "+duck")) then return true end
end )