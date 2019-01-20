#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <nvault>
#include <fakemeta>
#include <hamsandwich>
#include <eg_boss>

#define PLUGIN "[eG]基地建設永久商店"
#define VERSION "S1v2"
#define AUTHOR "EmeraldGhost"

new g_fvault
new g_iSelectPri[33]

//永久槍代數(目前二十項,如有更多請按照這樣再增加,不慬的話請告訴我)
new g_xD0625_fgun1[33], g_xD0625_fgun2[33], g_xD0625_fgun3[33], g_xD0625_fgun4[33], g_xD0625_fgun5[33], g_xD0625_fgun6[33], g_xD0625_fgun7[33],
    g_xD0625_fgun8[33], g_xD0625_fgun9[33], g_xD0625_fgun10[33], g_xD0625_fgun11[33], g_xD0625_fgun12[33], g_xD0625_fgun13[33], g_xD0625_fgun14[33],
    g_xD0625_fgun15[33], g_xD0625_fgun16[33], g_xD0625_fgun17[33], g_xD0625_fgun18[33], g_xD0625_fgun19[33], g_xD0625_fgun20[33]

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
    
    //請在這裡設定價錢
	register_cvar("fgun1_cost", "100") 
    register_cvar("fgun2_cost", "100") 
    register_cvar("fgun3_cost", "9999999")  //永久槍3價錢
    register_cvar("fgun4_cost", "9999999")  //永久槍4價錢
    register_cvar("fgun5_cost", "9999999")  //永久槍5價錢
    register_cvar("fgun6_cost", "9999999")  //永久槍6價錢
    register_cvar("fgun7_cost", "9999999")  //永久槍7價錢
    register_cvar("fgun8_cost", "9999999")  //永久槍8價錢
    register_cvar("fgun9_cost", "9999999")  //永久槍9價錢
    register_cvar("fgun10_cost", "9999999")//永久槍10價錢
    register_cvar("fgun11_cost", "9999999")//永久槍11價錢
    register_cvar("fgun12_cost", "9999999")//永久槍12價錢
    register_cvar("fgun13_cost", "9999999")//永久槍13價錢
    register_cvar("fgun14_cost", "9999999")//永久槍14價錢
    register_cvar("fgun15_cost", "9999999")//永久槍15價錢
    register_cvar("fgun16_cost", "9999999")//永久槍16價錢
    register_cvar("fgun17_cost", "9999999")//永久槍17價錢
    register_cvar("fgun18_cost", "9999999")//永久槍18價錢
    register_cvar("fgun19_cost", "9999999")//永久槍19價錢
    register_cvar("fgun20_cost", "9999999")//永久槍20價錢

    register_cvar("fhgun2_cost", "9999999")  //永久手槍2價錢
    register_cvar("fhgun3_cost", "9999999")  //永久手槍3價錢
    register_cvar("fhgun4_cost", "9999999")  //永久手槍4價錢
    register_cvar("fhgun5_cost", "9999999")  //永久手槍5價錢
    register_cvar("fhgun6_cost", "9999999")  //永久手槍6價錢
    register_cvar("fhgun7_cost", "9999999")  //永久手槍7價錢
    register_cvar("fhgun8_cost", "9999999")  //永久手槍8價錢
    register_cvar("fhgun9_cost", "9999999")  //永久手槍9價錢
    register_cvar("fhgun10_cost", "9999999")//永久手槍10價錢

    register_cvar("fthing3_cost", "9999999")//永久物品3價錢
    register_cvar("fthing4_cost", "9999999")//永久物品4價錢
    register_cvar("fthing5_cost", "9999999")//永久物品5價錢
    
    g_fvault = nvault_open("BB_Level_Shop_S1") 
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
				
		menu_additem(menu, "\g[突击步枪]\y416-C Carbine     \g100 武器点", "1", 0);
		menu_additem(menu, "\g[冲锋枪]\yKriss Super V     \g100 武器点", "2", 0);
		menu_additem(menu, "不日推出", "3", 0);
		menu_additem(menu, "不日推出", "4", 0);
		menu_additem(menu, "不日推出", "5", 0);
		menu_additem(menu, "不日推出", "6", 0);
		menu_additem(menu, "不日推出", "7", 0);
		menu_additem(menu, "不日推出", "8", 0);
		menu_additem(menu, "不日推出", "9", 0);
		menu_additem(menu, "不日推出", "10", 0);
		menu_additem(menu, "不日推出", "11", 0);
		menu_additem(menu, "不日推出", "12", 0);
		menu_additem(menu, "不日推出", "13", 0);
		menu_additem(menu, "不日推出", "14", 0);
		menu_additem(menu, "不日推出", "15", 0);
		menu_additem(menu, "不日推出", "16", 0);
		menu_additem(menu, "不日推出", "17", 0);
		menu_additem(menu, "不日推出", "18", 0);
		menu_additem(menu, "不日推出", "19", 0);
		menu_additem(menu, "不日推出^n", "20", 0);
		menu_additem(menu, "返回", "21", 0);
		
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

	
	switch(key)
	{
		case 1:
		{
			 if (!g_xD0625_fgun1[id])
			 {
				if (get_user_gp(id) >= get_cvar_num("fgun1_cost"))
				{
					g_xD0625_fgun1[id] = 1
					set_user_gp(id, get_user_gp(id) - get_cvar_num("fgun1_cost"))
					client_printc(id, "\g[永久商城] \t你己购买了 \y416-C Carbine\t! 可到\y我的背包\t装备。")
					client_print(id, print_console, "[FGUNSHOP] 你己購買了 416-C Carbine!可到 我的背包 装备。") 
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
		case 2:
		{
		 if (!g_xD0625_fgun2[id])
		 {
			if (get_user_gp(id) >= get_cvar_num("fgun2_cost"))
			{
				g_xD0625_fgun2[id] = 1
				set_user_gp(id, get_user_gp(id) - get_cvar_num("fgun2_cost"))
				client_printc(id, "\g[永久商城] \t你己购买了 \yKriss Super V\t! 可到\y我的背包\t装备。")
				client_print(id, print_console, "[FGUNSHOP] 你己購買了 Kriss Super V ! 可到 我的背包 装备。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\y武器點\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的武器點!!") 
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
		 if (!g_xD0625_fgun3[id])
		 {
			if (get_user_gp(id) >= get_cvar_num("fgun3_cost"))
			{
				g_xD0625_fgun3[id] = 1
				set_user_gp(id, get_user_gp(id) - get_cvar_num("fgun3_cost"))
				client_printc(id, "\g[永久商城] \t你己購買了 \y鐵血重炮 - M32\t! 可到\y我的背包\t裝備。")
				client_print(id, print_console, "[BossLevelS] 你己購買了 鐵血重炮 - M32!可到 我的背包 裝備。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\y武器點\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的武器點!!") 
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
		 if (!g_xD0625_fgun4[id])
		 {
			if (get_user_gp(id) >= get_cvar_num("fgun4_cost"))
			{
				g_xD0625_fgun4[id] = 1
				set_user_gp(id, get_user_gp(id) - get_cvar_num("fgun4_cost"))
				client_printc(id, "\g[永久商城] \t你己購買了 \y神器-幽能離子槍\t! 可到\y我的背包\t裝備。")
				client_print(id, print_console, "[BossLevelS] 你己購買了 神器 - 幽能離子槍!可到 我的背包 裝備。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\y武器點\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的武器點!!") 
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
		 if (!g_xD0625_fgun5[id])
		 {
			if (get_user_gp(id) >= get_cvar_num("fgun5_cost"))
			{
				g_xD0625_fgun5[id] = 1
				set_user_gp(id, get_user_gp(id) - get_cvar_num("fgun5_cost"))
				client_printc(id, "\g[永久商城] \t你己購買了 \y超神器 * Thanatos-5\t! 可到\y我的背包\t裝備。")
				client_print(id, print_console, "[BossLevelS] 你己購買了 超神器*Thanatos-5!可到 我的背包 裝備。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\y武器點\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的武器點!!") 
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
		 if (!g_xD0625_fgun6[id])
		 {
			if (get_user_gp(id) >= get_cvar_num("fgun6_cost"))
			{
				g_xD0625_fgun6[id] = 1
				set_user_gp(id, get_user_gp(id) - get_cvar_num("fgun6_cost"))
				client_printc(id, "\g[永久商城] \t你己購買了 \y超神器 * Thanatos-7\t! 可到\y我的背包\t裝備。")
				client_print(id, print_console, "[BossLevelS] 你己購買了 超神器*Thanatos-7!可到 我的背包 裝備。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\y武器點\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的武器點!!") 
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
		 if (!g_xD0625_fgun7[id])
		 {
			if (get_user_gp(id) >= get_cvar_num("fgun7_cost"))
			{
				g_xD0625_fgun7[id] = 1
				set_user_gp(id, get_user_gp(id) - get_cvar_num("fgun7_cost"))
				client_printc(id, "\g[永久商城] \t你己購買了 \y焚盡者<特別版>\t! 可到\y我的背包\t裝備。")
				client_print(id, print_console, "[BossLevelS] 你己購買了 焚燼者<特別版>!可到 我的背包 裝備。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\y武器點\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的武器點!!") 
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
		 if (!g_xD0625_fgun8[id])
		 {
			if (get_user_gp(id) >= get_cvar_num("fgun8_cost"))
			{
				g_xD0625_fgun8[id] = 1
				set_user_gp(id, get_user_gp(id) - get_cvar_num("fgun8_cost"))
				client_printc(id, "\g[永久商城] \t你己購買了 \y超神器 * 英雄戰擊\t! 可到\y我的背包\t裝備。")
				client_print(id, print_console, "[BossLevelS] 你己購買了 超神器 * 英雄戰擊!可到 我的背包 裝備。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\y武器點\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的武器點!!") 
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
		 if (!g_xD0625_fgun9[id])
		 {
			if (get_user_gp(id) >= get_cvar_num("fgun9_cost"))
			{
				g_xD0625_fgun9[id] = 1
				set_user_gp(id, get_user_gp(id) - get_cvar_num("fgun9_cost"))
				client_printc(id, "\g[永久商城] \t你己購買了 \b聖器-ThunderBoltEX\t! 可到\y我的背包\t裝備。")
				client_print(id, print_console, "[BossLevelS] 你己購買了 聖器-ThunderBoltEX!可到 我的背包 裝備。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\y武器點\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的武器點!!") 
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
		 if (!g_xD0625_fgun10[id])
		 {
			if (get_user_gp(id) >= get_cvar_num("fgun10_cost"))
			{
				g_xD0625_fgun10[id] = 1
				set_user_gp(id, get_user_gp(id) - get_cvar_num("fgun10_cost"))
				client_printc(id, "\g[永久商城] \t你己購買了 \y致命雙刺-DualKriss\t! 可到\y我的背包\t裝備。")
				client_print(id, print_console, "[BossLevelS] 你己購買了 致命雙刺-DualKriss!可到 我的背包 裝備。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\y武器點\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的武器點!!") 
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
		 if (!g_xD0625_fgun11[id])
		 {
			if (get_user_gp(id) >= get_cvar_num("fgun11_cost"))
			{
				g_xD0625_fgun11[id] = 1
				set_user_gp(id, get_user_gp(id) - get_cvar_num("fgun11_cost"))
				client_printc(id, "\g[永久商城] \t你己購買了 \yAT4CS火箭發射器\t! 可到\y我的背包\t裝備。")
				client_print(id, print_console, "[BossLevelS] 你己購買了 AT4CS火箭發射器!可到 我的背包 裝備。") 
			}
			else
			{
				client_printc(id, "\g[永久商城] \t你沒有足夠的\y武器點\t!!")
				client_print(id, print_console, "[BossLevelS] 你沒有足夠的武器點!!") 
			}
		 }
		 else
		 {
			client_printc(id, "\g[永久商城] \t你己擁有該把\y永久槍\t。")
			client_print(id, print_console, "[BossLevelS] 你己擁有該把永久槍。") 
		 }
		}
		case 12:
		{
		 if (!g_xD0625_fgun12[id])
		 {
			if (get_user_cash(id) >= get_cvar_num("fgun12_cost"))
			{
				g_xD0625_fgun12[id] = 1
				set_user_cash(id, get_user_cash(id) - get_cvar_num("fgun12_cost"))
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
		case 13:
		{
		 if (!g_xD0625_fgun13[id])
		 {
			if (get_user_cash(id) >= get_cvar_num("fgun13_cost"))
			{
				g_xD0625_fgun13[id] = 1
				set_user_cash(id, get_user_cash(id) - get_cvar_num("fgun13_cost"))
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
		case 14:
		{
		 if (!g_xD0625_fgun14[id])
		 {
			if (get_user_cash(id) >= get_cvar_num("fgun14_cost"))
			{
				g_xD0625_fgun14[id] = 1
				set_user_cash(id, get_user_cash(id) - get_cvar_num("fgun14_cost"))
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
		case 15:
		{
		 if (!g_xD0625_fgun15[id])
		 {
			if (get_user_cash(id) >= get_cvar_num("fgun15_cost"))
			{
				g_xD0625_fgun15[id] = 1
				set_user_cash(id, get_user_cash(id) - get_cvar_num("fgun15_cost"))
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
		case 16:
		{
		 if (!g_xD0625_fgun16[id])
		 {
			if (get_user_cash(id) >= get_cvar_num("fgun16_cost"))
			{
				g_xD0625_fgun16[id] = 1
				set_user_cash(id, get_user_cash(id) - get_cvar_num("fgun16_cost"))
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
		case 17:
		{
		 if (!g_xD0625_fgun17[id])
		 {
			if (get_user_cash(id) >= get_cvar_num("fgun17_cost"))
			{
				g_xD0625_fgun17[id] = 1
				set_user_cash(id, get_user_cash(id) - get_cvar_num("fgun17_cost"))
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
		case 18:
		{
		 if (!g_xD0625_fgun18[id])
		 {
			if (get_user_cash(id) >= get_cvar_num("fgun18_cost"))
			{
				g_xD0625_fgun18[id] = 1
				set_user_cash(id, get_user_cash(id) - get_cvar_num("fgun18_cost"))
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
		case 19:
		{
		 if (!g_xD0625_fgun19[id])
		 {
			if (get_user_cash(id) >= get_cvar_num("fgun19_cost"))
			{
				g_xD0625_fgun19[id] = 1
				set_user_cash(id, get_user_cash(id) - get_cvar_num("fgun19_cost"))
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
		case 20:
		{
		 if (!g_xD0625_fgun20[id])
		 {
			if (get_user_cash(id) >= get_cvar_num("fgun20_cost"))
			{
				g_xD0625_fgun20[id] = 1
				set_user_cash(id, get_user_cash(id) - get_cvar_num("fgun20_cost"))
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
		case 21:
		{
                        client_cmd(id, "fshopmenu")
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
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
	
	menu = menu_create("\r裝備永久槍", "my2_handler")
	if (g_xD0625_fgun1[id])
	{
		formatex(option, charsmax(option), "416-C Carbine     \r　: \y　己购买")
		menu_additem(menu, option, "1", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "416-C Carbine     \y　: \r　未购买")
		menu_additem(menu, option, "1", 0)	
	}
	if (g_xD0625_fgun2[id])
	{
		formatex(option, charsmax(option), "Kriss Super V  \r　: \y　己购买")
		menu_additem(menu, option, "2", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "Kriss Super V  \y　: \r　未购买")
		menu_additem(menu, option, "2", 0)	
	}
	if (g_xD0625_fgun3[id])
	{
		formatex(option, charsmax(option), "-------   \r　: \y　己購買")
		menu_additem(menu, option, "3", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------   \y　: \r　未購買")
		menu_additem(menu, option, "3", 0)	
	}
	if (g_xD0625_fgun4[id])
	{
		formatex(option, charsmax(option), "-------   \r　: \y　己購買")
		menu_additem(menu, option, "4", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------   \y　: \r　未購買")
		menu_additem(menu, option, "4", 0)	
	}
	if (g_xD0625_fgun5[id])
	{
		formatex(option, charsmax(option), "-------  \r　: \y　己購買")
		menu_additem(menu, option, "5", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------   \y　: \r　未購買")
		menu_additem(menu, option, "5", 0)	
	}
	if (g_xD0625_fgun6[id])
	{
		formatex(option, charsmax(option), "-------  \r　: \y　己購買")
		menu_additem(menu, option, "6", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------   \y　: \r　未購買")
		menu_additem(menu, option, "6", 0)	
	}
	if (g_xD0625_fgun7[id])
	{
		formatex(option, charsmax(option), "-------   \r　: \y　己購買")
		menu_additem(menu, option, "7", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------   \y　: \r　未購買")
		menu_additem(menu, option, "7", 0)	
	}
	if (g_xD0625_fgun8[id])
	{
		formatex(option, charsmax(option), "-------   \r　: \y　己購買")
		menu_additem(menu, option, "8", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------   \y　: \r　未購買")
		menu_additem(menu, option, "8", 0)	
	}
	if (g_xD0625_fgun9[id])
	{
		formatex(option, charsmax(option), "-------   \r　: \y　己購買")
		menu_additem(menu, option, "9", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------   \y　: \r　未購買")
		menu_additem(menu, option, "9", 0)	
	}
	if (g_xD0625_fgun10[id])
	{
		formatex(option, charsmax(option), "-------   \r　: \y　己購買")
		menu_additem(menu, option, "10", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------   \y　: \r　未購買")
		menu_additem(menu, option, "10", 0)	
	}
	if (g_xD0625_fgun11[id])
	{
		formatex(option, charsmax(option), "-------   \r　: \y　己購買")
		menu_additem(menu, option, "11", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------   \y　: \r　未購買")
		menu_additem(menu, option, "11", 0)	
	}
	if (g_xD0625_fgun12[id])
	{
		formatex(option, charsmax(option), "-------  \r　: \y　己購買")
		menu_additem(menu, option, "12", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------  \y　: \r　未購買")
		menu_additem(menu, option, "12", 0)	
	}
	if (g_xD0625_fgun13[id])
	{
		formatex(option, charsmax(option), "-------  \r　: \y　己購買")
		menu_additem(menu, option, "13", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------  \y　: \r　未購買")
		menu_additem(menu, option, "13", 0)	
	}
	if (g_xD0625_fgun14[id])
	{
		formatex(option, charsmax(option), "-------  \r　: \y　己購買")
		menu_additem(menu, option, "14", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------  \y　: \r　未購買")
		menu_additem(menu, option, "14", 0)	
	}
	if (g_xD0625_fgun15[id])
	{
		formatex(option, charsmax(option), "-------  \r　: \y　己購買")
		menu_additem(menu, option, "15", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------  \y　: \r　未購買")
		menu_additem(menu, option, "15", 0)	
	}
	if (g_xD0625_fgun16[id])
	{
		formatex(option, charsmax(option), "-------  \r　: \y　己購買")
		menu_additem(menu, option, "16", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------  \y　: \r　未購買")
		menu_additem(menu, option, "16", 0)	
	}
	if (g_xD0625_fgun17[id])
	{
		formatex(option, charsmax(option), "-------  \r　: \y　己購買")
		menu_additem(menu, option, "17", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------  \y　: \r　未購買")
		menu_additem(menu, option, "17", 0)	
	}
	if (g_xD0625_fgun18[id])
	{
		formatex(option, charsmax(option), "-------  \r　: \y　己購買")
		menu_additem(menu, option, "18", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------  \y　: \r　未購買")
		menu_additem(menu, option, "18", 0)	
	}
	if (g_xD0625_fgun19[id])
	{
		formatex(option, charsmax(option), "-------  \r　: \y　己購買")
		menu_additem(menu, option, "19", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------  \y　: \r　未購買")
		menu_additem(menu, option, "19", 0)	
	}
	if (g_xD0625_fgun20[id])
	{
		formatex(option, charsmax(option), "-------  \r　: \y　己購買^n")
		menu_additem(menu, option, "20", 0)
		
	}
	else
	{
		formatex(option, charsmax(option), "-------  \y　: \r　未購買^n")
		menu_additem(menu, option, "20", 0)	
	}
	menu_additem(menu, "返回", "21", 0);
	
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

	
	switch(key)
	{
		case 1:
		{
			if (g_xD0625_fgun1[id])
			{
				client_printc(id, "\g[枪械选择] \t你装备了 \y416-C Carbine\t !")
				client_cmd(id, "Hk416AssaultRifleHAHA")
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
			if (g_xD0625_fgun2[id])
			{
				client_printc(id, "\g[枪械选择] \t你装备了 \yKriss Super V\t !")
				client_cmd(id, "KrissSuperVSecondGunHAHA")
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
		if (g_xD0625_fgun3[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 \y鐵血重炮-M32\t!")
	    		client_cmd(id, "gaygunm32lun9gun")
	    		client_cmd(id, "clear")
	    		myfg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 4:
		{
		if (g_xD0625_fgun4[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 \y神器-幽能離子槍\t!")
	    		client_cmd(id, "use_plasma")
	    		client_cmd(id, "clear")
	    		myfg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 5:
		{
		if (g_xD0625_fgun5[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 \y超神器*Thanatos-5\t!")
	    		client_cmd(id, "Thanatos-5_sLolitaSGodGun")
	    		client_cmd(id, "clear")
	    		myfg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 6:
		{
		if (g_xD0625_fgun6[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 \y超神器*Thanatos-7\t!")
	    		client_cmd(id, "Thanatos-7_sLolitaSGodGun")
	    		client_cmd(id, "clear")
	    		myfg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 7:
		{
		if (g_xD0625_fgun7[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 \y焚燼者<特別版>\t!")
	    		client_cmd(id, "PoisonGunSoSadBoss99")
	    		client_cmd(id, "clear")
	    		myfg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 8:
		{
		if (g_xD0625_fgun8[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 \y超神器-英雄戰擊\t!")
			client_printc(id, "\g[槍械選擇] \t本武器目前為預售階段.日後開放選擇!")
	    		client_cmd(id, "SVDEXLDGUNaa")
	    		client_cmd(id, "clear")
	    		myfg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 9:
		{
		if (g_xD0625_fgun9[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 \b聖器-ThunderBoltEX\t!")
	    		client_cmd(id, "sfsniperex")
	    		client_cmd(id, "clear")
	    		myfg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 10:
		{
		if (g_xD0625_fgun10[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 \y致命雙刺-DualKriss\t!")
	    		client_cmd(id, "DualKrissVictor")
	    		client_cmd(id, "clear")
	    		myfg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 11:
		{
		if (g_xD0625_fgun11[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 \yAT4CS火箭發射器\t!")
	    		client_cmd(id, "AT4CSMISSILELAUNCHER")
	    		client_cmd(id, "clear")
	    		myfg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 12:
		{
		if (g_xD0625_fgun12[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 永久槍 - \y-----\t!")
	    		client_cmd(id, "")
	    		myfg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 13:
		{
		if (g_xD0625_fgun13[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 永久槍 - \y-----\t!")
	    		client_cmd(id, "")
	    		myfg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 14:
		{
		if (g_xD0625_fgun14[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 永久槍 - \y-----\t!")
	    		client_cmd(id, "")
	    		myfg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 15:
		{
		if (g_xD0625_fgun15[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 永久槍 - \y-----\t!")
	    		client_cmd(id, "")
	    		myfg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 16:
		{
		if (g_xD0625_fgun16[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 永久槍 - \y-----\t!")
	    		client_cmd(id, "")
	    		myfg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 17:
		{
		if (g_xD0625_fgun17[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 永久槍 - \y-----\t!")
	    		client_cmd(id, "")
	    		myfg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 18:
		{
		if (g_xD0625_fgun18[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 永久槍 - \y-----\t!")
	    		client_cmd(id, "")
	    		myfg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 19:
		{
		if (g_xD0625_fgun19[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 永久槍 - \y-----\t!")
	    		client_cmd(id, "")
	    		myfg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 20:
		{
		if (g_xD0625_fgun20[id])
		{
			client_printc(id, "\g[槍械選擇] \t你裝備了 永久槍 - \y-----\t!")
	    		client_cmd(id, "")
	    		myfg_menu(id)
		}
		else
		{
			client_print(id, print_console, "[BossLevelS] 請先到永久商城購買!!") 
			client_printc(id, "\g[槍械選擇] \t請先到\y永久商城\t購買!!!!")
		}
		}
		case 21:
		{
                        client_cmd(id, "mymenu")
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
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


public native_get_user_fgun1(id)  //永久槍1
{
    return g_xD0625_fgun1[id]
}

public native_set_user_fgun1(id, amount)  //永久槍1
{
    g_xD0625_fgun1[id] = amount
    return g_xD0625_fgun1[id]
}

public native_get_user_fgun2(id)  //永久槍2
{
    return g_xD0625_fgun2[id]
}

public native_set_user_fgun2(id, amount)  //永久槍2
{
    g_xD0625_fgun2[id] = amount
    return g_xD0625_fgun2[id]
}

public native_get_user_fgun3(id)
{
     return g_xD0625_fgun3[id]
}

public native_set_user_fgun3(id, amount)
{
     g_xD0625_fgun3[id] = amount
     return g_xD0625_fgun3[id]
}

public native_get_user_fgun4(id)
{
     return g_xD0625_fgun4[id]
}

public native_set_user_fgun4(id, amount)
{
     g_xD0625_fgun4[id] = amount
     return g_xD0625_fgun4[id]
}

public native_get_user_fgun5(id)
{
     return g_xD0625_fgun5[id]
}

public native_set_user_fgun5(id, amount)
{
     g_xD0625_fgun5[id] = amount
     return g_xD0625_fgun5[id]
}

public native_get_user_fgun6(id)
{
     return g_xD0625_fgun6[id]
}

public native_set_user_fgun6(id, amount)
{
     g_xD0625_fgun6[id] = amount
     return g_xD0625_fgun6[id]
}

public native_get_user_fgun7(id)
{
     return g_xD0625_fgun7[id]
}

public native_set_user_fgun7(id, amount)
{
     g_xD0625_fgun7[id] = amount
     return g_xD0625_fgun7[id]
}

public native_get_user_fgun8(id)
{
     return g_xD0625_fgun8[id]
}

public native_set_user_fgun8(id, amount)
{
     g_xD0625_fgun8[id] = amount
     return g_xD0625_fgun8[id]
}

public native_get_user_fgun9(id)
{
     return g_xD0625_fgun9[id]
}

public native_set_user_fgun9(id, amount)
{
     g_xD0625_fgun9[id] = amount
     return g_xD0625_fgun9[id]
}

public native_get_user_fgun10(id)
{
     return g_xD0625_fgun10[id]
}

public native_set_user_fgun10(id, amount)
{
     g_xD0625_fgun10[id] = amount
     return g_xD0625_fgun10[id]
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
}

public client_putinserver(id)
{
 LoadDatafgun(id)
 g_iSelectPri[id] = 0
}

public saveguns(id)
{
 SaveDatafgun(id)
}

public SaveDatafgun(id) //儲存永久物品資料
{ 
  new name[35], fvaultkey[64], fvaultdata[256]
              
  get_user_name(id, name, 34) 
  
  format(fvaultkey, 63, "%s-Fgun", name) 

  format(fvaultdata, 255, "%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#", g_xD0625_fgun1[id], g_xD0625_fgun2[id], g_xD0625_fgun3[id], g_xD0625_fgun4[id], g_xD0625_fgun5[id],

  g_xD0625_fgun6[id], g_xD0625_fgun7[id], g_xD0625_fgun8[id], g_xD0625_fgun9[id], g_xD0625_fgun10[id], g_xD0625_fgun11[id], g_xD0625_fgun12[id], g_xD0625_fgun13[id], g_xD0625_fgun14[id], g_xD0625_fgun15[id], g_xD0625_fgun16[id],

  g_xD0625_fgun17[id], g_xD0625_fgun18[id], g_xD0625_fgun19[id], g_xD0625_fgun20[id], g_xD0625_fhgun1[id], g_xD0625_fhgun2[id], g_xD0625_fhgun3[id], g_xD0625_fhgun4[id], g_xD0625_fhgun5[id], g_xD0625_fhgun6[id], g_xD0625_fhgun7[id], g_xD0625_fhgun8[id], g_xD0625_fhgun9[id], g_xD0625_fhgun10[id],

  g_xD0625_ftg1[id], g_xD0625_ftg2[id], g_xD0625_ftg3[id], g_xD0625_ftg4[id], g_xD0625_ftg5[id])

  nvault_set(g_fvault, fvaultkey, fvaultdata) 

  return PLUGIN_CONTINUE
} 

public LoadDatafgun(id) //載入永久物品資料
{ 
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
