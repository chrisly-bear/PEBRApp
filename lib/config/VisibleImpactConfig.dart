import 'package:flutter/foundation.dart';

/// Configuration of VisibleImpact where all patient data is stored

// API used in the app
// Automatically use production API when running in release mode.
const String VI_API = kReleaseMode ? VI_API_PROD : VI_API_TEST;

// Test API
const String VI_API_TEST = "https://lstowards909090.org/db-test/apiv1";

// Production API
// WARNING: Do not use the production API when testing the app because the data
// that will be created in PBERApp will overwrite the data on VisibleImpact!
// Only use the production API when making a release of PEBRApp.
const String VI_API_PROD = "https://lstowards909090.org/db/apiv1";

// username
const String VI_USERNAME = "";
// password
const String VI_PASSWORD = "";
