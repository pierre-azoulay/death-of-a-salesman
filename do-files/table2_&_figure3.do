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

merge m:1 id using "${F10}data/afterlife_mediation_analysis.dta", keep(match master) keepusing(acd_mem_vdplus acd_mem_vdwthn5 xpctd_lasso_all_ntrt_cites inxss_lasso_all_ntrt_cites);
assert _merge==3;
drop _merge;

bysort id (year): gen stk_nbcites=sum(nb_cites);
bysort id (year): gen stk_nbcites_ncoauthor=sum(nb_cites_ncoauthor);
bysort id (year): gen stk_nbcites_ycoauthor=sum(nb_cites_ycoauthor);
bysort id (year): gen stk_nbcites_nfield=sum(nb_cites_nfield);
bysort id (year): gen stk_nbcites_yfield=sum(nb_cites_yfield);
bysort id (year): gen stk_nbcites_ncoloc=sum(nb_cites_ncoloc);
bysort id (year): gen stk_nbcites_ycoloc=sum(nb_cites_ycoloc);

preserve;
drop if treat==0;
gegen cites_per_year = sum(nb_cites), by(setnb year);
gen yr_rltv_death = year - death_year;
collapse (mean) cites_per_year, by(yr_rltv_death);
drop if yr_rltv_death<-40 | yr_rltv_death>40;

graph twoway line cites_per_year yr_rltv_death, lcolor(gs3) xline(0, lp(dash) lcolor(gs9)) xlab(-40(5)40, labsize(vsmall) tlength(.75)) ylab(0(50)200, labsize(vsmall) tlength(.75) angle(horizontal) grid glwidth(vvthin) glcolor(gs3)) graphregion(color(white)) xtitle(" " "Years Before/After Death") ytitle("Mean Nb. of Cites Per Year") saving("${F10}figures/gph/figure_1b.gph", replace);
graph export "${F10}figures/tif/figure_1b.tif", as(tif) width(2100) replace;
graph export "${F10}figures/png/figure_1b.png", as(png) width(2100) replace;
graph close;
restore;

recode deg 6=2;
recode deg 4=1;
gen MD=deg==1;
gen PhD=deg==2;
gen MDPhD=deg==3;
gen sudden=cod==2;
gen antcpt=cod==1;

keep if year==death_year;

egen nb_srce_allpubs=nvals(srce_pmid), by(setnb);
gegen nb_srce_own_btm10pct=total(yrltv_btm10pct==1), by(setnb);
gegen nb_srce_own_mdl25_75pct=total(yrltv_mdl25_75pct==1), by(setnb);
gegen nb_srce_own_top10pct=total(yrltv_top10pct==1), by(setnb);
gegen nb_srce_unv_top5pct=total(nrltv_top5pct==1), by(setnb);
gegen nb_srce_unv_top1pct=total(nrltv_top1pct==1), by(setnb);

egen nbpubs_inxid=nvals(srce_pmid), by(xid treat);
gen weight_xid=1/nbpubs_inxid;

sum nbpubs_inxid [aweight=weight_xid] if treat==0, d;

assert death_year-star_yob==aad if treat==1;

byhist stk_nbcites [aweight=weight_xid] if stk_nbcites<250, bin(20) by(treat) frac tw(xtitle("") ytitle("Fraction of Articles") graphregion(color(white)) xlabel(0(25)250, labsize(vsmall) tlength(.75)) legend(label(1 "Control") label(2 "Treated") position(1) ring(0) cols(1) size(small) region(lstyle(none) lcolor(gs3) lwidth(vvthin))) ylabel(0(.10)0.50, labsize(vsmall) tlength(.75) angle(horizontal) format(%15.2f) grid glwidth(vvthin) glcolor(gs3))) tw1(color(gs3) lwidth(none)) tw2(color(gs12) lwidth(none) saving("${F10}figures/gph/figure_3.gph", replace));
graph export "${F10}figures/tif/figure_3.tif", as(tif) width(2100) replace;
graph export "${F10}figures/png/figure_3.png", as(png) width(2100) replace;
graph close;

rename stk_nwghtd_collabs stk_coauthors;

label variable artcl_age "Article Age in Year of Death";
label variable srce_pubyear "Article Year of Publication";
label variable stk_nbcites "Article Citations at Baseline";
label variable stk_nbcites_ncoauthor "Article Citations by Non-Collaborators at Baseline";
label variable stk_nbcites_ycoauthor "Article Citations by Collaborators at Baseline";
label variable stk_nbcites_nfield "Article Citations outside of Field at Baseline";
label variable stk_nbcites_yfield "Article Citations within Field at Baseline";
label variable stk_nbcites_ncoloc "Article Citations from Distant Authors at Baseline";
label variable stk_nbcites_ycoloc "Article Citations from Colocated Authors at Baseline";
label variable death_year "Investigator Death Year";
label variable aad "Investigator Age at Death";
label variable nb_srce_allpubs "Investigator Nb. Publications in Matched Sample";
label variable nb_srce_own_btm10pct "Investigator Nb. Publications in Own Bottom 10%";
label variable nb_srce_own_mdl25_75pct "Investigator Nb. Publications in Middle 25%-75%";
label variable nb_srce_own_top10pct "Investigator Nb. Publications in Own Top 10%";
label variable nb_srce_unv_top1pct "Investigator Nb. Publications in Universe Top 1%";
label variable nb_srce_unv_top5pct "Investigator Nb. Publications in Universe Top 1%";
label variable nbauthors "Article Nb. of Authors";
label variable star_yob "Investigator Year of Birth";
label variable deg_year "Investigator Degree Year";
label variable female "Female";
label variable sudden "Investigator Death was Sudden";
label variable antcpt "Investigator Death was Anticipated";
label variable MD "MD Degree";
label variable PhD "PhD Degree";
label variable MDPhD "MD/PhD Degree";
label variable stk_inv_pubs "Investigator Cuml. Nb. of Publications";
label variable stk_inv_cites "Investigator Cuml. Nb. of Citations";
label variable stk_inv_nih "Investigator Cuml. Amount of Funding";
label variable stk_trainees "Investigator Nb. of Trainees";
label variable stk_coauthors "Investigator Nb. of Collaborators";
label variable acd_mem_vdwthn5 "Investigator Nb. of Academic Recognition Events";
label variable acd_mem_vdplus "Investigator Nb. of Academic Recognition Events";
label variable xpctd_lasso_all_ntrt_cites "Predicted Citations";
label variable inxss_lasso_all_ntrt_cites "Excess Citations";

replace stk_inv_nih=stk_inv_nih/1000;

tab treat;
estimates drop _all;

quietly estpost tabstat artcl_age srce_pubyear nbauthors stk_nbcites stk_nbcites_ncoauthor stk_nbcites_ycoauthor stk_nbcites_nfield stk_nbcites_yfield stk_nbcites_ncoloc stk_nbcites_ycoloc star_yob deg_year death_year nb_srce_allpubs stk_inv_pubs stk_inv_cites stk_inv_nih stk_trainees stk_coauthors acd_mem_vdplus acd_mem_vdwthn5 xpctd_lasso_all_ntrt_cites inxss_lasso_all_ntrt_cites [aweight=weight_xid], by(treat) stat(mean p50 sd min max) c(s) nototal;
esttab, cells("mean(label(Mean) fmt(%15.3fc)) p50(label(Median) fmt(%15.0f)) sd(label(Std. Dev.) fmt(%15.3fc)) min(label(Min.) fmt(%15.0fc)) max(label(Max.) fmt(%15.0fc))") noobs nomtitle nonumber label;
esttab using "${F10}tables/table_2.rtf", cells("mean(label(Mean) fmt(%15.3fc)) p50(label(Median) fmt(%15.0f)) sd(label(Std. Dev.) fmt(%15.3fc)) min(label(Min.) fmt(%15.0f)) max(label(Max.) fmt(%15.0f))") noobs nomtitle nonumber label replace;

quietly estpost tabstat star_yob deg_year death_year [aweight=weight_xid], by(treat) stat(mean p50 sd min max) c(s) nototal;
esttab, cells("mean(label(Mean) fmt(%15.3f)) p50(label(Median) fmt(%15.0f)) sd(label(Std. Dev.) fmt(%15.3f)) min(label(Min.) fmt(%15.0f)) max(label(Max.) fmt(%15.0f))") noobs nomtitle nonumber label;
esttab using "${F10}tables/table_2.rtf", cells("mean(label(Mean) fmt(%15.3f)) p50(label(Median) fmt(%15.0f)) sd(label(Std. Dev.) fmt(%15.3f)) min(label(Min.) fmt(%15.0f)) max(label(Max.) fmt(%15.0f))") noobs nomtitle nonumber label append;

quietly estpost tabstat stk_inv_pubs stk_inv_cites stk_inv_nih stk_trainees stk_coauthors [aweight=weight_xid], by(treat) stat(mean p50 sd min max) c(s) nototal;
esttab, cells("mean(label(Mean) fmt(%15.0fc)) p50(label(Median) fmt(%15.0fc)) sd(label(Std. Dev.) fmt(%15.0fc)) min(label(Min.) fmt(%15.0fc)) max(label(Max.) fmt(%15.0fc))") noobs nomtitle nonumber label;
esttab using "${F10}tables/table_2.rtf", cells("mean(label(Mean) fmt(%15.0fc)) p50(label(Median) fmt(%15.0fc)) sd(label(Std. Dev.) fmt(%15.0fc)) min(label(Min.) fmt(%15.0fc)) max(label(Max.) fmt(%15.0fc))") noobs nomtitle nonumber label append;