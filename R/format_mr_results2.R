#' Split outcome column
#'
#' This function takes the outcome column from the results generated by [mr()] and splits it into separate columns for 'outcome name' and 'id'.
#'
#' @param mr_res Results from [mr()].
#'
#' @export
#' @return data frame
split_outcome <- function(mr_res)
{
	Pos<-grep("\\|\\|",mr_res$outcome) #the "||"" indicates that the outcome column was derived from summary data in MR-Base. Sometimes it wont look like this e.g. if the user has supplied their own outcomes
	if (sum(Pos)!=0) {
		Outcome<-as.character(mr_res$outcome[Pos])
		Vars<-strsplit(Outcome,split= "\\|\\|")
		Vars<-unlist(Vars)
		Vars<-trim(Vars)
		Trait<-Vars[seq(1,length(Vars),by=2)]
		id<-Vars[seq(2,length(Vars),by=2)]
		mr_res$outcome<-as.character(mr_res$outcome)
		mr_res$outcome[Pos]<-Trait
	}
	return(mr_res)
}

#' Split exposure column
#'
#' This function takes the exposure column from the results generated by [mr()] and splits it into separate columns for 'exposure name' and 'id'.
#'
#' @param mr_res Results from [mr()].
#'
#' @export
#' @return data frame
split_exposure <- function(mr_res)
{
	Pos<-grep("\\|\\|",mr_res$exposure) #the "||"" indicates that the outcome column was derived from summary data in MR-Base. Sometimes it wont look like this e.g. if the user has supplied their own outcomes
	# Pos2<-grep("\\|\\|",mr_res$exposure,invert=T)
	# mr_res2 <-mr_res[Pos2,]
	# mr_res1<-mr_res[Pos,]
	if (sum(Pos)!=0) {
		Exposure<-as.character(mr_res$exposure[Pos])
		Vars<-strsplit(as.character(Exposure),split= "\\|\\|")
		Vars<-unlist(Vars)
		Vars<-trim(Vars)
		Trait<-Vars[seq(1,length(Vars),by=2)]
		mr_res$exposure<-as.character(mr_res$exposure)
		mr_res$exposure[Pos]<-Trait
	}
	return(mr_res)
}


#' Generate odds ratios
#'
#' This function takes b and se from [mr()] and generates odds ratios and 95 percent confidence intervals.
#'
#' @param mr_res Results from [mr()].
#'
#' @export
#' @return data frame
generate_odds_ratios <- function(mr_res)
{
	mr_res$lo_ci <- mr_res$b - 1.96 * mr_res$se
	mr_res$up_ci <- mr_res$b + 1.96 * mr_res$se
	mr_res$or <- exp(mr_res$b)
	mr_res$or_lci95 <- exp(mr_res$lo_ci)
	mr_res$or_uci95 <- exp(mr_res$up_ci)
	return(mr_res)
}

#' Subset MR-results on method
#'
#' This function takes MR results from [mr()] and restricts to a single method per exposure x disease combination.
#'
#' @param mr_res Results from [mr()].
#' @param single_snp_method Which of the single SNP methods to use when only 1 SNP was used to estimate the causal effect? The default is `"Wald ratio"`.
#' @param multi_snp_method Which of the multi-SNP methods to use when there was more than 1 SNPs used to estimate the causal effect? The default is `"Inverse variance weighted"`.
#'
#' @export
#' @return data frame.
subset_on_method <- function(mr_res, single_snp_method="Wald ratio", multi_snp_method="Inverse variance weighted")
{
	dat <- subset(mr_res, (nsnp==1 & method==single_snp_method) | (nsnp > 1 & method == multi_snp_method))
	return(dat)

}

#' Combine all mr results
#'
#' This function combines results of [mr()], [mr_heterogeneity()], [mr_pleiotropy_test()] and [mr_singlesnp()] into a single data frame.
#' It also merges the results with outcome study level characteristics in [available_outcomes()].
#' If desired it also exponentiates results (e.g. if the user wants log odds ratio converted into odds ratios with 95 percent confidence intervals).
#' The exposure and outcome columns from the output from [mr()] contain both the trait names and trait ids.
#' The `combine_all_mrresults()` function splits these into separate columns by default.
#'
#' @param res Results from [mr()].
#' @param het Results from [mr_heterogeneity()].
#' @param plt Results from [mr_pleiotropy_test()].
#' @param sin Results from [mr_singlesnp()].
#' @param ao_slc Logical; if set to `TRUE` then outcome study level characteristics are retrieved from [available_outcomes()]. Default is `TRUE`.
#' @param Exp Logical; if set to `TRUE` results are exponentiated. Useful if user wants log odds ratios expressed as odds ratios. Default is `FALSE`.
#' @param split.exposure Logical; if set to `TRUE` the exposure column is split into separate columns for the exposure name and exposure ID. Default is `FALSE`.
#' @param split.outcome Logical; if set to `TRUE` the outcome column is split into separate columns for the outcome name and outcome ID. Default is `FALSE`.
#'
#' @export
#' @return data frame

#
# library(TwoSampleMR)
# library(MRInstruments)

# exp_dat <- extract_instruments(outcomes=c(2,300))

# chd_out_dat <- extract_outcome_data(
#     snps = exp_dat$SNP,
#     outcomes = c(6,7,8,9)
# )

# dat <- harmonise_data(
#     exposure_dat = exp_dat,
#     outcome_dat = chd_out_dat
# )

# dat<-power.prune(dat,method.size=F)


# Res<-mr(dat)
# Het<-mr_heterogeneity(dat)
# Plt<-mr_pleiotropy_test(dat)
# Sin<-mr_singlesnp(dat)

# All.res<-combine_all_mrresults(Res=Res,Het=Het,Plt=Plt,Sin=Sin)
# All.res<-split_exposure(All.res)
# All.res<-split_outcome(All.res)

combine_all_mrresults <- function(res,het,plt,sin,ao_slc=TRUE,Exp=FALSE,split.exposure=FALSE,split.outcome=FALSE)
{
	het<-het[,c("id.exposure","id.outcome","method","Q","Q_df","Q_pval")]

	# Convert all factors to character
	# lapply(names(Res), FUN=function(x) class(Res[,x]))
	Class<-unlist(lapply(names(res), FUN=function(x) class(res[,x])))
	if(any(Class == "factor")) {
		Pos<-which(unlist(lapply(names(res), FUN=function(x) class(res[,x])))=="factor")
		for(i in seq_along(Pos)){
			res[,Pos[i]]<-as.character(res[,Pos[i]])
		}
	}

	# lapply(names(Het), FUN=function(x) class(Het[,x]))
	Class<-unlist(lapply(names(het), FUN=function(x) class(het[,x])))
	if(any(Class == "factor")) {
		Pos<-which(unlist(lapply(names(het), FUN=function(x) class(het[,x])))=="factor")
		for(i in seq_along(Pos)){
			het[,Pos[i]]<-as.character(het[,Pos[i]])
		}
	}

	# lapply(names(Sin), FUN=function(x) class(Sin[,x]))
	Class<-unlist(lapply(names(sin), FUN=function(x) class(sin[,x])))
	if(any(Class == "factor")) {
		Pos<-which(unlist(lapply(names(sin), FUN=function(x) class(sin[,x])))=="factor")
		for(i in seq_along(Pos)){
			sin[,Pos[i]]<-as.character(sin[,Pos[i]])
		}
	}

	sin<-sin[grep("[:0-9:]",sin$SNP),]
	sin$method<-"Wald ratio"
	names(sin)[names(sin)=="p"]<-"pval"

	# Res<-Res[Res$method %in% c("MR Egger","Weighted median","Inverse variance weighted"),]

	#method is also the name of an argument in the method function. this prevents all.x argument from working. rename method column
	names(res)[names(res)=="method"]<-"Method"
	names(het)[names(het)=="method"]<-"Method"
	names(sin)[names(sin)=="method"]<-"Method"

	res<-merge(res,het,by=c("id.outcome","id.exposure","Method"),all.x=TRUE)
	res<-plyr::rbind.fill(res,sin[,c("exposure","outcome","id.exposure","id.outcome","SNP","b","se","pval","Method")])

	if(ao_slc)
	{
		ao<-available_outcomes()
		names(ao)[names(ao)=="nsnp"]<-"nsnps.outcome.array"
		res<-merge(res,ao[,!names(ao) %in% c("unit","priority","sd","path","note","filename","access","mr")],by.x="id.outcome",by.y="id")
	}

	res$nsnp[is.na(res$nsnp)]<-1

	for(i in unique(res$id.outcome))
	{
		Methods<-unique(res$Method[res$id.outcome==i])
		Methods<-Methods[Methods!="Wald ratio"]
		for(j in unique(Methods))
		{
			res$SNP[res$id.outcome == i & res$Method==j]<-paste(res$SNP[res$id.outcome == i & res$Method=="Wald ratio"],collapse="; ")
		}
	}

	if (Exp) {
		res$or<-exp(res$b)
		res$or_lci95<-exp(res$b-res$se*1.96)
		res$or_uci95<-exp(res$b+res$se*1.96)
	}

	# add intercept test from MR Egger
	plt<-plt[,c("id.outcome","id.exposure","egger_intercept","se","pval")]
	plt$Method<-"MR Egger"
	names(plt)[names(plt)=="egger_intercept"]<-"intercept"
	names(plt)[names(plt)=="se"]<-"intercept_se"
	names(plt)[names(plt)=="pval"]<-"intercept_pval"

	res<-merge(res,plt,by=c("id.outcome","id.exposure","Method"),all.x=TRUE)

	if (split.exposure) {
		res<-split_exposure(res)
	}

	if (split.outcome) {
		res<-split_outcome(res)
	}

	Cols<-c("Method","outcome","exposure","nsnp","b","se","pval","intercept","intercept_se","intercept_pval","Q","Q_df","Q_pval","consortium","ncase","ncontrol","pmid","population")

	res<-res[,c(names(res)[names(res) %in% Cols],names(res)[which(!names(res) %in% Cols)])]

	# names(ResSNP)<-tolower(names(ResSNP))
	return(res)
}

#' Power prune
#'
#' When there are duplicate summary sets for a particular exposure-outcome combination, this function keeps the
#' exposure-outcome summary set with the highest expected statistical power.
#' This can be done by dropping the duplicate summary sets with the smaller sample sizes.
#' Alternatively, the pruning procedure can take into account instrument strength and outcome sample size.
#' The latter is useful, for example, when there is considerable variation in SNP coverage between duplicate summary sets
#' (e.g. because some studies have used targeted or fine mapping arrays).
#' If there are a large number of SNPs available to instrument an exposure,
#' the outcome GWAS with the better SNP coverage may provide better power than the outcome GWAS with the larger sample size.
#'
#' @param dat Results from [harmonise_data()].
#' @param method Should the duplicate summary sets be pruned on the basis of sample size alone (`method = 1`)
#' or a combination of instrument strength and sample size (`method = 2`)? Default set to `1`.
#' When set to 1, the duplicate summary sets are first dropped on the basis of the outcome sample size (smaller duplicates dropped).
#' If duplicates are still present, remaining duplicates are dropped on the basis of the exposure sample size (smaller duplicates dropped).
#' When method is set to `2`, duplicates are dropped on the basis of instrument strength
#' (amount of variation explained in the exposure by the instrumental SNPs) and sample size,
#' and assumes that the SNP-exposure effects correspond to a continuous trait with a normal distribution (i.e. exposure cannot be binary).
#' The SNP-outcome effects can correspond to either a binary or continuous trait. If the exposure is binary then `method=1` should be used.
#'
#' @param dist.outcome The distribution of the outcome. Can either be `"binary"` or `"continuous"`. Default set to `"binary"`.
#'
#' @export
#' @return data.frame with duplicate summary sets removed

power_prune <- function(dat,method=1,dist.outcome="binary")
{

	# dat[,c("eaf.exposure","beta.exposure","se.exposure","samplesize.outcome","ncase.outcome","ncontrol.outcome")]
	if (method==1) {
		L<-NULL
		id.sets<-paste(split_exposure(dat)$exposure,split_outcome(dat)$outcome)
		id.set.unique<-unique(id.sets)
		dat$id.set<-as.numeric(factor(id.sets))
		for (i in seq_along(id.set.unique)) {
			# print(i)
			print(paste("finding summary set for --", id.set.unique[i],"-- with largest sample size", sep=""))
			dat1<-dat[id.sets == id.set.unique[i],]
			id.subset<-paste(dat1$exposure,dat1$id.exposure,dat1$outcome,dat1$id.outcome)
			id.subset.unique<-unique(id.subset)
			dat1$id.subset<-as.numeric(factor(id.subset))
			ncase<-dat1$ncase.outcome
			if (is.null(ncase)) {
				ncase<-NA
			}
			if (any(is.na(ncase))) {
				ncase<-dat1$samplesize.outcome
				if(dist.outcome=="binary") warning(paste("dist.outcome set to binary but case sample size is missing. Will use total sample size instead but power pruning may be less accurate"))
			}
			if (any(is.na(ncase))) stop("sample size missing for at least 1 summary set")
			dat1<-dat1[order(ncase,decreasing=TRUE),]
			# id.expout<-paste(split_exposure(dat)$exposure,split_outcome(dat)$outcome)
			ncase<-ncase[order(ncase,decreasing=TRUE)]
			# dat1$power.prune.ncase<-"drop"
			# dat1$power.prune.ncase[ncase==ncase[1]]<-"keep"
			dat1<-dat1[ncase==ncase[1],]
			nexp<-dat1$samplesize.exposure
			dat1<-dat1[order(nexp,decreasing=TRUE),]
			nexp<-nexp[order(nexp,decreasing=TRUE)]
			# dat1$power.prune.nexp<-"drop"
			# dat1$power.prune.nexp[nexp==nexp[1]]<-"keep"
			# dat1$power.prune<-"drop"
			# dat1$power.prune[dat1$power.prune.ncase=="keep" & dat1$power.prune.nexp == "keep"]<-"keep"
			# dat1<-dat1[,!names(dat1) %in% c("power.prune.ncase","power.prune.nexp")]
			# dat1[,c("samplesize.exposure","ncase.outcome","exposure","outcome")]
			dat1<-dat1[nexp==nexp[1],]
			L[[i]]<-dat1
		}
		dat<-do.call(rbind,L)
		dat<-dat[,!names(dat1) %in% c("id.set","id.subset")]
		# if(drop.duplicates == T) {
		# 	dat<-dat[dat$power.prune=="keep",]
		# }
		return(dat)
	}

	if (method==2) {
		L<-NULL
		id.sets<-paste(split_exposure(dat)$exposure,split_outcome(dat)$outcome)
		id.set.unique<-unique(id.sets)
		dat$id.set<-as.numeric(factor(id.sets))
		for (i in seq_along(id.set.unique)) {
			dat1<-dat[id.sets == id.set.unique[i],]
			# unique(dat1[,c("exposure","outcome")])
			id.subset<-paste(dat1$exposure,dat1$id.exposure,dat1$outcome,dat1$id.outcome)
			id.subset.unique<-unique(id.subset)
			dat1$id.subset<-as.numeric(factor(id.subset))
			L1<-NULL
			for (j in seq_along(id.subset.unique)) {
				# print(j)
				print(paste("identifying best powered summary set: ",id.subset.unique[j],sep=""))
				dat2<-dat1[id.subset ==id.subset.unique[j], ]
				p<-dat2$eaf.exposure #effect allele frequency
				# b<-abs(dat2$beta.exposure) # effect of SNP on risk factor
				se<-dat2$se.exposure
				z<-dat2$beta.exposure/dat2$se.exposure
				n<-dat2$samplesize.exposure
				b<-z/sqrt(2*p*(1-p)*(n+z^2))
				if (any(is.na(dat2$ncase.outcome))) stop(paste("number of cases missing for summary set: ",id.subset.unique[j],sep=""))
				n.cas<-dat2$ncase.outcome
				n.con<-dat2$ncontrol.outcome
				var<-1 # variance of risk factor assumed to be 1
				r2<-2*b^2*p*(1-p)/var
				if (any(is.na(r2))) warning("beta or allele frequency missing for some SNPs, which could affect accuracy of power pruning")
				r2<-r2[!is.na(r2)]
				# k<-length(p[!is.na(p)]) #number of SNPs in the instrument / associated with the risk factor
				# n<-min(n) #sample size of the exposure/risk factor GWAS
				r2sum<-sum(r2) # sum of the r-squares for each SNP in the instrument
				# F<-r2sum*(n-1-k)/((1-r2sum*k )
				if (dist.outcome == "continuous") {
					iv.se<- 1/sqrt(mean(dat2$samplesize.outcome, na.rm = TRUE)*r2sum) #standard error of the IV should be proportional to this
				}
				if (dist.outcome == "binary") {
					if(any(is.na(n.cas)) || any(is.na(n.con))) {
						warning("dist.outcome set to binary but number of cases or controls is missing. Will try using total sample size instead but power pruning will be less accurate")
						iv.se<- 1/sqrt(mean(dat2$samplesize.outcome, na.rm = TRUE)*r2sum)
					} else {
                    	iv.se<-1/sqrt(mean(n.cas, na.rm = TRUE)*mean(n.con, na.rm = TRUE)*r2sum) #standard error of the IV should be proportional to this
                    }
				}
				# Power calculations to implement at some point
				# iv.se<-1/sqrt(unique(n.cas)*unique(n.con)*r2sum) #standard error of the IV should be proportional to this
				# n.outcome<-unique(n.con+n.cas)
				# ratio<-unique(n.cas/n.con)
				# sig<-alpha #alpha
				# b1=log(or) # assumed log odds ratio
				# power<-pnorm(sqrt(n.outcome*r2sum*(ratio/(1+ratio))*(1/(1+ratio)))*b1-qnorm(1-sig/2))
				dat2$iv.se<-iv.se
				# dat2$power<-power
				L1[[j]]<-dat2
			}
			L[[i]]<-do.call(rbind,L1)
		}
		dat2<-do.call(rbind,L)
		dat2<-dat2[order(dat2$id.set,dat2$iv.se),]
		id.sets<-unique(dat2$id.set)
		id.keep<-NULL
		for (i in seq_along(id.sets)) {
			# print(i)
			# print(id.sets[i])
			id.temp<-unique(dat2[dat2$id.set==id.sets[i],c("id.set","id.subset")])
			id.keep[[i]]<-paste(id.temp$id.set,id.temp$id.subset)[1]
		}

		dat2$power.prune<-"drop"
		dat2$power.prune[paste(dat2$id.set,dat2$id.subset) %in% id.keep]<-"keep"
		# if(drop.duplicates == T) {
			dat2<-dat2[dat2$power.prune=="keep",]
		# }
		dat2<-dat2[,!names(dat2) %in% c("iv.se","power.prune","id.set","id.subset")]
		dat<-dat2
		# dat2[,c("exposure","outcome","iv.se","power","id.set","id.subset","power.prune")]

		# unique(dat2[order(dat2$id.set,dat2$id.subset),c("samplesize.exposure","ncase.outcome","exposure","outcome","iv.se","power","id.set","id.subset")])

		# dat2[dat2$id.set==1,c("iv.se","id.set","id.subset")]

		return(dat)

	}
}

#' Size prune
#'
#' Whens there are duplicate summary sets for a particular exposure-outcome combination,
#' this function drops the duplicates with the smaller total sample size
#' (for binary outcomes, the number of cases is used instead of total sample size).
#'
#' @param dat Results from [harmonise_data()].
#'
#' @export
#' @return data frame

size.prune <- function(dat)
{
	dat$ncase[is.na(dat$ncase)]<-dat$samplesize[is.na(dat$ncase)]
	dat<-dat[order(dat$ncase,decreasing=TRUE),]
	id.expout<-paste(dat$exposure,dat$outcome)
	id.keep<-id.expout[!duplicated(paste(dat$exposure,dat$originalname.outcome))]
	dat<-dat[id.expout %in% id.keep,]
}
