import { createAction } from 'common/redux';

export const donationsShow = createAction('donations/show');
export const donationsHide = createAction('donations/hide');
export const donationsToggle = createAction('donations/toggle');
export const donationsLoadData = createAction('donations/load_data');
