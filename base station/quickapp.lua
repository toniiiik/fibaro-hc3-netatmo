-- Multilevel sensor type have no actions to handle
-- To update multilevel sensor state, update property "value" with integer
-- Eg. self:updateProperty("value", 37.21) 

-- To set unit of the sensor, update property "unit". You can set it on QuickApp initialization
-- Eg. 
-- function QuickApp:onInit()
--     self:updateProperty("unit", "KB")
-- end

-- To update controls you can use method self:updateView(<component ID>, <component property>, <desired value>). Eg:  
-- self:updateView("slider", "value", "55") 
-- self:updateView("button1", "text", "MUTE") 
-- self:updateView("label", "text", "TURNED ON") 

local clientId = ""
local secret = ""
local username = ""
local password = ""
local baseUrl =  "https://api.netatmo.com"
local refresh_s = 5 * 60

local BASE_MODULE="base"
local RAIN_MODULE="NAModule3"
local WIND_MODULE="NAModule2"
local OUTDOOR_MODULE="NAModule1"
local language="en"
local sy={snow='\240\159\140\168',fog='\240\159\140\171',sunny='\226\152\128\239\184\143',partlysunny='\226\155\133\239\184\143',
  partlycloudy='\226\155\133\239\184\143',mostlysunny='\240\159\140\164',mostlycloudy='\240\159\140\165',rain='\240\159\140\167',
  flurries='\226\157\132\239\184\143',cloudy='\226\152\129\239\184\143',tornado='\240\159\140\170',chancerain='\240\159\140\166',
  chancesleet='\240\159\140\168',chancetstorms='\240\159\140\170',chanceflurries='\226\157\132\239\184\143',
  chancesnow='\226\152\131\239\184\143',windy='\240\159\140\172',wind='\240\159\140\172',gail='\240\159\146\168',clear='\226\152\128\239\184\143',
  sleet='\226\155\136',hazy='\240\159\140\165',tstorms='\226\155\136',warning='\226\154\160\239\184\143',ok='\226\156\133',
  temp='\240\159\140\161',humid='\240\159\146\167',noise='\240\159\148\138',co2='\240\159\152\183',arrowup='\226\134\145',
  arrowdn='\226\134\147',arrow_up="\226\172\134\239\184\143",arrow_dn="\226\172\135\239\184\143",arrow_right="\226\158\161\239\184\143",
  arrow_rraise="\226\134\151\239\184\143",arrow_rfall="\226\134\152\239\184\143",gust='\240\159\146\168',dir='\240\159\154\169',
  rainfall='\226\152\148\239\184\143',umbrella='\226\152\130\239\184\143',closed_umbrella='\240\159\140\130',brihi='\240\159\148\134',
  brilo='\240\159\148\133',sun='\226\152\128\239\184\143',heat='\240\159\140\158',cool='\226\157\132\239\184\143',
  refresh="\240\159\148\132",in_envelope="\240\159\147\168",battery="\240\159\148\139",signal="\240\159\147\182",floppy='\240\159\146\190',
  cd="\240\159\146\191",week="\240\157\147\166",month="\240\159\147\134",hour="\240\159\149\144",trackball="\240\159\150\178",
  eye="\240\159\145\129",round_pushpin="\240\159\147\141",sep='\226\142\170',question='\226\157\147',trackball="\240\159\150\178"}

local yellow = 1180
local orange = 1890
local red    = 2250

local langTable={lng=lng,nlng=language,
    en={co2="CO2 level",rain_hr="Last hour",rain_3hr="Last 3 hours",rain_day="Last day",rain_week="Last week",rain_month="Last month",
      uv="UV index",firmware="Firmware ver.",trend_up="up",trend_st="stable",trend_dn="down",update_ok="VD updated",update_er="Update error",
      refresh="Refresh",windDir={N="N",NNE="NNE",NE="NE",ENE="ENE",E="E",ESE="ESE",SE="SE",SSE="SSE",S="S",SSW="SSW",SW="SW",WSW="WSW",
        W="W",WNW="WNW",NW="NW",NNW="NNW"},
      weekdaymap={Sunday="Sunday",Monday="Monday",Tuesday="Tuesday",Wednesday="Wednesday",Thursday="Thursday",Friday="Friday",Saturday="Saturday"},},
    pl={co2="Poziom CO2",rain_hr="Przez godzinę",rain_3hr="Przez 3 godziny",rain_day="Przez dzień",rain_week="Przez tydzień",
      rain_month="Przez miesiąc",uv="Indeks UV",firmware="Wersja oprogram.",trend_up="wzrastać",trend_st="stabilny",trend_dn="spadać",
      update_ok="VD uaktualnione",update_er="Błąd aktualizacji",refresh="Odświerz",windDir={N="N",NNE="NNE",NE="NE",ENE="ENE",E="E",ESE="ESE",
        SE="SE",SSE="SSE",S="S",SSW="SSW",SW="SW",WSW="WSW",W="W",WNW="WNW",NW="NW",NNW="NNW"},
      weekdaymap={Sunday="Niedziela",Monday="Poniedziałek",Tuesday="Wtorek",Wednesday="Środa",Thursday="Czwartek",Friday="Piątek",Saturday="Sobota"},},
    de={co2="CO2 level",rain_hr="Last hour",rain_3hr="Last 3 hours",rain_day="Last day",rain_week="Last week",rain_month="Last month",
      uv="UV index",firmware="Firmware ver.",trend_up="up",trend_st="stable",trend_dn="down",update_ok="VD updated",update_er="Update error",
      refresh="Aktualisierung",windDir={N="N",NNE="NNE",NE="NE",ENE="ENE",E="E",ESE="ESE",SE="SE",SSE="SSE",S="S",SSW="SSW",SW="SW",WSW="WSW",
        W="W",WNW="WNW",NW="NW",NNW="NNW"},
      weekdaymap={Sunday="Sonntag",Monday="Montag",Tuesday="Dienstag",Wednesday="Mittwoch",Thursday="Donnerstag",Friday="Freitag",Saturday="Samstag"},},
    sv={co2="CO2 level",rain_hr="Last hour",rain_3hr="Last 3 hours",rain_day="Last day",rain_week="Last week",rain_month="Last month",
      uv="UV index",firmware="Firmware ver.",trend_up="up",trend_st="stable",trend_dn="down",update_ok="VD updated",update_er="Update error",
      refresh="Refresh",windDir={N="N",NNE="NNE",NE="NE",ENE="ENE",E="E",ESE="ESE",SE="SE",SSE="SSE",S="S",SSW="SSW",SW="SW",WSW="WSW",
        W="W",WNW="WNW",NW="NW",NNW="NNW"},
      weekdaymap={Sunday="S\195\182ndag",Monday="M\195\165ndag",Tuesday="Tisdag",Wednesday="Onsdag",Thursday="Torsdag",Friday="Fredag",Saturday="L\195\182rdag"},},
    pt={co2="CO2 level",rain_hr="Last hour",rain_3hr="Last 3 hours",rain_day="Last day",rain_week="Last week",rain_month="Last month",
      uv="UV index",firmware="Firmware ver.",trend_up="up",trend_st="stable",trend_dn="down",update_ok="VD updated",update_er="Update error",
      refresh="Refresh",windDir={N="N",NNE="NNE",NE="NE",ENE="ENE",E="E",ESE="ESE",SE="SE",SSE="SSE",S="S",SSW="SSW",SW="SW",WSW="WSW",
        W="W",WNW="WNW",NW="NW",NNW="NNW"},
      weekdaymap={Sunday="Domingo",Monday="Segunda-feira",Tuesday="Terça-feira",Wednesday="Quarta-feira",Thursday="Quinta-feira",Friday="Sexta-feira",Saturday="Sabado"},},
    it={co2="Livello di CO2",rain_hr="Ultima ora",rain_3hr="Ultime 3 ore",rain_day="Ultimo giorno",rain_week="Setimana scorsa",
      rain_month="Scorso mese",light="Luminosit\195\160",uv="Indice UV",firmware="versione firmware",trend_up="up",trend_st="stable",
      trend_dn="down",update_ok="VD aggiornato",update_er="Errore di aggiornamento",refresh="Aggiornare",windDir={N="N",NNE="NNE",NE="NE",
        ENE="ENE",E="E",ESE="ESE",SE="SE",SSE="SSE",S="S",SSW="SSO",SW="SO",WSW="OSO",W="O",WNW="ONO",NW="NO",NNW="NNW"},
      weekdaymap={Sunday="Domenica",Monday="Lunedì",Tuesday="Martedì",Wednesday="Mercoledì",Thursday="Giovedì",Friday="Venerdì",Saturday="Sabato"},},
    fr={co2="CO2 level",rain_hr="Last hour",rain_3hr="Last 3 hours",rain_day="Last day",rain_week="Last week",rain_month="Last month",
      uv="UV index",firmware="Firmware ver.",trend_up="up",trend_st="stable",trend_dn="down",update_ok="VD updated",update_er="Update error",
      refresh="Refresh",windDir={N="N",NNE="NNE",NE="NE",ENE="ENE",E="E",ESE="ESE",SE="SE",SSE="SSE",S="S",SSW="SSW",SW="SW",WSW="WSW",
        W="W",WNW="WNW",NW="NW",NNW="NNW"},
      weekdaymap={Sunday="Dimanche",Monday="Lundi",Tuesday="Mardi",Wednesday="Mercredi",Thursday="Jeudi",Friday="Vendredi",Saturday="Samedi"},},
    nl={co2="CO2 niveau",rain_hr="Laatste uur",rain_3hr="Laatste 3 uur",rain_day="Laatste dag",rain_week="Laatste week",rain_month="Laatste maand",
      uv="UV index",firmware="Firmware versie",trend_up="opstaan",trend_st="stabiel",trend_dn="leggen",update_ok="VD bijgewerkt",
      update_er="Foute bijwerking",refresh="Bijwerken",windDir={N="N",NNE="NNO",NE="NO",ENE="ONO",E="O",ESE="OZO",SE="ZO",SSE="ZZO",S="Z",
        SSW="ZZW",SW="ZW",WSW="WZW",W="W",WNW="WNW",NW="NW",NNW="NNW"},
      weekdaymap={Sunday="Zondag",Monday="Maandag",Tuesday="Dinsdag",Wednesday="Woensdag",Thursday="Donderdag",Friday="Vrijdag",Saturday="Zaterdag"},},
    ro={co2="CO2 level",rain_hr="Last hour",rain_3hr="Last 3 hours",rain_day="Last day",rain_week="Last week",rain_month="Last month",
      uv="UV index",firmware="Firmware ver.",trend_up="up",trend_st="stable",trend_dn="down",update_ok="VD updated",update_er="Update error",
      refresh="Refresh",windDir={N="N",NNE="NNE",NE="NE",ENE="ENE",E="E",ESE="ESE",SE="SE",SSE="SSE",S="S",SSW="SSW",SW="SW",WSW="WSW",
        W="W",WNW="WNW",NW="NW",NNW="NNW"},
      weekdaymap={Sunday="Duminica",Monday="Luni",Tuesday="Marti",Wednesday="Miercuri",Thursday="Joi",Friday="Vineri",Saturday="Sambata"},},
    br={co2="CO2 level",rain_hr="Last hour",rain_3hr="Last 3 hours",rain_day="Last day",rain_week="Last week",rain_month="Last month",
      uv="UV index",firmware="Firmware ver.",trend_up="up",trend_st="stable",trend_dn="down",update_ok="VD updated",update_er="Update error",
      refresh="Refresh",windDir={N="N",NNE="NNE",NE="NE",ENE="ENE",E="E",ESE="ESE",SE="SE",SSE="SSE",S="S",SSW="SSW",SW="SW",WSW="WSW",
        W="W",WNW="WNW",NW="NW",NNW="NNW"},
      weekdaymap={Sunday="Domingo",Monday="Segunda-feira",Tuesday="Terça-feira",Wednesday="Quarta-feira",Thursday="Quinta-feira",Friday= "Sexta-feira",Saturday="Sabado"},},
    et={co2="CO2 tase",rain_hr="Viimase tunni",rain_3hr="Viimase 3 tunni",rain_day="Viimane p\195\164ev",rain_week="Eelmine n\195\164dal",
      rain_month="Eelmine kuu",uv="UV indeks",firmware="P\195\188sivara versioon",trend_up="t\195\181stmine",trend_st="stabiilse",
      trend_dn="langeb",update_ok="VD uuendatud",update_er="Uuendatud vea",refresh="Uuendama",windDir={N="N",NNE="NNE",NE="NE",ENE="ENE",
        E="E",ESE="ESE",SE="SE",SSE="SSE",S="S",SSW="SSW",SW="SW",WSW="WSW",W="W",WNW="WNW",NW="NW",NNW="NNW"},
      weekdaymap={Sunday="Pühapäev",Monday="Esmaspäev",Tuesday="Teisipäev",Wednesday="Kolmapäev",Thursday="Neljapäev",Friday="Reede",Saturday="Laupäev"},},
    lv={co2="CO2 līmenis",rain_hr="Pēdējā stunda",rain_3hr="Pēdējais 3 stunda",rain_day="Pēdējā diena",rain_week="Pagājušajā nedēļā",
      rain_month="Pagājušajā mēnesī",uv="UV indekss",firmware="programma versija",trend_up="audzēšana",trend_st="stabils",trend_dn="krišana",
      update_ok="VD atjaunināta",update_er="Update kļūda",refresh="Atjaunināt",windDir={N="Z",NNE="ZZA",NE="ZA",ENE="AZA",E="A",ESE="ADA",
        SE="DA",SSE="DDA",S="D",SSW="DDR",SW="DR",WSW="RDR",W="R",WNW="RZR",NW="ZR",NNW="ZZR"},
      weekdaymap={Sunday="Svētdiena",Monday="Pirmdiena",Tuesday="Otrdiena",Wednesday="Trešdiena",Thursday="Ceturdiena",Friday="Piektdiena",Saturday="Sestdiena"},},
    cn={co2="CO2水平",rain_hr="上一个小时",rain_3hr="最近3个小时",rain_day="最后一天",rain_week="上个星期",rain_month="上个月",uv="紫外线指数",
      firmware="固件版本",trend_up="上",trend_st="定",trend_dn="下",update_ok="VD更新",update_er="更新错误",refresh="更新",windDir={N="北",
        NNE="北东北",NE="东北",ENE="东北东",E="东",ESE="东南东",SE="东南",SSE="南东南",S="南",SSW="南西南",SW="西南",WSW="西西南",W="西",WNW="西西北",
        NW="西北",NNW="北西北"},
      weekdaymap={Sunday="星期天",Monday="星期一",Tuesday="星期二",Wednesday="星期三",Thursday="星期四",Friday="星期五",Saturday="星期六"},},
    ru={co2="Уровень CO2",rain_hr="последний час",rain_3hr="Последние 3 часа",rain_day="последний день",rain_week="прошлой неделе",
      rain_month="прошлый месяц",uv="УФ-индекс",firmware="версия прошивки",trend_up="расти",trend_st="стабильный",trend_dn="падение",
      update_ok="Обновление VD",update_er="Ошибка обновления",refresh="обновление",windDir={N="N",NNE="NNE",NE="NE",ENE="ENE",E="E",ESE="ESE",
        SE="SE",SSE="SSE",S="S",SSW="SSW",SW="SW",WSW="WSW",W="W",WNW="WNW",NW="NW",NNW="NNW"},
      weekdaymap={Sunday="Bоскресенье",Monday="Понедельник",Tuesday="Bторник",Wednesday="Cреда",Thursday="Четверг",Friday="Пятница",Saturday="Cуббота"},},
    dk={co2="CO2-niveauer",rain_hr="Sidste time",rain_3hr="Sidste 3 timer",rain_day="sidste dag",rain_week="sidste uge",
      rain_month="sidste m\195\165ned",uv="UV indeks",firmware="Firmware ver.",trend_up="h\195\166vning",trend_st="stabil",trend_dn="faldende",
      update_ok="VD opdateret",update_er="Opdateringsfejl",refresh="Opdater",windDir={N="N",NNE="NN\195\152",NE="N\195\152",
        ENE="\195\152N\195\152",E="\195\152",ESE="\195\152S\195\152",SE="S\195\152",SSE="SS\195\152",S="S",SSW="SSV",SW="SV",WSW="VSV",
        W="V",WNW="VNV",NW="NV",NNW="NNV"},
      weekdaymap={Sunday="S\195\184ndag",Monday="Mandag",Tuesday="Tirsdag",Wednesday="Onsdag",Thursday="Torsdag",Friday="Fredag",Saturday="L\195\184rdag"},},
    fi={co2="CO2-tasot",rain_hr="Viime tunti",rain_3hr="Viimeiset 3 tuntia",rain_day="Viimeinen p\195\164iv\195\164",rain_week="Viime viikko",
      rain_month="Viime kuukausi",uv="UV-indeksi",firmware="Laiteversio",trend_up="nostaa",trend_st="vakaa",trend_dn="pudota",
      update_ok="VD p\195\164ivitetty",update_er="P\195\164ivitysvirhe",refresh="P\195\164ivitt\195\164\195\164",windDir={N="P",NNE="PPI",NE="PI",
        ENE="IPI",E="I",ESE="IEI",SE="EI",SSE="EEI",S="E",SSW="EEL",SW="EL",WSW="LEL",W="L",WNW="LPL",NW="PL",NNW="PPL"},
      weekdaymap={Sunday="Sunnuntai",Monday="Maanantai",Tuesday="Tiistai",Wednesday="Keskiviikko",Thursday="Torstai",Friday="Perjantai",Saturday="Lauantai"},},
    cz={co2="\195\154roveň CO2",rain_hr="Posledn\195\173 hodina",rain_3hr="Posledn\195\173ch 3 hodin",rain_day="Posledn\195\173 den",
      rain_week="Minulý týden",rain_month="Minulý měsíc",uv="UV index",firmware="Verze firmwaru",trend_up="nahoru",trend_st="stabiln\195\173",
      trend_dn="dolů",update_ok="VD aktualizov\195\161no",update_er="Chyba aktualizace",refresh="Obnovit",windDir={N="S",NNE="SSV",NE="SV",
        ENE="VSV",E="V",ESE="VJV",SE="JV",SSE="JJV",S="J",SSW="JJZ",SW="JZ",WSW="ZJZ",W="Z",WNW="ZSZ",NW="SZ",NNW="SSZ"},
      weekdaymap={Sunday="Neděle",Monday="Pondělí",Tuesday="Úterý",Wednesday="Středa",Thursday="Čtvrtek",Friday="Pátek",Saturday="Sobota"},},
    us={co2="CO2 level",rain_hr="Last hour",rain_3hr="Last 3 hours",rain_day="Last day",rain_week="Last week",rain_month="Last month",
      uv="UV index",firmware="Firmware ver.",trend_up="up",trend_st="stable",trend_dn="down",update_ok="VD updated",update_er="Update error",
      refresh="Refresh",windDir={N="N",NNE="NNE",NE="NE",ENE="ENE",E="E",ESE="ESE",SE="SE",SSE="SSE",S="S",SSW="SSW",SW="SW",WSW="WSW",
        W="W",WNW="WNW",NW="NW",NNW="NNW"},
      weekdaymap={Sunday="Sunday",Monday="Monday",Tuesday="Tuesday",Wednesday="Wednesday",Thursday="Thursday",Friday="Friday",Saturday="Saturday"},},
    es={co2="Nivel de CO2",rain_hr="Ultima hora",rain_3hr="\195\154ltimas 3 horas",rain_day="\195\186ltimo d\195\173a",rain_week="Semana pasada",
      rain_month="Mes pasado",uv="\195\141ndice UV",firmware="Versi\195\179n de firmware",trend_up="arriba",trend_st="estable",trend_dn="abajo",
      update_ok="VD actualizado",update_er="Error de actualizaci\195\179n",refresh="Refrescar",windDir={N="N",NNE="NNE",NE="NE",ENE="ENE",E="E",
        ESE="ESE",SE="SE",SSE="SSE",S="S",SSW="SSO",SW="SO",WSW="OSO",W="O",WNW="ONO",NW="NO",NNW="NNO"},
      weekdaymap={Sunday="Domingo",Monday="Lunes",Tuesday="Martes",Wednesday="Miércoles",Thursday="Jueves",Friday="Viernes",Saturday="Sabado"},},
    sk={co2="Hladina CO2",rain_hr="Posledn\195\186 hod.",rain_3hr="Posledn\195\169 3 hod.",rain_day="Posledný deň",rain_week="Posledný týždeň",
      rain_month="Posledný mesiac",uv="UV index",firmware="Verzia firmv\195\169ru",trend_up="rast\195\186ce",trend_st="stabilný",
      trend_dn="dolu",update_ok="VD Aktualizovan\195\169",update_er="Chyba aktualiz\195\161cie",refresh="Aktualizovať",windDir={N="S",NNE="SSO",
        NE="SO",ENE="OSO",E="O",ESE="OJO",SE="JO",SSE="JJO",S="J",SSW="JJZ",SW="JZ",WSW="ZJZ",W="Z",WNW="ZSZ",NW="SZ",NNW="SSZ"},
      weekdaymap={Sunday="Nedeľa",Monday="Pondelok",Tuesday="Utorok",Wednesday="Streda",Thursday="Štvrtok",Friday="Piatok",Saturday="Sobota"},},
    hr={co2="Nivo CO2",rain_hr="Zadnji sat",rain_3hr="Zadnja 3 sata",rain_day="Zadnjih 24 sata",rain_week="Zadnji tjedan",rain_month="Zadnji mjesec",
      uv="UV indeks",firmware="Verzija firmvera",trend_up="raste",trend_st="stabilno",trend_dn="pada",update_ok="VD ažuriran",
      update_er="Greška kod ažuriranja",refresh="Ažuriraj",windDir={N="S",NNE="SSI",NE="SI",ENE="ISI",E="I",ESE="IJI",SE="JI",SSE="JJI",S="J",
        SSW="JJZ",SW="JZ",WSW="ZJZ",W="Z",WNW="ZSZ",NW="SZ",NNW="SSZ"},
      weekdaymap={Sunday="Nedjelja",Monday="Ponedjeljak",Tuesday="Utorak",Wednesday="Srijeda",Thursday="Četvrtak",Friday="Petak",Saturday="Subota"},},
    ba={co2="Nivo CO2",rain_hr="Zadnji sat",rain_3hr="Zadnja 3 sata",rain_day="Zadnjih 24 sata",rain_week="Zadnji tjedan",rain_month="Zadnji mjesec",
      uv="UV indeks",firmware="Verzija firmvera",trend_up="raste",trend_st="stabilno",trend_dn="pada",update_ok="VD ažuriran",
      update_er="Greška kod ažuriranja",refresh="Ažuriraj",windDir={N="S",NNE="SSI",NE="SI",ENE="ISI",E="I",ESE="IJI",SE="JI",SSE="JJI",S="J",
        SSW="JJZ",SW="JZ",WSW="ZJZ",W="Z",WNW="ZSZ",NW="SZ",NNW="SSZ"},
      weekdaymap={Sunday="Nedjelja",Monday="Ponedjeljak",Tuesday="Utorak",Wednesday="Srijeda",Thursday="Četvrtak",Friday="Petak",Saturday="Subota"},},
    rs={co2="ниво ЦО2",rain_hr="задњи час",rain_3hr="задња 3 часа",rain_day="задња 24 часа",rain_week="Zadnji tjedan",rain_month="задњи месец",
      uv="УВ индекс",firmware="верзија фирмвера",trend_up="расте",trend_st="стабилно",trend_dn="пада",update_ok="ВД ажуриран",
      update_er="Грешка код ажурирањa",refresh="ажурирај",windDir={N="S",NNE="SSI",NE="SI",ENE="ISI",E="I",ESE="IJI",SE="JI",SSE="JJI",S="J",
        SSW="JJZ",SW="JZ",WSW="ZJZ",W="Z",WNW="ZSZ",NW="SZ",NNW="SSZ"},
      weekdaymap={Sunday="недеља",Monday="понедељак",Tuesday="Уторак",Wednesday="среда",Thursday="четвртак",Friday="петак",Saturday="субота"},},
    si={co2="Raven CO2",rain_hr="Zadnja ura",rain_3hr="Zadnja 3 ure",rain_day="Zadnjih 24 ur",rain_week="Zadnji tjedan",rain_month="Prejšnji mesec",
      uv="UV indeks",firmware="Različica firmvera",trend_up="Narašča",trend_st="Vztrajno",trend_dn="Padec",update_ok="VD posodobljen",
      update_er="Napake pri posodabljanju",refresh="Posodobitev",windDir={N="S",NNE="SSI",NE="SI",ENE="ISI",E="I",ESE="IJI",SE="JI",SSE="JJI",
        S="J",SSW="JJZ",SW="JZ",WSW="ZJZ",W="Z",WNW="ZSZ",NW="SZ",NNW="SSZ"},
      weekdaymap={Sunday="Nedelja",Monday="Ponedjeljek",Tuesday="Torek",Wednesday="Sreda",Thursday="Četrtek",Friday="Petek",Saturday="Sobota"},},
    no={co2="CO2-niv\195\165er",rain_hr="Siste time",rain_3hr="Siste 3 time",rain_day="Siste dag",rain_week="Forrige uke",
      rain_month="forrige m\195\165ned",uv="UV indeks",firmware="Fastvareversjon",trend_up="opp",trend_st="stabil",trend_dn="ned",
      update_ok="VD oppdatert",update_er="Oppdateringsfeil",refresh="Forfriske",windDir={N="N",NNE="NN\195\152",NE="N\195\152",
        ENE="\195\152N\195\152",E="\195\152",ESE="\195\152S\195\152",SE="S\195\152",SSE="SS\195\152",S="S",SSW="SSV",SW="SV",WSW="VSV",
        W="V",WNW="VNV",NW="NV",NNW="NNV"},
      weekdaymap={Sunday="S\195\184ndag",Monday="Mandag",Tuesday="Tirsdag",Wednesday="Onsdag",Thursday="Torsdag",Friday="Fredag",Saturday="L\195\184rdag"},},
    hu={co2="CO2 level",rain_hr="Last hour",rain_3hr="Last 3 hours",rain_day="Last day",rain_week="Last week",rain_month="Last month",
      uv="UV index",firmware="Firmware ver.",trend_up="up",trend_st="stable",trend_dn="down",update_ok="VD updated",update_er="Update error",
      refresh="Refresh",windDir={N="N",NNE="NNE",NE="NE",ENE="ENE",E="E",ESE="ESE",SE="SE",SSE="SSE",S="S",SSW="SSW",SW="SW",WSW="WSW",
        W="W",WNW="WNW",NW="NW",NNW="NNW"},
      weekdaymap={Sunday="Vasárnap",Monday="Hétfő",Tuesday="Kedd",Wednesday="Szerda",Thursday="Csütörtök",Friday="Péntek",Saturday="Szombat"},},
    bg={co2="CO2 level",rain_hr="Last hour",rain_3hr="Last 3 hours",rain_day="Last day",rain_week="Last week",rain_month="Last month",
      uv="UV index",firmware="Firmware ver.",trend_up="up",trend_st="stable",trend_dn="down",update_ok="VD updated",update_er="Update error",
      refresh="Refresh",windDir={N="N",NNE="NNE",NE="NE",ENE="ENE",E="E",ESE="ESE",SE="SE",SSE="SSE",S="S",SSW="SSW",SW="SW",WSW="WSW",
        W="W",WNW="WNW",NW="NW",NNW="NNW"},
      weekdaymap={Sunday="Неделя",Monday="Понеделник",Tuesday="Вторник",Wednesday="Сряда",Thursday="Четвъртък",Friday="Петък",Saturday="Събота"},}}



function createNetatmoClient(modules)
    self = {}
    self.baseApiUrl = baseUrl
    self.httpClient = net.HTTPClient()
    self.token = nil

    clientId = appSelf:getVariable("clientId")
    secret = appSelf:getVariable("secret")
    username = appSelf:getVariable("username")
    password = appSelf:getVariable("password")
    baseUrl =  "https://api.netatmo.com"

    modules = modules or {}

    self.rain = modules.RAIN_MODULE or {}
    self.base = modules.BASE_MODULE or {}
    self.wind = modules.WIND_MODULE or {}
    self.out = modules.OUTDOOR_MODULE or {}

    function self.getModules()
        local m = {
            RAIN_MODULE = self.rain,
            BASE_MODULE = self.base,
            WIND_MODULE = self.wind,
            OUTDOOR_MODULE = self.out
        }
        return m
    end
------------------------- Devices utils
    function self.getDirection(sValue)
        -- return "-"
        local lW = langTable
        local lng = lW.nlng
        debug("default lang: ", lng)
        if ((sValue >= 0) and (sValue <= 11)) then
            return lW[lng].windDir.N
        elseif ((sValue > 11) and (sValue <= 34)) then
            return lW[lng].windDir.NNE
        elseif ((sValue > 34) and (sValue <= 56)) then
            return lW[lng].windDir.NE
        elseif ((sValue > 56) and (sValue <= 79)) then
            return lW[lng].windDir.ENE
        elseif ((sValue > 79) and (sValue <= 101)) then
            return lW[lng].windDir.E
        elseif ((sValue > 101) and (sValue <= 124)) then
            return lW[lng].windDir.ESE
        elseif ((sValue > 124) and (sValue <= 146)) then
            return lW[lng].windDir.SE
        elseif ((sValue > 146) and (sValue <= 169)) then
            return lW[lng].windDir.SSE
        elseif ((sValue > 169) and (sValue <= 191)) then
            return lW[lng].windDir.S
        elseif ((sValue > 191) and (sValue <= 214)) then
            return lW[lng].windDir.SSW
        elseif ((sValue > 214) and (sValue <= 236)) then
            return lW[lng].windDir.SW
        elseif ((sValue > 236) and (sValue <= 259)) then
            return lW[lng].windDir.WSW
        elseif ((sValue > 259) and (sValue <= 281)) then
            return lW[lng].windDir.W
        elseif ((sValue > 281) and (sValue <= 304)) then
            return lW[lng].windDir.WNW
        elseif ((sValue > 304) and (sValue <= 326)) then
            return lW[lng].windDir.NW
        elseif ((sValue > 326) and (sValue <= 349)) then
            return lW[lng].windDir.NNW
        elseif ((sValue > 349) and (sValue <= 360)) then
            return lW[lng].windDir.N
        else
            return "-"
        end
    end

    function self.parseData(data)
        local t = type(data)
        if t ~= "table" then
            return false, string.format("The data is not a table, it's a %s.", t)
        end
        t = type(data.body)
        if t ~= "table" then
            return false, string.format('Table does not contain a table "body", it\'s a %s.', t)
        end
        t = type(data.body.devices)
        if t ~= "table" then
            return false, string.format('Table does not contain a table "body.devices", it\'s a %s', t)
        end
        return true, data.body.devices[1]
    end

    function self.startMeasure()
        self.measureToComplete = 0
        if self.rain.fail == 0 then 
            debug("start rain measure")
            self.getMeasure(RAIN_MODULE, self.rain._id, "sum_rain", "1hour", "true", os.time() - 60*60, nil, nil)
            self.measureToComplete = self.measureToComplete + 1
            self.getMeasure(RAIN_MODULE, self.rain._id, "sum_rain", "1hour", "true", os.time() - 60*60 * 24, nil, "Day")
            self.measureToComplete = self.measureToComplete + 1
            self.getMeasure(RAIN_MODULE, self.rain._id, "sum_rain", "1hour", "true", os.time() - 60*60 * 24 * 7, nil, "Week")
            self.measureToComplete = self.measureToComplete + 1
            self.getMeasure(RAIN_MODULE, self.rain._id, "sum_rain", "1hour", "true", os.time() - 60*60 * 24 * 30, nil, "Month")
            self.measureToComplete = self.measureToComplete + 1
        end

        if self.wind.fail == 0 then
            debug("start wind measure")
            self.getMeasure(WIND_MODULE, self.wind._id, "WindStrength,WindAngle,GustStrength,GustAngle", "max", nil, nil, "last")
            self.measureToComplete = self.measureToComplete + 1
        end

        if self.out.fail == 0 then
            debug("start out measure")
            self.getMeasure(OUTDOOR_MODULE, self.out._id, "humidity,temperature", "max", nil, nil, "last")
            self.measureToComplete = self.measureToComplete + 1
        end
    end

    function self.isMeasureDone()
        return self.measureToComplete == 0
    end

    function self.measureDone()
        self.measureToComplete = self.measureToComplete - 1
        debug("measure state: ",self.measureToComplete, "measures to go")
        if self.isMeasureDone() then
            post({type="onMeasureDone"})
        end
    end

    function self.parseNAModule1(data)
        debug("parse outdoor")
        self.out.humid_min = self.out.humid_min or 99
        self.out.humid_max = self.out.humid_max or 0
        self.out.humid = data.body[1].value[1][1]
        self.out.humid_min, self.out.humid_max =
          self.calcMinMax(
          self.out.humid_min,
          self.out.humid_max,
          self.out.humid,
          "outdoor humidity"
        )
        self.out.temp = data.body[1].value[1][2]
        if self.base.unit == "imperial" then
            self.out.temp = ((self.out.temp * 9 / 5) + 32)
        end
        debug(json.encode(self.out))
    end

    function self.parseNAModule2(data)
        debug("parse wind")
        self.wind.speed = data.body[1].value[1][1]
        _, self.wind.speed_max =
          self.calcMinMax(0, self.wind.speed_max or 0, self.wind.speed, "wind speed")
        if self.base.wind_unit == " mph" then
          self.wind.speed = tonumber(string.format("%.0f", (self.wind.speed * 0.621371)))
          self.wind.speed_max = tonumber(string.format("%.0f", (self.wind.speed_max * 0.621371)))
        elseif self.base.wind_unit == " m/s" then
          self.wind.speed = tonumber(string.format("%.1f", (self.wind.speed * 0.277778)))
          self.wind.speed_max = tonumber(string.format("%.1f", (self.wind.speed_max * 0.277778)))
        elseif self.base.wind_unit == " B" then
          if self.wind.speed < 6 then
            self.wind.speed = 1
          elseif self.wind.speed < 12 then
            self.wind.speed = 2
          elseif self.wind.speed < 20 then
            self.wind.speed = 3
          elseif self.wind.speed < 29 then
            self.wind.speed = 4
          elseif self.wind.speed < 39 then
            self.wind.speed = 5
          elseif self.wind.speed < 51 then
            self.wind.speed = 6
          elseif self.wind.speed < 62 then
            self.wind.speed = 7
          elseif self.wind.speed < 75 then
            self.wind.speed = 8
          elseif self.wind.speed < 89 then
            self.wind.speed = 9
          elseif self.wind.speed < 103 then
            self.wind.speed = 10
          elseif self.wind.speed < 118 then
            self.wind.speed = 11
          else
            self.wind.speed = 12
          end
          if self.wind.speed_max < 6 then
            self.wind.speed_max = 1
          elseif self.wind.speed_max < 12 then
            self.wind.speed_max = 2
          elseif self.wind.speed_max < 20 then
            self.wind.speed_max = 3
          elseif self.wind.speed_max < 29 then
            self.wind.speed_max = 4
          elseif self.wind.speed_max < 39 then
            self.wind.speed_max = 5
          elseif self.wind.speed_max < 51 then
            self.wind.speed_max = 6
          elseif self.wind.speed_max < 62 then
            self.wind.speed_max = 7
          elseif self.wind.speed_max < 75 then
            self.wind.speed_max = 8
          elseif self.wind.speed_max < 89 then
            self.wind.speed_max = 9
          elseif self.wind.speed_max < 103 then
            self.wind.speed_max = 10
          elseif self.wind.speed_max < 118 then
            self.wind.speed_max = 11
          else
            self.wind.speed_max = 12
          end
        elseif self.base.wind_unit == " kt." then
          self.wind.speed = tonumber(string.format("%.0f", (self.wind.speed * 0.539956803)))
          self.wind.speed_max = tonumber(string.format("%.0f", (self.wind.speed_max * 0.539956803)))
        end
        self.wind.deg = data.body[1].value[1][2]
        self.wind.dir = self.getDirection(self.wind.deg)
        -- get gusts
        self.wind.gust = data.body[1].value[1][3]
        _, self.wind.gust_max =
          self.calcMinMax(0, self.wind.gust_max or 0, self.wind.gust, "gust speed")
        if self.base.wind_unit == " mph" then
          self.wind.gust = tonumber(string.format("%.0f", (self.wind.gust * 0.621371)))
          self.wind.gust_max = tonumber(string.format("%.0f", (self.wind.gust_max * 0.621371)))
        elseif self.base.wind_unit == " m/s" then
          self.wind.gust = tonumber(string.format("%.1f", (self.wind.gust * 0.277778)))
          self.wind.gust_max = tonumber(string.format("%.1f", (self.wind.gust_max * 0.277778)))
        elseif self.base.wind_unit == " B" then
          if self.wind.gust < 6 then
            self.wind.gust = 1
          elseif self.wind.gust < 12 then
            self.wind.gust = 2
          elseif self.wind.gust < 20 then
            self.wind.gust = 3
          elseif self.wind.gust < 29 then
            self.wind.gust = 4
          elseif self.wind.gust < 39 then
            self.wind.gust = 5
          elseif self.wind.gust < 51 then
            self.wind.gust = 6
          elseif self.wind.gust < 62 then
            self.wind.gust = 7
          elseif self.wind.gust < 75 then
            self.wind.gust = 8
          elseif self.wind.gust < 89 then
            self.wind.gust = 9
          elseif self.wind.gust < 103 then
            self.wind.gust = 10
          elseif self.wind.gust < 118 then
            self.wind.gust = 11
          else
            self.wind.gust = 12
          end
          if self.wind.gust_max < 6 then
            self.wind.gust_max = 1
          elseif self.wind.gust_max < 12 then
            self.wind.gust_max = 2
          elseif self.wind.gust_max < 20 then
            self.wind.gust_max = 3
          elseif self.wind.gust_max < 29 then
            self.wind.gust_max = 4
          elseif self.wind.gust_max < 39 then
            self.wind.gust_max = 5
          elseif self.wind.gust_max < 51 then
            self.wind.gust_max = 6
          elseif self.wind.gust_max < 62 then
            self.wind.gust_max = 7
          elseif self.wind.gust_max < 75 then
            self.wind.gust_max = 8
          elseif self.wind.gust_max < 89 then
            self.wind.gust_max = 9
          elseif self.wind.gust_max < 103 then
            self.wind.gust_max = 10
          elseif self.wind.gust_max < 118 then
            self.wind.gust_max = 11
          else
            self.wind.gust_max = 12
          end
        elseif self.base.wind_unit == " kt." then
          self.wind.gust = tonumber(string.format("%.0f", (self.wind.gust * 0.539956803)))
          self.wind.gust_max = tonumber(string.format("%.0f", (self.wind.gust_max * 0.539956803)))
        end
        self.wind.gust_deg = data.body[1].value[1][4]
        self.wind.gust_dir = self.getDirection(self.wind.gust_deg)
        debug(string.format("Wind speed: %s%s - angle: %s",self.wind.speed,self.base.wind_unit,self.wind.deg))
        debug(string.format("Gust speed: %s%s - angle: %s",self.wind.gust,self.base.wind_unit,self.wind.gust_deg))
    end

    function self.parseNAModule3(data, opt)
        debug("parse rain ", opt or "hour")
        local sum_rain = 0
        for k, v in pairs(data.body) do
          for l, w in pairs(v.value) do
            sum_rain = sum_rain + w[1]
          end
        end
        if self.base.unit == "imperial" then
          sum_rain = (sum_rain * 0.039370)
        end
        self.rain["sum_" .. (opt or "hour")] = sum_rain
        debug(string.format("Rainfall: %s %s (%s)", sum_rain, self.base.rain_unit, opt or "hour"))
    end

    function self.parseNAModule3Day(data)
        self.parseNAModule3(data, "day")
    end

    function self.parseNAModule3Week(data)
        self.parseNAModule3(data, "week")
    end

    function self.parseNAModule3Month(data)
        self.parseNAModule3(data, "month")
    end

    function self.getModule(data, module)
        for _, v in pairs(data.body.devices[1].modules) do
            if v.type == module then
               return v 
            end
        end
        debug("no module ", module, " found.")
        return nil
    end

     function self.parseOutData(data)
        local v = self.getModule(data, OUTDOOR_MODULE)
        if v == nil or v._id == nill then
            self.out.fail = 1
            return self.out
        end
        
        self.out.fail = 0
        self.out.name = v.module_name
        self.out._id = v._id
        self.out.batt = v.battery_percent
        self.out._rf = (100 - v.rf_status)
        self.out.last_message = v.last_message
        self.out.last_seen = v.last_seen
        self.out.firmware = v.firmware
        self.out.temp_min = v.dashboard_data.min_temp
        self.out.temp_max = v.dashboard_data.max_temp
        if self.base.unit == "imperial" then
            self.out.temp_min = ((self.out.temp_min * 9 / 5) + 32)
            self.out.temp_max = ((self.out.temp_max * 9 / 5) + 32)
        end
        self.out.temp_trend = v.dashboard_data.temp_trend
        return self.out
    end

    function self.parseRainData(data)
        local v = self.getModule(data, RAIN_MODULE)
        if v == nil or v._id == nill then
            self.rain.fail = 1
            return self.rain
        end
        
        self.rain.fail = 0
        self.rain.name = v.module_name
        self.rain._id = v._id
        self.rain.batt = v.battery_percent
        self.rain._rf = (100 - v.rf_status)
        self.rain.last_message = v.last_message
        self.rain.last_seen = v.last_seen
        self.rain.firmware = v.firmware
        return self.rain
    end

    function self.parseWindData(data)
        local v = self.getModule(data, WIND_MODULE)
        if v == nil or v._id == nill then
            self.wind.fail = 1
            return self.wind
        end
        self.wind.fail = 0
        self.wind.name = v.module_name
        self.wind._id = v._id
        self.wind.batt = v.battery_percent
        self.wind._rf = (100 - v.rf_status)
        self.wind.last_message = v.last_message
        self.wind.last_seen = v.last_seen
        self.wind.firmware = v.firmware
        return self.wind
    end

    function self.parseBaseData(data)
        local ok, e = self.parseData(data)
        if not ok then
            post({type="onParseError", error = e})
            return
        end
        
        self.base.fail = 0
        self.base._id = data.body.devices[1]._id
        self.base.name = data.body.devices[1].station_name
        -- netatmo.module_name = data.body.devices[1].module_name
        self.base.wifi = data.body.devices[1].wifi_status
        self.base.last_status_store = data.body.devices[1].last_status_store
        self.base.firmware = data.body.devices[1].firmware
        if data.body.user.administrative.unit == 0 then
            self.base.unit = "metric"
            self.base.temp_unit = " \194\176C"
            self.base.rain_unit = " mm"
        else
            self.base.unit = "imperial"
            self.base.temp_unit = " \194\176F"
            self.base.rain_unit = " in"
        end
        if data.body.user.administrative.windunit == 0 then
            self.base.wind_unit = " km/h"
        elseif data.body.user.administrative.windunit == 1 then
            self.base.wind_unit = " mph"
        elseif data.body.user.administrative.windunit == 2 then
            self.base.wind_unit = " m/s"
        elseif data.body.user.administrative.windunit == 3 then
            self.base.wind_unit = " B"
        else
            self.base.wind_unit = " kt."
        end
        if data.body.user.administrative.pressureunit == 0 then
            self.base.press_unit = " hPa"
        elseif data.body.user.administrative.pressureunit == 1 then
            self.base.press_unit = " inHg"
        else
            self.base.press_unit = " mmHg"
        end
        if data.body.user.administrative.feel_like_algo == 0 then
            self.base.feels_like = "Humidex"
        else
            self.base.feels_like = "Heat Index"
        end
        self.base.country = data.body.user.administrative.country
        self.base.reg_locale = data.body.user.administrative.reg_locale
        self.base.lang = data.body.user.administrative.lang
        self.base.place={}
        self.base.place.altitude = data.body.devices[1].place.altitude
        self.base.place.city = data.body.devices[1].place.city
        self.base.place.country = data.body.devices[1].place.country
        self.base.place.time_zone = data.body.devices[1].place.timezone
        self.base.place.lon = data.body.devices[1].place.location[1]
        self.base.place.lat = data.body.devices[1].place.location[2]
        self.base.temp = {}
        self.base.temp = data.body.devices[1].dashboard_data.Temperature
        self.base.temp_min = data.body.devices[1].dashboard_data.min_temp
        self.base.temp_max = data.body.devices[1].dashboard_data.max_temp
        if self.base.unit == "imperial" then
            self.base.temp = ((self.base.temp * 9 / 5) + 32)
            self.base.temp_min = ((self.base.temp_min * 9 / 5) + 32)
            self.base.temp_max = ((self.base.temp_max * 9 / 5) + 32)
        end
        self.base.temp_trend = data.body.devices[1].dashboard_data.temp_trend
        self.base.humid = data.body.devices[1].dashboard_data.Humidity
        self.base.humid_min, self.base.humid_max =
            self.calcMinMax(self.base.humid_min or 0, self.base.humid_max or 0, self.base.humid, "indoor base humidity")
        self.base.abs_press = data.body.devices[1].dashboard_data.AbsolutePressure
        self.base.press = tonumber(string.format("%.0f", data.body.devices[1].dashboard_data.Pressure))
        self.base.press_min, self.base.press_max =
            self.calcMinMax(self.base.press_min or 0, self.base.press_max or 0, self.base.press, "air pressure")
        self.base.press_trend = data.body.devices[1].dashboard_data.pressure_trend
        self.base.noise = data.body.devices[1].dashboard_data.Noise
        self.base.co2 = data.body.devices[1].dashboard_data.CO2
        return self.base
    end
------------------------- tools
    function self.calcMinMax(min, max, val, dbg)
        local ct = os.date("%H:%M", os.time())
        dbg = dbg or ""
        if ((ct >= "00:00") and (ct <= "00:10")) then
            min = val
            max = val
            if addebug then
                debug("Resetting min/max values for ", dbg)
            end
        else
            if val < min then
            min = val
            end
            if val > max then
            max = val
            end
        end
        return min, max
    end
------------------------- API stuff
    function self.getUrl(url)
        return self.baseApiUrl .. url
    end

    function self.login()
        local dataUrl = self.getUrl("/oauth2/token")
        local requestBody =  "grant_type=password&" .. "client_id=" .. clientId .. "&client_secret=" .. secret .. "&username=" .. username .. "&password=" .. password .. "&scope=read_station"

        verbose("url: ",dataUrl)
        verbose("data: ",requestBody)

        self.httpClient:request(dataUrl, {
            options={
                headers = {
                    ["Content-Type"] = "application/x-www-form-urlencoded;charset=UTF-8"
                },
                data = requestBody,
                method = 'POST'
            },
            success = function(response)
                self.token = json.decode(response.data)
                post({type="onLogin"})
            end,
            error = function(error)
                post({type="onLoginError", e = error})
            end
        })
    end

    function self.validateLogin()
        if self.token == nil then
            debug("no token")
            return false
        end
        return true    
    end

    function self.refreshToken()
        local dataUrl = self.getUrl("/oauth2/token")
        local requestBody =  "grant_type=refresh_token&" .. "client_id=" .. clientId .. "&client_secret=" .. secret .. "&refresh_token=" .. self.token.refresh_token

        self.httpClient:request(dataUrl, {
            options={
                headers = {
                    ["Content-Type"] = "application/x-www-form-urlencoded;charset=UTF-8"
                },
                data = requestBody,
                method = 'POST'
            },
            success = function(response)
                self.token = json.decode(response.data)
                post({type="onLogin"})
            end,
            error = function(error)
                post({type="onLoginError", e = error})
            end
        })
    end

    function self.checkResponse(res)
        debug(json.encode(res))
        if res.status == 200 then
            return true, res.data
        end

        if res.status == 403 then
            return false, res.data.error
        end
    end

    function self.getData()
        local dataUrl = self.getUrl("/api/getstationsdata?get_favorites=false")
        debug("api url: ", dataUrl)
        if not self.validateLogin() then
            post({type="login"})
            return
        end
        debug("token: ",json.encode(self.token))
        self.httpClient:request(dataUrl, {
            options={
                headers = {
                    Accept = "application/json",
                    ContentType = "application/json",
                    Authorization = "Bearer " .. self.token.access_token
                },
                method = 'GET'
            },
            success = function(response)
                local ok, res = self.checkResponse(response)
                if ok then
                    post({type="onData", d = json.decode(res)})
                    return
                end
                post({type="onDataError", error = res})
            end,
            error = function(error)
                post({type="onDataError", error = error})
            end
        })
    end

    function self.getMeasure(moduleType, moduleId, type, scale, real_time, date_begin, date_end, measureOpt)
        local dataUrl = self.getUrl("/api/getmeasure") .. 
                        "?device_id=" .. self.base._id .. 
                        "&module_id=" .. moduleId .. 
                        "&scale=" .. scale ..  
                        "&type=" .. type
                        
        if real_time ~= nil then
            dataUrl = dataUrl .. "&real_time=" .. real_time
        end
        if date_begin ~= nil then
            dataUrl = dataUrl .. "&date_begin=" .. date_begin
        end
        if date_end ~= nil then
            dataUrl = dataUrl .. "&date_end=" .. date_end
        end
        debug("api url: ", dataUrl)
        if not self.validateLogin() then
            post({type="login"})
            return
        end
        self.httpClient:request(dataUrl, {
            options={
                headers = {
                    Accept = "application/json",
                    ContentType = "application/json",
                    Authorization = "Bearer " .. self.token.access_token
                },
                method = 'GET'
            },
            success = function(response)
                local ok, res = self.checkResponse(response)
                if ok then
                    post({type="onMeasureData", d = json.decode(res), moduleType=moduleType, measureOpt = measureOpt})
                    return
                end
                post({type="onMeasureError", error = res})
            end,
            error = function(error)
                post({type="onMeasureError", error = error})
            end
        })
    end

    return self
end

-- Posible conditions: "unknown", "clear", "rain", "snow", "storm", "cloudy", "fog"
function QuickApp:setCondition(condition)
    local conditionCodes = { 
        unknown = 3200,
        clear = 32,
        rain = 40,
        snow = 38,
        storm = 666,
        cloudy = 30,
        fog = 20,
    }

    local conditionCode = conditionCodes[condition]

    if conditionCode then
        self:updateProperty("ConditionCode", conditionCode)
        self:updateProperty("WeatherCondition", condition)
    end
end

-- To update controls you can use method self:updateView(<component ID>, <component property>, <desired value>). Eg:  
-- self:updateView("slider", "value", "55") 
-- self:updateView("button1", "text", "MUTE") 
-- self:updateView("label", "text", "TURNED ON") 

-- This is QuickApp inital method. It is called right after your QuickApp starts (after each save or on gateway startup). 
-- Here you can set some default values, setup http connection or get QuickApp variables.
-- To learn more, please visit: https://manuals.fibaro.com/
local trace = true
function post(e,t) 
    if trace then
        debug("event: ", json.encode(e))
        debug("timeout: ", t or 0)
    end
    setTimeout(function() main(e) end,t or 0) 
end

function main(e)
    ({
        start = function(e) 
            appSelf.nC.login() 
        end,
        onLogin = function(e) 
            post({type="refreshData"})
        end,
        onLoginError = function(e) 
            debug("login error") 
            post({type="start"}, 60 * 60)
        end,
        refreshData = function(e)
            appSelf.nC.getData() 
        end,
        onData = function(e) 
            -- debug(json.encode(e.d))
            local base = appSelf.nC.parseBaseData(e.d)
            local rain = appSelf.nC.parseRainData(e.d)
            local out = appSelf.nC.parseOutData(e.d)
            local wind = appSelf.nC.parseWindData(e.d)
            debug("base:", json.encode(base))
            debug("rain:", json.encode(rain))
            debug("wind:", json.encode(wind))
            debug("out:", json.encode(out))
            appSelf:refreshView()
            appSelf.nC.startMeasure()
        end,
        onDataError = function(e) 
            debug(json.encode(e)) 
            -- handle error properly
            -- if e.error.code == 2 then
            --     appSelf.nC.refreshToken()
            --     return
            -- end
            post({type="start"})   
        end,
        onMeasureData = function(e) -- d, moduleType
            debug("mesure for: ", e.moduleType, " with data: ", json.encode(e.d))
            appSelf.nC["parse" .. e.moduleType .. (e.measureOpt or "")](e.d)
            appSelf.nC.measureDone()
        end,
        onMeasureError = function(e)
            debug(json.encode(e))
            appSelf.nC.measureDone()
            if e.error == "invalid_token" then
                appSelf.nC.refreshToken()
            end
        end,
        onMeasureDone = function(e)
            debug("all data downloaded... init next refresh interval\n")
            appSelf:updateWeather()
            debug("---------------------------------------------------")
            post({type="refreshData"}, refresh_s * 1000)
        end,
        onParseError = function(e)
            debug(e.error)
            post({type="start"}, refresh_s * 1000)
        end

    })[e.type](e)
end

-- To update temperature, update property "Temperature" with floating point number
-- To update humidity, update property "Humidity" with floating point number
-- To update wind speed, update property "Wind" with floating point number
function QuickApp:updateWeather()
    local m = self:getNetatmoClient().getModules()
    -- debug(json.encode(m))
    fibaro.setGlobalVariable("netatmoModules", json.encode(m))
    -- self:updateView("lblTest", "text", "OK")
    -- self:updateView("lblLastTime", "text", "OK")
    -- self:setCondition("clear")
    -- local m = self.nC.getModules()
    -- self:updateProperty("Temperature", m.OUTDOOR_MODULE.temp)
    -- self:updateProperty("Humidity", m.OUTDOOR_MODULE.humid)
    -- self:updateProperty("Wind", m.WIND_MODULE.speed)
end

function QuickApp:initIcons()
    self.ic = {}
    self.ic.main_icon       = 1019
    self.ic.green_icon      = 1020
    self.ic.yellow_icon     = 1021
    self.ic.orange_icon     = 1022
    self.ic.red_icon        = 1023
    self.ic.error_icon      = 1024
end

function QuickApp:getNetatmoClient()
    return self.nC
end

function QuickApp:displayNil()
    self:updateView("lblMain","text",string.format("%s - %s - %s - %s -",sy.temp,sy.humid,sy.co2,sy.noise))
    self:updateView("lblTemp", "text",string.format("%s %s %s - %s - %s %s - %% %s - %%",sy.temp,sy.arrow_right,sy.arrowup,sy.arrowdn,sy.humid,sy.arrowup,sy.arrowdn))
    self:updateView("lblPress", "text",string.format("%s - %s %s - %s -",sy.arrow_dn,sy.arrow_right,sy.arrowup,sy.arrowdn))
    self:updateView("lblStation","text",string.format("%s %s %s - %s -",sy.round_pushpin,sy.warning,sy.trackball, sy.cd))
    if self.nC.base.last_status_store ~= nil then
        self:updateView("lblMessage","text",string.format("%s %s %s",sy.eye,sy.warning,os.date("%d %m %Y %H:%M",self.nC.base.last_status_store)))
    else self:updateView("lblMessage","text",string.format("%s %s -",sy.eye,sy.warning))end
    self:updateProperty("deviceIcon",self.ic.error_icon)
end

function QuickApp:refreshView()
    debug("updating view")
    local cTime = os.time();
    if ((cTime - self.nC.base.last_status_store) < 1800) then
      local temp_trend = ""
      if self.nC.base.temp_trend == "up" then
        temp_trend = sy.arrow_rraise
      elseif self.nC.base.temp_trend == "stable" then
        temp_trend = sy.arrow_right
      else
        temp_trend = sy.arrow_rfall
      end
      local press_trend = ""
      if self.nC.base.press_trend == "up" then
        press_trend = sy.arrow_rraise
      elseif self.nC.base.press_trend == "stable" then
        press_trend = sy.arrow_right
      else
        press_trend = sy.arrow_rfall
      end
      if self.nC.base.noise == nil then
       self.nC.base.noise = "--"
      end
      if self.nC.base.co2 == nil then
       self.nC.base.co2 = "--"
      end
      local label = string.format("%s %s%s %s %s %s%% %s %s ppm %s %s dB",
                            sy.temp,
                          self.nC.base.temp,
                          self.nC.base.temp_unit,
                            temp_trend,
                            sy.humid,
                          self.nC.base.humid,
                            sy.co2,
                          self.nC.base.co2,
                            sy.noise,
                          self.nC.base.noise
                          )
      self:updateView("lblMain", "text", label)
      self:updateView("lblTemp","text",string.format("%s %s%s%s %s%s%s %s %s%s%% %s%s%%",
                            sy.temp,
                            sy.arrowup,
                          self.nC.base.temp_max,
                          self.nC.base.temp_unit,
                            sy.arrowdn,
                          self.nC.base.temp_min,
                          self.nC.base.temp_unit,
                            sy.humid,
                            sy.arrowup,
                          self.nC.base.humid_max,
                            sy.arrowdn,
                          self.nC.base.humid_min
                          )
      )
      self:updateView("lblPress","text",string.format("%s %s%s %s %s%s%s %s%s%s",
                            sy.arrow_dn,
                          self.nC.base.press,
                          self.nC.base.press_unit,
                            press_trend,
                            sy.arrowup,
                          self.nC.base.press_max,
                          self.nC.base.press_unit,
                            sy.arrowdn,
                          self.nC.base.press_min,
                          self.nC.base.press_unit
                          )
      )
      self:updateView("lblStation","text",string.format("%s %s %s %s",
                            sy.round_pushpin,
                          self.nC.base.name,
                            sy.cd,
                          self.nC.base.firmware
                          )
      )
      self:updateView("lblMessage","text",string.format("%s %s", sy.eye, os.date("%d.%m.%Y %H:%M",self.nC.base.last_status_store)))

      if self.nC.base.co2 == "--" then
          self:updateProperty("deviceIcon", self.ic.green_icon)
      elseif self.nC.base.co2 <= yellow then
          self:updateProperty("deviceIcon", self.ic.green_icon)
      elseif self.nC.base.co2 > yellow and self.nC.base.co2 <= orange then
          self:updateProperty("deviceIcon", self.ic.yellow_icon)
      elseif self.nC.base.co2 > orange and self.nC.base.co2 <= red then
          self:updateProperty("deviceIcon", self.ic.orange_icon)
      else
          self:updateProperty("deviceIcon", self.ic.red_icon)
      end
      self:updateProperty("value", self.nC.base.temp)
      self:updateProperty("unit", self.nC.base.temp_unit)
    else
        self:debug("ERROR - Base module not updated recently")
        self:debug(json.encode(self.nC.base))
        self:displayNil()
    end
end

function QuickApp:initVariables()
    local checkVar = function(name, defaultValue, override)
        local tmp = fibaro.getGlobalVariable(name)
        if tmp == nil then
            debug("creating global " .. name .. " variable")
            local m = {
                name = name,
                isEnum = false,
                readOnly = false,
                value = json.encode(defaultValue)
            }
            api.post("/globalVariables", m)
            debug("creating global " .. name .. " variable... DONE")
        end
        if override then
            fibaro.setGlobalVariable(name, json.encode(defaultValue))
        end
    end

    checkVar("netatmoModules", {})
    checkVar("netatmo_sy", sy, override)
end

function QuickApp:onInit()
    self:debug("onInit")

    debug = function(text, ...) self:debug(text, ...) end
    verbose = function(text, ...) if trace then self:debug(text, ...) end end
    
    self:initIcons()
    self:initVariables()

    appSelf = self
    local modules = fibaro.getGlobalVariable("netatmoModules")
    if modules ~= nil then
        debug("reading modules from last gobal state")
    end
    self.nC = createNetatmoClient(modules)

    self:displayNil()
    post({type="start"})     
end
