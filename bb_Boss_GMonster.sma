#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fun>
#include <basebuilder>
#include <fakemeta>
#include <eG>
#include <hamsandwich>
#include <xs>
#include <dhudmessage>

#define BOSS_ALARM	"basebuilder/FAITH/Boss_Alarm.wav" // Alarm Sound

native zp_override_user_model(id, const newmodel[], modelindex = 0)

#define	TASK_BOSS_SKILL_COUNTDOWN 100
#define TASK_OFF_SKILL 100

new bool:g_bIsBoss[33]
new bool:g_bBossNoDmg = false
new bool:g_bBossExHit = false
new g_iBossPhase
new g_iBossCountdown[33]
new g_msgScreenShake

public plugin_init()
{
	g_msgScreenShake = get_user_msgid("ScreenShake")
}

public client_connected(id)
{
	g_bIsBoss[id] = false
	g_iBossCountdown[id] = 0
	g_iBossPhase = 0
}

public plugin_precache()
{
	// -- G-1
	precache_model("models/player/k_gmonster1/k_gmonster1.mdl")
	precache_model("models/FAITH/v_knife_gmonster01.mdl")
	
	// -- G-2
	precache_model("models/player/k_gmonster2/k_gmonster2.mdl")
	precache_model("models/FAITH/v_knife_gmonster02.mdl")

	precache_sound("basebuilder/FAITH/nemesis/nemesisgodmode.wav")
	precache_sound("basebuilder/FAITH/hulk_growl_1.wav")

	register_plugin("[BB] Boss: G-Virus Monster", "1.0", "EmeraldGhost")

	register_forward(FM_CmdStart, "fw_CmdStart")
	RegisterHam(Ham_Spawn, "player", "fwHam_spawn", 1)
	RegisterHam(Ham_Item_PostFrame, "weapon_knife", "HamFW_Item_PostFrame")
	RegisterHam(Ham_TakeDamage, "player", "HamFW_TakeDamage")
	
	register_clcmd("so9sadbbgmon", "Become_Boss")

	//register_clcmd("eg_testboss", "Become_Boss")
}

public plugin_natives()
{
	register_native("bb_gmonster_me", "Native_Become_Nemesis", 1)
	register_native("bb_gmonster_phase2", "Native_Nemesis_Evolution", 1)
}

public Native_Become_Nemesis(id) Become_Boss(id)
public Native_Nemesis_Evolution(id) Nemesis_Phase2(id)

public Become_Boss(id)
{
	new players_ct[32], ict
	get_players(players_ct,ict,"ae","CT")

	g_bIsBoss[id] = true
	g_iBossPhase = 1
	g_iBossCountdown[id] = 222
	set_task(0.5, "boss_skill_reload", id + TASK_BOSS_SKILL_COUNTDOWN, _, _, "b")
	
	set_pev(id, pev_viewmodel2, "models/FAITH/v_knife_gmonster01.mdl")
	set_pev(id, pev_weaponmodel2, "")
	zp_override_user_model(id, "k_gmonster1")
	
	set_user_health(id, ict * 3125 + 2333)
	set_user_maxspeed(id, 275.0)
	set_user_gravity(id, 0.8)
	
	new wjsl = get_playersnum(0)
}

public Nemesis_Phase2(id)
{
	if(g_iBossPhase != 1 || !g_bIsBoss[id])
		return PLUGIN_HANDLED

	client_cmd(0, "spk %s", BOSS_ALARM)
	set_dhudmessage(200, 0, 0, -1.0, 0.35, 0, 0.0, 3.0, 2.0, 1.0, false)
	show_dhudmessage(0, "G-Virus Monster 进化至 Phase 2")
		
	new players_ct[32], ict
	get_players(players_ct,ict,"ae","CT")

	g_iBossPhase = 2
	
	set_pev(id, pev_viewmodel2, "models/FAITH/v_knife_gmonster02.mdl")
	set_pev(id, pev_weaponmodel2, "")
	zp_override_user_model(id, "k_gmonster2")
	
	set_user_health(id, ict * 1780 + 4950)
	set_user_maxspeed(id, 275.0)
	set_user_gravity(id, 0.8)

	g_iBossCountdown[id] = 888
	
	g_bBossNoDmg = true

	client_cmd(0, "spk basebuilder/FAITH/nemesis/nemesisgodmode.wav")
	//emit_sound(id, CHAN_STATIC, "basebuilder/FAITH/nemesis/nemesisgodmode.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)

	set_user_godmode(id, 1)
	set_user_rendering(id, kRenderFxGlowShell, 200, 0, 0, kRenderNormal, 3)

	set_task(3.0, "Skill_Godmode_Off", id + TASK_OFF_SKILL)
}

public fwHam_spawn(id)
{
	remove_task(id + TASK_BOSS_SKILL_COUNTDOWN)
	g_iBossCountdown[id] = 0
	
	if(g_bIsBoss[id])
	{
		g_bBossNoDmg = false
		g_bBossExHit = false
		g_bIsBoss[id] = false
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0)
		set_pev(id, pev_weaponmodel2, "")
	}
}

public boss_skill_reload(taskid)
{
	new id = taskid - TASK_BOSS_SKILL_COUNTDOWN
	if(is_user_alive(id) && is_user_connected(id))
	{
		if(g_iBossCountdown[id] >= 888)
        {
			g_iBossCountdown[id] = 888
			
			if(g_iBossPhase == 1)
				client_print(id, print_center, "【 Reload 完成丨'E' 致命一击 'R' 加速】");
			else if(g_iBossPhase == 2)
				client_print(id, print_center, "【 Reload 完成丨按 'R' 使用无敌】");
        }
		else
		{		
			if(g_iBossPhase == 1)
			{
				g_iBossCountdown[id] += 14;
				client_print(id, print_center, "【 Reload: %d / 888 | 'E' 致命一击 'R' 加速 】", g_iBossCountdown[id])
			}
			else if(g_iBossPhase == 2)
			{
				g_iBossCountdown[id] += 26;
				client_print(id, print_center, "【 Reload: %d / 888 】", g_iBossCountdown[id])
			}
		}
	}
}

public HamFW_Item_PostFrame(iEntity) 
{
	new id = get_pdata_cbase(iEntity, 41, 4)

	if (!g_bIsBoss[id] || g_iBossPhase != 1 || !g_bBossExHit)
		return HAM_IGNORED;

	new userbut = pev(id, pev_button)

	if(get_pdata_float(iEntity, 47) <= 0.0 && get_pdata_float(id, 83, 5) <= 0.0)
	{
		userbut &= ~IN_ATTACK
		userbut &= ~IN_ATTACK2
		set_pev(id, pev_button, userbut)

		ExecuteHamB(Ham_Weapon_SecondaryAttack, iEntity)

		set_task(0.7, "Skill_ExHit_Off", id + TASK_OFF_SKILL)
	}
	return HAM_IGNORED
}

public HamFW_TakeDamage(victim, inflictor, attacker, Float:damage, damagebits)
{
	if (!is_user_connected(victim) || !is_user_connected(attacker) || !zp_get_user_zombie(attacker))
		return HAM_IGNORED

	if (!g_bBossExHit)
		return HAM_IGNORED

	if (g_bBossExHit)
	{
		SetHamParamFloat(4, 9999.0);
		return HAM_OVERRIDE
	}
}

public Skill_ExHit_Off(taskid)
{
	new id = taskid - TASK_OFF_SKILL
	g_bBossExHit = false;
}

public Skill_Godmode(id)
{
	g_bBossNoDmg = true
	event_hud(0, 0, 255, 255, "G Monster 发动技能【无敌】^n所有伤害免疫 4 秒")

	client_cmd(0, "spk basebuilder/FAITH/nemesis/nemesisgodmode.wav")

	set_user_godmode(id, 1)
	set_user_rendering(id, kRenderFxGlowShell, 200, 0, 0, kRenderNormal, 3)

	set_task(4.0, "Skill_Godmode_Off", id + TASK_OFF_SKILL)
}

public Skill_Rage(id)
{
	set_user_maxspeed(id, 320.0)
	event_hud(0, 0, 255, 255, "G Monster 发动技能【加速】^n移动速度大幅增加 5 秒")

	client_cmd(0, "spk basebuilder/FAITH/nemesis/nemesisgodmode.wav")
	set_user_rendering(id, kRenderFxGlowShell, 0, 128, 0, kRenderNormal, 3)

	set_task(5.0, "Skill_Rage_Off", id + TASK_OFF_SKILL)
}

public Skill_Godmode_Off(taskid)
{
	new id = taskid - TASK_OFF_SKILL
	
	if(is_user_alive(id) && is_user_connected(id))
	{
		g_bBossNoDmg = false
		set_user_godmode(id)
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0)
	}
}

public Skill_Rage_Off(taskid)
{
	new id = taskid - TASK_OFF_SKILL
	
	if(is_user_alive(id) && is_user_connected(id))
	{
		set_user_maxspeed(id, 275.0)
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0)
	}
}

public fw_CmdStart(id, uc_handle, seed) 
{
	if (!is_user_alive(id))
		return FMRES_IGNORED;

	static button, oldbutton
	button = get_uc(uc_handle, UC_Buttons)
	oldbutton = pev(id, pev_oldbuttons)
	
	if((button & IN_RELOAD) && !(oldbutton & IN_RELOAD))
	{
		if(zp_get_user_zombie(id) && is_user_alive(id) && g_bIsBoss[id])
		{
			if(g_iBossPhase == 1 && g_iBossCountdown[id] >= 555)
			{
				Skill_Rage(id)
				g_iBossCountdown[id] -= 555
			}
			else if(g_iBossPhase == 2 && g_iBossCountdown[id] == 888)
			{
				if(!g_bBossNoDmg)
				{
					Skill_Godmode(id)
					g_iBossCountdown[id] = 0
				}
				else client_print(id, print_center, "正在无敌状态, 无法使用无敌!")
			}
		}
	}
	else if ((button & IN_USE) && !(oldbutton & IN_USE))
	{
		if(g_iBossCountdown[id] >= 333)
		{
			g_bBossExHit = true;
			client_cmd(0, "spk basebuilder/FAITH/hulk_growl_1.wav")
			event_hud(0, 0, 255, 255, "G Monster 发动技能【致命一击】^n发动一次秒杀重击")
			g_iBossCountdown[id] -= 333;
		}
	}

	return PLUGIN_HANDLED 
}

stock Create_ScreenShake(id, amount, duration, frequency)
{
    message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, {0,0,0}, id) 
    write_short(amount)			        // ammount 
    write_short(duration)			// lasts this long 
    write_short(frequency)			// frequency
    message_end();
}

stock event_hud(index, red, green, blue, msg[])
{
	set_dhudmessage(red, green, blue, -1.0, 0.2, 0, 0.0, 2.0, 0.1, 0.1)
	show_dhudmessage(index, msg)
}
