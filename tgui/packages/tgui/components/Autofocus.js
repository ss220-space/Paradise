import { Component, createRef } from 'inferno';

export class Autofocus extends Component {
  ref = createRef();

  componentDidMount() {
    this.focusElement();
    this.ref.current?.addEventListener('blur', this.focusElement);
  }

  componentWillUnmount() {
    this.ref.current?.removeEventListener('blur', this.focusElement);
  }

  focusElement = () => {
    setTimeout(() => {
      this.ref.current?.focus();
    }, 1);
  };

  render() {
    return (
      <div ref={this.ref} tabIndex={-1}>
        {this.props.children}
      </div>
    );
  }
}
