//---------------------------------------------------------------------------
//
// 講解手場景資料系統
//
//---------------------------------------------------------------------------

#ifndef CSceneGraphH
#define CSceneGraphH

#include "globals.h"
#include "CTimer.h"
#include "CActor.h"
#include "CActorAction.h"
#include "MyXML.h"

//---------------------------------------------------------------------------
// 場景類別
//---------------------------------------------------------------------------
enum SceneGraphType
{
    SceneGraph_PPT = 1,
    SceneGraph_ScreenRec = 2
};


class CSceneGraph
{
public:

    CSceneGraph();
    ~CSceneGraph();

    //---------------------------------------------------------------------------
    // 載入pptxml中的場景內容
    //---------------------------------------------------------------------------
    SceneGraphType m_Type;
    /*!
     *
     */
    HRESULT LoadSceneGraph(string SceneName, xmlNodePtr xmlPPT, string LoadFilePath);
    HRESULT LoadMouse();
    bool GetActiveMouseVisible();
    void SetActiveMouseVisible(bool Visible);
    bool Visible;
    // 場景中的演員
    int  m_ActorIndex;
    vector<CActor *> m_ActorList;
    // 有特效的演員列表, 不另外配置空間，只存指標位置
    int m_ActorActionIndex;
    vector<CActorAction *> ActorActionList;

    // 滑鼠演員
    vector<CActor *> m_pMouseActors;
    CActor * m_pMouseActor;
    // 塗鴉演員
    int m_ActorDrawIndex;
    vector<CDrawActor *> ActorDrawList;
    // 暫停或NG點的塗鴉演員
    int m_PauseActorDrawIndex;
    vector<CDrawActor *> PauseActorDrawList;
    // 目前作用的塗鴉演員
    CDrawActor *m_pActiveDrawActor;
    // 特效演員最小的ZOrder
    int m_MinZOrder;
    //---------------------------------------------------------------------------
    // 場景內部的時間
    //---------------------------------------------------------------------------
    CTimer m_SceneTimer;
    //---------------------------------------------------------------------------
    // 場景的事件
    //---------------------------------------------------------------------------

    void OnTimer();
    void OnTimer(unsigned long dtime);

    bool OnMouseClick(int X, int Y);
    void OnMouseClick1(int X, int Y);    // 給看錄製結果的時候使用的
    void OnMouseMove(int X, int Y);
    void OnMouseMove1(int X, int Y);    // 給預覽的時候使用的
    //---------------------------------------------------------------------------
    // 重置場景
    //---------------------------------------------------------------------------
    void Reset();
    void ResetAction();
    // 用來處理一些在顯示時就要處理的東西，例如特效等。
    void StartShow();
    void StartShow1();
    // 判斷是否有前一個或下一個動畫
    bool HavePreviousAction(void);
    bool HaveNextAction(void);
    bool HaveAction(void);

    void ActionIndex(int &Index, int &Size);

    // 跳到前一個或下一個動畫
    bool GotoPreviousAction(void);
    bool GotoNextAction(void);



    //////////////////////////////////////////
    // 塗鴉演員相關函式

    // 記錄塗鴉資料, 將資料寫入塗鴉演員, ActorType 為 main 或 pause 兩種
    void Draw(string ActorType, CScriptAction Action);

    // 觸發塗鴉演員, 當腳本的指令為 Scene.Draw 時, 執行觸發塗鴉演員
    // ActorType 為 main 或 pause 兩種
    void TriggerDrawActor(string ActorType, CScriptAction Action);

    // 判斷塗鴉指令是否為開始或結束塗鴉指令
    bool IsBeginDraw(CScriptAction Action);
    bool IsEndDraw(CScriptAction Action);

    // 清除主要塗鴉演員與暫停錄製塗鴉演員
    void ClearDrawActor(void);
    void ClearPauseDrawActor(void);

    // 將暫停錄製或NG錄製的塗鴉演員資訊合併到主要錄製的塗鴉演員裡
    void MergePauseDrawActor(unsigned long PauseTime);

    // 清除塗鴉演員繪圖指令
    void ClearDrawActorCommand(void);
    void ClearPauseDrawActorCommand(void);


    // 判斷演員是否具有影片及是否播放影片
    HRESULT HasMediaActorWork(bool &Has, string &ActorName);


    // 設定場景時間是否可作用
    HRESULT SetTimerEnabled(bool Enabled);


    HRESULT MediaPlayerEnd(const char *pActorName);

    HRESULT StopAllMediaActor(void);

    HRESULT PauseAllMediaActor(void);

    HRESULT SetMute(bool Mute);

    HRESULT GotoTimeFinish();

    // 增加全螢幕錄製演員
    HRESULT AddScreenRecActor(const char *pFileName, int VideoWidth, int VideoHeight);   // pFileName即為全螢幕錄製檔案名稱(完整檔名或短檔名)




//private:
    MyXML m_xml;      //linx add

    // 場景基本資料
    string m_SceneName;
    int     m_Width;
    int     m_Height;
    int     m_BackgroundColor;

    // PowerPoint的Slide的資料
    string m_Outline;
    int     m_SlideID;
    int     m_SlideIndex;

    string m_SourceDir;
    string m_ScreenRecFileName;
    unsigned long LastTriggerTime;
    unsigned long MaxDurTime;

    void ActorActionFinish(CActorAction *pActorAction);
    void ActorActionError(CActorAction *pActorAction);
    // 滑鼠點擊有 ActionSetting 的演員
    void (*OnMouseClickAction)(int Action, int SlideID, string URL, bool &ChangeSlide);

    // 滑鼠移到有 ActionSetting 演員上，需改變滑鼠游標
    void (*OnMouseOverAction)(bool Over, bool &ChangeCursor);

    // 依照位置尋找演員索引
    bool SearchActorByPos(int X, int Y, unsigned int &ActorIndex, unsigned int &ActionSettingIndex);

    //======== 共用載入 PPTXML function =======
    // 取得使用母片的 Node
    HRESULT GetMasterNode(xmlNodePtr SlideNode, xmlNodePtr DesignsNode, xmlNodePtr &MasterNode);

    // 載入 Shape
    HRESULT LoadShape( xmlNodePtr ShapeNode,
                       string PreName,
                       string LoadFilePath,
                       map<unsigned long, xmlNodePtr> &AnimationShapeList);

    // 載入 Shape 集合
    HRESULT LoadShapes( xmlNodePtr ShapesNode,
                        string PreName,
                        string LoadFilePath,
                        map<unsigned long, xmlNodePtr> &AnimationShapeList);

    // 載入 Shape 集合，但演員的ZOrder必須比傳入的ZOrder要來得大，此演員才會被載入
    HRESULT LoadShapes( xmlNodePtr ShapesNode,
                        string PreName,
                        string LoadFilePath,
                        map<unsigned long, xmlNodePtr> &AnimationShapeList,
                        int ZOrder);

    // 載入 Slides
    HRESULT LoadSlide( xmlNodePtr SlideNode,
                       xmlNodePtr DesignsNode,
                       string LoadFilePath,
                       map<unsigned long, xmlNodePtr> &AnimationShapeList);

    // 舊的載入 Slide function
    HRESULT LoadSlide_V1( xmlNodePtr SlideNode,
                          xmlNodePtr DesignsNode,
                          string LoadFilePath,
                          map<unsigned long, xmlNodePtr> &AnimationShapeList);

    // 新的載入 Slide function
    HRESULT LoadSlide_V2( xmlNodePtr SlideNode,
                          xmlNodePtr DesignsNode,
                          string LoadFilePath,
                          map<unsigned long, xmlNodePtr> &AnimationShapeList);

    // 載入 2003 特效
    HRESULT LoadEffects(xmlNodePtr EffectsNode, xmlNodePtr SlideNode);

    // 載入 2000 特效
    HRESULT LoadSingleAnimationSettings(xmlNodePtr ShapeNode);
    HRESULT LoadMultiAnimationSettings(xmlNodePtr ShapeNode);
    HRESULT LoadAnimationSettings(map<unsigned long, xmlNodePtr> AnimationShapeList);

    // 判斷是否有超連結等資訊
    // 使用情況為建立靜態背景時，如果靜態背景中的演員有超連結，則需要建立演員資訊，但不給予圖片名稱。
    HRESULT HasActionSettings(xmlNodePtr ShapeNode, bool &Has);

    HRESULT LoadPowerPoint2003XML(string SceneName, xmlNodePtr xmlPPT, string LoadFilePath);
    HRESULT LoadPowerPoint2000XML(string SceneName, xmlNodePtr xmlPPT, string LoadFilePath);
    //

    // callback fucntion
    void (*OnProgressMessage)(string MessageId, int Position, bool Visible); //function pointer
    void (*OnDebugMessage)(string Message);
    void ProgressMessage(string MessageId, int Position, bool Visible);
    void DebugMessage(string Message);
};

//---------------------------------------------------------------------------
#endif
