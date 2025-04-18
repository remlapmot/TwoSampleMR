context("ld")

skip_on_cran()

vcr::use_cassette("test_ld_01", {
# extract some data
a <- extract_instruments("ieu-a-2", clump=FALSE)
out <- clump_data(a)
})

vcr::use_cassette("test_ld_02", {
test_that("clump", {
  skip_if_not(exists('a'), "a not created in test above")
  skip_if_not(exists('out'), "out not created in test above")
	expect_equal(ncol(a), ncol(out))
	expect_true(nrow(a) > nrow(out))
	expect_true(nrow(out) > 0)
})
})

vcr::use_cassette("test_ld_03", {
test_that("matrix", {
  skip_if_not(exists('out'), "out not created in test above")
	b <- ld_matrix(out$SNP)
	expect_equal(nrow(b), nrow(out))
	expect_equal(ncol(b), nrow(out))
})
})

vcr::use_cassette("test_ld_04", {
test_that("clump multiple", {
	a <- extract_instruments(c("ieu-a-2", "ieu-a-1001"), clump=FALSE)
	out <- clump_data(a)
	expect_equal(length(unique(a$id.exposure)), length(unique(out$id.exposure)))
})
})

test_that("clump local", {
  skip_if_not(exists('a'), "a not created in test above")
	skip_if_not(file.exists("/Users/gh13047/repo/opengwas-api-internal/opengwas-api/app/ld_files/EUR.bim"))
	aclump <- clump_data(a, bfile="/Users/gh13047/repo/opengwas-api-internal/opengwas-api/app/ld_files/EUR", plink_bin="plink")
})
