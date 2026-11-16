import { Icon } from 'tgui-core/components';
import { useBackend } from '../../backend';
import type { OvermapHelmData } from '../OvermapHelm';

export const HelmDockingButton = (props: { onLanding: () => void }) => {
  const { act, data } = useBackend<OvermapHelmData>();
  const { can_undock } = data;
  const disabled =
    !!data.radar_locked ||
    !!data.dock_aligning ||
    (!!data.dock_preview && !!data.dock_in_range && !data.dock_ready) ||
    (!data.dock_preview &&
      !can_undock &&
      !data.can_ship_undock &&
      !data.can_land &&
      !data.can_relay_jump &&
      !data.can_stop);
  const label = data.radar_locked
    ? 'Прыжок…'
    : data.dock_preview
      ? data.dock_aligning
        ? 'Автодоводка…'
        : data.dock_ready
          ? 'Состыковаться'
          : 'Стыковка'
      : can_undock || data.can_ship_undock
        ? 'Отстыковка'
        : data.can_relay_jump
          ? 'Прыжок'
          : data.can_land
            ? 'Посадка'
            : data.is_pod
              ? 'Стыковка'
              : 'Остановиться';
  return (
    <button
      type="button"
      className="HelmButton HelmDockingButton"
      disabled={disabled}
      title={
        data.dock_preview && !data.dock_ready
          ? 'Нажмите повторно, чтобы отменить заход'
          : undefined
      }
      onClick={() => {
        if (data.dock_preview) act('align_dock');
        else if (data.can_ship_undock) act('dock_ship');
        else if (can_undock) act('undock');
        else if (data.can_relay_jump) act('relay_jump');
        else if (data.can_land) props.onLanding();
        else act('prepare_stop');
      }}
    >
      <Icon
        name={
          data.dock_preview
            ? 'anchor'
            : data.can_land
              ? 'shuttle-space'
              : 'arrow-up-from-bracket'
        }
      />{' '}
      {label}
    </button>
  );
};
