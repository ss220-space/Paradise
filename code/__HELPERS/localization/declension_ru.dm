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

// Секунд, минут, единиц
#define DECL_SEC_MIN(num) declension_ru(num, "у", "ы", "")
// Кредит, символ
#define DECL_CREDIT(num) declension_ru(num, "", "а", "ов")
