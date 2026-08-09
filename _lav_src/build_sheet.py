# -*- coding: utf-8 -*-
"""Собирает lav25_sheet.png из Sprite-0002.ase.

В .ase восемь кадров разложены по холсту 4892x2446 сеткой 4x2, и каждый кадр
лежит отдельным слоем поверх слоя-подложки с разметкой. Подложку пропускаем по
размеру: она одна во весь холст.

Три вещи, которые скрипт делает и которые руками в редакторе делать больно:

  1. Снимает белый фон. Заливкой от кромки, а не по порогу яркости: светлые
     блики на броне порогом выедаются, а от края они отрезаны бронёй.
  2. Приводит все четыре кадра корпуса к одной длине и ставит их в кадр по
     центру силуэта. Иначе при развороте машина прыгает — ровно это и было
     в прежнем листе, где профиль сидел на 22 пикселя ниже вида сверху.
  3. Ставит башню в кадр по оси вращения, а не по габариту. Габарит у башни
     врёт: ствол в профиль длинный, сверху почти не виден, и центр рамки
     уезжает вслед за стволом.

Дальше кадры забирает pack_dmi.py — он же меряет погон на корпусе и печатает
готовый turret_offset.

Запуск:  python _lav_src/build_sheet.py
"""
import os
import struct
import sys
import zlib
from collections import deque

from PIL import Image, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, 'Sprite-0002.ase')
DST = os.path.join(HERE, 'lav25_sheet.png')
# Кадр большой не от щедрости. Всё считается от оси башни, потому что она стоит в
# центре кадра, и в половину кадра должны влезть трое: корма (MOUNT_ALONG длины
# корпуса), нос (остаток) и ствол в профиль. Корма и есть длинное плечо: при
# посадке 0.65 это 96 пикселей, ровно половина кадра 192 — и корма срезалась.
# Меняешь тут — правь pixel_x/pixel_y у /obj/vehicle/mw/lav25: они равны -(SIZE - 32) / 2.
# Скрипт сам проверит, что всё влезло, и скажет, если нет.
SIZE = 224
# Длина корпуса в кадре. M113 занимает 126 пикселей, то есть 3.9 тайла.
HULL_LENGTH = 148
# Толщина, до которой эрозия съедает выросты при поиске оси башни. Ствол в исходнике
# около 40 пикселей поперёк, тело башни — за 300, так что окно между ними широкое.
BARREL_ERODE = 51
# Башня идёт тем же масштабом, что и корпус — как нарисована, так и остаётся.
# Приводить её кадры к одной длине пробовали: в исходнике она нарисована в трёх
# размерах (397 пикселей вдоль оси на севере, 475 на юге, 597 в профиль), и
# выравнивание ужимает профильную на 28% вместе со стволом. Ствол от этого
# превращается в обрубок, а размерный разнобой глазу не мешает. Не выравниваем.

# --- Точка посадки башни. Своя на каждое направление. ---
#
# Погона в исходнике нет: крыша нарисована сплошной. Значит место башни задаём мы,
# и задаём его через корпус — кадр корпуса центруется не по силуэту, а по этой точке.
# Тогда башня просто стоит в центре кадра, turret_offset в DM не нужен, и при
# развороте машина не прыгает.
#
# Одной формулой на все четыре не выходит, и это не лень исходника, а его форма:
# кадры нарисованы по-разному детализированными. У северного корма занята аппарелью
# во всю ширину, у южного там пустая палуба; в профиль машина вообще другой высоты
# силуэта. Доля, попадающая на юге в чистое место, на севере садится на дверь.
# Поэтому таблица, а не число: правится ровно то направление, которое не нравится.
#
# Первое число — доля длины корпуса от носа. 0 нос, 1 корма.
# Второе — поперёк: у видов сверху доля ширины слева, у профиля доля высоты от крыши.
MOUNT = {
    'south': (0.57, 0.50),
    'north': (0.57, 0.50),
    'east': (0.57, 0.15),
    'west': (0.57, 0.15),
}

# Доводка в пикселях кадра, поверх долей. Доли меряются от габарита силуэта, а он
# у разных ракурсов обманывает по-разному: сверху в него входит корма с аппарелью,
# в профиль — колёса ниже днища. Проще не подгонять формулу, а сдвинуть на глаз.
#
# Куда едет БАШНЯ относительно корпуса: x вправо, y ВНИЗ. Значит «поднять башню» —
# это отрицательный y. Реализуется сдвигом корпуса в обратную сторону, потому что
# башня всегда стоит ровно в центре кадра.
NUDGE = {
    'south': (0, -7),
    'north': (0, -14),
    'east': (-5, 1),
    'west': (5, 1),
}

DIRS = ('south', 'north', 'east', 'west')
STATES = ('lav25', 'lav25_turret')


def read_cels(path, frame_index):
    """Слои-кадры указанного кадра .ase: (слой, x, y, картинка)."""
    data = open(path, 'rb').read()
    _, magic, frames, width, height, depth = struct.unpack('<IHHHHH', data[:14])
    if magic != 0xA5E0:
        sys.exit('%s: не aseprite' % os.path.basename(path))
    if depth != 32:
        sys.exit('%s: нужен RGBA, а глубина %d' % (os.path.basename(path), depth))
    pos, cels = 128, []
    for index in range(frames):
        size, _, old_count, _, _, new_count = struct.unpack('<IHHHHI', data[pos:pos + 16])
        chunk = pos + 16
        for _ in range(new_count or old_count):
            chunk_size, chunk_type = struct.unpack('<IH', data[chunk:chunk + 6])
            body = data[chunk + 6:chunk + chunk_size]
            if chunk_type == 0x2005 and index == frame_index:
                layer, x, y, _opacity, cel_type = struct.unpack('<HhhBH', body[:9])
                if cel_type == 2:  # сжатая картинка
                    cw, ch = struct.unpack('<HH', body[16:20])
                    image = Image.frombytes('RGBA', (cw, ch), zlib.decompress(body[20:]))
                    cels.append((layer, x, y, image))
            chunk += chunk_size
        pos += size
    return cels, width, height


def strip_background(image):
    """Гасит белый фон заливкой от кромки кадра."""
    image = image.convert('RGBA')
    width, height = image.size
    px = image.load()

    def is_background(pixel):
        return pixel[3] > 0 and min(pixel[:3]) > 225

    seen = [[False] * width for _ in range(height)]
    queue = deque()
    for x in range(width):
        for y in (0, height - 1):
            if is_background(px[x, y]) and not seen[y][x]:
                seen[y][x] = True
                queue.append((x, y))
    for y in range(height):
        for x in (0, width - 1):
            if is_background(px[x, y]) and not seen[y][x]:
                seen[y][x] = True
                queue.append((x, y))
    while queue:
        x, y = queue.popleft()
        px[x, y] = (0, 0, 0, 0)
        for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if 0 <= nx < width and 0 <= ny < height and not seen[ny][nx] and is_background(px[nx, ny]):
                seen[ny][nx] = True
                queue.append((nx, ny))
    return image


def pivot(image):
    """Ось вращения башни: центр тяжести её тела, из которого вытравлен ствол.

    Эрозией, а не по габариту и не по плотности строк. Габарит врёт грубее всего:
    ствол в профиль длинный, сверху почти не виден, и середина рамки уезжает вслед
    за ним. Плотность строк врёт тоньше — на кадре с юбкой и стволом разом полоса
    «плотных» строк выходит несимметричной. Эрозия просто съедает всё уже BARREL_ERODE
    пикселей, а тело башни втрое толще: оценка получается одинаковой на всех четырёх
    кадрах, и башня не гуляет при повороте.
    """
    mask = image.split()[3].point(lambda v: 255 if v > 128 else 0)
    body = mask.filter(ImageFilter.MinFilter(BARREL_ERODE))
    px = body.load()
    width, height = body.size
    total = x_sum = y_sum = 0
    for y in range(height):
        for x in range(width):
            if px[x, y]:
                x_sum += x
                y_sum += y
                total += 1
    if not total:
        sys.exit('кадр башни съеден эрозией целиком — уменьши BARREL_ERODE')
    return (x_sum / total, y_sum / total)


def mount(image, direction):
    """Точка посадки башни на кадре корпуса, в координатах исходника."""
    left, top, right, bottom = image.getbbox()
    along_fraction, across_fraction = MOUNT[direction]
    if direction in ('south', 'north'):
        length = bottom - top
        # Нос: у south он внизу кадра, у north наверху.
        along = (bottom - length * along_fraction if direction == 'south'
                 else top + length * along_fraction)
        return (left + (right - left) * across_fraction, along)
    length = right - left
    along = (right - length * along_fraction if direction == 'east'
             else left + length * along_fraction)
    return (along, top + (bottom - top) * across_fraction)


def place(image, scale, anchor, nudge=(0, 0)):
    """Масштабирует кадр и ставит его в SIZE так, чтобы anchor лёг в центр.

    nudge двигает КОРПУС, то есть башню он двигает в обратную сторону — см. NUDGE.

    Возвращает кадр и на сколько пикселей содержимое вылезло за кромку: обрезка
    тут молчаливая, а в игре это выглядит как отрубленная корма.
    """
    width = max(1, round(image.width * scale))
    height = max(1, round(image.height * scale))
    small = image.resize((width, height), Image.LANCZOS)
    box = small.getbbox()
    # Округляем сумму, а не слагаемые: сдвиг бывает дробным, и полпикселя в нём —
    # это «округли в другую сторону», а не «ничего не делай».
    left = round(SIZE / 2 - anchor[0] * scale + nudge[0])
    top = round(SIZE / 2 - anchor[1] * scale + nudge[1])
    clipped = max(0, -(left + box[0]), -(top + box[1]),
                  left + box[2] - SIZE, top + box[3] - SIZE)
    frame = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    frame.alpha_composite(small, (left, top))
    return frame, clipped


cels, canvas_w, canvas_h = read_cels(SRC, 1)
cell_w, cell_h = canvas_w // 4, canvas_h // len(STATES)

frames = {}
for layer, x, y, image in cels:
    if image.size == (canvas_w, canvas_h):
        continue  # подложка с разметкой
    col = int((x + image.width / 2) // cell_w)
    row = int((y + image.height / 2) // cell_h)
    frames[(row, col)] = strip_background(image)

missing = [(r, c) for r in range(len(STATES)) for c in range(4) if (r, c) not in frames]
if missing:
    sys.exit('в .ase нет кадров: %s' % ', '.join('%s %s' % (STATES[r], DIRS[c]) for r, c in missing))

# Масштаб корпуса — один на четыре кадра, по самому длинному: иначе машина при
# развороте меняет длину.
lengths = []
for col, direction in enumerate(DIRS):
    box = frames[(0, col)].getbbox()
    lengths.append(box[3] - box[1] if direction in ('south', 'north') else box[2] - box[0])
scale = HULL_LENGTH / max(lengths)
print('корпус в исходнике: %s -> масштаб %.4f' % (lengths, scale))

problems = []
turret_offset = {}
sheet = Image.new('RGBA', (4 * SIZE, len(STATES) * SIZE), (0, 0, 0, 0))
for row, state in enumerate(STATES):
    print('%s:' % state)
    for col, direction in enumerate(DIRS):
        image = frames[(row, col)]
        box = image.getbbox()
        if row == 0:
            # Корпус центруем по самой машине. Раньше центровали по точке посадки
            # башни — тогда башня садилась ровно, зато корпус уезжал с тайла, и в
            # игре спрайт стоял в стороне от хитбокса. Разницу теперь добирает
            # turret_offset в DM, для этого поле и заведено.
            box = image.getbbox()
            body = ((box[0] + box[2]) / 2, (box[1] + box[3]) / 2)
            anchor, nudge = body, (0, 0)
            # Куда от центра кадра уехала посадка башни — это и есть turret_offset.
            # pixel_y в BYOND растёт вверх, y картинки вниз, отсюда знак у второго.
            spot = mount(image, direction)
            shift = NUDGE[direction]
            turret_offset[direction] = (
                round((spot[0] - body[0]) * scale + shift[0]),
                -round((spot[1] - body[1]) * scale + shift[1]),
            )
            note = 'корпус по центру, башня %+d,%+d' % turret_offset[direction]
        else:
            anchor, nudge = pivot(image), (0, 0)
            note = 'ось вращения'
        frame, clipped = place(image, scale, anchor, nudge)
        if clipped:
            problems.append('%s %s: не влезло в кадр, срезано на %d px — растить SIZE '
                            'или двигать посадку' % (state, direction, clipped))
        out = frame.getbbox()
        print('   %-6s %3dx%-3d px = %.1fx%.1f тайла, %s (%.0f,%.0f)'
              % (direction, out[2] - out[0], out[3] - out[1],
                 (out[2] - out[0]) / 32, (out[3] - out[1]) / 32, note, *anchor))
        sheet.alpha_composite(frame, (col * SIZE, row * SIZE))

print('\nвставить в /obj/vehicle/mw/lav25:\n')
# Ключи числами: "[SOUTH]" в списке типа компилятор DM не берёт, ему нужна константа.
DIR_NUMBER = {'south': 2, 'north': 1, 'east': 4, 'west': 8}
print('\tturret_offset = list(')
for direction in DIRS:
    print('\t\t"%d" = list(%d, %d),  // %s'
          % (DIR_NUMBER[direction], *turret_offset[direction], direction.upper()))
print('\t)')

if problems:
    print('\nнадо поправить:')
    for line in problems:
        print('   ' + line)

sheet.save(DST)
print('\nзаписано: %s  (%dx%d)' % (DST, *sheet.size))
print('дальше:  python _lav_src/pack_dmi.py')
