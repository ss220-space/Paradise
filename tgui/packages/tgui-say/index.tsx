import './styles/main.scss';
import { render } from 'react-dom';

import { TguiSay } from './TguiSay';

document.onreadystatechange = function () {
  if (document.readyState !== 'complete') return;

  const root = document.getElementById('react-root');
  render(<TguiSay />, root);
};
