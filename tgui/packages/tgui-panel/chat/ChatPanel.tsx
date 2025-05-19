/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Component, createRef, RefObject } from 'react';
import { Button } from 'tgui/components';
import { shallowDiffers } from 'common/react';

import { chatRenderer } from './renderer';

type Props = {
  fontSize?: number;
  lineHeight?: number;
};

type State = {
  scrollTracking: boolean;
};

export class ChatPanel extends Component<Props, State> {
  ref: RefObject<HTMLDivElement>;
  handleScrollTrackingChange: (v: boolean) => void;
  constructor(props: Props) {
    super(props);
    this.ref = createRef();
    this.state = {
      scrollTracking: true,
    };
    this.handleScrollTrackingChange = (value: boolean) =>
      this.setState({
        scrollTracking: value,
      });
  }

  componentDidMount() {
    chatRenderer.mount(this.ref.current);
    chatRenderer.events.on(
      'scrollTrackingChanged',
      this.handleScrollTrackingChange
    );
    this.componentDidUpdate();
  }

  componentWillUnmount() {
    chatRenderer.events.off(
      'scrollTrackingChanged',
      this.handleScrollTrackingChange
    );
  }

  componentDidUpdate(prevProps?) {
    requestAnimationFrame(() => {
      chatRenderer.ensureScrollTracking();
    });
    const shouldUpdateStyle =
      !prevProps || shallowDiffers(this.props, prevProps);
    if (shouldUpdateStyle) {
      chatRenderer.assignStyle({
        width: '100%',
        whiteSpace: 'pre-wrap',
        fontSize: this.props.fontSize,
        lineHeight: this.props.lineHeight,
      });
    }
  }

  render() {
    const { scrollTracking } = this.state;
    return (
      <>
        <div className="Chat" ref={this.ref} />
        {!scrollTracking && (
          <Button
            className="Chat__scrollButton"
            icon="arrow-down"
            onClick={() => chatRenderer.scrollToBottom()}
          >
            Scroll to bottom
          </Button>
        )}
      </>
    );
  }
}
