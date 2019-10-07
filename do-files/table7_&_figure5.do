#delimit;
clear all;
version 16.0;
pause on;
program drop _all;
capture log close;
set more off;

cd /;
cd "${F10}data";

program drop _all;
program foo, eclass;
	tempname bmat;
	matrix `bmat' = e(b);
	forvalues k=1(1)7{;
	matrix `bmat'[1,`k'] = `bmat'[1,`k']+`bmat'[1,8];
	};
	ereturn repost b = `bmat';
end;

use afterlife_mediation_analysis.dta, clear;

replace deg=2 if deg==0;
replace deg_year=1929 if deg_year<1930;
replace deg_year=1983 if deg_year>1983;

drop acd_mem_vdplus;
rename acd_mem_vdwthn5 acd_mem_vdplus;

bysort setnb death_year: keep if _n==_N;
set seed 2358;
gen u=uniform();
egen maxu=max(u), by(setnb);
bysort setnb (maxu): keep if _n==_N;
drop u maxu;

keep setnb star_yob star_yod treat death_year cod deg deg_year female stk_inv_* nas nb_trainees nb_coauthors itrmrl_nih acd_mem_* ln_nb_trainees ln_nb_coauthors ln_nb_coauthors_nt zero_trainees zero_collabs zero_collabs_nt sudden_death antcpt_death log_cites log_pubs log_funding no_funding frac* index_slf_* top_prmtr*;
gen age_at_death=death_year-star_yob;
gen byte nknwn_death=cod==3;

byhist acd_mem_vdplus if acd_mem_ttl<=10, discrete by(treat) frac tw(xtitle(" " "Number of Memory/Recognition Events", size(small)) ytitle("Fraction of Articles") graphregion(color(white)) xlabel(0(1)10, labsize(vsmall) tlength(.75)) legend(label(1 "Control") label(2 "Treated") position(1) ring(0) cols(1) size(small) region(lstyle(none) lcolor(gs3) lwidth(vvthin))) ylabel(0(.10)1.00, labsize(vsmall) tlength(.75) angle(horizontal) format(%15.2f) grid glwidth(vvthin) glcolor(gs3))) tw1(color(gs3) lwidth(none)) tw2(color(gs13) lwidth(none) saving("${F10}figures/gph/figure_5a.gph", replace));
graph export "${F10}figures/tif/figure_5a.tif", as(tif) width(2100) replace;
graph export "${F10}figures/png/figure_5a.png", as(png) width(2100) replace;
graph close;

replace acd_mem_vdplus=1 if acd_mem_vdplus>1;

gen byte deg_dcd=0;
replace deg_dcd=1 if deg_year>=1940 & deg_year<1950;
replace deg_dcd=2 if deg_year>=1950 & deg_year<1960;
replace deg_dcd=3 if deg_year>=1960 & deg_year<1965;
replace deg_dcd=4 if deg_year>=1965 & deg_year<1970;
replace deg_dcd=5 if deg_year>=1970 & deg_year<1975;
replace deg_dcd=6 if deg_year>=1975 & deg_year<1980;
replace deg_dcd=7 if deg_year>=1980;

gen aad_45=age_at_death<=45;
gen aad_45_55=age_at_death>45 & age_at_death<=55;
gen aad_55_60=age_at_death>55 & age_at_death<=60;
gen aad_60_65=age_at_death>60 & age_at_death<=65;
gen aad_65_70=age_at_death>65 & age_at_death<=70;
gen aad_70_75=age_at_death>70 & age_at_death<=75;
gen aad_75_80=age_at_death>76 & age_at_death<=80;

label var aad_45 "<=45";
label var aad_45_55 "46-55";
label var aad_55_60 "56-60";
label var aad_60_65 "61-65";
label var aad_65_70 "66-70";
label var aad_70_75 "71-75";
label var aad_75_80 "76-80";

gen treat_aad_45=treat*(age_at_death<=45);
gen treat_aad_45_55=treat*(age_at_death>45 & age_at_death<=55);
gen treat_aad_55_60=treat*(age_at_death>55 & age_at_death<=60);
gen treat_aad_60_65=treat*(age_at_death>60 & age_at_death<=65);
gen treat_aad_65_70=treat*(age_at_death>65 & age_at_death<=70);
gen treat_aad_70_75=treat*(age_at_death>70 & age_at_death<=75);
gen treat_aad_75_80=treat*(age_at_death>76 & age_at_death<=80);

quietly: logit acd_mem_vdplus treat_aad_* treat aad_* log_cites log_pubs log_funding nas ln_nb_trainees zero_trainees ln_nb_coauthors_nt top_prmtr1_setnb female i.deg i.death_year nknwn_death sudden_death i.deg_dcd, robust cluster(setnb);
estpost margins, dydx(*) quietly;
foo;
estimates store dcsd_age_acd_mem_vdplus;

preserve;

rename treat_aad_45 	treat_aadx_45;
rename treat_aad_45_55 	treat_aadx_45_55;
rename treat_aad_55_60 	treat_aadx_55_60;
rename treat_aad_60_65 	treat_aadx_60_65;
rename treat_aad_65_70 	treat_aadx_65_70;
rename treat_aad_70_75 	treat_aadx_70_75;
rename treat_aad_75_80 	treat_aadx_75_80;

rename aad_45 treat_aad_45;
rename aad_45_55 treat_aad_45_55;
rename aad_55_60 treat_aad_55_60;
rename aad_60_65 treat_aad_60_65;
rename aad_65_70 treat_aad_65_70;
rename aad_70_75 treat_aad_70_75;
rename aad_75_80 treat_aad_75_80;

label var treat_aad_45 "<=45";
label var treat_aad_45_55 "46-55";
label var treat_aad_55_60 "56-60";
label var treat_aad_60_65 "61-65";
label var treat_aad_65_70 "66-70";
label var treat_aad_70_75 "71-75";
label var treat_aad_75_80 "76-80";

quietly: logit acd_mem_vdplus treat_aad_* treat_aadx_* treat log_cites log_pubs log_funding nas ln_nb_trainees zero_trainees ln_nb_coauthors_nt top_prmtr1_setnb female i.deg i.death_year nknwn_death sudden_death i.deg_dcd, robust cluster(setnb);
estpost margins, dydx(*) quietly;
estimates store stlving_age_acd_mem_vdplus;

coefplot (stlving_age_acd_mem_vdplus, label("Control") offset(-0.00) msymbol(D) msize(vsmall) mcolor(gs2) ciopts(lcolor(gs2) recast(rcap) msize(vsmall))) (dcsd_age_acd_mem_vdplus, label("Treated") offset(0.00) msymbol(O) msize(vsmall) mcolor(gs9) ciopts(lcolor(gs9) recast(rcap) msize(vsmall))), keep(treat_aad_*) vertical msize(vsmall) xlabel(, labsize(vsmall) tlength(.75) format(%15.0f)) ylabel(-0.50(0.10)0.50, labsize(vsmall) tlength(.75) angle(horizontal) format(%15.2f) grid glwidth(vvthin) glcolor(gs2)) xtitle(" " "Age at Death", size(small)) ytitle("Coefficient Estimates", size(small)) yline(0, lcolor(gs1) lpattern(-) lwidth(vthin)) graphregion(color(white)) legend(position(1) ring(0) cols(1) size(small) region(lwidth(vvthin))) ciopts(recast(rcap) msize(vsmall)) saving("${F10}figures/gph/figure_5b.gph", replace);
graph export "${F10}figures/tif/figure_5b.tif", as(tif) width(2100) replace;
graph export "${F10}figures/png/figure_5b.png", as(png) width(2100) replace;
graph close;
restore;

label var treat "Deceased";
label var female "Female";
label var sudden_death "Death is Sudden";
label var log_cites "Ln(cmltv. citations at death)";
label var log_pubs "Ln(cmltv. publications at death)";
label var log_funding "Ln(cmltv. funding at death)";
label var nas "Member of the NAS";
label var ln_nb_trainees "Ln(Nb. of past trainees)";
label var ln_nb_coauthors "Ln(Nb. of past coauthors [non-trainees])";
label var top_prmtr1_setnb "Self-Promoter";

local unrprtd_ctrls = "nknwn_death aad_* i.deg i.death_year";
/**/

logit acd_mem_vdplus treat log_cites log_pubs log_funding nas ln_nb_trainees ln_nb_coauthors zero_trainees top_prmtr1_setnb female sudden_death `unrprtd_ctrls', robust cluster(setnb);
estpost margins, dydx(*) quietly;
estimates save "${F10}estimates/table7/acd_mem_logit_clmn0_mdtn.ster", replace;
logit acd_mem_vdplus treat female sudden_death `unrprtd_ctrls', robust cluster(setnb);
estpost margins, dydx(*) quietly;
estimates save "${F10}estimates/table7/acd_mem_logit_clmn1_mdtn.ster", replace;
logit acd_mem_vdplus treat log_cites nas female sudden_death `unrprtd_ctrls', robust cluster(setnb);
estpost margins, dydx(*) quietly;
estimates save "${F10}estimates/table7/acd_mem_logit_clmn2_mdtn.ster", replace;
logit acd_mem_vdplus treat log_pubs nas female sudden_death `unrprtd_ctrls', robust cluster(setnb);
estpost margins, dydx(*) quietly;
estimates save "${F10}estimates/table7/acd_mem_logit_clmn3_mdtn.ster", replace;
logit acd_mem_vdplus treat log_funding nas female sudden_death `unrprtd_ctrls' itrmrl_nih no_funding, robust cluster(setnb);
estpost margins, dydx(*) quietly;
estimates save "${F10}estimates/table7/acd_mem_logit_clmn4_mdtn.ster", replace;
logit acd_mem_vdplus treat log_cites log_pubs log_funding nas female sudden_death `unrprtd_ctrls' itrmrl_nih no_funding, robust cluster(setnb);
estpost margins, dydx(*) quietly;
estimates save "${F10}estimates/table7/acd_mem_logit_clmn5_mdtn.ster", replace;
logit acd_mem_vdplus treat log_cites nas ln_nb_trainees zero_trainees female sudden_death `unrprtd_ctrls', robust cluster(setnb);
estpost margins, dydx(*) quietly;
estimates save "${F10}estimates/table7/acd_mem_logit_clmn6_mdtn.ster", replace;
logit acd_mem_vdplus treat log_cites nas ln_nb_coauthors_nt female sudden_death `unrprtd_ctrls', robust cluster(setnb);
estpost margins, dydx(*) quietly;
estimates save "${F10}estimates/table7/acd_mem_logit_clmn7_mdtn.ster", replace;
logit acd_mem_vdplus treat log_cites nas ln_nb_trainees ln_nb_coauthors_nt zero_trainees top_prmtr1_setnb female sudden_death `c', robust cluster(setnb);
estpost margins, dydx(*) quietly;
estimates save "${F10}estimates/table7/acd_mem_logit_clmn8_mdtn.ster", replace;

estimates drop _all;
estimates use "${F10}estimates/table7/acd_mem_logit_clmn0_mdtn.ster";
eststo;
estimates use "${F10}estimates/table7/acd_mem_logit_clmn1_mdtn.ster";
eststo;
estimates use "${F10}estimates/table7/acd_mem_logit_clmn2_mdtn.ster";
eststo;
estimates use "${F10}estimates/table7/acd_mem_logit_clmn3_mdtn.ster";
eststo;
estimates use "${F10}estimates/table7/acd_mem_logit_clmn4_mdtn.ster";
eststo;
estimates use "${F10}estimates/table7/acd_mem_logit_clmn5_mdtn.ster";
eststo;
estimates use "${F10}estimates/table7/acd_mem_logit_clmn6_mdtn.ster";
eststo;
estimates use "${F10}estimates/table7/acd_mem_logit_clmn7_mdtn.ster";
eststo;
estimates use "${F10}estimates/table7/acd_mem_logit_clmn8_mdtn.ster";
eststo;

esttab *, rename(ln_nb_coauthors_nt ln_nb_coauthors) order(treat log_cites log_pubs log_funding nas ln_nb_trainees ln_nb_coauthors top_prmtr1_setnb sudden_death female) keep(treat log_cites log_pubs log_funding nas ln_nb_trainees ln_nb_coauthors top_prmtr1_setnb female sudden_death) varwidth(25) nonumber noobs nogaps nodep label b(%5.3f) se(%5.3f) star(† 0.10 * 0.05 ** 0.01) compress scalars("N Nb. of Scientists" "r2_p Pseudo-R2") sfmt(%10.0fc %9.3f) mlabels("(0)" "(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)") eqlabels(none);
esttab * using "${F10}tables/table_7.rtf", rename(ln_nb_coauthors_nt ln_nb_coauthors) order(treat log_cites log_pubs log_funding nas ln_nb_trainees ln_nb_coauthors top_prmtr1_setnb sudden_death female) keep(treat log_cites log_pubs log_funding nas ln_nb_trainees ln_nb_coauthors top_prmtr1_setnb female sudden_death) varwidth(25) nonumber noobs nogaps nodep label b(%5.3f) se(%5.3f) star(† 0.10 * 0.05 ** 0.01) compress scalars("N Nb. of Scientists" "r2_p Pseudo-R2") sfmt(%10.0fc %9.32f) mlabels("(0)" "(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)") eqlabels(none) replace;
