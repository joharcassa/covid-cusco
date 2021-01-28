********************************************************************************
**************************** DIRESA Cusco **************************************
********************** Dirección de Epidemiología ******************************
***************** Datos de la pandemia por COVID-19 en Cusco ********************
********************************************************************************

********************************************************************************
* 0. Pasos previos para juntar las bases de datos: Notificación y SISCOVID

* Definir el directorio de trabajo actual
global path "C:\johar\covid-cusco"
	global base "$path/base"
	global data "$path/data"
	global do "$path/do"
	global regional "$path/regional"
	global provincial "$path/provincial"
	global distrital "$path/distrital"
	
* Unir las tres bases de datos
do "${do}\data-covid-unir.do"

* Crear las variables
do "${do}\data-covid-unir-variables.do"

********************************************************************************
* Análisis regional
do "${regional}\do\data-covid-unir-variables-diario.do"

* Borrar todas las observaciones menores al primer caso: 13 de marzo
drop if fecha_resultado < 21987
 
foreach var of varlist total_positivo total_positivo_molecular total_positivo_rapida total_positivo_antigenica total_muestra total_muestra_molecular total_muestra_rapida total_muestra_antigenica total_recuperado total_sintomaticos total_defunciones total_inicio total_inicio_molecular total_inicio_rapida total_inicio_antigenica total_igm total_igg total_igm_igg total_activos {
replace `var' = `var'[_n-1] if `var' ==.
}

recode * (.=0)

br 

save "${regional}/data/data-covid-unir-variables-diario.dta", replace

X

scalar hoy =  c(current_date)

drop if fecha_resultado > `c(current_date)'

recode * (.=0)

br fecha_resultado total_*

x 

do "${provincial}\do\data-covid-unir-variables-grafico-provincias.do"
drop if fecha_resultado < 21987

foreach var of varlist total_positivo* total_positivo_molecular* total_positivo_rapida* total_muestra* total_muestra_molecular* total_muestra_rapida* total_recuperado* total_sintomaticos* total_defunciones* total_inicio*  total_igm* total_igg* total_igm_igg* total_activos* {
replace `var' = `var'[_n-1] if `var' ==.
}
recode * (.=0)

br fecha_resultado total_positivo_1 total_recuperado_1 total_activos_1 total_defunciones_1 total_positivo_2 total_recuperado_2 total_activos_2 total_defunciones_2 total_positivo_3 total_recuperado_3 total_activos_3 total_defunciones_3 total_positivo_4 total_recuperado_4 total_activos_4 total_defunciones_4 total_positivo_5 total_recuperado_5 total_activos_5 total_defunciones_5  total_positivo_6 total_recuperado_6 total_activos_6 total_defunciones_6 total_positivo_7 total_recuperado_7 total_activos_7 total_defunciones_7 total_positivo_8 total_recuperado_8 total_activos_8 total_defunciones_8 total_positivo_9 total_recuperado_9 total_activos_9 total_defunciones_9 total_positivo_10 total_recuperado_10 total_activos_10 total_defunciones_10  total_positivo_11 total_recuperado_11 total_activos_11 total_defunciones_11 total_positivo_12 total_recuperado_12 total_activos_12 total_defunciones_12 total_positivo_13 total_recuperado_13 total_activos_13 total_defunciones_13

br fecha_resultado total_positivo_1   total_positivo_2    total_positivo_3    total_positivo_4   total_positivo_5     total_positivo_6    total_positivo_7    total_positivo_8    total_positivo_9    total_positivo_10 total_positivo_11    total_positivo_12    total_positivo_13

x

do "${distrital}\do\data-covid-unir-variables-grafico-distritos.do"
