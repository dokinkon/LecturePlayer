//---------------------------------------------------------------------------
#include "BWAES.h"
#include "BWMD5.h"
#include <math.h>
#include <stdio.h>
#include <memory>
using namespace std;

const UNIT8 SBox[16][16] = { {0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76}, //0
					         {0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0}, //1
					         {0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15}, //2
					         {0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75}, //3
					         {0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84}, //4
					         {0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf}, //5
					         {0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8}, //6
					         {0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2}, //7
					         {0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73}, //8
					         {0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb}, //9
					         {0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79}, //a
					         {0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08}, //b
					         {0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a}, //c
					         {0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e}, //d
					         {0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf}, //e
					         {0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16} }; //f

const UNIT8 InvSBox[16][16] = {{0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb}, //0
							   {0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb}, //1
							   {0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e}, //2
							   {0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25}, //3
							   {0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92}, //4
							   {0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84}, //5
							   {0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06}, //6
							   {0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b}, //7
							   {0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73}, //8
							   {0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e}, //9
							   {0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b}, //a
							   {0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4}, //b
							   {0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f}, //c
							   {0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef}, //d
							   {0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61}, //e
							   {0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d}}; //f

//---------------------------------------------------------------------------



inline UNIT8 BWAES::xtime(UNIT8 temp)
{
    if ( (temp&0x80)==0x80 )
    {
        temp = temp<<1;
        return (temp^0x1b);
    }
    else
    {
        return temp<<1;
    }
}

UNIT32 BWAES::SubWord(UNIT32 temp)
{
	int x,y;
	UNIT32 temp1=0x00000000;
	UNIT32 temp2[4];
	//temp[0]
	x = (temp&0xf0000000)>>28;
	y = (temp&0x0f000000)>>24;
	temp2[0] = SBox[x][y];

	//temp[1]
	x = (temp&0x00f00000)>>20;
	y = (temp&0x000f0000)>>16;
	temp2[1] = SBox[x][y];

	//temp[2]
	x = (temp&0x0000f000)>>12;
	y = (temp&0x00000f00)>>8;
	temp2[2] = SBox[x][y];

	//temp[3]
	x = (temp&0x000000f0)>>4;
	y = (temp&0x0000000f)>>0;
	temp2[3] = SBox[x][y];

	temp1 = (temp2[0]<<24)|(temp2[1]<<16)|(temp2[2]<<8)|temp2[3];

	return temp1;
}

UNIT32 BWAES::RotWord(UNIT32 temp)
{
    UNIT32 temp1=((temp&0xff000000)>>24);
    return (temp<<8)|temp1;
}



void BWAES::AddRoundKey(int round)
{
    for ( int i=0 ; i<Nb ; i++ )
        state[i] = state[i]^w[round*Nb+i];
}

void BWAES::SubBytes(void)
{
    UNIT32 temp,temp1,temp2,temp3,temp4;
    int x,y;
    for ( int i=0 ; i<Nb ; i++ )
    {
        temp = (state[i]&0xff000000)>>24;
        x = (temp&0x000000f0)>>4;
        y = (temp&0x0000000f);
        temp1 = (SBox[x][y]<<24);

        temp = (state[i]&0x00ff0000)>>16;
        x = (temp&0x000000f0)>>4;
        y = (temp&0x0000000f);
        temp2 = (SBox[x][y]<<16);

        temp = (state[i]&0x0000ff00)>>8;
        x = (temp&0x000000f0)>>4;
        y = (temp&0x0000000f);
        temp3 = (SBox[x][y]<<8);

        temp = (state[i]&0x000000ff);
        x = (temp&0x000000f0)>>4;
        y = (temp&0x0000000f);
        temp4 = (SBox[x][y]);

        state[i] = temp1|temp2|temp3|temp4;
    }
}
void BWAES::ShiftRows(void)
{
    UNIT32 col0,col1,col2,col3;
    //row 0 , do not shift

    //row 1
    col0 = state[0]&0x00ff0000;
    col1 = state[1]&0x00ff0000;
    col2 = state[2]&0x00ff0000;
    col3 = state[3]&0x00ff0000;
    state[0] = (state[0]&0xff00ffff)|col1;
    state[1] = (state[1]&0xff00ffff)|col2;
    state[2] = (state[2]&0xff00ffff)|col3;
    state[3] = (state[3]&0xff00ffff)|col0;

    //row 2
    col0 = state[0]&0x0000ff00;
    col1 = state[1]&0x0000ff00;
    col2 = state[2]&0x0000ff00;
    col3 = state[3]&0x0000ff00;
    state[0] = (state[0]&0xffff00ff)|col2;
    state[1] = (state[1]&0xffff00ff)|col3;
    state[2] = (state[2]&0xffff00ff)|col0;
    state[3] = (state[3]&0xffff00ff)|col1;

    //row 3
    col0 = state[0]&0x000000ff;
    col1 = state[1]&0x000000ff;
    col2 = state[2]&0x000000ff;
    col3 = state[3]&0x000000ff;
    state[0] = (state[0]&0xffffff00)|col3;
    state[1] = (state[1]&0xffffff00)|col0;
    state[2] = (state[2]&0xffffff00)|col1;
    state[3] = (state[3]&0xffffff00)|col2;
}
void BWAES::MixColumns(void)
{
    UNIT8 row0,row1,row2,row3;
    UNIT32 temp0,temp1,temp2,temp3;
    for ( int i=0 ; i<Nb ; i++ )    {
        row0 = (state[i]&0xff000000)>>24;
        row1 = (state[i]&0x00ff0000)>>16;
        row2 = (state[i]&0x0000ff00)>>8;
        row3 = (state[i]&0x000000ff);

        state[i] = 0x00000000;
        temp0 = 0x00000000;
        temp1 = 0x00000000;
        temp2 = 0x00000000;
        temp3 = 0x00000000;

        temp0 = (UNIT32)(xtime(row0)^xtime(row1)^row1^row2^row3);
        temp1 = (UNIT32)(row0^xtime(row1)^xtime(row2)^row2^row3);
        temp2 = (UNIT32)(row0^row1^xtime(row2)^xtime(row3)^row3);
        temp3 = (UNIT32)(xtime(row0)^row0^row1^row2^xtime(row3));

        state[i] = (temp0<<24)|(temp1<<16)|(temp2<<8)|temp3;

    }
}
//Inverse cipher subfunction
void BWAES::InvShiftRows(void)
{
    UNIT32 col0,col1,col2,col3;
    //row 0 , do not shift

    //row 1
    col0 = state[0]&0x00ff0000;
    col1 = state[1]&0x00ff0000;
    col2 = state[2]&0x00ff0000;
    col3 = state[3]&0x00ff0000;
    state[0] = (state[0]&0xff00ffff)|col3;
    state[1] = (state[1]&0xff00ffff)|col0;
    state[2] = (state[2]&0xff00ffff)|col1;
    state[3] = (state[3]&0xff00ffff)|col2;

    //row 2
    col0 = state[0]&0x0000ff00;
    col1 = state[1]&0x0000ff00;
    col2 = state[2]&0x0000ff00;
    col3 = state[3]&0x0000ff00;
    state[0] = (state[0]&0xffff00ff)|col2;
    state[1] = (state[1]&0xffff00ff)|col3;
    state[2] = (state[2]&0xffff00ff)|col0;
    state[3] = (state[3]&0xffff00ff)|col1;

    //row 3
    col0 = state[0]&0x000000ff;
    col1 = state[1]&0x000000ff;
    col2 = state[2]&0x000000ff;
    col3 = state[3]&0x000000ff;
    state[0] = (state[0]&0xffffff00)|col1;
    state[1] = (state[1]&0xffffff00)|col2;
    state[2] = (state[2]&0xffffff00)|col3;
    state[3] = (state[3]&0xffffff00)|col0;
}
void BWAES::InvSubBytes(void)
{
    UNIT32 temp,temp1,temp2,temp3,temp4;
    int x,y;
    for ( int i=0 ; i<Nb ; i++ )    {
        temp = (state[i]&0xff000000)>>24;
        x = (temp&0x000000f0)>>4;
        y = (temp&0x0000000f);
        temp1 = (InvSBox[x][y]<<24);

        temp = (state[i]&0x00ff0000)>>16;
        x = (temp&0x000000f0)>>4;
        y = (temp&0x0000000f);
        temp2 = (InvSBox[x][y]<<16);

        temp = (state[i]&0x0000ff00)>>8;
        x = (temp&0x000000f0)>>4;
        y = (temp&0x0000000f);
        temp3 = (InvSBox[x][y]<<8);

        temp = (state[i]&0x000000ff);
        x = (temp&0x000000f0)>>4;
        y = (temp&0x0000000f);
        temp4 = (InvSBox[x][y]);

        state[i] = temp1|temp2|temp3|temp4;
    }
}
void BWAES::InvMixColumns(void)
{
    UNIT8 row0,row1,row2,row3;
    UNIT8 row01,row11,row21,row31;
    UNIT32 temp0,temp1,temp2,temp3;
    for ( int i=0 ; i<Nb ; i++ )    {
        row0 = (state[i]&0xff000000)>>24;
        row1 = (state[i]&0x00ff0000)>>16;
        row2 = (state[i]&0x0000ff00)>>8;
        row3 = (state[i]&0x000000ff);

        state[i] = 0x00000000;
        temp0 = 0x00000000;
        temp1 = 0x00000000;
        temp2 = 0x00000000;
        temp3 = 0x00000000;

        row01 = xtime(xtime(xtime(row0)))^xtime(xtime(row0))^xtime(row0);
        row11 = xtime(xtime(xtime(row1)))^xtime(row1)^row1;
        row21 = xtime(xtime(xtime(row2)))^xtime(xtime(row2))^row2;
        row31 = xtime(xtime(xtime(row3)))^row3;
        temp0 = (UNIT32)(row01^row11^row21^row31);

        row01 = xtime(xtime(xtime(row0)))^row0;
        row11 = xtime(xtime(xtime(row1)))^xtime(xtime(row1))^xtime(row1);
        row21 = xtime(xtime(xtime(row2)))^xtime(row2)^row2;
        row31 = xtime(xtime(xtime(row3)))^xtime(xtime(row3))^row3;
        temp1 = (UNIT32)(row01^row11^row21^row31);

        row01 = xtime(xtime(xtime(row0)))^xtime(xtime(row0))^row0;
        row11 = xtime(xtime(xtime(row1)))^row1;
        row21 = xtime(xtime(xtime(row2)))^xtime(xtime(row2))^xtime(row2);
        row31 = xtime(xtime(xtime(row3)))^xtime(row3)^row3;
        temp2 = (UNIT32)(row01^row11^row21^row31);

        row01 = xtime(xtime(xtime(row0)))^xtime(row0)^row0;
        row11 = xtime(xtime(xtime(row1)))^xtime(xtime(row1))^row1;
        row21 = xtime(xtime(xtime(row2)))^row2;
        row31 = xtime(xtime(xtime(row3)))^xtime(xtime(row3))^xtime(row3);
        temp3 = (UNIT32)(row01^row11^row21^row31);

        state[i] = (temp0<<24)|(temp1<<16)|(temp2<<8)|temp3;
    }
}

BWAES::BWAES()
{
    Nk = 4;
    Nb = 4;
    Nr = 10;

    rcon[0] = 0x01000000;
    rcon[1] = 0x02000000;
    rcon[2] = 0x04000000;
    rcon[3] = 0x08000000;
    rcon[4] = 0x10000000;
    rcon[5] = 0x20000000;
    rcon[6] = 0x40000000;
    rcon[7] = 0x80000000;
    rcon[8] = 0x1b000000;
    rcon[9] = 0x36000000;

    w = new UNIT32[Nb*(Nr+1)];
    state = new UNIT32[Nb];
}

// 暫時取消任意key長度的aes加解密
/*
BWAES::BWAES(int nk=4)
{
	Nk = nk;
	Nb = 4;
    switch ( nk )   {
        case 4:
            Nr = 10;
            break;
        case 6:
            Nr = 12;
            break;
        case 8:
            Nr = 14;
            break;
    }

    rcon[0] = 0x01000000;
    rcon[1] = 0x02000000;
    rcon[2] = 0x04000000;
    rcon[3] = 0x08000000;
    rcon[4] = 0x10000000;
    rcon[5] = 0x20000000;
    rcon[6] = 0x40000000;
    rcon[7] = 0x80000000;
    rcon[8] = 0x1b000000;
    rcon[9] = 0x36000000;

	w = new UNIT32[Nb*(Nr+1)];
    state = new UNIT32[Nb];
}
*/

BWAES::~BWAES()
{
	delete [] w;
    delete [] state;
}

void BWAES::KeyExpansion(UNIT32 *key)
{
	UNIT32 temp;
	int i=0;
	while ( i<Nk )	{
        w[i] = key[i];
		i++;
	}
	i = Nk;

	while ( i<Nb*(Nr+1) )	{
		temp = w[i-1];
		if ( i%Nk==0 )
			temp = SubWord(RotWord(temp))^rcon[(i/Nk)-1];
		else if ( Nk>6 && i%Nk==4 )
			temp = SubWord(temp);
		w[i] = w[i-Nk]^temp;
		i = i+1;
	}
}
void BWAES::Cipher(UNIT32 *in,UNIT32 *out)
{
    memcpy(state,in,Nb*sizeof(UNIT32));

    AddRoundKey(0);

    for ( int round=1 ; round<Nr ; round++ )    {
        SubBytes();
        ShiftRows();
        MixColumns();
        AddRoundKey(round);
    }
    SubBytes();
    ShiftRows();
    AddRoundKey(Nr);

    memcpy(out,state,Nb*sizeof(UNIT32));
}

void BWAES::InvCipher(UNIT32 *in,UNIT32 *out)
{
    memcpy(state,in,Nb*sizeof(UNIT32));

    AddRoundKey(Nr);

    for ( int round=Nr-1 ; round>0 ; round-- )    {
        InvShiftRows();
        InvSubBytes();
        AddRoundKey(round);
        InvMixColumns();
    }
    InvShiftRows();
    InvSubBytes();
    AddRoundKey(0);

    memcpy(out,state,Nb*sizeof(UNIT32));
}

bool BWAES::ReadDataFromFile(FILE *inf,UNIT32 in[4])
{
    unsigned char temp[16];
    memset(temp,0,16);

    int i;
    for ( i=0 ; i<16 && fread(&temp[i],1,1,inf) ; i++ ) ;

    in[0] = (temp[0]<<24)|(temp[1]<<16)|(temp[2]<<8)|(temp[3]);
    in[1] = (temp[4]<<24)|(temp[5]<<16)|(temp[6]<<8)|(temp[7]);
    in[2] = (temp[8]<<24)|(temp[9]<<16)|(temp[10]<<8)|(temp[11]);
    in[3] = (temp[12]<<24)|(temp[13]<<16)|(temp[14]<<8)|(temp[15]);

    if ( i<16 )
        return false;
    else
        return true;
}

bool BWAES::WriteDataToFile(FILE *outf,UNIT32 out[4])
{
    unsigned char temp[16];

    for ( int i=0 ; i<4 ; i++ ) {
        temp[i*4] = ((out[i]&0xff000000)>>24);
        temp[i*4+1] = ((out[i]&0x00ff0000)>>16);
        temp[i*4+2] = ((out[i]&0x0000ff00)>>8);
        temp[i*4+3] = (out[i]&0x000000ff);
    }
    fwrite(temp,16,1,outf);
    return true;
}

bool BWAES::ReadDataFromBuffer(int index, unsigned char *pBuffer, int size, UNIT32 in[4])
{
    unsigned char temp[16];
    memset(temp,0,16);

    int i;
    for ( i=0 ; i<16 && index*16+i<size ; i++ )
    {
        // index 為目前要處理的區塊索引, 每個區塊的大小為 16 Bytes.
        temp[i] = pBuffer[index*16+i];
    }

    in[0] = (temp[0]<<24)|(temp[1]<<16)|(temp[2]<<8)|(temp[3]);
    in[1] = (temp[4]<<24)|(temp[5]<<16)|(temp[6]<<8)|(temp[7]);
    in[2] = (temp[8]<<24)|(temp[9]<<16)|(temp[10]<<8)|(temp[11]);
    in[3] = (temp[12]<<24)|(temp[13]<<16)|(temp[14]<<8)|(temp[15]);

    if ( i<16 )
        return false;

    return true;
}
bool BWAES::WriteDataToBuffer(int index, unsigned char *pBuffer, UNIT32 out[4])
{
    unsigned char temp[16];

    for ( int i=0 ; i<4 ; i++ ) {
        temp[i*4] = ((out[i]&0xff000000)>>24);
        temp[i*4+1] = ((out[i]&0x00ff0000)>>16);
        temp[i*4+2] = ((out[i]&0x0000ff00)>>8);
        temp[i*4+3] = (out[i]&0x000000ff);
    }

    for ( int i=0 ; i<16 ; i++ )
    {
        // index 為目前要處理的區塊索引, 每個區塊的大小為 16 Bytes.
        pBuffer[index*16+i] = temp[i];
    }

    return true;
}

bool BWAES::encode(char* InputFileName, char* OutputFileName, char* KeyString)
{

    // 初始化Key
    unsigned char Md5String[16];
    auto_ptr<BWMD5> md5maker(new BWMD5);

    if(md5maker->generateMD5(KeyString, Md5String) == false)
    {
        return false;
    }

    UNIT32 *Key = new UNIT32[Nk];
    memcpy(Key, Md5String, sizeof(UNIT32)*Nk);
    KeyExpansion(Key);


    // 開始加密
    FILE *inf,*outf;
    inf = fopen(InputFileName,"rb");
    outf = fopen(OutputFileName,"wb");

    int FileSize=0;

    fseek(inf, 0L, SEEK_END);
    FileSize = ftell(inf);
    fseek(inf, 0L, SEEK_SET);

    UNIT32 in[4];
    UNIT32 out[4];

    if ( FileSize%16 )  {
        while ( ReadDataFromFile(inf,in) )  {
            Cipher(in,out);
            WriteDataToFile(outf,out);
        }
        Cipher(in,out);
        WriteDataToFile(outf,out);
    }
    else    {
        while ( ReadDataFromFile(inf,in) )  {
            Cipher(in,out);
            WriteDataToFile(outf,out);
        }
    }

    fclose(inf);
    fclose(outf);

    delete [] Key;

    return true;
}


bool BWAES::decode(char* InputFileName, char* OutputFileName, char* KeyString)
{
    // 初始化Key
    unsigned char Md5String[16];
    auto_ptr<BWMD5> md5maker(new BWMD5);

    if(md5maker->generateMD5(KeyString, Md5String) == false)
    {
        return false;
    }

    UNIT32 *Key = new UNIT32[Nk];
    memcpy(Key, Md5String, sizeof(UNIT32)*Nk);
    KeyExpansion(Key);


    // 開始解密
    FILE *inf,*outf;
    inf = fopen(InputFileName,"rb");
    outf = fopen(OutputFileName,"wb");

    UNIT32 in[4];
    UNIT32 out[4];

    while ( ReadDataFromFile(inf,in) )  {
        InvCipher(in,out);
        WriteDataToFile(outf,out);
    }

    fclose(inf);
    fclose(outf);

    delete [] Key;

    return true;
}

bool BWAES::encode(unsigned char *pSrcBuffer,int SrcSize,
                unsigned char *pDestBuffer, int DestSize, char *KeyString)
{
    // 存放加密結果的記憶體空間不足, 離開加密程式
    if ( DestSize!=(int)(ceil((double)SrcSize/16.0)*16) )
        return false;

    // 初始化Key
    unsigned char Md5String[16];
    auto_ptr<BWMD5> md5maker(new BWMD5);

    if(md5maker->generateMD5(KeyString, Md5String) == false)
    {
        return false;
    }

    UNIT32 *Key = new UNIT32[Nk];
    memcpy(Key, Md5String, sizeof(UNIT32)*Nk);
    KeyExpansion(Key);


    // 開始加密
    UNIT32 in[4];
    UNIT32 out[4];

    int index = 0;

    if ( SrcSize%16 )  {

        while ( ReadDataFromBuffer(index, pSrcBuffer, SrcSize, in) )  {
            Cipher(in,out);
            WriteDataToBuffer(index, pDestBuffer, out);
            index++;
        }
        Cipher(in,out);
        WriteDataToBuffer(index, pDestBuffer, out);
    }
    else    {
        while ( ReadDataFromBuffer(index, pSrcBuffer, SrcSize, in) )  {
            Cipher(in,out);
            WriteDataToBuffer(index, pDestBuffer, out);
            index++;
        }
    }


    delete [] Key;

    return true;



}

bool BWAES::decode(unsigned char *pSrcBuffer,int SrcSize,
                unsigned char *pDestBuffer, int DestSize, char *KeyString)
{
    if ( SrcSize!=DestSize )
        return false;

    // 初始化Key
    unsigned char Md5String[16];
    auto_ptr<BWMD5> md5maker(new BWMD5);

    if(md5maker->generateMD5(KeyString, Md5String) == false)
    {
        return false;
    }

    UNIT32 *Key = new UNIT32[Nk];
    memcpy(Key, Md5String, sizeof(UNIT32)*Nk);
    KeyExpansion(Key);

    // 開始解密
    UNIT32 in[4];
    UNIT32 out[4];

    int index = 0;

    while ( ReadDataFromBuffer(index, pSrcBuffer, SrcSize, in) )  {
        InvCipher(in,out);
        WriteDataToBuffer(index, pDestBuffer, out);
        index++;
    }

    delete [] Key;

    return true;

}
