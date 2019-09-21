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
drop if year>death_year+10;

label var after_death "After Death";

gen byte antcpt=cod==1;
gen byte sudden=cod==2;
gen byte allcod=cod<=3;

gen byte allpubs=srce_pmid!=.;
gen byte own_btm = yrltv_btm10pct==1;
gen byte own_mid = yrltv_mdl25_75pct==1;
gen byte own_top = yrltv_top10pct==1;
gen byte unv_top = nrltv_top1pct==1;
gen byte wndw3=death_year-srce_pubyear<=3; 

fvset base 1975 yr;

foreach srcetype in own_btm own_mid own_top unv_top {;

xtqmlp nb_cites after_death after_death_cmn i.yr i.artcl_age if allcod==1 & `srcetype'==1, fe cluster(setnb);
distinct setnb if e(sample);
estadd scalar nbinv=r(ndistinct);
distinct id if e(sample);
estadd scalar nbsource=r(ndistinct);
estimates save "${F10}estimates/table4/poisson_maineffects_allcod_`srcetype'.ster", replace;

};

xtqmlp nb_cites after_death after_death_cmn i.yr i.artcl_age if allcod==1 & wndw3==1, fe cluster(setnb);
distinct setnb if e(sample);
estadd scalar nbinv=r(ndistinct);
distinct id if e(sample);
estadd scalar nbsource=r(ndistinct);
estimates save "${F10}estimates/table4/poisson_maineffects_allcod_wndw3.ster", replace;

estimates drop _all;
estimates use "${F10}estimates/table3/poisson_maineffects_allages_allcod_allpubs.ster";
eststo;
estimates use "${F10}estimates/table4/poisson_maineffects_allcod_own_btm.ster";
eststo;
estimates use "${F10}estimates/table4/poisson_maineffects_allcod_own_mid.ster";
eststo;
estimates use "${F10}estimates/table4/poisson_maineffects_allcod_own_top.ster";
eststo;
estimates use "${F10}estimates/table4/poisson_maineffects_allcod_unv_top.ster";
eststo;
estimates use "${F10}estimates/table4/poisson_maineffects_allcod_wndw3.ster";
eststo;

esttab *, keep(after_death) varwidth(25) nonumber noobs nogaps nodep label b(%5.3f) se(%5.3f) star(† 0.10 * 0.05 ** 0.01) compress scalars("nbinv Nb. of Investigators" "N_g Nb. of Source Articles" "N Nb. of Source Artcl.-Year Obs." "ll Log Likelihood") sfmt(%10.0fc %10.0fc %10.0fc %12.0fc) mlabels("All Publications" "Own Bottom 10pct" "Own 25pct-75pct" "Own Top 10pct" "Universe Top 1pct" "3 Years Before Death") eqlabels(none);
esttab * using "${F10}tables/table_4.rtf", keep(after_death) varwidth(25) nonumber noobs nogaps nodep label b(%5.3f) se(%5.3f) star(† 0.10 * 0.05 ** 0.01) compress scalars("nbinv Nb. of Investigators" "N_g Nb. of Source Articles" "N Nb. of Source Artcl.-Year Obs." "ll Log Likelihood") sfmt(%10.0fc %10.0fc %10.0fc %12.0fc) mlabels("All Publications" "Own Bottom 10pct" "Own 25pct-75pct" "Own Top 10pct" "Universe Top 1pct" "3 Years Before Death")  eqlabels(none) replace;
