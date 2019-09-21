#delimit;
clear all;
version 16.0;
pause on;
program drop _all;
capture log close;
set more off;

cd /;
cd "${F10}data";

use afterlife_mediation_analysis.dta, clear;

gegen setno=group(setnb);

foreach boost in all ncmmrlzr5 {;
gen log_xpctd_lasso_`boost'_cites = ln(xpctd_lasso_`boost'_ntrt_cites);
gen log_inxss_lasso_`boost'_cites = cond(inxss_lasso_`boost'_ntrt_cites <= 0, -ln(-inxss_lasso_`boost'_ntrt_cites), ln(inxss_lasso_`boost'_ntrt_cites));
};

drop inxss_* xpctd_*;

generate byte MemBins1 = (acd_mem_vdplus> 2);
generate byte MemBins2 = (acd_mem_vdplus==2);
generate byte MemBins3 = (acd_mem_vdplus==1);

label var treat "Deceased";
label var female "Female";
label var sudden_death "Death is Sudden";
label var MemBins3 "Scientists w/ 1 Celebrations";
label var MemBins2 "Scientists w/ 2 Celebrations";
label var MemBins1 "Scientists w/ 3+ Celebrations";

foreach boost in all ncmmrlzr5 {;

reghdfe log_inxss_lasso_`boost'_cites treat female sudden_death nknwn_death i.deg_year i.death_year i.deg, absorb(srce_pubyear) cluster(pmid setno);
estadd scalar adjr2=e(r2_a);
distinct setno if e(sample);
estadd scalar nbinv=r(ndistinct);
distinct pmid if e(sample);
estadd scalar nbsource=r(ndistinct);
estadd ysumm;
estadd scalar meandv=e(ymean);
estimates save "${F10}estimates/table8/inxss_lasso_`boost'_cites_acd_mem_mdtn_a.ster", replace;

reghdfe log_inxss_lasso_`boost'_cites MemBins3 MemBins2 MemBins1 female sudden_death nknwn_death i.deg_year i.death_year i.deg, absorb(srce_pubyear) cluster(pmid setno);
estadd scalar adjr2=e(r2_a);
distinct setno if e(sample);
estadd scalar nbinv=r(ndistinct);
distinct pmid if e(sample);
estadd scalar nbsource=r(ndistinct);
estadd ysumm;
estadd scalar meandv=e(ymean);
estimates save "${F10}estimates/table8/inxss_lasso_`boost'_cites_acd_mem_mdtn_b.ster", replace;

reghdfe log_inxss_lasso_`boost'_cites treat MemBins3 MemBins2 MemBins1 female sudden_death nknwn_death i.deg_year i.death_year i.deg, absorb(srce_pubyear) cluster(pmid setno);
estadd scalar adjr2=e(r2_a);
distinct setno if e(sample);
estadd scalar nbinv=r(ndistinct);
distinct pmid if e(sample);
estadd scalar nbsource=r(ndistinct);
estadd ysumm;
estadd scalar meandv=e(ymean);
estimates save "${F10}estimates/table8/inxss_lasso_`boost'_cites_acd_mem_mdtn_c.ster", replace;

};


estimates drop _all;   
estimates use "${F10}estimates/table8/inxss_lasso_all_cites_acd_mem_mdtn_a.ster";
eststo;
estimates use "${F10}estimates/table8/inxss_lasso_all_cites_acd_mem_mdtn_b.ster";
eststo;
estimates use "${F10}estimates/table8/inxss_lasso_all_cites_acd_mem_mdtn_c.ster";
eststo;
estimates use "${F10}estimates/table8/inxss_lasso_ncmmrlzr5_cites_acd_mem_mdtn_a";
eststo;
estimates use "${F10}estimates/table8/inxss_lasso_ncmmrlzr5_cites_acd_mem_mdtn_b";
eststo;
estimates use "${F10}estimates/table8/inxss_lasso_ncmmrlzr5_cites_acd_mem_mdtn_c";
eststo;

esttab *, keep(treat MemBins3 MemBins2 MemBins1) varwidth(25) nonumber noobs nogaps nodep constant label b(%5.3f) se(%5.3f) star(† 0.10 * 0.05 ** 0.01) compress scalars("meandv Mean of Depndnt. Variable" "N Nb. of Source Articles" "nbinv Nb. of Investigators" "adjr2 Adjusted R2") sfmt(%9.3f %10.0fc %10.0fc %9.3f) mlabels("(1a)" "(1b)" "(1c)" "(2a)" "(2b)" "(2c)") mgroups("All citations" "Excl. coauthors, memorializers, & 5 years post-death", pattern(1 0 0 1 0 0)) eqlabels(none);
esttab * using "${F10}tables/table_8.rtf", keep(treat MemBins3 MemBins2 MemBins1) varwidth(25) nonumber noobs nogaps nodep constant label b(%5.3f) se(%5.3f) star(† 0.10 * 0.05 ** 0.01) compress scalars("meandv Mean of Depndnt. Variable" "N Nb. of Source Articles" "nbinv Nb. of Investigators" "adjr2 Adjusted R2") sfmt(%9.3f %10.0fc %10.0fc %9.3f) mlabels("(1a)" "(1b)" "(1c)" "(2a)" "(2b)" "(2c)") mgroups("All citations" "Excl. coauthors, memorializers, & 5 years post-death", pattern(1 0 0 1 0 0)) eqlabels(none) replace;