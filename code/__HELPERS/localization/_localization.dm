/**
 * Макрос для `declent_ru` для автоматической капитализации первой буквы.
 *
 * Аргументы:
 * * `target` - Атом, название которого нужно капитализировать
 * * `case_id` - Падеж для названия атома
 */
#define DECLENT_RU_CAP(target, case_id) capitalize(target.declent_ru(case_id))
