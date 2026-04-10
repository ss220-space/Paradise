#define SM_EVENT_THREAT_D "Delta"
#define SM_EVENT_THREAT_C "Charlie"
#define SM_EVENT_THREAT_B "Bravo"
#define SM_EVENT_THREAT_A "Alpha"
#define SM_EVENT_THREAT_S "Sierra"

// These are used by supermatter and supermatter monitor program, mostly for UI updating purposes. Higher should always be worse!
// [/obj/machinery/atmospherics/supermatter_crystal/proc/get_status]
/// Unknown status, shouldn't happen but just in case.
#define SUPERMATTER_ERROR -1
/// No or minimal energy
#define SUPERMATTER_INACTIVE 0
/// Normal operation
#define SUPERMATTER_NORMAL 1
/// Ambient temp 80% of the default temp for SM to take damage.
#define SUPERMATTER_NOTIFY 2
/// Integrity below [/obj/machinery/atmospherics/supermatter_crystal/var/warning_point]. Start complaining on comms.
#define SUPERMATTER_WARNING 3
/// Integrity below [/obj/machinery/atmospherics/supermatter_crystal/var/danger_point]. Start spawning anomalies.
#define SUPERMATTER_DANGER 4
/// Integrity below [/obj/machinery/atmospherics/supermatter_crystal/var/emergency_point]. Start complaining to more people.
#define SUPERMATTER_EMERGENCY 5
/// Currently counting down to delamination. True [/obj/machinery/atmospherics/supermatter_crystal/var/final_countdown]
#define SUPERMATTER_DELAMINATING 6

/// Higher == Crystal safe operational temperature is higher.
#define SUPERMATTER_HEAT_PENALTY_THRESHOLD 40

#define PLASMA_HEAT_PENALTY 15	 // Higher == Bigger heat and waste penalty from having the crystal surrounded by this gas. Negative numbers reduce penalty.
#define OXYGEN_HEAT_PENALTY 1
#define CO2_HEAT_PENALTY 0.1
#define NITROGEN_HEAT_PENALTY -1.5
#define HYDROGEN_HEAT_PENALTY 20
#define H2O_HEAT_PENALTY 5

#define OXYGEN_TRANSMIT_MODIFIER 1.5   //Higher == Bigger bonus to power generation.
#define PLASMA_TRANSMIT_MODIFIER 4
#define HYDROGEN_TRANSMIT_MODIFIER 3
#define H2O_TRANSMIT_MODIFIER -10

#define N2O_HEAT_RESISTANCE 6		  //Higher == Gas makes the crystal more resistant against heat damage.

#define POWERLOSS_INHIBITION_GAS_THRESHOLD 0.20		 //Higher == Higher percentage of inhibitor gas needed before the charge inertia chain reaction effect starts.
#define POWERLOSS_INHIBITION_MOLE_THRESHOLD 20		//Higher == More moles of the gas are needed before the charge inertia chain reaction effect starts.		//Scales powerloss inhibition down until this amount of moles is reached
#define POWERLOSS_INHIBITION_MOLE_BOOST_THRESHOLD 500  //bonus powerloss inhibition boost if this amount of moles is reached

#define O2_CRUNCH 1.5
#define CO2_CRUNCH 1
#define N2_CRUNCH 0.55
#define N2O_CRUNCH 0.55
#define PLASMA_CRUNCH 4
#define HYDROGEN_CRUNCH 2
#define H2O_CRUNCH 0.75

#define MOLE_CRUNCH_THRESHOLD 1700		   //Above this value we can get lord singulo and
#define MOLE_PENALTY_THRESHOLD 1800		   //Above this value we can get lord singulo and independent mol damage, below it we can heal damage
#define MOLE_HEAT_PENALTY 350				 //Heat damage scales around this. Too hot setups with this amount of moles do regular damage, anything above and below is scaled
//Along with damage_penalty_point, makes flux anomalies.
/// The cutoff for the minimum amount of power required to trigger the crystal invasion delamination event.
#define EVENT_POWER_PENALTY_THRESHOLD 4500
#define POWER_PENALTY_THRESHOLD 5000		  //The cutoff on power properly doing damage, pulling shit around, and delamming into a tesla. Low chance of cryo anomalies, +2 bolts of electricity
#define SEVERE_POWER_PENALTY_THRESHOLD 7000   //+1 bolt of electricity, allows for gravitational anomalies, and higher chances of cryo anomalies
#define CRITICAL_POWER_PENALTY_THRESHOLD 9000 //+1 bolt of electricity.
#define DAMAGE_HARDCAP 0.002
#define DAMAGE_INCREASE_MULTIPLIER 0.25


#define THERMAL_RELEASE_MODIFIER 1		 //Higher == less heat released during reaction, not to be confused with the above values
#define PLASMA_RELEASE_MODIFIER 750		//Higher == less plasma released by reaction
#define OXYGEN_RELEASE_MODIFIER 325		//Higher == less oxygen released at high temperature/power

#define REACTION_POWER_MODIFIER 0.55	   //Higher == more overall power

#define MATTER_POWER_CONVERSION 10		 //Crystal converts 1/this value of stored matter into energy.

//These would be what you would get at point blank, decreases with distance
#define DETONATION_RADS 200
#define DETONATION_HALLUCINATION 600

/// All humans within this range will be irradiated
#define DETONATION_RADIATION_RANGE 20

#define WARNING_DELAY 60

#define HALLUCINATION_RANGE(P) (min(7, round((P) ** 0.25)))

#define MIN_GASMIX_POWER_RATIO_FOR_EXPLOSION 0.205

#define GRAVITATIONAL_ANOMALY "gravitational_anomaly"
#define FLUX_ANOMALY "flux_anomaly"
#define BLUESPACE_ANOMALY "bluespace_anomaly"

//If integrity percent remaining is less than these values, the monitor sets off the relevant alarm.
#define SUPERMATTER_DELAM_PERCENT 5
#define SUPERMATTER_EMERGENCY_PERCENT 25
#define SUPERMATTER_DANGER_PERCENT 50
#define SUPERMATTER_WARNING_PERCENT 100
#define CRITICAL_TEMPERATURE 10000

#define SUPERMATTER_COUNTDOWN_TIME 30 SECONDS

///to prevent accent sounds from layering
#define SUPERMATTER_ACCENT_SOUND_MIN_COOLDOWN 2 SECONDS

#define DEFAULT_ZAP_ICON_STATE "sm_arc"
#define SLIGHTLY_CHARGED_ZAP_ICON_STATE "sm_arc_supercharged"
#define OVER_9000_ZAP_ICON_STATE "sm_arc_dbz_referance" //Witty I know

#define MAX_SPACE_EXPOSURE_DAMAGE 2

/// Colours used for effects.
#define SUPERMATTER_COLOUR "#ffd04f"
#define SUPERMATTER_RED "#aa2c16"
#define SUPERMATTER_TESLA_COLOUR "#00ffff"
#define SUPERMATTER_SINGULARITY_RAYS_COLOUR "#750000"
#define SUPERMATTER_SINGULARITY_LIGHT_COLOUR "#400060"

// Zap energy accumulation keys.
/// Normal zap energy accumulation key from normal operations.
#define ZAP_ENERGY_ACCUMULATION_NORMAL "normal"
/// High energy zap energy accumulation key from high energy extra effects.
#define ZAP_ENERGY_ACCUMULATION_HIGH_ENERGY "high"

/// Zap energy discharge portion per tick.
#define ZAP_ENERGY_DISCHARGE_PORTION 0.1

/// The base zap power transmission of the supermatter crystal in W/MeV.
#define BASE_POWER_TRANSMISSION_RATE 1040

/// How much energy we get from external factors that are applied immediately.
#define SM_POWER_EXTERNAL_IMMEDIATE "External Power Gain"
/// How much energy we get from external factors that are applied over time.
#define SM_POWER_EXTERNAL_TRICKLE "External Power Trickle"
/// How much energy is gained from the temperature. Enabled by gas.
#define SM_POWER_HEAT "Gas Heat Power Gain"
/// How much energy the SM loses. Happens over time.
/// Order matters here. We depend on current power + power gained from the factors above for the loss calc.
#define SM_POWER_POWERLOSS "Internal Power Decay"
/// How much of the energy the SM loses is recouped. From gas factors here.
/// Order matters here. We depend on the powerloss amount.
#define SM_POWER_POWERLOSS_GAS "Gas Power Decay Negation"
/// How much of the energy the SM loses is recouped. From the psychologist this time.
/// Order matters here. We depend on the powerloss amount.
#define SM_POWER_POWERLOSS_SOOTHED "Psychologist Power Decay Negation"

/// How much we are multiplying our zap energy.
#define SM_ZAP_BASE "Base Zap Transmission"
/// How much we are multiplying our zap energy because of gas factors.
#define SM_ZAP_GAS "Gas Zap Transmission Modifier"
