--[[
		It is very important you read threw everything below before chaning anything

		Additional if you run into PROBLEMS you can visit the official gForum thread on facepunch.
		http://facepunch.com/showthread.php?t=1189744

		You can suggest features and additional forum support via the link above.
--]]


// Forum is the type of board software your site is running. Currently supports 'smf', 'mybb', 'ipb', and 'xf'
Forum = "mybb"

// Prefix is the alais used to define the begining of the forum tables. Examples are smf* or garry01_smf*.
Prefix = "mybb"

// URL is the address to your forum site index page. ** ** ** Do not include any file and file extentsion instead use the folder of the index page. ** ** **
URL = "http://127.0.0.1:8080/mybb/"

// Group is the default group you wish clients to be placed into. This must be a number. SMF(4), MyBB(2), IPB(3), Xen(2)
Group = 2

// Admin is whether you wish to enabled supported admin mods to dervied it's users from your site user group. This is disabled by default and is either true or false.
Admin = true

// Alias is whether you'd like to update the players forum title to display their ingame name. This is disabled by default and is either true or false.
Alias = true

// Kick is whether you like to kick users who are banned on your forums. This is disabled by default and is either true or false.
Kick = true

// Ban Group is the id of the group that is banned. This is disabled by default and is a number. SMF(Nil), MyBB(7), Xen(Nil)
BanGroup = 100

// Reset is the whether you like to allow user to unlink their registered account to their steamid.
Reset = false

// Register is whether you like to force user to register.
Register = true

print("[gForum] Server -> Variables loaded.")