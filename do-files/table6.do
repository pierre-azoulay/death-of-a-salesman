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

keep id xid srce_pmid year srce_pubyear treat death_year setnb cod after_death after_death_cmn nb_cites_y* nb_cites_n* artcl_age yr;

label var after_death "After Death";

fvset base 1975 yr;

foreach split in coauthor field coloc {;

egen total_cites_y`split'=sum(nb_cites_y`split'), by(id);
egen total_cites_n`split'=sum(nb_cites_n`split'), by(id);

xtqmlp nb_cites_y`split' after_death after_death_cmn i.yr i.artcl_age if total_cites_n`split'>0 & total_cites_y`split'>0, fe cluster(setnb);
distinct setnb if e(sample);
estadd scalar nbinv=r(ndistinct);
distinct id if e(sample);
estadd scalar nbsource=r(ndistinct);
estimates save "${F10}estimates/table6/poisson_y`split'_allages_allcod_allpubs.ster", replace;

xtqmlp nb_cites_n`split' after_death after_death_cmn i.yr i.artcl_age if total_cites_n`split'>0 & total_cites_y`split'>0, fe cluster(setnb);
distinct setnb if e(sample);
estadd scalar nbinv=r(ndistinct);
distinct id if e(sample);
estadd scalar nbsource=r(ndistinct);
estimates save "${F10}estimates/table6/poisson_n`split'_allages_allcod_allpubs.ster", replace;

drop total_cites_n`split' total_cites_y`split';

};

estimates drop _all;

estimates use "${F10}estimates/table6/poisson_ncoauthor_allages_allcod_allpubs.ster";
eststo;
estimates use "${F10}estimates/table6/poisson_ycoauthor_allages_allcod_allpubs.ster";
eststo;
estimates use "${F10}estimates/table6/poisson_nfield_allages_allcod_allpubs.ster";
eststo;
estimates use "${F10}estimates/table6/poisson_yfield_allages_allcod_allpubs.ster";
eststo;
estimates use "${F10}estimates/table6/poisson_ncoloc_allages_allcod_allpubs.ster";
eststo;
estimates use "${F10}estimates/table6/poisson_ycoloc_allages_allcod_allpubs.ster";
eststo;

esttab *, keep(after_death) varwidth(25) nonumber noobs nogaps nodep label b(%5.3f) se(%5.3f) star(† 0.10 * 0.05 ** 0.01) compress scalars("nbinv Nb. of Investigators" "N_g Nb. of Source Articles" "N Nb. of Source Artcl.-Year Obs." "ll Log Likelihood") sfmt(%10.0fc %10.0fc %10.0fc %12.0fc) mlabels("Non-Collab. Cites" "Collab. Cites" "Out-of-Field Cites" "In-Field Cites" "Distant Cites" "Local Cites") mgroups("Social Space" "Intellectual Space" "Geographic Space", pattern(1 0 1 0 1 0)) eqlabels(none);
esttab * using "${F10}tables/table_6.rtf", keep(after_death) varwidth(25) nonumber noobs nogaps nodep label b(%5.3f) se(%5.3f) star(† 0.10 * 0.05 ** 0.01) compress scalars("nbinv Nb. of Investigators" "N_g Nb. of Source Articles" "N Nb. of Source Artcl.-Year Obs." "ll Log Likelihood") sfmt(%10.0fc %10.0fc %10.0fc %12.0fc) mlabels("Non-Collab. Cites" "Collab. Cites" "Out-of-Field Cites" "In-Field Cites" "Distant Cites" "Local Cites") mgroups("Social Space" "Intellectual Space" "Geographic Space", pattern(1 0 1 0 1 0)) eqlabels(none) replace;
