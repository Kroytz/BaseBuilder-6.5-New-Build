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
��;:	��ȡ���ӵ�н��
����:	1.id - �������
����ֵ:	coin[id]
*/
native zpm_base_get_coin(id)

/*
	zpm_base_set_coin
�����:	ZPM_Base
��;:	�������ӵ�н��
����:	1.id - �������
		2.iAmount - ����
*/
native zpm_base_set_coin(id, iamount)

/*****************************
			Upgrade			
*****************************/

/*
	um_get_level
��;:	��ȡ��ҵ�ǰ�ȼ�
����:	1.id - �������
����ֵ:	PlayerLevel[id]
*/
native um_get_level(id)

/*
	um_get_save
��;:	��ȡ����Ƿ񱣴�
����:	1.id - �������
����ֵ:	shengjixianzhi[id]
		1 Ϊ������
		0 Ϊ����
*/
native um_get_save(id)

/*****************************
			Store			
*****************************/

/*
	zpm_store_get_equip_skin
��;:	��ȡ��ҵ�ǰװ��Ƥ��
����:	1.id - �������
����ֵ:	iWearSkin[id]
*/
native zpm_store_get_equip_skin(id)

/*****************************
			ZP Main			
*****************************/

forward zpr_user_zclass_change_attempt(id, classid)
native zpr_get_zclass_unlock(id, zclass)
native zpr_set_zclass_unlock(id, zclass)
native zpr_set_zclass_need_unlock(zclass)