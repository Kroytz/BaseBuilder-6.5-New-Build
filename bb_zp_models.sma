
#include <amxmodx>
#include <zombieplague>
#include <fakemeta>
#include <engine>
#include <fun>
#include <hamsandwich>
#include <dbi>
#include <colorchat_>

new const models_name[][] = { "", "SnowMiku", "积木人", "圣诞老人", "鞋貓劍客", "Wall-E (ZM变SAS)", "天線得得B Po (紅)", "涅普顿" }
new const models_path[][] = { "", "SnowMiku", "zmParadiseHa", "zmParadiseSanta2", "zmParaCat", "zmParaWallE", "zmParaPo", "Neptune" }

new const vip_models_name[][] = { "", "天線得得B Dipsy (綠)", "黑岩射手", "奈亚子" }
new const vip_models_path[][] = { "", "zmParaDipsy", "BlackRockShooter", "nyaruko" }

new const admin_models_name[][] = { "", "大鸡鸡"  }
new const admin_models_path[][] = { "", "zmParaBigChick" }

new const store_models_name[][] = { "", "蕾米莉亚", "黑白.涅普基雅", "五河琴里.新", "四糸乃", "時崎狂三", "SnowWhite Miku", "(特殊笑声)琪露诺", "(限定)克劳德", "(置换.Lv1)尼尔-2B", "(置换.Lv1)ELO-诗乃", "(置换.Lv2)泳装.和泉纱雾" }
new const store_models_path[][] = { "", "remilia", "nepgear_bw", "zmParaKotori", "yoshino", "kurumi", "snowwhitemiku", "cirno", "zmParaCloud", "yorha_2b", "asainuo", "zmParaSagiri" }

native zpm_store_get_user_skin(id, skinid)

new g_selection[33]

// SQL
new Sql:sql
new Result:result
new error[33]

new mapname[64]

public plugin_init()
{
	register_plugin("[ZP] Select models", "2.0", "Para")

	register_clcmd("say /models", "ClCmd_Models")
	register_clcmd("say !models", "ClCmd_Models")
	register_clcmd("say_team /models", "ClCmd_Models")
	register_clcmd("say_team !models", "ClCmd_Models")

	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)

	// Connect SQL
	new sql_host[64], sql_user[64], sql_pass[64], sql_db[64]
	get_cvar_string("amx_sql_host", sql_host, 63)
	get_cvar_string("amx_sql_user", sql_user, 63)
	get_cvar_string("amx_sql_pass", sql_pass, 63)
	get_cvar_string("amx_sql_db", sql_db, 63)

	sql = dbi_connect(sql_host, sql_user, sql_pass, sql_db, error, 32)

	if (sql == SQL_FAILED)
	{
		server_print("[Models] Could not connect to SQL database.")
	}

	get_mapname(mapname, 63)
}

public plugin_precache()
{
	new modelrealpath[255], modelrealpathT[255]

	for(new i = 1; i<sizeof models_path; i++)
	{
		format(modelrealpath, 254, "models/player/%s/%s.mdl", models_path[i], models_path[i])
		format(modelrealpathT, 254, "models/player/%s/%sT.mdl", models_path[i], models_path[i])

		// precache
		engfunc(EngFunc_PrecacheModel, modelrealpath)
		if (file_exists(modelrealpathT)) engfunc(EngFunc_PrecacheModel, modelrealpathT)
	}

	for(new i = 1; i<sizeof vip_models_path; i++)
	{
		format(modelrealpath, 254, "models/player/%s/%s.mdl", vip_models_path[i], vip_models_path[i])
		format(modelrealpathT, 254, "models/player/%s/%sT.mdl", vip_models_path[i], vip_models_path[i])

		// precache
		engfunc(EngFunc_PrecacheModel, modelrealpath)
		if (file_exists(modelrealpathT)) engfunc(EngFunc_PrecacheModel, modelrealpathT)
	}

	for(new i = 1; i<sizeof admin_models_path; i++)
	{
		format(modelrealpath, 254, "models/player/%s/%s.mdl", admin_models_path[i], admin_models_path[i])
		format(modelrealpathT, 254, "models/player/%s/%sT.mdl", admin_models_path[i], admin_models_path[i])

		// precache
		engfunc(EngFunc_PrecacheModel, modelrealpath)
		if (file_exists(modelrealpathT)) engfunc(EngFunc_PrecacheModel, modelrealpathT)
	}
	
	for(new i = 1; i<sizeof store_models_path; i++)
	{
		format(modelrealpath, 254, "models/player/%s/%s.mdl", store_models_path[i], store_models_path[i])
		format(modelrealpathT, 254, "models/player/%s/%sT.mdl", store_models_path[i], store_models_path[i])

		// precache
		engfunc(EngFunc_PrecacheModel, modelrealpath)
		if (file_exists(modelrealpathT)) engfunc(EngFunc_PrecacheModel, modelrealpathT)
	}
}

public plugin_natives()
{
	register_native("zpm_models_get_selection", "Native_Get_Selection", 1)
}

public ClCmd_Models(id)
{
	new menu = menu_create("\y模型菜单:", "main_models_client")
	
	menu_additem(menu, "\w选择人物模型", "1", 0)
	menu_additem(menu, "\w取消选择 (随机模型)^n", "2", 0)

	menu_additem(menu, "\y高玩/捐助者模型", "5", 0)
	menu_additem(menu, "\y管理员特殊模型", "6", 0)
	menu_additem(menu, "\y商店金币模型", "7", 0)
	
	menu_display(id, menu, 0)
}

public main_models_client(id, menu, item)
{
	new data[8], iName[64]
	new access, callback
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback)
	new key = str_to_num(data)

	switch(key)
	{
		case 1: {
			menu_destroy(menu)
			models_menu(id)
		}
		case 2: {
			g_selection[id] = 0
			menu_destroy(menu)
			ColorChat(id, GREEN, "^4[Models] ^1已取消你的人物模型选择，现在你每一局的模型都会不同。")

			new name[33]
			get_user_name(id, name, 32)
			replace_all(name, 32, "`", "\`")
			replace_all(name, 32, "'", "\'")

			dbi_query(sql, "UPDATE userinfo SET playermodel = '%d' WHERE name='%s'", g_selection[id], name)
		}
		case 5: {
			menu_destroy(menu)

			if(!(get_user_flags(id) & ADMIN_RESERVATION))
			{
				ColorChat(id, GREEN, "^4[Models] ^1你不是高玩或捐助者。")
				return PLUGIN_HANDLED
			}

			menu_vip(id)
		}
		case 6: {
			menu_destroy(menu)

			if(!(get_user_flags(id) & ADMIN_BAN))
			{
				ColorChat(id, GREEN, "^4[Models] ^1你不是管理员。")
				return PLUGIN_HANDLED
			}

			menu_admin(id)
		}
		case 7:{
			menu_destroy(menu)
			menu_store(id)
		}

		default: menu_destroy(menu)
	}

	return PLUGIN_HANDLED
}

public menu_vip(id)
{
	new menu = menu_create("\y选择你的人物模型:", "models_client_vip")
	new i_text[3], item_name[255]
	
	for(new i = 1; i<sizeof vip_models_name; i++)
	{
		format(i_text, 2, "%d", i)

		if(g_selection[id] == (i + 1000))
			format(item_name, 254, "\y%s", vip_models_name[i])
		else
			format(item_name, 254, "\w%s", vip_models_name[i])

		menu_additem(menu, item_name, i_text, 0)
	}
	
	menu_display(id, menu, 0)
}

public menu_admin(id)
{
	new menu = menu_create("\y选择你的人物模型:", "models_client_admin")
	new i_text[3], item_name[255]
	
	for(new i = 1; i<sizeof admin_models_name; i++)
	{
		format(i_text, 2, "%d", i)

		if(g_selection[id] == (i + 2000))
			format(item_name, 254, "\y%s", admin_models_name[i])
		else
			format(item_name, 254, "\w%s", admin_models_name[i])

		menu_additem(menu, item_name, i_text, 0)
	}
	
	menu_display(id, menu, 0)
}

public menu_store(id)
{
	new menu = menu_create("\y选择你的人物模型:", "models_client_store")
	new i_text[3], item_name[255]
	
	for(new i = 1; i<sizeof store_models_name; i++)
	{
		format(i_text, 2, "%d", i)

		if(g_selection[id] == (i + 5000))
			format(item_name, 254, "\y%s", store_models_name[i])
		else
			format(item_name, 254, "\w%s", store_models_name[i])

		menu_additem(menu, item_name, i_text, 0)
	}
	
	menu_display(id, menu, 0)
}

public models_menu(id)
{
	new menu = menu_create("\y选择你的人物模型:", "models_client")
	new i_text[3], item_name[255]
	
	for(new i = 1; i<sizeof models_name; i++)
	{
		format(i_text, 2, "%d", i)

		if(g_selection[id] == i)
			format(item_name, 254, "\y%s", models_name[i])
		else
			format(item_name, 254, "\w%s", models_name[i])

		menu_additem(menu, item_name, i_text, 0)
	}
	
	menu_display(id, menu, 0)
}

public models_client_vip(id, menu, item)
{
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback)
	new key = str_to_num(data)

	if((key > (sizeof models_name - 1)) || key < 1)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	g_selection[id] = key + 1000
	ColorChat(id, GREEN, "^4[Models] ^1你选择了 %s.", vip_models_name[g_selection[id] - 1000])

	new name[33]
	get_user_name(id, name, 32)
	replace_all(name, 32, "`", "\`")
	replace_all(name, 32, "'", "\'")

	dbi_query(sql, "UPDATE userinfo SET playermodel = '%d' WHERE name='%s'", g_selection[id], name)

	if(!is_user_alive(id) || zp_get_user_zombie(id))
		ColorChat(id, GREEN, "^4[Models] ^1你选择的模型会在下一局开始时变更.")
	else
		models_change(id)

	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public models_client_admin(id, menu, item)
{
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback)
	new key = str_to_num(data)

	if((key > (sizeof models_name - 1)) || key < 1)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	g_selection[id] = key + 2000
	ColorChat(id, GREEN, "^4[Models] ^1你选择了 %s.", admin_models_name[g_selection[id] - 2000])

	new name[33]
	get_user_name(id, name, 32)
	replace_all(name, 32, "`", "\`")
	replace_all(name, 32, "'", "\'")

	dbi_query(sql, "UPDATE userinfo SET playermodel = '%d' WHERE name='%s'", g_selection[id], name)

	if(!is_user_alive(id) || zp_get_user_zombie(id))
		ColorChat(id, GREEN, "^4[Models] ^1你选择的模型会在下一局开始时变更.")
	else
		models_change(id)

	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public models_client(id, menu, item)
{
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback)
	new key = str_to_num(data)

	if((key > (sizeof models_name - 1)) || key < 1)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	g_selection[id] = key
	ColorChat(id, GREEN, "^4[Models] ^1你选择了 %s.", models_name[g_selection[id]])

	new name[33]
	get_user_name(id, name, 32)
	replace_all(name, 32, "`", "\`")
	replace_all(name, 32, "'", "\'")

	dbi_query(sql, "UPDATE userinfo SET playermodel = '%d' WHERE name='%s'", g_selection[id], name)

	if(!is_user_alive(id) || zp_get_user_zombie(id))
		ColorChat(id, GREEN, "^4[Models] ^1你选择的模型会在下一局开始时变更.")
	else
		models_change(id)

	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public models_client_store(id, menu, item)
{
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(menu, item, access, data, 5, iName, 63, callback)
	new key = str_to_num(data)

	if((key > (sizeof store_models_name - 1)) || key < 1)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	new Skin = zpm_store_get_user_skin(id, key)
	if(Skin != 1)
	{
		menu_destroy(menu)
		ColorChat(id, GREEN, "^4[Models] ^1你还没有购买这个模型, 无法装备.")
		return PLUGIN_HANDLED
	}
	
	g_selection[id] = key + 5000
	ColorChat(id, GREEN, "^4[Models] ^1你选择了 %s.", store_models_name[g_selection[id] - 5000])

	new name[33]
	get_user_name(id, name, 32)
	replace_all(name, 32, "`", "\`")
	replace_all(name, 32, "'", "\'")

	dbi_query(sql, "UPDATE userinfo SET playermodel = '%d' WHERE name='%s'", g_selection[id], name)

	if(!is_user_alive(id) || zp_get_user_zombie(id))
		ColorChat(id, GREEN, "^4[Models] ^1你选择的模型会在下一局开始时变更.")
	else
		models_change(id)

	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public models_change(id)
{
	if(!is_user_connected(id) || !is_user_alive(id) || zp_get_user_zombie(id) || g_selection[id] == 0)
		return;

	if(g_selection[id] >= 5000)
	{
		zp_override_user_model(id, store_models_path[g_selection[id] - 5000], 0)
	}
	else if(g_selection[id] >= 2000)
	{
		zp_override_user_model(id, admin_models_path[g_selection[id] - 2000], 0)
	}
	else if(g_selection[id] >= 1000)
	{
			zp_override_user_model(id, vip_models_path[g_selection[id] - 1000], 0)
	}
	else
	{
		if(containi(mapname, "ze_") != 0 && equali(models_path[g_selection[id]], "zmParaWallE") )
			zp_override_user_model(id, "sas", 0)
		else
			zp_override_user_model(id, models_path[g_selection[id]], 0)
	}
}

public fw_PlayerSpawn_Post(id)
{
	if(is_user_connected(id) && is_user_alive(id) && !zp_get_user_zombie(id))
		set_task(2.0, "models_change", id)
}

public client_putinserver(id)
{
	new name[33]
	get_user_name(id, name, 33)
	replace_all(name, 32, "`", "\`")
	replace_all(name, 32, "'", "\'")

	result = dbi_query(sql, "SELECT playermodel FROM userinfo WHERE name='%s'", name)

	if(result == RESULT_NONE)
	{
		g_selection[id] = 0
	}
	else if(result <= RESULT_FAILED)
	{
		server_print("[Models] SQL error. (Load)")
		g_selection[id] = 0
	}
	else
	{
		g_selection[id] = dbi_field(result, 1)
		dbi_free_result(result)
	}

	if(!(get_user_flags(id) & ADMIN_RESERVATION) && g_selection[id] >= 1000)
	{
		g_selection[id] = 0

		new name[33]
		get_user_name(id, name, 32)
		replace_all(name, 32, "`", "\`")
		replace_all(name, 32, "'", "\'")

		dbi_query(sql, "UPDATE userinfo SET playermodel = '%d' WHERE name='%s'", g_selection[id], name)

	}
	else if(!(get_user_flags(id) & ADMIN_BAN) && g_selection[id] >= 2000)
	{
		g_selection[id] = 0

		new name[33]
		get_user_name(id, name, 32)
		replace_all(name, 32, "`", "\`")
		replace_all(name, 32, "'", "\'")

		dbi_query(sql, "UPDATE userinfo SET playermodel = '%d' WHERE name='%s'", g_selection[id], name)
	}
}

public client_disconnect(id)
	g_selection[id] = 0
	
public Native_Get_Selection(id) return g_selection[id]
