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
fvset base 1975 yr;

foreach srcetype in allpubs {; 
foreach csofdeath in allcod sudden antcpt {;
/**/
xtqmlp nb_cites after_death after_death_cmn i.yr i.artcl_age if `csofdeath'==1 & `srcetype'==1, fe cluster(setnb);
distinct setnb if e(sample);
estadd scalar nbinv=r(ndistinct);
distinct id if e(sample);
estadd scalar nbsource=r(ndistinct);
estimates save "${F10}estimates/table3/poisson_maineffects_allages_`csofdeath'_`srcetype'.ster", replace;

xtqmlp nb_cites after_death after_death_cmn i.yr i.artcl_age if `csofdeath'==1 & `srcetype'==1 & aad<=65, fe cluster(setnb);
distinct setnb if e(sample);
estadd scalar nbinv=r(ndistinct);
distinct id if e(sample);
estadd scalar nbsource=r(ndistinct);
estimates save "${F10}estimates/table3/poisson_maineffects_blw65_`csofdeath'_`srcetype'.ster", replace;

xtqmlp nb_cites after_death after_death_cmn i.yr i.artcl_age if `csofdeath'==1 & `srcetype'==1 & aad>65, fe cluster(setnb);
distinct setnb if e(sample);
estadd scalar nbinv=r(ndistinct);
distinct id if e(sample);
estadd scalar nbsource=r(ndistinct);
estimates save "${F10}estimates/table3/poisson_maineffects_abv65_`csofdeath'_`srcetype'.ster", replace;

};
};

foreach srcetype in allpubs {;

estimates drop _all;
estimates use "${F10}estimates/table3/poisson_maineffects_allages_allcod_`srcetype'.ster";
eststo;
estimates use "${F10}estimates/table3/poisson_maineffects_blw65_allcod_`srcetype'.ster";
eststo;
estimates use "${F10}estimates/table3/poisson_maineffects_abv65_allcod_`srcetype'.ster";
eststo;
estimates use "${F10}estimates/table3/poisson_maineffects_blw65_sudden_`srcetype'.ster";
eststo;
estimates use "${F10}estimates/table3/poisson_maineffects_abv65_sudden_`srcetype'.ster";
eststo;
estimates use "${F10}estimates/table3/poisson_maineffects_blw65_antcpt_`srcetype'.ster";
eststo;
estimates use "${F10}estimates/table3/poisson_maineffects_abv65_antcpt_`srcetype'.ster";
eststo;

	
esttab *, keep(after_death) varwidth(25) nonumber noobs nogaps nodep label b(%5.3f) se(%5.3f) star(† 0.10 * 0.05 ** 0.01) compress scalars("nbinv Nb. of Investigators" "N_g Nb. of Source Articles" "N Nb. of Source Artcl.-Year Obs." "ll Log Likelihood") sfmt(%10.0fc %10.0fc %10.0fc %12.0fc) mlabels("All Ages" "Younger than 65 at Time of Death" "Older than 65 at Time of Death" "Younger than 65 at Time of Death" "Older than 65 at Time of Death" "Younger than 65 at Time of Death" "Older than 65 at Time of Death") mgroups("All Causes of Death" "Sudden Death" "Anticipated Death", pattern(1 0 0 1 0 1 0)) eqlabels(none);
esttab * using "${F10}tables/table_3.rtf", keep(after_death) varwidth(25) nonumber noobs nogaps nodep label b(%5.3f) se(%5.3f) star(† 0.10 * 0.05 ** 0.01) compress scalars("nbinv Nb. of Investigators" "N_g Nb. of Source Articles" "N Nb. of Source Artcl.-Year Obs." "ll Log Likelihood") sfmt(%10.0fc %10.0fc %10.0fc %12.0fc) mlabels("All Ages" "Younger than 65 at Time of Death" "Older than 65 at Time of Death" "Younger than 65 at Time of Death" "Older than 65 at Time of Death" "Younger than 65 at Time of Death" "Older than 65 at Time of Death") mgroups("All Causes of Death" "Sudden Death" "Anticipated Death", pattern(1 0 0 1 0 1 0)) eqlabels(none) replace;

};