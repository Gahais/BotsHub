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
Global Const $NornFarmInformations = 'Norn title farm, bring solid heroes composition'
; Average duration ~ 45m
Global Const $NORN_FARM_DURATION = 45 * 60 * 1000


;~ Main loop for the norn faction farm
Func NornTitleFarm($STATUS)
	If GetMapID() <> $ID_Olafstead Then
		Info('Moving to Olafstead')
		DistrictTravel($ID_Olafstead, $DISTRICT_NAME)
		WaitMapLoading($ID_Olafstead, 10000, 2000)
	EndIf
	NorntitleSetup()

	AdlibRegister('TrackGroupStatus', 10000)
	Local $result = NornTitle()
	AdlibUnRegister('TrackGroupStatus')
	; Temporarily change a failure into a pause for debugging :
	;If $result == 1 Then $result = 2
	Return $result
EndFunc

Func NorntitleSetup()
	;LeaveGroup()
	;RndSleep(500)
	;AddHero($ID_Norgu)
	;RndSleep(500)
	;AddHero($ID_Gwen)
	;RndSleep(500)
	;AddHero($ID_Razah)
	;RndSleep(500)
	;AddHero($ID_Master_Of_Whispers)
	;RndSleep(500)
	;AddHero($ID_Livia)
	;RndSleep(500)
	;AddHero($ID_Olias)
	;RndSleep(500)
	;AddHero($ID_Xandra)
	;RndSleep(500)
	SwitchMode($ID_HARD_MODE)
EndFunc

;~ Cleaning Norntitles func
Func NornTitle()
	MoveTo(222, 756)
	MoveTo(-1435, 1217)
	RndSleep(5000)
	WaitMapLoading($ID_Varajar_Fells, 10000, 2000)
	MoveTo(-2484, 118)
	MoveTo(-3059, -419)
	MoveTo(-3301, -2008)
	MoveTo(-2034, -4512)

	Info('Taking Blessing')
	GoToNPC(GetNearestNPCToCoords(-2034, -4512))
	RndSleep(1000)
	Dialog(0x84)
	RndSleep(1000)

	If MoveAggroAndKill(-5278, -5771, 'Berzerker') Then Return 1
	If MoveAggroAndKill(-5456, -7921, 'Berzerker') Then Return 1
	If MoveAggroAndKill(-8793, -5837, 'Berzerker') Then Return 1

	If MoveAggroAndKill(-14092, -9662, 'Vaettir and Berzerker') Then Return 1
	If MoveAggroAndKill(-17260, -7906, 'Vaettir and Berzerker') Then Return 1

	If MoveAggroAndKill(-21964, -12877, 'Jotun', 2500) Then Return 1

	Info('Taking Blessing')
	GoToNPC(GetNearestNPCToCoords(-25274, -11970))
	RndSleep(1000)

	MoveTo(-22275, -12462)
	If MoveAggroAndKill(-21671, -2163, 'Berzerker') Then Return 1
	If MoveAggroAndKill(-19592, 772, 'Berzerker') Then Return 1
	If MoveAggroAndKill(-13795, -751, 'Berzerker') Then Return 1
	If MoveAggroAndKill(-17012, -5376, 'Berzerker') Then Return 1

	Info('Taking Blessing')
	GoToNPC(GetNearestNPCToCoords(-12071, -4274))

	If MoveAggroAndKill(-8351, -2633, 'Berzerker') Then Return 1
	MoveTo(-4362, -1610)
	If MoveAggroAndKill(-4316, 4033, 'Lake') Then Return 1
	If MoveAggroAndKill(-8809, 5639, 'Lake') Then Return 1
	If MoveAggroAndKill(-14916, 2475, 'Lake') Then Return 1

	Info('Taking Blessing')
	GoToNPC(GetNearestNPCToCoords(-11282, 5466))

	If MoveAggroAndKill(-16051, 6492, 'Elemental') Then Return 1
	If MoveAggroAndKill(-16934, 11145, 'Elemental') Then Return 1
	If MoveAggroAndKill(-19378, 14555, 'Elemental') Then Return 1

	Info('Taking Blessing')
	GoToNPC(GetNearestNPCToCoords(-22751, 14163))

	If MoveAggroAndKill(-15932, 9386, '') Then Return 1
	MoveTo(-13777, 8097)
	If MoveAggroAndKill(-4729, 15385, 'Lake') Then Return 1

	Info('Taking Blessing')
	GoToNPC(GetNearestNPCToCoords(-2290, 14879))

	If MoveAggroAndKill(-1810, 4679, 'Modnir') Then Return 1
	MoveTo(-6911, 5240)
	If MoveAggroAndKill(-15471, 6384, 'Boss') Then Return 1
	MoveTo(-411, 5874)
	If MoveAggroAndKill(2859, 3982, 'Modniir') Then Return 1
	If MoveAggroAndKill(4909, -4259, 'Ice Imp') Then Return 1
	If MoveAggroAndKill(7514, -6587, 'Ice Imp') Then Return 1
	If MoveAggroAndKill(3800, -6182, 'Berserker') Then Return 1
	If MoveAggroAndKill(7755, -11467, 'Berserker') Then Return 1
	If MoveAggroAndKill(15403, -4243, 'Elementals and Griffins') Then Return 1
	If MoveAggroAndKill(21597, -6798, 'Elementals and Griffins') Then Return 1

	Info('Taking Blessing')
	GoToNPC(GetNearestNPCToCoords(24522, -6532))

	If MoveAggroAndKill(22883, -4248, '') Then Return 1
	If MoveAggroAndKill(18606, -1894, '') Then Return 1
	If MoveAggroAndKill(14969, -4048, '') Then Return 1
	If MoveAggroAndKill(13599, -7339, '') Then Return 1
	If MoveAggroAndKill(10056, -4967, 'Ice Imp') Then Return 1
	If MoveAggroAndKill(10147, -1630, 'Ice Imp') Then Return 1
	If MoveAggroAndKill(8963, 4043, 'Ice Imp') Then Return 1

	Info('Taking Blessing')
	GoToNPC(GetNearestNPCToCoords(8963, 4043))

	If MoveAggroAndKill(15576, 7156, '') Then Return 1
	If MoveAggroAndKill(22838, 7914, 'Berserker', 2500) Then Return 1

	Info('Taking Blessing')
	GoToNPC(GetNearestNPCToCoords(22961, 12757))

	MoveTo(18067, 8766)
	If MoveAggroAndKill(13311, 11917, 'Modniir and Elemental') Then Return 1

	Info('Taking Blessing')
	GoToNPC(GetNearestNPCToCoords(13714, 14520))

	If MoveAggroAndKill(11126, 10443, 'Modniir and Elemental') Then Return 1
	If MoveAggroAndKill(5575, 4696, 'Modniir and Elemental', 2500) Then Return 1
	If MoveAggroAndKill(-503, 9182, 'Modniir and Elemental') Then Return 1
	If MoveAggroAndKill(1582, 15275, 'Modniir and Elemental', 2500) Then Return 1
	If MoveAggroAndKill(7857, 10409, 'Modniir and Elemental', 2500) Then Return 1
	Return 0
EndFunc