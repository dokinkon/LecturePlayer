//---------------------------------------------------------------------------
//LINX:重複的函式後面加上NEW的代表STRING版本
//---------------------------------------------------------------------------

//BWExtractFilePath
//BWDirectoryExists



#ifndef BWFileManagerToolH
#define BWFileManagerToolH

#include <string>

using std::string;

namespace BW
{
/*
typedef void ( FAR PASCAL FProcessStatus )
(
  wchar_t * i_Status,
  int i_process,
  bool* o_bCancel
);
typedef FProcessStatus FAR *LP_FProcessStatus;
*/
//---------------------------------------------------------------------------
// Read and Write Registry
//---------------------------------------------------------------------------
/* windows need */
//string BWGetRegistryValue(string KeyName, string DataName);
//bool       BWSetRegistryValue(string KeyName, string DataName, string Value);

//---------------------------------------------------------------------------

//wchar_t * BWGetCurrentDir();
std::string BWGetCurrentDirNew();
//bool       BWSetCurrentDir(wchar_t * Dir);
//wchar_t * BWGetSpecialFolder(wchar_t * FolderName);
//wchar_t * BWSelectDir(HANDLE Handle, const wchar_t * Title);

bool       BWCreateDirectory(std::string Dir);

//bool       BWSearchFile(wchar_t * SrcDir, wchar_t * KeyWord, vector<wchar_t *> &FileNames);
//bool       BWSearchFileNew(string SrcDir, vector<string> &FileNames);
//bool       BWSearchDir(wchar_t * SrcDir, wchar_t * KeyWord, vector<wchar_t *> &DirNames);

//---------------------linx add-----------------------------------------------
//connie void wsplitpath(wstring FileName,wstring& dir,wstring& fname,wstring& ext);

    bool FileExists(std::string filename);
    void ChangeSlash(std::string& refname);
    void splitpath(std::string FileName,std::string& dir,std::string& fname,std::string& ext);
//-------------------------------------------------------------------------------------

/*connie
wstring  BWExtractFileDir(wstring FileName);
wstring  BWExtractFilePath(wstring FileName);
wstring  BWExtractFileName(wstring FileName);
wstring  BWExtractFileExt(wstring FileName);
*/

//-------------------linx add-------------------------------------------------


    std::string BWExtractFileDirNew(string FileName);
    std::string  BWExtractFilePathNew(string FileName);
    std::string  BWExtractFileNameNew(string FileName);
    std::string  BWExtractFileExtNew(string FileName);
string  BWExtractFileOnly(string FileName);
//-------------------------------------------------------------------------------------


//connie wstring BWChangeFileExt(wstring FileName, wstring Ext);
string BWChangeFileExtNew(string FileName, string Ext);


// 檢查檔案或目錄存不存在

//connie bool       BWFileExists(wstring FileName);
//--------------------linx add----------------------------
bool       BWFileExistsNew(string FileName);
bool       BWDirectoryExistsNew(string DirName);
//--------------------------------------------------------------
// connie android add
void writeXMLTofile( string DestFileName,  unsigned char *buffer, int buffer_size );
void convertutf_16to8(string xml_path_t, int buffer_size);

//connie bool       BWDirectoryExists(wstring DirName);

//- 計算資料夾中所有檔案的個數
//int      BWDirectoryFileCounts(string SrcDir);

/*
// 複製檔案或目錄
bool       BWCopyFile(wchar_t * SrcFileName, wchar_t * DestFileName);
//bool       BWCopyDirectory(wchar_t * SrcDir, wchar_t * DestDir, LP_FProcessStatus i_Process = NULL);
bool       BWCopyDirectory(wchar_t * SrcDir, wchar_t * DestDir);


// 刪除檔案或目錄
bool       BWDeleteFile(wchar_t * FileName);
//bool       BWDeleteDirectory(wchar_t * DestDir, LP_FProcessStatus i_Process = NULL);
bool       BWDeleteDirectory(wchar_t * DestDir);


// 更名檔案或目錄
bool       BWRenameFile(wchar_t * SrcFileName, wchar_t * DestFileName);
bool       BWRenameDir(wchar_t * SrcDirName, wchar_t * DestDirName);
*/

// 將記憶體資料存檔
//bool       BWSaveMemoryToFile(wstring FileName, unsigned char* pBufferData, unsigned long BufferSize);

// 20061127 Jerry add
// 寫入設定值
//bool BWWriteINIFile( const wchar_t * IniFile,const wchar_t * Section, const wchar_t * Ident,const wchar_t * Value );

// 讀取設定值
//wchar_t * BWReadINIFile( const wchar_t * IniFile,const wchar_t * Section,const wchar_t * Ident );

// Jerry Add
//wchar_t * BWAddPathSlash( wchar_t * iPath );
//wchar_t * BWDeletePathSlash( wchar_t * iPath );
/*
wchar_t * BWFindEmptySerialFileName( wchar_t * iFName );

//- 取消檔案唯讀屬性
bool BWSetFileNotReadOnly( wchar_t * iFn );

//- 判斷檔案副檔名
bool BWFileExtIs( wchar_t * iFile, const wchar_t *& iFileExt );

wchar_t * BWExtractShortPathName(wchar_t * FileName);

//- 取得傳入參數字串
wchar_t * BWParamStrW( int index );
*/
//- 搜尋資料夾下所有檔案大小
//bool BWGetDirSize( wchar_t * iPath, double& o_filesize );

class BWFileManagerTool
{
public:


    // 取得目錄下有那個名稱是沒有使用
    //wchar_t * FindEmptySerialFileName( wchar_t * iFName );

    // 將一字串分為字串與數字, 如將"abc123"分為"abc"與123
    struct DivideStr
    {
        wchar_t * str;
        int num;
    };

    DivideStr m_DivideStr;

   // void DivideStrAndNum( wchar_t * str , DivideStr &i_DivideStr );

    //讀取BWStorytellerSkinMaker.ini的字串
    //wchar_t * GetSkinMakeriniString( wchar_t * i_FileName , wchar_t * i_StringSection , wchar_t * i_StringKey );

    //寫入字串
    //bool WriteSkinMakeriniString( wchar_t * i_FileName , wchar_t * i_StringSection , wchar_t * i_StringKey , wchar_t * i_StringValue );



    //int  BWGetFileSize(wchar_t * FileName);
    //bool BWDeleteFileToRecycler(wchar_t * FileName);

};

// 一個全域的檔案管理物件
//static BWFileManagerTool g_filetool;


} // namespace BW
using namespace BW;


//---------------------------------------------------------------------------
#endif
