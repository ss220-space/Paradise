import { type RefObject, useLayoutEffect, useRef } from 'react';
import { classes } from 'tgui-core/react';
import { useBackend } from '../../backend';
import type { OvermapHelmData } from '../OvermapHelm';
import { HelmDockingButton } from './HelmDockingButton';

const ticks = Array.from({ length: 24 }, (_, index) => {
  const angle = index * 15;
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
});
const degrees = (angle: number) =>
  `${String(Math.round(((angle % 360) + 360) % 360)).padStart(3, '0')}°`;

const HeadingDial = (props: {
  radarFacing: RefObject<((facing: number | null) => void) | null>;
  followHeading: boolean;
}) => {
  const { data } = useBackend<OvermapHelmData>();
  const { speed, heading } = data;
  const dial = useRef<SVGSVGElement>(null);
  const compass = useRef<SVGGElement>(null);
  const velocity = useRef<SVGGElement>(null);
  const ship = useRef<SVGGElement>(null);
  const value = useRef<SVGTextElement>(null);
  const current = useRef<number | null>(null);
  useLayoutEffect(() => {
    const paint = (angle: number | null) => {
      current.current = angle;
      const facing = angle ?? data.facing;
      const rotation = props.followHeading ? facing : 0;
      compass.current?.setAttribute('transform', `rotate(${-rotation})`);
      velocity.current?.setAttribute(
        'transform',
        `rotate(${heading - rotation})`,
      );
      ship.current?.setAttribute('transform', `rotate(${facing - rotation})`);
      const text = degrees(facing);
      if (value.current && value.current.textContent !== text) {
        value.current.textContent = text;
        dial.current?.setAttribute('aria-label', `Курс ${text}`);
      }
    };
    props.radarFacing.current = paint;
    paint(current.current);
    return () => {
      props.radarFacing.current = null;
    };
  }, [props.radarFacing, props.followHeading, data.facing, heading, speed]);
  return (
    <svg
      className="HelmHeading__dial"
      viewBox="-62 -62 124 124"
      role="img"
      ref={dial}
    >
      <circle className="HelmHeading__face" r={56} />
      <g ref={compass}>
        {ticks}
        <text className="HelmHeading__north" y={-38}>
          N
        </text>
      </g>
      {speed > 0 && (
        <g ref={velocity}>
          <circle className="HelmHeading__vector" cy={-50} r={3.5} />
        </g>
      )}
      <g ref={ship}>
        <path className="HelmHeading__nose" d="M0 -40l8 26-8-6-8 6z" />
        <line className="HelmHeading__spine" y1={-12} y2={22} />
      </g>
      <text ref={value} className="HelmHeading__value" y={40} />
    </svg>
  );
};

export const HelmHeading = (props: {
  radarFacing: RefObject<((facing: number | null) => void) | null>;
  followHeading: boolean;
  onToggleFollow: () => void;
}) => {
  const { act, data } = useBackend<OvermapHelmData>();
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
            <HeadingDial
              radarFacing={props.radarFacing}
              followHeading={props.followHeading}
            />
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
            <HelmDockingButton />
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
