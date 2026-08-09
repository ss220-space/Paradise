# -*- coding: utf-8 -*-
"""Показывает, как твои кадры сядут друг на друга в игре.

Берёт те же восемь PNG, что и pack_dmi.py, и склеивает их в одну картинку:
корпус, башня и совмещённый вид по всем четырём направлениям. Совмещение здесь
ровно такое же, как в движке — кадры кладутся друг на друга по центрам, и
больше ничего не происходит.

Запуск:  python _lav_src/preview.py
Смотреть: _lav_src/preview_out.png
"""
import os
import sys

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
DST = os.path.join(HERE, 'preview_out.png')
SIZE = 160
ZOOM = 3
DIRS = ('south', 'north', 'east', 'west')
BG = (35, 35, 42, 255)
CROSS = (255, 70, 70, 255)


SHEET = os.path.join(HERE, 'lav25_sheet.png')
STATES = ('lav25', 'lav25_turret')

if os.path.exists(SHEET):
    _sheet = Image.open(SHEET).convert('RGBA')
    sheet_frames = {(s, d): _sheet.crop((c * SIZE, r * SIZE,
                                        (c + 1) * SIZE, (r + 1) * SIZE))
                    for r, s in enumerate(STATES) for c, d in enumerate(DIRS)}
else:
    sheet_frames = None


def load(state, direction):
    if sheet_frames:
        return sheet_frames[(state, direction)]
    path = os.path.join(HERE, '%s_%s.png' % (state, direction))
    if not os.path.exists(path):
        if direction != 'west':
            sys.exit('нет файла: %s' % os.path.basename(path))
        return load(state, 'east').transpose(Image.FLIP_LEFT_RIGHT)
    im = Image.open(path).convert('RGBA')
    if im.size != (SIZE, SIZE):
        sys.exit('%s: кадр %dx%d, а нужен %dx%d'
                 % (os.path.basename(path), im.width, im.height, SIZE, SIZE))
    return im


rows = []
for d in DIRS:
    hull = load('lav25', d)
    turret = load('lav25_turret', d)
    both = hull.copy()
    both.alpha_composite(turret)
    rows.append((d, hull, turret, both))

sheet = Image.new('RGBA', (SIZE * 4, SIZE * 3), BG)
for col, (_, hull, turret, both) in enumerate(rows):
    for row, im in enumerate((hull, turret, both)):
        sheet.alpha_composite(im, (col * SIZE, row * SIZE))

sheet = sheet.resize((sheet.width * ZOOM, sheet.height * ZOOM), Image.NEAREST)
dr = ImageDraw.Draw(sheet)
for col in range(4):
    for row in range(3):
        cx = (col * SIZE + SIZE // 2) * ZOOM
        cy = (row * SIZE + SIZE // 2) * ZOOM
        dr.line([cx - 9, cy, cx + 9, cy], fill=CROSS)
        dr.line([cx, cy - 9, cx, cy + 9], fill=CROSS)
    dr.text((col * SIZE * ZOOM + 6, 4), DIRS[col].upper(), fill=(120, 160, 210, 255))
sheet.save(DST)
print('записано: %s' % DST)
print('строки: корпус / башня / совмещённые. Перекрестье — ось (80, 80).')
