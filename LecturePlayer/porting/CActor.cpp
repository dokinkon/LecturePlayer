//---------------------------------------------------------------------------
#include "CActor.h"
#include "BWStringTool.h"
#include "BWFileManagerTool.h"
//---------------------------------------------------------------------------
CActor::CActor()
{
    Visible = true;
    Enabled = false;
    m_X = 0;
    m_Y = 0;
    m_ImageX = 0;
    m_ImageY = 0;
    m_ImageWidth = 720;
    m_ImageHeight = 540;
    m_HaveEffect = false;
    m_ZOrderPosition = -1;
    textColorRGB[0] = 255;
    textColorRGB[1] = 255;
    textColorRGB[2] = 255;
    //m_NeedRefresh = false;
    m_IsActing = false;
    m_MediaFileName.clear();
    ClearActionSettings();

    // 預設演員允許超連結動作，但遇到不支援的影片或聲音演員，則不允許超連結動作
    m_ActionSettingsEnabled = true;


    // 預設為普通演員
    m_ActorType = ActorType_Normal;
    m_MediaActorState = MediaActorState_Stop;

    m_MediaGotoTime = false;
    m_MediaGotoTimeFinish = false;
    m_MediaActorRefresh = false;

}
//---------------------------------------------------------------------------
CActor::~CActor()
{
    m_ActorRenderInfo.clear();
    m_SubRenderInfo.clear();
}
//---------------------------------------------------------------------------

void CActor::ClearActorRenderInfo(void)
{
    if ( !m_ActorRenderInfo.empty() )
    {
        m_ActorRenderInfo.erase(m_ActorRenderInfo.begin(), m_ActorRenderInfo.end());
    }
}
//---------------------------------------------------------------------------
HRESULT CActor::LoadStaticImage(const char *pName, const char *pFile, int Width, int Height)
{
    HRESULT hr = S_OK;

    m_ZOrderPosition = 0;

    ActorName = string(pName);
    m_ImageFileName = string(pFile);

    type = 1;
    m_HaveEffect = false;

    m_X = 0;
    m_Y = 0;
    m_Width = Width;
    m_Height = Height;

    m_ImageX = 0;
    m_ImageY = 0;
    m_ImageWidth = m_Width;
    m_ImageHeight = m_Height;

    m_Rotation = 0;

    // 填入顯示用的資訊
    m_ImageRect[0][0] = m_ImageX;
    m_ImageRect[0][1] = m_ImageY;
    m_ImageRect[1][0] = m_ImageX + m_ImageWidth;
    m_ImageRect[1][1] = m_ImageY;
    m_ImageRect[2][0] = m_ImageX + m_ImageWidth;
    m_ImageRect[2][1] = m_ImageY + m_ImageHeight;
    m_ImageRect[3][0] = m_ImageX;
    m_ImageRect[3][1] = m_ImageY + m_ImageHeight;

    hr = InitRenderInfo();

    return hr;
}
//---------------------------------------------------------------------------
HRESULT CActor::LoadPPTShape(xmlNodePtr ShapeNode, string LoadFilePath)
{
    LOGD("int CActor::LoadPPTShape");

    HRESULT hr = S_OK;

    hr = LoadBaseInfo(ShapeNode);

    LOGD("after LoadBaseInfo(ShapeNode);");


    //if ( FAILED(hr) )
    if(hr!=S_OK)
    {
        return E_FAIL;
    }

    hr = LoadImageInfo(ShapeNode, LoadFilePath);

    LOGD("after LoadImageInfo(ShapeNode, LoadFilePath); ");

    if(hr!=S_OK)
    {
        return E_FAIL;
    }


    hr = DetermineActionSettingsEnabled(ShapeNode);

    LOGD("after DetermineActionSettingsEnabled(ShapeNode); ");
    // 此處不用判斷是否允許使用多媒體演員
    hr = LoadMediaInfo(ShapeNode);

    LOGD("after LoadMediaInfo(ShapeNode); ");


    hr = LoadShapeActionSettingsInfo(ShapeNode);
    LOGD("after LoadShapeActionSettingsInfo(ShapeNode); ");

    hr = LoadTextFrameInfo(ShapeNode);
    LOGD("after LoadTextFrameInfo(ShapeNode);");
    hr = LoadGroupShapesInfo(ShapeNode);
    LOGD("after LoadGroupShapesInfo(ShapeNode) ");
    hr = InitRenderInfo();
    LOGD("after InitRenderInfo();");

    return S_OK;
}

//---------------------------------------------------------------------------
void CActor::GetRGBvalue(string HexValue, int RGB[])
{
    char *color = (char*)HexValue.c_str() ;
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
//----------------------------------------------------------------------
bool CActor::ClearActionSettings(void)
{
    m_MCActionSettingAction.clear();
    m_MCHyperlinkSlideID.clear();
    m_MCURL.clear();
    m_ActionSettingSenseRect.clear();
    return true;
}
bool CActor::AddActionSettings(xmlNodePtr ActionSettingsNode)
{
    bool Result = false;
    char* temp=new char[1024];

    if ( m_ActionSettingsEnabled==false )
    {
        return Result;
    }

    int     MCActionSettingAction = 0;
    int     MCHyperlinkSlideID = -1;
    string MCURL = string("");

    for ( int index=0 ; index< m_xml.CountChildNode(ActionSettingsNode) ; index++ )
    {
        xmlNodePtr ActionSettingNode =  m_xml.FindChildIndex(ActionSettingsNode,index);

        int MouseActivation;

        if (  m_xml.HasAttribute(ActionSettingNode,xmlCharStrdup("MouseActivation")) )
        {
            //MouseActivation = ActionSettingNode->m_xml.GetAttribute(L"MouseActivation");
            temp=(char*)( m_xml.GetAttribute(ActionSettingNode,xmlCharStrdup("MouseActivation")));
            MouseActivation = atoi(temp);

            // 判斷 MouseActivation 是否為 Mouse Click.
            if ( MouseActivation==1 )
            {
                // Mouse Click

                if (  m_xml.HasAttribute(ActionSettingNode,xmlCharStrdup("Action")) )
                {
                    //MCActionSettingAction = ActionSettingNode->m_xml.GetAttribute(L"Action");
                    temp=(char*)( m_xml.GetAttribute(ActionSettingNode,xmlCharStrdup("Action")));
                    MCActionSettingAction = atoi(temp);

                    if(MCActionSettingAction == 0)
                    {
                        //ppActionNone  0
                        // 動作設定為0，所以離開
                        continue;
                    }
                }

                // 開啟外部檔案及巨集，檔案名稱及巨集名稱記錄在 Run 屬性
                if ( MCActionSettingAction==9 &&  m_xml.HasAttribute(ActionSettingNode,xmlCharStrdup("Run")))
                {
                     MCURL= string((char*)( m_xml.GetAttribute(ActionSettingNode,xmlCharStrdup("Run"))));

                }

                // 取出 Hyperlink 的資料
                //xmlNodePtr HyperlinkNode = ActionSettingNode->ChildNodes->FindNode(L"Hyperlink");
                xmlNodePtr HyperlinkNode =  m_xml.FindChildNode(ActionSettingNode,xmlCharStrdup("Hyperlink"));

                if ( HyperlinkNode!=NULL )
                {
                    if (  m_xml.HasAttribute(HyperlinkNode,xmlCharStrdup("SubAddress")) )
                    {
                        string SubAddress = string((char*)( m_xml.GetAttribute(HyperlinkNode,xmlCharStrdup("SubAddress"))));
                        string Item[3];

                        if ( ParserHyperlinkSubAddress(SubAddress, Item) == true)
                        {
                            MCHyperlinkSlideID = atoi(Item[0].c_str());
                        }
                    }

                    // 連結外部網頁，網址紀錄在 Hyperlink->Address，在講解手內部使用 m_MCURL 變數紀錄
                    if ( MCActionSettingAction==7 &&  m_xml.HasAttribute(HyperlinkNode,xmlCharStrdup("Address")) )
                    {
                        MCURL = string((char*)( m_xml.GetAttribute(HyperlinkNode,xmlCharStrdup("Address"))));
                    }
                }


                // 如果有動作設定的話，將動作加到Actor的設定中
                if(MCActionSettingAction != 0)
                {
                    m_MCActionSettingAction.push_back(MCActionSettingAction);
                    m_MCHyperlinkSlideID.push_back(MCHyperlinkSlideID);
                    m_MCURL.push_back(MCURL);

                    Result = true;
                }
            }
        }
    }

    return Result;
}

bool CActor::ParserHyperlinkSubAddress( string SubAddress, string Item[3])
{

    //if(SubAddress == NULL)
    if(SubAddress == "")
    {
        return false;
    }


    char seps[] = ",";
    char *SubString;
    int     index = 0;

    SubString = strtok((char*)SubAddress.c_str(), seps);

    while(SubString != NULL)
    {
        string Para = string(SubString);
        if ( !Para.empty() )
        {
            Item[index] = Para;
            index++;
        }
        SubString = strtok(NULL, seps);
    };

    if ( index!=3 )
    {
        return false;
    }
    return true;
}

bool CActor::Inside(int x, int y, unsigned int &ActionSettingIndex)
{
    for ( unsigned int index=0 ; index<m_ActionSettingSenseRect.size() ; index++ )
    {
        RECT rect = m_ActionSettingSenseRect[index];
        if ( ( x>=rect.left && x<=rect.right ) && ( y>=rect.top && y<=rect.bottom ) )
        {
            int dx = x - m_X;
            int dy = y - m_Y;

            for ( unsigned int index1=0 ; index1<m_ActorRenderInfo.size() ; index1++ )
            {
                if ( m_ActorRenderInfo[index1].Inside(dx, dy) )
                {
                    ActionSettingIndex = index;
                    return true;
                }
            }

        }
    }

    return false;
}

bool CActor::HasMCAction(void)
{
    if ( m_MCActionSettingAction.empty() )
    {
        return false;
    }

    return true;
}

//---------------------------------------------------------------------------
// 重設顯示區塊的特效是否完成。
void CActor::DetermineActionFinish(void)
{
    int size = m_ActorRenderInfo.size();

    for ( int index=0 ; index<size ; index++ )
    {
        CActorRenderInfo renderInfo = m_ActorRenderInfo[index];
        bool ActionFinish = m_ActorRenderInfo[index].m_ActionFinish;
        bool EnterFinish = m_ActorRenderInfo[index].m_EnterFinish;
        bool PathFinish = m_ActorRenderInfo[index].m_PathFinish;
        bool EnterAction = m_ActorRenderInfo[index].m_EnterAction;
        bool PathAction = m_ActorRenderInfo[index].m_PathAction;
        bool ExitAction = m_ActorRenderInfo[index].m_ExitAction;

        if ( ActionFinish==false && EnterFinish==true && PathAction==false && ExitAction==false )
        {
            m_ActorRenderInfo[index].m_ActionFinish = true;
        }
        else if ( ActionFinish==false && EnterAction==false && PathFinish==true && ExitAction==false )
        {
            m_ActorRenderInfo[index].m_ActionFinish = true;
        }
        else if ( ActionFinish==false && EnterFinish==true && PathFinish==true && ExitAction==false )
        {
            m_ActorRenderInfo[index].m_ActionFinish = true;
        }
    }
}
//---------------------------------------------------------------------------
// 重設顯示區塊的特效更新預設參數。
void CActor::ResetActionRefresh(void)
{
    for ( unsigned int index=0 ; index<m_ActorRenderInfo.size() ; index++ )
    {
        m_ActorRenderInfo[index].m_EnterAction = false;
        m_ActorRenderInfo[index].m_ExitAction = false;
        m_ActorRenderInfo[index].m_PathAction = false;

        m_ActorRenderInfo[index].m_EnterFinish = false;
        m_ActorRenderInfo[index].m_ExitFinish = false;
        m_ActorRenderInfo[index].m_PathFinish = false;
    }
}
void CActor::SetActionFinish(bool Finish)
{
    for ( unsigned int index=0 ; index<m_ActorRenderInfo.size() ; index++ )
    {
        m_ActorRenderInfo[index].m_ActionFinish = Finish;
    }
}
//---------------------------------------------------------------------------
HRESULT CActor::RenderInfo_Reset(void)
{
    m_ActorRenderInfo.clear();

    CActorRenderInfo ActorRenderInfo;
    ActorRenderInfo.Actor[0][0] = m_ImageRect[0][0];
    ActorRenderInfo.Actor[0][1] = m_ImageRect[0][1];
    ActorRenderInfo.Actor[1][0] = m_ImageRect[1][0];
    ActorRenderInfo.Actor[1][1] = m_ImageRect[1][1];
    ActorRenderInfo.Actor[2][0] = m_ImageRect[2][0];
    ActorRenderInfo.Actor[2][1] = m_ImageRect[2][1];
    ActorRenderInfo.Actor[3][0] = m_ImageRect[3][0];
    ActorRenderInfo.Actor[3][1] = m_ImageRect[3][1];
    ActorRenderInfo.OriActor[0][0] = m_ImageRect[0][0];
    ActorRenderInfo.OriActor[0][1] = m_ImageRect[0][1];
    ActorRenderInfo.OriActor[1][0] = m_ImageRect[1][0];
    ActorRenderInfo.OriActor[1][1] = m_ImageRect[1][1];
    ActorRenderInfo.OriActor[2][0] = m_ImageRect[2][0];
    ActorRenderInfo.OriActor[2][1] = m_ImageRect[2][1];
    ActorRenderInfo.OriActor[3][0] = m_ImageRect[3][0];
    ActorRenderInfo.OriActor[3][1] = m_ImageRect[3][1];
    ActorRenderInfo.TextActor[0][0] = m_ImageRect[0][0];
    ActorRenderInfo.TextActor[0][1] = m_ImageRect[0][1];
    ActorRenderInfo.TextActor[1][0] = m_ImageRect[1][0];
    ActorRenderInfo.TextActor[1][1] = m_ImageRect[1][1];
    ActorRenderInfo.TextActor[2][0] = m_ImageRect[2][0];
    ActorRenderInfo.TextActor[2][1] = m_ImageRect[2][1];
    ActorRenderInfo.TextActor[3][0] = m_ImageRect[3][0];
    ActorRenderInfo.TextActor[3][1] = m_ImageRect[3][1];

    ActorRenderInfo.TextureX = 0.0;
    ActorRenderInfo.TextureY = 0.0;
    ActorRenderInfo.TextureWidth = 1.0;
    ActorRenderInfo.TextureHeight = 1.0;
    ActorRenderInfo.OriTextureX = 0.0;
    ActorRenderInfo.OriTextureY = 0.0;
    ActorRenderInfo.OriTextureWidth = 1.0;
    ActorRenderInfo.OriTextureHeight = 1.0;
    ActorRenderInfo.TextTextureX = 0.0;
    ActorRenderInfo.TextTextureY = 0.0;
    ActorRenderInfo.TextTextureWidth = 1.0;
    ActorRenderInfo.TextTextureHeight = 1.0;
    ActorRenderInfo.Rotation = 0;
    ActorRenderInfo.Red = 1.0;
    ActorRenderInfo.Green = 1.0;
    ActorRenderInfo.Blue = 1.0;
    ActorRenderInfo.Alpha = 1.0;
    m_ActorRenderInfo.push_back(ActorRenderInfo);

    return S_OK;
}

bool CActor::GetRenderInfo(long Paragraph, vector<CActorRenderInfo> &RenderInfo)
{
    RenderInfo.clear();

    vector<CActorRenderInfo>::iterator iter;

    for ( iter=m_ActorRenderInfo.begin() ; iter!=m_ActorRenderInfo.end() ; iter++ )
    {
        if ( (*iter).Paragraph==Paragraph )
        {
            // 取得同ㄧ Paragraph 的 Render information。
            RenderInfo.push_back(*iter);
        }
    }

    if ( RenderInfo.size()==0 )
        return false;
    return true;
}


HRESULT CActor::LoadBaseInfo(xmlNodePtr ShapeNode)
{	LOGD("***************in  LoadBaseInfo 0");
    char* temp = new char[1024];
    if (  m_xml.HasAttribute(ShapeNode,xmlCharStrdup("Name"))==false )
    {
        return E_FAIL;
    }
    string ShapeName = string((char*)( m_xml.GetAttribute(ShapeNode,xmlCharStrdup("Name"))));
    ActorName = ShapeName;

    if (  m_xml.HasAttribute(ShapeNode,xmlCharStrdup("Type"))==false )
    {
        return E_FAIL;
    }
    temp = (char*)( m_xml.GetAttribute(ShapeNode,xmlCharStrdup("Type")));
    type = atoi(temp);

    if (  m_xml.HasAttribute(ShapeNode,xmlCharStrdup("ZOrderPosition"))==true )
    {
        temp= (char*)( m_xml.GetAttribute(ShapeNode,xmlCharStrdup("ZOrderPosition")));
        m_ZOrderPosition = atoi(temp);
    }

	LOGD("***************in  LoadBaseInfo 1");

    m_X = 0;
    m_Y = 0;
    m_Width = 720;
    m_Height = 540;
    m_Rotation = 0;


    if (  m_xml.HasAttribute(ShapeNode,xmlCharStrdup("Left"))==false )
    {
        return E_FAIL;
    }
    temp = (char*)( m_xml.GetAttribute(ShapeNode,xmlCharStrdup("Left")));
    m_X = atoi(temp);

	LOGD("***************in  LoadBaseInfo 2");

    if (  m_xml.HasAttribute(ShapeNode,xmlCharStrdup("Top"))==false )
    {
        return E_FAIL;
    }
    //m_Y = ShapeNode->m_xml.GetAttribute(L"Top");
    temp = (char*)( m_xml.GetAttribute(ShapeNode,xmlCharStrdup("Top")));
    m_Y = atoi(temp);

LOGD("***************in  LoadBaseInfo 3");
    if (  m_xml.HasAttribute(ShapeNode,xmlCharStrdup("Width"))==false )
    {
        return E_FAIL;
    }
    //m_Width = ShapeNode->m_xml.GetAttribute(L"Width");
    temp = (char*)( m_xml.GetAttribute(ShapeNode,xmlCharStrdup("Width")));
    m_Width = atoi(temp);
LOGD("***************in  LoadBaseInfo 4");
    if (  m_xml.HasAttribute(ShapeNode,xmlCharStrdup("Height"))==false )
    {
        return E_FAIL;
    }
    //m_Height = ShapeNode->m_xml.GetAttribute(L"Height");
    temp = (char*)( m_xml.GetAttribute(ShapeNode,xmlCharStrdup("Height")));
    m_Height = atoi(temp);

LOGD("***************in  LoadBaseInfo 5");  //在這之後當掉=>ok


    if (  m_xml.HasAttribute(ShapeNode,xmlCharStrdup("Rotation"))==true)
    {	
		LOGD("************** Rotation==true");  //在這之後當掉=>ok
		m_Rotation = 0;
		temp = (char*)( m_xml.GetAttribute(ShapeNode,xmlCharStrdup("Rotation")));
		m_Rotation = atof(temp);

	}

	//connie本來在此funtion當掉!
/*
	if (  m_xml.HasAttribute(ShapeNode,xmlCharStrdup("Rotation"))==false )
    {
        //m_Rotation = StrToFloatDef(ShapeNode->m_xml.GetAttribute("Rotation"), 0);
        temp = (char*)( m_xml.GetAttribute(ShapeNode,xmlCharStrdup("Rotation")));
		
		LOGD(temp);  //在這之後當掉
        
		m_Rotation = atof(temp);
    }
*/



	LOGD("***************in  LoadBaseInfo 6");

    return S_OK;
}

HRESULT CActor::LoadImageInfo(xmlNodePtr ShapeNode, string LoadFilePath)
{
    m_ImageX = 0;
    m_ImageY = 0;
    m_ImageWidth = m_Width;
    m_ImageHeight = m_Height;
    m_ImageFileName = string("");
    char* temp = new char[1024];

    // 圖片資訊
    //xmlNodePtr ImageNode = ShapeNode->ChildNodes->FindNode(L"Image");
    xmlNodePtr ImageNode= m_xml.FindChildNode(ShapeNode,xmlCharStrdup("Image"));

    if ( ImageNode==NULL )
    {
        return E_FAIL;
    }

    if (  m_xml.HasAttribute(ImageNode,xmlCharStrdup("href"))==false )
    {
        return E_FAIL;

    }

    string ImageFileName;

    if ( LoadFilePath=="" )
    {
        ImageFileName = string((char*)( m_xml.GetAttribute(ImageNode,xmlCharStrdup("href"))));
    }
    else
    {
        ImageFileName = LoadFilePath + string((char*)( m_xml.GetAttribute(ImageNode,xmlCharStrdup("href"))));
    }
    m_ImageFileName = ImageFileName;

    if (  m_xml.HasAttribute(ImageNode,xmlCharStrdup("Left")) )
    {
        temp = (char*)( m_xml.GetAttribute(ImageNode,xmlCharStrdup("Left")));
        m_ImageX = atoi(temp);
    }

    if (  m_xml.HasAttribute(ImageNode,xmlCharStrdup("Top")) )
    {
        //m_ImageY = ImageNode->m_xml.GetAttribute(L"Top");
        temp = (char*)( m_xml.GetAttribute(ImageNode,xmlCharStrdup("Top")));
        m_ImageY = atoi(temp);
    }

    if (  m_xml.HasAttribute(ImageNode,xmlCharStrdup("Width")))
    {
        //m_ImageWidth = ImageNode->m_xml.GetAttribute(L"Width");
        temp = (char*)( m_xml.GetAttribute(ImageNode,xmlCharStrdup("Width")));
        m_ImageWidth = atoi(temp);
    }

    if (  m_xml.HasAttribute(ImageNode,xmlCharStrdup("Height")) )
    {
        //m_ImageHeight = ImageNode->m_xml.GetAttribute(L"Height");
        temp = (char*)( m_xml.GetAttribute(ImageNode,xmlCharStrdup("Height")));
        m_ImageHeight = atoi(temp);
    }

    // 填入顯示用的資訊
    m_ImageRect[0][0] = m_ImageX;
    m_ImageRect[0][1] = m_ImageY;
    m_ImageRect[1][0] = m_ImageX + m_ImageWidth;
    m_ImageRect[1][1] = m_ImageY;
    m_ImageRect[2][0] = m_ImageX + m_ImageWidth;
    m_ImageRect[2][1] = m_ImageY + m_ImageHeight;
    m_ImageRect[3][0] = m_ImageX;
    m_ImageRect[3][1] = m_ImageY + m_ImageHeight;

    return S_OK;
}

HRESULT CActor::LoadShapeActionSettingsInfo(xmlNodePtr ShapeNode)
{
    // ActionSettng設定
    //xmlNodePtr ActionSettingsNode = ShapeNode->ChildNodes->FindNode(L"ActionSettings");
    xmlNodePtr ActionSettingsNode =  m_xml.FindChildNode(ShapeNode,xmlCharStrdup("ActionSettings"));
    if ( ActionSettingsNode!=NULL )
    {
        if ( AddActionSettings(ActionSettingsNode) )
        {
            RECT ActionSettingSenseRect;
            ActionSettingSenseRect.left   = m_X;
            ActionSettingSenseRect.top    = m_Y;
            ActionSettingSenseRect.right  = m_X + m_Width;
            ActionSettingSenseRect.bottom = m_Y + m_Height;
            m_ActionSettingSenseRect.push_back(ActionSettingSenseRect);
        }
    }

    return S_OK;
}

HRESULT CActor::LoadTextRangeInfo(xmlNodePtr TextFrameNode)
{
    //xmlNodePtr TextRangeNode = TextFrameNode->ChildNodes->FindNode(L"TextRange");
    xmlNodePtr TextRangeNode = m_xml.FindChildNode(TextFrameNode,xmlCharStrdup("TextRange"));
    if ( TextRangeNode!=NULL )
    {
        //xmlNodePtr FontNode = TextRangeNode->ChildNodes->FindNode(L"Font");
        xmlNodePtr FontNode = m_xml.FindChildNode(TextRangeNode,xmlCharStrdup("Font"));
        if ( FontNode!=NULL )
        {
            //xmlNodePtr ColorNode = FontNode->ChildNodes->FindNode(L"Color");
            xmlNodePtr ColorNode = m_xml.FindChildNode(FontNode,xmlCharStrdup("Color"));
            if ( ColorNode!=NULL )
            {
                if (  m_xml.HasAttribute(ColorNode,xmlCharStrdup("rgb")) )
                {
                    //GetRGBvalue(ColorNode->m_xml.GetAttribute("rgb"), textColorRGB);
                    string temp = string((char*)( m_xml.GetAttribute(ColorNode,xmlCharStrdup("rgb"))));
                    GetRGBvalue(temp,textColorRGB);
                }
            }
        }
    }

    return S_OK;
}
HRESULT CActor::LoadTextActionSettingsInfo(xmlNodePtr TextFrameNode)
{
    long BoundLeft, BoundTop, BoundWidth, BoundHeight;
    bool ResetActionSettingInfo = true;
    char* temp= new char[1024];

    //xmlNodePtr TextActionSettingsNode = TextFrameNode->ChildNodes->FindNode(L"TextActionSettings");
    xmlNodePtr TextActionSettingsNode= m_xml.FindChildNode(TextFrameNode,xmlCharStrdup("TextActionSettings"));
    if ( TextActionSettingsNode==NULL )
    {
        return S_OK;
    }

    for ( int index=0 ; index< m_xml.CountChildNode(TextActionSettingsNode) ; index++ )
    {
        xmlNodePtr TextRangeActionNode =  m_xml.FindChildIndex(TextActionSettingsNode,index);

        if ( TextRangeActionNode==NULL )
        {
            continue;
        }

        //BoundLeft = TextRangeActionNode->m_xml.GetAttribute(L"BoundLeft");
        //BoundTop = TextRangeActionNode->m_xml.GetAttribute(L"BoundTop");
        //BoundWidth = TextRangeActionNode->m_xml.GetAttribute(L"BoundWidth");
        //BoundHeight = TextRangeActionNode->m_xml.GetAttribute(L"BoundHeight");
        temp = (char*)( m_xml.GetAttribute(TextRangeActionNode,xmlCharStrdup("BoundLeft")));
        BoundLeft = atoi(temp);
        temp = (char*)( m_xml.GetAttribute(TextRangeActionNode,xmlCharStrdup("BoundTop")));
        BoundTop = atoi(temp);
        temp = (char*)( m_xml.GetAttribute(TextRangeActionNode,xmlCharStrdup("BoundWidth")));
        BoundWidth = atoi(temp);
        temp = (char*)( m_xml.GetAttribute(TextRangeActionNode,xmlCharStrdup("BoundHeight")));
        BoundHeight = atoi(temp);

        //xmlNodePtr ActionSettingsNode = TextRangeActionNode->ChildNodes->FindNode(L"ActionSettings");
        xmlNodePtr ActionSettingsNode = m_xml.FindChildNode(TextRangeActionNode,xmlCharStrdup("ActionSettings"));
        if ( ActionSettingsNode!=NULL )
        {
            if (  m_xml.CountChildNode(ActionSettingsNode)>0 )
            {
                if ( ResetActionSettingInfo==true )
                {
                    ClearActionSettings();
                    ResetActionSettingInfo = false;
                }

                if ( AddActionSettings(ActionSettingsNode) )
                {
                    RECT ActionSettingSenseRect;
                    ActionSettingSenseRect.left   = BoundLeft;
                    ActionSettingSenseRect.top    = BoundTop;
                    ActionSettingSenseRect.right  = BoundLeft + BoundWidth;
                    ActionSettingSenseRect.bottom = BoundTop + BoundHeight;
                    m_ActionSettingSenseRect.push_back(ActionSettingSenseRect);
                }
            }
        }
    }

    return S_OK;
}
HRESULT CActor::LoadParagraphInfo(xmlNodePtr TextFrameNode)
{
    long BoundLeft, BoundTop, BoundWidth, BoundHeight;
    bool ResetActionSettingInfo = true;
    char* temp = new char[1024];

    //xmlNodePtr ParagraphsNode = TextFrameNode->ChildNodes->FindNode(L"Paragraphs");
    xmlNodePtr ParagraphsNode = m_xml.FindChildNode(TextFrameNode,xmlCharStrdup("Paragraphs"));
    if ( ParagraphsNode==NULL )
    {
        return S_OK;
    }

    for ( int index=0 ; index< m_xml.CountChildNode(ParagraphsNode) ; index++ )
    {
        //xmlNodePtr ParagraphNode = ParagraphsNode->ChildNodes->Get(index);
        xmlNodePtr ParagraphNode = m_xml.FindChildIndex(ParagraphsNode,index);

        if ( ParagraphNode!=NULL )
        {
            //BoundLeft = ParagraphNode->m_xml.GetAttribute(L"BoundLeft");
            //BoundTop = ParagraphNode->m_xml.GetAttribute(L"BoundTop");
            //BoundWidth = ParagraphNode->m_xml.GetAttribute(L"BoundWidth");
            //BoundHeight = ParagraphNode->m_xml.GetAttribute(L"BoundHeight");
            temp = (char*)( m_xml.GetAttribute(ParagraphNode,xmlCharStrdup("BoundLeft")));
            BoundLeft = atoi(temp);
            temp = (char*)( m_xml.GetAttribute(ParagraphNode,xmlCharStrdup("BoundTop")));
            BoundTop = atoi(temp);
            temp = (char*)( m_xml.GetAttribute(ParagraphNode,xmlCharStrdup("BoundWidth")));
            BoundWidth = atoi(temp);
            temp = (char*)( m_xml.GetAttribute(ParagraphNode,xmlCharStrdup("BoundHeight")));
            BoundHeight = atoi(temp);


            //xmlNodePtr FontNode = ParagraphNode->ChildNodes->FindNode(L"Font");
            xmlNodePtr FontNode =  m_xml.FindChildNode(ParagraphNode,xmlCharStrdup("Font"));

            if ( FontNode!=NULL )
            {
                //int italic = FontNode->m_xml.GetAttribute(L"Italic");
                temp = (char*)( m_xml.GetAttribute(FontNode,xmlCharStrdup("Italic")));
                int italic = atoi(temp);
                if ( italic==-1 )
                {
                    BoundWidth += 6;
                }
            }

            CActorRenderInfo ActorRenderInfo;
            ActorRenderInfo.Paragraph = index+1;
            ActorRenderInfo.SubIndex = 0;
            ActorRenderInfo.Actor[0][0] = m_ImageRect[0][0];
            ActorRenderInfo.Actor[0][1] = BoundTop - m_Y;
            ActorRenderInfo.Actor[1][0] = m_ImageRect[1][0];
            ActorRenderInfo.Actor[1][1] = BoundTop - m_Y;
            ActorRenderInfo.Actor[2][0] = m_ImageRect[2][0];
            ActorRenderInfo.Actor[2][1] = BoundTop - m_Y + BoundHeight;
            ActorRenderInfo.Actor[3][0] = m_ImageRect[3][0];
            ActorRenderInfo.Actor[3][1] = BoundTop - m_Y + BoundHeight;

            ActorRenderInfo.OriActor[0][0] = m_ImageRect[0][0];
            ActorRenderInfo.OriActor[0][1] = BoundTop - m_Y;
            ActorRenderInfo.OriActor[1][0] = BoundLeft - m_X + BoundWidth;//m_ImageRect[1][0];
            ActorRenderInfo.OriActor[1][1] = BoundTop - m_Y;
            ActorRenderInfo.OriActor[2][0] = BoundLeft - m_X + BoundWidth;//m_ImageRect[2][0];
            ActorRenderInfo.OriActor[2][1] = BoundTop - m_Y + BoundHeight;
            ActorRenderInfo.OriActor[3][0] = m_ImageRect[3][0];
            ActorRenderInfo.OriActor[3][1] = BoundTop - m_Y + BoundHeight;

            ActorRenderInfo.TextActor[0][0] = BoundLeft - m_X;
            ActorRenderInfo.TextActor[0][1] = BoundTop - m_Y;
            ActorRenderInfo.TextActor[1][0] = BoundLeft - m_X + BoundWidth;
            ActorRenderInfo.TextActor[1][1] = BoundTop - m_Y;
            ActorRenderInfo.TextActor[2][0] = BoundLeft - m_X + BoundWidth;//m_Width;
            ActorRenderInfo.TextActor[2][1] = BoundTop - m_Y + BoundHeight;
            ActorRenderInfo.TextActor[3][0] = BoundLeft - m_X;
            ActorRenderInfo.TextActor[3][1] = BoundTop - m_Y + BoundHeight;

            ActorRenderInfo.TextureX = 0.0;
            ActorRenderInfo.TextureY = (float)( BoundTop - m_Y )/(float)m_ImageHeight;
            ActorRenderInfo.TextureWidth = 1.0;
            ActorRenderInfo.TextureHeight = (float)BoundHeight/(float)m_ImageHeight;

            ActorRenderInfo.OriTextureX = 0.0;
            ActorRenderInfo.OriTextureY = (float)( BoundTop - m_Y )/(float)m_ImageHeight;
            ActorRenderInfo.OriTextureWidth = (ActorRenderInfo.OriActor[2][0]-ActorRenderInfo.OriActor[0][0])/(float)m_ImageWidth;//1.0;
            ActorRenderInfo.OriTextureHeight = (float)BoundHeight/(float)m_ImageHeight;

            ActorRenderInfo.TextTextureX = (float)( BoundLeft - m_X)/(float)m_ImageWidth;
            ActorRenderInfo.TextTextureY = (float)( BoundTop - m_Y )/(float)m_ImageHeight;
            ActorRenderInfo.TextTextureWidth = (float)BoundWidth/(float)m_ImageWidth;
            ActorRenderInfo.TextTextureHeight = (float)BoundHeight/(float)m_ImageHeight;

            ActorRenderInfo.Rotation = 0;
            ActorRenderInfo.Red = 1.0;
            ActorRenderInfo.Green = 1.0;
            ActorRenderInfo.Blue = 1.0;
            ActorRenderInfo.Alpha = 1.0;
            m_SubRenderInfo.push_back(ActorRenderInfo);

            //xmlNodePtr ActionSettingsNode = ParagraphNode->ChildNodes->FindNode(L"ActionSettings");
            xmlNodePtr ActionSettingsNode = m_xml.FindChildNode(ParagraphNode,xmlCharStrdup("ActionSettings"));
            if ( ActionSettingsNode!=NULL )
            {
                if (  m_xml.CountChildNode(ActionSettingsNode)>0 )
                {
                    if ( ResetActionSettingInfo==true )
                    {
                        ClearActionSettings();
                        ResetActionSettingInfo = false;
                    }

                    if ( AddActionSettings(ActionSettingsNode) )
                    {
                        RECT ActionSettingSenseRect;
                        ActionSettingSenseRect.left   = BoundLeft;
                        ActionSettingSenseRect.top    = BoundTop;
                        ActionSettingSenseRect.right  = BoundLeft + BoundWidth;
                        ActionSettingSenseRect.bottom = BoundTop + BoundHeight;
                        m_ActionSettingSenseRect.push_back(ActionSettingSenseRect);
                    }
                }
            }
        }
    }

    return S_OK;
}

HRESULT CActor::LoadTextFrameInfo(xmlNodePtr ShapeNode)
{
//    long BoundLeft, BoundTop, BoundWidth, BoundHeight;

    // 文字資訊
    //xmlNodePtr TextFrameNode = ShapeNode->ChildNodes->FindNode(L"TextFrame");
    xmlNodePtr TextFrameNode =  m_xml.FindChildNode(ShapeNode,xmlCharStrdup("TextFrame"));

    if ( TextFrameNode==NULL )
    {
        return S_OK;
    }

    LoadTextRangeInfo(TextFrameNode);
    LoadTextActionSettingsInfo(TextFrameNode);
    LoadParagraphInfo(TextFrameNode);

    return S_OK;
}

HRESULT CActor::LoadGroupShapesInfo(xmlNodePtr ShapeNode)
{
    long BoundLeft, BoundTop, BoundWidth, BoundHeight;
    bool ResetActionSettingInfo = true;
    char* temp = new char[1024];

    //xmlNodePtr GroupShapesNode = ShapeNode->ChildNodes->FindNode(L"GroupShapes");
    xmlNodePtr GroupShapesNode = m_xml.FindChildNode(ShapeNode,xmlCharStrdup("GroupShapes"));

    if ( GroupShapesNode==NULL )
    {
        return S_OK;
    }

    for ( int index=0 ; index< m_xml.CountChildNode(GroupShapesNode) ; index++ )
    {
        //xmlNodePtr ActionSettingsNode = GroupShapesNode->ChildNodes->Get(index);
        xmlNodePtr ActionSettingsNode =  m_xml.FindChildIndex(GroupShapesNode,index);

        if ( ActionSettingsNode==NULL )
        {
            continue;
        }

        //BoundLeft = ActionSettingsNode->m_xml.GetAttribute(L"Left");
        //BoundTop = ActionSettingsNode->m_xml.GetAttribute(L"Top");
        //BoundWidth = ActionSettingsNode->m_xml.GetAttribute(L"Width");
        //BoundHeight = ActionSettingsNode->m_xml.GetAttribute(L"Height");
        temp = (char*)( m_xml.GetAttribute(ActionSettingsNode,xmlCharStrdup("Left")));
        BoundLeft = atoi(temp);
        temp = (char*)( m_xml.GetAttribute(ActionSettingsNode,xmlCharStrdup("Top")));
        BoundTop = atoi(temp);
        temp = (char*)( m_xml.GetAttribute(ActionSettingsNode,xmlCharStrdup("Width")));
        BoundWidth = atoi(temp);
        temp = (char*)( m_xml.GetAttribute(ActionSettingsNode,xmlCharStrdup("Height")));
        BoundHeight = atoi(temp);


        if (  m_xml.CountChildNode(ActionSettingsNode)>0 )
        {
            if ( ResetActionSettingInfo==true )
            {
                ClearActionSettings();
                ResetActionSettingInfo = false;
            }

            if ( AddActionSettings(ActionSettingsNode) )
            {
                RECT ActionSettingSenseRect;
                ActionSettingSenseRect.left   = BoundLeft;
                ActionSettingSenseRect.top    = BoundTop;
                ActionSettingSenseRect.right  = BoundLeft + BoundWidth;
                ActionSettingSenseRect.bottom = BoundTop + BoundHeight;
                m_ActionSettingSenseRect.push_back(ActionSettingSenseRect);
            }
        }
    }
    return S_OK;
}

HRESULT CActor::InitRenderInfo(void)
{
    CActorRenderInfo ActorRenderInfo;
    ActorRenderInfo.Actor[0][0] = m_ImageRect[0][0];
    ActorRenderInfo.Actor[0][1] = m_ImageRect[0][1];
    ActorRenderInfo.Actor[1][0] = m_ImageRect[1][0];
    ActorRenderInfo.Actor[1][1] = m_ImageRect[1][1];
    ActorRenderInfo.Actor[2][0] = m_ImageRect[2][0];
    ActorRenderInfo.Actor[2][1] = m_ImageRect[2][1];
    ActorRenderInfo.Actor[3][0] = m_ImageRect[3][0];
    ActorRenderInfo.Actor[3][1] = m_ImageRect[3][1];
    ActorRenderInfo.OriActor[0][0] = m_ImageRect[0][0];
    ActorRenderInfo.OriActor[0][1] = m_ImageRect[0][1];
    ActorRenderInfo.OriActor[1][0] = m_ImageRect[1][0];
    ActorRenderInfo.OriActor[1][1] = m_ImageRect[1][1];
    ActorRenderInfo.OriActor[2][0] = m_ImageRect[2][0];
    ActorRenderInfo.OriActor[2][1] = m_ImageRect[2][1];
    ActorRenderInfo.OriActor[3][0] = m_ImageRect[3][0];
    ActorRenderInfo.OriActor[3][1] = m_ImageRect[3][1];
    ActorRenderInfo.TextActor[0][0] = m_ImageRect[0][0];
    ActorRenderInfo.TextActor[0][1] = m_ImageRect[0][1];
    ActorRenderInfo.TextActor[1][0] = m_ImageRect[1][0];
    ActorRenderInfo.TextActor[1][1] = m_ImageRect[1][1];
    ActorRenderInfo.TextActor[2][0] = m_ImageRect[2][0];
    ActorRenderInfo.TextActor[2][1] = m_ImageRect[2][1];
    ActorRenderInfo.TextActor[3][0] = m_ImageRect[3][0];
    ActorRenderInfo.TextActor[3][1] = m_ImageRect[3][1];

    ActorRenderInfo.TextureX = 0.0;
    ActorRenderInfo.TextureY = 0.0;
    ActorRenderInfo.TextureWidth = 1.0;
    ActorRenderInfo.TextureHeight = 1.0;
    ActorRenderInfo.OriTextureX = 0.0;
    ActorRenderInfo.OriTextureY = 0.0;
    ActorRenderInfo.OriTextureWidth = 1.0;
    ActorRenderInfo.OriTextureHeight = 1.0;
    ActorRenderInfo.TextTextureX = 0.0;
    ActorRenderInfo.TextTextureY = 0.0;
    ActorRenderInfo.TextTextureWidth = 1.0;
    ActorRenderInfo.TextTextureHeight = 1.0;

    ActorRenderInfo.Rotation = 0;
    ActorRenderInfo.Red = 1.0;
    ActorRenderInfo.Green = 1.0;
    ActorRenderInfo.Blue = 1.0;
    ActorRenderInfo.Alpha = 1.0;
    m_ActorRenderInfo.push_back(ActorRenderInfo);

    return S_OK;
}

// 判斷ActionSettings是否被使用，有些Video或Audio檔案格式不支援，則ActionSettings不被使用
HRESULT CActor::DetermineActionSettingsEnabled(xmlNodePtr ShapeNode)  //在此function當掉
{

	LOGD("**************in DetermineActionSettingsEnabled  ");//sss
    //xmlNodePtr LinkFormatNode = ShapeNode->ChildNodes->FindNode(L"LinkFormat");
    xmlNodePtr LinkFormatNode =  m_xml.FindChildNode(ShapeNode,xmlCharStrdup("LinkFormat"));

	LOGD("**************in DetermineActionSettingsEnabled  1");//sss

    if ( LinkFormatNode!=NULL )
    {
		LOGD("**************in DetermineActionSettingsEnabled  2");//sss
        if (  m_xml.HasAttribute(LinkFormatNode,xmlCharStrdup("SourceFullName"))==true )
        {
			LOGD("**************in DetermineActionSettingsEnabled  3");//sss
            //string SourceFullName = (string)LinkFormatNode->m_xml.GetAttribute(L"SourceFullName");
            char* temp = (char*)( m_xml.GetAttribute(LinkFormatNode,xmlCharStrdup("SourceFullName")));
			LOGD("temp = ");//sss
			LOGD(temp);//sss


            m_ActionSettingsEnabled = false;
            string SourceFullName;
			SourceFullName.assign(temp);
			//LOGD("SourceFullName = ");//sss
			LOGD(SourceFullName.c_str());
           
			
			string Ext = BWExtractFileExtNew(SourceFullName);
			//LOGD("Ext ");//sss
			//	LOGD("before ext print");//sss
			//LOGD(Ext.c_str());//sss
		
			if(Ext == ""){
			 LOGD("Ext = null ");//sss
			}
			

			//Info[index].compare( Info[index].length()-3 , 3 , "jpg" )==0
          //  if ( Ext==string(".wmv") || Ext==string(".wma") )

			if(Ext != ""){
				if(SourceFullName.compare(SourceFullName.length()-3,3,"wmv") == 0 ||SourceFullName.compare(SourceFullName.length()-3,3,"wma") == 0  )			
				{
					LOGD("**************in DetermineActionSettingsEnabled  4");//sss
                // 目前只支援 .wmv 和 .wma 兩種格式
					 m_ActionSettingsEnabled = true;
				}
				}
			LOGD("**************in DetermineActionSettingsEnabled  end if 1");//sss
		}
LOGD("**************in DetermineActionSettingsEnabled  end if 2");//sss
    }
	
	LOGD("**************in DetermineActionSettingsEnabled  end end");//sss
    return S_OK;
}

// 取得Video資訊
HRESULT CActor::LoadMediaInfo(xmlNodePtr ShapeNode)
{

    char* temp = new char[1024];
    //xmlNodePtr AnimationSettingsNode = ShapeNode->ChildNodes->FindNode(L"AnimationSettings");
    xmlNodePtr AnimationSettingsNode =  m_xml.FindChildNode(ShapeNode,xmlCharStrdup("AnimationSettings"));
    if ( AnimationSettingsNode==NULL )
    {
        return E_FAIL;
    }

    //xmlNodePtr PlaySettingsNode = AnimationSettingsNode->ChildNodes->FindNode(L"PlaySettings");
    xmlNodePtr PlaySettingsNode =  m_xml.FindChildNode(AnimationSettingsNode,xmlCharStrdup("PlaySettings"));
    if ( PlaySettingsNode==NULL )
    {
        return E_FAIL;
    }

    if (  m_xml.HasAttribute(PlaySettingsNode,xmlCharStrdup("PlayOnEntry"))==false )
    {
        return E_FAIL;
    }

    //m_PlayOnEntry = PlaySettingsNode->m_xml.GetAttribute(L"PlayOnEntry");
    //bool m_PlayOnEntry:(convert to integer first)
    temp=(char*)( m_xml.GetAttribute(PlaySettingsNode,xmlCharStrdup("PlayOnEntry")));
    m_PlayOnEntry = atoi(temp);

    //xmlNodePtr LinkFormatNode = ShapeNode->ChildNodes->FindNode(L"LinkFormat");
    xmlNodePtr LinkFormatNode =  m_xml.FindChildNode(ShapeNode,xmlCharStrdup("LinkFormat"));
    if ( LinkFormatNode==NULL )
    {
        return E_FAIL;
    }

    if (  m_xml.HasAttribute(LinkFormatNode,xmlCharStrdup("SourceFullName"))==false )
    {
        return E_FAIL;
    }

    temp = (char*)( m_xml.GetAttribute(LinkFormatNode,xmlCharStrdup("SourceFullName")));
    m_MediaFileName =string(temp);


    if ( BWExtractFileExtNew(m_MediaFileName.c_str())==string(".wmv") ||
         BWExtractFileExtNew(m_MediaFileName.c_str())==string(".wma") )
    {
        m_ActorType = ActorType_Media;
        m_MediaActorState = MediaActorState_Stop;

        m_HaveEffect = true;


        if ( BWExtractFileExtNew(m_MediaFileName.c_str())==string(".wmv") )
        {
            //m_ImageFileName.clear();
            m_MediaType = MediaActorType_WMV;
        }
        else if ( BWExtractFileExtNew(m_MediaFileName.c_str())==string(".wma") )
        {
            m_MediaType = MediaActorType_WMA;
        }
    }

    return S_OK;
}


HRESULT CActor::Media_Click(bool TimerEnabled)
{
    if ( m_ActorType!=ActorType_Media )
    {
        return E_FAIL;
    }


    if ( m_MediaActorState==MediaActorState_Stop )
    {
        // 如果之前狀態為"停止"或"暫停"，則設定新狀態為"播放"
        m_MediaActorState = MediaActorState_Play;
        m_IsActing = true;
        m_MediaTimer.ResetTimer();
        m_MediaTimer.EnableTimer(TimerEnabled);
    }
    else if ( m_MediaActorState==MediaActorState_Pause )
    {
        m_MediaActorState = MediaActorState_Play;
        m_IsActing = true;
        m_MediaTimer.EnableTimer(TimerEnabled);
    }
    else if ( m_MediaActorState==MediaActorState_Play )
    {
        // 如果之前狀態為"播放"，則設定新狀態為暫停
        m_MediaActorState = MediaActorState_Pause;
        m_IsActing = false;
        m_MediaTimer.EnableTimer(false);
    }

    return S_OK;

}

// 多媒體演員開始
HRESULT CActor::Media_Start()
{
    if ( m_ActorType!=ActorType_Media )
    {
        return E_FAIL;
    }

    m_MediaActorState = MediaActorState_Play;
    m_IsActing = true;
    m_MediaTimer.EnableTimer(true);

    return S_OK;
}

HRESULT CActor::Media_Stop()
{
    if ( m_ActorType!=ActorType_Media )
    {
        return E_FAIL;
    }
    // 設定新狀態為停止，且重設多媒體時間
    m_MediaActorState = MediaActorState_Stop;
    m_IsActing = false;
    m_MediaTimer.EnableTimer(false);
    //m_MediaTimer.ResetTimer();

    // 強迫繪圖系統一定要更新
    m_MediaActorRefresh = true;

    return S_OK;
}

// 多媒體演員暫停
HRESULT CActor::Media_Pause()
{
    if ( m_ActorType!=ActorType_Media )
    {
        return E_FAIL;
    }
    // 設定新狀態為停止，且重設多媒體時間
    m_MediaActorState = MediaActorState_Pause;
    m_IsActing = false;
    m_MediaTimer.EnableTimer(false);

    return S_OK;
}



HRESULT CActor::Media_Reset(void)
{
    if ( m_ActorType!=ActorType_Media )
    {
        return E_FAIL;
    }

    m_MediaActorState = MediaActorState_Stop;
    m_IsActing = false;
    m_MediaTimer.ResetTimer();

    // 強迫繪圖系統一定要更新
    m_MediaActorRefresh = true;

    return S_OK;
}

HRESULT CActor::Reset(void)
{
    RenderInfo_Reset();
    Media_Reset();
    return S_OK;
}

// 更新多媒體的時間

HRESULT CActor::Media_Refresh()
{

    if ( m_ActorType!=ActorType_Media )
    {
        return E_FAIL;
    }

    // 為控制系統定時的更新，所以非使用拖拉時間軸呼叫的函數
    m_MediaGotoTime = false;
    m_MediaGotoTimeFinish = false;

    if ( m_MediaActorState==MediaActorState_Play && m_MediaTimer.IsEnabled()==true )
    {
        // 拖拉時間軸且是在播放狀態
        m_MediaTimer.UpdateTimer();
    }
    else
    {
        return E_FAIL;
    }
    return S_OK;
}
HRESULT CActor::Media_Refresh(unsigned long dTime)
{
    if ( m_ActorType!=ActorType_Media )
    {
        return E_FAIL;
    }


    // 此函數是用在拖拉時間軸時使用，所以設定現在多媒體演員為拖拉時間軸(m_MediaGotoTime=true)
    // 且拖拉時間軸還沒結束(m_MediaGotoTimeFinish=false)
    m_MediaGotoTime = true;
    m_MediaGotoTimeFinish = false;

    if ( m_MediaActorState==MediaActorState_Play && m_MediaTimer.IsEnabled()==false )
    {
        // 拖拉時間軸且是在播放狀態
        unsigned long Time = m_MediaTimer.GetTime();
        m_MediaTimer.SetTime(Time+dTime);
    }
    else
    {
        return E_FAIL;
    }

    return S_OK;

}

// 設定多媒體時間是否可作用
HRESULT CActor::Media_RefreshEnabled(bool TimerEnabled)
{
    if ( m_ActorType!=ActorType_Media )
    {
        return E_FAIL;
    }

    if ( TimerEnabled==true )
    {
        if ( m_MediaActorState==MediaActorState_Play && m_MediaTimer.IsEnabled()==false )
        {
            m_MediaTimer.EnableTimer(true);
        }
        else
        {
            return E_FAIL;
        }
    }
    else
    {
        // 如果之前狀態為"播放"，則設定新狀態為暫停
        //m_MediaActorState = MediaActorState_Pause;
        m_IsActing = false;
        m_MediaTimer.EnableTimer(false);

        //if ( m_MediaGotoTime==true )
        //{
        //    m_MediaGotoTimeFinish = true;
        //}
    }



    return S_OK;
}

HRESULT CActor::SetMute(bool Mute)
{
    m_Mute = Mute;
    return S_OK;
}

HRESULT CActor::GetMute(bool &Mute)
{
    Mute = m_Mute;
    return S_OK;
}

HRESULT CActor::GotoTimeFinish()
{
    if ( m_MediaGotoTime==true )
    {
        m_MediaGotoTimeFinish = true;
    }
    return S_OK;
}

HRESULT CActor::IsVisible()
{
    bool Show = false;

    vector<CActorRenderInfo> RenderInfo;
    if ( GetRenderInfo(0, RenderInfo)==true )
    {
        for ( unsigned int index=0 ; index<RenderInfo.size() ; index++ )
        {
            if ( RenderInfo[index].Alpha!=0 )
            {
                Show = true;
            }
        }
    }
    else
    {
        long index = 1;

        RenderInfo.clear();

        while ( GetRenderInfo(index, RenderInfo)==true )
        {
            for ( unsigned int index1=0 ; index1<RenderInfo.size() ; index1++ )
            {
                if ( RenderInfo[index1].Alpha!=0 )
                {
                    Show = true;
                }
            }

            RenderInfo.clear();

            index++;
        }
    }

    if ( Show==false )
    {
        return E_FAIL;
    }

    return S_OK;
}


HRESULT CActor::SetScreenRecActor(const char *pFileName, int VideoWidth, int VideoHeight)
{

    float X = 0;
    float Y = 0;
    float Width = 720;
    float Height = 540;

        float RatioHW = (float)VideoHeight/VideoWidth;

        if(RatioHW <= 0.75)
        {
            Width = 720;
            Height = (float)720*RatioHW;
            Y = (540 - Height)/2;
        }
        else
        {
            Width = (float)540/RatioHW;
            Height = 540;
            X = (720 - Width)/2;
        }


    ActorName = BWExtractFileNameNew(pFileName);


    // 16 多媒體演員
    type = 16;
    m_ZOrderPosition = 1;

    m_X = (int)X;
    m_Y = (int)Y;
    m_Width = (int)Width;
    m_Height = (int)Height;
    m_Rotation = 0;

    // 影像資訊
    m_ImageX = 0;
    m_ImageY = 0;
    m_ImageWidth = m_Width;
    m_ImageHeight = m_Height;
    //m_ImageFileName = string(pActorName);

    // 填入顯示用的資訊
    m_ImageRect[0][0] = m_ImageX;
    m_ImageRect[0][1] = m_ImageY;
    m_ImageRect[1][0] = m_ImageX + m_ImageWidth;
    m_ImageRect[1][1] = m_ImageY;
    m_ImageRect[2][0] = m_ImageX + m_ImageWidth;
    m_ImageRect[2][1] = m_ImageY + m_ImageHeight;
    m_ImageRect[3][0] = m_ImageX;
    m_ImageRect[3][1] = m_ImageY + m_ImageHeight;

    m_ActorType = ActorType_Media;
    m_MediaActorState = MediaActorState_Stop;
    m_MediaType = MediaActorType_WMV;

    m_PlayOnEntry = true;
    m_MediaFileName = string(pFileName);

    m_HaveEffect = true;

    m_ActionSettingsEnabled = true;

    m_MCActionSettingAction.push_back(12);
    m_MCHyperlinkSlideID.push_back(-1);
    m_MCURL.push_back("");

    RECT ActionSettingSenseRect;
    ActionSettingSenseRect.left   = m_X;
    ActionSettingSenseRect.top    = m_Y;
    ActionSettingSenseRect.right  = m_X + m_Width;
    ActionSettingSenseRect.bottom = m_Y + m_Height;
    m_ActionSettingSenseRect.push_back(ActionSettingSenseRect);

    InitRenderInfo();

    m_Mute = true;

    return S_OK;
}



//---------------------------------------------------------------------------


/***********************************
  塗鴉演員
***********************************/
//---------------------------------------------------------------------------

CDrawActor::CDrawActor()
{
    m_Command.clear();

    Enabled = false;

    PreTime = 0;
    Time = 0;

    m_Script.GotoBegin();

    OnDrawActorPosition = NULL;
}
//---------------------------------------------------------------------------
CDrawActor::~CDrawActor()
{
    for ( unsigned int index=0 ; index<m_Command.size() ; index++ )
    {
        m_Command[index].clear();
    }
    m_Command.clear();
}
//---------------------------------------------------------------------------
void CDrawActor::Reset(void)
{
    m_Command.clear();

    Enabled = false;

    PreTime = 0;
    Time = 0;

    m_Script.GotoBegin();
}

//---------------------------------------------------------------------------
bool CDrawActor::IsEmpty(void)
{
    return m_Command.empty();
}
//---------------------------------------------------------------------------
void CDrawActor::Refresh(string Type, unsigned long dTime)
{

    string X = "a", Y = "a";

    if ( Recording==true )
        return ;

    if ( Enabled==true )
    {
        Time = PreTime + dTime;

        CScriptAction ScriptAction;

        if ( !m_Script.Empty() )
        {

            if ( dTime!=0 )
            {
                unsigned int TmpIndex = LastIndex;

                m_Script.GotoBegin();
                m_Script.GetActions(ScriptAction);

                // 如果 PreTime 為開始的時間，則將 Begin(xxx) 的繪圖指令直接加入 m_Command
                if ( ScriptAction.Time==PreTime )
                {
                    m_Command.push_back(ScriptAction.Parameters);

                }

                LastIndex = 1;

                while ( m_Script.NextAction(ScriptAction) )
                {
                    if ( ScriptAction.Time>PreTime && ScriptAction.Time<=Time )
                    {
                        // 已經有交給繪圖系統的指令，不再送給繪圖系統。　
                        if ( LastIndex>=TmpIndex )
                        {
                            if ( Type=="GotoTime" )
                            {
                                string method = ScriptAction.Parameters[2];
                                if ( method=="OnLine" || method=="OnGeometryGraph" )
                                {

                                    //m_Command.erase(m_Command.begin()+1, m_Command.end());

                                    X = ScriptAction.Parameters[0];
                                    Y = ScriptAction.Parameters[1];

                                    m_Command.push_back(ScriptAction.Parameters);
                                }
                                else
                                {
                                    X = ScriptAction.Parameters[0];
                                    Y = ScriptAction.Parameters[1];

                                    m_Command.push_back(ScriptAction.Parameters);
                                }
                            }
                            else if ( Type=="Replaying" )
                            {
                                X = ScriptAction.Parameters[0];
                                Y = ScriptAction.Parameters[1];

                                m_Command.push_back(ScriptAction.Parameters);
                            }
                        }
                    }
                    else if ( ScriptAction.Time>Time )
                    {
                        break;
                    }

                    LastIndex ++;
                }

                PreTime = Time;
            }
            else if ( dTime==0 )
            {
                // 暫停錄製時的塗鴉指令
                CScriptAction ScriptAction;

                while( m_Script.GetActions(LastIndex, ScriptAction) )
                {
                    X = ScriptAction.Parameters[0];
                    Y = ScriptAction.Parameters[1];

                    m_Command.push_back(ScriptAction.Parameters);
                    LastIndex++;
                }
            }
        }
    }

    if ( X!="a" && Y!="a" )
    {
        if ( OnDrawActorPosition!=NULL )
            OnDrawActorPosition(atoi(X.c_str()), atoi(Y.c_str()));
    }
}
//---------------------------------------------------------------------------


bool CDrawActor::FirstScriptCompare(CScriptAction Action)
{
    CScriptAction ScriptAction;
    m_Script.GotoBegin();
    m_Script.GetActions(ScriptAction);

    if ( Action.Time!=ScriptAction.Time )
        return false;

    if ( Action.Action!=Action.Action )
        return false;

    if ( Action.Parameters.size()!=ScriptAction.Parameters.size() )
        return false;

    for ( unsigned int index=0 ; index<Action.Parameters.size() ; index++ )
    {
        if ( Action.Parameters[index]!=ScriptAction.Parameters[index] )
            return false;
    }

    return true;
}
//---------------------------------------------------------------------------
unsigned long CDrawActor::GetFirstTime(void)
{
    unsigned long FirstTime;
    m_Script.GetBeginTime(FirstTime);
    return FirstTime;
}
//---------------------------------------------------------------------------
unsigned long CDrawActor::GetLastTime(void)
{
    unsigned long LastTime;
    m_Script.GetEndTime(LastTime);
    return LastTime;
}
//---------------------------------------------------------------------------
void CDrawActor::Draw(CScriptAction Action)
{
    if ( Action.Parameters[0]==string("EndPen") ||
         Action.Parameters[0]==string("EndFluoropen") ||
         Action.Parameters[0]==string("EndEraser") ||
         Action.Parameters[0]==string("EndLine") ||
         Action.Parameters[0]==string("EndGeometryGraph") ||
         Action.Parameters[0]==string("EndText") )
    {
        if ( !m_Script.Empty() )
        {
            // 避免只有結束繪圖指令
            m_Script.InsertAction(Action);

            m_Command.push_back(Action.Parameters);
        }
    }
    else
    {
        m_Script.InsertAction(Action);

        m_Command.push_back(Action.Parameters);
    }


}
//---------------------------------------------------------------------------
void CDrawActor::BeginRecordDraw(void)
{
    Recording = true;

    Enabled = false;

    m_Command.clear();
}
//---------------------------------------------------------------------------
void CDrawActor::EndRecordDraw(void)
{
    Recording = false;

    Enabled = false;
}
//---------------------------------------------------------------------------
void CDrawActor::BeginReplayDraw(void)
{
    Recording = false;

    Enabled = true;

    m_Script.GotoBegin();

    m_Script.GetBeginTime(PreTime);

    m_Command.clear();

    LastIndex = 0;
}
//---------------------------------------------------------------------------
void CDrawActor::EndReplayDraw(void)
{
    CScriptAction ScriptAction;

    //
    while ( m_Script.GetActions(LastIndex, ScriptAction) )
    {
        m_Command.push_back(ScriptAction.Parameters);

        LastIndex++;
    }

    Enabled = false;
    Time = 0;
    PreTime = 0;

    Recording = false;
}
//---------------------------------------------------------------------------
