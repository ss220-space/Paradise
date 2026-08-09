# -*- coding: utf-8 -*-
"""Рисует template.png — подложку для ручной сборки кадров ЛАВ.

Фон непрозрачный: на шахматке редактора полупрозрачный призрак не читается.
Подложку держать отдельным слоем и не экспортировать.

В каждой клетке:
  * рамка кадра 160x160 и сетка по 32 — размер тайла;
  * перекрестье в (80, 80) — ось, куда садится погон корпуса и основание башни;
  * силуэт M113 в натуральную величину — эталон масштаба;
  * пунктирный габарит 84x150 — куда целимся корпусом ЛАВ.

Запуск:  python _lav_src/make_template.py
"""
import os
import re

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
M113 = os.path.join(HERE, '..', 'icons', 'mountain_wars', 'vehicle_lav.dmi')
DST = os.path.join(HERE, 'template.png')

SIZE = 160
TILE = 32
LEN, WID = 150, 84          # цель по корпусу ЛАВ
DIRS = ('SOUTH', 'NORTH', 'EAST', 'WEST')

BG = (28, 30, 36)
GRID = (44, 48, 56)
BORDER = (70, 104, 150)
GHOST = (128, 136, 146)
TARGET = (96, 132, 96)
CROSS = (226, 74, 74)
LABEL = (108, 146, 196)


def m113_frames():
    """Четыре направления эталона, в своём исходном размере."""
    raw = Image.open(os.path.abspath(M113))
    w = int(re.search(r'width = (\d+)', raw.text['Description']).group(1))
    img = raw.convert('RGBA')
    return [img.crop((i * w, 0, (i + 1) * w, w)) for i in range(4)], w


def ghost(frame):
    """Силуэт эталона: заливка одним цветом, чтобы не спорил с твоим артом."""
    flat = Image.new('RGBA', frame.size, GHOST + (110,))
    flat.putalpha(frame.split()[3].point(lambda v: 110 if v > 40 else 0))
    return flat


def dashed(dr, box, colour, step=4):
    x0, y0, x1, y1 = box
    for x in range(x0, x1, step * 2):
        dr.line([x, y0, min(x + step, x1), y0], fill=colour)
        dr.line([x, y1, min(x + step, x1), y1], fill=colour)
    for y in range(y0, y1, step * 2):
        dr.line([x0, y, x0, min(y + step, y1)], fill=colour)
        dr.line([x1, y, x1, min(y + step, y1)], fill=colour)


frames, fw = m113_frames()
sheet = Image.new('RGBA', (SIZE * 4, SIZE * 2), BG + (255,))
dr = ImageDraw.Draw(sheet)

for row in range(2):
    for col in range(4):
        ox, oy = col * SIZE, row * SIZE
        for t in range(TILE, SIZE, TILE):
            dr.line([ox + t, oy, ox + t, oy + SIZE], fill=GRID)
            dr.line([ox, oy + t, ox + SIZE, oy + t], fill=GRID)
        dr.rectangle([ox, oy, ox + SIZE - 1, oy + SIZE - 1], outline=BORDER)

        # Эталон только под корпусом: у M113 башни нет, сравнивать нечего.
        if row == 0:
            sheet.alpha_composite(ghost(frames[col]),
                                  (ox + (SIZE - fw) // 2, oy + (SIZE - fw) // 2))
            long_side = col >= 2          # восток и запад лежат вдоль кадра
            w, h = (LEN, WID) if long_side else (WID, LEN)
            dashed(dr, [ox + (SIZE - w) // 2, oy + (SIZE - h) // 2,
                        ox + (SIZE + w) // 2, oy + (SIZE + h) // 2], TARGET)

        cx, cy = ox + SIZE // 2, oy + SIZE // 2
        dr.line([cx - 7, cy, cx + 7, cy], fill=CROSS)
        dr.line([cx, cy - 7, cx, cy + 7], fill=CROSS)
        dr.point([cx, cy], fill=(255, 255, 255))
        dr.text((ox + 4, oy + 3),
                ('HULL ' if row == 0 else 'TURRET ') + DIRS[col], fill=LABEL)

sheet.convert('RGB').save(os.path.abspath(DST))
print('записано: %s  (%dx%d)' % (os.path.abspath(DST), *sheet.size))
bb = frames[0].getbbox()
print('зелёный пунктир — целевой габарит корпуса %dx%d, серый силуэт — M113 %dx%d'
      % (WID, LEN, bb[2] - bb[0], bb[3] - bb[1]))
