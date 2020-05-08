cd c:\Users\Blair\Documents\ECON7205_Grp_Assign\
use clogit.dta, replace

merge m:1 job state16 using wage.dta
drop if state16==9

capture drop job_1 job_2 job_3 job_4 ///
  immigrant_job_1 immigrant_job_2 immigrant_job_3 immigrant_job_4 ///
  ysa_job_1 ysa_job_2 ysa_job_3 ysa_job_4
gen job_1 = (job==1)
gen job_2 = (job==2)
gen job_3 = (job==3)
gen job_4 = (job==4)
gen immigrant_job_1 = immigrant * job_1
gen immigrant_job_2 = immigrant * job_2
gen immigrant_job_3 = immigrant * job_3
gen immigrant_job_4 = immigrant * job_4
gen ysa_job_1 = ysa * job_1
gen ysa_job_2 = ysa * job_2
gen ysa_job_3 = ysa * job_3
gen ysa_job_4 = ysa * job_4

// Clogit
eststo clear
est clear
cmset state16 person job
cmclogit choice min_wage avg_wage, casevars(immigrant c.ysa c.ysa#c.ysa education c.age c.age#c.age ///
	english sex_d qualification disstat) base(0) cluster(state16)
est store full
esttab using clogit.tex ///
  ,unstack nobaselevels replace nogap b(3) se(3) depvar booktabs  ///
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
  	disstat "$\mathit{Health}$" ///
  	min_wage "$\mathit{Minimum_Wage}$" ///
  	avg_wage "$\mathit{Average_Wage}$") ///
  star(* 0.1 ** 0.05 *** 0.01)
cmclogit choice min_wage avg_wage if job!=4, casevars(immigrant c.ysa c.ysa#c.ysa c.age c.age#c.age ///
	english sex_d qualification disstat) base(0)
est store restricted
hausman full restricted

eststo clear
cmset person job
cmclogit choice min_wage avg_wage, casevars(immigrant c.ysa c.ysa#c.ysa education c.age c.age#c.age ///
	english sex_d qualification disstat) base(0)
est store full
cmclogit choice min_wage avg_wage if job!=3, casevars(immigrant c.ysa c.ysa#c.ysa education c.age c.age#c.age ///
	english sex_d qualification disstat) base(0)
est store restricted
hausman full restricted

mixlogit choice min_wage avg_wage immigrant ysa, rand(job_1 job_2 job_3) group(person)
mixlogit choice min_wage avg_wage ///
  , rand(job_1 job_2 job_3 job_4 ///
  immigrant_job_1 immigrant_job_2 immigrant_job_3 immigrant_job_4 ///
  ysa_job_1 ysa_job_2 ysa_job_3 ysa_job_4) group(person) nrep(50)

cmset state16 person job
cmxtmixlogit choice min_wage avg_wage, casevars(immigrant c.ysa) base(0) rand(job_1 job_2 job_3) nocons
cmset person job
cmmixlogit choice min_wage avg_wage, casevars(immigrant c.ysa) base(0) rand(job_1 job_2 job_3 job_4) nocons
