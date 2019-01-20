
#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <cstrike>
#include <fun>
#include <colorchat>
#include <zombieplague>
#include <sqlx>

new const sound_buyammo[] = "items/9mmclip1.wav"
new const grenades[] = { CSW_HEGRENADE, CSW_FLASHBANG }
new const MAXCLIP[] = { 1, 13, 1, 10, 1, 7, 1, 30, 30, 1, 30, 20, 25, 30, 35, 25, 12, 20,
			10, 30, 100, 8, 30, 30, 20, 1, 7, 30, 30, 1, 50 }
new const AMMOID[] = { -1, 9, -1, 2, 12, 5, 14, 6, 4, 13, 10, 7, 6, 4, 4, 4, 6, 10,
			1, 10, 3, 5, 4, 10, 2, 11, 8, 4, 2, -1, 7 }

new g_msgAmmoPickup

new g_donaterlv[33]
new bool:g_inform_expired[33]

new db_num = 0
new db_donater_define[1000][64]
new db_donater_lv[1000]
new db_donater_flag[1000]
new db_donater_timeleft[1000][11]

public plugin_init()
{
	register_plugin("ZP: Donater", "1.2", "Para")

	register_clcmd("say /donater", "clcmd_donater")
	register_clcmd("say_team /donater", "clcmd_donater")
	register_clcmd("say !donater", "clcmd_donater")
	register_clcmd("say_team !donater", "clcmd_donater")

	g_msgAmmoPickup = get_user_msgid("AmmoPickup")

	set_task(0.1, "ReadUsers")
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheSound, sound_buyammo)
}

public plugin_natives()
{
	register_native("zp_donater_get_level", "native_get_lv", 1)
}

public clcmd_donater(id)
{
	new name[33]
	get_user_name(id, name, 32)

	new ip[33]
	get_user_ip(id, ip, 32, 1)

	new authid[64]
	get_user_authid(id, authid, 63)

	new display_html[2000], auth_type[11], expire_time[20]
	format(display_html, 1999, "<html><head><meta http-equiv=^"Content-Type^" content=^"text/html; charset=utf-8^"><title>捐助人系統</title></head><body><br><b>您不是捐助人</b><br><br><a href=^"http://cszmparadise.com/donater.php^">什麼是捐助人?</a></body></html>")

	for(new i = 0; i<db_num; i++)
	{
		if( (equali(db_donater_define[i], name) && db_donater_flag[i] == 0) || (equali(db_donater_define[i], ip) && db_donater_flag[i] == 1) || (equali(db_donater_define[i], authid) && db_donater_flag[i] == 2) )
		{
			if(!get_total_days(db_donater_timeleft[i]))
				format(expire_time, 19, "永久")
			else
				format(expire_time, 19, "%s 23:59:59", db_donater_timeleft[i])

			switch(db_donater_flag[i])
			{
				case 0: format(auth_type, 10, "名稱")
				case 1: format(auth_type, 10, "IP Address")
				case 2: format(auth_type, 10, "STEAM ID / Auth ID")
				default: format(auth_type, 10, "Undefined")
			}

			format(display_html, 1999, "<html><head><meta http-equiv=^"Content-Type^" content=^"text/html; charset=utf-8^"><title>捐助人系統</title></head><body><br><b>目前捐助人等級: %d<br><br>認證方式: %s<br><br>到期時間: %s</b></body></html>", db_donater_lv[i], auth_type, expire_time)

			i = db_num
		}
	}

	show_motd(id, display_html, "捐助人系統")

	return PLUGIN_CONTINUE
}

public ReadUsers()
{
	// Re-read
	db_num = 0

	new errorno, error[128]
	new Handle:info = SQL_MakeStdTuple()
	new Handle:conn = SQL_Connect(info, errorno, error, 127)

	if(conn == Empty_Handle)
	{
		log_amx("[Donater] Connection failed: #%d %s", errorno, error)
	}
	else
	{
		new Handle:query = SQL_PrepareQuery(conn, "SELECT define,level,flag,timeleft FROM donaterinfo WHERE level > 0")

		if(!SQL_Execute(query))
		{
			log_amx("[Donater] Execute failed.")
		}
		else if(!SQL_NumResults(query))
		{
			server_print("[Donater] No donaters.")
		}
		else
		{
			new q_define = SQL_FieldNameToNum(query, "define")
			new q_level = SQL_FieldNameToNum(query, "level")
			new q_flag = SQL_FieldNameToNum(query, "flag")
			new q_timeleft = SQL_FieldNameToNum(query, "timeleft")

			new t_level[11]
			new t_flag[11]

			while(SQL_MoreResults(query))
			{
				SQL_ReadResult(query, q_define, db_donater_define[db_num], 63)
				SQL_ReadResult(query, q_level, t_level, 10)
				SQL_ReadResult(query, q_flag, t_flag[10])
				SQL_ReadResult(query, q_timeleft, db_donater_timeleft[db_num], 10)

				db_donater_lv[db_num] = str_to_num(t_level)
				db_donater_flag[db_num] = str_to_num(t_flag)

				db_num ++

				SQL_NextRow(query)
			}
		}

		SQL_FreeHandle(query)
	}

	SQL_FreeHandle(conn)
	SQL_FreeHandle(info)
}

public native_get_lv(id) return g_donaterlv[id]

public event_round_start()
{
	set_task(0.5, "giveFreeGrenade")
}

public giveFreeGrenade()
{
	for(new id = 0; id<33; id++)
	{
		if(is_user_connected(id) && is_user_alive(id) && !zp_get_user_zombie(id) && g_donaterlv[id])
		{
			new Level = g_donaterlv[id]
			if(Level > 4) Level = 4
			for(new i = 0; i<Level; i++)
			{
				fm_give_item(id, grenades[random_num(0, sizeof grenades - 1)])
			}
		}
	}
}

stock fm_give_item(id, weapon)
{
	if (user_has_weapon(id, weapon))
	{
		cs_set_user_bpammo(id, weapon, cs_get_user_bpammo(id, weapon) + MAXCLIP[weapon])
		
		message_begin(MSG_ONE_UNRELIABLE, g_msgAmmoPickup, _, id)
		write_byte(AMMOID[weapon])
		write_byte(MAXCLIP[weapon])
		message_end()

		emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)

		return;
	}

	new weaponname[64]
	get_weaponname(weapon, weaponname, 63)
	give_item(id, weaponname)
}

public client_disconnect(id)
{
	g_donaterlv[id] = 0
	g_inform_expired[id] = false
}

public client_authorized(id)
{
	g_donaterlv[id] = 0
	g_inform_expired[id] = false
	getVipInfo(id)
}

public client_putinserver(id)
{
	if(g_inform_expired[id])
	{
		set_task(1.5, "expired_msg", id)
	}
}

public expired_msg(id)
{
	if(!is_user_connected(id))
		return;

	ColorChat(id, RED, "[贊助] 您的捐助人已經到期!")

	set_hudmessage(255, 0, 0, -1.0, 0.75, 1, 0.0, 30.0, 0.1, 0.2, -1)
	show_hudmessage(0, "!!!注意!!!^n您的捐助人已經到期!")
}

public getVipInfo(id)
{
	new name[33]
	get_user_name(id, name, 32)

	new ip[33]
	get_user_ip(id, ip, 32, 1)

	new authid[64]
	get_user_authid(id, authid, 63)

	// 0= name
	// 1= ip
	// 2= authid

	// Loop throw all database rows
	for(new i = 0; i<db_num; i++)
	{
		if( (equali(db_donater_define[i], name) && db_donater_flag[i] == 0) || (equali(db_donater_define[i], ip) && db_donater_flag[i] == 1) || (equali(db_donater_define[i], authid) && db_donater_flag[i] == 2) )
		{
			// Check expire
			if(is_past(get_total_days(db_donater_timeleft[i])))
			{
				// expired, delete from db and sql
				DeleteDonater(i)
				g_inform_expired[id] = true
			}
			else
			{
				// not expired, add the level to user
				g_donaterlv[id] = db_donater_lv[i]
			}

			i = db_num
		}
	}

	if(g_donaterlv[id] > 0)
	{
		server_print("[Donater] %s become Donater (Lv%d)", name, g_donaterlv[id])

		if(!(get_user_flags(id) & ADMIN_RESERVATION))
			set_user_flags(id, read_flags("bu"))
	}
}

DeleteDonater(i)
{
	new errorno, error[128]
	new Handle:info = SQL_MakeStdTuple()
	new Handle:conn = SQL_Connect(info, errorno, error, 127)

	if(conn == Empty_Handle)
	{
		log_amx("[Donater] Connection failed: #%d %s", errorno, error)
	}
	else
	{
		SQL_QueryAndIgnore(conn, "UPDATE donaterinfo SET level = '0' WHERE define = '%s' AND flag = '%d'", db_donater_define[i], db_donater_flag[i])
	}

	SQL_FreeHandle(conn)
	SQL_FreeHandle(info)

	// delete info from db
	copy(db_donater_define[i], 63, "")
}

// Date functions
get_total_days(str[])
{
	if(equal(str, ""))
		get_time("%Y-%m-%d", str, 8)

	new syear[5], smonth[3], sday[3], stmp[6]
	strtok(str, syear, 4, stmp, 5, '-')
	strtok(stmp, smonth, 2, sday, 2, '-')

	new result = (str_to_num(syear) * 365) + ((str_to_num(smonth) - 1) * 31) + (str_to_num(sday) - 1)

	return (result < 0 ? 0 : result)
}

is_past(a)
{
	if(a <= 0)	// invalid time
		return false

	if(get_total_days("") > a)	// this time pasted
		return true

	return false
}
