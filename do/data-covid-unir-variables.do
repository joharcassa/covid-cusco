********************************************************************************
**************************** DIRESA Cusco **************************************
********************** Dirección de Epidemiología ******************************
****************** Crear variables COVID-19 en Cusco ***************************
********************************************************************************

********************************************************************************
* 0. Preliminarios

* Definir el directorio de trabajo actual
global path "C:\johar\covid-cusco"
	global data "$path/data"

use "${data}\data-covid-unir.dta", clear

********************************************************************************
* 1. Tipo de prueba

gen tipo_prueba =.
replace tipo_prueba = 1 if prueba_molecular==1
replace tipo_prueba = 0 if prueba_rapida==1
label variable tipo_prueba "Tipo de prueba"
label define tipo_prueba 1 "Prueba molecular" 0 "Prueba rápida"
label values tipo_prueba tipo_prueba
tab tipo_prueba

********************************************************************************
* 2. Fechas 

* Fecha de inicio de sintoma
* Sum fecha_inicio

* Fecha de resultado
*sum fecha_resultado

* Fecha de recuperacion de los positivos
gen fecha_recuperado =.
replace fecha_recuperado = fecha_resultado + 14 if positivo_molecular == 1 | (positivo_rapida==1 & tipo_anticuerpo == "IgM Reactivo")
replace fecha_recuperado = fecha_resultado + 7 if (positivo_rapida == 1 & tipo_anticuerpo== "IgG Reactivo") | (positivo_rapida == 1 & tipo_anticuerpo== "IgM e IgG Reactivo")
format fecha_recuperado %td

* Fecha de estado de activo
gen fecha_activo = .
replace fecha_activo = fecha_resultado - fecha_recuperado
format fecha_activo %td

********************************************************************************
* 3. Variables demográfias

* Edad
*sum edad 

* Grupos etários
gen grupos_etarios = .
replace grupos_etarios = 1 if edad >= 0 & edad <=11
replace grupos_etarios = 2 if edad >= 12 & edad <= 17
replace grupos_etarios = 3 if edad >= 18 & edad <= 29
replace grupos_etarios = 4 if edad >= 30 & edad <= 59
replace grupos_etarios = 5 if edad >= 60 
label variable grupos_etarios "Grupos etáreos"
label define grupos_etarios 1 "Niños" 2 "Adolecente" 3 "Joven" 4 "Adulto" 5 "Adulto mayor"
label values grupos_etarios grupos_etarios grupos_etarios grupos_etarios grupos_etarios

********************************************************************************
* 4. Variables de salud

* Personal de salud con o sin COVID-19
gen personal_salud =.
replace personal_salud = 1 if ocupacion == "TRABAJADOR DE SALUD" | ocupacion == "TRABAJADOR DE SALUD EN LABORATORIO" | personal_s == "SI" | comun_prof == "Biólogo" | comun_prof == "Enfermero (a)" | comun_prof == "Enfermero(a)" | comun_prof=="Medico" | comun_prof == "Obstetra" | comun_prof== "Otros" | comun_prof== "Tecnólogo Medico" | comun_prof=="Técnico de Enfermería" | comun_prof == "Técnico de laboratorio"
replace personal_salud = 0 if personal_salud == .
label variable personal_salud "Personal de salud"
label define personal_salud 0 "No" 1 "Si"
label values personal_salud personal_salud

* Sintomáticos
gen sintomatico_molecular =.
replace sintomatico_molecular = 1 if (asintomatico == "" & prueba_molecular == 1) 
replace sintomatico_molecular = 0 if (asintomatico == "SI" & prueba_molecular==1)
label variable sintomatico_molecular "Tiene sintoma molecular"
label define sintomatico_molecular 0 "No" 1 "Si"
label values sintomatico_molecular sintomatico_molecular


gen sintomatico_rapida =.
replace sintomatico_rapida = 1 if (tiene_sint == "SI" & prueba_rapida ==1)
replace sintomatico_rapida = 0 if (tiene_sint == "NO" & prueba_rapida ==1)
label variable sintomatico_rapida "Tiene sintoma rapida"
label define sintomatico_rapida 0 "No" 1 "Si"
label values sintomatico_rapida sintomatico_rapida

* Sintomatico general (PCR y PR)
gen sintomatico =.
replace sintomatico = 1 if (sintomatico_molecular == 1 & positivo_molecular == 1) | (sintomatico_rapida == 1 & positivo_rapida == 1)
replace sintomatico = 0 if (sintomatico_molecular == 1 & positivo_molecular == 0) | (sintomatico_rapida == 1 & positivo_rapida == 0)
label variable sintomatico "Tiene sintoma"
label define sintomatico 0 "No" 1 "Si"
label values sintomatico sintomatico
tab sintomatico

* Preliminarios para calcular los tipos de síntomas 
destring fiebre_esc, force replace
destring malestar_g, force replace
destring tos, force replace
destring dolor_garg, force replace
destring congestion, force replace
destring dificultad, force replace
destring diarrea, force replace
destring nauseas_vo, force replace
destring presenta_c, force replace
destring irritabili, force replace
destring dolor_pre1, force replace
destring dolor_pre2, force replace
destring dolor_pre3, force replace
destring dolor_pre4, force replace
destring dolor_pre5, force replace

gen otros_sintom = .
replace otros_sintom = 1 if otros_sintomas != "" 

* Sintomas
gen sintomas = .
replace sintomas = 1 if fiebre == 1 | fiebre_esc == 1
replace sintomas = 2 if malestar == 1 | malestar_g == 1
replace sintomas = 3 if tos == 1
replace sintomas = 4 if garganta == 1 | dolor_garg ==1
replace sintomas = 5 if congestion == 1
replace sintomas = 6 if respiratoria == 1 | dificultad == 1
replace sintomas = 7 if diarrea == 1
replace sintomas = 8 if nauseas == 1 | nauseas_vo == 1
replace sintomas = 9 if cefalea == 1 | presenta_c == 1
replace sintomas = 10 if irritabilidad == 1 | irritabili == 1
replace sintomas = 11 if muscular == 1 | dolor_pre1 == 1
replace sintomas = 12 if abdominal == 1 | dolor_pre2 ==1
replace sintomas = 13 if pecho == 1 | dolor_pre3 ==1
replace sintomas = 14 if articulaciones == 1 | dolor_pre4 ==1
replace sintomas = 15 if otros_sintom == 1 | dolor_pre5 ==1
label variable sintomas "Sintomas"
label define sintomas 1 "Fiebre" 2 "Malestar general" 3 "Tos" 4 "Dolor de garganta" 5 "Congestion" 6 "Dificultad respiratoria" 7 "Diarrea" 8 "Nauseas" 9 "Cefalea" 10 "Irritabilidad" 11 "Dolor muscular" 12 "Dolor abdominal" 13 "Dolor de pecho" 14 "Dolor de articulaciones" 15 "Otros síntomas"
label values sintomas sintomas sintomas sintomas sintomas sintomas sintomas sintomas sintomas sintomas sintomas sintomas sintomas sintomas sintomas
tab sintomas if (positivo_molecular == 1 | positivo_rapida == 1) & sintomatico == 1

/*
* Comorbilidad
destring riesgo_per, replace force
destring riesgo_obe, replace force
destring riesgo_enf, replace force
destring ariesgo_di, replace force
destring riesgo_hip, replace force
destring riesgo_en1, replace force
destring riesgo_can, replace force
destring riesgo_emb, replace force
destring riesgo_may, replace force
destring riesgo_nin, replace force
destring riesgo_en2, replace force
destring riesgo_asm, replace force
destring riesgo_ren, replace force

gen otros_comorb = .
replace otros_comorb = 1 if riesgo != "" 
replace otros_comorb = 0 if riesgo == ""
tab otros_comorb

* Comorbilidad
gen comorbilidad =.
replace comorbilidad = 1 if embarazo == 1 | riesgo_emb == 1
replace comorbilidad = 2 if cardiovascular == 1 | riesgo_enf == 1 | riesgo_hip == 1
replace comorbilidad = 3 if diabetes == 1 | ariesgo_di == 1
replace comorbilidad = 4 if inmunodeficiencia == 1 | riesgo_en2 == 1
replace comorbilidad = 5 if renal == 1 | riesgo_ren == 1
replace comorbilidad = 6 if pulmonar == 1 | riesgo_en1 == 1 | riesgo_asm == 1
replace comorbilidad = 7 if cancer == 1 | riesgo_can == 1
replace comorbilidad = 8 if otros_comorb == 1 | hepatica == 1 | neurologica == 1 | hepatico == 1 | riesgo_per == 1 | riesgo_may == 1 | riesgo_obe == 1
label variable comorbilidad "Comorbilidad"
label define comorbilidad 1 "Embarazo" 2 "Cardiovascular" 3 "Diabetes" 4 "Inmunodeficiencia" 5 "Renal" 6 "Pulmonar" 7 "Cancer" 8 "Otros"
label values comorbilidad comorbilidad comorbilidad comorbilidad comorbilidad comorbilidad comorbilidad comorbilidad
tab comorbilidad if resultado == "POSITIVO" | validos == 2
*/

********************************************************************************
* 5. Variables geográficas

* Provincia
gen provincia_residencia =.
replace provincia_residencia = 1 if provincia == "ACOMAYO" | provincia== "Acomayo"
replace provincia_residencia = 2 if provincia == "ANTA" | provincia == "Anta"
replace provincia_residencia = 3 if provincia == "CALCA" | provincia == "Calca"
replace provincia_residencia = 4 if provincia == "CANAS" | provincia == "Canas"
replace provincia_residencia = 5 if provincia == "CANCHIS" | provincia == "Canchis"
replace provincia_residencia = 6 if provincia == "CHUMBIVILCAS" | provincia == "Chumbivilcas"
replace provincia_residencia = 7 if provincia == "CUSCO" | provincia == "Cusco"
replace provincia_residencia = 8 if provincia == "ESPINAR" | provincia == "Espinar"
replace provincia_residencia = 9 if provincia == "LA CONVENCION" | provincia == "LA CONVENCIÓN" | provincia == "La Convención"
replace provincia_residencia = 10 if provincia == "PARURO" | provincia == "Paruro"
replace provincia_residencia = 11 if provincia == "PAUCARTAMBO" | provincia == "Paucartambo"
replace provincia_residencia = 12 if provincia == "QUISPICANCHI" | provincia == "Quispicanchis"
replace provincia_residencia = 13 if provincia == "URUBAMBA" | provincia == "Urubamba"
label variable provincia_residencia "provincia de residencia"
label define provincia_residencia 1 "ACOMAYO" 2 "ANTA" 3 "CALCA" 4 "CANAS" 5 "CANCHIS" 6 "CHUMBIVILCAS" 7 "CUSCO" 8 "ESPINAR" 9 "LA CONVENCION" 10 "PARURO" 11 "PAUCARTAMBO" 12 "QUISPICANCHI" 13 "URUBAMBA"
label values provincia_residencia provincia_residencia provincia_residencia provincia_residencia provincia_residencia provincia_residencia provincia_residencia provincia_residencia provincia_residencia provincia_residencia provincia_residencia provincia_residencia provincia_residencia 
tab provincia_residencia if positivo_molecular == 1 | positivo_rapida == 1

* Distrito de cada uno de las 13 provincias

gen acomayo =.
replace acomayo = 1 if distrito == "ACOMAYO" | distrito == "Acomayo"
replace acomayo = 2 if distrito == "ACOPIA" | distrito == "Acopia"
replace acomayo = 3 if distrito == "ACOS" | distrito == "Acos"
replace acomayo = 4 if distrito == "MOSOC LLACTA" | distrito == "Mosoc Llacta"
replace acomayo = 5 if distrito == "POMACANCHI"| distrito == "Pomacanchi"
replace acomayo = 6 if distrito == "RONDOCAN" | distrito == "Rondocan"
replace acomayo = 7 if distrito == "SANGARARA" | distrito == "Sangarara"
label variable acomayo "ACOMAYO"
label define acomayo 1	"ACOMAYO" 2	"ACOPIA" 3	"ACOS" 4	"MOSOC LLACTA" 5	"POMACANCHI" 6	"RONDOCAN" 7	"SANGARARA"
label values acomayo acomayo acomayo acomayo acomayo acomayo acomayo
tab acomayo if positivo_molecular == 1 | positivo_rapida == 1

gen anta = .
replace anta = 1 if distrito == "ANCAHUASI" | distrito == "Ancahuasi"
replace anta = 2 if distrito == "ANTA" | distrito == "Anta"
replace anta = 3 if distrito == "CACHIMAYO" | distrito == "Cachimayo"
replace anta = 4 if distrito == "CHINCHAYPUJIO" | distrito == "Chinchaypujio"
replace anta = 5 if distrito == "HUAROCONDO" | distrito == "Huarocondo"
replace anta = 6 if distrito == "LIMATAMBO" | distrito == "Limatambo"
replace anta = 7 if distrito == "MOLLEPATA" | distrito == "Mollepata"
replace anta = 8 if distrito == "PUCYURA" | distrito == "Pucyura"
replace anta = 9 if distrito == "ZURITE" | distrito == "Zurite"
label variable anta "ANTA"
label define anta 1	"ANCAHUASI" 2 "ANTA" 3 "CACHIMAYO" 4 "CHINCHAYPUJIO" 5	"HUAROCONDO" 6	"LIMATAMBO" 7	"MOLLEPATA" 8 "PUCYURA ANTA" 9	"ZURITE"
label values anta anta anta anta anta anta anta anta anta
tab anta if positivo_molecular == 1 | positivo_rapida == 1

gen calca =.
replace calca = 1 if distrito == "CALCA" | distrito == "Calca"
replace calca = 2 if distrito == "COYA" | distrito == "Coya"
replace calca = 3 if distrito == "LAMAY" | distrito == "Lamay"
replace calca = 4 if distrito == "LARES" | distrito == "Lares"
replace calca = 5 if distrito == "PISAC" | distrito == "Pisac"
replace calca = 6 if distrito == "SAN SALVADOR" | distrito == "San Salvador"
replace calca = 7 if distrito == "TARAY" | distrito == "Taray"
replace calca = 8 if distrito == "YANATILE" | distrito == "Yanatile"
label variable calca "CALCA"
label define calca 1 "CALCA" 2 "COYA" 3	"LAMAY" 4 "LARES" 5	"PISAC" 6 "SAN SALVADOR" 7	"TARAY" 8	"YANATILE"
label values calca calca calca calca calca calca calca calca
tab calca if positivo_molecular == 1 | positivo_rapida == 1

gen canas =.
replace canas = 1 if distrito == "CHECCA" | distrito == "Checca"
replace canas = 2 if distrito == "KUNTURKANKI" | distrito == "Kunturkanki"
replace canas = 3 if distrito == "LANGUI" | distrito == "Langui"
replace canas = 4 if distrito == "LAYO" | distrito == "Layo"
replace canas = 5 if distrito == "PAMPAMARCA" | distrito == "Pampamarca"
replace canas = 6 if distrito == "QUEHUE" | distrito == "Quehue"
replace canas = 7 if distrito == "TUPAC AMARU" | distrito == "Tupac Amaru"
replace canas = 8 if distrito == "YANAOCA" | distrito == "Yanaoca"
label variable canas "CANAS"
label define canas 1	"CHECCA" 2	"KUNTURKANKI" 3	"LANGUI" 4	"LAYO" 5	"PAMPAMARCA" 6	"QUEHUE" 7	"TUPAC AMARU" 8	"YANAOCA"
label values  canas  canas  canas  canas  canas  canas  canas  canas 
tab canas if positivo_molecular == 1 | positivo_rapida == 1

gen canchis =.
replace canchis = 1 if distrito == "CHECACUPE" | distrito == "Checacupe"
replace canchis = 2 if distrito == "COMBAPATA" | distrito == "Combapata"
replace canchis = 3 if distrito == "MARANGANI" | distrito == "Marangani"
replace canchis = 4 if distrito == "PITUMARCA" | distrito == "Pitumarca"
replace canchis = 5 if distrito == "SAN PABLO" | distrito == "San Pablo"
replace canchis = 6 if distrito == "SAN PEDRO" | distrito == "San Pedro"
replace canchis = 7 if distrito == "SICUANI" | distrito == "Sicuani"
replace canchis = 8 if distrito == "TINTA" | distrito == "Tinta"
label variable canchis "CANCHIS"
label define canchis 1	"CHECACUPE" 2	"COMBAPATA" 3	"MARANGANI" 4	"PITUMARCA" 5	"SAN PABLO" 6	"SAN PEDRO" 7	"SICUANI" 8	"TINTA"
label values canchis canchis canchis canchis canchis canchis canchis canchis 
tab canchis if positivo_molecular == 1 | positivo_rapida == 1

gen chumbivilcas = .
replace chumbivilcas = 1 if distrito == "CAPACMARCA" | distrito == "Capacmarca" 
replace chumbivilcas = 2 if distrito == "CHAMACA" | distrito == "Chamaca" 
replace chumbivilcas = 3 if distrito == "COLQUEMARCA" | distrito == "Colquemarca" 
replace chumbivilcas = 4 if distrito == "LIVITACA" | distrito == "Livitaca" 
replace chumbivilcas = 5 if distrito == "LLUSCO" | distrito == "Llusco" 
replace chumbivilcas = 6 if distrito == "QUIÑOTA" | distrito == "Quiñota" 
replace chumbivilcas = 7 if distrito == "SANTO TOMAS" | distrito == "Santo Tomas" 
replace chumbivilcas = 8 if distrito == "VELILLE" | distrito == "Velille"
label variable chumbivilcas "CHUMBIVILCAS"
label define chumbivilcas 1	"CAPACMARCA" 2	"CHAMACA" 3	"COLQUEMARCA" 4	"LIVITACA" 5	"LLUSCO" 6	"QUIÑOTA" 7	"SANTO TOMAS" 8	"VELILLE"
label values  chumbivilcas chumbivilcas chumbivilcas chumbivilcas chumbivilcas chumbivilcas chumbivilcas chumbivilcas
tab chumbivilcas if positivo_molecular == 1 | positivo_rapida == 1

gen cusco =.
replace cusco = 1 if distrito == "CCORCA" | distrito == "Ccorca" 
replace cusco = 2 if distrito == "CUSCO" | distrito == "Cusco" 
replace cusco = 3 if distrito == "POROY" | distrito == "Poroy" 
replace cusco = 4 if distrito == "SAN JERONIMO" | distrito == "SAN JERÓNIMO" | distrito == "San Jeronimo" | distrito == "San Jerónimo"
replace cusco = 5 if distrito == "SAN SEBASTIAN" | distrito == "San Sebastian" 
replace cusco = 6 if distrito == "SANTIAGO" | distrito == "Santiago" 
replace cusco = 7 if distrito == "SAYLLA" | distrito == "Saylla" 
replace cusco = 8 if distrito == "WANCHAQ" | distrito == "Wanchaq" 
label variable cusco "CUSCO"
label define cusco 1	"CCORCA" 2	"CUSCO" 3	"POROY" 4	"SAN JERONIMO" 5	"SAN SEBASTIAN" 6	"SANTIAGO" 7	"SAYLLA" 8	"WANCHAQ"
label values cusco  cusco  cusco  cusco  cusco  cusco  cusco  cusco  
tab cusco if positivo_molecular == 1 | positivo_rapida == 1

gen espinar =.
replace espinar = 1 if distrito == "ALTO PICHIGUA" | distrito == "Alto Pichigua" 
replace espinar = 2 if distrito == "CONDOROMA" | distrito == "Condoroma" 
replace espinar = 3 if distrito == "COPORAQUE" | distrito == "Coporaque" 
replace espinar = 4 if distrito == "ESPINAR" | distrito == "Espinar" 
replace espinar = 5 if distrito == "OCORURO" | distrito == "Ocoruro" 
replace espinar = 6 if distrito == "PALLPATA" | distrito == "Pallpata" 
replace espinar = 7 if distrito == "PICHIGUA" | distrito == "Pichigua" 
replace espinar = 8 if distrito == "SUYCKUTAMBO" | distrito == "Suyckutambo" 
label variable espinar "ESPINAR"
label define espinar 1	"ALTO PICHIGUA" 2	"CONDOROMA" 3	"COPORAQUE" 4	"ESPINAR" 5	"OCORURO" 6	"PALLPATA" 7	"PICHIGUA" 8	"SUYCKUTAMBO"
label values  espinar espinar espinar espinar espinar espinar espinar espinar
tab espinar if positivo_molecular == 1 | positivo_rapida == 1

gen laconvencion=.
replace laconvencion = 1 if distrito == "ECHARATE" | distrito == "Echarate" 
replace laconvencion = 2 if distrito == "HUAYOPATA" | distrito == "Huayopata"
replace laconvencion = 3 if distrito == "INKAWASI" | distrito == "Inkawasi"
replace laconvencion = 4 if distrito == "KIMBIRI" | distrito == "Kimbiri"
replace laconvencion = 5 if distrito == "MARANURA" | distrito == "Maranura"
replace laconvencion = 6 if distrito == "MEGANTONI" | distrito == "Megantoni"
replace laconvencion = 7 if distrito == "OCOBAMBA" | distrito == "Ocobamba"
replace laconvencion = 8 if distrito == "PICHARI" | distrito == "Pichari"
replace laconvencion = 9 if distrito == "QUELLOUNO" | distrito == "Quellouno"
replace laconvencion = 10 if distrito == "SANTA ANA" | distrito == "Santa Ana"
replace laconvencion = 11 if distrito == "SANTA TERESA" | distrito == "Santa Teresa"
replace laconvencion = 12 if distrito == "VILCABAMBA" | distrito == "Vilcabamba"
replace laconvencion = 13 if distrito == "VILLA KINTIARINA" | distrito == "Villa Kintiarina"
replace laconvencion = 14 if distrito == "VILLA VIRGEN" | distrito == "Villa Virgen"
label variable laconvencion "LA CONVENCION"
label define laconvencion 1	"ECHARATE" 2	"HUAYOPATA" 3	"INKAWASI" 4	"KIMBIRI" 5	"MARANURA" 6	"MEGANTONI" 7	"OCOBAMBA" 8	"PICHARI" 9	"QUELLOUNO" 10	"SANTA ANA" 11	"SANTA TERESA" 12	"VILCABAMBA" 13	"VILLA KINTIARINA" 14	"VILLA VIRGEN"
label values  laconvencion laconvencion laconvencion laconvencion laconvencion laconvencion laconvencion laconvencion laconvencion laconvencion laconvencion laconvencion laconvencion laconvencion
tab laconvencion if positivo_molecular == 1 | positivo_rapida == 1

gen paruro =.
replace paruro = 1 if distrito == "ACCHA" | distrito == "Accha" 
replace paruro = 2 if distrito == "CCAPI" | distrito == "Ccapi" 
replace paruro = 3 if distrito == "COLCHA" | distrito == "Colcha" 
replace paruro = 4 if distrito == "HUANOQUITE" | distrito == "Huanoquite" 
replace paruro = 5 if distrito == "OMACHA" | distrito == "Omacha" 
replace paruro = 6 if distrito == "PACCARITAMBO" | distrito == "Paccaritambo" 
replace paruro = 7 if distrito == "PARURO" | distrito == "Paruro" 
replace paruro = 8 if distrito == "PILLPINTO" | distrito == "Pillpinto" 
replace paruro = 9 if distrito == "YAURISQUE" | distrito == "Yaurisque" 
label variable paruro "PARURO"
label define paruro 1 "ACCHA" 2	"CCAPI" 3	"COLCHA" 4	"HUANOQUITE" 5	"OMACHA" 6	"PACCARITAMBO" 7 "PARURO" 8	"PILLPINTO" 9 "YAURISQUE"
label values paruro paruro paruro paruro paruro paruro paruro paruro paruro
tab paruro if positivo_molecular == 1 | positivo_rapida == 1

gen paucartambo =.
replace paucartambo = 1 if distrito == "CAICAY" | distrito == "Caicay" 
replace paucartambo = 2 if distrito == "CHALLABAMBA" | distrito == "Challabamba" 
replace paucartambo = 3 if distrito == "COLQUEPATA" | distrito == "Colquepata" 
replace paucartambo = 4 if distrito == "HUANCARANI" | distrito == "Huancarani" 
replace paucartambo = 5 if distrito == "KOSÑIPATA" | distrito == "Kosñipata" 
replace paucartambo = 6 if distrito == "PAUCARTAMBO" | distrito == "Paucartambo" 
label variable paucartambo "PAUCARTAMBO"
label define paucartambo 1 "CAICAY" 2 "CHALLABAMBA" 3	"COLQUEPATA" 4	"HUANCARANI" 5	"KOSÑIPATA" 6 "PAUCARTAMBO"
label values  paucartambo paucartambo paucartambo paucartambo paucartambo paucartambo
tab paucartambo if positivo_molecular == 1 | positivo_rapida == 1

gen quispicanchi =.
replace quispicanchi = 1 if distrito == "ANDAHUAYLILLAS" | distrito == "Andahuaylillas" 
replace quispicanchi = 2 if distrito == "CAMANTI" | distrito == "Camanti" 
replace quispicanchi = 3 if distrito == "CCARHUAYO" | distrito == "Ccarhuayo" 
replace quispicanchi = 4 if distrito == "CCATCA" | distrito == "Ccatca" 
replace quispicanchi = 5 if distrito == "CUSIPATA" | distrito == "Cusipata" 
replace quispicanchi = 6 if distrito == "HUARO" | distrito == "Huaro" 
replace quispicanchi = 7 if distrito == "LUCRE" | distrito == "Lucre" 
replace quispicanchi = 8 if distrito == "MARCAPATA" | distrito == "Marcapata" 
replace quispicanchi = 9 if distrito == "OCONGATE" | distrito == "Ocongate" 
replace quispicanchi = 10 if distrito == "OROPESA" | distrito == "Oropesa" 
replace quispicanchi = 11 if distrito == "QUIQUIJANA" | distrito == "Quiquijana" 
replace quispicanchi = 12 if distrito == "URCOS" | distrito == "Urcos" 
label variable quispicanchi "QUISPICANCHI"
label define quispicanchi 1	"ANDAHUAYLILLAS" 2	"CAMANTI" 3	"CCARHUAYO" 4	"CCATCA" 5	"CUSIPATA" 6	"HUARO" 7	"LUCRE" 8	"MARCAPATA" 9	"OCONGATE" 10	"OROPESA" 11	"QUIQUIJANA" 12	"URCOS"
label values  quispicanchi quispicanchi quispicanchi quispicanchi quispicanchi quispicanchi quispicanchi quispicanchi quispicanchi quispicanchi quispicanchi quispicanchi
tab quispicanchi if positivo_molecular == 1 | positivo_rapida == 1

gen urubamba =.
replace urubamba = 1 if distrito == "CHINCHERO" | distrito == "Chinchero" 
replace urubamba = 2 if distrito == "HUAYLLABAMBA" | distrito == "Huayllabamba" 
replace urubamba = 3 if distrito == "MACHUPICCHU" | distrito == "Machupicchu" 
replace urubamba = 4 if distrito == "MARAS" | distrito == "Maras" 
replace urubamba = 5 if distrito == "OLLANTAYTAMBO" | distrito == "Ollantaytambo" 
replace urubamba = 6 if distrito == "URUBAMBA" | distrito == "Urubamba" 
replace urubamba = 7 if distrito == "YUCAY" | distrito == "Yucay" 
label variable urubamba "URUBAMBA" 
label define urubamba 1	"CHINCHERO" 2	"HUAYLLABAMBA" 3	"MACHUPICCHU" 4	"MARAS" 5 "OLLANTAYTAMBO" 6	"URUBAMBA" 7	"YUCAY"
label values  urubamba urubamba urubamba urubamba urubamba urubamba urubamba
tab urubamba if positivo_molecular == 1 | positivo_rapida == 1

keep if prueba_molecular == 1 | prueba_rapida == 1 | defuncion == 1

* Mantener las principales variables 
keep tipo_prueba fecha_inicio sintomatico_molecular sintomatico_rapida sintomatico sintomas prueba_molecular prueba_rapida positivo_molecular positivo_rapida tipo_anticuerpo ///
var_id  var_id_molecular var_id_rapida dni dni_molecular dni_rapida  ///
fecha_resultado fecha_molecular fecha_rapida fecha_recuperado fecha_activo ///
 edad sexo grupos_etarios personal_salud ///
 ubigeo departamento provincia_residencia provincia_origen distrito latitud longitud direccion ///
 acomayo anta calca canas canchis chumbivilcas cusco espinar laconvencion paruro paucartambo quispicanchi urubamba ///
 defuncion  

save "${data}/data-covid-unir-variables.dta", replace

keep edad sexo  sintomatico ubigeo latitud longitud sintomas positivo_rapida positivo_molecular tipo_anticuerpo defuncion grupos_etarios tipo_prueba fecha_resultado fecha_recuperado fecha_inicio fecha_activo distrito 

save "${data}/data-covid-unir-variables-brandon.dta", replace

