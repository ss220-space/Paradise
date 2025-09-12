import type { BooleanLike } from 'common/react';
import type { Access } from '../common/AccessList';

export type RadioData = {
  microphone: BooleanLike;
  speaker: BooleanLike;
  frequency: number;
  minFrequency: number;
  maxFrequency: number;
};

export type CargoItem = {
  name: string;
  amount: number;
  ref: string;
};

export type CargoData = {
  capacity: number;
  cargo_list: CargoItem[];
};

export type MainData = {
  isoperator: BooleanLike;
  ui_theme: string;
  name: string;
  integrity: number;
  integrity_max: number;
  power_level: number;
  power_max: number;
  internal_damage: number;
  internal_damage_keys: string[];
  mineral_material_amount: number;

  accesses: number[];
  one_access: BooleanLike;
  regions: Access[];

  use_internal_tank: number;
  cabin_pressure_warning_min: number;
  cabin_pressure_hazard_min: number;
  cabin_pressure_warning_max: number;
  cabin_pressure_hazard_max: number;
  cabin_temp_warning_min: number;
  cabin_temp_warning_max: number;

  one_atmosphere: number;
  cabin_pressure: number;
  cabin_temp: number;
  dna_lock: string | null;
  id_lock_on: BooleanLike;
  maint_access: BooleanLike;
  maintance_progress: BooleanLike;
  mech_view: string;
  modules: MechModule[];
  lights: BooleanLike;
  selected_module_index: number;
  radio_data: RadioData;
  cargo: CargoData;
  diagnostic_status: BooleanLike;
  ui_honked: BooleanLike;
};

export type MechModule = {
  selected: BooleanLike;
  slot: string;
  icon: string;
  icon_state: string;
  name: string;
  detachable: BooleanLike;
  can_be_toggled: BooleanLike;
  can_be_triggered: BooleanLike;
  active: BooleanLike;
  active_label: string;
  equip_cooldown: string;
  energy_per_use: number;
  snowflake: Snowflake;
  ref: string;
};

export type Snowflake = {
  snowflake_id: string;
  integrity: number;
};
