; University of Virginia
; CS 2150 In-Lab 8
; Spring 2018
; mergeSort.s	

	;; Patrick Hourican
	;; pjh4as
	;; 10/28/20
	;; mergeSort.s
	
	global mergeSort
	global merge

	section .text


; Parameter 1 is a pointer to the int array
; Parameter 2 is the left index in the array
; Parameter 3 is the right index in the array
; Return type is void 
mergeSort:
				; Implement mergeSort here
	;; set stack values
	push 	r12		; push register onto the stack to hold left index (rsi)
	push	r13		; push register onto the stack to hold right index (rdx)
	push	r14		; push register onto the stack to hold middle index
	mov	r12, rsi	; move the param 1 value (left) into r12
	mov	r13, rdx	; move the param 2 value (right) into r13

	;; base case
	cmp	r12, r13	; compare left value to right (base case)
	jge	epilogue	; if r12>r13 end mergesort and jump to return 

	;; set middle index value to r14
	mov	r14, r12	; move left index into middle index reg
	add	r14, r13	; add right index to middle index
	shr	r14, 1		; use shr ,1 (shift to the right 1) to represent arithmetic  division of 2

	;; left call
	mov	rsi, r12	; move left index value into the second param
	mov	rdx, r14	; move middle index value into the third paramer (acting as right index)
	call	mergeSort	; recursive call on left side of array

	;; right call
	mov	rdx, r13	; move right index value into the third param (right index)
	inc	r14		; add 1 to middle index value
	mov	rsi, r14	; move middle index value into the second param (left index)
	call	mergeSort	; recursive call on right side of array

	;; merge parameters -> merge(arr, l, m, r)
	mov	rsi, r12	; set second param back to original left index
	dec	r14		; set middle index back to first middle value (left call)
	mov	rdx, r14	; move middle value into third param
	mov	rcx, r13	; move original right value into fourth index
	push	r10		; r10 is used in merge, must be on stack when merge is called
	push	r11		; r11 also used in merge
	call	merge		; merge call

	pop	r11		; pop off stack before epilogue
	pop	r10		
	jmp	epilogue	; jump to epilogue to clean off stack and return sorted array

epilogue:
	pop	r14		; pop off stack from last added to first added, then return sorted array
	pop	r13
	pop	r12
	ret

	


; Parameter 1 is a pointer to the int array 
; Parameter 2 is the left index in the array
; Parameter 3 is the middle index in the array 
; Parameter 4 is the right index in the array
; Return type is void 
merge:
	; Save callee-save registers
	; Store local variables 
	push rbx			; int i
	push r12			; int j
	push r13			; int k
	push r14			; int n1
	push r15			; int n2
	
	mov r14, rdx			; n1 = mid - left + 1
	sub r14, rsi
	inc r14

	mov r15, rcx			; n2 = right - mid 
	sub r15, rdx

	lea r11, [r14+r15]		; r11 = rsp offset = 4(n1 + n2)
	lea r11, [4*r11]		
	sub rsp, r11			; allocate space for temp arrays

	mov rbx, 0			; i = 0
	mov r12, 0			; j = 0
	
; Copy elements of arr[] into L[]	
copyLloop:
	cmp rbx, r14			; is i >= n1?
	jge copyRloop
					; L[i] = arr[left + i]
	lea r10, [rsi+rbx]		
	mov r10d, DWORD [rdi+4*r10]	; r10 = arr[left + i]
	mov DWORD [rsp+4*rbx], r10d	; L[i] = r10
	inc rbx				; i++
	jmp copyLloop

; Copy elements of arr[] into R[]
copyRloop:
	cmp r12, r15			; is j >= n2?
	jge endcopyR
 					; R[j] = arr[mid + 1 + j]
	lea r10, [rdx+r12+1]	
	mov r10d, DWORD [rdi+4*r10]	; r10 = arr[mid + 1 + j]
	lea rax, [r12+r14]		
	mov DWORD [rsp+4*rax], r10d	; R[j] = r10
	inc r12				; j++
	jmp copyRloop

endcopyR:	
	mov rbx, 0			; i = 0
	mov r12, 0			; j = 0
	mov r13, rsi			; k = left

; Merge L[] and R[] into arr[]
mergeLoop:
	cmp rbx, r14			; is i >= n1 or j >= n2?
	jge loopL
	cmp r12, r15
	jge loopL
	lea r10, [r12+r14]
	mov r10d, DWORD [rsp+4*r10] 	; r10d = R[j]
	cmp DWORD [rsp+4*rbx], r10d	; is L[i] <= R[j]?
	jle if
	mov DWORD [rdi+4*r13], r10d	; arr[k] = R[j]
	inc r12				; j++
	jmp endif 
if:
	mov r10d, DWORD [rsp+4*rbx] 
	mov DWORD [rdi+4*r13], r10d	; arr[k] = L[i] 
	inc rbx				; i++
endif:	
	inc r13				; k++	
	jmp mergeLoop
	
; Copy elements of L[] into arr[]
loopL:				
	cmp rbx, r14			; is i >= n1?
	jge loopR
	mov r10d, DWORD [rsp+4*rbx] 
	mov DWORD [rdi+4*r13], r10d	; arr[k] = L[i]
	inc rbx				; i++
	inc r13				; k++
	jmp loopL

; Copy elements of R[] into arr[]
loopR:	
	cmp r12, r15			; is j >= n2?
	jge endR
	lea r10, [r12+r14]
	mov r10d, DWORD [rsp+4*r10] 	
	mov DWORD [rdi+4*r13], r10d	; arr[k] = R[j]

	inc r12				; j++
	inc r13				; k++
	jmp loopR
	
endR:
	; deallocate temp arrays
	; restore callee-save registers
	add rsp, r11	
	pop r15			
	pop r14
	pop r13
	pop r12
	pop rbx
	ret
