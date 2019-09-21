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

keep id xid srce_pmid year srce_pubyear treat death_year setnb cod after_death after_death_cmn nb_cites index_pubs index_cites index_amount artcl_age yr;
drop if year>death_year+10;

label var after_death "After Death";

gen byte antcpt=cod==1;
gen byte sudden=cod==2;
gen byte allcod=cod<=3;

gen byte allpubs=srce_pmid!=.;

fvset base 1975 yr;

xtqmlp nb_cites after_death after_death_cmn i.yr i.artcl_age if allcod==1 & allpubs==1 & index_pubs<=10, fe cluster(setnb);
distinct setnb if e(sample);
estadd scalar nbinv=r(ndistinct);
distinct id if e(sample);
estadd scalar nbsource=r(ndistinct);
estimates save "${F10}estimates/table9/poisson_maineffects_lopubs_allcod_allpubs.ster", replace;

xtqmlp nb_cites after_death after_death_cmn i.yr i.artcl_age if allcod==1 & allpubs==1 & index_pubs>10, fe cluster(setnb);
distinct setnb if e(sample);
estadd scalar nbinv=r(ndistinct);
distinct id if e(sample);
estadd scalar nbsource=r(ndistinct);
estimates save "${F10}estimates/table9/poisson_maineffects_hipubs_allcod_allpubs.ster", replace;

xtqmlp nb_cites after_death after_death_cmn i.yr i.artcl_age if allcod==1 & allpubs==1 & index_cites<=10, fe cluster(setnb);
distinct setnb if e(sample);
estadd scalar nbinv=r(ndistinct);
distinct id if e(sample);
estadd scalar nbsource=r(ndistinct);
estimates save "${F10}estimates/table9/poisson_maineffects_locites_allcod_allpubs.ster", replace;

xtqmlp nb_cites after_death after_death_cmn i.yr i.artcl_age if allcod==1 & allpubs==1 & index_cites>10, fe cluster(setnb);
distinct setnb if e(sample);
estadd scalar nbinv=r(ndistinct);
distinct id if e(sample);
estadd scalar nbsource=r(ndistinct);
estimates save "${F10}estimates/table9/poisson_maineffects_hicites_allcod_allpubs.ster", replace;

xtqmlp nb_cites after_death after_death_cmn i.yr i.artcl_age if allcod==1 & allpubs==1 & index_amount<=10 & substr(setnb,1,1)!="N", fe cluster(setnb);
distinct setnb if e(sample);
estadd scalar nbinv=r(ndistinct);
distinct id if e(sample);
estadd scalar nbsource=r(ndistinct);
estimates save "${F10}estimates/table9/poisson_maineffects_lofunded_allcod_allpubs.ster", replace;

xtqmlp nb_cites after_death after_death_cmn i.yr i.artcl_age if allcod==1 & allpubs==1 & index_amount>10 & substr(setnb,1,1)!="N", fe cluster(setnb);
distinct setnb if e(sample);
estadd scalar nbinv=r(ndistinct);
distinct id if e(sample);
estadd scalar nbsource=r(ndistinct);
estimates save "${F10}estimates/table9/poisson_maineffects_hifunded_allcod_allpubs.ster", replace;

estimates drop _all;
estimates use "${F10}estimates/table9/poisson_maineffects_lopubs_allcod_allpubs.ster";
eststo;
estimates use "${F10}estimates/table9/poisson_maineffects_hipubs_allcod_allpubs.ster";
eststo;
estimates use "${F10}estimates/table9/poisson_maineffects_locites_allcod_allpubs.ster";
eststo;
estimates use "${F10}estimates/table9/poisson_maineffects_hicites_allcod_allpubs.ster";
eststo;
estimates use "${F10}estimates/table9/poisson_maineffects_lofunded_allcod_allpubs.ster";
eststo;
estimates use "${F10}estimates/table9/poisson_maineffects_hifunded_allcod_allpubs.ster";
eststo;

esttab *, keep(after_death) varwidth(25) nonumber noobs nogaps nodep label b(%5.3f) se(%5.3f) star(† 0.10 * 0.05 ** 0.01) compress scalars("nbinv Nb. of Investigators" "N_g Nb. of Source Articles" "N Nb. of Source Artcl.-Year Obs." "ll Log Likelihood") sfmt(%10.0fc %10.0fc %10.0fc %12.0fc) mlabels("Below Median" "Above Median" "Below Median" "Above Median" "Below Median" "Above Median") mgroups("Publications" "Citations" "Funding", pattern(1 0 1 0 1 0)) eqlabels(none);
esttab * using "${F10}tables/table_9.rtf", keep(after_death) varwidth(25) nonumber noobs nogaps nodep label b(%5.3f) se(%5.3f) star(† 0.10 * 0.05 ** 0.01) compress scalars("nbinv Nb. of Investigators" "N_g Nb. of Source Articles" "N Nb. of Source Artcl.-Year Obs." "ll Log Likelihood") sfmt(%10.0fc %10.0fc %10.0fc %12.0fc) mlabels("Below Median" "Above Median" "Below Median" "Above Median" "Below Median" "Above Median") mgroups("Publications" "Citations" "Funding", pattern(1 0 1 0 1 0)) eqlabels(none) replace;