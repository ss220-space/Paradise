import {
  type MouseEventHandler,
  type ReactNode,
  useRef,
  useState,
  useEffect,
} from 'react';
import { KEY } from 'common/keys';
import { clamp } from 'common/math';
import { AnimatedNumber } from './AnimatedNumber';
import type { BoxProps } from './Box';

type StyleProp = string | number | undefined;

type Control = {
  /** Tooltip-like node to display. */
  displayElement: ReactNode;
  /** The value to display. */
  displayValue: number;
  /** Whether the element is being dragged */
  dragging: boolean;
  /** Whether the input is currently being edited */
  editing: boolean;
  /** Attach this to the element you want to be draggable  */
  handleDragStart: MouseEventHandler<HTMLDivElement>;
  /** The input element. */
  inputElement: ReactNode;
};

type Props = {
  children: (control: Control) => ReactNode;
  /** The external state value. */
  value: number;
} & Partial<{
  /** Animates the value if it was changed externally. */
  animated: boolean;
  /** Whether component disabled. */
  disabled: boolean;
  /** The matrix to use for the drag. */
  dragMatrix: [number, number];
  /** Format the value using this function before displaying it. */
  format: (value: number) => string;
  /** The maximum value. */
  maxValue: number;
  /** The minimum value. */
  minValue: number;
  /** An event which fires when you release the input, or successfully enter a number. */
  onChange: (event: Event, value: number) => void;
  /** An event which fires when you drag the input. */
  onDragInput: (event: MouseEvent, value: number) => void;
  /** The step size. */
  step: number;
  /** The step size in pixels. */
  stepPixelSize: number;
  /** The number of milliseconds to suppress flickering. */
  suppressFlicker: number;
  /** Whether to unclamp the value. */
  unclamped: boolean;
  /** The unit of the value. */
  unit: string;
  /** The rate at which the value is updated. */
  updateRate: number;
}> &
  Omit<BoxProps, 'children'>;

const DEFAULT_UPDATE_RATE = 400;

/** Reduces screen offset to a single number based on the matrix provided. */
const getScalarScreenOffset = (event: MouseEvent, matrix: number[]) => {
  return event.screenX * matrix[0] + event.screenY * matrix[1];
};

/**
 * ## DraggableControl
 *
 * A wrapper component for draggable elements.
 * Generally, you won't need to use this component directly.
 */
export const DraggableControl = (props: Props) => {
  const {
    // Our props
    animated,
    children,
    disabled,
    dragMatrix = [1, 0],
    format,
    maxValue = Number.POSITIVE_INFINITY,
    minValue = Number.NEGATIVE_INFINITY,
    onChange,
    onDragInput,
    step = 1,
    stepPixelSize = 1,
    suppressFlicker = 50,
    unclamped,
    unit,
    updateRate = DEFAULT_UPDATE_RATE,
    // Box props
    fontSize,
    height,
    lineHeight,
  } = props;

  const [finalValue, setFinalValue] = useState(props.value);
  const [editing, setEditing] = useState(false);
  const [suppressingFlicker, setSuppressingFlicker] = useState(false);

  const dragging = useRef(false);
  const internalValue = useRef(0);
  const origin = useRef(0);

  const flickerTimer = useRef<NodeJS.Timeout | null>(null);
  const inputRef = useRef<HTMLInputElement | null>(null);
  const dragIntervalRef = useRef<NodeJS.Timeout | null>(null);
  const timerRef = useRef<NodeJS.Timeout | null>(null);

  useEffect(() => {
    setFinalValue(props.value);
  }, [props.value]);

  const handleDragEnd = (event: MouseEvent) => {
    document.body.style['pointer-events'] = 'auto';

    if (timerRef.current) clearTimeout(timerRef.current);
    if (dragIntervalRef.current) clearInterval(dragIntervalRef.current);

    dragging.current = false;
    setEditing(false);
    origin.current = 0;
    document.removeEventListener('mousemove', handleDragMove);
    document.removeEventListener('mouseup', handleDragEnd);

    suppress();
    onChange?.(event, internalValue.current);
    onDragInput?.(event, internalValue.current);

    if (inputRef.current) {
      const input = inputRef.current;
      input.value = internalValue.toString();

      setTimeout(() => {
        input.focus();
        input.select();
      }, 10);
    }
  };

  /** Triggers on mouse move */
  const handleDragMove = (event: MouseEvent) => {
    if (!origin.current) return;
    const position = getScalarScreenOffset(event, dragMatrix);
    const offset = position - origin.current;

    if (!dragging.current) {
      if (Math.abs(offset) > 4) {
        dragging.current = true;
      }
      return;
    }

    const stepOffset = Number.isFinite(minValue) ? minValue % step : 0;

    // Translate mouse movement to value
    // Give it some headroom (by increasing clamp range by 1 step)
    internalValue.current = clamp(
      internalValue.current + (offset * step) / stepPixelSize,
      minValue - step,
      maxValue + step
    );

    // Clamp the final value
    setFinalValue(
      clamp(
        internalValue.current - (internalValue.current % step) + stepOffset,
        minValue,
        maxValue
      )
    );

    origin.current = position;
  };

  /** Handed to the child component - onMouseDown  */
  const handleDragStart = (event: React.MouseEvent<HTMLDivElement>) => {
    if (editing || disabled) return;

    const baseEvent = event.nativeEvent;

    document.body.style['pointer-events'] = 'none';
    origin.current = getScalarScreenOffset(baseEvent, dragMatrix);
    internalValue.current = props.value;

    timerRef.current = setTimeout(() => {
      dragging.current = true;
    }, 250);

    dragIntervalRef.current = setInterval(() => {
      if (dragging) onDragInput?.(baseEvent, props.value);
    }, updateRate);

    document.addEventListener('mousemove', handleDragMove);
    document.addEventListener('mouseup', handleDragEnd);
  };

  /** Triggers on key down */
  const handleKeyDown = (event: React.KeyboardEvent<HTMLInputElement>) => {
    if (event.key === KEY.Enter) {
      event.preventDefault();
      event.stopPropagation();
      setEventValue(event.nativeEvent, event.currentTarget.value);
      return;
    }
    if (event.key === KEY.Escape) {
      setEditing(false);
      return;
    }
  };

  /** Sets the value of the event */
  const setEventValue = (
    event: KeyboardEvent | FocusEvent,
    newValue: string
  ) => {
    let ourValue = Number.parseFloat(newValue);
    if (!unclamped) {
      ourValue = clamp(ourValue, minValue, maxValue);
    }

    if (Number.isNaN(ourValue)) {
      setEditing(false);
      return;
    }

    setEditing(false);
    setFinalValue(ourValue);
    internalValue.current = ourValue;
    suppress();
    onChange?.(event, ourValue);
  };

  /** Suppresses flickering */
  const suppress = () => {
    if (suppressFlicker <= 0) return;

    const timer = flickerTimer.current;
    if (!timer) return;

    setSuppressingFlicker(true);
    clearTimeout(timer);
    flickerTimer.current = setTimeout(() => {
      setSuppressingFlicker(false);
    }, suppressFlicker);

    return () => clearTimeout(timer);
  };

  /** Triggers on blur */
  const handleBlur = (event: React.FocusEvent<HTMLInputElement>) => {
    if (editing) {
      setEditing(false);
    }

    setEventValue(event.nativeEvent, event.currentTarget.value);
  };

  let displayValue = props.value;
  if (dragging.current || suppressingFlicker) {
    displayValue = finalValue;
  }

  const displayElement: ReactNode = (
    <>
      {animated && !dragging.current && !suppressingFlicker ? (
        <AnimatedNumber value={displayValue} format={format} />
      ) : format ? (
        format(displayValue)
      ) : (
        displayValue
      )}

      {unit ? ` ${unit}` : ''}
    </>
  );

  const inputElement: ReactNode = (
    <input
      ref={inputRef}
      className="NumberInput__input"
      style={{
        display: !editing || disabled ? 'none' : undefined,
        height: height as StyleProp,
        lineHeight: lineHeight as StyleProp,
        fontSize: fontSize as StyleProp,
      }}
      onBlur={handleBlur}
      onKeyDown={handleKeyDown}
      disabled={disabled}
    />
  );

  return children({
    displayElement,
    displayValue,
    dragging: dragging.current,
    editing,
    handleDragStart,
    inputElement,
  });
};
