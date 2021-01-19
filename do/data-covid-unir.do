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

- Guardar ambas bases en un solo directorio (el mío es "D:\Johar\7. Work\covid")

- Para trabajar normalmente (sin que haya problemas con que tenemos datos tan grandes que versiones de Stata no cargan). Yo recomiendo usar Stata 16 MP
*/

* Definir el directorio de trabajo actual
global path "C:\johar\covid-cusco"
	global base "$path/base"
	global data "$path/data"

********************************************************************************
* 1. Base de datos NOTICOVID

* Importar la base de datos de excel
import excel "${base}/BASE NOTICOVID.xlsx", sheet(BASE) firstrow clear

* Añadir un cero al ubigeo 
replace ubigeo = "0" + ubigeo 

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

* Primera prueba molecular
rename fecha_res fecha_molecular_1

split fecha_molecular_1, parse(-) destring
rename (fecha_molecular_1?) (dayl monthl yearl)
gen fecha_resultado = daily(fecha_molecular_1, "DMY")
format fecha_resultado %td

* Fecha oficial
gen fecha_molecular = fecha_resultado
format fecha_molecular %td

* Fecha para identificar 
gen fecha_1_molecular = fecha_resultado
format fecha_1_molecular %td 

* Resultado de la prueba (prueba oficial o primera prueba)
gen resultado_1_molecular = resultado

gen positivo_1_molecular = .
replace positivo_1_molecular = 1 if resultado == "POSITIVO"
replace positivo_1_molecular = 0 if resultado == "NEGATIVO"

* Segunda prueba molecular
rename fecha_res1 fecha_molecular_2
split fecha_molecular_2, parse(-) destring
rename (fecha_molecular_2?) (day2 month2 year2)
gen fecha_2_molecular = daily(fecha_molecular_2, "DMY")
format fecha_2_molecular %td

gen resultado_2_molecular = resultado1

gen positivo_2_molecular = .
replace positivo_2_molecular = 1 if resultado1 == "POSITIVO"
replace positivo_2_molecular = 0 if resultado1 == "NEGATIVO"


* Fecha de primera prueba rapida
rename fecha_res_rap fecha_rapida_1
split fecha_rapida_1, parse(-) destring 
rename (fecha_rapida_1?) (day3 month3 year3)
gen fecha_1_rapida_noti = daily(fecha_rapida_1, "DMY")
format fecha_1_rapida_noti %td

gen resultado_1_rapida_noti = resultado_rap 

gen positivo_1_rapida_noti = .
replace positivo_1_rapida_noti = 1 if resultado_rap == "Ig G POSITIVO" | resultado_rap == "Ig M  e Ig G POSITIVO" | resultado_rap == "Ig M POSITIVO"
replace positivo_1_rapida_noti = 0 if resultado_rap == "NEGATIVO"


* Fecha de segunda prueba rapida
rename fecha_res_rap1 fecha_rapida_2
split fecha_rapida_2, parse(-) destring 
rename (fecha_rapida_2?) (day4 month4 year4)
gen fecha_2_rapida_noti = daily(fecha_rapida_2, "DMY")
format fecha_2_rapida_noti %td

gen resultado_2_rapida_noti = resultado_rap1

gen positivo_2_rapida_noti = .
replace positivo_2_rapida_noti = 1 if resultado_rap1 == "Ig G POSITIVO" | resultado_rap1 == "Ig M  e Ig G POSITIVO" | resultado_rap1 == "Ig M POSITIVO"
replace positivo_2_rapida_noti = 0 if resultado_rap1 == "NEGATIVO"

************

* Fecha de inicio de síntoma
split fecha_ini, parse(-) destring 
rename (fecha_ini?) (day month year)
gen fecha_inicio = daily(fecha_ini, "DMY")
format fecha_inicio %td

* Indicador de positivos con prueba moleculares
gen positivo_molecular=.
replace positivo_molecular = 1 if resultado == "POSITIVO" & (muestra == "ASPIRADO TRAQUEAL O NASAL FARINGEO" | muestra == "HISOPADO NASAL Y FARINGEO") & (prueba != "PRUEBA ANTIGÉNICA" & prueba != "PRUEBA SEROLÓGICA")
replace positivo_molecular = 0 if resultado == "NEGATIVO" & (muestra == "ASPIRADO TRAQUEAL O NASAL FARINGEO" | muestra == "HISOPADO NASAL Y FARINGEO") & (prueba != "PRUEBA ANTIGÉNICA" & prueba != "PRUEBA SEROLÓGICA")
tab positivo_molecular

gen prueba_molecular =.
replace prueba_molecular = 1 if positivo_molecular == 1 | positivo_molecular == 0
replace prueba_molecular = 0 if prueba_molecular ==.
label variable prueba_molecular "Prueba molecular"
label define prueba_molecular 1 "Si molecular" 0 "No molecular"
label values prueba_molecular prueba_molecular
tab prueba_molecular 

* Indicador de positivos con prueba antigenicas
gen positivo_antigenicas=.
replace positivo_antigenicas = 1 if resultado == "POSITIVO" & (muestra == "ASPIRADO TRAQUEAL O NASAL FARINGEO" | muestra == "HISOPADO NASAL Y FARINGEO" | muestra == "LAVADO BRONCOALVEOLAR") & (prueba == "PRUEBA ANTIGÉNICA")
replace positivo_antigenicas = 0 if resultado == "NEGATIVO" & (muestra == "ASPIRADO TRAQUEAL O NASAL FARINGEO" | muestra == "HISOPADO NASAL Y FARINGEO"  | muestra == "LAVADO BRONCOALVEOLAR") & (prueba == "PRUEBA ANTIGÉNICA")
tab positivo_antigenicas

gen prueba_antigenicas=.
replace prueba_antigenicas = 1 if positivo_antigenicas == 1 | positivo_antigenicas == 0
replace prueba_antigenicas = 0 if prueba_antigenicas == .
label variable prueba_antigenicas "Prueba antigenicas"
label define prueba_antigenicas 1 "Si antigenicas" 0 "No antigenicas"
label values prueba_antigenicas prueba_antigenicas
tab prueba_antigenicas 

* Mantenemos sólo con pruebas moleculares (no tomando en cuenta las rápidas)
*keep if positivo_molecular == 1 | positivo_molecular == 0

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

* Identificador de fecha rápida para comparar
gen fecha_rapida = fecha_resultado
format fecha_rapida %td

* Fecha para identificar los duplicados 
gen fecha_siscovid = fecha_resultado
format fecha_siscovid %td

* Positivo para identificar los duplicados 
gen positivo_rapida_siscovid = .
replace positivo_rapida_siscovid = 1 if resultado == "IgG POSITIVO" | resultado == "IgG Reactivo" | resultado == "IgM POSITIVO" | resultado == "IgM Reactivo" | resultado == "IgM e IgG POSITIVO" | resultado == "IgM e IgG Reactivo" | resultado == "POSITIVO" | (resultado == "Indeterminado" & (resultado1 == "IgG Reactivo"| resultado1 == "IgM Reactivo" | resultado1 == "IgM e IgG Reactivo"))
replace positivo_rapida_siscovid = 0 if resultado == "NEGATIVO" | resultado == "No Reactivo" | (resultado1 == "Indeterminado" & (resultado1 == "Indeterminado" | resultado1 == "No reactivo"))


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
destring edad, replace
rename comun_sexo sexo

* IgM IgG y mixto
rename resultado1 tipo_anticuerpo

gen prueba_rapida =.
replace prueba_rapida = 1 if  (validos == 2 | validos == 1) & tipo_anticuerpo != ""
replace prueba_rapida = 0 if prueba_rapida ==.
label variable prueba_rapida "Prueba rápida"
label define prueba_rapida 1 "Si rápida" 0 "No rápida"
label values prueba_rapida prueba_rapida 
tab prueba_rapida

save "${data}/data_siscovid.dta", replace

********************************************************************************
* 3. Base de datos SINADEF (defunciones por COVID-19)
* OJO: Previamente tienes que cambiar el formato de fecha, un trabajo a mano
import excel "${base}\BASE SINADEF 2020.xlsx", sheet("DATA") firstrow clear

save "${data}/data_sinadef.dta", replace

import excel "${base}\BASE SINADEF.xlsx", sheet("DATA") firstrow clear

append using "${data}/data_sinadef.dta", force

* Generar la variable de identificación
rename DOCUMENTO dni
egen var_id = group(dni)

* Seleccionar solo a los que pertencen al departamento Cusco
rename DEPARTAMENTO departamento

* Donde han fallecido
rename PROVINCIA provincia
rename DISTRITO distrito

* Para identificar los migrantes
rename PROVINCIADOMICILIO provincia_vivienda
gen provincia_origen = .
replace provincia_origen = 1 if provincia_vivienda == "ACOMAYO"
replace provincia_origen = 2 if provincia_vivienda == "ANTA"
replace provincia_origen = 3 if provincia_vivienda == "CALCA"
replace provincia_origen = 4 if provincia_vivienda == "CANAS"
replace provincia_origen = 5 if provincia_vivienda == "CANCHIS"
replace provincia_origen = 6 if provincia_vivienda == "CHUMBIVILCAS"
replace provincia_origen = 7 if provincia_vivienda == "CUSCO"
replace provincia_origen = 8 if provincia_vivienda == "ESPINAR"
replace provincia_origen = 9 if provincia_vivienda == "LA CONVENCION"
replace provincia_origen = 10 if provincia_vivienda == "PARURO"
replace provincia_origen = 11 if provincia_vivienda == "PAUCARTAMBO"
replace provincia_origen = 12 if provincia_vivienda == "QUISPICANCHI"
replace provincia_origen = 13 if provincia_vivienda == "URUBAMBA"
replace provincia_origen = 14 if  provincia_origen == . 
label variable provincia_origen "provincia de origen"
label define provincia_reside 1 "ACOMAYO" 2 "ANTA" 3 "CALCA" 4 "CANAS" 5 "CANCHIS" 6 "CHUMBIVILCAS" 7 "CUSCO" 8 "ESPINAR" 9 "LA CONVENCION" 10 "PARURO" 11 "PAUCARTAMBO" 12 "QUISPICANCHI" 13 "URUBAMBA" 14 "MIGRATES"
label values provincia_origen provincia_origen provincia_origen provincia_origen provincia_origen provincia_origen provincia_origen provincia_origen provincia_origen provincia_origen provincia_origen provincia_origen provincia_origen provincia_origen 
tab  provincia_origen

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
destring edad, replace

save "${data}/data_sinadef.dta", replace

********************************************************************************
* 4. Juntar ambas bases de datos Notificación, SISCOVID y SINADEF 
use "${data}\data_siscovid.dta", clear
append using "${data}\data_noticovid.dta", force
append using "${data}\data_sinadef.dta", force

* 5. Tipo de prueba

gen tipo_prueba =.
replace tipo_prueba = 1 if prueba_molecular==1
replace tipo_prueba = 2 if prueba_rapida==1
replace tipo_prueba = 3 if prueba_antigenica==1
label variable tipo_prueba "Tipo de prueba"
label define tipo_prueba 1 "Prueba molecular" 2 "Prueba rápida" 3 "Prueba antigenica"
label values tipo_prueba tipo_prueba tipo_prueba
tab tipo_prueba

keep if tipo_prueba == 1 | tipo_prueba == 2 | tipo_prueba == 3

save "${data}\data-covid-unir.dta", replace