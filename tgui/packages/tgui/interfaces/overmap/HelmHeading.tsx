import { classes } from 'tgui-core/react';
import { useBackend } from '../../backend';
import type { OvermapHelmData } from '../OvermapHelm';
import { HelmDockingButton } from './HelmDockingButton';

const TICKS = Array.from({ length: 24 }, (_, index) => index * 15);
const degrees = (angle: number) =>
  `${String(Math.round(((angle % 360) + 360) % 360)).padStart(3, '0')}°`;

export const HelmHeading = (props: {
  onLanding: () => void;
  followHeading: boolean;
  onToggleFollow: () => void;
}) => {
  const { act, data } = useBackend<OvermapHelmData>();
  const rotation = props.followHeading ? data.facing : 0;
  const locked =
    !data.can_steer ||
    !!data.map_jammed ||
    !!data.dock_aligning ||
    (!!data.pilot_name && !data.piloting);
  return (
    <section className="HelmDeck">
      <div className="HelmDeck__body">
        <h2 className="HelmCaption">Курс</h2>
        <div className="HelmHeading">
          <button
            type="button"
            className="HelmHeading__orientation"
            aria-pressed={props.followHeading}
            aria-label={`Радар: ${props.followHeading ? 'по курсу' : 'север сверху'}`}
            title="Переключить радар: север сверху / по курсу корабля"
            onClick={props.onToggleFollow}
          >
            <svg
              className="HelmHeading__dial"
              viewBox="-62 -62 124 124"
              role="img"
              aria-label={`Курс ${degrees(data.facing)}`}
            >
              <circle className="HelmHeading__face" r={56} />
              <g transform={`rotate(${-rotation})`}>
                {TICKS.map((angle) => {
                  const rad = (angle * Math.PI) / 180;
                  const inner = angle % 90 === 0 ? 46 : 51;
                  return (
                    <line
                      key={angle}
                      className="HelmHeading__tick"
                      x1={Math.sin(rad) * 56}
                      y1={-Math.cos(rad) * 56}
                      x2={Math.sin(rad) * inner}
                      y2={-Math.cos(rad) * inner}
                    />
                  );
                })}
                <text className="HelmHeading__north" y={-38}>
                  N
                </text>
              </g>
              {data.speed > 0 && (
                <g transform={`rotate(${data.heading - rotation})`}>
                  <circle className="HelmHeading__vector" cy={-50} r={3.5} />
                </g>
              )}
              <g transform={`rotate(${data.facing - rotation})`}>
                <path className="HelmHeading__nose" d="M0 -40l8 26-8-6-8 6z" />
                <line className="HelmHeading__spine" y1={-12} y2={22} />
              </g>
              <text className="HelmHeading__value" y={40}>
                {degrees(data.facing)}
              </text>
            </svg>
            <span>{props.followHeading ? 'ПО КУРСУ' : 'СЕВЕР'}</span>
          </button>
          <div className="HelmHeading__modes">
            {(
              [
                [
                  'toggle_angular_dampeners',
                  'Вращение',
                  !!data.angular_dampeners,
                ],
                ['toggle_dampeners', 'Движение', !!data.dampeners],
              ] as const
            ).map(([action, label, enabled]) => (
              <button
                key={action}
                type="button"
                disabled={locked}
                aria-pressed={enabled}
                title={
                  action === 'toggle_angular_dampeners'
                    ? 'Гасить вращение, не меняя скорость движения'
                    : 'Гасить движение, не меняя вращение'
                }
                className={classes(['HelmButton', enabled && 'HelmButton--on'])}
                onClick={() => act(action)}
              >
                {label}
              </button>
            ))}
            <HelmDockingButton onLanding={props.onLanding} />
          </div>
        </div>
        <div className="HelmKeys">
          <kbd>Q</kbd>
          <kbd>E</kbd> поворот
        </div>
      </div>
    </section>
  );
};
