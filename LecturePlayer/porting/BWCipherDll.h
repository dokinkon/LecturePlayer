#ifndef BWCipherDllH
#define BWCipherDllH

#include "BWDES.h"
#include "BWAES.h"
#include "BWMD5.h"

#include <memory>
#include <string.h>
#include <math.h>
#include "globals.h"


using namespace std;

namespace BWCipherDll
{
	bool FileExists(char* filename);
	char* BWCipherDllVerson();   
    bool BWCipherEncode(char *inputfilename, char* outputfilename, char *keystring, char *cipheralgorithm);
    bool BWCipherDecode(char *inputfilename, char* outputfilename, char *keystring, char *cipheralgorithm);
    bool BWCipherEncode(unsigned char *pSrcBuffer,int srcsize,unsigned char *pDestBuffer, int destsize,char *keystring, char *cipheralgorithm);
    bool BWCipherDecode(unsigned char *pSrcBuffer,int srcsize,unsigned char *pDestBuffer, int destsize,char *keystring, char *cipheralgorithm);
    int BWCipherEncodeSize(int size, char *cipheralgorithm);
    string BWCipherMd5Sum(char* inputfilename);
}

//---------------------------------------------------------------------------
#endif

