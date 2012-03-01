--: IRCBot lua script :--
--: hello :--


--: The main	function :--
function main(data, args, irc)
	print('Running main function')
	
	--: Get the sender so that we can send the reply to the correct place :--
	sentTo = data[5]
	myNick = irc:getNickname()
	
	if (sentTo == myNick) then
		print('Sent to me')
		sendTo = data[2]
	end
	--::--
	
	if (args[2] ~= nil) then
		hello_string = 'hello ' .. args[3]
	else
		hello_string = 'hello ' .. data[2]
	end
	
	irc:sendMessage_to_(hello_string,sendTo)
	
	print('end')	
end