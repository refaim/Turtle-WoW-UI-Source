OPTIONS_FARCLIP_MIN = 177
OPTIONS_FARCLIP_MAX = 777

GameOptions = {
	{
		name = VIDEO
	},
	{
		name = DISPLAY,
		options = {
			{
				name = "RESOLUTION",
				desc = OPTION_TOOLTIP_RESOLUTION,
				type = "dropdown",
				identifier = "DisplayResolution",
				getter = "GetCurrentResolution",
				setter = "SetScreenResolution",
				requirement = OPTION_RELOAD_REQUIREMENT
			},
			{
				name = "WINDOWED_MODE",
				desc = OPTION_TOOLTIP_WINDOWED_MODE,
				type = "checkbutton",
				cvar = "gxWindow",
				restartGx = true,
				warning = WARNING_WINDOWED_MODE
			},
			{
				name = "WINDOWED_MAXIMIZED",
				desc = OPTION_TOOLTIP_WINDOWED_MAXIMIZED,
				type = "checkbutton",
				cvar = "gxMaximize",
				dependency = {"gxWindow", "1"},
				restartGx = true
			},
			{
				name = "REFRESH",
				desc = OPTION_TOOLTIP_REFRESH,
				type = "dropdown",
				identifier = "DisplayRefresh",
				cvar = "gxRefresh",
				dependency = {"gxWindow", "0"},
				restartGx = true,
				ignoreOffset = true
			},
			{
				name = "DESKTOP_GAMMA",
				desc = OPTION_TOOLTIP_DESKTOP_GAMMA,
				type = "checkbutton",
				cvar = "desktopGamma",
				dependency = {"gxWindow", "0"},
				ignoreOffset = true
			},
			{
				name = "GAMMA",
				desc = OPTION_TOOLTIP_GAMMA,
				type = "slider",
				getter = "GetGamma",
				setter = "SetGamma",
				dependency = {"desktopGamma", "0"},
				minval = -0.5,
				maxval = 0.5,
				step = 0.1,
				ignoreOffset = true
			},
			{
				name = "MULTISAMPLE",
				desc = OPTION_TOOLTIP_MULTISAMPLE,
				type = "dropdown",
				identifier = "DisplayMultisampling",
				setter = "SetMultisampleFormat",
				getter = "GetCurrentMultisampleFormat"
			},
			{
				name = "USE_UISCALE",
				desc = OPTION_TOOLTIP_USE_UISCALE,
				type = "checkbutton",
				cvar = "useUiScale"},
			{
				name = "UI_SCALE",
				desc = OPTION_TOOLTIP_UI_SCALE,
				type = "slider",
				cvar = "uiscale",
				dependency = {"useUiScale", "1"},
				numberLabels = true,
				minval = 0.64,
				maxval = 1.0,
				step = 0.01
			}
		}
	},
	{
		name = WORLD_APPEARANCE,
		options = {
			{
				name = "WORLD_LOD",
				desc = OPTION_TOOLTIP_WORLD_LOD,
				type = "checkbutton",
				cvar = "lod"
			},
			{
				name = "FARCLIP",
				desc = OPTION_TOOLTIP_FARCLIP,
				type = "slider",
				cvar = "farclip",
				minval = OPTIONS_FARCLIP_MIN,
				maxval = OPTIONS_FARCLIP_MAX,
				step = (OPTIONS_FARCLIP_MAX - OPTIONS_FARCLIP_MIN) / 10
			},
			{
				name = "TERRAIN_MIP",
				desc = OPTION_TOOLTIP_TERRAIN_MIP,
				type = "slider",
				cvar = "shadowLevel",
				minval = 0,
				maxval = 1,
				step = 1,
				inverted = true,
				requirement = OPTION_RESTART_REQUIREMENT
			},
			{
				name = "ENVIRONMENT_DETAIL",
				desc = OPTION_TOOLTIP_ENVIRONMENT_DETAIL,
				type = "slider",
				cvar = "smallCull",
				minval = 0,
				maxval = 2,
				step = 1
			},
			{
				name = "TEXTURE_DETAIL",
				desc = OPTION_TOOLTIP_TEXTURE_DETAIL,
				type = "slider",
				cvar = "baseMip",
				minval = 0,
				maxval = 1,
				step = 1,
				inverted = true
			},
			{
				name = "SPELL_DETAIL",
				desc = OPTION_TOOLTIP_SPELL_DETAIL,
				type = "slider",
				cvar = "spellEffectLevel",
				minval = 0,
				maxval = 2,
				step = 1},
			{
				name = "WEATHER_DETAIL",
				desc = OPTION_TOOLTIP_WEATHER_DETAIL,
				type = "slider",
				cvar = "weatherDensity",
				minval = 0,
				maxval = 3,
				step = 1},
			{
				name = "ANISOTROPIC",
				desc = OPTION_TOOLTIP_ANISOTROPIC,
				type = "dropdown",
				identifier = "WorldAppearanceAnisotropic",
				cvar = "anisotropic",
				requirement = OPTION_RESTART_REQUIREMENT
			}
		}
	},
	{
		name = PIXEL_SHADERS,
		options = {
			{
				name = "ENABLE_ALL_SHADERS",
				desc = OPTION_TOOLTIP_ENABLE_ALL_SHADERS,
				type = "checkbutton",
				cvar = "pixelShaders"
			},
			{
				name = "TERRAIN_HIGHLIGHTS",
				desc = OPTION_TOOLTIP_TERRAIN_HIGHLIGHTS,
				type = "checkbutton",
				cvar = "specular",
				dependency = {"pixelShaders", "1"},
				requirement = OPTION_LOGOUT_REQUIREMENT
			},
			{
				name = "FULL_SCREEN_GLOW",
				desc = OPTION_TOOLTIP_FULL_SCREEN_GLOW,
				type = "checkbutton",
				cvar = "ffxGlow",
				dependency = {"pixelShaders", "1"}
			},
			{
				name = "DEATH_EFFECT",
				desc = OPTION_TOOLTIP_DEATH_EFFECT,
				type = "checkbutton",
				cvar = "ffxDeath",
				dependency = {"pixelShaders", "1"}
			},
			{
				name = "VERTEX_ANIMATION_SHADERS",
				desc = OPTION_TOOLTIP_VERTEX_ANIMATION_SHADERS,
				type = "checkbutton",
				cvar = "M2UseShaders",
				warning = WARNING_VERTEX_SHADERS,
				requirement = OPTION_LOGOUT_REQUIREMENT
			},
			{
				name = "PHONG_SHADING",
				desc = OPTION_TOOLTIP_PHONG_SHADING,
				type = "checkbutton",
				cvar = "M2UsePixelShaders",
				dependency = {"M2UseShaders", "1"}
			},
			{
				name = "USE_WEATHER_SHADER",
				desc = OPTION_TOOLTIP_USE_WEATHER_SHADER,
				type = "checkbutton",
				cvar = "useWeatherShaders"
			}
		}
	},
	{
		name = MISCELLANEOUS,
		options = {
			{
				name = "TRILINEAR_FILTERING",
				desc = OPTION_TOOLTIP_TRILINEAR_FILTERING,
				type = "checkbutton",
				cvar = "trilinear",
				requirement = OPTION_RESTART_REQUIREMENT
			},
			{
				name = "VERTICAL_SYNC",
				desc = OPTION_TOOLTIP_VERTICAL_SYNC,
				type = "checkbutton",
				cvar = "gxVSync",
				restartGx = true
			},
			{
				name = "TRIPLE_BUFFER",
				desc = OPTION_TOOLTIP_TRIPLE_BUFFER,
				type = "checkbutton",
				cvar = "gxTripleBuffer",
				dependency = {"gxVSync", "1"},
				restartGx = true
			},
			{
				name = "CINEMATIC_SUBTITLES",
				desc = OPTION_TOOLTIP_CINEMATIC_SUBTITLES,
				type = "checkbutton",
				cvar = "movieSubtitle"
			},
			{
				name = "HARDWARE_CURSOR",
				desc = OPTION_TOOLTIP_HARDWARE_CURSOR,
				type = "checkbutton",
				cvar = "gxCursor",
				restartGx = true
			},
			{
				name = "FIX_LAG",
				desc = OPTION_TOOLTIP_FIX_LAG,
				type = "checkbutton",
				cvar = "gxFixLag",
				dependency = {"gxCursor", "1"},
				restartGx = true
			}
		}
	},
	{
		name = SOUND
	},
	{
		name = GENERAL,
		options = {
			{
				name = "ENABLE_ALL_SOUND",
				desc = OPTION_TOOLTIP_ENABLE_ALL_SOUND,
				type = "checkbutton",
				cvar = "MasterSoundEffects"
			},
			{
				name = "ENABLE_AMBIENCE",
				desc = OPTION_TOOLTIP_ENABLE_AMBIENCE,
				type = "checkbutton",
				cvar = "EnableAmbience",
				dependency = {"MasterSoundEffects", "1"}
			},
			{
				name = "ENABLE_ERROR_SPEECH",
				desc = OPTION_TOOLTIP_ENABLE_ERROR_SPEECH,
				type = "checkbutton",
				cvar = "EnableErrorSpeech",
				dependency = {"MasterSoundEffects", "1"}
			},
			{
				name = "ENABLE_MUSIC",
				desc = OPTION_TOOLTIP_ENABLE_MUSIC,
				type = "checkbutton",
				cvar = "EnableMusic"
			},
			{
				name = "ENABLE_SOUND_AT_CHARACTER",
				desc = OPTION_TOOLTIP_ENABLE_SOUND_AT_CHARACTER,
				type = "checkbutton",
				cvar = "SoundListenerAtCharacter"
			},
			{
				name = "ENABLE_EMOTE_SOUNDS",
				desc = OPTION_TOOLTIP_ENABLE_EMOTE_SOUNDS,
				type = "checkbutton",
				cvar = "EmoteSounds"
			},
			{
				name = "ENABLE_MUSIC_LOOPING",
				desc = OPTION_TOOLTIP_ENABLE_MUSIC_LOOPING,
				type = "checkbutton",
				cvar = "SoundZoneMusicNoDelay"
			},
			{
				name = "MASTER_VOLUME",
				desc = OPTION_TOOLTIP_MASTER_VOLUME,
				type = "slider",
				cvar = "MasterVolume",
				minval = 0,
				maxval = 1,
				step = 0.1
			},
			{
				name = "SOUND_VOLUME",
				desc = OPTION_TOOLTIP_SOUND_VOLUME,
				type = "slider",
				cvar = "SoundVolume",
				minval = 0,
				maxval = 1,
				step = 0.1
			},
			{
				name = "MUSIC_VOLUME",
				desc = OPTION_TOOLTIP_MUSIC_VOLUME,
				type = "slider",
				cvar = "MusicVolume",
				minval = 0,
				maxval = 1,
				step = 0.1
			},
			{
				name = "AMBIENCE_VOLUME",
				desc = OPTION_TOOLTIP_AMBIENCE_VOLUME,
				type = "slider",
				cvar = "AmbienceVolume",
				minval = 0,
				maxval = 1,
				step = 0.1
			}
		}
	},
	{
		name = INTERFACE
	},
	{
		name = ACTIONBAR_LABEL,
		options = {
			{
				name = "LOCK_ACTIONBAR_TEXT",
				desc = OPTION_TOOLTIP_LOCK_ACTIONBAR,
				type = "checkbutton",
				uvar = "LOCK_ACTIONBAR",
				defaultValue = "0"
			},
			{
				name = "SHOW_MULTIBAR1_TEXT",
				desc = OPTION_TOOLTIP_SHOW_MULTIBAR1,
				type = "checkbutton",
				getter = "MultiBar1_IsVisible",
				setter = "MultiBar1_Update",
				defaultValue = "0"
			},
			{
				name = "SHOW_MULTIBAR2_TEXT",
				desc = OPTION_TOOLTIP_SHOW_MULTIBAR2,
				type = "checkbutton",
				getter = "MultiBar2_IsVisible",
				setter = "MultiBar2_Update",
				defaultValue = "0"
			},
			{
				name = "SHOW_MULTIBAR3_TEXT",
				desc = OPTION_TOOLTIP_SHOW_MULTIBAR3,
				type = "checkbutton",
				getter = "MultiBar3_IsVisible",
				setter = "MultiBar3_Update",
				defaultValue = "0"
			},
			{
				name = "SHOW_MULTIBAR4_TEXT",
				desc = OPTION_TOOLTIP_SHOW_MULTIBAR4,
				type = "checkbutton",
				getter = "MultiBar4_IsVisible",
				setter = "MultiBar4_Update",
				dependency = {"MultiBar3_IsVisible()", 1},
				defaultValue = "0"
			},
			{
				name = "ALWAYS_SHOW_MULTIBARS_TEXT",
				desc = OPTION_TOOLTIP_ALWAYS_SHOW_MULTIBARS,
				type = "checkbutton",
				uvar = "ALWAYS_SHOW_MULTIBARS",
				func = "MultiActionBar_UpdateGridVisibility"
			}
		}
	},
	{
		name = CAMERA_LABEL,
		options = {
			{
				name = "CAMERA_FOLLOWING_STYLE",
				type = "dropdown",
				cvar = "cameraSmoothStyle",
				identifier = "CameraFollowStyle"
			},
			{
				name = "AUTO_FOLLOW_SPEED",
				desc = OPTION_TOOLTIP_AUTO_FOLLOW_SPEED,
				type = "slider",
				cvar = "cameraYawSmoothSpeed",
				dependency = {"cameraSmoothStyle", "1", "2"},
				minval = 90,
				maxval = 270,
				step = 10
			},
			{
				name = "FOLLOW_TERRAIN",
				desc = OPTION_TOOLTIP_FOLLOW_TERRAIN,
				type = "checkbutton",
				cvar = "cameraTerrainTilt"
			},
			{
				name = "HEAD_BOB",
				desc = OPTION_TOOLTIP_HEAD_BOB,
				type = "checkbutton",
				cvar = "cameraBobbing"
			},
			{
				name = "WATER_COLLISION",
				desc = OPTION_TOOLTIP_WATER_COLLISION,
				type = "checkbutton",
				cvar = "cameraWaterCollision"
			},
			{
				name = "SMART_PIVOT",
				desc = OPTION_TOOLTIP_SMART_PIVOT,
				type = "checkbutton",
				cvar = "cameraPivot"
			},
			{
				name = "MOUSE_LOOK_SPEED",
				desc = OPTION_TOOLTIP_MOUSE_LOOK_SPEED,
				type = "slider",
				cvar = "cameraYawMoveSpeed",
				minval = 90,
				maxval = 270,
				step = 10
			},
			{
				name = "MAX_FOLLOW_DIST",
				desc = OPTION_TOOLTIP_MAX_FOLLOW_DIST,
				type = "slider",
				cvar = "cameraDistanceMaxFactor",
				minval = 1,
				maxval = 2,
				step = 0.1
			}
		}
	},
	{
		name = CHAT_LABEL,
		options = {
			{
				name = "SIMPLE_CHAT_TEXT",
				desc = OPTION_TOOLTIP_SIMPLE_CHAT,
				type = "checkbutton",
				uvar = "SIMPLE_CHAT",
				defaultValue = "1",
				func = "Options_SetSimpleChat"
			},
			{
				name = "CHAT_LOCKED_TEXT",
				desc = OPTION_TOOLTIP_CHAT_LOCKED,
				type = "checkbutton",
				uvar = "CHAT_LOCKED",
				defaultValue = "1"
			},
			{
				name = "GUILDMEMBER_ALERT",
				desc = OPTION_TOOLTIP_GUILDMEMBER_ALERT,
				type = "checkbutton",
				cvar = "guildMemberNotify"
			},
			{
				name = "REMOVE_CHAT_DELAY_TEXT",
				desc = OPTION_TOOLTIP_REMOVE_CHAT_DELAY,
				type = "checkbutton",
				uvar = "REMOVE_CHAT_DELAY",
				defaultValue = "0",
				func = "SetChatMouseOverDelay"
			},
			{
				name = "CHAT_BUBBLES_TEXT",
				desc = OPTION_TOOLTIP_CHAT_BUBBLES,
				type = "checkbutton",
				cvar = "ChatBubbles"
			},
			{
				name = "PARTY_CHAT_BUBBLES_TEXT",
				desc = OPTION_TOOLTIP_PARTY_CHAT_BUBBLES,
				type = "checkbutton",
				cvar = "ChatBubblesParty"
			},
			{
				name = "SHOW_LOOT_SPAM",
				desc = OPTION_TOOLTIP_SHOW_LOOT_SPAM,
				type = "checkbutton",
				cvar = "showLootSpam"
			},
			{
				name = "AUTO_JOIN_GUILD_CHANNEL",
				desc = OPTION_TOOLTIP_AUTO_JOIN_GUILD_CHANNEL,
				type = "checkbutton",
				getter = "GetGuildRecruitmentMode",
				setter = "SetGuildRecruitmentMode",
				defaultValue = "1"
			},
			{
				name = "PROFANITY_FILTER",
				desc = OPTION_TOOLTIP_PROFANITY_FILTER,
				type = "checkbutton",
				cvar = "profanityFilter"
			}
		}
	},
	{
		name = CONTROLS_LABEL,
		options = {
			{
				name = "MOUSE_SENSITIVITY",
				desc = OPTION_TOOLTIP_MOUSE_SENSITIVITY,
				type = "slider",
				cvar = "mousespeed",
				minval = 0.5,
				maxval = 1.5,
				step = 0.05
			},
			{
				name = "INVERT_MOUSE",
				desc = OPTION_TOOLTIP_INVERT_MOUSE,
				type = "checkbutton",
				cvar = "mouseInvertPitch"
			},
			{
				name = "CLICK_TO_MOVE",
				desc = OPTION_TOOLTIP_CLICK_TO_MOVE,
				type = "checkbutton",
				cvar = "autointeract"
			},
			{
				name = "CLICK_CAMERA_STYLE",
				desc = OPTION_TOOLTIP_CLICK_CAMERA_STYLE,
				type = "dropdown",
				cvar = "cameraSmoothTrackingStyle",
				identifier = "ClickToMove",
				dependency = {"autointeract", "1"}
			},
			{
				name = "GAMEFIELD_DESELECT_TEXT",
				desc = OPTION_TOOLTIP_GAMEFIELD_DESELECT,
				type = "checkbutton",
				cvar = "deselectOnClick",
				inverted = true
			},
			{
				name = "ASSIST_ATTACK",
				desc = OPTION_TOOLTIP_ASSIST_ATTACK,
				type = "checkbutton",
				cvar = "assistAttack"
			},
			{
				name = "CLEAR_AFK",
				desc = OPTION_TOOLTIP_CLEAR_AFK,
				type = "checkbutton",
				cvar = "autoClearAFK"
			},
			{
				name = "AUTO_SELF_CAST_TEXT",
				desc = OPTION_TOOLTIP_AUTO_SELF_CAST,
				type = "checkbutton",
				cvar = "autoSelfCast"
			},
			{
				name = "BLOCK_TRADES",
				desc = OPTION_TOOLTIP_BLOCK_TRADES,
				type = "checkbutton",
				cvar = "BlockTrades"
			},
			{
				name = "LOOT_AT_WINDOW_CURSOR_TEXT",
				desc = OPTION_TOOLTIP_LOOT_AT_WINDOW_CURSOR,
				type = "checkbutton",
				uvar = "LOOT_WINDOW_AT_CURSOR",
				defaultValue = "0"
			}
		}
	},
	{
		name = DISPLAY,
		options = {
			{
				name = "USE_UBERTOOLTIPS",
				desc = OPTION_TOOLTIP_USE_UBERTOOLTIPS,
				type = "checkbutton",
				cvar = "UberTooltips"
			},
			{
				name = "STATUS_BAR_TEXT",
				desc = OPTION_TOOLTIP_STATUS_BAR,
				type = "checkbutton",
				cvar = "statusBarText"
			},
			{
				name = "SHOW_TARGET_OF_TARGET_TEXT",
				desc = OPTION_TOOLTIP_SHOW_TARGET_OF_TARGET,
				type = "checkbutton",
				uvar = "SHOW_TARGET_OF_TARGET",
				defaultValue = "0"
			},
			{
				name = "TARGET_OF_TARGET_STATE_TEXT",
				desc = OPTION_TOOLTIP_TARGET_OF_TARGET_STATE,
				type = "dropdown",
				uvar = "SHOW_TARGET_OF_TARGET_STATE",
				identifier = "TargetOfTarget",
				dependency = {"SHOW_TARGET_OF_TARGET", "1"}
			},
			{
				name = "SHOW_PLAYER_NAMES",
				desc = OPTION_TOOLTIP_SHOW_PLAYER_NAMES,
				type = "checkbutton",
				cvar = "UnitNamePlayer"
			},
			{
				name = "SHOW_GUILD_NAMES",
				desc = OPTION_TOOLTIP_SHOW_GUILD_NAMES,
				type = "checkbutton",
				cvar = "UnitNamePlayerGuild",
				dependency = {"UnitNamePlayer", "1"}
			},
			{
				name = "SHOW_PLAYER_TITLES",
				desc = OPTION_TOOLTIP_SHOW_PLAYER_TITLES,
				type = "checkbutton",
				cvar = "UnitNamePlayerPVPTitle",
				dependency = {"UnitNamePlayer", "1"}
			},
			{
				name = "SHOW_PLAYER_CHALLENGES_TEXT",
				desc = OPTION_TOOLTIP_SHOW_PLAYER_CHALLENGES,
				type = "checkbutton",
				uvar = "PLAYER_CHALLENGES",
				defaultValue = "1"
			},
			{
				name = "SHOW_GUILD_NAMES_ON_TOOLTIPS",
				desc = OPTION_TOOLTIP_SHOW_GUILD_NAMES_ON_TOOLTIPS,
				type = "checkbutton",
				uvar = "TOOLTIP_GUILD_NAMES",
				defaultValue = "0"
			},
			{
				name = "SHOW_NPC_NAMES",
				desc = OPTION_TOOLTIP_SHOW_NPC_NAMES,
				type = "checkbutton",
				cvar = "UnitNameNPC"
			},
			{
				name = "SHOW_OWN_NAME",
				desc = OPTION_TOOLTIP_SHOW_OWN_NAME,
				type = "checkbutton",
				cvar = "UnitNameOwn"
			},
			{
				name = "SHOW_CLOAK",
				desc = OPTION_TOOLTIP_SHOW_CLOAK,
				type = "checkbutton",
				getter = "ShowingCloak",
				setter = "ShowCloak",
				defaultValue = "1"
			},
			{
				name = "SHOW_HELM",
				desc = OPTION_TOOLTIP_SHOW_HELM,
				type = "checkbutton",
				getter = "ShowingHelm",
				setter = "ShowHelm",
				defaultValue = "1"
			},
			{
				name = "SHOW_QUEST_FADING_TEXT",
				desc = OPTION_TOOLTIP_SHOW_QUEST_FADING,
				type = "checkbutton",
				uvar = "QUEST_FADING_DISABLE",
				defaultValue = "1"
			},
			{
				name = "SHOW_BUFF_DURATION_TEXT",
				desc = OPTION_TOOLTIP_SHOW_BUFF_DURATION,
				type = "checkbutton",
				uvar = "SHOW_BUFF_DURATIONS",
				func = "BuffButtons_UpdatePositions",
				defaultValue = "1"
			},
			{
				name = "HIDE_OUTDOOR_WORLD_STATE_TEXT",
				desc = OPTION_TOOLTIP_HIDE_OUTDOOR_WORLD_STATE,
				type = "checkbutton",
				uvar = "HIDE_OUTDOOR_WORLD_STATE",
				defaultValue = "0",
				func = "WorldStateAlwaysUpFrame_Update"
			},
			{
				name = "AUTO_QUEST_WATCH_TEXT",
				desc = OPTION_TOOLTIP_AUTO_QUEST_WATCH,
				type = "checkbutton",
				uvar = "AUTO_QUEST_WATCH",
				defaultValue = "1"
			}
		}
	},
	{
		name = COMBAT_TEXT_LABEL,
		options = {
			{
				name = "SHOW_COMBAT_TEXT_TEXT",
				desc = OPTION_TOOLTIP_SHOW_COMBAT_TEXT,
				type = "checkbutton",
				uvar = "SHOW_COMBAT_TEXT",
				defaultValue = "0",
				func = "Options_UpdateCombatText"
			},
			{
				name = "COMBAT_TEXT_FLOAT_MODE_LABEL",
				desc = OPTION_TOOLTIP_COMBAT_TEXT_MODE,
				type = "dropdown",
				uvar = "COMBAT_TEXT_FLOAT_MODE",
				identifier = "CombatTextMode",
				dependency = {"SHOW_COMBAT_TEXT", "1"},
				func = "CombatText_UpdateDisplayedMessages"
			},
			{
				name = "COMBAT_TEXT_SHOW_LOW_HEALTH_MANA_TEXT",
				desc = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_LOW_HEALTH_MANA,
				type = "checkbutton",
				uvar = "COMBAT_TEXT_SHOW_LOW_HEALTH_MANA",
				dependency = {"SHOW_COMBAT_TEXT", "1"},
				defaultValue = "1",
				func = "CombatText_UpdateDisplayedMessages"
			},
			{
				name = "COMBAT_TEXT_SHOW_AURAS_TEXT",
				desc = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_AURAS,
				type = "checkbutton",
				uvar = "COMBAT_TEXT_SHOW_AURAS",
				dependency = {"SHOW_COMBAT_TEXT", "1"},
				defaultValue = "1",
				func = "CombatText_UpdateDisplayedMessages"
			},
			{
				name = "COMBAT_TEXT_SHOW_AURA_FADE_TEXT",
				desc = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_AURA_FADE,
				type = "checkbutton",
				uvar = "COMBAT_TEXT_SHOW_AURA_FADE",
				dependency = {"SHOW_COMBAT_TEXT", "1"},
				defaultValue = "0",
				func = "CombatText_UpdateDisplayedMessages"
			},
			{
				name = "COMBAT_TEXT_SHOW_COMBAT_STATE_TEXT",
				desc = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_COMBAT_STATE,
				type = "checkbutton",
				uvar = "COMBAT_TEXT_SHOW_COMBAT_STATE",
				dependency = {"SHOW_COMBAT_TEXT", "1"},
				defaultValue = "1",
				func = "CombatText_UpdateDisplayedMessages"
			},
			{
				name = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS_TEXT",
				desc = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_DODGE_PARRY_MISS,
				type = "checkbutton",
				uvar = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS",
				dependency = {"SHOW_COMBAT_TEXT", "1"},
				defaultValue = "0",
				func = "CombatText_UpdateDisplayedMessages"
			},
			{
				name = "COMBAT_TEXT_SHOW_RESISTANCES_TEXT",
				desc = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_RESISTANCES,
				type = "checkbutton",
				uvar = "COMBAT_TEXT_SHOW_RESISTANCES",
				dependency = {"SHOW_COMBAT_TEXT", "1"},
				defaultValue = "0",
				func = "CombatText_UpdateDisplayedMessages"
			},
			{
				name = "COMBAT_TEXT_SHOW_REPUTATION_TEXT",
				desc = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_REPUTATION,
				type = "checkbutton",
				uvar = "COMBAT_TEXT_SHOW_REPUTATION",
				dependency = {"SHOW_COMBAT_TEXT", "1"},
				defaultValue = "0",
				func = "CombatText_UpdateDisplayedMessages"
			},
			{
				name = "COMBAT_TEXT_SHOW_REACTIVES_TEXT",
				desc = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_REACTIVES,
				type = "checkbutton",
				uvar = "COMBAT_TEXT_SHOW_REACTIVES",
				dependency = {"SHOW_COMBAT_TEXT", "1"},
				defaultValue = "0",
				func = "CombatText_UpdateDisplayedMessages"
			},
			{
				name = "COMBAT_TEXT_SHOW_FRIENDLY_NAMES_TEXT",
				desc = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_FRIENDLY_NAMES,
				type = "checkbutton",
				uvar = "COMBAT_TEXT_SHOW_FRIENDLY_NAMES",
				dependency = {"SHOW_COMBAT_TEXT", "1"},
				defaultValue = "0",
				func = "CombatText_UpdateDisplayedMessages"
			},
			{
				name = "COMBAT_TEXT_SHOW_COMBO_POINTS_TEXT",
				desc = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_COMBO_POINTS,
				type = "checkbutton",
				uvar = "COMBAT_TEXT_SHOW_COMBO_POINTS",
				dependency = {"SHOW_COMBAT_TEXT", "1"},
				defaultValue = "0",
				func = "CombatText_UpdateDisplayedMessages"
			},
			{
				name = "COMBAT_TEXT_SHOW_MANA_TEXT",
				desc = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_MANA,
				type = "checkbutton",
				uvar = "COMBAT_TEXT_SHOW_MANA",
				dependency = {"SHOW_COMBAT_TEXT", "1"},
				defaultValue = "0",
				func = "CombatText_UpdateDisplayedMessages"
			},
			{
				name = "COMBAT_TEXT_SHOW_HONOR_GAINED_TEXT",
				desc = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_HONOR_GAINED,
				type = "checkbutton",
				uvar = "COMBAT_TEXT_SHOW_HONOR_GAINED",
				dependency = {"SHOW_COMBAT_TEXT", "1"},
				defaultValue = "1",
				func = "CombatText_UpdateDisplayedMessages"
			},
			{
				name = "SHOW_DAMAGE_TEXT",
				desc = OPTION_TOOLTIP_SHOW_DAMAGE,
				type = "checkbutton",
				cvar = "CombatDamage"},
			{
				name = "LOG_PERIODIC_EFFECTS",
				desc = OPTION_TOOLTIP_LOG_PERIODIC_EFFECTS,
				type = "checkbutton",
				cvar = "CombatLogPeriodicSpells",
				dependency = {"CombatDamage", "1"}
			},
			{
				name = "SHOW_PET_MELEE_DAMAGE",
				desc = OPTION_TOOLTIP_SHOW_PET_MELEE_DAMAGE,
				type = "checkbutton",
				cvar = "PetMeleeDamage",
				dependency = {"CombatDamage", "1"}
			}
		}
	},
	{
		name = RAID_AND_PARTY,
		options = {
			{
				name = "HIDE_PARTY_INTERFACE_TEXT",
				desc = OPTION_TOOLTIP_HIDE_PARTY_INTERFACE,
				type = "checkbutton",
				uvar = "HIDE_PARTY_INTERFACE",
				dependency = {"GROUP_REPLACE_PARTY", "0"},
				ignoreOffset = true,
				defaultValue = "0",
				func = "RaidOptionsFrame_UpdatePartyFrames"
			},
			{
				name = "SHOW_PARTY_BACKGROUND_TEXT",
				desc = OPTION_TOOLTIP_SHOW_PARTY_BACKGROUND,
				type = "checkbutton",
				uvar = "SHOW_PARTY_BACKGROUND",
				func = "UpdatePartyMemberBackground",
				defaultValue = "0"
			},
			{
				name = "SHOW_PARTY_PETS_TEXT",
				desc = OPTION_TOOLTIP_SHOW_PARTY_PETS,
				type = "checkbutton",
				uvar = "SHOW_PARTY_PETS",
				defaultValue = "1",
				requirement = OPTION_RELOAD_REQUIREMENT
			},
			{
				name = "SHOW_DISPELLABLE_DEBUFFS_TEXT",
				desc = OPTION_TOOLTIP_SHOW_DISPELLABLE_DEBUFFS,
				type = "checkbutton",
				uvar = "SHOW_DISPELLABLE_DEBUFFS",
				defaultValue = "1"
			},
			{
				name = "SHOW_CASTABLE_BUFFS_TEXT",
				desc = OPTION_TOOLTIP_SHOW_CASTABLE_BUFFS,
				type = "checkbutton",
				uvar = "SHOW_CASTABLE_BUFFS",
				defaultValue = "1"
			},
			{
				name = "GROUP_ENABLED_TEXT",
				desc = OPTION_TOOLTIP_GROUP_ENABLED,
				type = "checkbutton",
				uvar = "GROUP_ENABLED",
				defaultValue = "0",
				func = "GroupFrame_Toggle"
			},
			{
				name = "TOGGLE_MOVEMENT",
				type = "button",
				dependency = {"GROUP_ENABLED", "1"},
				func = "GroupFrame_ToggleMovement"
			},
			{
				name = "UNIT_POPUP_MOVE_RESET",
				type = "button",
				dependency = {"GROUP_ENABLED", "1"},
				func = "GroupFrame_ResetPosition"
			},
			{
				name = "GROUP_REPLACE_PARTY_TEXT",
				desc = OPTION_TOOLTIP_GROUP_REPLACE_PARTY,
				type = "checkbutton",
				uvar = "GROUP_REPLACE_PARTY",
				dependency = {"GROUP_ENABLED", "1"},
				defaultValue = "0",
				func = "GroupFrame_Toggle"
			},
			{
				name = "GROUP_CLASS_COLORED_NAMES_TEXT",
				desc = OPTION_TOOLTIP_GROUP_CLASS_COLORED_NAMES,
				type = "checkbutton",
				uvar = "GROUP_CLASS_COLORED_NAMES",
				func = "GroupFrame_Update",
				dependency = {"GROUP_ENABLED", "1"},
				defaultValue = "0"
			},
			{
				name = "GROUP_UNIT_HEALTH_COLOR_TEXT",
				desc = OPTION_TOOLTIP_GROUP_UNIT_HEALTH_COLORS,
				type = "dropdown",
				uvar = "GROUP_UNIT_HEALTH_COLOR",
				identifier = "GroupUnitHealthColor",
				dependency = {"GROUP_ENABLED", "1"},
				func = "GroupFrame_Update"
			},
			{
				name = "GROUP_DEBUFF_INDICATOR_STYLE_TEXT",
				desc = OPTION_TOOLTIP_GROUP_DEBUFF_INDICATOR_STYLE,
				type = "dropdown",
				uvar = "GROUP_DEBUFF_INDICATOR_STYLE",
				identifier = "GroupDebuffIndicatorStyle",
				dependency = {"GROUP_ENABLED", "1"},
				func = "GroupFrame_UpdateLayout"
			},
			{
				name = "GROUP_HEADERS_TEXT",
				desc = OPTION_TOOLTIP_GROUP_HEADERS,
				type = "checkbutton",
				uvar = "GROUP_HEADERS",
				func = "GroupFrame_UpdateLayout",
				dependency = {"GROUP_ENABLED", "1"},
				defaultValue = "1"
			},
			{
				name = "GROUP_BORDER_TEXT",
				desc = OPTION_TOOLTIP_GROUP_BORDER,
				type = "checkbutton",
				uvar = "GROUP_BORDER",
				func = "GroupFrame_UpdateLayout",
				dependency = {"GROUP_ENABLED", "1"},
				defaultValue = "1"
			},
			{
				name = "GROUP_UNIT_GROW_DIRECTION_TEXT",
				desc = OPTION_TOOLTIP_GROUP_UNIT_GROW_DIRECTION,
				type = "dropdown",
				uvar = "GROUP_UNIT_GROW_DIRECTION",
				identifier = "GroupUnitGrowDirection",
				dependency = {"GROUP_ENABLED", "1"},
				func = "GroupFrame_UpdateLayout"
			},
			{
				name = "GROUP_UNIT_WIDTH_TEXT",
				type = "slider",
				uvar = "GROUP_UNIT_WIDTH",
				func = "GroupFrame_UpdateLayout",
				dependency = {"GROUP_ENABLED", "1"},
				numberLabels = true,
				minval = 54,
				maxval = 96,
				step = 2,
				defaultValue = 60
			},
			{
				name = "GROUP_UNIT_HEIGHT_TEXT",
				type = "slider",
				uvar = "GROUP_UNIT_HEIGHT",
				func = "GroupFrame_UpdateLayout",
				dependency = {"GROUP_ENABLED", "1"},
				numberLabels = true,
				minval = 36,
				maxval = 48,
				step = 2,
				defaultValue = 40
			}
		}
	},
	{
		name = HELP_LABEL,
		options = {
			{
				name = "SHOW_TUTORIALS",
				desc = OPTION_TOOLTIP_SHOW_TUTORIALS,
				type = "checkbutton",
				getter = "TutorialsEnabled",
				setter = "Options_UpdateTutorials",
				defaultValue = "1"
			},
			{
				name = "SHOW_NEWBIE_TIPS_TEXT",
				desc = OPTION_TOOLTIP_SHOW_NEWBIE_TIPS,
				type = "checkbutton",
				uvar = "SHOW_NEWBIE_TIPS",
				defaultValue = "1"
			},
			{
				name = "SHOW_TIPOFTHEDAY_TEXT",
				desc = OPTION_TOOLTIP_SHOW_TIPOFTHEDAY,
				type = "checkbutton",
				cvar = "showGameTips"
			},
			{
				name = "RESET_TUTORIALS",
				type = "button",
				func = "Options_ResetTutorials"
			}
		}
	}
}

function Options_RegisterUVars()
	-- Group UI UVars
	GROUP_ENABLED = "0"
	RegisterForSave("GROUP_ENABLED")
	GROUP_REPLACE_PARTY = "0"
	RegisterForSave("GROUP_REPLACE_PARTY")
	GROUP_UNIT_HEALTH_COLOR = "1"
	RegisterForSave("GROUP_UNIT_HEALTH_COLOR")
	GROUP_CLASS_COLORED_NAMES = "0"
	RegisterForSave("GROUP_CLASS_COLORED_NAMES")
	GROUP_DEBUFF_INDICATOR_STYLE = "1"
	RegisterForSave("GROUP_DEBUFF_INDICATOR_STYLE")
	GROUP_HEADERS = "1"
	RegisterForSave("GROUP_HEADERS")
	GROUP_BORDER = "1"
	RegisterForSave("GROUP_BORDER")
	GROUP_UNIT_GROW_DIRECTION = "1"
	RegisterForSave("GROUP_UNIT_GROW_DIRECTION")
	GROUP_UNIT_WIDTH = 60
	RegisterForSave("GROUP_UNIT_WIDTH")
	GROUP_UNIT_HEIGHT = 40
	RegisterForSave("GROUP_UNIT_HEIGHT")
	-- Misc
	TOOLTIP_GUILDNAME = "0"
	RegisterForSave("TOOLTIP_GUILD_NAMES")
	PLAYER_CHALLENGES = "1"
	RegisterForSave("PLAYER_CHALLENGES")
	LOOT_WINDOW_AT_CURSOR = "0"
	RegisterForSave("LOOT_WINDOW_AT_CURSOR")
	SIMPLE_CHAT = "0"
	RegisterForSave("SIMPLE_CHAT")
	CHAT_LOCKED = "0"
	RegisterForSave("CHAT_LOCKED")
	REMOVE_CHAT_DELAY = "0"
	RegisterForSave("REMOVE_CHAT_DELAY")
	SHOW_NEWBIE_TIPS = "1"
	RegisterForSave("SHOW_NEWBIE_TIPS")
	LOCK_ACTIONBAR = "0"
	RegisterForSave("LOCK_ACTIONBAR")
	SHOW_BUFF_DURATIONS = "1"
	RegisterForSave("SHOW_BUFF_DURATIONS")
	ALWAYS_SHOW_MULTIBARS = "0"
	RegisterForSave("ALWAYS_SHOW_MULTIBARS")
	SHOW_PARTY_PETS = "1"
	RegisterForSave("SHOW_PARTY_PETS")
	QUEST_FADING_DISABLE = "1"
	RegisterForSave("QUEST_FADING_DISABLE")
	SHOW_PARTY_BACKGROUND = "0"
	RegisterForSave("SHOW_PARTY_BACKGROUND")
	HIDE_PARTY_INTERFACE = "0"
	RegisterForSave("HIDE_PARTY_INTERFACE")
	SHOW_TARGET_OF_TARGET = "0"
	SHOW_TARGET_OF_TARGET_STATE = "5"
	RegisterForSave("SHOW_TARGET_OF_TARGET")
	RegisterForSave("SHOW_TARGET_OF_TARGET_STATE")
	HIDE_OUTDOOR_WORLD_STATE = "0"
	RegisterForSave("HIDE_OUTDOOR_WORLD_STATE")
	AUTO_QUEST_WATCH = 1
	RegisterForSave("AUTO_QUEST_WATCH")
	-- Combat text UVars
	SHOW_COMBAT_TEXT = "0"
	RegisterForSave("SHOW_COMBAT_TEXT")
	COMBAT_TEXT_SHOW_LOW_HEALTH_MANA = "1"
	RegisterForSave("COMBAT_TEXT_SHOW_LOW_HEALTH_MANA")
	COMBAT_TEXT_SHOW_AURAS = "1"
	RegisterForSave("COMBAT_TEXT_SHOW_AURAS")
	COMBAT_TEXT_SHOW_AURA_FADE = "0"
	RegisterForSave("COMBAT_TEXT_SHOW_AURA_FADE")
	COMBAT_TEXT_SHOW_COMBAT_STATE = "1"
	RegisterForSave("COMBAT_TEXT_SHOW_COMBAT_STATE")
	COMBAT_TEXT_SHOW_DODGE_PARRY_MISS = "0"
	RegisterForSave("COMBAT_TEXT_SHOW_DODGE_PARRY_MISS")
	COMBAT_TEXT_SHOW_RESISTANCES = "0"
	RegisterForSave("COMBAT_TEXT_SHOW_RESISTANCES")
	COMBAT_TEXT_SHOW_REPUTATION = "0"
	RegisterForSave("COMBAT_TEXT_SHOW_REPUTATION")
	COMBAT_TEXT_SHOW_REACTIVES = "0"
	RegisterForSave("COMBAT_TEXT_SHOW_REACTIVES")
	COMBAT_TEXT_SHOW_FRIENDLY_NAMES = "0"
	RegisterForSave("COMBAT_TEXT_SHOW_FRIENDLY_NAMES")
	COMBAT_TEXT_SHOW_COMBO_POINTS = "0"
	RegisterForSave("COMBAT_TEXT_SHOW_COMBO_POINTS")
	COMBAT_TEXT_SHOW_MANA = "0"
	RegisterForSave("COMBAT_TEXT_SHOW_MANA")
	COMBAT_TEXT_FLOAT_MODE = "1"
	RegisterForSave("COMBAT_TEXT_FLOAT_MODE")
	COMBAT_TEXT_SHOW_HONOR_GAINED = "1"
	RegisterForSave("COMBAT_TEXT_SHOW_HONOR_GAINED")
	-- Nameplates UVars
	RegisterForSave("NAMEPLATES_ON")
	NAMEPLATES_ON = nil
	RegisterForSave("FRIENDNAMEPLATES_ON")
	FRIENDNAMEPLATES_ON = nil
end