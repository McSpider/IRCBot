--: IRCBot lua script :--
--: hello :--


--: The main	function :--
function main(data, args, irc)
	print('Running main function');
	
	--: Get the sender so that we can send the reply to the correct place :--
	sentTo = data[5]
	myNick = irc:getNickname()
	
	if (sentTo == myNick) then
		sendTo = data[2]
	else
	  sendTo = data[5]
	end
	--::--
	
	argument = args[3]
	if (argument ~= nil) then
		hello_string = 'hello ' .. args[3]
	else
		hello_string = 'hello ' .. data[2]
	end
	
	print('%' .. data[5] .. '%' .. myNick .. '%')
	
	irc:sendMessage_to_(hello_string,sendTo)

	
	print('end')	
end