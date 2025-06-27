/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import {
  type KeyboardEvent,
  type SyntheticEvent,
  useEffect,
  useRef,
} from 'react';
import { KEY, isEscape } from 'common/keys';
import { classes } from 'common/react';
import { debounce } from 'common/timer';
import { Box, type BoxProps } from './Box';

type ConditionalProps =
  | {
      /**
       * Mark this if you want to debounce onInput.
       *
       * This is useful for expensive filters, large lists etc.
       *
       * Requires `onInput` to be set.
       */
      expensive?: boolean;
      /**
       * Fires on each key press / value change. Used for searching.
       *
       * If it's a large list, consider using `expensive` prop.
       */
      onInput: (event: SyntheticEvent<HTMLInputElement>, value: string) => void;
    }
  | {
      /** This prop requires onInput to be set */
      expensive?: never;
      onInput?: never;
    };

type OptionalProps = Partial<{
  /** Automatically focuses the input on mount */
  autoFocus: boolean;
  /** Automatically selects the input value on focus */
  autoSelect: boolean;
  /** The class name of the input */
  className: string;
  /** Disables the input */
  disabled: boolean;
  /** Mark this if you want the input to be as wide as possible */
  fluid: boolean;
  /** The maximum length of the input value */
  maxLength: number;
  /** Mark this if you want to use a monospace font */
  monospace: boolean;
  /** Fires when user is 'done typing': Clicked out, blur, enter key */
  onChange: (event: SyntheticEvent<HTMLInputElement>, value: string) => void;
  /** Fires once the enter key is pressed */
  onEnter: (event: SyntheticEvent<HTMLInputElement>, value: string) => void;
  /** Fires once the escape key is pressed */
  onEscape: (event: SyntheticEvent<HTMLInputElement>) => void;
  /** The placeholder text when everything is cleared */
  placeholder: string;
  /** Clears the input value on enter */
  selfClear: boolean;
  /** Auto-updates the input value on props change, ie, data from Byond */
  updateOnPropsChange: boolean;
  /** The state variable of the input. */
  value: string | number;
}>;

type Props = OptionalProps & ConditionalProps & Omit<BoxProps, 'children'>;

type InputValue = string | number | undefined;

export const toInputValue = (value: InputValue): string => {
  return typeof value !== 'number' && typeof value !== 'string'
    ? ''
    : String(value);
};

const inputDebounce = debounce((onInput: () => void) => onInput(), 250);

/**
 * ### Input
 * A basic text input which allow users to enter text into a UI.
 * > Input does not support custom font size and height due to the way
 * > it's implemented in CSS. Eventually, this needs to be fixed.
 */
export const Input = (props: Props) => {
  const {
    autoFocus,
    autoSelect,
    className,
    disabled,
    expensive,
    fluid,
    maxLength,
    monospace,
    onChange,
    onEnter,
    onEscape,
    onInput,
    placeholder,
    selfClear,
    updateOnPropsChange,
    value,
    ...rest
  } = props;

  const inputRef = useRef<HTMLInputElement>(null);

  const handleInput = (event: SyntheticEvent<HTMLInputElement>) => {
    if (!onInput) return;

    const value = event.currentTarget?.value;

    if (expensive) {
      inputDebounce(() => onInput(event, value));
    } else {
      onInput(event, value);
    }
  };

  const handleKeyDown = (event: KeyboardEvent<HTMLInputElement>) => {
    if (event.key === KEY.Enter) {
      onEnter?.(event, event.currentTarget.value);
      if (selfClear) {
        event.currentTarget.value = '';
      } else {
        event.currentTarget.blur();
        onChange?.(event, event.currentTarget.value);
      }

      return;
    }

    if (isEscape(event.key)) {
      onEscape?.(event);

      event.currentTarget.value = toInputValue(value);
      event.currentTarget.blur();
    }
  };

  const setValue = (newValue: InputValue) => {
    const input = inputRef.current;
    if (!input) return;

    const changed = toInputValue(newValue);
    if (input.value === changed) return;

    input.value = changed;
  };

  /** Focuses the input on mount */
  useEffect(() => {
    const input = inputRef.current;

    if (input) {
      setValue(value);

      const hasFocusOrSelect = autoFocus || autoSelect;
      const isActive = document.activeElement === input;

      if (hasFocusOrSelect && !isActive) {
        setTimeout(() => {
          input.focus();

          if (autoSelect) {
            input.select();
          }
        }, 1);
      }
    }
  }, []);

  /** Updates the value on props change */
  useEffect(() => {
    if (updateOnPropsChange) {
      const input = inputRef.current;
      if (input) {
        const isActive = document.activeElement === input;
        if (!isActive) {
          setValue(value);
        }
      }
    }
  }, [value]);

  return (
    <Box
      className={classes([
        'Input',
        fluid && 'Input--fluid',
        monospace && 'Input--monospace',
        disabled && 'Input--disabled',
        className,
      ])}
      {...rest}
    >
      <div className="Input__baseline">.</div>
      <input
        className="Input__input"
        disabled={disabled}
        maxLength={maxLength}
        onBlur={(event) => onChange?.(event, event.target.value)}
        onChange={handleInput}
        onKeyDown={handleKeyDown}
        placeholder={placeholder}
        ref={inputRef}
      />
    </Box>
  );
};
