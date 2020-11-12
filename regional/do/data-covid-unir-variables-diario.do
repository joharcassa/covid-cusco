********************************************************************************
**************************** DIRESA Cusco **************************************
********************** Dirección de Epidemiología ******************************
****************** Generar datos diarios COVID-19 en Cusco *********************
********************************************************************************

********************************************************************************
* 0. Pasos previos para juntar las bases de datos: Notificación y SISCOVID

* Definir el directorio de trabajo actual
global path "D:\Johar\7. Work\covid"
	global base "$path/base"
	global data "$path/data"
	global regional "$path/regional"
set more off, permanent

********************************************************************************
* 1. Casos positivos totales por dia
use "${data}\data-covid-unir-variables.dta", clear

keep if positivo_molecular == 1 | positivo_rapida == 1

collapse (count) var_id, by(fecha_resultado)

tsset fecha_resultado, daily
tsfill
generate total_positivo=sum(var_id)

rename var_id positivos

save "${regional}/data/data-covid-unir-variables-positivo.dta", replace

* 1.1 Casos positivos molecular por dia
use "${data}\data-covid-unir-variables.dta", clear

keep if positivo_molecular == 1

collapse (count) var_id, by(fecha_resultado)

tsset fecha_resultado, daily
tsfill
generate total_positivo_molecular=sum(var_id)

rename var_id positivos_molecular

save "${regional}/data/data-covid-unir-variables-positivo-molecular.dta", replace

* 1.2 Casos positivos rápida por dia
use "${data}\data-covid-unir-variables.dta", clear

keep if positivo_rapida == 1

collapse (count) var_id, by(fecha_resultado)

tsset fecha_resultado, daily
tsfill
generate total_positivo_rapida=sum(var_id)

rename var_id positivos_rapida

save "${regional}/data/data-covid-unir-variables-positivo-rapida.dta", replace

********************************************************************************
* 2. Muestras totales por día
use "${data}\data-covid-unir-variables.dta", clear

keep if  prueba_molecular == 1 | prueba_rapida == 1

collapse (count) var_id, by(fecha_resultado)

tsset fecha_resultado, daily
tsfill
generate total_muestra=sum( var_id )

rename var_id muestra

save "${regional}/data/data-covid-unir-variables-muestra.dta", replace

* 2.1 Muestras molecular por día
use "${data}\data-covid-unir-variables.dta", clear
keep if  prueba_molecular == 1

collapse (count) var_id, by(fecha_resultado)

tsset fecha_resultado, daily
tsfill
generate total_muestra_molecular=sum( var_id )

rename var_id muestra_molecular

save "${regional}/data/data-covid-unir-variables-muestra-molecular.dta", replace

* 2.1 Muestras rápida por día
use "${data}\data-covid-unir-variables.dta", clear

keep if prueba_rapida == 1

collapse (count) var_id, by(fecha_resultado)

tsset fecha_resultado, daily
tsfill
generate total_muestra_rapida=sum( var_id )

rename var_id muestra_rapida

save "${regional}/data/data-covid-unir-variables-muestra-rapida.dta", replace

********************************************************************************
* 3. Recuperados por día
use "${data}\data-covid-unir-variables.dta", clear

keep  if positivo_molecular == 1 | positivo_rapida == 1

collapse (count) var_id, by(fecha_recuperado)

tsset fecha_recuperado, daily
tsfill
generate total_recuperado=sum(var_id)

rename fecha_recuperado fecha_resultado
rename var_id recuperado

save "${regional}/data/data-covid-unir-variables-recuperado.dta", replace

********************************************************************************
* 4. Sintomáticos por día 
use "${data}\data-covid-unir-variables.dta", clear

keep if sintomatico == 1

collapse (count) var_id, by(fecha_resultado)

tsset fecha_resultado, daily
tsfill
generate total_sintomaticos=sum(var_id)

rename var_id sintomaticos

save "${regional}/data/data-covid-unir-variables-sintomaticos.dta", replace

********************************************************************************
* 5. Defunciones 
use "${data}\data-covid-unir-variables.dta", clear

keep if defuncion == 1

collapse (count) var_id, by(fecha_resultado)

rename var_id defunciones

tsset fecha_resultado, daily
tsfill
generate total_defunciones=sum(defunciones)

save "${regional}/data/data-defunciones.dta", replace

********************************************************************************
* 6. Inicio de síntoma
use "${data}\data-covid-unir-variables.dta", clear

keep if  positivo_molecular ==1 | positivo_rapida ==1
keep if fecha_inicio >= 21980
drop if fecha_inicio == .

collapse (count) var_id, by(fecha_inicio)

tsset fecha_inicio, daily
tsfill
generate total_inicio=sum(var_id)

rename fecha_inicio fecha_resultado
rename var_id inicio

save "${regional}/data/data-inicio", replace

* 6.1 Inicio de síntoma molecular
use "${data}\data-covid-unir-variables.dta", clear

keep if  positivo_molecular == 1

keep if fecha_inicio >= 21980
drop if fecha_inicio == .

collapse (count) var_id, by(fecha_inicio)

tsset fecha_inicio, daily
tsfill
generate total_inicio_molecular=sum(var_id)

rename fecha_inicio fecha_resultado
rename var_id inicio_molecular

save "${regional}/data/data-inicio-molecular", replace

* 6.2 Inicio de síntoma prueba rápida
use "${data}\data-covid-unir-variables.dta", clear

keep if positivo_rapida == 1
keep if fecha_inicio >= 21980
drop if fecha_inicio == .

collapse (count) var_id, by(fecha_inicio)

tsset fecha_inicio, daily
tsfill
generate total_inicio_rapida=sum(var_id)

rename fecha_inicio fecha_resultado
rename var_id inicio_rapida

save "${regional}/data/data-inicio-rapida", replace
********************************************************************************
* 9. Positivos con prueba rapida e IgM
use "${data}\data-covid-unir-variables.dta", clear

keep if (positivo_rapida ==1 & tipo_anticuerpo == "IgM Reactivo")

collapse (count) var_id, by(fecha_resultado)

tsset fecha_resultado, daily
tsfill
generate total_igm=sum(var_id)

rename var_id igm

save "${regional}/data/data-covid-unir-variables-igm.dta", replace


********************************************************************************
* 10. Positivos con prueba rapida e IgG
use "${data}\data-covid-unir-variables.dta", clear

keep if (positivo_rapida ==1 & tipo_anticuerpo == "IgG Reactivo")

collapse (count) var_id, by(fecha_resultado)

tsset fecha_resultado, daily
tsfill
generate total_igg=sum(var_id)

rename var_id igg

save "${regional}/data/data-covid-unir-variables-igg.dta", replace


********************************************************************************
* 11. Positivos con prueba rapida e IgM e IgG Reactivo
use "${data}\data-covid-unir-variables.dta", clear

keep if (positivo_rapida ==1 & tipo_anticuerpo == "IgM e IgG Reactivo")

collapse (count) var_id, by(fecha_resultado)

tsset fecha_resultado, daily
tsfill
generate total_igm_igg=sum(var_id)

rename var_id igm_igg

save "${regional}/data/data-covid-unir-variables-igm-igg.dta", replace

********************************************************************************
* 7. Juntando las bases de datos
use "${regional}\data\data-covid-unir-variables-positivo", clear
merge 1:1 fecha_resultado using "${regional}\data\data-covid-unir-variables-positivo-molecular"
drop _merge
merge 1:1 fecha_resultado using "${regional}\data\data-covid-unir-variables-positivo-rapida"
drop _merge 
merge 1:1 fecha_resultado using "${regional}\data\data-covid-unir-variables-muestra"
drop _merge
merge 1:1 fecha_resultado using "${regional}\data\data-covid-unir-variables-muestra-molecular"
drop _merge
merge 1:1 fecha_resultado using "${regional}\data\data-covid-unir-variables-muestra-rapida"
drop _merge
merge 1:1 fecha_resultado using "${regional}\data\data-covid-unir-variables-recuperado"
drop _merge
merge 1:1 fecha_resultado using "${regional}\data\data-covid-unir-variables-sintomaticos"
drop _merge
merge 1:1 fecha_resultado using "${regional}\data\data-defunciones"
drop _merge
merge 1:1 fecha_resultado using "${regional}\data\data-inicio"
drop _merge
merge 1:1 fecha_resultado using "${regional}\data\data-inicio-molecular"
drop _merge 
merge 1:1 fecha_resultado using "${regional}\data\data-inicio-rapida"
drop _merge 
merge 1:1 fecha_resultado using "${regional}\data\data-covid-unir-variables-igm"
drop _merge
merge 1:1 fecha_resultado using "${regional}\data\data-covid-unir-variables-igg"
drop _merge
merge 1:1 fecha_resultado using "${regional}\data\data-covid-unir-variables-igm-igg"
drop _merge

********************************************************************************
* 8. Total de activos por día
gen total_activos = total_positivo - total_recuperado

save "${regional}/data/data-covid-unir-variables-diario.dta", replace