#CS = Comment Block Start ==========================================================================
; Author: An anonymous fan of Dhuum
; Copyright 2025 caustic-kronos
;
; Licensed under the Apache License, Version 2.0 (the 'License');
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
; http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an 'AS IS' BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.
#CE = Comment Block End ============================================================================

#include-once
#RequireAdmin
#NoTrayIcon

#include '../lib/GWA2.au3'
#include '../lib/GWA2_ID.au3'
#include '../lib/Utils.au3'


Opt('MustDeclareVars', 1)

; ==== Constants ====
Global Const $SunspearArmorInformations = 'Sunspear armor farm with 7heroes GWReborn s comp'
; Average duration ~ 15m
Global Const $SUNSPEAR_ARMOR_FARM_DURATION = 15 * 60 * 1000
Global $SUNSPEAR_ARMOR_FARM_SETUP = False

;~ Main loop for the Sunspear Armor farm
Func SunspearArmorFarm($STATUS)
	If GetMapID() <> $ID_Dajkah_Inlet_Outpost Then
		Info('Moving to Kodash Bazaar')
		DistrictTravel($ID_Dajkah_Inlet_Outpost, $DISTRICT_NAME)
		WaitMapLoading($ID_Dajkah_Inlet_Outpost, 10000, 2000)
	EndIf
	If Not $SUNSPEAR_ARMOR_FARM_SETUP Then SunspearArmorSetup()

	AdlibRegister('TrackPartyStatus', 10000)
	Local $result = SunspearArmorClean()
	AdlibUnRegister('TrackPartyStatus')
	; Temporarily change a failure into a pause for debugging :
	;If $result == $FAIL Then $result = $PAUSE
	Return $result
EndFunc

Func SunspearArmorSetup()
	;LeaveParty()
	;RandomSleep(500)
	;AddHero($ID_Norgu)
	;RandomSleep(500)
	;AddHero($ID_Gwen)
	;RandomSleep(500)
	;AddHero($ID_Razah)
	;RandomSleep(500)
	;AddHero($ID_Master_Of_Whispers)
	;RandomSleep(500)
	;AddHero($ID_Livia)
	;RandomSleep(500)
	;AddHero($ID_Olias)
	;RandomSleep(500)
	;AddHero($ID_Xandra)
	;RandomSleep(500)
	$SUNSPEAR_ARMOR_FARM_SETUP = True
	Info('Setup completed')
EndFunc

;~ Cleaning SunspearArmors func
Func SunspearArmorClean()
	GoToNPC(GetNearestNPCToCoords(-2884, -2572))
	RandomSleep(250)
	Dialog(0x00000087)
	RandomSleep(500)
	WaitMapLoading($ID_Dajkah_Inlet_Mission, 10000, 2000)
	MoveTo(25752.28, -3139.02)
	RandomSleep(62000)
	If MoveAggroAndKill(22595, -484) Then Return $FAIL
	If MoveAggroAndKill(21032, 1357) Then Return $FAIL
	If MoveAggroAndKill(20006, 3631) Then Return $FAIL
	If MoveAggroAndKill(20548, 4762, 'Lord 1') Then Return $FAIL
	If MoveAggroAndKill(20834, 5205, 'Cleaning') Then Return $FAIL
	If MoveAggroAndKill(20548, 4762) Then Return $FAIL
	MoveTo(18991, 3166)
	Info('Bridge 1')
	MoveTo(17809, 3999)
	Info('Bridge 2')
	If MoveAggroAndKill(3043, -625, 'Cleaning right downstairs') Then Return $FAIL
	If MoveAggroAndKill(-459, -2790, 'Cleaning left downstairs') Then Return $FAIL
	MoveTo(-2337, -5236)
	If MoveAggroAndKill(-3041, -5971, 'Cleaning left upstairs') Then Return $FAIL
	If MoveAggroAndKill(-4624, -5597) Then Return $FAIL
	If MoveAggroAndKill(-3602, -4455, 'Lord 2') Then Return $FAIL
	If MoveAggroAndKill(-4624, -5597) Then Return $FAIL
	If MoveAggroAndKill(-3041, -5971) Then Return $FAIL
	If MoveAggroAndKill(-459, -2790) Then Return $FAIL
	If MoveAggroAndKill(3043, -625) Then Return $FAIL
	MoveTo(4878, 2035)
	If MoveAggroAndKill(5258, 2388, 'Cleaning right upstairs') Then Return $FAIL
	If MoveAggroAndKill(4425, 3445, 'Lord 3') Then Return $FAIL
	MoveTo(5258, 2388)
	MoveTo(4878, 2035)
	MoveTo(-1775, 1634)
	MoveTo(-2077, 1961)
	Info('2nd portal')
	MoveTo(-22281, -1947)
	If MoveAggroAndKill(-24882, -2719) Then Return $FAIL
	If MoveAggroAndKill(-28780, -3676, 'Lord 4') Then Return $FAIL
	If MoveAggroAndKill(-24882, -2719) Then Return $FAIL
	If MoveAggroAndKill(-21963, 624, 'Last Lords gate') Then Return $FAIL
	If MoveAggroAndKill(-20928, 3428) Then Return $FAIL
	MoveTo(-20263, 4476)
	If MoveAggroAndKill(-19880, 4086, 'Lord 5') Then Return $FAIL
	RandomSleep(500)
	Resign()
	RandomSleep(3500)
	RandomSleep(12000)
	WaitMapLoading($ID_Dajkah_Inlet_Outpost, 10000, 2000)
	Return $SUCCESS
EndFunc