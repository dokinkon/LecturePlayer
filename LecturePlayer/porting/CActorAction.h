//---------------------------------------------------------------------------

#ifndef CActorActionH
#define CActorActionH

#include "globals.h"
#include <math.h>
#include "MyXML.h"
#include "CTimer.h"
#include "CActor.h"

#define ACTORACTION_CREATEWARNING 100


typedef struct
{
    char pathType;
    vector<double> path;
} PathNode ;

typedef struct
{
	long index;
	double time;
	string value;
} ActorPoint;
typedef ActorPoint * ActorPointPtr;

class CBehavior
{
public:
    long m_Type;
    long m_Accumulate;
    long m_Additive;

    //ColorEffect
    string colorBy ;
    string colorFrom ;
    string colorTo ;
    int colorRGBBy[3] ;
    int colorRGBFrom[3] ;
    int colorRGBTo[3] ;


    //SetEffect
    long setProperty ;
    double setTo ;

    //PropertyEffect
    long proProperty ;
    std::vector<ActorPointPtr>m_Points;

    //MotionEffect
    string ByX;
    string ByY;
    string FromX;
    string FromY;
    string ToX;
    string ToY;
    string Path;

    //RotationEffect
    string rotateBy ;
    string rotateFrom ;
    string rotateTo ;

    //ScaleEffect
    string scaleByX;
    string scaleByY;
    string scaleFromX;
    string scaleFromY;
    string scaleToX;
    string scaleToY;

    //FilterEffect
    long filterType ;
    long filterSubType ;
    long filterReveal ;

    //Timing Information
    double duration;
    double accelerate ;
    double decelerate ;
    long repeatCount;
    // long triggerType;
    double triggerDelayTime;

    long cycle;
    long cycleTime;

    CBehavior();
    ~CBehavior();

    void GetBehaviors(xmlNodePtr BehaviorNode);

    MyXML m_xml;   //linx add;

private:
    void GetRGBvalue(string HexValue, int RGB[]);
};



//---------------------------------------------------------------------------
// 場景中的演員動畫類別
//---------------------------------------------------------------------------

class CActorAction
{
public:
    CActorAction( xmlNodePtr a_EffectNode , xmlNodePtr shapeNodeList , int s_Width , int s_Height );
    CActorAction(int s_Width, int s_Height, string shape);
    CActorAction();
    ~CActorAction() ;

    // shape information
    string shapeFile ;
    double shapeWidth, shapeHeight ;
    double shapeLeft, shapeTop  ;

    // point on path
    vector <double> Point_X , Point_Y ;

    void *Actor;

    //*************** Variable ***************
    // Effect attributes
    long Index;
    long Type;
    long m_Exit;
    long Triggertype;
    double Triggerdelaytime;
    long Repeatcount;
    long Direction;
    double Duration;
    string Shape;


    // Slide information
    int slideWidth, slideHeight ;

    // Effect informatiion 屬性的資料
    long m_AfterEffect;
    long m_AnimateBackground;
    long m_AnimateTextInReverse;
    long m_BuildByLevelEffect;
    long m_TextUnitEffect;

    // Path information
    vector<PathNode> v_Path ;
    int cycle;
    long cycleTime;

    bool Enabled;

    vector<CBehavior *> m_Behaviors;

    string Color2;
    int Color2RGB[3];

    int GetSlideWidth();
    int GetSlideHeight();

    // 依照傳入的時間差，更新擁有此特效演員的顯示狀態
    void RefreshActor(unsigned long dtime);


    // 取得此特效的觸發方式
    long GetTriggerType(void)
    {
        return Triggertype;
    }

    // 當此特效結束時，通知 SceneGraph 此特效已經結束。
    void (*OnFinish)(CActorAction *pActorAction);

    // 當此特效發生問題時，通知 SceneGraph 此特效發生問題。
    void (*OnError)(CActorAction *pActorAction);

    // 開始特效
    void Start(void);

    // 結束特效
    void End(void);

    // 重設特效，將時間設為 0 。
    void Reset(void);

    // 初始化狀態
    HRESULT InitState(void);

    // 重新初始化狀態
    void ReinitState(void);

    // 取得目前時間
    unsigned long GetTime(void);

    // 取得總共時間
    unsigned long GetTotalTime(void)
    {
        return TotalTime;
    }

    // 判斷是否為作用中的特效
    bool IsEnabled(void)
    {
        return Enabled;
    }

    void SetSceneTriggerTime(unsigned long SceneTriggerTime)
    {
        m_SceneTriggerTime = SceneTriggerTime;
    }

    unsigned long PreTime;

    unsigned long m_SceneTriggerTime;

    void HideActor(void);

    // 將原始位置塞入 Point_X 和 Point_Y，以提供路徑特效時的正確開始位置
    void InsertOriginalPosition(void);

    HRESULT CreateActorAction( xmlNodePtr ShapeNode,
                               int SlideWidth,
                               int SlideHeight,
                               long Paragraph=0, // 整個物體
                               long TriggleMode=1 );    // 按ㄧ下頁面

     MyXML m_xml;   //linx add;
private:


    // Shape information
    xmlNodePtr shapeList ;
    xmlNodePtr a_ShapeNode ;

    string m_DisplayName;

    long m_Paragraph;

    // 時間
    unsigned long Time;             // 目前動畫已經執行的時間
    unsigned long TotalTime;        // 動畫的總時間 = 延遲時間+動畫實際執行時間
    unsigned long DelayTime;        // 延遲時間
    unsigned long DurationTime;     // 動畫實際執行時間

    // 更新動畫狀態
    bool RefreshEffect(void);

    bool RefreshRenderInfo(void);


    //*************** Method ***************
    xmlNodePtr GetEffectShape(string shape) ;  // Get the shape which apply the effect
    void GetPathNode(string path);            // Get the point of a path
    void GetPathPoint();

    void GetBehaviors(xmlNodePtr xmlEffect);
    void GetRGBvalue(string HexValue, int RGB[]);

    // 取得特效資訊
    bool RefreshEffectFlashOnce();          // 閃爍一次
    bool RefreshEffectSpin();
    bool RefreshEffectSwivel();
    bool RefreshEffectTransparency();
    bool RefreshEffectChangeFillColor();
    bool RefreshEffectChangeLineColor();
    bool RefreshEffectDarken();
    bool RefreshEffectDesaturate();
    bool RefreshEffectFlashBulb();
    bool RefreshEffectFlicker();
    bool RefreshEffectLighten();
    bool RefreshEffectBlinds();
    bool RefreshEffectBox();
    bool RefreshEffectCheckerboard();
    bool RefreshEffectCircle();
    bool RefreshEffectDiamond();
    bool RefreshEffectPlus();
    bool RefreshEffectWedge();
    bool RefreshEffectSplit();
    bool RefreshEffectWipeIn(float TimePercentage);                         // 進入擦去
    bool RefreshEffectWipeOut(float TimePercentage);                        // 結束擦去
    bool RefreshEffectWipe(void);		                                    // 擦去
    bool RefreshEffectPath(void);                                           // 路徑
    bool RefreshEffectDrawCircle();
    bool RefreshEffectBrushOnColor();                                       // 筆刷色彩
    bool RefreshEffectBrushOnUnderline();                                   // 筆刷底線
    bool RefreshEffectStrips();
    bool RefreshEffectPinwheel();
    bool RefreshEffectZoomIn(float TimePercentage, float myTotalTime);      // 進入縮放
    bool RefreshEffectZoomOut(float TimePercentage, float myTotalTime);     // 結束縮放
    bool RefreshEffectZoom(void);			                                // 縮放
    bool RefreshEffectFadedZoom();
    bool RefreshEffectGrowAndTurn();
    bool RefreshEffectGrowShrink();
    bool RefreshEffectSpinner();                                            // 旋式誘餌
    bool RefreshEffectStretch();
    bool RefreshEffectAppear(void);                                         // 消失 出現
    bool RefreshEffectPeakIn(float TimePercentage);                         // 鑽入
    bool RefreshEffectPeakOut(float TimePercentage);                        // 鑽出
    bool RefreshEffectPeak(void);		                                    // 鑽出、鑽入
    bool RefreshEffectCenterRevolve();
    bool RefreshEffectSpiral();
    bool RefreshEffectArcUp();
    bool RefreshEffectVerticalGrow();
    bool RefreshEffectTeeter();
    bool RefreshEffectFold();
    bool RefreshEffectFly();
    bool RefreshEffectAscend();
    bool RefreshEffectGlide();
    bool RefreshEffectRiseUp();
    bool RefreshEffectFade(void);                                           // 淡出


    // 取得同ㄧ段落(Paragraph)的演員顯示資訊，使用時機為填入RenderInfo資料時。
    void GetParagraphRenderInfo(long Paragraph, vector<CActorRenderInfo> &ParagraphRenderInfo);

    void GetParagraphInfo(long Paragraph, vector<CActorRenderInfo> &ParagraphInfo);

    void DeleteParagraphRenderInfo(long Paragraph);

    // 判斷是否為支援的特效
    bool LegalAction(void);

    string GetPPTPointValue(CBehavior *Behavior,int PPTPointIndex)
    {
        ActorPointPtr PointPtr;
        PointPtr = (ActorPointPtr)Behavior->m_Points.at(PPTPointIndex);
        return PointPtr->value;
    }

    // 給PowerPoint 2000使用的Function
    // 用途為將PowerPoint 2000的特效載入使用


    // 出現
    HRESULT CreateEffectCut(xmlNodePtr AnimationSettingsNode);

    // 飛入
    HRESULT CreateEffectFlyFromBottom(xmlNodePtr AnimationSettingsNode);        // 自底
    HRESULT CreateEffectFlyFromLeft(xmlNodePtr AnimationSettingsNode);          // 自左
    HRESULT CreateEffectFlyFromRight(xmlNodePtr AnimationSettingsNode);         // 自右
    HRESULT CreateEffectFlyFromTop(xmlNodePtr AnimationSettingsNode);           // 自頂
    HRESULT CreateEffectFlyFromBottomLeft(xmlNodePtr AnimationSettingsNode);    // 自左下
    HRESULT CreateEffectFlyFromBottomRight(xmlNodePtr AnimationSettingsNode);   // 自右下
    HRESULT CreateEffectFlyFromTopLeft(xmlNodePtr AnimationSettingsNode);       // 自左上
    HRESULT CreateEffectFlyFromTopRight(xmlNodePtr AnimationSettingsNode);      // 自右上

    // 百葉窗
    HRESULT CreateEffectBlindsHorizontal(xmlNodePtr AnimationSettingsNode);     // 水平
    HRESULT CreateEffectBlindsVertical(xmlNodePtr AnimationSettingsNode);       // 垂直

    // 盒狀
    HRESULT CreateEffectBoxIn(xmlNodePtr AnimationSettingsNode);                // 收縮
    HRESULT CreateEffectBoxOut(xmlNodePtr AnimationSettingsNode);               // 放射

    // 棋盤式
    HRESULT CreateEffectCheckerboardAcross(xmlNodePtr AnimationSettingsNode);   // 橫向
    HRESULT CreateEffectCheckerboardDown(xmlNodePtr AnimationSettingsNode);     // 縱向

    // 慢速
    HRESULT CreateEffectCrawlFromDown(xmlNodePtr AnimationSettingsNode);        // 自下
    HRESULT CreateEffectCrawlFromLeft(xmlNodePtr AnimationSettingsNode);        // 自左
    HRESULT CreateEffectCrawlFromRight(xmlNodePtr AnimationSettingsNode);       // 自右
    HRESULT CreateEffectCrawlFromUp(xmlNodePtr AnimationSettingsNode);          // 自上

    // 溶解
    HRESULT CreateEffectDissolve(xmlNodePtr AnimationSettingsNode);

    // 閃爍一次
    HRESULT CreateEffectFlashOnceFast(xmlNodePtr AnimationSettingsNode);        // 快速
    HRESULT CreateEffectFlashOnceMedium(xmlNodePtr AnimationSettingsNode);      // 中速
    HRESULT CreateEffectFlashOnceSlow(xmlNodePtr AnimationSettingsNode);        // 慢速

    // 鑽入
    HRESULT CreateEffectPeekFromDown(xmlNodePtr AnimationSettingsNode);         // 自下
    HRESULT CreateEffectPeekFromLeft(xmlNodePtr AnimationSettingsNode);         // 自左
    HRESULT CreateEffectPeekFromRight(xmlNodePtr AnimationSettingsNode);        // 自右
    HRESULT CreateEffectPeekFromUp(xmlNodePtr AnimationSettingsNode);           // 自上

    // 隨機
    HRESULT CreateEffectRandomBarsHorizontal(xmlNodePtr AnimationSettingsNode); // 水平
    HRESULT CreateEffectRandomBarsVertical(xmlNodePtr AnimationSettingsNode);   // 垂直

    // 螺旋
    HRESULT CreateEffectSpiral(xmlNodePtr AnimationSettingsNode);

    // 向中夾縮
    HRESULT CreateEffectSplitHorizontalIn(xmlNodePtr AnimationSettingsNode);    // 水平
    HRESULT CreateEffectSplitVerticalIn(xmlNodePtr AnimationSettingsNode);      // 垂直

    // 向外擴張
    HRESULT CreateEffectSplitHorizontalOut(xmlNodePtr AnimationSettingsNode);   // 水平
    HRESULT CreateEffectSplitVerticalOut(xmlNodePtr AnimationSettingsNode);     // 垂直

    // 伸展
    HRESULT CreateEffectStretchAcross(xmlNodePtr AnimationSettingsNode);        // 水平
    HRESULT CreateEffectStretchDown(xmlNodePtr AnimationSettingsNode);          // 從下
    HRESULT CreateEffectStretchLeft(xmlNodePtr AnimationSettingsNode);          // 從左
    HRESULT CreateEffectStretchRight(xmlNodePtr AnimationSettingsNode);         // 從右
    HRESULT CreateEffectStretchUp(xmlNodePtr AnimationSettingsNode);            // 從上

    // 階梯狀
    HRESULT CreateEffectStripsLeftDown(xmlNodePtr AnimationSettingsNode);       // 左下
    HRESULT CreateEffectStripsLeftUp(xmlNodePtr AnimationSettingsNode);         // 左上
    HRESULT CreateEffectStripsRightDown(xmlNodePtr AnimationSettingsNode);      // 右下
    HRESULT CreateEffectStripsRightUp(xmlNodePtr AnimationSettingsNode);        // 右上

    // 旋轉
    HRESULT CreateEffectSwivel(xmlNodePtr AnimationSettingsNode);

    // 擦去
    HRESULT CreateEffectWipeDown(xmlNodePtr AnimationSettingsNode);             // 往下
    HRESULT CreateEffectWipeLeft(xmlNodePtr AnimationSettingsNode);             // 往左
    HRESULT CreateEffectWipeRight(xmlNodePtr AnimationSettingsNode);            // 往右
    HRESULT CreateEffectWipeUp(xmlNodePtr AnimationSettingsNode);               // 往上

    // 縮小
    HRESULT CreateEffectZoomIn(xmlNodePtr AnimationSettingsNode);               // 進入
    HRESULT CreateEffectZoomCenter(xmlNodePtr AnimationSettingsNode);           // 從螢幕中央
    HRESULT CreateEffectZoomInSlightly(xmlNodePtr AnimationSettingsNode);       // 略微縮小

    // 放大
    HRESULT CreateEffectZoomOut(xmlNodePtr AnimationSettingsNode);              // 推出
    HRESULT CreateEffectZoomBottom(xmlNodePtr AnimationSettingsNode);           // 從螢幕底端
    HRESULT CreateEffectZoomOutSlightly(xmlNodePtr AnimationSettingsNode);      // 略微放大

    // 產生 Behavior 及 ActorPoint
    CBehavior* CreateBehavior(long BType, long BAccumulate, long BAdditive);
    ActorPointPtr CreatePoint(long Index, string Value, double Time);
};

//---------------------------------------------------------------------------
#endif
