import './styles/main.scss';

import { useEffect, useRef, useState } from 'react';
import { dragStartHandler } from 'tgui/drag';
import { isEscape, KEY } from 'common/keys';
import { BooleanLike, classes } from 'common/react';
import { Channel, ChannelIterator } from './ChannelIterator';
import { ChatHistory, HistoryRecord } from './ChatHistory';
import {
  LineLength,
  RADIO_PREFIXES,
  BINARY_PREFIXES,
  WindowSize,
} from './constants';
import { getPrefix, windowClose, windowOpen, windowSet } from './helpers';
import { byondMessages } from './timers';
type ByondOpen = {
  channel: Channel;
};
type ByondProps = {
  maxLength: number;
  lightMode: BooleanLike;
  scale: BooleanLike;
};
const ROWS: Record<keyof typeof WindowSize, number> = {
  Small: 1,
  Medium: 2,
  Large: 3,
  Width: 1, // not used
} as const;

export const TguiSay = () => {
  const innerRef = useRef<HTMLTextAreaElement>(null);
  const channelIterator = useRef(new ChannelIterator());
  const chatHistory = useRef(new ChatHistory());
  const messages = useRef(byondMessages);
  const scale = useRef(true);
  // I initially wanted to make these an object or a reducer, but it's not really worth it.
  // You lose the granulatity and add a lot of boilerplate.
  const [buttonContent, setButtonContent] = useState('');
  const [currentPrefix, setCurrentPrefix] = useState<
    keyof typeof RADIO_PREFIXES | null
  >(null);
  const [lightMode, setLightMode] = useState(false);
  const [maxLength, setMaxLength] = useState(1024);
  const [size, setSize] = useState(WindowSize.Small);
  const [value, setValue] = useState('');

  const position = useRef([window.screenX, window.screenY]);
  const isDragging = useRef(false);
  const handleArrowKeys = (direction: KEY.Up | KEY.Down): void => {
    const chat = chatHistory.current;
    const iterator = channelIterator.current;
    if (direction === KEY.Up) {
      if (chat.isAtLatest() && value) {
        // Save current message to temp history if at the most recent message
        chat.saveTemp({
          value: value,
          channel: iterator.current(),
          prefix: currentPrefix,
        });
      }
      // Try to get the previous message, fall back to the current value if none
      const prevMessage = chat.getOlderMessage();
      if (prevMessage) {
        UpdateInput(prevMessage);
      }
    } else {
      const nextMessage = chat.getNewerMessage() || chat.getTemp();
      if (nextMessage) UpdateInput(nextMessage);
    }
  };
  const handleBackspaceDelete = (): void => {
    const chat = chatHistory.current;
    const iterator = channelIterator.current;
    // User is on a chat history message
    if (!chat.isAtLatest()) {
      chat.reset();
      setButtonContent(currentPrefix ?? iterator.current());
      // Empty input, resets the channel
    } else if (currentPrefix && iterator.isSay() && value?.length === 0) {
      setCurrentPrefix(null);
      setButtonContent(iterator.current());
    } else if (
      innerRef.current?.selectionStart === 0 &&
      innerRef.current?.selectionEnd === 0 &&
      !iterator.isCurrentChannelBlacklisted()
    ) {
      setCurrentPrefix(null);
      iterator.set('Сказать');
      setButtonContent(iterator.current());
    }
  };

  const handleButtonClick = (
    event: React.MouseEvent<HTMLButtonElement>
  ): void => {
    isDragging.current = true;

    setTimeout(() => {
      // So the button doesn't jump around accidentally
      if (isDragging.current) {
        dragStartHandler(event.nativeEvent);
      }
    }, 50);
  };

  // Prevents the button from changing channels if it's dragged
  const handleButtonRelease = (): void => {
    isDragging.current = false;
    const currentPosition = [window.screenX, window.screenY];
    if (JSON.stringify(position.current) !== JSON.stringify(currentPosition)) {
      position.current = currentPosition;
      return;
    }
    handleIncrementChannel();
  };

  const handleClose = (): void => {
    innerRef.current?.blur();
    windowClose(scale.current);
    setTimeout(() => {
      chatHistory.current.reset();
      channelIterator.current.reset();
      unloadChat();
    }, 25);
  };
  const handleEnter = (): void => {
    const iterator = channelIterator.current;
    const prefix = currentPrefix ?? null;
    const channel = iterator.current();
    if (value?.length && value.length < maxLength) {
      chatHistory.current.add({
        prefix: prefix,
        channel: channel,
        value: value,
      });
      Byond.sendMessage('entry', {
        channel: channel,
        entry: iterator.isSay() ? (prefix || '') + value : value,
      });
    }
    handleClose();
  };
  const unloadChat = (): void => {
    setCurrentPrefix(null);
    setButtonContent(channelIterator.current.current());
    setValue('');
  };
  const handleForceSay = (): void => {
    const iterator = channelIterator.current;
    // Only force say if we're on a visible channel and have typed something
    if (!value || iterator.isVisible()) return;
    const prefix = currentPrefix ?? '';
    const grunt = iterator.isSay() ? prefix + value : value;
    messages.current.forceSayMsg(grunt, iterator.current());
    unloadChat();
  };

  const handleIncrementChannel = (): void => {
    const iterator = channelIterator.current;
    iterator.next();
    setButtonContent(iterator.current());
    setCurrentPrefix(null);
    messages.current.channelIncrementMsg(iterator.isVisible());
    innerRef.current.focus();
  };

  const handleInput = (event: React.FormEvent<HTMLTextAreaElement>): void => {
    const iterator = channelIterator.current;
    let newValue = event.currentTarget.value;

    // Early check for standard radio channel key
    if (newValue && newValue.slice(0, 2) === '; ') {
      iterator.set('Радио');
      setCurrentPrefix(null);
      setValue(newValue.slice(2));
      setButtonContent(iterator.current());
      return;
    }

    let newPrefix = getPrefix(newValue) || currentPrefix;

    // Handles switching prefixes
    if (newPrefix && newPrefix !== currentPrefix) {
      newValue = newValue.slice(3);
      UpdatePrefix(newPrefix);
    }
    // Handles typing indicators
    UpdateTyping(newPrefix);
    setValue(newValue);
  };

  const UpdatePrefix = (prefix: keyof typeof RADIO_PREFIXES | null) => {
    const iterator = channelIterator.current;
    setButtonContent(RADIO_PREFIXES[prefix]);
    setCurrentPrefix(prefix);
    iterator.set('Сказать');
    if (prefix in BINARY_PREFIXES) {
      Byond.sendMessage('thinking', { visible: false });
    }
  };

  const UpdateTyping = (prefix: keyof typeof RADIO_PREFIXES | null) => {
    if (channelIterator.current.isVisible() && !(prefix in BINARY_PREFIXES)) {
      messages.current.typingMsg();
    }
  };

  const UpdateInput = ({ value, prefix, channel }: HistoryRecord) => {
    const iterator = channelIterator.current;
    channel = channel || 'Сказать';
    if (prefix && prefix !== currentPrefix) {
      UpdatePrefix(prefix);
    } else if (channel) {
      setCurrentPrefix(null);
      iterator.set(channel);
      setButtonContent(channel);
    }

    UpdateTyping(prefix);
    setValue(value);
  };

  const handleKeyDown = (
    event: React.KeyboardEvent<HTMLTextAreaElement>
  ): void => {
    if (event.getModifierState('AltGraph')) return;

    switch (event.key) {
      case KEY.Up:
      case KEY.Down:
        event.preventDefault();
        handleArrowKeys(event.key);
        break;
      case KEY.Delete:
      case KEY.Backspace:
        handleBackspaceDelete();
        break;
      case KEY.Enter:
        event.preventDefault();
        handleEnter();
        break;
      case KEY.Tab:
        event.preventDefault();
        handleIncrementChannel();
        break;
      default:
        if (isEscape(event.key)) {
          handleClose();
        }
        if (event.altKey && event.shiftKey) {
          setTimeout(() => {
            if (innerRef.current) {
              innerRef.current.focus();
            }
          }, 10);
        }
    }
  };

  const handleOpen = (data: ByondOpen): void => {
    channelIterator.current.set(data.channel);

    setCurrentPrefix(null);
    setButtonContent(channelIterator.current.current());

    windowOpen(channelIterator.current.current(), scale.current);

    innerRef.current?.focus();
  };

  const handleProps = (data: ByondProps): void => {
    setMaxLength(data.maxLength);
    setLightMode(!!data.lightMode);
    scale.current = !!data.scale;
  };
  /** Subscribe to Byond messages */
  useEffect(() => {
    Byond.subscribeTo('props', handleProps);
    Byond.subscribeTo('force', handleForceSay);
    Byond.subscribeTo('open', handleOpen);
  }, []);
  /** Value has changed, we need to check if the size of the window is ok */
  useEffect(() => {
    const len = value?.length || 0;
    let newSize: WindowSize;
    if (len > LineLength.Medium) {
      newSize = WindowSize.Large;
    } else if (len <= LineLength.Medium && len > LineLength.Small) {
      newSize = WindowSize.Medium;
    } else {
      newSize = WindowSize.Small;
    }
    if (size !== newSize) {
      setSize(newSize);
      windowSet(newSize, scale.current);
    }
  }, [value]);
  const theme =
    (lightMode && 'lightMode') ||
    (currentPrefix && RADIO_PREFIXES[currentPrefix]) ||
    channelIterator.current.current();
  return (
    <>
      <div
        className={`window window-${theme} window-${size}`}
        onMouseDown={dragStartHandler}
        style={{
          zoom: scale.current ? '' : `${100 / window.devicePixelRatio}%`,
        }}
      >
        {!lightMode && <div className={`shine shine-${theme}`} />}
      </div>
      <div
        className={classes(['content', lightMode && 'content-lightMode'])}
        style={{
          zoom: scale.current ? '' : `${100 / window.devicePixelRatio}%`,
        }}
      >
        <button
          className={`button button-${theme}`}
          onMouseDown={handleButtonClick}
          onMouseUp={handleButtonRelease}
          type="button"
        >
          {buttonContent}
        </button>
        <textarea
          autoCorrect="off"
          className={`textarea textarea-${theme}`}
          maxLength={maxLength}
          onInput={handleInput}
          onKeyDown={handleKeyDown}
          ref={innerRef}
          spellCheck={false}
          rows={ROWS[size] || 1}
          value={value}
        />
      </div>
    </>
  );
};
