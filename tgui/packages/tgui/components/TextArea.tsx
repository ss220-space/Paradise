/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @author Warlockd
 * @license MIT
 */

import {
  type RefObject,
  forwardRef,
  useEffect,
  useImperativeHandle,
  useRef,
  useState,
} from 'react';
import type { KeyboardEvent, SyntheticEvent } from 'react';
import { KEY, isEscape } from 'common/keys';
import { classes } from 'common/react';
import { Box, type BoxProps } from './Box';
import { toInputValue } from './Input';

type Props = Partial<{
  /** Automatically focus the textarea on mount */
  autoFocus: boolean;
  /** Selects all text on mount */
  autoSelect: boolean;
  /** The value to display in the textarea */
  displayedValue: string;
  /** Don't use tab for indent */
  dontUseTabForIndent: boolean;
  /** Sets width to 100% */
  fluid: boolean;
  /** Maximum length of the textarea */
  maxLength: number;
  /** Removes the border. */
  noborder: boolean;
  /** Fires when user is 'done typing': Clicked out, blur, enter key (but not shift+enter) */
  onChange: (event: SyntheticEvent<HTMLTextAreaElement>, value: string) => void;
  /** Fires once the enter key is pressed */
  onEnter: (event: SyntheticEvent<HTMLTextAreaElement>, value: string) => void;
  /** Fires once the escape key is pressed */
  onEscape: (event: SyntheticEvent<HTMLTextAreaElement>) => void;
  /** Fires on each key press / value change. Used for searching */
  onInput: (event: SyntheticEvent<HTMLTextAreaElement>, value: string) => void;
  /** Dummy text inside the textarea when it's empty */
  placeholder: string;
  /** Whether the textarea is scrollable when it has more content than height */
  scrollbar: boolean;
  /** Clears the textarea when the enter key is pressed */
  selfClear: boolean;
  /** Provides a Record with key: markupChar entries which can be used for ctrl + key combinations to surround a selected text with the markup character */
  userMarkup: Record<string, string>;
  /** The value of the textarea */
  value: string;
}> &
  BoxProps;

const getMarkupString = (
  inputText: string,
  markupType: string,
  startPosition: number,
  endPosition: number
) => {
  return `${inputText.substring(0, startPosition)}${markupType}${inputText.substring(startPosition, endPosition)}${markupType}${inputText.substring(endPosition)}`;
};

/**
 * ## Textarea
 *
 * An input for larger amounts of text. Use this when you want inputs larger
 * than one row.
 */
export const TextArea = forwardRef(
  (props: Props, forwardedRef: RefObject<HTMLTextAreaElement>) => {
    const {
      autoFocus,
      autoSelect,
      displayedValue,
      dontUseTabForIndent,
      maxLength,
      noborder,
      onChange,
      onEnter,
      onEscape,
      onInput,
      placeholder,
      scrollbar,
      selfClear,
      userMarkup,
      value,
      ...boxProps
    } = props;
    const { className, fluid, nowrap, ...rest } = boxProps;

    const textareaRef = useRef<HTMLTextAreaElement>(null);
    const [scrolledAmount, setScrolledAmount] = useState(0);

    const handleKeyDown = (event: KeyboardEvent<HTMLTextAreaElement>) => {
      if (event.key === KEY.Enter) {
        if (event.shiftKey) {
          event.currentTarget.focus();
          return;
        }

        onEnter?.(event, event.currentTarget.value);
        if (selfClear) {
          event.currentTarget.value = '';
        }
        event.currentTarget.blur();
        return;
      }

      if (isEscape(event.key)) {
        onEscape?.(event);
        if (selfClear) {
          event.currentTarget.value = '';
        } else {
          event.currentTarget.value = toInputValue(value);
          event.currentTarget.blur();
        }

        return;
      }

      if (!dontUseTabForIndent && event.key === KEY.Tab) {
        event.preventDefault();
        const { value, selectionStart, selectionEnd } = event.currentTarget;
        event.currentTarget.value = `${value.substring(0, selectionStart)}\t${value.substring(selectionEnd)}`;
        event.currentTarget.selectionEnd = selectionStart + 1;
      }

      if (
        userMarkup &&
        (event.ctrlKey || event.metaKey) &&
        userMarkup[event.key]
      ) {
        event.preventDefault();
        const { value, selectionStart, selectionEnd } = event.currentTarget;
        const markupString = userMarkup[event.key];
        event.currentTarget.value = getMarkupString(
          value,
          markupString,
          selectionStart,
          selectionEnd
        );
        event.currentTarget.selectionEnd =
          selectionEnd + markupString.length * 2;
      }
    };

    useImperativeHandle(
      forwardedRef,
      () => textareaRef.current as HTMLTextAreaElement
    );

    /** Focuses the input on mount */
    useEffect(() => {
      if (!autoFocus && !autoSelect) return;

      const input = textareaRef.current;
      if (!input) return;

      if (autoFocus || autoSelect) {
        setTimeout(() => {
          input.focus();

          if (autoSelect) {
            input.select();
          }
        }, 1);
      }
    }, []);

    /** Updates the initial value on props change */
    useEffect(() => {
      const input = textareaRef.current;
      if (!input) return;

      const newValue = toInputValue(value);
      if (input.value === newValue) return;

      input.value = newValue;
    }, [value]);

    return (
      <Box
        className={classes([
          'TextArea',
          fluid && 'TextArea--fluid',
          noborder && 'TextArea--noborder',
          className,
        ])}
        {...rest}
      >
        {!!displayedValue && (
          <div
            style={{
              height: '100%',
              overflow: 'hidden',
              position: 'absolute',
              width: '100%',
            }}
          >
            <div
              className={classes([
                'TextArea__textarea',
                'TextArea__textarea_custom',
              ])}
              style={{
                transform: `translateY(-${scrolledAmount}px)`,
              }}
            >
              {displayedValue}
            </div>
          </div>
        )}
        <textarea
          autoComplete="off"
          className={classes([
            'TextArea__textarea',
            scrollbar && 'TextArea__textarea--scrollable',
            nowrap && 'TextArea__nowrap',
          ])}
          maxLength={maxLength}
          onBlur={(event) => onChange?.(event, event.target.value)}
          onChange={(event) => onInput?.(event, event.target.value)}
          onKeyDown={handleKeyDown}
          onScroll={() => {
            if (displayedValue && textareaRef.current) {
              setScrolledAmount(textareaRef.current.scrollTop);
            }
          }}
          placeholder={placeholder}
          ref={textareaRef}
          spellCheck={false}
          style={{
            color: displayedValue ? 'rgba(0, 0, 0, 0)' : 'inherit',
          }}
        />
      </Box>
    );
  }
);
