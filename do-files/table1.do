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
keep if treat==1;
bysort setnb: keep if _n==_N;

keeporder setnb death_year cod star_yob aad deg deg_year female stk_inv_pubs stk_inv_cites stk_inv_nih nas stk_trainees stk_nwghtd_collabs frac1_slf_yprmt_setnb;
rename stk_nwghtd_collabs stk_coauthors;
recode stk_coauthors .=0;
recode stk_trainees .=0;

merge 1:1 setnb using "${F10}data/afterlife_dead_stars_memories.dta", keep(match master) keepusing(itrmrl_nih total_mem academic_mem nyt_obit wikipedia_page named_award festschrift xpctd_lasso_all_ntrt_cites inxss_lasso_all_ntrt_cites);
tab _merge;
assert _merge==3;
drop _merge;
replace festschrift=1 if festschrift>1 & festschrift!=.;

tab itrmrl_nih;
replace stk_inv_nih=. if itrmrl_nih==1;

recode deg 6=2;
recode deg 4=1;
gen byte MD=deg==1;
gen byte PhD=deg==2;
gen byte MDPhD=deg==3;
gen byte antcpt=cod==1;
gen byte sudden=cod==2;
gen byte nknown=cod==3;

label variable star_yob "Year of Birth";
label variable death_year "Death Year";
label variable deg_year "Degree year";
label variable aad "Age at Death";
label variable female "Female";
label variable antcpt "Death was Anticipated";
label variable sudden "Death was Sudden";
label variable nknown "Unknown Cause of Death";
label variable MD "MD Degree";
label variable PhD "PhD Degree";
label variable MDPhD "MD/PhD Degree";
label variable nas "Member of the NAS";
label variable stk_inv_pubs "Cuml. Nb. of Publications";
label variable stk_inv_cites "Cuml. Nb. of Citations";
label variable stk_inv_nih "Cuml. Amount of NIH Funding";
label variable stk_trainees "Cuml. Nb. of Trainees at Death";
label variable stk_coauthors "Cuml. Nb. of Coauthors at Death";
label variable xpctd_lasso_all_ntrt_cites  "Cuml. Nb. of Predicted Citations";
label variable inxss_lasso_all_ntrt_cites  "Cuml. Nb. of Excess Citations";
label variable total_mem "Total Nb. Memory Events";
label variable academic_mem "Total Nb. Academic Memory Events";
label variable nyt_obit "New York Times Obituary";
label variable wikipedia_page "Wikipedia Page"; 
label variable named_award "Named Award";
label variable festschrift "Festschrift";

quietly estpost summarize star_yob deg_year death_year aad female MD PhD MDPhD sudden antcpt nknown stk_inv_pubs stk_inv_cites stk_inv_nih stk_trainees stk_coauthors xpctd_lasso_all_ntrt_cites inxss_lasso_all_ntrt_cites total_mem academic_mem nyt_obit wikipedia_page named_award festschrift, d;
esttab, cells("count(label(N) fmt(%3.0f)) mean(label(Mean) fmt(%10.3f)) p50(label(Median) fmt(%10.0f)) sd(label(Std. Dev.) fmt(%10.3fc)) min(label(Min.) fmt(%10.0f)) max(label(Max.) fmt(%10.0f))") noobs nomtitle nonumber label;
esttab using "${F10}/tables/table_1.rtf", cells("count(label(N) fmt(%3.0f)) mean(label(Mean) fmt(%10.3f)) p50(label(Median) fmt(%10.0f)) sd(label(Std. Dev.) fmt(%10.3fc)) min(label(Min.) fmt(%10.0f)) max(label(Max.) fmt(%10.0f))") noobs nomtitle nonumber replace label;

quietly estpost summarize stk_inv_pubs stk_inv_cites stk_inv_nih stk_trainees stk_coauthors xpctd_lasso_all_ntrt_cites inxss_lasso_all_ntrt_cites, d;
esttab, cells("count(label(N) fmt(%3.0f)) mean(label(Mean) fmt(%10.0fc)) p50(label(Median) fmt(%10.0fc)) sd(label(Std. Dev.) fmt(%10.0fc)) min(label(Min.) fmt(%10.0fc)) max(label(Max.) fmt(%12.0fc))") noobs nomtitle nonumber label;
esttab using "${F10}tables/table_1.rtf", cells("count(label(N) fmt(%3.0f)) mean(label(Mean) fmt(%10.0fc)) p50(label(Median) fmt(%10.0fc)) sd(label(Std. Dev.) fmt(%12.0fc)) min(label(Min.) fmt(%10.0fc)) max(label(Max.) fmt(%12.0fc))") noobs nomtitle nonumber append label;