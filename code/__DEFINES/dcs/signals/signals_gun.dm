#define COMSIG_GUN_FIRE "gun_fire"
#define COMSIG_MOB_GUN_FIRE "mob_gun_fire"
#define COMSIG_GUN_STOP_FIRE "gun_stop_fire"
#define COMSIG_GUN_AUTOFIREDELAY_MODIFIED "gun_firedelay_modified"
#define COMSIG_GUN_BURST_SHOTS_TO_FIRE_MODIFIED "gun_burstamount_modified"
#define COMSIG_GUN_BURST_SHOT_DELAY_MODIFIED "gun_burstdelay_modified"
#define COMSIG_GUN_AUTO_BURST_SHOT_DELAY_MODIFIED "gun_auto_burstdelay_modified"
#define COMSIG_GUN_USER_UNSET "gun_user_unset"
#define COMSIG_GUN_USER_SET "gun_user_set"
#define COMSIG_MOB_GUN_FIRED "mob_gun_fired"
#define COMSIG_MOB_GUN_COOLDOWN "mob_gun_cooldown"
/// Gun can shoot check signal (/mob/user)
#define COMSIG_GUN_CHECK_CAN_SHOOT "gun_can_shoot_check"
	///Return this in response if you want cancel gun attack
	#define GUN_CHECK_CANCEL_ATTACK (1<<0)
