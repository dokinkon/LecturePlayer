#ifndef __BWSTRINGTOOLH__
#define __BWSTRINGTOOLH__

#include <string>
#include "globals.h"

namespace BW
{
using std::string;
typedef short char16_t;
string xmlconvert(unsigned char*,int size);
string xmlconvertFormfile(string fileName);
string Char16ToString(char16_t *C, int size);
unsigned long stringToDWORD(string data, unsigned long def);
unsigned long charToDWORD(char wchar);
int stringToInt(string data, int def_value);
string IntToStringNew(int value, int letternum);
string IntToString16New(int value, int letternum); 
bool   BWReplaceStringNew(string &SourceText, string A, string B);
string BWGenerateValidURL(string URL);

} // namesapce BW
//---------------------------------------------------------------------------
#endif
