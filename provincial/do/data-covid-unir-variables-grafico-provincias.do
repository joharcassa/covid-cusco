********************************************************************************
**************************** DIRESA Cusco **************************************
********************** Dirección de Epidemiología ******************************
************* Datos diarios por  provincia COVID-19 en Cusco *******************
********************************************************************************

********************************************************************************
* 0. Pasos previos para juntar las bases de datos: Notificación y SISCOVID

* Definir el directorio de trabajo actual
global path "D:\Johar\7. Work\covid"
	global data "$path/data"
	global provincial "$path/provincial"
set more off, permanent

********************************************************************************
* 1. Casos positivos totales por dia

forvalues t = 1/13 {
use "${data}\data-covid-unir-variables.dta", clear

keep if provincia_residencia == `t'

keep if positivo_molecular ==1 | positivo_rapida == 1

collapse (count) var_id, by(fecha_resultado)

tsset fecha_resultado, daily
tsfill
generate total_positivo_`t'=sum(var_id)

rename var_id positivos_`t'

save "${provincial}/data/data-covid-unir-variables-positivo-`t'.dta", replace

* 1.1 Casos positivos molecular por dia

use "${data}\data-covid-unir-variables.dta", clear

keep if provincia_residencia == `t'

keep if positivo_molecular ==1 

collapse (count) var_id, by(fecha_resultado)

tsset fecha_resultado, daily
tsfill
generate total_positivo_molecular_`t'=sum(var_id)

rename var_id positivos_molecular_`t'

save "${provincial}/data/data-covid-unir-variables-positivo-molecular-`t'.dta", replace

* 1.2 Casos positivos rápida por dia
use "${data}\data-covid-unir-variables.dta", clear

keep if provincia_residencia == `t'

keep if positivo_rapida == 1

collapse (count) var_id, by(fecha_resultado)

tsset fecha_resultado, daily
tsfill
generate total_positivo_rapida_`t'=sum(var_id)

rename var_id positivos_rapida_`t'

save "${provincial}/data/data-covid-unir-variables-positivo-rapida-`t'.dta", replace

********************************************************************************
* 2. Muestras totales por día

use "${data}\data-covid-unir-variables.dta", clear

keep if provincia_residencia == `t'

keep if  prueba_molecular == 1 | prueba_rapida == 1

collapse (count) var_id, by(fecha_resultado)

tsset fecha_resultado, daily
tsfill
generate total_muestra_`t'=sum( var_id )

rename var_id muestra_`t'

save "${provincial}/data/data-covid-unir-variables-muestra-`t'.dta", replace

* 2.1 Muestras molecular por día

use "${data}\data-covid-unir-variables.dta", clear

keep if provincia_residencia == `t'

keep if  prueba_molecular == 1

collapse (count) var_id, by(fecha_resultado)

tsset fecha_resultado, daily
tsfill
generate total_muestra_molecular_`t'=sum( var_id )

rename var_id muestra_molecular_`t'

save "${provincial}/data/data-covid-unir-variables-muestra-molecular-`t'.dta", replace

* 2.1 Muestras rápidas por día

use "${data}\data-covid-unir-variables.dta", clear

keep if provincia_residencia == `t'

keep if  prueba_rapida == 1

collapse (count) var_id, by(fecha_resultado)

tsset fecha_resultado, daily
tsfill
generate total_muestra_rapida_`t'=sum( var_id )

rename var_id muestra_rapida_`t'

save "${provincial}/data/data-covid-unir-variables-muestra-rapida-`t'.dta", replace

********************************************************************************
* 3. Recuperados por día

use "${data}\data-covid-unir-variables.dta", clear

keep if provincia_residencia == `t'

keep  if positivo_molecular == 1 | positivo_rapida == 1 

collapse (count) var_id, by(fecha_recuperado)

tsset fecha_recuperado, daily
tsfill
generate total_recuperado_`t'=sum(var_id)

rename fecha_recuperado fecha_resultado
rename var_id recuperado_`t'

save "${provincial}/data/data-covid-unir-variables-recuperado-`t'.dta", replace


********************************************************************************
* 4. Sintomáticos por día

use "${data}\data-covid-unir-variables.dta", clear

keep if provincia_residencia == `t'

keep if positivo_molecular == 1 | positivo_rapida == 1

keep if sintomatico == 1
collapse (count) var_id, by(fecha_resultado)

tsset fecha_resultado, daily
tsfill
generate total_sintomaticos_`t'=sum(var_id)

rename var_id sintomaticos_`t'

save "${provincial}/data/data-covid-unir-variables-sintomaticos-`t'.dta", replace


********************************************************************************
* 5. Defunciones 

* Previamente tienes que cambiar el formato de fecha, un trabajo a mano arduo

use "${data}\data-covid-unir-variables.dta", clear

keep if defuncion == 1

keep if provincia_residencia == `t'

collapse (count) var_id, by(fecha_resultado)

rename var_id defunciones_`t'

tsset fecha_resultado, daily
tsfill
generate total_defunciones_`t'=sum(defunciones_`t')

save "${provincial}/data/data-defunciones-`t'.dta", replace


********************************************************************************
* 6. Inicio de síntoma

use "${data}\data-covid-unir-variables.dta", clear

keep if provincia_residencia == `t'

keep if  positivo_molecular == 1 | positivo_rapida == 1

keep if fecha_inicio >= 21980
drop if fecha_inicio == .

collapse (count) var_id, by(fecha_inicio)

tsset fecha_inicio, daily
tsfill
generate total_inicio_`t'=sum(var_id)

rename fecha_inicio fecha_resultado
rename var_id inicio_`t'

save "${provincial}/data/data-inicio-`t'", replace

********************************************************************************
* 9. Positivos con prueba rapida e IgM

use "${data}\data-covid-unir-variables.dta", clear

keep if provincia_residencia == `t'

keep if (positivo_rapida==1 & tipo_anticuerpo == "IgM Reactivo")

collapse (count) var_id, by(fecha_resultado)

tsset fecha_resultado, daily
tsfill
generate total_igm_`t'=sum(var_id)

rename var_id igm_`t'

save "${provincial}/data/data-covid-unir-variables-igm-`t'.dta", replace


********************************************************************************
* 10. Positivos con prueba rapida e IgG

use "${data}\data-covid-unir-variables.dta", clear

keep if provincia_residencia == `t'

keep if (positivo_rapida==1 & tipo_anticuerpo== "IgG Reactivo")

collapse (count) var_id, by(fecha_resultado)

tsset fecha_resultado, daily
tsfill
generate total_igg_`t'=sum(var_id)

rename var_id igq_`t'

save "${provincial}/data/data-covid-unir-variables-igg-`t'.dta", replace


********************************************************************************
* 11. Positivos con prueba rapida e IgM e IgG Reactivo

use "${data}\data-covid-unir-variables.dta", clear

keep if provincia_residencia == `t'

keep if (positivo_rapida==1 & tipo_anticuerpo == "IgM e IgG Reactivo")

collapse (count) var_id, by(fecha_resultado)

tsset fecha_resultado, daily
tsfill
generate total_igm_igg_`t'=sum(var_id)

rename var_id igm_igg_`t'

save "${provincial}/data/data-covid-unir-variables-igm-igg-`t'.dta", replace

********************************************************************************
* 7. Juntando las bases de datos

use "${provincial}\data\data-covid-unir-variables-positivo-`t'", clear

merge 1:1 fecha_resultado using "${provincial}\data\data-covid-unir-variables-positivo-molecular-`t'.dta"
drop _merge
merge 1:1 fecha_resultado using "${provincial}\data\data-covid-unir-variables-positivo-rapida-`t'.dta"
drop _merge 
merge 1:1 fecha_resultado using "${provincial}\data\data-covid-unir-variables-muestra-`t'.dta"
drop _merge
merge 1:1 fecha_resultado using "${provincial}\data\data-covid-unir-variables-muestra-molecular-`t'.dta"
drop _merge
merge 1:1 fecha_resultado using "${provincial}\data\data-covid-unir-variables-muestra-rapida-`t'.dta"
drop _merge
merge 1:1 fecha_resultado using "${provincial}\data\data-covid-unir-variables-recuperado-`t'.dta"
drop _merge
merge 1:1 fecha_resultado using "${provincial}\data\data-covid-unir-variables-sintomaticos-`t'.dta"
drop _merge
merge 1:1 fecha_resultado using "${provincial}\data\data-defunciones-`t'.dta"
drop _merge 
merge 1:1 fecha_resultado using "${provincial}\data\data-inicio-`t'.dta"
drop _merge 
merge 1:1 fecha_resultado using "${provincial}\data\data-covid-unir-variables-igm-`t'.dta"
drop _merge
merge 1:1 fecha_resultado using "${provincial}\data\data-covid-unir-variables-igg-`t'.dta"
drop _merge
merge 1:1 fecha_resultado using "${provincial}\data\data-covid-unir-variables-igm-igg-`t'.dta"
drop _merge

********************************************************************************
* 8. Total de activos por día
gen total_activos_`t' = total_positivo_`t' - total_recuperado_`t'

save "${provincial}/data/data-covid-unir-variables-grafico-`t'.dta", replace

}

use "${provincial}\data\data-covid-unir-variables-grafico-1.dta", clear

forvalues i=2/13 {

merge 1:1 fecha_resultado using "${provincial}\data\data-covid-unir-variables-grafico-`i'.dta"
drop _merge 
}

save "${provincial}/data/data-covid-unir-variables-grafico-provincial-total.dta", replace