
#if defined _register_system_included
  #endinput
#endif
#define _register_system_included

native set_block_name_change(id, bool:stats)
native is_user_logged(id)
native auth_user_password(id, pw[])
native force_logout(id)

forward client_logged(id)