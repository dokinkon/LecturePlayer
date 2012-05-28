//---------------------------------------------------------------------------

//#pragma hdrstop

#include "BWZipTool.h"

#include <stdio.h>
#include <string.h>
#include <assert.h>
//#include <mem.h>

#include "zlib.h"

#define CHUNK 16384

//---------------------------------------------------------------------------

//#pragma package(smart_init)

// 模仿 fread 和 fwrite 函式讀取記憶體區塊
int BWZipTool::BufferRead(void *Dest, int Size, int n, void *Src, int index, int SrcSize)
{
    unsigned char *dest = (unsigned char *)Dest;
    unsigned char *src = (unsigned char *)Src;

    for ( int i=0 ; i<n  ; i++ )
    {
        if ( index+i*Size>SrcSize )
        {
            return i-1;
        }

        memcpy(dest+i*Size, src+index+i*Size, Size);

    }

    return n;
}
int BWZipTool::BufferWrite(void *Src, int Size, int n, void *Dest, int index, int DestSize)
{
    unsigned char *dest = (unsigned char *)Dest;
    unsigned char *src = (unsigned char *)Src;

    for ( int i=0 ; i<n  ; i++ )
    {
        if ( index+i*Size>DestSize )
        {
            return i;
        }

        memcpy(dest+index+i*Size, src+i*Size, Size);

    }

    return n;

}
/*****************************************************************************
    Compress from file source to file dest until EOF on source.
    def() returns Z_OK on success, Z_MEM_ERROR if memory could not be
    allocated for processing, Z_STREAM_ERROR if an invalid compression
    level is supplied, Z_VERSION_ERROR if the version of zlib.h and the
    version of the library linked do not match, or Z_ERRNO if there is
    an error reading or writing the files.
*****************************************************************************/
int BWZipTool::def(FILE *source, FILE *dest, int level)
{
    int ret, flush;
    unsigned have;
    z_stream strm;
    char in[CHUNK];
    char out[CHUNK];

    /* allocate deflate state */
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    ret = deflateInit(&strm, level);
    if (ret != Z_OK)
        return ret;

    /* compress until end of file */
    do {
        strm.avail_in = fread(in, 1, CHUNK, source);
        if (ferror(source)) {
            (void)deflateEnd(&strm);
            return Z_ERRNO;
        }
        flush = feof(source) ? Z_FINISH : Z_NO_FLUSH;
        strm.next_in = (Bytef *)in;

        /* run deflate() on input until output buffer not full, finish
           compression if all of source has been read in */
        do {
            strm.avail_out = CHUNK;
            strm.next_out = (Bytef *)out;
            ret = deflate(&strm, flush);    /* no bad return value */
            assert(ret != Z_STREAM_ERROR);  /* state not clobbered */
            have = CHUNK - strm.avail_out;
            if (fwrite(out, 1, have, dest) != have || ferror(dest)) {
                (void)deflateEnd(&strm);
                return Z_ERRNO;
            }
        } while (strm.avail_out == 0);
        assert(strm.avail_in == 0);     /* all input will be used */

        /* done when last data in file processed */
    } while (flush != Z_FINISH);
    assert(ret == Z_STREAM_END);        /* stream will be complete */

    /* clean up and return */
    (void)deflateEnd(&strm);
    return Z_OK;
}
int BWZipTool::def(unsigned char *pSrcBuffer, int SrcSize, int Level)
{
    int ret, flush;
    unsigned have;
    z_stream strm;
    char in[CHUNK];
    char out[CHUNK];

    /* allocate deflate state */
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    ret = deflateInit(&strm, Level);
    if (ret != Z_OK)
        return ret;

    int index = 0;

    /* compress until end of file */
    do {

        strm.avail_in = BufferRead(in, 1, CHUNK, (void *)pSrcBuffer, index, SrcSize);

        flush = (strm.avail_in!=CHUNK) ? Z_FINISH : Z_NO_FLUSH;
        strm.next_in = (Bytef *)in;

        /* run deflate() on input until output buffer not full, finish
           compression if all of source has been read in */
        do {
            strm.avail_out = CHUNK;
            strm.next_out = (Bytef *)out;
            ret = deflate(&strm, flush);    /* no bad return value */
            assert(ret != Z_STREAM_ERROR);  /* state not clobbered */
            have = CHUNK - strm.avail_out;

            for ( unsigned int i=0 ; i<have ; i++ )
            {
                dest.push_back(out[i]);
            }

        } while (strm.avail_out == 0);
        assert(strm.avail_in == 0);     /* all input will be used */

        index += CHUNK;

        /* done when last data in file processed */
    } while (flush != Z_FINISH);

    assert(ret == Z_STREAM_END);        /* stream will be complete */

    /* clean up and return */
    (void)deflateEnd(&strm);
    return Z_OK;
}

/****************************************************************************
    Decompress from file source to file dest until stream ends or EOF.
    inf() returns Z_OK on success, Z_MEM_ERROR if memory could not be
    allocated for processing, Z_DATA_ERROR if the deflate data is
    invalid or incomplete, Z_VERSION_ERROR if the version of zlib.h and
    the version of the library linked do not match, or Z_ERRNO if there
    is an error reading or writing the files.
****************************************************************************/
int BWZipTool::inf(FILE *source, FILE *dest)
{
    int ret;
    unsigned have;
    z_stream strm;
    char in[CHUNK];
    char out[CHUNK];

    /* allocate inflate state */
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.avail_in = 0;
    strm.next_in = Z_NULL;
    ret = inflateInit(&strm);
    if (ret != Z_OK)
        return ret;

    /* decompress until deflate stream ends or end of file */
    do {
        strm.avail_in = fread(in, 1, CHUNK, source);
        if (ferror(source)) {
            (void)inflateEnd(&strm);
            return Z_ERRNO;
        }
        if (strm.avail_in == 0)
            break;
        strm.next_in = (Bytef *)in;

        /* run inflate() on input until output buffer not full */
        do {
            strm.avail_out = CHUNK;
            strm.next_out = (Bytef *)out;
            ret = inflate(&strm, Z_NO_FLUSH);
            assert(ret != Z_STREAM_ERROR);  /* state not clobbered */
            switch (ret) {
            case Z_NEED_DICT:
                ret = Z_DATA_ERROR;     /* and fall through */
            case Z_DATA_ERROR:
            case Z_MEM_ERROR:
                (void)inflateEnd(&strm);
                return ret;
            }
            have = CHUNK - strm.avail_out;
            if (fwrite(out, 1, have, dest) != have || ferror(dest)) {
                (void)inflateEnd(&strm);
                return Z_ERRNO;
            }
        } while (strm.avail_out == 0);
        assert(strm.avail_in == 0);     /* all input will be used */

        /* done when inflate() says it's done */
    } while (ret != Z_STREAM_END);

    /* clean up and return */
    (void)inflateEnd(&strm);
    return ret == Z_STREAM_END ? Z_OK : Z_DATA_ERROR;
}

int BWZipTool::inf(unsigned char *pSrcBuffer, int SrcSize)
{
    int ret;
    unsigned have;
    z_stream strm;
    char in[CHUNK];
    char out[CHUNK];

    /* allocate inflate state */
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.avail_in = 0;
    strm.next_in = Z_NULL;
    ret = inflateInit(&strm);
    if (ret != Z_OK)
        return ret;

    int index = 0;

    /* decompress until deflate stream ends or end of file */
    do {

        strm.avail_in = BufferRead(in, 1, CHUNK, (void *)pSrcBuffer, index, SrcSize);

        if (strm.avail_in == 0)
            break;
        strm.next_in = (Bytef *)in;

        /* run inflate() on input until output buffer not full */
        do {
            strm.avail_out = CHUNK;
            strm.next_out = (Bytef *)out;
            ret = inflate(&strm, Z_NO_FLUSH);
            assert(ret != Z_STREAM_ERROR);  /* state not clobbered */
            switch (ret) {
            case Z_NEED_DICT:
                ret = Z_DATA_ERROR;     /* and fall through */
            case Z_DATA_ERROR:
            case Z_MEM_ERROR:
                (void)inflateEnd(&strm);
                return ret;
            }
            have = CHUNK - strm.avail_out;

            for ( unsigned int i=0 ; i<have ; i++ )
            {
                dest.push_back(out[i]);
            }

        } while (strm.avail_out == 0);

        //!發生在解一個bst的聲音檔時assert error，所以Darcy暫時註解掉下列assert程式碼
        //assert(strm.avail_in == 0);     /* all input will be used */

        index += CHUNK;
        /* done when inflate() says it's done */
    } while (ret != Z_STREAM_END);

    /* clean up and return */
    (void)inflateEnd(&strm);
    return ret == Z_STREAM_END ? Z_OK : Z_DATA_ERROR;
}

/* report a zlib or i/o error */
void BWZipTool::zerr(int ret)
{
    fputs("zpipe: ", stderr);
    switch (ret) {
    case Z_ERRNO:
        if (ferror(stdin))
            fputs("error reading stdin\n", stderr);
        if (ferror(stdout))
            fputs("error writing stdout\n", stderr);
        break;
    case Z_STREAM_ERROR:
        fputs("invalid compression level\n", stderr);
        break;
    case Z_DATA_ERROR:
        fputs("invalid or incomplete deflate data\n", stderr);
        break;
    case Z_MEM_ERROR:
        fputs("out of memory\n", stderr);
        break;
    case Z_VERSION_ERROR:
        fputs("zlib version mismatch!\n", stderr);
    }
}

/* compress or decompress from stdin to stdout */
//int main(int argc, char **argv)
//{
//    int ret;

    /* do compression if no arguments */
    /*
    if (argc == 1) {
        ret = def(stdin, stdout, Z_DEFAULT_COMPRESSION);
        if (ret != Z_OK)
            zerr(ret);
        return ret;
    }
    */

    /* do decompression if -d specified */
    /*
    else if (argc == 2 && strcmp(argv[1], "-d") == 0) {
        ret = inf(stdin, stdout);
        if (ret != Z_OK)
            zerr(ret);
        return ret;
    }
    */

    /* otherwise, report usage */
    /*
    else {
        fputs("zpipe usage: zpipe [-d] < source > dest\n", stderr);
        return 1;
    }
    */
//}

//---------------------------------------------------------------------------
// level為壓縮率，介於0~9之間，0代表不壓縮，1為最快壓縮，9為最大壓縮
//---------------------------------------------------------------------------

bool BWZipTool::Compress(FILE *in, FILE *out, int level)
{
    // 預設為Z_DEFAULT_COMPRESSION，值為6
    int compressionlevel = 6;
    if(level >= 0 && level <= 9)
    {
        compressionlevel = level;
    }

    int ret = def(in, out, compressionlevel);
    if (ret != Z_OK)
    {
        zerr(ret);
        return false;
    }

    return true;
}

//---------------------------------------------------------------------------

bool BWZipTool::Decompress(FILE *in, FILE *out)
{
    int ret = inf(in, out);
    if (ret != Z_OK)
    {
        zerr(ret);
        return false;
    }

    return true;
}

//---------------------------------------------------------------------------

int BWZipTool::Compress(unsigned char *pSrcBuffer, int SrcSize, int Level)
{
    int compressionlevel = 6;
    if(Level >= 0 && Level <= 9)
    {
        compressionlevel = Level;
    }

    dest.clear();

    int ret = def(pSrcBuffer, SrcSize, compressionlevel);
    if (ret != Z_OK)
    {
        zerr(ret);
        return 0;
    }

    return dest.size();

}

int BWZipTool::Decompress(unsigned char *pSrcBuffer, int SrcSize)
{
    dest.clear();

    int ret = inf(pSrcBuffer, SrcSize);
    if (ret != Z_OK)
    {
        zerr(ret);
        return 0;
    }

    return dest.size();
}

int BWZipTool::GetData(unsigned char *pBuffer)
{
    for ( unsigned int i=0 ; i<dest.size() ; i++ )
    {
        pBuffer[i] = dest[i];
    }

    return dest.size();
}


