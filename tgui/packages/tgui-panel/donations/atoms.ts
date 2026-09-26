import { atom } from 'jotai';

export type Meta = {
  monthDonations: number;
  targetDonation: number;
  ttsTargetDonation: number;
  donationsText: string;
  boostyUrl: string;
  kofiUrl: string;
  discordUrl: string;
};

const initialState: Meta = {
  monthDonations: 0,
  targetDonation: 0,
  ttsTargetDonation: 0,
  donationsText: '',
  boostyUrl: '',
  kofiUrl: '',
  discordUrl: '',
};

export const donationVisibleAtom = atom(false);
export const metaAtom = atom<Meta | null>(initialState);

//------- Convenience --------------------------------------------------------//

export const donationsAtom = atom((get) => ({
  visible: get(donationVisibleAtom),
  meta: get(metaAtom),
}));
