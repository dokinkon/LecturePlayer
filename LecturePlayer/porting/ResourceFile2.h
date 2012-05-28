//---------------------------------------------------------------------------
//#include <utils/String16.h>
//#include <utils/String8.h>
//#include "BWCipherDll.h"

/*
#include "BWCipherDll.h"
#include "BWZipTool.h"
#include "BWFileManagerTool.h"
#include "BWStringTool.h"
#include "globals.h"
#include <fstream>
*/
#ifndef ResourceFileH
#define ResourceFileH

#include <vector>
#include <string>
#include <map>

using std::vector;
using std::string;
using std::map;


//connie#include "IResourceFile.h"

//---------------------------------------------------------------------------

#define ZIP_Compress 0x01
#define DES_Encryption 0x10
#define AES_Encryption 0x20

#include "globals.h"

//---------------------------------------------------------------------------
//add by darren
struct ImageBufferInfo{
    unsigned long size;
    unsigned char *buffer;
};

class cmap:public map< string , ImageBufferInfo >{
public:
    ~cmap();
};



class CDataPackage
{
public:
    CDataPackage();
    ~CDataPackage();

    bool SetState(unsigned char State);
    void ClearState(void);

    unsigned long Execute(unsigned char *pSrcBuffer, unsigned long SrcSize);  //unsigned long~double word by win32 API

    unsigned long InvExecute(unsigned char *pSrcBuffer, unsigned long SrcSize);

    int GetData(unsigned char *pBuffer);

    void SetKey(string Key);

private:
    unsigned char *m_pBuffer;
    unsigned long m_Size;

    vector<unsigned char> m_State;
    string m_Key;

    bool NeedInvExecute(unsigned char *pBuffer, unsigned char *State);

    unsigned long GetSize(unsigned char *pBuffer, int index);
    void SetSize(unsigned char *pBuffer, unsigned long Size);

    unsigned long ZIPCompress(void);
    unsigned long DESEncryption(void);
    unsigned long AESEncryption(void);

    unsigned long ZIPInvCompress(void);
    unsigned long DESInvEncryption(void);
    unsigned long AESInvEncryption(void);
};


class CDataAtom
{
public:
    CDataAtom();
    ~CDataAtom();

    // 寫入DataAtom所需要的函式
    //connie void SetWriteFile(wstring FileName);
    void SetWriteFile(string FileName);

    bool SetState(unsigned char State);

    void ClearState(void)
    {
        m_DataPackage.ClearState();
    }

    unsigned long Write(unsigned char *pBuffer, unsigned long Size, long &Offset);
     // 讀入DataAtom所需要的函式, 檔案
     //connie   void SetReadFile(wstring FileName);
    void SetReadFile(string FileName);
    // 從檔案裡讀取 DataAtom 資料
    unsigned long Read(unsigned long Offset, unsigned long Size);
    // 從 buffer 裡讀取 DataAtom 資料
    unsigned long Read(unsigned char *pBuffer, unsigned long Offset, unsigned long Size);

    unsigned long GetData(unsigned char *pBuffer);

    unsigned long GetSize(void)
    {
        return m_Size;
    }

//connie    wstring GetTmpFileName(void);
    string GetTmpFileName(void);

    void SetKey(string Key)
    {
        m_DataPackage.SetKey(Key);
    }

    void ReleaseBuffer(void)
    {
        SAFE_DELETE_ARRAY(m_pBuffer);
        m_Size = 0;
    }

    bool IsEmpty(void)
    {
        if ( m_pBuffer==NULL )
            return true;

        return false;
    }

private:
    //connie wstring m_FileName;
    string m_FileName;

    unsigned char *m_pBuffer;
    unsigned long m_Size;

    CDataPackage m_DataPackage;


};

class CInfoAtom
{
public:

    bool ReadFromFile(FILE *stream);
    unsigned long ReadFromBuffer(unsigned char *pBuffer, unsigned long Offset);
    bool WriteToFile(FILE *stream);
    void Assign(char Type[4], string RefName, unsigned long RefSize, unsigned long DataOffset, unsigned long DataSize);
    void Get(char Type[4], string &RefName, unsigned long &RefSize, unsigned long &DataOffset, unsigned long &DataSize);
    //connie wstring GetRefName(void)
    string GetRefName(void)
    {
        return m_RefName;
    }

    unsigned long GetAtomSize(void)
    {
        return m_Size;
    }

    unsigned long GetRefSize(void)
    {
        return m_RefSize;
    }

    unsigned long GetDataOffset(void)
    {
        return m_DataOffset;
    }

    unsigned long GetDataSize(void)
    {
        return m_DataSize;
    }

    char * GetType(void)
    {
        return m_Type;
    }

    void UpdateDataOffset(unsigned long Offset)
    {
        m_DataOffset += Offset;
    }

private:

    char m_Type[4];
    unsigned long m_Size;
    unsigned long m_RefNameSize;
    string m_RefName;

    unsigned long m_RefSize;
    unsigned long m_DataOffset;
    unsigned long m_DataSize;
    void ChangeSlash(string& refname);
    bool IsInfoAtom(char Type[4]);
};

//不考慮WRITE的函式 並且只使用一種GETDATA&GETDATAFROMBUFFER的方法
class CTopicResource//:public ITopicResourceFile
{
public:
    CTopicResource();
    ~CTopicResource();
   
    //add by darren
    cmap m_ImageBuffer;
    
    string tempTest;  
  
     // Path為完整路徑, 例如:"c:\\講解手測試\\測試投影片\\04-package\\001-BST"
    //virtual bool  WriteToFile(wstring DirName, wstring FileName, vector<wstring> &Info);

    //virtual bool  WriteToFile(vector<wstring> FileList, wstring FileName, vector<wstring> &Info);

    // 兩種讀取 bst 資料的方法不可混合使用
    // 從 .bst 檔案裡面讀取資料
    // EnableSize 是指目前檔案的大小，因為檔案可能是重網路上下載，所以可能還沒下載到所需要的檔案區塊
    virtual bool  ReadFromFile(const string& FileName, vector<string> &Info);
    virtual unsigned long GetData(string RefName, unsigned char *pBuffer, unsigned long Size, unsigned long EnableSize = 0xffffffff);

    // 從記憶體區塊讀取資料
    virtual bool  ReadFromBuffer(unsigned char *pSrcBuffer, unsigned long SrcSize, vector<string> &Info);
    virtual unsigned long GetDataFromBuffer(unsigned char *pSrcBuffer, unsigned long SrcSize, string RefName, unsigned char *pBuffer, unsigned long Size);
    virtual unsigned int GetEnabledRefName(vector<string> &RefNames, unsigned long EnabledSize = 0xffffffff); //connie not sure

    // 讀入 bst 檔案並且寫入到指定的資料夾裡
    virtual bool WriteBSTToDir(string BSTFileName, string DirName);

    virtual unsigned long   GetSize(const string& RefName);
  
    virtual string GetPPTXMLRefName(void);
    virtual string GetScriptRefName(void);

    virtual string GetSoundRefName(void);
    virtual bool GetSoundRefNames(vector<string> &SoundRefNames);
    virtual bool GetVideoRefNames(vector<string> &VideoRefNames);
    virtual bool GetScreenRefNames(const string& FirstName, vector<string> &ScreenRefNames);
    virtual unsigned long GetImageRefName(vector<string> &RefName);
    virtual unsigned long GetAttachmentRefName(vector<string> &RefName);
    virtual unsigned long GetMediaRefName(vector<string> &RefName);
    //---------------------------------------------------------------
    virtual string GetDRMServer(void);
    virtual unsigned long GetID(void);

    // 以下需先設定解密密碼才可取得資料
    virtual bool GetDelAfterPlay(void)
    {
        return m_DelAfterPlay;
    }
    //----------------------------------------------------------------

    // 設定加解密的 Key
    virtual void SetKey(string Key)
    {
        m_DataAtom.SetKey(Key);
    }

    virtual bool SetState(unsigned char State)
    {
        return m_DataAtom.SetState(State);
    }

    virtual void ClearState(void)
    {
        m_DataAtom.ClearState();
    }
    //---------------------------------------------------------------
    virtual void SetApplication(char App[4])
    {
        memcpy(m_Application, App, 4);
    }

    virtual void SetVersion(char Version[5])
    {
        memcpy(m_Version, Version, 5);
    }

    virtual void SetTitle(string Title)
    {
        m_Title = Title;
        if ( !m_Title.empty() )
        {
            m_TitleSize = m_Title.size() + 2;
        }
        else
        {
            m_TitleSize = 0;
        }
    }

    virtual void SetDRMServer(string DRMServer)
    {
        m_DRMServer = DRMServer;
        if ( !m_DRMServer.empty() )
        {
            m_DRMServerSize = m_DRMServer.size() + 2;
        }
        else
        {
            m_DRMServerSize = 0;
        }
    }


    virtual void SetID(unsigned long ID)
    {
        m_ID = ID;
    }

    virtual void SetDelAfterPlay(bool DelAfterPlay)
    {
        m_DelAfterPlay = DelAfterPlay;
    }

    //virtual unsigned long ParseExtendInfo(unsigned char *pSrcBuffer, unsigned long SrcSize);
    //-----------------------------------------------------------------
	
private:

    // ResourceFile的版本
    //  00.01 : 影音檔案的聲音部分是另外的聲音檔案儲存。
    //  00.02 : 影音檔案的聲音部分已經沒有被分離開來。
    //  00.03 : BST檔案內包含DRM資訊

    // 產生資源檔的應用程式(m_Application)
    // bwst : 講解手
    // bwfp : 智勝Flash Player

   

    char m_Type[4];
    char m_Application[4];
    char m_Version[5];
    unsigned long m_Size;
    unsigned long m_TitleSize;
    string m_Title;  //connie m_Title 原為wstring
    string m_DRMServer;
    unsigned long   m_DRMServerSize;
    unsigned long   m_ID;
    bool m_DelAfterPlay;
    vector<string> m_RefName;
    map<string, CInfoAtom> m_InfoAtom;
    CDataAtom m_DataAtom;
    wchar_t * TmpFileName;
};

//---------------------------------------------------------------------------

#endif
