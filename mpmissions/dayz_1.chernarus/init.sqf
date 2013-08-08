// Mission Initialization
startLoadingScreen ["", "RscDisplayLoadCustom"];
cutText ["", "BLACK OUT"];
enableSaving [false, false];

// Variable Initialization
dayZ_instance = 1;
dayzHiveRequest = [];
initialized = false;
dayz_previousID = 0;

// Settings
player setVariable ["BIS_noCoreConversations", true]; 	// Disable greeting menu
//enableRadio false; 									// Disable global chat radio messages
// Compile and call important functions
call compile preprocessFileLineNumbers "\z\addons\dayz_code\init\variables.sqf";
progressLoadingScreen 0.1;
call compile preprocessFileLineNumbers "\z\addons\dayz_code\init\publicEH.sqf";
progressLoadingScreen 0.2;
call compile preprocessFileLineNumbers "\z\addons\dayz_code\medical\setup_functions_med.sqf";
progressLoadingScreen 0.4;
call compile preprocessFileLineNumbers "custom\compiles.sqf"; //Compile custom compiles
progressLoadingScreen 1.0;

// Set Tonemapping
"Filmic" setToneMappingParams [0.153, 0.357, 0.231, 0.1573, 0.011, 3.750, 6, 4];
setToneMapping "Filmic";

// Run the server monitor
if (isServer) then {
	_serverMonitor = [] execVM "\z\addons\dayz_server\system\server_monitor.sqf";
};

if (!isServer && isNull player) then {
	waitUntil { !isNull player };
	waitUntil { time > 3 };
};

if (!isServer && player != player) then {
	waitUntil { player == player };
	waitUntil { time > 3 };
};

player_wearClothes = compile preprocessFileLineNumbers "fixes\player_wearClothes.sqf";

// Run the player monitor
if (!isDedicated) then {
	0 fadeSound 0;
	waitUntil { !isNil "dayz_loadScreenMsg" };
	dayz_loadScreenMsg = (localize "STR_AUTHENTICATING");

	 _id = player addEventHandler ["Respawn", {_id = [] spawn player_death; _nul = [] execVM "playerspawn.sqf";}];
	_playerMonitor = [] execVM "\z\addons\dayz_code\system\player_monitor.sqf";
	"heliCrash" addPublicVariableEventHandler {
        _list = nearestObjects [_this select 1, ["CraterLong"], 100];
        {deleteVehicle _x;} foreach _list;
    };
	_nul = [] execVM "playerspawn.sqf";	
	#include "gcam\gcam_config.hpp"
	#include "gcam\gcam_functions.sqf"

	#ifdef GCAM
		waitUntil { alive Player };
		waituntil { !(IsNull (findDisplay 46)) };

		if (serverCommandAvailable "#kick") then { (findDisplay 46) displayAddEventHandler ["keyDown", "_this call fnc_keyDown"]; };
	#endif
};

if (!isDedicated) then {
[] execVM "fixes\change_streetlights.sqf";
[] execVM "Scripts\kh_actions.sqf";
};
if (isServer) then {
axe_server_lampObjs =    compile preprocessFileLineNumbers "lights\fnc_returnLampWS.sqf";
    "axeLampObjects" addPublicVariableEventHandler {_id = (_this select 1) spawn axe_server_lampObjs};
};
 
if (!isDedicated) then {
//StreetLights
[] execVM "lights\street_lights.sqf";
};
if (!isServer) then
{
    chooChooCode = {
    sleep .3;
 
    // rail id numbers
    _rail = _this select 0;
 
    _mynum = count _rail;
    _mynum = _mynum - 1;
 
    // rail id you want to dtop at
    _stops = _this select 1;
 
    // rail id you want to dtop at
    _hornblow = _this select 2;
 
    _train = _this select 3;
 
    _i = 0;
    _j = 0;
    _track = (getpos _train) nearestobject (_rail select 0);
    for "_i" from 0 to ((count _rail) - 1) do
    {
        if ((_train distance ((getpos _train) nearestobject (_rail select _i))) < 100) then {
                if ((_track distance _train) > ((getpos _train) nearestobject (_rail select _i)) distance _train) then
                {
                    _track = (getpos _train) nearestobject (_rail select _i);
                    _j = _i;
                };
        };
    };
 
    _dirPlayer = (getdir _train);
    _dirTrack = (getdir _track);
    _oppsite = 0;
    if (abs(_dirPlayer - _dirTrack) > 100) then { _oppsite = 1};
    if (_oppsite == 0) then {_train setDir getdir _track; } else {_train setDir ((getdir _track) - 180)};
    _train setPos (getPos _track);
 
 
    _gun = 0;
 
    // train settings
    _stoptime = 10;
    _topspeed = 55;
 
    _pos = position _train;
    _wb = _this select 4;
    _wf = _this select 5;
 
    _cars = [_wb,_wf];
 
    // spawned sounds ,gun and train bend
 
        [_train] spawn {
        _train = _this select 0;
        _delay = 1.5;
 
            while {true} do
            {
            _sound = if (speed _train < 10) then {"engine"}else{"train"};
            //if (speed _train < 10) then {_delay = 1.5}else{_delay = 5.5};
            _initCode = "this say3D " + str(_sound);
            [nil,_train,rSAY,[_sound, 300]] call RE;
            sleep _delay;
            };
 
        };
 
        _horn = {
        _train = _this select 0;
        _initCode = "this say3D 'trainhorn'";
        [nil,_train,rSAY,['trainhorn', 500]] call RE;
        };
 
        _link = {
        _newdir = _this select 0;
        _train = _this select 1;
        _car = _this select 2;
        _trackpos = _this select 3;
        _curve = true;
        _newdir = _newdir / 1.5;
        _car setdir _newdir;
        _dis = _car distance _train;
 
            while {_curve} do
            {
            _dir1 = round direction _train;
            sleep .5;
            _dir2 = round direction _train;
            _pos = if (_dir1 == _dir2) then {position _car}else{[0,0,0]};
            if (str(_pos) != "[0,0,0]") then {waituntil {_car distance _pos > _dis};_car setdir 0;_curve = false};
            };
 
        };
    _classname = "helihEmpty"; _location = _pos;
    _fire = createVehicle [_classname, _location, [], 0, "CAN_COLLIDE"];
    _h1 = _fire;
    _fire = createVehicle [_classname, _location, [], 0, "CAN_COLLIDE"];
    _h2 = _fire;
    //_h1 = "helihEmpty" createVehicle _pos;
    //_h2 = "helihEmpty" createVehicle _pos;
    sleep .1;
 
    _classname = "Rabbit"; _location = _pos;
    _fire = createVehicle [_classname, _location, [], 0, "CAN_COLLIDE"];
    _driver = _fire;
    //_driver = "Rabbit" createVehicle _pos;
 
    //removeallweapons _driver;
    _driver allowdamage false;
    _driver disableAI "MOVE";
    _driver disableAI "ANIM";
    _driver setdir getdir _train;
    sleep .1;
    _train setvariable ["driver",_driver,false];
    _train attachto [_driver,[0,-4.5,2.3]];
    sleep .1;
    _vector = [0,0,.001];
    _driver setpos _pos;
 
    _h1 attachto [_train,[0,-7,-1.8]];
    _wb attachto [_h1,[-.35,-5.8,1.51]];
    _h2 attachto [_wb,[.39,-5.7,1.25]];
    _wf attachto [_h2,[0.05,-9,-2.225]];
    sleep .1;
    _driver setpos _pos;
    _driver setvectorUp _vector;
    _train setvectorUp _vector;
    sleep .1;
 
    // the moving stuff
 
    _dir = getdir _driver;
    _vel = velocity _driver;
    _speed = 5;
    _driver setVelocity [(_vel select 0)+(sin _dir*_speed),(_vel select 1)+(cos _dir*_speed),0];
    _a = 0;
    _b = _j;
    _c = _oppsite;
    _delay = 0.4;
    _track = ((getpos _train) nearestobject (_rail select _j));
    _trackpos = position _track;
    _trackdir = 0;
    _trackold = _track;
    _i = _rail select _b;
    _newdir = 0;
 
        while {true} do
        {
        _pos = position _driver;
 
            if (_track distance _driver < 5) then
            {
            _stopdelay = 0;
            if (_b == 0) then {_c = 0;};
            if (_rail select _b in _stops) then {_stopdelay = _stoptime;if !(alive _gunner) then {};};
            if (_b >= _mynum) then {_c = 1;};
            if (_c == 0) then {_b = _b + 1}else{_b = _b - 1};
            _i = _rail select _b;
            if (_i in _hornblow) then {[_train] spawn _horn};
            if (_i in _stops) then {[_train] spawn _horn;};
            _track = (_pos nearestobject _i);
            _trackpos = position _track;
            sleep _stopdelay;
            }else{
            _ang = ((_trackpos select 0)-(_pos select 0)) atan2 ((_trackpos select 1)-(_pos select 1));
            _trackdir = ((_ang + 360) % 360);
            _newdir = ((direction _train) - _trackdir);
            if ((abs _newdir > 2) && (_trackold != _track)) then {_trackold = _track;{[_newdir,_train,_x] spawn _link} foreach _cars;};
            sleep _delay;
            _driver setdir _trackdir;
            };
 
        _dir = getdir _driver;
        _vel = velocity _driver;
        _speed = if (speed _driver < _topspeed) then {2.2}else{0};
        if (speed _driver < 10) then {_delay = 0.077}else{_delay = 0.13};
        _driver setVelocity [(_vel select 0)+(sin _dir*_speed),(_vel select 1)+(cos _dir*_speed),0];
        };
    };
 
 
    chooChooCode2 = {
        waitUntil { !isNil ("dayz_locationCheck") };
        _train = _this select 3;
        while {true} do
        {
            _pos = getPos _train;
            sleep 15;
            if ((_pos distance _train) < 10) then
            {
                terminate dayz_locationCheck;
                {
                    deleteVehicle _x;
                } foreach (nearestObjects [[6684,2781], ["land_cncblock_stripes", "hiluxwreck"], 10] + nearestObjects [[7976,3288], ["uazwreck"], 10]);
                _this spawn chooChooCode;
            };
        };
    };
    waitUntil { !isNil ("trackChernoElectro") };
    trackChernoElectro spawn chooChooCode2;
};
 
if (isServer) then
{
    TrainCherno = "Land_loco_742_blue" createVehicle ([6566,2658,0]);
    _pos = position TrainCherno;
    TrainBoxCherno = "Land_wagon_box" createVehicle _pos;
    TrainFlatCherno = "Land_wagon_flat" createVehicle _pos;
    railCherno = [962153,962154,962152,962147,962150,962151,962148,962138,962139,962142,962143,962141,962140,962467,962470,
    962465,962466,962472,962471,962464,962480,962479,962478,962481,962155,962157,962444,962156,962158,962452,962449,962448,
    962447,962450,962446,962451,962454,962453,962455,962445,962456,962457,962458,962460,962459,962462,962461,962670,962671,
    962669,962673,962672,962676,962674,962675,962681,962679,962677,962678,962680,962683,962684,962682,962685,962687,962689,962686,
    962690,962688,962691,962693,962694,962692,962695,962697,962698,962696,962699,962700,962701,962702,962181,962182,962179,962180,962183,
    962185,962186,962187,962184,962188,962189,962190,962191,962192,962197,962194,962198,962193,962196,962195,962199,962202,962200,962203,962201,
    962204,962206,962205,962207,962208,962209,962210,962211,962213,962212,962214,962217,962219,962215,962220,962216,962218,962223,962221,962222,962224,
    962228,962225,962226,962227,962242,962237,962238,962243,962246,962245,962247,962248,962272,962273,962274,962276,962277,962295,962297,962260,962252,962254,962336,366912,
    962338];
    stopsCherno = [962154,962480,962673,962700,962218,366912];
    hornblowCherno = [962138,962158,962682,962198,962222];
 
    trackChernoElectro = [railCherno,stopsCherno,hornblowCherno,TrainCherno,TrainBoxCherno,TrainFlatCherno];
    publicVariable "trackChernoElectro";
};