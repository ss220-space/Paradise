import './styles/main.scss';

import { useEffect, useRef, useState } from 'react';
import { dragStartHandler, setupDrag } from 'tgui/drag';
import { focusMap } from 'tgui/focus';
import { isEscape, KEY } from 'tgui-core/keys';
import { type BooleanLike, classes } from 'tgui-core/react';
import { type Channel, ChannelIterator } from './ChannelIterator';
import { ChatHistory, type HistoryRecord } from './ChatHistory';
import {
  BINARY_PREFIXES,
  LineLength,
  RADIO_PREFIXES,
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

export const TguiSay = () => {
  const innerRef = useRef<HTMLTextAreaElement>(null);
  const channelIterator = useRef(new ChannelIterator());
  const chatHistory = useRef(new ChatHistory());
  const messages = useRef(byondMessages);
  const scale = useRef(true);
  const currentPrefix = useRef<keyof typeof RADIO_PREFIXES | null>(null);
  // I initially wanted to make these an object or a reducer, but it's not really worth it.
  // You lose the granulatity and add a lot of boilerplate.
  const [buttonContent, setButtonContent] = useState('');
  const [lightMode, setLightMode] = useState(false);
  const [maxLength, setMaxLength] = useState(1024);
  const [size, setSize] = useState(WindowSize.Small);
  const [value, setValue] = useState('');

  const position = useRef([window.screenX, window.screenY]);
  const isDragging = useRef(false);

  function setCurrentPrefix(prefix: keyof typeof RADIO_PREFIXES | null): void {
    currentPrefix.current = prefix;
  }
  const handleArrowKeys = (direction: KEY.Up | KEY.Down): void => {
    const chat = chatHistory.current;
    const iterator = channelIterator.current;
    if (direction === KEY.Up) {
      if (chat.isAtLatest() && value) {
        // Save current message to temp history if at the most recent message
        chat.saveTemp({
          value: value,
          channel: iterator.current(),
          prefix: currentPrefix.current,
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
      setButtonContent(currentPrefix.current ?? iterator.current());
      // Empty input, resets the channel
    } else if (
      currentPrefix.current &&
      iterator.isSay() &&
      value?.length === 0
    ) {
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

  function handleButtonClick(event: React.MouseEvent<HTMLButtonElement>): void {
    isDragging.current = true;
    setTimeout(() => {
      // So the button doesn't jump around accidentally
      if (isDragging.current) {
        dragStartHandler(event.nativeEvent);
      }
    }, 50);
  }

  // Prevents the button from changing channels if it's dragged
  // Prevents the button from changing channels if it's dragged
  function handleButtonRelease(): void {
    isDragging.current = false;
    const currentPosition = [window.screenX, window.screenY];

    if (JSON.stringify(position.current) !== JSON.stringify(currentPosition)) {
      position.current = currentPosition;
      return;
    }

    handleIncrementChannel();
  }

  const handleClose = (): void => {
    focusMap();
    windowClose(scale.current);
    setTimeout(() => {
      chatHistory.current.reset();
      channelIterator.current.reset();
      unloadChat();
    }, 25);
  };
  const handleEnter = (): void => {
    const iterator = channelIterator.current;
    const prefix = currentPrefix.current ?? null;
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
  function handleForceSay(): void {
    const iterator = channelIterator.current;
    const currentValue = innerRef.current?.value;

    // Only force say if we're on a visible channel and have typed something
    if (!currentValue || !iterator.isVisible()) return;

    const prefix = currentPrefix.current ?? '';
    const grunt = iterator.isSay() ? prefix + currentValue : currentValue;

    messages.current.forceSayMsg(grunt, iterator.current());
    handleClose();
  }

  function handleSaveText(): void {
    const iterator = channelIterator.current;
    const currentValue = innerRef.current?.value;

    if (!currentValue || !iterator.isVisible()) return;

    messages.current.saveText(currentValue, iterator.current());
  }

  const handleIncrementChannel = (): void => {
    const iterator = channelIterator.current;
    iterator.next();
    setButtonContent(iterator.current());
    setCurrentPrefix(null);
    messages.current.channelIncrementMsg(iterator.isVisible());
    innerRef?.current?.focus();
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

    const newPrefix = getPrefix(newValue) || currentPrefix.current;

    // Handles switching prefixes
    if (newPrefix && newPrefix !== currentPrefix.current) {
      newValue = newValue.slice(3);
      UpdatePrefix(newPrefix);
    }
    // Handles typing indicators
    UpdateTyping(newPrefix);
    messages.current.saveText(newValue, iterator.current());
    setValue(newValue);
  };

  const UpdatePrefix = (prefix: keyof typeof RADIO_PREFIXES | null) => {
    const iterator = channelIterator.current;
    if (!prefix) return;
    setButtonContent(RADIO_PREFIXES[prefix]);
    setCurrentPrefix(prefix);
    iterator.set('Сказать');
    if (prefix in BINARY_PREFIXES) {
      Byond.sendMessage('thinking', { visible: false });
    }
  };

  const UpdateTyping = (prefix: keyof typeof RADIO_PREFIXES | null) => {
    if (!prefix) return;
    if (channelIterator.current.isVisible() && !(prefix in BINARY_PREFIXES)) {
      messages.current.typingMsg();
    }
  };

  const UpdateInput = ({ value, prefix, channel }: HistoryRecord) => {
    const iterator = channelIterator.current;
    channel = channel || 'Сказать';
    if (prefix && prefix !== currentPrefix.current) {
      UpdatePrefix(prefix);
    } else if (channel) {
      setCurrentPrefix(null);
      iterator.set(channel);
      setButtonContent(channel);
    }

    if (prefix) UpdateTyping(prefix);
    if (value) setValue(value);
  };

  function handleKeyDown(
    event: React.KeyboardEvent<HTMLTextAreaElement>,
  ): void {
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
    }
  }

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
    Byond.subscribeTo('save', handleSaveText);
    Byond.subscribeTo('close', handleClose);
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
      windowSet(newSize, scale.current);
      setSize(newSize);
    }
  }, [value]);
  const theme =
    (lightMode && 'lightMode') ||
    (currentPrefix.current && RADIO_PREFIXES[currentPrefix.current]) ||
    channelIterator.current.current();
  useEffect(() => {
    setupDrag();
  });
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
          className={classes([
            'textarea',
            `textarea-${theme}`,
            value.length > LineLength.Large && 'textarea-large',
          ])}
          maxLength={maxLength}
          onInput={handleInput}
          onKeyDown={handleKeyDown}
          ref={innerRef}
          spellCheck={false}
          value={value}
        />
      </div>
    </>
  );
};
