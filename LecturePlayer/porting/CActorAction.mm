//---------------------------------------------------------------------------
#include "CActorAction.h"
#include "PowerPoint_2003.h"
#include "ppteval.h"
#include "BWStringTool.h"

//---------------------------------------------------------------------------
CBehavior::CBehavior()
{
}
//---------------------------------------------------------------------------
CBehavior::~CBehavior()
{
    for ( unsigned int index=0 ; index<m_Points.size() ; index++ )
    {
        delete m_Points[index];
    }
    m_Points.clear();
}
//---------------------------------------------------------------------------
void CBehavior::GetBehaviors(xmlNodePtr BehaviorNode)
{
    if (  m_xml.HasAttribute(BehaviorNode,xmlCharStrdup("Type")) )
    {
        m_Type = atol((char*) m_xml.GetAttribute(BehaviorNode,xmlCharStrdup("Type")));
    }

    if (  m_xml.HasAttribute(BehaviorNode,xmlCharStrdup("Accumulate")) )
    {
        m_Accumulate = atol((char*) m_xml.GetAttribute(BehaviorNode,xmlCharStrdup("Accumulate")));
    }

    if (  m_xml.HasAttribute(BehaviorNode,xmlCharStrdup("Additive")) )
    {
        m_Additive = atol((char*) m_xml.GetAttribute(BehaviorNode,xmlCharStrdup("Additive")));
    }

    xmlNodePtr EffectNode;
    xmlNodePtr ColorFormatNode;
    xmlNodePtr PointsNode;
    xmlNodePtr PointNode;

    switch ( m_Type )
    {
        case 1 : // msoAnimTypeMotion

            EffectNode =  m_xml.FindChildNode(BehaviorNode,xmlCharStrdup("MotionEffect"));
            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("ByX")) )
                ByX = string((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("ByX")));
            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("ByY")) )
                ByY = string((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("ByY")));
            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("FromX")) )
                FromX = string((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("FromX")));
            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("FromY")) )
                FromY = string((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("FromY")));
            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("ToX")) )
                ToX = string((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("ToX")));
            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("ToY")) )
                ToY = string((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("ToY")));
            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("Path")) )
                Path = string((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("Path")));
            break;

        case 2 : // msoAnimTypeColor

            EffectNode =  m_xml.FindChildNode(BehaviorNode,xmlCharStrdup("ColorEffect"));

            // By
            ColorFormatNode =  m_xml.FindChildNode(EffectNode,xmlCharStrdup("By"));
            colorBy = string((char*) m_xml.GetAttribute(ColorFormatNode,xmlCharStrdup("rgb")));
            if ( colorBy.empty()==false )
                GetRGBvalue(colorBy, colorRGBBy);
            // From
            ColorFormatNode =  m_xml.FindChildNode(EffectNode,xmlCharStrdup("From"));
            colorFrom = string((char*) m_xml.GetAttribute(ColorFormatNode,xmlCharStrdup("rgb")));
            if ( colorFrom.empty()==false )
                GetRGBvalue(colorFrom, colorRGBBy);
            // To
            ColorFormatNode =  m_xml.FindChildNode(EffectNode,xmlCharStrdup("To"));
            colorTo = string((char*) m_xml.GetAttribute(ColorFormatNode,xmlCharStrdup("rgb")));
            if ( colorTo.empty()==false )
                GetRGBvalue(colorTo, colorRGBBy);
            break ;

        case 3 : // msoAnimTypeScale

            EffectNode =  m_xml.FindChildNode(BehaviorNode,xmlCharStrdup("ScaleEffect"));
            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("ByX")) )
                scaleByX = string((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("ByX")));
            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("ByY")) )
                scaleByY = string((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("ByY")));
            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("FromX")) )
                scaleFromX = string((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("FromX")));
            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("FromY")) )
                scaleFromY = string((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("FromY")));
            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("ToX")) )
                scaleToX = string((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("ToX")));
            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("ToY")) )
                scaleToY = string((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("ToY")));
            break;

        case 4 : // msoAnimTypeRotation
            EffectNode =  m_xml.FindChildNode(BehaviorNode,xmlCharStrdup("RotationEffect"));
            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("By")) )
                rotateBy = string((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("By")));
            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("From")) )
                rotateFrom = string((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("From")));
            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("To")) )
                rotateTo = string((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("To")));
            break;

        case 5 : // msoAnimTypeProperty

            EffectNode =  m_xml.FindChildNode(BehaviorNode,xmlCharStrdup("PropertyEffect"));

            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("Property")) )
            {
                proProperty = atol((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("Property")));
            }

            for ( unsigned int index=0 ; index<m_Points.size() ; index++ )
            {
                delete m_Points[index];
            }
            m_Points.clear();

            PointsNode =  m_xml.FindChildNode(EffectNode,xmlCharStrdup("Points"));
            if ( PointsNode!=NULL )
            {
                for ( int index=0 ; index< m_xml.CountChildNode(PointsNode) ; index++ )
                {
                    PointNode =  m_xml.FindChildIndex(PointsNode,index);
                    if ( PointNode!=NULL )
                    {
                        ActorPointPtr PointPtr = new ActorPoint;
                        PointPtr->index =  index+1;
                        PointPtr->value = string((char*) m_xml.GetAttribute(PointNode,xmlCharStrdup("Value")));
                        PointPtr->time = atof((char*) m_xml.GetAttribute(PointNode,xmlCharStrdup("Time")));
                        m_Points.push_back(PointPtr );
                    }
                }
            }

            break;

        case 6 : // msoAnimTypeCommand
            // 無
            break;
        case 7 : // msoAnimTypeFilter

            EffectNode =  m_xml.FindChildNode(BehaviorNode,xmlCharStrdup("FilterEffect"));

            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("Type")) )
                filterType = atol((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("Type")));

            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("Subtype")) )
                filterSubType = atol((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("Subtype")));

            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("Reveal")) )
                filterReveal = atol((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("Reveal")));
            break;

        case 8 : // msoAnimTypeSet

            EffectNode =  m_xml.FindChildNode(BehaviorNode,xmlCharStrdup("SetEffect"));

            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("Property")) )
                setProperty = atol((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("Property")));

            if (  m_xml.HasAttribute(EffectNode,xmlCharStrdup("To")) )
                setTo = atof((char*) m_xml.GetAttribute(EffectNode,xmlCharStrdup("To")));
            break;
    }

    xmlNodePtr TimingNode =  m_xml.FindChildNode(BehaviorNode,xmlCharStrdup("Timing"));

    if (  m_xml.HasAttribute(TimingNode,xmlCharStrdup("Duration")) )
        duration = atof((char*) m_xml.GetAttribute(TimingNode,xmlCharStrdup("Duration")));

    if (  m_xml.HasAttribute(TimingNode,xmlCharStrdup("Accelerate")) )
        accelerate = atof((char*) m_xml.GetAttribute(TimingNode,xmlCharStrdup("Accelerate")));

    if (  m_xml.HasAttribute(TimingNode,xmlCharStrdup("Decelerate")) )
        decelerate = atof((char*) m_xml.GetAttribute(TimingNode,xmlCharStrdup("Decelerate")));

    if (  m_xml.HasAttribute(TimingNode,xmlCharStrdup("RepeatCount")) )
        repeatCount = atol((char*) m_xml.GetAttribute(TimingNode,xmlCharStrdup("RepeatCount")));

    if (  m_xml.HasAttribute(TimingNode,xmlCharStrdup("TriggerDelayTime")) )
        triggerDelayTime = atof((char*) m_xml.GetAttribute(TimingNode,xmlCharStrdup("TriggerDelayTime")));


    //cycle = (long)((double)duration*1000/(double)cycleTime);
}

void CBehavior::GetRGBvalue(string HexValue, int RGB[])
{
    char *color = (char*)HexValue.c_str();
    for ( int k=0 ; k < 3; k++ )
    {
        int tmp , total = 0 ;

        if ( ( color[2*k] >= 'A' ) && ( color[2*k] <= 'F' ) )
            tmp = (color[2*k]-'A') + 10 ;
        else
            tmp = color[2*k]-'0' ;

        total = tmp * 16  ;

        if ( ( color[2*k+1] >= 'A' ) && ( color[2*k+1] <= 'F' ) )
            tmp = (color[2*k+1]-'A') + 10 ;
        else
            tmp = color[2*k+1]-'0' ;

        total = total + tmp ;
        RGB[k] = total ;
    }
}
//------------------------------------------------------------------------------------------------------------
CActorAction::CActorAction( xmlNodePtr a_EffectNode , xmlNodePtr shapeNodeList , int s_Width , int s_Height )
{
    cycleTime = 30;

    OnFinish = NULL;
    OnError = NULL;
    Type = msoAnimEffectFade;

    // 清空所有資料
    Point_X.clear();
    Point_Y.clear();
    v_Path.clear();
    for ( unsigned int index=0 ; index<m_Behaviors.size() ; index++ )
    {
        delete m_Behaviors[index];
    }
    m_Behaviors.clear();

    slideWidth = s_Width ;
    slideHeight = s_Height ;
    shapeList = shapeNodeList ;


    if (  m_xml.HasAttribute(a_EffectNode,xmlCharStrdup("Index")) )
        Index = atol((char*) m_xml.GetAttribute(a_EffectNode,xmlCharStrdup("Index")));

    if (  m_xml.HasAttribute(a_EffectNode,xmlCharStrdup("EffectType")) )
        Type = atol((char*) m_xml.GetAttribute(a_EffectNode,xmlCharStrdup("EffectType")));

    if (  m_xml.HasAttribute(a_EffectNode,xmlCharStrdup("Paragraph")) )
    {
        m_Paragraph = atol((char*) m_xml.GetAttribute(a_EffectNode,xmlCharStrdup("Paragraph")));
    }
    else
    {
        m_Paragraph = 0;
    }


    if (  m_xml.HasAttribute(a_EffectNode,xmlCharStrdup("Shape")) )
        Shape = string((char*) m_xml.GetAttribute(a_EffectNode,xmlCharStrdup("Shape")));

    if (  m_xml.HasAttribute(a_EffectNode,xmlCharStrdup("Exit")) )
        m_Exit = atol((char*) m_xml.GetAttribute(a_EffectNode,xmlCharStrdup("Exit")));

    if (  m_xml.HasAttribute(a_EffectNode,xmlCharStrdup("DisplayName")) )
        m_DisplayName = string((char*) m_xml.GetAttribute(a_EffectNode,xmlCharStrdup("DisplayName")));

    // Timing
    xmlNodePtr TimingNode =  m_xml.FindChildNode(a_EffectNode,xmlCharStrdup("Timing"));
    if ( TimingNode!=NULL )
    {
        if (  m_xml.HasAttribute(TimingNode,xmlCharStrdup("TriggerType")) )
            Triggertype = atol((char*) m_xml.GetAttribute(TimingNode,xmlCharStrdup("TriggerType")));
        if (  m_xml.HasAttribute(TimingNode,xmlCharStrdup("TriggerDelayTime")) )
            Triggerdelaytime = atof((char*) m_xml.GetAttribute(TimingNode,xmlCharStrdup("TriggerDelayTime")));
        if (  m_xml.HasAttribute(TimingNode,xmlCharStrdup("RepeatCount")) )
            Repeatcount = atol((char*) m_xml.GetAttribute(TimingNode,xmlCharStrdup("RepeatCount")));
        if (  m_xml.HasAttribute(TimingNode,xmlCharStrdup("Duration")) )
            Duration = atof((char*) m_xml.GetAttribute(TimingNode,xmlCharStrdup("Duration")));
    }

    // EffectParameters
    xmlNodePtr EffectParametersNode =  m_xml.FindChildNode(a_EffectNode,xmlCharStrdup("EffectParameters"));
    if ( EffectParametersNode!=NULL )
    {
        if (  m_xml.HasAttribute(EffectParametersNode,xmlCharStrdup("Direction")) )
            Direction = atol((char*) m_xml.GetAttribute(EffectParametersNode,xmlCharStrdup("Direction")));

        xmlNodePtr Color2Node =  m_xml.FindChildNode(EffectParametersNode,xmlCharStrdup("Color2"));
        if ( Color2Node!=NULL )
        {
            if (  m_xml.HasAttribute(Color2Node,xmlCharStrdup("rgb")) )
            {
                Color2 = string((char*) m_xml.GetAttribute(Color2Node,xmlCharStrdup("rgb")));
                GetRGBvalue(Color2, Color2RGB) ;
            }
        }
    }

    // Effect informatiion 屬性的資料
    xmlNodePtr EffectInformationNode =  m_xml.FindChildNode(a_EffectNode,xmlCharStrdup("EffectInformation"));

    if ( EffectInformationNode!=NULL )
    {
        if (  m_xml.HasAttribute(EffectInformationNode,xmlCharStrdup("AfterEffect")) )
            m_AfterEffect = atol((char*) m_xml.GetAttribute(EffectInformationNode,xmlCharStrdup("AfterEffect")));

        if (  m_xml.HasAttribute(EffectInformationNode,xmlCharStrdup("AnimateBackground")) )
            m_AnimateBackground = atol((char*) m_xml.GetAttribute(EffectInformationNode,xmlCharStrdup("AnimateBackground")));
        if (  m_xml.HasAttribute(EffectInformationNode,xmlCharStrdup("AnimateTextInReverse")) )
            m_AnimateTextInReverse = atol((char*) m_xml.GetAttribute(EffectInformationNode,xmlCharStrdup("AnimateTextInReverse")));
        if (  m_xml.HasAttribute(EffectInformationNode,xmlCharStrdup("BuildByLevelEffect")) )
            m_BuildByLevelEffect = atol((char*) m_xml.GetAttribute(EffectInformationNode,xmlCharStrdup("BuildByLevelEffect")));
        if (  m_xml.HasAttribute(EffectInformationNode,xmlCharStrdup("TextUnitEffect")) )
            m_TextUnitEffect = atol((char*) m_xml.GetAttribute(EffectInformationNode,xmlCharStrdup("TextUnitEffect")));

    }


    a_ShapeNode = GetEffectShape (Shape) ;
    shapeLeft = atof((char*) m_xml.GetAttribute(a_ShapeNode,xmlCharStrdup("Left")));
    shapeTop = atof((char*) m_xml.GetAttribute(a_ShapeNode,xmlCharStrdup("Top")));
    shapeWidth = atof((char*) m_xml.GetAttribute(a_ShapeNode,xmlCharStrdup("Width")));
    shapeHeight = atof((char*) m_xml.GetAttribute(a_ShapeNode,xmlCharStrdup("Height")));

    //shapeFile = (string)a_ShapeNode->m_xml.GetAttribute("image");

    // 特效的總時間
    DelayTime = (unsigned long)(Triggerdelaytime*100);

    if ( Duration*100<1 )
    {
        TotalTime = (unsigned long)(Triggerdelaytime*100+1);
        DurationTime = 1;
    }
    else
    {
        TotalTime = (unsigned long)((Duration+Triggerdelaytime)*100);
        DurationTime = (unsigned long)Duration*100;
    }

    if ( LegalAction() )
    {
        // 判斷是否為支援的特效
        GetBehaviors ( a_EffectNode ) ;
    }

    // 畫路徑相關
    string Path;
    for ( unsigned int index=0 ; index<m_Behaviors.size() ; index++ )
    {
        if ( m_Behaviors[index]->m_Type==msoAnimTypeMotion )
        {
            Path = m_Behaviors[index]->Path;
        }
    }

    if ( Path.empty() != true ) {
        GetPathNode( Path );
        GetPathPoint () ;
    }

    // 變色相關
    // ...

    // 縮放相關
    // ...

    // 變形相關
    // ...

    Enabled = false;
    Time = 0;
}


CActorAction::CActorAction(int s_Width, int s_Height, string shape)
{
    cycleTime = 30;

    OnFinish = NULL;
    OnError = NULL;
    Triggertype = 1;
    Type = msoAnimEffectFade;

    // 清空所以資料
    Point_X.clear();
    Point_Y.clear();

    v_Path.clear();


    slideWidth = s_Width;
    slideHeight = s_Height;
    Shape = shape;

    m_Exit = 0;

    m_DisplayName = string("載入錯誤的動畫");

    m_Paragraph = 0;

    DelayTime = 0;
    TotalTime = 100;

    Enabled = false;
    Time = 0;
}
CActorAction::CActorAction()
{
    cycleTime = 30;

    OnFinish = NULL;
    OnError = NULL;
    Type = msoAnimEffectFade;

    Point_X.clear();
    Point_Y.clear();
    v_Path.clear();
    for ( unsigned int index=0 ; index<m_Behaviors.size() ; index++ )
    {
        delete m_Behaviors[index];
    }
    m_Behaviors.clear();

    Enabled = false;
    Time = 0;
}

////////////////////////////////////////////////////////////////////////////////

CActorAction::~CActorAction()
{
    Point_X.clear();
    Point_Y.clear();


    v_Path.clear();

    for ( unsigned int index=0 ; index<m_Behaviors.size() ; index++ )
    {
        delete m_Behaviors[index];
    }
    m_Behaviors.clear();
}

////////////////////////////////////////////////////////////////////////////////

void CActorAction::GetPathNode( string path )
{
    v_Path.clear() ;
    PathNode a_path ;

    char seps[] = " ";
    char *SubString;

    SubString = strtok((char*)path.c_str(), seps);

    bool End=false;

    while( SubString!=NULL )
    {
        a_path.pathType = (*SubString);

        if ( a_path.pathType!='E' && a_path.pathType!='Z' )
        {
            // 一般有兩各參數
            SubString = strtok(NULL, seps);
            a_path.path.push_back(atof(SubString)) ;

            SubString = strtok(NULL, seps);
            a_path.path.push_back(atof(SubString)) ;

            if ( ( a_path.pathType == 'C' ) || ( a_path.pathType == 'c' ) )
            {
                // 如果 Type 為 'C' 或 'c' 則有 6 各參數，所以還需要取得四個參數
                SubString = strtok(NULL, seps);
                a_path.path.push_back(atof(SubString)) ;

                SubString = strtok(NULL, seps);
                a_path.path.push_back(atof(SubString)) ;

                SubString = strtok(NULL, seps);
                a_path.path.push_back(atof(SubString)) ;

                SubString = strtok(NULL, seps);
                a_path.path.push_back(atof(SubString)) ;
            }
        }
        else
        {
            End = true;
        }

        v_Path.push_back (a_path) ;
        a_path.path.clear() ;

        SubString = strtok(NULL, seps);
    };

    if ( End==false )
    {
        a_path.pathType = 'E';
        v_Path.push_back (a_path) ;
        a_path.path.clear() ;

    }

}

////////////////////////////////////////////////////////////////////////////////

xmlNodePtr CActorAction::GetEffectShape(string shapeName)
{
    xmlNodePtr theShape ;
    for ( int i = 0 ; i <  m_xml.CountNode(shapeList) ; i ++ )
    {
        theShape =  m_xml.FindIndex(shapeList,i) ;
        if (  m_xml.HasAttribute(theShape,xmlCharStrdup("Name")) )
        {
            if ( string((char*)( m_xml.GetAttribute(theShape,xmlCharStrdup("Name")))) == shapeName )
            {
                return theShape;
            }
        }
    }
    return NULL;   //linx add
}

////////////////////////////////////////////////////////////////////////////////

void CActorAction::GetPathPoint ()
{
    Point_X.clear();
    Point_Y.clear();

    bool moving = true ;
    //int n_path = 1 , index = 0 ;
    int n_path,index;
    char p_type  ;
    double p_x , p_y, p_cycle ;
    double g_x, g_y ;
    double start_X , start_Y , stop_X , stop_Y ;
    double shift_X , shift_Y , move_X , move_Y , slope ;

    n_path=1;
    index=0;
    p_x = v_Path[0].path[0] ;
    p_y = v_Path[0].path[1] ;
    if ( ( p_x == 0 ) && ( p_y == 0 ))  {
      g_x = shapeLeft ;
      g_y = shapeTop ;
    }
    else {
      g_x = slideWidth*p_x + shapeLeft ;
      g_y = slideHeight*p_y + shapeTop ;
    }
    Point_X.push_back ( g_x ) ;
    Point_Y.push_back ( g_y ) ;


    // ?? 會發生除以0
    double d_cycle = ((v_Path.size() -2) == 0) ? 0 : 30* Duration / (v_Path.size() -2) ;
    cycle = (int)floor(d_cycle+0.5) ;
    if ( cycle == 0 )
      cycle = 1 ;

    start_X = shapeLeft ;
    start_Y = shapeTop ;
    stop_X = g_x ;
    stop_Y = g_y ;

    while ( moving == true ) {
       p_type = v_Path[n_path].pathType ;
       p_cycle = cycle ;
       if ( ( p_type == 'C' ) || ( p_type == 'c' ) ) {
          p_cycle = (double)cycle/3 ;
          if ( p_cycle == 0 )
            p_cycle = 1 ;
       }

       if ( ( p_type == 'C' ) || ( p_type == 'L' ) || ( p_type == 'l' ) || ( p_type == 'c' )) {
          // 計算位移的長度
          p_x = v_Path[n_path].path[index] ;
          p_y = v_Path[n_path].path[index+1] ;
          if ( ( p_type == 'l' ) || ( p_type == 'c' ) ) {
             start_X = stop_X ;
             start_Y = stop_Y ;
          }
          shift_X = slideWidth*p_x + start_X - stop_X ;
          shift_Y = slideHeight*p_y + start_Y - stop_Y ;
          stop_X = slideWidth*p_x + start_X ;
          stop_Y = slideHeight*p_y + start_Y ;

          move_X = 0 , move_Y = 0 ;
          if ( fabs(shift_X) > fabs(shift_Y) ) {
             move_X = shift_X/p_cycle ;
             if ( ( n_path == 1 ) || ( n_path == (int)v_Path.size()-2) )
                 move_X = shift_X / (p_cycle + 5) ;
          }
          else {
             move_Y = shift_Y/p_cycle ;
             if ( ( n_path == 1 ) || ( n_path == (int)v_Path.size()-2 ) )
                move_Y = shift_Y / (p_cycle + 5) ;
          }
          if ( ( move_X == 0 ) && ( move_Y == 0 ) ) {
             Point_X.push_back ( g_x ) ;
             Point_Y.push_back ( g_y ) ;
             move_X = 0.5 ;
          }

          // 以X軸為位移標準
          if ( fabs( move_X ) > 0 ) {
             while ( fabs( stop_X - g_x ) >= fabs( move_X )  ) {
                g_x = g_x + move_X ;
                slope = (double)(move_X/shift_X) ;
                g_y = g_y + slope * shift_Y ;
                Point_X.push_back ( g_x ) ;
                Point_Y.push_back ( g_y ) ;
             }
             if ( g_x != stop_X ) {
                g_x = stop_X ;
                g_y = stop_Y ;
                Point_X.push_back ( g_x ) ;
                Point_Y.push_back ( g_y ) ;
             }
             stop_X = g_x ;
             stop_Y = g_y ;
             if ( index >= (int)v_Path[n_path].path.size()-2 ) {

                n_path++ ;
                index = 0 ;
                if ( n_path >= (int)v_Path.size()-1 )
                   moving = false;
             }
             else
                index = index + 2 ;
          }
          // 以Y軸為位移標準
          else if ( fabs ( move_Y ) > 0 ) {
              while ( fabs( stop_Y - g_y ) >= fabs( move_Y )  ) {
                g_y = g_y + move_Y ;
                slope = fabs((double)(move_Y/shift_Y)) ;
                g_x = g_x + slope * shift_X ;
                Point_X.push_back ( g_x ) ;
                Point_Y.push_back ( g_y ) ;
             }
             if ( g_y != stop_Y ) {
                g_x = stop_X ;
                g_y = stop_Y ;
                Point_X.push_back ( g_x ) ;
                Point_Y.push_back ( g_y ) ;
             }
             stop_X = g_x ;
             stop_Y = g_y ;
             if ( index >= (int)v_Path[n_path].path.size()-2 ) {
                n_path++ ;
                index = 0 ;
                if ( n_path >= (int)v_Path.size()-1 )
                   moving = false ;
             }
             else
                index = index + 2 ;
          }
       } // endif (p_type)
       else
          moving = false ;
    } // while


}

//---------------------------------------------------------------------------

void CActorAction::GetBehaviors(xmlNodePtr xmlEffect)
{
    // 清除資料
    for ( unsigned int index=0 ; index<m_Behaviors.size() ; index++ )
    {
        delete m_Behaviors[index];
    }
    m_Behaviors.clear();

    xmlNodePtr BehaviorsNode =  m_xml.FindChildNode(xmlEffect,xmlCharStrdup("Behaviors"));

    for ( int index=0 ; index< m_xml.CountChildNode(BehaviorsNode) ; index++ )
    {
        xmlNodePtr BehaviorNode =  m_xml.FindChildIndex(BehaviorsNode,index);

        CBehavior *pBehavior = new CBehavior();

        pBehavior->GetBehaviors(BehaviorNode);

        m_Behaviors.push_back (pBehavior) ;
    }
}

//---------------------------------------------------------------------------
// 取得 RGB 顏色值
void CActorAction::GetRGBvalue(string HexValue, int RGB[])
{
    char *color = (char*)HexValue.c_str();
    for ( int k=0 ; k < 3; k++ )
    {
        int tmp , total = 0 ;

        if ( ( color[2*k] >= 'A' ) && ( color[2*k] <= 'F' ) )
            tmp = (color[2*k]-'A') + 10 ;
        else
            tmp = color[2*k]-'0' ;

        total = tmp * 16  ;

        if ( ( color[2*k+1] >= 'A' ) && ( color[2*k+1] <= 'F' ) )
            tmp = (color[2*k+1]-'A') + 10 ;
        else
            tmp = color[2*k+1]-'0' ;

        total = total + tmp ;
        RGB[k] = total ;
    }
}

//---------------------------------------------------------------------------

void CActorAction::HideActor(void)
{
    // 取得對應顯示資訊
    vector<CActorRenderInfo> ParagraphRenderInfo;
    GetParagraphRenderInfo(m_Paragraph, ParagraphRenderInfo);
    DeleteParagraphRenderInfo(m_Paragraph);

    CActor *pActor = (CActor *)Actor;

    for ( unsigned int index=0 ; index<ParagraphRenderInfo.size() ; index++ )
    {
        ParagraphRenderInfo[index].Alpha = 0.0;
        pActor->m_ActorRenderInfo.push_back(ParagraphRenderInfo[index]);
    }

    ParagraphRenderInfo.clear();
}
//---------------------------------------------------------------------------

// 依照傳入的時間差，更新擁有此特效演員的顯示狀態
void CActorAction::RefreshActor(unsigned long dtime)
{
    //connie try
    //{
        CActor *pActor = (CActor *)Actor;

        if ( Enabled == false )
        {
            return;
        }

        PreTime = Time;
        Time = Time + dtime;

        //pActor->m_NeedRefresh = true;

        // 如果對應演員的特效還沒執行完畢，則更新演員顯示資訊。
        if ( Time>=DelayTime && Time<TotalTime )
        {
            bool success = RefreshEffect();

            if ( success==false )
            {
                pActor->m_IsActing = false;
                Enabled = false;

                if ( OnError!=NULL )
                    OnError(this);
            }
        }
        else if ( Time>=TotalTime )
        {
            Time = TotalTime;

            //msoAnimAfterEffectDim  1
            //msoAnimAfterEffectHide  2
            //msoAnimAfterEffectHideOnNextClick  3
            //msoAnimAfterEffectMixed  -1
            //msoAnimAfterEffectNone  0
            if ( m_AfterEffect==2 )
            {
                // 如果是播放動畫後隱藏，則讓演員消失
                HideActor();
            }
            else
            {
                // 其餘狀況
                RefreshEffect();
            }

            Enabled = false;
            pActor->m_IsActing = false;
            if ( OnFinish!=NULL )
                OnFinish(this);

        }
  //  }
 //   catch(...)
 //   {
        //int a=1;
  //  }
}

//---------------------------------------------------------------------------
// 更新動畫狀態
bool CActorAction::RefreshEffect(void)
{
    /************************************************************************************
    演員更新規則
                       演員已更新的特效種類              |        目前演員的特效種類
    ---------------------------------------------------------------------------------------
    RenderInfo->m_EnterAction | RenderInfo->m_ExitAction | 進入、路進特效 | 結束特效
    ---------------------------------------------------------------------------------------
               false          |           false          |     更新       |   更新
               false          |           true           |     不更新     |   不更新
               true           |           false          |     不更新     |   如果時間已經大於等於特效的總時間，則更新
               true           |           true           |     不更新     |   不更新
    ************************************************************************************/
    bool success = true;

    // 取得對應顯示資訊
    vector<CActorRenderInfo> ParagraphRenderInfo;
    GetParagraphRenderInfo(m_Paragraph, ParagraphRenderInfo);

    bool ActionFinish;

    if ( ParagraphRenderInfo.empty() )
    {
        ActionFinish = false;
    }
    else
    {
        ActionFinish = ParagraphRenderInfo[0].m_ActionFinish;
    }

    if ( ActionFinish==false )
    {
        // 更新顯示資訊
        success = RefreshRenderInfo();

        if ( success==true )
        {
            // 取得對應的顯示區塊
            ParagraphRenderInfo.clear();
            GetParagraphRenderInfo(m_Paragraph, ParagraphRenderInfo);

            // 作特效結束的相關處理
            if ( Time>=TotalTime )
            {

                if ( m_Exit==-1 )
                {
                    // 如果是結束特效，則設定 結束特效 完成和 特效 完成旗標為 true。
                    for ( unsigned int index=0 ; index<ParagraphRenderInfo.size() ; index++ )
                    {
                        ParagraphRenderInfo[index].m_ExitFinish = true;
                        ParagraphRenderInfo[index].m_ActionFinish = true;
                        ParagraphRenderInfo[index].m_LastUseExitAction = true;
                    }
                }
                else if ( m_Exit==0 )
                {
                    // 設定進入或路徑特效結束為 true。
                    for ( unsigned int index=0 ; index<ParagraphRenderInfo.size() ; index++ )
                    {
                        if ( ParagraphRenderInfo[index].m_PathAction==true )
                        {
                            ParagraphRenderInfo[index].m_PathFinish = true;
                        }
                        else
                        {
                            ParagraphRenderInfo[index].m_EnterFinish = true;
                        }
                    }
                }
            }

            CActor *pActor = (CActor *)Actor;

            DeleteParagraphRenderInfo(m_Paragraph);

            // 設定顯示區塊的特效種類並且塞回 Actor->m_ActorRenderInfo 裡
            for ( unsigned int index=0 ; index<ParagraphRenderInfo.size() ; index++ )
            {
                CActorRenderInfo tmp = ParagraphRenderInfo[index];
                if ( ParagraphRenderInfo[index].m_EnterAction==false && m_Exit==0 && Point_X.empty() )
                {
                    ParagraphRenderInfo[index].m_EnterAction = true;
                    ParagraphRenderInfo[index].m_LastUseExitAction = false;
                }

                if ( ParagraphRenderInfo[index].m_ExitAction==false && m_Exit==-1 && Point_X.empty() )
                {
                    ParagraphRenderInfo[index].m_ExitAction = true;
                }

                pActor->m_ActorRenderInfo.push_back(ParagraphRenderInfo[index]);
            }

            pActor->DetermineActionFinish();
        }
    }
    else
    {
        // 如果對應演員的特效已經執行完畢(別的結束特效已經先完成)，則將 Enabled 設成 false，
        // 停止此特效的更新。
        CActor *pActor = (CActor *)Actor;
        pActor->m_IsActing = false;
        Enabled = false;
    }

    return success;
}
//---------------------------------------------------------------------------
bool CActorAction::RefreshRenderInfo(void)
{
    bool success = true;

    // 取得對應顯示資訊
    vector<CActorRenderInfo> ParagraphRenderInfo;
    GetParagraphRenderInfo(m_Paragraph, ParagraphRenderInfo);

    // 如果找不到相同段落的顯示資訊，則代表此演員的顯示資訊是以整個演員為單位，並未被切成段落。
    if ( ParagraphRenderInfo.empty() )
    {
        // 將整個演員的顯示資訊清除，並且填入分段的顯示資訊
        CActor *pActor = (CActor *)Actor;

        pActor->m_ActorRenderInfo.clear();

        for ( unsigned int index=0 ; index<pActor->m_SubRenderInfo.size() ; index++ )
        {
            pActor->m_ActorRenderInfo.push_back(pActor->m_SubRenderInfo[index]);
        }
    }

    ParagraphRenderInfo.clear();
    GetParagraphRenderInfo(m_Paragraph, ParagraphRenderInfo);

    if ( ParagraphRenderInfo[0].m_LastUseExitAction==true && m_Exit==-1/*msoTrue*/ )
    {
        return true;
    }

    bool EnterAction = ParagraphRenderInfo[0].m_EnterAction;
    bool ExitAction = ParagraphRenderInfo[0].m_ExitAction;

    if ( ( EnterAction==false && ExitAction==false ) ||
         ( EnterAction==true && ExitAction==false && m_Exit==-1 && Time>=TotalTime ) ||
         ( !Point_X.empty() ) )
    {


        switch( Type )
        {
            case msoAnimEffectWipe: // 擦去
                RefreshEffectWipe() ? success=true : success=false ;
                break;

            case msoAnimEffectPeek: // 鑽入
                RefreshEffectPeak() ? success=true : success=false ;
                break;

            case msoAnimEffectZoom: // 縮放
                RefreshEffectZoom() ? success=true : success=false ;
                break;

            case msoAnimEffectFade: // 淡出
                RefreshEffectFade() ? success=true : success=false ;
                break;

            case msoAnimEffectBrushOnColor: // 筆刷色彩
                RefreshEffectBrushOnColor() ? success=true : success=false ;
                break;

            case msoAnimEffectBrushOnUnderline: // 筆刷底線
                RefreshEffectBrushOnUnderline() ? success=true : success=false ;
                break;

            //Add by han, 2005/ 10/ 25
            case msoAnimEffectSpinner:  // 旋式誘餌
                RefreshEffectSpinner() ? success=true : success=false ;
                break;

            case msoAnimEffectAppear:   // 出現 消失

                RefreshEffectAppear() ? success=true : success=false;
                break;

            case msoAnimEffectRiseUp:   // 上升

                RefreshEffectRiseUp() ? success=true : success=false;
                break;

            case msoAnimEffectFly:      // 飛入、飛出
            case msoAnimEffectCrawl:    // 慢速推入、慢速推出
            //case msoAnimEffectCredits:  // 字幕
            //case msoAnimEffectAscend:   // 進入下斜
            //case msoAnimEffectDescend:  // 結束下斜

                RefreshEffectFly() ? success=true : success=false;
                break;

            //case msoAnimEffectGlide:    // 下滑
            //    RefreshEffectGlide() ? success=true : success=false;
            //    break;

            case msoAnimEffectFlashOnce: //閃爍一次
                RefreshEffectFlashOnce() ? success=true :  success=false;
                break;

            case msoAnimEffectPathDiagonalUpRight: // 路徑-右斜
            case msoAnimEffectPathDiagonalDownRight: // 路徑-左斜
            case msoAnimEffectPathDown: // 路徑-向下
            case msoAnimEffectPathUp: // 路徑-向上
            case msoAnimEffectPathRight: // 路徑-向右
            case msoAnimEffectPathLeft: // 路徑-向左
            case msoAnimEffectPathPentagon: // 路徑-五邊形
            case msoAnimEffectPathHexagon:  // 路徑-六邊形
            case msoAnimEffectPathOctagon: // 路徑 - 八邊形
            case msoAnimEffectPath4PointStar: // 路徑-四點星形
            case msoAnimEffectPath5PointStar: // 路徑-五點星形
            case msoAnimEffectPath6PointStar: // 路徑-六點星形
            case msoAnimEffectPath8PointStar: // 路徑-八點星形
            case msoAnimEffectPathHeart:      // 路徑-心形
            case msoAnimEffectPathSquare: // 路徑-方形
            case msoAnimEffectPathTeardrop: // 路徑-水滴形
            case msoAnimEffectPathParallelogram : // 路徑-平行四邊形
            case msoAnimEffectPathEqualTriangle : // 路徑-正三角形
            case msoAnimEffectPathRightTriangle: // 路徑-直角三角形
            case msoAnimEffectPathTrapezoid: // 路徑-梯形
            case msoAnimEffectPathDiamond : // 路徑-菱形
            case msoAnimEffectPathCircle : // 路徑-圓形擴展
            case msoAnimEffectPathCrescentMoon: // 路徑-新月
            case msoAnimEffectPathFootball : // 路徑-橄欖球形
            case msoAnimEffectPathSCurve1: // 路徑-S形彎曲 1
            case msoAnimEffectPathSCurve2: // 路徑-S形彎曲 2
            case msoAnimEffectPathZigzag: // 路徑-Z字形
            case msoAnimEffectPathHeartbeat: // 路徑-心跳
            case msoAnimEffectPathTurnRight: // 路徑-右後轉彎
            case msoAnimEffectPathSineWave: // 路徑-正弦波
            case msoAnimEffectPathTurnDown: // 路徑-向下轉
            case msoAnimEffectPathTurnUp: // 路徑-向上轉
            case msoAnimEffectPathBounceRight: // 路徑-向右彈跳
            case msoAnimEffectPathCurvyRight: // 路徑-向右彎曲
            case msoAnimEffectPathBounceLeft : // 路徑-向左彈跳
            case msoAnimEffectPathCurvyLeft: // 路徑-向左彎曲
            case msoAnimEffectPathArcDown: // 路徑-弧形向下
            case msoAnimEffectPathArcUp: // 路徑-弧形向上
            case msoAnimEffectPathArcRight: // 路徑-弧形向右
            case msoAnimEffectPathArcLeft: // 路徑-弧形向左
            case msoAnimEffectPathWave: // 路徑-波浪1
            case msoAnimEffectPathDecayingWave: // 路徑-波浪2
            case msoAnimEffectPathFunnel : // 路徑-漏斗
            case msoAnimEffectPathSpring : // 路徑-彈簧
            case msoAnimEffectPathStairsDown: // 路徑-樓梯向下
            case msoAnimEffectPathSpiralRight : // 路徑-螺旋向右
            case msoAnimEffectPathSpiralLeft : // 路徑-螺旋向左
            case msoAnimEffectPathTurnUpRight : // 路徑-轉向右上
            case msoAnimEffectPathPlus : // 路徑-十字形擴展
            case msoAnimEffectPathHorizontalFigure8 : // 路徑-水平數字8
            case msoAnimEffectPathPointyStar : // 路徑-尖的星形
            case msoAnimEffectPathBean : // 路徑-豆莢
            case msoAnimEffectPathNeutron : // 路徑-物理中子
            case msoAnimEffectPathPeanut : // 路徑-花生狀
            case msoAnimEffectPathVerticalFigure8 : // 路徑-垂直數字8
            case msoAnimEffectPathInvertedTriangle : // 路徑-倒三角形
            case msoAnimEffectPathInvertedSquare : // 路徑-倒方形
            case msoAnimEffectPathFigure8Four : // 路徑-畫四個8
            case msoAnimEffectPathLoopdeLoop : // 路徑-漣漪
            case msoAnimEffectPathSwoosh : // 路徑-噴湧
            case msoAnimEffectPathBuzzsaw : // 路徑-鋸齒狀
            case msoAnimEffectPathCurvedX : // 路徑-彎曲的X
            case msoAnimEffectPathCurvedSquare : // 路徑-彎曲的方形
            case msoAnimEffectPathCurvyStar: // 路徑-彎曲的星形
            case msoAnimEffectCustom : // 路徑-繪製自訂路徑

                RefreshEffectPath() ? success=true : success=false ;
                break;

            default:    // 如果特效不支援，以淡出處理
                RefreshEffectFade() ? success=true : success=false ;
                break;

        }
    }
    else
    {
        success = false;
    }


    //pActor->m_HaveRefreshEffect = true;

    return success;
}

//---------------------------------------------------------------------------
// 閃爍一次
bool CActorAction::RefreshEffectFlashOnce()
{
    unsigned long time;
    (Time<DelayTime)?(time=0):(time=Time-DelayTime);
    //unsigned long delaytime = DelayTime;
    //unsigned long totaltime = TotalTime;

    float TimePercentage = (float)(time)/(float)(TotalTime-DelayTime);

    float Alpha;

    CActor *pActor = (CActor *)Actor;

    if ( m_Exit==msoFalse )
    {
        // 進入-閃爍一次
        if ( TimePercentage==0 )
        {
            Alpha = 0.0;
        }
        else if ( TimePercentage>0 && TimePercentage<1 )
        {
            Alpha = 1.0;
        }
        else if ( TimePercentage>=1 )
        {
            Alpha = 0.0;
        }

    }
    else if ( m_Exit==msoTrue )
    {
        // 結束-閃爍一次
        if ( TimePercentage==0 )
        {
            Alpha = 1.0;
        }
        else if ( TimePercentage>0 && TimePercentage<0.5 )
        {
            Alpha = 0.0;
        }
        else if ( TimePercentage>=0.5 && TimePercentage<1 )
        {
            Alpha = 1.0;
        }
        else if ( TimePercentage>=1.0 )
        {
            Alpha = 0.0;
        }
    }
    else
    {
        return false;
    }

    vector<CActorRenderInfo> RenderInfo;
    GetParagraphRenderInfo(m_Paragraph, RenderInfo);
    DeleteParagraphRenderInfo(m_Paragraph);

    RenderInfo[0].m_EffectType = Type;

    RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[0][0];
    RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[0][1];
    RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[1][0];
    RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[1][1];
    RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[2][0];
    RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[2][1];
    RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[3][0];
    RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[3][1];
    RenderInfo[0].TextureX = RenderInfo[0].OriTextureX;
    RenderInfo[0].TextureY = RenderInfo[0].OriTextureY;
    RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth;
    RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight;
    RenderInfo[0].Alpha = Alpha;

    pActor->m_ActorRenderInfo.push_back(RenderInfo[0]);

    RenderInfo.clear();

    return true;
}
// 進入擦去
bool CActorAction::RefreshEffectWipeIn(float TimePercentage)
{

    vector<CActorRenderInfo> RenderInfo;
    GetParagraphRenderInfo(m_Paragraph, RenderInfo);
    DeleteParagraphRenderInfo(m_Paragraph);

    CActor *pActor = (CActor *)Actor;
    RenderInfo[0].m_EffectType = Type;

    float width = RenderInfo[0].OriActor[1][0] - RenderInfo[0].OriActor[0][0];
    float height = RenderInfo[0].OriActor[3][1] - RenderInfo[0].OriActor[0][1];

    if ( Direction==3 )
    {
        //下
        RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[0][0];
        RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[3][1] - height * TimePercentage;
        RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[1][0];
        RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[2][1] - height * TimePercentage;
        RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[2][0];
        RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[2][1];
        RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[3][0];
        RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[3][1];
        RenderInfo[0].TextureX = RenderInfo[0].OriTextureX;
        RenderInfo[0].TextureY = RenderInfo[0].OriTextureY + (RenderInfo[0].OriTextureHeight * (1.0-TimePercentage));
        RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth;
        RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight * TimePercentage;
    }
    else if ( Direction==1 )
    {
        //上
        RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[0][0];
        RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[0][1];
        RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[1][0];
        RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[1][1];
        RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[2][0];
        RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[1][1] + height * TimePercentage;
        RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[3][0];
        RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[0][1] + height * TimePercentage;
        RenderInfo[0].TextureX = RenderInfo[0].OriTextureX;
        RenderInfo[0].TextureY = RenderInfo[0].OriTextureY;
        RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth;
        RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight * TimePercentage;
    }
    else if ( Direction==2 )
    {
        //右
        RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[1][0] - width * TimePercentage;
        RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[0][1];
        RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[1][0];
        RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[1][1];
        RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[2][0];
        RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[2][1];
        RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[2][0] - width * TimePercentage;
        RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[3][1];
        RenderInfo[0].TextureX = RenderInfo[0].OriTextureX + (RenderInfo[0].OriTextureWidth * (1.0-TimePercentage));
        RenderInfo[0].TextureY = RenderInfo[0].OriTextureY;
        RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth * TimePercentage;
        RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight;
    }
    else if ( Direction==4 )
    {
        //左
        RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[0][0];
        RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[0][1];
        RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[0][0] + width * TimePercentage;
        RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[1][1];
        RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[3][0] + width * TimePercentage;
        RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[2][1];
        RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[3][0];
        RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[3][1];
        RenderInfo[0].TextureX = RenderInfo[0].OriTextureX;
        RenderInfo[0].TextureY = RenderInfo[0].OriTextureY;
        RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth * TimePercentage;
        RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight;
    }

    pActor->m_ActorRenderInfo.push_back(RenderInfo[0]);

    return true;
}
//---------------------------------------------------------------------------
// 結束擦去
bool CActorAction::RefreshEffectWipeOut(float TimePercentage)
{
    vector<CActorRenderInfo> RenderInfo;
    GetParagraphRenderInfo(m_Paragraph, RenderInfo);
    DeleteParagraphRenderInfo(m_Paragraph);

    CActor *pActor = (CActor *)Actor;
    RenderInfo[0].m_EffectType = Type;

    float width = RenderInfo[0].OriActor[1][0] - RenderInfo[0].OriActor[0][0];
    float height = RenderInfo[0].OriActor[3][1] - RenderInfo[0].OriActor[0][1];

    if ( Direction==3 )
    {
        //下
        RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[0][0];
        RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[0][1];
        RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[1][0];
        RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[1][1];
        RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[2][0];
        RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[2][1] - height * TimePercentage;
        RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[3][0];
        RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[3][1] - height * TimePercentage;
        RenderInfo[0].TextureX = RenderInfo[0].OriTextureX;
        RenderInfo[0].TextureY = RenderInfo[0].OriTextureY;
        RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth;
        RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight * ( 1.0 - TimePercentage );
    }
    else if ( Direction==1 )
    {
        //上
        RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[0][0];
        RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[0][1] + height * TimePercentage;
        RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[1][0];
        RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[1][1] + height * TimePercentage;
        RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[2][0];
        RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[2][1];
        RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[3][0];
        RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[3][1];
        RenderInfo[0].TextureX = RenderInfo[0].OriTextureX;
        RenderInfo[0].TextureY = RenderInfo[0].OriTextureY + (RenderInfo[0].OriTextureWidth * TimePercentage);
        RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth;
        RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight * ( 1.0 - TimePercentage );
    }
    else if ( Direction==2 )
    {
        //右
        RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[0][0];
        RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[0][1];
        RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[1][0] - width * TimePercentage;
        RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[1][1];
        RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[2][0] - width * TimePercentage;
        RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[2][1];
        RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[3][0];
        RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[3][1];
        RenderInfo[0].TextureX = RenderInfo[0].OriTextureX;
        RenderInfo[0].TextureY = RenderInfo[0].OriTextureY;
        RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth * ( 1.0 - TimePercentage );
        RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight;
    }
    else if ( Direction==4 )
    {
        //左
        RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[0][0] + width * TimePercentage;
        RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[0][1];
        RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[1][0];
        RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[1][1];
        RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[2][0];
        RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[2][1];
        RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[3][0] + width * TimePercentage;
        RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[3][1];
        RenderInfo[0].TextureX = RenderInfo[0].OriTextureX + ( RenderInfo[0].OriTextureWidth * TimePercentage );
        RenderInfo[0].TextureY = RenderInfo[0].OriTextureY;
        RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth * ( 1.0 - TimePercentage );
        RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight;
    }

    pActor->m_ActorRenderInfo.push_back(RenderInfo[0]);

    return true;

}
//---------------------------------------------------------------------------
// 擦去
bool CActorAction::RefreshEffectWipe(void)
{
    unsigned long time;
    (Time<DelayTime)?(time=0):(time=Time-DelayTime);
    //unsigned long delaytime = DelayTime;
    //unsigned long totaltime = TotalTime;

    float TimePercentage = (float)(time)/(float)(TotalTime-DelayTime);

    if ( m_Exit==msoFalse )
    {
        if ( !RefreshEffectWipeIn(TimePercentage) )
            return false;

    }
    else if ( m_Exit==msoTrue )
    {

        if ( !RefreshEffectWipeOut(TimePercentage) )
            return false;

    }
    else
    {
        return false;
    }

    return true ;
}
//---------------------------------------------------------------------------
// 鑽入
bool CActorAction::RefreshEffectPeakIn(float TimePercentage)
{
    vector<CActorRenderInfo> RenderInfo;
    GetParagraphRenderInfo(m_Paragraph, RenderInfo);
    DeleteParagraphRenderInfo(m_Paragraph);

    CActor *pActor = (CActor *)Actor;
    RenderInfo[0].m_EffectType = Type;

    float width = RenderInfo[0].OriActor[1][0] - RenderInfo[0].OriActor[0][0];
    float height = RenderInfo[0].OriActor[3][1] - RenderInfo[0].OriActor[0][1];

    switch( m_Behaviors[1]->filterSubType )
    {
        case msoAnimFilterEffectSubtypeFromLeft:
            //左
            RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[0][0];
            RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[0][1];
            RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[0][0] + width * TimePercentage;
            RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[1][1];
            RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[0][0] + width * TimePercentage;
            RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[2][1];
            RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[3][0];
            RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[3][1];
            RenderInfo[0].TextureX = RenderInfo[0].OriTextureX + ( RenderInfo[0].OriTextureWidth * (1-TimePercentage) );
            RenderInfo[0].TextureY = RenderInfo[0].OriTextureY;
            RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth * TimePercentage;
            RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight;

            break;

        case msoAnimFilterEffectSubtypeFromRight:
            //右
            RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[1][0] - width *TimePercentage;
            RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[0][1];
            RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[1][0];
            RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[1][1];
            RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[2][0];
            RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[2][1];
            RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[2][0] - width * TimePercentage;
            RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[3][1];
            RenderInfo[0].TextureX = RenderInfo[0].OriTextureX;
            RenderInfo[0].TextureY = RenderInfo[0].OriTextureY;
            RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth * TimePercentage;
            RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight;

            break;

        case msoAnimFilterEffectSubtypeFromTop:
            // 上
            RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[0][0];
            RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[0][1];
            RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[1][0];
            RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[1][1];
            RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[2][0];
            RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[1][1] + height * TimePercentage;
            RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[3][0];
            RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[0][1] + height * TimePercentage;
            RenderInfo[0].TextureX = RenderInfo[0].OriTextureX;
            RenderInfo[0].TextureY = RenderInfo[0].OriTextureY + ( RenderInfo[0].OriTextureHeight * (1.0-TimePercentage) );
            RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth;
            RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight * TimePercentage;

            break;

        case msoAnimFilterEffectSubtypeFromBottom:
            // 下
            RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[0][0];
            RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[3][1] - height * TimePercentage;
            RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[1][0];
            RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[2][1] - height * TimePercentage;
            RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[2][0];
            RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[2][1];
            RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[3][0];
            RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[3][1];
            RenderInfo[0].TextureX = RenderInfo[0].OriTextureX;
            RenderInfo[0].TextureY = RenderInfo[0].OriTextureY;
            RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth;
            RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight * TimePercentage;

            break;
    }

    pActor->m_ActorRenderInfo.push_back(RenderInfo[0]);

    return true;
}
//---------------------------------------------------------------------------
// 鑽出
bool CActorAction::RefreshEffectPeakOut(float TimePercentage)
{
    vector<CActorRenderInfo> RenderInfo;
    GetParagraphRenderInfo(m_Paragraph, RenderInfo);
    DeleteParagraphRenderInfo(m_Paragraph);

    CActor *pActor = (CActor *)Actor;
    RenderInfo[0].m_EffectType = Type;

    float width = RenderInfo[0].OriActor[1][0] - RenderInfo[0].OriActor[0][0];
    float height = RenderInfo[0].OriActor[3][1] - RenderInfo[0].OriActor[0][1];

    switch( m_Behaviors[0]->filterSubType )
    {
        case msoAnimFilterEffectSubtypeFromLeft:
            //左
            RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[0][0];
            RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[0][1];
            RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[1][0] - width * TimePercentage;
            RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[1][1];
            RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[2][0] - width * TimePercentage;
            RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[2][1];
            RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[3][0];
            RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[3][1];
            RenderInfo[0].TextureX = RenderInfo[0].OriTextureX + ( RenderInfo[0].OriTextureWidth * TimePercentage );
            RenderInfo[0].TextureY = RenderInfo[0].OriTextureY;
            RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth * (1.0 - TimePercentage);
            RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight;

            break;

        case msoAnimFilterEffectSubtypeFromRight:
            //右
            RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[0][0] + width *TimePercentage;
            RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[0][1];
            RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[1][0];
            RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[1][1];
            RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[2][0];
            RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[2][1];
            RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[3][0] + width * TimePercentage;
            RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[3][1];
            RenderInfo[0].TextureX = RenderInfo[0].OriTextureX;
            RenderInfo[0].TextureY = RenderInfo[0].OriTextureY;
            RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth * (1.0 - TimePercentage);
            RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight;

            break;

        case msoAnimFilterEffectSubtypeFromTop:
            // 上
            RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[0][0];
            RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[0][1];
            RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[1][0];
            RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[1][1];
            RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[2][0];
            RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[2][1] - height * TimePercentage;
            RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[3][0];
            RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[3][1] - height * TimePercentage;
            RenderInfo[0].TextureX = RenderInfo[0].OriTextureX;
            RenderInfo[0].TextureY = RenderInfo[0].OriTextureY + ( RenderInfo[0].OriTextureHeight * TimePercentage);
            RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth;
            RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight * (1.0 - TimePercentage);

            break;

        case msoAnimFilterEffectSubtypeFromBottom:
            // 下
            RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[0][0];
            RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[0][1] + height * TimePercentage;
            RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[1][0];
            RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[1][1] + height * TimePercentage;
            RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[2][0];
            RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[2][1];
            RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[3][0];
            RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[3][1];
            RenderInfo[0].TextureX = RenderInfo[0].OriTextureX;
            RenderInfo[0].TextureY = RenderInfo[0].OriTextureY;
            RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth;
            RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight * (1.0 - TimePercentage);

            break;
    }

    pActor->m_ActorRenderInfo.push_back(RenderInfo[0]);

    return true;
}
//---------------------------------------------------------------------------
// 鑽入 鑽出
bool CActorAction::RefreshEffectPeak(void)
{
    unsigned long time;
    (Time<DelayTime)?(time=0):(time=Time-DelayTime);
    //unsigned long delaytime = DelayTime;
    //unsigned long totaltime = TotalTime;

    float TimePercentage = (float)(time)/(float)(TotalTime-DelayTime);

    if ( m_Behaviors.empty() )
        return false;

    if ( m_Exit==msoFalse )
    {
        if ( !RefreshEffectPeakIn(TimePercentage) )
            return false;

    }
    else if ( m_Exit==msoTrue )
    {

        if ( !RefreshEffectPeakOut(TimePercentage) )
            return false;

    }
    else
    {
        return false;
    }

    return true;
}
//---------------------------------------------------------------------------
// 進入縮放
bool CActorAction::RefreshEffectZoomIn(float TimePercentage, float myTotalTime)
{
    CActor *pActor = (CActor *)Actor;

    float ActorX, ActorY, ActorWidth, ActorHeight;

    vector<CActorRenderInfo> RenderInfo;
    GetParagraphRenderInfo(m_Paragraph, RenderInfo);

    float X = pActor->m_X + RenderInfo[0].OriActor[0][0];
    float Y = pActor->m_Y + RenderInfo[0].OriActor[0][1];
    float Width = RenderInfo[0].OriActor[1][0] - RenderInfo[0].OriActor[0][0];
    float Height = RenderInfo[0].OriActor[3][1] - RenderInfo[0].OriActor[0][1];


    if ( Direction==19 )
    {
        //內

        //抓取圖型起始的大小
        float ini_w = atof(GetPPTPointValue(m_Behaviors.at(1), 0).c_str());
        float ini_h = atof(GetPPTPointValue(m_Behaviors.at(2), 0).c_str());

        string temp_fin_w = GetPPTPointValue(m_Behaviors.at(1), 1);
        string temp_fin_h = GetPPTPointValue(m_Behaviors.at(2), 1);
        //計算圖形變化後的大小
        //PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, pActor->m_X, pActor->m_Y, pActor->m_Width, pActor->m_Height);
        PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, (int)X, (int)Y, (int)Width, (int)Height);

        float fin_w = (float)calPoint->eval(temp_fin_w) * slideWidth;
        float fin_h = (float)calPoint->eval(temp_fin_h) * slideHeight;

        delete calPoint;
        //每次的變化量
        //float dx = (float)( pActor->m_Width / 2.0 ) / (float)myTotalTime;
        //float dy = (float)( pActor->m_Height / 2.0 ) / (float)myTotalTime;
        float dx = (float)( Width / 2.0 ) / (float)myTotalTime;
        float dy = (float)( Height / 2.0 ) / (float)myTotalTime;
        float dw = (float)( fin_w - ini_w ) / (float)myTotalTime;
        float dh = (float)( fin_h - ini_h ) / (float)myTotalTime;

        //ActorX = ( pActor->m_X + pActor->m_Width / 2.0 ) - dx * Time;
        //ActorY = ( pActor->m_Y + pActor->m_Height / 2.0 ) - dy * Time;
        ActorX = ( X + Width / 2.0 ) - dx * Time;
        ActorY = ( Y + Height / 2.0 ) - dy * Time;
        ActorWidth = ini_w + dw * Time;
        ActorHeight = ini_h + dh * Time;
    }
    else if ( Direction==30 )
    {
        //從螢幕中央向內

        //計算圖形變化後的大小
        //PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, pActor->m_X, pActor->m_Y, pActor->m_Width, pActor->m_Height);
        PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight,(int) X,(int) Y, (int)Width, (int)Height);

        //抓取圖形起始的位置
        string temp_ini_x = GetPPTPointValue(m_Behaviors.at(3), 0);
        string temp_ini_y = GetPPTPointValue(m_Behaviors.at(4), 0);

        float ini_x = (float)calPoint->eval(temp_ini_x) * slideWidth;
        float ini_y = (float)calPoint->eval(temp_ini_y) * slideHeight;

        //抓取圖型起始的大小
        string temp_int_w = GetPPTPointValue(m_Behaviors.at(1), 0);
        string temp_int_h = GetPPTPointValue(m_Behaviors.at(2), 0);

        float ini_w = (float)calPoint->eval(temp_int_w) * slideWidth;
        float ini_h = (float)calPoint->eval(temp_int_h) * slideHeight;

        //抓取圖形起始的位置
        string temp_fin_x = GetPPTPointValue(m_Behaviors.at(3), 1);
        string temp_fin_y = GetPPTPointValue(m_Behaviors.at(4), 1);

        float fin_x = (float)calPoint->eval(temp_fin_x);
        float fin_y = (float)calPoint->eval(temp_fin_y);

        //抓取圖形變化後的大小
        string temp_fin_w = GetPPTPointValue(m_Behaviors.at(1), 1);
        string temp_fin_h = GetPPTPointValue(m_Behaviors.at(2), 1);

        float fin_w = (float)calPoint->eval(temp_fin_w) * slideWidth;
        float fin_h = (float)calPoint->eval(temp_fin_h) * slideHeight;

        delete calPoint;

        //每次的變化量
        float dx = (float)( fin_x - ini_x ) / (float)myTotalTime;
        float dy = (float)( fin_y - ini_y ) / (float)myTotalTime;
        float dw = (float)( fin_w - ini_w ) / (float)myTotalTime;
        float dh = (float)( fin_h - ini_h ) / (float)myTotalTime;

        ActorWidth = ini_w + dw * Time;
        ActorHeight = ini_h + dh * Time;

        ActorX = (float)ini_x + dx * Time;// - dw * Time / 2.0;
        ActorY = (float)ini_y + dy * Time;// - dh * Time / 2.0;

    }
    else if ( Direction==29 )
    {
        //略為向內

        //計算圖形變化後的大小
        //PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, pActor->m_X, pActor->m_Y, pActor->m_Width, pActor->m_Height);
        PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, (int)X, (int)Y, (int)Width, (int)Height);

        //抓取圖型起始的大小
        string temp_int_w = GetPPTPointValue(m_Behaviors.at(1), 0);
        string temp_int_h = GetPPTPointValue(m_Behaviors.at(2), 0);

        float ini_w = (float)calPoint->eval(temp_int_w) * slideWidth;
        float ini_h = (float)calPoint->eval(temp_int_h) * slideHeight;

        string temp_fin_w = GetPPTPointValue(m_Behaviors.at(1), 1);
        string temp_fin_h = GetPPTPointValue(m_Behaviors.at(2), 1);

        float fin_w = (float)calPoint->eval(temp_fin_w) * slideWidth;
        float fin_h = (float)calPoint->eval(temp_fin_h) * slideHeight;

        delete calPoint;

        //每次的變化量
        float dw = (float)( fin_w - ini_w ) / (float)myTotalTime;
        float dh = (float)( fin_h - ini_h ) / (float)myTotalTime;

        //ActorX = ( pActor->m_X + (float)( fin_w - ini_w ) / 2.0 ) - (float)(dw/2) * Time;
        //ActorY = ( pActor->m_Y + (float)( fin_h - ini_h ) / 2.0 ) - (float)(dh/2) * Time;
        ActorX = ( X + (float)( fin_w - ini_w ) / 2.0 ) - (float)(dw/2) * Time;
        ActorY = ( Y + (float)( fin_h - ini_h ) / 2.0 ) - (float)(dh/2) * Time;
        ActorWidth = ini_w + dw * Time;
        ActorHeight = ini_h + dh * Time;

    }
    else if ( Direction==20  )
    {
        //外

        //計算圖形變化後的大小
        //PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, pActor->m_X, pActor->m_Y, pActor->m_Width, pActor->m_Height);
        PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, (int)X, (int)Y, (int)Width, (int)Height);

        //抓取圖型起始的大小
        string temp_int_w = GetPPTPointValue(m_Behaviors.at(1), 0);
        string temp_int_h = GetPPTPointValue(m_Behaviors.at(2), 0);

        float ini_w = (float)calPoint->eval(temp_int_w) * slideWidth;
        float ini_h = (float)calPoint->eval(temp_int_h) * slideHeight;

        string temp_fin_w = GetPPTPointValue(m_Behaviors.at(1), 1);
        string temp_fin_h = GetPPTPointValue(m_Behaviors.at(2), 1);

        float fin_w = (float)calPoint->eval(temp_fin_w) * slideWidth;
        float fin_h = (float)calPoint->eval(temp_fin_h) * slideHeight;

        delete calPoint;

        //每次的變化量
        float dw = (float)( fin_w - ini_w ) / (float)myTotalTime;
        float dh = (float)( fin_h - ini_h ) / (float)myTotalTime;

        //原始的位置 = 物件位置 + ( 原來大小 - 放大後的大小 ) / 2
        //ActorX = pActor->m_X + ( pActor->m_Width - ( ini_w + dw * Time ) ) /2;
        //ActorY = pActor->m_Y + ( pActor->m_Height - ( ini_h + dh * Time ) ) /2;
        ActorX = X + ( Width - ( ini_w + dw * Time ) ) /2;
        ActorY = Y + ( Height - ( ini_h + dh * Time ) ) /2;
        ActorWidth = ini_w + dw * Time;
        ActorHeight = ini_h + dh * Time;

    }else if( Direction==34 ){
        //從螢幕下方向外

        //計算圖形變化後的大小
        //PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, pActor->m_X, pActor->m_Y, pActor->m_Width, pActor->m_Height);
        PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, (int)X, (int)Y, (int)Width, (int)Height);

        //抓取圖形起始的位置
        string temp_ini_x = GetPPTPointValue(m_Behaviors.at(3), 0);
        string temp_ini_y = GetPPTPointValue(m_Behaviors.at(4), 0);

        float ini_x = (float)calPoint->eval(temp_ini_x) * slideWidth;
        float ini_y = (float)calPoint->eval(temp_ini_y) * slideHeight;
        if(ini_y > slideHeight ){
                ini_y = slideHeight;
        }

        //抓取圖型起始的大小
        string temp_int_w = GetPPTPointValue(m_Behaviors.at(1), 0);
        string temp_int_h = GetPPTPointValue(m_Behaviors.at(2), 0);

        float ini_w = (float)calPoint->eval(temp_int_w) * slideWidth;
        float ini_h = (float)calPoint->eval(temp_int_h) * slideHeight;

        //抓取圖形起始的位置
        string temp_fin_x = GetPPTPointValue(m_Behaviors.at(3), 1);
        string temp_fin_y = GetPPTPointValue(m_Behaviors.at(4), 1);

        float fin_x = (float)calPoint->eval(temp_fin_x);
        float fin_y = (float)calPoint->eval(temp_fin_y);

        //抓取圖形變化後的大小
        string temp_fin_w = GetPPTPointValue(m_Behaviors.at(1), 1);
        string temp_fin_h = GetPPTPointValue(m_Behaviors.at(2), 1);

        float fin_w = (float)calPoint->eval(temp_fin_w) * slideWidth;
        float fin_h = (float)calPoint->eval(temp_fin_h) * slideHeight;

        delete calPoint;

        //每次的變化量
        float dx = (float)( fin_x - ini_x ) / (float)myTotalTime;
        float dy = (float)( fin_y - ini_y ) / (float)myTotalTime;
        float dw = (float)( fin_w - ini_w ) / (float)myTotalTime;
        float dh = (float)( fin_h - ini_h ) / (float)myTotalTime;

        ActorX = (float)ini_x + dx * Time;
        ActorY = (float)ini_y + dy * Time;
        ActorWidth = ini_w + dw * Time;
        ActorHeight = ini_h + dh * Time;

    }else if( Direction==32 ){
        //略為向外

        //計算圖形變化後的大小
        //PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, pActor->m_X, pActor->m_Y, pActor->m_Width, pActor->m_Height);
        PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, (int)X, (int)Y, (int)Width, (int)Height);

        //抓取圖型起始的大小
        string temp_int_w = GetPPTPointValue(m_Behaviors.at(1), 0);
        string temp_int_h = GetPPTPointValue(m_Behaviors.at(2), 0);

        float ini_w = (float)calPoint->eval(temp_int_w) * slideWidth;
        float ini_h = (float)calPoint->eval(temp_int_h) * slideHeight;

        string temp_fin_w = GetPPTPointValue(m_Behaviors.at(1), 1);
        string temp_fin_h = GetPPTPointValue(m_Behaviors.at(2), 1);

        float fin_w = (float)calPoint->eval(temp_fin_w) * slideWidth;
        float fin_h = (float)calPoint->eval(temp_fin_h) * slideHeight;

        delete calPoint;

        //每次的變化量
        float dw = (float)( fin_w - ini_w ) / (float)myTotalTime;
        float dh = (float)( fin_h - ini_h ) / (float)myTotalTime;

        //ActorX = ( pActor->m_X + (float)( fin_w - ini_w ) / 2.0 ) - (float)(dw/2) * Time;
        //ActorY = ( pActor->m_Y + (float)( fin_h - ini_h ) / 2.0 ) - (float)(dh/2) * Time;
        ActorX = ( X + (float)( fin_w - ini_w ) / 2.0 ) - (float)(dw/2) * Time;
        ActorY = ( Y + (float)( fin_h - ini_h ) / 2.0 ) - (float)(dh/2) * Time;
        ActorWidth = ini_w + dw * Time;
        ActorHeight = ini_h + dh * Time;
    }


    RenderInfo.clear();
    GetParagraphRenderInfo(m_Paragraph, RenderInfo);
    DeleteParagraphRenderInfo(m_Paragraph);

    RenderInfo[0].m_EffectType = Type;

    RenderInfo[0].Actor[0][0] = ActorX - pActor->m_X;
    RenderInfo[0].Actor[0][1] = ActorY - pActor->m_Y;
    RenderInfo[0].Actor[1][0] = ( ActorX + ActorWidth ) - pActor->m_X;
    RenderInfo[0].Actor[1][1] = ActorY - pActor->m_Y;
    RenderInfo[0].Actor[2][0] = ( ActorX + ActorWidth ) - pActor->m_X;
    RenderInfo[0].Actor[2][1] = ( ActorY + ActorHeight ) - pActor->m_Y;
    RenderInfo[0].Actor[3][0] = ActorX - pActor->m_X;
    RenderInfo[0].Actor[3][1] = ( ActorY + ActorHeight ) - pActor->m_Y;

    RenderInfo[0].TextureX = RenderInfo[0].OriTextureX;
    RenderInfo[0].TextureY = RenderInfo[0].OriTextureY;
    RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth;
    RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight;
    RenderInfo[0].Rotation = 0.0;
    RenderInfo[0].Red = 1.0;
    RenderInfo[0].Green = 1.0;
    RenderInfo[0].Blue = 1.0;

    if( Time == 0 )
    {
        RenderInfo[0].Alpha = 0.0;
    }
    else if( Time>0 )
    {
        RenderInfo[0].Alpha = 1.0;
    }

    pActor->m_ActorRenderInfo.push_back(RenderInfo[0]);

    return true;
}
//---------------------------------------------------------------------------
// 結束縮放
bool CActorAction::RefreshEffectZoomOut(float TimePercentage, float myTotalTime)
{
    CActor *pActor = (CActor *)Actor;

    float ActorX, ActorY, ActorWidth, ActorHeight;

    vector<CActorRenderInfo> RenderInfo;
    GetParagraphRenderInfo(m_Paragraph, RenderInfo);

    float X = pActor->m_X + RenderInfo[0].OriActor[0][0];
    float Y = pActor->m_Y + RenderInfo[0].OriActor[0][1];
    float Width = RenderInfo[0].OriActor[1][0] - RenderInfo[0].OriActor[0][0];
    float Height = RenderInfo[0].OriActor[3][1] - RenderInfo[0].OriActor[0][1];

    if ( Direction==20  )
    {
        //外(退場)

        //計算圖形變化後的大小
        //PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, pActor->m_X, pActor->m_Y, pActor->m_Width, pActor->m_Height);
        PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, (int)X, (int)Y, (int)Width, (int)Height);
        //抓取圖型起始的大小
        string temp_int_w = GetPPTPointValue(m_Behaviors.at(0), 0);
        string temp_int_h = GetPPTPointValue(m_Behaviors.at(1), 0);

        float ini_w = (float)calPoint->eval(temp_int_w) * slideWidth;
        float ini_h = (float)calPoint->eval(temp_int_h) * slideHeight;
        //float ini_h = GetPPTPointValue(m_Behaviors.at(1), 0).ToDouble();

        string temp_fin_w = GetPPTPointValue(m_Behaviors.at(0), 1);
        string temp_fin_h = GetPPTPointValue(m_Behaviors.at(1), 1);

        float fin_w = (float)calPoint->eval(temp_fin_w) * slideWidth;
        float fin_h = (float)calPoint->eval(temp_fin_h) * slideHeight;

        delete calPoint;

        //每次的變化量
        float dw = (float)( fin_w - ini_w ) / (float)myTotalTime;
        float dh = (float)( fin_h - ini_h ) / (float)myTotalTime;

        //原始的位置 = 物件位置 + ( 原來大小 - 放大後的大小 ) / 2
        //ActorX = pActor->m_X + ( pActor->m_Width - ( ini_w + dw * Time ) ) /2;
        //ActorY = pActor->m_Y + ( pActor->m_Height - ( ini_h + dh * Time ) ) /2;
        ActorX = X + ( Width - ( ini_w + dw * Time ) ) /2;
        ActorY = Y + ( Height - ( ini_h + dh * Time ) ) /2;
        ActorWidth = ini_w + dw * Time;
        ActorHeight = ini_h + dh * Time;

    }else if ( Direction==33 )
    {
        //向外至螢幕中央

        //計算圖形變化後的大小
        //PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, pActor->m_X, pActor->m_Y, pActor->m_Width, pActor->m_Height);
        PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, (int)X, (int)Y, (int)Width, (int)Height);

        //抓取圖形起始的位置
        string temp_ini_x = GetPPTPointValue(m_Behaviors.at(2), 0);
        string temp_ini_y = GetPPTPointValue(m_Behaviors.at(3), 0);

        float ini_x = (float)calPoint->eval(temp_ini_x) ;
        float ini_y = (float)calPoint->eval(temp_ini_y) ;

        //抓取圖型起始的大小
        string temp_int_w = GetPPTPointValue(m_Behaviors.at(0), 0);
        string temp_int_h = GetPPTPointValue(m_Behaviors.at(1), 0);

        float ini_w = (float)calPoint->eval(temp_int_w) * slideWidth;
        float ini_h = (float)calPoint->eval(temp_int_h) * slideHeight;

        //抓取圖形起始的位置
        string temp_fin_x = GetPPTPointValue(m_Behaviors.at(2), 1);
        string temp_fin_y = GetPPTPointValue(m_Behaviors.at(3), 1);

        float fin_x = (float)calPoint->eval(temp_fin_x) * slideWidth;
        float fin_y = (float)calPoint->eval(temp_fin_y) * slideHeight;

        //抓取圖形變化後的大小
        string temp_fin_w = GetPPTPointValue(m_Behaviors.at(0), 1);
        string temp_fin_h = GetPPTPointValue(m_Behaviors.at(1), 1);

        float fin_w = (float)calPoint->eval(temp_fin_w) * slideWidth;
        float fin_h = (float)calPoint->eval(temp_fin_h) * slideHeight;

        delete calPoint;

        //每次的變化量
        float dx = (float)( fin_x - ini_x ) / (float)myTotalTime;
        float dy = (float)( fin_y - ini_y ) / (float)myTotalTime;
        float dw = (float)( fin_w - ini_w ) / (float)myTotalTime;
        float dh = (float)( fin_h - ini_h ) / (float)myTotalTime;

        ActorWidth = ini_w + dw * Time;
        ActorHeight = ini_h + dh * Time;

        ActorX = (float)ini_x + dx * Time;// - dw * Time / 2.0;
        ActorY = (float)ini_y + dy * Time;// - dh * Time / 2.0;
    }
    else if( Direction==32 ){
        //略為向外

        //計算圖形變化後的大小
        //PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, pActor->m_X, pActor->m_Y, pActor->m_Width, pActor->m_Height);
        PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, (int)X, (int)Y, (int)Width, (int)Height);
        //抓取圖型起始的大小
        string temp_int_w = GetPPTPointValue(m_Behaviors.at(0), 0);
        string temp_int_h = GetPPTPointValue(m_Behaviors.at(1), 0);

        float ini_w = (float)calPoint->eval(temp_int_w) * slideWidth;
        float ini_h = (float)calPoint->eval(temp_int_h) * slideHeight;

        string temp_fin_w = GetPPTPointValue(m_Behaviors.at(0), 1);
        string temp_fin_h = GetPPTPointValue(m_Behaviors.at(1), 1);

        float fin_w = (float)calPoint->eval(temp_fin_w) * slideWidth;
        float fin_h = (float)calPoint->eval(temp_fin_h) * slideHeight;

        delete calPoint;

        //每次的變化量
        float dw = (float)( fin_w - ini_w ) / (float)myTotalTime;
        float dh = (float)( fin_h - ini_h ) / (float)myTotalTime;

        //ActorX = pActor->m_X - (float)(dw/2) * Time;
        //ActorY = pActor->m_Y - (float)(dh/2) * Time;
        ActorX = X - (float)(dw/2) * Time;
        ActorY = Y - (float)(dh/2) * Time;
        ActorWidth = ini_w + dw * Time;
        ActorHeight = ini_h + dh * Time;
    }
    else if ( Direction==19 )
    {
        //內

        //計算圖形變化後的大小
        //PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, pActor->m_X, pActor->m_Y, pActor->m_Width, pActor->m_Height);
        PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, (int)X, (int)Y, (int)Width, (int)Height);
        //抓取圖型起始的大小
        string temp_int_w = GetPPTPointValue(m_Behaviors.at(0), 0);
        string temp_int_h = GetPPTPointValue(m_Behaviors.at(1), 0);

        float ini_w = (float)calPoint->eval(temp_int_w) * slideWidth;
        float ini_h = (float)calPoint->eval(temp_int_h) * slideHeight;

        string temp_fin_w = GetPPTPointValue(m_Behaviors.at(0), 1);
        string temp_fin_h = GetPPTPointValue(m_Behaviors.at(1), 1);

        float fin_w = (float)calPoint->eval(temp_fin_w) * slideWidth;
        float fin_h = (float)calPoint->eval(temp_fin_h) * slideHeight;

        delete calPoint;

        //每次的變化量
        float dw = (float)( fin_w - ini_w ) / (float)myTotalTime;
        float dh = (float)( fin_h - ini_h ) / (float)myTotalTime;

        //原始的位置 = 物件位置 + ( 原來大小 - 放大後的大小 ) / 2
        //ActorX = pActor->m_X - ( dw * Time / 2.0 );
        //ActorY = pActor->m_Y - ( dh * Time / 2.0 );
        ActorX = X - ( dw * Time / 2.0 );
        ActorY = Y - ( dh * Time / 2.0 );
        ActorWidth = ini_w + dw * Time;
        ActorHeight = ini_h + dh * Time;
    }else if( Direction==31 ){
        //向內至螢幕下方

        //計算圖形變化後的大小
        //PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, pActor->m_X, pActor->m_Y, pActor->m_Width, pActor->m_Height);
        PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, (int)X, (int)Y,(int) Width, (int)Height);

        //抓取圖形起始的位置
        //string temp_ini_x = GetPPTPointValue(m_Behaviors.at(2), 0);
        string temp_ini_y = GetPPTPointValue(m_Behaviors.at(2), 0);

        //float ini_x = (float)calPoint->eval(temp_ini_x) * slideWidth;
        //float ini_x = pActor->m_X;
        float ini_y = (float)calPoint->eval(temp_ini_y);

        //抓取圖型起始的大小
        string temp_int_w = GetPPTPointValue(m_Behaviors.at(0), 0);
        string temp_int_h = GetPPTPointValue(m_Behaviors.at(1), 0);

        float ini_w = (float)calPoint->eval(temp_int_w) * slideWidth;
        float ini_h = (float)calPoint->eval(temp_int_h) * slideHeight;

        //抓取圖形起始的位置
        //string temp_fin_x = GetPPTPointValue(m_Behaviors.at(2), 1);
        string temp_fin_y = GetPPTPointValue(m_Behaviors.at(2), 1);

        //float fin_x = (float)calPoint->eval(temp_fin_x);
        float fin_y = (float)calPoint->eval(temp_fin_y) * slideHeight;

        //抓取圖形變化後的大小
        string temp_fin_w = GetPPTPointValue(m_Behaviors.at(0), 1);
        string temp_fin_h = GetPPTPointValue(m_Behaviors.at(1), 1);

        float fin_w = (float)calPoint->eval(temp_fin_w) * slideWidth;
        float fin_h = (float)calPoint->eval(temp_fin_h) * slideHeight;

        delete calPoint;

        //每次的變化量
        //float dx = (float)( fin_x - ini_x ) / (float)myTotalTime;
        float dy = (float)( fin_y - ini_y ) / (float)myTotalTime;
        float dw = (float)( fin_w - ini_w ) / (float)myTotalTime;
        float dh = (float)( fin_h - ini_h ) / (float)myTotalTime;

        //ActorX = pActor->m_X - dw * Time / 2.0 ;
        ActorX = X - dw * Time / 2.0 ;
        ActorY = (float)ini_y + dy * Time;
        ActorWidth = ini_w + dw * Time;
        ActorHeight = ini_h + dh * Time;
    }else if ( Direction==29 )
    {
        //略為向內

        //計算圖形變化後的大小
        //PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, pActor->m_X, pActor->m_Y, pActor->m_Width, pActor->m_Height);
        PPTEVAL *calPoint = new PPTEVAL(slideWidth, slideHeight, (int)X, (int)Y, (int)Width, (int)Height);
        //抓取圖型起始的大小
        string temp_int_w = GetPPTPointValue(m_Behaviors.at(0), 0);
        string temp_int_h = GetPPTPointValue(m_Behaviors.at(1), 0);

        float ini_w = (float)calPoint->eval(temp_int_w) * slideWidth;
        float ini_h = (float)calPoint->eval(temp_int_h) * slideHeight;

        string temp_fin_w = GetPPTPointValue(m_Behaviors.at(0), 1);
        string temp_fin_h = GetPPTPointValue(m_Behaviors.at(1), 1);

        float fin_w = (float)calPoint->eval(temp_fin_w) * slideWidth;
        float fin_h = (float)calPoint->eval(temp_fin_h) * slideHeight;

        delete calPoint;

        //每次的變化量
        float dw = (float)( fin_w - ini_w ) / (float)myTotalTime;
        float dh = (float)( fin_h - ini_h ) / (float)myTotalTime;

        //ActorX = pActor->m_X - (float)(dw/2) * Time;
        //ActorY = pActor->m_Y - (float)(dh/2) * Time;
        ActorX = X - (float)(dw/2) * Time;
        ActorY = Y - (float)(dh/2) * Time;
        ActorWidth = ini_w + dw * Time;
        ActorHeight = ini_h + dh * Time;

    }

    RenderInfo.clear();
    GetParagraphRenderInfo(m_Paragraph, RenderInfo);
    DeleteParagraphRenderInfo(m_Paragraph);

    RenderInfo[0].m_EffectType = Type;

    RenderInfo[0].Actor[0][0] = ActorX - pActor->m_X;
    RenderInfo[0].Actor[0][1] = ActorY - pActor->m_Y;
    RenderInfo[0].Actor[1][0] = ( ActorX + ActorWidth ) - pActor->m_X;
    RenderInfo[0].Actor[1][1] = ActorY - pActor->m_Y;
    RenderInfo[0].Actor[2][0] = ( ActorX + ActorWidth ) - pActor->m_X;
    RenderInfo[0].Actor[2][1] = ( ActorY + ActorHeight ) - pActor->m_Y;
    RenderInfo[0].Actor[3][0] = ActorX - pActor->m_X;
    RenderInfo[0].Actor[3][1] = ( ActorY + ActorHeight ) - pActor->m_Y;
    RenderInfo[0].TextureX = RenderInfo[0].OriTextureX;
    RenderInfo[0].TextureY = RenderInfo[0].OriTextureY;
    RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth;
    RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight;
    RenderInfo[0].Rotation = 0.0;
    RenderInfo[0].Red = 1.0;
    RenderInfo[0].Green = 1.0;
    RenderInfo[0].Blue = 1.0;

    if( TimePercentage<1.0 )
    {
        RenderInfo[0].Alpha = 1.0;
    }
    else if( TimePercentage==1.0 )
    {
        RenderInfo[0].Alpha = 0.0;
    }

    pActor->m_ActorRenderInfo.push_back(RenderInfo[0]);

    return true;
}

//---------------------------------------------------------------------------
// 縮放
bool CActorAction::RefreshEffectZoom(void)
{

    unsigned long time;
    (Time<DelayTime)?(time=0):(time=Time-DelayTime);
    //unsigned long delaytime = DelayTime;
    //unsigned long totaltime = TotalTime;

    float myTotalTime = (float)(TotalTime-DelayTime);
    float TimePercentage = (float)(time)/ (float)myTotalTime;

    if ( m_Exit==msoFalse )
    {
        // 進入縮放
        RefreshEffectZoomIn(TimePercentage, myTotalTime);
    }
    else if ( m_Exit==msoTrue )
    {
        // 結束縮放
        RefreshEffectZoomOut(TimePercentage, myTotalTime);
    }
    else
    {
        return false;
    }

    return true;
}
//---------------------------------------------------------------------------
// 淡出
bool CActorAction::RefreshEffectFade(void)
{
    unsigned long time;
    (Time<DelayTime)?(time=0):(time=Time-DelayTime);
//    unsigned long delaytime = DelayTime;
   // unsigned long totaltime = TotalTime;

    float TimePercentage = (float)(time)/(float)(TotalTime-DelayTime);

    float Alpha;

    CActor *pActor = (CActor *)Actor;

    if ( m_Exit==msoFalse )
    {
        // 進入淡出
        (TimePercentage>1.0)?(Alpha=1.0):(Alpha=TimePercentage);
    }
    else if ( m_Exit==msoTrue )
    {
        // 結束淡出
        (TimePercentage>1.0)?(Alpha=0.0):(Alpha=1.0-TimePercentage);
    }
    else
    {
        return false;
    }

    vector<CActorRenderInfo> RenderInfo;
    GetParagraphRenderInfo(m_Paragraph, RenderInfo);
    DeleteParagraphRenderInfo(m_Paragraph);

    RenderInfo[0].m_EffectType = Type;

    RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[0][0];
    RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[0][1];
    RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[1][0];
    RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[1][1];
    RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[2][0];
    RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[2][1];
    RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[3][0];
    RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[3][1];
    RenderInfo[0].TextureX = RenderInfo[0].OriTextureX;
    RenderInfo[0].TextureY = RenderInfo[0].OriTextureY;
    RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth;
    RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight;
    RenderInfo[0].Alpha = Alpha;

    pActor->m_ActorRenderInfo.push_back(RenderInfo[0]);

    RenderInfo.clear();

    return true;
}
//---------------------------------------------------------------------------
// 筆刷色彩
bool CActorAction::RefreshEffectBrushOnColor()
{
    unsigned long time;
    (Time<DelayTime)?(time=0):(time=Time-DelayTime);
   // unsigned long delaytime = DelayTime;
    //unsigned long totaltime = TotalTime;

    float TimePercentage = (float)(time)/(float)(TotalTime-DelayTime);

    CActor *pActor = (CActor *)Actor;

    vector<CActorRenderInfo> RenderInfo;
    GetParagraphRenderInfo(m_Paragraph, RenderInfo);
    DeleteParagraphRenderInfo(m_Paragraph);

    float width = RenderInfo[0].OriActor[1][0] - RenderInfo[0].OriActor[0][0];
//    float height = RenderInfo[0].OriActor[3][1] - RenderInfo[0].OriActor[0][1] +1.0;

    CActorRenderInfo FirstActorRenderInfo;
    FirstActorRenderInfo.m_EffectType = Type;
    FirstActorRenderInfo.SubIndex = 0;
    FirstActorRenderInfo.Paragraph = m_Paragraph;
    FirstActorRenderInfo.Actor[0][0] = RenderInfo[0].OriActor[0][0];
    FirstActorRenderInfo.Actor[0][1] = RenderInfo[0].OriActor[0][1];
    FirstActorRenderInfo.Actor[1][0] = RenderInfo[0].OriActor[0][0] + width * TimePercentage;
    FirstActorRenderInfo.Actor[1][1] = RenderInfo[0].OriActor[1][1];
    FirstActorRenderInfo.Actor[2][0] = RenderInfo[0].OriActor[3][0] + width * TimePercentage;
    FirstActorRenderInfo.Actor[2][1] = RenderInfo[0].OriActor[2][1];
    FirstActorRenderInfo.Actor[3][0] = RenderInfo[0].OriActor[3][0];
    FirstActorRenderInfo.Actor[3][1] = RenderInfo[0].OriActor[3][1];

    FirstActorRenderInfo.OriActor[0][0] = RenderInfo[0].OriActor[0][0];
    FirstActorRenderInfo.OriActor[0][1] = RenderInfo[0].OriActor[0][1];
    FirstActorRenderInfo.OriActor[1][0] = RenderInfo[0].OriActor[1][0];
    FirstActorRenderInfo.OriActor[1][1] = RenderInfo[0].OriActor[1][1];
    FirstActorRenderInfo.OriActor[2][0] = RenderInfo[0].OriActor[2][0];
    FirstActorRenderInfo.OriActor[2][1] = RenderInfo[0].OriActor[2][1];
    FirstActorRenderInfo.OriActor[3][0] = RenderInfo[0].OriActor[3][0];
    FirstActorRenderInfo.OriActor[3][1] = RenderInfo[0].OriActor[3][1];

    FirstActorRenderInfo.TextActor[0][0] = RenderInfo[0].TextActor[0][0];
    FirstActorRenderInfo.TextActor[0][1] = RenderInfo[0].TextActor[0][1];
    FirstActorRenderInfo.TextActor[1][0] = RenderInfo[0].TextActor[1][0];
    FirstActorRenderInfo.TextActor[1][1] = RenderInfo[0].TextActor[1][1];
    FirstActorRenderInfo.TextActor[2][0] = RenderInfo[0].TextActor[2][0];
    FirstActorRenderInfo.TextActor[2][1] = RenderInfo[0].TextActor[2][1];
    FirstActorRenderInfo.TextActor[3][0] = RenderInfo[0].TextActor[3][0];
    FirstActorRenderInfo.TextActor[3][1] = RenderInfo[0].TextActor[3][1];


    FirstActorRenderInfo.TextureX = RenderInfo[0].OriTextureX;
    FirstActorRenderInfo.TextureY = RenderInfo[0].OriTextureY;
    FirstActorRenderInfo.TextureWidth = RenderInfo[0].OriTextureWidth * TimePercentage;
    FirstActorRenderInfo.TextureHeight = RenderInfo[0].OriTextureHeight;

    FirstActorRenderInfo.OriTextureX = RenderInfo[0].OriTextureX;
    FirstActorRenderInfo.OriTextureY = RenderInfo[0].OriTextureY;
    FirstActorRenderInfo.OriTextureWidth = RenderInfo[0].OriTextureWidth;
    FirstActorRenderInfo.OriTextureHeight = RenderInfo[0].OriTextureHeight;

    FirstActorRenderInfo.TextTextureX = RenderInfo[0].TextTextureX;
    FirstActorRenderInfo.TextTextureY = RenderInfo[0].TextTextureY;
    FirstActorRenderInfo.TextTextureWidth = RenderInfo[0].TextTextureWidth;
    FirstActorRenderInfo.TextTextureHeight = RenderInfo[0].TextTextureHeight;

    FirstActorRenderInfo.Rotation = 0.0;
    FirstActorRenderInfo.Red = (float)Color2RGB[0]/255.0;
    FirstActorRenderInfo.Green = (float)Color2RGB[1]/255.0;
    FirstActorRenderInfo.Blue = (float)Color2RGB[2]/255.0;
    FirstActorRenderInfo.Alpha = 1.0;

    FirstActorRenderInfo.m_EnterAction = RenderInfo[0].m_EnterAction;
    FirstActorRenderInfo.m_ExitAction = RenderInfo[0].m_ExitAction;
    FirstActorRenderInfo.m_EnterFinish = RenderInfo[0].m_EnterFinish;
    FirstActorRenderInfo.m_ExitFinish = RenderInfo[0].m_ExitFinish;
    FirstActorRenderInfo.m_ActionFinish = RenderInfo[0].m_ActionFinish;
    FirstActorRenderInfo.m_HaveInit = RenderInfo[0].m_HaveInit;

    pActor->m_ActorRenderInfo.push_back(FirstActorRenderInfo);

    CActorRenderInfo SecondActorRenderInfo;
    SecondActorRenderInfo.m_EffectType = Type;
    SecondActorRenderInfo.SubIndex = 1;
    SecondActorRenderInfo.Paragraph = m_Paragraph;
    SecondActorRenderInfo.Actor[0][0] = RenderInfo[0].OriActor[0][0] + width * TimePercentage;
    SecondActorRenderInfo.Actor[0][1] = RenderInfo[0].OriActor[0][1];
    SecondActorRenderInfo.Actor[1][0] = RenderInfo[0].OriActor[1][0];
    SecondActorRenderInfo.Actor[1][1] = RenderInfo[0].OriActor[1][1];
    SecondActorRenderInfo.Actor[2][0] = RenderInfo[0].OriActor[2][0];
    SecondActorRenderInfo.Actor[2][1] = RenderInfo[0].OriActor[2][1];
    SecondActorRenderInfo.Actor[3][0] = RenderInfo[0].OriActor[3][0] + width * TimePercentage;
    SecondActorRenderInfo.Actor[3][1] = RenderInfo[0].OriActor[3][1];

    SecondActorRenderInfo.OriActor[0][0] = RenderInfo[0].OriActor[0][0];
    SecondActorRenderInfo.OriActor[0][1] = RenderInfo[0].OriActor[0][1];
    SecondActorRenderInfo.OriActor[1][0] = RenderInfo[0].OriActor[1][0];
    SecondActorRenderInfo.OriActor[1][1] = RenderInfo[0].OriActor[1][1];
    SecondActorRenderInfo.OriActor[2][0] = RenderInfo[0].OriActor[2][0];
    SecondActorRenderInfo.OriActor[2][1] = RenderInfo[0].OriActor[2][1];
    SecondActorRenderInfo.OriActor[3][0] = RenderInfo[0].OriActor[3][0];
    SecondActorRenderInfo.OriActor[3][1] = RenderInfo[0].OriActor[3][1];

    SecondActorRenderInfo.TextActor[0][0] = RenderInfo[0].TextActor[0][0];
    SecondActorRenderInfo.TextActor[0][1] = RenderInfo[0].TextActor[0][1];
    SecondActorRenderInfo.TextActor[1][0] = RenderInfo[0].TextActor[1][0];
    SecondActorRenderInfo.TextActor[1][1] = RenderInfo[0].TextActor[1][1];
    SecondActorRenderInfo.TextActor[2][0] = RenderInfo[0].TextActor[2][0];
    SecondActorRenderInfo.TextActor[2][1] = RenderInfo[0].TextActor[2][1];
    SecondActorRenderInfo.TextActor[3][0] = RenderInfo[0].TextActor[3][0];
    SecondActorRenderInfo.TextActor[3][1] = RenderInfo[0].TextActor[3][1];

    SecondActorRenderInfo.TextureX = RenderInfo[0].OriTextureX + ( RenderInfo[0].OriTextureWidth * TimePercentage );
    SecondActorRenderInfo.TextureY = RenderInfo[0].OriTextureY;
    SecondActorRenderInfo.TextureWidth = RenderInfo[0].OriTextureWidth * (1.0-TimePercentage);
    SecondActorRenderInfo.TextureHeight = RenderInfo[0].OriTextureHeight;

    SecondActorRenderInfo.OriTextureX = RenderInfo[0].OriTextureX;
    SecondActorRenderInfo.OriTextureY = RenderInfo[0].OriTextureY;
    SecondActorRenderInfo.OriTextureWidth = RenderInfo[0].OriTextureWidth;
    SecondActorRenderInfo.OriTextureHeight = RenderInfo[0].OriTextureHeight;

    SecondActorRenderInfo.TextTextureX = RenderInfo[0].TextTextureX;
    SecondActorRenderInfo.TextTextureY = RenderInfo[0].TextTextureY;
    SecondActorRenderInfo.TextTextureWidth = RenderInfo[0].TextTextureWidth;
    SecondActorRenderInfo.TextTextureHeight = RenderInfo[0].TextTextureHeight;

    SecondActorRenderInfo.Rotation = 0;
    SecondActorRenderInfo.Red = (float)pActor->textColorRGB[0]/255.0;
    SecondActorRenderInfo.Green = (float)pActor->textColorRGB[1]/255.0;
    SecondActorRenderInfo.Blue = (float)pActor->textColorRGB[2]/255.0;
    SecondActorRenderInfo.Alpha = 1.0;

    SecondActorRenderInfo.m_EnterAction = RenderInfo[0].m_EnterAction;
    SecondActorRenderInfo.m_ExitAction = RenderInfo[0].m_ExitAction;
    SecondActorRenderInfo.m_EnterFinish = RenderInfo[0].m_EnterFinish;
    SecondActorRenderInfo.m_ExitFinish = RenderInfo[0].m_ExitFinish;
    SecondActorRenderInfo.m_ActionFinish = RenderInfo[0].m_ActionFinish;
    SecondActorRenderInfo.m_HaveInit = RenderInfo[0].m_HaveInit;

    pActor->m_ActorRenderInfo.push_back(SecondActorRenderInfo);

    return true ;
}
//---------------------------------------------------------------------------
// 筆刷底線
bool CActorAction::RefreshEffectBrushOnUnderline()
{
    unsigned long time;
    (Time<DelayTime)?(time=0):(time=Time-DelayTime);
//    unsigned long delaytime = DelayTime;
 //   unsigned long totaltime = TotalTime;

    float TimePercentage = (float)(time)/(float)(TotalTime-DelayTime);

    CActor *pActor = (CActor *)Actor;

    vector<CActorRenderInfo> RenderInfo;
    GetParagraphRenderInfo(m_Paragraph, RenderInfo);
    DeleteParagraphRenderInfo(m_Paragraph);

    // 文字部分
    CActorRenderInfo TextActorRenderInfo;
    TextActorRenderInfo.m_EffectType = Type;
    TextActorRenderInfo.SubIndex = 0;
    TextActorRenderInfo.Paragraph = m_Paragraph;
    TextActorRenderInfo.Actor[0][0] = RenderInfo[0].OriActor[0][0];
    TextActorRenderInfo.Actor[0][1] = RenderInfo[0].OriActor[0][1];
    TextActorRenderInfo.Actor[1][0] = RenderInfo[0].OriActor[1][0];
    TextActorRenderInfo.Actor[1][1] = RenderInfo[0].OriActor[1][1];
    TextActorRenderInfo.Actor[2][0] = RenderInfo[0].OriActor[2][0];
    TextActorRenderInfo.Actor[2][1] = RenderInfo[0].OriActor[2][1];
    TextActorRenderInfo.Actor[3][0] = RenderInfo[0].OriActor[3][0];
    TextActorRenderInfo.Actor[3][1] = RenderInfo[0].OriActor[3][1];

    TextActorRenderInfo.OriActor[0][0] = RenderInfo[0].OriActor[0][0];
    TextActorRenderInfo.OriActor[0][1] = RenderInfo[0].OriActor[0][1];
    TextActorRenderInfo.OriActor[1][0] = RenderInfo[0].OriActor[1][0];
    TextActorRenderInfo.OriActor[1][1] = RenderInfo[0].OriActor[1][1];
    TextActorRenderInfo.OriActor[2][0] = RenderInfo[0].OriActor[2][0];
    TextActorRenderInfo.OriActor[2][1] = RenderInfo[0].OriActor[2][1];
    TextActorRenderInfo.OriActor[3][0] = RenderInfo[0].OriActor[3][0];
    TextActorRenderInfo.OriActor[3][1] = RenderInfo[0].OriActor[3][1];

    TextActorRenderInfo.TextActor[0][0] = RenderInfo[0].TextActor[0][0];
    TextActorRenderInfo.TextActor[0][1] = RenderInfo[0].TextActor[0][1];
    TextActorRenderInfo.TextActor[1][0] = RenderInfo[0].TextActor[1][0];
    TextActorRenderInfo.TextActor[1][1] = RenderInfo[0].TextActor[1][1];
    TextActorRenderInfo.TextActor[2][0] = RenderInfo[0].TextActor[2][0];
    TextActorRenderInfo.TextActor[2][1] = RenderInfo[0].TextActor[2][1];
    TextActorRenderInfo.TextActor[3][0] = RenderInfo[0].TextActor[3][0];
    TextActorRenderInfo.TextActor[3][1] = RenderInfo[0].TextActor[3][1];

    TextActorRenderInfo.TextureX = RenderInfo[0].OriTextureX;
    TextActorRenderInfo.TextureY = RenderInfo[0].OriTextureY;
    TextActorRenderInfo.TextureWidth = RenderInfo[0].OriTextureWidth;
    TextActorRenderInfo.TextureHeight = RenderInfo[0].OriTextureHeight;

    TextActorRenderInfo.OriTextureX = RenderInfo[0].OriTextureX;
    TextActorRenderInfo.OriTextureY = RenderInfo[0].OriTextureY;
    TextActorRenderInfo.OriTextureWidth = RenderInfo[0].OriTextureWidth;
    TextActorRenderInfo.OriTextureHeight = RenderInfo[0].OriTextureHeight;

    TextActorRenderInfo.TextTextureX = RenderInfo[0].TextTextureX;
    TextActorRenderInfo.TextTextureY = RenderInfo[0].TextTextureY;
    TextActorRenderInfo.TextTextureWidth = RenderInfo[0].TextTextureWidth;
    TextActorRenderInfo.TextTextureHeight = RenderInfo[0].TextTextureHeight;

    TextActorRenderInfo.Rotation = RenderInfo[0].Rotation;
    TextActorRenderInfo.Red = 1.0;
    TextActorRenderInfo.Green = 1.0;
    TextActorRenderInfo.Blue = 1.0;
    TextActorRenderInfo.Alpha = 1.0;

    TextActorRenderInfo.m_EnterAction = RenderInfo[0].m_EnterAction;
    TextActorRenderInfo.m_ExitAction = RenderInfo[0].m_ExitAction;
    TextActorRenderInfo.m_EnterFinish = RenderInfo[0].m_EnterFinish;
    TextActorRenderInfo.m_ExitFinish = RenderInfo[0].m_ExitFinish;
    TextActorRenderInfo.m_ActionFinish = RenderInfo[0].m_ActionFinish;
    TextActorRenderInfo.m_HaveInit = RenderInfo[0].m_HaveInit;

    pActor->m_ActorRenderInfo.push_back(TextActorRenderInfo);


    float width = RenderInfo[0].TextActor[1][0] - RenderInfo[0].TextActor[0][0];
    float height = RenderInfo[0].TextActor[3][1] - RenderInfo[0].TextActor[0][1];
    //float width = RenderInfo[0].OriActor[1][0] - RenderInfo[0].OriActor[0][0];
    //float height = RenderInfo[0].OriActor[3][1] - RenderInfo[0].OriActor[0][1];

    float dy = (height/10.0)*9.5;

    CActorRenderInfo LineActorRenderInfo;
    LineActorRenderInfo.m_EffectType = Type;
    LineActorRenderInfo.SubIndex = 1;
    LineActorRenderInfo.Paragraph = m_Paragraph;
    LineActorRenderInfo.Actor[0][0] = RenderInfo[0].TextActor[0][0];
    LineActorRenderInfo.Actor[0][1] = RenderInfo[0].TextActor[0][1] + dy;
    LineActorRenderInfo.Actor[1][0] = RenderInfo[0].TextActor[0][0] + width * TimePercentage;
    LineActorRenderInfo.Actor[1][1] = RenderInfo[0].TextActor[0][1] + dy;
    LineActorRenderInfo.Actor[2][0] = RenderInfo[0].TextActor[0][0] + width * TimePercentage;
    LineActorRenderInfo.Actor[2][1] = RenderInfo[0].TextActor[0][1] + dy +2;
    LineActorRenderInfo.Actor[3][0] = RenderInfo[0].TextActor[0][0];
    LineActorRenderInfo.Actor[3][1] = RenderInfo[0].TextActor[0][1] + dy +2;
    /*
    LineActorRenderInfo.Actor[0][0] = RenderInfo[0].OriActor[0][0];
    LineActorRenderInfo.Actor[0][1] = RenderInfo[0].OriActor[0][1] + dy;
    LineActorRenderInfo.Actor[1][0] = RenderInfo[0].OriActor[0][0] + width * TimePercentage;
    LineActorRenderInfo.Actor[1][1] = RenderInfo[0].OriActor[0][1] + dy;
    LineActorRenderInfo.Actor[2][0] = RenderInfo[0].OriActor[0][0] + width * TimePercentage;
    LineActorRenderInfo.Actor[2][1] = RenderInfo[0].OriActor[0][1] + dy +2;
    LineActorRenderInfo.Actor[3][0] = RenderInfo[0].OriActor[0][0];
    LineActorRenderInfo.Actor[3][1] = RenderInfo[0].OriActor[0][1] + dy +2;
    */
    LineActorRenderInfo.OriActor[0][0] = RenderInfo[0].OriActor[0][0];
    LineActorRenderInfo.OriActor[0][1] = RenderInfo[0].OriActor[0][1];
    LineActorRenderInfo.OriActor[1][0] = RenderInfo[0].OriActor[1][0];
    LineActorRenderInfo.OriActor[1][1] = RenderInfo[0].OriActor[1][1];
    LineActorRenderInfo.OriActor[2][0] = RenderInfo[0].OriActor[2][0];
    LineActorRenderInfo.OriActor[2][1] = RenderInfo[0].OriActor[2][1];
    LineActorRenderInfo.OriActor[3][0] = RenderInfo[0].OriActor[3][0];
    LineActorRenderInfo.OriActor[3][1] = RenderInfo[0].OriActor[3][1];

    LineActorRenderInfo.TextActor[0][0] = RenderInfo[0].TextActor[0][0];
    LineActorRenderInfo.TextActor[0][1] = RenderInfo[0].TextActor[0][1];
    LineActorRenderInfo.TextActor[1][0] = RenderInfo[0].TextActor[1][0];
    LineActorRenderInfo.TextActor[1][1] = RenderInfo[0].TextActor[1][1];
    LineActorRenderInfo.TextActor[2][0] = RenderInfo[0].TextActor[2][0];
    LineActorRenderInfo.TextActor[2][1] = RenderInfo[0].TextActor[2][1];
    LineActorRenderInfo.TextActor[3][0] = RenderInfo[0].TextActor[3][0];
    LineActorRenderInfo.TextActor[3][1] = RenderInfo[0].TextActor[3][1];

    LineActorRenderInfo.TextureX = RenderInfo[0].OriTextureX;
    LineActorRenderInfo.TextureY = RenderInfo[0].OriTextureY;
    LineActorRenderInfo.TextureWidth = RenderInfo[0].OriTextureWidth;
    LineActorRenderInfo.TextureHeight = RenderInfo[0].OriTextureHeight;

    LineActorRenderInfo.OriTextureX = RenderInfo[0].OriTextureX;
    LineActorRenderInfo.OriTextureY = RenderInfo[0].OriTextureY;
    LineActorRenderInfo.OriTextureWidth = RenderInfo[0].OriTextureWidth;
    LineActorRenderInfo.OriTextureHeight = RenderInfo[0].OriTextureHeight;

    LineActorRenderInfo.TextTextureX = RenderInfo[0].TextTextureX;
    LineActorRenderInfo.TextTextureY = RenderInfo[0].TextTextureY;
    LineActorRenderInfo.TextTextureWidth = RenderInfo[0].TextTextureWidth;
    LineActorRenderInfo.TextTextureHeight = RenderInfo[0].TextTextureHeight;

    LineActorRenderInfo.Rotation = 0.0;
    LineActorRenderInfo.Red = (float)pActor->textColorRGB[0]/255.0;
    LineActorRenderInfo.Green = (float)pActor->textColorRGB[1]/255.0;
    LineActorRenderInfo.Blue = (float)pActor->textColorRGB[2]/255.0;
    LineActorRenderInfo.Alpha = 1.0;

    LineActorRenderInfo.m_EnterAction = RenderInfo[0].m_EnterAction;
    LineActorRenderInfo.m_ExitAction = RenderInfo[0].m_ExitAction;
    LineActorRenderInfo.m_EnterFinish = RenderInfo[0].m_EnterFinish;
    LineActorRenderInfo.m_ExitFinish = RenderInfo[0].m_ExitFinish;
    LineActorRenderInfo.m_ActionFinish = RenderInfo[0].m_ActionFinish;
    LineActorRenderInfo.m_HaveInit = RenderInfo[0].m_HaveInit;

    pActor->m_ActorRenderInfo.push_back(LineActorRenderInfo);

    return true;
}
//---------------------------------------------------------------------------
// 旋式誘餌
bool CActorAction::RefreshEffectSpinner()
{
    unsigned long time;
    (Time<DelayTime)?(time=0):(time=Time-DelayTime);
 //   unsigned long delaytime = DelayTime;
 //   unsigned long totaltime = TotalTime;

    float TimePercentage = (float)(time)/(float)(TotalTime-DelayTime);

    float Rotation, Alpha;

    if ( m_Exit==msoFalse )
    {
        // 進入旋式誘餌
        Rotation = -360 * TimePercentage;
        (TimePercentage>1.0)?(Alpha=1.0):(Alpha=TimePercentage);
    }
    else if ( m_Exit==msoTrue )
    {
        // 結束旋式誘餌
        Rotation = 360 * TimePercentage;
        (TimePercentage>1.0)?(Alpha=0.0):(Alpha=1.0-TimePercentage);
    }
    else
    {
        return false;
    }

    CActor *pActor = (CActor *)Actor;

    vector<CActorRenderInfo> RenderInfo;
    GetParagraphRenderInfo(m_Paragraph, RenderInfo);
    DeleteParagraphRenderInfo(m_Paragraph);

    RenderInfo[0].m_EffectType = Type;

    RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[0][0];
    RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[0][1];
    RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[1][0];
    RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[1][1];
    RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[2][0];
    RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[2][1];
    RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[3][0];
    RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[3][1];
    RenderInfo[0].TextureX = RenderInfo[0].OriTextureX;
    RenderInfo[0].TextureY = RenderInfo[0].OriTextureY;
    RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth;
    RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight;
    RenderInfo[0].Rotation = Rotation;
    RenderInfo[0].Alpha = Alpha;

    pActor->m_ActorRenderInfo.push_back(RenderInfo[0]);

    RenderInfo.clear();

    return true;
}
//---------------------------------------------------------------------------
// 消失 出現
bool CActorAction::RefreshEffectAppear(void)
{
    unsigned long time;
    (Time<DelayTime)?(time=0):(time=Time-DelayTime);
//    unsigned long delaytime = DelayTime;
  //  unsigned long totaltime = TotalTime;

    float TimePercentage = (float)(time)/(float)(TotalTime-DelayTime);

    float Alpha;

    CActor *pActor = (CActor *)Actor;

    if ( m_Exit==msoFalse )
    {
        // 出現
        if ( TimePercentage>0 )
            Alpha = 1.0;
        else
            Alpha = 0.0;

    }
    else if ( m_Exit==msoTrue )
    {
        // 消失
        if ( TimePercentage>0 )
            Alpha = 0.0;
        else
            Alpha = 1.0;

    }
    else
    {
        return false;
    }

    vector<CActorRenderInfo> RenderInfo;
    GetParagraphRenderInfo(m_Paragraph, RenderInfo);
    DeleteParagraphRenderInfo(m_Paragraph);

    RenderInfo[0].m_EffectType = Type;

    RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[0][0];
    RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[0][1];
    RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[1][0];
    RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[1][1];
    RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[2][0];
    RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[2][1];
    RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[3][0];
    RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[3][1];
    RenderInfo[0].TextureX = RenderInfo[0].OriTextureX;
    RenderInfo[0].TextureY = RenderInfo[0].OriTextureY;
    RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth;
    RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight;
    RenderInfo[0].Alpha = Alpha;

    pActor->m_ActorRenderInfo.push_back(RenderInfo[0]);

    RenderInfo.clear();

    return true;
}
//---------------------------------------------------------------------------
// 上升、下沉
bool CActorAction::RefreshEffectRiseUp(void)
{
    unsigned long time;
    (Time<DelayTime)?(time=0):(time=Time-DelayTime);
//    unsigned long delaytime = DelayTime;
 //   unsigned long totaltime = TotalTime;

    float TimePercentage = (float)(time)/(float)(TotalTime-DelayTime);



    CActor *pActor = (CActor *)Actor;

    vector<CActorRenderInfo> RenderInfo;
    GetParagraphRenderInfo(m_Paragraph, RenderInfo);


    float Alpha;
    float dist;



    if ( m_Exit==msoFalse )
    {
        // 上升
        (TimePercentage>=0.7)?(Alpha=1.0):(Alpha=TimePercentage+(0.3*TimePercentage));
        if ( TimePercentage<=0.7 )
        {
            dist = ((float)slideHeight - ( pActor->m_Y + RenderInfo[0].OriActor[0][1] ) )*(0.7-TimePercentage);
        }
        else if ( TimePercentage>0.7 && TimePercentage<=0.85 )
        {
            dist = -50 * ( TimePercentage - 0.7 );
        }
        else
        {
            dist = -50 * ( 1 - TimePercentage );
        }

    }
    else if ( m_Exit==msoTrue )
    {
        // 下沉
        (TimePercentage<=0.3)?(Alpha=1.0):(Alpha=1.0-TimePercentage);
        if ( TimePercentage>=0.3 )
        {
            dist = ((float)slideHeight - ( pActor->m_Y + RenderInfo[0].OriActor[0][1] ) )*(TimePercentage-0.3);
        }
        else if ( TimePercentage>=0 && TimePercentage<0.15 )
        {
            dist = -50 * TimePercentage;
        }
        else
        {
            dist = -50 * ( 0.3 - TimePercentage );
        }

    }
    else
    {
        return false;
    }

    RenderInfo[0].m_EffectType = Type;

    RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[0][0];
    RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[0][1] + dist;
    RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[1][0];
    RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[1][1] + dist;
    RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[2][0];
    RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[2][1] + dist;
    RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[3][0];
    RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[3][1] + dist;
    RenderInfo[0].TextureX = RenderInfo[0].OriTextureX;
    RenderInfo[0].TextureY = RenderInfo[0].OriTextureY;
    RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth;
    RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight;
    RenderInfo[0].Alpha = Alpha;

    DeleteParagraphRenderInfo(m_Paragraph);

    pActor->m_ActorRenderInfo.push_back(RenderInfo[0]);

    RenderInfo.clear();
    return true ;

}
//---------------------------------------------------------------------------
bool CActorAction::RefreshEffectFly(void)
{
    unsigned long time;
    (Time<DelayTime)?(time=0):(time=Time-DelayTime);
//    unsigned long delaytime = DelayTime;
 //   unsigned long totaltime = TotalTime;

    CActor *pActor = (CActor *)Actor;

    float TimePercentage = (float)(time)/(float)(TotalTime-DelayTime);

    string pptX_From,pptX_To,pptY_From,pptY_To;
    double Alpha_From, Alpha_To;

    float dist_x, dist_y, Alpha;
    unsigned long AlphaTriggerTime;
    ActorPointPtr ptr;

    for ( unsigned int index=0 ; index<m_Behaviors.size() ; index++ )
    {
        if ( m_Behaviors[index]->m_Type==msoAnimTypeProperty && m_Behaviors[index]->proProperty==msoAnimX)
        {
            ptr = (ActorPointPtr)m_Behaviors[index]->m_Points[0];
            pptX_From = ptr->value;
            ptr = (ActorPointPtr)m_Behaviors[index]->m_Points[1];
            pptX_To = ptr->value;
            float half_w = (float)pActor->m_Width/2.0;

            if ( pptX_From=="#ppt_x" && pptX_To=="#ppt_x" )
            {
                dist_x = 0;
            }
            else if ( pptX_From=="0-#ppt_w/2" && pptX_To=="#ppt_x" )
            {
                dist_x = ( -pActor->m_X - half_w ) * ( 1.0- TimePercentage );
            }
            else if ( pptX_From=="#ppt_x" && pptX_To=="1+#ppt_w/2" )
            {
                dist_x = ( slideWidth - pActor->m_X + half_w ) * TimePercentage;
            }
            else if ( pptX_From=="1+#ppt_w/2" && pptX_To=="#ppt_x" )
            {
                dist_x = ( slideWidth - pActor->m_X + half_w ) * ( 1.0 - TimePercentage );
            }
            else if ( pptX_From=="#ppt_x" && pptX_To=="0-#ppt_w/2" )
            {
                dist_x = ( -pActor->m_X - half_w ) * TimePercentage;
            }

        }
        else if ( m_Behaviors[index]->m_Type==msoAnimTypeProperty && m_Behaviors[index]->proProperty==msoAnimY )
        {
            ptr = (ActorPointPtr)m_Behaviors[index]->m_Points[0];
            pptY_From = ptr->value;
            ptr = (ActorPointPtr)m_Behaviors[index]->m_Points[1];
            pptY_To = ptr->value;

            float half_h = (float)pActor->m_Height/2.0;

            if ( pptX_From=="#ppt_y" && pptX_To=="#ppt_y" )
            {
                dist_y = 0;
            }
            else if ( pptY_From=="0-#ppt_h/2" && pptY_To=="#ppt_y" )
            {
                dist_y = ( -pActor->m_Y - half_h ) * ( 1.0- TimePercentage );
            }
            else if ( pptY_From=="#ppt_y" && pptY_To=="1+#ppt_h/2" )
            {
                dist_y = ( slideHeight - pActor->m_Y + half_h ) * TimePercentage;
            }
            else if ( pptY_From=="1+#ppt_h/2" && pptY_To=="#ppt_y" )
            {
                dist_y = ( slideHeight - pActor->m_Y + half_h ) * ( 1.0 - TimePercentage );
            }
            else if ( pptY_From=="#ppt_y" && pptY_To=="0-#ppt_h/2" )
            {
                dist_y = ( -pActor->m_Y - half_h ) * TimePercentage;
            }
            else if ( pptY_From=="#ppt_y-1" && pptY_To=="#ppt_y+1" )
            {
                if ( TimePercentage<=0.5 )
                    dist_y = -slideHeight*( 1.0 - TimePercentage*2.0 );
                else
                    dist_y = slideHeight*( (TimePercentage-0.5) * 2.0);
            }
            else if ( pptY_From=="#ppt_y+1" && pptY_To=="#ppt_y-1" )
            {
                if ( TimePercentage<=0.5 )
                    dist_y = slideHeight*( 1.0 - TimePercentage*2.0 );
                else
                    dist_y = -slideHeight*( (TimePercentage-0.5) * 2.0);
            }
            else if ( pptY_From=="#ppt_y-.1" && pptY_To=="#ppt_y" )
            {
                dist_y = ( -slideHeight*0.1 )*( 1.0 - TimePercentage );
            }
            else if ( pptY_From=="#ppt_y" && pptY_To=="#ppt_y+.1" )
            {
                dist_y = ( slideHeight*0.1 ) * TimePercentage;
            }

        }
        else if ( m_Behaviors[index]->m_Type==msoAnimTypeSet && m_Behaviors[index]->setProperty==msoAnimVisibility )
        {
            Alpha_From = 1.0-m_Behaviors[index]->setTo;
            Alpha_To = m_Behaviors[index]->setTo;
            AlphaTriggerTime = (unsigned long)(m_Behaviors[index]->triggerDelayTime*100.0);
        }
    }

    if ( time>AlphaTriggerTime )
    {
        Alpha = Alpha_To;
    }
    else
    {
        Alpha = Alpha_From;
    }

    vector<CActorRenderInfo> RenderInfo;
    GetParagraphRenderInfo(m_Paragraph, RenderInfo);

    RenderInfo[0].m_EffectType = Type;

    RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[0][0] + dist_x;
    RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[0][1] + dist_y;
    RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[1][0] + dist_x;
    RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[1][1] + dist_y;
    RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[2][0] + dist_x;
    RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[2][1] + dist_y;
    RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[3][0] + dist_x;
    RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[3][1] + dist_y;
    RenderInfo[0].TextureX = RenderInfo[0].OriTextureX;
    RenderInfo[0].TextureY = RenderInfo[0].OriTextureY;
    RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth;
    RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight;
    RenderInfo[0].Alpha = Alpha;

    DeleteParagraphRenderInfo(m_Paragraph);

    pActor->m_ActorRenderInfo.push_back(RenderInfo[0]);

    RenderInfo.clear();

    return true ;

}
//---------------------------------------------------------------------------
bool CActorAction::RefreshEffectGlide(void)
{
    unsigned long time;
    (Time<DelayTime)?(time=0):(time=Time-DelayTime);
//    unsigned long delaytime = DelayTime;
 //   unsigned long totaltime = TotalTime;

    CActor *pActor = (CActor *)Actor;

    float TimePercentage = (float)(time)/(float)(TotalTime-DelayTime);

    string pptX_From,pptX_To,pptY_From,pptY_To;
    double Alpha_From, Alpha_To;

    float dist_x, dist_y, dw, dh, Alpha;
    unsigned long AlphaTriggerTime;
    ActorPointPtr ptr;

    vector<CActorRenderInfo> RenderInfo;
    GetParagraphRenderInfo(m_Paragraph, RenderInfo);

    float w = RenderInfo[0].OriActor[1][0] - RenderInfo[0].OriActor[0][0];
    float h = RenderInfo[0].OriActor[3][1] - RenderInfo[0].OriActor[0][1];

    for ( unsigned int index=0 ; index<m_Behaviors.size() ; index++ )
    {
        if ( m_Behaviors[index]->m_Type==msoAnimTypeProperty && m_Behaviors[index]->proProperty==msoAnimX)
        {
            ptr = (ActorPointPtr)m_Behaviors[index]->m_Points[0];
            pptX_From = ptr->value;
            ptr = (ActorPointPtr)m_Behaviors[index]->m_Points[1];
            pptX_To = ptr->value;

            if ( pptX_From=="#ppt_x" && pptX_To=="#ppt_x" )
            {
                dist_x = 0;
            }
            else if ( pptX_From=="#ppt_x-.2" && pptX_To=="#ppt_x" )
            {
                dist_x = ( -w*0.2 ) * ( 1.0- TimePercentage );
            }
            else if ( pptX_From=="#ppt_x" && pptX_To=="#ppt_x-.2" )
            {
                dist_x = ( -w*0.2 ) * TimePercentage;
            }

        }
        else if ( m_Behaviors[index]->m_Type==msoAnimTypeProperty && m_Behaviors[index]->proProperty==msoAnimY )
        {
            ptr = (ActorPointPtr)m_Behaviors[index]->m_Points[0];
            pptY_From = ptr->value;
            ptr = (ActorPointPtr)m_Behaviors[index]->m_Points[1];
            pptY_To = ptr->value;

            if ( pptY_From=="#ppt_y" && pptY_To=="#ppt_y" )
            {
                dist_y = 0;
            }
        }
        else if ( m_Behaviors[index]->m_Type==msoAnimTypeProperty && m_Behaviors[index]->proProperty==msoAnimWidth )
        {
            ptr = (ActorPointPtr)m_Behaviors[index]->m_Points[0];
            string pptWidth_From = ptr->value;

            ptr = (ActorPointPtr)m_Behaviors[index]->m_Points[1];
            string pptWidth_To = ptr->value;

            if ( pptWidth_From=="#ppt_w*0.05" && pptWidth_To=="#ppt_w" )
            {
                dw = ( w*0.05 ) + ( w*0.95*TimePercentage );
            }
            else if ( pptWidth_From=="#ppt_w" && pptWidth_To=="#ppt_w*0.05" )
            {
                dw = ( w*0.05 ) + ( w*0.95*(1.0-TimePercentage) );
            }

        }
        else if ( m_Behaviors[index]->m_Type==msoAnimTypeProperty && m_Behaviors[index]->proProperty==msoAnimHeight )
        {
            ptr = (ActorPointPtr)m_Behaviors[index]->m_Points[0];
            string pptHeight_From = ptr->value;

            ptr = (ActorPointPtr)m_Behaviors[index]->m_Points[1];
            string pptHeight_To = ptr->value;

            if ( pptHeight_From=="#ppt_h" && pptHeight_To=="#ppt_h" )
            {
                dh = h;
            }
        }
        else if ( m_Behaviors[index]->m_Type==msoAnimTypeSet && m_Behaviors[index]->setProperty==msoAnimVisibility )
        {
            Alpha_From = 1.0-m_Behaviors[index]->setTo;
            Alpha_To = m_Behaviors[index]->setTo;
            AlphaTriggerTime = (unsigned long)(m_Behaviors[index]->triggerDelayTime*100.0);
        }
    }

    if ( time>AlphaTriggerTime )
    {
        Alpha = Alpha_To;
    }
    else
    {
        Alpha = Alpha_From;
    }

    RenderInfo[0].m_EffectType = Type;

    RenderInfo[0].Actor[0][0] = RenderInfo[0].OriActor[0][0] + dist_x;
    RenderInfo[0].Actor[0][1] = RenderInfo[0].OriActor[0][1] + dist_y;
    RenderInfo[0].Actor[1][0] = RenderInfo[0].OriActor[0][0] + dw;
    RenderInfo[0].Actor[1][1] = RenderInfo[0].OriActor[1][1] + dist_y;
    RenderInfo[0].Actor[2][0] = RenderInfo[0].OriActor[0][0] + dw;
    RenderInfo[0].Actor[2][1] = RenderInfo[0].OriActor[0][1] + dh;
    RenderInfo[0].Actor[3][0] = RenderInfo[0].OriActor[3][0] + dist_x;
    RenderInfo[0].Actor[3][1] = RenderInfo[0].OriActor[0][1] + dh;
    RenderInfo[0].TextureX = RenderInfo[0].OriTextureX;
    RenderInfo[0].TextureY = RenderInfo[0].OriTextureY;
    RenderInfo[0].TextureWidth = RenderInfo[0].OriTextureWidth;
    RenderInfo[0].TextureHeight = RenderInfo[0].OriTextureHeight;
    RenderInfo[0].Alpha = Alpha;

    DeleteParagraphRenderInfo(m_Paragraph);

    pActor->m_ActorRenderInfo.push_back(RenderInfo[0]);

    RenderInfo.clear();

    return true ;
}
//---------------------------------------------------------------------------
// 路徑特效
bool CActorAction::RefreshEffectPath(void)
{
    unsigned long time;
    (Time<DelayTime)?(time=0):(time=Time-DelayTime);

    //unsigned int index = (unsigned int)((float)time/((float)DurationTime/(float)Point_X.size())+0.5);
    unsigned int index = (unsigned int)((float)time*((float)Point_X.size()/(float)DurationTime)+0.5);

    if ( index>=Point_X.size() )
        index = Point_X.size()-1;
    else if ( index<0 )
        index = 0;

    vector<CActorRenderInfo> RenderInfo;
    GetParagraphRenderInfo(m_Paragraph, RenderInfo);
    DeleteParagraphRenderInfo(m_Paragraph);

    CActor *pActor = (CActor *)Actor;

    vector<CActorRenderInfo> ParagraphInfo;

    for ( unsigned int index1=0 ; index1<RenderInfo.size() ; index1++ )
    {
        ParagraphInfo.clear();
        GetParagraphInfo(m_Paragraph, ParagraphInfo);

        double dx;
        double dy;

        if ( !ParagraphInfo.empty() )
        {
            dx = Point_X[index] + ParagraphInfo[0].OriActor[0][0] - pActor->m_X - RenderInfo[index1].OriActor[0][0];
            dy = Point_Y[index] + ParagraphInfo[0].OriActor[0][1] - pActor->m_Y - RenderInfo[index1].OriActor[0][1];

        }
        else
        {
            dx = Point_X[index] - pActor->m_X - RenderInfo[index1].OriActor[0][0];
            dy = Point_Y[index] - pActor->m_Y - RenderInfo[index1].OriActor[0][1];
        }

        RenderInfo[index1].m_EffectType = Type;

        RenderInfo[index1].m_PathAction = true;

        RenderInfo[index1].Actor[0][0] = RenderInfo[index1].Actor[0][0] + dx;
        RenderInfo[index1].Actor[0][1] = RenderInfo[index1].Actor[0][1] + dy;
        RenderInfo[index1].Actor[1][0] = RenderInfo[index1].Actor[1][0] + dx;
        RenderInfo[index1].Actor[1][1] = RenderInfo[index1].Actor[1][1] + dy;
        RenderInfo[index1].Actor[2][0] = RenderInfo[index1].Actor[2][0] + dx;
        RenderInfo[index1].Actor[2][1] = RenderInfo[index1].Actor[2][1] + dy;
        RenderInfo[index1].Actor[3][0] = RenderInfo[index1].Actor[3][0] + dx;
        RenderInfo[index1].Actor[3][1] = RenderInfo[index1].Actor[3][1] + dy;

        RenderInfo[index1].OriActor[0][0] = RenderInfo[index1].OriActor[0][0] + dx;
        RenderInfo[index1].OriActor[0][1] = RenderInfo[index1].OriActor[0][1] + dy;
        RenderInfo[index1].OriActor[1][0] = RenderInfo[index1].OriActor[1][0] + dx;
        RenderInfo[index1].OriActor[1][1] = RenderInfo[index1].OriActor[1][1] + dy;
        RenderInfo[index1].OriActor[2][0] = RenderInfo[index1].OriActor[2][0] + dx;
        RenderInfo[index1].OriActor[2][1] = RenderInfo[index1].OriActor[2][1] + dy;
        RenderInfo[index1].OriActor[3][0] = RenderInfo[index1].OriActor[3][0] + dx;
        RenderInfo[index1].OriActor[3][1] = RenderInfo[index1].OriActor[3][1] + dy;

        pActor->m_ActorRenderInfo.push_back(RenderInfo[index1]);


    }

    RenderInfo.clear();

    return true;
}

//---------------------------------------------------------------------------

void CActorAction::Start(void)
{
    Enabled = true;
    Time = 0;

    // 特效被啟動，設定對應演員特效完成為 false。
    CActor *pActor = (CActor *)Actor;
    pActor->m_IsActing = true;


    // 設定演員對應的顯示區塊特效未結束
    vector<CActorRenderInfo> ParagraphRenderInfo;
    GetParagraphRenderInfo(m_Paragraph, ParagraphRenderInfo);
    DeleteParagraphRenderInfo(m_Paragraph);

    int tmp = pActor->m_ActorRenderInfo.size();

    for ( unsigned int index=0 ; index<ParagraphRenderInfo.size() ; index++ )
    {
        ParagraphRenderInfo[index].m_ActionFinish = false;

        // 以下還不確定
        ParagraphRenderInfo[index].m_EnterAction = false;
        ParagraphRenderInfo[index].m_ExitAction = false;
        ParagraphRenderInfo[index].m_PathAction = false;
        ParagraphRenderInfo[index].m_EnterFinish = false;
        ParagraphRenderInfo[index].m_ExitFinish = false;
        // 結束
        pActor->m_ActorRenderInfo.push_back(ParagraphRenderInfo[index]);
    }

    tmp = pActor->m_ActorRenderInfo.size();
}

void CActorAction::End(void)
{
    // 此處設定 Enabled==true 的目的是要在利用 RefreshActor 更新演員狀態
    CActor *pActor = (CActor *)Actor;
    pActor->m_IsActing = false;
    Enabled = true;                 // Enable 不可設為 false，因為還需要一次更新，將顯示資料更新到正確的狀態。
    Time = TotalTime;
    RefreshActor(0);

}

//---------------------------------------------------------------------------

void CActorAction::Reset(void)
{
    InitState();
    Time = 0;
    Enabled = false;
}

//---------------------------------------------------------------------------

HRESULT CActorAction::InitState(void)
{
    CActor *pActor = (CActor *)Actor;
    pActor->m_HaveEffect = true;

    // 取得對應顯示資訊
    vector<CActorRenderInfo> ParagraphRenderInfo;
    GetParagraphRenderInfo(m_Paragraph, ParagraphRenderInfo);

    // 如果找不到相同段落的顯示資訊，則代表此演員的顯示資訊是以整個演員為單位，並未被切成段落。
    if ( ParagraphRenderInfo.empty() )
    {

        if ( pActor->m_SubRenderInfo.empty() )
        {
            return E_FAIL;
        }

        // 將整個演員的顯示資訊清除，並且填入分段的顯示資訊
        pActor->m_ActorRenderInfo.clear();

        for ( unsigned int index=0 ; index<pActor->m_SubRenderInfo.size() ; index++ )
        {
            pActor->m_ActorRenderInfo.push_back(pActor->m_SubRenderInfo[index]);
        }
    }

    ParagraphRenderInfo.clear();

    GetParagraphRenderInfo(m_Paragraph, ParagraphRenderInfo);

    if ( ParagraphRenderInfo.empty() )
    {
        return E_FAIL;
    }

    if ( ParagraphRenderInfo[0].m_HaveInit==false )
    {
        Time = 0;

        Enabled = false;

        pActor->Visible = true;

        RefreshRenderInfo();

        ParagraphRenderInfo.clear();

        GetParagraphRenderInfo(m_Paragraph, ParagraphRenderInfo);

        DeleteParagraphRenderInfo(m_Paragraph);

        for ( unsigned int index=0 ; index<ParagraphRenderInfo.size() ; index++ )
        {
            ParagraphRenderInfo[index].m_HaveInit = true;
            pActor->m_ActorRenderInfo.push_back(ParagraphRenderInfo[index]);
        }

        ParagraphRenderInfo.clear();
    }

    return S_OK;
}
//---------------------------------------------------------------------------
void CActorAction::ReinitState(void)
{
    CActor *pActor = (CActor *)Actor;

    pActor->Visible = true;

    vector<CActorRenderInfo> ParagraphRenderInfo;
    GetParagraphRenderInfo(m_Paragraph, ParagraphRenderInfo);
    DeleteParagraphRenderInfo(m_Paragraph);

    for ( unsigned int index=0 ; index<ParagraphRenderInfo.size() ; index++ )
    {
        ParagraphRenderInfo[index].m_HaveInit = true;
        ParagraphRenderInfo[index].m_EnterAction = false;
        ParagraphRenderInfo[index].m_ExitAction = false;
        ParagraphRenderInfo[index].m_ActionFinish = true;

        if ( Time>=TotalTime )
        {
            if ( m_Exit==-1 )
            {
                // 此時的 LastUseExitAction 的數值是由目前的特效更新
                // 所以需要更改數值
                ParagraphRenderInfo[index].m_LastUseExitAction = false;
            }
        }

        pActor->m_ActorRenderInfo.push_back(ParagraphRenderInfo[index]);
    }

    Time = 0;

    RefreshRenderInfo();

    Enabled = false;

}

//---------------------------------------------------------------------------

// 取得同ㄧ段落(Paragraph)的演員顯示資訊，使用時機為填入RenderInfo資料時。
void CActorAction::GetParagraphRenderInfo(long Paragraph, vector<CActorRenderInfo> &ParagraphRenderInfo)
{
    CActor *pActor = (CActor *)Actor;

    ParagraphRenderInfo.clear();

    vector<CActorRenderInfo>::iterator iter;

//    int size = pActor->m_ActorRenderInfo.size();

    for ( iter=pActor->m_ActorRenderInfo.begin() ; iter!=pActor->m_ActorRenderInfo.end() ; iter++ )
    {
        CActorRenderInfo tmp = (*iter);
        if ( (*iter).Paragraph==Paragraph )
        {
            // 取得同ㄧ Paragraph 的 Render information。
            ParagraphRenderInfo.push_back(*iter);
        }
    }

}
//---------------------------------------------------------------------------
void CActorAction::GetParagraphInfo(long Paragraph, vector<CActorRenderInfo> &ParagraphInfo)
{
    CActor *pActor = (CActor *)Actor;

    vector<CActorRenderInfo>::iterator iter;

    for ( iter=pActor->m_SubRenderInfo.begin() ; iter!=pActor->m_SubRenderInfo.end() ; iter++ )
    {
        if ( (*iter).Paragraph==Paragraph )
        {
            // 取得同ㄧ Paragraph 的 Render information。
            ParagraphInfo.push_back(*iter);
        }
    }
}
//---------------------------------------------------------------------------
void CActorAction::DeleteParagraphRenderInfo(long Paragraph)
{
    CActor *pActor = (CActor *)Actor;

    vector<CActorRenderInfo>::iterator iter;

    int tmp = pActor->m_ActorRenderInfo.size();

    iter=pActor->m_ActorRenderInfo.begin();
    while ( iter!=pActor->m_ActorRenderInfo.end() )
    {
        if ( (*iter).Paragraph==Paragraph )
        {
            // 刪除已取出的 Render information。
            iter = pActor->m_ActorRenderInfo.erase(iter);

            tmp = pActor->m_ActorRenderInfo.size();
        }
        else
        {
            iter++;
        }
    }
}

//---------------------------------------------------------------------------
unsigned long CActorAction::GetTime(void)
{
    return Time;
}
//---------------------------------------------------------------------------
// 將原始位置塞入 Point_X 和 Point_Y，以提供路徑特效時的正確開始位置
void CActorAction::InsertOriginalPosition(void)
{
    CActor *pActor = (CActor *)Actor;
    if ( !Point_X.empty() )
    {
        Point_X.insert(Point_X.begin(), (double)pActor->m_X);
        Point_Y.insert(Point_Y.begin(), (double)pActor->m_Y);
    }
}
//---------------------------------------------------------------------------
bool CActorAction::LegalAction(void)
{
    bool Legal;
    switch( Type )
    {
        case msoAnimEffectWipe: // 擦去
        case msoAnimEffectPeek: // 鑽入
        case msoAnimEffectZoom: // 縮放
        case msoAnimEffectFade: // 淡出
        case msoAnimEffectBrushOnColor: // 筆刷色彩
        case msoAnimEffectBrushOnUnderline: // 筆刷底線
        case msoAnimEffectSpinner:  // 旋式誘餌
        case msoAnimEffectAppear:   // 出現 消失

        //case msoAnimEffectRiseUp:   // 上升、下沉
        case msoAnimEffectFly:      // 飛入、飛出
        case msoAnimEffectCrawl:    // 慢速推入、慢速推出
        //case msoAnimEffectCredits:  // 字幕
        //case msoAnimEffectAscend:   // 進入下斜
        //case msoAnimEffectDescend:  // 結束下斜
        //case msoAnimEffectGlide:    // 進入、結束下滑
        case msoAnimEffectFlashOnce : // 閃爍一次

        case msoAnimEffectPathDiagonalUpRight: // 路徑-右斜
        case msoAnimEffectPathDiagonalDownRight: // 路徑-左斜
        case msoAnimEffectPathDown: // 路徑-向下
        case msoAnimEffectPathUp: // 路徑-向上
        case msoAnimEffectPathRight: // 路徑-向右
        case msoAnimEffectPathLeft: // 路徑-向左
        case msoAnimEffectPathPentagon: // 路徑-五邊形
        case msoAnimEffectPathHexagon:  // 路徑-六邊形
        case msoAnimEffectPathOctagon: // 路徑 - 八邊形
        case msoAnimEffectPath4PointStar: // 路徑-四點星形
        case msoAnimEffectPath5PointStar: // 路徑-五點星形
        case msoAnimEffectPath6PointStar: // 路徑-六點星形
        case msoAnimEffectPath8PointStar: // 路徑-八點星形
        case msoAnimEffectPathHeart:      // 路徑-心形
        case msoAnimEffectPathSquare: // 路徑-方形
        case msoAnimEffectPathTeardrop: // 路徑-水滴形
        case msoAnimEffectPathParallelogram : // 路徑-平行四邊形
        case msoAnimEffectPathEqualTriangle : // 路徑-正三角形
        case msoAnimEffectPathRightTriangle: // 路徑-直角三角形
        case msoAnimEffectPathTrapezoid: // 路徑-梯形
        case msoAnimEffectPathDiamond : // 路徑-菱形
        case msoAnimEffectPathCircle : // 路徑-圓形擴展
        case msoAnimEffectPathCrescentMoon: // 路徑-新月
        case msoAnimEffectPathFootball : // 路徑-橄欖球形
        case msoAnimEffectPathSCurve1: // 路徑-S形彎曲 1
        case msoAnimEffectPathSCurve2: // 路徑-S形彎曲 2
        case msoAnimEffectPathZigzag: // 路徑-Z字形
        case msoAnimEffectPathHeartbeat: // 路徑-心跳
        case msoAnimEffectPathTurnRight: // 路徑-右後轉彎
        case msoAnimEffectPathSineWave: // 路徑-正弦波
        case msoAnimEffectPathTurnDown: // 路徑-向下轉
        case msoAnimEffectPathTurnUp: // 路徑-向上轉
        case msoAnimEffectPathBounceRight: // 路徑-向右彈跳
        case msoAnimEffectPathCurvyRight: // 路徑-向右彎曲
        case msoAnimEffectPathBounceLeft : // 路徑-向左彈跳
        case msoAnimEffectPathCurvyLeft: // 路徑-向左彎曲
        case msoAnimEffectPathArcDown: // 路徑-弧形向下
        case msoAnimEffectPathArcUp: // 路徑-弧形向上
        case msoAnimEffectPathArcRight: // 路徑-弧形向右
        case msoAnimEffectPathArcLeft: // 路徑-弧形向左
        case msoAnimEffectPathWave: // 路徑-波浪1
        case msoAnimEffectPathDecayingWave: // 路徑-波浪2
        case msoAnimEffectPathFunnel : // 路徑-漏斗
        case msoAnimEffectPathSpring : // 路徑-彈簧
        case msoAnimEffectPathStairsDown: // 路徑-樓梯向下
        case msoAnimEffectPathSpiralRight : // 路徑-螺旋向右
        case msoAnimEffectPathSpiralLeft : // 路徑-螺旋向左
        case msoAnimEffectPathTurnUpRight : // 路徑-轉向右上
        case msoAnimEffectPathPlus : // 路徑-十字形擴展
        case msoAnimEffectPathHorizontalFigure8 : // 路徑-水平數字8
        case msoAnimEffectPathPointyStar : // 路徑-尖的星形
        case msoAnimEffectPathBean : // 路徑-豆莢
        case msoAnimEffectPathNeutron : // 路徑-物理中子
        case msoAnimEffectPathPeanut : // 路徑-花生狀
        case msoAnimEffectPathVerticalFigure8 : // 路徑-垂直數字8
        case msoAnimEffectPathInvertedTriangle : // 路徑-倒三角形
        case msoAnimEffectPathInvertedSquare : // 路徑-倒方形
        case msoAnimEffectPathFigure8Four : // 路徑-畫四個8
        case msoAnimEffectPathLoopdeLoop : // 路徑-漣漪
        case msoAnimEffectPathSwoosh : // 路徑-噴湧
        case msoAnimEffectPathBuzzsaw : // 路徑-鋸齒狀
        case msoAnimEffectPathCurvedX : // 路徑-彎曲的X
        case msoAnimEffectPathCurvedSquare : // 路徑-彎曲的方形
        case msoAnimEffectPathCurvyStar: // 路徑-彎曲的星形
        case msoAnimEffectCustom : // 路徑-繪製自訂路徑

            Legal = true;

            break;

        default:    // 如果特效不支援，以淡出處理

            Legal = false;

    }

    return Legal;
}

// 給PowerPoint 2000使用的Function
// 用途為將PowerPoint 2000的特效載入使用

HRESULT CActorAction::CreateActorAction( xmlNodePtr ShapeNode,
                                         int SlideWidth,
                                         int SlideHeight,
                                         long Paragraph,
                                         long TriggleMode)
{

    xmlNodePtr AnimationSettingsNode =  m_xml.FindChildNode(ShapeNode,xmlCharStrdup("AnimationSettings"));
    if ( AnimationSettingsNode==NULL )
    {
        // 沒有 AnimationSettingsNode
        return E_FAIL;
    }

    if (  m_xml.HasAttribute(AnimationSettingsNode,xmlCharStrdup("Animate"))==false )
    {
        // 沒有判斷是否有特效的參數
        return E_FAIL;
    }

    long Animate = atol((char*) m_xml.GetAttribute(AnimationSettingsNode,xmlCharStrdup("Animate")));

    if ( Animate!=msoTrue )
    {
        // 沒有特效
        return E_FAIL;
    }

    if (  m_xml.HasAttribute(AnimationSettingsNode,xmlCharStrdup("EntryEffect"))==false )
    {
        // 沒有指定特效種類的參數
        return E_FAIL;
    }

    long AnimationSettingsType = atol((char*) m_xml.GetAttribute(AnimationSettingsNode,xmlCharStrdup("EntryEffect")));



    // 設定共同的資訊
    Type = msoAnimEffectFade;
    m_Exit = 0;
    Triggertype = msoAnimTriggerOnPageClick;
    Triggerdelaytime = 0;
    m_AfterEffect = msoAnimAfterEffectNone;
    Duration = 0.5;
    m_Paragraph = Paragraph;
    slideWidth = SlideWidth;
    slideHeight = SlideHeight;
    Enabled = false;
    Time = 0;


    if (  m_xml.HasAttribute(ShapeNode,xmlCharStrdup("Left"))==true )
    {
        shapeLeft =  atof((char*)m_xml.GetAttribute(ShapeNode,xmlCharStrdup("Left")));
    }
    if (  m_xml.HasAttribute(ShapeNode,xmlCharStrdup("Top"))==true )
    {
        shapeTop =  atof((char*)m_xml.GetAttribute(ShapeNode,xmlCharStrdup("Top")));
    }
    if (  m_xml.HasAttribute(ShapeNode,xmlCharStrdup("Width"))==true )
    {
        shapeWidth =  atof((char*)m_xml.GetAttribute(ShapeNode,xmlCharStrdup("Width")));
    }
    if (  m_xml.HasAttribute(ShapeNode,xmlCharStrdup("Height"))==true )
    {
        shapeHeight =  atof((char*)m_xml.GetAttribute(ShapeNode,xmlCharStrdup("Height")));
    }


    if ( Paragraph==0 )
    {
        // 整個Shape的特效，沒有段落
        // 特效觸發的情況
        if (  m_xml.HasAttribute(AnimationSettingsNode,xmlCharStrdup("AdvanceMode"))==true )
        {
            long AdvanceMode = atol((char*) m_xml.GetAttribute(AnimationSettingsNode,xmlCharStrdup("AdvanceMode")));

            if ( AdvanceMode==ppAdvanceOnClick )
            {
                // 滑鼠點一下觸發
                Triggertype = msoAnimTriggerOnPageClick;
            }
            else if ( AdvanceMode==ppAdvanceOnTime )
            {
                // 特效在前一特效結束後，才觸發
                Triggertype = msoAnimTriggerAfterPrevious;

                if (  m_xml.HasAttribute(AnimationSettingsNode,xmlCharStrdup("AdvanceTime"))==true )
                {
                    // 延遲觸發的時間
                    Triggerdelaytime = atof((char*) m_xml.GetAttribute(AnimationSettingsNode,xmlCharStrdup("AdvanceTime")));
                }
            }
        }
    }
    else
    {
        // 有段落
        Triggertype = TriggleMode;

        if (  m_xml.HasAttribute(AnimationSettingsNode,xmlCharStrdup("AdvanceMode"))==true )
        {
            long AdvanceMode = atol((char*) m_xml.GetAttribute(AnimationSettingsNode,xmlCharStrdup("AdvanceMode")));

            if ( AdvanceMode==ppAdvanceOnTime )
            {
                if (  m_xml.HasAttribute(AnimationSettingsNode,xmlCharStrdup("AdvanceTime"))==true )
                {
                    // 延遲觸發的時間
                    Triggerdelaytime = atof((char*) m_xml.GetAttribute(AnimationSettingsNode,xmlCharStrdup("AdvanceTime")));
                }
            }
        }
    }


    // 動畫結束後的動作
    if (  m_xml.HasAttribute(AnimationSettingsNode,xmlCharStrdup("AfterEffect"))==true )
    {
        long AfterEffect = atol((char*) m_xml.GetAttribute(AnimationSettingsNode,xmlCharStrdup("AfterEffect")));

        if ( AfterEffect==ppAfterEffectDim )
        {
            m_AfterEffect = msoAnimAfterEffectDim;
        }
        else if ( AfterEffect==ppAfterEffectHide )
        {
            m_AfterEffect = msoAnimAfterEffectHide;
        }
        else if ( AfterEffect==ppAfterEffectHideOnClick )
        {
            m_AfterEffect = msoAnimAfterEffectHideOnNextClick;
        }
        else if ( AfterEffect==(long)ppAfterEffectMixed )
        {
            m_AfterEffect = msoAnimAfterEffectMixed;
        }
        else if ( AfterEffect==ppAfterEffectNothing )
        {
            m_AfterEffect = msoAnimAfterEffectNone;
        }
    }

    // 目前都一定會有的 Behavior 設定
    CBehavior *pBehavior = NULL;
    pBehavior = new CBehavior;
    pBehavior->m_Type       = 8;
    pBehavior->m_Accumulate = 1;
    pBehavior->m_Additive   = 1;

    pBehavior->setProperty  = 8;
    pBehavior->setTo        = 1;

    m_Behaviors.push_back(pBehavior);

    bool Warning = false;

    // 設定指定特效的個別參數
    switch ( AnimationSettingsType )
    {
        case ppEffectCut :  // 出現
            CreateEffectCut(AnimationSettingsNode);
            break;


        case ppEffectFlyFromBottom :    // 飛入-自底
            CreateEffectFlyFromBottom(AnimationSettingsNode);
            break;
        case ppEffectFlyFromLeft :     // 飛入-自左
            CreateEffectFlyFromLeft(AnimationSettingsNode);
            break;
        case ppEffectFlyFromRight :     // 飛入-自右
            CreateEffectFlyFromRight(AnimationSettingsNode);
            break;
        case ppEffectFlyFromTop :     // 飛入-自頂
            CreateEffectFlyFromTop(AnimationSettingsNode);
            break;
        case ppEffectFlyFromBottomLeft :     // 飛入-自左下
            CreateEffectFlyFromBottomLeft(AnimationSettingsNode);
            break;
        case ppEffectFlyFromBottomRight :     // 飛入-自右下
            CreateEffectFlyFromBottomRight(AnimationSettingsNode);
            break;
        case ppEffectFlyFromTopLeft :     // 飛入-自左上
            CreateEffectFlyFromTopLeft(AnimationSettingsNode);
            break;
        case ppEffectFlyFromTopRight :     // 飛入-自右上
            CreateEffectFlyFromTopRight(AnimationSettingsNode);
            break;


        case ppEffectBlindsHorizontal : // 百葉窗-水平
            CreateEffectBlindsHorizontal(AnimationSettingsNode);
            break;
        case ppEffectBlindsVertical : // 百葉窗-垂直
            CreateEffectBlindsVertical(AnimationSettingsNode);
            break;


        case ppEffectBoxIn :   // 盒狀-收縮
            CreateEffectBoxIn(AnimationSettingsNode);
            break;
        case ppEffectBoxOut :   // 盒狀-放射
            CreateEffectBoxOut(AnimationSettingsNode);
            break;


        case ppEffectCheckerboardAcross : // 棋盤式-橫向
            CreateEffectCheckerboardAcross(AnimationSettingsNode);
            break;
        case ppEffectCheckerboardDown : // 棋盤式-縱向
            CreateEffectCheckerboardDown(AnimationSettingsNode);
            break;


        case ppEffectCrawlFromDown :     // 慢速-自下
            CreateEffectCrawlFromDown(AnimationSettingsNode);
            break;
        case ppEffectCrawlFromLeft :     // 慢速-自左
            CreateEffectCrawlFromLeft(AnimationSettingsNode);
            break;
        case ppEffectCrawlFromRight :     // 慢速-自右
            CreateEffectCrawlFromRight(AnimationSettingsNode);
            break;
        case ppEffectCrawlFromUp :     // 慢速-自上
            CreateEffectCrawlFromUp(AnimationSettingsNode);
            break;


        case ppEffectDissolve  :  // 溶解
            CreateEffectDissolve(AnimationSettingsNode);
            break;


        case ppEffectFlashOnceFast  : // 閃爍一次-快速
            CreateEffectFlashOnceFast(AnimationSettingsNode);
            break;
        case ppEffectFlashOnceMedium : // 閃爍一次-中速
            CreateEffectFlashOnceMedium(AnimationSettingsNode);
            break;
        case ppEffectFlashOnceSlow : // 閃爍一次-慢速
            CreateEffectFlashOnceSlow(AnimationSettingsNode);
            break;


        case ppEffectPeekFromDown :     // 鑽入-自下
            CreateEffectPeekFromDown(AnimationSettingsNode);
            break;
        case ppEffectPeekFromLeft :     // 鑽入-自左
            CreateEffectPeekFromLeft(AnimationSettingsNode);
            break;
        case ppEffectPeekFromRight :     // 鑽入-自右
            CreateEffectPeekFromRight(AnimationSettingsNode);
            break;
        case ppEffectPeekFromUp :     // 鑽入-自上
            CreateEffectPeekFromUp(AnimationSettingsNode);
            break;


        case ppEffectRandomBarsHorizontal : // 隨機-水平
            CreateEffectRandomBarsHorizontal(AnimationSettingsNode);
            break;
        case ppEffectRandomBarsVertical : // 隨機-垂直
            CreateEffectRandomBarsVertical(AnimationSettingsNode);
            break;


        case ppEffectSpiral : // 螺旋
            CreateEffectSpiral(AnimationSettingsNode);
            break;


        case ppEffectSplitHorizontalIn : // 向中夾縮-水平
            CreateEffectSplitHorizontalIn(AnimationSettingsNode);
            break;
        case ppEffectSplitVerticalIn : // 向中夾縮-垂直
            CreateEffectSplitVerticalIn(AnimationSettingsNode);
            break;


        case ppEffectSplitHorizontalOut : // 向外擴張-水平
            CreateEffectSplitHorizontalOut(AnimationSettingsNode);
            break;
        case ppEffectSplitVerticalOut : // 向外擴張-垂直
            CreateEffectSplitVerticalOut(AnimationSettingsNode);
            break;


        case ppEffectStretchAcross : // 伸展-水平
            CreateEffectStretchAcross(AnimationSettingsNode);
            break;
        case ppEffectStretchDown : // 伸展-從下
            CreateEffectStretchDown(AnimationSettingsNode);
            break;
        case ppEffectStretchLeft : // 伸展-從左
            CreateEffectStretchLeft(AnimationSettingsNode);
            break;
        case ppEffectStretchRight : // 伸展-從右
            CreateEffectStretchRight(AnimationSettingsNode);
            break;
        case ppEffectStretchUp : // 伸展-從上
            CreateEffectStretchUp(AnimationSettingsNode);
            break;


        case ppEffectStripsLeftDown : // 階梯狀-左下
            CreateEffectStripsLeftDown(AnimationSettingsNode);
            break;
        case ppEffectStripsLeftUp : // 階梯狀-左上
            CreateEffectStripsLeftUp(AnimationSettingsNode);
            break;
        case ppEffectStripsRightDown : // 階梯狀-右下
            CreateEffectStripsRightDown(AnimationSettingsNode);
            break;
        case ppEffectStripsRightUp : // 階梯狀-右上
            CreateEffectStripsRightUp(AnimationSettingsNode);
            break;


        case ppEffectSwivel : // 旋轉
            CreateEffectSwivel(AnimationSettingsNode);
            break;


        case ppEffectWipeDown :     // 擦去-往下
            CreateEffectWipeDown(AnimationSettingsNode);
            break;
        case ppEffectWipeLeft :     // 擦去-往左
            CreateEffectWipeLeft(AnimationSettingsNode);
            break;
        case ppEffectWipeRight :     // 擦去-往右
            CreateEffectWipeRight(AnimationSettingsNode);
            break;
        case ppEffectWipeUp :     // 擦去-往上
            CreateEffectWipeUp(AnimationSettingsNode);
            break;


        case ppEffectZoomIn :     // 縮小-進入
            CreateEffectZoomIn(AnimationSettingsNode);
            break;
        case ppEffectZoomCenter :     // 縮小-從螢幕中央
            CreateEffectZoomCenter(AnimationSettingsNode);
            break;
        case ppEffectZoomInSlightly :     // 縮小-略微縮小
            CreateEffectZoomInSlightly(AnimationSettingsNode);
            break;


        case ppEffectZoomOut :     // 放大-推出
            CreateEffectZoomOut(AnimationSettingsNode);
            break;
        case ppEffectZoomBottom :     // 放大-從螢幕底
            CreateEffectZoomBottom(AnimationSettingsNode);
            break;
        case ppEffectZoomOutSlightly :     // 放大-略微放大
            CreateEffectZoomOutSlightly(AnimationSettingsNode);
            break;

        default :
            // 產生未定義的特效演員，使用淡出特效取代。
            Warning = true;
    }

    // 特效的總時間
    DelayTime = (unsigned long)(Triggerdelaytime*100);

    if ( Duration*100<1 )
    {
        TotalTime = (unsigned long)(Triggerdelaytime*100+1);
        DurationTime = 1;
    }
    else
    {
        TotalTime = (unsigned long)((Duration+Triggerdelaytime)*100);
        DurationTime = (unsigned long)Duration*100;
    }



    if ( Warning==true )
    {
        return ACTORACTION_CREATEWARNING;
    }

    return S_OK;
}

// 出現
HRESULT CActorAction::CreateEffectCut(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectAppear;
    Direction = msoAnimDirectionNone;

    return S_OK;
}

// 飛入-自底
HRESULT CActorAction::CreateEffectFlyFromBottom(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectFly;
    Direction = msoAnimDirectionDown;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 1;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_x", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_x", 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 2;
    pBehavior->m_Points.push_back(CreatePoint(1, "1+#ppt_h/2", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_y"    , 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;

}
// 飛入-自左
HRESULT CActorAction::CreateEffectFlyFromLeft(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectFly;
    Direction = msoAnimDirectionLeft;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 1;
    pBehavior->m_Points.push_back(CreatePoint(1, "0-#ppt_w/2", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_x"    , 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 2;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_y", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_y", 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 飛入-自右
HRESULT CActorAction::CreateEffectFlyFromRight(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectFly;
    Direction = msoAnimDirectionRight;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 1;
    pBehavior->m_Points.push_back(CreatePoint(1, "1+#ppt_w/2", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_x"    , 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 2;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_y", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_y", 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 飛入-自頂
HRESULT CActorAction::CreateEffectFlyFromTop(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectFly;
    Direction = msoAnimDirectionUp;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 1;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_x", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_x", 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 2;
    pBehavior->m_Points.push_back(CreatePoint(1, "0-#ppt_h/2", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_y", 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 飛入-自左下
HRESULT CActorAction::CreateEffectFlyFromBottomLeft(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectFly;
    Direction = msoAnimDirectionDownLeft;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 1;
    pBehavior->m_Points.push_back(CreatePoint(1, "0-#ppt_w/2", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_x"    , 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 2;
    pBehavior->m_Points.push_back(CreatePoint(1, "1+#ppt_h/2", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_y", 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 飛入-自右下
HRESULT CActorAction::CreateEffectFlyFromBottomRight(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectFly;
    Direction = msoAnimDirectionDownRight;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 1;
    pBehavior->m_Points.push_back(CreatePoint(1, "1+#ppt_w/2", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_x"    , 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 2;
    pBehavior->m_Points.push_back(CreatePoint(1, "1+#ppt_h/2", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_y", 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 飛入-自左上
HRESULT CActorAction::CreateEffectFlyFromTopLeft(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectFly;
    Direction = msoAnimDirectionUpLeft;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 1;
    pBehavior->m_Points.push_back(CreatePoint(1, "0-#ppt_w/2", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_x"    , 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 2;
    pBehavior->m_Points.push_back(CreatePoint(1, "0-#ppt_h/2", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_y", 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 飛入-自右上
HRESULT CActorAction::CreateEffectFlyFromTopRight(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectFly;
    Direction = msoAnimDirectionUpRight;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 1;
    pBehavior->m_Points.push_back(CreatePoint(1, "1+#ppt_w/2", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_x"    , 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 2;
    pBehavior->m_Points.push_back(CreatePoint(1, "0-#ppt_h/2", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_y", 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}

// 百葉窗-水平
HRESULT CActorAction::CreateEffectBlindsHorizontal(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectBlinds;
    Direction = msoAnimDirectionHorizontal;
    Duration = 0.5;

    CBehavior *pBehavior = NULL;

    // 第一個 FilterEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 2;
    pBehavior->filterSubType = 5;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;

}
// 百葉窗-垂直
HRESULT CActorAction::CreateEffectBlindsVertical(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectBlinds;
    Direction = msoAnimDirectionVertical;
    Duration = 0.5;

    CBehavior *pBehavior = NULL;

    // 第一個 FilterEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 2;
    pBehavior->filterSubType = 6;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}

// 盒狀-收縮
HRESULT CActorAction::CreateEffectBoxIn(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectBox;
    Direction = msoAnimDirectionIn;
    Duration = 0.5;

    CBehavior *pBehavior = NULL;

    // 第一個 FilterEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 3;
    pBehavior->filterSubType = 7;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 盒狀-放射
HRESULT CActorAction::CreateEffectBoxOut(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectBox;
    Direction = msoAnimDirectionOut;
    Duration = 0.5;

    CBehavior *pBehavior = NULL;

    // 第一個 FilterEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 3;
    pBehavior->filterSubType = 8;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}

// 棋盤式-橫向
HRESULT CActorAction::CreateEffectCheckerboardAcross(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectCheckerboard;
    Direction = msoAnimDirectionHorizontal;
    Duration = 0.5;

    CBehavior *pBehavior = NULL;

    // 第一個 FilterEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 4;
    pBehavior->filterSubType = 9;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 棋盤式-縱向
HRESULT CActorAction::CreateEffectCheckerboardDown(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectCheckerboard;
    Direction = msoAnimDirectionVertical;
    Duration = 0.5;

    CBehavior *pBehavior = NULL;

    // 第一個 FilterEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 4;
    pBehavior->filterSubType = 25;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}

// 慢速-自下
HRESULT CActorAction::CreateEffectCrawlFromDown(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectCrawl;
    Direction = msoAnimDirectionDown;
    Duration = 5;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 1;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_x", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_x", 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 2;
    pBehavior->m_Points.push_back(CreatePoint(1, "1+#ppt_h/2", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_y", 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 慢速-自左
HRESULT CActorAction::CreateEffectCrawlFromLeft(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectCrawl;
    Direction = msoAnimDirectionLeft;
    Duration = 5;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 1;
    pBehavior->m_Points.push_back(CreatePoint(1, "0-#ppt_w/2", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_x"    , 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 2;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_y", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_y", 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 慢速-自右
HRESULT CActorAction::CreateEffectCrawlFromRight(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectCrawl;
    Direction = msoAnimDirectionRight;
    Duration = 5;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 1;
    pBehavior->m_Points.push_back(CreatePoint(1, "1+#ppt_w/2", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_x", 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 2;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_y", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_y", 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 慢速-自上
HRESULT CActorAction::CreateEffectCrawlFromUp(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectCrawl;
    Direction = msoAnimDirectionUp;
    Duration = 5;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 1;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_x", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_x", 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 2;
    pBehavior->m_Points.push_back(CreatePoint(1, "0-#ppt_h/2", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_y"    , 1));

    m_Behaviors.push_back(pBehavior);


    return S_OK;
}

// 溶解
HRESULT CActorAction::CreateEffectDissolve(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectDissolve;
    Direction = msoAnimDirectionNone;
    Duration = 0.5;

    CBehavior *pBehavior = NULL;

    // 第一個 FilterEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 7;
    pBehavior->filterSubType = 0;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}

// 閃爍一次-快速
HRESULT CActorAction::CreateEffectFlashOnceFast(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectFlashOnce;
    Direction = msoAnimDirectionNone;
    Duration = 0.25;

    return S_OK;
}
// 閃爍一次-中速
HRESULT CActorAction::CreateEffectFlashOnceMedium(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectFlashOnce;
    Direction = msoAnimDirectionNone;
    Duration = 0.5;

    return S_OK;
}
// 閃爍一次-慢速
HRESULT CActorAction::CreateEffectFlashOnceSlow(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectFlashOnce;
    Direction = msoAnimDirectionNone;
    Duration = 1;

    return S_OK;
}

// 鑽入-自下
HRESULT CActorAction::CreateEffectPeekFromDown(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectPeek;
    Direction = msoAnimDirectionDown;

    CBehavior *pBehavior = NULL;

    // 第一個 FilterEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 13;
    pBehavior->filterSubType = 13;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 鑽入-自左
HRESULT CActorAction::CreateEffectPeekFromLeft(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectPeek;
    Direction = msoAnimDirectionLeft;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 13;
    pBehavior->filterSubType = 10;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;

}
// 鑽入-自右
HRESULT CActorAction::CreateEffectPeekFromRight(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectPeek;
    Direction = msoAnimDirectionRight;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 13;
    pBehavior->filterSubType = 11;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 鑽入-自上
HRESULT CActorAction::CreateEffectPeekFromUp(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectPeek;
    Direction = msoAnimDirectionUp;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 13;
    pBehavior->filterSubType = 12;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}

// 隨機-水平
HRESULT CActorAction::CreateEffectRandomBarsHorizontal(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectRandomBars;
    Direction = msoAnimDirectionHorizontal;
    Duration = 0.5;

    CBehavior *pBehavior = NULL;

    // 第一個 FilterEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 12;
    pBehavior->filterSubType = 5;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 隨機-垂直
HRESULT CActorAction::CreateEffectRandomBarsVertical(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectRandomBars;
    Direction = msoAnimDirectionVertical;
    Duration = 0.5;

    CBehavior *pBehavior = NULL;

    // 第一個 FilterEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 12;
    pBehavior->filterSubType = 6;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}

// 螺旋
HRESULT CActorAction::CreateEffectSpiral(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectSpiral;
    Direction = msoAnimDirectionNone;
    Duration = 1;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 3;
    pBehavior->m_Points.push_back(CreatePoint(1, "0"     , 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_w", 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 4;
    pBehavior->m_Points.push_back(CreatePoint(1, "0"     , 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_h", 1));

    m_Behaviors.push_back(pBehavior);

    // 第三個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 1;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_x+(cos(-2*pi*(1-$))*-#ppt_x-sin(-2*pi*(1-$))*(1-#ppt_y))*(1-$)", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "1"                                                                  , 1));

    m_Behaviors.push_back(pBehavior);


    // 第四個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 2;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_y+(sin(-2*pi*(1-$))*-#ppt_x+cos(-2*pi*(1-$))*(1-#ppt_y))*(1-$)", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "1"                                                                  , 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}

// 向中夾縮-水平
HRESULT CActorAction::CreateEffectSplitHorizontalIn(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectSplit;
    Direction = msoAnimDirectionHorizontalIn;
    Duration = 0.5;

    CBehavior *pBehavior = NULL;

    // 第一個 FilterEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 1;
    pBehavior->filterSubType = 3;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 向中夾縮-垂直
HRESULT CActorAction::CreateEffectSplitVerticalIn(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectSplit;
    Direction = msoAnimDirectionVerticalIn;
    Duration = 0.5;

    CBehavior *pBehavior = NULL;

    // 第一個 FilterEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 1;
    pBehavior->filterSubType = 1;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}

// 向外擴張-水平
HRESULT CActorAction::CreateEffectSplitHorizontalOut(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectSplit;
    Direction = msoAnimDirectionHorizontalOut;
    Duration = 0.5;

    CBehavior *pBehavior = NULL;

    // 第一個 FilterEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 1;
    pBehavior->filterSubType = 4;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 向外擴張-垂直
HRESULT CActorAction::CreateEffectSplitVerticalOut(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectSplit;
    Direction = msoAnimDirectionVerticalOut;
    Duration = 0.5;

    CBehavior *pBehavior = NULL;

    // 第一個 FilterEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 1;
    pBehavior->filterSubType = 2;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}

// 伸展-水平
HRESULT CActorAction::CreateEffectStretchAcross(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectStretch;
    Direction = msoAnimDirectionHorizontal;
    Duration = 1;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 3;
    pBehavior->m_Points.push_back(CreatePoint(1, "0"     , 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_w", 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 4;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_h", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_h", 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 伸展-從下
HRESULT CActorAction::CreateEffectStretchDown(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectStretch;
    Direction = msoAnimDirectionDown;
    Duration = 1;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 1;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_x", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_x", 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 2;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_y+#ppt_h/2", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_y"         , 1));

    m_Behaviors.push_back(pBehavior);

    // 第三個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 3;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_w", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_w", 1));

    m_Behaviors.push_back(pBehavior);


    // 第四個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 4;
    pBehavior->m_Points.push_back(CreatePoint(1, "0"     , 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_h", 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 伸展-從左
HRESULT CActorAction::CreateEffectStretchLeft(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectStretch;
    Direction = msoAnimDirectionLeft;
    Duration = 1;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 1;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_x-#ppt_w/2", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_x"         , 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 2;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_y", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_y", 1));

    m_Behaviors.push_back(pBehavior);

    // 第三個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 3;
    pBehavior->m_Points.push_back(CreatePoint(1, "0"     , 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_w", 1));

    m_Behaviors.push_back(pBehavior);


    // 第四個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 4;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_h", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_h", 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 伸展-從右
HRESULT CActorAction::CreateEffectStretchRight(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectStretch;
    Direction = msoAnimDirectionRight;
    Duration = 1;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 1;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_x+#ppt_w/2", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_x"         , 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 2;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_y", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_y", 1));

    m_Behaviors.push_back(pBehavior);

    // 第三個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 3;
    pBehavior->m_Points.push_back(CreatePoint(1, "0"     , 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_w", 1));

    m_Behaviors.push_back(pBehavior);


    // 第四個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 4;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_h", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_h", 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 伸展-從上
HRESULT CActorAction::CreateEffectStretchUp(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectStretch;
    Direction = msoAnimDirectionUp;
    Duration = 1;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 1;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_x", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_x", 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 2;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_y-#ppt_h/2", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_y"         , 1));

    m_Behaviors.push_back(pBehavior);

    // 第三個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 3;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_w", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_w", 1));

    m_Behaviors.push_back(pBehavior);


    // 第四個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 4;
    pBehavior->m_Points.push_back(CreatePoint(1, "0"     , 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_h", 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}


// 階梯狀-左下
HRESULT CActorAction::CreateEffectStripsLeftDown(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectStrips;
    Direction = msoAnimDirectionDownLeft;
    Duration = 0.5;

    CBehavior *pBehavior = NULL;

    // 第一個 FilterEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 15;
    pBehavior->filterSubType = 14;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 階梯狀-左上
HRESULT CActorAction::CreateEffectStripsLeftUp(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectStrips;
    Direction = msoAnimDirectionUpLeft;
    Duration = 0.5;

    CBehavior *pBehavior = NULL;

    // 第一個 FilterEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 15;
    pBehavior->filterSubType = 15;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 階梯狀-右下
HRESULT CActorAction::CreateEffectStripsRightDown(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectStrips;
    Direction = msoAnimDirectionDownRight;
    Duration = 0.5;

    CBehavior *pBehavior = NULL;

    // 第一個 FilterEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 15;
    pBehavior->filterSubType = 16;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 階梯狀-右上
HRESULT CActorAction::CreateEffectStripsRightUp(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectStrips;
    Direction = msoAnimDirectionUpRight;
    Duration = 0.5;

    CBehavior *pBehavior = NULL;

    // 第一個 FilterEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 15;
    pBehavior->filterSubType = 17;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}

// 旋轉
HRESULT CActorAction::CreateEffectSwivel(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectSwivel;
    Direction = msoAnimDirectionHorizontal;
    Duration = 5;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 3;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_w*sin(2.5*pi*$)", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "1"                   , 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 4;
    pBehavior->m_Points.push_back(CreatePoint(1, "#ppt_h", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_h", 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}




// 擦去-往下
HRESULT CActorAction::CreateEffectWipeDown(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectWipe;
    Direction = msoAnimDirectionUp;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 18;
    pBehavior->filterSubType = 26;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 擦去-往左
HRESULT CActorAction::CreateEffectWipeLeft(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectWipe;
    Direction = msoAnimDirectionRight;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 18;
    pBehavior->filterSubType = 24;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 擦去-往右
HRESULT CActorAction::CreateEffectWipeRight(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectWipe;
    Direction = msoAnimDirectionLeft;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 18;
    pBehavior->filterSubType = 23;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 擦去-往上
HRESULT CActorAction::CreateEffectWipeUp(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectWipe;
    Direction = msoAnimDirectionDown;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(7, 1, 1);

    pBehavior->filterType = 18;
    pBehavior->filterSubType = 25;
    pBehavior->filterReveal = -1;

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}

// 縮小-進入
HRESULT CActorAction::CreateEffectZoomIn(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectZoom;
    Direction = msoAnimDirectionIn;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 3;
    pBehavior->m_Points.push_back(CreatePoint(1, "0"     , 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_w", 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 4;
    pBehavior->m_Points.push_back(CreatePoint(1, "0"     , 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_h", 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 縮小-從螢幕中央
HRESULT CActorAction::CreateEffectZoomCenter(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectZoom;
    Direction = msoAnimDirectionInCenter;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 3;
    pBehavior->m_Points.push_back(CreatePoint(1, "0"     , 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_w", 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 4;
    pBehavior->m_Points.push_back(CreatePoint(1, "0"     , 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_h", 1));

    m_Behaviors.push_back(pBehavior);


    // 第三個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 1;
    pBehavior->m_Points.push_back(CreatePoint(1, "0.5"   , 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_x", 1));

    m_Behaviors.push_back(pBehavior);


    // 第四個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 2;
    pBehavior->m_Points.push_back(CreatePoint(1, "0.5"   , 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_y", 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 縮小-略微縮小
HRESULT CActorAction::CreateEffectZoomInSlightly(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectZoom;
    Direction = msoAnimDirectionInSlightly;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 3;
    pBehavior->m_Points.push_back(CreatePoint(1, "2/3*#ppt_w", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_w"    , 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 4;
    pBehavior->m_Points.push_back(CreatePoint(1, "2/3*#ppt_h", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_h"    , 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}

// 放大-推出
HRESULT CActorAction::CreateEffectZoomOut(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectZoom;
    Direction = msoAnimDirectionOut;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 3;
    pBehavior->m_Points.push_back(CreatePoint(1, "4*#ppt_w", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_w"  , 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 4;
    pBehavior->m_Points.push_back(CreatePoint(1, "4*#ppt_h", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_h"  , 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 放大-從螢幕底端
HRESULT CActorAction::CreateEffectZoomBottom(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectZoom;
    Direction = msoAnimDirectionOutBottom;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 3;
    pBehavior->m_Points.push_back(CreatePoint(1, "(6*min(max(#ppt_w*#ppt_h,.3),1)-7.4)/-.7*#ppt_w", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_w"                                         , 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 4;
    pBehavior->m_Points.push_back(CreatePoint(1, "(6*min(max(#ppt_w*#ppt_h,.3),1)-7.4)/-.7*#ppt_h", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_h"                                         , 1));

    m_Behaviors.push_back(pBehavior);


    // 第三個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 1;
    pBehavior->m_Points.push_back(CreatePoint(1, "0.5"   , 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_x", 1));

    m_Behaviors.push_back(pBehavior);


    // 第四個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 2;
    pBehavior->m_Points.push_back(CreatePoint(1, "1+(6*min(max(#ppt_w*#ppt_h,.3),1)-7.4)/-.7*#ppt_h/2", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_y"                                             , 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}
// 放大-略微放大
HRESULT CActorAction::CreateEffectZoomOutSlightly(xmlNodePtr AnimationSettingsNode)
{
    Type = msoAnimEffectZoom;
    Direction = msoAnimDirectionOutSlightly;

    CBehavior *pBehavior = NULL;

    // 第一個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 3;
    pBehavior->m_Points.push_back(CreatePoint(1, "4/3*#ppt_w", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_w"    , 1));

    m_Behaviors.push_back(pBehavior);


    // 第二個 PropertyEffect
    pBehavior = CreateBehavior(5, 1, 1);

    pBehavior->proProperty  = 4;
    pBehavior->m_Points.push_back(CreatePoint(1, "4/3*#ppt_h", 0));
    pBehavior->m_Points.push_back(CreatePoint(2, "#ppt_h"    , 1));

    m_Behaviors.push_back(pBehavior);

    return S_OK;
}


long m_Type;
    long m_Accumulate;
    long m_Additive;


CBehavior* CActorAction::CreateBehavior(long BType, long BAccumulate, long BAdditive)
{
    CBehavior *pBehavior = new CBehavior;
    pBehavior->m_Type       = BType;
    pBehavior->m_Accumulate = BAccumulate;
    pBehavior->m_Additive   = BAdditive;
    return pBehavior;

}

ActorPointPtr CActorAction::CreatePoint(long Index, string Value, double Time)
{
    ActorPointPtr PointPtr = new ActorPoint;
    PointPtr->index = Index;
    PointPtr->value = Value;
    PointPtr->time = Time;
    return PointPtr;
}
