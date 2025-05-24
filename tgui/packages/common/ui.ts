import type { CSSProperties } from 'react';
import type { BoxProps } from 'tgui/components/Box';
import { CSS_COLORS } from 'tgui/constants';
import { type BooleanLike, classes } from './react';

type UnitMapper = (value: unknown) => string | undefined;

// Do you get it? Are you feeling it now mr krabs?
type StyleCourier = (
  ...args: any[]
) => (style: CSSProperties, value: unknown) => void;

/**
 * Coverts our rem-like spacing unit into a CSS unit.
 */
export const unit: UnitMapper = (value) => {
  if (typeof value === 'string') {
    // Transparently convert pixels into rem units
    if (value.endsWith('px')) {
      return `${Number.parseFloat(value) / 12}rem`;
    }
    return value;
  }
  if (typeof value === 'number') {
    return `${value}rem`;
  }
};

/**
 * Same as `unit`, but half the size for integers numbers.
 */
export const halfUnit: UnitMapper = (value) => {
  if (typeof value === 'string') {
    return unit(value);
  }
  if (typeof value === 'number') {
    return unit(value * 0.5);
  }
};

const isColorCode = (str: unknown): boolean => {
  return !isColorClass(str);
};

const isColorClass = (str: unknown): boolean => {
  return typeof str === 'string' && CSS_COLORS.includes(str as any);
};

const mapRawPropTo: StyleCourier = (attrName: string) => (style, value) => {
  if (typeof value === 'number' || typeof value === 'string') {
    style[attrName] = value;
  }
};

const mapUnitPropTo: StyleCourier =
  (attrName: string, unitMapper: UnitMapper) => (style, value) => {
    if (typeof value === 'number' || typeof value === 'string') {
      style[attrName] = unitMapper(value);
    }
  };

const mapBooleanPropTo: StyleCourier =
  (attrName: string, attrValue: unknown) => (style, value) => {
    if (value) {
      style[attrName] = attrValue;
    }
  };

const mapDirectionalUnitPropTo: StyleCourier =
  (attrName: string, unitMapper: UnitMapper, dirs: string[]) =>
  (style, value) => {
    if (typeof value === 'number' || typeof value === 'string') {
      for (let i = 0; i < dirs.length; i++) {
        style[attrName + dirs[i]] = unitMapper(value);
      }
    }
  };

const mapColorPropTo: StyleCourier = (attrName: string) => (style, value) => {
  if (isColorCode(value)) {
    style[attrName] = value;
  }
};

export type StringStyleMap = {
  // Alignment

  /** Align text inside the box. */
  align: string | BooleanLike;
  /** A direct mapping to `position` CSS property. */
  position: string | BooleanLike;
  /** Vertical align property. */
  verticalAlign: string | BooleanLike;

  // Color props

  /** Sets background color. */
  backgroundColor: string | BooleanLike;
  /** Applies an atomic `color-<name>` class to the element. */
  color: string | BooleanLike;
  /** Opacity, from 0 to 1. */
  opacity: string | BooleanLike;
  /** Sets text color. */
  textColor: string | BooleanLike;

  // Margin

  /** Margin on all sides. */
  m: string | BooleanLike;
  /** Bottom margin. */
  mb: string | BooleanLike;
  /** Left margin. */
  ml: string | BooleanLike;
  /** Right margin. */
  mr: string | BooleanLike;
  /** Top margin. */
  mt: string | BooleanLike;
  /** Horizontal margin. */
  mx: string | BooleanLike;
  /** Vertical margin. */
  my: string | BooleanLike;

  /** Bottom margin. */
  bottom: string | BooleanLike;
  /** Left margin. */
  left: string | BooleanLike;
  /** Right margin. */
  right: string | BooleanLike;
  /** Top margin. */
  top: string | BooleanLike;

  // Overflow

  /** Overflow property. */
  overflow: string | BooleanLike;
  /** Overflow-X property. */
  overflowX: string | BooleanLike;
  /** Overflow-Y property. */
  overflowY: string | BooleanLike;

  // Padding

  /** Padding on all sides. */
  p: string | BooleanLike;
  /** Bottom padding. */
  pb: string | BooleanLike;
  /** Left padding. */
  pl: string | BooleanLike;
  /** Right padding. */
  pr: string | BooleanLike;
  /** Top padding. */
  pt: string | BooleanLike;
  /** Horizontal padding. */
  px: string | BooleanLike;
  /** Vertical padding. */
  py: string | BooleanLike;

  // Size

  /** Box height. */
  height: string | BooleanLike;
  /** Box maximum height. */
  maxHeight: string | BooleanLike;
  /** Box maximum width. */
  maxWidth: string | BooleanLike;
  /** Box minimum height. */
  minHeight: string | BooleanLike;
  /** Box minimum width. */
  minWidth: string | BooleanLike;
  /** Box width. */
  width: string | BooleanLike;

  // Text

  /** Font family. */
  fontFamily: string | BooleanLike;
  /** Font size. */
  fontSize: string | BooleanLike;
  /** Font weight. */
  fontWeight: string | BooleanLike;
  /** Directly affects the height of text lines. Useful for adjusting button height. */
  lineHeight: string | BooleanLike;
  /** Align text inside the box. */
  textAlign: string | BooleanLike;
};

// String / number props
export const stringStyleMap: Record<keyof StringStyleMap, any> = {
  align: mapRawPropTo('textAlign'),
  bottom: mapUnitPropTo('bottom', unit),
  fontFamily: mapRawPropTo('fontFamily'),
  fontSize: mapUnitPropTo('fontSize', unit),
  fontWeight: mapRawPropTo('fontWeight'),
  height: mapUnitPropTo('height', unit),
  left: mapUnitPropTo('left', unit),
  maxHeight: mapUnitPropTo('maxHeight', unit),
  maxWidth: mapUnitPropTo('maxWidth', unit),
  minHeight: mapUnitPropTo('minHeight', unit),
  minWidth: mapUnitPropTo('minWidth', unit),
  opacity: mapRawPropTo('opacity'),
  overflow: mapRawPropTo('overflow'),
  overflowX: mapRawPropTo('overflowX'),
  overflowY: mapRawPropTo('overflowY'),
  position: mapRawPropTo('position'),
  right: mapUnitPropTo('right', unit),
  textAlign: mapRawPropTo('textAlign'),
  top: mapUnitPropTo('top', unit),
  verticalAlign: mapRawPropTo('verticalAlign'),
  width: mapUnitPropTo('width', unit),

  lineHeight: (style, value) => {
    if (typeof value === 'number') {
      style.lineHeight = value;
    } else if (typeof value === 'string') {
      style.lineHeight = unit(value);
    }
  },
  // Margin
  m: mapDirectionalUnitPropTo('margin', halfUnit, [
    'Top',
    'Bottom',
    'Left',
    'Right',
  ]),
  mb: mapUnitPropTo('marginBottom', halfUnit),
  ml: mapUnitPropTo('marginLeft', halfUnit),
  mr: mapUnitPropTo('marginRight', halfUnit),
  mt: mapUnitPropTo('marginTop', halfUnit),
  mx: mapDirectionalUnitPropTo('margin', halfUnit, ['Left', 'Right']),
  my: mapDirectionalUnitPropTo('margin', halfUnit, ['Top', 'Bottom']),
  // Padding
  p: mapDirectionalUnitPropTo('padding', halfUnit, [
    'Top',
    'Bottom',
    'Left',
    'Right',
  ]),
  pb: mapUnitPropTo('paddingBottom', halfUnit),
  pl: mapUnitPropTo('paddingLeft', halfUnit),
  pr: mapUnitPropTo('paddingRight', halfUnit),
  pt: mapUnitPropTo('paddingTop', halfUnit),
  px: mapDirectionalUnitPropTo('padding', halfUnit, ['Left', 'Right']),
  py: mapDirectionalUnitPropTo('padding', halfUnit, ['Top', 'Bottom']),
  // Color props
  color: mapColorPropTo('color'),
  textColor: mapColorPropTo('color'),
  backgroundColor: mapColorPropTo('backgroundColor'),
};

export type BooleanStyleMap = {
  /** Make text bold. */
  bold: boolean;
  /** Fill positioned parent. */
  fillPositionedParent: boolean;
  /** Forces the `Box` to appear as an `inline-block`. */
  inline: boolean;
  /** Make text italic. */
  italic: boolean;
  /** Stops text from wrapping. */
  nowrap: boolean;
  /** Preserves line-breaks and spacing in text. */
  preserveWhitespace: boolean;
};

// Boolean props
export const booleanStyleMap: Record<keyof BooleanStyleMap, any> = {
  bold: mapBooleanPropTo('fontWeight', 'bold'),
  fillPositionedParent: (style: CSSProperties, value: unknown) => {
    if (value) {
      style.position = 'absolute';
      style.top = 0;
      style.bottom = 0;
      style.left = 0;
      style.right = 0;
    }
  },
  inline: mapBooleanPropTo('display', 'inline-block'),
  italic: mapBooleanPropTo('fontStyle', 'italic'),
  nowrap: mapBooleanPropTo('whiteSpace', 'nowrap'),
  preserveWhitespace: mapBooleanPropTo('whiteSpace', 'pre-wrap'),
};

export const computeBoxProps = (props): Record<string, any> => {
  const computedProps: Record<string, any> = {};
  const computedStyles: Record<string, string | number> = {};

  // Compute props
  for (const propName in props) {
    if (propName === 'style') {
      continue;
    }

    const propValue = props[propName];

    const mapPropToStyle =
      stringStyleMap[propName] || booleanStyleMap[propName];

    if (mapPropToStyle) {
      mapPropToStyle(computedStyles, propValue);
    } else {
      computedProps[propName] = propValue;
    }
  }

  // Merge computed styles and any directly provided styles
  computedProps.style = { ...computedStyles, ...props.style };

  return computedProps;
};

export const computeBoxClassName = (props: BoxProps): string => {
  const color = props.textColor || props.color;
  const { backgroundColor } = props;

  return classes([
    isColorClass(color) && `color-${color}`,
    isColorClass(backgroundColor) && `color-bg-${backgroundColor}`,
  ]);
};

type StyleMap = StringStyleMap & BooleanStyleMap;

/** Super light implementation of tailwind-like class names. */
export const computeTwClass = (input: string | undefined): StyleMap => {
  const props = {} as StyleMap;

  if (!input) return props;

  const parts = input.split(' ');

  for (const part of parts) {
    const [name, value] = part.split('-');
    if (!name) continue;

    if (name in stringStyleMap) {
      if (value === '') continue;

      const numbered = Number(value);
      if (!Number.isNaN(numbered) && Number.isFinite(numbered)) {
        props[name] = numbered;
      } else {
        props[name] = value;
      }
    } else if (name in booleanStyleMap) {
      props[name] = true;
    } else {
      console.warn(`Unknown prop ${name}`);
    }
  }

  return props;
};
