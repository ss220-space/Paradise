import { Icon } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { useBackend } from '../../backend';
import type { OvermapHelmData } from '../OvermapHelm';
import { overmapKindIcon, overmapKindLabel } from './OvermapChrome';

export type HelmSelection =
  | { kind: 'object'; id: string; name: string }
  | { kind: 'point'; x: number; y: number; name?: string };

const decimal = (value: number) => value.toFixed(1).replace('.', ',');
const coordinates = (x: number, y: number) => `${decimal(x)} : ${decimal(y)}`;
const distanceTo = (data: OvermapHelmData, x: number, y: number) =>
  data.self_pos ? Math.hypot(x - data.self_pos[0], y - data.self_pos[1]) : 0;

export const helmPointSelection = (
  data: OvermapHelmData,
  x: number,
  y: number,
  name?: string,
): HelmSelection | null => {
  if (!data.radar_world || !data.self_pos || !data.cell_span) return null;
  return {
    kind: 'point',
    x: data.self_pos[0] + (x - data.radar_world[0]) / data.cell_span,
    y: data.self_pos[1] + (y - data.radar_world[1]) / data.cell_span,
    name,
  };
};

export const HelmTargetCard = (props: {
  selection: HelmSelection;
  onCancel: () => void;
}) => {
  const { data, act } = useBackend<OvermapHelmData>();
  const { selection, onCancel } = props;
  const object =
    selection.kind === 'object'
      ? data.objects?.find((entry) => entry.id === selection.id)
      : null;
  const lost = selection.kind === 'object' && !object;
  const x = selection.kind === 'point' ? selection.x : object?.x;
  const y = selection.kind === 'point' ? selection.y : object?.y;
  const name =
    selection.kind === 'point'
      ? selection.name || 'Точка пространства'
      : object?.name || selection.name;
  const locked =
    !!data.programmed_locked ||
    !!data.map_jammed ||
    lost ||
    x == null ||
    y == null;
  const buffer = () => {
    if (locked) return;
    act('buffer_dest', {
      ...(selection.kind === 'object' ? { id: selection.id } : {}),
      x,
      y,
      name:
        selection.kind === 'point'
          ? selection.name || `Точка ${coordinates(x!, y!)}`
          : name,
    });
  };
  return (
    <section className="HelmTarget" aria-label="Выбранная цель">
      <div className="HelmCaption">
        Выбрано · {selection.kind === 'point' ? 'точка' : 'объект'}
      </div>
      <div className="HelmTarget__title">
        <Icon
          name={object ? overmapKindIcon(object.kind) : 'location-crosshairs'}
        />
        <h3 title={name}>{object?.destroyed ? <s>{name}</s> : name}</h3>
      </div>
      <div className="HelmTarget__kind">
        {lost
          ? 'КОНТАКТ ПОТЕРЯН'
          : object?.destroyed
            ? 'УНИЧТОЖЕН'
            : object
              ? overmapKindLabel(object.kind)
              : 'НАВИГАЦИОННАЯ ТОЧКА'}
      </div>
      {x != null && y != null && (
        <div className="HelmTarget__readouts">
          <div>
            <small>Координаты</small>
            <b>{coordinates(x, y)}</b>
          </div>
          <div>
            <small>Дистанция</small>
            <b>{decimal(distanceTo(data, x, y))} кл</b>
          </div>
          {object?.speed != null && (
            <div>
              <small>Скорость</small>
              <b>{decimal(object.speed)} м/с</b>
            </div>
          )}
          {!!object?.distress && (
            <div className="HelmTarget__warning">СИГНАЛ БЕДСТВИЯ</div>
          )}
        </div>
      )}
      <div className="HelmTarget__actions">
        <button
          type="button"
          className="HelmButton HelmButton--on"
          disabled={locked}
          onClick={buffer}
        >
          БУФЕР
        </button>
        <button
          type="button"
          className="HelmButton"
          disabled
          title="Захват пока недоступен"
        >
          ЗАХВАТИТЬ
        </button>
        <button type="button" className="HelmButton" onClick={onCancel}>
          ОТМЕНИТЬ
        </button>
      </div>
    </section>
  );
};

export const HelmAutopilot = () => {
  const { data, act } = useBackend<OvermapHelmData>();
  const { dest, autopilot, can_steer } = data;
  const targetDestroyed = data.objects?.some(
    (object) => object.id === data.navigation_target_id && object.destroyed,
  );
  const destinationName = data.dest_name || 'Навигационная точка';
  const locked = !can_steer || !!data.map_jammed || !!data.programmed_locked;
  const distance = dest ? distanceTo(data, dest[0], dest[1]) : 0;
  return (
    <section className="HelmDeck HelmNavigation">
      <div className="HelmDeck__body">
        <div className="HelmNavigation__header">
          <h2 className="HelmCaption">Автопилот</h2>
          <span
            className={classes([
              'HelmNavigation__status',
              autopilot && 'HelmNavigation__status--on',
            ])}
          >
            {autopilot ? (data.avoiding ? 'ОБХОД' : 'В ПУТИ') : 'ОЖИДАНИЕ'}
          </span>
        </div>
        <div
          className={classes([
            'HelmNavigation__buffer',
            dest && 'HelmNavigation__buffer--set',
          ])}
        >
          <Icon name={dest ? 'location-crosshairs' : 'route'} />
          <div>
            <small>БУФЕР МАРШРУТА</small>
            <h3 title={data.dest_name}>
              {dest ? (
                targetDestroyed ? (
                  <s>{destinationName}</s>
                ) : (
                  destinationName
                )
              ) : (
                'Буфер пуст'
              )}
            </h3>
            <p>
              {dest
                ? `${coordinates(dest[0], dest[1])} · ${decimal(distance)} кл`
                : 'Буфер пуст'}
            </p>
          </div>
          <button
            type="button"
            className="HelmNavigation__clear"
            aria-label="Убрать цель из буфера"
            title="Очистить буфер и остановить автопилот"
            disabled={!dest || !!data.programmed_locked}
            onClick={() => act('clear_dest')}
          >
            <Icon name="xmark" />
            <span>СБРОС</span>
          </button>
        </div>
        <div className="HelmNavigation__readouts">
          <div>
            <small>Задано</small>
            <b>{data.max_speed} м/с</b>
          </div>
          <div>
            <small>ETA</small>
            <b>{autopilot && data.eta ? `${Math.ceil(data.eta)} с` : '—'}</b>
          </div>
          <span>
            {data.autopilot_status ||
              (autopilot
                ? 'Следование по маршруту'
                : 'Готов к прокладке курса')}
          </span>
        </div>
        <div className="HelmNavigation__actions">
          <button
            type="button"
            className={classes(['HelmButton', autopilot && 'HelmButton--on'])}
            disabled={locked || !dest}
            onClick={() => act('toggle_autopilot')}
          >
            <Icon name={autopilot ? 'pause' : 'play'} />{' '}
            {autopilot ? 'ОСТАНОВИТЬ' : 'НАЧАТЬ ПОЛЁТ'}
          </button>
          <button
            type="button"
            className={classes([
              'HelmButton',
              data.matching_velocity && 'HelmButton--on',
            ])}
            disabled={locked || !data.navigation_target}
            onClick={() => act('match_velocity')}
          >
            <Icon name="arrows-left-right-to-line" /> СБЛИЖЕНИЕ
          </button>
        </div>
        <button
          type="button"
          className={classes([
            'HelmToggle',
            data.avoid_obstacles && 'HelmToggle--on',
          ])}
          disabled={locked}
          aria-pressed={!!data.avoid_obstacles}
          onClick={() => act('toggle_avoidance')}
        >
          <i /> ОБХОД ПРЕПЯТСТВИЙ
        </button>
        {!!data.programmed_cancellable && (
          <button
            type="button"
            className="HelmButton"
            onClick={() => act('cancel_programmed')}
          >
            ОТМЕНИТЬ ПРОГРАММНЫЙ РЕЙС
          </button>
        )}
      </div>
    </section>
  );
};
