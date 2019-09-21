#delimit;
clear all;
version 16.0;
pause on;
program drop _all;
capture log close;
set more off;

cd /;
cd "${F10}data";

foreach csofdeath in allcod sudden antcpt {;
foreach srcetype in allpubs {;
foreach ageatdeath in allages blw65 abv65 {;

use afterlife_dd_dataset.dta, clear;
drop if year>death_year+10;

gen byte antcpt=cod==1;
gen byte sudden=cod==2;
gen byte allcod=cod<=3;
gen byte allpubs=srce_pmid!=.;
gen byte allages=aad<100;
gen byte blw65=aad<=65;
gen byte abv65=aad>65;

fvset base 1975 yr;
gen yr_to_death=year-death_year;


forvalues i=5(-1)1 {;
	gen yrs_before_death_cmn`i'=0;
	replace yrs_before_death_cmn`i'=1 if yr_to_death==-`i';
};

forvalues i=1(1)10 {;
	gen yrs_after_death_cmn`i'=0;
	replace yrs_after_death_cmn`i'=1 if yr_to_death==`i';
};
gen yrs_after_death_cmn11=0;
replace yrs_after_death_cmn11=1 if yr_to_death>10;

gen yrs_before_death_cmn6=0;
replace yrs_before_death_cmn6=1 if yr_to_death<-5;


forvalues i=5(-1)1 {;
	gen yrs_before_death`i'=0;
	replace yrs_before_death`i'=1 if yr_to_death==-`i' & treat==1;
};

forvalues i=1(1)10 {;
	gen yrs_after_death`i'=0;
	replace yrs_after_death`i'=1 if yr_to_death==`i' & treat==1;
};
gen yrs_after_death11=0;
replace yrs_after_death11=1 if yr_to_death>10 & treat==1;

gen yrs_before_death6=0;
replace yrs_before_death6=1 if yr_to_death<-5 & treat==1;

drop yr_to_death;

keeporder id xid srce_pmid setnb year srce_pubyear death_year artcl_age nb_cites treat yrs_before_death_cmn6 yrs_before_death_cmn5-yrs_after_death_cmn11 yrs_before_death6 yrs_before_death5-yrs_after_death11 cod aad antcpt sudden allcod year yr allpubs allages blw65 abv65;

*xtqmlp nb_cites yrs_before_death_cmn6-yrs_before_death_cmn1 yrs_after_death_cmn1-yrs_after_death_cmn11 yrs_before_death6-yrs_before_death1 yrs_after_death1-yrs_after_death11 i.artcl_age i.yr if `csofdeath'==1 & `srcetype'==1 & `ageatdeath'==1, fe cluster(setnb);
*estimates save "${F10}estimates/figure4/poisson_afterlife_dynamics_`ageatdeath'_`csofdeath'_`srcetype'.ster", replace;

estimates drop _all;
estimates use  "${F10}estimates/figure4/poisson_afterlife_dynamics_`ageatdeath'_`csofdeath'_`srcetype'.ster";

matrix B=e(b);
matrix V=e(V);

keep if treat==1;
gen t_to_death=year-death_year;
bysort t_to_death: keep if _n==_N;

foreach y in 1 2 3 4 5 6 {;
	local t=colnumb(B,"yrs_before_death`y'");
	gen yrs_before_death`y'_coef = B[1,`t'];
	gen yrs_before_death`y'_var = V[`t',`t'];
};

foreach y in 1 2 3 4 5 6 7 8 9 10 {;
	local t=colnumb(B,"yrs_after_death`y'");
	gen yrs_after_death`y'_coef = B[1,`t'];
	gen yrs_after_death`y'_var = V[`t',`t'];
};

gen treatment_coefs=0;
gen treatment_vars=0;

foreach var in  yrs_before_death6 yrs_before_death5 yrs_before_death4 yrs_before_death3 yrs_before_death2 yrs_before_death1 
 		yrs_after_death1 yrs_after_death2 yrs_after_death3 yrs_after_death4 yrs_after_death5 
 		yrs_after_death6 yrs_after_death7 yrs_after_death8 yrs_after_death9 yrs_after_death10 
 		{;
		replace treatment_coefs=`var'_coef  if `var'==1;
		replace treatment_vars=`var'_var  if `var'==1;
		};

gen treatment_95lo=treatment_coefs-1.96*sqrt(treatment_vars);
gen treatment_95hi=treatment_coefs+1.96*sqrt(treatment_vars);

foreach y in 1 2 3 4 5 6 {;
	local t=colnumb(B,"yrs_before_death_cmn`y'");
	gen yrs_before_death_cmn`y'_coef = B[1,`t'];
	gen yrs_before_death_cmn`y'_var = V[`t',`t'];
};

foreach y in 1 2 3 4 5 6 7 8 9 10 {;
	local t=colnumb(B,"yrs_after_death_cmn`y'");
	gen yrs_after_death_cmn`y'_coef = B[1,`t'];
	gen yrs_after_death_cmn`y'_var = V[`t',`t'];
};

gen treatment_cmn_coefs=0;
gen treatment_cmn_vars=0;

foreach var in  yrs_before_death_cmn6 yrs_before_death_cmn5 yrs_before_death_cmn4 yrs_before_death_cmn3 yrs_before_death_cmn2 yrs_before_death_cmn1 
 		yrs_after_death_cmn1 yrs_after_death_cmn2 yrs_after_death_cmn3 yrs_after_death_cmn4 yrs_after_death_cmn5 
 		yrs_after_death_cmn6 yrs_after_death_cmn7 yrs_after_death_cmn8 yrs_after_death_cmn9 yrs_after_death_cmn10 
 		{;
		replace treatment_cmn_coefs=`var'_coef  if `var'==1;
		replace treatment_cmn_vars=`var'_var  if `var'==1;
		};

gen treatment_cmn_95lo=treatment_cmn_coefs-1.96*sqrt(treatment_vars);
gen treatment_cmn_95hi=treatment_cmn_coefs+1.96*sqrt(treatment_vars);

sort t_to_death;

local barcolor 166 206 227;
local mcolor 31 120 180;
local addedlines xline(0, lcolor(gs10) lpattern(-)) yline(0, lcolor(black) lwidth(thin));

twoway rbar treatment_95hi treatment_95lo t_to_death, /* color("`barcolor'") */ color(gs11) fintensity(100) barwidth(0.30) || scatter treatment_coefs t_to_death, /* mcolor("`mcolor'") */ mcolor(gs4) msymbol(o) msize(small)|| 
if t_to_death >= -5 & t_to_death <= 10, xtitle(" " "Time to/After Death") xlabel(-5(1)10, labsize(small)) ylabel(-0.25(0.05)0.25, format(%15.2f) angle(horizontal) labsize(small) grid glwidth(vvthin) glcolor(gs3)) `addedlines' graphregion(color(white)) plotregion(style(none)) legend(off) saving("${F10}figures/gph/poisson_afterlife_dynamics_`ageatdeath'_`csofdeath'_`srcetype'.gph", replace);
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
