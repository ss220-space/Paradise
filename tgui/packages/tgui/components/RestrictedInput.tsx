import { classes } from 'common/react';
import { clamp } from 'common/math';
import React, {
  Component,
  createRef,
  ChangeEvent,
  FocusEvent,
  KeyboardEvent,
} from 'react';
import { Box } from './Box';
import { KEY_ESCAPE, KEY_ENTER } from 'common/keycodes';

const DEFAULT_MIN = 0;
const DEFAULT_MAX = 10000;

type Props = {
  value?: number;
  onChange?: (event: ChangeEvent<HTMLInputElement>, value: number) => void;
  onInput?: (event: ChangeEvent<HTMLInputElement>, value: number) => void;
  onEnter?: (event: KeyboardEvent<HTMLInputElement>, value: number) => void;
  onEscape?: (event: KeyboardEvent<HTMLInputElement>) => void;
  minValue?: number;
  maxValue?: number;
  allowFloats?: boolean;
  autoFocus?: boolean;
  autoSelect?: boolean;
  fluid?: boolean;
  monospace?: boolean;
  className?: string;
};

interface State {
  editing: boolean;
}

const getClampedNumber = (
  value: string | undefined,
  minValue?: number,
  maxValue?: number,
  allowFloats?: boolean
): string => {
  const minimum = minValue ?? DEFAULT_MIN;
  const maximum = maxValue ?? DEFAULT_MAX;

  if (!value || value.length === 0) {
    return String(minimum);
  }

  const parsedFloat = parseFloat(value.replace(/[^\-\d.]/g, ''));
  const parsedValue = allowFloats ? parsedFloat : Math.round(parsedFloat);

  if (isNaN(parsedValue)) {
    return String(minimum);
  }

  return String(clamp(parsedValue, minimum, maximum));
};

export class RestrictedInput extends Component<Props, State> {
  inputRef = createRef<HTMLInputElement>();

  constructor(props: Props) {
    super(props);
    this.state = {
      editing: false,
    };
  }

  handleBlur = (e: FocusEvent<HTMLInputElement>) => {
    if (this.state.editing) {
      this.setEditing(false);
    }
  };

  handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    const { maxValue, minValue, onChange, allowFloats } = this.props;
    e.target.value = getClampedNumber(
      e.target.value,
      minValue,
      maxValue,
      allowFloats
    );
    onChange?.(e, +e.target.value);
  };

  handleFocus = (e: FocusEvent<HTMLInputElement>) => {
    if (!this.state.editing) {
      this.setEditing(true);
    }
  };

  handleInput = (e: ChangeEvent<HTMLInputElement>) => {
    const { onInput } = this.props;
    if (!this.state.editing) {
      this.setEditing(true);
    }
    onInput?.(e, +e.target.value);
  };

  handleKeyDown = (e: KeyboardEvent<HTMLInputElement>) => {
    const {
      maxValue,
      minValue,
      onChange,
      onEnter,
      onEscape,
      allowFloats,
      value,
    } = this.props;

    if (e.keyCode === KEY_ENTER) {
      const safeNum = getClampedNumber(
        e.currentTarget.value,
        minValue,
        maxValue,
        allowFloats
      );
      this.setEditing(false);
      onChange?.(e as any, +safeNum); // `as any` due to shared handler signature
      onEnter?.(e, +safeNum);
      e.currentTarget.blur();
      return;
    }

    if (e.keyCode === KEY_ESCAPE) {
      onEscape?.(e);
      this.setEditing(false);
      e.currentTarget.value = value?.toString() ?? '';
      e.currentTarget.blur();
    }
  };

  componentDidMount() {
    const { maxValue, minValue, allowFloats, autoFocus, autoSelect } =
      this.props;
    const input = this.inputRef.current;
    const nextValue = this.props.value?.toString();

    if (input) {
      input.value = getClampedNumber(
        nextValue,
        minValue,
        maxValue,
        allowFloats
      );
      if (autoFocus || autoSelect) {
        setTimeout(() => {
          input.focus();
          if (autoSelect) {
            input.select();
          }
        }, 1);
      }
    }
  }

  componentDidUpdate(prevProps: Props) {
    const { maxValue, minValue, allowFloats, value } = this.props;
    const { editing } = this.state;
    const input = this.inputRef.current;

    if (input && !editing) {
      const nextValue = value?.toString();
      const prevValue = prevProps.value?.toString();
      if (nextValue !== prevValue && nextValue !== input.value) {
        input.value = getClampedNumber(
          nextValue,
          minValue,
          maxValue,
          allowFloats
        );
      }
    }
  }

  setEditing(editing: boolean) {
    this.setState({ editing });
  }

  render() {
    const {
      onChange,
      onEnter,
      onInput,
      onEscape,
      value,
      className,
      fluid,
      monospace,
      ...rest
    } = this.props;

    return (
      <Box
        className={classes([
          'Input',
          fluid && 'Input--fluid',
          monospace && 'Input--monospace',
          className,
        ])}
        {...rest}
      >
        <div className="Input__baseline">.</div>
        <input
          className="Input__input"
          onChange={this.handleChange}
          onInput={this.handleInput}
          onFocus={this.handleFocus}
          onBlur={this.handleBlur}
          onKeyDown={this.handleKeyDown}
          ref={this.inputRef}
          type="number"
        />
      </Box>
    );
  }
}
