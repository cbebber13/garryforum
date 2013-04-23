
function RegisterUser(self, user, pass, email, group, regdate)
	local salt, hash, key
	if self.Registered then
		umsg.Start("cl_error", self)
			umsg.String("Registeration Error;Your already registered.")
		umsg.End()
		return
	end
	if !user or !pass or !email then
		umsg.Start("cl_register", self)
		umsg.End()
		umsg.Start("cl_error", self)
			umsg.String("Registeration Error;You left a entry blank.")
		umsg.End()
		return
	end
	if !group then group = Group or 0 end
	if !regdate then regdate = os.time() end
	if Forum == "smf" then
		local query1 = database:query("SELECT `member_name` FROM " .. Prefix .. "_members WHERE `member_name`='" .. user .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query, data )
			local Args = query:getData()[1] or nil
			if Args then
				umsg.Start("cl_register", self)
				umsg.End()
				umsg.Start("cl_error", self)
					umsg.String("Registeration Error;This username is taken.")
				umsg.End()
				self.Halt = true
				timer.Simple(3, function()
					// query is to fast because the return is so slow
					self.Halt = false
				end)
				return
			end
		end
		query1:start()
		hash= string.lower(user) .. pass
		local query2 = database:query("SELECT SHA1('" .. hash .. "')")
		query2.onError = function( err, sql )
			MsgN( "Query2 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query2.onSuccess = function( query, data )
			for k, v in pairs(query:getData()[1]) do
				hash = string.lower(v)
				break
			end
			
			if self.Halt then return end
			local query3 = database:query("INSERT INTO " .. Prefix .. "_members (`member_name`, `passwd`, `date_registered`, `id_group`, `real_name`, `email_address`, `member_ip`, `member_ip2`) VALUES('" .. escape(user) .. "', '" .. escape(hash) .. "', '" .. regdate .. "', '" .. group .. "', '" .. escape(user) .. "', '" .. email .. "', '" .. self:IPAddress() .. "', '" .. self:IPAddress() .. "' )" )
			query3.onError = function( err, sql )
				MsgN( "Query3 errored!" )
				MsgN( "Query:", sql )
				MsgN( "Error:", err )
			end
			query3.onSuccess = function( query, data )
				self:ChatPrint("[SMF] Successfully registered user, " .. user)
				LinkUser(self, user, pass)
				self.Registered = true
			end
			query3:start()
		end
		query2:start()
	elseif Forum == "mybb" then
		local query1 = database:query("SELECT `username` FROM " .. Prefix .. "_users WHERE `username`='" .. user .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query, data )
			local Args = query:getData()[1] or nil
			if Args then
				umsg.Start("cl_register", self)
				umsg.End()
				umsg.Start("cl_error", self)
					umsg.String("Registeration Error;This username is taken.")
				umsg.End()
				self.Halt = true
				timer.Simple(3, function()
					// query is to fast because the return is so slow
					self.Halt = false
				end)
				return
			end
		end
		query1:start()
		salt = Salt(self, 8)
		hash = pass
		local query2 = database:query("SELECT MD5('" .. escape(salt) .. "')")
		query2.onError = function( err, sql )
			MsgN( "Query2 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query2.onSuccess = function( query, data )
			for k, v in pairs(query:getData()[1]) do
				hash = hash
				local query3 = database:query("SELECT MD5('" .. escape(hash) .. "')")
				query3.onError = function( err, sql )
					MsgN( "Query3 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query3.onSuccess = function( _query, _data )
					for _k, _v in pairs(_query:getData()[1]) do
						local query4 = database:query("SELECT MD5('" .. escape(v .. _v) .. "')")
						query4.onError = function( err, sql )
							MsgN( "Query4 errored!" )
							MsgN( "Query:", sql )
							MsgN( "Error:", err )
						end
						query4.onSuccess = function( __query, __data )
							for __k, __v in pairs(__query:getData()[1]) do
								hash = __v
								if self.Halt then return end
								local query5 = database:query("INSERT INTO " .. Prefix .. "_users (`username`, `password`, `salt`, `regdate`, `usergroup`, `usertitle`, `email`, `regip`, `lastip`) VALUES('" .. escape(user) .. "', '" .. escape(hash) .. "', '" .. escape(salt) .. "', '" .. regdate .. "', '" .. group .. "', '" .. escape(user) .. "', '" .. email .. "', '" .. self:IPAddress() .. "', '" .. self:IPAddress() .. "' )")
								query5.onError = function( err, sql )
									MsgN( "Query5 errored!" )
									MsgN( "Query:", sql )
									MsgN( "Error:", err )
								end
								query5.onSuccess = function( query, data )
									self:ChatPrint("[MyBB] Successfully registered user, " .. user)
									LinkUser(self, user, pass)
									self.Registered = true
								end
								query5:start()
								break
							end
						end
						query4:start()
						break
					end
				end
				query3:start()
				break
			end
		end
		query2:start()
	elseif Forum == "ipb" then
		local query1 = database:query("SELECT `name` FROM " .. Prefix .. "_members WHERE `name`='" .. user .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query, data )
			local Args = query:getData()[1] or nil
			if Args or Args['name'] == user then
				umsg.Start("cl_register", self)
				umsg.End()
				umsg.Start("cl_error", self)
					umsg.String("Registeration Error;This username is taken.")
				umsg.End()
				self.Halt = true
				timer.Simple(3, function()
					// query is to fast because the return is so slow
					self.Halt = false
				end)
				return
			end
		end
		query1:start()
		salt = Salt(self, 5)
		local key = Salt(self, 32)
		hash = pass
		local query2 = database:query("SELECT MD5('" .. escape(salt) .. "')")
		query2.onError = function( err, sql )
			MsgN( "Query2 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query2.onSuccess = function( query, data )
			for k, v in pairs(query:getData()[1]) do
				local query3 = database:query("SELECT MD5('" .. escape(hash) .. "')")
				query3.onError = function( err, sql )
					MsgN( "Query3 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query3.onSuccess = function( _query, _data )
					for _k, _v in pairs(_query:getData()[1]) do
						local query4 = database:query("SELECT MD5('" .. escape(v .. _v) .. "')")
						query4.onError = function( err, sql )
							MsgN( "Query4 errored!" )
							MsgN( "Query:", sql )
							MsgN( "Error:", err )
						end
						query4.onSuccess = function( __query, __data )
							for __k, __v in pairs(__query:getData()[1]) do
								hash = __v
								if self.Halt then return end
								local query5 = database:query("INSERT INTO " .. Prefix .. "_members (`name`, `member_group_id`, `email`, `joined`, `ip_address`, `title`, `member_login_key`, `members_display_name`, `members_seo_name`, `members_l_display_name`, `members_l_username`, `members_pass_hash`, `members_pass_salt`) VALUES('" .. escape(user) .. "', '" .. group .. "', '" .. escape(email) .. "', '" .. regdate .. "', '" .. escape(self:IPAddress()) .. "', '" .. escape(user) .. "', '" .. escape(key) .. "', '" .. escape(user) .. "', '" .. escape(user) .. "', '" .. escape(user) .. "', '" .. escape(user) .. "', '" .. escape(hash) .. "', '" .. escape(salt) .. "' )")
								query5.onError = function( err, sql )
									MsgN( "Query5 errored!" )
									MsgN( "Query:", sql )
									MsgN( "Error:", err )
								end
								query5.onSuccess = function( query, data )
									self:ChatPrint("[IPB] Successfully registered user, " .. user)
									LinkUser(self, user, pass)
									self.Registered = true
								end
								query5:start()
								break
							end
						end
						query4:start()
						break
					end
				end
				query3:start()
				break
			end
		end
		query2:start()
	else
		local query1 = database:query("SELECT `username` FROM " .. Prefix .. "_user WHERE `username`='" .. user .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query, data )
			local Arg = query:getData()[1] or nil
			if Arg then
				umsg.Start("cl_register", self)
				umsg.End()
				umsg.Start("cl_error", self)
					umsg.String("Registeration Error;This username is taken.")
				umsg.End()
				self.Halt = true
				timer.Simple(3, function()
					// query is to fast because the return is so slow
					self.Halt = false
				end)
				return
			end
		end
		query1:start()
		salt = Salt(self, 64)
		key = Salt(self, 40)
		key = string.lower(tostring(key))
		hash = string.lower(tostring(pass))
		local query2 = database:query("SELECT SHA2('" .. hash .. "', '" .. 256 .. "')")
		query2.onError = function( err, sql )
			MsgN( "Query2 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query2.onSuccess = function( query, data )
			for k, v in pairs(query:getData()[1]) do
				local query3 = database:query("SELECT SHA2('" .. string.lower(v .. salt) .. "', '" .. 256 .. "')")
				query3.onError = function( err, sql )
					MsgN( "Query3 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query3.onSuccess = function( query, data )
					for k, v in pairs(query:getData()[1]) do
						hash = string.lower(v)
						break
					end
					if self.Halt then return end
					hash = tostring('a:3:{s:4:\"hash\";s:64:\"' .. hash .. '\";s:4:\"salt\";s:64:\"' .. salt .. '\";s:8:\"hashFunc\";s:6:\"sha256\";}')
					local query4 = database:query("INSERT INTO " .. Prefix .. "_user (`username`, `email`, `language_id`, `user_group_id`, `display_style_group_id`, `permission_combination_id`, `register_date`, `user_state`) VALUES('" .. escape(user) .. "', '" .. escape(email) .. "', '" .. 1 .. "', '" .. group .. "', '" .. group .. "', '" .. group .. "', '" .. regdate .. "', '" .. escape('valid') .. "')")
					query4.onError = function( err, sql )
						MsgN( "Query4 errored!" )
						MsgN( "Query:", sql )
						MsgN( "Error:", err )
					end
					query4.onSuccess = function( _query )
						local query5 = database:query("SELECT `user_id` FROM " .. Prefix .. "_user WHERE `username`='" .. user .. "'" )
						query5.onError = function( err, sql )
							MsgN( "Query5 errored!" )
							MsgN( "Query:", sql )
							MsgN( "Error:", err )
						end
						query5.onSuccess = function( __query )
							local _Args = __query:getData()[1] or nil
							if _Args then
								local auth = "XenForo_Authentication_Core"
								local query6 = database:query("INSERT INTO " .. Prefix .. "_user_authenticate (`user_id`, `scheme_class`, `data`, `remember_key`) VALUES('" .. _Args['user_id'] .. "', '" .. escape(auth) .. "', '" .. escape(hash) .. "', '" .. escape(key) .."')")
								query6.onError = function( err, sql )
									MsgN( "Query6 errored!" )
									MsgN( "Query:", sql )
									MsgN( "Error:", err )
								end
								query6.onSuccess = function( ___query )
									self:ChatPrint("[XF] Successfully registered user, " .. user)
									LinkUser(self, user, pass)
									self.Registered = true
								end
								local token = Salt(self, 40)
								token = string.lower(tostring(token))
								local query7 = database:query("INSERT INTO " .. Prefix .. "_user_profile (`user_id`, `csrf_token`) VALUES('" .. _Args['user_id'] .. "', '" .. escape(token) .. "')")
								query7.onError = function( err, sql )
									MsgN( "Query7 errored!" )
									MsgN( "Query:", sql )
									MsgN( "Error:", err )
								end
								query7:start()
								local query8 = database:query("INSERT INTO " .. Prefix .. "_user_option (`user_id`) VALUES('" .. _Args['user_id'] .. "')")
								query8.onError = function( err, sql )
									MsgN( "Query8 errored!" )
									MsgN( "Query:", sql )
									MsgN( "Error:", err )
								end
								query8:start()
								local query9 = database:query("INSERT INTO " .. Prefix .. "_user_group_relation (`user_id`, `user_group_id`, `is_primary`) VALUES('" .. _Args['user_id'] .. "', '" .. 2 .. "', '" .. 1 .. "')")
								query9.onError = function( err, sql )
									MsgN( "Query9 errored!" )
									MsgN( "Query:", sql )
									MsgN( "Error:", err )
								end
								query9:start()
								local query10 = database:query("INSERT INTO " .. Prefix .. "_user_privacy (`user_id`) VALUES('" .. _Args['user_id'] .. "')")
								query.onError = function( err, sql )
									MsgN( "Query10 errored!" )
									MsgN( "Query:", sql )
									MsgN( "Error:", err )
								end
								query10:start()
								query6:start()
							end
						end
						query5:start()
					end
					query4:start()
				end
				query3:start()
				break
			end
		end
		query2:start()
	end
end

function LinkUser(self, name, pass)
	local salt, hash
	if self.Halt then return end
	if self.Registered then
		umsg.Start("cl_error", self)
			umsg.String("Link Error;You already linked your account.")
		umsg.End()
		return
	end
	local Password, Salt
	if Forum == "smf" then
		hash = string.lower(name) .. pass
		local query1 = database:query("SELECT SHA1('" .. hash .. "')")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query, data )
			for k, v in pairs(query:getData()[1]) do
				hash = string.lower(v)
				break
			end
			local query2 = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
			query2.onError = function( err, sql )
				MsgN( "Query2 errored!" )
				MsgN( "Query:", sql )
				MsgN( "Error:", err )
			end
			query2.onSuccess = function( query, data )
				local Erg = query:getData()[1] or nil
				if Erg && Erg['id'] then
					self.Registered = true
					self:ChatPrint("[SMF] You've already had your account linked.")
				else
					local query3 = database:query("SELECT `id_member`, `member_name`, `passwd`, `password_salt` FROM " .. Prefix .. "_members WHERE `member_name`='" .. name .. "'")
					query3.onError = function( err, sql )
						MsgN( "Query3 errored!" )
						MsgN( "Query:", sql )
						MsgN( "Error:", err )
					end
					query3.onSuccess = function( _query )
						local Args = _query:getData()[1] or nil
						if !Args or !Args['id_member'] then
							umsg.Start("cl_link", self)
							umsg.End()
							umsg.Start("cl_error", self)
								umsg.String("Link Error;The username you entered wasn't found.")
							umsg.End()
							return
						end
						local query = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `id`='" .. Args['id_member'] .. "'")
						query.onError = function( err, sql )
							MsgN( "Query errored!" )
							MsgN( "Query:", sql )
							MsgN( "Error:", err )
						end
						query.onSuccess = function( query, data )
							local Erg = query:getData()[1] or nil
							if Erg && Erg['id'] then
								umsg.Start("cl_link", self)
								umsg.End()
								umsg.Start("cl_error", self)
									umsg.String("Link Error;That account was already linked.")
								umsg.End()
								return
							else
								if Args['passwd'] == hash then
									local query4 = database:query("INSERT INTO " .. Prefix .. "_link (`id`, `steamid`) VALUES('" .. escape(Args['id_member']) .. "', '" .. escape(self:SteamID()) .. "')")
									query4.onError = function( err, sql )
										MsgN( "Query4 errored!" )
										MsgN( "Query:", sql )
										MsgN( "Error:", err )
									end
									query4.onSuccess = function( __query )
										local _Args = __query:getData()[1] or nil
										self:ChatPrint("[SMF] Your account has been successfully linked.")
										timer.Simple(2, function() 
											GetUserID(self)
										end)
									end
									query4:start()
								elseif Args['passwd'] != hash then
									umsg.Start("cl_link", self)
									umsg.End()
									umsg.Start("cl_error", self)
										umsg.String("Link Error;The password you entered didn't match.")
									umsg.End()
								end
							end
						end
						query:start()
					end
					query3:start()
				end
			end
			query2:start()
		end
		query1:start()
	elseif Forum == "mybb" then
		hash = string.lower(tostring(pass))
		local query1 = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query, data )
			local Arg = query:getData()[1] or nil
			if Arg then
				self.Registered = true
				self:ChatPrint("[MyBB] You've already had your account linked.")
			else
				local query2 = database:query("SELECT `uid`, `username`, `password`, `salt` FROM " .. Prefix .. "_users WHERE `username`='" .. name .. "'")
				query2.onError = function( err, sql )
					MsgN( "Query2 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query2.onSuccess = function( query )
					local Args = query:getData()[1] or nil
					if Args then
						local query = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `id`='" .. Args['uid'] .. "'")
						query.onError = function( err, sql )
							MsgN( "Query errored!" )
							MsgN( "Query:", sql )
							MsgN( "Error:", err )
						end
						query.onSuccess = function( query, data )
							local Erg = query:getData()[1] or nil
							if Erg && Erg['id'] then
								umsg.Start("cl_link", self)
								umsg.End()
								umsg.Start("cl_error", self)
									umsg.String("Link Error;That account was already linked.")
								umsg.End()
								return
							else
								local query3 = database:query("SELECT MD5('" .. escape(Args['salt']) .. "')")
								query3.onError = function( err, sql )
									MsgN( "Query3 errored!" )
									MsgN( "Query:", sql )
									MsgN( "Error:", err )
								end
								query3.onSuccess = function( _query, _data )
									for k, v in pairs(_query:getData()[1]) do
										local query4 = database:query("SELECT MD5('" .. escape(hash) .. "')")
										query4.onError = function( err, sql )
											MsgN( "Query4 errored!" )
											MsgN( "Query:", sql )
											MsgN( "Error:", err )
										end
										query4.onSuccess = function( __query, __data )
											for _k, _v in pairs(__query:getData()[1]) do
												local query5 = database:query("SELECT MD5('" .. escape(v ..  _v) .. "')")
												query5.onError = function( err, sql )
													MsgN( "Query5 errored!" )
													MsgN( "Query:", sql )
													MsgN( "Error:", err )
												end
												query5.onSuccess = function( ___query, ___data )
													for __k, __v in pairs(___query:getData()[1]) do
														hash = string.lower(__v)
														if Args['password'] == hash then
															local query6 = database:query("INSERT INTO " .. Prefix .. "_link (`id`, `steamid`) VALUES('" .. escape(Args['uid']) .. "', '" .. escape(self:SteamID()) .. "')")
															query6.onError = function( err, sql )
																MsgN( "Query6 errored!" )
																MsgN( "Query:", sql )
																MsgN( "Error:", err )
															end
															query6.onSuccess = function( query )
																self:ChatPrint("[MyBB] Your account has been successfully linked.")
																timer.Simple(2, function() 
																	GetUserID(self)
																end)
															end
															query6:start()
														elseif Args['password'] != hash then
															umsg.Start("cl_link", self)
															umsg.End()
															umsg.Start("cl_error", self)
															umsg.String("Link Error;The password you entered didn't match.")
															umsg.End()
														end
														break
													end
												end
												query5:start()
												break
											end
										end
										query4:start()
										break
									end
								end
								query3:start()
							end
						end
						query:start()
					end
				end
				query2:start()
			end
		end
		query1:start()
	elseif Forum == "ipb" then
		hash = string.lower(tostring(pass))
		local query1 = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query, data )
			local Arg = query:getData()[1] or nil
			if Arg then
				self.Registered = true
				self:ChatPrint("[IPB] You've already had your account linked.")
			else
				local query2 = database:query("SELECT `member_id`, `name`, `members_pass_hash`, `members_pass_salt` FROM " .. Prefix .. "_members WHERE `name`='" .. name .. "'")
				query2.onError = function( err, sql )
					MsgN( "Query2 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query2.onSuccess = function( query )
					local Args = query:getData()[1] or nil
					if Args then
						local query = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `id`='" .. Args['member_id'] .. "'")
						query.onSuccess = function( query, data )
							local Erg = query:getData()[1] or nil
							if Erg && Erg['id'] then
								umsg.Start("cl_link", self)
								umsg.End()
								umsg.Start("cl_error", self)
									umsg.String("Link Error;That account was already linked.")
								umsg.End()
								return
							else
								local query3 = database:query("SELECT MD5('" .. escape(Args['members_pass_salt']) .. "')")
								query3.onError = function( err, sql )
									MsgN( "Query3 errored!" )
									MsgN( "Query:", sql )
									MsgN( "Error:", err )
								end
								query3.onSuccess = function( _query, _data )
									for k, v in pairs(_query:getData()[1]) do
										local query4 = database:query("SELECT MD5('" .. escape(hash) .. "')")
										query4.onError = function( err, sql )
											MsgN( "Query4 errored!" )
											MsgN( "Query:", sql )
											MsgN( "Error:", err )
										end
										query4.onSuccess = function( __query, __data )
											for _k, _v in pairs(__query:getData()[1]) do
												local query5 = database:query("SELECT MD5('" .. escape(v ..  _v) .. "')")
												query5.onError = function( err, sql )
													MsgN( "Query5 errored!" )
													MsgN( "Query:", sql )
													MsgN( "Error:", err )
												end
												query5.onSuccess = function( ___query, ___data )
													for __k, __v in pairs(___query:getData()[1]) do
														hash = string.lower(__v)
														if Args['members_pass_hash'] == hash then
															local query6 = database:query("INSERT INTO " .. Prefix .. "_link (`id`, `steamid`) VALUES('" .. escape(Args['member_id']) .. "', '" .. escape(self:SteamID()) .. "')")
															query6.onError = function( err, sql )
																MsgN( "Query6 errored!" )
																MsgN( "Query:", sql )
																MsgN( "Error:", err )
															end
															query6.onSuccess = function( query )
																self:ChatPrint("[IPB] Your account has been successfully linked.")
																timer.Simple(2, function() 
																	GetUserID(self)
																end)
															end
															query6:start()
														elseif Args['members_pass_hash'] != hash then
															umsg.Start("cl_link", self)
															umsg.End()
															umsg.Start("cl_error", self)
															umsg.String("Link Error;The password you entered didn't match.")
															umsg.End()
														end
														break
													end
												end
												query5:start()
												break
											end
										end
										query4:start()
										break
									end
								end
								query3:start()
							end
						end
						query:start()
					end
				end
				query2:start()
			end
		end
		query1:start()
	else
		hash = string.lower(pass)
		local query1 = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query, data )
			local Arg = query:getData()[1] or nil
			if Arg then
				self.Registered = true
				self:ChatPrint("[XF] You've already had your account linked.")
			else
				local query2 = database:query("SELECT `user_id`, `username` FROM " .. Prefix .. "_user WHERE `username`='" .. name .. "'")
				query2.onError = function( err, sql )
					MsgN( "Query2 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query2.onSuccess = function( _query )
					local Args = _query:getData()[1] or nil
					if !Args then
						umsg.Start("cl_link", self)
						umsg.End()
						umsg.Start("cl_error", self)
							umsg.String("Link Error;The username you entered wasn't found.")
						umsg.End()
						query3:abort()
						return
					end
					if Args['user_id'] then
						local query = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `id`='" .. Args['user_id'] .. "'")
						query.onError = function( err, sql )
							MsgN( "Query errored!" )
							MsgN( "Query:", sql )
							MsgN( "Error:", err )
						end
						query.onSuccess = function( query, data )
							local Erg = query:getData()[1] or nil
							if Erg && Erg['id'] then
								umsg.Start("cl_link", self)
								umsg.End()
								umsg.Start("cl_error", self)
									umsg.String("Link Error;That account was already linked.")
								umsg.End()
								return
							else
								local query3 = database:query("SELECT `data` FROM " .. Prefix .. "_user_authenticate WHERE `user_id`='" .. Args['user_id'] .. "'")
								query3.onError = function( err, sql )
									MsgN( "Query3 errored!" )
									MsgN( "Query:", sql )
									MsgN( "Error:", err )
								end
								query3.onSuccess = function( __query )
									local _Args = __query:getData()[1] or nil
									local pass_str = string.Explode('"hash";s:64:"', _Args['data'])
									local salt_str = string.Explode('"salt";s:64:"', _Args['data'])
									local password = ""
									local salt = ""
									if pass_str[2] then
										_pass_str = string.Explode('";s:', pass_str[2])
										password = _pass_str[1] or ""
									end
									if salt_str[2] then
										_salt_str = string.Explode('";s:', salt_str[2])
										salt = _salt_str[1] or ""
									end
									if string.find(_Args['data'], "sha256") then
										local query4 = database:query("SELECT SHA2('" .. hash .. "', '" .. 256 .. "')")
										query4.onError = function( err, sql )
											MsgN( "Query4 errored!" )
											MsgN( "Query:", sql )
											MsgN( "Error:", err )
										end
										query4.onSuccess = function( query, data )
											for k, v in pairs(query:getData()[1]) do
												local query5 = database:query("SELECT SHA2('" .. string.lower(v .. salt) .. "', '" .. 256 .. "')")
												query5.onError = function( err, sql )
													MsgN( "Query5 errored!" )
													MsgN( "Query:", sql )
													MsgN( "Error:", err )
												end
												query5.onSuccess = function( query, data )
													for k, v in pairs(query:getData()[1]) do
														hash = string.lower(v)
														break
													end
													if password == hash then
														local query6 = database:query("INSERT INTO " .. Prefix .. "_link (`id`, `steamid`) VALUES('" .. escape(Args['user_id']) .. "', '" .. escape(self:SteamID()) .. "')")
														query6.onError = function( err, sql )
															MsgN( "Query6 errored!" )
															MsgN( "Query:", sql )
															MsgN( "Error:", err )
														end
														query6.onSuccess = function(___Query, __Args)
															self:ChatPrint("[XF] Your account has been successfully linked.")
															timer.Simple(2, function() 
																GetUserID(self)
															end)
														end
														query6:start()
													elseif password != hash then
														umsg.Start("cl_link", self)
														umsg.End()
														umsg.Start("cl_error", self)
															umsg.String("Link Error;The password you entered didn't match.")
														umsg.End()
													elseif salt == "" then
														umsg.Start("cl_link", self)
														umsg.End()
														umsg.Start("cl_error", self)
															umsg.String("Link Error;Please visit the website an login then retry.")
														umsg.End()
													end
												end
												query5:start()
												break
											end
										end
										query4:start()
									else
										local query4 = database:query("SELECT SHA1('" .. hash .. "')")
										query4.onError = function( err, sql )
											MsgN( "Query4 errored!" )
											MsgN( "Query:", sql )
											MsgN( "Error:", err )
										end
										query4.onSuccess = function( query, data )
											for k, v in pairs(query:getData()[1]) do
												local query5 = database:query("SELECT SHA1('" .. string.lower(v .. salt) .. "')")
												query5.onError = function( err, sql )
													MsgN( "Query5 errored!" )
													MsgN( "Query:", sql )
													MsgN( "Error:", err )
												end
												query5.onSuccess = function( query, data )
													for k, v in pairs(query:getData()[1]) do
														hash = string.lower(v)
														break
													end
													if password == hash then
														local query6 = database:query("INSERT INTO " .. Prefix .. "_link (`id`, `steamid`) VALUES('" .. escape(Args['user_id']) .. "', '" .. escape(self:SteamID()) .. "')")
														query6.onError = function( err, sql )
															MsgN( "Query6 errored!" )
															MsgN( "Query:", sql )
															MsgN( "Error:", err )
														end
														query6.onSuccess = function(___Query, __Args)
															self:ChatPrint("[XF] Your account has been successfully linked.")
															timer.Simple(2, function() 
																GetUserID(self)
															end)
														end
														query6:start()
													elseif password != hash then
														umsg.Start("cl_link", self)
														umsg.End()
														umsg.Start("cl_error", self)
															umsg.String("Link Error;The password you entered didn't match.")
														umsg.End()
													elseif salt == "" then
														umsg.Start("cl_link", self)
														umsg.End()
														umsg.Start("cl_error", self)
															umsg.String("Link Error;Please visit the website an login then retry.")
														umsg.End()
													end
												end
												query5:start()
												break
											end
										end
										query4:start()
									end
								end
								query3:start()
							end
						end
						query:start()
					end
				end
				query2:start()
			end
		end
		query1:start()
	end
end

function GetUserID(self)
	local group
	if Forum == "smf" then
		local query1 = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query, data )
			local Arg = query:getData()[1] or nil
			if Arg then
				self.Registered = true
				self:ChatPrint("[SMF] Welcome back " .. self:Nick() .. ", Remember to visit our forums @ " .. URL )
				local query2 = database:query("SELECT `id_member`, `member_name`, `id_group`, `personal_text` FROM " .. Prefix .. "_members WHERE `id_member`='" .. Arg['id'] .. "'")
				query2.onError = function( err, sql )
					MsgN( "Query2 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query2.onSuccess = function( _query )
					local Args = _query:getData()[1] or nil
					if Args['id_member'] then
						if Alias then
							if Args['personal_text'] != self:Nick() then
								database:query("UPDATE " .. Prefix .. "_members SET `personal_text`='" .. escape(self:Nick()) .."' WHERE `id_member`='" .. Arg['id'] .. "'")
							end
						end
						local query3 = database:query("SELECT `group_name`,`id_group` FROM " .. Prefix .. "_membergroups WHERE `id_group`='" .. Args['id_group'] .. "'")
						query3.onError = function( err, sql )
							MsgN( "Query3 errored!" )
							MsgN( "Query:", sql )
							MsgN( "Error:", err )
						end
						query3.onSuccess = function( __query )
							local _Args = __query:getData()[1] or nil
							if !_Args['group_name'] then
								group = "Registered"
							else
								group = _Args['group_name']
							end
							if tonumber(_Args['id_group']) == BanGroup and Kick then
								self:Kick("Your are currently banned on our forums.")
							end
							
							umsg.Start("cl_setinfo", self)
								umsg.String(Args['member_name'])
								umsg.String(group)
								umsg.String(URL)
							umsg.End()
							
							local tbl = { self:Nick(), Args['member_name'], self:UniqueID(), Arg['id'] }
							ForumUsers[Arg['id']] = tbl
							
							util.AddNetworkString("ForumUsers")
							net.Start("ForumUsers")
								net.WriteTable(ForumUsers)
							net.Send(self)
							
							if Admin then
								CheckUserGroup(self, Args['id_member'], _Args['id_group'], _Args['group_name'])
							end
						end
						query3:start()
					end
				end
				query2:start()
			else
				self.Registered = false
				umsg.Start("cl_register", self)
				umsg.End()
				umsg.Start("cl_error", self)
					umsg.String("Attention;Please register or link an account.")
				umsg.End()
			end
		end
		query1:start()
	elseif Forum == "mybb" then
		local query1 = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query, data )
			local Arg = query:getData()[1] or nil
			if Arg then
				self.Registered = true
				self:ChatPrint("[MyBB] Welcome back " .. self:Nick() .. ", Remember to visit our forums @ " .. URL )
				local query2 = database:query("SELECT `uid`, `username`, `usergroup`, `postnum`, `usertitle` FROM " .. Prefix .. "_users WHERE `uid`='" .. Arg['id'] .. "'")
				query2.onError = function( err, sql )
					MsgN( "Query2 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query2.onSuccess = function( _query )
					local Args = _query:getData()[1] or nil
					if Args['uid'] then
						if Alias then
							if Args['usertitle'] != self:Nick() then
								local query3 = database:query("UPDATE " .. Prefix .. "_users SET `usertitle`='" .. escape(self:Nick()) .."' WHERE `uid`='" .. Arg['id'] .. "'")
								query3.onError = function( err, sql )
									MsgN( "Query3 errored!" )
									MsgN( "Query:", sql )
									MsgN( "Error:", err )
								end
								query3:start()
							end
						end
						local query4 = database:query("SELECT `title`, `gid` FROM " .. Prefix .. "_usergroups WHERE `gid`='" .. Args['usergroup'] .. "'")
						query4.onError = function( err, sql )
							MsgN( "Query4 errored!" )
							MsgN( "Query:", sql )
							MsgN( "Error:", err )
						end
						query4.onSuccess = function( __query )
						local _Args = __query:getData()[1] or nil
							if !_Args['title'] then
								group = "Registered"
							else
								group = _Args['title']
							end
							if tonumber(_Args['gid']) == BanGroup and Kick then
								self:Kick("Your are currently banned on our forums.")
							end
							umsg.Start("cl_setinfo", self)
								umsg.String(Args['username'])
								umsg.String(group)
								umsg.String(URL)
							umsg.End()
							
							local tbl = { self:Nick(), Args['username'], self:UniqueID(), Arg['id'] }
							ForumUsers[Arg['id']] = tbl
							
							util.AddNetworkString("ForumUsers")
							net.Start("ForumUsers")
								net.WriteTable(ForumUsers)
							net.Send(self)
							
							if Admin then
								CheckUserGroup(self, Args['uid'], _Args['gid'], _Args['title'])
							end
						end
						query4:start()
					end
				end
				query2:start()
			else
				self.Registered = false
				umsg.Start("cl_register", self)
				umsg.End()
				umsg.Start("cl_error", self)
					umsg.String("Attention;Please register or link an account.")
				umsg.End()
			end
		end
		query1:start()
	elseif Forum == "ipb" then
		local query1 = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query, data )
			local Arg = query:getData()[1] or nil
			if Arg then
				self.Registered = true
				self:ChatPrint("[IPB] Welcome back " .. self:Nick() .. ", Remember to visit our forums @ " .. URL )
				local query2 = database:query("SELECT `member_id`, `name`, `member_group_id`, `posts`, `title` FROM " .. Prefix .. "_members WHERE `member_id`='" .. Arg['id'] .. "'")
				query2.onError = function( err, sql )
					MsgN( "Query2 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query2.onSuccess = function( _query )
					local Args = _query:getData()[1] or nil
					if Args['member_id'] then
						if Alias then
							if Args['title'] != self:Nick() then
								local query3 = database:query("UPDATE " .. Prefix .. "_members SET `title`='" .. escape(self:Nick()) .."' WHERE `member_id`='" .. Arg['id'] .. "'")
								query3.onError = function( err, sql )
									MsgN( "Query3 errored!" )
									MsgN( "Query:", sql )
									MsgN( "Error:", err )
								end
								query3:start()
							end
						end
						local query4 = database:query("SELECT `g_title`, `g_id` FROM " .. Prefix .. "_groups WHERE `g_id`='" .. Args['member_group_id'] .. "'")
						query4.onError = function( err, sql )
							MsgN( "Query4 errored!" )
							MsgN( "Query:", sql )
							MsgN( "Error:", err )
						end
						query4.onSuccess = function( __query )
						local _Args = __query:getData()[1] or nil
							if !_Args['g_title'] then
								group = "Members"
							else
								group = _Args['g_title']
							end
							if tonumber(_Args['g_id']) == BanGroup and Kick then
								self:Kick("Your are currently banned on our forums.")
							end
							umsg.Start("cl_setinfo", self)
								umsg.String(Args['name'])
								umsg.String(group)
								umsg.String(URL)
							umsg.End()
							
							local tbl = { self:Nick(), Args['name'], self:UniqueID(), Arg['id'] }
							ForumUsers[Arg['id']] = tbl
							
							util.AddNetworkString("ForumUsers")
							net.Start("ForumUsers")
								net.WriteTable(ForumUsers)
							net.Send(self)
							
							if Admin then
								CheckUserGroup(self, Args['member_id'], _Args['g_id'], _Args['g_title'])
							end
						end
						query4:start()
					end
				end
				query2:start()
			else
				self.Registered = false
				umsg.Start("cl_register", self)
				umsg.End()
				umsg.Start("cl_error", self)
					umsg.String("Attention;Please register or link an account.")
				umsg.End()
			end
		end
		query1:start()
	else
		local query1 = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query, data )
			local Arg = query:getData()[1] or nil
			if Arg && Arg['id'] then
				self.Registered = true
				self:ChatPrint("[XF] Welcome back " .. self:Nick() .. ", Remember to visit our forums @ " .. URL )
				local query2 = database:query("SELECT `user_id`, `username`, `user_group_id`, `message_count`, `custom_title` FROM " .. Prefix .. "_user WHERE `user_id`='" .. Arg['id'] .. "'")
				query2.onError = function( err, sql )
					MsgN( "Query2 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query2.onSuccess = function( _query )
					local Args = _query:getData()[1] or nil
					if Args['user_id'] then
						if Alias then
							if Args['custom_title'] != self:Nick() then
								local query3 = database:query("UPDATE " .. Prefix .. "_user SET `custom_title`='" .. escape(self:Nick()) .."' WHERE `user_id`='" .. Arg['id'] .. "'")
								query3.onError = function( err, sql )
									MsgN( "Query3 errored!" )
									MsgN( "Query:", sql )
									MsgN( "Error:", err )
								end
								query3:start()
							end
						end
						local query4 = database:query("SELECT `user_title`, `user_group_id` FROM " .. Prefix .. "_user_group WHERE `user_group_id`='" .. Args['user_group_id'] .. "'")
						query4.onError = function( err, sql )
							MsgN( "Query4 errored!" )
							MsgN( "Query:", sql )
							MsgN( "Error:", err )
						end
						query4.onSuccess = function( __query )
							local _Args = __query:getData()[1] or nil
							if !_Args['user_title'] or _Args['user_title'] == "" then
								group = "Registered"
							else
								group = _Args['user_title']
							end
							if tonumber(_Args['user_group_id']) == BanGroup and Kick then
								self:Kick("Your are currently banned on our forums.")
							end
							umsg.Start("cl_setinfo", self)
								umsg.String(Args['username'])
								umsg.String(group)
								umsg.String(URL) 
							umsg.End()
							
							local tbl = { self:Nick(), Args['username'], self:UniqueID(), Arg['id'] }
							ForumUsers[Arg['id']] = tbl
							
							util.AddNetworkString("ForumUsers")
							net.Start("ForumUsers")
								net.WriteTable(ForumUsers)
							net.Send(self)
							
							if Admin then
								CheckUserGroup(self, Args['user_id'], _Args['user_group_id'], _Args['user_title'])
							end
						end
						query4:start()
					end
				end
				query2:start()
			else
				self.Registered = false
				umsg.Start("cl_register", self)
				umsg.End()
				umsg.Start("cl_error", self)
					umsg.String("Attention;Please register or link an account.")
				umsg.End()
			end
		end
		query1:start()
	end
end

function CheckUserGroup( self, id, gid, name )
	if !self or !id or !gid or !name then return end
	id, gid = tonumber(id), tonumber(gid)
	local query1 = database:query("SELECT * FROM " .. Prefix .. "_rank WHERE `steamid`='" .. self:SteamID() .. "'")
	query1.onError = function( err, sql )
		MsgN( "Query1 errored!" )
		MsgN( "Query:", sql )
		MsgN( "Error:", err )
	end
	query1.onSuccess = function( query )
		local Arg = query:getData()[1] or nil
		if !Arg and Group != gid then
			local query2 = database:query("INSERT INTO " .. Prefix .. "_rank (`id`, `rank`, `steamid`) VALUES('" .. id .. "', '" .. escape(name) .. "', '" .. escape(self:SteamID()) .. "')" )
			query2.onError = function( err, sql )
				MsgN( "Query2 errored!" )
				MsgN( "Query:", sql )
				MsgN( "Error:", err )
			end
			query2.onSuccess = function( _query )
			local Args = _query:getData()[1] or nil
				if Group == gid then return end
				if ULib and ULib.ucl then
					self:ChatPrint("[gForum] Your ulx admin access was set to " .. name .. ".")
					local plyInfo = ULib.ucl.authed[self:UniqueID()]
					ULib.ucl.addUser(self:SteamID(), plyInfo.allow or {}, plyInfo.deny or {}, name:lower())
				else
					self:ChatPrint("[gForum] Your evolve admin access was set to " .. name .. ".")
					self:EV_SetRank(name:lower())
				end
			end
			query2:start()
		else
			if Group != gid then
				local query2 = database:query("UPDATE " .. Prefix .. "_rank SET `rank`='" .. name .. "' WHERE `steamid`='" .. self:SteamID() .. "'" )
				query2.onError = function( err, sql )
					MsgN( "Query2 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query2.onSuccess = function( _query )
				local Args = _query:getData()[1] or nil
					if ULib and ULib.ucl then
						self:ChatPrint("[gForum] Your ulx admin access was set to " .. name .. ".")
						local plyInfo = ULib.ucl.authed[self:UniqueID()]
						ULib.ucl.addUser(self:SteamID(), plyInfo.allow or {}, plyInfo.deny or {}, name:lower())
					else
						self:ChatPrint("[gForum] Your evolve admin access was set to " .. name .. ".")
						self:EV_SetRank(name:lower())
					end
				end
				query2:start()
			else
				if ULib and ULib.ucl then
					self:ChatPrint("[gForum] Your ulx admin access was revoked.")
					ULib.ucl.removeUser(self:SteamID())
				else
					self:ChatPrint("[gForum] Your evolve admin access was revoked.")
					self:EV_SetRank("guest")
				end
				local query2 = database:query("DELETE FROM " .. Prefix .. "_rank WHERE `steamid`='" .. self:SteamID() .. "'")
				query2.onError = function( err, sql )
					MsgN( "Query2 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query2:start()
			end
		end
	end
	query1:start()
end

function GetPM( self )
	if Forum == "smf" then
		local query1 = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query )
			local Arg = query:getData()[1] or nil
			if !Arg then
				self.Registered = false
				umsg.Start("cl_register", self)
				umsg.End()
				umsg.Start("cl_error", self)
					umsg.String("Attention;Please register or link an account.")
				umsg.End()
				return
			end
			if Arg then
				local query2 = database:query("SELECT `id_pm` FROM " .. Prefix .. "_pm_recipients WHERE `id_member`='" .. Arg['id'] .. "' AND `is_new`='" .. 1 .. "'")
				query2.onError = function( err, sql )
					MsgN( "Query2 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query2.onSuccess = function( _query )
					local Args = _query:getData()[1] or nil
					if !Args then return end
					local query3 = database:query("SELECT `id_pm`, `from_name`, `subject`, `body` FROM " .. Prefix .. "_personal_messages WHERE `id_pm`='" .. Args['id_pm'] .. "'")
					query3.onError = function( err, sql )
						MsgN( "Query3 errored!" )
						MsgN( "Query:", sql )
						MsgN( "Error:", err )
					end
					query3.onSuccess = function ( __query )
						local _Args = __query:getData()[1] or nil
						util.AddNetworkString("PersonalMessage")
						net.Start("PersonalMessage")
							net.WriteTable({_Args['from_name'], _Args['subject'], _Args['body'], Args['id_pm']})
						net.Send(self)
					end
					query3:start()
				end
				query2:start()
			end
		end
		query1:start()
	elseif Forum == "mybb" then
		local query1 = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query )
			local Arg = query:getData()[1] or nil
			if !Arg then
				self.Registered = false
				umsg.Start("cl_register", self)
				umsg.End()
				umsg.Start("cl_error", self)
					umsg.String("Attention;Please register or link an account.")
				umsg.End()
				return
			end
			if Arg then
				local query2 = database:query("SELECT `pmid`, `fromid`, `subject`, `message` FROM " .. Prefix .. "_privatemessages WHERE `toid`= '" .. Arg['id'] .. "' AND `status`='" .. 0 .. "'")
				query2.onError = function( err, sql )
					MsgN( "Query2 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query2.onSuccess = function( _query )
					local Args = _query:getData()[1] or nil
					if !Args then return end
					local query3 = database:query("SELECT `username` FROM " .. Prefix .. "_users WHERE `uid`='" .. Args['fromid'] .. "'")
					query3.onError = function( err, sql )
						MsgN( "Query3 errored!" )
						MsgN( "Query:", sql )
						MsgN( "Error:", err )
					end
					query3.onSuccess = function( __query )
						local _Args = __query:getData()[1] or nil
						if !_Args then return end
						util.AddNetworkString("PersonalMessage")
						net.Start("PersonalMessage")
							net.WriteTable({_Args['username'], Args['subject'], Args['message'], Args['pmid']})
						net.Send(self)
					end
					query3:start()
				end
				query2:start()
			end
		end
		query1:start()
	elseif Forum == "ipb" then
		local query1 = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query )
			local Arg = query:getData()[1] or nil
			if !Arg then
				self.Registered = false
				umsg.Start("cl_register", self)
				umsg.End()
				umsg.Start("cl_error", self)
					umsg.String("Attention;Please register or link an account.")
				umsg.End()
				return
			end
			if Arg then
				local query2 = database:query("SELECT `mt_id`, `mt_title`, `mt_to_member_id` FROM " .. Prefix .. "_message_topics WHERE `mt_to_member_id`='" .. Arg['id'] .. "' AND `mt_is_deleted`='" .. 0 .. "'")
				query2.onError = function( err, sql )
					MsgN( "Query2 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query2.onSuccess = function( _query )
					local Args = _query:getData()[1] or nil
					if !Args then return end
					local query3 = database:query("SELECT `map_read_time` FROM " .. Prefix .. "_message_topic_user_map WHERE `map_topic_id`='" .. Args['mt_id'] .. "' AND `map_read_time`='" .. 0 .. "' AND `map_has_unread`='" .. 1 .. "'")
					query3.onError = function( err, sql )
						MsgN( "Query3 errored!" )
						MsgN( "Query:", sql )
						MsgN( "Error:", err )
					end
					query3.onSuccess = function( __query )
						local _Arg = __query:getData()[1] or nil
						if _Arg and tonumber(_Arg['map_read_time']) == 0 then
							local query4 = database:query("SELECT `msg_post`, `msg_author_id` FROM " .. Prefix .. "_message_posts WHERE `msg_topic_id`='" .. Args['mt_id'] .. "'")
							query4.onError = function( err, sql )
								MsgN( "Query4 errored!" )
								MsgN( "Query:", sql )
								MsgN( "Error:", err )
							end
							query4.onSuccess = function( __query )
								local __Arg = __query:getData()[1] or nil
								if __Arg then
									local query5 = database:query("SELECT `name` FROM " .. Prefix .. "_members WHERE `member_id`='" .. __Arg['msg_author_id'] .. "'")
									query5.onError = function( err, sql )
										MsgN( "Query5 errored!" )
										MsgN( "Query:", sql )
										MsgN( "Error:", err )
									end
									query5.onSuccess = function( __query )
										local ___Arg = __query:getData()[1] or nil
										util.AddNetworkString("PersonalMessage")
										net.Start("PersonalMessage")
											net.WriteTable({___Arg['name'], Args['mt_title'], __Arg['msg_post'], Args['mt_id']})
										net.Send(self)
									end
									query5:start()
								end
							end
							query4:start()
						end
					end
					query3:start()
				end
				query2:start()
			end
		end
		query1:start()
	else
		local query1 = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query )
			local Arg = query:getData()[1] or nil
			if !Arg then
				self.Registered = false
				umsg.Start("cl_register", self)
				umsg.End()
				umsg.Start("cl_error", self)
					umsg.String("Attention;Please register or link an account.")
				umsg.End()
				return
			end
			if Arg then
				local query2 = database:query("SELECT `conversation_id` FROM " .. Prefix .. "_conversation_user WHERE `owner_user_id`='" .. Arg['id'] .. "' AND `is_unread`='" .. 1 .. "'")
				query2.onError = function( err, sql )
					MsgN( "Query2 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query2.onSuccess = function( _query )
					local Args = _query:getData()[1] or nil
					if !Args then return end
					local query3 = database:query("SELECT `username`, `message` FROM " .. Prefix .. "_conversation_message WHERE `conversation_id`='" .. Args['conversation_id'] .. "'")
					query.onError = function( err, sql )
						MsgN( "Query errored!" )
						MsgN( "Query:", sql )
						MsgN( "Error:", err )
					end
					query3.onSuccess = function( __query )
						local _Args = __query:getData()[1] or nil
						if !_Args then return end
						local query4 = database:query("SELECT `title` FROM " .. Prefix .. "_conversation_master WHERE `conversation_id`='" .. Args['conversation_id'] .. "'")
						query3.onError = function( err, sql )
							MsgN( "Query3 errored!" )
							MsgN( "Query:", sql )
							MsgN( "Error:", err )
						end
						query4.onSuccess = function( ___query )
							local __Args = ___query:getData()[1] or nil
							util.AddNetworkString("PersonalMessage")
							net.Start("PersonalMessage")
								net.WriteTable({_Args['username'], __Args['title'], _Args['message'], Args['conversation_id']})
							net.Send(self)
						end
						query4:start()
					end
					query3:start()
				end
				query2:start()
			end
		end
		query1:start()
	end
end

function ReadPM( self, id )
	if !id then return end
	id = tonumber(id)
	local time = os.time()
	if Forum == "smf" then
		local query1 = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query )
			local Arg = query:getData()[1] or nil
			if !Arg then
				self.Registered = false
				umsg.Start("cl_register", self)
				umsg.End()
				umsg.Start("cl_error", self)
					umsg.String("Attention;Please register or link an account.")
				umsg.End()
				return
			end
			if Arg then
				local query2 = database:query("SELECT `id_pm` FROM " .. Prefix .. "_pm_recipients WHERE `id_member`='" .. Arg['id'] .. "' AND `is_new`='" .. 1 .."'")
				query2.onError = function( err, sql )
					MsgN( "Query2 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query2.onSuccess = function( _query )
					if !_Args then return end
					local query3 = database:query("UPDATE " .. Prefix .. "_pm_recipients SET is_new='" .. 0 .. "', is_read='" .. 1 .. "' WHERE id_pm='" .. id .. "' AND `is_new`='" .. 1 .."'")
					query3.onError = function( err, sql )
						MsgN( "Query3 errored!" )
						MsgN( "Query:", sql )
						MsgN( "Error:", err )
					end
					query3:start()
				end
				query2:start()
			end
		end
		query1:start()
	elseif Forum == "mybb" then
		local query1 = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query )
			local Arg = query:getData()[1] or nil
			if !Arg then
				self.Registered = false
				umsg.Start("cl_register", self)
				umsg.End()
				umsg.Start("cl_error", self)
					umsg.String("Attention;Please register or link an account.")
				umsg.End()
				return
			end
			if Arg then
				local query2 = database:query("SELECT `pmid` FROM " .. Prefix .. "_privatemessages WHERE `toid`='" .. Arg['id'] .. "' AND `status`='" .. 0 .."'")
				query2.onError = function( err, sql )
					MsgN( "Query2 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query2.onSuccess = function( _query )
					local Args = _query:getData()[1] or nil
					if !Args then return end
					local query3 = database:query("UPDATE " .. Prefix .. "_privatemessages SET status='" .. 1 .. "', readtime='" .. time .. "' WHERE `toid`='" .. Arg['id'] .. "' AND `status`='" .. 0 .."'")
					query3.onError = function( err, sql )
						MsgN( "Query3 errored!" )
						MsgN( "Query:", sql )
						MsgN( "Error:", err )
					end
					query3:start()
				end
				query2:start()
			end
		end
		query1:start()
	elseif Forum == "ipb" then
		local query1 = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query )
			local Arg = query:getData()[1] or nil
			if !Arg then
				self.Registered = false
				umsg.Start("cl_register", self)
				umsg.End()
				umsg.Start("cl_error", self)
					umsg.String("Attention;Please register or link an account.")
				umsg.End()
				return
			end
			if Arg then
				local query2 = database:query("SELECT `map_topic_id` FROM " .. Prefix .. "_message_topic_user_map WHERE `map_topic_id`='" .. Arg['id'] .. "' AND `map_has_unread`='" .. 1 .."'")
				query2.onError = function( err, sql )
					MsgN( "Query2 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query2.onSuccess = function( _query )
					local Args = _query:getData()[1] or nil
					if !Args then return end
					local query3 = database:query("UPDATE " .. Prefix .. "_message_topic_user_map SET map_has_unread='" .. 0 .. "', readtime='" .. time .. "' WHERE `map_user_id`='" .. Arg['id'] .. "' AND `map_has_unread`='" .. 1 .."'")
					query3.onError = function( err, sql )
						MsgN( "Query3 errored!" )
						MsgN( "Query:", sql )
						MsgN( "Error:", err )
					end
					query3:start()
				end
				query2:start()
			end
		end
		query1:start()
	else
		local query1 = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query )
			local Arg = query:getData()[1] or nil
			if !Arg then
				self.Registered = false
				umsg.Start("cl_register", self)
				umsg.End()
				umsg.Start("cl_error", self)
					umsg.String("Attention;Please register or link an account.")
				umsg.End()
				return
			end
			if Arg then
				local query2 = database:query("SELECT `conversation_id` FROM " .. Prefix .. "_conversation_user WHERE `owner_user_id`='" .. Arg['id'] .. "' AND `is_unread`='" .. 1 .."'")
				query2.onError = function( err, sql )
					MsgN( "Query2 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query2.onSuccess = function( _query )
					local Args = _query:getData()[1] or nil
					if !Args then return end
					local query3 = database:query("UPDATE " .. Prefix .. "_conversation_user SET `is_unread`='" .. 0 .."' WHERE `owner_user_id`='" .. Arg['id'] .. "' AND `is_unread`='" .. 1 .."'")
					query3.onError = function( err, sql )
						MsgN( "Query3 errored!" )
						MsgN( "Query:", sql )
						MsgN( "Error:", err )
					end
					query3:start()
				end
				query2:start()
			end
		end
		query1:start()
	end
end

function SendPM( self, who, sub, msg )
	if !who or !sub or !msg then return end
	local time = os.time()
	if Forum == "smf" then
		local query1 = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query )
			local Arg = query:getData()[1] or nil
			if !Arg then
				self.Registered = false
				umsg.Start("cl_register", self)
				umsg.End()
				umsg.Start("cl_error", self)
					umsg.String("Attention;Please register or link an account.")
				umsg.End()
				return
			end
			if Arg then
				local query2 = database:query("SELECT `id_member` FROM " .. Prefix .. "_members WHERE `member_name`='" .. who .. "'")
				query2.onError = function( err, sql )
					MsgN( "Query2 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query2.onSuccess = function( _query )
					local Args = _query:getData()[1] or nil
					if !Args then
						umsg.Start("cl_error", self)
							umsg.String("Send PM;Their is no user with that name.")
						umsg.End()
						return
					end
					if Args then
						local query3 = database:query("SELECT `member_name` FROM " .. Prefix .. "_members WHERE `id_member`='" .. Arg['id'] .. "'")
						query3.onError = function( err, sql )
							MsgN( "Query3 errored!" )
							MsgN( "Query:", sql )
							MsgN( "Error:", err )
						end
						query3.onSuccess = function( __query )
							local _Args = __query:getData()[1] or nil
							if _Args then
								local query4 = database:query("INSERT INTO " .. Prefix .. "_personal_messages (`id_member_from`, `deleted_by_sender`, `from_name`, `msgtime`, `subject`, `body`) VALUES('" .. Arg['id'] .. "', '" .. 0 .. "', '" .. escape(_Args['member_name']) .. "', '" .. time .. "', '" .. escape(sub) .. "', '" .. escape(msg) .. "')")
								query4.onError = function( err, sql )
									MsgN( "Query4 errored!" )
									MsgN( "Query:", sql )
									MsgN( "Error:", err )
								end
								query4:start()
								local query5 = database:query("SELECT `id_pm` FROM " .. Prefix .. "_personal_messages WHERE `id_member_from`='" .. Arg['id'] .. "' AND `from_name`='" .. _Args['member_name'] .. "' AND `subject`='" .. sub .. "' AND `body`='" .. msg .. "' AND `msgtime`='" .. time .. "'")
								query5.onError = function( err, sql )
									MsgN( "Query5 errored!" )
									MsgN( "Query:", sql )
									MsgN( "Error:", err )
								end
								query5.onSuccess = function( ___query )
									local __Args = ___query:getData()[1] or nil
									if __Args then
										local query6 = database:query("INSERT INTO  " .. Prefix .. "_pm_recipients (`id_pm`, `id_member`, `labels`, `bcc`, `is_read`, `is_new`, `deleted`) VALUES('" .. __Args['id_pm'] .. "', '" .. Args['id_member'] .. "', '" .. -1 .. "', '" .. 0 .. "', '" .. 0 .. "', '" .. 1 .. "', '" .. 0 .. "')")
										query6.onError = function( err, sql )
											MsgN( "Query6 errored!" )
											MsgN( "Query:", sql )
											MsgN( "Error:", err )
										end
										query6.onSuccess = function( ____query )
											self:ChatPrint("Sent PM to " .. who .. " titled " .. sub .. ".")
										end
										query6:start()
									end
								end
								query5:start()
							end
						end
						query3:start()
					end
				end
				query2:start()
			end
		end
		query1:start()
	elseif Forum == "mybb" then
		local query1 = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query )
			local Arg = query:getData()[1] or nil
			if !Arg then
				self.Registered = false
				umsg.Start("cl_register", self)
				umsg.End()
				umsg.Start("cl_error", self)
					umsg.String("Attention;Please register or link an account.")
				umsg.End()
				return
			end
			if Arg then
				local query2 = database:query("SELECT `uid` FROM " .. Prefix .. "_users WHERE `username`='" .. who .. "'")
				query2.onError = function( err, sql )
					MsgN( "Query2 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query2.onSuccess = function( _query )
					local Args = _query:getData()[1] or nil
					if !Args then
						umsg.Start("cl_error", self)
							umsg.String("Send PM;Their is no user with that name.")
						umsg.End()
						return
					end
					if Args then
						local reps = 'a:1:{s:2:"to";a:1:{i:0;s:1:"' .. Args['uid'] .. '";}}'
						local query3 = database:query("INSERT INTO " .. Prefix .. "_privatemessages (`uid`, `toid`, `fromid`, `recipients`, `folder`, `subject`, `icon`, `message`, `dateline`, `receipt`, `readtime`) VALUES('" .. Args['uid'] .. "', '" .. Args['uid'] .. "', '" .. Arg['id'] .. "', '" .. escape(reps) .. "', '" .. 1 .. "', '" .. escape(sub) .. "', '" .. 0 .. "', '" .. escape(msg) .. "', '" .. time .. "', '" .. 0 .. "', '" .. 0 .. "')")
						query3.onError = function( err, sql )
							MsgN( "Query3 errored!" )
							MsgN( "Query:", sql )
							MsgN( "Error:", err )
						end
						local query4 = database:query("INSERT INTO " .. Prefix .. "_privatemessages (`uid`, `toid`, `fromid`, `recipients`, `folder`, `subject`, `icon`, `message`, `dateline`, `status`, `receipt`, `readtime`) VALUES('" .. Arg['id'] .. "', '" .. Args['uid'] .. "', '" .. Arg['id'] .. "', '" .. escape(reps) .. "', '" .. 2 .. "', '" .. escape(sub) .. "', '" .. 0 .. "', '" .. escape(msg) .. "', '" .. time .. "', '" .. 1 .. "', '" .. 0 .. "', '" .. 0 .. "')")
						query4.onError = function( err, sql )
							MsgN( "Query4 errored!" )
							MsgN( "Query:", sql )
							MsgN( "Error:", err )
						end
						query3:start()
						query4:start()
						self:ChatPrint("Sent PM to " .. who .. " titled " .. sub .. ".")
					end
				end
				query2:start()
			end
		end
		query1:start()
	elseif Forum == "ipb" then
		local query1 = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query )
			local Arg = query:getData()[1] or nil
			if !Arg then
				self.Registered = false
				umsg.Start("cl_register", self)
				umsg.End()
				umsg.Start("cl_error", self)
					umsg.String("Attention;Please register or link an account.")
				umsg.End()
				return
			end
			if Arg then
				local query2 = database:query("SELECT `member_id` FROM " .. Prefix .. "_members WHERE `name`='" .. who .. "'")
				query2.onError = function( err, sql )
					MsgN( "Query2 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query2.onSuccess = function( _query )
					local Args = _query:getData()[1] or nil
					if !Args then
						umsg.Start("cl_error", self)
							umsg.String("Send PM;Their is no user with that name.")
						umsg.End()
						return
					end
					if Arg['id'] == Args['member_id'] then
						umsg.Start("cl_error", self)
							umsg.String("Send PM;You can't send a pm to your self.")
						umsg.End()
						return
					end
					if Args then
						local rep = "a:0:{}"
						local folder = "myconvo"
						local query3 = database:query("INSERT INTO " .. Prefix .. "_message_topics (`mt_date`, `mt_title`, `mt_starter_id`, `mt_start_time`, `mt_last_post_time`, `mt_invited_members`, `mt_to_count`, `mt_to_member_id`, `mt_last_msg_id`, `mt_first_msg_id`) VALUES( '" .. time .. "', '" .. escape(sub) .. "', '" .. Arg['id'] .. "', '" .. time .. "', '" .. time .. "', '" .. escape(rep) .. "', '" .. 1 .. "', '" .. Args['member_id'] .. "', '" .. Arg['id'] .. "', '" .. Arg['id'] .. "' )")
						query3:start()
						query3.onError = function( err, sql )
							MsgN( "Query3 errored!" )
							MsgN( "Query:", sql )
							MsgN( "Error:", err )
						end
						local query4 = database:query("SELECT `mt_id` FROM " .. Prefix .. "_message_topics WHERE `mt_starter_id`='" .. Arg['id'] .. "' AND `mt_start_time`='" .. time .. "'")
						query4.onError = function( err, sql )
							MsgN( "Query4 errored!" )
							MsgN( "Query:", sql )
							MsgN( "Error:", err )
						end
						query4.onSuccess = function( _query )
						local _Arg = _query:getData()[1] or nil
							if _Arg then
								local query5 = database:query("INSERT INTO " .. Prefix .. "_message_posts (`msg_id`, `msg_topic_id`, `msg_date`, `msg_post`, `msg_author_id`, `msg_ip_address`, `msg_is_first_post`) VALUES('" .. _Arg['mt_id'] .. "', '" .. _Arg['mt_id'] .. "', '" .. time .. "', '" .. msg .. "', '" .. Arg['id'] .. "', '" .. escape(self:IPAddress()) .. "', '" .. 1 .. "')")
								local query6 = database:query("INSERT INTO " .. Prefix .. "_message_topic_user_map (`map_user_id`, `map_topic_id`, `map_folder_id`, `map_read_time`, `map_user_active`, `map_has_unread`, `map_is_starter`, `map_last_topic_reply`) VALUES('" .. Arg['id'] .. "', '" .. _Arg['mt_id'] .. "', '" .. escape(folder) .. "', '" .. time .. "','" .. 1 .. "', '" .. 0 .. "', '" .. 1 .. "', '" .. time .. "')")
								local query7 = database:query("INSERT INTO " .. Prefix .. "_message_topic_user_map (`map_user_id`, `map_topic_id`, `map_folder_id`, `map_read_time`, `map_user_active`, `map_has_unread`, `map_is_starter`, `map_last_topic_reply`) VALUES('" .. Args['member_id'] .. "', '" .. _Arg['mt_id'] .. "', '" .. escape(folder) .. "', '" .. time .. "','" .. 1 .. "', '" .. 1 .. "', '" .. 0 .. "', '" .. time .. "')")
								query5:start()
								query6:start()
								query7:start()
								query5.onError = function( err, sql )
									MsgN( "Query5 errored!" )
									MsgN( "Query:", sql )
									MsgN( "Error:", err )
								end
								query6.onError = function( err, sql )
									MsgN( "Query6 errored!" )
									MsgN( "Query:", sql )
									MsgN( "Error:", err )
								end
								query7.onError = function( err, sql )
									MsgN( "Query7 errored!" )
									MsgN( "Query:", sql )
									MsgN( "Error:", err )
								end
							end
						end
						query4:start()
						self:ChatPrint("Sent PM to " .. who .. " titled " .. sub .. ".")
					end
				end
				query2:start()
			end
		end
		query1:start()
	else
		local query1 = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
		query1.onError = function( err, sql )
			MsgN( "Query1 errored!" )
			MsgN( "Query:", sql )
			MsgN( "Error:", err )
		end
		query1.onSuccess = function( query )
			local Arg = query:getData()[1] or nil
			if !Arg then
				self.Registered = false
				umsg.Start("cl_register", self)
				umsg.End()
				umsg.Start("cl_error", self)
					umsg.String("Attention;Please register or link an account.")
				umsg.End()
				return
			end
			if Arg then
				local query2 = database:query("SELECT `user_id` FROM " .. Prefix .. "_user WHERE `username`='" .. who .. "'")
				query2.onError = function( err, sql )
					MsgN( "Query2 errored!" )
					MsgN( "Query:", sql )
					MsgN( "Error:", err )
				end
				query2.onSuccess = function( _query )
					local Args = _query:getData()[1] or nil
					if !Args then
						umsg.Start("cl_error", self)
							umsg.String("Send PM;Their is no user with that name.")
						umsg.End()
						return
					end
					if Args then
						local query3 = database:query("SELECT `username` FROM " .. Prefix .. "_user WHERE `user_id`='" .. Arg['id'] .. "'")
						query3.onError = function( err, sql )
							MsgN( "Query3 errored!" )
							MsgN( "Query:", sql )
							MsgN( "Error:", err )
						end
						query3.onSuccess = function( __query )
							local _Args = __query:getData()[1] or nil
							if _Args then
								local query4 = database:query("INSERT INTO " .. Prefix .. "_conversation_master (`title`, `user_id`, `username`, `start_date`, `open_invite`, `conversation_open`, `reply_count`, `recipient_count`, `first_message_id`, `last_message_date`, `last_message_id`, `last_message_user_id`, `last_message_username`) VALUES('" .. escape(sub) .. "', '" .. Arg['id'] .. "', '" .. _Args['username'] .. "', '" .. time .. "', '" .. 0 .. "', '" .. 1 .. "', '" .. 0 .. "', '" .. 0 .. "', '" .. 0 .. "',  '" .. time .. "',  '" .. 0 .. "', '" .. escape(Arg['id']) .. "', '" .. escape(_Args['username']) .. "')")
								query4.onError = function( err, sql )
									MsgN( "Query4 errored!" )
									MsgN( "Query:", sql )
									MsgN( "Error:", err )
								end
								query4.onSuccess = function( ___query )
									local query5 = database:query("SELECT `conversation_id` FROM " .. Prefix .. "_conversation_master WHERE `user_id`='" .. Arg['id'] .. "' AND `username`='" .. _Args['username'] .. "' AND `title`='" .. sub .. "'")
									query5.onError = function( err, sql )
										MsgN( "Query5 errored!" )
										MsgN( "Query:", sql )
										MsgN( "Error:", err )
									end
									query5.onSuccess = function( ___query )
										local __Args = ___query:getData()[1] or nil
										if __Args then
											local query6 = database:query("INSERT INTO " .. Prefix .. "_conversation_recipient (`conversation_id`, `user_id`, `recipient_state`, `last_read_date`) VALUES('" .. __Args['conversation_id'] .. "', '" .. Args['user_id'] .. "', '" .. escape('deleted') .. "', '" .. time .. "')")
											query6.onError = function( err, sql )
												MsgN( "Query6 errored!" )
												MsgN( "Query:", sql )
												MsgN( "Error:", err )
											end
											local query7 = database:query("INSERT INTO " .. Prefix .. "_conversation_message (`conversation_id`, `message_date`, `user_id`, `username`, `message`, `attach_count`, `ip_id`) VALUES('" .. __Args['conversation_id'] .. "', '" .. time .. "', '" .. Arg['id'] .. "', '" ..  escape(_Args['username']) .. "', '" .. escape(sub) .. "', '" .. 0 .. "', '" .. 0 .. "' )")
											query7.onError = function( err, sql )
												MsgN( "Query7 errored!" )
												MsgN( "Query:", sql )
												MsgN( "Error:", err )
											end
											local query8 = database:query("INSERT INTO " .. Prefix .. "_conversation_recipient (`conversation_id`, `user_id`, `recipient_state`, `last_read_date`) VALUES('" .. __Args['conversation_id'] .. "', '" .. Arg['id'] .. "', '" .. escape('deleted') .. "', '" .. time .. "')")
											query8.onError = function( err, sql )
												MsgN( "Query8 errored!" )
												MsgN( "Query:", sql )
												MsgN( "Error:", err )
											end
											local query9 = database:query("INSERT INTO " .. Prefix .. "_conversation_user (`conversation_id`, `owner_user_id`, `is_unread`, `reply_count`, `last_message_date`, `last_message_id`, `last_message_user_id`, `last_message_username`) VALUES('" .. __Args['conversation_id'] .. "', '" .. Args['user_id'] .. "', '" .. 1 .. "', '" .. 0 .. "', '" .. time .. "', '" .. 0 .. "', '" .. escape(Arg['id']) .. "', '" .. escape(_Args['user_id']) .. "')")
											query9.onError = function( err, sql )
												MsgN( "Query9 errored!" )
												MsgN( "Query:", sql )
												MsgN( "Error:", err )
											end
											local query10 = database:query("INSERT INTO " .. Prefix .. "_conversation_user (`conversation_id`, `owner_user_id`, `is_unread`, `reply_count`, `last_message_date`, `last_message_id`, `last_message_user_id`, `last_message_username`) VALUES('" .. __Args['conversation_id'] .. "', '" .. Arg['id'] .. "', '" .. 1 .. "', '" .. 0 .. "', '" .. time .. "', '" .. 0 .. "', '" .. escape(Arg['id']) .. "', '" .. escape(_Args['user_id']) .. "')")
											query10.onError = function( err, sql )
												MsgN( "Query10 errored!" )
												MsgN( "Query:", sql )
												MsgN( "Error:", err )
											end
											query6:start()
											query7:start()
											query8:start()
											query9:start()
											query10:start()
											self:ChatPrint("Sent PM to " .. who .. " titled " .. sub .. ".")
										end
									end
									query5:start()
								end
								query4:start()
							end
						end
						query3:start()
					end
				end
				query2:start()
			end
		end
		query1:start()
	end
end

function ResetUser(self)
	if !self then return end
	if !Reset then return self:ChatPrint("Server currently has reset disabled.") end
	local query1 = database:query("SELECT `id` FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
	query1.onError = function( err, sql )
		MsgN( "Query1 errored!" )
		MsgN( "Query:", sql )
		MsgN( "Error:", err )
	end
	query1.onSuccess = function( query, data )
		local Arg = query:getData()[1] or nil
		if Arg && Arg['id'] then
			local query2 = database:query("DELETE FROM " .. Prefix .. "_link WHERE `steamid`='" .. self:SteamID() .. "'")
			query2.onError = function( err, sql )
				MsgN( "Query2 errored!" )
				MsgN( "Query:", sql )
				MsgN( "Error:", err )
			end
			query2.onSuccess = function( query, data )
				self.Registered = false
				umsg.Start("cl_register", self)
				umsg.End()
				umsg.Start("cl_error", self)
					umsg.String("Attention;You've unlink your account via reset.")
				umsg.End()
				self:ChatPrint("Your account has been succesfully unlinked.")
			end
			query2:start()
		end
	end
	query1:start()
end

function Salt(self, key )
	if !key then return end
	key = tonumber(key)
	local salt = ""
	local characters = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "1", "2", "3", "4", "5", "6", "7", "8", "9" }
	for i=1,key do
		salt = salt .. table.Random(characters)
	end
	return tostring(salt)
end

print("[gForum] Server -> Player meta's loaded.")