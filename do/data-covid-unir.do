********************************************************************************
**************************** DIRESA Cusco **************************************
********************** Dirección de Epidemiología ******************************
****************** Unir la base de datos COVID-19 en Cusco *********************
********************************************************************************

********************************************************************************
* 0. Pasos previos para juntar las bases de datos: Notificación y SISCOVID

/*
- Guardar la base de datos en excel con nombre de "BASE COVID" en la hoja "BD_coronavirus"
 para datos de Notificación y "BASE SISCOVID" en la hoja "Hoja2" para datos de la base de SISCOVID

- Los datos de SISCOVID son para pruebas rapidas y Notificación para pruebas moleculares

- Guardar ambas bases en un solo directorio (el mío es "D:\Johar\7. Work")

- Para trabajar normalmente (sin que haya problemas con que tenemos datos tan grandes que versiones de Stata no cargan). Yo recomiendo usar Stata 16 MP
*/

* Definir el directorio de trabajo actual
global path "D:\Johar\7. Work\covid"
	global base "$path/base"
	global data "$path/data"

set more off, permanent

********************************************************************************
* 1. Base de datos NOTICOVID

* Importar la base de datos de excel
import excel "${base}/BASE NOTICOVID.xlsx", sheet(BD_coronavirus) firstrow clear

* Generar una variable genérica/única de identificación
egen var_id = group(dni)   /* necesaria para hacer el match con la BASE SISCOVID*/
gen var_id_molecular = var_id /*necesaria para identificar a las proebas moleculares*/
destring dni, generate(dni_molecular) force /*recuperar el DNI en formato de número*/

* Seleccionar solo a los que pertencen al departamento Cusco
gen departamento = departamento_residencia
keep if departamento == "CUSCO"
rename provincia_residencia provincia
rename residencia distrito

* Convertir la 'fecha de resultado' en el formato que lea la variable
* Segunda prueba molecular
rename fecha_res1 fecha_molecular_2
split fecha_molecular_2, parse(-) destring
rename (fecha_molecular_2?) (day2 month2 year2)
gen fecha_2_molecular = daily(fecha_molecular_2, "DMY")
format fecha_2_molecular %td

* Primera prueba molecular
split fecha_res, parse(-) destring
rename (fecha_res?) (dayl monthl yearl)
gen fecha_resultado = daily(fecha_res, "DMY")
format fecha_resultado %td
gen fecha_molecular = fecha_resultado
format fecha_molecular %td

* Fecha de inicio de síntoma
split fecha_ini, parse(-) destring 
rename (fecha_ini?) (day month year)
gen fecha_inicio = daily(fecha_ini, "DMY")
format fecha_inicio %td

* Indicador de positivos con prueba moleculares
gen positivo_molecular=.
replace positivo_molecular = 1 if resultado == "POSITIVO"
replace positivo_molecular = 0 if resultado == "NEGATIVO"
tab positivo_molecular

* Mantenemos sólo con pruebas moleculares (no tomando en cuenta las rápidas)
keep if positivo_molecular == 1 | positivo_molecular == 0

save "${data}/data_noticovid.dta", replace

********************************************************************************
* 2. Base de datos SISCOVID
import excel "${base}\BASE SISCOVID.xlsx", sheet(Hoja1) firstrow clear

* Generar la variable de identificación
rename nro_docume dni
egen var_id = group(dni)
destring dni, generate(dni_rapida) force
gen var_id_rapida = var_id

* Seleccionar solo a los que pertencen al departamento Cusco y a los migrantes
gen departamento = departamen
* En caso quisiera borrar los de los demás departamentos:
* keep if region == "CUSCO"

* Convertir la 'fecha de resultado' en el formato que lea la variable
rename fecha_prue fecha_resultado 
format fecha_resultado %d
gen fecha_rapida = fecha_resultado
format fecha_rapida %td

* Fecha de inicio de síntoma 
split fecha_inic, parse(-) destring 
rename (fecha_inic?) (year month day)
gen fecha_inicio = daily(fecha_ini, "YMD")
format fecha_inicio %td

* Indentificador de prueba rápida
gen positivo_rapida=.
replace positivo_rapida = 1 if validos == 2
replace positivo_rapida = 0 if (validos == 1 & resultado1 == "No Reactivo")
tab positivo_rapida

* Otras variables relevantes para que sean similares a la base NOTICOVID
rename id_ubigeo ubigeo
destring ubigeo, force replace
destring edad, replace
rename comun_sexo sexo

save "${data}/data_siscovid.dta", replace

********************************************************************************
* 3. Base de datos SINADEF (defunciones por COVID-19)
* OJO: Previamente tienes que cambiar el formato de fecha, un trabajo a mano

import excel "${base}\defunciones.xlsx", sheet("DATA") firstrow clear

* Generar la variable de identificación
rename DOCUMENTO dni
egen var_id = group(dni)

* Seleccionar solo a los que pertencen al departamento Cusco
rename DEPARTAMENTO departamento
rename PROVINCIA provincia
rename DISTRITO distrito

* Convertir la 'fecha de resultado' en el formato que lea la variable
gen fecha_resultado = mdy(MES,DIA,AÑO)
format fecha_resultado %td

* Indicador de defunciones por COVID
gen defuncion =.
replace defuncion = 1
replace defuncion = 0 if defuncion == .

* Otras variables relevantes para que sean similares a la base NOTICOVID y SISCOVID
rename SEXO sexo
rename EDAD edad

save "${data}/data_defunciones.dta", replace

********************************************************************************
* 4. Juntar ambas bases de datos Notificación y SISCOVID 
use "${data}\data_siscovid.dta", clear
append using "${data}\data_noticovid.dta", force
append using "${data}\data_defunciones.dta", force

save "${data}\data-covid-unir.dta", replace