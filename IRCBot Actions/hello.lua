-- IRCBot lua script
-- hello

-- Import the base frameworks
LuaCocoa.import("Foundation")


-- The main	function --
function main(data, args, irc)
	print('Running main function');
		
	msg = 'hello ' .. data[2]
	hello_string = NSString:alloc():initWithUTF8String(msg)	
	irc:sendMessage_to_(hello_string,data[5])
	
	print('end')	
end