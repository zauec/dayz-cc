/*
_item spawn player_wearClothes;
TODO: female
*/
private["_item","_isFemale","_itemNew","_item","_onLadder","_model","_hasclothesitem","_config","_text"];
_item = _this;
call gear_ui_init;
_onLadder = (getNumber (configFile >> "CfgMovesMaleSdr" >> "States" >> (animationState player) >> "onLadder")) == 1;
if (_onLadder) exitWith {cutText [(localize "str_player_21") , "PLAIN DOWN"]};

_hasclothesitem = _this in magazines player;
_config = configFile >> "CfgMagazines";
_text = getText (_config >> _item >> "displayName");

if (!_hasclothesitem) exitWith {cutText [format[(localize "str_player_31"),_text,"wear"] , "PLAIN DOWN"]};

if (vehicle player != player) exitWith {cutText ["You may not change clothes while in a vehicle", "PLAIN DOWN"]};

_isFemale = ((typeOf player == "SurvivorW2_DZ")||(typeOf player == "BanditW1_DZ"));
if (_isFemale) exitWith {cutText ["Currently Female Characters cannot change to this skin. This will change in a future update.", "PLAIN DOWN"]};

private["_itemNew","_myModel","_humanity","_isBandit","_isHero", "_toHero", "_toBandit"];
_myModel = (typeOf player);
_humanity = player getVariable ["humanity",0];
_isBandit = _humanity <= -10000;
_toBandit = (_humanity > -10000)&&(_humanity <= -2000);
_toHero =  (_humanity >= 5000)&&(_humanity < 10000);
_isHero = _humanity >= 10000;
_itemNew = "Skin_" + _myModel;

if ( !(isClass(_config >> _itemNew)) ) then {
	_itemNew = if (!_isFemale) then {"Skin_Survivor2_DZ"} else {"Skin_SurvivorW2_DZ"}; 
};

switch (_item) do {
	case "Skin_Sniper1_DZ": {
		_model = ["Skin_Sniper1_DZ", "BAF_Soldier_SniperH_MTP", "BAF_Soldier_SniperH_W", "BAF_Soldier_SniperN_MTP", "BAF_Soldier_Sniper_MTP", "FR_Corpsman"] call BIS_fnc_selectRandom;
	};
	case "Skin_Camo1_DZ": {
		_model = ["CDF_Soldier", "CDF_Commander", "CDF_Soldier_AR", "CDF_Soldier_Light", "CDF_Soldier_Medic", "CDF_Soldier_Militia"] call BIS_fnc_selectRandom;
	};
	case "Skin_Soldier1_DZ": {
		_model = ["USMC_Soldier_Crew", "USMC_Soldier_Light", "USMC_Soldier_Medic", "USMC_Soldier_Officer", "BAF_Soldier_L_DDPM", "BAF_Soldier_DDPM"] call BIS_fnc_selectRandom;
	};
	case "Skin_Survivor2_DZ": {
		_model = ["Survivor2_DZ", "INS_Soldier_Pilot", "INS_Woodlander1", "INS_Woodlander2", "INS_Woodlander3"] call BIS_fnc_selectRandom;
		
		if (_isBandit) then {
			_model = ["INS_Lopotev", "INS_Bardak", "GUE_Soldier_Medic"] call BIS_fnc_selectRandom;
		};
		if (_toBandit) then {
			_model = "Bandit1_DZ";
			_model = ["INS_Commander", "INS_Soldier_1", "INS_Soldier_Medic", "Bandit1_DZ" ] call BIS_fnc_selectRandom;
		};
		
		if (_toHero) then {
			_model = ["RU_Commander", "RU_Soldier_Light", "RU_Soldier_Medic", "US_Soldier_Light_EP1", "US_Soldier_Medic_EP1", ""] call BIS_fnc_selectRandom;
		};	
		
		if (_isHero) then {
			_model = ["CZ_Soldier_DES_EP1", "Survivor3_DZ", "CZ_Soldier_Light_DES_EP1", "GER_Soldier_Medic_EP1", "BAF_Soldier_Officer_DDPM"] call BIS_fnc_selectRandom;
		};
	};
};

if (_model != _myModel) then {
	player removeMagazine _item;
	player addMagazine _itemNew;
	[dayz_playerUID,dayz_characterID,_model] spawn player_humanityMorph;
};