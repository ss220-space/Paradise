import { store } from '../events/store';
import { donationVisibleAtom, type Meta, metaAtom } from './atoms';

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
