import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input } from '../components';
import { Window } from "../layouts";
import { RADIO_CHANNELS } from "../constants";
import { classes } from "common/react";
import { KEY_1, KEY_9 } from "../hotkeys";
import { logger } from "../logging";

const channelsNamesMap = {
  Common: {
    text: ";",
    icon: "users",
  },
  Command: {
    text: ":c",
    icon: "star",
  },
  Security: {
    text: ":s",
    icon: "shield-alt",
  },
  Engineering: {
    text: ":e",
    icon: "wrench",
  },
  Science: {
    text: ":n",
    icon: "flask",
  },
  Medical: {
    text: ":m",
    icon: "heartbeat",
  },
  Supply: {
    text: ":u",
    icon: "cubes",
  },
  Service: {
    text: ":z",
    icon: "concierge-bell",
  },
  Procedure: {
    text: ":x",
    icon: "gavel",
  },
};

const specialChannelsNames = {
  Syndicate: {
    text: ":t",
    icon: "strikethrough",
  },
  SyndTeam: {
    text: ":_",
    icon: "strikethrough",
  },
  SyndTaipan: {
    text: ":,",
    icon: "strikethrough",
  },
  ["Response Team"]: {
    text: ":$",
    icon: "registered",
  },
  ["Special Ops"]: {
    text: ":-",
    icon: "skull",
  },
};

export const SayInterface = (properties, context) => {
  const { data, act } = useBackend(context);
  const {
    channels,
  } = data;
  const availableChannels = Object.keys(channelsNamesMap).filter(channel => Object.keys(channels).includes(channel));
  const enabledChannels = Object.entries(channels).filter(value => value[1]).map(channel => channel[0]);

  const enabledSpecialChannels = Object.keys(specialChannelsNames).filter(channel => enabledChannels.includes(channel));

  const [text, setText] = useLocalState(context, "text", 0);
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
      modifiedText = `${channelsNamesMap[chosenRadio]?.text} ${text}`;
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
      className={classes(["say-buttons", isActive() && 'say-active-channel'])}
      backgroundColor={findChannelColor(channel)}
      onClick={e => onClick(e)}
    />
  );
};
