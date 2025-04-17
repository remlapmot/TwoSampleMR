library("vcr") # *Required* as vcr is set up on loading
invisible(vcr::vcr_configure(
  filter_sensitive_data = list("<<<opengwas_x_test_mode_key>>>" = Sys.getenv('OPENGWAS_X_TEST_MODE_KEY')),
  dir = vcr::vcr_test_path("fixtures")
))
vcr::check_cassette_names()
