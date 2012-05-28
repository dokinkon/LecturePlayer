//---------------------------------------------------------------------------
#include "CSceneGraph.h"
#include "BWStringTool.h"
#include "BWFileManagerTool.h"


//---------------------------------------------------------------------------
// 場景類別
//---------------------------------------------------------------------------
CSceneGraph::CSceneGraph()
{
    m_Type = SceneGraph_PPT;
    m_SceneName = "";
    m_Width = 720;
    m_Height = 540;
    m_BackgroundColor = 0xFFFFFFFF;
    m_Outline = "";
    m_ScreenRecFileName.clear();
    m_ActorIndex = 0;
    m_ActorActionIndex = 0;
    m_pMouseActor = NULL;
    Visible = true;
    m_SceneTimer.ResetTimer();
    m_pActiveDrawActor = NULL;
    OnMouseClickAction = NULL;
    OnMouseOverAction  = NULL;
    // callback function
    OnProgressMessage = NULL;
    OnDebugMessage = NULL;
    m_ActorList.clear();
}
//---------------------------------------------------------------------------
CSceneGraph::~CSceneGraph()
{
    for ( unsigned int index=0 ; index<m_ActorList.size() ; index++ )
    {
        SAFE_DELETE(m_ActorList[index]);
    }
    m_ActorList.clear();

    for ( unsigned int index=0 ; index<ActorActionList.size() ; index++ )
    {
        SAFE_DELETE(ActorActionList[index]);
    }
    ActorActionList.clear();


    for ( unsigned int index=0 ; index<ActorDrawList.size() ; index++ )
    {
        SAFE_DELETE(ActorDrawList[index]);
    }
    ActorDrawList.clear();

    for ( unsigned int index=0 ; index<m_pMouseActors.size() ; index++ )
    {
        SAFE_DELETE(m_pMouseActors[index]);
    }
    ActorDrawList.clear();

    m_pMouseActor = NULL;

    //SAFE_DELETE(m_pMouseActor);
}
//---------------------------------------------------------------------------
void CSceneGraph::ProgressMessage(string MessageId, int Position, bool Visible)
{
    if(this->OnProgressMessage != NULL)
    {
        OnProgressMessage(MessageId, Position, Visible);
    }
}

void CSceneGraph::DebugMessage(string Message)
{
    if(this->OnDebugMessage != NULL)
    {
        OnDebugMessage(Message);
    }
}

//---------------------------------------------------------------------------

void CSceneGraph::OnTimer()
{
    // 更新場景的時間
    unsigned long oldtime = m_SceneTimer.GetTime();
    m_SceneTimer.UpdateTimer();
    unsigned long dtime =  m_SceneTimer.GetTime() - oldtime;

    // 更新暫停或NG的塗鴉演員
    // 由於暫停或NG的塗鴉會發生在時間差為0的時候，所以要將暫停或NG的塗鴉更新放在前面
    for ( unsigned int index=0 ; index<PauseActorDrawList.size() ; index++ )
    {

        PauseActorDrawList[index]->Refresh("Replaying", dtime);
    }


    if(dtime == 0)
    {
        return;
    }

    // 更新塗鴉的演員
    for ( unsigned int index=0 ; index<ActorDrawList.size() ; index++ )
    {

        ActorDrawList[index]->Refresh("Replaying", dtime);
    }


    // 設定演員特效更新所需的相關變數
    for ( unsigned int index=0 ; index<m_ActorList.size() ; index++ )
    {
        m_ActorList[index]->ResetActionRefresh();
        m_ActorList[index]->Media_Refresh();
    }


    // 更新場景的演員
    for ( unsigned int index=0 ; index<ActorActionList.size() ; index++ )
    {
        ActorActionList[index]->RefreshActor(dtime);
    }

    //  判斷演員的特效是否執行完畢
    for ( unsigned int index=0 ; index<m_ActorList.size() ; index++ )
    {
        m_ActorList[index]->DetermineActionFinish();
    }
}

void CSceneGraph::OnTimer(unsigned long dtime)
{
    // 更新場景的時間
    unsigned long oldtime = m_SceneTimer.GetTime();
    m_SceneTimer.SetTime(oldtime+dtime);

    // 更新暫停或NG的塗鴉演員
    // 由於暫停或NG的塗鴉會發生在時間差為0的時候，所以要將暫停或NG的塗鴉更新放在前面
    for ( unsigned int index=0 ; index<PauseActorDrawList.size() ; index++ )
    {
        PauseActorDrawList[index]->Refresh("GotoTime", dtime);
    }


    if(dtime == 0)
    {
        return;
    }

    // 更新塗鴉的演員
    for ( unsigned int index=0 ; index<ActorDrawList.size() ; index++ )
    {

        ActorDrawList[index]->Refresh("GotoTime", dtime);
    }


    for ( unsigned int index=0 ; index<m_ActorList.size() ; index++ )
    {
        // 設定演員特效更新所需的相關變數
        m_ActorList[index]->ResetActionRefresh();

        m_ActorList[index]->Media_Refresh(dtime);
    }

    // 更新場景的演員
    int OldActorActionIndex = m_ActorActionIndex;

    // 先處理已經被觸發的動畫
    for ( int index=0 ; index<OldActorActionIndex ; index++ )
    {
        ActorActionList[index]->RefreshActor(dtime);
    }

    // 可能有問題
    while ( m_SceneTimer.GetTime()-LastTriggerTime>0 )
    {
        int TmpActorActionIndex = m_ActorActionIndex;
        dtime = m_SceneTimer.GetTime()-LastTriggerTime;

        for ( int index=OldActorActionIndex ; index<TmpActorActionIndex ; index++ )
        {
            ActorActionList[index]->RefreshActor(dtime);
        }

        // 當 m_ActorActionIndex 沒有再增加的時候，則離開回圈
        if ( TmpActorActionIndex==m_ActorActionIndex )
            break;

        OldActorActionIndex = TmpActorActionIndex;
    }

    //  判斷演員的特效是否執行完畢
    for ( unsigned int index=0 ; index<m_ActorList.size() ; index++ )
    {
        m_ActorList[index]->DetermineActionFinish();
    }
}

//---------------------------------------------------------------------------
// 重置場景
//---------------------------------------------------------------------------

void CSceneGraph::Reset()
{
    // 重置場景的時間
    m_SceneTimer.ResetTimer();

    // 重置場景的演員
    for ( unsigned int index=0 ; index<m_ActorList.size() ; index++ )
    {
        m_ActorList[index]->Reset();
    }

    // 重置特效演員
    for ( unsigned int index=0 ; index<ActorActionList.size() ; index++ )
    {
        ActorActionList[index]->Reset();
    }

    m_ActorActionIndex = 0;

    // 重置塗鴉演員
    for ( unsigned int index=0 ; index<ActorDrawList.size() ; index++ )
    {
        ActorDrawList[index]->Reset();
    }

    m_ActorDrawIndex = 0;
    m_PauseActorDrawIndex = 0;

    LastTriggerTime = 0;
}

void CSceneGraph::ResetAction()
{
    // 重置場景的時間
    //m_SceneTimer.ResetTimer();

    // 重置場景的演員
    for ( unsigned int index=0 ; index<m_ActorList.size() ; index++ )
    {
        m_ActorList[index]->Reset();
    }

    // 重置特效演員
    for ( unsigned int index=0 ; index<ActorActionList.size() ; index++ )
    {
        ActorActionList[index]->Reset();
    }

    m_ActorActionIndex = 0;
    LastTriggerTime = 0;
}

//---------------------------------------------------------------------------

bool CSceneGraph::OnMouseClick(int X, int Y)
{
	unsigned int ActorIndex;
    unsigned int ActionSettingIndex;
    bool         ChangeSlide = false;

    //
	if ( SearchActorByPos(X, Y, ActorIndex, ActionSettingIndex) )
	{
        // 點擊到的演員有"動作設定"
        if ( m_ActorList[ActorIndex]->m_ActorType==ActorType_Normal )
        {
            // 演員種類為普通演員
            // 如果演員有在滑鼠 click 的位置上，且演員有 MouseClickAction，則執行 MouseClickAction的設定。
            if ( OnMouseClickAction!=NULL )
            {
                PauseAllMediaActor();
                OnMouseClickAction( m_ActorList[ActorIndex]->m_MCActionSettingAction[ActionSettingIndex],
                                    m_ActorList[ActorIndex]->m_MCHyperlinkSlideID[ActionSettingIndex],
                                    m_ActorList[ActorIndex]->m_MCURL[ActionSettingIndex],
                                    ChangeSlide);
            }
        }
        else if ( m_ActorList[ActorIndex]->m_ActorType==ActorType_Media &&
                  m_ActorList[ActorIndex]->m_MCActionSettingAction[ActionSettingIndex]==12 )
        {
            // 演員種類為多媒體演員和動作種類為Play(12)
            m_ActorList[ActorIndex]->Media_Click(true);

            //unsigned long time1 = ::GetTickCount();
            //DebugMessage(string("觸發多媒體演員")+IntToStr(time1));

        }
	}
	else
	{
    	GotoNextAction();
    }

    if ( ChangeSlide==true )
    {
        return false;
    }
    return true;
}
void CSceneGraph::OnMouseClick1(int X, int Y)
{
    // 經由 ControlSystem->PlayScript() 呼叫
    // 在執行多媒體演員的 Media_Click() 時請注意此場景的時間是否被打開
    // 因為多媒體演員需要知道系統是否為播放、暫停或停止。

    unsigned int ActorIndex;
    unsigned int ActionSettingIndex;

    if ( SearchActorByPos(X, Y, ActorIndex, ActionSettingIndex) )
    {
        // 點擊到的演員有"動作設定"
        if ( m_ActorList[ActorIndex]->m_ActorType==ActorType_Media &&
             m_ActorList[ActorIndex]->m_MCActionSettingAction[ActionSettingIndex]==12 )
        {
            // 演員種類為多媒體演員和動作種類為Play(12)
            m_ActorList[ActorIndex]->Media_Click(m_SceneTimer.IsEnabled());
            //unsigned long time1 = ::GetTickCount();
            //DebugMessage(string(L"觸發多媒體演員") + IntToStr(time1));

        }
    }
	else
	{
        GotoNextAction();
	}
}

//---------------------------------------------------------------------------

void CSceneGraph::OnMouseMove(int X, int Y)
{
	unsigned int ActorIndex;
    unsigned int ActionSettingIndex;

    if ( SearchActorByPos(X, Y, ActorIndex, ActionSettingIndex) )
    {


        if ( OnMouseOverAction!=NULL )
        {
            bool ChangeCursor = false;
            OnMouseOverAction(true, ChangeCursor);

            if ( ChangeCursor==true )
            {
                // 如果滑鼠有移上某一個具有 ActionSetting 的演員，則滑鼠游標需做相關的更改。
                if ( m_pMouseActor!=m_pMouseActors[1] )
                {
                    m_pMouseActor = m_pMouseActors[1];
                }


            }
        }

        if ( m_pMouseActor!=NULL )
        {
            m_pMouseActor->X = X;
            m_pMouseActor->Y = Y;
        }

    }
    else
    {

        if ( OnMouseOverAction!=NULL )
        {
            bool ChangeCursor = false;
            OnMouseOverAction(false, ChangeCursor);

            if ( ChangeCursor==true )
            {
                if ( m_pMouseActor!=m_pMouseActors[0] )
                {
                    m_pMouseActor = m_pMouseActors[0];
                }
            }
        }

        if ( m_pMouseActor!=NULL )
        {
            m_pMouseActor->X = X;
            m_pMouseActor->Y = Y;
        }
    }
}

void CSceneGraph::OnMouseMove1(int X, int Y)
{
    unsigned int ActorIndex;
    unsigned int ActionSettingIndex;

    if ( SearchActorByPos(X, Y, ActorIndex, ActionSettingIndex) )
    {

        if ( OnMouseOverAction!=NULL )
        {
            bool ChangeCursor;
            OnMouseOverAction(true, ChangeCursor);
        }

    }
    else
    {

        if ( OnMouseOverAction!=NULL )
        {
            bool ChangeCursor;
            OnMouseOverAction(false, ChangeCursor);
        }
    }
}

//---------------------------------------------------------------------------

HRESULT CSceneGraph::LoadSceneGraph(string SceneName, xmlNodePtr xmlPPT, string LoadFilePath)
{
	
    m_ActorList.clear();

    HRESULT hr = S_OK;
	
    //DebugMessage("CSceneGraph::LoadSceneGraph");

    if (  m_xml.HasAttribute(xmlPPT,xmlCharStrdup("ApplicationName"))==false )
    {  
        hr = LoadPowerPoint2003XML(SceneName, xmlPPT, LoadFilePath);
    }
	
    else
    {
		
        string ApplicationName = string((char*) m_xml.GetAttribute(xmlPPT,xmlCharStrdup("ApplicationName")));
		
        if ( ApplicationName==string("Microsoft PowerPoint") )
        {
			
            if (  m_xml.HasAttribute(xmlPPT,xmlCharStrdup("ApplicationVersion"))==true )
            {

                string ApplicationVersion=string((char*) m_xml.GetAttribute(xmlPPT,xmlCharStrdup("ApplicationVersion")));
                if ( ApplicationVersion==string("11.0") )
                {

                    hr = LoadPowerPoint2003XML(SceneName, xmlPPT, LoadFilePath);
					
                }
                else
                {
                    hr = LoadPowerPoint2000XML(SceneName, xmlPPT, LoadFilePath);
                }
            }
            else
            {
                hr = E_FAIL;
            }
        }
        else
        {
            hr = E_FAIL;
        }
    }

    return hr;
}

//---------------------------------------------------------------------------

HRESULT CSceneGraph::LoadMouse()
{

	 LOGD("test log in LoadMouse");
    // 設定滑鼠演員
    CActor * pMouseActor;
    pMouseActor = new CActor();
 LOGD("test log in LoadMouse 0 ");
    pMouseActor->ActorName = string("cursor");
	LOGD("test log in LoadMouse 0.1 ");
    pMouseActor->X = 730;
    pMouseActor->Y = 50;
    pMouseActor->Width = 24;
    pMouseActor->Height = 24;
    pMouseActor->Alpha = 255;
   LOGD("test log in LoadMouse 0.2 ");
    pMouseActor->m_ImageFileName = BWGetCurrentDirNew() + string("/UI/pen.png");

LOGD("test log in LoadMouse 0.3 ");

	
	 LOGD("test log in LoadMouse 1 ");
    m_pMouseActors.push_back(pMouseActor);
    m_pMouseActor = pMouseActor;
 LOGD("test log in LoadMouse 2 ");
    pMouseActor = new CActor();
	 LOGD("test log in LoadMouse 3");
    pMouseActor->ActorName = string("MouseOverCursor");
    pMouseActor->X = 730;
    pMouseActor->Y = 50;
    pMouseActor->Width = 24;
    pMouseActor->Height = 24;
    pMouseActor->Alpha = 255;
    //pMouseActor->m_ImageFileName = BWExtractFilePathNew(Application->ExeName) + string("UI/pen2.png");
    pMouseActor->m_ImageFileName = BWGetCurrentDirNew() + string("/UI/pen2.png");
 LOGD("test log in LoadMouse 4 ");
    m_pMouseActors.push_back(pMouseActor);
	 LOGD("test log in LoadMouse 5 ");
    return S_OK;
}

void CSceneGraph::ActorActionFinish(CActorAction *pActorAction)
{
    // 啟動演員
//    int index = pActorAction->Index;

    //DebugMessage(string("第 ")+string(index)+string(" 結束"));

    if ( m_ActorActionIndex < (int)ActorActionList.size() )
    {

        bool OthersFinish = true;

        for ( unsigned int index=0 ; index<ActorActionList.size() ; index++ )
        {
            if ( ActorActionList[index]->Enabled==true )
                OthersFinish = false;
        }

        if ( ActorActionList[m_ActorActionIndex]->GetTriggerType()==3 && OthersFinish==true )
        {
            // TriggerType=3 為 msoAnimTriggerAfterPrevious

            // 由於在前動畫結束後，只有接續前動畫的特效才可以被啟動，所以最後觸發時間需要以前一個觸發的時間
            // 加上前一組動畫的最大時間間隔，作為目前動畫的觸發時間
            LastTriggerTime = LastTriggerTime + MaxDurTime;

            ActorActionList[m_ActorActionIndex]->Start();

            ActorActionList[m_ActorActionIndex]->SetSceneTriggerTime(LastTriggerTime);

            MaxDurTime = ActorActionList[m_ActorActionIndex]->GetTotalTime();

            m_ActorActionIndex++;

            while ( m_ActorActionIndex<(int)ActorActionList.size() && ActorActionList[m_ActorActionIndex]->GetTriggerType()==2 )
            {
                // TriggerType=2 為 msoAnimTriggerWithPrevious
                ActorActionList[m_ActorActionIndex]->Start();

                ActorActionList[m_ActorActionIndex]->SetSceneTriggerTime(LastTriggerTime);

                if ( MaxDurTime < ActorActionList[m_ActorActionIndex]->GetTotalTime() )
                {
                    MaxDurTime = ActorActionList[m_ActorActionIndex]->GetTotalTime();
                }

                m_ActorActionIndex++;
            }
        }
    }
}

//---------------------------------------------------------------------------

void CSceneGraph::ActorActionError(CActorAction *pActorAction)
{

    if ( m_ActorActionIndex < (int)ActorActionList.size() )
    {
        if ( ActorActionList[m_ActorActionIndex]->GetTriggerType()==3 )
        {
            // TriggerType=3 為 msoAnimTriggerAfterPrevious
            ActorActionList[m_ActorActionIndex]->Start();

            ActorActionList[m_ActorActionIndex]->SetSceneTriggerTime(m_SceneTimer.GetTime());

            MaxDurTime = ActorActionList[m_ActorActionIndex]->GetTotalTime();

            m_ActorActionIndex++;

            while ( m_ActorActionIndex<(int)ActorActionList.size() && ActorActionList[m_ActorActionIndex]->GetTriggerType()==2 )
            {
                // TriggerType=2 為 msoAnimTriggerWithPrevious
                ActorActionList[m_ActorActionIndex]->Start();

                ActorActionList[m_ActorActionIndex]->SetSceneTriggerTime(m_SceneTimer.GetTime());

                if ( MaxDurTime < ActorActionList[m_ActorActionIndex]->GetTotalTime() )
                    MaxDurTime = ActorActionList[m_ActorActionIndex]->GetTotalTime();

                m_ActorActionIndex++;
            }

            LastTriggerTime = m_SceneTimer.GetTime();

        }
    }
}

//---------------------------------------------------------------------------

void CSceneGraph::StartShow()
{
    // 特效處理
    if ( m_ActorActionIndex==0 && m_ActorActionIndex<(int)ActorActionList.size() )
    {
        if ( ActorActionList[m_ActorActionIndex]->GetTriggerType()==3 || ActorActionList[m_ActorActionIndex]->GetTriggerType()==2 )
        {
            // TriggerType=3 為 msoAnimTriggerAfterPrevious
            ActorActionList[m_ActorActionIndex]->Start();

            ActorActionList[m_ActorActionIndex]->SetSceneTriggerTime(m_SceneTimer.GetTime());

            MaxDurTime = ActorActionList[m_ActorActionIndex]->GetTotalTime();

            m_ActorActionIndex++;

            while ( m_ActorActionIndex<(int)ActorActionList.size() && ActorActionList[m_ActorActionIndex]->GetTriggerType()==2 )
            {
                // TriggerType=2 為 msoAnimTriggerWithPrevious
                ActorActionList[m_ActorActionIndex]->Start();

                ActorActionList[m_ActorActionIndex]->SetSceneTriggerTime(m_SceneTimer.GetTime());

                if ( MaxDurTime < ActorActionList[m_ActorActionIndex]->GetTotalTime())
                    MaxDurTime = ActorActionList[m_ActorActionIndex]->GetTotalTime();

                m_ActorActionIndex++;
            }

            LastTriggerTime = m_SceneTimer.GetTime();
        }
    }

}

void CSceneGraph::StartShow1()
{
    bool tmp = m_SceneTimer.IsEnabled();

    for ( unsigned int index=0 ; index<m_ActorList.size() ; index++ )
    {
        if ( m_ActorList[index]->m_ActorType==ActorType_Media &&
             m_ActorList[index]->m_PlayOnEntry==true )
        {
            //m_ActorList[index]->Media_Start();
            m_ActorList[index]->Media_Click(tmp);
        }
    }


}

//---------------------------------------------------------------------------

bool CSceneGraph::GetActiveMouseVisible()
{
    if ( m_pMouseActor==NULL )
    {
        return false;
    }
    return m_pMouseActor->Visible;
}

void CSceneGraph::SetActiveMouseVisible(bool Visible)
{
    if ( m_pMouseActor!=NULL )
    {
        m_pMouseActor->Visible = Visible;
    }
}

//---------------------------------------------------------------------------
// 判斷是否有前一個或下一個動畫
bool CSceneGraph::HavePreviousAction(void)
{
    if ( m_ActorActionIndex>0 && !ActorActionList.empty() )
        return true;

    return false;
}
//---------------------------------------------------------------------------
bool CSceneGraph::HaveNextAction(void)
{
    if ( m_ActorActionIndex<(int)ActorActionList.size() )
        return true;

    return false;
}
//---------------------------------------------------------------------------
bool CSceneGraph::HaveAction(void)
{
    if ( ActorActionList.empty() || m_ActorActionIndex==0 )
        return false;

    return true;
}
void CSceneGraph::ActionIndex(int &Index, int &Size)
{
    Index = m_ActorActionIndex;
    Size = ActorActionList.size();
}
//---------------------------------------------------------------------------
// 跳到前一個或下一個動畫
bool CSceneGraph::GotoPreviousAction(void)
{
    // 啟動演員
    if ( !HavePreviousAction() )
    {
        return false;
    }

    m_ActorActionIndex--;

    if ( m_ActorActionIndex < (int)ActorActionList.size() )
    {
        if ( ActorActionList[m_ActorActionIndex]->GetTriggerType()==1 )
        {
            // 按一下頁面觸發
            ActorActionList[m_ActorActionIndex]->ReinitState();
        }
        else
        {
            while ( m_ActorActionIndex>=0 &&
                    ( ActorActionList[m_ActorActionIndex]->GetTriggerType()==2 ||
                    ActorActionList[m_ActorActionIndex]->GetTriggerType()==3 ) )
            {
                // TriggerType=2 為 msoAnimTriggerWithPrevious
                ActorActionList[m_ActorActionIndex]->ReinitState();
                m_ActorActionIndex--;
            }

            if ( m_ActorActionIndex<0 )
                m_ActorActionIndex = 0;

            if ( ActorActionList[m_ActorActionIndex]->GetTriggerType()==1 )
            {
                // 按一下頁面觸發
                ActorActionList[m_ActorActionIndex]->ReinitState();
            }
        }

        if ( m_ActorActionIndex!=0 )
        {

            LastTriggerTime = ActorActionList[0]->m_SceneTriggerTime;

            for ( int index=1 ; index<m_ActorActionIndex ; index++ )
            {
                if ( ActorActionList[index]->GetTriggerType()==1 )
                {
                    LastTriggerTime = ActorActionList[index]->m_SceneTriggerTime;
                }
            }
        }
        else
        {
            LastTriggerTime = 0;
        }

        StopAllMediaActor();
    }
    return HavePreviousAction();
}
//---------------------------------------------------------------------------
bool CSceneGraph::GotoNextAction(void)
{
    // 設定演員特效更新所需的相關變數
    for ( unsigned int index=0 ; index<m_ActorList.size() ; index++ )
    {
        m_ActorList[index]->ResetActionRefresh();
    }

    // 如果有還在執行的動畫，則直接結束動畫。
    for ( int index=0 ; index<m_ActorActionIndex ; index++ )
    {
        if ( ActorActionList[index]->Enabled==true )
            ActorActionList[index]->End();

    }
    // 將同一個群組的動畫直接結束
    if ( m_ActorActionIndex!=0 )
    {
        if ( m_ActorActionIndex<(int)ActorActionList.size() && ActorActionList[m_ActorActionIndex]->GetTriggerType()==3 )
        {
            while ( m_ActorActionIndex<(int)ActorActionList.size() &&
                    ( ActorActionList[m_ActorActionIndex]->GetTriggerType()==2 ||
                      ActorActionList[m_ActorActionIndex]->GetTriggerType()==3 ) )
            {
                ActorActionList[m_ActorActionIndex]->End();
                m_ActorActionIndex++;
            }
        }
    }

    // 下次按滑鼠動作後隱藏處理
    bool exit = false;
    for ( int index=m_ActorActionIndex-1 ; index>=0 && exit==false ; index-- )
    {
        //msoAnimAfterEffectDim  1
        //msoAnimAfterEffectHide  2
        //msoAnimAfterEffectHideOnNextClick  3
        //msoAnimAfterEffectMixed  -1
        //msoAnimAfterEffectNone  0
        if ( ActorActionList[index]->m_AfterEffect==3 )
        {
            // 如果是下次按滑鼠動作後隱藏，則讓演員消失
            ActorActionList[index]->HideActor();
        }


        // TriggerType=2 為 msoAnimTriggerWithPrevious
        // TriggerType=3 為 msoAnimTriggerAfterPrevious
        if ( ActorActionList[index]->GetTriggerType()==2 || ActorActionList[index]->GetTriggerType()==3 )
        {

        }
        else
        {
            exit = true;
        }
    }


    if ( m_ActorActionIndex < (int)ActorActionList.size() )
    {
        if ( ActorActionList[m_ActorActionIndex]->GetTriggerType()==1 )
        {
            // 按一下頁面觸發
            ActorActionList[m_ActorActionIndex]->Start();

            ActorActionList[m_ActorActionIndex]->SetSceneTriggerTime(m_SceneTimer.GetTime());

            MaxDurTime = ActorActionList[m_ActorActionIndex]->GetTotalTime();

            m_ActorActionIndex++;

            while ( m_ActorActionIndex<(int)ActorActionList.size() && ActorActionList[m_ActorActionIndex]->GetTriggerType()==2 )
            {
                // TriggerType=2 為 msoAnimTriggerWithPrevious
                ActorActionList[m_ActorActionIndex]->Start();

                ActorActionList[m_ActorActionIndex]->SetSceneTriggerTime(m_SceneTimer.GetTime());

                if ( MaxDurTime < ActorActionList[m_ActorActionIndex]->GetTotalTime() )
                    MaxDurTime = ActorActionList[m_ActorActionIndex]->GetTotalTime();

                m_ActorActionIndex++;
            }

            LastTriggerTime = m_SceneTimer.GetTime();
        }
        else
        {
            // 如果使用者使用前ㄧ動畫，而前ㄧ動畫剛好為該投影片第一個動畫，
            // 且動畫觸發方式為接續前ㄧ動畫或與前動畫同時，
            // 則會執行以下程式碼

            // TriggerType=2 為 msoAnimTriggerWithPrevious
            if ( ActorActionList[m_ActorActionIndex]->GetTriggerType()==2 )
            {
                ActorActionList[m_ActorActionIndex]->Start();

                ActorActionList[m_ActorActionIndex]->SetSceneTriggerTime(m_SceneTimer.GetTime());

                MaxDurTime = ActorActionList[m_ActorActionIndex]->GetTotalTime();

                m_ActorActionIndex++;
                while ( m_ActorActionIndex<(int)ActorActionList.size() && ActorActionList[m_ActorActionIndex]->GetTriggerType()==2 )
                {
                    // TriggerType=2 為 msoAnimTriggerWithPrevious

                    ActorActionList[m_ActorActionIndex]->Start();

                    ActorActionList[m_ActorActionIndex]->SetSceneTriggerTime(m_SceneTimer.GetTime());

                    if ( MaxDurTime < ActorActionList[m_ActorActionIndex]->GetTotalTime() )
                        MaxDurTime = ActorActionList[m_ActorActionIndex]->GetTotalTime();

                    m_ActorActionIndex++;
                }

                LastTriggerTime = m_SceneTimer.GetTime();
            }
            else if ( ActorActionList[m_ActorActionIndex]->GetTriggerType()==3 )
            {
                // TriggerType=3 為 msoAnimTriggerAfterPrevious
                ActorActionList[m_ActorActionIndex]->Start();

                ActorActionList[m_ActorActionIndex]->SetSceneTriggerTime(m_SceneTimer.GetTime());

                MaxDurTime = ActorActionList[m_ActorActionIndex]->GetTotalTime();

                m_ActorActionIndex++;
                while ( m_ActorActionIndex<(int)ActorActionList.size() && ActorActionList[m_ActorActionIndex]->GetTriggerType()==2 )
                {
                    // TriggerType=2 為 msoAnimTriggerWithPrevious
                    ActorActionList[m_ActorActionIndex]->Start();

                    ActorActionList[m_ActorActionIndex]->SetSceneTriggerTime(m_SceneTimer.GetTime());

                    if ( MaxDurTime < ActorActionList[m_ActorActionIndex]->GetTotalTime() )
                        MaxDurTime = ActorActionList[m_ActorActionIndex]->GetTotalTime();

                    m_ActorActionIndex++;
                }

                LastTriggerTime = m_SceneTimer.GetTime();
            }
        }

        StopAllMediaActor();
    }
    return HaveNextAction();
}
//---------------------------------------------------------------------------
bool CSceneGraph::IsBeginDraw(CScriptAction Action)
{
    string drawmethod = Action.Parameters[2];
    if(drawmethod == string("BeginPen") )
    {
        return true;
    }
    else if(drawmethod == string("BeginFluoropen") )
    {
        return true;
    }
    else if(drawmethod == string("BeginEraser") )
    {
        return true;
    }
    else if(drawmethod == string("BeginLine") )
    {
        return true;
    }
    else if(drawmethod == string("BeginGeometryGraph") )
    {
        return true;
    }
    else if(drawmethod == string("BeginText") )
    {
        return true;
    }
    return false;
}
bool CSceneGraph::IsEndDraw(CScriptAction Action)
{
    string drawmethod = Action.Parameters[2];
    if(drawmethod == string("EndPen") )
    {
        return true;
    }
    else if(drawmethod == string("EndFluoropen") )
    {
        return true;
    }
    else if(drawmethod == string("EndEraser") )
    {
        return true;
    }
    else if(drawmethod == string("EndLine") )
    {
        return true;
    }
    else if(drawmethod == string("EndGeometryGraph") )
    {
        return true;
    }
    else if(drawmethod == string("EndText") )
    {
        return true;
    }
    return false;
}


// 記錄塗鴉資料
void CSceneGraph::Draw(string ActorType, CScriptAction Action)
{
    // Scene.Draw 為繪圖指令的塗鴉腳本
    if ( Action.Action=="Scene.Draw" )
    {
        string drawmethod = Action.Parameters[2];
        if( IsBeginDraw(Action) )
        {

            // 如果 m_pActiveDrawActor!=NULL，則代表前一個繪圖指令沒有結束，因此刪除前一個繪圖指令。
            if ( m_pActiveDrawActor!=NULL )
            {
                vector<CDrawActor *>::iterator iter;
                for ( iter=ActorDrawList.begin() ; iter!=ActorDrawList.end() ; iter++ )
                {
                    if ( (*iter)==m_pActiveDrawActor )
                    {
                        SAFE_DELETE((*iter));
                        ActorDrawList.erase(iter);
                        break;
                    }
                }

                for ( iter=PauseActorDrawList.begin() ; iter!=PauseActorDrawList.end() ; iter++ )
                {
                    if ( (*iter)==m_pActiveDrawActor )
                    {
                        SAFE_DELETE((*iter));
                        PauseActorDrawList.erase(iter);
                        break;
                    }
                }
            }

            m_pActiveDrawActor = new CDrawActor();
            //m_pActiveDrawActor->OnDrawActorPosition = OnMouseMove;   //no use??
            m_pActiveDrawActor->BeginRecordDraw();
            m_pActiveDrawActor->Draw(Action);

            if ( ActorType=="main" )
            {
                ActorDrawList.push_back(m_pActiveDrawActor);
            }
            else if ( ActorType=="pause" )
            {
                PauseActorDrawList.push_back(m_pActiveDrawActor);
            }

        }
        else if( IsEndDraw(Action) )
        {
            if ( m_pActiveDrawActor!=NULL )
            {
                //DebugMessage("EndDraw");
                m_pActiveDrawActor->Draw(Action);
                m_pActiveDrawActor->EndRecordDraw();
                m_pActiveDrawActor = NULL;
            }
        }
        else if(drawmethod == string("Clear") )
        {
            m_pActiveDrawActor = new CDrawActor();
            //m_pActiveDrawActor->OnDrawActorPosition = OnMouseMove;
            m_pActiveDrawActor->BeginRecordDraw();
            m_pActiveDrawActor->Draw(Action);
            m_pActiveDrawActor->EndRecordDraw();
            if ( ActorType=="main" )
            {
                ActorDrawList.push_back(m_pActiveDrawActor);
            }
            else if ( ActorType=="pause" )
            {
                PauseActorDrawList.push_back(m_pActiveDrawActor);
            }
            m_pActiveDrawActor = NULL;
        }
        else
        {
            m_pActiveDrawActor->Draw(Action);
        }
    }
}
//---------------------------------------------------------------------------
// 觸發塗鴉演員
void CSceneGraph::TriggerDrawActor(string ActorType, CScriptAction Action)
{
    // Scene.Draw 為繪圖指令的塗鴉腳本
    if ( Action.Action=="Scene.Draw" )
    {
        CDrawActor *pActiveDrawActor = NULL;
        //if ( m_ActorDrawIndex<ActorDrawList.size() )
        {
            string drawmethod = Action.Parameters[2];
            unsigned long time = Action.Time;
            if( IsBeginDraw(Action) )
            {

                if ( ActorType=="main" )
                {
                    pActiveDrawActor = ActorDrawList[m_ActorDrawIndex];

                    if ( time==pActiveDrawActor->GetFirstTime() )
                    {

                        //if ( m_pActiveDrawActor->FirstScriptCompare(Action) )
                            pActiveDrawActor->BeginReplayDraw();

                        m_ActorDrawIndex++;
                    }
                }
                else if ( ActorType=="pause" )
                {
                    pActiveDrawActor = PauseActorDrawList[m_PauseActorDrawIndex];

                    if ( time==pActiveDrawActor->GetFirstTime() )
                    {

                        //if ( m_pActiveDrawActor->FirstScriptCompare(Action) )
                            pActiveDrawActor->BeginReplayDraw();

                        m_PauseActorDrawIndex++;
                    }
                }
            }
            else if( IsEndDraw(Action) )
            {
                // 如果已經有Begin指令執行過且結束指令的時間要相同
                if ( ActorType=="main" )
                {
                    if ( m_ActorDrawIndex>0 )
                    {
                        pActiveDrawActor = ActorDrawList[m_ActorDrawIndex-1];

                    }
                }
                else if ( ActorType=="pause" )
                {
                    if ( m_ActorDrawIndex>0 )
                    {
                        pActiveDrawActor = PauseActorDrawList[m_PauseActorDrawIndex-1];
                    }
                }

                if ( pActiveDrawActor!=NULL && time==pActiveDrawActor->GetLastTime() )
                {
                    pActiveDrawActor->EndReplayDraw();
                }

            }
            else if(drawmethod == string("Clear") )
            {
                // 要先清除給繪圖系統看的指令，在新增塗鴉演員，增加GotoTime()的效能
                ClearDrawActorCommand();
                ClearPauseDrawActorCommand();

                if ( ActorType=="main" )
                {
                    pActiveDrawActor = ActorDrawList[m_ActorDrawIndex];
                    pActiveDrawActor->BeginReplayDraw();
                    pActiveDrawActor->EndReplayDraw();
                    m_ActorDrawIndex++;
                }
                else if ( ActorType=="pause" )
                {
                    pActiveDrawActor = PauseActorDrawList[m_PauseActorDrawIndex];
                    pActiveDrawActor->BeginReplayDraw();
                    pActiveDrawActor->EndReplayDraw();
                    m_PauseActorDrawIndex++;
                }
            }
        }
    }
}

//---------------------------------------------------------------------------

void CSceneGraph::ClearDrawActor(void)
{
    m_pActiveDrawActor = NULL;
    m_ActorDrawIndex = 0;

    for ( unsigned int index=0 ; index<ActorDrawList.size() ; index++ )
    {
        SAFE_DELETE(ActorDrawList[index]);
    }
    ActorDrawList.clear();
}

//---------------------------------------------------------------------------

void CSceneGraph::ClearPauseDrawActor(void)
{
    m_PauseActorDrawIndex = 0;

    for ( unsigned int index=0 ; index<PauseActorDrawList.size() ; index++ )
    {
        SAFE_DELETE(PauseActorDrawList[index]);
    }
    PauseActorDrawList.clear();
}

//---------------------------------------------------------------------------

void CSceneGraph::MergePauseDrawActor(unsigned long PauseTime)
{


    if ( !PauseActorDrawList.empty() )
    {

        //
        unsigned long Time = PauseActorDrawList[0]->GetFirstTime();

        vector<CDrawActor *>::iterator iter;
        for ( iter=ActorDrawList.begin() ; iter!=ActorDrawList.end() ; iter++ )
        {
            unsigned long FirstTime = (*iter)->GetFirstTime();

            if ( FirstTime>Time )
                break;
        }

        while ( iter!=ActorDrawList.end() )
        {
            SAFE_DELETE((*iter));
            iter = ActorDrawList.erase(iter);
        }


        if ( ActorDrawList.size()!=0 )
        {
            // 處理最後一個塗鴉演員
            CScriptAction ScriptAction;
            CDrawActor *pLastDrawActor = ActorDrawList[ActorDrawList.size()-1];

            // 取得結束的位置
            pLastDrawActor->m_Script.GotoTime(PauseTime);
            pLastDrawActor->m_Script.GetActions(ScriptAction);
            string X = ScriptAction.Parameters[0];
            string Y = ScriptAction.Parameters[1];

            // 重新設定結束的位置
            unsigned long EndTime;
            pLastDrawActor->m_Script.GetEndTime(EndTime);
            pLastDrawActor->m_Script.GotoTime(EndTime);
            pLastDrawActor->m_Script.GetActions(ScriptAction);
            ScriptAction.Parameters[0] = X;
            ScriptAction.Parameters[1] = Y;

            // 刪除資料，並插入結束塗鴉指令
            pLastDrawActor->m_Script.RemoveSpeicfyTimeLaterAction(PauseTime);
            pLastDrawActor->m_Script.InsertAction(ScriptAction);
        }



        for ( unsigned int index=0 ; index<PauseActorDrawList.size() ; index++ )
        {
            CDrawActor *pDrawActor = new CDrawActor;
            //pDrawActor->OnDrawActorPosition = OnMouseMove;
            pDrawActor->m_Script = PauseActorDrawList[index]->m_Script;

            // 直接將原本在暫停塗鴉演員的資料丟給繪圖系統
            //pDrawActor->BeginReplayDraw();
            //pDrawActor->EndReplayDraw();

            ActorDrawList.push_back(pDrawActor);
        }

        ClearPauseDrawActor();
    }
    else
    {
        vector<CDrawActor *>::iterator iter;
        for ( iter=ActorDrawList.begin() ; iter!=ActorDrawList.end() ; iter++ )
        {
            unsigned long FirstTime = (*iter)->GetFirstTime();

            if ( FirstTime>PauseTime )
                break;
        }

        while ( iter!=ActorDrawList.end() )
        {
            SAFE_DELETE((*iter));
            iter = ActorDrawList.erase(iter);
        }

        if ( ActorDrawList.size()!=0 )
        {
            // 處理最後一個塗鴉演員
            CScriptAction ScriptAction;
            CDrawActor *pLastDrawActor = ActorDrawList[ActorDrawList.size()-1];

            // 取得結束的位置
            pLastDrawActor->m_Script.GotoTime(PauseTime);
            pLastDrawActor->m_Script.GetActions(ScriptAction);
            string X = ScriptAction.Parameters[0];
            string Y = ScriptAction.Parameters[1];

            // 重新設定結束的位置
            unsigned long EndTime;
            pLastDrawActor->m_Script.GetEndTime(EndTime);
            pLastDrawActor->m_Script.GotoTime(EndTime);
            pLastDrawActor->m_Script.GetActions(ScriptAction);
            ScriptAction.Time = PauseTime;
            ScriptAction.Parameters[0] = X;
            ScriptAction.Parameters[1] = Y;

            // 刪除資料，並插入結束塗鴉指令
            pLastDrawActor->m_Script.RemoveSpeicfyTimeLaterAction(PauseTime);
            pLastDrawActor->m_Script.InsertAction(ScriptAction);
        }
    }
}

// 清除塗鴉演員繪圖指令
void CSceneGraph::ClearDrawActorCommand(void)
{
    for ( unsigned int index=0 ; index<ActorDrawList.size() ; index++ )
    {
        ActorDrawList[index]->m_Command.clear();
    }
}
void CSceneGraph::ClearPauseDrawActorCommand(void)
{
    for ( unsigned int index=0 ; index<PauseActorDrawList.size() ; index++ )
    {
        PauseActorDrawList[index]->m_Command.clear();
    }
}

bool CSceneGraph::SearchActorByPos(int X, int Y, unsigned int &ActorIndex, unsigned int &ActionSettingIndex)
{
    unsigned int TmpActionSettingIndex = 0;
    if ( !m_ActorList.empty() )
    {
        // index 從後面往前計算，主要原因是演員覆蓋的問題 Zorder
        for ( int index=m_ActorList.size()-1 ; index>=0 ; index-- )
        {
            // 先判斷是否有 MouseClickAction 在判斷 click 的位置是否在演員上
            if ( m_ActorList[index]->HasMCAction() && m_ActorList[index]->Inside(X, Y, TmpActionSettingIndex) )
            {
                ActorIndex         = index;
                ActionSettingIndex = TmpActionSettingIndex;
                return true;
            }
        }
    }

	return false;
}

//---------------------------------------------------------------------------

// 共用載入 PPTXML function
// 取得使用母片的 Node
HRESULT CSceneGraph::GetMasterNode(xmlNodePtr SlideNode, xmlNodePtr DesignsNode, xmlNodePtr &MasterNode)
{
    HRESULT hr = S_OK;

    MasterNode = NULL;

    xmlNodePtr SlideDesignNode =  m_xml.FindChildNode(SlideNode,xmlCharStrdup("Design"));
    if ( SlideDesignNode!=NULL )
    {
        if (  m_xml.HasAttribute(SlideDesignNode,xmlCharStrdup("Name"))==false )
        {
            hr = E_FAIL;
            goto Exit;
        }

        string SlideDesignName = string((char*) m_xml.GetAttribute(SlideDesignNode,xmlCharStrdup("Name")));

        if (  m_xml.CountChildNode(DesignsNode)<=0 )
        {
            hr = E_FAIL;
            goto Exit;
        }

        for ( int DesignIndex=0 ; DesignIndex< m_xml.CountChildNode(DesignsNode) ; DesignIndex++ )
        {
            xmlNodePtr DesignNode =  m_xml.FindChildIndex(DesignsNode,DesignIndex);

            if (  m_xml.HasAttribute(DesignNode,xmlCharStrdup("Name"))==false )
            {
                hr = E_FAIL;
                goto Exit;
            }

            string DesignName = string((char*) m_xml.GetAttribute(DesignNode,xmlCharStrdup("Name")));

            if ( SlideDesignName==DesignName )
            {
                xmlNodePtr SlideMasterNode =  m_xml.FindChildNode(SlideNode,xmlCharStrdup("Master"));

                if ( SlideMasterNode!=NULL )
                {
                    if (  m_xml.HasAttribute(SlideMasterNode,xmlCharStrdup("Name"))==false )
                    {
                        hr = E_FAIL;
                        goto Exit;
                    }

                    string SlideMasterName = string((char*) m_xml.GetAttribute(SlideMasterNode,xmlCharStrdup("Name")));

                    if ( SlideMasterName==string("TitleMaster") )
                    {
                        MasterNode =  m_xml.FindChildNode(DesignNode,xmlCharStrdup("TitleMaster"));
                        if ( MasterNode==NULL )
                        {
                            hr = E_FAIL;
                            goto Exit;
                        }

                    }
                    else if ( SlideMasterName==string("SlideMaster") )
                    {
                        MasterNode =  m_xml.FindChildNode(DesignNode,xmlCharStrdup("SlideMaster"));
                        if ( MasterNode==NULL )
                        {
                            hr = E_FAIL;
                            goto Exit;
                        }
                    }
                }
            }
        }
    }

Exit:

    return hr;
}


// 載入 Shape
HRESULT CSceneGraph::LoadShape( xmlNodePtr ShapeNode,
                                string PreName,
                                string LoadFilePath,
                                map<unsigned long, xmlNodePtr> &AnimationShapeList)
{
    CActor *pActor = new CActor();
LOGD("***************LoadShape  ");//sss

    if ( LoadFilePath.empty() )
    {
		LOGD("***************LoadShape  LoadFilePath.empty() ");

        if ( pActor->LoadPPTShape(ShapeNode, string(""))==E_FAIL )
        {	
			LOGD("***************LoadShape in  if ( pActor->LoadPPTShape(ShapeNode, string())==E_FAIL ) ");

            SAFE_DELETE(pActor);
			LOGD("***************LoadShape return E_FAIL ");
            return E_FAIL;
        }
    }
    else
    {  LOGD("***************LoadShape  LoadFilePath.empty() else ");//sss 當掉

        if ( pActor->LoadPPTShape(ShapeNode, LoadFilePath)==E_FAIL )
        {
			 LOGD("***************LoadShape return fail ");//sss
            SAFE_DELETE(pActor);
            return E_FAIL;
        }
    }

    pActor->ActorName = PreName + pActor->ActorName;
	LOGD("***************pActor->ActorName  ");//sss
	LOGD((pActor->ActorName).c_str());


    /*
    // 如果遇到具有影音檔案的演員，則會將此演員視為具有特效的演員，所以需要設定場景中特效演員的最小ZOrder
    if ( pActor->m_ActorType==ActorType_Media )
    {
        if ( pActor->m_ZOrderPosition<m_MinZOrder )
        {
            m_MinZOrder = pActor->m_ZOrderPosition;
        }
    }
    */

    m_ActorList.push_back(pActor);

    // AnimationSettings
    xmlNodePtr AnimationSettingsNode =  m_xml.FindChildNode(ShapeNode,xmlCharStrdup("AnimationSettings"));

    if ( AnimationSettingsNode!=NULL )
    {
        if (  m_xml.HasAttribute(AnimationSettingsNode,xmlCharStrdup("Animate"))==true )
        {
            long Animate = atol((char*) m_xml.GetAttribute(AnimationSettingsNode,xmlCharStrdup("Animate")));
            if ( Animate==-1 ) // msoTrue
            {
                if (  m_xml.HasAttribute(AnimationSettingsNode,xmlCharStrdup("AnimationOrder"))==true )
                {
                    long AnimationOrder = atol((char*) m_xml.GetAttribute(AnimationSettingsNode,xmlCharStrdup("AnimationOrder")));

                    AnimationShapeList[(unsigned long)AnimationOrder] = ShapeNode;
                }
            }
        }
    }

    return S_OK;
}

// 載入 Shape 集合
HRESULT CSceneGraph::LoadShapes( xmlNodePtr ShapesNode,
                                 string PreName,
                                 string LoadFilePath,
                                 map<unsigned long, xmlNodePtr> &AnimationShapeList)
{
    if ( ShapesNode==NULL )
    {
		LOGD("***************LoadShapes error  ");//sss
        return E_FAIL;
    }

    for ( int ShapeIndex=0 ; ShapeIndex< m_xml.CountChildNode(ShapesNode) ; ShapeIndex++ )
    {
		LOGD("******index");
		LOGD(IntToStringNew(ShapeIndex,0).c_str());
		LOGD("***************LoadShapes for  0");//sss 當掉

		LOGD("******child node count");
		LOGD(IntToStringNew( m_xml.CountChildNode(ShapesNode),0).c_str());
		
		
        xmlNodePtr ShapeNode =  m_xml.FindChildIndex(ShapesNode,ShapeIndex);//這裡當掉!!!

		LOGD("***************LoadShapes for  1");//sss 當掉

		if( ShapeNode != NULL){ //connie
			LoadShape(ShapeNode, PreName, LoadFilePath, AnimationShapeList);
		
		}
    }
	LOGD("***************LoadShapes end for  ");//sss

    return S_OK;
}

HRESULT CSceneGraph::LoadShapes( xmlNodePtr ShapesNode,
                                 string PreName,
                                 string LoadFilePath,
                                 map<unsigned long, xmlNodePtr> &AnimationShapeList,
                                 int ZOrder)
{
    if ( ShapesNode==NULL )
    {
        return E_FAIL;
    }

    for ( int ShapeIndex=0 ; ShapeIndex< m_xml.CountChildNode(ShapesNode) ; ShapeIndex++ )
    {
        xmlNodePtr ShapeNode =  m_xml.FindChildIndex(ShapesNode,ShapeIndex);

        if (  m_xml.HasAttribute(ShapeNode,xmlCharStrdup("ZOrderPosition")) )
        {
            int ZOrderPosition = atoi((char*) m_xml.GetAttribute(ShapeNode,xmlCharStrdup("ZOrderPosition")));

            if ( ZOrderPosition>=ZOrder )
            {
                LoadShape(ShapeNode, PreName, LoadFilePath, AnimationShapeList);
            }
            else
            {
                // 如果有演員具有Hyperlink 且被歸類為靜態背景，則建立演員但不給圖片位置
                bool Has;
                HasActionSettings(ShapeNode, Has);
                if ( Has==true )
                {
                    LoadShape(ShapeNode, PreName, LoadFilePath, AnimationShapeList);
                    m_ActorList[m_ActorList.size()-1]->m_ImageFileName.clear();
                }
            }
        }
    }

    return S_OK;
}
//---------------------------------------------------------------------------

// 載入 Slides
HRESULT CSceneGraph::LoadSlide( xmlNodePtr SlideNode,
                                xmlNodePtr DesignsNode,
                                string LoadFilePath,
                                map<unsigned long, xmlNodePtr> &AnimationShapeList)
{
    HRESULT hr = S_OK;


    // 讀取 SlideTitle
    if (  m_xml.HasAttribute(SlideNode,xmlCharStrdup("Title")) )
    {
        m_Outline = string((char*) m_xml.GetAttribute(SlideNode,xmlCharStrdup("Title")));

        if(m_Outline == string(""))
        {
            m_Outline = m_SceneName;
        }
    }
    else
    {
        m_Outline = m_SceneName;
    }

    // 讀取 SlideID
    if (  m_xml.HasAttribute(SlideNode,xmlCharStrdup("SlideID")) )
    {
        m_SlideID = atoi((char*) m_xml.GetAttribute(SlideNode,xmlCharStrdup("SlideID")));
    }

    // 讀取 SlideIndex
    if (  m_xml.HasAttribute(SlideNode,xmlCharStrdup("SlideIndex")) )
    {
        m_SlideIndex = atoi((char*) m_xml.GetAttribute(SlideNode,xmlCharStrdup("SlideIndex")));
    }

    hr = LoadSlide_V1( SlideNode, DesignsNode, LoadFilePath, AnimationShapeList);

    /*
    xmlNodePtr StaticImageNode = SlideNode->ChildNodes->FindNode(L"StaticImage");
    if ( StaticImageNode==NULL )
    {
        hr = LoadSlide_V1( SlideNode, DesignsNode, LoadFilePath, AnimationShapeList);
    }
    else
    {
        hr = LoadSlide_V2( SlideNode, DesignsNode, LoadFilePath, AnimationShapeList);
    }
    */

	LOGD("~~~~~~~~~~~~~~end of  :LoadSlide  ");
    return hr;
}


// 舊的載入 Slide function
HRESULT CSceneGraph::LoadSlide_V1( xmlNodePtr SlideNode,
                                   xmlNodePtr DesignsNode,
                                   string LoadFilePath,
                                   map<unsigned long, xmlNodePtr> &AnimationShapeList)
{
	 LOGD("~~~~~~~~~~~~~~test log in LoadSlide_V1");
    HRESULT hr;

    int SlideWidth = 720;
    int SlideHeight = 540;

    // 尋找使用的投影片範例
    xmlNodePtr UseMasterNode = NULL;
    hr = GetMasterNode(SlideNode, DesignsNode, UseMasterNode);

    // 建立底圖(母片或背景)
    if ( UseMasterNode!=NULL )
    {
        SlideWidth = 720;
        SlideHeight = 540;

        if (  m_xml.HasAttribute(UseMasterNode,xmlCharStrdup("Width"))==true )
        {
			 LOGD("~~~~~~~~~~~~~~test log in LoadSlide_V1     m_xml.HasAttribute(UseMasterNode,xmlCharStrdup(Width))==true        ");
            //SlideWidth = (int)((float)UseMasterNode->m_xml.GetAttribute(L"Width")+0.5);
            float temp = atof((char*)m_xml.GetAttribute(UseMasterNode,xmlCharStrdup("Width")))+0.5;
            SlideWidth = (int)temp;
        }

        if (  m_xml.HasAttribute(UseMasterNode,xmlCharStrdup("Height"))==true )
        {

			 LOGD("~~~~~~~~~~~~~~test log in LoadSlide_V1     m_xml.HasAttribute(UseMasterNode,xmlCharStrdup(Height))==true        ");
            //SlideHeight = (int)((float)UseMasterNode->m_xml.GetAttribute(L"Height")+0.5);
            float temp = atof((char*)m_xml.GetAttribute(UseMasterNode,xmlCharStrdup("Height")))+0.5;
            SlideHeight = (int)temp;
        }

        // 決定投影片或投影片範圍是否要參照投影片母片的背景。
        if (  m_xml.HasAttribute(SlideNode,xmlCharStrdup("FollowMasterBackground")) )
        {
			
			 LOGD("~~~~~~~~~~~~~~test log in LoadSlide_V1      m_xml.HasAttribute(SlideNode,xmlCharStrdup(FollowMasterBackground)     ");
            long FollowMasterBackground = atol((char*) m_xml.GetAttribute(SlideNode,xmlCharStrdup("FollowMasterBackground")));
            if ( FollowMasterBackground==-1 )  // msoTrue
            {
				 LOGD("~~~~~~~~~~~~~~test log in LoadSlide_V1  FollowMasterBackground==-1    ");
                //指定投影片或投影片範圍參照投影片母片的背景。
                // 建立演員
                xmlNodePtr BackgroundNode =  m_xml.FindChildNode(UseMasterNode,xmlCharStrdup("Background"));
                if ( BackgroundNode!=NULL )
                {
					 LOGD("~~~~~~~~~~~~~~test log in LoadSlide_V1  if ( BackgroundNode!=NULL )  ");
                    xmlNodePtr ShapesNode =  m_xml.FindChildNode(BackgroundNode,xmlCharStrdup("Shapes"));
                    if ( LoadFilePath=="" )
                    {
						 LOGD("~~~~~~~~~~~~~~test log in LoadSlide_V1 LoadFilePath== ");
                        hr = LoadShapes(ShapesNode, string("Master_"), string(""), AnimationShapeList);
                    }
                    else
                    {
						 LOGD("~~~~~~~~~~~~~~test log in LoadSlide_V1 LoadFilePath== else");  //connie here 當掉
						 LOGD( LoadFilePath.c_str()); 
                        hr = LoadShapes(ShapesNode, string("Master_"), LoadFilePath, AnimationShapeList);
                    }
                }
            }
            else if ( FollowMasterBackground==0 ) // msoFalse
            {
				 LOGD("~~~~~~~~~~~~~~test log in LoadSlide_V1  FollowMasterBackground==0    ");
                // 指定投影片或投影片範圍有自訂的背景。
                // 建立演員
                xmlNodePtr BackgroundNode =  m_xml.FindChildNode(SlideNode,xmlCharStrdup("Background"));
                if ( BackgroundNode!=NULL )
                {
                    xmlNodePtr ShapesNode =  m_xml.FindChildNode(BackgroundNode,xmlCharStrdup("Shapes"));
                    if ( LoadFilePath=="" )
                    {
						LOGD("~~~~~~~~~~~~~~test log in LoadSlide_V1  FollowMasterBackground==0  if  ");
                        hr = LoadShapes(ShapesNode, string("Master_"), string(""), AnimationShapeList);
                    }
                    else
                    {
						LOGD("~~~~~~~~~~~~~~test log in LoadSlide_V1  FollowMasterBackground==0  else ");
                        hr = LoadShapes(ShapesNode, string("Master_"), LoadFilePath, AnimationShapeList); //connie error for new bst
						LOGD("~~~~~~~~~~~~~~test log in LoadSlide_V1  FollowMasterBackground==0  else load shap end");

                    }
                }
            }
        }


        //決定指定投影片或投影片範圍，是否要在投影片母片上顯示背景物件。
        if (  m_xml.HasAttribute(SlideNode,xmlCharStrdup("DisplayMasterShapes")) )
        {
			LOGD(" m_xml.HasAttribute(SlideNode,xmlCharStrdup(DisplayMasterShapes)");
            long DisplayMasterShapes = atol((char*) m_xml.GetAttribute(SlideNode,xmlCharStrdup("DisplayMasterShapes")));
            if ( DisplayMasterShapes==-1 )  // msoTrue
            {
				LOGD(" m_xml.HasAttribute(SlideNode,xmlCharStrdup(DisplayMasterShapes) if ");
                // 指定投影片或投影片範圍，將在投影片母片上顯示背景物件。
                // 建立演員
                xmlNodePtr ShapesNode =  m_xml.FindChildNode(UseMasterNode,xmlCharStrdup("Shapes"));
                if ( ShapesNode!=NULL )
                {
                    for ( int ShapeIndex=0 ; ShapeIndex< m_xml.CountChildNode(ShapesNode) ; ShapeIndex++ )
                    {
                        xmlNodePtr ShapeNode =  m_xml.FindChildIndex(ShapesNode,ShapeIndex);

                        long ShapeType = atol((char*) m_xml.GetAttribute(ShapeNode,xmlCharStrdup("Type")));
                        if ( ShapeType!=14 /*&& ShapeType!=7*/ ) // ?? 不確定拿掉 Type7 會不會有問題 OLEObject
                        {
                            CActor *pActor = new CActor();

                            if ( LoadFilePath=="" )
                            {
                                if ( pActor->LoadPPTShape(ShapeNode, string(""))==E_FAIL )
                                {
                                    SAFE_DELETE(pActor);
                                    continue;
                                }
                            }
                            else
                            {
                                if ( pActor->LoadPPTShape(ShapeNode, LoadFilePath)==E_FAIL )
                                {
                                    SAFE_DELETE(pActor);
                                    continue;
                                }
                            }

                            pActor->ActorName = string("Master_") + pActor->ActorName;

                            m_ActorList.push_back(pActor);
                        }
                    }
                }
            }
        }
    }
	LOGD(" m_xml.HasAttribute(SlideNode,xmlCharStrdup(DisplayMasterShapes) end");

    // 建立演員
    xmlNodePtr ShapesNode =  m_xml.FindChildNode(SlideNode,xmlCharStrdup("Shapes"));

    if ( ShapesNode!=NULL )
    {
        m_MinZOrder =  m_xml.CountChildNode(ShapesNode)+1;
        if ( LoadFilePath=="" )
        {
            hr = LoadShapes(ShapesNode, string(""), string(""), AnimationShapeList);
        }
        else
        {
            hr = LoadShapes(ShapesNode, string(""), LoadFilePath, AnimationShapeList);
        }
    }

LOGD(" ~~~~~~~~~~~~~~test log in LoadSlide_V1  end end");
    m_Width = SlideWidth;
    m_Height = SlideHeight;

    return hr;
}

// 新的載入 Slide function
HRESULT CSceneGraph::LoadSlide_V2( xmlNodePtr SlideNode,
                                   xmlNodePtr DesignsNode,
                                   string LoadFilePath,
                                   map<unsigned long, xmlNodePtr> &AnimationShapeList)
{
     LOGD("~~~~~~~~~~~~~~test log in LoadSlide_V2");
	HRESULT hr;

    int SlideWidth = 720;
    int SlideHeight = 540;

    // 尋找使用的投影片範例
    xmlNodePtr UseMasterNode = NULL;
    hr = GetMasterNode(SlideNode, DesignsNode, UseMasterNode);

    // 建立底圖(母片或背景)
    if ( UseMasterNode!=NULL )
    {
        SlideWidth = 720;
        SlideHeight = 540;

        if (  m_xml.HasAttribute(UseMasterNode,xmlCharStrdup("Width"))==true )
        {
            //SlideWidth = (int)((float)UseMasterNode->m_xml.GetAttribute(L"Width")+0.5);
            float temp = atof((char*)m_xml.GetAttribute(UseMasterNode,xmlCharStrdup("Width")))+0.5;
            SlideWidth = (int)temp;
        }

        if (  m_xml.HasAttribute(UseMasterNode,xmlCharStrdup("Height"))==true )
        {
            //SlideHeight = (int)((float)UseMasterNode->m_xml.GetAttribute(L"Height")+0.5);
            float temp = atof((char*)m_xml.GetAttribute(UseMasterNode,xmlCharStrdup("Height")))+0.5;
            SlideHeight = (int)temp;
        }
    }

    xmlNodePtr StaticImageNode =  m_xml.FindChildNode(SlideNode,xmlCharStrdup("StaticImage"));
    if ( StaticImageNode==NULL )
    {
        return E_FAIL;
    }

    // 載入靜態場景
    string StaticImage = string((char*) m_xml.GetAttribute(StaticImageNode,xmlCharStrdup("href")));
    StaticImage = LoadFilePath + StaticImage;

    CActor *pActor = new CActor();
    pActor->LoadStaticImage(m_SceneName.c_str(), StaticImage.c_str(), SlideWidth, SlideHeight);
    m_ActorList.push_back(pActor);

    // 取得最大深度
    m_MinZOrder = atoi((char*) m_xml.GetAttribute(StaticImageNode,xmlCharStrdup("StaticZOrder")));

    // 建立演員
    xmlNodePtr ShapesNode =  m_xml.FindChildNode(SlideNode,xmlCharStrdup("Shapes"));
    hr = LoadShapes(ShapesNode, string(""), LoadFilePath, AnimationShapeList, m_MinZOrder);

    m_Width = SlideWidth;
    m_Height = SlideHeight;

    return hr;
}

//---------------------------------------------------------------------------
// 個別載入 PPTXML function
// 載入 2003 特效
HRESULT CSceneGraph::LoadEffects(xmlNodePtr EffectsNode, xmlNodePtr SlideNode)
{
    // 建立特效
    if ( EffectsNode==NULL )
    {
        return E_FAIL;
    }

    for ( int EffectIndex=0 ; EffectIndex< m_xml.CountChildNode(EffectsNode) ; EffectIndex++ )
    {

        xmlNodePtr ShapesNode =  m_xml.FindChildNode(SlideNode,xmlCharStrdup("Shapes"));
        //xmlNodePtrList ShapesList = ShapesNode->ChildNodes;
        xmlNodePtr ShapesList = ShapesNode->xmlChildrenNode;   //取代LIST 需改變CACTORACTION

        xmlNodePtr EffectNode =  m_xml.FindChildIndex(EffectsNode,EffectIndex);

        // 作用的ShapeName
        if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("Shape"))==false )
        {
            // 如果特效沒有指定演員，則不處理此特效
            continue;
        }

        string ShapeName = string((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("Shape")));

        CActorAction *pActorAction = NULL;
        CActor *pEffectActor = NULL;

        // 取得擁有此特效的演員指標
        for ( int ActorIndex=0 ; ActorIndex<(int)m_ActorList.size() ; ActorIndex++ )
        {
            if ( m_ActorList[ActorIndex]->ActorName==ShapeName )
            {
                pEffectActor = m_ActorList[ActorIndex];


         //       if ( pEffectActor->m_ZOrderPosition!=-1 && pEffectActor->m_ZOrderPosition<m_MinZOrder )
                //{
      //              m_MinZOrder = pEffectActor->m_ZOrderPosition;
                //}

                break;
            }
        }

        if ( pEffectActor==NULL )
        {
            // 如果沒有找到特效所指定的演員，則不做任何事情
            continue;
        }

        //connie try
        //{
            // 建立特效
            pActorAction = new CActorAction(EffectNode, ShapesList, m_Width, m_Height);   //modify constructor
            //pActorAction->OnFinish = ActorActionFinish;
            //pActorAction->OnError = ActorActionError;
            pActorAction->Actor = (void *)pEffectActor;

        //}
     /*   catch(...)
        {
            // 建立特效產生例外，建立預設特效
            //string message;
            //message = message + "檢查：";
            //message = message + "載入場景" + m_SceneName ;
            //message = message + "的第" + string(EffectIndex+1) + L"個特效發生例外";
            //DebugMessage(message);

            if ( pActorAction!=NULL )
            {
                SAFE_DELETE(pActorAction);
            }

            // 產生預設的
            pActorAction = new CActorAction(m_Width, m_Height, ShapeName);
            //pActorAction->OnFinish = ActorActionFinish;
            //pActorAction->OnError = ActorActionError;
            pActorAction->Actor = (void *)pEffectActor;

        }*/
        pActorAction->InsertOriginalPosition();

        if ( pActorAction->InitState()==E_FAIL )
        {
            SAFE_DELETE(pActorAction);
            continue;
        }

        ActorActionList.push_back(pActorAction);
    }

    return S_OK;
}

// 載入 2000 特效
HRESULT CSceneGraph::LoadSingleAnimationSettings(xmlNodePtr ShapeNode)
{
    HRESULT hr = S_OK;

    // 作用的ShapeName
    string ShapeName = string((char*) m_xml.GetAttribute(ShapeNode,xmlCharStrdup("Name")));

    CActorAction *pActorAction = NULL;
    CActor *pEffectActor = NULL;

    // 取得擁有此特效的演員指標
    for ( int ActorIndex=0 ; ActorIndex<(int)m_ActorList.size() ; ActorIndex++ )
    {
        if ( m_ActorList[ActorIndex]->ActorName==ShapeName )
        {
            pEffectActor = m_ActorList[ActorIndex];


       //     if ( pEffectActor->m_ZOrderPosition!=-1 && pEffectActor->m_ZOrderPosition<m_MinZOrder )
            //{
     //           m_MinZOrder = pEffectActor->m_ZOrderPosition;
            //}

            break;
        }
    }

    if ( pEffectActor==NULL )
    {
        // 如果沒有找到特效所指定的演員，則不做任何事情
        return E_FAIL;
    }

    pActorAction = new CActorAction();

    hr = pActorAction->CreateActorAction(ShapeNode, m_Width, m_Height);
    if ( hr==E_FAIL )
    {
        SAFE_DELETE(pActorAction);
        return E_FAIL;
    }

    //pActorAction->OnFinish = ActorActionFinish;
    //pActorAction->OnError = ActorActionError;
    pActorAction->Actor = (void *)pEffectActor;
    pActorAction->InsertOriginalPosition();
    pActorAction->InitState();
    ActorActionList.push_back(pActorAction);

    return S_OK;
}


HRESULT CSceneGraph::LoadMultiAnimationSettings(xmlNodePtr ShapeNode)
{

    HRESULT hr = S_OK;
    vector<CActorAction *> TemplateActorActionList;

    // ppAnimateByAllLevels  16
    // ppAnimateByFifthLevel  5
    // ppAnimateByFirstLevel  1
    // ppAnimateByFourthLevel  4
    // ppAnimateBySecondLevel  2
    // ppAnimateByThirdLevel  3
    // ppAnimateLevelMixed  -2
    // ppAnimateLevelNone  0

    xmlNodePtr AnimationSettingsNode =  m_xml.FindChildNode(ShapeNode,xmlCharStrdup("AnimationSettings"));

    long TextLevelEffect = 0;
    if (  m_xml.HasAttribute(AnimationSettingsNode,xmlCharStrdup("TextLevelEffect"))==true )
    {
        TextLevelEffect = atol((char*) m_xml.GetAttribute(AnimationSettingsNode,xmlCharStrdup("TextLevelEffect")));
    }

    if ( TextLevelEffect==-2 )
    {
        // 無法處理此種狀況
        return E_FAIL;
    }

    if ( TextLevelEffect==0 || TextLevelEffect==16 )
    {
        // 使用錯誤的 function，不為分段特效
        return E_FAIL;
    }

    CActorAction *pActorAction = NULL;
    CActor *pEffectActor = NULL;

    // 作用的ShapeName
    string ShapeName =string((char*) m_xml.GetAttribute(ShapeNode,xmlCharStrdup("Name")));

    // 取得擁有此特效的演員指標
    for ( int ActorIndex=0 ; ActorIndex<(int)m_ActorList.size() ; ActorIndex++ )
    {
        if ( m_ActorList[ActorIndex]->ActorName==ShapeName )
        {
            pEffectActor = m_ActorList[ActorIndex];

            /*
            if ( pEffectActor->m_ZOrderPosition!=-1 && pEffectActor->m_ZOrderPosition<m_MinZOrder )
            {
                m_MinZOrder = pEffectActor->m_ZOrderPosition;
            }
            */
            break;
        }
    }

    if ( pEffectActor==NULL )
    {
        // 如果沒有找到特效所指定的演員，則不做任何事情
        return E_FAIL;
    }

    xmlNodePtr TextFrameNode =  m_xml.FindChildNode(ShapeNode,xmlCharStrdup("TextFrame"));

    if ( TextFrameNode==NULL )
    {
        // 沒有找到文字屬性的 Node
        return E_FAIL;
    }

    xmlNodePtr ParagraphsNode =  m_xml.FindChildNode(TextFrameNode,xmlCharStrdup("Paragraphs"));

    if ( ParagraphsNode==NULL )
    {
        // 沒有找到文字段落集合的 Node
        return E_FAIL;
    }

    for ( int index=0 ; index<m_xml.CountChildNode(ParagraphsNode) ; index++ )
    {
        xmlNodePtr ParagraphNode =  m_xml.FindChildIndex(ParagraphsNode,index);

        if ( ParagraphNode==NULL )
        {
            // 發生問題
            for ( unsigned int index=0 ; index<TemplateActorActionList.size() ; index++ )
            {
                SAFE_DELETE(TemplateActorActionList[index]);
            }
            TemplateActorActionList.clear();

            return E_FAIL;
        }

        if (  m_xml.HasAttribute(ParagraphNode,xmlCharStrdup("IndentLevel"))==false )
        {
            // 發生問題
            for ( unsigned int index=0 ; index<TemplateActorActionList.size() ; index++ )
            {
                SAFE_DELETE(TemplateActorActionList[index]);
            }
            TemplateActorActionList.clear();

            return E_FAIL;
        }

        long IndentLevel = atol((char*) m_xml.GetAttribute(ParagraphNode,xmlCharStrdup("IndentLevel")));

        if ( IndentLevel<=TextLevelEffect )
        {
            pActorAction = new CActorAction();
            // TriggleType = 1 : msoAnimTriggerOnPageClick
            hr = pActorAction->CreateActorAction(ShapeNode, m_Width, m_Height, index+1, 1);
            if ( hr==E_FAIL )
            {
                SAFE_DELETE(pActorAction);

                for ( unsigned int index=0 ; index<TemplateActorActionList.size() ; index++ )
                {
                    SAFE_DELETE(TemplateActorActionList[index]);
                }
                TemplateActorActionList.clear();

                return E_FAIL;
            }
        }
        else
        {
            // msoAnimTextUnitEffectByCharacter  1
            // msoAnimTextUnitEffectByParagraph  0
            // msoAnimTextUnitEffectByWord  2
            // msoAnimTextUnitEffectMixed  -1

            long TextUnitEffect = 0;

            if (  m_xml.HasAttribute(AnimationSettingsNode,xmlCharStrdup("TextUnitEffect"))==true )
            {
                TextUnitEffect = atol((char*) m_xml.GetAttribute(AnimationSettingsNode,xmlCharStrdup("TextUnitEffect")));
            }

            pActorAction = new CActorAction();
            if ( TextUnitEffect==0 )
            {
                // 同時
                // TriggleType = 2 : msoAnimTriggerWithPrevious
                hr = pActorAction->CreateActorAction(ShapeNode, m_Width, m_Height, index+1, 2);

            }
            else if ( TextUnitEffect==1 )
            {
                // 依據英文句子或中文句子
                // TriggleType = 3 : msoAnimTriggerAfterPrevious
                hr = pActorAction->CreateActorAction(ShapeNode, m_Width, m_Height, index+1, 3);

            }
            else
            {
                // 預設給同時出現
                // TriggleType = 2 : msoAnimTriggerWithPrevious
                hr = pActorAction->CreateActorAction(ShapeNode, m_Width, m_Height, index+1, 2);
            }



            if ( hr==E_FAIL )
            {
                SAFE_DELETE(pActorAction);

                for ( unsigned int index=0 ; index<TemplateActorActionList.size() ; index++ )
                {
                    SAFE_DELETE(TemplateActorActionList[index]);
                }
                TemplateActorActionList.clear();

                return E_FAIL;
            }
        }

        //pActorAction->OnFinish = ActorActionFinish;
        //pActorAction->OnError = ActorActionError;
        pActorAction->Actor = (void *)pEffectActor;
        pActorAction->InsertOriginalPosition();
        pActorAction->InitState();
        TemplateActorActionList.push_back(pActorAction);
    }

    for ( unsigned int index=0 ; index<TemplateActorActionList.size() ; index++ )
    {
        ActorActionList.push_back(TemplateActorActionList[index]);
    }
    TemplateActorActionList.clear();

    return S_OK;
}

HRESULT CSceneGraph::LoadAnimationSettings(map<unsigned long, xmlNodePtr> AnimationShapeList)
{

    HRESULT hr = S_OK;

    map<unsigned long, xmlNodePtr>::iterator iter;
    int index = 1;

    while (1)
    {
        iter = AnimationShapeList.find(index);

        if ( iter==AnimationShapeList.end() )
        {
            break;
        }

        // ppAnimateByAllLevels  16
        // ppAnimateByFifthLevel  5
        // ppAnimateByFirstLevel  1
        // ppAnimateByFourthLevel  4
        // ppAnimateBySecondLevel  2
        // ppAnimateByThirdLevel  3
        // ppAnimateLevelMixed  -2
        // ppAnimateLevelNone  0

        //xmlNodePtr AnimationSettingsNode = iter->second->ChildNodes->FindNode(L"AnimationSettings");
        xmlNodePtr AnimationSettingsNode =  m_xml.FindChildNode(iter->second,xmlCharStrdup("AnimationSettings"));

        long TextLevelEffect = 0;
        if (  m_xml.HasAttribute(AnimationSettingsNode,xmlCharStrdup("TextLevelEffect"))==true )
        {
            TextLevelEffect = atol((char*) m_xml.GetAttribute(AnimationSettingsNode,xmlCharStrdup("TextLevelEffect")));
        }

        if ( TextLevelEffect==0 || TextLevelEffect==16 )
        {
            hr = LoadSingleAnimationSettings(iter->second);
            if ( hr!=S_OK )
            {

            }
        }
        else
        {
            hr = LoadMultiAnimationSettings(iter->second);
            if ( hr!=S_OK )
            {

            }
        }

        index++;

    }

    return S_OK;
}
//---------------------------------------------------------------------------

HRESULT CSceneGraph::LoadPowerPoint2003XML(string SceneName, xmlNodePtr xmlPPT, string LoadFilePath)
{
    //DebugMessage("CSceneGraph::LoadSceneGraph");

    HRESULT hr = S_OK;

    map<unsigned long, xmlNodePtr> AnimationShapeList;

    // 先取得Masters和Slides指標
    xmlNodePtr DesignsNode =  m_xml.FindChildNode(xmlPPT,xmlCharStrdup("Designs"));
    xmlNodePtr SlidesNode =  m_xml.FindChildNode(xmlPPT,xmlCharStrdup("Slides"));
    if(SlidesNode == NULL)
    {
        return E_FAIL;
    }


    m_SceneName = SceneName;
    m_Width = 720;
    m_Height = 540;
    m_BackgroundColor = 0x00ffffff;
    m_pMouseActor = NULL;


    bool IsSomethingWrong = false;

	 LOGD("test log before for ");
    for ( int SlideIndex=0 ; SlideIndex <  m_xml.CountChildNode(SlidesNode) ; SlideIndex++ )
    {
		 LOGD("test log in for 2003 ");
        xmlNodePtr SlideNode =  m_xml.FindChildIndex(SlidesNode,SlideIndex);

        if(string((char*) m_xml.GetAttribute(SlideNode,xmlCharStrdup("Name"))) != SceneName)
        {
            continue;
        }


        //connie try
        //{
            hr = LoadSlide(SlideNode, DesignsNode, LoadFilePath, AnimationShapeList);
        //}
        /*catch(...)
        {
            //DebugMessage(string("檢查：") + SceneName + string("的LoadSlide有例外。"));
            IsSomethingWrong = true;
        }
		*/


        // 建立特效
        xmlNodePtr TimeLineNode =  m_xml.FindChildNode(SlideNode,xmlCharStrdup("TimeLine"));
        if ( TimeLineNode!=NULL )
        {
            xmlNodePtr MainSequenceNode =  m_xml.FindChildNode(TimeLineNode,xmlCharStrdup("MainSequence"));

           //connie try
            //{
                hr = LoadEffects(MainSequenceNode, SlideNode);
            //}
            /*catch(...)
            {
                //DebugMessage(string("檢查：") + SceneName + string("的LoadEffects有例外。"));
                IsSomethingWrong = true;
            }*/
        }
    }
	 LOGD("test log out for ");

    // 設定滑鼠演員
     LoadMouse();
	 LOGD("test log after   LoadMouse(); ");


    // 設定索引預設值
    m_ActorIndex = 0;
    m_ActorActionIndex = 0;

    LastTriggerTime = 0;

    AnimationShapeList.clear();

    if(IsSomethingWrong == true)
    {
        // 有一些部份沒有載入成功。
        return E_FAIL;
    }

    return S_OK;
}
//---------------------------------------------------------------------------
HRESULT CSceneGraph::LoadPowerPoint2000XML(string SceneName, xmlNodePtr xmlPPT, string LoadFilePath)
{
    //DebugMessage("CSceneGraph::LoadSceneGraph");
    LOGD("test log in LoadPowerPoint2000XML");
    HRESULT hr = S_OK;

    map<unsigned long, xmlNodePtr> AnimationShapeList;

    // 先取得Masters和Slides指標
    xmlNodePtr DesignsNode =  m_xml.FindChildNode(xmlPPT,xmlCharStrdup("Designs"));
    xmlNodePtr SlidesNode =  m_xml.FindChildNode(xmlPPT,xmlCharStrdup("Slides"));

	    LOGD("test log in LoadPowerPoint2000XML 1");
    if(SlidesNode == NULL)
    {
        return E_FAIL;
    }

        LOGD("test log in LoadPowerPoint2000XML 2"); 
    m_SceneName = SceneName;
    m_Width = 720;
    m_Height = 540;
    m_BackgroundColor = 0x00ffffff;
    m_pMouseActor = NULL;

    LOGD("test log in LoadPowerPoint2000XML 3");
    bool IsSomethingWrong = false;

    for ( int SlideIndex=0 ; SlideIndex <  m_xml.CountChildNode(SlidesNode) ; SlideIndex++ )
    {
		 LOGD("test log in for");
        xmlNodePtr SlideNode =  m_xml.FindChildIndex(SlidesNode,SlideIndex);

        if(string((char*) m_xml.GetAttribute(SlideNode,xmlCharStrdup("Name"))) != SceneName)
        {
            continue;
        }

        //connie try
       // {
            hr = LoadSlide(SlideNode, DesignsNode, LoadFilePath, AnimationShapeList);
    //    }
     /*   catch(...)
        {
            //DebugMessage(string("檢查：") + SceneName + string("的LoadSlide有例外。"));
            IsSomethingWrong = true;
        }*/

     //connie   try
        //{
            hr = LoadAnimationSettings(AnimationShapeList);
        //}
        /*catch(...)
        {
            //DebugMessage(string("檢查：") + SceneName + string("的LoadAnimationSettings有例外。"));
            IsSomethingWrong = true;
        }*/
    }
    LOGD("test log in out for");
    // 設定滑鼠演員
    LoadMouse();
	LOGD("test log after LoadMouse(); ");

    // 設定索引預設值
    m_ActorIndex = 0;
    m_ActorActionIndex = 0;

    LastTriggerTime = 0;

    AnimationShapeList.clear();

    if(IsSomethingWrong == true)
    {
        // 有一些部份沒有載入成功。
        return E_FAIL;
    }

    return S_OK;
}
//---------------------------------------------------------------------------
HRESULT CSceneGraph::HasActionSettings(xmlNodePtr ShapeNode, bool &Has)
{
    Has = false;

    xmlNodePtr ActionSettingsNode =  m_xml.FindChildNode(ShapeNode,xmlCharStrdup("ActionSettings"));
    if ( ActionSettingsNode!=NULL )
    {
        if (  m_xml.CountChildNode(ActionSettingsNode)!=0 )
        {
            Has = true;
            return S_OK;
        }
    }

    xmlNodePtr TextFrameNode =  m_xml.FindChildNode(ShapeNode,xmlCharStrdup("TextFrame"));
    xmlNodePtr TextActionSettingsNode =  m_xml.FindChildNode(TextFrameNode,xmlCharStrdup("TextActionSettings"));
    if ( TextActionSettingsNode!=NULL )
    {
        if (  m_xml.CountChildNode(TextActionSettingsNode)!=0 )
        {
            Has = true;
            return S_OK;
        }
    }

    return E_FAIL;
}

// 設定場景時間是否可作用
HRESULT CSceneGraph::SetTimerEnabled(bool Enabled)
{
    m_SceneTimer.EnableTimer(Enabled);

    //unsigned int kk = m_ActorList.size();

    for ( unsigned int index=0 ; index<m_ActorList.size() ; index++ )
    {
        m_ActorList[index]->Media_RefreshEnabled(Enabled);
    }

    return S_OK;

}

HRESULT CSceneGraph::MediaPlayerEnd(const char *pActorName)
{
    vector<CActor *>::iterator iter;
    for ( iter=m_ActorList.begin() ; iter!=m_ActorList.end() ; iter++ )
    {
        string SlideActorName = m_SceneName + "_" + (*iter)->ActorName;
        if ( SlideActorName==string(pActorName) )
        {
            (*iter)->Media_Stop();
        }
    }
    return S_OK;
}

HRESULT CSceneGraph::StopAllMediaActor(void)
{
    vector<CActor *>::iterator iter;
    for ( iter=m_ActorList.begin() ; iter!=m_ActorList.end() ; iter++ )
    {
        (*iter)->Media_Stop();
    }
    return S_OK;
}

HRESULT CSceneGraph::PauseAllMediaActor(void)
{
    vector<CActor *>::iterator iter;
    for ( iter=m_ActorList.begin() ; iter!=m_ActorList.end() ; iter++ )
    {
        (*iter)->Media_Pause();
    }
    return S_OK;
}

HRESULT CSceneGraph::SetMute(bool Mute)
{
    for ( unsigned int index=0 ; index<m_ActorList.size() ; index++ )
    {
        m_ActorList[index]->SetMute(Mute);
    }
    return S_OK;
}

HRESULT CSceneGraph::GotoTimeFinish()
{
    for ( unsigned int index=0 ; index<m_ActorList.size() ; index++ )
    {
        m_ActorList[index]->GotoTimeFinish();
    }
    return S_OK;
}

HRESULT CSceneGraph::AddScreenRecActor(const char *pFileName, int VideoWidth, int VideoHeight)
{
    // 將底色改成黑色
    m_BackgroundColor = 0x000000;

    CActor *pActor = new CActor();
    pActor->SetScreenRecActor(pFileName, VideoWidth, VideoHeight);
    m_ActorList.push_back(pActor);
    return S_OK;
}
