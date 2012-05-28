//---------------------------------------------------------------------------
//
// 腳本系統
//
//---------------------------------------------------------------------------

#ifndef CScriptSystemH
#define CScriptSystemH

#include "globals.h"
#include "ResourceFile2.h"
using namespace std;
//---------------------------------------------------------------------------

class CScriptAction
{
public:
    CScriptAction()
    {
        Time = 0;
    }

    ~CScriptAction()
    {
        Parameters.clear();
    }

    unsigned long           Time;
    string         Action;
    vector<string> Parameters;
};

//---------------------------------------------------------------------------
class CScriptSystem
{
public:
    CScriptSystem();
    ~CScriptSystem();
    // 讀入腳本
    bool LoadFromFile(string FileName , CTopicResource *resource);
    //bool LoadFromStream(TMemoryStream *pMemoryStream);
    // 儲存腳本
    //HRESULT SaveToFile(string FileName);
    // 下一筆資料
    bool NextAction(CScriptAction &Action);
    // 前一筆資料
    bool PreviousAction(CScriptAction &Action);
    // 取得目前 NowAction 的資料
    bool GetActions(CScriptAction &Action);

    bool GetParameters(vector<string> Parameters);
    //Goto the begin of Actions.
    bool GotoBegin(void);
    //bool GotoTime(long Time);
    bool GotoTime(unsigned long Time);
    //long QueryTime(void) { return (*NowAction).Time; }
    unsigned long QueryTime(void) { return (*NowAction).Time; }
    // 依照時間插入適當位置
    bool InsertAction(CScriptAction Action);
    // 移除 NowAction 之後的所有腳本, 不包含 NowAction
    bool RemoveActionLater( );
    //void RemoveSpeicfyTimeLaterAction(long Time);
    void RemoveSpeicfyTimeLaterAction(unsigned long Time);
    // 清除腳本
    void Clear();
    // 判斷是否為空Script
    bool Empty() { return Actions.empty(); }
    // 插入另外ㄧ個腳本到此腳本
    bool InsertScript(CScriptSystem *pScriptSystem);
    // 取得開始時間
    bool GetBeginTime(unsigned long &Time);
    // 取得最後的時間
    bool GetEndTime(unsigned long &Time);

    bool GetActions(unsigned int index, CScriptAction &Action);

    bool GetParameters(unsigned int index, vector<string> &Parameters);

    int GetScriptActionNumber(void)
    {
        return Actions.size();
    }
    HRESULT SetInfo(string Title, vector<string> SceneNameList);
    // 腳本總共的時間
    unsigned long m_TotalScriptTime;

private:
    // 腳本指令
    std::vector<CScriptAction> Actions;
    // 記錄目前指到的 vector item
    std::vector<CScriptAction>::iterator NowAction;
    // 當 NextAction 移動出最後一個 Actions 時, OutofActions為true, 用於 RemoveActionLater() 中
    bool OutofActions;
    // Parser command
    bool ParserCommand(string Command);
    // Parser script
    //bool ParserScriptFile( AnsiString FileName );
    bool ParserScriptFile(const string& FileName, CTopicResource *resource);
    // ParserScriptFile(string FileName);
    // 腳本總共的時間, 移到 Public
    // long m_TotalScriptTime;
    string m_FullFileName;
    string m_Title;
    vector<string> m_SceneNameList;
};
//---------------------------------------------------------------------------
#endif
