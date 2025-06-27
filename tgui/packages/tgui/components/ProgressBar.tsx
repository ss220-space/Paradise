/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import type { CSSProperties, PropsWithChildren } from 'react';
import { Component } from 'react';
import { CSS_COLORS } from '../constants';
import { clamp01, keyOfMatchingRange, scale, toFixed } from 'common/math';
import { classes } from 'common/react';
import { computeBoxClassName, computeBoxProps } from 'common/ui';
import type { BoxProps } from './Box';

type Props = {
  /**
   * Current progress as a floating point number between `minValue` (default: 0) and `maxValue` (default: 1).
   * Determines the percentage and how filled the bar is.
   */
  value: number;
} & Partial<{
  /**
   * Color of the progress bar. Can take any of the following formats:
   * - `#ffffff` - Hex format
   * - `rgb(r,g,b) / rgba(r,g,b,a)` - RGB format
   * - `<name>` - the name of a `color-<name>` CSS class. See `CSS_COLORS` in `constants.js`.
   * - `<name>` - the name of a base CSS color, if not overridden by the definitions above.
   */
  color: string;
  /** Highest possible value. */
  maxValue: number;
  /** Lowest possible value. */
  minValue: number;
  /**
   * Applies a `color` to the progress bar based on whether the value lands in the range between `from` and `to`.
   * This takes an object with the following format:
   * ```tsx
   * {
   *   (colorname): [from, to]
   * }
   * ```
   * For example:
   * ```tsx
   * <ProgressBar
   *   value={0.5}
   *   ranges={{
   *     bad: [0, 0.5],
   *     good: [0.5, 1],
   *   }}
   * />
   * ```
   *
   */
  ranges: Record<string, [number, number]>;
  /**
   *The number of digits to appear after the decimal point; should be a value between 0 and 100.
   */
  fractionDigits: number;
}> &
  BoxProps &
  PropsWithChildren;

export type ProgressBarProps = Props;

/**
 * ## ProgressBar
 * Progress indicators inform users about the status of ongoing processes.
 */
export const ProgressBar = (props: Props) => {
  const {
    className,
    value,
    minValue = 0,
    maxValue = 1,
    color,
    ranges = {},
    children,
    fractionDigits = 0,
    ...rest
  } = props;
  const scaledValue = scale(value, minValue, maxValue);
  const hasContent = children !== undefined;

  const effectiveColor =
    color || keyOfMatchingRange(value, ranges) || 'default';

  // We permit colors to be in hex format, rgb()/rgba() format,
  // a name for a color-<name> class, or a base CSS class.
  const outerProps = computeBoxProps(rest);

  const outerClasses = ['ProgressBar', className, computeBoxClassName(rest)];
  const fillStyles: CSSProperties = {
    width: `${clamp01(scaledValue) * 100}%`,
  };
  if (
    CSS_COLORS.includes(effectiveColor as any) ||
    effectiveColor === 'default'
  ) {
    // If the color is a color-<name> class, just use that.
    outerClasses.push(`ProgressBar--color--${effectiveColor}`);
  } else {
    // Otherwise, set styles directly.
    outerProps.style = { ...outerProps.style, borderColor: effectiveColor };
    fillStyles.backgroundColor = effectiveColor;
  }

  return (
    <div className={classes(outerClasses)} {...outerProps}>
      <div
        className="ProgressBar__fill ProgressBar__fill--animated"
        style={fillStyles}
      />
      <div className="ProgressBar__content">
        {hasContent
          ? children
          : `${toFixed(scaledValue * 100, fractionDigits)}%`}
      </div>
    </div>
  );
};

type CountdownProps = Omit<Props, 'value'> & {
  start: number;
  current: number;
  end: number;
  rate?: number;
};

type CountdownState = {
  value: number;
};

export class ProgressBarCountdown extends Component<
  CountdownProps,
  CountdownState
> {
  timer: ReturnType<typeof setInterval> | null = null;

  constructor(props) {
    super(props);
    this.timer = null;
    this.state = {
      value: Math.max(props.current * 100, 0), // ds -> ms
    };
  }
  static defaultProps = {
    rate: 1000,
  };

  tick() {
    const newValue = Math.max(this.state.value + this.props.rate, 0);
    if (newValue <= 0) {
      clearInterval(this.timer);
    }
    this.setState((prevState) => {
      return {
        value: newValue,
      };
    });
  }

  componentDidMount() {
    this.timer = setInterval(() => this.tick(), this.props.rate);
  }

  componentWillUnmount() {
    clearInterval(this.timer);
  }

  render() {
    const { start, current, end, ...rest } = this.props;
    const frac = (this.state.value / 100 - start) / (end - start);
    return <ProgressBar value={frac} {...rest} />;
  }
}

ProgressBar.Countdown = ProgressBarCountdown;
