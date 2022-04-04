////////////////////////////////////////////////////////////////////////////////////////////////////////
// Part of Injectable Generic Camera System
// Copyright(c) 2016, Frans Bouma
// All rights reserved.
// https://github.com/FransBouma/InjectableGenericCameraSystem
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met :
//
//  * Redistributions of source code must retain the above copyright notice, this
//	  list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and / or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED.IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
////////////////////////////////////////////////////////////////////////////////////////////////////////
#include "stdafx.h"
#include "CameraManipulator.h"

using namespace DirectX;
using namespace std;

extern "C" {
	LPBYTE _cameraStructAddress = NULL;
}

XMFLOAT3 GetCurrentCameraCoords()
{
	float* coordsInMemory = reinterpret_cast<float*>(_cameraStructAddress + CAMERA_COORDS_IN_CAMERA_STRUCT_OFFSET);
	XMFLOAT3 currentCoords = XMFLOAT3(coordsInMemory);
	return currentCoords;
}


// newLookQuaternion: newly calculated quaternion of camera view space. Can be used to construct a 4x4 matrix if the game uses a matrix instead of a quaternion
// newCoords are the new coordinates for the camera in worldspace.
void WriteNewCameraValuesToGameData(XMVECTOR newLookQuaternion, XMFLOAT3 newCoords)
{
	XMMATRIX rotationMatrixPacked = XMMatrixRotationQuaternion(newLookQuaternion);
	float* matrixInMemory = reinterpret_cast<float*>(_cameraStructAddress + CAMERA_LOOK_MATRIX);
	float* coordsInMemory = reinterpret_cast<float*>(_cameraStructAddress + CAMERA_COORDS_IN_CAMERA_STRUCT_OFFSET);
	XMFLOAT4X4 rotationMatrix;
	XMStoreFloat4x4(&rotationMatrix, rotationMatrixPacked);
	matrixInMemory[0] = rotationMatrix._11;
	matrixInMemory[1] = rotationMatrix._21;
	matrixInMemory[2] = rotationMatrix._31;
	matrixInMemory[4] = rotationMatrix._12;
	matrixInMemory[5] = rotationMatrix._22;
	matrixInMemory[6] = rotationMatrix._32;
	matrixInMemory[8] = rotationMatrix._13;
	matrixInMemory[9] = rotationMatrix._23;
	matrixInMemory[10] = rotationMatrix._33;

	coordsInMemory[0] = newCoords.x;
	coordsInMemory[1] = newCoords.y;
	coordsInMemory[2] = newCoords.z;
}


// Waits for the interceptor to pick up the camera struct address. Should only return if address is found 
void WaitForCameraStructAddresses()
{
	while(0 == _cameraStructAddress)
	{
		Sleep(100);
	}
#ifdef _DEBUG
	cout << "Address found: " << hex << (void*)_cameraStructAddress << endl;
#endif
}