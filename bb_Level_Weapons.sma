#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <dbi>
#include <fakemeta>
#include <hamsandwich>
#include <eg_boss>

#define PLUGIN "[BB] 永久商城"
#define VERSION "S1v2"
#define AUTHOR "EmeraldGhost"

//SQL variable
new Sql:sql
new Result:result
new error[33]

new const is_bought_gun[][] = { "未购买", "已购买" }
new const gun_type[][] = { "null", "[突击步枪]", "[冲锋枪]" }
new const gun_name[][] = { "null", "416-C Carbine", "Kriss Super V" }
new const gun_cost[] = { 0, 100, 100 }
new const gun_code[][] = { "null", "hk416", "kriss"}

new const log_file[] = "BB_FGunBuyLog.txt"

new g_iSelectPri[33]

//永久槍代數
new g_iForeverGun[33][sizeof gun_code]

//永久手槍代數(目前十項,如有更多請按照這樣再增加,不慬的話請告訴我)
new g_xD0625_fhgun1[33], g_xD0625_fhgun2[33], g_xD0625_fhgun3[33], g_xD0625_fhgun4[33], g_xD0625_fhgun5[33], g_xD0625_fhgun6[33], g_xD0625_fhgun7[33], g_xD0625_fhgun8[33], g_xD0625_fhgun9[33], g_xD0625_fhgun10[33]

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

public plugin_natives()  //註冊獨有指令INC(這裡我只加了我5樣永久物品,有需要自行增加,用來防止按~指令拿槍)
{
    register_native("get_user_fgun1", "native_get_user_fgun1", 1)
    register_native("set_user_fgun1", "native_set_user_fgun1", 1)
    register_native("get_user_fgun2", "native_get_user_fgun2", 1)
    register_native("set_user_fgun2", "native_set_user_fgun2", 1)
    register_native("get_user_fgun3","native_get_user_fgun3", 1)
    register_native("set_user_fgun3","native_set_user_fgun3", 1)
    register_native("get_user_fgun4","native_get_user_fgun4", 1)
    register_native("set_user_fgun4","native_set_user_fgun4", 1)
    register_native("get_user_fgun5","native_get_user_fgun5", 1)
    register_native("set_user_fgun5","native_set_user_fgun5", 1)
    register_native("get_user_fgun6","native_get_user_fgun6", 1)
    register_native("set_user_fgun6","native_set_user_fgun6", 1)
    register_native("get_user_fgun7", "native_get_user_fgun7", 1)
    register_native("set_user_fgun7", "native_set_user_fgun7", 1)
    register_native("get_user_fgun8", "native_get_user_fgun8", 1)
    register_native("set_user_fgun8", "native_set_user_fgun8", 1)
    register_native("get_user_fgun9", "native_get_user_fgun9", 1)
    register_native("set_user_fgun9", "native_set_user_fgun9", 1)
    register_native("get_user_fgun10", "native_get_user_fgun10", 1)
    register_native("set_user_fgun10", "native_set_user_fgun10", 1)
    register_native("get_user_fgun11", "native_get_user_fgun11", 1)
    register_native("set_user_fgun11", "native_set_user_fgun11", 1)
    register_native("get_user_fhgun1", "native_get_user_fhgun1", 1)
    register_native("set_user_fhgun1", "native_set_user_fhgun1", 1)
    register_native("get_user_fhgun2", "native_get_user_fhgun2", 1)
    register_native("set_user_fhgun2", "native_set_user_fhgun2", 1)
    register_native("get_user_fhgun3", "native_get_user_fhgun3", 1)
    register_native("set_user_fhgun3", "native_set_user_fhgun3", 1)
    register_native("get_user_fhgun4", "native_get_user_fhgun4", 1)
    register_native("set_user_fhgun4", "native_set_user_fhgun4", 1)
    register_native("get_user_fhgun5", "native_get_user_fhgun5", 1)
    register_native("set_user_fhgun5", "native_set_user_fhgun5", 1)
    register_native("get_user_ftg1", "native_get_user_fthing1", 1)
    register_native("set_user_ftg1", "native_set_user_fthing1", 1)
    register_native("get_user_ftg2", "native_get_user_fthing2", 1)
    register_native("set_user_ftg2", "native_set_user_fthing2", 1)
}

public ham_PlayerSpawn_Post(id)
{
	g_iSelectPri[id] = 0
}

public fshop_gun(id) //永久商城主槍械(己列出例子)
{
		new menu = menu_create("\r永久商城 - 永久枪", "fshop2_handler");
				
		new szTempid[32]
		for(new i = 1; i < sizeof gun_code; i++)
		{
			new szItems[101]
			//\g[突击步枪]\y416-C Carbine     \g100 武器点
			formatex(szItems, 100, "\g%s\y%s     \g%d 武器点", gun_type[i], gun_name[i], gun_cost[i])
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

	if(key <= (sizeof gun_code - 1))
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
		if (get_user_gp(id) >= gun_cost[wpnid])
		{
			log_buy(id, 1)
			g_iForeverGun[id][wpnid] = 1
			set_user_gp(id, get_user_gp(id) - gun_cost[wpnid])
			client_printc(id, "\g[永久商城] \t你己购买了 \y%s\t! 可到\y我的背包\t装备。", gun_name[wpnid])
			client_print(id, print_console, "[FGUNSHOP] 你己購買了 %s !可到 我的背包 装备。", gun_name[wpnid]) 
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
		new menu = menu_create("\r永久商城 - 手槍", "fshop3_handler");
				
		menu_additem(menu, "不日推出", "1", 0);
		menu_additem(menu, "不日推出", "2", 0);
		menu_additem(menu, "不日推出", "3", 0);
		menu_additem(menu, "不日推出", "4", 0);
		menu_additem(menu, "不日推出", "5", 0);
		menu_additem(menu, "不日推出", "6", 0);
		menu_additem(menu, "不日推出", "7", 0);
		menu_additem(menu, "不日推出", "8", 0);
		menu_additem(menu, "不日推出", "9", 0);
		menu_additem(menu, "不日推出^n", "10", 0);
		menu_additem(menu, "返回", "11", 0);
		
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

	
	switch(key)
	{
		case 1:
		{
	    		client_cmd(id, "buy_bullz") //因這插件內裡用設定了所以直接控制台輸入
		}
		case 2:
		{
		 if (!g_xD0625_fhgun2[id])
		 {
			if (get_user_cash(id) >= get_cvar_num("fhgun2_cost"))
			{
				g_xD0625_fhgun2[id] = 1
				set_user_cash(id, get_user_cash(id) - get_cvar_num("fhgun2_cost"))
				client_printc(id, "\g[永久商城] \t你己購買了 \y神怒之炎\t! 可到\y我的背包\t裝備。")
				client_print(id, print_console, "[BossLevelS] 你己購買了 神怒之炎!可到 我的背包 裝備。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\yCash\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的Cash!!") 
			}
		 }
		 else
		 {
			client_printc(id, "\g[永久商城] \t你己擁有該把\y永久槍\t。")
			client_print(id, print_console, "[BossLevelS] 你己擁有該把永久槍。") 
		 }
		}
		case 3:
		{
		 if (!g_xD0625_fhgun3[id])
		 {
			if (get_user_cash(id) >= get_cvar_num("fhgun3_cost"))
			{
				g_xD0625_fhgun3[id] = 1
				set_user_cash(id, get_user_cash(id) - get_cvar_num("fhgun3_cost"))
				client_printc(id, "\g[永久商城] \t你己購買了 \y眼鏡王蛇-KingCobra\t! 可到\y我的背包\t裝備。")
				client_print(id, print_console, "[BossLevelS] 你己購買了 眼鏡王蛇-KingCobra!可到 我的背包 裝備。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\yCash\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的Cash!!") 
			}
		 }
		 else
		 {
			client_printc(id, "\g[永久商城] \t你己擁有該把\y永久槍\t。")
			client_print(id, print_console, "[BossLevelS] 你己擁有該把永久槍。") 
		 }
		}
		case 4:
		{
		 if (!g_xD0625_fhgun4[id])
		 {
			if (get_user_cash(id) >= get_cvar_num("fhgun4_cost"))
			{
				g_xD0625_fhgun4[id] = 1
				set_user_cash(id, get_user_cash(id) - get_cvar_num("fhgun4_cost"))
				client_printc(id, "\g[永久商城] \t你己購買了 永久槍 - \y-------\t! 可到\y我的背包\t裝備。")
				client_print(id, print_console, "[BossLevelS] 你己購買了 永久槍 - -------!可到 我的背包 裝備。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\yCash\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的Cash!!") 
			}
		 }
		 else
		 {
			client_printc(id, "\g[永久商城] \t你己擁有該把\y永久槍\t。")
			client_print(id, print_console, "[BossLevelS] 你己擁有該把永久槍。") 
		 }
		}
		case 5:
		{
		 if (!g_xD0625_fhgun5[id])
		 {
			if (get_user_cash(id) >= get_cvar_num("fhgun5_cost"))
			{
				g_xD0625_fhgun5[id] = 1
				set_user_cash(id, get_user_cash(id) - get_cvar_num("fhgun5_cost"))
				client_printc(id, "\g[永久商城] \t你己購買了 \y神器 - 雙持夜鷹\t! 可到\y我的背包\t裝備。")
				client_print(id, print_console, "[BossLevelS] 你己購買了 神器 - 雙持夜鷹!可到 我的背包 裝備。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\yCash\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的Cash!!") 
			}
		 }
		 else
		 {
			client_printc(id, "\g[永久商城] \t你己擁有該把\y永久槍\t。")
			client_print(id, print_console, "[BossLevelS] 你己擁有該把永久槍。") 
		 }
		}
		case 6:
		{
		 if (!g_xD0625_fhgun6[id])
		 {
			if (get_user_cash(id) >= get_cvar_num("fhgun6_cost"))
			{
				g_xD0625_fhgun6[id] = 1
				set_user_cash(id, get_user_cash(id) - get_cvar_num("fhgun6_cost"))
				client_printc(id, "\g[永久商城] \t你己購買了 永久槍 - \y-------\t! 可到\y我的背包\t裝備。")
				client_print(id, print_console, "[BossLevelS] 你己購買了 永久槍 - -------!可到 我的背包 裝備。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\yCash\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的Cash!!") 
			}
		 }
		 else
		 {
			client_printc(id, "\g[永久商城] \t你己擁有該把\y永久槍\t。")
			client_print(id, print_console, "[BossLevelS] 你己擁有該把永久槍。") 
		 }
		}
		case 7:
		{
		 if (!g_xD0625_fhgun7[id])
		 {
			if (get_user_cash(id) >= get_cvar_num("fhgun7_cost"))
			{
				g_xD0625_fhgun7[id] = 1
				set_user_cash(id, get_user_cash(id) - get_cvar_num("fhgun7_cost"))
				client_printc(id, "\g[永久商城] \t你己購買了 永久槍 - \y-------\t! 可到\y我的背包\t裝備。")
				client_print(id, print_console, "[BossLevelS] 你己購買了 永久槍 - -------!可到 我的背包 裝備。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\yCash\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的Cash!!") 
			}
		 }
		 else
		 {
			client_printc(id, "\g[永久商城] \t你己擁有該把\y永久槍\t。")
			client_print(id, print_console, "[BossLevelS] 你己擁有該把永久槍。") 
		 }
		}
		case 8:
		{
		 if (!g_xD0625_fhgun8[id])
		 {
			if (get_user_cash(id) >= get_cvar_num("fhgun8_cost"))
			{
				g_xD0625_fhgun8[id] = 1
				set_user_cash(id, get_user_cash(id) - get_cvar_num("fhgun8_cost"))
				client_printc(id, "\g[永久商城] \t你己購買了 永久槍 - \y-------\t! 可到\y我的背包\t裝備。")
				client_print(id, print_console, "[BossLevelS] 你己購買了 永久槍 - -------!可到 我的背包 裝備。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\yCash\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的Cash!!") 
			}
		 }
		 else
		 {
			client_printc(id, "\g[永久商城] \t你己擁有該把\y永久槍\t。")
			client_print(id, print_console, "[BossLevelS] 你己擁有該把永久槍。") 
		 }
		}
		case 9:
		{
		 if (!g_xD0625_fhgun9[id])
		 {
			if (get_user_cash(id) >= get_cvar_num("fhgun9_cost"))
			{
				g_xD0625_fhgun9[id] = 1
				set_user_cash(id, get_user_cash(id) - get_cvar_num("fhgun9_cost"))
				client_printc(id, "\g[永久商城] \t你己購買了 永久槍 - \y-------\t! 可到\y我的背包\t裝備。")
				client_print(id, print_console, "[BossLevelS] 你己購買了 永久槍 - -------!可到 我的背包 裝備。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\yCash\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的Cash!!") 
			}
		 }
		 else
		 {
			client_printc(id, "\g[永久商城] \t你己擁有該把\y永久槍\t。")
			client_print(id, print_console, "[BossLevelS] 你己擁有該把永久槍。") 
		 }
		}
		case 10:
		{
		 if (!g_xD0625_fhgun10[id])
		 {
			if (get_user_cash(id) >= get_cvar_num("fhgun10_cost"))
			{
				g_xD0625_fhgun10[id] = 1
				set_user_cash(id, get_user_cash(id) - get_cvar_num("fhgun10_cost"))
				client_printc(id, "\g[永久商城] \t你己購買了 永久槍 - \y-------\t! 可到\y我的背包\t裝備。")
				client_print(id, print_console, "[BossLevelS] 你己購買了 永久槍 - -------!可到 我的背包 裝備。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\yCash\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的Cash!!") 
			}
		 }
		 else
		 {
			client_printc(id, "\g[永久商城] \t你己擁有該把\y永久槍\t。")
			client_print(id, print_console, "[BossLevelS] 你己擁有該把永久槍。") 
		 }
		}
		case 11:
		{
                        client_cmd(id, "fshopmenu")
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
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
	menu = menu_create("\r裝備永久槍", "my2_handler")
	new szTempid[32]
	for(new i = 1; i < sizeof gun_code; i++)
	{
		new iSkin = g_iForeverGun[id][i]
		
		new szItems[101]
		formatex(szItems, 100, "%s     \r　: 　\y%s", gun_name[i], is_bought_gun[iSkin])
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

	if(key <= (sizeof gun_code - 1))
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
	}
}

public myfhg_menu(id)//裝備永久手槍(己列出例子)
{
	static menu, option[64]
	
	menu = menu_create("\r裝備永久手槍", "my3_handler")
	if (g_xD0625_fhgun1[id])
	{
		formatex(option, charsmax(option), "雙持左輪-bullz \r　: \y　己購買")
		menu_additem(menu, option, "1", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "雙持左輪-bullz \y　: \r　未購買")
		menu_additem(menu, option, "1", 0)	
	}
	if (g_xD0625_fhgun2[id])
	{
		formatex(option, charsmax(option), "神怒之炎  \r　: \y　己購買")
		menu_additem(menu, option, "2", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "神怒之炎  \y　: \r　未購買")
		menu_additem(menu, option, "2", 0)	
	}
	if (g_xD0625_fhgun3[id])
	{
		formatex(option, charsmax(option), "眼鏡王蛇-KingCobra  \r　: \y　己購買")
		menu_additem(menu, option, "3", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "眼鏡王蛇-KingCobra  \y　: \r　未購買")
		menu_additem(menu, option, "3", 0)	
	}
	if (g_xD0625_fhgun4[id])
	{
		formatex(option, charsmax(option), "-------  \r　: \y　己購買")
		menu_additem(menu, option, "4", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------  \y　: \r　未購買")
		menu_additem(menu, option, "4", 0)	
	}
	if (g_xD0625_fhgun5[id])
	{
		formatex(option, charsmax(option), "神器-雙持夜鷹  \r　: \y　己購買")
		menu_additem(menu, option, "5", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "神器-雙持夜鷹  \y　: \r　未購買")
		menu_additem(menu, option, "5", 0)	
	}
	if (g_xD0625_fhgun6[id])
	{
		formatex(option, charsmax(option), "-------  \r　: \y　己購買")
		menu_additem(menu, option, "6", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------  \y　: \r　未購買")
		menu_additem(menu, option, "6", 0)	
	}
	if (g_xD0625_fhgun7[id])
	{
		formatex(option, charsmax(option), "-------  \r　: \y　己購買")
		menu_additem(menu, option, "7", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------  \y　: \r　未購買")
		menu_additem(menu, option, "7", 0)	
	}
	if (g_xD0625_fhgun8[id])
	{
		formatex(option, charsmax(option), "-------  \r　: \y　己購買")
		menu_additem(menu, option, "8", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------  \y　: \r　未購買")
		menu_additem(menu, option, "8", 0)	
	}
	if (g_xD0625_fhgun9[id])
	{
		formatex(option, charsmax(option), "-------  \r　: \y　己購買")
		menu_additem(menu, option, "9", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------  \y　: \r　未購買")
		menu_additem(menu, option, "9", 0)	
	}
	if (g_xD0625_fhgun10[id])
	{
		formatex(option, charsmax(option), "-------  \r　: \y　己購買^n")
		menu_additem(menu, option, "10", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------  \y　: \r　未購買^n")
		menu_additem(menu, option, "10", 0)	
	}
	menu_additem(menu, "返回", "11", 0);

	
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
	    		client_cmd(id, "use_bullz")
                        myfhg_menu(id)
		}
		case 2:
		{
		if (g_xD0625_fhgun2[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 \y神怒之炎\t!")
	    		client_cmd(id, "SNZYaa12345678900")
	    		myfhg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 3:
		{
		if (g_xD0625_fhgun3[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 \y眼鏡王蛇-KingCobra\t!")
	    		client_cmd(id, "KingCobraAA12345678900")
	    		myfhg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 4:
		{
		if (g_xD0625_fhgun4[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 永久槍 - \y-----\t!")
	    		client_cmd(id, "")
	    		myfhg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 5:
		{
		if (g_xD0625_fhgun5[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 \y神器-雙持夜鷹\t!")
	    		client_cmd(id, "")
	    		myfhg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 6:
		{
		if (g_xD0625_fhgun6[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 永久槍 - \y-----\t!")
	    		client_cmd(id, "")
	    		myfhg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 7:
		{
		if (g_xD0625_fhgun7[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 永久槍 - \y-----\t!")
	    		client_cmd(id, "")
	    		myfhg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 8:
		{
		if (g_xD0625_fhgun8[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 永久槍 - \y-----\t!")
	    		client_cmd(id, "")
	    		myfhg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 9:
		{
		if (g_xD0625_fhgun9[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 永久槍 - \y-----\t!")
	    		client_cmd(id, "")
	    		myfhg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 10:
		{
		if (g_xD0625_fhgun10[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 永久槍 - \y-----\t!")
	    		client_cmd(id, "")
	    		myfhg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 11:
		{
                        client_cmd(id, "mymenu")
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
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

public native_get_user_fhgun1(id)  //永久手槍1
{
    return g_xD0625_fhgun1[id]
}

public native_set_user_fhgun1(id, amount)  //永久手槍1
{
    g_xD0625_fhgun1[id] = amount
    return g_xD0625_fhgun1[id]
}

public native_get_user_fhgun2(id)  //永久手槍2
{
    return g_xD0625_fhgun2[id]
}

public native_set_user_fhgun2(id, amount)  //永久手槍2
{
    g_xD0625_fhgun2[id] = amount
    return g_xD0625_fhgun2[id]
}

public native_get_user_fhgun3(id)  //永久手槍3
{
    return g_xD0625_fhgun3[id]
}

public native_set_user_fhgun3(id, amount)  //永久手槍3
{
    g_xD0625_fhgun3[id] = amount
    return g_xD0625_fhgun3[id]
}

public native_get_user_fhgun5(id)  //永久手槍5
{
    return g_xD0625_fhgun5[id]
}

public native_set_user_fhgun5(id, amount)  //永久手槍5
{
    g_xD0625_fhgun5[id] = amount
    return g_xD0625_fhgun5[id]
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
 SaveDatafgun(id)
 g_iSelectPri[id] = 0
 
		for(new i=1;i<sizeof gun_code;i++)
		{
			g_iForeverGun[id][i] = 0
		}
}

public client_putinserver(id)
{
		for(new i=1;i<sizeof gun_code;i++)
		{
			g_iForeverGun[id][i] = 0
		}
 LoadDatafgun(id)
 g_iSelectPri[id] = 0
}

public saveguns(id)
{
 SaveDatafgun(id)
}

public SaveDatafgun(id) //儲存永久物品資料
{ 
/*
  new name[35], fvaultkey[64], fvaultdata[256]
              
  get_user_name(id, name, 34) 
  
  format(fvaultkey, 63, "%s-Fgun", name) 

  format(fvaultdata, 255, "%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#", g_xD0625_fgun1[id], g_xD0625_fgun2[id], g_xD0625_fgun3[id], g_xD0625_fgun4[id], g_xD0625_fgun5[id],

  g_xD0625_fgun6[id], g_xD0625_fgun7[id], g_xD0625_fgun8[id], g_xD0625_fgun9[id], g_xD0625_fgun10[id], g_xD0625_fgun11[id], g_xD0625_fgun12[id], g_xD0625_fgun13[id], g_xD0625_fgun14[id], g_xD0625_fgun15[id], g_xD0625_fgun16[id],

  g_xD0625_fgun17[id], g_xD0625_fgun18[id], g_xD0625_fgun19[id], g_xD0625_fgun20[id], g_xD0625_fhgun1[id], g_xD0625_fhgun2[id], g_xD0625_fhgun3[id], g_xD0625_fhgun4[id], g_xD0625_fhgun5[id], g_xD0625_fhgun6[id], g_xD0625_fhgun7[id], g_xD0625_fhgun8[id], g_xD0625_fhgun9[id], g_xD0625_fhgun10[id],

  g_xD0625_ftg1[id], g_xD0625_ftg2[id], g_xD0625_ftg3[id], g_xD0625_ftg4[id], g_xD0625_ftg5[id])

  nvault_set(g_fvault, fvaultkey, fvaultdata) 
*/

	new authid[32]
	get_user_name(id, authid, 31)
	replace_all(authid, 32, "`", "\`")
	replace_all(authid, 32, "'", "\'")
	
	for(new i=1;i<sizeof gun_code;i++)
	{
		dbi_query(sql, "UPDATE bb_weapons SET %s='%d' WHERE name = '%s'", gun_code[i], g_iForeverGun[id][i], authid)
	}
	
	return PLUGIN_CONTINUE
} 

public LoadDatafgun(id) //載入永久物品資料
{ 
/*
  new name[35], fvaultkey[64], fvaultdata[256]
  get_user_name(id,name,34) 
             
  format(fvaultkey, 63, "%s-Fgun", name) 

  format(fvaultdata, 255, "%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#", g_xD0625_fgun1[id], g_xD0625_fgun2[id], g_xD0625_fgun3[id], g_xD0625_fgun4[id], g_xD0625_fgun5[id],

  g_xD0625_fgun6[id], g_xD0625_fgun7[id], g_xD0625_fgun8[id], g_xD0625_fgun9[id], g_xD0625_fgun10[id], g_xD0625_fgun11[id], g_xD0625_fgun12[id], g_xD0625_fgun13[id], g_xD0625_fgun14[id], g_xD0625_fgun15[id], g_xD0625_fgun16[id],

  g_xD0625_fgun17[id], g_xD0625_fgun18[id], g_xD0625_fgun19[id], g_xD0625_fgun20[id], g_xD0625_fhgun1[id], g_xD0625_fhgun2[id], g_xD0625_fhgun3[id], g_xD0625_fhgun4[id], g_xD0625_fhgun5[id], g_xD0625_fhgun6[id], g_xD0625_fhgun7[id], g_xD0625_fhgun8[id], g_xD0625_fhgun9[id], g_xD0625_fhgun10[id],

  g_xD0625_ftg1[id], g_xD0625_ftg2[id], g_xD0625_ftg3[id], g_xD0625_ftg4[id], g_xD0625_ftg5[id])

  nvault_get(g_fvault, fvaultkey, fvaultdata, 255)

  replace_all(fvaultdata, 255, "#", " ") 

  new player_f1[32], player_f2[32], player_f3[32], player_f4[32], player_f5[32], player_f6[32], player_f7[32],

  player_f8[32], player_f9[32], player_f10[32], player_f11[32], player_f12[32], player_f13[32], player_f14[32],

  player_f15[32], player_f16[32], player_f17[32], player_f18[32], player_f19[32], player_f20[32],

  player_fh1[32], player_fh2[32], player_fh3[32], player_fh4[32], player_fh5[32], player_fh6[32], player_fh7[32], player_fh8[32], player_fh9[32], player_fh10[32],

  player_ftg1[32], player_ftg2[32], player_ftg3[32], player_ftg4[32], player_ftg5[32]
  
  parse(fvaultdata, player_f1, 31 , player_f2, 31 , player_f3, 31 , player_f4, 31 , player_f5, 31 , player_f6, 31 , player_f7, 31 ,

  player_f8, 31 , player_f9, 31 , player_f10, 31 , player_f11, 31 , player_f12, 31 , player_f13, 31 , player_f14, 31 , player_f15, 31 ,

  player_f16, 31 , player_f17, 31 , player_f18, 31 , player_f19, 31 , player_f20, 31 ,

  player_fh1, 31 , player_fh2, 31 , player_fh3, 31 , player_fh4, 31 , player_fh5, 31 , player_fh6, 31 , player_fh7, 31 , player_fh8, 31 , player_fh9, 31 , player_fh10, 31 ,

  player_ftg1, 31 , player_ftg2, 31 , player_ftg3, 31 , player_ftg4, 31 , player_ftg5, 31)

  g_xD0625_fgun1[id] = str_to_num(player_f1)
  g_xD0625_fgun2[id] = str_to_num(player_f2)
  g_xD0625_fgun3[id] = str_to_num(player_f3)
  g_xD0625_fgun4[id] = str_to_num(player_f4)
  g_xD0625_fgun5[id] = str_to_num(player_f5)
  g_xD0625_fgun6[id] = str_to_num(player_f6)
  g_xD0625_fgun7[id] = str_to_num(player_f7)
  g_xD0625_fgun8[id] = str_to_num(player_f8)
  g_xD0625_fgun9[id] = str_to_num(player_f9)
  g_xD0625_fgun10[id] = str_to_num(player_f10)
  g_xD0625_fgun11[id] = str_to_num(player_f11)
  g_xD0625_fgun12[id] = str_to_num(player_f12)
  g_xD0625_fgun13[id] = str_to_num(player_f13)
  g_xD0625_fgun14[id] = str_to_num(player_f14)
  g_xD0625_fgun15[id] = str_to_num(player_f15)
  g_xD0625_fgun16[id] = str_to_num(player_f16)
  g_xD0625_fgun17[id] = str_to_num(player_f17)
  g_xD0625_fgun18[id] = str_to_num(player_f18)
  g_xD0625_fgun19[id] = str_to_num(player_f19)
  g_xD0625_fgun20[id] = str_to_num(player_f20)
  g_xD0625_fhgun1[id] = str_to_num(player_fh1)
  g_xD0625_fhgun2[id] = str_to_num(player_fh2)
  g_xD0625_fhgun3[id] = str_to_num(player_fh3)
  g_xD0625_fhgun4[id] = str_to_num(player_fh4)
  g_xD0625_fhgun5[id] = str_to_num(player_fh5)
  g_xD0625_fhgun6[id] = str_to_num(player_fh6)
  g_xD0625_fhgun7[id] = str_to_num(player_fh7)
  g_xD0625_fhgun8[id] = str_to_num(player_fh8)
  g_xD0625_fhgun9[id] = str_to_num(player_fh9)
  g_xD0625_fhgun10[id] = str_to_num(player_fh10)
  g_xD0625_ftg1[id] = str_to_num(player_ftg1)
  g_xD0625_ftg2[id] = str_to_num(player_ftg2)
  g_xD0625_ftg3[id] = str_to_num(player_ftg3)
  g_xD0625_ftg4[id] = str_to_num(player_ftg4)
  g_xD0625_ftg5[id] = str_to_num(player_ftg5)

  return PLUGIN_CONTINUE
  */
  
	new authid[32] 
	get_user_name(id,authid,31)
	replace_all(authid, 32, "`", "\`")
	replace_all(authid, 32, "'", "\'")

	result = dbi_query(sql, "SELECT hk416,kriss FROM bb_weapons WHERE name='%s'", authid)

	if(result == RESULT_NONE)
	{
	dbi_query(sql, "INSERT INTO bb_weapons(name,hk416,kriss) VALUES('%s','0','0')", authid)
	}
	else if(result <= RESULT_FAILED)
	{
		server_print("[FGunShop] SQL Init error. (Load)")
	}
	else
	{
		for(new i=1;i<sizeof gun_code;i++)
		{
			g_iForeverGun[id][i] = dbi_field(result, i)
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