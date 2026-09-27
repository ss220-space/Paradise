"""Generates static colour fallbacks for engines without relative colour syntax.

Reads a built tgui bundle, resolves every hsl()/oklch() relative colour down to a
literal value and writes a stylesheet guarded by @supports, so that only engines
lacking the syntax pick it up.

Usage: gen_legacy_colors.py <bundle.css> <output.scss>
"""

import math
import re
import sys

NAMED = {
    "white": (255, 255, 255),
    "black": (0, 0, 0),
    "transparent": (0, 0, 0, 0.0),
    "red": (255, 0, 0),
    "gray": (128, 128, 128),
    "grey": (128, 128, 128),
}

REL = re.compile(r"^\s*(hsl|oklch|rgb|hwb)\(\s*from\s+(.*)\)\s*$", re.I | re.S)
DECL = re.compile(r"([-a-z0-9]+)\s*:\s*([^;]+)")


def parse_blocks(css):
    blocks = []
    pos = 0
    while True:
        brace = css.find("{", pos)
        if brace < 0:
            break
        end = css.find("}", brace)
        if end < 0:
            break
        selector = css[pos:brace].strip().strip("}").strip()
        body = css[brace + 1 : end]
        if selector and not selector.startswith("@"):
            blocks.append((selector, body))
        pos = end + 1
    return blocks



def take_colour_token(text):
    text = text.strip()
    if not text:
        return None, ""
    depth = 0
    for index, char in enumerate(text):
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
            if depth == 0:
                return text[: index + 1], text[index + 1 :]
        elif depth == 0 and char in " 	":
            return text[:index], text[index:]
    return text, ""


def split_args(text):
    """Splits colour components, tolerating minified css that glues them."""
    tokens, index = [], 0
    text = text.strip()
    while index < len(text):
        char = text[index]
        if char in " 	":
            index += 1
            continue
        if char == "/":
            tokens.append("/")
            index += 1
            continue
        start = index
        while index < len(text) and text[index] not in " 	/(":
            index += 1
        if index < len(text) and text[index] == "(":
            depth = 0
            while index < len(text):
                if text[index] == "(":
                    depth += 1
                elif text[index] == ")":
                    depth -= 1
                    if depth == 0:
                        index += 1
                        break
                index += 1
        tokens.append(text[start:index])
    return tokens


def hex_to_rgb(value):
    value = value.lstrip("#")
    if len(value) in (3, 4):
        value = "".join(char * 2 for char in value)
    channels = [int(value[i : i + 2], 16) for i in range(0, len(value), 2)]
    if len(channels) == 4:
        return (channels[0], channels[1], channels[2], channels[3] / 255)
    return tuple(channels[:3])


def hsl_to_rgb(hue, sat, light):
    hue = hue % 360
    sat = max(0.0, min(1.0, sat))
    light = max(0.0, min(1.0, light))
    chroma = (1 - abs(2 * light - 1)) * sat
    second = chroma * (1 - abs((hue / 60) % 2 - 1))
    match = light - chroma / 2
    table = [(chroma, second, 0), (second, chroma, 0), (0, chroma, second),
             (0, second, chroma), (second, 0, chroma), (chroma, 0, second)]
    red, green, blue = table[int(hue // 60) % 6]
    return tuple(round((channel + match) * 255) for channel in (red, green, blue))


def rgb_to_hsl(rgb):
    red, green, blue = [channel / 255 for channel in rgb[:3]]
    high, low = max(red, green, blue), min(red, green, blue)
    light = (high + low) / 2
    if high == low:
        return 0.0, 0.0, light
    delta = high - low
    sat = delta / (2 - high - low) if light > 0.5 else delta / (high + low)
    if high == red:
        hue = (green - blue) / delta + (6 if green < blue else 0)
    elif high == green:
        hue = (blue - red) / delta + 2
    else:
        hue = (red - green) / delta + 4
    return hue * 60, sat, light


def srgb_to_linear(channel):
    channel /= 255
    return channel / 12.92 if channel <= 0.04045 else ((channel + 0.055) / 1.055) ** 2.4


def linear_to_srgb(channel):
    value = channel * 12.92 if channel <= 0.0031308 else 1.055 * channel ** (1 / 2.4) - 0.055
    return max(0, min(255, round(value * 255)))


def rgb_to_oklch(rgb):
    red, green, blue = [srgb_to_linear(channel) for channel in rgb[:3]]
    long = (0.4122214708 * red + 0.5363325363 * green + 0.0514459929 * blue) ** (1 / 3)
    medium = (0.2119034982 * red + 0.6806995451 * green + 0.1073969566 * blue) ** (1 / 3)
    short = (0.0883024619 * red + 0.2817188376 * green + 0.6299787005 * blue) ** (1 / 3)
    light = 0.2104542553 * long + 0.7936177850 * medium - 0.0040720468 * short
    a_axis = 1.9779984951 * long - 2.4285922050 * medium + 0.4505937099 * short
    b_axis = 0.0259040371 * long + 0.7827717662 * medium - 0.8086757660 * short
    chroma = math.hypot(a_axis, b_axis)
    hue = math.degrees(math.atan2(b_axis, a_axis)) % 360
    return light, chroma, hue


def oklch_to_rgb(light, chroma, hue):
    a_axis = chroma * math.cos(math.radians(hue))
    b_axis = chroma * math.sin(math.radians(hue))
    long = (light + 0.3963377774 * a_axis + 0.2158037573 * b_axis) ** 3
    medium = (light - 0.1055613458 * a_axis - 0.0638541728 * b_axis) ** 3
    short = (light - 0.0894841775 * a_axis - 1.2914855480 * b_axis) ** 3
    red = 4.0767416621 * long - 3.3077115913 * medium + 0.2309699292 * short
    green = -1.2684380046 * long + 2.6097574011 * medium - 0.3413193965 * short
    blue = -0.0041960863 * long - 0.7034186147 * medium + 1.7076147010 * short
    return tuple(linear_to_srgb(channel) for channel in (red, green, blue))


def format_colour(rgb, alpha=None):
    red, green, blue = rgb[:3]
    if alpha is None and len(rgb) == 4:
        alpha = rgb[3]
    if alpha is not None and alpha < 0.999:
        return f"rgba({red},{green},{blue},{round(alpha, 3)})"
    return f"#{red:02x}{green:02x}{blue:02x}"


class Resolver:
    def __init__(self, variables, numbers):
        self.variables = variables
        self.numbers = numbers
        self.cache = {}

    def number(self, token, fallback=None):
        token = token.strip()
        if token.endswith("%"):
            token = token[:-1]
        if token.startswith("var("):
            name = token[4:].rstrip(")").split(",")[0].strip()
            if name in self.numbers:
                return float(self.numbers[name])
            return fallback
        try:
            return float(token)
        except ValueError:
            return fallback

    def colour(self, token, seen=None):
        token = token.strip()
        seen = seen or set()
        if token.startswith("var("):
            name = token[4:].rstrip(")").split(",")[0].strip()
            if name in seen or name not in self.variables:
                return None
            return self.colour(self.variables[name], seen | {name})
        if token.startswith("#"):
            return hex_to_rgb(token)
        if token.lower() in NAMED:
            return NAMED[token.lower()]
        match = re.match(r"rgba?\(([^)]*)\)", token, re.I)
        if match:
            parts = [p.strip() for p in re.split(r"[,\s/]+", match.group(1)) if p.strip()]
            try:
                channels = [int(float(p)) for p in parts[:3]]
            except ValueError:
                return None
            alpha = float(parts[3]) if len(parts) > 3 else None
            return (*channels, alpha) if alpha is not None else tuple(channels)
        match = re.match(r"hsla?\((?!from)(.*)\)\s*$", token, re.I | re.S)
        if match:
            parts = [p.strip() for p in split_args(match.group(1).replace(",", " ")) if p.strip() != "/"]
            hue = self.number(parts[0].replace("deg", "")) if parts else None
            sat = self.number(parts[1]) if len(parts) > 1 else None
            light = self.number(parts[2]) if len(parts) > 2 else None
            if hue is None or sat is None or light is None:
                return None
            sat /= 100
            light /= 100
            rgb = hsl_to_rgb(hue, sat, light)
            if len(parts) > 3:
                return (*rgb, float(parts[3]))
            return rgb
        match = REL.match(token)
        if match:
            return self.relative(match.group(1).lower(), match.group(2), seen)
        return None

    def component(self, token, current, scale):
        token = token.strip()
        if token in ("h", "s", "l", "c", "r", "g", "b", "alpha"):
            return current
        if token.startswith("var("):
            name = token[4:].rstrip(")").split(",")[0].strip()
            referenced = str(self.variables.get(name, self.numbers.get(name, ""))).strip()
            if referenced in ("h", "s", "l", "c"):
                return current
            return self.number(token)
        if token.startswith("calc("):
            return self.evaluate(token[5:-1] if token.endswith(")") else token[5:], current)
        parsed = self.number(token)
        if parsed is None:
            return None
        return parsed * scale if token.endswith("%") else parsed

    def evaluate(self, expression, current):
        def substitute(match):
            name = match.group(1)
            referenced = str(self.variables.get(name, self.numbers.get(name, ""))).strip()
            if referenced in ("h", "s", "l", "c"):
                return str(current)
            try:
                return str(float(referenced))
            except ValueError:
                return "None"

        expression = re.sub(r"var\(\s*(--[a-z0-9-]+)\s*\)", substitute, expression)
        expression = re.sub(r"(?<![\w.])(?:h|s|l|c)(?![\w.])", str(current), expression)
        expression = expression.replace("%", "")
        if not re.fullmatch(r"[\d.\s()+\-*/]+", expression):
            return None
        try:
            return float(eval(expression, {"__builtins__": {}}, {}))
        except Exception:
            return None

    def relative(self, space, body, seen):
        base_token, remainder = take_colour_token(body)
        if not base_token:
            return None
        base = self.colour(base_token, seen)
        if base is None:
            return None
        rest = split_args(remainder)
        alpha = base[3] if len(base) == 4 else 1.0
        if "/" in rest:
            index = rest.index("/")
            alpha_token = rest[index + 1] if len(rest) > index + 1 else None
            rest = rest[:index]
            if alpha_token:
                value = self.component(alpha_token, alpha, 0.01)
                if value is None:
                    return None
                alpha = value if value <= 1 else value / 100
        if space == "hsl":
            hue, sat, light = rgb_to_hsl(base)
            values = [
                self.component(rest[0], hue, 1) if len(rest) > 0 else hue,
                self.component(rest[1], sat * 100, 1) if len(rest) > 1 else sat * 100,
                self.component(rest[2], light * 100, 1) if len(rest) > 2 else light * 100,
            ]
            if any(value is None for value in values):
                return None
            rgb = hsl_to_rgb(values[0], values[1] / 100, values[2] / 100)
        elif space == "oklch":
            light, chroma, hue = rgb_to_oklch(base)
            values = [
                self.component(rest[0], light, 0.01) if len(rest) > 0 else light,
                self.component(rest[1], chroma, 1) if len(rest) > 1 else chroma,
                self.component(rest[2], hue, 1) if len(rest) > 2 else hue,
            ]
            if any(value is None for value in values):
                return None
            rgb = oklch_to_rgb(values[0], values[1], values[2])
        else:
            return None
        return (*rgb, alpha) if alpha < 0.999 else rgb


THEME = re.compile(r"\.theme-([a-z0-9_]+)", re.I)


def collect(blocks):
    """Splits variable definitions into the default set and per-theme overlays."""
    default, numbers, themes, class_colours = {}, {}, {}, {}
    for selector, body in blocks:
        theme = THEME.search(selector)
        for name, value in DECL.findall(body):
            if not name.startswith("--"):
                continue
            value = value.strip()
            if re.fullmatch(r"-?[\d.]+%?", value):
                numbers.setdefault(name, value.rstrip("%"))
            if name == "--color":
                for part in selector.split(","):
                    class_colours.setdefault(part.strip(), value)
            elif theme:
                themes.setdefault(theme.group(1), {})[name] = value
            else:
                default[name] = value
    return default, numbers, themes, class_colours


def split_pseudo(selector):
    match = re.match(r"^([^:\s]+)(.*)$", selector)
    return (match.group(1), match.group(2)) if match else (selector, "")


def main():
    css = open(sys.argv[1], encoding="utf-8", errors="replace").read()
    blocks = parse_blocks(css)
    default, numbers, themes, class_colours = collect(blocks)

    def resolve_block(variables, selector, body):
        resolver = Resolver(variables, numbers)
        produced = []
        for name, value in DECL.findall(body):
            value = value.strip()
            important = ""
            if value.lower().endswith("!important"):
                value = value[: -len("!important")].strip()
                important = " !important"
            if not REL.match(value):
                continue
            colour = resolver.colour(value)
            if colour is not None:
                produced.append((selector, name, format_colour(colour) + important))
                continue
            base, pseudo = split_pseudo(selector)
            own = next(
                (
                    class_colours["." + token]
                    for token in base.split(".")[1:][::-1]
                    if "." + token in class_colours
                ),
                None,
            )
            if own:
                local = Resolver({**variables, "--color": own}, numbers)
                colour = local.colour(value)
                if colour is not None:
                    produced.append((selector, name, format_colour(colour) + important))
                    continue
            for variant, source in class_colours.items():
                if not variant.startswith(base + "--"):
                    continue
                local = Resolver({**variables, "--color": source}, numbers)
                colour = local.colour(value)
                if colour is not None:
                    produced.append((variant + pseudo, name, format_colour(colour) + important))
        return produced

    rules, seen = [], set()
    for selector, body in blocks:
        if "from " not in body or THEME.search(selector):
            continue
        for produced in resolve_block(default, selector, body):
            if produced not in seen:
                seen.add(produced)
                rules.append(produced)

    theme_rules = []
    for theme, overrides in sorted(themes.items()):
        variables = {**default, **overrides}
        produced, theme_seen = [], set()
        for selector, body in blocks:
            if "from " not in body:
                continue
            match = THEME.search(selector)
            if match and match.group(1) != theme:
                continue
            for target, name, value in resolve_block(variables, selector, body):
                if (target, name, value) in seen or (target, name) in theme_seen:
                    continue
                theme_seen.add((target, name))
                produced.append((target, name, value))
        if produced:
            theme_rules.append((theme, produced))

    def emit(entries, indent):
        grouped = {}
        for selector, name, value in entries:
            grouped.setdefault(selector, []).append((name, value))
        out = []
        for selector, declarations in grouped.items():
            out.append(f"{indent}{selector} {{")
            for name, value in declarations:
                out.append(f"{indent}  {name}: {value};")
            out.append(f"{indent}}}")
        return out

    def scope(theme, selector):
        if selector.startswith(":root"):
            return f".theme-{theme}{selector}"
        if f".theme-{theme}" in selector:
            return selector
        return f".theme-{theme} {selector}"

    lines = ["@supports not (color: hsl(from red h s l)) {"]
    lines += emit(rules, "  ")
    for theme, produced in theme_rules:
        lines += emit([(scope(theme, selector), name, value) for selector, name, value in produced], "  ")
    lines.append("}")
    open(sys.argv[2], "w", encoding="utf-8").write(chr(10).join(lines) + chr(10))
    total = len(rules) + sum(len(p) for _, p in theme_rules)
    print(f"правил по умолчанию: {len(rules)} | тем: {len(theme_rules)} | всего объявлений: {total}")


if __name__ == "__main__":
    main()
