/**
 * @file
 * @copyright 2024 Aylong (https://github.com/AyIong)
 * @license MIT
 */

import type { Placement } from '@popperjs/core';
import type { ReactNode } from 'react';
import { type BooleanLike, classes } from 'common/react';
import { computeBoxProps } from 'common/ui';
import type { BoxProps } from './Box';
import { type Direction, DmIcon } from './DmIcon';
import { Icon } from './Icon';
import { Image } from './Image';
import { Stack } from './Stack';
import { Tooltip } from './Tooltip';

type Props = Partial<{
  /** Asset cache. Example: `asset={['assetname32x32', thing.key]}` */
  asset: string[];
  /**
   * Asset size. Used for asset scaling. Example: `assetSize={32}`
   * With that, you can use `imageSize` to set asset image size in px.
   * By default, it's 32px. So if you have 32x32 you don't need to touch it.
   */
  assetSize: number;
  /** Classic way to put images. Example: `base64={thing.image}` */
  base64: string;
  /**
   * Special container for buttons.
   * You can put any other component here.
   * Has some special stylings!
   * Example: `buttons={<Button>Send</Button>}`
   */
  buttons: ReactNode;
  /**
   * Same as buttons, but. Have disabled pointer-events on content inside if non-fluid.
   * Fluid version have humburger layout.
   * Can be used with buttons prop.
   */
  buttonsAlt: ReactNode;
  /** Content under image. Or on the right if fluid. */
  children: ReactNode;
  /** Applies a CSS class to the element. */
  className: string;
  /**
   * Color of the button. See
   * [Button](https://github.com/tgstation/tgui-core/tree/main/lib/components/Button.tsx)
   * but without `transparent`.
   */
  color: string;
  /** Makes button disabled and dark red if true. Also disables onClick. */
  disabled: BooleanLike;
  /** Optional. Adds a "stub" when loading DmIcon. */
  dmFallback: ReactNode;
  /** Parameter `icon` of component `DmIcon`. */
  dmIcon: string | null;
  /** Parameter `icon_state` of component `DmIcon`. */
  dmIconState: string | null;
  /** Parameter `direction` of component `DmIcon`. */
  dmDirection: Direction;
  /**
   * Changes the layout of the button, making it fill the entire horizontally available space.
   * Allows the use of `title`
   */
  fluid: boolean;
  /** Parameter responsible for the size of the image, component and standard "stubs". */
  imageSize: number;
  /** Prop `src` of Image component. Example: `imageSrc={resolveAsset(thing.image)}` */
  imageSrc: string;
  /** Called when button is clicked with LMB. */
  onClick: (e: any) => void;
  /** Called when button is clicked with RMB. */
  onRightClick: (e: any) => void;
  /** Makes button selected and green if true. */
  selected: BooleanLike;
  /** Requires `fluid` for work. Bold text with divider betwen content. */
  title: string;
  /** A fancy, boxy tooltip, which appears when hovering over the button */
  tooltip: ReactNode;
  /** Position of the tooltip. See [`Popper`](#Popper) for valid options. */
  tooltipPosition: Placement;
}> &
  BoxProps;

/**
 * Stylized button, with the ability to easily and simply insert any picture into it.
 * - Without image, will be default question icon.
 * - If an image is specified but for some reason cannot be displayed, there will be a spinner fallback until it is loaded.
 * - Component has no **hover** effects, if `onClick` or `onRightClick` is not specified.
 */
export const ImageButton = (props: Props) => {
  const {
    asset,
    assetSize = 32,
    base64,
    buttons,
    buttonsAlt,
    children,
    className,
    color,
    disabled,
    dmFallback,
    dmIcon,
    dmIconState,
    dmDirection,
    fluid,
    imageSize = 64,
    imageSrc,
    onClick,
    onRightClick,
    selected,
    title,
    tooltip,
    tooltipPosition,
    ...rest
  } = props;

  let buttonContent = (
    <div
      className={classes([
        'container',
        fluid && (!!buttons || !!buttonsAlt) && 'hasButtons',
        !onClick && !onRightClick && 'noAction',
        selected && 'ImageButton--selected',
        disabled && 'ImageButton--disabled',
        color && typeof color === 'string'
          ? `ImageButton--color__${color}`
          : 'ImageButton--color__default',
      ])}
      tabIndex={!disabled ? 0 : undefined}
      onClick={(event) => {
        if (!disabled && onClick) {
          onClick(event);
        }
      }}
      onKeyDown={(event) => {
        if (event.key === 'Enter' && !disabled && onClick) {
          onClick(event);
        }
      }}
      onContextMenu={(event) => {
        event.preventDefault();
        if (!disabled && onRightClick) {
          onRightClick(event);
        }
      }}
      style={{ width: !fluid ? `calc(${imageSize}px + 0.5em + 2px)` : 'auto' }}
    >
      {/** There is too many ternaty operators, why we can't just use unified image type? */}
      <div className="image">
        {base64 || imageSrc ? (
          <Image
            src={base64 ? `data:image/png;base64,${base64}` : imageSrc}
            height={`${imageSize}px`}
            width={`${imageSize}px`}
          />
        ) : dmIcon && dmIconState ? (
          <DmIcon
            icon={dmIcon}
            icon_state={dmIconState}
            direction={dmDirection}
            fallback={
              dmFallback || <Fallback icon="spinner" spin size={imageSize} />
            }
            height={`${imageSize}px`}
            width={`${imageSize}px`}
          />
        ) : asset ? (
          <Image
            className={classes(asset || [])}
            height={`${imageSize}px`}
            width={`${imageSize}px`}
            style={{
              transform: `scale(${imageSize / assetSize})`,
              transformOrigin: 'top left',
            }}
          />
        ) : (
          <Fallback icon="question" size={imageSize} />
        )}
      </div>
      {/** End of image container */}
      {fluid ? (
        <div className="info">
          {title && (
            <span className={classes(['title', children && 'divider'])}>
              {title}
            </span>
          )}
          {children && <span className="contentFluid">{children}</span>}
        </div>
      ) : (
        children && (
          <span
            className={classes([
              'content',
              selected && 'ImageButton--contentSelected',
              disabled && 'ImageButton--contentDisabled',
              color && typeof color === 'string'
                ? `ImageButton--contentColor__${color}`
                : 'ImageButton--contentColor__default',
            ])}
          >
            {children}
          </span>
        )
      )}
    </div>
  );

  let result = (
    <div
      className={classes([
        'ImageButton',
        fluid && 'ImageButton--fluid',
        className,
      ])}
      {...computeBoxProps(rest)}
    >
      {buttonContent}
      {buttons && (
        <div
          className={classes([
            'buttonsContainer',
            !children && 'buttonsEmpty',
            fluid && disabled && 'ImageButton--disabled',
            fluid && color && typeof color === 'string'
              ? `ImageButton--buttonsContainerColor__${color}`
              : fluid && 'ImageButton--buttonsContainerColor__default',
          ])}
          style={{
            width: 'auto',
          }}
        >
          {buttons}
        </div>
      )}
      {buttonsAlt && (
        <div
          className={classes([
            'buttonsContainer',
            'buttonsAltContainer',
            !children && 'buttonsEmpty',
            fluid && disabled && 'ImageButton--disabled',
            fluid && color && typeof color === 'string'
              ? `ImageButton--buttonsContainerColor__${color}`
              : fluid && 'ImageButton--buttonsContainerColor__default',
          ])}
          style={{
            width: `calc(${imageSize}px + ${fluid ? 0 : 0.5}em)`,
            maxWidth: !fluid ? `calc(${imageSize}px +  0.5em)` : 'auto',
          }}
        >
          {buttonsAlt}
        </div>
      )}
    </div>
  );

  if (tooltip) {
    result = (
      <Tooltip content={tooltip} position={tooltipPosition as Placement}>
        {result}
      </Tooltip>
    );
  }

  return result;
};

type FallbackProps = {
  icon: string;
} & Partial<{
  spin: true;
  size: number;
}>;

const Fallback = (props: FallbackProps) => {
  const { icon, spin = false, size = 64 } = props;

  return (
    <Stack height={`${size}px`} width={`${size}px`}>
      <Stack.Item grow textAlign="center" align="center">
        <Icon
          spin={spin}
          name={icon}
          color="gray"
          style={{ fontSize: `calc(${size}px * 0.75)` }}
        />
      </Stack.Item>
    </Stack>
  );
};
