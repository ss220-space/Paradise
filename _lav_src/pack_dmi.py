# -*- coding: utf-8 -*-
"""Собирает icons/mountain_wars/vehicle_lav25.dmi из PNG-кадров.

Два способа, как удобнее.

Одним листом: рядом лежит lav25_sheet.png на 640x320 — та же раскладка, что у
template.png. Верхний ряд корпус, нижний башня, слева направо SOUTH, NORTH,
EAST, WEST. Рисуешь прямо поверх шаблона и сохраняешь одной картинкой.

Или отдельными кадрами, восемь картинок 160x160 с прозрачным фоном:

    lav25_south.png         lav25_turret_south.png
    lav25_north.png         lav25_turret_north.png
    lav25_east.png          lav25_turret_east.png
    lav25_west.png          lav25_turret_west.png    (необязательные)

Западные кадры можно не рисовать — тогда зеркалится восточный, как это сделано
у эталонной M113: её кадры E и W совпадают пиксель в пиксель.

.dmi — это обычный PNG, у которого раскладка кадров лежит в текстовом чанке
zTXt с именем Description. Кадры идут слева направо, по четыре в ряд, в порядке
SOUTH, NORTH, EAST, WEST для каждого стейта подряд.

Кроме сборки скрипт меряет геометрию и печатает готовый блок turret_offset для
/obj/vehicle/mw/lav25: кадры корпуса центрованы по машине, погон в них лежит не
в центре, и разницу код добирает сдвигом башни (см. align_turret в vehicles.dm).

Запуск:  python _lav_src/pack_dmi.py
"""
import os
import sys
from collections import deque

from PIL import Image
from PIL.PngImagePlugin import PngInfo

HERE = os.path.dirname(os.path.abspath(__file__))
DST = os.path.join(HERE, '..', 'icons', 'mountain_wars', 'vehicle_lav25.dmi')
SIZE = 224
TILE = 32
DARK = 60      # темнее — дыра погона, а не броня
DIRS = ('south', 'north', 'east', 'west')
STATES = ('lav25', 'lav25_turret')
# Цвета разметки из template.png: дожили до листа — значит слой не погасили.
GUIDE = ((226, 74, 74), (70, 104, 150), (103, 139, 187))
lengths, offsets, problems = {}, {}, []


SHEET = os.path.join(HERE, 'lav25_sheet.png')


def load_sheet():
    """Лист 640x320: ряд корпуса, ряд башни, по четыре направления в каждом."""
    im = Image.open(SHEET).convert('RGBA')
    if im.size != (4 * SIZE, len(STATES) * SIZE):
        sys.exit('lav25_sheet.png: %dx%d, а нужен %dx%d'
                 % (im.width, im.height, 4 * SIZE, len(STATES) * SIZE))
    return {(state, direction): im.crop((c * SIZE, r * SIZE,
                                         (c + 1) * SIZE, (r + 1) * SIZE))
            for r, state in enumerate(STATES)
            for c, direction in enumerate(DIRS)}


def load(state, direction):
    """Кадр направления. Запад, если его не нарисовали, зеркалит восток."""
    if sheet_frames:
        return sheet_frames[(state, direction)]
    path = os.path.join(HERE, '%s_%s.png' % (state, direction))
    if not os.path.exists(path):
        if direction != 'west':
            sys.exit('нет файла: %s' % os.path.basename(path))
        east = load(state, 'east')
        print('   west   <- зеркало east')
        return east.transpose(Image.FLIP_LEFT_RIGHT)
    im = Image.open(path).convert('RGBA')
    if im.size != (SIZE, SIZE):
        sys.exit('%s: кадр %dx%d, а нужен %dx%d'
                 % (os.path.basename(path), im.width, im.height, SIZE, SIZE))
    return im


def ring_offset(im):
    """Где лежит погон корпуса: центр крупнейшего тёмного пятна внутри силуэта.

    Пятна, выходящие на кромку силуэта, не в счёт — это колёса и тень по борту.
    Дыра под башню единственная лежит целиком внутри брони.
    """
    px = im.load()
    solid = [[px[x, y][3] > 128 for x in range(SIZE)] for y in range(SIZE)]
    dark = [[solid[y][x] and (0.299 * px[x, y][0] + 0.587 * px[x, y][1]
                              + 0.114 * px[x, y][2]) < DARK
             for x in range(SIZE)] for y in range(SIZE)]
    seen = [[False] * SIZE for _ in range(SIZE)]
    best = None
    for sy in range(SIZE):
        for sx in range(SIZE):
            if not dark[sy][sx] or seen[sy][sx]:
                continue
            blob, touches, queue = [], False, deque([(sx, sy)])
            seen[sy][sx] = True
            while queue:
                x, y = queue.popleft()
                blob.append((x, y))
                for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                    if not (0 <= nx < SIZE and 0 <= ny < SIZE) or not solid[ny][nx]:
                        touches = True
                    elif dark[ny][nx] and not seen[ny][nx]:
                        seen[ny][nx] = True
                        queue.append((nx, ny))
            if not touches and (best is None or len(blob) > len(best)):
                best = blob
    if not best:
        return None
    return (sum(p[0] for p in best) / len(best) - SIZE / 2,
            sum(p[1] for p in best) / len(best) - SIZE / 2)


def check(name, im):
    """Три промаха, которые в редакторе не заметны, а в игре видны сразу."""
    px = im.load()
    solid = 0
    for y in range(SIZE):
        for x in range(SIZE):
            if px[x, y][3] <= 128:
                continue
            solid += 1
            if px[x, y][:3] in GUIDE:
                problems.append('%s: остался цвет разметки — не погашен шаблон' % name)
                return
    if solid > 0.9 * SIZE * SIZE:
        problems.append('%s: кадр залит почти целиком — экспортнулся фон' % name)
    rim = range(SIZE)
    if any(px[x, y][3] > 128 for x in rim for y in (0, SIZE - 1)) or \
       any(px[x, y][3] > 128 for y in rim for x in (0, SIZE - 1)):
        problems.append('%s: содержимое упирается в край кадра — обрежется' % name)


def report(state, direction, im):
    name = '%s %s' % (state, direction)
    bb = im.getbbox()
    if not bb:
        problems.append('%s: пустой кадр' % name)
        print('   %-6s ПУСТОЙ КАДР' % direction)
        return
    check(name, im)
    w, h = bb[2] - bb[0], bb[3] - bb[1]
    half = SIZE / 2
    note = ''
    if state == STATES[0]:
        # Длина машины: по вертикали сверху, по горизонтали в профиль.
        lengths[direction] = h if direction in ('south', 'north') else w
        # Погон здесь больше не ищем. В исходнике его нет — крыша нарисована сплошной,
        # и ring_offset() цеплялся за люки, выдавая разный сдвиг на каждое направление.
        # Место башни теперь задаёт build_sheet.py: он центрует кадр корпуса не по
        # силуэту, а по точке посадки. Значит башня стоит ровно в центре кадра, и
        # turret_offset у /obj/vehicle/mw/lav25 остаётся пустым.
        half = SIZE / 2
        drift = max(abs((bb[0] + bb[2]) / 2 - half), abs((bb[1] + bb[3]) / 2 - half))
        note = 'силуэт смещён от центра на %d — это посадка башни' % round(drift)
    else:
        reach = max(half - bb[0], bb[2] - half, half - bb[1], bb[3] - half)
        note = 'вылет от оси %d из %d' % (reach, half)
        if reach > half - 2:
            problems.append('%s: ствол почти в краю кадра' % name)
    print('   %-6s %3dx%-3d px = %.1fx%.1f тайла   %s'
          % (direction, w, h, w / TILE, h / TILE, note))


sheet_frames = load_sheet() if os.path.exists(SHEET) else None
print('источник: %s\n' % ('lav25_sheet.png' if sheet_frames else 'отдельные кадры'))

frames = []
for state in STATES:
    print('%s:' % state)
    for direction in DIRS:
        im = load(state, direction)
        report(state, direction, im)
        frames.append(im)

if len(set(lengths.values())) > 1:
    problems.append('длина корпуса разная по направлениям (%s) — при развороте машина '
                    'будет расти и сжиматься'
                    % ', '.join('%s %d' % kv for kv in sorted(lengths.items())))

if offsets:
    # Кадры корпуса центрованы по машине, а не по погону, иначе длинная корма не
    # влезает в кадр. Эту разницу код добирает сдвигом башни — см. align_turret().
    print('\nвставить в /obj/vehicle/mw/lav25:\n')
    print('\tturret_offset = list(')
    for direction in DIRS:
        if direction in offsets:
            print('\t\t"[%s]" = list(%d, %d),' % (direction.upper(), *offsets[direction]))
    print('\t)')

if problems:
    print('\nнадо поправить:')
    for line in problems:
        print('   ' + line)

sheet = Image.new('RGBA', (4 * SIZE, len(frames) // 4 * SIZE), (0, 0, 0, 0))
for i, fr in enumerate(frames):
    sheet.paste(fr, ((i % 4) * SIZE, (i // 4) * SIZE))

lines = ['# BEGIN DMI', 'version = 4.0',
         '\twidth = %d' % SIZE, '\theight = %d' % SIZE]
for state in STATES:
    lines += ['state = "%s"' % state, '\tdirs = 4', '\tframes = 1']
lines += ['# END DMI', '']

info = PngInfo()
info.add_text('Description', '\n'.join(lines), zip=True)
sheet.save(os.path.abspath(DST), format='PNG', pnginfo=info, optimize=True)
print('\nзаписано: %s  (%dx%d)' % (os.path.abspath(DST), *sheet.size))
print('перед компиляцией закрой Dream Daemon — он держит paradise.rsc')
