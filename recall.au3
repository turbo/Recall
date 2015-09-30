#AutoIt3Wrapper_Outfile=recall.exe
#AutoIt3Wrapper_Change2CUI=y

Local $Stack        [Null]
Local $Variables    [1024][2]
Local $Functions    [7]
Local $sInput       = ""
Local $pInput       = 0

If $CmdLine[0] > 1 Then $sInput = (FileExists($CmdLine[2]) ? FileRead($CmdLine[2]) : $CmdLine[2])
recall(defunc(FileExists($CmdLine[1]) ? FileRead($CmdLine[1]) : $CmdLine[1]))

Func defunc($Code)
	$Code = StringRegExpReplace($Code, "\#.*?\n", "")
	Local $aCode = StringSplit($Code, "", 3), $sMain = "", $sMacro, $sComment
	For $iPointer = 0 To UBound($aCode)-1
		Switch $aCode[$iPointer]
			Case 'Q', 'R', 'S', 'T', 'U', 'V', 'W'
				If StringIsUpper($aCode[$iPointer]) Then
					$sMacro = ""
					For $k = $iPointer+1 To UBound($aCode)-1
						If (StringInStr("QRSTUVW", $aCode[$k], 1) <> 0) Then
							If Asc($aCode[$k]) = Asc($aCode[$iPointer]) Then Exit ConsoleWrite("!> Error: Macro " & $aCode[$iPointer] & " is alread defined!" & @LF)
							ExitLoop
						EndIf
						$sMacro &= $aCode[$k]
						If $k = UBound($aCode)-1 Then ExitLoop
					Next
					$Functions[Asc($aCode[$iPointer])-Asc('Q')] = $sMacro
					$iPointer += StringLen($sMacro)
				Else
					$sMain &= $aCode[$iPointer]
				EndIf
			Case Else
				$sMain &= $aCode[$iPointer]
		EndSwitch
	Next

	Return $sMain
EndFunc

Func recall($Code, $bLoop = False)
	Local $iLoopHead, $aCode = StringSplit($Code, "", 3), $sVar, $sLoopBody, $sComment, $argA, $argB, $nVal, $iLoopDepth
	For $iPointer = 0 To UBound($aCode)-1
		Switch $aCode[$iPointer]
			Case '#'
				Return 1
			Case 'q', 'r', 's', 't', 'u', 'v', 'w'
				$nMacro = Asc(StringUpper($aCode[$iPointer]))-Asc('Q')
				If $nMacro > UBound($Functions)-1 Then Exit ConsoleWrite("!> Error: Macro " & $aCode[$iPointer] & " does not exist." & @LF)
				recall($Functions[$nMacro])
			Case 'Y'
				$iLoopDepth = 1
				If $aCode[$iPointer] == 'y' Then Exit ConsoleWrite("!> Unmatched loop tail encountered!")
				$sLoopBody = ""
				For $k = $iPointer+1 To UBound($aCode)-1
					If $aCode[$k] == 'y' And $iLoopDepth = 1 Then ExitLoop
					If $aCode[$k] == 'Y' Then $iLoopDepth += 1
					If $aCode[$k] == 'y' Then $iLoopDepth -= 1
					If $k = UBound($aCode)-1 And $aCode[$k] <> 'y' Then Exit ConsoleWrite("!> Encountered EOC while searching for loop tail :(." & @LF)
					$sLoopBody &= $aCode[$k]
				Next
				While recall($sLoopBody, True)
					; Q: "Won't this cause a stack overflow exception?!"
					; A: No, beacause it doesn't recurse, it just evaluates.
					;    The stack is only used when the loop contains nested loops.
				WEnd
				$iPointer += (StringLen($sLoopBody) + 1)
			Case '!'
				dump()
			Case 'Z', 'z'
				If Not $bLoop Then Exit ConsoleWrite("!> Syntax error: Loop break outside of loop." & @LF)
				$iVal = pop()
				If ($aCode[$iPointer] == 'Z' And $iVal > 0) Or ($aCode[$iPointer] == 'z' And $iVal = 0) Then Return 0
			Case '.'
			Case 'X', 'x'
				If $aCode[$iPointer] == 'X' Then
					ConsoleWrite(Chr(pop()))
				Else
					$pInput += 1
					$iVal = StringMid($sInput, $pInput, 1)
					If $iVal = "" Then
						push(0)
					Else
						push(Asc($iVal))
					EndIf
				EndIf
			Case '0'
				If $iPointer < UBound($aCode)-1 Then
					If num($aCode[$iPointer+1]) Then
						$sVar = ""
						For $k = $iPointer+1 To UBound($aCode)-1
							If Not num($aCode[$k]) Then ExitLoop
							$sVar &= $aCode[$k]
						Next
						$Variables[$sVar][1] = 1
						push($Variables[$sVar][0])
						$iPointer += StringLen($sVar)
					Else
						push(0)
					EndIf
				Else
					push(0)
				EndIf
			Case Else
				If StringInStr("ABCDEFGHIJKLMNOP", $aCode[$iPointer]) <> 0 Then
					If StringIsUpper($aCode[$iPointer]) Then
						$nVal = pop()
						$argA = BitShift($nVal, -1)
						$argB = BitShift($nVal,  1)
					Else
						$argB = pop()
						$argA = pop()
					EndIf
					Switch $aCode[$iPointer]
						Case 'A'
							push(0)
						Case 'B'
							push(BitNOT(BitOR($argA, $argB)))
						Case 'C'
							push(BitAND(BitNOT($argA), $argB))
						Case 'D'
							push(BitNOT($argA))
						Case 'E'
							push(BitAND($argA, BitNOT($argB)))
						Case 'F'
							push(BitNOT($argB))
						Case 'G'
							push(BitXOR($argA, $argB))
						Case 'H'
							push(BitNOT(BitAND($argA, $argB)))
						Case 'I'
							push(BitAND($argA, $argB))
						Case 'J'
							push(BitNOT(BitXOR($argA, $argB)))
						Case 'K'
							push($argB)
						Case 'L'
							push(BitNOT(BitAND($argA, BitNOT($argB))))
						Case 'M'
							push($argA)
						Case 'N'
							push(BitNOT(BitAND($argB, BitNOT($argA))))
						Case 'O'
							push(BitOR($argA, $argB))
						Case 'P'
							push(255)
					EndSwitch
				ElseIf num($aCode[$iPointer]) Then
					$sVar = ""
					For $k = $iPointer To UBound($aCode)-1
						If Not num($aCode[$k]) Then ExitLoop
						$sVar &= $aCode[$k]
					Next
					$Variables[$sVar][1] = 1
					$Variables[$sVar][0] = pop()
					If StringLen($sVar) > 1 Then $iPointer += (StringLen($sVar)-1)
				EndIf
		EndSwitch
		If $iPointer > UBound($aCode)-1 Then $iPointer -= 1
	Next

	Return 1
EndFunc

Func bin($iNumber)
    Local $sBinString = "", $iUnsignedNumber=BitAND($iNumber,0x7FFFFFFF)
    Do
        $sBinString = BitAND($iUnsignedNumber, 1) & $sBinString
        $iUnsignedNumber = BitShift($iUnsignedNumber, 1)
    Until Not $iUnsignedNumber
    Return ($iNumber < 0 ? '1' : '0') & StringRight("000000000000000000000000000000" & $sBinString,31)
EndFunc

Func dump()
	ConsoleWrite(@LF)
	For $i = UBound($Stack)-1 To 0 Step -1
		ConsoleWrite(">  STACK(" & $i & "):" & @TAB & (($Stack[$i] > 31 And $Stack[$i] < 127) ? Chr($Stack[$i]) : " ") & " " & Hex($Stack[$i],8) & " " & bin($Stack[$i]) & @LF)
	Next
	For $i = UBound($Variables)-1 To 0 Step -1
		If $Variables[$i][1] = 1 Then ConsoleWrite("-> VAR(" & $i & "):" & @TAB & (($Variables[$i][0] > 31 And $Variables[$i][0] < 127) ? Chr($Variables[$i][0]) : " ") & " " & Hex($Variables[$i][0],8) & " " & bin($Variables[$i][0]) & @LF)
	Next
	ConsoleWrite(@LF)
EndFunc

Func pop()
	If UBound($Stack) < 1 Then push(0)
	Local $iVal = $Stack[UBound($Stack)-1]
	ReDim $Stack[UBound($Stack)-1]
	Return $iVal
EndFunc

Func push($_)
	ReDim $Stack[UBound($Stack)+1]
	$Stack[UBound($Stack)-1] = $_
EndFunc

Func num($_)
	Return (Asc($_) > Asc('0')) And (Asc($_) < Asc(':'))
EndFunc