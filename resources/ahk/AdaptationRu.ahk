/*

��������������� ������� ��� ������� ���������

*/



; ������������ ������� �������� ����� � �� ���������� ��������
; ��������� ������� �������� ����� � ��������� ���������
AdpRu_ConvertRuModToEn(_item)
{
;console_log(_item, "_item")	
	For k, imod in _item.mods {
		
		_item.mods[k].name_ru := _item.mods[k].name
		result1 := AdpRu_Ru_En_Stats_Value(_item.mods[k].name)
		_item.mods[k].name := result1.name
		
		; ���������� ��������������� ������������ �������� ����, 
		; ��� ����� ��� ����� � �������, �������� "����� 1 ������" 
		; - ��� ����� ����� � ����� ������ ���� ������������ ������� �������� � ��������� ����������
		result2 := AdpRu_Ru_En_Stats_Value(_item.mods[k].name_orig)
		_item.mods[k].name_orig_en := result2.name
		
		; ���� ��� �� ��� ��������������
		;If (_item.mods[k].name = _item.mods[k].name_ru) {		
		If (not result1.IsName) {		
			; � ������� ������������ �������� ����� ��� ����� � ������ ����� #, ������� ���� ��� ������������, �� ����������� �� ���
			RegExMatch(_item.mods[k].name, "(.*)([+-]#)(.*)", mod_name)			
			modRu := mod_name1 "#" mod_name3
			result := AdpRu_Ru_En_Stats_Value(modRu)
			modEn := result.name
			; � ��������� ����� ��������� ����������� ��������
			_item.mods[k].name := StrReplace(modEn, "#", mod_name2)
		}
	}
;console_log(_item, "_item")
	Return _item
}


; ��������������� ��� ����� ������ ����
AdpRu_ConvertRuOneModToEn(smod)
{
	result := AdpRu_Ru_En_Stats_Value(smod)
		
	; ���� ��� �� ��� ��������������		
	If (not result.IsName) {		
		; � ������� ������������ �������� ����� ��� ����� ����� #, ������� ���� �� ������������, �� ����������� �� ����
		RegExMatch(smod, "(.*)([+]#)(.*)", mod_name)			
		modRu := mod_name1 "#" mod_name3

		result := AdpRu_Ru_En_Stats_Value(modRu)
		If (result.IsName) {
			modEn := result.name
			; � ��������� ����� ��������� ����������� ��������
			smod := StrReplace(modEn, "#", "+#")
		}
	} Else {
		smod := result.name
	}

;console_log(smod, "smod")

	Return smod
}


;
AdpRu_Ru_En_Stats_Value(smod)
{
	ru_en_stats := Globals.Get("ru_en_stats")
	
	result := {}
	result.name := ""
	result.IsName := ""

	smod_en := ru_en_stats[smod]
	
	If(not smod_en) {
	
		; ��� ������ � ���������� - ��� ���� �������� # ������ ���������
		res := AdpRu_nameModNumToConst(smod)
		If (res.IsNameRuConst) {
			smod_en := ru_en_stats[res.nameModConst]
		}
		
		; �������� ��� ��� ���������
		If(not smod_en) {				
			; � ������� ������������ � ����� ���� ��������� ������������ ����� (��������� ��������) - ������� � � �� ����� ����
			smod_en := ru_en_stats[smod . " (��������� ��������)"]
			; � ������ �� ���. ����� ����
			smod_en := RegExReplace(smod_en, " \(Captured Beast\)", "")
		}
		
		If(not smod_en) {	
			;return smod
			result.name := smod
			result.IsName := false
			return result
		}
	}
	
	; ��������� �� ������� ����� ������ ������� ��� �� ������
	; - ��� ������, ����� � ����� ������������ � ���������� �������� ���� ������������ ������ ����� ������, �.�. � ����� poetrade �� �����������
	StringReplace, smod_en, smod_en, `n, %A_Space%, All
	
	result.name := smod_en
	result.IsName := true
	
	;return smod_en
	return result
}


;������������ ������� ����� ��������� � ���������� �������
AdpRu_ConvertRuItemNameToEn(itemRu, currency=false)
{
	Global Item
	
	; ��������� � ��������� ������ - ���������
	If (not currency and RegExMatch(itemRu, "i)������� �����")) {
		return itemRu
	}
	
	;itemRu_ := Trim(RegExReplace(itemRu, "i)�������� ��������", ""))
	itemRu_ := Trim(StrReplace(itemRu, "�������� ��������", ""))
	
	If (Item.IsMap) {
		; ��� ����� "����� �����" ���  ����� ����������� �������, �.�. � ����������
		; �������� ����� ������������ ������ ����������� � ANSI ��������� - "o" � ����� ������� ������
		; �������������� ������ ������ �� ����������� � ����� � ANSI ����������
		;If (RegExMatch(itemRu_, "����� �����")) 
		IfInString, itemRu_, ����� �����
		{
			itemEn := "Maelstr" chr(0xF6) "m of Chaos"
			return itemEn
		}
	}
	
	If (Item.IsWeapon and Item.SubType = Mace) {
		; ���� ��� ����������� ������ "��������" 
		IfInString, itemRu_, ��������
		{
			itemEn := "Mj" chr(0xF6) "lner"
			return itemEn
		}
	}
	
	; ���������� ������ ������ ��������� � ����������� ����������
	sameNameItem  := Globals.Get("sameNameItem")
	itemEn := ""
	If (Item.IsDivinationCard) {
		itemEn := sameNameItem.DivinationCard[itemRu_]
		If (itemEn) {
			return itemEn
		}
	}
	Else If (Item.IsGem) {
		itemEn := sameNameItem.Gem[itemRu_]
		If (itemEn) {
			return itemEn
		}
	}

	; ������ ������������ ������� ���� ��������� �� ������� ����� �� ���������� ���������
	nameItemRuToEn := Globals.Get("nameItemRuToEn")	
	
	itemEn := ""
	itemEn := nameItemRuToEn[itemRu_]
	
	If (not itemEn) {
		; ���� ������������ �� �������, ���������� ��� �� �������
		; �������� ���������� ���-�� ������������ ����� ������ - ������, � ������ ���� ������������ �������� �� ������� �������
		itemEn := itemRu
	}	
	
	return itemEn
}


; ��������������� ������� ����� ��������� �������� � ���������� �������
AdpRu_ConvertRuFlaskNameToEn(nameRu, baseNameRu)
{
	ruPrefSufFlask := TradeGlobals.Get("ruPrefSufFlask")
	
	affName := RegExReplace(nameRu, baseNameRu, "")
	
	; ��������� ������� �� ��������	
	If (RegExMatch(affName, "^([�-��-߸�]+) ([�-��-߸� ]+)*$", aff_name))
	{		
		pref := Trim(aff_name1)
		suff := Trim(aff_name2)
	} ; ������ �������
	Else If (RegExMatch(affName, "([�-ߨ][�-��]+)", aff_name)){
		pref := Trim(aff_name1)
		suff := ""
	} ; ������ �������
	Else If (RegExMatch(affName, "([�-��]+)", aff_name)){
		pref := ""
		suff := Trim(aff_name1)
	}
	
	nameEn := ""
	nameEn := ruPrefSufFlask[pref] " " AdpRu_ConvertRuItemNameToEn(baseNameRu) " " ruPrefSufFlask[suff]
	
	return nameEn
}


; ������������ ��� ���� � # � ��� ���� � �����������
AdpRu_nameModNumToConst(nameMod)
{
	nameModNum  := Globals.Get("nameModNum")
	nameModConst := nameModNum[nameMod]
	
	result := {}
	
	If(not nameModConst)
	{
		result.IsNameRuConst := false
		result.nameModConst := nameMod
		return result
	} 
	result.IsNameRuConst := true
	result.nameModConst := nameModConst
;console_log(nameMod, "nameMod")	
;console_log(nameMod, "nameMod")	
;console_log(result, "result")		

	return result
}


; ���� ���� � ����������� ������� ������� � ����� ����
; � ���������� ���������� �������� ���� �������� �� ���������
; ����� ���� ���������� ���������� ���������� �� � ���������� �������� -
; �� ���� ����� ������� ��������� ������� � �� #
AdpRu_ConverNameModToValue(nameMod, name_ru)
{
	; ��������� �������������� ��� �� ���������	
	RegExMatch(name_ru, "([^\d#]*)([\d#]*)([^\d#]*)([\d#]*)([^\d#]*)([\d#]*)([^\d#]*)", name_ruSub)

	If (name_ruSub2 or name_ruSub4 or name_ruSub6) {
		
		; ��������� ������������ ��� �� ���������
		RegExMatch(nameMod, "(\D*)(\d+)(\D*)(\d+)(\D*)(\d*)(\D*)", nameModSub)

		; ���� �������� �����, ������ ��� ���������
		If ((nameModSub2 = name_ruSub2) and nameModSub2) {
			value1 := "#"
		} Else { ; �����, ��� ��������
			value1 := nameModSub2
		}
		
		If ((nameModSub4 = name_ruSub4) and nameModSub4) {
			value2 := "#"
		} Else { 
			value2 := nameModSub4
		}
		
		; ���� ���� � ����� �����������
		If ((nameModSub6 = name_ruSub6) and nameModSub6) {
			value3 := "#"
		} Else { 
			value3 := nameModSub6
		}
		
		nameMod := nameModSub1 . value1 . nameModSub3 . value2 . nameModSub5 . value3 . nameModSub7
				
		;console_log(nameMod, "CONST")		
	}
	;console_log(nameMod, "nameMod Full")		
	
	return nameMod
}


; �� ������� ������ � ������������ ������ 2.8.0 ��� ��������� ���������� ��������� � ����������� ������ - ���
; ���������� �������� ������ ����� ������� �� ��������� � ������� �� ����������� ���������� ��������, � �� �� ��� ����.
; �������� ������������� ������� �� ��������� �� ��������� ����� ���������.
; ����� ������������ ��� ���������� ��������� �������, ���� �� ��������� � ����-���� ������� \data_trade\uniques.json, 
; ���� � ���� ����� �� ��������� ��������� �������� �����, ���� � ����-����� \data_trade\mods.json ����������
; �������� ����� �������������� �� poe.trade ���� ������� ��������� - ������ ��������� ������, ���� � ��������� �����������
; ����������� ������� ��������, ���� � �������������� ������������� ������ �� �������� ��� ����������� ������.
; ������ ������� ��������� ���������� � ������ ������������� ����� ���������� � ������� ����������� ������������� ����� ������ � ��������. 
;
; ����� �������� ���������� ��������� � ���� \data_trade\ru\uniquesItemModEmpty.txt
AdpRu_AddUniqueVariableMods(uniqueItem)
{
	Global Item, ItemData
	
	tempMods	:= []
	utempMods	:= {}
	
	Affixes	:= StrSplit(ItemData.Affixes, "`n")

	For key, val in Affixes {

		modFound := false
		
		; remove negative sign also			
		t_ru_full := TradeUtils.CleanUp(RegExReplace(val, "i)-?[\d\.]+", "#"))

		; ��� ����� � �����������
		t_ru := AdpRu_nameModNumToConst(t_ru_full)
		; ���� ��� � ����������
		If (t_ru.IsNameRuConst) {
			t := AdpRu_ConvertRuOneModToEn(t_ru.nameModConst)
		} Else {
			t := AdpRu_ConvertRuOneModToEn(t_ru_full)
		}
		
		; ���������� ��� ����
		nameVarMod := t

		t := TradeUtils.CleanUp(RegExReplace(t, "i)-?[\d\.]+", "#"))
		
		; ��������� �� "+" � ����� - ���� ���� � ������� "+" ���������� � ��������
		t := StrReplace(t, "+", "")

		For k, v in uniqueItem.mods {
			
			; ������������� �������������� �����
			n := utempMods[k]

			If (not n){ ; ���� ��� �� �����������, �� ���������� ���
				n := TradeUtils.CleanUp(RegExReplace(v.name, "i)-?[\d\.]+", "#"))
				n := TradeUtils.CleanUp(n)

				; ��������� �� "+" � ����� - ���� ���� � ������� "+" ���������� � ��������			
				n := StrReplace(n, "+", "")
				
				; �������� �������������� ��� �� ��������� �������
				utempMods[k] := n
			}

			; match with optional positive sign to match for example "-7% to cold resist" with "+#% to cold resist"
			RegExMatch(n, "i)(\+?" . t . ")", match)

			If (match) {
				; �������������� ���� ����������
				modFound := true
				break				
			} 
		}
		
		If (not modFound) {
			; ���������� ������ � ����
			varMod := {}
			; ���������� ��� ����
			varMod.name := nameVarMod
			; ��������� ������������ ������ ���� � ��������
			varMod.name_orig_item := val
			; ������������ �������� �������� ����� ������
			varMod.ranges := []
			; �������, ��� ��� ����������
			varMod.isVariable := true
			; �������, ��� ���� ���������� �������������
			varMod.isSort := true
			
			; ��������� ������������� ����
			tempMods.push(varMod)
		}
	}
;console_log(tempMods, "tempMods")	
	; 
	If (tempMods) {
		For key, val in tempMods {
			; ������� ��� � ������ ����� �� ���������� ��������
			uniqueItem.mods.push(val)
		}
	}
	
	return uniqueItem
}


; ������� ������������� ������� ���� ���������� ���������:
; - � ���������� �������� �����
; - � ������ ������� ��� �� ��������� � ��������� ���� uniques.json ������������� �������.
; ��������� ��� ������� AdpRu_AddUniqueVariableMods(uniqueItem)
AdpRu_InitUniquesItemModEmpty()
{
	FileRead, uniquesItemModEmpty, %A_ScriptDir%\data_trade\ru\uniquesItemModEmpty.txt
	uniquesItemModEmpty	:= StrSplit(uniquesItemModEmpty, "`r`n")
	
	tmpArr := {}
	
	For k, uIt in uniquesItemModEmpty {
		uIt := Trim(uIt)
		If (uIt) {
			tmpArr[uIt] := true
		}
	}

	TradeGlobals.Set("uniquesItemModEmpty", tmpArr)
}


; ������������� ���������� �������� ���������
AdpRu_InitNameEnItem()
{
	Global Item
	
	; ��������������� ������� ����� ��������� ��������
	If (Item.IsFlask and Item.RarityLevel = 2) {
		Item.Name_En := AdpRu_ConvertRuFlaskNameToEn(Item.Name, Item.BaseName)
	}
	Else {
		; ������������� �� ����������� ������� �������� � ����������
		Item.Name_En := AdpRu_ConvertRuItemNameToEn(Item.Name, Item.IsCurrency)
	}
	
	Item.BaseName_En := AdpRu_ConvertRuItemNameToEn(Item.BaseName, Item.IsCurrency)
}

; ������� ������������� ������� ������������ �������� ��������� � ��������� ��������
AdpRu_InitRuPrefSufFlask()
{
	FileRead, ruPrefSufFlask, %A_ScriptDir%\data_trade\ru\ruPrefSufFlask.json	
	TradeGlobals.Set("ruPrefSufFlask", JSON.Load(ruPrefSufFlask))
}


; ������� ������������� ������� ������������ ��������� � ��������� � ��������� ������ ������� ��������� ����������
AdpRu_InitBuyoutCurrencyEnToRu()
{
	FileRead, buyoutCurrencyEnToRu, %A_ScriptDir%\data_trade\ru\ruBuyoutCurrency.json	
	TradeGlobals.Set("buyoutCurrencyEnToRu", JSON.Load(buyoutCurrencyEnToRu))
}


; ������������ �������� ������ � ����������� �� �������
AdpRu_ConvertBuyoutCurrencyEnToRu(buycurEn)
{
	buyoutCurrencyEnToRu := TradeGlobals.Get("buyoutCurrencyEnToRu")
	buycurRu := buyoutCurrencyEnToRu[ buycurEn ]

	If (buycurRu){
		return buycurRu
	}
	Else {
		return buycurEn
	}
}


; ��������������� ������� ������� ����������� �������
; ���������� ����� Clone() ��������� ������ ������ �����������, �.�. ���������� ���������� �� ���������,
; � � ���� ������
AdpRu_ObjFullyClone(obj)
{
	nobj := obj.Clone()
	For k,v in nobj
		if IsObject(v)
			nobj[k] := A_ThisFunc.(v)
	return nobj
}


; ������� ������ �������� ���������� � ���������� �������
; var_ - ����������
; name_var - ��������� ��� ����������, ���� ����� ������� ����� ������� � ��������� ����� ���������
; console_log(var_, "var_")
console_log(var_, name_var)
{
	;console.log("############ " name_var " ############")
	;console.log(var_)
	;console.log("##############################")
	console.log("------------- " name_var " -------------")
	console.log(var_)
	console.log("---------------------------------------")
}


AdpRu_InitTimeStart := 0

; ������� ����������� ��� ������������ ��� ������ ������������������
;
; ��������� ������� ������ ������� - ������ ���������� ����� ����������� �����
AdpRu_InitTime()
{
	Global AdpRu_InitTimeStart
	
	;AdpRu_InitTimeStart := A_TickCount
	; ���������� ������ ��������� � ������� ������ ����������
	DllCall("QueryPerformanceCounter", "Int64*", AdpRu_InitTimeStart)
}


; ������� � ���������� ������� ���������� ������ ��������� � ������� ������ ���������� �������
; ������ ���������� ����� ������������ ����
AdpRu_ElapsedTime()
{
	Global AdpRu_InitTimeStart
	
	;_A_TickCount_ := A_TickCount
	DllCall("QueryPerformanceCounter", "Int64*", _A_TickCount_)

	elapsed_time := _A_TickCount_ - AdpRu_InitTimeStart
	console_log(elapsed_time, " ������ ������: ")
}
