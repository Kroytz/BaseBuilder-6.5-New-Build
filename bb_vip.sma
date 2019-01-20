
// VIP
#include <amxmodx>
#include <amxmisc>
#include <colorchat>
#include <zombieplague>
#include <sqlx>

new g_viplv[33]

new const vipname[][] = { "", "认证高玩", "进阶高玩", "上级高玩", "至尊高玩", "神样高玩", "搞事神烦" }
new const vipmax[] = { 15, 20, 25, 30, 35, 40, 10 }

public plugin_init()
{
	register_plugin("[ZP] 認證高玩", "1.0", "Para")

	register_clcmd("say !vip", "CmdVip")
	register_clcmd("say_team !vip", "CmdVip")
	register_clcmd("say /vip", "CmdVip")
	register_clcmd("say_team /vip", "CmdVip")

	register_concmd("vip_adduid", "cmd_adduid", ADMIN_LEVEL_A , "<uid> <flag> <vip level (255=ban)> - Add user to the vip list in SQL.", 0)
	register_concmd("vip_deleteuid", "cmd_removeuid", ADMIN_LEVEL_A , "<uid> - Remove user from vip list in SQL.", 0)
	register_concmd("vip_setlv", "cmd_setlv", ADMIN_LEVEL_A , "<uid> <new level> - Upgrade or downgrade VIP Level.", 0)
}

public CmdVip(id)
{
	if(g_viplv[id] > 0)
		ColorChat(id, GREEN, "^4[高玩认证] ^1您是 ^4%d ^1级的 ^4%s^1。", g_viplv[id], vipname[g_viplv[id]])
	else
		ColorChat(id, GREEN, "^4[高玩认证] ^1您不是高玩。")
}

public client_authorized(id)
{
	g_viplv[id] = 0
	getVipInfo(id)
}

public client_putinserver(id)
{
	if(g_viplv[id] == 255)
	{
		server_cmd("kick #%d ^"無法連接至本伺服器，因為您已經被封禁。^"", get_user_userid(id))
	}
}


public getVipInfo(id)
{
	new name[33]
	get_user_name(id, name, 32)
	replace_all(name, 32, "`", "\`")
	replace_all(name, 32, "'", "\'")

	new ip[33]
	get_user_ip(id, ip, 32, 1)
	replace_all(ip, 32, "`", "\`")
	replace_all(ip, 32, "'", "\'")

	new authid[64]
	get_user_authid(id, authid, 63)
	replace_all(authid, 63, "`", "\`")
	replace_all(authid, 63, "'", "\'")

	// 0= name
	// 1= ip
	// 2= authid

	new errorno, error[128]
	new Handle:info = SQL_MakeStdTuple()
	new Handle:conn = SQL_Connect(info, errorno, error, 127)

	if(conn == Empty_Handle)
	{
		g_viplv[id] = 0
		log_amx("[VIP] Connection failed: #%d %s", errorno, error)
	}
	else
	{
		new sqlquery[1000]
		format(sqlquery, charsmax(sqlquery), "SELECT viplv FROM vipinfo WHERE (define='%s' AND flag='0') OR (define='%s' AND flag='1') OR (define='%s' AND flag='2')", name, ip, authid)

		new Handle:query = SQL_PrepareQuery(conn, sqlquery)

		if(!SQL_Execute(query))
		{
			g_viplv[id] = 0
			log_amx("[VIP] Execute failed.")
		}
		else if(!SQL_NumResults(query))
		{
			g_viplv[id] = 0
		}
		else
		{
			new viplv[5]
			new q_viplv = SQL_FieldNameToNum(query, "viplv")
			SQL_MoreResults(query)
			SQL_ReadResult(query, q_viplv, viplv, sizeof(viplv) -1)
			g_viplv[id] = str_to_num(viplv)
		}

		SQL_FreeHandle(query)
	}

	SQL_FreeHandle(conn)
	SQL_FreeHandle(info)

	if(g_viplv[id] == 255)
	{
		server_cmd("kick #%d ^"無法連接至本伺服器，因為您的賬戶已被永久封禁。^"", get_user_userid(id))
		return;
	}

	if(g_viplv[id] > 0 && g_viplv[id] < 6)
	{
		new name2[33]
		get_user_name(id, name2, 32)
		server_print("[VIP] %s become VIP (Lv%d)", name2, g_viplv[id])

		if(!(get_user_flags(id) & ADMIN_RESERVATION))
			set_user_flags(id, read_flags("b"))
	}
	else if(!(get_user_flags(id) & ADMIN_RESERVATION))
		set_user_flags(id, read_flags("z"))

	if((get_playersnum(1) - 1) >= (get_maxplayers() - 1))
	{
		if(!(get_user_flags(id) & ADMIN_RESERVATION))
		{
			server_cmd("kick #%d ^"服务器已满! QQ群: 303159408^"", get_user_userid(id))
		}
	}
}

public cmd_removeuid(jd, level, cid)
{
	if (!cmd_access(jd, level, cid, 2))
		return PLUGIN_HANDLED;
	
	new arg[255]
	read_argv(1, arg, charsmax(arg))

	new uid = str_to_num(arg)
	new id = -1

	for(new i = 0; i<33; i++)
		if(get_user_userid(i) == uid)
			id = i

	if(id < 1)
	{
		client_print(jd, print_console, "[VIP] User is not exists.")
		return PLUGIN_HANDLED;
	}

	new name[33]
	get_user_name(id, name, 32)
	replace_all(name, 32, "`", "\`")
	replace_all(name, 32, "'", "\'")

	new ip[33]
	get_user_ip(id, ip, 32, 1)
	replace_all(ip, 32, "`", "\`")
	replace_all(ip, 32, "'", "\'")

	new authid[64]
	get_user_authid(id, authid, 63)
	replace_all(authid, 63, "`", "\`")
	replace_all(authid, 63, "'", "\'")

	new sqlquery[500]
	format(sqlquery, charsmax(sqlquery), "DELETE FROM vipinfo WHERE (define='%s' AND flag='0') OR (define='%s' AND flag='1') OR (define='%s' AND flag='2')", name, ip, authid)
	db_query(sqlquery)

	g_viplv[id] = 0

	new name2[33]
	get_user_name(id, name2, 32)

	ColorChat(0, GREEN, "^4[认证] ^1玩家 ^4%s ^1已经不再具有认证了。", name2)

	if(!(get_user_flags(id) & ADMIN_MENU))
		set_user_flags(id, read_flags("z"))

	return PLUGIN_HANDLED;
}

public cmd_adduid(jd, level, cid)
{
	if (!cmd_access(jd, level, cid, 4))
		return PLUGIN_HANDLED;
	
	new arg[255], arg2[255], arg3[255]
	read_argv(1, arg, charsmax(arg))
	read_argv(2, arg2, charsmax(arg2))
	read_argv(3, arg3, charsmax(arg3))

	new uid = str_to_num(arg)
	new flag = str_to_num(arg2)
	new viplv = str_to_num(arg3)
	new id = -1

	for(new i = 0; i<33; i++)
		if(get_user_userid(i) == uid)
			id = i

	if(id < 1)
	{
		client_print(jd, print_console, "[VIP] User is not exists.")
		return PLUGIN_HANDLED;
	}

	if(flag < 0 || flag > 2)
	{
		client_print(jd, print_console, "[VIP] Flag is not exists. (0=name, 1=ip, 2=steam id)")
		return PLUGIN_HANDLED;
	}

	if(viplv != 255)
	{

		if(viplv < 1 || viplv > 6)
		{
			client_print(jd, print_console, "[VIP] Level is not exists. (1=min, 6=max)")
			return PLUGIN_HANDLED;
		}
	}

	// Got it! name got, flag got!
	new define[255]

	if(flag == 0)	//name
		get_user_name(id, define, 254)
	else if(flag == 1) // ip addr
		get_user_ip(id, define, 254, 1)
	else if(flag == 2)
		get_user_authid(id, define, 254)

	replace_all(define, 254, "`", "\`")
	replace_all(define, 254, "'", "\'")

	new sqlquery[500]
	format(sqlquery, charsmax(sqlquery), "INSERT INTO vipinfo(viplv, define, flag) VALUES('%d','%s','%d')", viplv, define, flag)
	db_query(sqlquery)

	new name2[33]
	get_user_name(id, name2, 32)

	if(viplv == 255)
	{
		ColorChat(0, GREEN, "^4[认证] ^1玩家 ^4%s ^1被封禁了 ^4永久 ^1了。", name2)
		server_cmd("kick #%d ^"您已被伺服器永久封禁。請聯繫管理員獲取更多信息。^"", get_user_userid(id))

		set_user_info(id, "_vgui2_enabled", "2")
	}
	else
	{

		
		// Refresh info
		g_viplv[id] = viplv

		ColorChat(0, GREEN, "^4[认证] ^1玩家 ^4%s ^1已被认证为 ^4%s ^1了。", name2, vipname[viplv])

		if(!(get_user_flags(id) & ADMIN_RESERVATION) && g_viplv[id] != 6)
			set_user_flags(id, read_flags("b"))
	}

	return PLUGIN_HANDLED;
}

public cmd_setlv(jd, level, cid)
{
	if (!cmd_access(jd, level, cid, 2))
		return PLUGIN_HANDLED;
	
	new arg[255], arg2[255]
	read_argv(1, arg, charsmax(arg))
	read_argv(2, arg2, charsmax(arg))

	new uid = str_to_num(arg)
	new viplv = str_to_num(arg2)
	new id = -1

	for(new i = 0; i<33; i++)
		if(get_user_userid(i) == uid)
			id = i

	if(id < 1)
	{
		client_print(jd, print_console, "[VIP] User is not exists.")
		return PLUGIN_HANDLED;
	}

	if(viplv < 1 || viplv > 6)
	{
		client_print(jd, print_console, "[VIP] Level is not exists. (1=min, 6=max)")
		return PLUGIN_HANDLED;
	}

	if(g_viplv[id] < 1)
	{
		client_print(jd, print_console, "[VIP] This user is not vip. Please use vip_adduid!")
		return PLUGIN_HANDLED;
	}

	new name[33]
	get_user_name(id, name, 32)
	replace_all(name, 32, "`", "\`")
	replace_all(name, 32, "'", "\'")

	new ip[33]
	get_user_ip(id, ip, 32, 1)
	replace_all(ip, 32, "`", "\`")
	replace_all(ip, 32, "'", "\'")

	new authid[64]
	get_user_authid(id, authid, 63)
	replace_all(authid, 63, "`", "\`")
	replace_all(authid, 63, "'", "\'")

	new sqlquery[500]
	format(sqlquery, charsmax(sqlquery), "UPDATE vipinfo SET viplv = '%d' WHERE (define='%s' AND flag='0') OR (define='%s' AND flag='1') OR (define='%s' AND flag='2')", viplv, name, ip, authid)
	db_query(sqlquery)

	g_viplv[id] = viplv

	new name2[33]
	get_user_name(id, name2, 32)

	ColorChat(0, GREEN, "^4[认证] ^1玩家 ^4%s ^1已被认证为 ^4%s ^1了。", name2, vipname[viplv])

	return PLUGIN_HANDLED;
}

get_vip_num()
{
	new retval = 0

	for(new id = 0; id<33; id++)
		if(is_user_connected(id))
			if(get_user_flags(id) & ADMIN_RESERVATION)
				retval ++
}

db_query(sqlquery[])
{
	new errorno, error[128]
	new Handle:info = SQL_MakeStdTuple()
	new Handle:conn = SQL_Connect(info, errorno, error, 127)

	if(conn == Empty_Handle)
	{
		log_amx("[VIP] Connection failed: #%d %s", errorno, error)
	}
	else
	{
		new Handle:query = SQL_PrepareQuery(conn, sqlquery)
		SQL_Execute(query)
		SQL_FreeHandle(query)
	}

	SQL_FreeHandle(conn)
	SQL_FreeHandle(info)
}