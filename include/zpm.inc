#if defined _zpm_included
  #endinput
#endif
#define _zpm_included

/*****************************
			API			
*****************************/

native zpm_api_set_player_model(id, const szModel[])
native zpm_api_reset_player_model(id)

/*****************************
			Base			
*****************************/

/*
	zpm_base_get_coin
用途:	获取玩家拥有金币
参数:	1.id - 玩家索引
返回值:	coin[id]
*/
native zpm_base_get_coin(id)

/*
	zpm_base_set_coin
主插件:	ZPM_Base
用途:	设置玩家拥有金币
参数:	1.id - 玩家索引
		2.iAmount - 数量
*/
native zpm_base_set_coin(id, iamount)

/*****************************
			Upgrade			
*****************************/

/*
	um_get_level
用途:	获取玩家当前等级
参数:	1.id - 玩家索引
返回值:	PlayerLevel[id]
*/
native um_get_level(id)

/*
	um_get_save
用途:	获取玩家是否保存
参数:	1.id - 玩家索引
返回值:	shengjixianzhi[id]
		1 为不保存
		0 为保存
*/
native um_get_save(id)

/*****************************
			Store			
*****************************/

/*
	zpm_store_get_equip_skin
用途:	获取玩家当前装备皮肤
参数:	1.id - 玩家索引
返回值:	iWearSkin[id]
*/
native zpm_store_get_equip_skin(id)

/*****************************
			ZP Main			
*****************************/

forward zpr_user_zclass_change_attempt(id, classid)
native zpr_get_zclass_unlock(id, zclass)
native zpr_set_zclass_unlock(id, zclass)
native zpr_set_zclass_need_unlock(zclass)