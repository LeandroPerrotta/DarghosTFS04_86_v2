function onThink(interval)
	autoBroadcast()
	return true
end

function autoBroadcast()

	local messages = {
		{type = "pvp-channel", text = "Gosta de PvP? Participe de partidas com outros jogadores, ganhe recompensas, conquiste façanhas na Battleground! Guarde seu lugar na fila para a proxima partida com o comando '!bg entrar' agora mesmo!"}
		--,{text = "Confira os novos preços das Contas Premium! Ter acesso as todas vantagens e beneficios nunca esteve tão barato: www.darghos.com.br"}
		,{text = "Participe do ultimo evento do Darghos! Ajude o Rei Ordon a recuperar 5 items perdidos e ganhe como recompensa um premium scroll de 30 dias e um item unico! Maiores informações em nosso website! www.darghos.com.br"}
	}
	
	local random = math.random(1, #messages)
	local message = messages[random]
	
	if(not message.type) then
		doBroadcastMessage(message.text, MESSAGE_TYPES["blue"])
	elseif(message.type == "pvp-channel") then
		broadcastChannel(CUSTOM_CHANNEL_PVP, message.text)	
	end
end