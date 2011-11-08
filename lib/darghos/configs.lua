-- Arquivo de configurações dos aspectos do Darghos

-- Distro utilizada
-- opções: opentibia, tfs
darghos_distro = "tfs"

-- Sistema de stages personalizado do Darghos
-- opções: true(ativo), false (desativo)
-- Obs: 
--	* Para evitar problemas certificar que todas rates estão configuradas como 1x no config.lua e eventual stages.xml da distro
darghos_use_stages = true

-- Sistema de reborn
-- opções: true (ativo), false (desativo)
-- Obs:
--	* para true é necessario que as vocações de reborn estejam devidamente configuradas em vocations.xml
darghos_use_reborn = false

-- Sistema de recordes personalizado
-- opções: true (ativo), false (desativo)
darghos_use_record = false

-- Darghos exp rate (double,  triple,  etc)
darghos_exp_multipler = 1

-- Change pvp
darghos_change_pvp_debuff_percent = 50
darghos_change_pvp_days_cooldown = 30

-- Darghos spoof players
-- opções: true (ativo), false (desativo)
darghos_spoof_players = true
darghos_players_to_spoof = 75
darghos_spoof_start_in = 25

-- Define se é necessario comer para recuperar life/mana
darghos_need_eat = false

-- Define se jogadores em area non-pvp usarão um estagio de exp diferenciado do normal
darghos_use_secure_stages = false