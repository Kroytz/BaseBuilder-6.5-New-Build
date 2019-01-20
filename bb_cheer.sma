
#include <amxmodx>
#include <cstrike>
#include <colorchat>

new const cheerpath[][] = { "zmParadise/cheer/cheer_1.wav", "zmParadise/cheer/cheer_2.wav", "zmParadise/cheer/cheer_3.wav", "zmParadise/cheer/cheer_4.wav", "zmParadise/cheer/cheer_5.wav", "zmParadise/cheer/cheer_6.wav", "zmParadise/cheer/cheer_7.wav", "zmParadise/cheer/cheer_8.wav", "zmParadise/cheer/cheer_9.wav", "zmParadise/cheer/cheer_10.wav" }
new const jeerpath[] = { "zmParadise/cheer/jeer.wav" }
new const bakapath[] = { "zmParadise/cheer/cirno.wav" }
new Float:lastcheer[33]

native zpm_models_get_selection(id)
native zp_donater_get_level(id)

public plugin_init()
{
	register_plugin("Cheer", "2.5", "Para")

	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")

	register_concmd("consolecheer", "cmdconsolecheer", _, "Console Cheer", 0)
	register_concmd("consolejeer", "cmdconsolejeer", _, "Console Jeer", 0)
	register_clcmd("cheer", "CmdCheer")
	//register_clcmd("cirno_cheer", "CmdCirnoCheer")
	register_clcmd("say cheer", "CmdCheer")
	register_clcmd("say_team cheer", "CmdCheer")
	register_clcmd("say !cheer", "CmdCheer")
	register_clcmd("say_team !cheer", "CmdCheer")
	register_clcmd("say /cheer", "CmdCheer")
	register_clcmd("say_team /cheer", "CmdCheer")
	register_clcmd("say jeer", "CmdCheer")
	register_clcmd("say_team jeer", "CmdCheer")
	register_clcmd("say !jeer", "CmdCheer")
	register_clcmd("say_team !jeer", "CmdCheer")
	register_clcmd("say /jeer", "CmdCheer")
	register_clcmd("say_team /jeer", "CmdCheer")
	register_clcmd("say /laugh", "CmdCheer")
	register_clcmd("say_team /laugh", "CmdCheer")
}

public plugin_precache()
{
	for(new i = 0; i<sizeof cheerpath; i++)
		precache_sound(cheerpath[i])

	precache_sound(jeerpath)
	//precache_sound(bakapath)
}

public client_putinserver(id)
{
	set_task(5.0, "bindkey", id)
}

public bindkey(id)
{
	client_cmd(id, "bind j cheer")
}

public cmdconsolecheer(id)
{
	if(!(get_user_flags(id) & ADMIN_KICK))
		return PLUGIN_HANDLED

	ColorChat(0, GREEN, "^1伺服器控制台 ^4cheered!!!")
	client_cmd(0, "spk %s", cheerpath[random_num(0, sizeof cheerpath - 1)])

	return PLUGIN_HANDLED
}

public cmdconsolejeer(id)
{
	if(!(get_user_flags(id) & ADMIN_KICK))
		return PLUGIN_HANDLED

	ColorChat(0, GREEN, "^1伺服器控制台 ^4jeered!!!")
	client_cmd(0, "spk %s", jeerpath)

	return PLUGIN_HANDLED
}

public event_round_start()
{
	remove_task()

	for(new i = 0; i<33; i++)
	{
		lastcheer[i] = 0.0
	}
}
/*
public CmdCirnoCheer(id)
{
	new name[33]
	get_user_name(id, name, 32)

	ColorChat(0, BLUE, "^3%s ^4baka!!!", name)
	PlaySound(0, bakapath)
	return PLUGIN_HANDLED
}
*/
public CmdCheer(id)
{
	if(lastcheer[id] != 0.0 && lastcheer[id] + 3.0 > get_gametime())
	{
		client_print(id, print_chat, "不能笑得太頻繁！")
		return PLUGIN_HANDLED
	}

	lastcheer[id] = get_gametime()

	new name[33]
	get_user_name(id, name, 32)

	if(is_user_alive(id))
	{
		if(get_user_team(id) == 1)
		{
			if(zp_donater_get_level(id) > 0) ColorChat(0, RED, "^3%s ^4c^3h^4e^1e^4r^3e^4d^1!^4!^3!", name)
			else ColorChat(0, RED, "^3%s ^4cheered!!!", name)
			
			emit_sound(id, CHAN_AUTO, cheerpath[random_num(0, sizeof cheerpath - 1)], 0.30, ATTN_NORM, 0, PITCH_NORM)
		}
		else
		{
			if(zpm_models_get_selection(id) == 5007)
				emit_sound(id, CHAN_AUTO, bakapath, 0.30, ATTN_NORM, 0, PITCH_NORM)
			else emit_sound(id, CHAN_AUTO, cheerpath[random_num(0, sizeof cheerpath - 1)], 0.30, ATTN_NORM, 0, PITCH_NORM)
		
			if(zp_donater_get_level(id) > 0) ColorChat(0, BLUE, "^3%s ^4c^3h^4e^1e^4r^3e^4d^1!^4!^3!", name)
			ColorChat(0, BLUE, "^3%s ^4cheered!!!", name)
		}
	}
	else
	{
		client_cmd(0, "spk %s", jeerpath)

		switch(get_user_team(id))
		{
			case 1:	ColorChat(0, RED, "^1*DEAD* ^3%s ^4jeered!!!", name)
			case 2:	ColorChat(0, BLUE, "^1*DEAD* ^3%s ^4jeered!!!", name)
			default: ColorChat(0, GREY, "^1*SPEC* ^3%s ^4jeered!!!", name)
		}
	}

	return PLUGIN_HANDLED
}

stock PlaySound(id, const sound[])
{
	if (equal(sound[strlen(sound)-4], ".mp3")) client_cmd(id, "mp3 play ^"sound/%s^"", sound)
	else client_cmd(id, "spk ^"%s^"", sound)
}