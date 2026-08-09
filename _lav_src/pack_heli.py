# -*- coding: utf-8 -*-
"""Временная обшивка вертолёта: icons/mountain_wars/helicopter.dmi.

Один стейт heli_shell размером 384x160 (12x5 тайлов). Рисунок черновой —
нужен только чтобы проверить механику скрытия. Настоящий спрайт кладётся
поверх с тем же именем стейта и тем же размером.
"""
import os
from PIL import Image, ImageDraw
from PIL.PngImagePlugin import PngInfo

W, H = 384, 160
DST = r'C:\Users\PAVEL\Documents\GitHub\Mountain-Wars\icons\mountain_wars\helicopter.dmi'

im = Image.new('RGBA', (W, H), (0, 0, 0, 0))
d = ImageDraw.Draw(im)

BODY = (58, 68, 48, 255)
EDGE = (34, 40, 28, 255)
GLASS = (86, 110, 120, 255)
ROTOR = (24, 24, 24, 90)

# хвостовая балка, запад
d.rectangle([4, 64, 96, 96], fill=BODY, outline=EDGE)
d.rectangle([4, 40, 16, 120], fill=BODY, outline=EDGE)          # киль
# фюзеляж
d.rounded_rectangle([64, 16, 352, 144], radius=24, fill=BODY, outline=EDGE, width=2)
# кабина, восток
d.rounded_rectangle([300, 40, 348, 120], radius=16, fill=GLASS, outline=EDGE, width=2)
# аппарель, запад — вход внутрь
d.rectangle([64, 64, 96, 96], fill=(40, 46, 32, 255), outline=EDGE)
# диск несущего винта
d.ellipse([48, -88, 368, 232], outline=ROTOR, width=3)

info = PngInfo()
info.add_text('Description', '\n'.join([
    '# BEGIN DMI', 'version = 4.0',
    '\twidth = %d' % W, '\theight = %d' % H,
    'state = "heli_shell"', '\tdirs = 1', '\tframes = 1',
    '# END DMI', '',
]), zip=True)
im.save(os.path.abspath(DST), format='PNG', pnginfo=info, optimize=True)
print('записано:', os.path.abspath(DST), im.size)
