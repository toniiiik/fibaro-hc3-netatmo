# Netatmo devices for fibaro home center 3

*this is alpha version of devices*

thanks @jangabrielsson for all the tips and tricks https://forum.fibaro.com/topic/49113-hc3-quickapps-coding-tips-and-tricks/

thanks @Sankotronic for the Netatmo integration with HC2 https://forum.fibaro.com/files/file/93-netatmo-weather-station-vd-scene-standalone/

![Netatmo devices](room_devices.png?raw=true "Netatmo Devices")

# Installation & configuration

## Instalation base module
1. upload ``Netatmo_base_station.fqa`` to devices
2. check if variables is initialized (variable netatmoModules has value '{}' after rist setup)
![Global_vars](doc/global_vars.png?raw=true "Global Vars")
3. update device variables
![Setup_device_vars](doc/1.setup_device_vars.png?raw=true "Setup Device Vars")
4. after save and few seconds device will be ready and values will appear (look at preview tab)
![Preview](doc/2.after_variable_set.png?raw=true "Preview")


## Instalation of another modules
just upload fqa for module no other setup is needed. 

## Instalation of indoor module

!!! works only with latest version of HC3 (at the time build: 5.030.45)

instalation is same as other devices but in variables there is required value for proper function. ``module_name`` is the name which you choose in netatmo application when you add additional indoor devices.
![Indoor_variables](doc/indoor_variables.png?raw=true "indoor variables")

when you add indoor device controller the three more devices is created during first start.
![Indoor_devices](doc/indoor_devices.png?raw=true "indoor device")


## Devices and icons

1. base station (must be installed)
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
- [x] more debug and error handling
- [x] use pcall to handle "exceptions" in code to prevent app crash.
- [ ] add actions to support module device refresh invoke.
- [ ] split module data to separate variables and use event handlers to update module state
- [ ] add separate device for outdoor humid and temperature
- [x] add support for additional indoor modules
- [ ] add support for more then one station
- [ ] add weather provider class with data from base station

