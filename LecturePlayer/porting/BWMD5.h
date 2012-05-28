//---------------------------------------------------------------------------
#ifndef BWMD5H
#define BWMD5H
#include "globals.h"
#include <string>
//---------------------------------------------------------------------------
class BWMD5
{
public:
    std::string  md5sum(char*  InputFileName);
    // OutputString 是16Byte的資料，也就是128bit的資料
    bool generateMD5(char*  InputString, unsigned char* OutputString);
};

//---------------------------------------------------------------------------
#endif
