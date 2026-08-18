import { store } from '../events/store';
import { type Meta, metaAtom, donationVisibleAtom } from './atoms';

export function showDonations(): void {
  store.set(donationVisibleAtom, true);
}

export function hideDonations(): void {
  store.set(donationVisibleAtom, false);
}

export function loadDonations(payload: Meta): void {
  showDonations();
  store.set(metaAtom, payload);
}
