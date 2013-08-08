// Script by Zonekiller  -- http://zonekiller.ath.cx --    -- zonekiller@live.com.au --

if !(isserver) exitwith {};

//add this to the init of the train

// this == train - 1 == if you want the gun on the back
// _nil = [this,1] execVM "Scripts\Train\Train_Start.sqf";

sleep .3;

// rail id numbers
_rail = [961656,961658,961660,961651,961676,961667,961669,961668,961671,961670,961672,961673,961684,961685,961706,961709,961688,961695,961699,961716,961717,961721,961718,961687,961732,961729,961728,961730,961739,961738,961737,961740,961744,961743,961742,961741,961745,961746,961747,961748,961752,961749,961750,961751,961755,961756,961757,961758,961753,961754,961759,961760,961761,961762,961764,961765,961763,961767,961766,961768,961769,961771,961770,961772,265791,961773,961775,961774,961776,961777,961780,961778,961781,961779,961782,961783,961784,961785,961793,961786,961790,961804,961806,961805,961807,961803,961808,961809,961810,961811,961812,961813,961814,961815,961816,961818,961817,961819,961820,961821,961822,961823,961824,961825,961826,961827,961828,961829,961830,961842,961846,961833,961861];

_mynum = count _rail;
_mynum = _mynum - 1; 

// rail id you want to dtop at
_stops = [961656,961741,961804,961861];

// rail id you want to dtop at
_hornblow = [961651,961721,961740,961755,961778,961786];

_train = _this select 0;
_gun = 1;

// train settings
_stoptime = 10;
_topspeed = 100;

_pos = position _train;
_wb = "Land_wagon_box" createVehicle _pos;
_wf = "Land_wagon_flat" createVehicle _pos;

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
		_train setVehicleInit _initCode; 
		processInitCommands;
		clearVehicleInit _train;
		sleep _delay;
		};

	};

	_horn = {
	_train = _this select 0;
	_initCode = "this say3D 'trainhorn'";
	_train setVehicleInit _initCode; 
	processInitCommands;
	clearVehicleInit _train;
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


_h1 = "helihEmpty" createVehicle _pos;
_h2 = "helihEmpty" createVehicle _pos;
sleep .1;
_driver = "RU_Soldier" createVehicle _pos;
removeallweapons _driver;
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

	if (_gun == 1) then 
	{
	_tgun = "KORD_high" createVehicle _pos;
	_tgun allowdamage false;
	sleep .5;
	_tgun attachto [_wf,[0,-6,1.6]];
	_tgun setdir (getdir _car - 180);
	};

sleep 15;

// the moving stuff

_dir = getdir _driver;
_vel = velocity _driver;
_speed = 5;
_driver setVelocity [(_vel select 0)+(sin _dir*_speed),(_vel select 1)+(cos _dir*_speed),0];
_a = 0;
_b = 0;
_c = 0;
_delay = 0.4;
_track = (_pos nearestobject (_rail select _b));
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
		if (_rail select _b in _stops) then {_stopdelay = _stoptime;if !(alive _gunner) then {[_tgun,_pos,_group] spawn _gunnercode};};
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

