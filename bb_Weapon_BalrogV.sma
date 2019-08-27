#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <xs>
#include <cstrike>
#include <fakemeta_util>
#include <basebuilder>
#include <eg_boss>

#define ENG_NULLENT			-1
#define EV_INT_WEAPONKEY	EV_INT_impulse
#define balrog5_WEAPONKEY 	332
#define MAX_PLAYERS  		32
#define IsValidUser(%1) (1 <= %1 <= g_MaxPlayers)

const USE_STOPPED = 0
const OFFSET_ACTIVE_ITEM = 373
const OFFSET_WEAPONOWNER = 41
const OFFSET_LINUX = 5
const OFFSET_LINUX_WEAPONS = 4

#define WEAP_LINUX_XTRA_OFF		4
#define m_fKnown					44
#define m_flNextPrimaryAttack 		46
#define m_flTimeWeaponIdle			48
#define m_iClip					51
#define m_fInReload				54
#define PLAYER_LINUX_XTRA_OFF	5
#define m_flNextAttack				83

#define BALROG5_SHOOT1		1
#define BALROG5_SHOOT2		2
#define BALROG5_SHOOT3		3
#define BALROG5_RELOAD		4
#define BALROG5_DRAW			5
#define BALROG5_RELOAD_TIME		2.5

#define write_coord_f(%1)	engfunc(EngFunc_WriteCoord,%1)

new const Fire_Sounds[][] = { "weapons/balrog5-1.wav" }

new balrog5_V_MODEL[64] = "models/FAITH/v_balrog5.mdl"
new balrog5_P_MODEL[64] = "models/FAITH/p_balrog5.mdl"
new balrog5_W_MODEL[64] = "models/FAITH/w_balrog5.mdl"

new const g_shellent [] = "balrog5_shell"
new const Sound_Zoom[] = { "weapons/zoom.wav" }
new const GUNSHOT_DECALS[] = { 41, 42, 43, 44, 45 }

new cvar_dmg_balrog5, cvar_recoil_balrog5, cvar_clip_balrog5, cvar_spd_balrog5, cvar_balrog5_ammo, cvar_shellshealth_balrog5, cvar_ammo_exp, cvar_dmg_spr
new g_MaxPlayers, g_orig_event_balrog5, g_IsInPrimaryAttack
new Float:cl_pushangle[MAX_PLAYERS + 1][3], m_iBlood[2]
new g_has_balrog5[33], g_clip_ammo[33], g_balrog5_TmpClip[33], oldweap[33], g_hasZoom[33], Float:g_flNextUseTime[33], g_Reload[33] 
new gmsgWeaponList, shells_model
new Float:g_lastspr[33], sprite_balrog5

const PRIMARY_WEAPONS_BIT_SUM = 
(1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<
CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
new const WEAPONENTNAMES[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
			"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550",
			"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
			"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
			"weapon_ak47", "weapon_knife", "weapon_p90" }

public plugin_init()
{
	register_plugin("[ZP]Balrog-V", "1.1", "Crock / PbI)I(Uu' / Barney / LARS-DAY[BR]EAKER")
	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg")
	register_event("CurWeapon","CurrentWeapon","be","1=1")
	RegisterHam(Ham_Item_AddToPlayer, "weapon_ak47", "fw_balrog5_AddToPlayer")
	RegisterHam(Ham_Use, "func_tank", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankmortar", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankrocket", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tanklaser", "fw_UseStationary_Post", 1)
	for (new i = 1; i < sizeof WEAPONENTNAMES; i++)
	if (WEAPONENTNAMES[i][0]) RegisterHam(Ham_Item_Deploy, WEAPONENTNAMES[i], "fw_Item_Deploy_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "fw_balrog5_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "fw_balrog5_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Item_PostFrame, "weapon_ak47", "balrog5_ItemPostFrame")
	RegisterHam(Ham_Weapon_Reload, "weapon_ak47", "balrog5_Reload")
	RegisterHam(Ham_Weapon_Reload, "weapon_ak47", "balrog5_Reload_Post", 1)
	RegisterHam(Ham_Item_Holster, "weapon_ak47", "balrog5_Holster_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_PlaybackEvent, "fwPlaybackEvent")
	register_forward(FM_CmdStart, "fw_CmdStart")
        register_think(g_shellent,"think_shell")
	
	RegisterHam(Ham_Spawn, "player", "fw_Spawn_Post", 1)
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_breakable", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_wall", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_door", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_door_rotating", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_plat", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_rotating", "fw_TraceAttack", 1)

	cvar_dmg_balrog5 = register_cvar("zp_balrog5_dmg", "1.03")
	cvar_dmg_spr = register_cvar("zp_balrog5_dmg_spr", "95.0")
	cvar_recoil_balrog5 = register_cvar("zp_balrog5_recoil", "0.6")
	cvar_clip_balrog5 = register_cvar("zp_balrog5_clip", "35")
	cvar_spd_balrog5 = register_cvar("zp_balrog5_spd", "1.0")
	cvar_balrog5_ammo = register_cvar("zp_balrog5_ammo", "200")
	cvar_ammo_exp = register_cvar("zp_balrog5_ammo_exp", "4.0")
	cvar_shellshealth_balrog5 = register_cvar("zp_balrog5_shellslife", "5")

	register_clcmd(DEF_BGV_CODE, "give_balrog5")
	
	g_MaxPlayers = get_maxplayers()
	gmsgWeaponList = get_user_msgid("WeaponList")
}

public plugin_precache()
{
	precache_model(balrog5_V_MODEL)
	precache_model(balrog5_P_MODEL)
	precache_model(balrog5_W_MODEL)
	for(new i = 0; i < sizeof Fire_Sounds; i++)
	precache_sound(Fire_Sounds[i])	
	precache_sound(Sound_Zoom)
	precache_sound("weapons/balrog5-2.wav")
	precache_sound("weapons/balrog5_clipin1.wav")
	precache_sound("weapons/balrog5_clipin2.wav")
	precache_sound("weapons/balrog5_clipout1.wav")
	shells_model = precache_model("models/rshell.mdl")
	sprite_balrog5 = precache_model("sprites/balrog5stack.spr")
	m_iBlood[0] = precache_model("sprites/blood.spr")
	m_iBlood[1] = precache_model("sprites/bloodspray.spr")
	precache_generic("sprites/weapon_balrog5.txt")
	precache_generic("sprites/640hud2.spr")
	precache_generic("sprites/640hud10.spr")
	precache_generic("sprites/640hud78.spr")
	
    register_clcmd("weapon_balrog5", "weapon_hook")	

	register_forward(FM_PrecacheEvent, "fwPrecacheEvent_Post", 1)
}

public weapon_hook(id)
{
    	engclient_cmd(id, "weapon_ak47")
    	return PLUGIN_HANDLED
}

public fw_Spawn_Post(id)
{
	g_has_balrog5[id] = false
}

public fw_TraceAttack(iEnt, iAttacker, Float:flDamage, Float:fDir[3], ptr, iDamageType)
{
	if(!is_user_alive(iAttacker))
		return

	new g_currentweapon = get_user_weapon(iAttacker)

	if(g_currentweapon != CSW_AK47) return
	
	if(!g_has_balrog5[iAttacker]) return

	static Float:flEnd[3]
	get_tr2(ptr, TR_vecEndPos, flEnd)
	
	if(iEnt)
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_DECAL)
		write_coord_f(flEnd[0])
		write_coord_f(flEnd[1])
		write_coord_f(flEnd[2])
		write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
		write_short(iEnt)
		message_end()
	}
	else
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		write_coord_f(flEnd[0])
		write_coord_f(flEnd[1])
		write_coord_f(flEnd[2])
		write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
		message_end()
	}
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_GUNSHOTDECAL)
	write_coord_f(flEnd[0])
	write_coord_f(flEnd[1])
	write_coord_f(flEnd[2])
	write_short(iAttacker)
	write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
	message_end()
}
/*
public plugin_natives()
{
	register_native("give_weapon_balrog5", "native_give_weapon_add", 1)
}
*/

public fwPrecacheEvent_Post(type, const name[])
{
	if (equal("events/ak47.sc", name))
	{
		g_orig_event_balrog5 = get_orig_retval()
		return FMRES_HANDLED
	}
	return FMRES_IGNORED
}

public client_connect(id)
{
	g_has_balrog5[id] = false
}

public client_disconnect(id)
{
	g_has_balrog5[id] = false
}

public fw_SetModel(entity, model[])
{
	if(!is_valid_ent(entity))
		return FMRES_IGNORED
	
	static szClassName[33]
	entity_get_string(entity, EV_SZ_classname, szClassName, charsmax(szClassName))
		
	if(!equal(szClassName, "weaponbox"))
		return FMRES_IGNORED
	
	static iOwner
	
	iOwner = entity_get_edict(entity, EV_ENT_owner)
	
	if(equal(model, "models/w_ak47.mdl"))
	{
		static iStoredAugID
		
		iStoredAugID = find_ent_by_owner(ENG_NULLENT, "weapon_ak47", entity)
	
		if(!is_valid_ent(iStoredAugID))
			return FMRES_IGNORED
	
		if(g_has_balrog5[iOwner])
		{
			entity_set_int(iStoredAugID, EV_INT_WEAPONKEY, balrog5_WEAPONKEY)
			
			g_has_balrog5[iOwner] = false
			
			entity_set_model(entity, balrog5_W_MODEL)
			
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}

public give_balrog5(id)
{
	drop_weapons(id, 1)
	new iWep2 = give_item(id,"weapon_ak47")
	if( iWep2 > 0 )
	{
		cs_set_weapon_ammo(iWep2, get_pcvar_num(cvar_clip_balrog5))
		cs_set_user_bpammo (id, CSW_AK47, get_pcvar_num(cvar_balrog5_ammo))	
		UTIL_PlayWeaponAnimation(id, BALROG5_DRAW)
		set_pdata_float(id, m_flNextAttack, 1.0, PLAYER_LINUX_XTRA_OFF)
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("AmmoPickup"), _, id)
		write_byte(3)
		write_byte(240)
		message_end()

		message_begin(MSG_ONE, gmsgWeaponList, {0,0,0}, id)
		write_string("weapon_balrog5")
		write_byte(2)
		write_byte(90)
		write_byte(-1)
		write_byte(-1)
		write_byte(0)
		write_byte(1)
		write_byte(CSW_AK47)
		message_end()
	}
	g_has_balrog5[id] = true
}

public fw_balrog5_AddToPlayer(balrog5, id)
{
	if(!is_valid_ent(balrog5) || !is_user_connected(id))
		return HAM_IGNORED
	
	if(entity_get_int(balrog5, EV_INT_WEAPONKEY) == balrog5_WEAPONKEY)
	{
		g_has_balrog5[id] = true
		
		entity_set_int(balrog5, EV_INT_WEAPONKEY, 0)

		message_begin(MSG_ONE, gmsgWeaponList, {0,0,0}, id)
		write_string("weapon_balrog5")
		write_byte(2)
		write_byte(90)
		write_byte(-1)
		write_byte(-1)
		write_byte(0)
		write_byte(1)
		write_byte(CSW_AK47)
		message_end()
		
		return HAM_HANDLED
	}
	else
	{
		message_begin(MSG_ONE, gmsgWeaponList, {0,0,0}, id)
		write_string("weapon_ak47")
		write_byte(2)
		write_byte(90)
		write_byte(-1)
		write_byte(-1)
		write_byte(0)
		write_byte(1)
		write_byte(CSW_AK47)
		message_end()
	}
	return HAM_IGNORED
}

public fw_UseStationary_Post(entity, caller, activator, use_type)
{
	if (use_type == USE_STOPPED && is_user_connected(caller))
		replace_weapon_models(caller, get_user_weapon(caller))
}

public fw_Item_Deploy_Post(weapon_ent)
{
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	static weaponid
	weaponid = cs_get_weapon_id(weapon_ent)
	
	replace_weapon_models(owner, weaponid)
}

public CurrentWeapon(id)
{
     replace_weapon_models(id, read_data(2))

     if(read_data(2) != CSW_AK47 || !g_has_balrog5[id])
          return
     
     static Float:iSpeed
     if(g_has_balrog5[id])
          iSpeed = get_pcvar_float(cvar_spd_balrog5)
     
     static weapon[32],Ent
     get_weaponname(read_data(2),weapon,31)
     Ent = find_ent_by_owner(-1,weapon,id)
     if(Ent)
     {
          static Float:Delay
          Delay = get_pdata_float( Ent, 46, 4) * iSpeed
          if (Delay > 0.0)
          {
               set_pdata_float(Ent, 46, Delay, 4)
          }
     }
}

replace_weapon_models(id, weaponid)
{
	switch (weaponid)
	{
		case CSW_AK47:
		{
			if (zp_get_user_zombie(id))
				return
			
			if(g_has_balrog5[id])
			{
				set_pev(id, pev_viewmodel2, balrog5_V_MODEL)
				set_pev(id, pev_weaponmodel2, balrog5_P_MODEL)
				if(oldweap[id] != CSW_AK47) 
				{
					UTIL_PlayWeaponAnimation(id, BALROG5_DRAW)
					set_pdata_float(id, m_flNextAttack, 1.0, PLAYER_LINUX_XTRA_OFF)

					message_begin(MSG_ONE, gmsgWeaponList, {0,0,0}, id)
					write_string("weapon_balrog5")
					write_byte(2)
					write_byte(90)
					write_byte(-1)
					write_byte(-1)
					write_byte(0)
					write_byte(1)
					write_byte(CSW_AK47)
					message_end()
				}
			}
		}
	}
	oldweap[id] = weaponid
}

public fw_UpdateClientData_Post(Player, SendWeapons, CD_Handle)
{
	if(!is_user_alive(Player) || (get_user_weapon(Player) != CSW_AK47 || !g_has_balrog5[Player]))
		return FMRES_IGNORED
	
	set_cd(CD_Handle, CD_flNextAttack, halflife_time () + 0.001)
	return FMRES_HANDLED
}

public fw_balrog5_PrimaryAttack(Weapon)
{
	new Player = get_pdata_cbase(Weapon, 41, 4)
	
	if (!g_has_balrog5[Player])
		return
	
	g_IsInPrimaryAttack = 1
	pev(Player,pev_punchangle,cl_pushangle[Player])
	
	g_clip_ammo[Player] = cs_get_weapon_ammo(Weapon)
}

public fwPlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if ((eventid != g_orig_event_balrog5) || !g_IsInPrimaryAttack)
		return FMRES_IGNORED
	if (!(1 <= invoker <= g_MaxPlayers))
    return FMRES_IGNORED

	playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
	return FMRES_SUPERCEDE
}

public fw_CmdStart(id, uc_handle, seed)
{
	if(g_Reload[id])
		return PLUGIN_HANDLED

	if(!is_user_alive(id)) 
		return PLUGIN_HANDLED
	
	if((get_uc(uc_handle, UC_Buttons) & IN_ATTACK2) && !(pev(id, pev_oldbuttons) & IN_ATTACK2))
	{
		new szClip, szAmmo
		new szWeapID = get_user_weapon(id, szClip, szAmmo)

		if(szWeapID == CSW_AK47 && g_has_balrog5[id] && !g_hasZoom[id] == true)
		{
			g_hasZoom[id] = true
			cs_set_user_zoom(id, CS_SET_AUGSG552_ZOOM, 0)
			emit_sound(id, CHAN_ITEM, Sound_Zoom, 0.20, 2.40, 0, 100)
		}
		else if(szWeapID == CSW_AK47 && g_has_balrog5[id] && g_hasZoom[id])
		{
			g_hasZoom[id] = false
			cs_set_user_zoom(id, CS_RESET_ZOOM, 0)	
		}
	}
	return PLUGIN_HANDLED
}

public fw_balrog5_PrimaryAttack_Post(Weapon)
{
	g_IsInPrimaryAttack = 0
	new Player = get_pdata_cbase(Weapon, 41, 4)
	
	new szClip, szAmmo
	get_user_weapon(Player, szClip, szAmmo)
	
	if(!is_user_alive(Player))
		return

	if(g_has_balrog5[Player])
	{
		if (!g_clip_ammo[Player])
			return

		new Float:push[3]
		pev(Player,pev_punchangle,push)
		xs_vec_sub(push,cl_pushangle[Player],push)
		
		xs_vec_mul_scalar(push,get_pcvar_float(cvar_recoil_balrog5),push)
		xs_vec_add(push,cl_pushangle[Player],push)
		set_pev(Player,pev_punchangle,push)
		
		emit_sound(Player, CHAN_WEAPON, Fire_Sounds[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		UTIL_PlayWeaponAnimation(Player, random_num(BALROG5_SHOOT1, BALROG5_SHOOT2))
		make_shell(Player)
			
		if(get_gametime()-get_pcvar_float(cvar_ammo_exp) > g_lastspr[Player])
		{
			spritebalrog5(Player)
			g_lastspr[Player] = get_gametime()
		}
		if(g_hasZoom[Player]) set_pdata_float(Player, m_flNextAttack, 0.2, 5)
	}
}

public spritebalrog5(id)
{
	if(is_user_alive(id))
	{
		new Float:originF[3]
		fm_get_aim_origin(id, originF)
		
		new aimOrigin[3], target, body
		get_user_origin(id, aimOrigin, 3)
		get_user_aiming(id, target, body)
		if(target > 0 && target <= get_maxplayers() && zp_get_user_zombie(target))
		{
			new Float:fStart[3], Float:fEnd[3], Float:fRes[3], Float:fVel[3]
			pev(id, pev_origin, fStart)
			velocity_by_aim(id, 64, fVel)
			fStart[0] = float(aimOrigin[0])
			fStart[1] = float(aimOrigin[1])
			fStart[2] = float(aimOrigin[2])
			fEnd[0] = fStart[0]+fVel[0]
			fEnd[1] = fStart[1]+fVel[1]
			fEnd[2] = fStart[2]+fVel[2]
			new res
			engfunc(EngFunc_TraceLine, fStart, fEnd, 0, target, res)
			get_tr2(res, TR_vecEndPos, fRes)
			engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, fStart, 0)
			write_byte(TE_SPRITE) // Temporary entity ID
			engfunc(EngFunc_WriteCoord, originF[0]) // engfunc because float
			engfunc(EngFunc_WriteCoord, originF[1])
			engfunc(EngFunc_WriteCoord, originF[2])
			write_short(sprite_balrog5) // Sprite index
			write_byte(5) // Scale
			write_byte(200) // Framerate
			message_end()
		
			new a = FM_NULLENT
			while((a = find_ent_in_sphere(a, originF, 60.0)) != 0)
			{
				if (id == a)
					continue 
				
				if(pev(a, pev_takedamage) != DAMAGE_NO)
				{
					ExecuteHamB(Ham_TakeDamage, a, id, id, get_pcvar_float(cvar_dmg_spr), DMG_BULLET)
					UTIL_PlayWeaponAnimation(id, 3)
				}
				return PLUGIN_HANDLED
			}
			return PLUGIN_HANDLED
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	if (victim != attacker && is_user_connected(attacker))
	{
		if(get_user_weapon(attacker) == CSW_AK47)
		{
			if(g_has_balrog5[attacker])
				SetHamParamFloat(4, damage * get_pcvar_float(cvar_dmg_balrog5))
		}
	}
}

public message_DeathMsg(msg_id, msg_dest, id)
{
	static szTruncatedWeapon[33], iAttacker, iVictim
	
	get_msg_arg_string(4, szTruncatedWeapon, charsmax(szTruncatedWeapon))
	
	iAttacker = get_msg_arg_int(1)
	iVictim = get_msg_arg_int(2)
	
	if(!is_user_connected(iAttacker) || iAttacker == iVictim)
		return PLUGIN_CONTINUE
	
	if(equal(szTruncatedWeapon, "ak47") && get_user_weapon(iAttacker) == CSW_AK47)
	{
		if(g_has_balrog5[iAttacker])
			set_msg_arg_string(4, "balrog5")
	}
	return PLUGIN_CONTINUE
}

stock fm_cs_get_current_weapon_ent(id)
{
	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX)
}

stock fm_cs_get_weapon_ent_owner(ent)
{
	return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS)
}

stock UTIL_PlayWeaponAnimation(const Player, const Sequence)
{
	set_pev(Player, pev_weaponanim, Sequence)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player)
	write_byte(Sequence)
	write_byte(pev(Player, pev_body))
	message_end()
}

public balrog5_ItemPostFrame(weapon_entity) 
{
     new id = pev(weapon_entity, pev_owner)
     if (!is_user_connected(id))
          return HAM_IGNORED

     if (!g_has_balrog5[id])
          return HAM_IGNORED

     static iClipExtra
     
     iClipExtra = get_pcvar_num(cvar_clip_balrog5)
     new Float:flNextAttack = get_pdata_float(id, m_flNextAttack, PLAYER_LINUX_XTRA_OFF)

     new iBpAmmo = cs_get_user_bpammo(id, CSW_AK47)
     new iClip = get_pdata_int(weapon_entity, m_iClip, WEAP_LINUX_XTRA_OFF)

     new fInReload = get_pdata_int(weapon_entity, m_fInReload, WEAP_LINUX_XTRA_OFF) 
     if(!(get_user_button(id) & IN_ATTACK))
     	g_lastspr[id]=get_gametime()

     if( fInReload && flNextAttack <= 0.0 )
     {
	     new j = min(iClipExtra - iClip, iBpAmmo)
	
	     set_pdata_int(weapon_entity, m_iClip, iClip + j, WEAP_LINUX_XTRA_OFF)
	     cs_set_user_bpammo(id, CSW_AK47, iBpAmmo-j)
		
	     set_pdata_int(weapon_entity, m_fInReload, 0, WEAP_LINUX_XTRA_OFF)
	     fInReload = 0
     }
     return HAM_IGNORED
}

public balrog5_Reload(weapon_entity) 
{
     new id = pev(weapon_entity, pev_owner)
     if (!is_user_connected(id))
          return HAM_IGNORED

     if (!g_has_balrog5[id])
          return HAM_IGNORED

     static iClipExtra

     if(g_has_balrog5[id])
          iClipExtra = get_pcvar_num(cvar_clip_balrog5)

     g_balrog5_TmpClip[id] = -1

     new iBpAmmo = cs_get_user_bpammo(id, CSW_AK47)
     new iClip = get_pdata_int(weapon_entity, m_iClip, WEAP_LINUX_XTRA_OFF)

     if (iBpAmmo <= 0)
          return HAM_SUPERCEDE

     if (iClip >= iClipExtra)
          return HAM_SUPERCEDE

     g_balrog5_TmpClip[id] = iClip

     return HAM_IGNORED
}

public balrog5_Reload_Post(weapon_entity) 
{
	new id = pev(weapon_entity, pev_owner)
	if (!is_user_connected(id))
		return HAM_IGNORED

	if (!g_has_balrog5[id])
		return HAM_IGNORED

	if (g_balrog5_TmpClip[id] == -1)
		return HAM_IGNORED

	set_pdata_int(weapon_entity, m_iClip, g_balrog5_TmpClip[id], WEAP_LINUX_XTRA_OFF)

	cs_set_user_zoom(id, CS_RESET_ZOOM, 1)

	set_pdata_float(weapon_entity, m_flTimeWeaponIdle, BALROG5_RELOAD_TIME, WEAP_LINUX_XTRA_OFF)

	set_pdata_float(id, m_flNextAttack, BALROG5_RELOAD_TIME, PLAYER_LINUX_XTRA_OFF)

	set_pdata_int(weapon_entity, m_fInReload, 1, WEAP_LINUX_XTRA_OFF)

	UTIL_PlayWeaponAnimation(id, BALROG5_RELOAD)

	return HAM_IGNORED
}

public balrog5_Holster_Post(weapon_entity)
{
	static Player
	Player = get_pdata_cbase(weapon_entity, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS)
	
	g_flNextUseTime[Player] = 0.0

	if(g_has_balrog5[Player])
	{
		cs_set_user_zoom(Player, CS_RESET_ZOOM, 1)
	}
}

public make_shell(id)
{
	if(!is_user_alive(id) || zp_get_user_zombie(id))
		return;
	
	if(get_user_weapon(id) != CSW_AK47) 
		return;
	
	if(!g_has_balrog5[id])
		return;
	
	static Float:player_origin[3], Float:origin[3], Float:origin2[3], Float:gunorigin[3], Float:oldangles[3], Float:v_forward[3], Float:v_forward2[3], Float:v_up[3], Float:v_up2[3], Float:v_right[3], Float:v_right2[3], Float:viewoffsets[3];
	pev(id,pev_v_angle, oldangles)
	pev(id,pev_origin,player_origin)
	pev(id, pev_view_ofs, viewoffsets);
	
	engfunc(EngFunc_MakeVectors, oldangles);
	
	global_get(glb_v_forward, v_forward);
	global_get(glb_v_up, v_up);
	global_get(glb_v_right, v_right);
	
	global_get(glb_v_forward, v_forward2);
	global_get(glb_v_up, v_up2);
	global_get(glb_v_right, v_right2);
	
	xs_vec_add(player_origin, viewoffsets, gunorigin);
	
	xs_vec_mul_scalar(v_forward, 15.3, v_forward);
	xs_vec_mul_scalar(v_right, 5.9, v_right);
	xs_vec_mul_scalar(v_up, -3.7, v_up);
	
	xs_vec_mul_scalar(v_forward2, 15.0, v_forward2);
	xs_vec_mul_scalar(v_right2, 7.0, v_right2);
	xs_vec_mul_scalar(v_up2, -4.0, v_up2);
	
	xs_vec_add(gunorigin, v_forward, origin);
	xs_vec_add(gunorigin, v_forward2, origin2);
	xs_vec_add(origin, v_right, origin);
	xs_vec_add(origin2, v_right2, origin2);
	xs_vec_add(origin, v_up, origin);
	xs_vec_add(origin2, v_up2, origin2);
	
	new Float:velocity[3]
	get_speed_vector(origin2, origin, random_float(110.0, 130.0), velocity)

	new ent = create_entity("info_target")
	set_pev(ent, pev_classname, g_shellent)
	
	new angle = random_num(0, 360)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, id)
	write_byte(TE_MODEL)
	write_coord_f(origin[0])
	write_coord_f(origin[1])
	write_coord_f(origin[2])
	write_coord_f(velocity[0])
	write_coord_f(velocity[1])
	write_coord_f(velocity[2])
	write_angle(angle)
	write_short(shells_model)
	write_byte(1)
	write_byte(get_pcvar_num(cvar_shellshealth_balrog5) * 10)
	message_end()
	
	new Float:origin3[3]
	origin3 = origin
	
	xs_vec_mul_scalar(v_forward, 3.9, v_forward);
	xs_vec_add(origin, v_forward, origin);
	
	for(new i; i <= 32; i++)
	{
		if(!is_user_connected(i) || i == id) continue;
		
		if(!is_user_alive(i) && pev(i, pev_iuser2) == id && pev(i, pev_iuser1) == 4)
		{
			message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, i)
			write_byte(TE_MODEL)
			write_coord_f(origin3[0])
			write_coord_f(origin3[1])
			write_coord_f(origin3[2])
			write_coord_f(velocity[0])
			write_coord_f(velocity[1])
			write_coord_f(velocity[2])
			write_angle(angle)
			write_short(shells_model)
			write_byte(1)
			write_byte(get_pcvar_num(cvar_shellshealth_balrog5) * 10)
			message_end()	
		}
		else
		{
			message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, i)
			write_byte(TE_MODEL)
			write_coord_f(origin[0])
			write_coord_f(origin[1])
			write_coord_f(origin[2])
			write_coord_f(velocity[0])
			write_coord_f(velocity[1])
			write_coord_f(velocity[2])
			write_angle(angle)
			write_short(shells_model)
			write_byte(1)
			write_byte(get_pcvar_num(cvar_shellshealth_balrog5) * 10)
			message_end()	
		}
	}
}

public think_shell(ent) 
{
	if(!pev_valid(ent))
		return
		
	if(!(pev(ent,pev_flags) & FL_ONGROUND))
	{
		new Float:oldangles[3],Float:angles[3]
		pev(ent,pev_angles,oldangles)
		angles[0] = oldangles[0] + random_float(10.0,20.0)
		angles[1] = oldangles[1] + random_float(10.0,20.0)
		angles[2] = oldangles[2] + random_float(10.0,20.0)
		set_pev(ent,pev_angles,angles)
	}
	entity_set_float(ent, EV_FL_health, entity_get_float(ent,EV_FL_health) - 10.0) 
	entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.01) 
	if(entity_get_float(ent,EV_FL_health) <= 0) remove_entity(ent)
}

stock get_speed_vector(const Float:origin1[3], const Float:origin2[3], Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	new Float:num = floatsqroot(speed * speed / (new_velocity[0] * new_velocity[0] + new_velocity[1] * new_velocity[1] + new_velocity[2] * new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
	
	return 1;
}

stock drop_weapons(id, dropwhat)
{
     static weapons[32], num, i, weaponid
     num = 0
     get_user_weapons(id, weapons, num)
     
     for (i = 0; i < num; i++)
     {
          weaponid = weapons[i]
          
          if (dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM))
          {
               static wname[32]
               get_weaponname(weaponid, wname, sizeof wname - 1)
               engclient_cmd(id, "drop", wname)
          }
     }
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
