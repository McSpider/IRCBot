-- IRCBot lua script
-- hello


-- The main	function --
function main(data, args, irc)
	print('Running main function');
	
	if not args[3] ~= nil then
		hello_string = 'hello ' .. args[3]
	else
		hello_string = 'hello ' .. data[2]
	end
	
	irc:sendMessage_to_(hello_string,data[5])
	
	print('end')	
end