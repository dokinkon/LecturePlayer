#include "BWStringTool.h"
#include <fstream>

static int wlen = 100;
using namespace std;

namespace BW
{
string xmlconvert(unsigned char* buffer ,int size)
{
    char16_t *tpBuf = new  char16_t[size/2];
    for(int i = 0; i <size ;i++ )
    {
        int tempi;
        if(i % 2 == 0)
        {
            tempi = ((int)buffer[i]);		
        }
        else
        {
            tempi += ((int)buffer[i])*256;
            tpBuf[(i-1)/2] = (char16_t)tempi;
        }
    }
    //  char *tpBuf = "abc";
    string s = Char16ToString(tpBuf,size/2);
    s.replace(33,7,"utf-8");        
    SAFE_DELETE_ARRAY(tpBuf);
    return s;
}
//---------------------------------------------------------------------------
string xmlconvertFormfile(string fileName)
{
    string result = "";
    FILE *stream = fopen(fileName.c_str(), "rb");
    int headerSize = 120;
    char16_t *header = new char16_t[headerSize];	
    fread(header, headerSize, 1, stream); 
    string m_header = "<?xml version= \"1.0\" encoding=\"utf-8\" standalone=\"yes\" ?>";
    string m_content ="";	
    char16_t temp16;

    while (!feof(stream)) {
        fread(&temp16, sizeof(char16_t), 1, stream); 
        m_content.append(Char16ToString(&temp16,1));
    }
    fclose(stream );
    result = m_header + m_content;
    ofstream out("/sdcard/temp1.xml");
    out << result << endl;
    return result;
}
//---------------------------------------------------------------------------
string Char16ToString(char16_t *C, int size)
{
    NSData* data = [NSData dataWithBytes:C length:size*sizeof(char16_t)];
    NSString* s = [[[NSString alloc] initWithData:data encoding:NSUTF16LittleEndianStringEncoding] autorelease];
    return string([s cStringUsingEncoding:NSUTF8StringEncoding]);
}
//---------------------------------------------------------------------------
unsigned long wcharToDWORD(wchar_t wchar)
{
    if (wchar==L'0')
        return 0;
    else if (wchar==L'1')
        return 1;
    else if (wchar==L'2')
        return 2;
    else if (wchar==L'3')
        return 3;
    else if (wchar==L'4')
        return 4;
    else if (wchar==L'5')
        return 5;
    else if (wchar==L'6')
        return 6;
    else if (wchar==L'7')
        return 7;
    else if (wchar==L'8')
        return 8;
    else if (wchar==L'9')
        return 9;
    return 10;
}
//---------------------------------------------------------------------------
unsigned long stringToDWORD(string data, unsigned long def)
{
    unsigned long dword = 0;

    for ( unsigned int index=0; index<data.length() ; index++ )
    {
        if ( charToDWORD(data.at(index))!=10 )
            dword = dword*10+charToDWORD(data.at(index));
        else
            return def;
    }
    return dword;
}
//-------------------------------------------------------------------------
unsigned long charToDWORD(char wchar)
{
    if (wchar=='0')
        return 0;
    else if (wchar=='1')
        return 1;
    else if (wchar=='2')
        return 2;
    else if (wchar=='3')
        return 3;
    else if (wchar=='4')
        return 4;
    else if (wchar=='5')
        return 5;
    else if (wchar=='6')
        return 6;
    else if (wchar=='7')
        return 7;
    else if (wchar=='8')
        return 8;
    else if (wchar=='9')
        return 9;
    return 10;
}
//------------------------------------------------------------------------------
int stringToInt(string data, int def_value)
{
    int value = 0;
    char temp[wlen];
    sprintf(temp,"%s",data.c_str());
    value = atoi(temp);
    return value;
}
//------------------------------------------------------------------------------
string IntToStringNew(int value, int letternum)
{
    char* result = new char[wlen];

    if(letternum <= 0)
    {
        sprintf(result,"%d",value);
        return string(result);
    }

    char *ch_result = new char[wlen];
    char *temp1 = new char[wlen];
    char *temp2 = new char[wlen];
    for(int i=0;i<letternum;i++)
    {
        sprintf(temp2,"%d",value%10);
        temp1=strcat(temp2,ch_result);
        strcpy(ch_result,temp1);
        value = value/10;
    }
    sprintf(result,"%s",ch_result);
    return string(result);
}
//-------------------------------------------------------------------
string IntToString16New(int value, int letternum)
{
    ofstream out1("/sdcard/tttt.txt");
    out1 << value<< endl;
    // char* result = new char[wlen];
    string result = "";
    int temp;
    do
    {
        temp  = (int)(value/16);
        if(temp == 0)
            temp = value % 16;

        switch (temp)
        {
            case 0:
                result.append("0");
                break;
            case 1:
                result.append("1");
                break;
            case 2:
                result.append( "2");
                break;
            case 3:
                result.append( "3");
                break;
            case 4:
                result.append( "4");
                break;
            case 5:
                result.append( "5");
                break;		
            case 6:
                result.append("6");
                break;
            case 7:
                result.append("7");
                break;
            case 8:
                result.append( "8");
                break;
            case 9:
                result.append( "9");
                break;

            case 10:
                result.append("a");
                break;
            case 11:
                result.append("b");
                break;
            case 12:
                result.append( "c");
                break;
            case 13:
                result.append( "d");
                break;
            case 14:
                result.append( "e");
                break;
            case 15:
                result.append( "f");
                break;		
        }		 
    } while ((value /16) > 1);

    if(value == 15)
        out1 << "===="<<endl;
    out1 << result << endl;
    return result;
}
//--------------------------------------------------------------------------------
bool BWReplaceStringNew(string &SourceText, string A, string B)
{
    if(A.size() == 0)
    {
        return false;
    }

    do
    {
        int index = SourceText.find(A.c_str(), 0);

        if(index >= 0)
        {
            SourceText.erase(index, A.size());
            SourceText.insert(index, B);
        }
        else
        {
            break;
        }
    } while (true);
    return true;
}

//---------------------------------------------------------------------------
string BWGenerateValidURL(string URL)
{
    string url = URL;
    BWReplaceStringNew(url, "%", "1123.1123.1123");
    BWReplaceStringNew(url, "1123.1123.1123", "%25");

    BWReplaceStringNew(url, "'", "%60");
    BWReplaceStringNew(url, "[", "%5B");
    BWReplaceStringNew(url, "]", "%5D");
    BWReplaceStringNew(url, "#", "%23");
    BWReplaceStringNew(url, "^", "%5E");
    BWReplaceStringNew(url, "&", "%26");
    BWReplaceStringNew(url, "{", "%7B");
    BWReplaceStringNew(url, "}", "%7D");
    BWReplaceStringNew(url, " ", "%20");

    BWReplaceStringNew(url, "\r", "%5Cr");
    BWReplaceStringNew(url, "\n", "%5Cn");
    return url;
}
} // namespace BW

//---------------------------------------------------------------------------

