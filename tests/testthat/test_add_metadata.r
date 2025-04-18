context("add metadata")

skip_on_cran()

# get required data
# d1 <- extract_instruments('ieu-a-2')
# d2 <- extract_instruments(c('ieu-a-2', 'ieu-a-7'))
# exposure <- extract_instruments("ieu-a-2")[1:5,]
# d3 <- extract_outcome_data(exposure$SNP, 'ieu-a-2')
# d4 <- extract_outcome_data(exposure$SNP, c('ieu-a-2', 'ieu-a-7'))
# d5 <- make_dat(proxies=FALSE)
# d6 <- extract_instruments("ieu-a-2")[1:5,]
# d7 <- extract_outcome_data(exposure$SNP, 'ieu-a-2')
# d8 <- extract_outcome_data(exposure$SNP, 'ukb-d-30710_irnt')
# d9 <- extract_instruments("bbj-a-1")
# d10 <- extract_instruments("ieu-b-109")

# save(d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, file="inst/extdata/test_add_metadata.RData", compress = "xz")

load(system.file("extdata", "test_add_metadata.RData", package="TwoSampleMR"))

vcr::use_cassette("add_metadata_01", {
test_that("exposure data 1", {
	d1 <- d1 %>% add_metadata()
	expect_true("units.exposure" %in% names(d1))
})
})

vcr::use_cassette("add_metadata_02", {
test_that("exposure data 2", {
	d2 <- d2 %>% add_metadata()
	expect_true("units.exposure" %in% names(d2))
})
})

vcr::use_cassette("add_metadata_03", {
test_that("outcome data 1", {
	d3 <- d3 %>% add_metadata()
	expect_true("units.outcome" %in% names(d3))
})
})

vcr::use_cassette("add_metadata_04", {
test_that("outcome data 2", {
	d4 <- d4 %>% add_metadata()
	expect_true("units.outcome" %in% names(d4))
})
})

vcr::use_cassette("add_metadata_05", {
test_that("dat 2", {
	d5 <- d5 %>% add_metadata()
	expect_true("units.outcome" %in% names(d5) & "units.exposure" %in% names(d5))
})
})

vcr::use_cassette("add_metadata_06", {
test_that("no id1", {
	d6$id.exposure <- "not a real id"
	d6 <- add_metadata(d6)
	expect_true(!"units.exposure" %in% names(d6))
})
})

vcr::use_cassette("add_metadata_07", {
test_that("no id2", {
	d7$id.outcome <- "not a real id"
	d7 <- add_metadata(d7)
	expect_true(!"units.outcome" %in% names(d7))
})
})

vcr::use_cassette("add_metadata_08", {
test_that("ukb-d", {
	d8 <- add_metadata(d8)
	expect_true("units.outcome" %in% names(d8))
})
})

vcr::use_cassette("add_metadata_09", {
test_that("bbj-a-1", {
	d9 <- d9 %>% add_metadata()
	expect_true("samplesize.exposure" %in% names(d9))
	expect_true(all(!is.na(d9$samplesize.exposure)))
})
})

vcr::use_cassette("add_metadata_10", {
test_that("ieu-b-109", {
	d10 <- d10 %>% add_metadata()
	expect_true("samplesize.exposure" %in% names(d10))
	expect_true(all(!is.na(d10$samplesize.exposure)))
})
})
