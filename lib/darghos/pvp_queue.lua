pvpQueue = {
	queue = {},
	loaded = false
}

function pvpQueue.load()

	local value = luaGlobal.getVar("pvp_queue")
	
	if(value == nil) then
		value = {}
	end
	
	pvpQueue.queue = value
	pvpQueue.loaded = true
end

function pvpQueue.save()

	if(#pvpQueue.queue ~= 0) then
		luaGlobal.setVar("pvp_queue", pvpQueue.queue)
	else
		luaGlobal.unsetVar("pvp_queue")
	end
end

function pvpQueue.getQueue()
	if(not pvpQueue.loaded) then
		error("Tentativa de acessar a fila sem sincronia.")
		return
	end

	return pvpQueue.queue
end

function pvpQueue.size()
	if(not pvpQueue.loaded) then
		error("Tentativa de inserir jogador em uma fila não sincronizada.")
		return
	end
	
	return #pvpQueue.queue
end

function pvpQueue.insert(cid)

	if(not pvpQueue.loaded) then
		error("Tentativa de inserir jogador em uma fila não sincronizada.")
		return
	end
	
	table.insert(pvpQueue.queue, cid)
	pvpQueue.save()
end

function pvpQueue.remove(pos)

	if(not pvpQueue.loaded) then
		error("Tentativa de remover jogador em uma fila não sincronizada.")
		return
	end
	
	pos = pos or 1
	
	table.remove(pvpQueue.queue, pos)
	pvpQueue.save()
end

function pvpQueue.getPlayer(pos)
	
	if(not pvpQueue.loaded) then
		error("Tentativa de ler jogador em uma fila não sincronizada.")
		return
	end
	
	pos = pos or 1
	return pvpQueue.queue[pos]
end

function pvpQueue.getPlayerPosByCid(cid)

	if(not pvpQueue.loaded) then
		error("Tentativa de ler jogador em uma fila não sincronizada.")
		return
	end
	
	local pos = table.find(pvpQueue.queue, cid)
	return pos	
end

function pvpQueue.removePlayerByCid(cid)
	local pos = pvpQueue.getPlayerPosByCid(cid)
	table.remove(pvpQueue.queue, pos)
	pvpQueue.save()
end