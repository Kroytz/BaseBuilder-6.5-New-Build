#include <amxmodx>
#include <zpm>
#include <vault>
#include <eG>
#include <zombieplague>
#include <hamsandwich>
#include <dbi>
#include <register_system>

#define COMPOSE_COST 50

new const has_model[][] = { "[未拥有]", "[已拥有]" }

new const model_name[][] = { "null", "【蕾米莉亚】", "【五河琴里】", "【黑白.涅普基雅】", "【四糸乃】", "【時崎狂三】", "(合成)【尼尔.2B】", "(特殊笑声)【琪露诺】", "(合成)【ELO-诗乃】" }
//new const model_inf[][] = { "null", "东方大小姐", "精灵形态的妹妹", "基雅的黑白装扮", "精灵形态四兔子", "精灵形态狂三", "小姐姐真棒" }
new const model_cost[] = { 0, 500, 1500, 1000, 1500, 1500, 99999, 750, 99999 }
new const model_sell[] = { 0, 250, 500, 500, 500, 500, 1000, 425, 1000 }
//new const model_cost[] = { 0, 50, 50, 50, 50, 50, 99999, 50, 99999 }
//new const model_sell[] = { 0, 50, 50, 50, 50, 50, 1000, 50, 1000 }
new const model_code[][] = { "null", "remilia", "kotori", "bwgear", "yoshino", "kurumi", "nier2b", "cirno", "eloshino" }

new pcv_debug

new iSelected[33]
new iPlayerHasSkin[33][sizeof model_code]

new const log_file[] = "ZStore_PlayerBuy.txt"

//SQL variable
new Sql:sql
new Result:result
new error[33]

public plugin_init()
{
	register_plugin("[eG] ZP Store - Skin", "v20181124", "EmeraldGhost")
	
	// SQL Initionlize
	new sql_host[64], sql_user[64], sql_pass[64], sql_db[64]
	get_cvar_string("amx_sql_host", sql_host, 63)
	get_cvar_string("amx_sql_user", sql_user, 63)
	get_cvar_string("amx_sql_pass", sql_pass, 63)
	get_cvar_string("amx_sql_db", sql_db, 63)

	sql = dbi_connect(sql_host, sql_user, sql_pass, sql_db, error, 32)

	if (sql == SQL_FAILED)
	{
		server_print("[ZStore] Could not connect to SQL database. %s", error)
	}
	
	register_clcmd("store_skin", "skin_menu")
	register_clcmd("say /store", "skin_menu")
	register_clcmd("say !store", "skin_menu")
	
	register_clcmd("store_sell", "sellskin_menu")
	register_clcmd("say /storesell", "sellskin_menu")
	register_clcmd("say !storesell", "sellskin_menu")
	
	register_clcmd("store_compose", "compose_skin")
	register_clcmd("say /compose", "compose_skin")
	register_clcmd("say !compose", "compose_skin")
}

public plugin_natives()
{
	register_native("zpm_store_get_user_skin", "Native_Get_Skin", 1)
}

public client_putinserver(id)
{
	for(new i=1;i<sizeof model_code;i++)
		iPlayerHasSkin[id][i] = 0
		
	load_data(id)
}

public client_disconnect(id)
{
	for(new i=1;i<sizeof model_code;i++)
		iPlayerHasSkin[id][i] = 0
}

public save_data(id)
{ 
	new authid[32]
	get_user_name(id, authid, 31)
	replace_all(authid, 32, "`", "\`")
	replace_all(authid, 32, "'", "\'")
	
	for(new i=1;i<sizeof model_code;i++)
	{
		dbi_query(sql, "UPDATE skinstore SET %s='%d' WHERE name = '%s'", model_code[i], iPlayerHasSkin[id][i], authid)
	}
}

public load_data(id) 
{
	new authid[32] 
	get_user_name(id,authid,31)
	replace_all(authid, 32, "`", "\`")
	replace_all(authid, 32, "'", "\'")

	result = dbi_query(sql, "SELECT remilia,kotori,bwgear,yoshino,kurumi,nier2b,cirno,eloshino FROM skinstore WHERE name='%s'", authid)

	if(result == RESULT_NONE)
	{
	dbi_query(sql, "INSERT INTO skinstore(name,remilia,kotori,bwgear,yoshino,kurumi,nier2b,cirno,eloshino) VALUES('%s','0','0','0','0','0','0','0','0')", authid)
	}
	else if(result <= RESULT_FAILED)
	{
		server_print("[ZStore] SQL Init error. (Skin-Load)")
	}
	else
	{
		for(new i=1;i<sizeof model_code;i++)
		{
			iPlayerHasSkin[id][i] = dbi_field(result, i)
		}
		dbi_free_result(result)
	}
}

public skin_menu(id)
{
		static option[64]
		formatex(option, charsmax(option), "\r[喪屍樂園] - 模型商店^n您拥有金币：%d 个", zpm_base_get_coin(id))
		new menu = menu_create(option, "store_skinmenu");
		
		new szTempid[32]
		for(new i = 1; i < sizeof model_code; i++)
		{
			new iSkin = iPlayerHasSkin[id][i]
		
			new szItems[101]
			formatex(szItems, 100, "\y%s\r%s - %d 金币", has_model[iSkin], model_name[i], model_cost[i])
			num_to_str(i, szTempid, 31)
			menu_additem(menu, szItems, szTempid, 0)
		}

		menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
		menu_setprop(menu, MPROP_BACKNAME, "返回"); 
		menu_setprop(menu, MPROP_NEXTNAME, "更多"); 
		menu_setprop(menu, MPROP_EXITNAME, "退出"); 
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		
		menu_display(id, menu, 0);
		return PLUGIN_HANDLED;
}

public store_skinmenu(id, menu, item)
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
	iSelected[id] = key
	sure_to_buy(id, iSelected[id])
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public sure_to_buy(id, skinid)
{
		static option[64]
		formatex(option, charsmax(option), "\r你确定要购买%s吗？", model_name[skinid])
		new menu = menu_create(option, "confirm_handler");
				
		menu_additem(menu, "\y是的，我确定买！", "1");
		menu_additem(menu, "\y不是，我手抖了。", "2");
		
		menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
		menu_setprop(menu, MPROP_BACKNAME, "返回"); 
		menu_setprop(menu, MPROP_NEXTNAME, "更多..."); 
		menu_setprop(menu, MPROP_EXITNAME, "退出"); 
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		
		menu_display(id, menu, 0);
		return PLUGIN_HANDLED;
}

public confirm_handler(id, menu, item)
{
	new sz_Name[ 32 ];
	
	get_user_name( id, sz_Name, 31 );

	if(item == MENU_EXIT)
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
			buy_skin(id, iSelected[id])
		}
		case 2:
		{
			return PLUGIN_HANDLED;
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public buy_skin(id, skinid)
{
	if(!is_user_logged(id))
		return PLUGIN_HANDLED;

	new IsHasModel = iPlayerHasSkin[id][skinid]
	new iCoin = zpm_base_get_coin(id)

	if(IsHasModel == 1)
	{
		client_printc(id, "\g[Store]\y 你已经拥有皮肤%s了 !", model_name[skinid]);
	}
	else if(iCoin >= model_cost[skinid])
	{
		client_printc(id, "\g[Store]\y 购买皮肤\g%s\y成功 !", model_name[skinid]);
		PlaySound(id, "zmParadise/Store/coinlose_sound.wav")
		zpm_base_set_coin(id, iCoin - model_cost[skinid]);
		iPlayerHasSkin[id][skinid] = 1
		save_data(id)
		log_buy(id, skinid)
	}
	else client_printc(id, "\g[Store]\y 没钱还想买皮肤? 算了吧!");
	
	return PLUGIN_HANDLED;
}

public log_buy(id, skinid)
{
    new name[32]
    get_user_name(id,name,31)
	
	log_to_file(log_file, "[Buy] %s 购买皮肤 %s .", name, model_name[skinid])
}

public sellskin_menu(id)
{
		static option[64]
		formatex(option, charsmax(option), "\r[喪屍樂園] - 模型收购^n您拥有金币：%d 个", zpm_base_get_coin(id))
		new menu = menu_create(option, "store_sellskinmenu");
		
		new szTempid[32]
		for(new i = 1; i < sizeof model_code; i++)
		{
			new iSkin = iPlayerHasSkin[id][i]
		
			new szItems[101]
			formatex(szItems, 100, "\y%s\r%s - %d 金币", has_model[iSkin], model_name[i], model_sell[i])
			num_to_str(i, szTempid, 31)
			menu_additem(menu, szItems, szTempid, 0)
		}

		menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
		menu_setprop(menu, MPROP_BACKNAME, "返回"); 
		menu_setprop(menu, MPROP_NEXTNAME, "更多"); 
		menu_setprop(menu, MPROP_EXITNAME, "退出"); 
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		
		menu_display(id, menu, 0);
		return PLUGIN_HANDLED;
}

public store_sellskinmenu(id, menu, item)
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
	iSelected[id] = key
	sure_to_sell(id, iSelected[id])
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public sure_to_sell(id, skinid)
{
		static option[64]
		formatex(option, charsmax(option), "\r你确定要卖出%s吗？", model_name[skinid])
		new menu = menu_create(option, "sell_confirm_handler");
				
		menu_additem(menu, "\y是的，我确定卖！", "1");
		menu_additem(menu, "\y不是，我手抖了。", "2");
		
		menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
		menu_setprop(menu, MPROP_BACKNAME, "返回"); 
		menu_setprop(menu, MPROP_NEXTNAME, "更多..."); 
		menu_setprop(menu, MPROP_EXITNAME, "退出"); 
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		
		menu_display(id, menu, 0);
		return PLUGIN_HANDLED;
}

public sell_confirm_handler(id, menu, item)
{
	new sz_Name[ 32 ];
	
	get_user_name( id, sz_Name, 31 );

	if(item == MENU_EXIT)
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
			sell_skin(id, iSelected[id])
		}
		case 2:
		{
			return PLUGIN_HANDLED;
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public sell_skin(id, skinid)
{
	if(!is_user_logged(id))
		return PLUGIN_HANDLED;

	new IsHasModel = iPlayerHasSkin[id][skinid]
	new iCoin = zpm_base_get_coin(id)

	if(IsHasModel == 1)
	{
		client_printc(id, "\g[Store]\y 卖出皮肤\g%s\y成功 !", model_name[skinid]);
		PlaySound(id, "zmParadise/Store/coin_sound.wav")
		zpm_base_set_coin(id, iCoin + model_sell[skinid]);
		iPlayerHasSkin[id][skinid] = 0
		save_data(id)
		log_sell(id, skinid)
	}
	else client_printc(id, "\g[Store]\y 没皮肤你卖什么? 洗洗睡吧!");
	
	return PLUGIN_HANDLED;
}

public log_sell(id, skinid)
{
    new name[32]
    get_user_name(id,name,31)
	
	log_to_file(log_file, "[Sell] %s 卖出皮肤 %s .", name, model_name[skinid])
}

public compose_skin(id)
{
	static option[64]
	formatex(option, charsmax(option), "\r[喪屍樂園] - 玄学菜单^n请选择模型：", zpm_base_get_coin(id))
	new menu = menu_create(option, "compose_handler");
			
	new szTempid[32]
	for(new i = 1; i < sizeof model_code; i++)
	{
		new iSkin = iPlayerHasSkin[id][i]
	
		new szItems[101]
		formatex(szItems, 100, "\y%s\r%s", has_model[iSkin], model_name[i])
		num_to_str(i, szTempid, 31)
		menu_additem(menu, szItems, szTempid, 0)
	}
	
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
	menu_setprop(menu, MPROP_BACKNAME, "返回"); 
	menu_setprop(menu, MPROP_NEXTNAME, "更多"); 
	menu_setprop(menu, MPROP_EXITNAME, "退出"); 
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public compose_handler(id, menu, item)
{
	new sz_Name[ 32 ];
	
	get_user_name( id, sz_Name, 31 );

	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new data[6], szName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data, charsmax(data), szName, charsmax(szName), callback);
	
	new key = str_to_num(data);

	new iSkin = iPlayerHasSkin[id][key]
	if(iSkin == 1)
	{
		iSelected[id] = key
		sure_to_compose(id, key)
	}
	else client_printc(id, "\g[Compose] \y你没有皮肤%s !", model_name[key])
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public sure_to_compose(id, skinid)
{
		static option[64]
		formatex(option, charsmax(option), "\r你确定要拿%s来抽奖吗？", model_name[skinid])
		new menu = menu_create(option, "confirm_compose_handler");
		
		formatex(option, charsmax(option), "\y是的，我是欧皇！(消耗 \r%d\y 金币)", COMPOSE_COST)		
		menu_additem(menu, option, "1");
		menu_additem(menu, "\y不是，我手抖了。^n^n", "2");
		menu_additem(menu, "\y提示：皮肤越贵，爆率越高哦！", "5");
		
		menu_setprop(menu, MPROP_NUMBER_COLOR, "\r"); 
		menu_setprop(menu, MPROP_BACKNAME, "返回"); 
		menu_setprop(menu, MPROP_NEXTNAME, "更多..."); 
		menu_setprop(menu, MPROP_EXITNAME, "退出"); 
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		
		menu_display(id, menu, 0);
		return PLUGIN_HANDLED;
}

public confirm_compose_handler(id, menu, item)
{
	new sz_Name[ 32 ];
	
	get_user_name( id, sz_Name, 31 );

	if(item == MENU_EXIT)
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
			new iCoin = zpm_base_get_coin(id)
			if(iCoin >= COMPOSE_COST)
			{
			zpm_base_set_coin(id, zpm_base_get_coin(id) - COMPOSE_COST)
			try_compose_skin(id, iSelected[id])
			}
			else client_printc(id, "\g[Compose] \y没钱还想白嫖? 不可能的!")
		}
		case 2:
		{
			return PLUGIN_HANDLED;
		}
		case 5:
		{
			return PLUGIN_HANDLED;
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public try_compose_skin(id, skinid)
{
	if(!is_user_logged(id))
		return PLUGIN_HANDLED;

    new name[32]
    get_user_name(id,name,31)

	new MaxNum = 500
	if(model_cost[skinid] == 500) MaxNum = 970
	else if(model_cost[skinid] == 1000) MaxNum = 950
	else if(model_cost[skinid] == 1500) MaxNum = 920
	else if(model_cost[skinid] == 750) MaxNum = 965
	
	new cNum = random_num(1, MaxNum)
	switch(cNum)
	{
		case 436..476:
		{
			new comNum = random_num(1, 2)
			switch(comNum)
			{
				case 1:
				{
					if(iPlayerHasSkin[id][5] == 0)
					{
						iPlayerHasSkin[id][skinid] = 0
						iPlayerHasSkin[id][5] = 1
						log_compose(id, skinid, 5)
						save_data(id)
						client_printc(0, "\g[Compose] \t%s\y 使用了\t%s\y参与置换，成功置换\t【尼尔.2B】\y皮肤 !", name, model_name[skinid])
						return PLUGIN_HANDLED;
					}
					else
					{
						client_printc(0, "\g[Compose] \t%s\y 使用了\t%s\y参与置换，本来可以置换\t【尼尔.2B】\y皮肤，可惜他有了！", name, model_name[skinid])
						return PLUGIN_HANDLED;
					}
				}
				case 2:
				{
					if(iPlayerHasSkin[id][8] == 0)
					{
						iPlayerHasSkin[id][skinid] = 0
						iPlayerHasSkin[id][8] = 1
						log_compose(id, skinid, 8)
						save_data(id)
						client_printc(0, "\g[Compose] \t%s\y 使用了\t%s\y参与置换，成功置换\t【ELO-诗乃】\y皮肤 !", name, model_name[skinid])
						return PLUGIN_HANDLED;
					}
					else
					{
						client_printc(0, "\g[Compose] \t%s\y 使用了\t%s\y参与置换，本来可以置换\t【ELO-诗乃】\y皮肤，可惜他有了！", name, model_name[skinid])
						return PLUGIN_HANDLED;
					}
				}
			}
		}
		case 604..699:
		{
			new nSkin = random_num(1, 5)
			if(iPlayerHasSkin[id][nSkin] == 0)
			{
			iPlayerHasSkin[id][skinid] = 0
			iPlayerHasSkin[id][nSkin] = 1
			log_compose(id, skinid, nSkin)
			save_data(id)
			client_printc(0, "\g[Compose] \t%s\y 使用了\t%s\y参与置换，成功置换\t%s\y皮肤 !", name, model_name[skinid], model_name[nSkin])
			return PLUGIN_HANDLED;
			}
			else
			{
				client_printc(0, "\g[Compose] \t%s\y 使用了\t%s\y参与置换，本来可以置换\t%s\y皮肤，可惜已有！", name, model_name[skinid], model_name[nSkin])
				return PLUGIN_HANDLED;
			}
		}
	}

	client_printc(0, "\g[Compose] \t%s\y 使用了\t%s\y参与置换，可惜什么都没有获得 !", name, model_name[skinid])
	return PLUGIN_HANDLED;
}

public log_compose(id, oldskin, skinid)
{
    new name[32]
    get_user_name(id,name,31)
	
	log_to_file(log_file, "[Compose] %s 成功使用%s合成皮肤%s.", name, model_name[oldskin], model_name[skinid])
}

public Native_Get_Skin(id, skinid) return iPlayerHasSkin[id][skinid]