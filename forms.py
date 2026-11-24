import re

TARGET_FILE = r"E:\GitHub\Parashiza\code\modules\paperwork\paper_premade.dm"
with open(TARGET_FILE, 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

# 1. Расширяем поля, которые стоят после <br> (на отдельной строке) до 36 подчёркиваний
content = re.sub(
    r'<br>\\\[_{5,}\\\]',
    r'<br>\\[____________________________________\\]',
    content
)

# 2. Переносим поле на новую строку после "Объясните свои намерения"
content = re.sub(
    r'(Объясните свои намерения)\s*\\\[_{5,}\\\]',
    r'\1<br>\\[____________________________________\\]',
    content
)

with open(TARGET_FILE, 'w', encoding='utf-8') as f:
    f.write(content)
print("Поля расширены!")
