#delimit;
clear all;
version 16.0;
pause on;
program drop _all;
capture log close;
set more off;

cd /;
cd "${F10}data";

use afterlife_dd_dataset.dta, clear;

drop stk_nwghtd_collabs frac* nas stk_trainees stk_inv_pats stk_inv_nih stk_inv_cites stk_inv_pubs;
rename srce_pmid pmid;
gen nb_cites_nwndw5=nb_cites;
replace nb_cites_nwndw5=0 if year-death_year==0 | year-death_year==1 | year-death_year==2 | year-death_year==3 | year-death_year==4;

assert nb_cites==nb_cites_nwndw5 if year<death_year;

gegen setno=group(setnb);

preserve;
keep setnb setno;
bysort setnb: keep if _n==_N;
save setnb_nmrc_xwalk.dta, replace;
restore;

replace after_death_cmn=1 if year==death_year;

gcollapse (sum) nb_cites nb_cites_ncmmrlzr nb_cites_nwndw5 nb_cites_ncmmrlzr5 (mean) pmid setno nbauthors journal_name deg_year deg female srce_pubyear death_year treat index_stk_trainees index_stk_collabs index_pubs index_cites index_amount index_slf_prmtr1_setnb, by(id after_death_cmn);
bysort id (after_death_cmn): gen nb_cites_bfr=nb_cites[1];
bysort id (after_death_cmn): gen nb_cites_nwndw5_bfr=nb_cites_nwndw5[1];
bysort id (after_death_cmn): gen nb_cites_ncmmrlzr_bfr=nb_cites_ncmmrlzr[1];
bysort id (after_death_cmn): gen nb_cites_ncmmrlzr5_bfr=nb_cites_ncmmrlzr5[1];

bysort id (after_death_cmn): keep if _n==_N;
drop after_death_cmn;

merge m:1 setno using setnb_nmrc_xwalk.dta;
assert _merge==3;
drop _merge;

gen deg_=deg;
replace deg_=4 if deg==0;
replace deg_=2 if deg==6;
drop deg;
rename deg_ deg;

rename nb_cites nb_cites_all;
rename nb_cites_bfr nb_cites_all_bfr;

/* all journals with less than 10 observations are lumped into a single residual journal. */
gegen nbpubs_per_journal=nunique(id), by(journal_name);
gegen min_journal_id=min(journal_name) if nbpubs_per_journal<10;
gegen min_jrnl_id=min(min_journal_id);
replace journal_name=min_jrnl_id if nbpubs_per_journal<10;
drop nbpubs_per_journal min_journal_id min_jrnl_id;

gen ln_nb_cites_all_bfr=ln(nb_cites_all_bfr);
gen ln_nb_cites_nwndw5_bfr=ln(nb_cites_nwndw5_bfr);
gen ln_nb_cites_ncmmrlzr_bfr=ln(nb_cites_ncmmrlzr_bfr);
gen ln_nb_cites_ncmmrlzr5_bfr=ln(nb_cites_ncmmrlzr5_bfr);

recode ln_nb_cites_all_bfr .=0;
recode ln_nb_cites_nwndw5_bfr .=0;
recode ln_nb_cites_ncmmrlzr_bfr .=0;
recode ln_nb_cites_ncmmrlzr5_bfr .=0;

gen byte zero_cites_all_bfr=nb_cites_all_bfr==0;
gen byte zero_cites_nwndw5_bfr=nb_cites_nwndw5_bfr==0;
gen byte zero_cites_ncmmrlzr_bfr=nb_cites_ncmmrlzr_bfr==0;
gen byte zero_cites_ncmmrlzr5_bfr=nb_cites_ncmmrlzr5_bfr==0;

capture erase setnb_nmrc_xwalk.dta;

vl set;
vl substitute prdct_cite = (female i.deg i.deg_year i.death_year i.srce_pubyear i.journal_name i.nbauthors i.index_stk_trainees i.index_stk_collabs i.index_amount i.index_slf_prmtr1_setnb);

splitsample, generate(smplvar) split(0.80 0.20) values(0 1) cluster(setno) rseed(2869);

label variable smplvar "smpl_type";
label define smpl_type	0 "Training" 1	"Testing";
label values smplvar smpl_type;

label var treat "Deceased";

foreach boost in all ncmmrlzr5 {;

lasso poisson nb_cites_`boost' zero_cites_`boost'_bfr ln_nb_cites_`boost'_bfr ${prdct_cite} if smplvar == 0, selection(plugin);
lassogof, over(smplvar);
estadd scalar dev_trn = r(table)[1,1];
estadd scalar dev_tst = r(table)[2,1];
estadd scalar devratio_trn = r(table)[1,2];
estadd scalar devratio_tst = r(table)[2,2];
distinct setno if e(sample);
estadd scalar nbinv_trn=r(ndistinct);
distinct setno if smplvar==1;
estadd scalar nbinv_tst=r(ndistinct);
sum nb_cites_`boost'_bfr if smplvar==1;
estadd scalar n_tst = r(N);
estimates save "${F10}estimates/estimates_lasso_nbcites_`boost'.ster", replace;
predict xpctd_lasso_`boost'_ntrt_cites, n;
gen inxss_lasso_`boost'_ntrt_cites=nb_cites_`boost'-xpctd_lasso_`boost'_ntrt_cites;

};


set emptycells drop;
estimates drop _all;   
estimates use "${F10}estimates/estimates_lasso_nbcites_all.ster";
eststo;
estimates use "${F10}estimates/estimates_lasso_nbcites_ncmmrlzr5.ster";
eststo;

esttab *, keep(_cons) varwidth(25) nonumber noobs nogaps nodep constant label b(%5.3f) compress scalars("N Nb. of Source Articles [training sample]" "n_tst Nb. of Source Articles [testing sample]" "nbinv_trn Nb. of Investigators [training sample]" "nbinv_tst Nb. of Investigators [testing sample]" "dev_trn deviance [training sample]" "dev_tst deviance [testing sample]" "devratio_trn deviance ratio [training sample]" "devratio_tst deviance ratio [testing sample]" "k_nonzero_sel Nb. of Non-0 Covars" "k_allvars Nb. of Potential Predictors Covars") sfmt(%10.0fc %10.0fc %10.0fc %10.0fc %9.3f %9.3f %9.3f %9.3f %10.0fc %10.0fc) mlabels("All citations" "Excl. 5 years post-death & mmrlzrs citations") nonotes eqlabels(none);
esttab * using "${F10}tables/predictions_lasso_diagnostics.rtf", keep(_cons) varwidth(25) nonumber noobs nogaps nodep constant label b(%5.3f) compress scalars("N Nb. of Source Articles [training sample]" "n_tst Nb. of Source Articles [testing sample]" "nbinv_trn Nb. of Investigators [training sample]" "nbinv_tst Nb. of Investigators [testing sample]" "dev_trn deviance [training sample]" "dev_tst deviance [testing sample]" "devratio_trn deviance ratio [training sample]" "devratio_tst deviance ratio [testing sample]" "k_nonzero_sel Nb. of Non-0 Covars" "k_allvars Nb. of Potential Predictors Covars") sfmt(%10.0fc %10.0fc %10.0fc %10.0fc %9.3f %9.3f %9.3f %9.3f %10.0fc %10.0fc) mlabels("All citations" "Excl. 5 years post-death & mmrlzrs citations") nonotes eqlabels(none) replace;

keeporder id pmid setnb death_year treat nb_cites_all xpctd_lasso_all_ntrt_cites inxss_lasso_all_ntrt_cites nb_cites_ncmmrlzr5 xpctd_lasso_ncmmrlzr5_ntrt_cites inxss_lasso_ncmmrlzr5_ntrt_cites;

compress;

save "${F10}data/afterlife_prdct_cites_pmid_level.dta", replace;
keep if treat==1;
keeporder setnb death_year nb_cites_* xpctd_* inxss_*;

collapse death_year (sum) nb_cites_* xpctd_* inxss_*, by(setnb);
sort setnb;

keeporder setnb death_year nb_cites_all xpctd_lasso_all_ntrt_cites inxss_lasso_all_ntrt_cites nb_cites_ncmmrlzr5 xpctd_lasso_ncmmrlzr5_ntrt_cites inxss_lasso_ncmmrlzr5_ntrt_cites;
compress;
save "${F10}data/afterlife_prdct_cites_invst_level.dta", replace;