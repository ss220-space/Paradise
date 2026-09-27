import struct, zlib, sys
from PIL import Image

def read_desc(path):
    data = open(path,'rb').read()
    i = 8
    while i < len(data):
        ln = struct.unpack('>I', data[i:i+4])[0]
        typ = data[i+4:i+8]
        chunk = data[i+8:i+8+ln]
        if typ == b'zTXt':
            kw, rest = chunk.split(b'\x00',1)
            return zlib.decompress(rest[1:]).decode('latin1')
        if typ == b'tEXt':
            kw, txt = chunk.split(b'\x00',1)
            return txt.decode('latin1')
        i += 12 + ln
    raise ValueError('no desc chunk in '+path)

def parse_states(desc):
    """Return (width, height, [ (raw_block_lines, cell_count) ]) in order."""
    lines = desc.splitlines()
    width = height = 32
    states = []
    cur = None
    dirs = frames = 1
    def flush():
        nonlocal cur, dirs, frames
        if cur is not None:
            states.append([cur, dirs*frames])
        cur = None; dirs = 1; frames = 1
    for ln in lines:
        s = ln.strip()
        if s.startswith('width = '):
            width = int(s.split('=')[1])
        elif s.startswith('height = '):
            height = int(s.split('=')[1])
        elif s.startswith('state = '):
            flush()
            cur = [ln]
        elif cur is not None and (s.startswith('# END') or s.startswith('state =')):
            pass
        elif cur is not None:
            cur.append(ln)
            if s.startswith('dirs = '):
                dirs = int(s.split('=')[1])
            elif s.startswith('frames = '):
                frames = int(s.split('=')[1])
    flush()
    return width, height, states

def load_cells(path):
    desc = read_desc(path)
    w, h, states = parse_states(desc)
    img = Image.open(path).convert('RGBA')
    cols = img.width // w
    cells = []  # flat list of cell images in reading order
    total = sum(c for _, c in states)
    for idx in range(total):
        cx = (idx % cols) * w
        cy = (idx // cols) * h
        cells.append(img.crop((cx, cy, cx+w, cy+h)))
    # split per state
    out = []
    pos = 0
    for block, cnt in states:
        out.append((block, cells[pos:pos+cnt]))
        pos += cnt
    return w, h, out

def write_dmi(path, w, h, state_list):
    """state_list: [ (raw_block_lines:list[str], cells:list[Image]) ]"""
    total = sum(len(c) for _, c in state_list)
    import math
    cols = max(1, math.ceil(math.sqrt(total)))  # roughly square; BYOND tolerant
    rows = math.ceil(total / cols)
    sheet = Image.new('RGBA', (cols*w, rows*h), (0,0,0,0))
    flat = []
    for _, cells in state_list:
        flat.extend(cells)
    for idx, c in enumerate(flat):
        cx = (idx % cols) * w
        cy = (idx // cols) * h
        sheet.paste(c, (cx, cy))
    # build description
    desc_lines = ['# BEGIN DMI', 'version = 4.0', '\twidth = %d'%w, '\theight = %d'%h]
    for block, _ in state_list:
        desc_lines.extend(block)
    desc_lines.append('# END DMI')
    desc = '\n'.join(desc_lines) + '\n'
    # save base png to bytes
    import io
    buf = io.BytesIO()
    sheet.save(buf, 'PNG')
    png = buf.getvalue()
    # build zTXt chunk
    comp = zlib.compress(desc.encode('latin1'))
    payload = b'Description\x00\x00' + comp
    crc = zlib.crc32(b'zTXt'+payload) & 0xffffffff
    ztxt = struct.pack('>I', len(payload)) + b'zTXt' + payload + struct.pack('>I', crc)
    # insert ztxt before IDAT
    idx = png.find(b'IDAT') - 4
    out = png[:idx] + ztxt + png[idx:]
    open(path,'wb').write(out)

def get_state(state_list, name):
    for block, cells in state_list:
        if block[0].strip() == 'state = "%s"'%name:
            return block, cells
    return None

def splice(target, source, state_name):
    tw, th, tstates = load_cells(target)
    sw, sh, sstates = load_cells(source)
    assert (tw,th)==(sw,sh), 'size mismatch %s vs %s'%( (tw,th),(sw,sh))
    src = get_state(sstates, state_name)
    if src is None:
        raise ValueError('source has no state '+state_name)
    if get_state(tstates, state_name):
        # replace existing
        tstates = [(b,c) for (b,c) in tstates if b[0].strip()!='state = "%s"'%state_name]
    tstates.append(src)
    write_dmi(target, tw, th, tstates)
    print('spliced %s into %s (%d cells)'%(state_name, target, len(src[1])))

if __name__ == '__main__':
    target, source, name = sys.argv[1], sys.argv[2], sys.argv[3]
    splice(target, source, name)
