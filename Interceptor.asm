;////////////////////////////////////////////////////////////////////////////////////////////////////////
;// Part of Injectable Generic Camera System
;// Copyright(c) 2016, Frans Bouma
;// All rights reserved.
;// https://github.com/FransBouma/InjectableGenericCameraSystem
;//
;// Redistribution and use in source and binary forms, with or without
;// modification, are permitted provided that the following conditions are met :
;//
;//  * Redistributions of source code must retain the above copyright notice, this
;//	  list of conditions and the following disclaimer.
;//
;//  * Redistributions in binary form must reproduce the above copyright notice,
;//    this list of conditions and the following disclaimer in the documentation
;//    and / or other materials provided with the distribution.
;//
;// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;// DISCLAIMED.IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
;// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;// DAMAGES(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
;// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
;// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
;// OR TORT(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;////////////////////////////////////////////////////////////////////////////////////////////////////////
;---------------------------------------------------------------
; Game specific asm file to intercept execution flow to obtain addresses, prevent writes etc.
;---------------------------------------------------------------
;---------------------------------------------------------------
; Public definitions so the linker knows which names are present in this file
;---------------------------------------------------------------

;---------------------------------------------------------------
; Externs defined in CameraManipulator.cpp, which are used and set by the system. Read / write these
; values in asm to communicate with the system
EXTERN _cameraStructAddress: qword
EXTERN _cameraEnabled: byte
;---------------------------------------------------------------

;---------------------------------------------------------------
; Own externs, defined in InterceptorHelper.cpp
EXTERN _cameraStructInterceptionContinue: qword
EXTERN _cameraWriteInterceptionContinue1: qword

;DarkSoulsII.exe+1F1A4E - 0F28 81 A0010000      - movaps xmm0,[rcx+000001A0]
;DarkSoulsII.exe+1F1A55 - 48 89 9C 24 80000000  - mov [rsp+00000080],rbx
;DarkSoulsII.exe+1F1A5D - 48 8B 5F 08           - mov rbx,[rdi+08]
;DarkSoulsII.exe+1F1A61 - 66 0F7F 44 24 20      - movdqa [rsp+20],xmm0
.code 
cameraAddressInterceptor PROC
	mov [_cameraStructAddress], rcx						; intercept address of camera struct
originalCode:
	movaps xmm0, [rcx + 1A0h]
	mov [rsp+80h],rbx
	mov rbx,[rdi+08h]
	movdqa [rsp+20h],xmm0
	jmp [_cameraStructInterceptionContinue]			; jmp to original code
cameraAddressInterceptor ENDP





;CameraInterceptLocation
;DarkSoulsII.exe+AE07E0 - 0F 28 02               - movaps xmm0,[rdx]
;DarkSoulsII.exe+AE07E3 - 66 0F 7F 01            - movdqa [rcx],xmm0
;DarkSoulsII.exe+AE07E7 - 0F 28 4A 10            - movaps xmm1,[rdx+10]
;DarkSoulsII.exe+AE07EB - 66 0F 7F 49 10         - movdqa [rcx+10],xmm1
;DarkSoulsII.exe+AE07F0 - 0F28 42 20            - movaps xmm0,[rdx+20]
;DarkSoulsII.exe+AE07F4 - 66 0F7F 41 20         - movdqa [rcx+20],xmm0
;DarkSoulsII.exe+AE07F9 - 0F28 4A 30            - movaps xmm1,[rdx+30]
;DarkSoulsII.exe+AE07FD - 66 0F7F 49 30         - movdqa [rcx+30],xmm1
;DarkSoulsII.exe+AE0802 - C3                    - ret 
cameraWriteInterceptor1 PROC
	cmp byte ptr [_cameraEnabled], 1					; check if the user enabled the camera. If so, just skip the write statements, otherwise just execute the original code.
	je exit												; our own camera is enabled, just skip the writes
originalCode:
	movaps xmm0,[rdx]
	movdqa [rcx],xmm0
	movaps xmm1,[rdx+10h]
	movdqa [rcx+10h],xmm1
	movaps xmm0,[rdx+20h]
	movdqa [rcx+20h],xmm0
	movaps xmm1,[rdx+30h]
	movdqa [rcx+30h],xmm1
exit:
	jmp [_cameraWriteInterceptionContinue1]
cameraWriteInterceptor1 ENDP


_TEXT ENDS

END