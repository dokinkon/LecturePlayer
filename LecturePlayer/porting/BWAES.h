//---------------------------------------------------------------------------

#ifndef BWAESH
#define BWAESH

#include <stdio.h>

#define UNIT8 unsigned char
#define UNIT32 unsigned int


class BWAES
{
private:
	int Nk;	//Key Length
	int Nb;	//Block Size
	int Nr;	//Number of Rounds
	UNIT32 *w;	//Nb*(Nr+1)
    UNIT32 *state;
    UNIT32 rcon[10];

    UNIT8 xtime(UNIT8);

    //Key expansion subfunction
	UNIT32 SubWord(UNIT32 temp);
	UNIT32 RotWord(UNIT32 temp);

    //Cipher subfunction
    void AddRoundKey(int round);
    void SubBytes(void);
    void ShiftRows(void);
    void MixColumns(void);

    //Inverse cipher subfunction
    void InvShiftRows(void);
    void InvSubBytes(void);
    void InvMixColumns(void);

    // 較低階的加解密函式
    void KeyExpansion(UNIT32 *key);
    void Cipher(UNIT32 *in,UNIT32 *out);
    void InvCipher(UNIT32 *in,UNIT32 *out);

    bool ReadDataFromFile(FILE *inf,UNIT32 in[4]);
    bool WriteDataToFile(FILE *inf,UNIT32 out[4]);

    bool ReadDataFromBuffer(int index, unsigned char *pBuffer, int size, UNIT32 in[4]);
    bool WriteDataToBuffer(int index, unsigned char *pBuffer, UNIT32 out[4]);

public:
    BWAES();

    // 暫時取消任意key長度的aes加解密
	//BWAES(int nk);
	~BWAES();

    bool encode(char* InputFileName, char* OutputFileName, char* KeyString);
    bool decode(char* InputFileName, char* OutputFileName, char* KeyString);

    bool encode(unsigned char *pSrcBuffer,int SrcSize,
                unsigned char *pDestBuffer, int DestSize, char *KeyString);

    bool decode(unsigned char *pSrcBuffer,int SrcSize,
                unsigned char *pDestBuffer, int DestSize, char *KeyString);
};
//---------------------------------------------------------------------------
#endif
