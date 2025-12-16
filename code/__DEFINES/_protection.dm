///Protects a datum from being VV'd
#ifndef TESTING
#define GENERAL_PROTECT_DATUM(Path)\
##Path/can_vv_get(var_name){\
	return FALSE;\
}\
##Path/vv_edit_var(var_name, var_value){\
	return FALSE;\
}\
##Path/CanProcCall(procname){\
	return FALSE;\
}
#else
#define GENERAL_PROTECT_DATUM(Path)
#endif
