//
//---------------------------------------------------------------------------
// connie
// 把 "BWCipherDll.h 的function內容拆到"BWCipherDll.cpp
// 避免在兩個檔案內都include BWCipherDll.h  所產生的 error "multiple definition of [function name]"
// 
//
//---------------------------------------------------------------------------

#include "BWCipherDll.h"
#include "TPlayerMainForm.h"

//---------------------------------------------------------------------------
// 將BWCipherDll的函式都寫在命名空間BWCipherDll中
//---------------------------------------------------------------------------

namespace BWCipherDll
{
	bool FileExists(char* filename){
		FILE* test = fopen(filename,"r");
		if(test == NULL){
			return false;
		}
		else{
			fclose(test);
			return true;
		}
	}
    char* BWCipherDllVerson()
    {
        // BWCipher目前版本是0.4
        char* BWCipherDllVerson = "0.4 support Trible-DES, AES.";
        return BWCipherDllVerson;
    }

    bool BWCipherEncode(char *inputfilename, char* outputfilename, char *keystring, char *cipheralgorithm)
    {
        if(FileExists(inputfilename) == false)
        {
            return false;
        }

        char* CipherAlgorithm = cipheralgorithm;

        if(CipherAlgorithm == "DES")
        {
            auto_ptr<BWDES> desmaker(new BWDES);
            return (desmaker->encode(inputfilename, outputfilename, keystring) == true) ? true :false;
        }
        else if(CipherAlgorithm == "AES")
        {
            auto_ptr<BWAES> aesmaker(new BWAES);
            return (aesmaker->encode(inputfilename, outputfilename, keystring) == true) ? true :false;
        }
        return false;
    }

    bool BWCipherDecode(char *inputfilename, char* outputfilename, char *keystring, char *cipheralgorithm)
    {
        if(FileExists(inputfilename) == false)
        {
            return false;
        }

        char* CipherAlgorithm = cipheralgorithm;
        if(CipherAlgorithm == "DES")
        {
            auto_ptr<BWDES> desmaker(new BWDES);
            return (desmaker->decode(inputfilename, outputfilename, keystring) == true) ? true :false;
        }
        else if(CipherAlgorithm == "AES")
        {
            auto_ptr<BWAES> aesmaker(new BWAES);
            return (aesmaker->decode(inputfilename, outputfilename, keystring) == true) ? true :false;
        }

        return false;
    }

    bool BWCipherEncode(unsigned char *pSrcBuffer,int srcsize,
                    unsigned char *pDestBuffer, int destsize,
                    char *keystring, char *cipheralgorithm)
    {

        if( strcmp(cipheralgorithm, "DES")==0 )
        {
            if ( destsize!=(int)(ceil((double)srcsize/8.0)*8) )
                return false;

            auto_ptr<BWDES> desmaker(new BWDES);
            return (desmaker->encode(pSrcBuffer, srcsize, pDestBuffer, destsize, keystring) == true) ? true :false;
        }
        else if( strcmp(cipheralgorithm, "AES")==0 )
        {
            if ( destsize!=(int)(ceil((double)srcsize/16.0)*16) )
            return false;

            auto_ptr<BWAES> aesmaker(new BWAES);
            return (aesmaker->encode(pSrcBuffer, srcsize, pDestBuffer, destsize, keystring) == true) ? true :false;
        }

        return false;
    }

     bool BWCipherDecode(unsigned char *pSrcBuffer,int srcsize,
                    unsigned char *pDestBuffer, int destsize,
                    char *keystring, char *cipheralgorithm)
    {
        // 解密的 SrcBuffer size 跟 DestBuffer size 要ㄧ樣大
        if ( srcsize!=destsize )
            return false;

        if( strcmp(cipheralgorithm, "DES")==0 )
        {
            auto_ptr<BWDES> desmaker(new BWDES);
            return (desmaker->decode(pSrcBuffer, srcsize, pDestBuffer, destsize, keystring) == true) ? true :false;
        }
        else if( strcmp(cipheralgorithm, "AES")==0 )
        {
            auto_ptr<BWAES> aesmaker(new BWAES);
            return (aesmaker->decode(pSrcBuffer, srcsize, pDestBuffer, destsize, keystring) == true) ? true :false;
        }

        return false;
    }

    int BWCipherEncodeSize(int size, char *cipheralgorithm)
    {
        // 依不同的加密方式所需要的 Buffer size
        if( strcmp(cipheralgorithm, "DES")==0 )
        {
            return (int)(ceil((double)size/8.0)*8);
        }
        else if( strcmp(cipheralgorithm, "AES")==0 )
        {
            return (int)(ceil((double)size/16.0)*16);
        }

        return 0;
    }

    string BWCipherMd5Sum(char* inputfilename)
    {
        auto_ptr<BWMD5> pMD5(new BWMD5);
		string Md5String = pMD5->md5sum(inputfilename);
        return Md5String;
    }
}

