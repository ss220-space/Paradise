import { useBackend } from '../../backend';
import { CrewManifest, type ManifestData } from '../common/CrewManifest';

export const pai_manifest = (_props: unknown) => {
  const { data } = useBackend<PaiData<ManifestData>>();

  return <CrewManifest {...data.app_data} />;
};
