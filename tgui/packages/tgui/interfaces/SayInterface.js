import { useBackend, useLocalState } from '../backend';
import { Button, Input } from '../components';
import { Window } from "../layouts";
import { RADIO_CHANNELS } from "../constants";
import { createLogger } from "common/logging";
import { logger } from "../logging";
import { winset } from "../byond";
import { classes, pureComponentHooks, shallowDiffers } from "common/react";
import { KEY_1, KEY_8 } from "../hotkeys";

const channelsNamesMap = {
  Common: ";",
  Command: ":c",
  Security: ":s",
  Engineering: ":e",
  Science: ":n",
  Medical: ":m",
  Supply: ":u",
  Service: ":z",
  Procedure: ":x",
};

export const SayInterface = (properties, context) => {
  const { store } = context;
  const { data, act, dispatch } = useBackend(context);
  const {
    channels,
  } = data;
  const channelsArray = Object.keys(channels);
  const [text, setText] = useLocalState(context, "text", 0);
  const [chosenRadio, setChosenRadio] = useLocalState(context, "chosenRadio", " ");

  const handleRadioChosen = radio => {
    setChosenRadio(radio === chosenRadio ? " " : radio);
  };

  const test = () => {
    logger.log('test232');
  };
  // test = e => {
  //   logger.log('test');
  //   const keyCode = window.event ? e.which : e.keyCode;
  //   if (e.ctrlKey && keyCode >= KEY_1 && keyCode <= KEY_8) {
  //     handleRadioChosen(Object.keys(channelsNamesMap)[keyCode - 49]);
  //   }
  // };

  const handleSay = () => {
    let modifiedText = text;
    if (Object.keys(channelsNamesMap).includes(chosenRadio)) {
      modifiedText = `${channelsNamesMap[chosenRadio]} ${text}`;
    }
    act('Say', { text: modifiedText });
  };

  return (
    <Window onComponentDidAppear={test} title={chosenRadio} theme="no-logo">
      <div className="say-container">
        <div className="say-channels">
          {Object.keys(channelsNamesMap).map(channel => (
            <ChannelButton activeChannel={chosenRadio} key={channel} channel={channel} onClick={() => handleRadioChosen(channel)} />
          ))}
        </div>
        <div style={{ display: "flex" }}>
          <Input style={{ flex: 1 }} onInput={(e, value) => setText(value)} onEnter={() => handleSay()} />
        </div>
      </div>
    </Window>
  );
};

const findChannelColor = channel => {
  return RADIO_CHANNELS.find(ch => ch.name === channel)?.color;
};

const ChannelButton = props => {
  const {
    channel,
    style,
    onClick,
    activeChannel,
  } = props;

  const isActive = () => {
    return activeChannel === channel;
  };

  return (
    <Button style={{ ...style }} className={classes(["say-buttons", isActive() && 'say-active-channel'])} backgroundColor={findChannelColor(channel)} content={channel[0]} onClick={e => onClick(e)} />
  );
};
