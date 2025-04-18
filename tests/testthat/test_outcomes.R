context("outcome")

skip_on_cran()

vcr::use_cassette("test_outcomes_01", {
a <- extract_instruments("ieu-a-7")
})

vcr::use_cassette("test_outcomes_02", {
test_that("outcomes 1", {
	b <- extract_outcome_data(a$SNP, "ieu-a-2", proxies=FALSE)
	expect_true(nrow(b) < 30 & nrow(b) > 15)
})
})

vcr::use_cassette("test_outcomes_03", {
test_that("outcomes 2", {
	b <- extract_outcome_data(a$SNP, "ieu-a-2", proxies=TRUE)
	expect_true(nrow(b) > 30 & nrow(b) < nrow(a))
})
})

vcr::use_cassette("test_outcomes_04", {
test_that("outcomes 3", {
	b <- extract_outcome_data(a$SNP, c("ieu-a-2", "a"), proxies=FALSE)
	expect_true(nrow(b) < 30 & nrow(b) > 15)
})
})

vcr::use_cassette("test_outcomes_05", {
test_that("outcomes 4", {
	b <- extract_outcome_data(a$SNP, c("ieu-a-2", "a"), proxies=TRUE)
	expect_true(nrow(b) > 30 & nrow(b) < nrow(a))
})
})

vcr::use_cassette("test_outcomes_06", {
test_that("outcomes 5", {
	b <- extract_outcome_data(a$SNP, c("ieu-a-2", "ieu-a-7"), proxies=FALSE)
	expect_true(nrow(b) > 60)
})
})

vcr::use_cassette("test_outcomes_07", {
test_that("outcomes 6", {
	b <- extract_outcome_data(a$SNP, c("ieu-a-2", "ieu-a-7"), proxies=TRUE)
	expect_true(nrow(b) > 70)
})
})
