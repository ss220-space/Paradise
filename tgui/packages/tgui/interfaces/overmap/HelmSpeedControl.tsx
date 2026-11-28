import { classes } from 'tgui-core/react';
import { useBackend } from '../../backend';
import type { OvermapHelmData } from '../OvermapHelm';

const MAX_SPEED = 45;

export const HelmSpeedControl = (props: {
  speed: number;
  onChange: (speed: number) => void;
}) => {
  const { data } = useBackend<OvermapHelmData>();
  const { speed, onChange } = props;
  const selected = speed > 0;
  const threshold = data.stealth_speed;
  const detectable = selected && threshold != null && speed >= threshold;
  const locked =
    !data.can_steer ||
    !!data.map_jammed ||
    (!!data.pilot_name && !data.piloting);
  const fraction = Math.min(1, Math.max(0, speed / MAX_SPEED));
  return (
    <div
      className={classes([
        'OvermapHelmLever',
        'HelmSpeed',
        detectable && 'HelmSpeed--detectable',
        !selected && 'HelmSpeed--empty',
      ])}
    >
      <div className="HelmCaption">Ход</div>
      <div className="HelmSpeed__telegraph">
        <div className="HelmSpeed__lever">
          <div
            className="HelmSpeed__fill"
            style={{ height: `${fraction * 100}%` }}
          />
          <div
            className="HelmSpeed__now"
            title={`Текущая скорость: ${data.speed} м/с`}
            style={{
              bottom: `calc((100% - 14px) * ${Math.min(1, Math.max(0, data.speed / MAX_SPEED))} + 7px)`,
            }}
          />
          {threshold != null && threshold > 0 && threshold < MAX_SPEED && (
            <div
              className="HelmSpeed__stealthMark"
              style={{ bottom: `${(threshold / MAX_SPEED) * 100}%` }}
            />
          )}
          <div
            className="HelmSpeed__knob"
            style={{ bottom: `calc((100% - 14px) * ${fraction})` }}
          />
          <input
            type="range"
            aria-label="Максимальная скорость"
            aria-orientation="vertical"
            min={0}
            max={MAX_SPEED}
            step={1}
            value={speed}
            disabled={locked}
            onChange={(event) => onChange(Number(event.target.value))}
          />
        </div>
        <div className="HelmSpeed__info">
          <span className="HelmSpeed__maximum">{MAX_SPEED} м/с</span>
          <div className="HelmSpeed__selected">
            <small>Задано</small>
            <output>
              {selected ? speed : '—'}
              <small>{selected ? ' м/с' : ''}</small>
            </output>
          </div>
          <div
            className="HelmSpeed__signature"
            title={`Порог дальних сенсоров без транспондера. Масса корабля: ${data.mass} т.`}
          >
            {!selected
              ? 'СКОРОСТЬ НЕ ЗАДАНА'
              : threshold == null
                ? 'НЕТ ДАННЫХ СЕНСОРОВ'
                : detectable
                  ? 'ЗАМЕТЕН СЕНСОРАМ'
                  : 'СКРЫТНЫЙ ХОД'}
            {threshold != null && (
              <small>
                {threshold > 0
                  ? `скрытно < ${threshold} м/с`
                  : 'масса исключает скрытный ход'}
              </small>
            )}
          </div>
          <span className="HelmSpeed__minimum">0</span>
        </div>
      </div>
    </div>
  );
};
