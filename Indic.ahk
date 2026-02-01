#Requires AutoHotkey v2.0

devanagariMode := false

LAlt & LShift::
{
    global devanagariMode := !devanagariMode
    if (devanagariMode)
        ToolTip("Devanagari Mode: ON")
    else
        ToolTip("Devanagari Mode: OFF")
    
    SetTimer () => ToolTip(), -2000 ; Hide tooltip after 2 seconds
}

; This section only runs when devanagariMode is true
#HotIf devanagariMode

$Enter::
{
    A_Clipboard := "" 

    Send("^a") ; Select all
    Send("^c") ; Copy
    
    ; Wait up to 500ms for clipboard to contain data
    if !ClipWait(0.5) {
        Send("{Enter}") ; If field was empty, just press Enter
        return
    }

    inputText := A_Clipboard
    outputText := ""

    half := false

    ccMap := Map(
	"kh", "ख",
	"gh", "घ",
	"ch", "छ",
	"jh", "झ",
	"Th", "ठ",
	"Dh", "ढ",
	"th", "थ",
	"dh", "ध",
	"ph", "फ",
	"bh", "भ")
    cMap := Map(
	"k", "क",
	"g", "ग",
	"G", "ङ",
	"c", "च",
	"j", "ज",
	"J", "ञ",
	"T", "ट",
	"D", "ड",
	"N", "ण",
	"t", "त",
	"d", "द",
	"n", "न",
	"p", "प",
	"b", "ब",
	"m", "म",
	"y", "य",
	"r", "र",
	"l", "ल",
	"L", "ळ",
	"v", "व",
	"z", "श",
	"S", "ष",
	"s", "स",
	"h", "ह")
    vvMap := Map(
	"RR", "ॠ",
	"RL", "ऌ",
	"ai", "ऐ",
	"au", "ओ",
	"MM", "ँ")
    vMap := Map("a", "अ",
	"A", "आ",
	"i", "इ",
	"I", "ई",
	"u", "उ",
	"U", "ऊ",
	"R", "ऋ",
	"e", "ए",
	"o", "ओ",
	"M", "ं",
	"H", "ः")
    vvMapHalf := Map(
	"RR", "ॄ",
	"RL", "ॢ",
	"ai", "ै",
	"au", "ौ",
	"MM", "ँ")
    vMapHalf := Map(
	"a", "",
	"A", "ा",
	"i", "ि",
	"I", "ी",
	"u", "ु",
	"U", "ू",
	"R", "ृ",
	"e", "े",
	"o", "ो",
	"M", "ं",
	"H", "ः")
    punctuation := [
	["...", "ॐ"],
	["..", "॥"],
	[".", "।"],
	["'", "ऽ"],
	["0", "०"],
	["1", "१"],
	["2", "२"],
	["3", "३"],
	["4", "४"],
	["5", "५"],
	["6", "६"],
	["7", "७"],
	["8", "८"],
	["9", "९"]]

    for pair in punctuation {
        inputText := StrReplace(inputText, pair[1], pair[2])
    }

    i := 1
    while (i <= StrLen(inputText)) {
        char := SubStr(inputText, i, 1)
	twoChar := char
	if (i <= StrLen(inputText) - 1) {
            next := SubStr(inputText, i + 1, 1)
	    twoChar .= next
	}

	if ccMap.Has(twoChar) {
	    outputText .= ccMap[twoChar]
            i += 2
	    if !(i <= StrLen(inputText) && vMap.Has(SubStr(inputText, i, 1))) {
	        outputText .= "्"
		half := false
	    }
	    else {
		half := true
	    }
	}
	else if cMap.Has(char) {
	    outputText .= cMap[char]
            i += 1
	    if !(i <= StrLen(inputText) && vMap.Has(SubStr(inputText, i, 1))) {
	        outputText .= "्"
		half := false
	    }
	    else {
		half := true
	    }
	}
	else if vvMap.Has(twoChar) {
	    outputText .= half ? vvMapHalf[twoChar] : vvMap[twoChar]
	    i += 2
	    half := false
	}
	else if vMap.Has(char) {
	    outputText .= half ? vMapHalf[char] : vMap[char]
	    i += 1
	    half := false
	}
        else if (char = "_") {
	    i += 1
	}
	else {
	    outputText .= char
	    i += 1
	}

    }

    A_Clipboard := outputText
    Send("^v")
    Sleep(50) ; Small delay to ensure paste finishes
    Send("{Enter}")
}

#HotIf