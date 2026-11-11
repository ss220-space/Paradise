export const CORE_IDS = ['station', 'service', 'wilderness_a'];
export const LINE_STYLES = ['solid', 'dashed', 'dotted', 'dash-dot'];
export const HATCH_STYLES = ['none', 'diagonal', 'cross', 'dots', 'horizontal'];
export const LINK_STATES = ['active', 'closed', 'unstable'];
export const DEFAULT_STYLE = {
  line: 'solid',
  width: 2,
  opacity: 0.85,
  fill: '#193a51',
  fillOpacity: 0.18,
  hatch: 'none',
  hatchOpacity: 0.25,
  hatchSpacing: 12,
};
export const MIN_SCALE = 0.001;
export const MAX_SCALE = 160;
export const clamp = (value, low, high) => Math.min(high, Math.max(low, value));
export const lineDash = (style) =>
  ({ dashed: '9 6', dotted: '2 5', 'dash-dot': '10 4 2 4' })[style];
export const chartSystems = (chart) => chart.systems || chart.sectors || [];
export const territoryStyle = (territory, factions = []) => ({
  ...DEFAULT_STYLE,
  ...factions.find((f) => f.id === territory.faction)?.style,
  ...territory.style,
});
export function chartBounds(chart) {
  const points = [
    ...chartSystems(chart).map((s) => [s.x, s.y]),
    ...(chart.territories || []).flatMap((t) => t.points),
    ...(chart.pois || []).map((p) => [p.x, p.y]),
    ...(chart.links || []).flatMap((l) => l.waypoints || []),
  ];
  if (!points.length) return [-100, -100, 100, 100];
  const bounds = [Infinity, Infinity, -Infinity, -Infinity];
  for (const [x, y] of points) {
    bounds[0] = Math.min(bounds[0], x);
    bounds[1] = Math.min(bounds[1], y);
    bounds[2] = Math.max(bounds[2], x);
    bounds[3] = Math.max(bounds[3], y);
  }
  return bounds;
}
export function fitCamera(chart, width, height, padding = 65) {
  const [x0, y0, x1, y1] = chartBounds(chart);
  return {
    x: (x0 + x1) / 2,
    y: (y0 + y1) / 2,
    scale: clamp(
      Math.min(
        Math.max(1, width - padding * 2) / Math.max(20, x1 - x0),
        Math.max(1, height - padding * 2) / Math.max(20, y1 - y0),
      ),
      MIN_SCALE,
      MAX_SCALE,
    ),
  };
}
export const project = (point, camera, width, height) => [
  width / 2 + (point[0] - camera.x) * camera.scale,
  height / 2 - (point[1] - camera.y) * camera.scale,
];
export const unproject = (point, camera, width, height) => [
  camera.x + (point[0] - width / 2) / camera.scale,
  camera.y - (point[1] - height / 2) / camera.scale,
];
export function zoomCamera(camera, factor, anchor, width, height) {
  const world = unproject(anchor, camera, width, height);
  const scale = clamp(camera.scale * factor, MIN_SCALE, MAX_SCALE);
  return {
    scale,
    x: world[0] - (anchor[0] - width / 2) / scale,
    y: world[1] + (anchor[1] - height / 2) / scale,
  };
}
export function linkPoints(link, systems) {
  const from = systems.find((s) => s.id === link.from);
  const to = systems.find((s) => s.id === link.to);
  return from && to
    ? [[from.x, from.y], ...(link.waypoints || []), [to.x, to.y]]
    : [];
}
export const pointsPath = (points) =>
  points.map((p, i) => `${i ? 'L' : 'M'}${p[0]} ${p[1]}`).join(' ');
export function pointAlongPath(points, progress) {
  const lengths = points
    .slice(1)
    .map((p, i) => Math.hypot(p[0] - points[i][0], p[1] - points[i][1]));
  let distance = clamp(progress, 0, 1) * lengths.reduce((a, b) => a + b, 0);
  for (let i = 0; i < lengths.length; i++) {
    if (distance <= lengths[i] || i === lengths.length - 1) {
      const f = lengths[i] ? distance / lengths[i] : 0;
      return {
        x: points[i][0] + (points[i + 1][0] - points[i][0]) * f,
        y: points[i][1] + (points[i + 1][1] - points[i][1]) * f,
        angle:
          (Math.atan2(
            -(points[i + 1][1] - points[i][1]),
            points[i + 1][0] - points[i][0],
          ) *
            180) /
          Math.PI,
      };
    }
    distance -= lengths[i];
  }
  return { x: points[0]?.[0] || 0, y: points[0]?.[1] || 0, angle: 0 };
}
export function niceStep(value) {
  const power = 10 ** Math.floor(Math.log10(Math.max(value, 0.0001)));
  return ([1, 2, 5, 10].find((v) => v * power >= value) || 10) * power;
}
export function validateGalaxy(doc) {
  const errors = [];
  const fail = (path, text) => errors.push(`${path}: ${text}`);
  const number = (n, low, high) =>
    typeof n === 'number' && Number.isFinite(n) && n >= low && n <= high;
  const color = (c) => typeof c === 'string' && /^#[0-9a-f]{6}$/i.test(c);
  const label = (s) =>
    typeof s === 'string' && s.trim().length > 0 && s.length <= 180;
  if (!doc || typeof doc !== 'object' || Array.isArray(doc))
    return ['Ожидается объект JSON'];
  if (doc.version !== 1) fail('version', 'поддерживается версия 1');
  if (!label(doc.name)) fail('name', 'нужно название карты');
  if (
    doc.units !== undefined &&
    (typeof doc.units !== 'string' || doc.units.length > 64)
  )
    fail('units', 'нужна строка до 64 символов');
  const ids = {};
  for (const key of ['systems', 'factions', 'territories', 'links', 'pois']) {
    if (!Array.isArray(doc[key]) || doc[key].length > 256) {
      fail(key, 'нужен массив, максимум 256 записей');
      continue;
    }
    ids[key] = new Set();
    for (const [i, item] of doc[key].entries()) {
      if (!item || typeof item !== 'object') {
        fail(`${key}[${i}]`, 'нужен объект');
        continue;
      }
      if (!/^[a-zA-Z0-9_-]{1,64}$/.test(item.id || '') || ids[key].has(item.id))
        fail(`${key}[${i}].id`, 'нужен уникальный ID: латиница, цифры, _ и -');
      ids[key].add(item.id);
      if (key !== 'links' && !label(item.name))
        fail(`${key}[${i}].name`, 'нужно название');
    }
  }
  if (errors.length) return errors;
  for (const id of CORE_IDS)
    if (!ids.systems.has(id))
      fail('systems', `нельзя удалить служебный сектор ${id}`);
  const point = (p) =>
    Array.isArray(p) &&
    p.length === 2 &&
    p.every((n) => number(n, -100000, 100000));
  const style = (s, path) => {
    if (!s || typeof s !== 'object' || Array.isArray(s)) {
      fail(path, 'нужен объект стиля');
      return;
    }
    if (s.line !== undefined && !LINE_STYLES.includes(s.line))
      fail(path, 'неизвестный тип линии');
    if (s.hatch !== undefined && !HATCH_STYLES.includes(s.hatch))
      fail(path, 'неизвестная штриховка');
    for (const field of ['opacity', 'fillOpacity', 'hatchOpacity'])
      if (s[field] !== undefined && !number(s[field], 0, 1))
        fail(path, `${field}: от 0 до 1`);
    if (s.width !== undefined && !number(s.width, 0.5, 8))
      fail(path, 'ширина: от 0.5 до 8');
    if (s.hatchSpacing !== undefined && !number(s.hatchSpacing, 4, 60))
      fail(path, 'шаг штриховки: от 4 до 60');
    if (s.fill !== undefined && !color(s.fill))
      fail(path, 'цвет заливки: #RRGGBB');
  };
  for (const item of [...doc.systems, ...doc.pois]) {
    const m = item.marker;
    if (m !== undefined) {
      if (!m || typeof m !== 'object' || Array.isArray(m)) {
        fail(item.id, 'неверный маркер');
        continue;
      }
      if (m.shape !== undefined && !MARKER_SHAPES.includes(m.shape))
        fail(item.id, 'неизвестная форма маркера');
      for (const key of ['color', 'fill', 'labelColor'])
        if (m[key] !== undefined && !color(m[key]))
          fail(item.id, 'неверный цвет маркера');
      for (const [key, lo, hi] of [
        ['size', 1, 40],
        ['width', 0.5, 8],
        ['opacity', 0, 1],
        ['rotation', -360, 360],
        ['labelSize', 6, 32],
        ['labelX', -200, 200],
        ['labelY', -200, 200],
        ['imageSize', 8, 160],
      ])
        if (m[key] !== undefined && !number(m[key], lo, hi))
          fail(item.id, `неверный ${key}`);
      if (
        m.showLabel !== undefined &&
        typeof m.showLabel !== 'boolean' &&
        m.showLabel !== 0 &&
        m.showLabel !== 1
      )
        fail(item.id, 'неверный showLabel');
      if (m.image !== undefined && !validMarkerImage(m.image))
        fail(item.id, 'изображение: PNG, JPEG или WebP до 512 КиБ');
    }
    if (item.generation !== undefined) {
      if (
        !item.generation ||
        typeof item.generation !== 'object' ||
        Array.isArray(item.generation)
      )
        fail(item.id, 'неверные веса генерации');
      else
        for (const [key, value] of Object.entries(item.generation))
          if (!GENERATION_KEYS.includes(key) || !number(value, 0, 5))
            fail(item.id, 'веса: от 0 до 5');
    }
  }
  for (const s of doc.systems) {
    if (!point([s.x, s.y])) fail(s.id, 'неверные координаты');
    if (s.faction && !ids.factions.has(s.faction))
      fail(s.id, 'неизвестное государство');
    if (
      s.description !== undefined &&
      (typeof s.description !== 'string' || s.description.length > 4000)
    )
      fail(s.id, 'неверное описание');
  }
  for (const f of doc.factions) {
    if (!color(f.color)) fail(f.id, 'цвет: #RRGGBB');
    style(f.style || {}, f.id);
  }
  for (const t of doc.territories) {
    if (!ids.factions.has(t.faction)) fail(t.id, 'неизвестное государство');
    if (
      !Array.isArray(t.points) ||
      t.points.length < 3 ||
      t.points.length > 512 ||
      !t.points.every(point)
    )
      fail(t.id, 'граница: от 3 до 512 точек');
    if (t.style) style(t.style, t.id);
  }
  const pairs = new Set();
  for (const l of doc.links) {
    const pair = [l.from, l.to].sort().join('/');
    if (
      !ids.systems.has(l.from) ||
      !ids.systems.has(l.to) ||
      l.from === l.to ||
      pairs.has(pair)
    )
      fail(l.id, 'неверная или повторная связь');
    pairs.add(pair);
    const from = doc.systems.find((s) => s.id === l.from);
    const to = doc.systems.find((s) => s.id === l.to);
    if (from && to && from.x === to.x && from.y === to.y)
      fail(l.id, 'связанные системы не должны совпадать по координатам');
    if (!LINK_STATES.includes(l.state))
      fail(l.id, 'неизвестное состояние связи');
    if (!['public', 'restricted'].includes(l.access))
      fail(l.id, 'неверный доступ');
    if (
      !Array.isArray(l.waypoints) ||
      l.waypoints.length > 64 ||
      !l.waypoints.every(point)
    )
      fail(l.id, 'неверные точки изгиба');
    if (!color(l.color)) fail(l.id, 'цвет: #RRGGBB');
    if (l.distance !== undefined && !number(l.distance, 1, 100000))
      fail(l.id, 'длина: от 1 до 100000');
    style(l, l.id);
  }
  if (!errors.length) errors.push(...transitTopologyErrors(doc));
  for (const p of doc.pois)
    if (!point([p.x, p.y]) || !color(p.color))
      fail(p.id, 'неверные координаты или цвет');
  return errors;
}

export function entryCamera(
  chart,
  width,
  height,
  sectorId,
  entry = 'overview',
) {
  const own = chartSystems(chart).find((s) => s.id === sectorId);
  return entry === 'close' && own
    ? { x: own.x, y: own.y, scale: MAX_SCALE }
    : fitCamera(chart, width, height);
}
export const MARKER_SHAPES = [
  'circle',
  'diamond',
  'square',
  'triangle',
  'star',
  'cross',
  'ring',
];
export const GENERATION_KEYS = ['hazards', 'asteroids', 'emp', 'carp', 'ruins'];
export const validMarkerImage = (value) =>
  typeof value === 'string' &&
  value.length <= 700000 &&
  /^data:image\/(png|jpeg|webp);base64,[A-Za-z0-9+/=]+$/.test(value);
export const markerPath = (shape, r) =>
  ({
    diamond: `M0 ${-r}L${r} 0L0 ${r}L${-r} 0Z`,
    square: `M${-r} ${-r}H${r}V${r}H${-r}Z`,
    triangle: `M0 ${-r}L${r} ${r}L${-r} ${r}Z`,
    cross: `M${-r} 0H${r}M0 ${-r}V${r}`,
    star: `${Array.from({ length: 10 }, (_, i) => {
      const a = (i * Math.PI) / 5 - Math.PI / 2;
      const d = i % 2 ? r * 0.42 : r;
      return `${i ? 'L' : 'M'}${Math.cos(a) * d} ${Math.sin(a) * d}`;
    }).join(' ')}Z`,
  })[shape];

export function transitTopologyErrors(doc) {
  const systems = new Map(doc.systems.map((s) => [s.id, s]));
  const adjacent = new Map(doc.systems.map((s) => [s.id, []]));
  const errors = [];
  for (const link of doc.links) {
    adjacent.get(link.from)?.push(link);
    adjacent.get(link.to)?.push(link);
  }
  for (const node of doc.systems) {
    if (node.kind !== 'transit') continue;
    if (CORE_IDS.includes(node.id))
      errors.push(`${node.id}: служебный сектор нельзя сделать транзитным`);
    if (adjacent.get(node.id).length !== 2)
      errors.push(`${node.id}: транзитному сектору нужны ровно две связи`);
  }
  if (errors.length) return errors;
  const visited = new Set();
  for (const start of doc.systems) {
    if (start.kind === 'transit') continue;
    for (const first of adjacent.get(start.id)) {
      if (visited.has(first.id)) continue;
      let node = start,
        link = first;
      while (link) {
        if (visited.has(link.id)) return ['Транзитный маршрут зациклен'];
        visited.add(link.id);
        const next = systems.get(link.from === node.id ? link.to : link.from);
        if (!next) return ['Неизвестный конец транзитного маршрута'];
        if (next.kind !== 'transit') {
          if (next.id === start.id)
            errors.push(
              `${start.id}: транзитный маршрут возвращается в исходную систему`,
            );
          break;
        }
        const options = adjacent.get(next.id);
        link = options.find((candidate) => candidate !== link);
        node = next;
      }
    }
  }
  if (visited.size !== doc.links.length)
    errors.push('Замкнутая транзитная цепочка не имеет конечных систем');
  return errors;
}
