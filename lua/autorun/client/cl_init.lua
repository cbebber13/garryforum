local Forum, FName, FGroup, FPosts = "", "", "", ""

usermessage.Hook("cl_forum", function( um )
	local str = um:ReadString()
	if str == "smf" then
		Forum = "SMF"
	elseif str == "mybb" then
		Forum = "MyBB"
	elseif str == "ipb" then
		Forum = "IPB"
	else
		Forum = "XF"
	end
	OpenedAlready = false
end)

function RegisterAccount()
	local p = LocalPlayer()
	local RegisterPanel = vgui.Create("DFrame")
	RegisterPanel:SetSize(186, 164)
	RegisterPanel:SetPos(ScrW() / 2 - 93, ScrH() / 2 - 82)
	RegisterPanel:SetTitle("Forum Account Creation")
	RegisterPanel:SetSizable(false)
	RegisterPanel:SetDraggable(false)
	RegisterPanel:SetDeleteOnClose(false)
	RegisterPanel:ShowCloseButton(false)
	RegisterPanel:MakePopup()
	RegisterPanel.Paint = function()
		surface.SetDrawColor(54, 57, 61, 255)
		surface.DrawRect(0, 0, RegisterPanel:GetWide(), RegisterPanel:GetTall())
		
		surface.SetDrawColor(46, 48, 57, 255)
		surface.DrawRect(1, 0, RegisterPanel:GetWide() - 2, RegisterPanel:GetTall() - 145)
		
		surface.SetDrawColor(150, 150, 150, 200)
		surface.DrawOutlinedRect(0, 0, RegisterPanel:GetWide(), RegisterPanel:GetTall())
	end
	
	local Link = vgui.Create("DImageButton", RegisterPanel)
	Link:SetPos(164, 4)
	Link:SetImage("icon16/arrow_right.png")
	Link:SetSize(14, 14)
	Link:SetToolTip("Already have an account?")
	Link.DoClick = function()
		LinkAccount()
		RegisterPanel:Close()
	end
	
	timer.Create("blink", 1, 3, function()
		if OpenedAlready then return end
		Link:SetColor(Color(255, 0, 0, 255))
		timer.Create("blink2", 0.5, 3, function()
			Link:SetColor(Color(255, 255, 255, 255))
		end)
		OpenedAlready = true
	end)
	
	// Username
	local Username = vgui.Create("DLabel", RegisterPanel)
	Username:SetPos(10, 24)
	Username:SetText("Username")
	Username:SizeToContents()
	
	local UsernameEntry = vgui.Create("DTextEntry", RegisterPanel)
	UsernameEntry:SetSize(125, 20)
	UsernameEntry:SetPos(30, 38)
	UsernameEntry:SetText("")
	UsernameEntry.Paint = function( )
		draw.RoundedBox(4, 0, 0, UsernameEntry:GetWide(), UsernameEntry:GetTall(), Color( 255, 255, 255, 200 ) )
		local username = UsernameEntry:GetValue()
		local color = Color(100, 100, 100, 255)
		if string.len(username) <= 0 then
			username = "Username"
			color = Color(100, 100, 100, 255)
		elseif string.len(username) >= 1 then
			username = UsernameEntry:GetValue()
			color = Color(50, 50, 50, 255)
		end
		surface.SetFont("Default")
		surface.SetTextColor(color)
		surface.SetTextPos(2, 5) 
		surface.DrawText(username)
	end
	UsernameEntry.Think = function( )
		local username = UsernameEntry:GetValue()
		if string.len(username) > 5 then
			UsernameStatus:SetImage("icon16/tick.png")
		end
	end
	
	local UsernameIcon = vgui.Create("DImage", RegisterPanel)
	UsernameIcon:SetSize(14, 14)
	UsernameIcon:SetPos(10, 38)
	UsernameIcon:SetImage("icon16/user.png")
	UsernameIcon:SetToolTip("User name must be 5 characters long.")
	
	UsernameStatus = vgui.Create("DImage", RegisterPanel)
	UsernameStatus:SetSize(14, 14)
	UsernameStatus:SetPos(160, 38)
	UsernameStatus:SetImage("icon16/exclamation.png")
	
	// Password
	local Password = vgui.Create("DLabel", RegisterPanel)
	Password:SetPos(10, 62)
	Password:SetText("Password")
	Password:SizeToContents()
	
	local PasswordEntry = vgui.Create("DTextEntry", RegisterPanel)
	PasswordEntry:SetSize(125, 20)
	PasswordEntry:SetPos(30, 77)
	PasswordEntry:SetText("")
	PasswordEntry.Paint = function( )
		draw.RoundedBox(4, 0, 0, PasswordEntry:GetWide(), PasswordEntry:GetTall(), Color( 255, 255, 255, 200 ))
		local password = PasswordEntry:GetValue()
		local color = Color(100, 100, 100, 255)
		if string.len(password) <= 0 then
			password = "Password"
			color = Color(100, 100, 100, 255)
		elseif string.len(password) >= 1 then
			password = PasswordEntry:GetValue()
			color = Color(50, 50, 50, 255)
		end
		surface.SetFont("Default")
		surface.SetTextColor(color)
		surface.SetTextPos(2, 5) 
		surface.DrawText(password)
	end
	PasswordEntry.Think = function( )
		local password = PasswordEntry:GetValue()
		if string.len(password) > 5 then
			PasswordStatus:SetImage("icon16/tick.png")
		end
	end
	
	local PasswordIcon = vgui.Create("DImage", RegisterPanel)
	PasswordIcon:SetSize(14, 14)
	PasswordIcon:SetPos(10, 77)
	PasswordIcon:SetImage("icon16/key.png")
	PasswordIcon:SetToolTip("Password must be 5 characters long.")
	
	PasswordStatus = vgui.Create("DImage", RegisterPanel)
	PasswordStatus:SetSize(14, 14)
	PasswordStatus:SetPos(160, 77)
	PasswordStatus:SetImage("icon16/exclamation.png")
	
	// Email
	local Email = vgui.Create("DLabel", RegisterPanel)
	Email:SetPos(10, 99)
	Email:SetText("Email")
	Email:SizeToContents()
	
	local EmailEntry = vgui.Create("DTextEntry", RegisterPanel)
	EmailEntry:SetSize(125, 20)
	EmailEntry:SetPos(30, 115)
	EmailEntry:SetText("")
	EmailEntry.Paint = function( )
		draw.RoundedBox(4, 0, 0, EmailEntry:GetWide(), EmailEntry:GetTall(), Color( 255, 255, 255, 200 ))
		local email = EmailEntry:GetValue()
		local color = Color(100, 100, 100, 255)
		if string.len(email) <= 0 then
			email = "Email"
			color = Color(100, 100, 100, 255)
		elseif string.len(email) >= 1 then
			email = EmailEntry:GetValue()
			color = Color(50, 50, 50, 255)
		end
		surface.SetFont("Default")
		surface.SetTextColor(color)
		surface.SetTextPos(2, 5) 
		surface.DrawText(email)
	end
	EmailEntry.Think = function( )
		local email = EmailEntry:GetValue()
		if string.len(email) > 8 then
			EmailStatus:SetImage("icon16/tick.png")
		end
	end
	
	local EmailIcon = vgui.Create("DImage", RegisterPanel)
	EmailIcon:SetSize(14, 14)
	EmailIcon:SetPos(10, 115)
	EmailIcon:SetImage("icon16/email.png")
	EmailIcon:SetToolTip("Email must be 8 characters long.")
	
	EmailStatus = vgui.Create("DImage", RegisterPanel)
	EmailStatus:SetSize(14, 14)
	EmailStatus:SetPos(160, 115)
	EmailStatus:SetImage("icon16/exclamation.png")
	
	// Submit
	local Submit = vgui.Create("DButton", RegisterPanel)
	Submit:SetSize(60, 20)
	Submit:SetPos(58, 138)
	Submit:SetText("Submit")
	Submit:SetFont("Default")
	Submit.Paint = function()
		draw.RoundedBox(4, 0, 0, Submit:GetWide(), Submit:GetTall(), Color(255, 255, 255, 200))
	end
	
	Submit.DoClick = function()
		local username = UsernameEntry:GetValue()
		local password = PasswordEntry:GetValue()
		local email = EmailEntry:GetValue()
		if string.len(username) < 4 then p:ChatPrint("[" .. Forum .. "] Your username has be 4 characters or more.") return end
		if string.len(password) < 6 then p:ChatPrint("[" .. Forum .. "] Your password has be 6 characters or more.") return end
		if string.len(email) < 8 then p:ChatPrint("[" .. Forum .. "] Your email has be 8 characters or more.") return end
		RegisterPanel:Close()
		RunConsoleCommand("sv_register", username, password, email)
	end
end

usermessage.Hook("cl_register", function( um )
	return RegisterAccount()
end)

function LinkAccount()
	local p = LocalPlayer()
	local LinkPanel = vgui.Create("DFrame")
	LinkPanel:SetSize(186, 164)
	LinkPanel:SetPos(ScrW() / 2 - 93, ScrH() / 2 - 82)
	LinkPanel:SetTitle("Forum Account Link")
	LinkPanel:SetSizable(false)
	LinkPanel:SetDraggable(false)
	LinkPanel:SetDeleteOnClose(false)
	LinkPanel:ShowCloseButton(false)
	LinkPanel:MakePopup()
	LinkPanel.Paint = function()
		surface.SetDrawColor(54, 57, 61, 255)
		surface.DrawRect(0, 0, LinkPanel:GetWide(), LinkPanel:GetTall())
		
		surface.SetDrawColor(46, 48, 57, 255)
		surface.DrawRect(1, 0, LinkPanel:GetWide() - 2, LinkPanel:GetTall() - 145)
		
		surface.SetDrawColor(150, 150, 150, 200)
		surface.DrawOutlinedRect(0, 0, LinkPanel:GetWide(), LinkPanel:GetTall())
	end
	
	local Register = vgui.Create("DImageButton", LinkPanel)
	Register:SetPos(164, 4)
	Register:SetImage("icon16/arrow_right.png")
	Register:SetSize(14, 14)
	Register:SetToolTip("Don't have an account?")
	Register.DoClick = function()
		RegisterAccount()
		LinkPanel:Close()
	end
	
	timer.Create("blink", 1, 3, function()
		if OpenedAlready then return end
		Register:SetColor(Color(255, 0, 0, 255))
		timer.Create("blink2", 0.5, 3, function()
			Register:SetColor(Color(255, 255, 255, 255))
		end)
		OpenedAlready = true
	end)
	
	// Username
	local Username = vgui.Create("DLabel", LinkPanel)
	Username:SetPos(10, 24)
	Username:SetText("Username")
	Username:SizeToContents()
	
	local UsernameEntry = vgui.Create("DTextEntry", LinkPanel)
	UsernameEntry:SetSize(125, 20)
	UsernameEntry:SetPos(30, 38)
	UsernameEntry:SetText("")
	UsernameEntry.Paint = function( )
		draw.RoundedBox(4, 0, 0, UsernameEntry:GetWide(), UsernameEntry:GetTall(), Color( 255, 255, 255, 200 ) )
		local username = UsernameEntry:GetValue()
		local color = Color(100, 100, 100, 255)
		if string.len(username) <= 0 then
			username = "Username"
			color = Color(100, 100, 100, 255)
		elseif string.len(username) >= 1 then
			username = UsernameEntry:GetValue()
			color = Color(50, 50, 50, 255)
		end
		surface.SetFont("Default")
		surface.SetTextColor(color)
		surface.SetTextPos(2, 5) 
		surface.DrawText(username)
	end
	UsernameEntry.Think = function( )
		local username = UsernameEntry:GetValue()
		if string.len(username) > 3 then
			UsernameStatus:SetImage("icon16/tick.png")
		end
	end
	
	local UsernameIcon = vgui.Create("DImage", LinkPanel)
	UsernameIcon:SetSize(14, 14)
	UsernameIcon:SetPos(10, 38)
	UsernameIcon:SetImage("icon16/user.png")
	UsernameIcon:SetToolTip("User name must be 3 characters long.")
	
	UsernameStatus = vgui.Create("DImage", LinkPanel)
	UsernameStatus:SetSize(14, 14)
	UsernameStatus:SetPos(160, 38)
	UsernameStatus:SetImage("icon16/exclamation.png")
	
	// Password
	local Password = vgui.Create("DLabel", LinkPanel)
	Password:SetPos(10, 62)
	Password:SetText("Password")
	Password:SizeToContents()
	
	local PasswordEntry = vgui.Create("DTextEntry", LinkPanel)
	PasswordEntry:SetSize(125, 20)
	PasswordEntry:SetPos(30, 77)
	PasswordEntry:SetText("")
	PasswordEntry.Paint = function( )
		draw.RoundedBox(4, 0, 0, PasswordEntry:GetWide(), PasswordEntry:GetTall(), Color( 255, 255, 255, 200 ))
		local password = PasswordEntry:GetValue()
		local color = Color(100, 100, 100, 255)
		if string.len(password) <= 0 then
			password = "Password"
			color = Color(100, 100, 100, 255)
		elseif string.len(password) >= 1 then
			password = PasswordEntry:GetValue()
			color = Color(50, 50, 50, 255)
		end
		surface.SetFont("Default")
		surface.SetTextColor(color)
		surface.SetTextPos(2, 5) 
		surface.DrawText(password)
	end
	PasswordEntry.Think = function( )
		local password = PasswordEntry:GetValue()
		if string.len(password) > 3 then
			PasswordStatus:SetImage("icon16/tick.png")
		end
	end
	
	local PasswordIcon = vgui.Create("DImage", LinkPanel)
	PasswordIcon:SetSize(14, 14)
	PasswordIcon:SetPos(10, 77)
	PasswordIcon:SetImage("icon16/key.png")
	PasswordIcon:SetToolTip("Password must be 3 characters.")

	PasswordStatus = vgui.Create("DImage", LinkPanel)
	PasswordStatus:SetSize(14, 14)
	PasswordStatus:SetPos(160, 77)
	PasswordStatus:SetImage("icon16/exclamation.png")
	
	// Submit
	local Submit = vgui.Create("DButton", LinkPanel)
	Submit:SetSize(60, 20)
	Submit:SetPos(58, 138)
	Submit:SetText("Submit")
	Submit:SetFont("Default")
	Submit.Paint = function()
		draw.RoundedBox(4, 0, 0, Submit:GetWide(), Submit:GetTall(), Color(255, 255, 255, 200))
	end
	
	Submit.DoClick = function()
		local username = UsernameEntry:GetValue()
		local password = PasswordEntry:GetValue()
		if string.len(username) < 4 then p:ChatPrint("[" .. Forum .. "] Your username has be 4 characters or more.") return end
		if string.len(password) < 4 then p:ChatPrint("[" .. Forum .. "] Your password has be 4 characters or more.") return end
		LinkPanel:Close()
		RunConsoleCommand("sv_link", username, password)
	end
end

usermessage.Hook("cl_link", function( um )
	return LinkAccount()
end)

function ShowError( txt )
	local st = string.Explode(";", txt)
	local line1, line2 = st[1], st[2]
	local p = LocalPlayer()
	
	local ErrorPanel = vgui.Create("DFrame")
	ErrorPanel:SetSize(220, 64)
	ErrorPanel:SetPos(ScrW() / 2 - 110, ScrH() / 2 - 32)
	ErrorPanel:SetTitle(line1)
	ErrorPanel:SetSizable(false)
	ErrorPanel:SetDraggable(false)
	ErrorPanel:SetDeleteOnClose(false)
	ErrorPanel:ShowCloseButton(false)
	ErrorPanel:MakePopup()
	ErrorPanel.Paint = function()
		surface.SetDrawColor(54, 57, 61, 255)
		surface.DrawRect(0, 0, ErrorPanel:GetWide(), ErrorPanel:GetTall())
		
		surface.SetDrawColor(46, 48, 57, 255)
		surface.DrawRect(1, 1, ErrorPanel:GetWide() - 2, ErrorPanel:GetTall() - 145)
		
		surface.SetDrawColor(150, 150, 150, 200)
		surface.DrawOutlinedRect(0, 0, ErrorPanel:GetWide(), ErrorPanel:GetTall())
	end
	
	local Close = vgui.Create("DImageButton", ErrorPanel)
	Close:SetPos(200, 4)
	Close:SetImage("icon16/exclamation.png")
	Close:SetSize(14, 14)
	Close:SetToolTip("Close this panel?")
	Close.DoClick = function()
		ErrorPanel:Close()
	end
	
	local Message = vgui.Create("DLabel", ErrorPanel)
	Message:SetPos(2, 24)
	Message:SetTextColor(Color(255, 255, 255, 255))
	Message:SetText(" " .. st[2])
	Message:SizeToContents()
end

usermessage.Hook("cl_error", function( um )
	local txt = um:ReadString()
	ShowError(txt)
end)

function ReadPM( )
	if table.Count(PersonalMessages) == 0 then RunConsoleCommand("sv_getpm") return end
	local PMPanel = vgui.Create("DFrame")
	PMPanel:SetSize(350, 170)
	PMPanel:SetPos(ScrW() / 2 - 175, ScrH() / 2 - 85)
	PMPanel:SetTitle("Read PM")
	PMPanel:SetSizable(false)
	PMPanel:SetDraggable(false)
	PMPanel:SetDeleteOnClose(false)
	PMPanel:ShowCloseButton(false)
	PMPanel:MakePopup()
	PMPanel.Paint = function()
		surface.SetDrawColor(54, 57, 61, 255)
		surface.DrawRect(0, 0, PMPanel:GetWide(), PMPanel:GetTall())
		
		surface.SetDrawColor(46, 48, 57, 255)
		surface.DrawRect(1, 0, PMPanel:GetWide() - 2, PMPanel:GetTall() - 145)
		
		surface.SetDrawColor(150, 150, 150, 200)
		surface.DrawOutlinedRect(0, 0, PMPanel:GetWide(), PMPanel:GetTall())
	end
	
	local last = 0
	for k, v in pairs(PersonalMessages) do
		if table.Count(PersonalMessages) >= 1 and k != last then
			last = k
			local Next = vgui.Create("DImageButton", PMPanel)
			Next:SetPos(PMPanel:GetWide() - 36, 4)
			Next:SetImage("icon16/arrow_right.png")
			Next:SetSize(14, 14)
			Next:SetToolTip("Next personal messgae.")
			Next.DoClick = function()
				RunConsoleCommand("sv_readpm", v[4])
				v = table.FindNext(PersonalMessages, v)
				last, k = table.KeyFromValue(PersonalMessages, v), table.KeyFromValue(PersonalMessages, v)
			end
			
			local Close = vgui.Create("DImageButton", PMPanel)
			Close:SetPos(PMPanel:GetWide() - 16, 4)
			Close:SetImage("icon16/cross.png")
			Close:SetSize(14, 14)
			Close:SetToolTip("Close this panel?")
			Close.DoClick = function()
				PMPanel:Close()
			end
			
			local UsernameIcon = vgui.Create("DImage", PMPanel)
			UsernameIcon:SetPos(6, 28)
			UsernameIcon:SetImage("icon16/user.png")
			UsernameIcon:SetSize(14, 14)
			UsernameIcon:SetToolTip("Who the message is from.")
			
			local SubjectIcon = vgui.Create("DImage", PMPanel)
			SubjectIcon:SetPos(156, 28)
			SubjectIcon:SetImage("icon16/email.png")
			SubjectIcon:SetSize(14, 14)
			SubjectIcon:SetToolTip("The title of the personal message.")
			
			local To = vgui.Create("DTextEntry", PMPanel)
			To:SetSize(128, 20)
			To:SetPos(24, 26)
			To:SetEditable(true)
			To.Paint = function()
				draw.RoundedBox(4, 0, 0, To:GetWide(), To:GetTall(), Color( 255, 255, 255, 200 ))
				surface.SetFont("Default")
				surface.SetTextColor(Color(50, 50, 50, 255))
				surface.SetTextPos(2, 5) 
				surface.DrawText(v[1])
			end
			
			local Subject = vgui.Create("DTextEntry", PMPanel)
			Subject:SetSize(128, 20)
			Subject:SetPos(174, 26)
			Subject:SetEditable(true)
			Subject.Paint = function()
				draw.RoundedBox(4, 0, 0, Subject:GetWide(), Subject:GetTall(), Color( 255, 255, 255, 200 ))
				surface.SetFont("Default")
				surface.SetTextColor(Color(50, 50, 50, 255))
				surface.SetTextPos(2, 5) 
				surface.DrawText(v[2])
			end
			
			local Message = vgui.Create("DTextEntry", PMPanel)
			Message:SetSize(346, 98)
			Message:SetPos(2, 48)
			Message:SetMultiline(true)
			Message:SetEditable(true)
			Message.Paint = function()
				draw.RoundedBox(4, 0, 0, Message:GetWide(), Message:GetTall(), Color( 255, 255, 255, 200 ))
				surface.SetFont("Default")
				surface.SetTextColor(Color(50, 50, 50, 255))
				surface.SetTextPos(2, 5) 
				surface.DrawText(v[3])
			end
		end
	end
end

net.Receive("PersonalMessages", function( len, p )
	PersonalMessages = net.ReadTable()
end)

function SendPM()
	local PMPanel = vgui.Create("DFrame")
	PMPanel:SetSize(350, 170)
	PMPanel:SetPos(ScrW() / 2 - 175, ScrH() / 2 - 85)
	PMPanel:SetTitle("Send PM")
	PMPanel:SetSizable(false)
	PMPanel:SetDraggable(false)
	PMPanel:SetDeleteOnClose(false)
	PMPanel:ShowCloseButton(false)
	PMPanel:MakePopup()
	PMPanel.Paint = function()
		surface.SetDrawColor(54, 57, 61, 255)
		surface.DrawRect(0, 0, PMPanel:GetWide(), PMPanel:GetTall())
		
		surface.SetDrawColor(46, 48, 57, 255)
		surface.DrawRect(1, 0, PMPanel:GetWide() - 2, PMPanel:GetTall() - 145)
		
		surface.SetDrawColor(150, 150, 150, 200)
		surface.DrawOutlinedRect(0, 0, PMPanel:GetWide(), PMPanel:GetTall())
	end
	
	local Close = vgui.Create("DImageButton", PMPanel)
	Close:SetPos(PMPanel:GetWide() - 16, 4)
	Close:SetImage("icon16/cross.png")
	Close:SetSize(14, 14)
	Close:SetToolTip("Close this panel?")
	Close.DoClick = function()
		PMPanel:Close()
	end
	
	local UsernameIcon = vgui.Create("DImage", PMPanel)
	UsernameIcon:SetPos(6, 28)
	UsernameIcon:SetImage("icon16/user.png")
	UsernameIcon:SetSize(14, 14)
	UsernameIcon:SetToolTip("The user you wish to send a pm to.")
	
	local SubjectIcon = vgui.Create("DImage", PMPanel)
	SubjectIcon:SetPos(156, 28)
	SubjectIcon:SetImage("icon16/email.png")
	SubjectIcon:SetSize(14, 14)
	SubjectIcon:SetToolTip("The user you wish to send a pm to.")
	
	local ToStatus = vgui.Create("DImage", PMPanel)
	ToStatus:SetPos(130, 30)
	ToStatus:SetImage("icon16/exclamation.png")
	ToStatus:SetSize(14, 14)
	
	local SubjectStatus = vgui.Create("DImage", PMPanel)
	SubjectStatus:SetPos(284, 30)
	SubjectStatus:SetImage("icon16/exclamation.png")
	SubjectStatus:SetSize(14, 14)
	
	local MessageStatus = vgui.Create("DImage", PMPanel)
	MessageStatus:SetPos(330, 130)
	MessageStatus:SetImage("icon16/exclamation.png")
	MessageStatus:SetSize(14, 14)
	
	local To = vgui.Create("DTextEntry", PMPanel)
	To:SetSize(128, 20)
	To:SetPos(24, 26)
	To.OnGetFocus = function()
		ToStatus:SetImageColor(Color(255, 255, 255, 0))
	end
	To.OnLoseFocus = function()
		ToStatus:SetImageColor(Color(255, 255, 255, 255))
		ToStatus:MoveToFront()
	end
	To.Paint = function()
		draw.RoundedBox(4, 0, 0, To:GetWide(), To:GetTall(), Color( 255, 255, 255, 200 ))
		local towhom = To:GetValue()
		local color = Color(100, 100, 100, 255)
		if string.len(towhom) <= 0 then
			towhom = "Username"
			color = Color(100, 100, 100, 255)
		elseif string.len(towhom) >= 1 then
			towhom = To:GetValue()
			color = Color(50, 50, 50, 255)
		end
		surface.SetFont("Default")
		surface.SetTextColor(color)
		surface.SetTextPos(2, 5) 
		surface.DrawText(towhom)
	end
	To.Think = function( )
		local username = To:GetValue()
		if string.len(username) >= 5 then
			ToStatus:SetImage("icon16/tick.png")
		end
	end
	To:MoveToBack()
	
	local Subject = vgui.Create("DTextEntry", PMPanel)
	Subject:SetSize(128, 20)
	Subject:SetPos(174, 26)
	Subject.OnGetFocus = function()
		SubjectStatus:SetImageColor(Color(255, 255, 255, 0))
	end
	Subject.OnLoseFocus = function()
		SubjectStatus:SetImageColor(Color(255, 255, 255, 255))
		SubjectStatus:MoveToFront()
	end
	Subject.Paint = function()
		draw.RoundedBox(4, 0, 0, Subject:GetWide(), Subject:GetTall(), Color( 255, 255, 255, 200 ))
		local subject = Subject:GetValue()
		local color = Color(100, 100, 100, 255)
		if string.len(subject) <= 0 then
			subject = "Subject"
			color = Color(100, 100, 100, 255)
		elseif string.len(subject) >= 1 then
			subject = Subject:GetValue()
			color = Color(50, 50, 50, 255)
		end
		surface.SetFont("Default")
		surface.SetTextColor(color)
		surface.SetTextPos(2, 5) 
		surface.DrawText(subject)
	end
	Subject.Think = function( )
		local subject = Subject:GetValue()
		if string.len(subject) >= 8 then
			SubjectStatus:SetImage("icon16/tick.png")
		end
	end
	Subject:MoveToBack()
	
	local Message = vgui.Create("DTextEntry", PMPanel)
	Message:SetSize(346, 98)
	Message:SetPos(2, 48)
	Message:SetMultiline(true)
	Message.Paint = function()
		draw.RoundedBox(4, 0, 0, Message:GetWide(), Message:GetTall(), Color( 255, 255, 255, 200 ))
		local message = Message:GetValue()
		local color = Color(100, 100, 100, 255)
		if string.len(message) <= 0 then
			message = "Your message here."
			color = Color(100, 100, 100, 255)
		elseif string.len(message) >= 1 then
			message = Message:GetValue()
			color = Color(50, 50, 50, 255)
		end
		surface.SetFont("Default")
		surface.SetTextColor(color)
		surface.SetTextPos(2, 5) 
		surface.DrawText(message)
	end
	Message.OnGetFocus = function()
		MessageStatus:SetImageColor(Color(255, 255, 255, 0))
	end
	Message.OnLoseFocus = function()
		MessageStatus:SetImageColor(Color(255, 255, 255, 255))
		MessageStatus:MoveToFront()
	end
	Message.Think = function( )
		local message = Message:GetValue()
		if string.len(message) >= 12 then
			MessageStatus:SetImage("icon16/tick.png")
		end
	end
	Message:MoveToBack()
	
	Submit = vgui.Create("DButton", PMPanel)
	Submit:SetSize(70, 20)
	Submit:SetPos(140, 148)
	Submit:SetText('Submit')
	Submit.DoClick = function() 
		local who = To:GetValue()
		local title = Subject:GetValue()
		local message = Message:GetValue()
		if string.len(who) <= 4 then LocalPlayer():ChatPrint("[" .. Forum .. "] Your username has be 5 characters or more.") return end
		if string.len(title) <= 7 then LocalPlayer():ChatPrint("[" .. Forum .. "] Your username has be 8 characters or more.") return end
		if string.len(message) <= 11 then LocalPlayer():ChatPrint("[" .. Forum .. "] Your message has be 12 characters or more.") return end
		PMPanel:Close()
		RunConsoleCommand("sv_sendpm", who, title, message)
	end
end

ForumUsers = {}
net.Receive("ForumUsers", function( len, p )
	local tbl = net.ReadTable()
	ForumUsers = tbl
end)

function Users()
	local UsersPanel = vgui.Create( "DFrame" )
	UsersPanel:SetTitle("Server Forum Users")
	UsersPanel:SetSize(300, 600)
	UsersPanel:SetDraggable(false)
	UsersPanel:ShowCloseButton(false)
	UsersPanel:MakePopup()
	UsersPanel:Center()
	UsersPanel:SetMouseInputEnabled(true)
	UsersPanel:SetKeyBoardInputEnabled(false)
	
	local Close = vgui.Create("DImageButton", UsersPanel)
	Close:SetPos(UsersPanel:GetWide() - 17, 4)
	Close:SetImage("icon16/cross.png")
	Close:SetSize(14, 14)
	Close:SetToolTip("Close this panel?")
	Close.DoClick = function()
		UsersPanel:Close()
	end
	
	local x, y = 4, 28
	for k, v in pairs(ForumUsers) do
		
		local User = vgui.Create("DPanel", UsersPanel)
		User:SetSize(UsersPanel:GetWide() - 8, 32)
		User:SetPos(x, y)
		
		local Avatar = vgui.Create("AvatarImage", User)
		Avatar:SetPos(2, 4)
		Avatar:SetSize(24, 24)
		Avatar:SetPlayer(player.GetByUniqueID(v[3]), 24)
		
		local Name = vgui.Create("DLabel", User)
		Name:SetPos(32, 4)
		Name:SetText(v[1])
		Name:SetFont("Trebuchet18")
		Name:SetTextColor(Color(1, 1, 1, 255))
		
		local FName = vgui.Create("DLabel", User)
		FName:SetPos(Avatar:GetWide() + Name:GetWide() + 4, 4)
		FName:SetText(v[2])
		FName:SetFont("Trebuchet18")
		FName:SetTextColor(Color(1, 1, 1, 255))
		
		local UserButton = vgui.Create("DButton", User)
		UserButton:SetSize(UsersPanel:GetWide() - 8, 32)
		UserButton:SetPos(0, 0)
		UserButton:SetText("")
		UserButton.DoClick = function()
			if Forum == "smf" then
				gui.OpenURL(FURL .. "index.php?action=profile;u=" .. v[4])
			elseif Forum == "mybb" then
				gui.OpenURL(FURL .. "member.php?action=profile&uid=" .. v[4])
			elseif Forum == "ipb" then
				gui.OpenURL(FURL .. "user/" .. v[4] .. "-" .. string.lower(v[2]) .. "/")
			else
				gui.OpenURL(FURL .. "members/" .. v[4])
			end
		end
		UserButton.Paint = function()
			surface.SetDrawColor(1, 1, 1, 0)
			surface.DrawRect(0, 0, User:GetWide(), User:GetTall())
		end
		
		y = y + 34
	end
	
	UsersPanel:SizeToChildren(false, true)
	UsersPanel:Center()
	UsersPanel.Paint = function()
		surface.SetDrawColor(54, 57, 61, 255)
		surface.DrawRect(0, 0, UsersPanel:GetWide(), UsersPanel:GetTall())
		
		surface.SetDrawColor(150, 150, 150, 200)
		surface.DrawOutlinedRect(0, 0, UsersPanel:GetWide(), UsersPanel:GetTall())
	end
end

function DisplayAccount( p, bool )
	if !p or !bool then return end
	if !Panel then
		Panel = vgui.Create("DFrame")
		Panel:SetPos(2, 2)
		Panel:SetSize(150, 74)
		Panel:SetTitle("")
		Panel:SetDraggable(false)
		Panel:ShowCloseButton(false)
		Panel:MakePopup()
		Panel:SetMouseInputEnabled(true)
		Panel:SetKeyBoardInputEnabled(false)
		Panel:SetDrawOnTop(false)
		Panel.Paint = function()
			surface.SetDrawColor(54, 57, 61, 255)
			surface.DrawRect(0, 0, Panel:GetWide(), Panel:GetTall())
			
			surface.SetDrawColor(46, 48, 57, 255)
			surface.DrawRect(1, 0, Panel:GetWide() - 2, Panel:GetTall() - 55)
			
			surface.SetDrawColor(150, 150, 150, 200)
			surface.DrawOutlinedRect(0, 0, Panel:GetWide(), Panel:GetTall())
			
			surface.SetTextPos(40, 26)
			surface.SetFont("Default")
			surface.DrawText(FName)
			surface.SetTextColor(255, 255, 255, 255)
			
			surface.SetTextPos(40, 40)
			surface.SetFont("Default")
			surface.DrawText(FGroup)
			surface.SetTextColor(255, 255, 255, 255)
		end
		
		local Avatar = vgui.Create("AvatarImage", Panel)
		Avatar:SetPos(1, 25)
		Avatar:SetSize(32, 32)
		Avatar:SetPlayer(p, 32)
		
		local ReadPMs = vgui.Create("DImageButton", Panel)
		ReadPMs:SetPos(Panel:GetWide() - 28, 54)
		ReadPMs:SetImage("icon16/email_open.png")
		ReadPMs:SetSize(16, 16)
		ReadPMs:SetToolTip("Read Personal Messages.")
		ReadPMs.DoClick = function()
			ReadPM()
		end
		
		local SendPMs = vgui.Create("DImageButton", Panel)
		SendPMs:SetPos(Panel:GetWide() - 56, 54)
		SendPMs:SetImage("icon16/email_go.png")
		SendPMs:SetSize(16, 16)
		SendPMs:SetToolTip("Send a Personal Message.")
		SendPMs.DoClick = function()
			SendPM()
		end
		
		local User = vgui.Create("DImageButton", Panel)
		User:SetPos(Panel:GetWide() - 84, 54)
		User:SetImage("icon16/user_go.png")
		User:SetSize(16, 16)
		User:SetToolTip("View all users forum account.")
		User.DoClick = function()
			Users()
		end
		
		local Forum = vgui.Create("DImageButton", Panel)
		Forum:SetPos(Panel:GetWide() - 112, 54)
		Forum:SetImage("icon16/world_go.png")
		Forum:SetSize(16, 16)
		Forum:SetToolTip("Goto our forums.")
		Forum.DoClick = function()
			gui.OpenURL(FURL)
		end
	end
	if bool == "true" then
		Panel:SetVisible(true)
	elseif bool == "false" then
		Panel:SetVisible(false)
	end
end

hook.Add("ScoreboardHide", "ScoreboardHide.DisplayAccount", function()
	DisplayAccount(LocalPlayer(), "false")
	gui.EnableScreenClicker(false)
end)

hook.Add("ScoreboardShow", "ScoreboardShow.DisplayAccount", function()
	DisplayAccount(LocalPlayer(), "true")
	gui.EnableScreenClicker(true)
end)

hook.Add("InitPostEntity", "InitPostEntity.Init", function()
	PersonalMessages = {}
end)

usermessage.Hook("cl_setinfo", function( um )
	FName = um:ReadString()
	FGroup = um:ReadString()
	FURL = um:ReadString()
	if string.GetChar(FURL, string.len(FURL)) != "/" then
		FURL = FURL .. "/"
	end
end)

net.Receive("PersonalMessage", function( len )
	local tbl = net.ReadTable()
	for k, v in pairs(PersonalMessages) do
		if v[4] == tbl[4] then
			return
		end
	end
	table.insert(PersonalMessages, tbl)
end)

print("[gForum] Client -> Interface & Networking loaded.")
