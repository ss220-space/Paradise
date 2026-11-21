import { useEffect } from 'react';

const FLIGHT_KEYS: Record<string, string> = {
  KeyW: 'W',
  KeyA: 'A',
  KeyS: 'S',
  KeyD: 'D',
  KeyQ: 'Q',
  KeyE: 'E',
  Space: 'Space',
  ShiftLeft: 'Shift',
  ShiftRight: 'Shift',
};

export const useHelmFlightKeys = (enabled: boolean) => {
  useEffect(() => {
    if (!enabled) return;
    const held = new Map<string, string>();
    const sendFlightKeys = () => {
      const keys = [...held.values()].filter((key) => key !== 'Shift');
      Byond.command(`HelmInput "${Byond.windowId}" "${keys.join(',') || '-'}"`);
    };
    const changeKey = (key: string, down: boolean) => {
      if (key === 'Shift') {
        Byond.command(`${down ? 'KeyDown' : 'KeyUp'} "Shift" 0 0 0 0`);
      } else {
        sendFlightKeys();
      }
    };
    const release = () => {
      const keys = new Set(held.values());
      held.clear();
      if (keys.delete('Shift')) changeKey('Shift', false);
      if (keys.size) sendFlightKeys();
    };
    const keyEvent = (event: KeyboardEvent) => {
      const key = FLIGHT_KEYS[event.code];
      if (!key) return;
      const down = event.type === 'keydown';
      if (!down && held.has(event.code)) {
        held.delete(event.code);
        if (![...held.values()].includes(key)) changeKey(key, false);
      } else {
        const typing =
          event.target instanceof Element &&
          event.target.closest(
            'textarea, input:not([type="range"]), select, [contenteditable="true"]',
          );
        if (
          !down ||
          typing ||
          event.ctrlKey ||
          event.altKey ||
          event.metaKey ||
          event.isComposing
        )
          return;
        if (!held.has(event.code)) {
          const alreadyHeld = [...held.values()].includes(key);
          held.set(event.code, key);
          if (!alreadyHeld) changeKey(key, true);
        }
      }
      event.preventDefault();
      event.stopPropagation();
    };
    const visibility = () => {
      if (document.hidden) release();
    };
    document.addEventListener('keydown', keyEvent, true);
    document.addEventListener('keyup', keyEvent, true);
    document.addEventListener('visibilitychange', visibility);
    window.addEventListener('blur', release);
    return () => {
      document.removeEventListener('keydown', keyEvent, true);
      document.removeEventListener('keyup', keyEvent, true);
      document.removeEventListener('visibilitychange', visibility);
      window.removeEventListener('blur', release);
      release();
    };
  }, [enabled]);
};
