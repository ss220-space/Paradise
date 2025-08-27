import { globalStore } from './backend';
import { IconProvider } from './Icons';

export const App = () => {
  const { getRoutedComponent } = require('./routes');
  const Component = getRoutedComponent(globalStore);

  return (
    <>
      <Component />
      <IconProvider />
    </>
  );
};
