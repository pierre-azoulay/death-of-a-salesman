*! version 0.3.0  20may2018  Tim Simcoe, Miikka Rokkanen, Michael Stepner

/* Original version: Tim Simcoe 2007-02-20 */
/* Updated: Miikka Rokkanen 2012-08-10 */
/* Updated: Michael Stepner 2018-05-20 */

/*   This program caculates a "Robust" Covariance Matrix for the 
Poisson QML model with conditional fixed effects. Formulas were
obtained from Wooldridge (1999), Journal of Econometrics  */

program define xtqmlp, eclass byable(recall) sort
	version 12.0
	local cmdline=`"xtqmlp `0'"'

	syntax varlist(fv) [if] [in] [iweight], [FE IRr CLuster(varname)]
	marksample touse

	** Make sure user specifies a Group Variable (j)
	local j = "`_dta[iis]'"
	if length("`j'") == 0 {
		di as error "must specify panelvar; use {bf:xtset}"
		exit 459
	}

	** Prepare clustering
	if length("`cluster'") > 0 {
		* Check to see that groups (j) are nested within clusters
	    cap bys `touse' `j': assert `cluster'==`cluster'[_n-1] if _n>1 & `touse'
        if _rc {
			di as error "group variable (`j') must be nested within clusters (`cluster')"
			exit 459
        }

		* Count number of clusters
		quietly {
			regress `varlist' if `touse', cluster(`cluster')
			display " regress `varlist' if `touse', cluster(`cluster')  `e(N_clust)'"	
			local cs =`e(N_clust)'
		}
	}
	

	xtpoisson `varlist' if `touse' [`weight'`exp'], fe i(`j') `irr'

	display "Calculating Robust Standard Errors..."
	* Note: within xtpoisson.ado, robust standard errors are calculated by the program XTPOISSON_FE_ROBUST
	quietly {

		tempvar mu mubar ybar score
		
		matrix b = e(b)
		matrix V = e(V)			
			
		qui predict double `mu' if e(sample), xb
		qui replace `mu' = exp(`mu') if e(sample)
		qui egen double `mubar' = mean(`mu') if e(sample), by(`j')
		qui egen double `ybar' = mean(`e(depvar)') if e(sample), by(`j')
		qui gen double `score' = `e(depvar)' - `mu'*`ybar'/`mubar' if e(sample)
		
		if length("`cluster'") > 0 {
			_robust `score' if e(sample), variance(V) cluster(`cluster') minus(0)
		}
		if length("`cluster'") == 0 {
			_robust `score' if e(sample), variance(V) cluster(`j') minus(0)
		}

		/* Calculate Wald Chi2 Statistic (first get rid of omitted variables) */

		_ms_omit_info b
		local cols = colsof(b)
		matrix noomit =  J(1,`cols',1) - r(omit)

		mata: newV = select(st_matrix("V"),(st_matrix("noomit")))
		mata: newV = select(newV, (st_matrix("noomit"))')
		mata: st_matrix("newV",newV)
			
		mata: newB = select(st_matrix("b"),(st_matrix("noomit")))
		mata: st_matrix("newB",newB)
		
		local dof = colsof(newB)
		
		mat chi = newB * inv(newV) * newB'
		local chi2 = trace(chi)
		local pval = chi2tail(`dof',`chi2')	
		
		ereturn scalar chi2 = `chi2'
		ereturn scalar p = `pval'										   
		if length("`cluster'") > 0 {
			ereturn scalar N_clust =`cs'
		}
		ereturn repost b = b V = V 
		if ("`cluster'"!="") ereturn local clustvar ="`cluster'"
		ereturn local vce ="robust"
		ereturn local vcetype ="Robust"
		ereturn local predict ="xtqmlp_refe_p"
		ereturn local cmd ="xtqmlp"
		ereturn local cmdline =`"`cmdline'"'
		
	}

	if "`irr'" == "irr" {
		ereturn display, eform(IRR)
	}

	if "`irr'" != "irr" {
		ereturn display
	}

	di in green "Wald chi2(" in yellow `dof' in green ") = " in yellow %8.2f `chi2' ///
		"                                " in green "Prob > chi2 = " in yellow %8.4f `pval'
	
	if length("`cluster'") > 0 { 
		di in green "Number of Clusters: " in yellow `cs'
	}

end

