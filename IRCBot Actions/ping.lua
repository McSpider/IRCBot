--: IRCBot lua script :--
--: ping :--


--: The main	function :--
function main(data, args, irc)
	print('Running main function');
		
	if not args[3] ~= nil then
		ping_string = "pong " .. args[3]
	else
		ping_string = "pong"
	end

	irc:sendMessage_to_(ping_string,data[5])
	
	print('end')	
end
