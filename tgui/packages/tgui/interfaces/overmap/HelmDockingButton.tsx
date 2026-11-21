import { Icon } from 'tgui-core/components';
import { useBackend } from '../../backend';
import type { OvermapHelmData } from '../OvermapHelm';

export const HelmDockingButton = () => {
  const { act, data } = useBackend<OvermapHelmData>();
  const busy = !!(
    data.radar_locked ||
    data.dock_aligning ||
    data.changing_altitude
  );
  let label = 'Остановиться';
  let action = 'prepare_stop';
  let enabled = !!data.can_stop;
  if (data.dock_preview) {
    label = data.dock_aligning
      ? 'Автодоводка…'
      : data.dock_ready
        ? 'Состыковаться'
        : data.dock_in_range
          ? 'Док занят'
          : 'Отменить заход';
    action = 'align_dock';
    enabled = !data.dock_in_range || !!data.dock_ready;
  } else if (data.can_undock || data.can_ship_undock) {
    label = 'Отстыковка';
    action = data.can_ship_undock ? 'dock_ship' : 'undock';
    enabled = true;
  } else if (data.can_approach_planet) {
    label = 'Сблизиться';
    action = 'approach_planet';
    enabled = true;
  } else if (data.can_relay_jump) {
    label = 'Прыжок';
    action = 'relay_jump';
    enabled = true;
  }
  return (
    <>
      <button
        type="button"
        className="HelmButton HelmDockingButton"
        disabled={busy || !enabled}
        title={
          data.dock_preview && !data.dock_in_range
            ? 'Подведите корабль к отмеченной области или отмените заход'
            : undefined
        }
        onClick={() => act(action)}
      >
        <Icon name={data.dock_preview ? 'anchor' : 'shuttle-space'} />{' '}
        {data.radar_locked ? 'Прыжок…' : label}
      </button>
      {!!data.in_atmosphere && (
        <div className="HelmAtmosphereActions">
          {!!data.dock_preview && (
            <button
              type="button"
              className="HelmButton"
              disabled={busy || !data.can_stop}
              onClick={() => act('prepare_stop')}
            >
              Остановиться
            </button>
          )}
          <button
            type="button"
            className="HelmButton"
            disabled={busy}
            onClick={() => act('leave_atmosphere')}
          >
            Вылететь
          </button>
        </div>
      )}
    </>
  );
};
