//---------------------------------------------------------------------------
//
// BWZipTool，利用zlib來作壓縮和解壓縮，執行時需要包含zlib1.dll
//
//---------------------------------------------------------------------------

#ifndef BWZipToolH
#define BWZipToolH

#include <stdio.h>
#include <vector>

class BWZipTool
{

    std::vector<unsigned char> dest;

    // 模仿 fread 和 fwrite 函式讀取記憶體區塊
    int BufferRead(void *Dest, int Size, int n, void *Src, int index, int SrcSize);
    int BufferWrite(void *Src, int Size, int n, void *Dest, int index, int DestSize);

    /**********************************************************************
      Compress from file source to file dest until EOF on source.
      def() returns Z_OK on success, Z_MEM_ERROR if memory could not be
      allocated for processing, Z_STREAM_ERROR if an invalid compression
      level is supplied, Z_VERSION_ERROR if the version of zlib.h and the
      version of the library linked do not match, or Z_ERRNO if there is
      an error reading or writing the files.
    **********************************************************************/
    int def(FILE *source, FILE *dest, int level);
    int def(unsigned char *pSrcBuffer, int SrcSize, int Level);

    /*************************************************************************
      Decompress from file source to file dest until stream ends or EOF.
      inf() returns Z_OK on success, Z_MEM_ERROR if memory could not be
      allocated for processing, Z_DATA_ERROR if the deflate data is
      invalid or incomplete, Z_VERSION_ERROR if the version of zlib.h and
      the version of the library linked do not match, or Z_ERRNO if there
      is an error reading or writing the files.
    *************************************************************************/
    int inf(FILE *source, FILE *dest);
    int inf(unsigned char *pSrcBuffer, int SrcSize);


    /* report a zlib or i/o error */
    void zerr(int ret);





public:
    bool Compress(FILE *in, FILE *out, int level);

    bool Decompress(FILE *in, FILE *out);

    int Compress(unsigned char *pSrcBuffer, int SrcSize, int Level);

    int Decompress(unsigned char *pSrcBuffer, int SrcSize);

    int GetDataSize(void)
    {
        return dest.size();
    }

    int GetData(unsigned char *pBuffer);

};


//---------------------------------------------------------------------------
#endif
 
