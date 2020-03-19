INCLUDE Irvine32.inc
INCLUDE macros.inc

BUFFER_SIZE = 98

.data
Row byte 0
Col byte 0
index BYTE 0
buffer BYTE BUFFER_SIZE DUP(?)
Initial_Matrix BYTE 81 DUP(?)
FinalMatrix BYTE 81 DUP(?)
EditMatrix byte 81 dup(?)
ColorMatrix byte 81 dup(30h)            ;Contains 1 ifthe current char is not 0

YeditOffset dword offset EditMatrix     ; used in filling the EditMatrix
YcolorOffset dword offset ColorMatrix   ; used in filling the ColorMatrix
Ytmp dword 0     
Ytmp2 dword 0                       ; used in filling the ColorMatrix
YinitialIsFull byte 0
checkRight byte 0					; = '1' if the number entered is correct & '0' if it is wrong 
Ycounter byte 0		; if > 9 endline (used in YDisplay)
YRowIndexCounter byte 1					
YColCounter	byte 1				
YRowCounter byte 1
isFinish byte 0
Corrects byte 0
Wrongs byte 0
missed byte 0
DontCount byte 0

UnSolvedFiles BYTE "diff_1_1.txt",0,"diff_1_2.txt",0,"diff_1_3.txt",0,"diff_2_1.txt",0,"diff_2_2.txt",0,"diff_2_3.txt",0,"diff_3_1.txt",0,"diff_3_2.txt",0,"diff_3_3.txt"
SolvedFiles BYTE "diff_1_1_solved.txt",0,"diff_1_2_solved.txt",0,"diff_1_3_solved.txt",0,"diff_2_1_solved.txt",0,"diff_2_2_solved.txt",0,"diff_2_3_solved.txt",0,"diff_3_1_solved.txt",0,"diff_3_2_solved.txt",0,"diff_3_3_solved.txt"
str1Len byte 13
str2Len byte 20
check byte 0
fileHandle  HANDLE ?
 UserFile BYTE 'UserMatrix.txt',0

Value byte 0
.code
main PROC

mWrite "Choose Level : ",0
	    call CRLF
	mWrite "[1] EASY",0
		call CRLF
	mWrite "[2] MEDIUM",0
		call CRLF
	mWrite "[3] HARD",0
		call CRLF
	mWrite "Enter your choice : ",0
	call readint

call ShowBoards 
mov YinitialIsFull, 0
mov checkRight, 0	
mov Ycounter, 0	
mov YRowIndexCounter, 1					
mov YColCounter, 1				
mov YRowCounter, 1
mov isFinish, 0

MAINLOOP:
call YDisplay

jmp MAINLOOP

	exit
main ENDP






;##############################################################ShowBoards#######################################################
;read the matrix from the file and load it into buffer array
;###############################################################################################################################

ShowBoards PROC

YFinalLoop:

        cmp check,0 
        jne sol                        ;go to fill FinalMatrix
		mov	edx,OFFSET UnSolvedFiles   ;fill FinalMatrix the initial matrix 
		mov bl, byte ptr str1Len

      jmp mnext

       sol:
        mov	edx,OFFSET SolvedFiles
		mov bl, byte ptr str2Len
		mov eax, Ytmp2
		;jmp Next

mnext:
	mov Ytmp2,eax
	cmp eax,1
	je Easy   

	cmp eax,2
	je Medium

	cmp eax,3
	je Hard

	Easy:
		call writeString
		call crlf
		jmp Next

	Medium:
		mov al,3
		Mul bl
		add edx, eax
		call writeString
		call crlf
		jmp Next

	Hard:
		mov al,6
		Mul bl
		add edx, eax
		call writeString
		call crlf
		jmp Next
	

	Next:
	call OpenInputFile
	mov	fileHandle,eax


                                                    ; Check for errors.
	cmp	eax,INVALID_HANDLE_VALUE		            ; error opening file?
	jne	file_ok					                    ; no: skip
	mWrite <"Cannot open file",0dh,0ah>
	jmp	quit						                ; and quit

    file_ok:                                                   ; Read the file into a buffer.
	mov	edx,OFFSET buffer
	mov	ecx,BUFFER_SIZE
	call ReadFromFile
	jnc	check_buffer_size			                ; error reading?
	mWrite "Error reading file. "		            ; yes: show error message
	call	WriteWindowsMsg
	jmp	close_file
	
check_buffer_size:
	cmp	eax,BUFFER_SIZE			                   ; buffer large enough?
	jb	buf_size_ok				                   ; yes
	mWrite <"Error: Buffer too small for the file",0dh,0ah>
	jmp	quit						               ; and quit


buf_size_ok:	
	cmp check,0 
	jne close_file

	mov	buffer[eax],0		                       ; insert null terminator
	mWrite "File size: "
	call	WriteDec			                   ; display file size
	call	Crlf
                    

close_file:
	mov	eax,fileHandle
	call CloseFile

	quit:
call TransferData
cmp YinitialIsFull, 0
je Return		;if TransferData has been called before
jmp YFinalLoop	;the second itiration is to fill the final matrix from the solved matrix

Return:
	ret
ShowBoards ENDP

;#################################################################################################################
;#################################################################################################################








;#####################################################Colors###################################################
;Set the colors
;##############################################################################################################


;colors the chars before printing them
setCharColor PROC
mov ecx,sizeof buffer
DisplayLoop:
mov bl, [edx]
cmp bl, 30h
jne Ywhite
call ColorItRed
jmp Yred
Ywhite:
call DefaultColor
Yred:
mov al,bl
call writeChar
inc edx
Loop DisplayLoop

ret
setCharColor ENDP

;################################################################################################################

DefaultColor PROC
	mov eax,white+(black*16)
	call SetTextColor
	ret
DefaultColor ENDP

;################################################################################################################

ColorItRed PROC
	mov eax,red+(black*16)
	call SetTextColor

	ret
ColorItRed ENDP

;################################################################################################################

ColorItGreen PROC
	mov eax,green+(black*16)
	call SetTextColor

	ret
ColorItGreen ENDP

;################################################################################################################

ColorItBlue PROC
	mov eax,blue+(black*16)
	call SetTextColor

	ret
ColorItBlue ENDP

;################################################################################################################

ColorItYellow PROC
	mov eax,yellow+(black*16)
	call SetTextColor

	ret
ColorItYellow ENDP

;#################################################################################################################
;#################################################################################################################








;########################################################### YDisplay ##############################################





;Displayes the board with each new value
YDisplay PROC
call clrscr
call CRLF
mwrite"================="
call CRLF
mwrite"|Select a choice|"
call CRLF
mwrite"================="
call CRLF
mwrite"1)Finish Board"
call CRLF
mwrite"2)Clear Board"
call CRLF
mwrite"3)Edit cell"
call CRLF
mwrite"4)Save & Exit "
call CRLF
call CRLF

mov corrects, 0
mov wrongs, 0
mov missed, 0
mov YRowIndexCounter, 2				
mov YColCounter, 1				
mov YRowCounter, 1
mov Ycounter, 0	
call ColorItYellow
mWrite "   1 2 3  |  4 5 6  |  7 8 9 "
call crlf
mwrite "   ---------------------------"
call crlf
mwrite "1 |"
call DefaultColor

mov ecx,sizeof EditMatrix
mov ebp, 0
DisplayEditLoop:
mov al, EditMatrix[ebp]
cmp ColorMatrix[ebp],30h
je NOTWHITE			
call DefaultColor			;if WHITE
jmp SKIP

NOTWHITE:					;else if NOT WHITE
cmp al, ' '
jne NOTBLUE
call ColorItBlue			;if BLUE
cmp DontCount, 0
jne SKIP
inc missed
jmp SKIP
NOTBLUE:
call Kcompare
cmp checkRight,0
jne CORRECT
call ColorItRed				;if the current value is WRONG
cmp DontCount, 0
jne SKIP
inc wrongs
jmp SKIP

CORRECT:
call ColorItGreen			;if the current value is RIGHT
cmp DontCount, 0
jne SKIP
inc corrects
SKIP:
mov DontCount, 0
cmp isFinish, 0
je NOTFINISH
mov al, FinalMatrix[ebp]
jmp FINISH

NOTFINISH:
mov al, EditMatrix[ebp]
FINISH:
cmp YColCounter, 3
jbe PRINTSPACECOLUMN
mov Ytmp, eax
call DefaultColor
mov eax, Ytmp
mWrite " |  "
mov YColCounter, 1
mov DontCount,1
jmp DisplayEditLoop
PRINTSPACECOLUMN:
inc YColCounter
call writeChar				;print the current element in EditMatrix
mWrite " "
inc ebp
inc Ycounter				
cmp Ycounter, 9
jb CONT	
mov Ytmp, eax
call ColorItYellow
mwrite "|"	
mov eax, Ytmp
cmp YRowCounter, 3
jb PRINTSPACEROW		
call crlf
mov Ytmp,eax
call DefaultColor
mov eax,Ytmp
mov Ytmp,ecx
 mWrite "  |------"
mov ecx, 2
PRINTDASHESLOOP:
 mWrite "   -------"
loop PRINTDASHESLOOP
mov ecx, Ytmp
mwrite "|"	
mov YRowCounter, 0
PRINTSPACEROW:
call crlf				;if Ycounter > 9 endLine

cmp YRowIndexCounter, 9
ja CONT
mov Ytmp, eax
call ColorItYellow
mov al, YRowIndexCounter
call writeDec
mwrite " |"
inc YRowIndexCounter
mov eax,Ytmp
call DefaultColor

mov YColCounter, 1
mov Ycounter, 0
inc YRowCounter
CONT:
DEC ecx
jnz DisplayEditLoop
cmp isFinish ,0
je CHOOSE
mwrite "Number of correct numbers: "
mov al, corrects
call writedec
call crlf
mwrite "Number of wrong numbers: "
mov al, wrongs
call writedec
call crlf
mwrite "Number of missed numbers: "
mov al, missed
call writedec
call crlf
mwrite "Press any key to back to main list, .. "
call readchar
call Clear
call clrscr
call main

CHOOSE:
mwrite"Enter Your Choice : "
call readint
cmp al, 1
je FinishProc
cmp al, 2
je ClearProc
cmp al, 3
je editproc
cmp al,4
je save
jmp mskip
FinishProc:
mov isFinish, 1
ret

ClearProc:
call Clear
ret

editproc:
call Kedit
ret

mskip:
save:
call WriteeFile
ret
YDisplay ENDP



;#################################################################################################################
;#################################################################################################################




;#################################################################################################################
;########################################################### CLEAR ###############################################
;#################################################################################################################


Clear PROC USES edi eax esi ecx edi

	mov corrects, 0
	mov wrongs, 0
	mov missed, 0
	mov esi,offset Initial_Matrix
	mov edi,offset EditMatrix

	mov ecx,lengthof Initial_Matrix
	TransferLoop:
		mov al,[esi]
		mov byte ptr [edi],al
		inc esi
		inc edi
	loop TransferLoop
	cmp isFinish, 0
	je quit
	mov isFinish, 0
	quit:
	ret
Clear ENDP

;#################################################################################################################
;########################################################### END CLEAR ###########################################
;#################################################################################################################




;########################################################### Kedit ##############################################


Kedit PROC
	KL1:
	;//////////////////////////////////////////////

	;//////////////////////////////////////////////
	mwrite "Enter Row number: "
	call readint
	call crlf
	dec al
	mov Row ,al
	mwrite "Enter Column number: "
	call readint
	call crlf
	dec al
	mov Col ,al
	mwrite "Enter Value: "
	call readchar
	mov Value ,al
	call CheckValid
	
	jmp KE
	Loop KL1
	KE:
	mov al,Value
	mov EditMatrix[ebp],al
	ret
Kedit ENDP


;#################################################################################################################
;#################################################################################################################








;########################################################### Kcompare ##############################################
;check the value is correct or not
;####################################################################################################################


; Function that compares the edited value 
Kcompare PROC
	cmp al,FinalMatrix[ebp]
	je  right
	mov al,0
	mov checkRight,al
ret
	right:
	mov al,1
	mov checkRight,al
ret
Kcompare ENDP


;#####################################################################################################################
;#####################################################################################################################










;####################################################TransferData########################################################
;this proc for transeferring data from buffer array to the initial or final array without spaces and endlines
;#########################################################################################################################



;Transfares numbers from Buffer to Initioal_Matrix without endlines
;and filling the 'ColorMatrix'

TransferData PROC
mov YcolorOffset, offset ColorMatrix
mov YeditOffset, offset EditMatrix


mov ecx, sizeOf buffer
dec ecx
cmp check,0
jne finall                       ;if check != 0 go to fill the final matrix
mov ebx, offset Initial_Matrix   ;if check == 0 fill the initial matrix 
jmp Yskip
finall:
mov ebx, offset FinalMatrix 

Yskip:

mov esi, offset buffer
TransLoop:
mov edx, esi
lodsb
cmp al, 0dh		
jne Store		 ;if al != '\r' go to stor it into initial matrix
add esi, 1       ;if al = '\r' skip it and skip the next element
dec ecx

jmp Skip

Store:
mov edi,ebx

cmp check,0
jne StoreFinal

cmp al,30h
je DontSetColor				;if al == 0 dont store '1' into the color matrix
mov Ytmp,ebx
mov ebx, YcolorOffset       ;if al != 0 store '1' into the color matrix
mov byte ptr [ebx], 31h
inc ebx
mov YcolorOffset, ebx 
mov ebx,Ytmp
jmp Continue

DontSetColor:

inc YcolorOffset
mov al,' '
Continue:
stosb						;store into InitialMatrix
mov edi, edx
mov Ytmp, edi
mov edi, YeditOffset
stosb						;store into EditMatrix

mov YeditOffset, edi
mov edi, Ytmp
inc ebx
jmp Skip

StoreFinal:
stosb						;store into the finall matrix

inc ebx						;go to the next element
Skip:
loop TransLoop

;====================================TEST DISPLAY INITIAL, EDIT, COLOR, FINAL======================
;====================================END TEST DISPLAY INITIAL, EDIT, COLOR, FINAL======================

not check
not YinitialIsFull
ret
TransferData ENDP


;###########################################################################################################
;###########################################################################################################









;#########################################Get Index###########################################################
;this proc take row and col and return it's position in the array
;#############################################################################################################


;PROC to get the index of selected index in 1D array
GetIndex PROC   
	mov Ytmp, eax     
	mov index, 0
	mov al, 9
	mul Row
	add index,al
	mov eax,Ytmp
	mov Ytmp,ebx
	mov bl, Col
	add index,bl
movzx ebp,index
	mov ebx, Ytmp

	ret 
GetIndex ENDP

;################################################################################################################
;################################################################################################################





;################################################# WriteeFile ####################################################
;this proc is only to save the user matrix into a file with name 'UserMatrix' 
;#################################################################################################################


WriteeFile PROC

    mov     edx, OFFSET EditMatrix              ; point to the edit matrix
    push    offset EditMatrix

	movzx eax,UserFile                           ; store the name of the file in eax

    mov     edx, OFFSET UserFile 
    call    CreateOutputFile 
    push    eax                             ; save file handle

    mov     ecx, 81          
    mov     edx, OFFSET EditMatrix 
    call    WriteToFile 
    pop     eax                             ; restore file handle
    call    CloseFile 

ret
WriteeFile ENDP


;#################################################################################################################
;#################################################################################################################






;##################################################DisplayCorrect#################################################
;Display incorrect number and change the color into green and return it back to it's default color
;#################################################################################################################



DisplayCorrect PROC
call ColorItGreen
call SetTextColor
mwrite"							Correct Number :)"
call DefaultColor
call SetTextColor
call CRLF
call waitmsg
ret
DisplayCorrect ENDP

;###############################################################################################################################
;###############################################################################################################################






;##################################################DisplayIncorrect############################################################
;Display incorrect number and change the color into red and return it back to it's default color
;###############################################################################################################################


DisplayIncorrect PROC
call ColorItRed
call SetTextColor
mwrite"							Invalid Number :("
call DefaultColor
call SetTextColor
call CRLF
call waitmsg

ret
DisplayIncorrect ENDP
   
;###########################################################################################################################
;###############################################################################################################################







;#######################################################CheckValid###########################################################
;check whether the input integer is correct or not
;############################################################################################################################

CheckValid PROC

call GetIndex
call writechar
call CRLF

movzx ebx,ColorMatrix[ebp]
cmp ebx,30h
je KE
mwrite "Invalid row or column u cannot edit this cell"
jmp skip
KE:
cmp FinalMatrix[ebp],al
je correct
call DisplayIncorrect
jmp skip
correct:
call DisplayCorrect
skip:
ret
CheckValid ENDP

;###############################################################################################################################
;###############################################################################################################################

END main
