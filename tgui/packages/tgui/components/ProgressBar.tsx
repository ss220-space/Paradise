/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { clamp01, scale, keyOfMatchingRange, toFixed } from 'common/math';
import { classes } from 'common/react';
import { BoxProps, computeBoxClassName, computeBoxProps } from './Box';
import { CSS_COLORS } from '../constants';
import { PropsWithChildren, Component } from 'react';

type Props = {
  value: number;
} & Partial<{
  backgroundColor: string;
  className: string;
  color: string;
  height: string | number;
  maxValue: number;
  minValue: number;
  ranges: Record<string, [number, number]>;
  style: Partial<HTMLDivElement['style']>;
  title: string;
  width: string | number;
  fractionDigits: number;
}> &
  Partial<BoxProps> &
  PropsWithChildren;

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
  const fillStyles = {
    width: clamp01(scaledValue) * 100 + '%',
  };
  if (CSS_COLORS.includes(effectiveColor) || effectiveColor === 'default') {
    // If the color is a color-<name> class, just use that.
    outerClasses.push('ProgressBar--color--' + effectiveColor);
  } else {
    // Otherwise, set styles directly.
    outerProps.style = { ...outerProps.style, borderColor: effectiveColor };
    fillStyles['backgroundColor'] = effectiveColor;
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
          : toFixed(scaledValue * 100, fractionDigits) + '%'}
      </div>
    </div>
  );
};

export class ProgressBarCountdown extends Component {
  timer;
  constructor(props) {
    super(props);
    this.timer = null;
    this.state = {
      value: Math.max(props.current * 100, 0), // ds -> ms
    };
  }

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

ProgressBarCountdown.defaultProps = {
  rate: 1000,
};

ProgressBar.Countdown = ProgressBarCountdown;
