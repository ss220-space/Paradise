/// Signal sent when a blob overmind picked a new strain (/mob/camera/blob/overmind, /datum/blobstrain/new_strain)
#define COMSIG_BLOB_SELECTED_STRAIN "blob_selected_strain"
/// Signal sent by a blob spore when it creates a zombie (/mob/living/basic/blob_minion/spore/spore, //mob/living/basic/blob_minion/zombie/zombie)
#define COMSIG_BLOB_ZOMBIFIED "blob_zombified"

/// Signal sent by a blob when it try expand
#define COMSIG_TRY_CONSUME_TURF "try_consume_turf"
	/// Component blocks consuming
	#define COMPONENT_CANT_CONSUME (1<<0)
