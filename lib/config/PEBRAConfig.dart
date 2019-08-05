/// Configuration of how the PEBRApp operates

// how often (in days) automated backups should happen
const int AUTO_BACKUP_EVERY_X_DAYS = 1;

// how often (in days) automated viral load fetches should happen
const int AUTO_VL_FETCH_EVERY_X_DAYS = 1;

// show a warning after this many days without backup
const int SHOW_BACKUP_WARNING_AFTER_X_DAYS = 7;

// show a warning after this many days without a viral load fetch
const int SHOW_VL_FETCH_WARNING_AFTER_X_DAYS = 7;

// viral load in c/mL above which it counts as "unsuppressed"
const int VL_SUPPRESSED_THRESHOLD = 1000;

// how long after the app has been unused should the app be locked with a PIN
const int SECONDS_UNTIL_APP_LOCK = 60;

// if the device width is below this value use the narrow design
const double NARROW_DESIGN_WIDTH = 500.0;
