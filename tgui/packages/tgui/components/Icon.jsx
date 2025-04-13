/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes, pureComponentHooks } from 'common/react';
import { Box, computeBoxProps, computeBoxClassName } from './Box';

const FA_OUTLINE_REGEX = /-o$/;

export const Icon = (props) => {
  const { name, size, spin, className, rotation, inverse, ...rest } = props;
  const boxProps = computeBoxProps(rest);
  if (size) {
    if (!boxProps.style) {
      boxProps.style = {};
    }
    boxProps.style['font-size'] = size * 100 + '%';
  }
  if (typeof rotation === 'number') {
    if (!boxProps.style) {
      boxProps.style = {};
    }
    boxProps.style['transform'] = `rotate(${rotation}deg)`;
  }
  const faRegular = FA_OUTLINE_REGEX.test(name);
  const faName = name.replace(FA_OUTLINE_REGEX, '');
  return (
    <i
      className={classes([
        'Icon',
        faRegular ? 'far' : 'fas',
        'fa-' + faName,
        spin && 'fa-spin',
        className,
        computeBoxClassName(rest),
      ])}
      {...boxProps}
    />
  );
};

Icon.defaultHooks = pureComponentHooks;

export const IconStack = (props) => {
  const { className, style = {}, children, ...rest } = props;
  return (
    <span
      class={classes(['IconStack', className, computeBoxClassName(rest)])}
      style={style}
      {...computeBoxProps(rest)}
    >
      {children}
    </span>
  );
};

Icon.Stack = IconStack;
