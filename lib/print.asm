;print(char *str)
;
;
;
CursorPos	EQU	0BE00h
[SECTION .CODE32]
GLOBAL print
print:
	PUSH	EBP
	MOV	EBP,ESP
	MOV	SI
