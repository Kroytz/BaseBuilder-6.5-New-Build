#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <cstrike>

#include <eg_boss>

#define weapon_name		"weapon_awp"
#define weapon_new		"weapon_pgmhecate"

#define ANIM_IDLE		0
#define ANIM_SHOOT_1		1
#define ANIM_SHOOT_2		2
#define ANIM_RELOAD		4
#define ANIM_DRAW		5

#define IDLE_TIME		1.7
#define DRAW_TIME		1.4
#define RELOAD_TIME		3.1

#define pData_Player				5
#define pData_Item				4

#define pDataKey_WeaponBoxItems			34

#define pDataKey_iOwner				41
#define pDataKey_iNext				42
#define pDataKey_iId				43

#define pDataKey_flNextPrimaryAttack		46
#define pDataKey_flNextSecondaryAttack		47
#define pDataKey_flNextTimeWeaponIdle		48
#define pDataKey_iPrimaryAmmoType		49
#define pDataKey_iClip				51
#define pDataKey_iInReload			54
#define pDataKey_iSpecialReload			55
#define pDataKey_iState				74

#define pDataKey_iLastHitGroup			75
#define pDataKey_flNextAttack			83

#define pDataKey_iPlayerItems			367
#define pDataKey_iActiveItem			373	
#define pDataKey_ibpAmmo			376
#define pDataKey_fEjectBrass                    111

#define pDataKey_szAnimExtention                1968

#define WEAPON_KEY				7572312354678975642
#define Is_CustomItem(%0)			(pev(%0,pev_impulse)==WEAPON_KEY)

#define model_v		"models/FAITH/v_pgm.mdl"
#define model_p		"models/FAITH/p_pgm.mdl"
#define model_w		"models/FAITH/w_pgm.mdl"

#define weapon_punchangle		1.0	
#define weapon_damage			9.3				
#define weapon_aspeed			1.23			
#define weapon_max_energy               100
#define weapon_energy_restore           0.1

#define weapon_ammo	5
#define weapon_bpammo 200
#define sound_shot	"weapons/pgm-1.wav"
#define MUZZLEFLASH "sprites/muz1.spr"

new g_Muzzleflash_Ent,g_Muzzleflash[33]
new Msg_WeaponList
new g_AllocString_V,g_AllocString_P
new g_ShellId,g_Energy[512],g_Beam_SprId
new g_item,g_Ent;

public plugin_precache(){
	engfunc(EngFunc_PrecacheModel,model_v)
	engfunc(EngFunc_PrecacheModel,model_p)
	engfunc(EngFunc_PrecacheModel,model_w)
	g_AllocString_V=engfunc(EngFunc_AllocString,model_v)
	g_AllocString_P=engfunc(EngFunc_AllocString,model_p)
	
	engfunc(EngFunc_PrecacheSound,sound_shot)
	engfunc(EngFunc_PrecacheSound,"weapons/pgm_clipin.wav")
	engfunc(EngFunc_PrecacheSound,"weapons/pgm_clipout.wav")
	engfunc(EngFunc_PrecacheSound,"weapons/pgm_pull.wav")
	engfunc(EngFunc_PrecacheSound,"weapons/pgm_push.wav")
	
	g_ShellId=engfunc(EngFunc_PrecacheModel,"models/rshell_big.mdl")
	
	g_Beam_SprId=engfunc(EngFunc_PrecacheModel,"sprites/zbeam2.spr")
	
	g_Muzzleflash_Ent=engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
	engfunc(EngFunc_PrecacheModel,MUZZLEFLASH)
	engfunc(EngFunc_SetModel,g_Muzzleflash_Ent,MUZZLEFLASH)
	set_pev(g_Muzzleflash_Ent,pev_scale,0.05)
	set_pev(g_Muzzleflash_Ent,pev_rendermode,kRenderTransTexture)
	set_pev(g_Muzzleflash_Ent,pev_renderamt,0.0)
	
	engfunc(EngFunc_PrecacheGeneric,"sprites/hecate.spr")
	engfunc(EngFunc_PrecacheGeneric,"sprites/weapon_pgmhecate.txt")
	
	register_forward(FM_Spawn,"HookFm_Spawn",0)
}
public plugin_init(){
	register_plugin("PGM Hecate II", "1.0", "UNKNOWN")
	register_clcmd(DEF_PGM_CODE, "get_item")

	RegisterHam(Ham_Item_Deploy,weapon_name,"HookHam_Weapon_Deploy",1)
	RegisterHam(Ham_Item_AddToPlayer,weapon_name,"HookHam_Weapon_Add",1)
	RegisterHam(Ham_Item_PostFrame,weapon_name,"HookHam_Weapon_Frame",0)
	
	RegisterHam(Ham_Weapon_Reload,weapon_name,"HookHam_Weapon_Reload",0)
	RegisterHam(Ham_Weapon_WeaponIdle,weapon_name,"HookHam_Weapon_Idle",0)
	RegisterHam(Ham_Weapon_PrimaryAttack,weapon_name,"HookHam_Weapon_PrimaryAttack",0)
	RegisterHam(Ham_TakeDamage,"player","HookHam_TakeDamage")
	
	register_forward(FM_SetModel,"HookFm_SetModel")
	register_forward(FM_AddToFullPack,"fw_AddToFullPack_post",1)
	register_forward(FM_CheckVisibility,"fw_CheckVisibility")
	
	register_forward(FM_UpdateClientData,"HookFm_UpdateClientData",1)
	
	Msg_WeaponList=get_user_msgid("WeaponList");
	register_clcmd(weapon_new,"hook_item")
}
public get_item(id){
	UTIL_DropWeapon(id,1);
	new weapon=make_weapon();if(weapon<=0)return
	if(!ExecuteHamB(Ham_AddPlayerItem,id,weapon)){engfunc(EngFunc_RemoveEntity,weapon);return;}
	ExecuteHam(Ham_Item_AttachToPlayer,weapon,id)
	new ammotype=pDataKey_ibpAmmo+get_pdata_int(weapon,pDataKey_iPrimaryAmmoType,pData_Item)
	new ammo=get_pdata_int(id,ammotype,pData_Player)
	if(ammo<weapon_bpammo)set_pdata_int(id,ammotype,weapon_bpammo,pData_Player)
	set_pdata_int(weapon,pDataKey_iClip,weapon_ammo,pData_Item)
	emit_sound(id,CHAN_ITEM,"items/gunpickup2.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM)
	g_Energy[weapon]=1
	g_Muzzleflash[id]=false
}
public hook_item(id){
	engclient_cmd(id,weapon_name)
	return PLUGIN_HANDLED
}
public fw_AddToFullPack_post(esState,iE,iEnt,iHost,iHostFlags,iPlayer,pSet){
	if(iEnt==g_Muzzleflash_Ent){
		if(g_Muzzleflash[iHost]){
			set_es(esState,ES_Frame,float(random_num(0,2)))
			set_es(esState,ES_RenderMode,kRenderTransAdd)
			set_es(esState,ES_RenderAmt,255.0)
			g_Muzzleflash[iHost]=false
		}	
		set_es(esState,ES_Skin,iHost)
		set_es(esState,ES_Body,1)
		set_es(esState,ES_AimEnt,iHost)
		set_es(esState,ES_MoveType,MOVETYPE_FOLLOW)
	} 
}
public fw_CheckVisibility(iEntity,pSet){
	if(iEntity==g_Muzzleflash_Ent){
		forward_return(FMV_CELL,1)
		return FMRES_SUPERCEDE
	} 
	return FMRES_IGNORED
}
public HookHam_Weapon_Deploy(ent){
	if(!Is_CustomItem(ent))return HAM_IGNORED
	static id;id=get_pdata_cbase(ent,pDataKey_iOwner,pData_Item)

	set_pev_string(id,pev_viewmodel2,g_AllocString_V)
	set_pev_string(id,pev_weaponmodel2,g_AllocString_P)
	set_pdata_float(ent,pDataKey_flNextPrimaryAttack,DRAW_TIME,pData_Item)
	set_pdata_float(ent,pDataKey_flNextSecondaryAttack,DRAW_TIME,pData_Item)
	set_pdata_float(ent,pDataKey_flNextTimeWeaponIdle,DRAW_TIME,pData_Item)
	Play_WeaponAnim(id,ANIM_DRAW)
	set_pdata_string(id,pDataKey_szAnimExtention,"rifle",-1,20);
	g_Energy[ent]=1
	g_Ent=ent
	return HAM_IGNORED
}
public HookHam_Weapon_Add(ent,id){
	switch(pev(ent,pev_impulse)){
		case WEAPON_KEY:Weaponlist(id,true)
		case 0:Weaponlist(id,false)
	}
	return HAM_IGNORED
}
public HookHam_Weapon_Frame(ent){
	if(!Is_CustomItem(ent))return HAM_IGNORED;
	static id;id=get_pdata_cbase(ent,pDataKey_iOwner,pData_Item);
	if(get_pdata_int(ent,pDataKey_iInReload,pData_Item)){
		static clip,ammotype,ammo,j
		clip=get_pdata_int(ent,pDataKey_iClip,pData_Item);
		ammotype=pDataKey_ibpAmmo+get_pdata_int(ent,pDataKey_iPrimaryAmmoType,pData_Item);
		ammo=get_pdata_int(id,ammotype,pData_Player);
		j=min(weapon_ammo-clip,ammo);
		set_pdata_int(ent,pDataKey_iClip,clip+j,pData_Item);
		set_pdata_int(id,ammotype,ammo-j,pData_Player);
		set_pdata_int(ent,pDataKey_iInReload,0,pData_Item);
	}
	if(cs_get_user_zoom(id)==2||cs_get_user_zoom(id)==3){
		client_print(id,print_center,"| 蓄  %d  能 |",g_Energy[ent])
		if(g_Energy[ent]<weapon_max_energy){
			static Float:EnergyTime[512];
			if((EnergyTime[ent]+weapon_energy_restore)<get_gametime()){
				EnergyTime[ent]=get_gametime()
				g_Energy[ent]++
			}
		}
	}
	else{
		g_Energy[ent]=1
	}
	return HAM_IGNORED;
}
public HookHam_Weapon_Reload(ent){
	if(!Is_CustomItem(ent))return HAM_IGNORED;
	
	static clip;clip=get_pdata_int(ent,pDataKey_iClip,pData_Item);
	if(clip>=weapon_ammo)return HAM_SUPERCEDE;
	
	static id;id=get_pdata_cbase(ent,pDataKey_iOwner,pData_Item);
	if(get_pdata_int(id,pDataKey_ibpAmmo+get_pdata_int(ent,pDataKey_iPrimaryAmmoType,pData_Item),pData_Player)<=0)return HAM_SUPERCEDE
	
	set_pdata_int(ent,pDataKey_iClip,0,pData_Item);
	ExecuteHam(Ham_Weapon_Reload,ent);
	set_pdata_int(ent,pDataKey_iClip,clip,pData_Item);
	set_pdata_int(ent,pDataKey_iInReload,1,pData_Item);
	set_pdata_float(ent,pDataKey_flNextPrimaryAttack,RELOAD_TIME,pData_Item)
	set_pdata_float(ent,pDataKey_flNextSecondaryAttack,RELOAD_TIME,pData_Item)
	set_pdata_float(ent,pDataKey_flNextTimeWeaponIdle,RELOAD_TIME,pData_Item)
	set_pdata_float(id,pDataKey_flNextAttack,RELOAD_TIME,pData_Player)
	Play_WeaponAnim(id,ANIM_RELOAD)
	return HAM_SUPERCEDE;
}
public HookHam_Weapon_Idle(ent){
	if(!Is_CustomItem(ent))return HAM_IGNORED
	if(get_pdata_float(ent,pDataKey_flNextTimeWeaponIdle,pData_Item)>0.0)return HAM_IGNORED
	set_pdata_float(ent,pDataKey_flNextTimeWeaponIdle,IDLE_TIME,pData_Item)
	Play_WeaponAnim(get_pdata_cbase(ent,pDataKey_iOwner,pData_Item),ANIM_IDLE)
	return HAM_SUPERCEDE
}
public HookHam_Weapon_PrimaryAttack(ent){
	if(!Is_CustomItem(ent))return HAM_IGNORED
	static ammo;ammo=get_pdata_int(ent,pDataKey_iClip,pData_Item);
	if(ammo<=0){
		ExecuteHam(Ham_Weapon_PlayEmptySound,ent);
		set_pdata_float(ent,pDataKey_flNextPrimaryAttack,weapon_aspeed,pData_Item)
		return HAM_SUPERCEDE
	}
		
	static id;id=get_pdata_cbase(ent,pDataKey_iOwner,pData_Item)
	static Float:user_punchangle[3];pev(id,pev_punchangle,user_punchangle)
	static fm_hooktrace;fm_hooktrace=register_forward(FM_TraceLine,"HookFm_TraceLine",true)
	static fm_playbackevent;fm_playbackevent=register_forward(FM_PlaybackEvent,"HookFm_PlayBackEvent",false)
	
	state FireBullets: Enabled;
	ExecuteHam(Ham_Weapon_PrimaryAttack,ent)
	state FireBullets: Disabled;
	
	unregister_forward(FM_TraceLine,fm_hooktrace,true)
	unregister_forward(FM_PlaybackEvent,fm_playbackevent,false)
	
	set_pdata_int(ent,57,g_ShellId,4)
	set_pdata_float(id,pDataKey_fEjectBrass,get_gametime()+0.6)
	
	Play_WeaponAnim(id,random_num(ANIM_SHOOT_1,ANIM_SHOOT_2))
	set_pdata_int(ent,pDataKey_iClip,ammo-1,pData_Item)
	set_pdata_float(ent,pDataKey_flNextTimeWeaponIdle,2.0,pData_Item)
	static Float:user_newpunch[3];pev(id,pev_punchangle,user_newpunch)
	
	user_newpunch[0]=user_punchangle[0]+(user_newpunch[0]-user_punchangle[0])*weapon_punchangle
	user_newpunch[1]=user_punchangle[1]+(user_newpunch[1]-user_punchangle[1])*weapon_punchangle
	user_newpunch[2]=user_punchangle[2]+(user_newpunch[2]-user_punchangle[2])*weapon_punchangle
	set_pev(id,pev_punchangle,user_newpunch)

	emit_sound(id,CHAN_WEAPON,sound_shot,VOL_NORM,ATTN_NORM,0,PITCH_NORM)

	set_pdata_float(ent,pDataKey_flNextPrimaryAttack,weapon_aspeed,pData_Item)
	
	g_Muzzleflash[id]=true
	
	if(g_Energy[ent]>=weapon_max_energy-30){
		static Float:g_VecStartBeam[3], Float:EndOrigin[3], Float:g_VecEndBeam[3]
		
		Stock_Get_Postion(id, 40.0, 7.5, -5.0, g_VecStartBeam)
		Stock_Get_Postion(id, 4096.0, 0.0, 0.0, EndOrigin)
	
		static TrResult; TrResult = create_tr2()
		engfunc(EngFunc_TraceLine, g_VecStartBeam, EndOrigin, IGNORE_MONSTERS, id, TrResult) 
		get_tr2(TrResult, TR_vecEndPos, g_VecEndBeam)
		free_tr2(TrResult)
	
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_BEAMPOINTS)
		engfunc(EngFunc_WriteCoord,g_VecStartBeam[0])
		engfunc(EngFunc_WriteCoord,g_VecStartBeam[1])
		engfunc(EngFunc_WriteCoord,g_VecStartBeam[2])
		engfunc(EngFunc_WriteCoord,g_VecEndBeam[0])
		engfunc(EngFunc_WriteCoord,g_VecEndBeam[1])
		engfunc(EngFunc_WriteCoord,g_VecEndBeam[2])
		write_short(g_Beam_SprId) 
		write_byte(1) 
		write_byte(1) 
		write_byte(5) 
		write_byte(30) 
		write_byte(0) 
		write_byte(0)
		write_byte(255)
		write_byte(0)
		write_byte(255)
		write_byte(10)
		message_end()
	}
	
	return HAM_SUPERCEDE
}
public HookHam_TakeDamage(victim,inflictor,attacker,Float:damage)<FireBullets: Enabled>{ 
	SetHamParamFloat(4,damage*1.02 + (weapon_damage*g_Energy[g_Ent]));
	return HAM_OVERRIDE;
}
public HookHam_TakeDamage()<FireBullets: Disabled>{ 
	return HAM_IGNORED;
}
public HookFm_SetModel(ent){ 
	static i,classname[32],item;pev(ent,pev_classname,classname,31);
	if(!equal(classname,"weaponbox"))return FMRES_IGNORED;
	for(i=0;i<6;i++){
		item=get_pdata_cbase(ent,pDataKey_WeaponBoxItems+i,4);
		if(item>0 && Is_CustomItem(item)){
			engfunc(EngFunc_SetModel,ent,model_w);
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}
public HookFm_PlayBackEvent(){ 
	return FMRES_SUPERCEDE
}
public HookFm_TraceLine(Float:tr_start[3],Float:tr_end[3],tr_flag,tr_ignore,tr){
	if(tr_flag&IGNORE_MONSTERS)return FMRES_IGNORED;
	static hit;hit=get_tr2(tr,TR_pHit)
	static Decal
	static glassdecal;if(!glassdecal)glassdecal=engfunc(EngFunc_DecalIndex,"{bproof1")
	hit=get_tr2(tr,TR_pHit)
	if(hit>0&&pev_valid(hit))
		if(pev(hit,pev_solid)!=SOLID_BSP)return FMRES_IGNORED
		else if(pev(hit,pev_rendermode)!=0)Decal=glassdecal
		else Decal=random_num(41,45)
	else Decal=random_num(41,45)

	static Float:vecEnd[3];get_tr2(tr,TR_vecEndPos,vecEnd)
	
	engfunc(EngFunc_MessageBegin,MSG_PAS,SVC_TEMPENTITY,vecEnd,0)
	write_byte(TE_GUNSHOTDECAL)
	engfunc(EngFunc_WriteCoord,vecEnd[0])
	engfunc(EngFunc_WriteCoord,vecEnd[1])
	engfunc(EngFunc_WriteCoord,vecEnd[2])
	write_short(hit>0?hit:0)
	write_byte(Decal)
	message_end()
	
	static Float:WallVector[3];get_tr2(tr,TR_vecPlaneNormal,WallVector)
	
	engfunc(EngFunc_MessageBegin,MSG_PVS,SVC_TEMPENTITY,vecEnd,0);
	write_byte(TE_STREAK_SPLASH)
	engfunc(EngFunc_WriteCoord,vecEnd[0]);
	engfunc(EngFunc_WriteCoord,vecEnd[1]);
	engfunc(EngFunc_WriteCoord,vecEnd[2]);
	engfunc(EngFunc_WriteCoord,WallVector[0]*random_float(25.0,30.0));
	engfunc(EngFunc_WriteCoord,WallVector[1]*random_float(25.0,30.0));
	engfunc(EngFunc_WriteCoord,WallVector[2]*random_float(25.0,30.0));
	write_byte(111)
	write_short(12)
	write_short(3)
	write_short(75)	
	message_end()
	
	return FMRES_IGNORED
}
public HookFm_UpdateClientData(id,SendWeapons,CD_Handle){
	static item;item=get_pdata_cbase(id,pDataKey_iActiveItem,pData_Player)
	if(item<=0||!Is_CustomItem(item))return FMRES_IGNORED
	set_cd(CD_Handle,CD_flNextAttack,99999.0)
	return FMRES_HANDLED
}
public HookFm_Spawn(id){
	if(pev_valid(id)!=2)return FMRES_IGNORED
	static ClName[32];pev(id,pev_classname,ClName,31)
	if(strlen(ClName)<5)return FMRES_IGNORED
	static Trie:ClBuffer;if(!ClBuffer)ClBuffer=TrieCreate()
	if(!TrieKeyExists(ClBuffer,ClName)){
		TrieSetCell(ClBuffer,ClName,1)
		RegisterHamFromEntity(Ham_TakeDamage,id,"HookHam_TakeDamage",0)
	}
	return FMRES_IGNORED
}
stock make_weapon(){
	static ent;
	static g_AllocString_E;
	if(g_AllocString_E||(g_AllocString_E=engfunc(EngFunc_AllocString,weapon_name)))
		ent=engfunc(EngFunc_CreateNamedEntity,g_AllocString_E)
	else return 0
	if(ent<=0)return 0;
	set_pev(ent,pev_spawnflags,SF_NORESPAWN);
	set_pev(ent,pev_impulse,WEAPON_KEY);
	ExecuteHam(Ham_Spawn,ent)
	return ent
}
stock UTIL_DropWeapon(id,slot){
	static iEntity;iEntity=get_pdata_cbase(id,(pDataKey_iPlayerItems+slot),pData_Player);
	if(iEntity>0){
		static iNext,szWeaponName[32];
		do{
			iNext=get_pdata_cbase(iEntity,pDataKey_iNext,4);
			if(get_weaponname(get_pdata_int(iEntity,pDataKey_iId,4),szWeaponName,31))
				engclient_cmd(id,"drop",szWeaponName)
		} while((iEntity=iNext)>0);
	}
}
stock Play_WeaponAnim(id,anim){
	set_pev(id,pev_weaponanim,anim)
	message_begin(MSG_ONE_UNRELIABLE,SVC_WEAPONANIM,_,id)
	write_byte(anim)
	write_byte(0)
	message_end()
}
stock Weaponlist(id,bool:set){
	if(!is_user_connected(id))return
	message_begin(MSG_ONE,Msg_WeaponList,_,id);
	write_string(set==false?weapon_name:weapon_new);
	write_byte(1);
	write_byte(weapon_bpammo);
	write_byte(-1);
	write_byte(-1);
	write_byte(0);
	write_byte(2);
	write_byte(18);
	write_byte(0);
	message_end();
}
stock get_weapon_position(id,Float:fOrigin[3],Float:add_forward=0.0,Float:add_right=0.0,Float:add_up=0.0){
	static Float:Angles[3],Float:ViewOfs[3],Float:vAngles[3]
	static Float:Forward[3],Float:Right[3],Float:Up[3]
	pev(id,pev_v_angle,vAngles)
	pev(id,pev_origin,fOrigin)
	pev(id,pev_view_ofs,ViewOfs)
	vec_add(fOrigin,ViewOfs,fOrigin)
	pev(id,pev_v_angle,Angles)
	engfunc(EngFunc_MakeVectors,Angles)
	global_get(glb_v_forward,Forward)
	global_get(glb_v_right,Right)
	global_get(glb_v_up,Up)
	vec_mul_scalar(Forward,add_forward,Forward)
	vec_mul_scalar(Right,add_right,Right)
	vec_mul_scalar(Up,add_up,Up)
	fOrigin[0]=fOrigin[0]+Forward[0]+Right[0]+Up[0]
	fOrigin[1]=fOrigin[1]+Forward[1]+Right[1]+Up[1]
	fOrigin[2]=fOrigin[2]+Forward[2]+Right[2]+Up[2]
}
vec_add(const Float:in1[],const Float:in2[],Float:out[]){
	out[0]=in1[0]+in2[0];
	out[1]=in1[1]+in2[1];
	out[2]=in1[2]+in2[2];
}
vec_mul_scalar(const Float:vec[],Float:scalar,Float:out[]){
	out[0]=vec[0]*scalar;
	out[1]=vec[1]*scalar;
	out[2]=vec[2]*scalar;
}
stock Stock_Get_Postion(id,Float:forw,Float:right, Float:up,Float:vStart[])
{
	static Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]
	
	pev(id, pev_origin, vOrigin)
	pev(id, pev_view_ofs,vUp) //for player
	vec_add(vOrigin,vUp,vOrigin)
	pev(id, pev_v_angle, vAngle) // if normal entity ,use pev_angles
	
	angle_vector(vAngle,ANGLEVECTOR_FORWARD,vForward) //or use EngFunc_AngleVectors
	angle_vector(vAngle,ANGLEVECTOR_RIGHT,vRight)
	angle_vector(vAngle,ANGLEVECTOR_UP,vUp)
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
} 
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1049\\ f0\\ fs16 \n\\ par }
*/
