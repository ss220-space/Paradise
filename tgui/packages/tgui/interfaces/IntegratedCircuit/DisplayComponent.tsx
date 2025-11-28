import { Component, createRef, CSSProperties, RefObject } from 'react';
import { Button, Stack, Box } from '../../components';
import { classes } from 'common/react';

import { noop } from './constants';
import { Port } from './Port';
import { DisplayComponentProps } from './types';

export class DisplayComponent extends Component<DisplayComponentProps> {
  ref: RefObject<HTMLDivElement>;
  constructor(props) {
    super(props);
    this.ref = createRef();
  }

  componentDidUpdate() {
    const { onDisplayUpdated } = this.props;
    if (onDisplayUpdated) {
      onDisplayUpdated(this.ref.current);
    }
  }

  componentDidMount() {
    const { onDisplayLoaded } = this.props;
    if (onDisplayLoaded) {
      onDisplayLoaded(this.ref.current);
    }
  }

  shouldComponentUpdate(nextProps, nextState) {
    if (nextProps.component !== this.props.component) {
      return true;
    }
    if (nextProps.top !== this.props.top) {
      return true;
    }
    if (nextProps.left !== this.props.left) {
      return true;
    }
    return false;
  }

  render() {
    const { component, fixedSize, ...rest } = this.props;
    const categoryClass = `ObjectComponent__Category__${component.category || 'Unassigned'}`;
    return (
      <Box {...rest}>
        <div ref={this.ref}>
          <Box
            py={1}
            px={1}
            className={classes(['ObjectComponent__Titlebar', categoryClass])}
          >
            <Stack>
              <Stack.Item grow={1}>{component.name}</Stack.Item>
              {!!component.ui_alerts &&
                Object.keys(component.ui_alerts).map((icon) => (
                  <Stack.Item key={icon}>
                    <Button
                      icon={icon}
                      className={categoryClass}
                      compact
                      tooltip={component.ui_alerts[icon]}
                    />
                  </Stack.Item>
                ))}
              <Stack.Item>
                <Button
                  icon="info"
                  compact
                  className={categoryClass}
                  tooltip={component.description}
                  tooltipPosition="top"
                />
              </Stack.Item>
            </Stack>
          </Box>
          <Box className="ObjectComponent__Content" py={1} px={1}>
            <Stack>
              <Stack.Item grow={fixedSize}>
                <Stack vertical fill>
                  {component.input_ports.map((port, portIndex) => (
                    <Stack.Item key={portIndex}>
                      <Port port={port} act={noop} />
                    </Stack.Item>
                  ))}
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <Stack vertical>
                  {component.output_ports.map((port, portIndex) => (
                    <Stack.Item key={portIndex}>
                      <Port port={port} act={noop} isOutput />
                    </Stack.Item>
                  ))}
                </Stack>
              </Stack.Item>
            </Stack>
          </Box>
        </div>
      </Box>
    );
  }
}
