#CS = Comment Block Start ==========================================================================
======================================
|  	  Stygian Gemstones Farm bot     |
|			  TonReuf   		     |
======================================
;
; Run it as Assassin or Mesmer or Ranger
;
; Rewritten for BotsHub: Gahais
; stygian gemstone farms in the Stygian Veil based on below articles:
https://gwpvx.fandom.com/wiki/Build:Me/A_Stygian_Farmer
https://gwpvx.fandom.com/wiki/Build:R/N_HM_Stygian_Veil_Trapper
;
#CE = Comment Block End ============================================================================

#include-once
#RequireAdmin
#NoTrayIcon

Opt('MustDeclareVars', True)

#include '../lib/GWA2.au3'
#include '../lib/GWA2_ID.au3'
#include '../lib/Utils.au3'

#Region Configuration
; === Build ===
Global Const $StygianAssasinSkillBar = "OwVTI4h9X6mSGYFct0E4uM0ZCCA"
Global Const $StygianMesmerSkillBar = "OQdUASBPmfS3UyArgrlmA3lhOTQA"
Global Const $StygianRangerSkillBar = "OgQTcybiZK5o5Y5wSIXc465o7AA"
Global $StygianPlayerProfession = $ID_Mesmer ;~ global variable to remember player's profession in setup and avoid creating Dll structs over and over
;Global Const $StygianMonkHeroSkillBar = "OgMSY5LHAAAAAAAAA0E6"
Global Const $StygianMonkHeroSkillBar = "OwITAnHb5Qe/zhx7jpE6+G"

;~ You can select which monk hero to use in the farm here, among 3 heroes available. Uncomment below line for hero to use
;~ party hero ID that is used to add hero to the party team
;Global Const $StygianHeroPartyID = $ID_Dunkoro
;Global Const $StygianHeroPartyID = $ID_Tahlkora
Global Const $StygianHeroPartyID = $ID_Ogden
Global Const $StygianHeroIndex = 1 ;~ index of first hero party member in team, player index is 0
Global $StygianHeroAgentID = Null ;~ agent ID that is randomly assigned to hero in exploration areas
Global $StygianPlayerProfession = $ID_Mesmer ;~ global variable to remember player's profession in setup and avoid creating Dll structs over and over


Global Const $Stygian_WastrelsDemise		= 1
Global Const $Stygian_WastrelsWorry			= 2
Global Const $Stygian_ShadowSanctuary		= 3
Global Const $Stygian_Mindbender			= 4
Global Const $Stygian_Channeling			= 5
Global Const $Stygian_DwarvenStability		= 6
Global Const $Stygian_ShadowOfHaste			= 7
Global Const $Stygian_Dash					= 8

Global Const $Stygian_Ranger_DustTrap		= 1
Global Const $Stygian_Ranger_SpikeTrap		= 2
Global Const $Stygian_Ranger_FlameTrap		= 3
Global Const $Stygian_Ranger_MarkOfPain		= 4
Global Const $Stygian_Ranger_EbonStandard	= 5
Global Const $Stygian_Ranger_TrappersSpeed	= 6
Global Const $Stygian_Ranger_Winnowing		= 7
Global Const $Stygian_Ranger_MuddyTerrain	= 8

;~ Monk protector hero
Global Const $Stygian_Hero_BalthazarSpirit	= 1
Global Const $Stygian_Hero_WatchfulSpirit		= 2
Global Const $Stygian_Hero_LifeBarrier		= 3
Global Const $Stygian_Hero_LifeBond			= 4
Global Const $Stygian_Hero_VitalBlessing		= 5
Global Const $Stygian_Hero_BlessedSignet		= 6
Global Const $Stygian_Hero_Succor			= 7
Global Const $Stygian_Hero_EdgeOfExtinction	= 8
#EndRegion Configuration

; ==== Constants ====
Global Const $GemstoneStygianFarmInformations = '' & @CRLF _
	& 'This bot farms stygian gemstones (1 of 4 types) in Stygian Veil location' & @CRLF _
	& 'Mesmer/Assassin builds work by exploiting Guild Wars bug in pathing AI, which causes mobs to not attack player' & @CRLF _
	& 'Player needs to have access to Gate of Anguish outpost which has exit to Stygian Veil location' & @CRLF _
	& 'Recommended to have maxed out Lightbringer title. If not maxed out then this farm is good for raising lightbringer rank' & @CRLF _
	& 'Can switch to normal mode in case of low success rate but hard mode has better loots' & @CRLF _
	& 'Gemstones can be exchanged into armbrace of truth (15 of each type) or coffer of whisper (1 of each type)' & @CRLF _
	& 'This farm is based on below articles:' & @CRLF _
	& 'https://gwpvx.fandom.com/wiki/Build:Me/A_Stygian_Farmer' & @CRLF _
	& 'https://gwpvx.fandom.com/wiki/Build:R/N_HM_Stygian_Veil_Trapper' & @CRLF
;~ Average duration ~ 5 minutes
Global Const $GEMSTONE_STYGIAN_FARM_DURATION = 5 * 60 * 1000
Global Const $MAX_GEMSTONE_STYGIAN_FARM_DURATION = 10 * 60 * 1000
Global $GemstoneStygianFarmTimer = Null
Global $GEMSTONE_STYGIAN_FARM_SETUP = False
Global Const $Stygians_Range_Short = 800
Global Const $Stygians_Range_Long = 1200


;~ Main loop function for farming stygian gemstones
Func GemstoneStygianFarm($STATUS)
	;~ Need to be done here in case bot comes back from inventory management
	If Not $GEMSTONE_STYGIAN_FARM_SETUP Then
		If SetupGemstoneStygianFarm() == $FAIL Then Return $FAIL
	EndIf
	If $STATUS <> 'RUNNING' Then Return $PAUSE

	If GoToStygianVeil() == $FAIL Then Return $FAIL
	Local $result = GemstoneStygianFarmLoop()
	If $result == $SUCCESS Then
		Info("Successfully cleared stygian mobs")
	ElseIf $result == $FAIL Then
		If IsPlayerDead() Then Warn('Player died')
		Info("Could not clear stygian mobs")
	EndIf
	Info("Returning back to the outpost")
	Sleep(1000)
	Resign()
	Sleep(4000)
	ReturnToOutpost()
	Sleep(6000)
	Return $result
EndFunc


Func SetupGemstoneStygianFarm()
	Info('Setting up farm')
	If GetMapID() <> $ID_Gate_Of_Anguish Then
		TravelToOutpost($ID_Gate_Of_Anguish, $DISTRICT_NAME)
	Else ;~ resigning to return to outpost in case when player is in one of 4 DoA farm areas that have the same map ID as Gate of Anguish outpost (474)
		Resign()
		Sleep(4000)
		ReturnToOutpost()
		Sleep(6000)
	EndIf
	SwitchToHardModeIfEnabled()
	Sleep(500)
	SetDisplayedTitle($ID_Lightbringer_Title)
	Sleep(500)
    If SetupTeamStygianFarm() == $FAIL Then Return $FAIL
	Sleep(500)
	If SetupPlayerStygianFarm() == $FAIL Then Return $FAIL
    Sleep(500)
	If DllStructGetData(GetMyAgent(), 'Primary') == $ID_Ranger Then
		SetupHeroStygianFarm()
    	Sleep(500)
    EndIf
	$GEMSTONE_STYGIAN_FARM_SETUP = True
	Info('Preparations complete')
EndFunc


Func SetupTeamStygianFarm()
	Info('Setting up team')
	Sleep(500)
	LeaveParty()
	Sleep(500)
    If DllStructGetData(GetMyAgent(), 'Primary') == $ID_Ranger Then
		AddHero($StygianHeroPartyID)
		Sleep(500)
		If GetPartySize() <> 2 Then
			Warn("Could not add monk hero to team. Team size different than 2")
			Return $FAIL
		EndIf
	EndIf
EndFunc


Func SetupPlayerStygianFarm()
	Info('Setting up player build skill bar')
	Sleep(500)
	If DllStructGetData(GetMyAgent(), 'Primary') == $ID_Assassin Then
		$StygianPlayerProfession = $ID_Assassin
		LoadSkillTemplate($StygianAssasinSkillBar)
    ElseIf DllStructGetData(GetMyAgent(), 'Primary') == $ID_Mesmer Then
		$StygianPlayerProfession = $ID_Mesmer
		LoadSkillTemplate($StygianMesmerSkillBar)
    ElseIf DllStructGetData(GetMyAgent(), 'Primary') == $ID_Elementalist Then
		$StygianPlayerProfession = $ID_Elementalist
		LoadSkillTemplate($StygianElementalistSkillBar)
    ElseIf DllStructGetData(GetMyAgent(), 'Primary') == $ID_Ranger Then
		$StygianPlayerProfession = $ID_Ranger
		LoadSkillTemplate($StygianRangerSkillBar)
    Else
		Warn("You need to run this farm bot as Assassin or Mesmer or Elementalist or Ranger")
		Return $FAIL
    EndIf
	ChangeWeaponSet(4) ;~ change to other weapon slot or comment this line if necessary
	Sleep(500)
EndFunc


Func SetupHeroStygianFarm()
	Info('Setting up hero build skill bar')
    Sleep(500)
	LoadSkillTemplate($StygianMonkHeroSkillBar, $StygianHeroIndex)
    Sleep(500)
	SetHeroAggression($StygianHeroIndex, $ID_Hero_avoiding)
    DisableStygianHeroSkills() ;~ disabling 1,2,3,4,5,7 skills for monk hero, leaving 6,8 skills enabled
EndFunc


Func DisableStygianHeroSkills()
	Sleep(500)
	For $i = 1 To 8
		DisableHeroSkillSlot($StygianHeroIndex, $i)
		Sleep(500)
	Next
EndFunc


;~ exit gate of Anguish outpost by moving into portal that leads into farming location - Stygian Veil
Func GoToStygianVeil()
	Info('Moving to Stygian Veil')
	;~ Unfortunately all 4 gemstone farm explorable locations have the same map ID as Gate of Anguish outpost, so it is hard to tell if player left the outpost
	;~ Therefore below loop checks if player is in close range of coordinates of that start zone where player initially spawns in Stygian Veil
	Local Static $StartX = -364
	Local Static $StartY = -10445
	Local Static $StartZoneRange = 2000
	Local $TimerZoning = TimerInit()
	While GetDistanceToPoint(GetMyAgent(), $StartX, $StartY) > $StartZoneRange
		If TimerDiff($TimerZoning) > 120000 Then ;~ 120 seconds max time for leaving outpost in case of bot getting stuck
			Info('Could not zone to Stygian Veil')
			Return $FAIL
		EndIf
		MoveTo(6798, -15867)
		MoveTo(1315, -17924)
		MoveTo(-785, -18969)
		Move(-1100, -20000, 0)
		Sleep(12000) ;~ wait 12 seconds to ensure that player exited outpost
	WEnd
EndFunc


Func GemstoneStygianFarmLoop()
	Sleep(2000)
	If IsPlayerDead() Then Return $FAIL
	Info("Starting Farm")
	$GemstoneStygianFarmTimer = TimerInit() ;~ starting run timer, if run lasts longer than max time then bot must have gotten stuck and fail is returned to restart run

	StygianMoveToPoint(2415, -10451)
	RandomSleep(14000)
	StygianMoveToPoint(7010, -9050)
	RandomSleep(250)
	If GetLightbringerTitle() < 50000 Then
		Info("Taking Blessing")
		GoNearestNPCToCoords(7309, -8902)
		Sleep(1000)
		Dialog(0x85)
		Sleep(500)
	EndIf
	Info("Taking Quest")
	GoNearestNPCToCoords(7188, -9108)
	Sleep(1000)
	Dialog(0x82E601)
	Sleep(250)

	If IsPlayerDead() Then Return $FAIL
	If $StygianPlayerProfession == $ID_Assassin Or $StygianPlayerProfession == $ID_Mesmer Then
		StygianFarmMesmerAssassin()
	ElseIf $StygianPlayerProfession == $ID_Ranger Then
		StygianFarmRanger()
	EndIf

	Return IsPlayerAlive()? $SUCCESS : $FAIL
EndFunc


Func StygianFarmMesmerAssassin()
	If IsPlayerDead() Then Return $FAIL
	StygianJobMesmerAssassin()
	StygianMoveToPoint(13240, -10006)
	StygianJobMesmerAssassin()
	MoveTo(13240, -10006)
	;~ Too hard to aggro the 2 groups after that, so pick up loot
	Local Static $pick_up_event = True
	If $pick_up_event Then
		HideToLoot()
	Else
		If IsPlayerAlive() Then PickUpItems(Null, DefaultShouldPickItem, $Stygians_Range_Long)
	EndIf
	Return IsPlayerAlive()? $SUCCESS : $FAIL
EndFunc


Func StygianFarmRanger()
	If IsPlayerDead() Then Return $FAIL
	UseHeroSkill($StygianHeroIndex, $Stygian_Hero_Succor, GetMyAgent())
	MoveTo(10575, -8170)
	MoveTo(10871, -7842, 0)
	If IsPlayerAlive() Then RandomSleep(15000)
	MoveTo(10575, -8170)
	StygianJobRanger()
	MoveTo(7337, -9709)
	MoveTo(9071, -7330)
	If IsPlayerAlive() Then RandomSleep(10000)
	StygianJobRanger()
;~    MoveTo(7337, -9709)
;~    MoveTo(9071, -7330)
;~    If IsPlayerAlive() Then RandomSleep(10000)
;~    StygianJobRanger()
;~    MoveTo(7337, -9709)
;~    MoveTo(9071, -7330)
;~    If IsPlayerAlive() Then RandomSleep(10000)
;~    StygianJobRanger()
	Return IsPlayerAlive()? $SUCCESS : $FAIL
EndFunc


Func StygianJobMesmerAssassin()
	Local Static $SomethingToPickUp = False
	If IsPlayerDead() Then Return $FAIL
	StygianMoveToPoint(10575, -8170)
	MoveTo(10871, -7842, 0)
	RandomSleep(15000)
	StygianMoveToPoint(10575, -8170)
	StygianMoveToPoint(12853, -9936)
	RandomSleep(500)
	If $SomethingToPickUp And IsPlayerAlive() Then PickUpItems(Null, DefaultShouldPickItem, $Stygians_Range_Long)
	MoveTo(13128, -10084)
	MoveTo(13082, -9788, 0)
	RandomSleep(500)
	If IsRecharged($Stygian_DwarvenStability) Then
		UseSkillEx($Stygian_DwarvenStability)
		RandomSleep(100)
	EndIf
	UseSkillEx($Stygian_ShadowOfHaste)
	MoveTo(13240, -10006)
	MoveTo(9437, -9283)
	UseSkillEx($Stygian_Mindbender)
	MoveTo(8567, -9050) ;~ aggro mobs
	RandomSleep(200)
	MoveTo(12376, -9557)
	RandomSleep(1500)
	UseSkillEx($Stygian_Dash)
	RandomSleep(2700)
	KillStygianMobsUsingWastrelSkills()
	$SomethingToPickUp = True
	Return IsPlayerAlive()? $SUCCESS : $FAIL
EndFunc


Func StygianJobRanger()
	If IsPlayerDead() Then Return $FAIL
	MoveTo(10844, -10205)
	MoveTo(10313, -11156)
	MoveTo(8269, -11160, 10)
	CommandHero($StygianHeroIndex, 9492, -11484)
	If IsRecharged($Stygian_Ranger_Winnowing) Then UseSkillEx($Stygian_Ranger_Winnowing)
	RandomSleep(2000)
	MoveTo(8177, -11171, 10)
	If IsRecharged($Stygian_Ranger_TrappersSpeed) Then UseSkillEx($Stygian_Ranger_TrappersSpeed)
	Do
		RandomSleep(100)
	Until IsRecharged($Stygian_Ranger_DustTrap) Or IsPlayerDead()
	If IsRecharged($Stygian_Ranger_DustTrap) Then UseSkillEx($Stygian_Ranger_DustTrap)
	Do
		RandomSleep(100)
	Until IsRecharged($Stygian_Ranger_SpikeTrap) Or IsPlayerDead()
	If IsRecharged($Stygian_Ranger_SpikeTrap) Then UseSkillEx($Stygian_Ranger_SpikeTrap)
	Do
		RandomSleep(100)
	Until IsRecharged($Stygian_Ranger_FlameTrap) Or IsPlayerDead()
	If IsRecharged($Stygian_Ranger_FlameTrap) Then UseSkillEx($Stygian_Ranger_FlameTrap)
	If IsRecharged($Stygian_Ranger_TrappersSpeed) Then UseSkillEx($Stygian_Ranger_TrappersSpeed)
	Do
		RandomSleep(100)
	Until IsRecharged($Stygian_Ranger_SpikeTrap) Or IsPlayerDead()
	If IsRecharged($Stygian_Ranger_SpikeTrap) Then UseSkillEx($Stygian_Ranger_SpikeTrap)
	Do
		RandomSleep(100)
	Until IsRecharged($Stygian_Ranger_FlameTrap) Or IsPlayerDead()
	If IsRecharged($Stygian_Ranger_FlameTrap) Then UseSkillEx($Stygian_Ranger_FlameTrap)
	Do
		RandomSleep(100)
	Until IsRecharged($Stygian_Ranger_DustTrap) Or IsPlayerDead()
	If IsRecharged($Stygian_Ranger_DustTrap) Then UseSkillEx($Stygian_Ranger_DustTrap)
	If IsRecharged($Stygian_Ranger_MuddyTerrain) Then UseSkillEx($Stygian_Ranger_MuddyTerrain)
	RandomSleep(2000)
	If IsRecharged($Stygian_Ranger_TrappersSpeed) Then UseSkillEx($Stygian_Ranger_TrappersSpeed)
	Do
		RandomSleep(100)
	Until IsRecharged($Stygian_Ranger_SpikeTrap) Or IsPlayerDead()
	If IsRecharged($Stygian_Ranger_SpikeTrap) Then UseSkillEx($Stygian_Ranger_SpikeTrap)
	Do
		RandomSleep(100)
	Until IsRecharged($Stygian_Ranger_FlameTrap) Or IsPlayerDead()
	If IsRecharged($Stygian_Ranger_FlameTrap) Then UseSkillEx($Stygian_Ranger_FlameTrap)
	Do
		RandomSleep(100)
	Until IsRecharged($Stygian_Ranger_DustTrap) Or IsPlayerDead()
	Do
		RandomSleep(100)
	Until IsRecharged($Stygian_Ranger_SpikeTrap) Or IsPlayerDead()
	If IsRecharged($Stygian_Ranger_SpikeTrap) Then UseSkillEx($Stygian_Ranger_SpikeTrap)
	Do
		RandomSleep(100)
	Until IsRecharged($Stygian_Ranger_FlameTrap) Or IsPlayerDead()
	If IsRecharged($Stygian_Ranger_FlameTrap) Then UseSkillEx($Stygian_Ranger_FlameTrap)
	UseHeroSkill($StygianHeroIndex, $Stygian_Hero_EdgeOfExtinction)
	;TargetNearestEnemy()
	Local $target = GetNearestEnemyToAgent(GetMyAgent())
	ChangeTarget($target)
	UseSkill($Stygian_Ranger_MarkOfPain, $target)
	Do
		RandomSleep(50)
	Until GetHasHex($target) Or IsPlayerDead()
	MoveTo(8368, -11244)
	If IsRecharged($Stygian_Ranger_EbonStandard) Then UseSkillEx($Stygian_Ranger_EbonStandard)
	While CountFoesInRangeOfAgent(GetMyAgent(), $Stygians_Range_Long) > 0 And IsPlayerAlive()
		If TimerDiff($GemstoneStygianFarmTimer) > $MAX_GEMSTONE_STYGIAN_FARM_DURATION Then Return $FAIL
		RandomSleep(100)
	WEnd
	CancelAll()
	RandomSleep(500)
	If IsPlayerAlive() Then PickUpItems(Null, DefaultShouldPickItem, $Stygians_Range_Long)
	Return IsPlayerAlive()? $SUCCESS : $FAIL
EndFunc


Func KillStygianMobsUsingWastrelSkills()
	If IsPlayerDead() Then Return $FAIL
	Local $me, $target, $distance
	RandomSleep(500)

	While CountFoesInRangeOfAgent(GetMyAgent(), $Stygians_Range_Long) > 0 And IsPlayerAlive()
		If TimerDiff($GemstoneStygianFarmTimer) > $MAX_GEMSTONE_STYGIAN_FARM_DURATION Then Return $FAIL
		$me = GetMyAgent()
		$target = GetNearestEnemyToAgent(GetMyAgent())
		ChangeTarget($target)
		If GetHealth(GetMyAgent()) < 300 And IsRecharged($Stygian_ShadowSanctuary) And GetEnergy() > 5 Then UseSkillEx($Stygian_ShadowSanctuary)
		If IsRecharged($Stygian_Channeling) And GetEnergy() > 5 Then
			UseSkillEx($Stygian_Channeling)
			RandomSleep(100)
		EndIf
		$distance = GetDistance($me, $target)
		If IsRecharged($Stygian_WastrelsDemise) And GetEnergy() > 5 And $distance < $Stygians_Range_Short Then
			UseSkill($Stygian_WastrelsDemise, $target)
			RandomSleep(300)
		EndIf
		$distance = GetDistance($me, $target)
		If IsRecharged($Stygian_WastrelsWorry) And GetEnergy() > 5 And $distance < $Stygians_Range_Short Then
			UseSkill($Stygian_WastrelsWorry, $target)
			RandomSleep(300)
		EndIf
		RandomSleep(100)
	WEnd
	RandomSleep(500)
	Return IsPlayerAlive()? $SUCCESS : $FAIL
;~ 	If IsPlayerAlive() Then PickUpItems(Null, DefaultShouldPickItem, $Stygians_Range_Long)
EndFunc


Func StygianCheckBuffs()
	If IsPlayerDead() Then Return $FAIL
	If IsRecharged($Stygian_DwarvenStability) And GetEnergy() > 5 Then UseSkillEx($Stygian_DwarvenStability)
	If IsRecharged($Stygian_Dash) And GetEnergy() > 5 Then UseSkillEx($Stygian_Dash)
	Return IsPlayerAlive()? $SUCCESS : $FAIL
EndFunc


Func HideToLoot()
	If IsPlayerDead() Then Return $FAIL
	StygianMoveToPoint(10575, -8170)
	MoveTo(10871, -7842, 0)
	RandomSleep(15000)
	StygianMoveToPoint(10575, -8170)
	StygianMoveToPoint(12853, -9936)
	RandomSleep(500)
	If IsPlayerAlive() Then PickUpItems(Null, DefaultShouldPickItem, $Stygians_Range_Long)
	Return IsPlayerAlive()? $SUCCESS : $FAIL
EndFunc


Func StygianMoveToPoint($destinationX, $destinationY, $random = 150)
	If IsPlayerDead() Then Return $FAIL
	Local $me, $blocked, $angle, $target
	Local $ChatStuckTimer = TimerInit()
	Move($destinationX, $destinationY, $random)
	While IsPlayerAlive() And GetDistanceToPoint(GetMyAgent(), $destinationX, $destinationY) > $random * 1.5
	    StygianCheckBuffs()
		;TargetNearestEnemy()
	    $target = GetNearestEnemyToAgent(GetMyAgent())
	    ChangeTarget($target)
		RandomSleep(50)
		$me = GetMyAgent()
		If GetIsDead($me) Then Return $FAIL
		StygianCheckBuffs()
		If Not IsPlayerMoving() Then
			StygianCheckBuffs()
			$blocked += 1
			If $blocked < 5 Then
				Move($destinationX, $destinationY, $random)
			ElseIf $blocked < 30 Then
				$angle += 40
				StygianCheckBuffs()
				Move(DllStructGetData($me, 'X')+300*sin($angle), DllStructGetData($me, 'Y')+300*cos($angle))
			EndIf
		Else
			If $blocked > 0 Then
				If TimerDiff($ChatStuckTimer) > 3000 Then	; use a timer to avoid spamming /stuck
					SendChat("stuck", "/")
					$ChatStuckTimer = TimerInit()
				EndIf
				$blocked = 0
			EndIf
			StygianCheckBuffs()
			If GetDistance($me, $target) > 1100 Then ; target is far, we probably got stuck.
				If TimerDiff($ChatStuckTimer) > 3000 Then ; dont spam
					SendChat("stuck", "/")
					$ChatStuckTimer = TimerInit()
					If GetDistance($me, $target) > 1100 Then ; we werent stuck, but target broke aggro. select a new one.
						;TargetNearestEnemy()
						$target = GetNearestEnemyToAgent(GetMyAgent())
						ChangeTarget($target)
					EndIf
				EndIf
			EndIf
		EndIf
	Wend
	Return IsPlayerAlive()? $SUCCESS : $FAIL
EndFunc