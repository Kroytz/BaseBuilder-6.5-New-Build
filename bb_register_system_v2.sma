
#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <colorchat>
#include <dhudmessage>
#include <sqlx>

//#define sv_ip_verify

#if defined sv_ip_verify
new const g_szServerIP[] = "10.122.29.138:27020" //输入IP地址
#endif

#define WAITRL_TIME 100

#define TASK_DELAY 10001
#define TASK_WAITRL 20001

#define TEAM_SELECT_VGUI_MENU_ID 2

const KEYSMENU = MENU_KEY_1|MENU_KEY_2

new g_MsgSync, g_screenfade

new g_fwLogged, g_fwDummyResult

new bool:g_CanRL[33]
new bool:g_Login[33]
new bool:g_NeedRegister[33]
new bool:g_ScreenFade[33]
new bool:g_CanChangeName[33]
new bool:g_CanChangePw[33]

new g_Countdown[33]
new g_Password[33][32]
new g_RealPassword[33][32]


public plugin_init()
{
	register_plugin("Register System", "2.0", "Para")

	register_forward(FM_ClientDisconnect, "fw_ClientDisconnect_Post", 1)

	register_message(get_user_msgid("ShowMenu"), "message_show_menu")
	register_message(get_user_msgid("VGUIMenu"), "message_vgui_menu")

	register_clcmd("say /changepw", "clcmd_saychangepw")
	register_clcmd("say_team /changepw", "clcmd_saychangepw")
	register_clcmd("say /changepassword", "clcmd_saychangepw")
	register_clcmd("say_team /changepassword", "clcmd_saychangepw")
	register_clcmd("say /change_pw", "clcmd_saychangepw")
	register_clcmd("say_team /change_pw", "clcmd_saychangepw")
	register_clcmd("say /change_password", "clcmd_saychangepw")
	register_clcmd("say_team /change_password", "clcmd_saychangepw")

	register_clcmd("_login", "clcmd_login")
	register_clcmd("_register", "clcmd_register")
	register_clcmd("_old_pw", "clcmd_oldpw")
	register_clcmd("_change_pw", "clcmd_changepw")

	register_clcmd("say", "clcmd_say")
	register_clcmd("say_team", "clcmd_say")

	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")

	register_menu("Register Menu", KEYSMENU, "MenuRegister")

	g_screenfade = get_user_msgid("ScreenFade")

	// forwards
	g_fwLogged = CreateMultiForward("client_logged", ET_IGNORE, FP_CELL)

	g_MsgSync = CreateHudSyncObj()
	
	#if defined sv_ip_verify
	new szIP[22]; get_user_ip(0, szIP, charsmax(szIP)); 
	if(!equal(szIP, g_szServerIP))
	{
		set_fail_state("[RegSystem] IP Address Verify Fail. Contact QQ: 544051367 or Email: i@imomoe.cn for more information. "); 
		return;
	}
	#endif
}

public clcmd_say(id)
{
	if(!g_Login[id])
	{
		ColorChat(id, RED, "请留意左上角的文字，输入密码时不用按 Y 键。")
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public plugin_natives()
{
	register_native("set_block_name_change", "native_set_name_change", 1)
	register_native("is_user_logged", "native_is_user_logged", 1)
	register_native("auth_user_password", "native_auth_pw", 1)
	register_native("force_logout", "native_force_logout", 1)
}

public client_putinserver(id)
{
	client_connect(id)
	remove_task(id+TASK_DELAY)
}


public client_connect(id)
{
	g_CanRL[id] = false
	g_Login[id] = false
	g_NeedRegister[id] = false
	g_Countdown[id] = 0
	g_CanChangeName[id] = false
	g_CanChangePw[id] = false
	g_ScreenFade[id] = false
	copy(g_Password[id], 31, "")
	copy(g_RealPassword[id], 31, "")
}

public fw_ClientDisconnect_Post(id)
{
	g_CanRL[id] = false
	g_Login[id] = false
	g_NeedRegister[id] = false
	g_Countdown[id] = 0
	g_CanChangeName[id] = false
	g_CanChangePw[id] = false
	g_ScreenFade[id] = false
	copy(g_Password[id], 31, "")
	copy(g_RealPassword[id], 31, "")
}

public client_infochanged(id) 
{
	if(g_CanChangeName[id])
		return PLUGIN_CONTINUE

	new newname[32], oldname[32]

	get_user_info(id, "name", newname, 31)
	get_user_name(id, oldname, 31)

	if(!is_user_connected(id) || is_user_bot(id))
		return PLUGIN_CONTINUE

	if(!equali(newname, oldname))
	{
		set_user_info(id, "name", oldname)

		client_print(id, print_center, "抱歉! 若要更改名字，请先离线!.")
		ColorChat(id, RED, "抱歉! 若要更改名字，请先离线!.")
		client_print(id, print_console, "Sorry! Disconnect first if you want to change your name.")

		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public message_show_menu(msgid, dest, id)
{
	if(g_Login[id])
		return PLUGIN_CONTINUE

	if (task_exists(id+TASK_DELAY))
		return PLUGIN_CONTINUE

	static team_select[] = "#Team_Select"
	static menu_text_code[sizeof team_select]
	get_msg_arg_string(4, menu_text_code, sizeof menu_text_code - 1)

	if (!equal(menu_text_code, team_select))
		return PLUGIN_CONTINUE

	set_task(0.5, "ReadUserInfo", id+TASK_DELAY)

	return PLUGIN_HANDLED
}

public message_vgui_menu(msgid, dest, id)
{
	if(g_Login[id])
		return PLUGIN_CONTINUE

	if (get_msg_arg_int(1) != TEAM_SELECT_VGUI_MENU_ID || task_exists(id+TASK_DELAY))
		return PLUGIN_CONTINUE

	set_task(0.5, "ReadUserInfo", id+TASK_DELAY)

	return PLUGIN_HANDLED
}

public ReadUserInfo(taskid)
{
	new id = taskid - TASK_DELAY

	if(!is_user_connected(id))
		return;

	remove_task(id+TASK_DELAY)
	remove_task(id+TASK_WAITRL)

	new errorno, error[128]
	new Handle:info = SQL_MakeStdTuple()
	new Handle:conn = SQL_Connect(info, errorno, error, 127)

	if(conn == Empty_Handle)
	{
		log_amx("SQL Connection Error: #%d %s", errorno, error)

		if(g_Countdown[id] >= 5)
		{
			server_cmd("kick #%d ^"服务器无法连线到资料库，请联络QQ: 544051367 / Can't connect to DB^"", get_user_userid(id))
			return;
		}

		set_hudmessage(0, 255, 0, 0.25, 0.35, 0, 0.0, 1.1, 0.1, 0.0, -1)
		ShowSyncHudMsg(id, g_MsgSync, "[喪屍樂園]^n服务器正在尝试连线到资料库.^n请稍等...^n^nServer is connecting to the database.^nPlease wait...")

		// retry after 1s
		set_task(1.0, "ReadUserInfo", id+TASK_DELAY)
		g_Countdown[id] ++
	}
	else
	{
		new name[33]
		get_user_name(id, name, 32)
		replace_all(name, 32, "`", "\`")
		replace_all(name, 32, "'", "\'")

		new Handle:query = SQL_PrepareQuery(conn, "SELECT password FROM userpass WHERE name='%s'", name)

		if(!SQL_Execute(query))
		{
			log_amx("Could not execute: %s query", name)

			if(g_Countdown[id] >= 5)
			{
				server_cmd("kick #%d ^"服务器无法连线到资料库，请联络QQ: 544051367 / Can't connect to DB^"", get_user_userid(id))
				return;
			}

			set_hudmessage(0, 255, 0, 0.25, 0.35, 0, 0.0, 1.1, 0.1, 0.0, -1)
			ShowSyncHudMsg(id, g_MsgSync, "[喪屍樂園]^n服务器正在尝试连线到资料库.^n请稍等...^n^nServer is connecting to the database.^nPlease wait...")

			// retry after 1s
			set_task(1.0, "ReadUserInfo", id+TASK_DELAY)
			g_Countdown[id] ++
		}
		else if(!SQL_NumResults(query))
		{
			// need to register
			g_NeedRegister[id] = true
			g_Countdown[id] = WAITRL_TIME
			g_Login[id] = false
			g_CanRL[id] = false
			copy(g_Password[id], 31, "")

			ShowTipsMsg(id, true)
			set_task(1.0, "WaitUserRL", id+TASK_WAITRL, _, _, "b")

		}
		else
		{
			// need to login
			g_NeedRegister[id] = false
			g_Countdown[id] = WAITRL_TIME
			g_Login[id] = false
			g_CanRL[id] = false
			copy(g_Password[id], 31, "")

			// store the real password
			SQL_ReadResult(query, SQL_FieldNameToNum(query, "password"), g_RealPassword[id], 31)

			ShowTipsMsg(id, true)
			set_task(1.0, "WaitUserRL", id+TASK_WAITRL, _, _, "b")
		}

		SQL_FreeHandle(query)
	}

	SQL_FreeHandle(conn)
}

public WaitUserRL(taskid)
{
	new id = taskid - TASK_WAITRL

	if(!is_user_connected(id))
	{
		remove_task(taskid)
		return;
	}

	g_Countdown[id] --

	if(g_Countdown[id] <= 0)
	{
		remove_task(taskid)
		server_cmd("kick #%d ^"注册或登陆超时(不知道密码请改名) / Login or register time out(Change name if you don't know password)^"", get_user_userid(id))
		return;
	}

	ShowTipsMsg(id, false)
}

public ShowTipsMsg(id, effect)
{
	if(effect) set_hudmessage(0, 255, 0, 0.25, 0.35, 0, 0.0, 1.1, 0.1, 0.0, -1)
	else set_hudmessage(0, 255, 0, 0.25, 0.35, 0, 0.0, 1.1, 0.0, 0.0, -1)
/*
	if(!g_NeedRegister[id])
	{
		ShowSyncHudMsg(id, g_MsgSync, "Zombie Paradise - 喪屍樂園^nQQ群:303159408^n^n你的名字已经注册,请在左上角入密码^n您还剩下%d秒登陆(不知道密码请换个名字)。^n^nPlease type your password to login.^nYou remain %ds to login.", g_Countdown[id], g_Countdown[id])
		client_cmd(id, "messagemode _login")
	}
	else
	{
		ShowSyncHudMsg(id, g_MsgSync, "Zombie Paradise - 喪屍樂園^nQQ群:303159408^n^n你还没有注册,请在左上角输入密码进行注册.^n您还剩下%d秒注册。^n^nPlease type your password to register.^nYou remain %ds to register.", g_Countdown[id], g_Countdown[id])
		client_cmd(id, "messagemode _register")
	}
*/
	if(!g_NeedRegister[id])
	{
		ShowSyncHudMsg(id, g_MsgSync, "Zombie Paradise - 喪屍樂園^n- Powered By 天殇社区 -^nQQ群:937442194^n^n你的名字已经注册,请在左上角入密码^n您还剩下%d秒登陆(不知道密码请换个名字)。^n^nPlease type your password to login.^nYou remain %ds to login.", g_Countdown[id], g_Countdown[id])
		client_cmd(id, "messagemode _login")
	}
	else
	{
		ShowSyncHudMsg(id, g_MsgSync, "Zombie Paradise - 喪屍樂園^n- Powered By 天殇社区 -^nQQ群:937442194^n^n你还没有注册,请在左上角输入密码进行注册.^n您还剩下%d秒注册。^n^nPlease type your password to register.^nYou remain %ds to register.", g_Countdown[id], g_Countdown[id])
		client_cmd(id, "messagemode _register")
	}
}

public clcmd_register(id)
{
	// block invalid register
	if(!is_user_connected(id))
		return PLUGIN_HANDLED

	if(g_Login[id] || !g_NeedRegister[id])
		return PLUGIN_HANDLED

	new password[32]
	read_argv(1, password, 31)
	remove_quotes(password)

	if(containi(password, "'") >= 0 || containi(password, "`") >= 0 || containi(password, "\") >= 0 || containi(password, "^"") >= 0)
	{
		ColorChat(id, RED, "您的密码不能包含特殊字符: ' ` \ ^" / Your password doesn't allow to contain: ' ` \ ^"")
		return PLUGIN_HANDLED
	}

	if(strlen(password) > 20)
	{
		ColorChat(id, RED, "您的密码太长了! / Your password length too long.")
		return PLUGIN_HANDLED
	}

	if(strlen(password) < 6)
	{
		ColorChat(id, RED, "您的密码太短了!请输入6位数以上的密码 / Your password length too short.")
		return PLUGIN_HANDLED
	}

	remove_task(id+TASK_WAITRL)
	ShowRegisterMenu(id, password)

	return PLUGIN_HANDLED
}

public clcmd_login(id)
{
	// block invalid register
	if(!is_user_connected(id))
		return PLUGIN_HANDLED

	if(g_Login[id] || g_NeedRegister[id])
		return PLUGIN_HANDLED

	if(equal(g_RealPassword[id], ""))
	{
		ColorChat(id, RED, "发生错误! 请重新登入! / Error occurred! Please retry!")
		ReadUserInfo(id)
		return PLUGIN_HANDLED
	}

	new password[32]
	read_argv(1, password, 31)
	remove_quotes(password)

	if(containi(password, "'") >= 0 || containi(password, "`") >= 0 || containi(password, "\") >= 0 || containi(password, "^"") >= 0)
	{
		ColorChat(id, RED, "您的密码不能包含特殊字附: ' ` \ ^" / Your password doesn't allow to contain: ' ` \ ^"")
		return PLUGIN_HANDLED
	}

	if(strlen(password) > 20)
	{
		ColorChat(id, RED, "您的密码太长了! / Your password length too long.")
		return PLUGIN_HANDLED
	}

	if(strlen(password) < 6)
	{
		ColorChat(id, RED, "您的密码太短了!请输入6位数以上的密码 ! / Your password length too short.")
		return PLUGIN_HANDLED
	}

	if(!equali(g_RealPassword[id], password))
	{
		ColorChat(id, RED, "密码错误! 请重新登陆。若您不知道密码，请先离线改名字后重试!")
		ColorChat(id, RED, "Wrong password! Please retry. If you don't know your password, please disconnect, rename and retry!")

		g_Countdown[id] -= 60		// punishment

		return PLUGIN_HANDLED
	}

	SetUserLoginStats(id)
	ColorChat(id, RED, "登入成功，如无法加入游戏，请按M 键开启队伍选择选单! / Success. Press M if you can't join the game.")

	return PLUGIN_HANDLED
}

public ShowRegisterMenu(id, password[])
{
	copy(g_Password[id], 31, password)

	static menu[300], len
	len = 0
	len += formatex(menu[len], charsmax(menu) - len, "\r您是否确定要使用这组密码来注册?^nDo you want to register with this password?^n\y密碼(Password): %s^n^n", password)
	len += formatex(menu[len], charsmax(menu) - len, "\r1. \w是，让我注册 (Yes)^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r2. \w否，我想更改密码 (No)^n")

	show_menu(id, KEYSMENU, menu, -1, "Register Menu")
}

public clcmd_saychangepw(id)
{
	if(!g_Login[id])
		return PLUGIN_HANDLED

	if(g_CanChangePw[id])
	{
		ColorChat(id, RED, "现在无法更改密码，请稍后再试。 / You can't change your password in this time. Please try again later.")
		return PLUGIN_HANDLED
	}

	client_cmd(id, "messagemode _old_pw")
	ColorChat(id, RED, "请输入旧密码，按 ESC 取消 / Please type your old password or press ESC to cancel")
	return PLUGIN_HANDLED
}

public MenuRegister(id, key)
{
	if(key == 0)
	{
		new errorno, error[128]
		new Handle:info = SQL_MakeStdTuple()
		new Handle:conn = SQL_Connect(info, errorno, error, 127)

		if(conn == Empty_Handle)
			return PLUGIN_HANDLED

		new name[33]
		get_user_name(id, name, 32)
		replace_all(name, 32, "'", "\'")
		replace_all(name, 32, "`", "\`")

		SQL_QueryAndIgnore(conn, "INSERT INTO userpass(name, password) VALUES('%s','%s')", name, g_Password[id])
		SQL_FreeHandle(conn)

		copy(g_RealPassword[id], 31, g_Password[id])

		// prepare to play
		SetUserLoginStats(id)

		ColorChat(id, RED, "您的密码不能包含特殊字附! / Success. Please remember your password.")
	}
	else
	{
		// retry to register
		set_task(0.5, "ReadUserInfo", id+TASK_DELAY)
	}

	return PLUGIN_HANDLED
}

public SetUserLoginStats(id)
{
	if(g_Login[id])
		return;

	remove_task(id+TASK_DELAY)
	remove_task(id+TASK_WAITRL)

	// clear
	set_hudmessage(200, 100, 200, 0.25, 0.35, 0, 0.0, 0.1, 0.0, 0.0, -1)
	ShowSyncHudMsg(id, g_MsgSync, "")

	g_Login[id] = true
	ExecuteForward(g_fwLogged, g_fwDummyResult, id)

	set_task(1.0, "chooseteam", id)
}

public chooseteam(id)
{
	if(!is_user_connected(id))
		return PLUGIN_HANDLED

	// send twice chooseteam to client(prevent lost packet)
	client_cmd(id, "chooseteam")
	client_cmd(id, "chooseteam")

	return PLUGIN_HANDLED
}

public clcmd_oldpw(id)
{
	// block invalid register
	if(!is_user_connected(id))
		return PLUGIN_HANDLED

	if(!g_Login[id] || g_CanChangePw[id])
		return PLUGIN_HANDLED

	new password[32]
	read_argv(1, password, 31)
	remove_quotes(password)

	if(containi(password, "'") >= 0 || containi(password, "`") >= 0 || containi(password, "\") >= 0 || containi(password, "^"") >= 0)
	{
		ColorChat(id, RED, "您的密码不能包含特殊字附: ' ` \ ^" / Your password doesn't allow to contain: ' ` \ ^"")
		return PLUGIN_HANDLED
	}

	if(strlen(password) > 20)
	{
		ColorChat(id, RED, "您的密码太长了! / Your password length too long.")
		return PLUGIN_HANDLED
	}

	if(strlen(password) < 6)
	{
		ColorChat(id, RED, "您的密码太短了! / Your password length too short.")
		return PLUGIN_HANDLED
	}

	if(!equali(g_RealPassword[id], password))
	{
		ColorChat(id, RED, "密码错误! 三秒后自动退出! / Wrong password! Auto logout in 3 seconds!")
		g_ScreenFade[id] = true
		set_task(3.0, "RetryClient", id)

		// message to client
		set_dhudmessage(255, 0, 0, -1.0, -1.0, 0, 0.0, 3.0, 0.1, 0.1, false)
		show_dhudmessage(id, "验证身份失败!^n为了您的帐号安全，将于三秒后自动登出。")

		return PLUGIN_HANDLED
	}

	g_CanChangePw[id] = true
	ColorChat(id, RED, "请输入您的新密码，按 ESC 取消 / Please input your new password. Press ESC to cancel.")
	client_cmd(id, "messagemode _change_pw")

	set_task(30.0, "SetCantChangePw", id)

	return PLUGIN_HANDLED

}

public RetryClient(id)
{
	if(!is_user_connected(id))
		return PLUGIN_HANDLED

	client_cmd(id, "retry")
	return PLUGIN_HANDLED
}

public clcmd_changepw(id)
{
	// block invalid register
	if(!is_user_connected(id))
		return PLUGIN_HANDLED

	if(!g_Login[id])
		return PLUGIN_HANDLED

	if(!g_CanChangePw[id])
	{
		ColorChat(id, RED, "更改密码超时，请输入 /changepw 重試! / Change password time out. Please type /changepw retry.")
		return PLUGIN_HANDLED
	}

	new password[32]
	read_argv(1, password, 31)
	remove_quotes(password)

	if(containi(password, "'") >= 0 || containi(password, "`") >= 0 || containi(password, "\") >= 0 || containi(password, "^"") >= 0)
	{
		ColorChat(id, RED, "您的密码不能包含特殊字附: ' ` \ ^" / Your password doesn't allow to contain: ' ` \ ^"")
		return PLUGIN_HANDLED
	}

	if(strlen(password) > 20)
	{
		ColorChat(id, RED, "您的密碼太長了! / Your password length too long.")
		return PLUGIN_HANDLED
	}

	if(strlen(password) < 6)
	{
		ColorChat(id, RED, "您的密碼太短了! / Your password length too short.")
		return PLUGIN_HANDLED
	}

	if(equali(g_RealPassword[id], password))
	{
		ColorChat(id, RED, "新旧密码相同，无须更改! / Your new password equal to old one. Nothing changed.")
		return PLUGIN_HANDLED
	}

	new errorno, error[128]
	new Handle:info = SQL_MakeStdTuple()
	new Handle:conn = SQL_Connect(info, errorno, error, 127)

	if(conn == Empty_Handle)
		return PLUGIN_HANDLED

	new name[33]
	get_user_name(id, name, 32)
	replace_all(name, 32, "'", "\'")
	replace_all(name, 32, "`", "\`")

	SQL_QueryAndIgnore(conn, "UPDATE userpass SET password='%s' WHERE name='%s'", password, name)
	SQL_FreeHandle(conn)

	copy(g_RealPassword[id], 31, password)

	g_CanChangePw[id] = false
	ColorChat(id, RED, "密码已更改，新密码: %s / Password changed. New password: %s", password, password)

	return PLUGIN_HANDLED

}

public SetCantChangePw(id)
{
	g_CanChangePw[id] = false
}

public fw_PlayerPreThink(id)
{
	if(g_Login[id] && !g_ScreenFade[id])
		return PLUGIN_CONTINUE

	message_begin(MSG_ONE_UNRELIABLE, g_screenfade, {0,0,0}, id)
	write_short(1<<10)
	write_short(1<<12)
	write_short(0x0000)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	write_byte(255)
	message_end()

	return PLUGIN_CONTINUE
}

public native_set_name_change(id, bool:stats)
{
	if(!is_user_connected(id))
		return;

	g_CanChangeName[id] = stats
}

public native_is_user_logged(id)
{
	if(!is_user_connected(id))
		return false;

	if(is_user_bot(id))
		return true;

	return g_Login[id];
}

public native_auth_pw(id, pw[])
{
	if(equal(g_RealPassword[id], pw))
		return true;

	return false;
}

public native_force_logout(id)
{
	fw_ClientDisconnect_Post(id)
}