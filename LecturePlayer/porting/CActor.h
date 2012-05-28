#ifndef __CACTOR_H__
#define __CACTOR_H__

//#include <math.h>
#include "CScriptSystem.h"
#include "CTimer.h"
#include "globals.h"
#include "MyXML.h"

#include <string>
#include <vector>

using std::string;
using std::vector;

;         //strange error!
//----------------linx add-------------------------------------------
struct RECT
{
    int top;
    int bottom;
    int left;
    int right;
};
//---------------------------------------------------------------------------


enum ActorType
{
    ActorType_Normal = 1,
    ActorType_Media  = 2
};

enum MediaActorState
{
    MediaActorState_Play  = 1,
    MediaActorState_Pause = 2,
    MediaActorState_Stop  = 3
};

enum MediaActorType
{
    MediaActorType_WMV = 1,
    MediaActorType_WMA = 2
};


class CActorRenderInfo
{
public:
    int EffectIndex;    // 沒有作用了，原本指特效的索引值

    float Actor[4][2];  // 與 Shape 左上角頂點的相對位置
    float TextureX;
    float TextureY;
    float TextureWidth;
    float TextureHeight;
    float Rotation;
    float Red;
    float Green;
    float Blue;
    float Alpha;


    // 原始資料，在沒有做任何特效前的資料
    float OriActor[4][2];
    float OriTextureX;
    float OriTextureY;
    float OriTextureWidth;
    float OriTextureHeight;


    // 文字段落的位置(不包含前面索引)
    float TextActor[4][2];
    float TextTextureX;
    float TextTextureY;
    float TextTextureWidth;
    float TextTextureHeight;


    // 指此 RenderInfo 是屬於第幾個段落，如果沒有段落，則為 0 ，default=0。
    long Paragraph;

    // 如果某ㄧ特效需要使用到兩個 RenderInfo 才可表現，則需設定 SubIndex，default=0。
    int SubIndex;

    // 判斷是否已經執行進入或路徑特效的旗標，如果有進入或路徑特效被執行，則 m_EnterPathAction=true。
    bool m_EnterAction;

    // 判斷是否已經執行結束特效的旗標，如果有結束特效被執行，則 m_ExitAction=true。　
    bool m_ExitAction;

    // 進入或路徑特效完成旗標
    bool m_EnterFinish;

    // 結束特效完成旗標
    bool m_ExitFinish;

    // 判斷是否已經被初始化
    bool m_HaveInit;

    // 判斷群組的特效是否已經被執行完畢，執行完畢意思為，所有特效執行完畢或有ㄧ各結束特效已經結束。
    bool m_ActionFinish;

    // 特效種類
    long m_EffectType;

    // 判斷是否有路徑特效，如果有路徑特效，此特效顯示資訊結束改變的時間會以路徑特效的時間為主
    bool m_PathAction;

    bool m_PathFinish;

    // 判斷最後一個執行的特效是否為結束特效
    bool m_LastUseExitAction;

    CActorRenderInfo()
    {
        Paragraph = 0;
        SubIndex = 0;
        m_EffectType = -1;

        m_EnterAction = false;

        m_ExitAction = false;
        m_EnterFinish = true;
        m_ExitFinish = true;

        m_PathAction = false;
        m_PathFinish = true;

        m_HaveInit = false;

        m_ActionFinish = true;

        m_EffectType = -1;

        m_LastUseExitAction = false;

        TextureX = 0.0;
        TextureY = 0.0;
        TextureWidth = 1.0;
        TextureHeight = 1.0;
        Rotation = 0.0;
        Red = 1.0;
        Green = 1.0;
        Blue = 1.0;
        Alpha = 1.0;


    }

    void DetermineActionFinish(void)
    {
        // 如果 (1)特效還沒結束 (2)有ㄧ各進入、路徑特效結束 (3)沒有結束特效
        // 則此演員的特效已經結束
        if ( m_ActionFinish==false && m_EnterFinish==true && m_ExitAction==false )
            m_ActionFinish = true;
    }

    void Reset(void)
    {
        m_EnterAction = false;
        m_ExitAction = false;
        m_EnterFinish = true;
        m_ExitFinish = true;

        m_HaveInit = false;

        m_ActionFinish = true;
    }

    bool operator!=(CActorRenderInfo RenderInfo)
    {
        if ( Actor[0][0]!=RenderInfo.Actor[0][0] )
            return true;
        if ( Actor[0][1]!=RenderInfo.Actor[0][1] )
            return true;
        if ( Actor[1][0]!=RenderInfo.Actor[1][0] )
            return true;
        if ( Actor[1][1]!=RenderInfo.Actor[1][1] )
            return true;
        if ( Actor[2][0]!=RenderInfo.Actor[2][0] )
            return true;
        if ( Actor[2][1]!=RenderInfo.Actor[2][1] )
            return true;
        if ( Actor[3][0]!=RenderInfo.Actor[3][0] )
            return true;
        if ( Actor[3][1]!=RenderInfo.Actor[3][1] )
            return true;

        if ( TextureX!=RenderInfo.TextureX )
            return true;
        if ( TextureY!=RenderInfo.TextureY )
            return true;
        if ( TextureWidth!=RenderInfo.TextureWidth )
            return true;
        if ( TextureHeight!=TextureHeight )
            return true;
        if ( Rotation!=RenderInfo.Rotation )
            return true;
        if ( Red!=RenderInfo.Red )
            return true;
        if ( Green!=RenderInfo.Green )
            return true;
        if ( Blue!=RenderInfo.Blue )
            return true;
        if ( Alpha!=RenderInfo.Alpha )
            return true;
        return false;
    }

    bool Inside(int X, int Y)
    {
        if ( Alpha!=1 )
            return false;

    	if ( (X>=Actor[0][0] && X<=Actor[1][0]) && (Y>=Actor[0][1] && Y<=Actor[3][1]) )
    	{
    		return true;
    	}
    	return false;
    }
};



class CActor
{
public:
    CActor();
    ~CActor();
    HRESULT LoadStaticImage(const char *pName, const char *pFile, int Width, int Height);
    HRESULT LoadPPTShape(xmlNodePtr ShapeNode, string LoadFilePath);
    void ClearActorRenderInfo(void);
    // 重設顯示區塊的特效是否完成。
    void DetermineActionFinish(void);
    // 重設顯示區塊的特效更新預設參數。
    void ResetActionRefresh(void);
    void SetActionFinish(bool Finish);
    bool GetRenderInfo(long Paragraph, vector<CActorRenderInfo> &RenderInfo);
    bool Inside(int x, int y, unsigned int &ActionSettingIndex);
    bool HasMCAction(void);
    // 多媒體演員被滑鼠點擊
    // 此處的 TimerEnabled 是用來指定 m_MediaTimer 是否被啟動，
    // 當直接拖拉時間軸執行 Media_Click() 時，m_MediaTimer 不被啟動
    HRESULT Media_Click(bool TimerEnabled);
    // 多媒體演員開始
    HRESULT Media_Start();
    // 多媒體演員停止
    HRESULT Media_Stop();
    // 多媒體演員暫停
    HRESULT Media_Pause();
    // 更新多媒體的時間
    HRESULT Media_Refresh();
    HRESULT Media_Refresh(unsigned long dTime);
    // 設定多媒體時間是否可作用
    HRESULT Media_RefreshEnabled(bool TimerEnabled);
    //===== 重設資訊相關 =====
    // 對外的重設函數
    HRESULT Reset(void);
    HRESULT SetMute(bool Mute);
    HRESULT GetMute(bool &Mute);
    HRESULT GotoTimeFinish();
    HRESULT IsVisible();
    HRESULT SetScreenRecActor(const char *pFileName, int VideoWidth, int VideoHeight);   // pFileName 為全螢幕錄製檔案完整檔名或短檔名

    // 顯示用的資訊
    vector<CActorRenderInfo> m_ActorRenderInfo;
    // 我們自己定義的種類
    ActorType m_ActorType;  
    // 特效是否正在作用
    bool m_IsActing;
    // 文字方塊分段的顯示資訊
    vector<CActorRenderInfo> m_SubRenderInfo;
    // 原始shape的位置及大小
    int m_X;
    int m_Y;
    int m_Width;
    int m_Height;
    // 文字顏色資訊
    int textColorRGB[3];
    // 演員是否有特效
    bool m_HaveEffect;
    // 演員控制資料
    bool Visible;
    bool Enabled;

    /******************************
     m_ActionSettingAction list :
     ppActionEndShow          6
     ppActionFirstSlide       3
     ppActionHyperlink        7
     ppActionLastSlide        4
     ppActionLastSlideViewed  5
     ppActionMixed           -2
     ppActionNamedSlideShow  10
     ppActionNextSlide        1
     ppActionNone             0
     ppActionOLEVerb         11
     ppActionPlay            12
     ppActionPreviousSlide    2
     ppActionRunMacro         8
     ppActionRunProgram       9
     *******************************/
    vector<int>     m_MCActionSettingAction;
    vector<int>     m_MCHyperlinkSlideID;
    vector<string> m_MCURL;
    vector<RECT> m_ActionSettingSenseRect;   //矩型 no use???
    
    // 滑鼠游標專用
    int X;
    int Y;
    int Width;
    int Height;
    int Alpha;
    
    // 演員基本資料
    string ActorName;
    string m_ImageFileName;
    
    bool            m_PlayOnEntry;      // 判斷是否投影片播放時就播放多媒體



    // 儲存出影像的大概位置
    int m_ImageX;
    int m_ImageY;
    int m_ImageWidth;
    int m_ImageHeight;

    
    
private:
    // ===== 多媒體相關成員與函數 =====
    // 影片演員資訊
       string         m_MediaFileName;    // 多媒體的檔案名稱
    MediaActorState m_MediaActorState;  // 多媒體的播放狀態
    CTimer          m_MediaTimer;       // 多媒體的播放時間
    bool m_MediaGotoTime;
    bool m_MediaGotoTimeFinish;
    bool m_MediaActorRefresh;
    MyXML m_xml;   //linx add
    bool m_Mute;
    
    MediaActorType m_MediaType; // 我們自己定的的多媒體演員的子種類
       
    //bool m_NeedRefresh;
    
    
    
    
    
        // 跟 Shape 的相對位置
    float m_ImageRect[4][2];
    
    // 交大在動畫時，需載入所有Shape資訊
    // 以下為Shape的剩餘資訊
    long type;
    double m_Rotation;
    int m_ZOrderPosition;
    
    
    // 判斷ActionSettings是否被使用，有些Video或Audio檔案格式不支援，則ActionSettings不被使用
    bool m_ActionSettingsEnabled;
    void GetRGBvalue(string HexValue, int RGB[]);
    bool ClearActionSettings(void);
    bool AddActionSettings(xmlNodePtr ActionSettingsNode);
    bool ParserHyperlinkSubAddress( string SubAddress, string Item[3]);
    // 將 Load function 分成下列幾個 sub-function
    HRESULT LoadBaseInfo(xmlNodePtr ShapeNode);
    HRESULT LoadImageInfo(xmlNodePtr ShapeNode, string LoadFilePath);
    HRESULT LoadShapeActionSettingsInfo(xmlNodePtr ShapeNode);
    HRESULT LoadTextRangeInfo(xmlNodePtr TextFrameNode);
    HRESULT LoadTextActionSettingsInfo(xmlNodePtr TextFrameNode);
    HRESULT LoadParagraphInfo(xmlNodePtr TextFrameNode);
    HRESULT LoadTextFrameInfo(xmlNodePtr ShapeNode);
    HRESULT LoadGroupShapesInfo(xmlNodePtr ShapeNode);
    HRESULT InitRenderInfo(void);
    // 判斷是否允許Video的啟動
    HRESULT DetermineActionSettingsEnabled(xmlNodePtr ShapeNode);
    // 取得多媒體資訊
    HRESULT LoadMediaInfo(xmlNodePtr ShapeNode);
    //===== 重設資訊相關 =====
    // 重設顯示資訊
    HRESULT RenderInfo_Reset(void);
    // 重設多媒體相關資訊
    HRESULT Media_Reset(void);
};

// 塗鴉演員，使用腳本系統來記錄塗鴉指令
class CDrawActor
{
public:
    // 塗鴉指令，使用腳本系統
    CScriptSystem m_Script;

    // 繪圖指令，給繪圖系統看的指令
    vector< vector<string> > m_Command;

    bool Enabled;

    // 在塗鴨演員裡的時間與塗鴉指令(腳本)的時間相同，而不是以0為開始時間
    // 此點與特效不同
    unsigned long PreTime;
    unsigned long Time;

    // LastIndex 用來判斷目前執行到第幾條塗鴉指令，在 EndDraw 時會用LastIndex資訊
    // 將剩下的塗鴉指令畫出
    unsigned int LastIndex;

    bool Recording;

    CDrawActor();
    ~CDrawActor();

    // 重置塗鴉演員的時間及相關事項
    void Reset(void);
    // 判斷此塗鴉演員是否有塗鴉指令的存在
    bool IsEmpty(void);
    // 更新供繪圖系統繪圖的指令
    void Refresh(string Type, unsigned long dTime);
    // 錄製時的開始與結束塗鴉
    void BeginRecordDraw(void);
    void EndRecordDraw(void);
    // 播放時的開始與結束塗鴉
    void BeginReplayDraw(void);
    void EndReplayDraw(void);
    // 比較第一條塗鴉指令，用於播放塗鴉時的判斷
    bool FirstScriptCompare(CScriptAction Action);
    // 取得塗鴉指令開始與結束的時間
    unsigned long GetFirstTime(void);
    unsigned long GetLastTime(void);

    // 送進塗鴉指令
    void Draw(CScriptAction Action);

    // 傳出目前塗鴉演員塗鴉的位置，以提供畫面移動滑鼠位置
    //void ( __closure * OnDrawActorPosition)(int X, int Y);
    void (*OnDrawActorPosition)(int X, int Y);

private:

};

//---------------------------------------------------------------------------
#endif


