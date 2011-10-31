--[[
 * Contem todas constantes referentes ao Darghos, podem estar divididas por Arrays!
]]--

	ACCESS_PLAYER				= 0
	ACCESS_TUTOR				= 1
	ACCESS_GAME_MASTER			= 3
	ACCESS_COMMUNITY_MANAGER	= 4
	ACCESS_ADMIN				= 5
	
	GROUP_PLAYER				= 1
	GROUP_PLAYER_NON_PVP		= 2
	GROUP_PLAYER_TUTOR			= 3
	
	DISTROS_OPENTIBIA			= "opentibia"
	DISTROS_TFS					= "tfs"

	T_LOG_ALL = "ALL"
	T_LOG_NOTIFY = "NOTIFY"
	T_LOG_WARNING = "WARNING"
	T_LOG_FAIL = "FAIL"
	T_LOG_ERROR = "ERROR"
	T_LOG_FATAL_ERROR = "FATAL ERROR"
	
	STORAGE_NULL = -1
	
	LIGHT_FULL = 1
	LIGHT_NONE = -1
	
	ANTI_IDLE_INTERVAL = 1000 * 60
	ANTI_IDLE_NONE = 0
	
	BOAT_DESTINY_QUENDOR = 				{x=2228, y=1693, z=6}
	BOAT_DESTINY_ARACURA = 				{x=3401, y=1991, z=6}
	BOAT_DESTINY_AARAGON = 				{x=3005, y=1119, z=6}
	BOAT_DESTINY_SALAZART = 			{x=2140, y=2662, z=6}
	BOAT_DESTINY_NORTHREND = 			{x=2025, y=1235, z=6}
	BOAT_DESTINY_KASHMIR = 				{x=1167, y=1124, z=7}
	BOAT_DESTINY_THAUN = 				{x=2267, y=2058, z=6}
	BOAT_DESTINY_TRAINERS =				{x=2160, y=1486, z=6}
	BOAT_DESTINY_ISLAND_OF_PEACE = 		{x=1204, y=2186, z=6}
	BOAT_DESTINY_SEA_SERPENT_AREA = 	{x=2089, y=1141, z=8}
	
	CARPET_DESTINY_AARAGON = 	{x=2941, y=1207, z=6}
	CARPET_DESTINY_HILLS = 		{x=2167, y=1978, z=3}
	CARPET_DESTINY_SALAZART = 	{x=2311, y=2393, z=5}
	
	TRAIN_DESTINY_QUENDOR = 	{x=1980, y=1829, z=8}
	TRAIN_DESTINY_THORN = 		{x=2411, y=1826, z=8}
	
	EVENT_STATE_NONE	= -1
	EVENT_STATE_INIT	= 0
	EVENT_STATE_END		= 1

	groups =
	{
		PLAYER = 0,
		TUTOR = 0,
		SENIOR_TUTOR = 2,
		GAME_MASTER = 3,
		COMMUNITY_MANAGER = 4,
		GOD = 5
	}
	
	access = groups
	
	vocations =
	{
		NONE = 0,
		SORCERER = 1,
		DRUID = 2,
		PALADIN = 3,
		KNIGHT = 4,
		MASTER_SORCERER = 5,
		ELDER_DRUID = 6,
		ROYAL_PALADIN = 7,
		ELITE_KNIGHT = 8
	}

	outfits =
	{
		CITIZEN = {female = 136, male = 128},
		HUNTER = {female = 137, male = 129},
		MAGE = {female = 138, male = 130},
		KNIGHT = {female = 139, male = 131},
		NOBLE = {female = 140, male = 132},
		SUMMONER = {female = 141, male = 133},
		WARRIOR = {female = 142, male = 134},
		BARBARIAN = {female = 147, male = 143},
		DRUID = {female = 148, male = 144},
		WIZARD = {female = 149, male = 145},
		ORIENTAL = {female = 150, male = 146},
		PIRATE = {female = 155, male = 151},
		ASSASSIN = {female = 156, male = 152},
		BEGGAR = {female = 157, male = 153},
		SHAMAN = {female = 158, male = 154},
		NORSE = {female = 252, male = 251},
		NIGHTMARE = {female = 269, male = 268},
		JESTER = {female = 270, male = 273},
		BROTHERHOOD = {female = 279, male = 278},
		DEMONHUNTER = {female = 288, male = 289},
		YALAHARIAN = {female = 324, male = 325},
		WARMASTER = {female = 336, male = 335},
		WEEDING = {female = 329, male = 328},
		GAMEMASTER = {female = 75, male = 75},
		OLD_CM = {female = 266, male = 266},
		CM = {female = 302, male = 302}
	}

	-->> Posi��es de area para checagem ao login {creaturescripts/login.lua} (expulsa jogadores free de area premium)
	areaCheck = 
	{
		ARACURA_START = {x=2627 ,y=1043 ,z=7},
		ARACURA_END = {x=3097 ,y=1411 ,z=7},

		NORTHREND_START = {x=1677 ,y=1026 ,z=7},
		NORTHREND_END = {x=2103 ,y=1526 ,z=7},

		SALAZART_START = {x=1952 ,y=2299 ,z=7},
		SALAZART_END = {x=2773 ,y=2660 ,z=7}
	}
	
	towns =
	{
		QUENDOR = 1,
		ISLAND_OF_PEACE = 6
	}
	
	temp_towns =
	{
		BATTLEGROUND_TEAM_1 = 12,
		BATTLEGROUND_TEAM_2 = 13
	}
	
	-->> Posi��es dos templos

		QUENDOR = {x=2020 ,y=1903, z=7}
		THORN = {x=2383 ,y=1856, z=7}
		SALAZART = {x=2271 ,y=2686, z=7}
		ARACURA = {x=2897 ,y=1185, z=7}
		ISLAND_PEACE = {x=1234 ,y=2234 ,z=7}

	QUESTLOG = {
	
		ARIADNE = {
		
			LAIR 			= 3600,
			GHAZRAN_WING 	= 3601,
			CULTISTS_WING 	= 3602
		},

		DIVINE_ANKH = {
			COURSE_CHURCH	= 3610,
			CHAMBER_TEMPTATION = 3611
		},
		
		MISSION_BONARTES = {
			KILL_DEMONS	= 3613,
			KILL_HEROS = 3612,
			KILL_BEHEMOTHS = 3614
		},
		
		INQUISITION = {
			MISSION_OUTFIT = 3615,
			MISSION_FIRST_ADDON = 3616,
			MISSION_SHADOW_NEXUS = 3617
		}	
	}
	
	KILL_MISSIONS = {
		BONARTES_HERO = 8457,
		BONARTES_BEHEMOTH = 3731,
		BONARTES_DEMON = 1209	
	}
	
	ACTION_ID_RANGES = {
	
		MIN_FIELD_DAMAGE = 8300,
		MAX_FIELD_DAMAGE = 8499
	}
	
	WEEKDAY = {
		SUNDAY 		= 1,
		MONDAY 		= 2,
		TUESDAY 	= 3,
		WEDNESDAY 	= 4,
		THURSDAY 	= 5,
		FRIDAY 		= 6,
		SATURDAY 	= 7
	}
	
	CUSTOM_ITEMS = {
	
		DURIN_HELMET			= 11736,
		DURIN_ARMOR				= 11737,
		DURIN_LEGS				= 11738,
		DURIN_SHIELD			= 11739,
		
		TASHI_AHARON_HELMET		= 11740,
		TASHI_AHARON_ARMOR		= 11741,
		TASHI_AHARON_LEGS		= 11742,
		TASHI_AHARON_BOOTS		= 11743,
		
		WARDEN_HELMET			= 11744,
		WARDEN_ARMOR			= 11745,
		WARDEN_LEGS				= 11746,
		WARDEN_BOOTS			= 11747,
		
		DEATHFACE_HELMET		= 11748,
		DEATHFACE_ARMOR			= 11749,
		DEATHFACE_LEGS			= 11750,
		DEATHFACE_BOOTS			= 11751,
		
		DARK_DUST				= 12669,
		UNHOLY_SWORD			= 12670,
		TELEPORT_RUNE			= 12671,
		PREMIUM_SCROLL			= 12690,
		OUTFIT_TICKET			= 12691
	}

	CUSTOM_CHANNEL_PVP			= 10
	CUSTOM_CHANNEL_BG_CHAT		= 11
	
	PLAYERCUSTOMFLAG_CONTINUEONLINEWHENEXIT = 26
	
	-- Constantes para o OpenTibia, nao envolvem coisas do Darghos mas nao existem no projeto original
	HOUSE_ACCESS_NOT_INVITED = 0
	HOUSE_ACCESS_GUEST = 1
	HOUSE_ACCESS_SUBOWNER = 2
	HOUSE_ACCESS_OWNER = 3