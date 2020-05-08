//gen employed vs unemployed
gen dummywork = 0
replace dummywork = 1 if lfscp == 1
//gen occupation
gen dummyocc = 0
gen occupation = string(occ6dig)
gen occup = substr(occupation,1,1)
gen occpchoice = real(occup)

label define occpchoice 1 "managers" 2 "professionals" 3 "technicians and trades workers" 4 "community and personal service workers" 5 "clerical and administrative workers" 6 "sales workers" 7 "machinery operators and drivers" 8 "labours"
label values occpchoice occpchoice

//combine occc
gen dummyoccc = 0
//replace dummyoccc 
replace dummyoccc = 1 if occpchoice == 2
replace dummyoccc = 2 if occpchoice == 1 | occpchoice == 5| occpchoice == 6
replace dummyoccc = 3 if occpchoice == 7
replace dummyoccc = 4 if occpchoice == 8 
replace dummyoccc = 5 if occpchoice == 4
replace dummyoccc = 6 if occpchoice == 3

label define dummyoccc 1"professionals" 2"whitecollar" 3"bluecollar" 4"labours" 5 "community and personal service workers" 6 "Trade"
label values dummyoccc dummyoccc

// Generate education
capture drop education
gen education = .
replace education = 5 if lvledua==1
replace education = 4 if lvledua==2 | lvledua== 3
replace education = 3 if lvledua==4 |lvledua==5| lvledua==6| lvledua==7
replace education = 2 if lvledua==8|lvledua==9| lvledua==10| lvledua==11
replace education = 1 if lvledua==12

// Generate english
capture drop english
gen english = .
replace english = 1 if cobcb==1 | cobcb==2
replace english = 0 if cobcb==3

//gen age2
gen age2=ageec*ageec

//gen year of arrive
gen arrive=.
replace arrive = 1 if yoabc==4
replace arrive =2 if yoabc==3
replace arrive=3 if yoabc==2
replace arrive=4 if yoabc==1

//run models
probit dummywork ageec age2 education english sexp mstatp arrive, nolog
reg inctscp8 ageec age2 education english sexp mstatp arrive, robust
mlogit dummyoccc ageec age2 education english arrive if dummyoccc>0, base(4) nolog