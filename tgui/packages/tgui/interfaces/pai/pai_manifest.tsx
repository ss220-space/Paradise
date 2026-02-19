import { useBackend } from '../../backend';
import { CrewManifest, ManifestData } from '../common/CrewManifest';

export const pai_manifest = (props: unknown) => {
  const { data } = useBackend<PaiData<ManifestData>>();

  return <CrewManifest {...data.app_data} />;
};
