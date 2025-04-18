context("Instruments")

skip_on_cran()

vcr::use_cassette("test_instruments_01", {
test_that("server and mrinstruments 1", {
	# no no
  exp_dat <- extract_instruments(outcomes=c("ieu-a-1032"))
	expect_true(length(unique(exp_dat$id)) == 0)
})
})

vcr::use_cassette("test_instruments_02", {
test_that("server and mrinstruments 2", {
	# no yes
	exp_dat <- extract_instruments(outcomes=c("ebi-a-GCST004634"))
	expect_true(length(unique(exp_dat$id)) == 1)
})
})

vcr::use_cassette("test_instruments_03", {
test_that("server and mrinstruments 3", {
	# yes no
	exp_dat <- extract_instruments(outcomes=c("ieu-a-2", "ieu-a-1032"))
	expect_true(length(unique(exp_dat$id)) == 1)
})
})

vcr::use_cassette("test_instruments_04", {
test_that("server and mrinstruments 4", {
	# yes yes
	exp_dat <- extract_instruments(outcomes=c("ieu-a-2", "ebi-a-GCST004634"))
	expect_true(length(unique(exp_dat$id)) == 2)
})
})

vcr::use_cassette("test_instruments_05", {
test_that("server and mrinstruments 5", {
	exp_dat <- extract_instruments(outcomes=c("ieu-a-1032", "ebi-a-GCST004634"))
	expect_true(length(unique(exp_dat$id)) == 1)
})
})

vcr::use_cassette("test_instruments_06", {
test_that("server and mrinstruments 6", {
	exp_dat <- extract_instruments(outcomes=c(2,100,"ieu-a-1032",104,72,999))
	expect_true(length(unique(exp_dat$id)) == 5)
})
})

vcr::use_cassette("test_instruments_07", {
test_that("server and mrinstruments 7", {
	exp_dat <- extract_instruments(outcomes=c(2,100,"ieu-a-1032",104,72,999, "ebi-a-GCST004634"))
	expect_true(length(unique(exp_dat$id)) == 6)
})
})

load(system.file("extdata", "test_commondata.RData", package="TwoSampleMR"))

vcr::use_cassette("test_instruments_08", {
test_that("read data", {
	exp_dat <- extract_instruments("ieu-a-2")
	names(exp_dat) <- gsub(".exposure", "", names(exp_dat))
	fn <- tempfile()
	write.table(exp_dat, file=fn, row=FALSE, col=TRUE, qu=FALSE, sep="\t")

	a <- read_exposure_data(fn, sep="\t")
	b <- read_outcome_data(fn, sep="\t")

	expect_true("chr.outcome" %in% names(b))
	expect_true("chr.exposure" %in% names(a))
})
})
