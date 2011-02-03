-- IRCBot lua script
-- ping

-- Import the base frameworks
LuaCocoa.import("Foundation")


-- The main	function --
function main(data, args, irc)
	print('Running main function');
		
	if not args[2] ~= nil then
		msg = "pong " .. args[2]
	else
		msg = "pong " .. data[2]
	end

	ping_string = NSString:alloc():initWithUTF8String(msg)	
	irc:sendMessage_to_(ping_string,data[5])
	
	print('end')	
end
