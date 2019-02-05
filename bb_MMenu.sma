#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <ColorChat_>

const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0

#define PLUGIN "[BB] Menu: ChooseTeam"
#define VERSION "1.0"
#define AUTHOR "EmeraldGhost"

public plugin_init() 
{
    register_plugin(PLUGIN, VERSION, AUTHOR)

	register_menu("Game Menu 2", KEYSMENU, "menu_game_2")
	
	register_clcmd("show_menu_game", "show_menu_game_2")
}

public show_menu_game_2(id)
{
	static menu[1000], len, userflags
	len = 0
	userflags = get_user_flags(id)
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\y基地建设 6.5^n修改：CyberTech Dev Team.^n版本号：65Nem-190117RL^n^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r1.\w 丧屍类型选择 \d/Class^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r2.\w 复活(丧屍出笼前) \d/Revive^n^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r3.\w 皮肤商店 \d/Store^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r4.\w 皮肤置换 \d/Compose^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r5.\w 皮肤出售 \d/StoreSell^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r6.\w 皮肤选单 \d/Models^n^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r7.\w 投票换图 \d/RTV^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r8.\w 投票封禁 \d/VoteBan^n^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r9.\w 升级系统 \d/BB_Lvl^n")
	
	// 0. Exit
	len += formatex(menu[len], charsmax(menu) - len, "^n\r0.\w 退出")
	
	show_menu(id, KEYSMENU, menu, -1, "Game Menu 2")
}

public menu_game_2(id, key)
{
	switch (key)
	{
		case 0: client_cmd(id, "say /class")
		case 1: client_cmd(id, "say /revive")
		case 2: client_cmd(id, "say /store")
		case 3: client_cmd(id, "say /compose")
		case 4: client_cmd(id, "say /storesell")
		case 5: client_cmd(id, "say /models")
		case 6: client_cmd(id, "say /rtv")
		case 7: client_cmd(id, "say /voteban")
		case 8: client_cmd(id, "say /bb_lvl")
	}
	
	return PLUGIN_HANDLED;
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
