import {
  donationsHide,
  donationsLoadData,
  donationsShow,
  donationsToggle,
} from './actions';

const initialState = {
  visible: false,
  monthDonations: 0,
  targetDonation: 0,
  ttsTargetDonation: 0,
  donationsText: '',
  boostyUrl: '',
  kofiUrl: '',
  discordUrl: '',
};

export const donationsReducer = (state = initialState, action) => {
  const { type, payload } = action;
  if (type === donationsShow.type) {
    return {
      ...state,
      visible: true,
    };
  }
  if (type === donationsHide.type) {
    return {
      ...state,
      visible: false,
    };
  }
  if (type === donationsToggle.type) {
    return {
      ...state,
      visible: !state.visible,
    };
  }
  if (type === donationsLoadData.type) {
    const {
      month_donations,
      target_donation,
      tts_target_donation,
      donations_text,
      boosty_url,
      kofi_url,
      discord_url,
    } = payload;
    return {
      ...state,
      visible: true,
      monthDonations: month_donations,
      targetDonation: target_donation,
      ttsTargetDonation: tts_target_donation,
      donationsText: donations_text,
      boostyUrl: boosty_url,
      kofiUrl: kofi_url,
      discordUrl: discord_url,
    };
  }
  return state;
};
