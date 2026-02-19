import {
  type MouseEventHandler,
  type ReactNode,
  useEffect,
  useRef,
  useState,
} from 'react';
import { KEY, isEscape } from 'common/keys';
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
  onDrag: (event: MouseEvent, value: number) => void;
  /** The step size. */
  step: number;
  /** The step size in pixels. */
  stepPixelSize: number;

  /** Whether to unclamp the value. */
  unclamped: boolean;
  /** The unit of the value. */
  unit: string;
  /** The rate at which the value is updated. */
  updateRate: number;
}> &
  Omit<BoxProps, 'children'>;

const DEFAULT_UPDATE_RATE = 400;

const ORIGIN_UNSET = -1;

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
    dragMatrix = [1, 0],
    format,
    maxValue = Number.POSITIVE_INFINITY,
    minValue = Number.NEGATIVE_INFINITY,
    onChange,
    onDrag,
    step = 1,
    stepPixelSize = 1,

    unclamped,
    unit,
    updateRate = DEFAULT_UPDATE_RATE,
    // Box props
    fontSize,
    height,
    lineHeight,
  } = props;

  // just to re-render
  const [_stateValue, setStateValue] = useState(props.value);
  const [editing, setEditing] = useState(false);

  const dragging = useRef(false);
  const finalValue = useRef(props.value);
  const internalValue = useRef(0);
  const origin = useRef(ORIGIN_UNSET);

  const inputRef = useRef<HTMLInputElement | null>(null);
  const dragIntervalRef = useRef<NodeJS.Timeout | null>(null);
  const timerRef = useRef<NodeJS.Timeout | null>(null);

  useEffect(() => {
    if (props.value !== finalValue.current) {
      finalValue.current = props.value;
      setStateValue(props.value);
    }
  }, [props.value]);

  /** Handed to the child component - onMouseDown  */
  const handleDragStart = (event: React.MouseEvent<HTMLDivElement>) => {
    if (editing) return;

    document.body.style['pointer-events'] = 'none';

    origin.current = getScalarScreenOffset(event.nativeEvent, dragMatrix);
    internalValue.current = props.value;
    dragging.current = true;

    document.addEventListener('mouseup', handleDragEnd);

    timerRef.current = setTimeout(() => {
      checkDragging(event.nativeEvent);
    }, 100);
  };

  /** Called after x seconds to ensure it's still dragging */
  const checkDragging = (event: MouseEvent) => {
    if (dragging.current) {
      document.addEventListener('mousemove', handleDragMove);

      dragIntervalRef.current = setInterval(() => {
        if (dragging.current) onDrag?.(event, props.value);
      }, updateRate);
    } else {
      setEditing(true);

      if (inputRef.current) {
        const input = inputRef.current;
        input.value = internalValue.current.toString();

        setTimeout(() => {
          input.focus();
          input.select();
        }, 10);
      }
    }

    if (timerRef.current) clearTimeout(timerRef.current);
  };

  /** User has held mouse down and is moving */
  const handleDragMove = (event: MouseEvent) => {
    const position = getScalarScreenOffset(event, dragMatrix);
    const offset = position - origin.current;

    const stepOffset = Number.isFinite(minValue) ? minValue % step : 0;

    // Translate mouse movement to value
    // Give it some headroom (by increasing clamp range by 1 step)
    internalValue.current = clamp(
      internalValue.current + (offset * step) / stepPixelSize,
      minValue - step,
      maxValue + step
    );

    const clamped = clamp(
      internalValue.current - (internalValue.current % step) + stepOffset,
      minValue,
      maxValue
    );

    finalValue.current = clamped;
    setStateValue(clamped);

    origin.current = position;
  };

  /** Ends all drag/click events */
  const handleDragEnd = (event: MouseEvent) => {
    document.body.style['pointer-events'] = 'auto';

    if (dragIntervalRef.current) clearInterval(dragIntervalRef.current);

    origin.current = ORIGIN_UNSET;

    document.removeEventListener('mousemove', handleDragMove);
    document.removeEventListener('mouseup', handleDragEnd);

    if (!dragging.current) return; // user only clicked

    onChange?.(event, finalValue.current);
    onDrag?.(event, finalValue.current);
    dragging.current = false;
  };

  const handleKeyDown = (event: React.KeyboardEvent<HTMLInputElement>) => {
    if (event.key === KEY.Enter || isEscape(event.key)) {
      setEditing(false);
    }
  };

  const handleBlur = (event: React.FocusEvent<HTMLInputElement>) => {
    let ourValue = Number.parseFloat(event.currentTarget.value);

    if (!unclamped) {
      ourValue = clamp(ourValue, minValue, maxValue);
    }

    if (Number.isNaN(ourValue)) {
      setEditing(false);
      return;
    }

    internalValue.current = ourValue;
    finalValue.current = ourValue;
    setStateValue(ourValue);

    onChange?.(event.nativeEvent, ourValue);

    if (editing) {
      setEditing(false);
    }
  };

  let displayValue = props.value;
  if (dragging.current) {
    displayValue = finalValue.current;
  }

  const displayElement: ReactNode = (
    <>
      {animated && !dragging.current ? (
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
        display: !editing ? 'none' : undefined,
        height: height as StyleProp,
        lineHeight: lineHeight as StyleProp,
        fontSize: fontSize as StyleProp,
      }}
      onBlur={handleBlur}
      onKeyDown={handleKeyDown}
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
