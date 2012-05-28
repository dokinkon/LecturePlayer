//---------------------------------------------------------------------------


#include <fstream>
#include "CScriptSystem.h"
#include "BWStringTool.h"
#include "MyXML.h"
//#include "BWDictionary.h"



const string Comma = "#cma";

CScriptSystem::CScriptSystem()
{
    NowAction= Actions.end();
    m_TotalScriptTime = 0;
}
//---------------------------------------------------------------------------
CScriptSystem::~CScriptSystem()
{
    Actions.clear();
}
//---------------------------------------------------------------------------
bool CScriptSystem::LoadFromFile(string FileName , CTopicResource *resource)
{
    OutofActions = false;
    Actions.clear();
    m_TotalScriptTime = -1;
    return ParserScriptFile( FileName ,resource);
}
//---------------------------------------------------------------------------
bool CScriptSystem::ParserCommand( string Command )
{
    CScriptAction Action;

    // 取得時間
    //Action.Time = (unsigned long)StrToIntDef(Command.SubString(1, 6), 0);
    //Action.Time = wstringToDWORD(Command.substr(0,6), 0);
    string temp=Command.substr(0,6);
    Action.Time = atoi(temp.c_str());

    int ParameterBegin =  Command.find_first_of((string)"(");
    int ParameterEnd = Command.find_last_of((string)")");

    // 取得 Action 名稱
    //Action.Action = Command.SubString(8, ParameterBegin-8);
    Action.Action = Command.substr(7, ParameterBegin-7);

    // 取得參數
    string Parameters = Command.substr(ParameterBegin+1, ParameterEnd-ParameterBegin-1);
    char seps[] = ",";
    char *SubString = strtok((char*)Parameters.c_str(), seps);

    while(SubString != NULL)
    {
        string Para = SubString;
        BW::BWReplaceStringNew(Para, Comma, ",");
        Action.Parameters.push_back(Para);
        SubString = strtok(NULL, seps);
    }
    Actions.push_back(Action);
    return true;
}
//---------------------------------------------------------------------------
bool CScriptSystem::ParserScriptFile(const string& fileName, CTopicResource *resource )
{
    string xmlpath = "track";
    xmlpath += fileName.substr(fileName.find_last_of("/"));
    xmlDoc *xmldoc = NULL;
    xmlNode *xmlRoot = NULL;

    //connie add
    string s = BW::xmlconvert(resource->m_ImageBuffer[xmlpath].buffer ,resource->m_ImageBuffer[xmlpath].size);
    //ofstream out("/sdcard/track.xml");
    //out << s << endl;

    xmldoc = xmlReadMemory( s.c_str(),
            s.size() ,
            NULL ,
            NULL ,
            0);

    xmlRoot = xmlDocGetRootElement(xmldoc);
    MyXML m_xml;
    xmlNode* xmlScript = m_xml.FindChildNode(xmlRoot,xmlCharStrdup("腳本"));  //should modify later
    string ScriptContent = string((char*)xmlNodeListGetString(xmldoc, xmlScript->xmlChildrenNode, 1));
    xmlFreeDoc(xmldoc);

    //以下印出來是正常的字串 不需要使用TTNTSTRINGLIST
    vector<string> pStringList;

    char seps[] = "\r\n";
    char *SubString = strtok((char*)ScriptContent.c_str(), seps);
    while (SubString != NULL)
    {
        string Para = string(SubString);
        if ( !Para.empty() )
        {
            pStringList.push_back(Para);
        }
        SubString = strtok(NULL, seps);
    };

    unsigned int index = 0;
    while(index < pStringList.size())
    {
        string text = pStringList[index];
        string command=text;
        if ( ParserCommand(command) == false )
        {
            pStringList.clear();
            return false;
        }
        index++;
    }

    pStringList.clear();
    // 將 NowAction 指標指到開始位置
    NowAction = Actions.begin();
    // 記錄此腳本的最終時間
    m_TotalScriptTime = (*(Actions.end()-1)).Time;
    return true;
}
//---------------------------------------------------------------------------
bool CScriptSystem::NextAction(CScriptAction &Action)
{
    OutofActions = false;

    if ( NowAction==Actions.end() )
        return false;

    if ( NowAction==Actions.end()-1 )
    {
        OutofActions = true;
        return false;
    }

    NowAction++;
    Action = (*NowAction);
    return true;
}
//---------------------------------------------------------------------------
bool CScriptSystem::PreviousAction(CScriptAction &Action)
{
    if ( NowAction==Actions.end()  )
        return false;

    if ( NowAction==Actions.begin() )
    {
        return false;
    }

    NowAction--;
    Action = (*NowAction);

    return true;
}
//---------------------------------------------------------------------------
bool CScriptSystem::GetActions(CScriptAction &Action)
{
    if ( NowAction==Actions.end() )
    {
        return false;
    }
    Action = (*NowAction);
    return true;
}
//---------------------------------------------------------------------------
bool CScriptSystem::GetParameters(vector<string> Parameters)
{
    if ( NowAction==Actions.end() )
    {
        return false;
    }
    Parameters = (*NowAction).Parameters;
    return true;
}
//---------------------------------------------------------------------------
bool CScriptSystem::GotoBegin(void)
{
    if ( NowAction==Actions.end() )
    {
        return false;
    }
    NowAction = Actions.begin();
    return true;
}
//---------------------------------------------------------------------------
bool CScriptSystem::InsertAction( CScriptAction Action )
{
    std::vector<CScriptAction>::iterator iter;
    for ( iter=Actions.begin() ; iter!=Actions.end() && Action.Time>=(*iter).Time ; iter++ ) ;


    if( iter==Actions.end() )
    {
        // 加入到最後面
        Actions.push_back(Action);
        NowAction = Actions.end()-1;
    }
    else
    {
        // 加入到 iter 之前的位置
        NowAction = Actions.insert( iter, Action);
    }

    // 記錄腳本的最後時間
    m_TotalScriptTime = Actions[Actions.size()-1].Time;

    return true;
}
//---------------------------------------------------------------------------
bool CScriptSystem::RemoveActionLater()
{
    if ( OutofActions==true )   // 沒有東西可以移除
        return true;

    // 如果移除的指令為 OnPen, OnFluoropen, 或 OnEraser 則更改繪圖腳本為結束的繪圖腳本
    if ( (*NowAction).Action!= "Draw" )
    {
        std::vector<CScriptAction>::iterator iter = NowAction-1;

        if ( iter!=Actions.begin() )
        {
            if ( (*iter).Action== "Draw" )
            {
                if ( (*iter).Parameters[5]=="OnPen" )
                {
                    (*iter).Parameters[5] = "EndPen";
                }
                else if ( (*iter).Parameters[5]=="OnFluoropen" )
                {
                    (*iter).Parameters[5] = "EndFluoropen";
                }
                else if ( (*iter).Parameters[5]=="OnEraser" )
                {
                    (*iter).Parameters[5] = "EndEraser";
                }
            }
        }
    }

    if ( NowAction!=Actions.end() )
    {
        NowAction = Actions.erase( NowAction, Actions.end());
        NowAction = Actions.end()-1;
        m_TotalScriptTime = (*NowAction).Time;
    }

    if ( Actions.empty() )
    {
        NowAction = Actions.end();
        m_TotalScriptTime = 0;
    }
    return true;

}
//---------------------------------------------------------------------------
void CScriptSystem::Clear()
{
    NowAction =Actions.end();
    Actions.clear();
    m_TotalScriptTime = 0;
}
//---------------------------------------------------------------------------
bool CScriptSystem::GotoTime(unsigned long Time)
{
    // 如果沒有腳本，離開
    if ( Actions.empty() )
    {
        NowAction =Actions.end();
        m_TotalScriptTime = 0;
        OutofActions = false;
        return false;
    }

    NowAction = Actions.begin();

    CScriptAction Action;

    while ( NowAction!=Actions.end() && Time>=(*NowAction).Time )
    {
        NowAction++;
    }

    // 如果已經移到最後一個位置，傳回 false
    if ( NowAction==Actions.end() )
    {
        NowAction = Actions.end()-1;
        m_TotalScriptTime = (*NowAction).Time;
        OutofActions = true;
        return false;
    }
    else
    {
        m_TotalScriptTime = (*NowAction).Time;
        OutofActions = false;
        return true;
    }
}
//---------------------------------------------------------------------------
void CScriptSystem::RemoveSpeicfyTimeLaterAction(unsigned long Time)
{
    // 如果沒有腳本，離開
    if ( Actions.empty() )
    {
        NowAction = Actions.end();
        m_TotalScriptTime = 0;
        OutofActions = false;
        return ;
    }
    NowAction = Actions.begin();
    CScriptAction Action;

    while ( NowAction!=Actions.end() && Time>=(*NowAction).Time )
    {
        NowAction++;
    }

    // 如果已經移到最後一個位置，傳回 false
    if ( NowAction==Actions.end() )
    {
        NowAction = Actions.end()-1;
        m_TotalScriptTime = (*NowAction).Time;
        OutofActions = true;
    }
    else
    {
        m_TotalScriptTime = (*NowAction).Time;
        OutofActions = false;
    }

    RemoveActionLater();

}
//---------------------------------------------------------------------------
bool CScriptSystem::InsertScript(CScriptSystem *pScriptSystem)
{
    CScriptAction Action;
    pScriptSystem->GotoBegin();

    if ( NowAction!=Actions.end() )
    {
        string tmp = (*NowAction).Action;
        if ( (*NowAction).Action== "Draw" )
        {
            if ( (*NowAction).Parameters[5]=="OnPen" )
            {
                (*NowAction).Parameters[5] = "EndPen";
            }
            else if ( (*NowAction).Parameters[5]=="OnFluoropen" )
            {
                (*NowAction).Parameters[5] = "EndFluoropen";
            }
            else if ( (*NowAction).Parameters[5]=="OnEraser" )
            {
                (*NowAction).Parameters[5] = "EndEraser";
            }
        }
    }

    do
    {
        pScriptSystem->GetActions(Action);
        InsertAction(Action);
    } while( pScriptSystem->NextAction(Action) );
    return true;
}
// 取得開始時間
bool CScriptSystem::GetBeginTime(unsigned long &Time)
{
    if ( Actions.empty() )
    {
        return false;
    }
    Time = Actions[0].Time;
    return true;
}
// 取得最後的時間
bool CScriptSystem::GetEndTime(unsigned long &Time)
{
    if ( Actions.empty() )
    {
        return false;
    }
    Time = Actions[Actions.size()-1].Time;
    return true;
}
//---------------------------------------------------------------------------
bool CScriptSystem::GetActions(unsigned int index, CScriptAction &Action)
{
    if ( index>=Actions.size() )
        return false;

    Action = Actions[index];
    return true;
}
//---------------------------------------------------------------------------
bool CScriptSystem::GetParameters(unsigned int index, vector<string> &Parameters)
{
    if ( index>=Actions.size() )
        return false;
    Parameters = Actions[index].Parameters;
    return true;
}
//---------------------------------------------------------------------------
HRESULT CScriptSystem::SetInfo(string Title, vector<string> SceneNameList)
{
    m_Title = Title;
    m_SceneNameList = SceneNameList;
    return S_OK;
}
//---------------------------------------------------------------------------
