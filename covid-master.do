********************************************************************************
**************************** DIRESA Cusco **************************************
********************** Dirección de Epidemiología ******************************
***************** Datos de la pandemia por COVID-19 en Cusco ********************
********************************************************************************

********************************************************************************
* 0. Pasos previos para juntar las bases de datos: Notificación y SISCOVID

* Definir el directorio de trabajo actual
global path "D:\Johar\7. Work\covid"
	global base "$path/base"
	global data "$path/data"
	global do "$path/do"
	global regional "$path/regional"
	global provincial "$path/provincial"

set more off, permanent

do "${do}\data-covid-unir.do"
do "${do}\data-covid-unir-variables.do"

do "${regional}\do\data-covid-unir-variables-diario.do"
do "${provincial}\do\data-covid-unir-variables-grafico-provincias.do"