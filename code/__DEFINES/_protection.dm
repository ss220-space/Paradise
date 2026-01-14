/// Protects a datum from being VV'd
#ifndef TESTING
#define GENERAL_PROTECT_DATUM(Path)\
##Path/can_vv_get(var_name){\
	datum_protecting_flags = DPF_CAN_VV_GET;\
	return ..();\
}\
##Path/vv_edit_var(var_name, var_value){\
	datum_protecting_flags = DPF_VV_EDIT_VAR;\
	return ..();\
}\
##Path/CanProcCall(procname){\
	datum_protecting_flags = DPF_CANPROCCALL;\
	return ..();\
}\
##Path/Read(savefile/savefile){\
	del(src)/* we del instead of qdel because for security reasons we must ensure the datum does not exist if Read is called. qdel will not enforce this. */;\
}\
##Path/Write(savefile/savefile){\
	return;\
}
#else
#define GENERAL_PROTECT_DATUM(Path)
#endif

// Flags to protect the datum
/// Protects datum from [/datum/proc/CanProcCall]
#define DPF_CANPROCCALL (1<<0)
/// Protects datum from [/datum/proc/can_vv_get]
#define DPF_CAN_VV_GET (1<<1)
/// Protects datum from [/datum/proc/vv_edit_var]
#define DPF_VV_EDIT_VAR (1<<2)
