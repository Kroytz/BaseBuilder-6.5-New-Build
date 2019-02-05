#if defined _eg_boss_included
  #endinput
#endif
#define _eg_boss_included

#define DEF_HK416_CODE "Hk416AssaultRifleHAHA"
#define DEF_KRISS_CODE "KrissSuperVSecondGunHAHA"
#define DEF_SPSMG_CODE "NewComenFkingPro"
#define DEF_FIRECRACKER_CODE "FireCrackerGLSec"
#define DEF_M32_CODE "GayGunM32Lun9GunJJ"

native z4e_burn_get(id);
native z4e_burn_set(id, Float:flTime, bDrawEffect);
forward z4e_fw_burn_set_pre(id, Float:flTime, bDrawEffect);
forward z4e_fw_burn_set_post(id, Float:flTime, bDrawEffect);

native get_user_xp(id)
native set_user_xp(id, value)

native get_user_level(id)
native set_user_level(id, value)

native get_user_cash(id)
native set_user_cash(id, value)

native get_user_sp(id)
native set_user_sp(id, value)

native get_user_gp(id)
native set_user_gp(id, value)

native is_user_in_zammo(id)

/*	Use Less
native get_user_fgun4(id)
native set_user_fgun4(id, value)
native get_user_fgun5(id)
native set_user_fgun5(id, value)
native get_user_fgun6(id)
native set_user_fgun6(id, value)
native get_user_fgun7(id)
native set_user_fgun7(id, value)
native get_user_fgun8(id)
native set_user_fgun8(id, value)
native get_user_fgun9(id)
native set_user_fgun9(id, value)
native get_user_fgun10(id)
native set_user_fgun10(id, value)

native get_round_level(value)
native set_round_level(value)

native give_hk416(id)
native give_poison(id)
native give_at4cs(id)
native give_c7(id)
native give_kriss(id)

native give_plasma(id)
native give_t7(id)
native give_t5(id)
native give_m32(id)
native give_buffak(id)
native give_sgdrill(id)
native give_tbex(id)
*/