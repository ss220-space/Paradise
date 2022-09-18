import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input } from '../components';
import { Window } from "../layouts";
import { RADIO_CHANNELS } from "../constants";
import { classes } from "common/react";
import { KEY_1, KEY_9, KEY_Q, KEY_E } from "../hotkeys";
import { logger } from "../logging";

const channelsNamesMap = {
  Common: {
    key: ";",
    icon: "users",
  },
  Command: {
    key: ":c",
    icon: "star",
  },
  Security: {
    key: ":s",
    icon: "shield-alt",
  },
  Engineering: {
    key: ":e",
    icon: "wrench",
  },
  Science: {
    key: ":n",
    icon: "flask",
  },
  Medical: {
    key: ":m",
    icon: "heartbeat",
  },
  Supply: {
    key: ":u",
    icon: "cubes",
  },
  Service: {
    key: ":z",
    icon: "concierge-bell",
  },
  Procedure: {
    key: ":x",
    icon: "gavel",
  },
  ["AI Private"]: {
    key: ":p",
    icon: "laptop",
  },
};

const specialChannelsNames = {
  Syndicate: {
    key: ":t",
    icon: "strikethrough",
  },
  SyndTeam: {
    key: ":_",
    icon: "strikethrough",
  },
  SyndTaipan: {
    key: ":,",
    icon: "strikethrough",
  },
  ["Response Team"]: {
    key: ":$",
    icon: "registered",
  },
  ["Special Ops"]: {
    key: ":-",
    icon: "skull",
  },
};

export const SayInterface = (properties, context) => {
  const { data, act } = useBackend(context);
  const {
    channels,
    languages,
  } = data;
  const availableChannels = Object.keys(channelsNamesMap).filter(channel => Object.keys(channels).includes(channel));
  const enabledChannels = Object.entries(channels).filter(value => value[1]).map(channel => channel[0]);

  const enabledSpecialChannels = Object.keys(specialChannelsNames).filter(channel => enabledChannels.includes(channel));

  const [text, setText] = useLocalState(context, "text", "");
  const [chosenRadio, setChosenRadio] = useLocalState(context, "chosenRadio", " ");

  const handleRadioChosen = radio => {
    if (!enabledChannels.includes(radio) && radio !== " ") {
      return;
    }

    setChosenRadio(radio === chosenRadio ? " " : radio);
  };

  const handleHotkey = e => {
    if (!e.ctrlKey) {
      return;
    }

    const keyCode = window.event ? e.which : e.keyCode;
    if (keyCode >= KEY_1 && keyCode <= KEY_9) {
      handleRadioChosen(availableChannels[keyCode - 49]);
    } else if (keyCode === 192) {
      handleRadioChosen(" ");
    }
  };

  const handleSay = () => {
    let modifiedText = text;
    if (enabledChannels.includes(chosenRadio)) {
      modifiedText = `${channelsNamesMap[chosenRadio]?.key} ${text}`;
    }
    act('Say', { text: modifiedText });
  };

  return (
    <Window title={chosenRadio} theme="no-logo" icon="comment-dots">
      <Box className="say-container" onKeyDown={handleHotkey}>
        <div className="say-channels">
          {availableChannels.map(channel => (
            <ChannelButton
              disabled={!enabledChannels.includes(channel)}
              icon={channelsNamesMap[channel]?.icon}
              activeChannel={chosenRadio}
              key={channel}
              channel={channel}
              onClick={() => handleRadioChosen(channel)}
            />
          ))}

          <div className="say-channels-special">
            {enabledSpecialChannels.map(channel => (
              <ChannelButton
                icon={specialChannelsNames[channel]?.icon}
                activeChannel={chosenRadio}
                key={channel}
                channel={channel}
                onClick={() => handleRadioChosen(channel)}
              />
            ))}
          </div>
        </div>
        <div style={{ display: "flex" }}>
          <Input className="say-input" autofocus fluid onInput={(e, value) => setText(value)} onEnter={() => handleSay()} />
        </div>
        <div className="say-buttons">
          <Button content="Ok" onClick={() => handleSay()} />
        </div>
      </Box>
    </Window>
  );
};

const findChannelColor = channel => {
  return RADIO_CHANNELS.find(ch => ch.name === channel)?.color;
};

const ChannelButton = props => {
  const {
    icon,
    channel,
    style,
    onClick,
    activeChannel,
    disabled,
  } = props;

  const isActive = () => {
    return activeChannel === channel;
  };

  return (
    <Button
      icon={icon}
      disabled={disabled}
      style={{ ...style }}
      className={classes(["say-channel-button", isActive() && 'say-active-channel'])}
      backgroundColor={findChannelColor(channel)}
      onClick={e => onClick(e)}
    />
  );
};
