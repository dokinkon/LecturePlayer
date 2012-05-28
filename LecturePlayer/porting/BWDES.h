#ifndef __BWDES_H__
#define __BWDES_H__

class BWDES
{
public:
    bool encode(char* InputFileName, char* OutputFileName, char* KeyString);
    bool decode(char* InputFileName, char* OutputFileName, char* KeyString);

    bool encode(unsigned char *pSrcBuffer,int SrcSize,
                unsigned char *pDestBuffer, int DestSize, char *KeyString);

    bool decode(unsigned char *pSrcBuffer,int SrcSize,
                unsigned char *pDestBuffer, int DestSize, char *KeyString);
private:

    bool ReadDataFromBuffer(int index, unsigned char *pBuffer, int size, unsigned char in[8]);
    bool WriteDataToBuffer(int index, unsigned char *pBuffer, unsigned char out[8]);
};

#endif

