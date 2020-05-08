cd c:\Users\Blair\Documents\ECON7205_Grp_Assign\
use nhs17spb.dta, replace

// Generate occupation
capture drop occupation
gen occupation = .
// Labours
replace occupation = 0 if occup13b==8
// Blue collar
replace occupation = 1 if occup13b==7
// White collar
replace occupation = 2 if occup13b==3 | occup13b==4 | occup13b==5 | occup13b==6
// Managers
replace occupation = 3 if occup13b==1
// Professional
replace occupation = 4 if occup13b==2

// Generate employment status 0 for unemployed and 1 for employed
capture drop employment
gen employment = 0
replace employment = 1 if lfsbc==1

// Generate education
capture drop education
gen education = .
replace education = 8 if hyschcbc==5
replace education = 9 if hyschcbc==4
replace education = 10 if hyschcbc==3
replace education = 11 if hyschcbc==2
replace education = 12 if hyschcbc==1

// Generate original country
capture drop original
gen original = .
replace original = 1 if cobbc==1 | cobbc==2
replace original = 0 if cobbc==3
label define original 1 "Origin from English-speaking Countries" ///
	0 "Original from non English-speaking Countries"

// Immigrants
capture drop immigrant
gen immigrant = .
replace immigrant = 1 if cobbc==2 | cobbc==3
replace immigrant = 0 if cobbc==1

// Generate age based on ageb
capture drop age
gen age = .
replace age = 2 if ageb==1
replace age = 7 if ageb==2
replace age = 12 if ageb==3
replace age = 16 if ageb==4
replace age = 18 if ageb==5
replace age = 22 if ageb==6
replace age = 27 if ageb==7
replace age = 32 if ageb==8
replace age = 37 if ageb==9
replace age = 42 if ageb==10
replace age = 47 if ageb==11
replace age = 52 if ageb==12
replace age = 57 if ageb==13
replace age = 62 if ageb==14
replace age = 67 if ageb==15
replace age = 72 if ageb==16
replace age = 77 if ageb==17
replace age = 82 if ageb==18
replace age = 85 if ageb==19
gen age_sqrt = age * age
gen age_log = log(age)
gen age_log_sqrt = log(age_sqrt)

capture drop age_d
gen age_d = .
replace age_d = 0 if ageb==1 | ageb==2 | ageb==3 | ageb==4
replace age_d = 1 if ageb==5 | ageb==6 | ageb==7
replace age_d = 2 if ageb==8 | ageb==9
replace age_d = 3 if ageb==10 | ageb==11
replace age_d = 4 if ageb==12 | ageb==13
replace age_d = 5 if ageb==14 | ageb==15 | ageb==16 | ageb==17 | ageb==18 | ageb==19

// Year since arrival based on age and yoabc
// If yoabc=1, ysa=age
// else, ysa=age-yoabc
capture drop year_of_arrival
gen year_of_arrival = .
replace year_of_arrival = 1985 if yoabc==2
replace year_of_arrival = 1988 if yoabc==3
replace year_of_arrival = 1993 if yoabc==4
replace year_of_arrival = 1998 if yoabc==5
replace year_of_arrival = 2003 if yoabc==6
replace year_of_arrival = 2008 if yoabc==7
replace year_of_arrival = 2011 if yoabc==8

capture drop ysa
gen ysa = .
replace ysa = 2018 - year_of_arrival if yoabc==2 | yoabc==3 | yoabc==4 ///
	| yoabc==5 | yoabc==6 | yoabc==7 | yoabc==8
replace ysa = 0 if yoabc==1
gen ysa_sqrt = ysa * ysa
gen ysa_log = log(ysa)

// Sex dummy
capture drop sex_d
gen sex_d = .
replace sex_d = 0 if sex==1
replace sex_d = 1 if sex==2

// English proficiency
capture drop english
gen english = .
replace english = 0 if profeng==8
replace english = 1 if profeng==4
replace english = 2 if profeng==3
replace english = 3 if profeng==2
replace english = 4 if profeng==1
replace english = 5 if profeng==5

// Non-school qualification
capture drop qualification
gen qualification = .
replace qualification = 1 if edattq2==1
replace qualification = 0 if edattq2==2

// Clogit

merge m:1 abshidb using nhs17hhb
keep occupation education immigrant ysa age english sex_d qualification disstat abshidb state16
drop if occupation==.

capture drop person
gen person = _n

save clogit.dta, replace

eststo clear
probit employment education immigrant c.ysa c.ysa#c.ysa ///
	c.age c.age#c.age english sex_d qualification disstat, nolog
eststo reg
probit employment education immigrant c.ysa c.ysa#c.ysa ///
	c.age c.age#c.age english sex_d qualification disstat, nolog robust
eststo reg_robust
margins, dydx(*) post
eststo ame
esttab using ./probit.tex ///
  , nobaselevels replace nogap b(3) se(3) depvar booktabs  ///
  eqlabels(none) nonumbers ///
  mtitles("Probit Regression" "Robust Standard Errors" ///
   "Average Marginal Effects") ///
  stats(N r2_p ll, fmt(0 3 3) ///
  labels("N" "Pseudo R-squared" "Log Likelihood")) ///
  varlabels(_cons "$\mathit{Intercept}$" ///
  	education "$\mathit{Education}$" ///
  	immigrant "$\mathit{Immigrant}$" ///
  	ysa "$\mathit{Year\ since\ Migration}$" ///
  	c.ysa#c.ysa "$\mathit{Year\ since\ Migration}^2$" ///
  	age "$\mathit{Age}$" ///
  	c.age#c.age "$\mathit{Age}^2$" ///
  	english "$\mathit{English}$" ///
  	sex_d "$\mathit{Sex}$" ///
  	qualification "$\mathit{Qualification}$" ///
  	disstat "$\mathit{Health}$") ///
  star(* 0.1 ** 0.05 *** 0.01)

qui: probit employment education immigrant c.ysa c.ysa#c.ysa c.age c.age#c.age ///
	english sex_d qualification disstat, nolog
margins, at(ysa=(0 (5) 30) immigrant=1 english=4 sex_d=1 ///
	age=30 qualification=1 disstat=7) atmeans post
qui: probit employment education immigrant c.ysa c.ysa#c.ysa c.age c.age#c.age ///
	english sex_d qualification disstat, nolog
margins, at(ysa=0 immigrant=0 english=5 sex_d=1 ///
	age=30 qualification=1 disstat=7) atmeans post

eststo clear
mlogit occupation education immigrant c.ysa c.ysa#c.ysa c.age c.age#c.age ///
	english sex_d qualification disstat, base(0) robust
esttab using mlogit1.tex ///
  ,unstack nobaselevels replace nogap b(3) se(3) depvar  ///
  eqlabels(none) nonumbers noobs ///
  stats(N r2_p ll, fmt(0 3 3) ///
  labels("N" "Pseudo R-squared" "Log Likelihood")) ///
  varlabels(_cons "$\mathit{Intercept}$" ///
  	education "$\mathit{Education}$" ///
  	immigrant "$\mathit{Immigrant}$" ///
  	ysa "$\mathit{Year\ since\ Migration}$" ///
  	c.ysa#c.ysa "$\mathit{Year\ since\ Migration}^2$" ///
  	age "$\mathit{Age}$" ///
  	c.age#c.age "$\mathit{Age}^2$" ///
  	english "$\mathit{English}$" ///
  	sex_d "$\mathit{Sex}$" ///
  	qualification "$\mathit{Qualification}$" ///
  	disstat "$\mathit{Health}$") ///
  star(* 0.1 ** 0.05 *** 0.01)

eststo clear
mlogit occupation education immigrant c.ysa c.ysa#c.ysa c.age c.age#c.age ///
	english sex_d qualification disstat, base(0) robust
eststo mlogit
foreach o in 1 2 3 4{
	quietly margins, dydx(*) predict(outcome(`o')) post
	eststo, title(Outcome `o')
	estimates restore mlogit
}
eststo drop mlogit
esttab using mlogit2.tex ///
  ,unstack nobaselevels replace nogaps b(3) se(3) depvar  ///
  eqlabels(none) nonumbers noobs ///
  stats(N r2_p ll, fmt(0 3 3) ///
  labels("N" "Pseudo R-squared" "Log Likelihood")) ///
  varlabels(_cons "$\mathit{Intercept}$" ///
  	education "$\mathit{Education}$" ///
  	immigrant "$\mathit{Immigrant}$" ///
  	ysa "$\mathit{Year\ since\ Migration}$" ///
  	c.ysa#c.ysa "$\mathit{Year\ since\ Migration}^2$" ///
  	age "$\mathit{Age}$" ///
  	c.age#c.age "$\mathit{Age}^2$" ///
  	english "$\mathit{English}$" ///
  	sex_d "$\mathit{Sex}$" ///
  	qualification "$\mathit{Qualification}$" ///
  	disstat "$\mathit{Health}$") ///
  star(* 0.1 ** 0.05 *** 0.01)

eststo clear
mlogit occupation immigrant c.ysa c.ysa#c.ysa education c.age c.age#c.age ///
	english sex_d qualification disstat, rr base(0) robust
esttab using mlogit_rr1.tex ///
  ,unstack nobaselevels replace nogap b(3) se(3) depvar  ///
  eqlabels(none) nonumbers noobs eform ///
  stats(N r2_p ll, fmt(0 3 3) ///
  labels("N" "Pseudo R-squared" "Log Likelihood")) ///
  varlabels(_cons "$\mathit{Intercept}$" ///
  	education "$\mathit{Education}$" ///
  	immigrant "$\mathit{Immigrant}$" ///
  	ysa "$\mathit{Year\ since\ Migration}$" ///
  	c.ysa#c.ysa "$\mathit{Year\ since\ Migration}^2$" ///
  	age "$\mathit{Age}$" ///
  	c.age#c.age "$\mathit{Age}^2$" ///
  	english "$\mathit{English}$" ///
  	sex_d "$\mathit{Sex}$" ///
  	qualification "$\mathit{Qualification}$" ///
  	disstat "$\mathit{Health}$") ///
  star(* 0.1 ** 0.05 *** 0.01)


// Plot 1
use plot1, clear
twoway (connected immi year, sort) (connected nonimmi year, sort) ///
	, ytitle(Predicted Probabilities) xtitle(Year since Arrival)

// Plot2

qui: mlogit occupation education immigrant c.ysa c.ysa#c.ysa c.age c.age#c.age ///
	english sex_d qualification disstat, base(0)
margins, at(ysa=(0 (5) 30) immigrant=1 english=4 sex_d=1 ///
	age=30 qualification=1 disstat=7) atmeans predict(outcome(1)) post
qui: mlogit occupation education immigrant c.ysa c.ysa#c.ysa c.age c.age#c.age ///
	english sex_d qualification disstat, base(0)
margins, at(ysa=(0 (5) 30) immigrant=1 english=4 sex_d=1 ///
	age=30 qualification=1 disstat=7) atmeans predict(outcome(2)) post
qui: mlogit occupation education immigrant c.ysa c.ysa#c.ysa c.age c.age#c.age ///
	english sex_d qualification disstat, base(0)
margins, at(ysa=(0 (5) 30) immigrant=1 english=4 sex_d=1 ///
	age=30 qualification=1 disstat=7) atmeans predict(outcome(3)) post
qui: mlogit occupation education immigrant c.ysa c.ysa#c.ysa c.age c.age#c.age ///
	english sex_d qualification disstat, base(0)
margins, at(ysa=(0 (5) 30) immigrant=1 english=4 sex_d=1 ///
	age=30 qualification=1 disstat=7) atmeans predict(outcome(4)) post

qui: mlogit occupation education immigrant c.ysa c.ysa#c.ysa c.age c.age#c.age ///
	english sex_d qualification disstat, base(0)
margins, at(ysa=0 immigrant=0 english=5 sex_d=1 ///
	age=30 qualification=1 disstat=7) atmeans predict(outcome(1)) post
qui: mlogit occupation education immigrant c.ysa c.ysa#c.ysa c.age c.age#c.age ///
	english sex_d qualification disstat, base(0)
margins, at(ysa=0 immigrant=0 english=5 sex_d=1 ///
	age=30 qualification=1 disstat=7) atmeans predict(outcome(2)) post
qui: mlogit occupation education immigrant c.ysa c.ysa#c.ysa c.age c.age#c.age ///
	english sex_d qualification disstat, base(0)
margins, at(ysa=0 immigrant=0 english=5 sex_d=1 ///
	age=30 qualification=1 disstat=7) atmeans predict(outcome(3)) post
qui: mlogit occupation education immigrant c.ysa c.ysa#c.ysa c.age c.age#c.age ///
	english sex_d qualification disstat, base(0)
margins, at(ysa=0 immigrant=0 english=5 sex_d=1 ///
	age=30 qualification=1 disstat=7) atmeans predict(outcome(4)) post

use Plot2, clear
twoway (connected Immi_Blue Year_since_Arrival, sort msymbol(circle)) ///
	(connected Nonimmi_Blue Year_since_Arrival, sort msymbol(circle)) ///
	, ytitle(Predicted Probabilities) xtitle(Year since Arrival)
graph export "./Plot21.pdf", as(pdf) name("Graph") replace
twoway (connected Immi_White Year_since_Arrival, sort msymbol(square)) ///
	(connected Nonimmi_White Year_since_Arrival, sort msymbol(square)) ///
	, ytitle(Predicted Probabilities) xtitle(Year since Arrival)
graph export "./Plot22.pdf", as(pdf) name("Graph") replace
twoway (connected Immi_Mgr Year_since_Arrival, sort msymbol(triangle)) ///
	(connected Nonimm_Mgr Year_since_Arrival, sort msymbol(triangle)) ///
	, ytitle(Predicted Probabilities) xtitle(Year since Arrival)
graph export "./Plot23.pdf", as(pdf) name("Graph") replace
twoway (connected Immi_Prof Year_since_Arrival, sort msymbol(diamond)) ///
	(connected Nonimmi_Prof Year_since_Arrival, sort msymbol(diamond)) ///		
	, ytitle(Predicted Probabilities) xtitle(Year since Arrival)
graph export "./Plot24.pdf", as(pdf) name("Graph") replace
