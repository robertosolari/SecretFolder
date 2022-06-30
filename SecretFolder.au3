#include <guiconstants.au3>
#include <editconstants.au3>
#include <Crypt.au3>

Global $pass
Global $contatore=0
Global $controllo=0
Global $sicu=-1


$gui=GUICreate("Login",170,150)
GUISetBkColor(0,0x000000)
$pass_label=GUICtrlCreateLabel("Inserisci Password: ",30,30)
GUICtrlSetColor($pass_label,0x00ff00)
$pass_input=GUICtrlCreateInput("",30,50,0,0,$ES_PASSWORD)
GUICtrlSetBkColor($pass_input,0x000000)
GUICtrlSetColor($pass_input,0x00ff00)
;GUICtrlSetLimit($pass_input,13)
$accedi=GUICtrlCreateButton("Accedi",30,80,100,30)
GUICtrlSetBkColor($accedi,0x000000)
GUICtrlSetColor($accedi,0x00ff00)



$PASS_DIR=@appdatadir&"\SecretFolder"
$PASS_DEC=$PASS_DIR&"\pass.txt"
$PASS_ENC=@AppDataDir&"\SecretFolder\pwd.pwdcry"
$FILE_PAS="pwd.pwdcry"
$SEC_DIR="SecretFolder"



_Crypt_Startup()

If Not FileExists($PASS_DIR) Then
  GUICtrlSetData($accedi,"Registra")
EndIf

GUISetState()

While 1
  Switch GUIGetMsg()
Case $GUI_EVENT_CLOSE
  If $sicu=0 Then
             cripta()
                RunWait(@comspec&" /c attrib +s +h "&$FILE_PAS&" ",$PASS_DIR,@SW_HIDE)
  EndIf                
  Exit
Case $accedi
  If GUICtrlRead($pass_input)="" Then                                                  
         MsgBox(16,"Error","Errore devi inserire una password")                                
  Else
         If GUICtrlRead($accedi)="Registra" Then
         DirCreate($PASS_DIR)
         $pass=GUICtrlRead($pass_input)
         FileWrite($PASS_DEC,$pass)
         If cripta()=True Then
                Sleep(500)
                RunWait(@comspec&" /c attrib +s +h "&$FILE_PAS&" ",$PASS_DIR,@SW_HIDE)
                Sleep(1000)
                MsgBox(0,"","Password salvata con successo")
         EndIf
         ExitLoop
  Else
         $pass=GUICtrlRead($pass_input)
         $sicu=0
         If $contatore=0 Then
         RunWait(@comspec&" /c attrib -s -h "&$FILE_PAS&" ",$PASS_DIR,@SW_HIDE)
         Sleep(1000)
         decripta()
         Sleep(1000)
         EndIf
         If $pass=FileRead($PASS_DEC) Then
                MsgBox(0,"","Accesso permesso")
                cripta()
                RunWait(@comspec&" /c attrib +s +h "&$FILE_PAS&" ",$PASS_DIR,@SW_HIDE)
                $sicu=1
                ExitLoop
         Else
                MsgBox(48,"","Dati non corrispondenti")
                $contatore+=1
                If $contatore>3 Then
                       Exit
                EndIf
         EndIf
  EndIf
  EndIf
EndSwitch
WEnd

GUIDelete($gui)

_Crypt_Shutdown()



$controllo=0

If Not FileExists(@MyDocumentsDir&"\"&$SEC_DIR) Then
  DirCreate(@MyDocumentsDir&"\"&$SEC_DIR)
  RunWait(@comspec&" /c attrib +s +h "&$SEC_DIR&" ",@MyDocumentsDir,@SW_HIDE)
EndIf


$gui=GUICreate("SecretFolder V. 1.0",300,200)
GUISetBkColor(0x000000)
$apri=GUICtrlCreateButton("Apri cartella",100,20,100,30)
GUICtrlSetBkColor($apri,0x000000)
GUICtrlSetColor($apri,0x00ff00)
$blocca=GUICtrlCreateButton("Blocca cartella",100,70,100,30)
GUICtrlSetBkColor($blocca,0x000000)
GUICtrlSetColor($blocca,0x00ff00)
$sblocca=GUICtrlCreateButton("Sblocca cartella",100,120,100,30)
GUICtrlSetBkColor($sblocca,0x000000)
GUICtrlSetColor($sblocca,0x00ff00)

GUISetState()

While 1
  Switch GUIGetMsg()
  Case $GUI_EVENT_CLOSE
  Exit
  Case $apri
  ShellExecute(@MyDocumentsDir&"\"&$SEC_DIR)
  Case $blocca
  If $controllo=1 Then
         RunWait(@comspec&" /c attrib +s +h "&$SEC_DIR&" ",@mydocumentsdir,@sw_hide)
         RunWait(@ComSpec&" /c cacls "&$SEC_DIR&" /e /c /d "&@UserName,@MyDocumentsDir,@SW_HIDE)
         MsgBox(0,"Bloccata","Cartella bloccata con successo")
         $controllo=0
  EndIf
  Case $sblocca
  $controllo=1
  RunWait(@ComSpec&" /c cacls "&$SEC_DIR&" /e /c /g "&@UserName&":f",@MyDocumentsDir,@SW_HIDE)
  RunWait(@comspec&" /c attrib -s -h "&$SEC_DIR&" ",@mydocumentsdir,@sw_hide)
  MsgBox(0,"Sbloccata","Cartella sbloccata con successo")
  EndSwitch
WEnd


Func cripta()
  $controllo=_crypt_encryptfile($PASS_DEC,$PASS_ENC,"secret",$CALG_RC4)
  Sleep(1000)
  FileDelete($PASS_DEC)
         
  Return $controllo
EndFunc


Func decripta()
  $controllo=_crypt_decryptfile($PASS_ENC,$PASS_DEC,"secret",$CALG_RC4)
  Sleep(1000)
  FileDelete($PASS_ENC)
 
  Return $controllo
EndFunc
