#define STARTING_PAYCHECKS 5

#define PAYCHECK_MINIMAL 30
#define PAYCHECK_EASY 40
#define PAYCHECK_MEDIUM 50
#define PAYCHECK_HARD 70
#define PAYCHECK_COMMAND 100
#define PAYCHECK_VIP 300

#define PAYCHECK_WELFARE 20 //NEETbucks


#define NON_STATION_BUDGET_BASE rand(8888888, 11111111)
#define BUDGET_RATIO_TYPE_SINGLE 1 // For Service & Civilian budget
#define BUDGET_RATIO_TYPE_DOUBLE 2 // and for the rest


#define ACCOUNT_STATION_ID "Station"
#define ACCOUNT_STATION_NAME "Station Budget"
#define ACCOUNT_SRV_ID "Service"
#define ACCOUNT_SRV_NAME "Service Budget"
#define ACCOUNT_CAR_ID "Cargo"
#define ACCOUNT_CAR_NAME "Cargo Budget"
#define ACCOUNT_SCI_ID "Science"
#define ACCOUNT_SCI_NAME "Scientific Budget"
#define ACCOUNT_ENG_ID "Engineering"
#define ACCOUNT_ENG_NAME "Engineering Budget"
#define ACCOUNT_MED_ID "Medical"
#define ACCOUNT_MED_NAME "Medical Budget"
#define ACCOUNT_SEC_ID "Security"
#define ACCOUNT_SEC_NAME "Defense Budget"
#define ACCOUNT_VIP_ID "VIP"
#define ACCOUNT_VIP_NAME "Nanotrasen VIP Expense Account Budget"
#define ACCOUNT_NEET_ID "Welfare"
#define ACCOUNT_NEET_NAME "Space Nations Welfare"
#define ACCOUNT_GOLEM_ID "Golem"
#define ACCOUNT_GOLEM_NAME "Shared Mining Account"

// If a vending machine matches its department flag with your bank account's, it gets free.
#define NO_FREEBIES 0 // used for a vendor selling nothing for free
#define ACCOUNT_COM_BITFLAG (1<<0) // for Commander only vendor items (i.e. HoP cartridge vendor)
#define ACCOUNT_CIV_BITFLAG (1<<1)
#define ACCOUNT_SRV_BITFLAG (1<<2)
#define ACCOUNT_CAR_BITFLAG (1<<3)
#define ACCOUNT_SCI_BITFLAG (1<<4)
#define ACCOUNT_ENG_BITFLAG (1<<5)
#define ACCOUNT_MED_BITFLAG (1<<6)
#define ACCOUNT_SEC_BITFLAG (1<<7)
#define ACCOUNT_VIP_BITFLAG (1<<8) // for VIP only vendor items. currently not used.
// this should use the same bitflag values in `\_DEFINES\jobs.dm` to match.
// It's true that bitflags shouldn't be separated in two DEFINES if these are same, but just in case the system can be devided, it's remained separated.

/// How much mail the Economy SS will create per minute, regardless of firing time.
#define MAX_MAIL_PER_MINUTE 3
/// Probability of using letters of envelope sprites on all letters.
#define FULL_CRATE_LETTER_ODDS 70


/// used for custom_currency
#define ACCOUNT_CURRENCY_MINING "mining points"
#define ACCOUNT_CURRENCY_EXPLO "exploration points"

// List of default, game-created departments
#define DEPARTMENT_STATION /datum/department/station
#define DEPARTMENT_ENGINEERING /datum/department/engineering
#define DEPARTMENT_SCIENCE /datum/department/science
#define DEPARTMENT_MEDICAL /datum/department/medical
#define DEPARTMENT_SECURITY /datum/department/security
#define DEPARTMENT_SUPPLY /datum/department/supply
#define DEPARTMENT_KITCHEN /datum/department/kitchen
#define DEPARTMENT_BOTANY /datum/department/botany
#define DEPARTMENT_BAR /datum/department/bar
#define DEPARTMENT_LIBRARY /datum/department/library
#define DEPARTMENT_CHAPEL /datum/department/chapel
#define DEPARTMENT_VIP /datum/department/vip
