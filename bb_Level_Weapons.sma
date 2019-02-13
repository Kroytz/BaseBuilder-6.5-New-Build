#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <dbi>
#include <fakemeta>
#include <hamsandwich>
#include <eg_boss>

#define PLUGIN "[BB] Level: Gun Shop"
#define VERSION "S1v2"
#define AUTHOR "EmeraldGhost"

//SQL variable
new Sql:sql
new Result:result
new error[33]

new const is_bought_gun[][] = { "未购买", "已购买" }

// Primary Weapons
new const pri_gun_type[][] = { "null", "[突击步枪]", "[冲锋枪]", "[冲锋枪]" }
new const pri_gun_name[][] = { "null", "416-C Carbine", "Kriss Super V", "爆炎蒸汽 SPSMG" }
new const pri_gun_cost[] = { 0, 150, 100, 150 }
new const pri_gun_code[][] = { "null", "hk416", "kriss", "spsmg" }

// Secondrary Weapons
new const sec_gun_type[][] = { "null", "[榴弹发射器]" }
new const sec_gun_name[][] = { "null", "FireCracker" }
new const sec_gun_cost[] = { 0, 100 }
new const sec_gun_code[][] = { "null", "firecracker" }

new const log_file[] = "BB_FGunBuyLog.txt"

// Log Select
new g_iSelectPri[33]
new g_iSelectSec[33]

//永久槍代數
new g_iForeverGun[33][sizeof pri_gun_code]

//永久手槍代數
new g_iForeverHandGun[33][sizeof sec_gun_code]

//永久物品代數(目前五項,如有更多請按照這樣再增加,不慬的話請告訴我)
new g_xD0625_ftg1[33], g_xD0625_ftg2[33], g_xD0625_ftg3[33], g_xD0625_ftg4[33], g_xD0625_ftg5[33]

public plugin_init() 
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    register_clcmd("fshopgun","fshop_gun")
    register_clcmd("fshophandgun","fshop_handgun")
    register_clcmd("fshopother","fshop_other")
    register_clcmd("myfgmenu","myfg_menu")
    register_clcmd("myfhgmenu","myfhg_menu")
    register_clcmd("myfomenu","myfo_menu")
    register_clcmd("vipmenu","vip_menu")
    register_clcmd("savefguns", "savefguns")
	
	RegisterHam(Ham_Spawn, 		"player", 	"ham_PlayerSpawn_Post", 1)
    
	// SQL Initionlize
	new sql_host[64], sql_user[64], sql_pass[64], sql_db[64]
	get_cvar_string("amx_sql_host", sql_host, 63)
	get_cvar_string("amx_sql_user", sql_user, 63)
	get_cvar_string("amx_sql_pass", sql_pass, 63)
	get_cvar_string("amx_sql_db", sql_db, 63)

	sql = dbi_connect(sql_host, sql_user, sql_pass, sql_db, error, 32)

	if (sql == SQL_FAILED)
	{
		server_print("[FGunShop] Could not connect to SQL database. %s", error)
	}
}

public ham_PlayerSpawn_Post(id)
{
	g_iSelectPri[id] = 0
}

public fshop_gun(id) //永久商城主槍械(己列出例子)
{
		new menu = menu_create("\r永久商城 - 永久枪", "fshop2_handler");
				
		new szTempid[32]
		for(new i = 1; i < sizeof pri_gun_code; i++)
		{
			new szItems[101]
			//\g[突击步枪]\y416-C Carbine     \g100 武器点
			formatex(szItems, 100, "\g%s\y%s     \g%d 武器点", pri_gun_type[i], pri_gun_name[i], pri_gun_cost[i])
			num_to_str(i, szTempid, 31)
			menu_additem(menu, szItems, szTempid, 0)
		}
		
		menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
		menu_setprop(menu, MPROP_BACKNAME, "返回"); 
		menu_setprop(menu, MPROP_NEXTNAME, "更多..."); 
		menu_setprop(menu, MPROP_EXITNAME, "退出"); 
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		
		menu_display(id, menu, 0);
		return PLUGIN_HANDLED;
}

public fshop2_handler(id, menu, item)
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

	if(key <= (sizeof pri_gun_code - 1))
	{
		BuyFgun(id, key)
	}
	else 
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
}

public BuyFgun(id, wpnid)
{
	 if (!g_iForeverGun[id][wpnid])
	 {
		if (get_user_gp(id) >= pri_gun_cost[wpnid])
		{
			log_buy(id, wpnid)
			g_iForeverGun[id][wpnid] = 1
			set_user_gp(id, get_user_gp(id) - pri_gun_cost[wpnid])
			client_printc(id, "\g[永久商城] \t你己购买了 \y%s\t! 可到\y我的背包\t装备。", pri_gun_name[wpnid])
			client_print(id, print_console, "[FGUNSHOP] 你己購買了 %s !可到 我的背包 装备。", pri_gun_name[wpnid]) 
			savefguns(id)
		}
		else
		{
			client_printc(id, "\g[永久商城] \t你没有足够的\y 武器点 \t!!")
			client_print(id, print_console, "[FGUNSHOP] 你沒有足夠的武器點!!") 
		}
	 }
	 else
	 {
		client_printc(id, "\g[永久商城] \t你己拥有这把\y永久枪\t。")
		client_print(id, print_console, "[FGUNSHOP] 你己擁有該把永久槍。") 
	 }
}

public fshop_handgun(id)//永久商城副槍械(己列出例子)
{
		new menu = menu_create("\r永久商城 - 永久手枪", "fshop3_handler");
				
		new szTempid[32]
		for(new i = 1; i < sizeof sec_gun_code; i++)
		{
			new szItems[101]
			//\g[突击步枪]\y416-C Carbine     \g100 武器点
			formatex(szItems, 100, "\g%s\y%s     \g%d 武器点", sec_gun_type[i], sec_gun_name[i], sec_gun_cost[i])
			num_to_str(i, szTempid, 31)
			menu_additem(menu, szItems, szTempid, 0)
		}
		
		menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
		menu_setprop(menu, MPROP_BACKNAME, "返回"); 
		menu_setprop(menu, MPROP_NEXTNAME, "更多..."); 
		menu_setprop(menu, MPROP_EXITNAME, "退出"); 
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		
		menu_display(id, menu, 0);
		return PLUGIN_HANDLED;
}

public fshop3_handler(id, menu, item)
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

	if(key <= (sizeof sec_gun_code - 1))
	{
		BuyFHgun(id, key)
	}
	else 
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
}

public BuyFHgun(id, wpnid)
{
	 if (!g_iForeverHandGun[id][wpnid])
	 {
		if (get_user_gp(id) >= sec_gun_cost[wpnid])
		{
			log_buy(id, wpnid)
			g_iForeverHandGun[id][wpnid] = 1
			set_user_gp(id, get_user_gp(id) - sec_gun_cost[wpnid])
			client_printc(id, "\g[永久商城] \t你己购买了 \y%s\t! 可到\y我的背包\t装备。", pri_gun_name[wpnid])
			client_print(id, print_console, "[FGUNSHOP] 你己購買了 %s !可到 我的背包 装备。", pri_gun_name[wpnid]) 
			savefguns(id)
		}
		else
		{
			client_printc(id, "\g[永久商城] \t你没有足够的\y 武器点 \t!!")
			client_print(id, print_console, "[FGUNSHOP] 你沒有足夠的武器點!!") 
		}
	 }
	 else
	 {
		client_printc(id, "\g[永久商城] \t你己拥有这把\y永久枪\t。")
		client_print(id, print_console, "[FGUNSHOP] 你己擁有該把永久槍。") 
	 }
}

public fshop_other(id)//永久商城特殊物品(己列出例子)
{
		new menu = menu_create("\r永久商城 - 特殊物品", "fshop4_handler");
				
		menu_additem(menu, "不日推出", "1", 0);
		menu_additem(menu, "不日推出", "2", 0);
		menu_additem(menu, "不日推出", "3", 0);
		menu_additem(menu, "不日推出", "4", 0);
		menu_additem(menu, "不日推出^n", "5", 0);
		menu_additem(menu, "返回", "6", 0);
		
		menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
		menu_setprop(menu, MPROP_BACKNAME, "返回"); 
		menu_setprop(menu, MPROP_NEXTNAME, "更多..."); 
		menu_setprop(menu, MPROP_EXITNAME, "退出"); 
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		
		menu_display(id, menu, 0);
		return PLUGIN_HANDLED;
}

public fshop4_handler(id, menu, item)
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
	    		client_cmd(id, "buy_kara") //因這插件內裡用設定了所以直接控制台輸入
		}
		case 2:
		{
	    		client_cmd(id, "buy_suit") //因這插件內裡用設定了所以直接控制台輸入
		}
		case 3:
		{
		 if (!g_xD0625_ftg3[id])
		 {
			if (get_user_cash(id) >= get_cvar_num("fthing3_cost"))
			{
				g_xD0625_ftg3[id] = 1
				set_user_cash(id, get_user_cash(id) - get_cvar_num("fthing3_cost"))
				client_printc(id, "\g[永久商城] \t你己購買了 永久裝備 - \y-------\t! 可到\y我的背包\t裝備。")
				client_print(id, print_console, "[BossLevelS] 你己購買了 永久裝備 - -------!可到 我的背包 裝備。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\yCash\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的Cash!!") 
			}
		 }
		 else
		 {
			client_printc(id, "\g[永久商城] \t你己擁有該\y永久裝備\t。")
			client_print(id, print_console, "[BossLevelS] 你己擁有該永久裝備。") 
		 }
		}
		case 4:
		{
		 if (!g_xD0625_ftg4[id])
		 {
			if (get_user_cash(id) >= get_cvar_num("fthing4_cost"))
			{
				g_xD0625_ftg4[id] = 1
				set_user_cash(id, get_user_cash(id) - get_cvar_num("fthing4_cost"))
				client_printc(id, "\g[永久商城] \t你己購買了 永久裝備 - \y-------\t! 可到\y我的背包\t裝備。")
				client_print(id, print_console, "[BossLevelS] 你己購買了 永久裝備 - -------!可到 我的背包 裝備。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\yCash\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的Cash!!") 
			}
		 }
		 else
		 {
			client_printc(id, "\g[永久商城] \t你己擁有該\y永久裝備\t。")
			client_print(id, print_console, "[BossLevelS] 你己擁有該永久裝備。") 
		 }
		}
		case 5:
		{
		 if (!g_xD0625_ftg5[id])
		 {
			if (get_user_cash(id) >= get_cvar_num("fthing5_cost"))
			{
				g_xD0625_ftg5[id] = 1
				set_user_cash(id, get_user_cash(id) - get_cvar_num("fthing5_cost"))
				client_printc(id, "\g[永久商城] \t你己購買了 永久裝備 - \y-------\t! 可到\y我的背包\t裝備。")
				client_print(id, print_console, "[BossLevelS] 你己購買了 永久裝備 - -------!可到 我的背包 裝備。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\yCash\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的Cash!!") 
			}
		 }
		 else
		 {
			client_printc(id, "\g[永久商城] \t你己擁有該\y永久裝備\t。")
			client_print(id, print_console, "[BossLevelS] 你己擁有該永久裝備。") 
		 }
		}
		case 6:
		{
                        client_cmd(id, "fshopmenu")
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public myfg_menu(id)//裝備永久槍(己列出例子)
{
	if(g_iSelectPri[id])
	{
		client_printc(id, "\y[\g基地建设\y] 你已经选择过主武器了 !")
		return PLUGIN_HANDLED
	}

	static menu, option[64]
	
	// 416-C Carbine     \r　: \y　己购买
	menu = menu_create("\r装备永久枪", "my2_handler")
	new szTempid[32]
	for(new i = 1; i < sizeof pri_gun_code; i++)
	{
		new iSkin = g_iForeverGun[id][i]
		
		new szItems[101]
		formatex(szItems, 100, "%s     \r　: 　\y%s", pri_gun_name[i], is_bought_gun[iSkin])
		num_to_str(i, szTempid, 31)
		menu_additem(menu, szItems, szTempid, 0)
	}
	
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
	menu_setprop(menu, MPROP_BACKNAME, "返回"); 
	menu_setprop(menu, MPROP_NEXTNAME, "更多..."); 
	menu_setprop(menu, MPROP_EXITNAME, "退出"); 
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public my2_handler(id, menu, item)
{
	if(get_user_team(id) == 1)
		return PLUGIN_HANDLED

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

	if(key <= (sizeof pri_gun_code - 1))
	{
		EquipFGun(id, key)
	}
	else 
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
}

public EquipFGun(id, wpnid)
{
	switch(wpnid)
	{
		case 1:
		{
			if (g_iForeverGun[id][1])
			{
				client_printc(id, "\g[枪械选择] \t你装备了 \y416-C Carbine\t !")
				client_cmd(id, DEF_HK416_CODE)
				g_iSelectPri[id] = 1
			}
			else
			{
				client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
				client_printc(id, "\g[枪械选择] \t请先到\y 永久商城 \t购买 !!")
			}
		}
		case 2:
		{
			if (g_iForeverGun[id][2])
			{
				client_printc(id, "\g[枪械选择] \t你装备了 \yKriss Super V\t !")
				client_cmd(id, DEF_KRISS_CODE)
				g_iSelectPri[id] = 1
			}
			else
			{
				client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
				client_printc(id, "\g[枪械选择] \t请先到\y 永久商城 \t购买 !!")
			}
		}
		case 3:
		{
			if (g_iForeverGun[id][3])
			{
				client_printc(id, "\g[枪械选择] \t你装备了 \y爆炎蒸汽 SPSMG\t !")
				client_cmd(id, DEF_SPSMG_CODE)
				g_iSelectPri[id] = 1
			}
			else
			{
				client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
				client_printc(id, "\g[枪械选择] \t请先到\y 永久商城 \t购买 !!")
			}
		}
	}
}

public myfhg_menu(id)//裝備永久手槍(己列出例子)
{
	if(g_iSelectSec[id])
	{
		client_printc(id, "\y[\g基地建设\y] 你已经选择过副武器了 !")
		return PLUGIN_HANDLED
	}

	static menu, option[64]
	
	// 416-C Carbine     \r　: \y　己购买
	menu = menu_create("\r装备永久手枪", "my3_handler")
	new szTempid[32]
	for(new i = 1; i < sizeof sec_gun_code; i++)
	{
		new iSkin = g_iForeverHandGun[id][i]
		
		new szItems[101]
		formatex(szItems, 100, "%s     \r　: 　\y%s", sec_gun_name[i], is_bought_gun[iSkin])
		num_to_str(i, szTempid, 31)
		menu_additem(menu, szItems, szTempid, 0)
	}
	
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
	menu_setprop(menu, MPROP_BACKNAME, "返回"); 
	menu_setprop(menu, MPROP_NEXTNAME, "更多..."); 
	menu_setprop(menu, MPROP_EXITNAME, "退出"); 
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public my3_handler(id, menu, item)
{
	if(get_user_team(id) == 1)
		return PLUGIN_HANDLED

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

	if(key <= (sizeof pri_gun_code - 1))
	{
		EquipFHGun(id, key)
	}
	else 
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
}

public EquipFHGun(id, wpnid)
{
	switch(wpnid)
	{
		case 1:
		{
			if (g_iForeverHandGun[id][1])
			{
				client_printc(id, "\g[枪械选择] \t你装备了 \yFireCracker\t !")
				client_cmd(id, DEF_FIRECRACKER_CODE)
				g_iSelectSec[id] = 1
			}
			else
			{
				client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
				client_printc(id, "\g[枪械选择] \t请先到\y 永久商城 \t购买 !!")
			}
		}
	}
}

public myfo_menu(id)//裝備永久特殊物品(己列出例子)
{
	static menu, option[64]
	
	menu = menu_create("\r裝備永久物品", "my4_handler")
	if (g_xD0625_ftg1[id])
	{
		formatex(option, charsmax(option), "降魔劍-俱利加羅     \r　: \y　己購買")
		menu_additem(menu, option, "1", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "降魔劍-俱利加羅     \y　: \r　未購買")
		menu_additem(menu, option, "1", 0)	
	}
	if (g_xD0625_ftg2[id])
	{
		formatex(option, charsmax(option), "DeadSpace Suit裝甲 \r　: \y　己購買")
		menu_additem(menu, option, "2", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "DeadSpace Suit裝甲 \y　: \r　未購買")
		menu_additem(menu, option, "2", 0)	
	}
	if (g_xD0625_ftg3[id])
	{
		formatex(option, charsmax(option), "-------  \r　: \y　己購買")
		menu_additem(menu, option, "3", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------  \y　: \r　未購買")
		menu_additem(menu, option, "3", 0)	
	}
	if (g_xD0625_ftg4[id])
	{
		formatex(option, charsmax(option), "-------  \r　: \y　己購買")
		menu_additem(menu, option, "4", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------  \y　: \r　未購買")
		menu_additem(menu, option, "4", 0)	
	}
	if (g_xD0625_ftg5[id])
	{
		formatex(option, charsmax(option), "-------  \r　: \y　己購買^n")
		menu_additem(menu, option, "5", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------  \y　: \r　未購買^n")
		menu_additem(menu, option, "5", 0)	
	}
	menu_additem(menu, "返回", "6", 0);
	
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
	menu_setprop(menu, MPROP_BACKNAME, "返回"); 
	menu_setprop(menu, MPROP_NEXTNAME, "更多..."); 
	menu_setprop(menu, MPROP_EXITNAME, "退出"); 
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public my4_handler(id, menu, item)
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
	    		client_cmd(id, "use_kara")
                        myfo_menu(id)
		}
		case 2:
		{
	    		client_cmd(id, "use_suit")
                        myfo_menu(id)
		}
		case 3:
		{
		if (g_xD0625_ftg3[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 \y-----\t!")
	    		client_cmd(id, "")
	    		myfo_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 4:
		{
		if (g_xD0625_ftg4[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 \y-----\t!")
	    		client_cmd(id, "")
	    		myfo_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 5:
		{
		if (g_xD0625_ftg5[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 \y-----\t!")
	    		client_cmd(id, "")
	    		myfo_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 6:
		{
                        client_cmd(id, "mymenu")
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public vip_menu(id) //VIP專區(有一個示範)
{
		new menu = menu_create("\rVIP專區", "vip_handler");
				
		menu_additem(menu, "\y等離子步槍-Plasma", "1", ADMIN_RESERVATION);
		menu_additem(menu, "\y激光劍", "2", ADMIN_RESERVATION);
		menu_additem(menu, "\y『即將推出模組(暫無)』^n", "3", ADMIN_RESERVATION);
		menu_additem(menu, "返回主目錄", "4", 0);
		
		menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
		menu_setprop(menu, MPROP_BACKNAME, "返回"); 
		menu_setprop(menu, MPROP_NEXTNAME, "更多..."); 
		menu_setprop(menu, MPROP_EXITNAME, "退出"); 
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		
		menu_display(id, menu, 0);
		return PLUGIN_HANDLED;
}

public vip_handler(id, menu, item)
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
	    		client_cmd(id, "use_pa") //因這插件內裡用設定了權限所以直接控制台輸入
	    		vip_menu(id)
		}
		case 2:
		{
                        client_cmd(id, "use_me") //因這插件內裡用設定了權限所以直接控制台輸入
	    		vip_menu(id)
		}
		case 3:
		{
                        if(get_user_flags(id) & ADMIN_RESERVATION)
                        {
                         client_cmd(id, "")
                         client_printc(id, "\g[VIP專區] \t你選擇了模組 \y『暫時無模組』\t!。")
                         vip_menu(id)
                        }
                        else
                        {
                         client_print(id, print_console, "[BossLevelS] You are not VIP or Admin!!") 
                         client_printc(id, "\g[VIP專區] \t你不是\yVIP / Admin\t!!")
                        }
		}
		case 4:
		{
                        client_cmd(id, "say /boss_menu")
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public native_get_user_fthing1(id)  //永久物品1
{
    return g_xD0625_ftg1[id]
}

public native_set_user_fthing1(id, amount)  //永久物品1
{
    g_xD0625_ftg1[id] = amount
    return g_xD0625_ftg1[id]
}

public native_get_user_fthing2(id)  //永久物品2
{
    return g_xD0625_ftg2[id]
}

public native_set_user_fthing2(id, amount)  //永久物品2
{
    g_xD0625_ftg2[id] = amount
    return g_xD0625_ftg2[id]
}

public savefguns(id) 
{
 SaveDatafgun(id)
} 

public client_disconnect(id) 
{
	g_iSelectPri[id] = 0
	g_iSelectSec[id] = 0
	
	for(new i=1;i<sizeof pri_gun_code;i++)
	{
		g_iForeverGun[id][i] = 0
	}
	
	for(new i=1;i<sizeof sec_gun_code;i++)
	{
		g_iForeverHandGun[id][i] = 0
	}
}

public client_putinserver(id)
{
	for(new i=1;i<sizeof pri_gun_code;i++)
	{
		g_iForeverGun[id][i] = 0
	}
	
	for(new i=1;i<sizeof sec_gun_code;i++)
	{
		g_iForeverHandGun[id][i] = 0
	}
	LoadDatafgun(id)
	g_iSelectPri[id] = 0
	g_iSelectSec[id] = 0
}

public saveguns(id)
{
	SaveDatafgun(id)
}

public SaveDatafgun(id) //儲存永久物品資料
{ 
	new wjsl = get_playersnum(0)
	if(wjsl < 4)
	{
		client_printc(id, "\t由于玩家数量小于 4 人, 你的武器数据不会被保存.")
		return PLUGIN_HANDLED
	}

	new authid[32]
	get_user_name(id, authid, 31)
	replace_all(authid, 32, "`", "\`")
	replace_all(authid, 32, "'", "\'")
	
	for(new i=1;i<sizeof pri_gun_code;i++)
	{
		dbi_query(sql, "UPDATE bb_weapons SET %s='%d' WHERE name = '%s'", pri_gun_code[i], g_iForeverGun[id][i], authid)
	}
	
	for(new i=1;i<sizeof sec_gun_code;i++)
	{
		dbi_query(sql, "UPDATE bb_weapons_sec SET %s='%d' WHERE name = '%s'", sec_gun_code[i], g_iForeverHandGun[id][i], authid)
	}
	
	return PLUGIN_CONTINUE
} 

public LoadDatafgun(id) //載入永久物品資料
{ 
	LoadPriFGun(id)
	LoadSecFGun(id)
}

public LoadPriFGun(id)
{
	new authid[32] 
	get_user_name(id,authid,31)
	replace_all(authid, 32, "`", "\`")
	replace_all(authid, 32, "'", "\'")

	result = dbi_query(sql, "SELECT hk416,kriss,spsmg FROM bb_weapons WHERE name='%s'", authid)

	if(result == RESULT_NONE)
	{
	dbi_query(sql, "INSERT INTO bb_weapons(name,hk416,kriss,spsmg) VALUES('%s','0','0','0')", authid)
	}
	else if(result <= RESULT_FAILED)
	{
		server_print("[FGunShop] SQL Init error. (Load)")
	}
	else
	{
		for(new i=1;i<sizeof pri_gun_code;i++)
		{
			g_iForeverGun[id][i] = dbi_field(result, i)
		}
		dbi_free_result(result)
	}
}

public LoadSecFGun(id)
{
	new authid[32] 
	get_user_name(id,authid,31)
	replace_all(authid, 32, "`", "\`")
	replace_all(authid, 32, "'", "\'")

	result = dbi_query(sql, "SELECT firecracker FROM bb_weapons_sec WHERE name='%s'", authid)

	if(result == RESULT_NONE)
	{
	dbi_query(sql, "INSERT INTO bb_weapons_sec(name,firecracker) VALUES('%s','0')", authid)
	}
	else if(result <= RESULT_FAILED)
	{
		server_print("[FGunShop] SQL Init error. (Load)")
	}
	else
	{
		for(new i=1;i<sizeof sec_gun_code;i++)
		{
			g_iForeverHandGun[id][i] = dbi_field(result, i)
		}
		dbi_free_result(result)
	}
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

public log_buy(id, wpnid)
{
	new name[33]
	get_user_name(id,name,31)
	
	log_to_file(log_file, " %s 购买武器 - 武器代号 [%d]", name, wpnid)
}