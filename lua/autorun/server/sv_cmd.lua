
concommand.Add("sv_register", function( p, c, a )
	if !p or !a then return end
	RegisterUser(p, a[1], a[2], a[3])
end)

concommand.Add("sv_link", function( p, c, a )
	if !p or !a then return end
	LinkUser(p, a[1], a[2])
end)

concommand.Add("sv_reset", function( p, c, a )
	if !p or !a then return end
	if !Reset then return end
	ResetUser(p)
end)

concommand.Add("sv_readpm", function( p, c, a )
	if !p or !a then return end
	a[1] = tonumber(a[1])
	ReadPM(p, a[1])
	timer.Simple(1, function()
		GetPM(p)
	end)
end)

concommand.Add("sv_getpm", function( p, c, a )
	if !p or !a then return end
	GetPM(p)
end)

concommand.Add("sv_sendpm", function( p, c, a )
	if !p or !a then return end
	SendPM(p, a[1], a[2], a[3])
end)

print("[gForum] Server -> Commands loaded.")