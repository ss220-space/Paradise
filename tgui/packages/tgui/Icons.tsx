import { Suspense, useEffect } from 'react';
import { fetchRetry } from 'common/https';

import { resolveAsset } from './assets';
import { logger } from 'common/logging';

const loadIconMap = () => {
  fetchRetry(resolveAsset('icon_ref_map.json'))
    .then((res) => res.json())
    .then((data) => (Byond.iconRefMap = data))
    .catch((error) => logger.log(error));
};

const IconMapLoader = () => {
  useEffect(() => {
    if (Object.keys(Byond.iconRefMap).length === 0) {
      loadIconMap();
    }
  }, []);

  return null;
};

export const IconProvider = () => {
  return (
    <Suspense fallback={null}>
      <IconMapLoader />
    </Suspense>
  );
};
