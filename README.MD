# Netatmo devices for fibaro home center 3

*this is alpha version of devices*

thanks @jangabrielsson for all the tips and tricks https://forum.fibaro.com/topic/49113-hc3-quickapps-coding-tips-and-tricks/

thanks @Sankotronic for the Netatmo integration with HC2 https://forum.fibaro.com/files/file/93-netatmo-weather-station-vd-scene-standalone/

TBD description

# Installation & configuration

there is problem with global variable value length constraint on UI (teste on safari). It is not possible to set value longer then 20 chars

## Global variables (hack)
create dummy quick app and run code.
```lua
fibaro.setGlobalVariable("netatmo_clientId", "your cliebt")
fibaro.setGlobalVariable("netatmo_secret", "your seecret")
fibaro.setGlobalVariable("netatmo_userName", "your username")
fibaro.setGlobalVariable("netatmo_password", "your password")
fibaro.setGlobalVariable("netatmoModules", "{}") 

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

 fibaro.setGlobalVariable("netatmo_sy", json.encode(sy))  

```

## Devices and icons

1. base station
2. rain
3. wind
4. outdoor
5. base humid
6. base temperature

setup icon IDs for each device and state in QuickApp:initIcons function. If you want to use netatmo icon use icons from HC2 virtual devices https://forum.fibaro.com/files/file/93-netatmo-weather-station-vd-scene-standalone/


# TODO

- [x] add support for rain module
- [x] add support for outdoor module
- [x] add separete device for indoor humid and temperature
- [ ] add lang support
- [ ] setup icon IDs via device variable
- [ ] update user incons code via the module variables not the quickapp code
- [ ] more debug and error handling
- [ ] use pcall to handle "exceptions" in code to prevent app crash.
- [ ] add actions to support module device refresh invoke.
- [ ] split module data to separate variables and use event handlers to update module state
- [ ] add separate device for outdoor humid and temperature
- [ ] add support for additional indoor modules
- [ ] add support for more then one station
- [ ] add weather provider class with data from base station

