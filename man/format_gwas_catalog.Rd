% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_data.R
\name{format_gwas_catalog}
\alias{format_gwas_catalog}
\title{Get data selected from GWAS catalog into correct format}
\usage{
format_gwas_catalog(gwas_catalog_subset, type = "exposure")
}
\arguments{
\item{gwas_catalog_subset}{Subset of rows from \code{data(gwas_catalog)}}

\item{type}{Are these data used as "exposure" or "outcome"? Default is "exposure"}

\item{traitname}{If specified, will name the exposure/outcome this variable. Otherwise (default) will name it based on the Phenotype columnin \code{gwas_catalog_subset}}
}
\value{
Data frame
}
\description{
Subset the GWAS catalogue to have the rows you require for instrumenting a particular exposure and then run this command.
Be careful to avoid using different phenotypes, phenotype types, or units together.
}
\examples{
\dontrun{
data(gwas_catalog)
bmi <- subset(gwas_catalog, Phenotype=="Body mass index" & Year==2010 & grepl("kg", Units)
bmi <- format_gwas_catalog(bmi)
}
}
