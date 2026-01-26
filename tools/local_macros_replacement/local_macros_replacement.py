import glob
import re
import os
import sys

IGNORE_LOCALIZATION_FILE = [
    "localization.dm",
    "golem.dm"
]

def print_message(message: str, filename: str):
    print(f"{filename}: {message}")

REPLACEMENTS = [
    # (pattern, replacement, name)

    # declension_ru()
    (r'declension_ru\(([^,]+),\s*"у",\s*"ы",\s*""\)', r'DECL_SEC_MIN(\1)', 'DECL_SEC_MIN'),
    (r'declension_ru\(([^,]+),\s*"",\s*"а",\s*"ов"\)', r'DECL_CREDIT(\1)', 'DECL_CREDIT'),

    # pluralize_ru()
    (r'pluralize_ru\(([^,]+)\.gender,\s*"ёт",\s*"ют"\)', r'PLUR_YOT_YUT(\1)', 'PLUR_YOT_YUT'),
    (r'pluralize_ru\(gender,\s*"ёт",\s*"ют"\)', r'PLUR_YOT_YUT(src)', 'PLUR_YOT_YUT'),

    (r'pluralize_ru\(([^,]+)\.gender,\s*"ет",\s*"ут"\)', r'PLUR_ET_UT(\1)', 'PLUR_ET_UT'),
    (r'pluralize_ru\(gender,\s*"ет",\s*"ут"\)', r'PLUR_ET_UT(src)', 'PLUR_ET_UT'),

    (r'pluralize_ru\(([^,]+)\.gender,\s*"ит",\s*"ят"\)', r'PLUR_IT_YAT(\1)', 'PLUR_IT_YAT'),
    (r'pluralize_ru\(gender,\s*"ит",\s*"ят"\)', r'PLUR_IT_YAT(src)', 'PLUR_IT_YAT'),

    (r'pluralize_ru\(([^,]+)\.gender,\s*"ит",\s*"ат"\)', r'PLUR_IT_AT(\1)', 'PLUR_IT_AT'),
    (r'pluralize_ru\(gender,\s*"ит",\s*"ат"\)', r'PLUR_IT_AT(src)', 'PLUR_IT_AT'),

    (r'pluralize_ru\(([^,]+)\.gender,\s*"ет",\s*"ют"\)', r'PLUR_ET_YUT(\1)', 'PLUR_ET_YUT'),
    (r'pluralize_ru\(gender,\s*"ет",\s*"ют"\)', r'PLUR_ET_YUT(src)', 'PLUR_ET_YUT'),

    (r'pluralize_ru\(([^,]+)\.gender,\s*"",\s*"и"\)', r'PLUR_I(\1)', 'PLUR_I'),
    (r'pluralize_ru\(gender,\s*"",\s*"и"\)', r'PLUR_I(src)', 'PLUR_I'),

    (r'pluralize_ru\(([^,]+)\.gender,\s*"ёт",\s*"ут"\)', r'PLUR_YOT_UT(\1)', 'PLUR_YOT_UT'),
    (r'pluralize_ru\(gender,\s*"ёт",\s*"ут"\)', r'PLUR_YOT_UT(src)', 'PLUR_YOT_UT'),

    (r'pluralize_ru\(([^,]+)\.gender,\s*"жет",\s*"гут"\)', r'PLUR_JET_GUT(\1)', 'PLUR_JET_GUT'),
    (r'pluralize_ru\(gender,\s*"жет",\s*"гут"\)', r'PLUR_JET_GUT(src)', 'PLUR_JET_GUT'),

    (r'pluralize_ru\(([^,]+)\.gender,\s*"чет",\s*"тят"\)', r'PLUR_CHET_TYAT(\1)', 'PLUR_CHET_TYAT'),
    (r'pluralize_ru\(gender,\s*"чет",\s*"тят"\)', r'PLUR_CHET_TYAT(src)', 'PLUR_CHET_TYAT'),

    # genderize_ru()
    (r'genderize_ru\(([^,]+)\.gender,\s*"он",\s*"она",\s*"оно",\s*"они"\)', r'GEND_HE_SHE(\1)', 'GEND_HE_SHE'),
    (r'genderize_ru\(gender,\s*"он",\s*"она",\s*"оно",\s*"они"\)', r'GEND_HE_SHE(src)', 'GEND_HE_SHE'),

    (r'genderize_ru\(([^,]+)\.gender,\s*"Он",\s*"Она",\s*"Оно",\s*"Они"\)', r'GEND_HE_SHE_CAP(\1)', 'GEND_HE_SHE_CAP'),
    (r'genderize_ru\(gender,\s*"Он",\s*"Она",\s*"Оно",\s*"Они"\)', r'GEND_HE_SHE_CAP(src)', 'GEND_HE_SHE_CAP'),

    (r'genderize_ru\(([^,]+)\.gender,\s*"его",\s*"её",\s*"его",\s*"их"\)', r'GEND_HIS_HER(\1)', 'GEND_HIS_HER'),
    (r'genderize_ru\(gender,\s*"его",\s*"её",\s*"его",\s*"их"\)', r'GEND_HIS_HER(src)', 'GEND_HIS_HER'),

    (r'genderize_ru\(([^,]+)\.gender,\s*"Его",\s*"Её",\s*"Его",\s*"Их"\)', r'GEND_HIS_HER_CAP(\1)', 'GEND_HIS_HER_CAP'),
    (r'genderize_ru\(gender,\s*"Его",\s*"Её",\s*"Его",\s*"Их"\)', r'GEND_HIS_HER_CAP(src)', 'GEND_HIS_HER_CAP'),

    (r'genderize_ru\(([^,]+)\.gender,\s*"ему",\s*"ей",\s*"ему",\s*"им"\)', r'GEND_HIM_HER(\1)', 'GEND_HIM_HER'),
    (r'genderize_ru\(gender,\s*"ему",\s*"ей",\s*"ему",\s*"им"\)', r'GEND_HIM_HER(src)', 'GEND_HIM_HER'),

    (r'genderize_ru\(([^,]+)\.gender,\s*"нём",\s*"ней",\s*"нём",\s*"них"\)', r'GEND_ON_IN_HIM(\1)', 'GEND_ON_IN_HIM'),
    (r'genderize_ru\(gender,\s*"нём",\s*"ней",\s*"нём",\s*"них"\)', r'GEND_ON_IN_HIM(src)', 'GEND_ON_IN_HIM'),

    (r'genderize_ru\(([^,]+)\.gender,\s*"ся",\s*"ась",\s*"ось",\s*"ись"\)', r'GEND_SYA_AS_OS_IS(\1)', 'GEND_SYA_AS_OS_IS'),
    (r'genderize_ru\(gender,\s*"ся",\s*"ась",\s*"ось",\s*"ись"\)', r'GEND_SYA_AS_OS_IS(src)', 'GEND_SYA_AS_OS_IS'),

    (r'genderize_ru\(([^,]+)\.gender,\s*"",\s*"а",\s*"о",\s*"и"\)', r'GEND_A_O_I(\1)', 'GEND_A_O_I'),
    (r'genderize_ru\(gender,\s*"",\s*"а",\s*"о",\s*"и"\)', r'GEND_A_O_I(src)', 'GEND_A_O_I'),

    (r'genderize_ru\(([^,]+)\.gender,\s*"",\s*"а",\s*"о",\s*"ы"\)', r'GEND_A_O_Y(\1)', 'GEND_A_O_Y'),
    (r'genderize_ru\(gender,\s*"",\s*"а",\s*"о",\s*"ы"\)', r'GEND_A_O_Y(src)', 'GEND_A_O_Y'),

    (r'genderize_ru\(([^,]+)\.gender,\s*"",\s*"а",\s*"е",\s*"и"\)', r'GEND_A_E_I(\1)', 'GEND_A_E_I'),
    (r'genderize_ru\(gender,\s*"",\s*"а",\s*"е",\s*"и"\)', r'GEND_A_E_I(src)', 'GEND_A_E_I'),

    (r'genderize_ru\(([^,]+)\.gender,\s*"",\s*"ла",\s*"ло",\s*"ли"\)', r'GEND_LA_LO_LI(\1)', 'GEND_LA_LO_LI'),
    (r'genderize_ru\(gender,\s*"",\s*"ла",\s*"ло",\s*"ли"\)', r'GEND_LA_LO_LI(src)', 'GEND_LA_LO_LI'),

    (r'genderize_ru\(([^,]+)\.gender,\s*"ен",\s*"на",\s*"но",\s*"ны"\)', r'GEND_EN_NA_NO_NY(\1)', 'GEND_EN_NA_NO_NY'),
    (r'genderize_ru\(gender,\s*"ен",\s*"на",\s*"но",\s*"ны"\)', r'GEND_EN_NA_NO_NY(src)', 'GEND_EN_NA_NO_NY'),

    (r'genderize_ru\(([^,]+)\.gender,\s*"ем",\s*"ей",\s*"ем",\s*"их"\)', r'GEND_EM_EI_EM_IH(\1)', 'GEND_EM_EI_EM_IH'),
    (r'genderize_ru\(gender,\s*"ем",\s*"ей",\s*"ем",\s*"их"\)', r'GEND_EM_EI_EM_IH(src)', 'GEND_EM_EI_EM_IH'),

    (r'genderize_ru\(([^,]+)\.gender,\s*"ым",\s*"ой",\s*"ым",\s*"ыми"\)', r'GEND_YM_OI_YM_YMI(\1)', 'GEND_YM_OI_YM_YMI'),
    (r'genderize_ru\(gender,\s*"ым",\s*"ой",\s*"ым",\s*"ыми"\)', r'GEND_YM_OI_YM_YMI(src)', 'GEND_YM_OI_YM_YMI'),

    (r'genderize_ru\(([^,]+)\.gender,\s*"им",\s*"ей",\s*"им",\s*"ими"\)', r'GEND_IM_EI_IM_IMI(\1)', 'GEND_IM_EI_IM_IMI'),
    (r'genderize_ru\(gender,\s*"им",\s*"ей",\s*"им",\s*"ими"\)', r'GEND_IM_EI_IM_IMI(src)', 'GEND_IM_EI_IM_IMI'),

    (r'genderize_ru\(([^,]+)\.gender,\s*"ый",\s*"ая",\s*"ое",\s*"ые"\)', r'GEND_YI_AYA_OE_YE(\1)', 'GEND_YI_AYA_OE_YE'),
    (r'genderize_ru\(gender,\s*"ый",\s*"ая",\s*"ое",\s*"ые"\)', r'GEND_YI_AYA_OE_YE(src)', 'GEND_YI_AYA_OE_YE'),

    (r'genderize_ru\(([^,]+)\.gender,\s*"шёл",\s*"шла",\s*"шло",\s*"шли"\)', r'GEND_SHEL(\1)', 'GEND_SHEL'),
    (r'genderize_ru\(gender,\s*"шёл",\s*"шла",\s*"шло",\s*"шли"\)', r'GEND_SHEL(src)', 'GEND_SHEL'),

    (r'genderize_ru\(([^,]+)\.gender,\s*"ваш",\s*"вашу",\s*"ваше",\s*"ваши"\)', r'GEND_YOUR(\1)', 'GEND_YOUR'),
    (r'genderize_ru\(gender,\s*"ваш",\s*"вашу",\s*"ваше",\s*"ваши"\)', r'GEND_YOUR(src)', 'GEND_YOUR'),

    (r'genderize_ru\(([^,]+)\.gender,\s*"вашего",\s*"вашей",\s*"вашего",\s*"ваших"\)', r'GEND_YOURS(\1)', 'GEND_YOURS'),
    (r'genderize_ru\(gender,\s*"вашего",\s*"вашей",\s*"вашего",\s*"ваших"\)', r'GEND_YOURS(src)', 'GEND_YOURS'),

    (r'genderize_ru\(([^,]+)\.gender,\s*"ий",\s*"ая",\s*"ий",\s*"ие"\)', r'GEND_II_AYA_II_IE(\1)', 'GEND_II_AYA_II_IE'),
    (r'genderize_ru\(gender,\s*"ий",\s*"ая",\s*"ий",\s*"ие"\)', r'GEND_II_AYA_II_IE(src)', 'GEND_II_AYA_II_IE'),
]

COMPILED_PATTERNS = [(re.compile(pattern), replacement, name) for pattern, replacement, name in REPLACEMENTS]

def process_file(filepath: str) -> bool:
    try:
        with open(filepath, 'r', encoding='utf-8') as file:
            content = file.read()

        original_content = content
        replacements_made = []

        for pattern, replacement, name in COMPILED_PATTERNS:
            new_content, count = pattern.subn(replacement, content)
            if count > 0:
                content = new_content
                replacements_made.append((name, count))

        if content != original_content:
            with open(filepath, 'w', encoding='utf-8', newline='\n') as file:
                file.write(content)

            for macro_name, count in replacements_made:
                print_message(f"Replaced {count} occurrence(s) of {macro_name}", filepath)

        return False

    except Exception as e:
        print_message(f"Error processing file: {str(e)}", filepath)
        return True

def main():
    print("Auto replace started.")

    if len(sys.argv) > 1:
        dm_files = [sys.argv[1]]
    else:
        all_dm_files = glob.glob("**/*.dm", recursive=True)
        dm_files = [f for f in all_dm_files if os.path.basename(f) not in IGNORE_LOCALIZATION_FILE]

    error_count = 0
    for filepath in dm_files:
        if process_file(filepath):
            error_count += 1

    print(f"Processed {len(dm_files)} files, errors: {error_count}")

    sys.exit(1 if error_count > 0 else 0)

if __name__ == "__main__":
    main()
