#include "ResourceFile2.h"
#include "globals.h"
#include <fstream>

#include "BWCipherDll.h"
#include "BWZipTool.h"
#include "BWFileManagerTool.h"
#include "BWStringTool.h"

//add by darren
cmap::~cmap(){
    for(  iterator itr=this->begin() ; itr!=this->end() ; ++itr ){
        if( (*itr).second.buffer!=NULL ){
            delete[] (*itr).second.buffer;
    }
  }
}

const char ScriptAtomType[4] = {'s', 'c', 'r', 'p'};    // 腳本檔案
const char SoundAtomType[4]  = {'s', 'o', 'u', 'd'};    // 聲音檔案
const char VideoAtomType[4]  = {'v', 'i', 'd', 'o'};    // Camera錄製檔案
const char ScreenAtonType[4] = {'s', 'v', 'i', 'd'};    // 全螢幕錄製檔案
const char PPTXMLAtomType[4] = {'p', 'x', 'm', 'l'};    // PPT轉出的XML檔案
const char ShapeAtomType[4]  = {'s', 'h', 'a', 'p'};    // 演員圖檔
const char AttachAtomType[4] = {'a', 't', 't', 'e'};    // 附加檔案
const char PPTMediaAtomType[4] = {'p', 'm', 'e', 'd'};  // PPT裡面使用到的多媒體檔案，目前只有.wmv檔
const char ExtendAtomType[4] = {'e', 'x', 't', 'e'};    // 延伸資訊，儲存播放完畢檔案是否刪除等資訊
const char CommonAtomType[4] = {'c', 'o', 'm', 'm'};    // 共同檔案


/****************************************************************************
    CDataPackage member function
****************************************************************************/

CDataPackage::CDataPackage()
{
    m_pBuffer = NULL;
    m_Size = 0;
    m_State.clear();
}
CDataPackage::~CDataPackage()
{
    SAFE_DELETE_ARRAY(m_pBuffer);
    m_State.clear();
}

bool CDataPackage::SetState(unsigned char State)
{
    if ( State==ZIP_Compress || State==DES_Encryption || State==AES_Encryption )
    {
        m_State.push_back(State);
        return true;
    }

    return false;
}

void CDataPackage::ClearState(void)
{
    m_State.clear();
}

unsigned long CDataPackage::Execute(unsigned char *pSrcBuffer, unsigned long SrcSize)
{
    SAFE_DELETE_ARRAY(m_pBuffer);

    m_pBuffer = new unsigned char[SrcSize+7];
    m_Size = SrcSize+7;

    m_pBuffer[0] = 'd';
    m_pBuffer[1] = 'a';
    m_pBuffer[2] = 't';
    SetSize(m_pBuffer+3, SrcSize);

    memcpy(m_pBuffer+7, pSrcBuffer, SrcSize);

    for ( unsigned int index=0 ; index<m_State.size() ; index++ )
    {
        switch( m_State[index] )
        {
            case ZIP_Compress :
                m_Size = ZIPCompress();
                break;
            case DES_Encryption :
                m_Size = DESEncryption();
                break;
            case AES_Encryption :
                m_Size = AESEncryption();
                break;
        }
    }
    return m_Size;
}

unsigned long CDataPackage::InvExecute(unsigned char *pSrcBuffer, unsigned long SrcSize)
{
    if ( SrcSize<7 )
        return 0;
    SAFE_DELETE_ARRAY(m_pBuffer);
    m_pBuffer = new unsigned char[SrcSize];
    m_Size = SrcSize;
    memcpy(m_pBuffer, pSrcBuffer, SrcSize);
    unsigned char State;

    while ( NeedInvExecute(m_pBuffer, &State) )
    {
        switch( State )
        {
            case ZIP_Compress :
                m_Size = ZIPInvCompress();
                break;
            case DES_Encryption :
                m_Size = DESInvEncryption();
                break;
            case AES_Encryption :
                m_Size = AESInvEncryption();
                break;
        }
    }

    if ( m_pBuffer[0]!='d' || m_pBuffer[1]!='a' || m_pBuffer[2]!='t' )
    {
        return 0;
    }

    unsigned long Size = GetSize(m_pBuffer, 3);

    unsigned char *pBuffer = new unsigned char[Size];

    memcpy(pBuffer, m_pBuffer+7, Size);

    SAFE_DELETE_ARRAY(m_pBuffer);

    m_pBuffer = pBuffer;
    m_Size = Size;
    return Size;
}

int CDataPackage::GetData(unsigned char *pBuffer)
{
    memcpy(pBuffer, m_pBuffer, m_Size);
    return m_Size;
}
//----------------------------------------------------------------------------------------
void CDataPackage::SetKey(string Key)
{
    m_Key.assign(Key);
	LOGD("key:");
	LOGD( m_Key.c_str());  
}
//----------------------------------------------------------------------------------------
bool CDataPackage::NeedInvExecute(unsigned char *pBuffer, unsigned char *State)
{
    if ( pBuffer[0]=='z' && pBuffer[1]=='i' && pBuffer[2]=='p' )
    {
        *State = ZIP_Compress;
        return true;
    }

    if ( pBuffer[0]=='d' && pBuffer[1]=='e' && pBuffer[2]=='s' )
    {
        //LOGD("#############test log des"); 
        *State = DES_Encryption;
        return true;
    }

    if ( pBuffer[0]=='a' && pBuffer[1]=='e' && pBuffer[2]=='s' )
    {
        //LOGD("#############test log aes"); 
        *State = AES_Encryption;
        return true;
    }
    *State = 0;
    //LOGD("#############test log end false"); 
    return false;
}
unsigned long CDataPackage::GetSize(unsigned char *pBuffer, int index)
{
    unsigned long Size = (pBuffer[index]<<24) + (pBuffer[index+1]<<16) + (pBuffer[index+2]<<8) + pBuffer[index+3];
    return Size;
}
void CDataPackage::SetSize(unsigned char *pBuffer, unsigned long Size)
{
    *pBuffer = (Size&0xff000000)>>24;
    *(pBuffer+1) = (Size&0x00ff0000)>>16;
    *(pBuffer+2) = (Size&0x0000ff00)>>8;
    *(pBuffer+3) =  Size&0x000000ff;
}

unsigned long CDataPackage::ZIPCompress(void)
{
    BWZipTool ZipTool;
    int Size = ZipTool.Compress(m_pBuffer, m_Size, 9);
    unsigned char *pTmpBuffer = new unsigned char[Size];
    ZipTool.GetData(pTmpBuffer);

    SAFE_DELETE_ARRAY(m_pBuffer);

    m_pBuffer = new unsigned char[Size+11];

    m_pBuffer[0] = 'z';
    m_pBuffer[1] = 'i';
    m_pBuffer[2] = 'p';
    SetSize(m_pBuffer+3, Size);
    SetSize(m_pBuffer+7, m_Size);

    memcpy(m_pBuffer+11, pTmpBuffer, Size);

    SAFE_DELETE_ARRAY(pTmpBuffer);

    m_Size = Size+11;

    return m_Size;
}
unsigned long CDataPackage::DESEncryption(void)
{

    int Size = BWCipherDll::BWCipherEncodeSize(m_Size, "DES");
    unsigned char *pTmpBuffer = new unsigned char[Size];

    BWCipherDll::BWCipherEncode(m_pBuffer, m_Size, pTmpBuffer, Size, (char*)m_Key.c_str(), "DES");

    SAFE_DELETE_ARRAY(m_pBuffer);

    m_pBuffer = new unsigned char[Size+11];

    m_pBuffer[0] = 'd';
    m_pBuffer[1] = 'e';
    m_pBuffer[2] = 's';
    SetSize(m_pBuffer+3, Size);
    SetSize(m_pBuffer+7, m_Size);

    memcpy(m_pBuffer+11, pTmpBuffer, Size);

    SAFE_DELETE_ARRAY(pTmpBuffer);

    m_Size = Size+11;

    return m_Size;

}
unsigned long CDataPackage::AESEncryption(void)
{
    int Size = BWCipherDll::BWCipherEncodeSize(m_Size, "AES");
    unsigned char *pTmpBuffer = new unsigned char[Size];

    BWCipherDll::BWCipherEncode(m_pBuffer, m_Size, pTmpBuffer, Size, (char*)m_Key.c_str(), "AES");

    SAFE_DELETE_ARRAY(m_pBuffer);

    m_pBuffer = new unsigned char[Size+11];

    m_pBuffer[0] = 'a';
    m_pBuffer[1] = 'e';
    m_pBuffer[2] = 's';
    SetSize(m_pBuffer+3, Size);
    SetSize(m_pBuffer+7, m_Size);

    memcpy(m_pBuffer+11, pTmpBuffer, Size);

    SAFE_DELETE_ARRAY(pTmpBuffer);

    m_Size = Size+11;

    return m_Size;
}

unsigned long CDataPackage::ZIPInvCompress(void)
{
    unsigned long DataSize = GetSize(m_pBuffer, 3);
    unsigned char *pTmpBuffer = new unsigned char[DataSize];

    memcpy(pTmpBuffer, m_pBuffer+11, DataSize);

    BWZipTool ZipTool;

    int Size = ZipTool.Decompress(pTmpBuffer, DataSize);

    SAFE_DELETE_ARRAY(m_pBuffer);

    m_pBuffer = new unsigned char[Size];

    ZipTool.GetData(m_pBuffer);
    m_Size = Size;

    SAFE_DELETE_ARRAY(pTmpBuffer);

    return m_Size;
}
unsigned long CDataPackage::DESInvEncryption(void)
{
    unsigned long DataSize = GetSize(m_pBuffer, 3);
    unsigned long OriginalSize = GetSize(m_pBuffer, 7);

    unsigned char *pTmpBuffer1 = new unsigned char[DataSize];
    unsigned char *pTmpBuffer2 = new unsigned char[DataSize];

    memcpy(pTmpBuffer1, m_pBuffer+11, DataSize);

	LOGD("key:");
	LOGD( m_Key.c_str());  
    BWCipherDll::BWCipherDecode(pTmpBuffer1, DataSize, pTmpBuffer2, DataSize,(char*)m_Key.c_str(), "DES");
    
    SAFE_DELETE_ARRAY(m_pBuffer);

    m_pBuffer = new unsigned char[OriginalSize];

    memcpy(m_pBuffer, pTmpBuffer2, OriginalSize);
    m_Size = OriginalSize;

    SAFE_DELETE_ARRAY(pTmpBuffer1);
    SAFE_DELETE_ARRAY(pTmpBuffer2);

    return m_Size;
}
unsigned long CDataPackage::AESInvEncryption(void)
{
    unsigned long DataSize = GetSize(m_pBuffer, 3);
    unsigned long OriginalSize = GetSize(m_pBuffer, 7);

    unsigned char *pTmpBuffer1 = new unsigned char[DataSize];
    unsigned char *pTmpBuffer2 = new unsigned char[DataSize];

    memcpy(pTmpBuffer1, m_pBuffer+11, DataSize);

    BWCipherDll::BWCipherDecode(pTmpBuffer1, DataSize, pTmpBuffer2, DataSize,(char*) m_Key.c_str(), "AES");

    SAFE_DELETE_ARRAY(m_pBuffer);

    m_pBuffer = new unsigned char[OriginalSize];

    memcpy(m_pBuffer, pTmpBuffer2, OriginalSize);
    m_Size = OriginalSize;

    SAFE_DELETE_ARRAY(pTmpBuffer1);
    SAFE_DELETE_ARRAY(pTmpBuffer2);

    return m_Size;

}
//---------------------------------------------------------------------------
CDataAtom::CDataAtom()
{
    m_pBuffer = NULL;
    m_Size = 0;
}
//--------------------------------------------------------------------------------------------
CDataAtom::~CDataAtom()
{
    SAFE_DELETE_ARRAY(m_pBuffer);
}
//--------------------------------------------------------------------------------------------
void CDataAtom::SetWriteFile(string FileName)
{
    FILE *stream = fopen(FileName.c_str(), "wb");
    fclose(stream);
}
//--------------------------------------------------------------------------------------------
bool CDataAtom::SetState(unsigned char State)
{
    return m_DataPackage.SetState(State);
}
//--------------------------------------------------------------------------------------------
unsigned long CDataAtom::Write(unsigned char *pBuffer, unsigned long Size, long &Offset)
{
    if ( Size==0 )
    {
        return 0;
    }

    m_Size = m_DataPackage.Execute(pBuffer, Size);

    SAFE_DELETE_ARRAY(m_pBuffer);
    m_pBuffer = new unsigned char[m_Size];
    m_DataPackage.GetData(m_pBuffer);

    FILE* stream = fopen(m_FileName.c_str(), "ab");

    fseek(stream, 0L, SEEK_END);
    Offset = ftell(stream);
    fwrite(m_pBuffer, m_Size, 1, stream);
    fclose(stream);
    return m_Size;
}
//--------------------------------------------------------------------------------------------
void CDataAtom::SetReadFile(string FileName)
{
    m_FileName = FileName;
}

//每一個INFO去讀取各自的DATA
unsigned long CDataAtom::Read(unsigned long Offset, unsigned long Size)
{
    //----------------------------------------------------------------
    //cout << "----------------in CDataAtom::Read-------------------" << endl;
    //----------------------------------------------------------------
    unsigned char *pSrcBuffer = new unsigned char[Size];

    FILE *stream;
  
    stream = fopen(m_FileName.c_str(), "rb");
    fseek(stream, Offset, SEEK_SET);
    fread(pSrcBuffer, Size, 1, stream);    	
    fclose(stream);
    unsigned long TmpSize;
    TmpSize = m_DataPackage.InvExecute(pSrcBuffer, Size);
    if ( TmpSize!=0 )
    {
        SAFE_DELETE_ARRAY(m_pBuffer);
        m_pBuffer = new unsigned char[TmpSize];
        m_DataPackage.GetData(m_pBuffer);
        m_Size = TmpSize; 
    }
    SAFE_DELETE_ARRAY(pSrcBuffer);
    return TmpSize;
}

unsigned long CDataAtom::Read(unsigned char *pBuffer, unsigned long Offset, unsigned long Size)
{
    unsigned char *pSrcBuffer = new unsigned char[Size];

    memcpy(pSrcBuffer, pBuffer+Offset, Size);
    unsigned long TmpSize;
    TmpSize = m_DataPackage.InvExecute(pSrcBuffer, Size);
    if ( TmpSize!=0 )
    {
        SAFE_DELETE_ARRAY(m_pBuffer);
        m_pBuffer = new unsigned char[TmpSize];
        m_DataPackage.GetData(m_pBuffer);
        m_Size = TmpSize;
    }
    SAFE_DELETE_ARRAY(pSrcBuffer);

    return TmpSize;
}

unsigned long CDataAtom::GetData(unsigned char *pBuffer)
{
    //----------------------------------------------------------------
    //cout << "----------------in CDataAtom::GetData-------------------" << endl;
    //cout << "m_pBuffer: " << m_pBuffer << endl;
    //----------------------------------------------------------------
    memcpy(pBuffer, m_pBuffer, m_Size);
    return m_Size;
}

string CDataAtom::GetTmpFileName(void)
{
    return m_FileName;
}

// End CDataAtom
//---------------------------------------------------------------------------

/****************************************************************************
    CInfoAtom member function
****************************************************************************/




bool CInfoAtom::ReadFromFile(FILE *stream)//connieok
{
     //----------------------------------------------------------------
    //cout << "----------------in CInfoAtom::ReadFromFile-------------------" << endl;
    //----------------------------------------------------------------
    long CurOffset = ftell(stream);     //return current pos in the file

    char Type[4];
    fread(Type, 4, 1, stream);

    if ( !IsInfoAtom(Type) )
    {
        // 如果是沒有定義的 Type 則將 stream 跳回到原先的位置
        fseek(stream, CurOffset, SEEK_SET);
        return false;
    }

    memcpy(m_Type, Type, 4);
    fread(&m_Size, 4, 1, stream);
    fread(&m_RefNameSize, 4, 1, stream);

    //connie error
    char16_t *refname = new char16_t[m_RefNameSize];	
    fread(refname, m_RefNameSize * 2, 1, stream); 
    m_RefName = Char16ToString(refname,m_RefNameSize );
    SAFE_DELETE_ARRAY(refname);



    ChangeSlash(m_RefName);    //connie 應在BWFileManagerTool.h 為了測試先複製過來
    fread(&m_RefSize, 4, 1, stream);
    fread(&m_DataOffset, 4, 1, stream);
    fread(&m_DataSize, 4, 1, stream);
    return true;
}

//connie 應在BWFileManagerTool.h 為了測試先複製過來
//--------------------------------------------------------------------------
//linx add 必需要先PARSE REFNAME,若遇到\要轉換成/的LINUX格式
void CInfoAtom::ChangeSlash(string& refname)
{
    unsigned int start = 0;
    while( (start=refname.find("\\",start))!=string::npos ){
        refname.replace( start , 1 , "/" );
        start++;
    }
}
//---------------------------------------------------------------------------

unsigned long CInfoAtom::ReadFromBuffer(unsigned char *pBuffer, unsigned long Offset)
{
    unsigned long Size = 0;
    char Type[4];
    memcpy(Type, pBuffer+Offset, 4);
    Offset += 4;
    Size += 4;
    if ( !IsInfoAtom(Type) )
    {
        // 如果是沒有定義的 Type 則將 stream 跳回到原先的位置
        return 0;
    }

    memcpy(m_Type, Type, 4);

    memcpy(&m_Size, pBuffer+Offset, 4);
    Offset += 4;
    Size += 4;

    memcpy(&m_RefNameSize, pBuffer+Offset, 4);
    Offset += 4;
    Size += 4;
    
    char16_t *RefName = new char16_t[m_RefNameSize];
    //connie wmemset(RefName, 0, m_RefNameSize);
    memcpy(RefName, pBuffer+Offset, m_RefNameSize*2);
    Offset += (m_RefNameSize*2);
    Size += (m_RefNameSize*2);
    //connie not sure m_RefName.assign(RefName, m_RefNameSize);
	m_RefName = Char16ToString(RefName,m_RefNameSize);

    SAFE_DELETE_ARRAY(RefName);

    memcpy(&m_RefSize, pBuffer+Offset, 4);
    Offset += 4;
    Size += 4;

    memcpy(&m_DataOffset, pBuffer+Offset, 4);
    Offset += 4;
    Size += 4;

    memcpy(&m_DataSize, pBuffer+Offset, 4);
    Offset += 4;
    Size += 4;

    return Size;
}

bool CInfoAtom::WriteToFile(FILE *stream)
{
    fwrite(m_Type, 4, 1, stream);
    fwrite(&m_Size, 4, 1, stream);
    fwrite(&m_RefNameSize, 4, 1, stream);
    fwrite(m_RefName.c_str(), m_RefNameSize*2, 1, stream);
    fwrite(&m_RefSize, 4, 1, stream);
    fwrite(&m_DataOffset, 4, 1, stream);
    fwrite(&m_DataSize, 4, 1, stream);
    return true;
}

void CInfoAtom::Assign(char Type[4], string RefName, unsigned long RefSize, unsigned long DataOffset, unsigned long DataSize)
{
    memcpy(m_Type, Type, 4);
    m_RefName = RefName;
    m_RefSize = RefSize;
    m_DataOffset = DataOffset;
    m_DataSize = DataSize;

    m_RefNameSize = RefName.size();
    m_Size = 24+m_RefNameSize*2;
}
void CInfoAtom::Get(char Type[4], string &RefName, unsigned long &RefSize, unsigned long &DataOffset, unsigned long &DataSize)
{
    memcpy(Type, m_Type, 4);
    RefName = m_RefName;
    RefSize = m_RefSize;
    DataOffset = m_DataOffset;
    DataSize = m_DataSize;
}

//---------------------------------------------------------------------------
bool CInfoAtom::IsInfoAtom(char Type[4])
{
    if ( memcmp(Type, ScriptAtomType, 4)==0 )
        return true;
    else if ( memcmp(Type, SoundAtomType, 4)==0 )
        return true;
    else if ( memcmp(Type, PPTXMLAtomType, 4)==0 )
        return true;
    else if ( memcmp(Type, ShapeAtomType, 4)==0 )
        return true;
    else if ( memcmp(Type, AttachAtomType, 4)==0 )
        return true;
    else if ( memcmp(Type, CommonAtomType, 4)==0 )
        return true;
    else if ( memcmp(Type, VideoAtomType, 4)==0 )
        return true;
    else if ( memcmp(Type, ScreenAtonType, 4)==0 )
        return true;
    else if ( memcmp(Type, PPTMediaAtomType, 4)==0 )
        return true;
    else if ( memcmp(Type, ExtendAtomType, 4)==0 )
        return true;
    return false;
}
//---------------------------------------------------------------------------
CTopicResource::CTopicResource()
{
    m_Type[0] = 't';
    m_Type[1] = 'h';
    m_Type[2] = 'e';
    m_Type[3] = 'a';

    m_Application[0] = 'b';
    m_Application[1] = 'w';
    m_Application[2] = 's';
    m_Application[3] = 't';

    m_Version[0] = '0';
    m_Version[1] = '0';
    m_Version[2] = '.';
    m_Version[3] = '0';
    m_Version[4] = '1';

	m_DataAtom.SetKey(string("123"));
    m_Title = "";
    m_TitleSize = 0;

    m_DRMServer = "";
    m_DRMServerSize = 0;
    m_ID = 0;
    m_DelAfterPlay = false;
}
//--------------------------------------------------------------------------------------
CTopicResource::~CTopicResource()
{
    m_RefName.clear();
    m_InfoAtom.clear();
}
//--------------------------------------------------------------------------------------
bool CTopicResource::ReadFromFile(const string& fileName, vector<string>& Info)
{
    char Type[4];
    char Application[4];
    char Version[5];
    char DRMVersion[5] = {'0', '0', '.', '0', '3'};
   
    FILE *stream = fopen(fileName.c_str(), "rb");
    if( !stream )
    {
        return false;
    }

    fread(Type, 4, 1, stream);

    if ( memcmp(Type, m_Type, 4)!=0 )
        return false;

    fread(Application, 4, 1, stream);
    fread(Version, 5, 1, stream);
    m_RefName.clear();
    m_InfoAtom.clear();
    Info.clear();

    memcpy(m_Type, Type, 4);
    memcpy(m_Application, Application, 4);
    memcpy(m_Version, Version, 5);
    fread(&m_Size, 4, 1, stream);
    fread(&m_TitleSize, 4, 1, stream);

    char16_t *Title = new char16_t[m_TitleSize ];	
    fread(Title, m_TitleSize, 1, stream); 
    m_Title = Char16ToString(Title,m_TitleSize/2 );
    SAFE_DELETE_ARRAY(Title);

    if ( memcmp(m_Version, DRMVersion, 5)==0 )
    {	
        fread(&m_DRMServerSize, 4, 1, stream);
        if ( m_DRMServerSize!=0 )
        { 
            char16_t *pDRMServer = new char16_t[m_DRMServerSize];
			fread(pDRMServer, m_DRMServerSize, 1, stream);
	        m_DRMServer = Char16ToString(pDRMServer,m_DRMServerSize/2 );
			LOGD("m_DRMServer");
			LOGD(m_DRMServer.c_str());
            SAFE_DELETE_ARRAY(pDRMServer);
        }
        fread(&m_ID, 4, 1, stream);
    }

    int counter = 0;
    bool have;
    do
    {
        CInfoAtom InfoAtom;
        have = InfoAtom.ReadFromFile(stream);
        InfoAtom.UpdateDataOffset(m_Size);
        if ( have==true )
        {	
            string RefName;
            RefName = InfoAtom.GetRefName();
            m_RefName.push_back(RefName);
            m_InfoAtom[RefName] = InfoAtom;
            Info.push_back(RefName);
            tempTest += "resource ReadFromFile WHILE";
        }
    } while ( have );
    m_DataAtom.SetReadFile(fileName);
    fclose(stream);
    return true;
}

unsigned long CTopicResource::GetData(string RefName, unsigned char *pBuffer, unsigned long Size, unsigned long EnableSize)
{
    if ( EnableSize<(m_InfoAtom[RefName].GetDataOffset() + m_InfoAtom[RefName].GetDataSize()) )
        return 0;
    unsigned long DataSize = m_DataAtom.Read(m_InfoAtom[RefName].GetDataOffset(), m_InfoAtom[RefName].GetDataSize()); //connie 讀檔頭資料
//out << "3 "<< endl;

    if ( DataSize!=m_InfoAtom[RefName].GetRefSize() )
        return 0;
    if ( DataSize!=Size )
        return 0;   // 存取的記憶體區塊大小不同
    m_DataAtom.GetData(pBuffer);   //paste data's m_pBuffer to pBuffer
    m_DataAtom.ReleaseBuffer();
    return DataSize;
}
//connie not check
bool CTopicResource::ReadFromBuffer(unsigned char *pSrcBuffer, unsigned long SrcSize, vector<string> &Info)
{
    if ( SrcSize<17 )
        return false;
    int Offset = 0;
    char DRMVersion[5] = {'0', '0', '.', '0', '3'};
    char Type[4];
    char Application[4];
    char Version[5];

    memcpy(Type, pSrcBuffer+Offset, 4);
    Offset += 4;
    if ( memcmp(Type, m_Type, 4)!=0 )
        return false;

    memcpy(Application, pSrcBuffer+Offset, 4);
    Offset += 4;
    memcpy(Version, pSrcBuffer+Offset, 5);
    Offset += 5;
    m_RefName.clear();
    m_InfoAtom.clear();
    Info.clear();

    memcpy(m_Type, Type, 4);
    memcpy(m_Application, Application, 4);
    memcpy(m_Version, Version, 5);

    memcpy(&m_Size, pSrcBuffer+Offset, 4);
    Offset += 4;

    if ( SrcSize<m_Size )
        return false;

    memcpy(&m_TitleSize, pSrcBuffer+Offset, 4);
    Offset += 4;

    char16_t *Title = new char16_t[m_TitleSize];
    memcpy(Title, pSrcBuffer+Offset, m_TitleSize);
    Offset += m_TitleSize;
    m_Title = Char16ToString(Title,m_TitleSize/2);
    SAFE_DELETE_ARRAY(Title);

    //-------------------------------------------------------------
	//connie not sure
    if ( memcmp(m_Version, DRMVersion, 5)==0 )
    {
        memcpy(&m_DRMServerSize, pSrcBuffer+Offset, 4);
        Offset += 4;

        if ( m_DRMServerSize!=0 )
        {
            char16_t *pDRMServer = new char16_t[m_DRMServerSize+1];
            memset(pDRMServer, 0, (m_DRMServerSize+1)*2);
            memcpy(pDRMServer, pSrcBuffer+Offset, m_DRMServerSize);
            Offset += m_DRMServerSize;
            m_DRMServer =Char16ToString(pDRMServer,m_DRMServerSize/2);
            SAFE_DELETE_ARRAY(pDRMServer);
        }

        memcpy(&m_ID, pSrcBuffer+Offset, 4);
        Offset += 4;
    }
    //-------------------------------------------------------------

    // Read info atom

    unsigned long size;
    do
    {
        CInfoAtom InfoAtom;
        size = InfoAtom.ReadFromBuffer(pSrcBuffer, Offset);
        InfoAtom.UpdateDataOffset(m_Size);
        if ( size!=0 )
        {
            string RefName;
            RefName = InfoAtom.GetRefName();
            m_RefName.push_back(RefName);
            m_InfoAtom[RefName] = InfoAtom;
            Info.push_back(RefName);

            Offset += size;
        }
    } while ( size!=0 );

    return true;
}

unsigned long CTopicResource::GetDataFromBuffer(unsigned char *pSrcBuffer, unsigned long SrcSize, string RefName, unsigned char *pBuffer, unsigned long Size)
{
    if ( SrcSize<(m_InfoAtom[RefName].GetDataOffset() + m_InfoAtom[RefName].GetDataSize()) )
        return 0;
    unsigned long DataSize = m_DataAtom.Read(pSrcBuffer, m_InfoAtom[RefName].GetDataOffset(), m_InfoAtom[RefName].GetDataSize());
    if ( DataSize!=m_InfoAtom[RefName].GetRefSize() )
        return 0;
    if ( DataSize!=Size )
        return 0;   // 存取的記憶體區塊大小不同
    m_DataAtom.GetData(pBuffer);
    m_DataAtom.ReleaseBuffer();
    return DataSize;
}
//-----------------------------------------------------------------------------------------------------------
unsigned int CTopicResource::GetEnabledRefName(vector<string> &RefNames, unsigned long EnabledSize)
{
    RefNames.clear();
    map<string, CInfoAtom>::iterator iter;
    for ( unsigned int index=0 ; index<m_RefName.size() ; index++ )
    {
        iter = m_InfoAtom.find(m_RefName[index]);

        if ( iter==m_InfoAtom.end() )
        {
            continue;
        }

        if ( m_RefName[index]==iter->first && EnabledSize>=(iter->second.GetDataOffset()+iter->second.GetDataSize()) )
        {
            string tmp = iter->first;
            RefNames.push_back(iter->first);
        }
    }
    return RefNames.size();
}
// 讀入 bst 檔案並且寫入到指定的資料夾裡(單機版講解手BST適用,BST的解秘密鑰是magical)
bool CTopicResource::WriteBSTToDir(string BSTFileName, string DirName)
{
    vector<string> Info;
    if (!ReadFromFile(BSTFileName, Info)) //connie 把wstring => string
    {
        Info.clear();
        return false;
    }

    string DestFileName;
    unsigned long size;
    for ( unsigned int index=0 ; index<Info.size() ; index++ )
    {
        DestFileName = DirName + "/" + Info[index];
        NSLog(@"DEST FILE NAME:%s", DestFileName.c_str());

        // 建立需要的目錄
        vector<string> Dirs;
        string tmpDir ;
        tmpDir = BWExtractFileDirNew(DestFileName);

        if ( !BWDirectoryExistsNew(tmpDir) ){
            //out1 << "Dir not exit" << tmpDir <<endl;
        }
        else{
            //out1 << "Dir exit" << tmpDir <<endl;
        }
        while ( !BWDirectoryExistsNew(tmpDir) )
        {
            int k=0;
            Dirs.push_back(tmpDir);
            tmpDir = BWExtractFileDirNew(tmpDir);
            k++;
        }

        for ( int i=Dirs.size()-1 ; i>=0 ; i-- )
        {
            // out1 <<"creat tmpDir" << tmpDir << endl;	    
            BWCreateDirectory(Dirs[i]);
        }
        Dirs.clear();
        //  out1 << "save file begin dse" <<  DestFileName << endl;

        // 儲存檔案
        size = GetSize(Info[index]);     //info's m_RefSize

        unsigned char *pBuf = new unsigned char[size];

        unsigned long EnableSize = 0xffffffff;

        size = GetData(Info[index], pBuf, size,EnableSize); //connie: 在這裡解密解壓縮...
        //   out1 << "getData end\n size = " << size << endl;

        if ( size==0 )
        {
            SAFE_DELETE_ARRAY(pBuf);
            return false;
        }


        //add by darren
        //判斷副檔是否為圖檔或.xml檔( .emf .bmp .jpg .png .wmf .xml)是的話 就存到ImageBuffer中
        //connie L"jpg" -> "jpg"
        if ( Info[index].length()>3 ) {
            if ( Info[index].compare( Info[index].length()-3 , 3 , "jpg" )==0 ||
                 Info[index].compare( Info[index].length()-3 , 3 , "png" )==0 ||
                 Info[index].compare( Info[index].length()-3 , 3 , "bmp" )==0 ||
                 Info[index].compare( Info[index].length()-3 , 3 , "emf" )==0 ||
                 Info[index].compare( Info[index].length()-3 , 3 , "wmf" )==0 ||
                 Info[index].compare( Info[index].length()-3 , 3 , "xml" )==0 ){

                ImageBufferInfo tmpInfo;	      
                tmpInfo.size=size;              
                tmpInfo.buffer=pBuf;	       

                //connie加!!!!
                //if 是.xml的話~要把編碼從utf-16全部轉成utf-8
                if(Info[index].compare( Info[index].length()-3 , 3 , "xml" )==0 ){
                    //先輸出檔案看看
                    //out1 << "data content" << endl;
                    char16_t *tpBuf = new  char16_t[size/2];

                    for(int i = 0; i <tmpInfo.size;i++ ){
                        int tempi;
                        if(i % 2 == 0){
                            tempi = ((int)pBuf[i]);		
                        }
                        else{
                            tempi += ((int)pBuf[i])*256;
                            tpBuf[(i-1)/2] = (char16_t)tempi;
                        }
                    }
                    string s = Char16ToString(tpBuf,size/2);
                    s.replace(33,7,"utf-8");
                    tempTest.append(s);
                }
                //connie end
                m_ImageBuffer[Info[index]]=tmpInfo;	   
                continue;
            }
        }
        FILE *stream = fopen(DestFileName.c_str(), "wb");
        fwrite(pBuf, size, 1, stream);
        fclose(stream);
        SAFE_DELETE_ARRAY(pBuf);
    }
    Info.clear();
    return true;
}
//------------------------------------------------------------------------------------
unsigned long CTopicResource::GetSize(const string& refName)
{
    return m_InfoAtom[refName].GetRefSize();
}
//------------------------------------------------------------------------------------
string CTopicResource::GetPPTXMLRefName(void)
{
    string refName = "";
    map<string, CInfoAtom>::iterator iter;
    for ( iter=m_InfoAtom.begin() ; iter!=m_InfoAtom.end() ; iter++ )
    {
        char* type = iter->second.GetType();
        if ( memcmp(type, PPTXMLAtomType, 4)==0 )
        {
            refName = iter->second.GetRefName();
            break;
        }
    }
    return refName;
}
//------------------------------------------------------------------------
string CTopicResource::GetScriptRefName(void)
{
    string refName = "";
    map<string, CInfoAtom>::iterator iter = m_InfoAtom.begin();
    for (;iter!=m_InfoAtom.end();iter++)
    {
        char* type = iter->second.GetType();
        if ( memcmp(type, ScriptAtomType, 4)==0 )
        {
            refName = iter->second.GetRefName();
            break;
        }
    }
    return refName;
}
//------------------------------------------------------------------------
string CTopicResource::GetSoundRefName(void)
{
    string refName = "";
    map<string, CInfoAtom>::iterator iter = m_InfoAtom.begin();
    for (;iter!=m_InfoAtom.end();iter++)
    {
        char* type = iter->second.GetType();
        if ( memcmp(type, SoundAtomType, 4)==0 )
        {
            refName = iter->second.GetRefName();
            break;
        }
    }
    return refName;
}
//------------------------------------------------------------------------
bool CTopicResource::GetSoundRefNames(vector<string>& soundRefNames)
{
    soundRefNames.clear();
    map<string, CInfoAtom>::iterator iter = m_InfoAtom.begin();
    for (;iter!=m_InfoAtom.end();iter++)
    {
        char* type = iter->second.GetType();
        if ( memcmp(type, SoundAtomType, 4)==0 )
        {
            string refName = iter->second.GetRefName();
            soundRefNames.push_back(refName);
        }
    }
    return true;
}
//----------------------------------------------------------------------------------------
bool CTopicResource::GetVideoRefNames(vector<string>& videoRefNames)
{
    videoRefNames.clear();
    map<string, CInfoAtom>::iterator iter = m_InfoAtom.begin();

    for (;iter!=m_InfoAtom.end();iter++)
    {
        char* type = iter->second.GetType();
        if ( memcmp(type, VideoAtomType, 4)==0 )
        {
            string refName = iter->second.GetRefName();
            videoRefNames.push_back(refName);
        }
    }
    return true;
}
//----------------------------------------------------------------------------------------
bool CTopicResource::GetScreenRefNames(const string& firstName, vector<string>& screenRefNames)
{
    screenRefNames.clear();
    string refName = "";
    map<string, CInfoAtom>::iterator iter = m_InfoAtom.begin();
    for (;iter!=m_InfoAtom.end();iter++)
    {
        char* type = iter->second.GetType();
        if ( memcmp(type, ScreenAtonType, 4)==0 )
        {
            refName = iter->second.GetRefName();
            vector<string> Para;

            char seps[] = "-";
            char *subString = NULL;
            char *refname = new char[refName.length() + 1];
            strcpy(refname, refName.c_str());

            for (subString = strtok( refname, seps);
                    subString != NULL;
                    subString = strtok(NULL, seps)) {
                string result(subString);
                Para.push_back( result);
            }

            string refFileName;
            for ( unsigned int index=0 ; index<Para.size()-1 ; index++ )
            {
                refFileName += Para[index];
                if ( index<Para.size()-2 )
                {
                    refFileName += string("-");
                }
            }

            if ( refFileName== firstName )
            {
                screenRefNames.push_back(iter->second.GetRefName());
            }
        }
    }
    return true;
}
//--------------------------------------------------------------------------------
unsigned long CTopicResource::GetImageRefName(vector<string>& refNames)
{
    map<string, CInfoAtom>::iterator iter = m_InfoAtom.begin();
    for (;iter!=m_InfoAtom.end();iter++)
    {
        char* type = iter->second.GetType();
        if ( memcmp(type, ShapeAtomType, 4)==0 )
        {
            string tmpRefName = iter->second.GetRefName();
            refNames.push_back(tmpRefName);
        }
    }
    return (unsigned long)refNames.size();
}
//--------------------------------------------------------------------------------
unsigned long CTopicResource::GetAttachmentRefName(vector<string>& refNames)
{
    map<string, CInfoAtom>::iterator iter = m_InfoAtom.begin();
    for (;iter!=m_InfoAtom.end();iter++)
    {
        char* type = iter->second.GetType();
        if ( memcmp(type, AttachAtomType, 4)==0 )
        {
            string tmpRefName = iter->second.GetRefName();
            refNames.push_back(tmpRefName);
        }
    }
    return (unsigned long)refNames.size();
}
//--------------------------------------------------------------------------------
unsigned long CTopicResource::GetMediaRefName(vector<string>& refNames)
{
    map<string, CInfoAtom>::iterator iter = m_InfoAtom.begin();
    for (;iter!=m_InfoAtom.end();iter++)
    {
        char* type = iter->second.GetType();
        if ( memcmp(type, PPTMediaAtomType, 4)==0)
        {
            string tmpRefName = iter->second.GetRefName();
            refNames.push_back(tmpRefName);
        }

    }
    return (unsigned long)refNames.size();
}
//---------------------------------------------------------------
string CTopicResource::GetDRMServer(void)
{
    return m_DRMServer;
}
//---------------------------------------------------------------------
unsigned long CTopicResource::GetID(void)
{
    return m_ID;
}




