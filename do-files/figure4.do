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

keeporder id xid srce_pmid setnb year srce_pubyear death_year artcl_age nb_cites treat year yr cod aad;

gen byte antcpt=cod==1;
gen byte sudden=cod==2;
gen byte allcod=cod<=3;
gen byte allpubs=srce_pmid!=.;
gen byte allages=aad<100;
gen byte blw65=aad<=65;
gen byte abv65=aad>65;

gen yr_to_death2=year-death_year;
replace yr_to_death2=-6 if yr_to_death2<-6;

gen yr_to_death=6+yr_to_death2;
drop yr_to_death2;

gen yr_to_death_x_treat=yr_to_death*treat;
fvset base 1975 yr;
fvset base 6 yr_to_death;
fvset base 6 yr_to_death_x_treat;

label define lvls 0 "<-5" 1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "-1" 6 "0" 7 "+1" 8 "+2" 9 "+3" 10 "+4" 11 "+5" 12 "+6" 13 "+7" 14 "+8" 15 "+9" 16 "+10", modify;
label val yr_to_death_x_treat lvls;

foreach csofdeath in allcod sudden antcpt {;
foreach srcetype in allpubs {;
foreach ageatdeath in allages blw65 abv65 {;

xtqmlp nb_cites i.yr_to_death i.yr_to_death_x_treat i.artcl_age i.yr if `csofdeath'==1 & `srcetype'==1 & `ageatdeath'==1, fe cluster(setnb);
estimates save "${F10}estimates/figure4/poisson_afterlife_dynamics_`ageatdeath'_`csofdeath'_`srcetype'.ster", replace;

estimates drop _all;
estimates use "${F10}estimates/figure4/poisson_afterlife_dynamics_`ageatdeath'_`csofdeath'_`srcetype'.ster";
eststo;

coefplot (*, msymbol(O) mcolor(gs3) ciopts(recast(rbar) color(gs11) fintensity(100) barwidth(0.30))), keep(*.yr_to_death_x_treat) drop(0.yr_to_death_x_treat) vertical omitted baselevels legend(off) msize(vsmall) xlabel(, valuelabels labsize(small) tlength(.75) format(%15.0f)) ylabel(-0.25(0.05)0.25, labsize(small) tlength(.75) angle(horizontal) format(%15.2f) grid glwidth(vvthin) glcolor(gs1)) xtitle(" " "Time to/After Death", size(small)) ytitle("", size(small)) xline(6, lcolor(gs10) lpattern(-)) yline(0, lcolor(black) lwidth(vthin)) graphregion(color(white)) nooffsets ciopts(recast(rbar) color(gs11) fintensity(100) barwidth(0.30)) saving("${F10}figures/gph/poisson_afterlife_dynamics_`ageatdeath'_`csofdeath'_`srcetype'.gph", replace);
graph export "${F10}figures/tif/poisson_afterlife_dynamics_`ageatdeath'_`csofdeath'_`srcetype'.tif", as(tif) width(2100) replace;
graph export "${F10}figures/png/poisson_afterlife_dynamics_`ageatdeath'_`csofdeath'_`srcetype'.png", as(png) width(2100) replace;
graph close;

};
};
};

cd "${F10}figures/gph/";
shell rename poisson_afterlife_dynamics_allages_allcod_allpubs.gph figure_4a.gph;
shell rename poisson_afterlife_dynamics_blw65_allcod_allpubs.gph figure_4b.gph;
shell rename poisson_afterlife_dynamics_abv65_allcod_allpubs.gph figure_4c.gph;
shell rename poisson_afterlife_dynamics_allages_sudden_allpubs.gph figure_4d.gph;
shell rename poisson_afterlife_dynamics_allages_antcpt_allpubs.gph figure_4e.gph;
capture erase poisson_afterlife_dynamics_abv65_antcpt_allpubs.gph;
capture erase poisson_afterlife_dynamics_abv65_sudden_allpubs.gph;
capture erase poisson_afterlife_dynamics_blw65_antcpt_allpubs.gph;
capture erase poisson_afterlife_dynamics_blw65_sudden_allpubs.gph;

cd "${F10}figures/tif/";
shell rename poisson_afterlife_dynamics_allages_allcod_allpubs.tif figure_4a.tif;
shell rename poisson_afterlife_dynamics_blw65_allcod_allpubs.tif figure_4b.tif;
shell rename poisson_afterlife_dynamics_abv65_allcod_allpubs.tif figure_4c.tif;
shell rename poisson_afterlife_dynamics_allages_sudden_allpubs.tif figure_4d.tif;
shell rename poisson_afterlife_dynamics_allages_antcpt_allpubs.tif figure_4e.tif;
capture erase poisson_afterlife_dynamics_abv65_antcpt_allpubs.tif;
capture erase poisson_afterlife_dynamics_abv65_sudden_allpubs.tif;
capture erase poisson_afterlife_dynamics_blw65_antcpt_allpubs.tif;
capture erase poisson_afterlife_dynamics_blw65_sudden_allpubs.tif;

cd "${F10}figures/png/";
shell rename poisson_afterlife_dynamics_allages_allcod_allpubs.png figure_4a.png;
shell rename poisson_afterlife_dynamics_blw65_allcod_allpubs.png figure_4b.png;
shell rename poisson_afterlife_dynamics_abv65_allcod_allpubs.png figure_4c.png;
shell rename poisson_afterlife_dynamics_allages_sudden_allpubs.png figure_4d.png;
shell rename poisson_afterlife_dynamics_allages_antcpt_allpubs.png figure_4e.png;
capture erase poisson_afterlife_dynamics_abv65_antcpt_allpubs.png;
capture erase poisson_afterlife_dynamics_abv65_sudden_allpubs.png;
capture erase poisson_afterlife_dynamics_blw65_antcpt_allpubs.png;
capture erase poisson_afterlife_dynamics_blw65_sudden_allpubs.png;
