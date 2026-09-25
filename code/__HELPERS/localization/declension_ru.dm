/**
 * Возвращает правильную форму слова, соответствующую русскому склонению числительных.
 *
 * Учитывает правила русского языка, определяющие окончания числительных, на основе переданного числа.
 * Использует три формы: единственное число (1), двойственное число (2-4) и множественное число (5+).
 * Дробные числа используют форму двойственного числа (2-4) (родительный падеж ед. ч.); отрицательные склоняются по модулю.
 *
 * Аргументы:
 * * `num` - Число, для которого необходимо определить форму слова
 * * `single_name` - Форма слова для 1 (например, "стол")
 * * `double_name` - Форма слова для 2-4 (например, "стола")
 * * `multiple_name` - Форма слова для 5+ (например, "столов")
 */
/proc/declension_ru(num, single_name, double_name, multiple_name)
	SHOULD_BE_PURE(TRUE)
	if(!isnum(num))
		stack_trace("Invalid number argument in 'declension_ru' proc: [num]")
		return double_name
	if(!istext(single_name) || !istext(double_name) || !istext(multiple_name))
		stack_trace("Invalid word arguments in 'declension_ru' proc: [single_name], [double_name], [multiple_name]")
		return double_name
	if(!ISINTEGER(num))
		return double_name // дробные числа
	var/count = abs(num) // отрицательные склоняются, как их модуль
	if(((count % 10) == 1) && ((count % 100) != 11)) // 1, но не 11
		return single_name
	if(ISINRANGE(count % 10, 2, 4) && !ISINRANGE(count % 100, 12, 14)) // 2, 3, 4, но не 12, 13, 14
		return double_name
	return multiple_name // 5, 6, 7, 8, 9, 0


#define DECL_U_Y_0(num) declension_ru(num, "у", "ы", "")
#define DECL_0_A_OV(num) declension_ru(num, "", "а", "ов")
#define DECL_A_Y_0(num) declension_ru(num, "а", "ы", "")
#define DECL_E_YA_J(num) declension_ru(num, "е", "я", "й")
#define DECL_O_A_OV(num) declension_ru(num, "о", "а", "ов")
#define DECL_EN_NYA_NEJ(num) declension_ru(num, "ень", "ня", "ней")
#define DECL_KA_KI_EK(num) declension_ru(num, "ка", "ки", "ек")
#define DECL_0_Y_O(num) declension_ru(num, "", "ы", "о")
#define DECL_YU_I_J(num) declension_ru(num, "ю", "и", "й")
#define DECL_0_I_O(num) declension_ru(num, "", "и", "о")
#define DECL_OK_KA_KOV(num) declension_ru(num, "ок", "ка", "ков")
#define DECL_Y_0_0(num) declension_ru(num, "ы", "", "")
#define DECL_0_I_YEJ(num) declension_ru(num, "ь", "и", "ей")
#define DECL_YEJ_AMI_AMI(num) declension_ru(num, "ей", "ами", "ами")
#define DECL_OM_AMI_AMI(num) declension_ru(num, "ом", "ами", "ами")
#define DECL_OJ_AMI_AMI(num) declension_ru(num, "ой", "ами", "ами")
#define DECL_YE_AM_AM(num) declension_ru(num, "е", "ам", "ам")
#define DECL_YE_Y_0(num) declension_ru(num, "е", "ы", "")
#define DECL_A_O_O(num) declension_ru(num, "а", "о", "о")
#define DECL_0_O_O(num) declension_ru(num, "", "о", "о")
#define DECL_A_OV_OV(num) declension_ru(num, "а", "ов", "ов")
#define DECL_0_I_I(num) declension_ru(num, "", "и", "и")
#define DECL_0_Y_Y(num) declension_ru(num, "", "ы", "ы")
#define DECL_YE_AH_AH(num) declension_ru(num, "е", "ах", "ах")
#define DECL_SYA_OS_OS(num) declension_ru(num, "ся", "ось", "ось")
#define DECL_0_A_0(num) declension_ru(num, "", "а", "")
#define DECL_O_A_0(num) declension_ru(num, "о", "а", "")
#define DECL_O_I_I(num) declension_ru(num, "о", "и", "и")
#define DECL_J_YE_YE(num) declension_ru(num, "й", "е", "е")
#define DECL_J_H_H(num) declension_ru(num, "й", "х", "х")
#define DECL_YA_I_I(num) declension_ru(num, "я", "и", "и")
#define DECL_U_Y_Y(num) declension_ru(num, "у", "ы", "ы")
#define DECL_YEN_NO_NO(num) declension_ru(num, "ен", "но", "но")
#define DECL_OJE_YH_YH(num) declension_ru(num, "ое", "ых", "ых")
#define DECL_OJ_YH_YH(num) declension_ru(num, "ой", "ых", "ых")
#define DECL_YJ_YH_YH(num) declension_ru(num, "ый", "ых", "ых")
#define DECL_OGO_YH_YH(num) declension_ru(num, "ого", "ых", "ых")
