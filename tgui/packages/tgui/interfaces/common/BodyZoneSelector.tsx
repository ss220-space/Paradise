import { Component, createRef } from 'react';
import { Image } from 'tgui-core/components';

import { resolveAsset } from '../../assets';
import { useBackend } from 'tgui/backend';

export enum BodyZone {
  Head = 'head',
  Chest = 'chest',
  LeftArm = 'l_arm',
  LeftHand = 'l_hand',
  RightArm = 'r_arm',
  RightHand = 'r_hand',
  LeftLeg = 'l_leg',
  LeftFoot = 'l_foot',
  RightLeg = 'r_leg',
  RightFoot = 'r_foot',
  Eyes = 'eyes',
  Tail = 'tail',
  Wing = 'wing',
  Mouth = 'mouth',
  Groin = 'groin',
}

const renderTogetherIfImprecise = {
  [BodyZone.Chest]: [BodyZone.Groin],
};

function bodyZonePixelToZone(
  x: number,
  y: number,
  precise: boolean,
): BodyZone | null {
  const zones = [
    { zone: BodyZone.RightFoot, x1: 7, x2: 12, y1: 7, y2: 9 },
    { zone: BodyZone.RightLeg, x1: 9, x2: 12, y1: 9, y2: 14 },
    { zone: BodyZone.LeftFoot, x1: 13, x2: 18, y1: 7, y2: 9 },
    { zone: BodyZone.LeftLeg, x1: 13, x2: 16, y1: 9, y2: 14 },
    { zone: BodyZone.RightHand, x1: 5, x2: 9, y1: 15, y2: 17 },
    { zone: BodyZone.RightArm, x1: 5, x2: 8, y1: 17, y2: 24 },
    { zone: BodyZone.LeftHand, x1: 16, x2: 20, y1: 15, y2: 17 },
    { zone: BodyZone.LeftArm, x1: 16, x2: 20, y1: 17, y2: 24 },
    { zone: BodyZone.Groin, x1: 9, x2: 16, y1: 14, y2: 17 },
    { zone: BodyZone.Chest, x1: 9, x2: 16, y1: 17, y2: 24 },
    { zone: BodyZone.Head, x1: 10, x2: 15, y1: 24, y2: 29 },
    { zone: BodyZone.Tail, x1: 13, x2: 21, y1: 7, y2: 14 },
    { zone: BodyZone.Wing, x1: 2, x2: 23, y1: 14, y2: 27 },
  ];

  if (precise) {
    if (y > 25 && y < 26 && x > 11 && x < 13) {
      return BodyZone.Mouth;
    }
    if (y > 27 && y < 29 && x > 10 && x < 14) {
      return BodyZone.Eyes;
    }
  }

  for (const { zone, x1, x2, y1, y2 } of zones) {
    if (x >= x1 && x <= x2 && y >= y1 && y <= y2) {
      return zone;
    }
  }

  return null;
}

type BodyImageProps = {
  zone: BodyZone;
  scale?: number;
  theme?: string;
  opacity?: number;
  precise?: boolean;
};

function BodyImage(props: BodyImageProps) {
  const {
    zone,
    scale = 3,
    theme = 'midnight',
    opacity = 1,
    precise = true,
  } = props;

  return (
    <>
      <Image
        src={resolveAsset(`body_zones.${zone}.png`)}
        style={{
          opacity: opacity,
          pointerEvents: 'none',
          position: 'absolute',
          width: `${32 * scale}px`,
          height: `${32 * scale}px`,
        }}
      />
      {!precise &&
        renderTogetherIfImprecise[zone]?.map((otherZone) => (
          <Image
            key={otherZone}
            src={resolveAsset(`body_zones.${otherZone}.png`)}
            style={{
              opacity: opacity,
              pointerEvents: 'none',
              position: 'absolute',
              width: `${32 * scale}px`,
              height: `${32 * scale}px`,
            }}
          />
        ))}
    </>
  );
}

function HoverImage(props: BodyImageProps) {
  return <BodyImage {...props} opacity={0.5} />;
}

type BodyZoneSelectorProps = {
  onClick?: (zone: BodyZone) => void;
  scale?: number;
  selectedZone: BodyZone | null;
  theme?: string;
  precise?: boolean;
};

type BodyZoneSelectorState = {
  hoverZone: BodyZone | null;
};

export class BodyZoneSelector extends Component<
  BodyZoneSelectorProps,
  BodyZoneSelectorState
> {
  ref = createRef<HTMLDivElement>();
  state: BodyZoneSelectorState = {
    hoverZone: null,
  };

  render() {
    const { hoverZone } = this.state;
    const {
      scale = 3,
      selectedZone,
      theme = 'midnight',
      precise = true,
    } = this.props;

	const{config} = useBackend()

    return (
      <div
        ref={this.ref}
        style={{
          width: `${32 * scale}px`,
          height: `${32 * scale}px`,
          position: 'relative',
        }}
      >
        <Image
          src={resolveAsset(`body_zones.base_${theme}.png`)}
          onClick={() => {
            const onClick = this.props.onClick;
            if (onClick && this.state.hoverZone) {
              onClick(this.state.hoverZone);
            }
          }}
          onMouseMove={(event) => {
            if (!this.props.onClick) {
              return;
            }

            const rect = this.ref.current?.getBoundingClientRect();
            if (!rect) {
              return;
            }
			const dpr = (config.window.scale? window.devicePixelRatio : 1) || 1;
			const no_dpr = (config.window.scale? 1 : window.devicePixelRatio ) || 1;
            const x = (event.clientX - rect.left)/dpr;
            const y = rect.height * no_dpr - (event.clientY - rect.top)/dpr;

            this.setState({
              hoverZone: bodyZonePixelToZone(x / scale, y / scale, precise),
            });
          }}
          style={{
            position: 'absolute',
            width: `${32 * scale}px`,
            height: `${32 * scale}px`,
          }}
        />
        {selectedZone && <BodyImage {...this.props} zone={selectedZone} />}
        {hoverZone && hoverZone !== selectedZone && (
          <HoverImage {...this.props} zone={hoverZone} />
        )}
      </div>
    );
  }
}
