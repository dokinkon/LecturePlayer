//---------------------------------------------------------------------------

#include "globals.h"

#include "BWDRMClient.h"
#include "BWStringTool.h"


// 解析XML檔所需的函式標頭檔
#include "MyXML.h"
//#include <XMLDoc.hpp>

#include "BWDES.h"
#include "BWMD5.h"
#include <math.h>

#include "HttpDownload.h"
//#include "md5.h"

//#include <TntSystem.hpp>


// 設定DRM Server的主程式名稱
//connie string g_WebApp = "Main.php" ;
string g_WebApp = "main.aspx" ;//connie
//---------------------------------------------------------------------------

//#pragma package(smart_init)

//---------------------------------------------------------------------------



BWDRMServer::BWDRMServer()
{
    m_IsInitialized = false;
    m_ServerIP = string("");
    m_UserName = string("");
    m_UserPassword = string("");

    m_HttpsEnabled = true;
    m_SecurityCommunicate = true;

    m_ProxyCached = false;

}

//---------------------------------------------------------------------------

BWDRMServer::~BWDRMServer()
{

}

//---------------------------------------------------------------------------

bool BWDRMServer::Initialize(string ServerIP)
{
    m_ServerIP = ServerIP;
    m_IsInitialized = true;

    return true; //直接用Main.php

    //! 測試
    //return true;

    // 從Server下載drminfo.htm檔案，以取得DRM Server的能力
    string XMLText;
    string DRMServerInfoUrl = m_ServerIP + "/drminfo.htm";

    if ( this->Get(DRMServerInfoUrl, XMLText)==true )
    {
        try
        {
            xmlDoc *xmldoc = NULL;
            xmlNode *xmlRoot = NULL;
            MyXML m_xml;

            xmldoc = xmlReadMemory( XMLText.data(), XMLText.size() , NULL , NULL , 0);
            xmlRoot = xmlDocGetRootElement(xmldoc);

            string action;
            if ( m_xml.HasAttribute( xmlRoot , xmlCharStrdup("action") ) )
            {
                //action = wstring(xmlRoot->GetAttribute(L"action"));
                action = (char*)m_xml.GetAttribute( xmlRoot , xmlCharStrdup("action") );
                //cout<<action<<endl;
            }

            if ( action=="DRMinfo" )
            {
                for ( int index=0 ; index<m_xml.CountChildNode( xmlRoot ) ; index++ )
                {
                    xmlNode *xmlReturn = m_xml.FindChildIndex( xmlRoot , index );
                    if ( m_xml.HasAttribute( xmlReturn , xmlCharStrdup("name") ) )
                    {
                        string name = (char*)m_xml.GetAttribute( xmlReturn , xmlCharStrdup("name"));

                        if ( name=="Language" )
                        {
                            if ( m_xml.HasAttribute( xmlReturn , xmlCharStrdup("value") ) )
                            {
                                string value = (char*)m_xml.GetAttribute( xmlReturn , xmlCharStrdup( "value" ) );
                                //cout<<value<<endl;
                                g_WebApp = "Main." + value;
                                //wcout<<g_WebApp.c_str()<<endl;
                            }
                        }
                    }
                }
            }

            xmlFreeDoc(xmldoc);
            xmldoc = NULL;
        }
        catch(...)
        {
            // 載入XML發生例外，需要使用DES模組將DRM的回傳值解密
        }
    }

    return true;
}

//---------------------------------------------------------------------------

bool BWDRMServer::Login(string UserName, string UserPassword)
{
    if(m_IsInitialized == false)
    {
        return false;
    }

    // 目前不是真的login，只是將帳號密碼存下來
    m_UserName = UserName;
    m_UserPassword = UserPassword;
    return true;
}

bool BWDRMServer::Logout()
{
    if(m_IsInitialized == false)
    {
        return false;
    }

    m_UserName = "";
    m_UserPassword = "";
    return true;
}

bool BWDRMServer::Exectue(string FunctionName, vector<string> ParamNames, vector<string> ParamValues, string &XMLText)
{
    if(m_IsInitialized == false)
    {
        return false;
    }

    if(FunctionName == string(""))
    {
        return false;
    }

    if(ParamNames.size() != ParamValues.size())
    {
        return false;
    }

    string result;
    if(m_ServerIP != string(""))
    {
        // 第一次建立DRM連線時，會先使用DES加密跟DRM溝通
        // 如果DRM無法溝通，則取消DES加密溝通的方式

        //! 暫時關掉DRM通訊加密
        m_SecurityCommunicate = false;

        if ( m_SecurityCommunicate==true )
        {
            //! 跑加密傳輸

            // 組成url
            string URL = m_ServerIP + "/" + g_WebApp + "?do=CheckSN";
            string Param = "Status=" + FunctionName;
            Param = Param + "&ID=" + m_UserName;
            Param = Param + "&PW=" + m_UserPassword;
            Param = Param + "&EC=1";        // 設定回傳值需要加密

            for(size_t i=0;i<ParamNames.size();i++)
            {
                Param = Param + "&" + ParamNames[i] + "=" + BW::BWGenerateValidURL(ParamValues[i]);
            }

		
            //UTF8String utf8Param = wstringToUTF8(Param);
            //UTF8String utf8Param = UTF8String(Param.c_bstr());
            string utf8Param = Param;
            //char kk[4096];
            //UnicodeToUtf8(kk, Param.c_bstr(), 4096);
            //UTF8String utf8Param = UTF8String(kk);

            //utf8Param += UTF8String("&&&&&&&&");

            time_t t;

            srand((unsigned) time(&t));

            int RandKeyNo = rand() % 10000;

            BWMD5 bwmd5;
            //connie gchar *String_RandKeyNo;
            string String_RandKeyNo;
            unsigned char* md5_result=new unsigned char[16];
            char *tmp=new char[7];
            
            //connie String_RandKeyNo=g_strdup_printf("%d",RandKeyNo);
            String_RandKeyNo = BW::IntToStringNew(RandKeyNo,0);
            char *temps=new char[strlen(String_RandKeyNo.c_str())];
            strcpy(temps,String_RandKeyNo.c_str());
            
            bwmd5.generateMD5( temps , md5_result );
            delete []temps; 
            for( int i=0 ; i<6 ; i++ )tmp[i]=(char)md5_result[i];
            tmp[6]=0;

            bwmd5.generateMD5( tmp , md5_result );
            string key="";
            for( int i=0 ; i<16 ; i++ )key+=(char)md5_result[i];

            delete[] tmp;
            delete[] md5_result;


            int DestSize; //???DestSize沒給定初值？
            DestSize=(int)(ceil((double)utf8Param.length()/8.0)*8);

            BWDES bwdes;
            //bwdes.encode((unsigned char *)utf8Param.c_str(), utf8Param.length(), NULL, DestSize, (char *)key.c_str());

            unsigned char *pDest = new unsigned char[DestSize];
            memset(pDest, 0, DestSize);
            bwdes.encode((unsigned char *)utf8Param.c_str(), utf8Param.length(), pDest, DestSize, (char *)key.c_str());

            string ptmp = "";
            for ( int ii=0 ; ii<DestSize ; ii++ )
            {
                ptmp += (char)pDest[ii];
                //memcpy(ptmp+ii, pDest, DestSize);
            }

            delete [] pDest;


            //URL += wstring("&des=") + wstring((char *)pDest) + wstring("&keyno=") + AnsiString(RandKeyNo);
            URL += string("&des=") + ptmp + "&keyno=" + String_RandKeyNo;
           // g_free( String_RandKeyNo );

            //DebugMessage(URL);
           // cout<<URL.c_str()<<endl;

            // 連結DRM Server取得資料(使用DES加密)
            if(this->Get(URL, result) == true)
            {
                // DRM的回傳值需要DES解密

                // 嘗試載入XML
                bool DecodeResult = false;
                string result1 = result;
                xmlDoc *xmldoc=NULL;// = NewXMLDocument();
                try
                {
                    //要check是不是有弄錯對象
                    xmldoc=xmlReadMemory( XMLText.data() , XMLText.size() , NULL , NULL , 0);
                }
                catch(...)
                {
                    // 載入XML發生例外，需要使用DES模組將DRM的回傳值解密
                    DecodeResult = true;
                }
                xmlFreeDoc(xmldoc);
                xmldoc = NULL;

                if ( DecodeResult==true )
                {
                    // DRM的回傳值需要DES解密
                    string result1 = result;
                    unsigned char *pDestBuffer = new unsigned char[result1.length()/2];
                    memset(pDestBuffer, 0, result1.length()/2);

                    bwdes.decode((unsigned char *)result1.c_str(), result1.length(), pDestBuffer, result1.length()/2, (char *)key.c_str());

                    // 解密後的資料再用XML模組試圖載入，藉此判斷回傳資料的格式是否有問題
                    result1 = string((char *)pDestBuffer);

                    // 須先講解密完的字串轉成Unicode，避免XML模組無法載入
                    string result2 = result1;

                    xmlDoc *xmldoc1=NULL;// = NewXMLDocument();
                    try
                    {
                        xmldoc1=xmlReadMemory( result1.data(), result1.size() , NULL , NULL , 0);
                        //xmldoc1=xmlReadFile(result1.c_str(),NULL,0);
                    }
                    catch(...)
                    {
                        // 解密之後的資料格式不是XML的格式，改用非加密的方式與DRM溝通
                        m_SecurityCommunicate = false;
                    }
                    xmlFreeDoc( xmldoc1);
                    xmldoc1 = NULL;

                    if ( m_SecurityCommunicate==true )
                    {
                        // 使用加密方式與DRM溝通流程跑完，濾除XML內的特殊字元
                        result = string((char *)pDestBuffer);
                    }

                    delete [] pDestBuffer;
                }
                else
                {
                    // DRM的回傳值不需要DES解密
                    result = result;
                }
            }
            else
            {
                m_SecurityCommunicate = false;
            }
        }

        if ( m_SecurityCommunicate==false )
        {
            //! 跑明碼的傳輸
            string URL = m_ServerIP + "/" + g_WebApp + "?do=CheckSN";
            URL = URL + "&Status=" + FunctionName;
            URL = URL + "&ID=" + m_UserName;
            URL = URL + "&PW=" + m_UserPassword;

            for(size_t i=0;i<ParamNames.size();i++)
            {
                URL = URL + "&" + ParamNames[i] + "=" + BW::BWGenerateValidURL(ParamValues[i]);
            }


				//connie
			URL.append("&HD=308c24b6ab80b915&AP=soEZLecturing&VN=3%2E3&PD=20080711%2E1");


            string URL1 = "140.113.208.98/BWDRM_test/main.aspx?do=CheckSN&Status=GetObjectKey&ID=connie&PW=connie&CI=2&HD=308c24b6ab80b915&AP=soEZLecturing&VN=3%2E3&PD=20080711%2E1";

			
            //DebugMessage(URL);
            //wcout<<URL.c_str();

            // 連結DRM Server取得資料
            if(this->Get(URL, result) == false)
            {
                return false;
            }

            result = result;
        }

    }
    else
    {
        if(FunctionName == string("GetNewObjectID"))
        {
            result += "<?xml version=\"1.0\"?>\n";
            result += "<function name=\"GetNewObjectID\">\n";
            result += "<return name=\"id\" value=\"A001\" />\n";
            result += "<return name=\"key\" value=\"1123\" />\n";
            result += "</function>";
        }
        else if(FunctionName == string("CheckSN"))
        {
            result += "<?xml version=\"1.0\"?>\n";
            result += "<function name=\"CheckSN\">\n";
            result += "<return name=\"result\" value=\"ok\" />\n";
            result += "</function>";
        }
        else if(FunctionName == string("GetReadingLog"))
        {
            result += "<?xml version=\"1.0\"?>\n";
            result += "<function name=\"GetReadingLog\">\n";
            result += "<return name=\"ReadingLog\" date=\"20060623152317\" topic=\"1\" begintime=\"0\" endtime=\"60\"/>\n";
            result += "<return name=\"ReadingLog\" date=\"20060623152417\" topic=\"2\" begintime=\"0\" endtime=\"60\"/>\n";
            result += "</function>";
        }
        else if(FunctionName == string("GetCourseInfo"))
        {
            result += "<?xml version=\"1.0\"?>\n";
            result += "<function name=\"GetCourseInfo\">\n";
            result += "<return name=\"MinimalTime\" value=\"300\" />\n";
            result += "<return name=\"TestURL\" value=\"http://10.0.0.80/bwdram/test.php\" />\n";
            result += "</function>";
        }
        else if(FunctionName == string("SaveReadingLog"))
        {
            result += "<?xml version=\"1.0\"?>\n";
            result += "<function name=\"SaveReadingLog\">\n";
            result += "<return name=\"result\" value=\"ok\" />\n";
            result += "</function>";
        }
        else
        {
            result += "<?xml version=\"1.0\"?>\n";
            result += "<function name=\"\">\n";
            result += "<return name=\"result\" value=\"fail\" />\n";
            result += "</function>";
        }
    }

    XMLText = result;
    return true;
}

//---------------------------------------------------------------------------


bool BWDRMServer::Get(string URL, string &XMLText)
{
    HttpDownload downloader;
    if( downloader.GetURLtoMemory( URL , XMLText ) ){
      //connie cout<<endl<<"*** In Get ***"<<endl<<XMLText.data()<<endl;
      return true;
    }

    return false;
}
//---------------------------------------------------------------------------

string BWDRMServer::ExtractXMLText(string Text)
{
    string XMLHeader = "<?xml";

    int Pos = Text.find(XMLHeader);

    return Text.substr(Pos);
}

//---------------------------------------------------------------------------




//---------------------------------------------------------------------------

BWDRMClient::BWDRMClient()
{
    m_IsInitialized = false;
    m_ServerIP = "";
    m_UserName = "";
    m_UserPassword = "";
    m_pDRMServer = NULL;
}

BWDRMClient::~BWDRMClient()
{
    SAFE_DELETE(m_pDRMServer);
}

bool BWDRMClient::Initialize(string ServerIP, string UserName, string UserPassword)
{
    m_ServerIP = ServerIP;
    m_UserName = UserName;
    m_UserPassword = UserPassword;

    //! 避免一直重新建立BWDRMServer物件，以加速有Proxy的情況下的連線速度
    //SAFE_DELETE(m_pDRMServer);
    //m_pDRMServer = new BWDRMServer;
    if(m_pDRMServer == NULL)
    {
        m_pDRMServer = new BWDRMServer;
    }

    if(m_pDRMServer->Initialize(m_ServerIP) == false)
    {
        return false;
    }

    if(m_pDRMServer->Login(m_UserName, m_UserPassword) == false)
    {
        return false;
    }

    m_IsInitialized = true;
    return true;
}

bool BWDRMClient::CheckSN(string CourseID, string &Code)
{
    if(m_IsInitialized == false)
    {
        return false;
    }

    Code = string("");

    //將xxxx-xxxx格式的課程代號轉回正常的數字
    //wstring value = wstringTowstring(CourseID);
    //BWReplaceString(value, L"-", L"");
    //wstring CI = wstringToInt(value);


    string FunctionName = "Login";
    vector<string> ParamNames;
    vector<string> ParamValues;
    ParamNames.push_back("SN");
    ParamValues.push_back(CourseID);
    ParamNames.push_back("norec");
    ParamValues.push_back("1");


    string XMLText;
    if(m_pDRMServer->Exectue(FunctionName, ParamNames, ParamValues, XMLText) == false)
    {
        return false;
    }

    xmlDoc *xmldoc= NULL;// = NewXMLDocument();
    try
    {
        MyXML m_xml;

        xmldoc = xmlReadMemory( XMLText.data(), XMLText.size() , NULL , NULL , 0);
        //_di_IXMLNode xmlRoot = xmldoc->DocumentElement;
        xmlNode *xmlRoot = NULL;
        xmlRoot = xmlDocGetRootElement(xmldoc);

        // 判斷回傳的XML是否為我們要的XML資料
        if( m_xml.HasAttribute( xmlRoot , xmlCharStrdup("action") )==false )
        //if ( xmlRoot->HasAttribute(wstring(L"action"))==false )
        {
            throw "";
        }

        string action = (char*)m_xml.GetAttribute( xmlRoot , xmlCharStrdup("action") );
        if ( action!="Login" )
        {
            throw "";
        }

        //for(int i=0;i<xmlRoot->ChildNodes->Count;i++)
        for ( int i=0 ; i<m_xml.CountChildNode( xmlRoot ) ; i++ )
        {
            //_di_IXMLNode xmlNode = xmlRoot->ChildNodes->Get(i);
            xmlNode *xmlnode = m_xml.FindChildIndex( xmlRoot , i );
            string Name=(char*)m_xml.GetAttribute( xmlnode , xmlCharStrdup("name") );
            //wstring Name = xmlnode->GetAttribute(L"name");
            string Value=(char*)m_xml.GetAttribute( xmlnode , xmlCharStrdup("value") );
            //wstring Value = xmlnode->GetAttribute(L"value");

            /*
            // 舊式的作法
            if(Name == wstring("Result"))
            {
                Result = Value;
            }
            */

            if ( Name=="Code" )
            {
                Code = Value;
            }

            /*
            // 新的作法，由Code判斷
            if ( Name==wstring(L"Code") && Value==WideString(L"60030") )
            {
                Result = WideString(L"ok");
            }
            else if ( Name==WideString(L"Code") && Value==WideString(L"60040") )
            {
                Result = WideString(L"ok");
            }
            else if ( Name==WideString(L"Code") && Value==WideString(L"60050") )
            {
                Result = WideString(L"ok");
            }
            else if ( Name==WideString(L"Code") && Value==WideString(L"10000") )
            {
                Result = WideString(L"ok");
            }
            */
        }
    }
    catch(...)
    {
        Code = "";
    }

    xmlFreeDoc(xmldoc);
    xmldoc = NULL;
    return true;
}

bool BWDRMClient::GetObjectKey(string CourseID, string &Code, string &CourseKey, map<string, string> &Params)
{
    if(m_IsInitialized == false)
    {
        return false;
    }

    Code = string("");
    Params.clear();

    string FunctionName = "GetObjectKey";
    vector<string> ParamNames;
    vector<string> ParamValues;
    ParamNames.push_back("CI");
    ParamValues.push_back(CourseID);




    string XMLText;
    if(m_pDRMServer->Exectue(FunctionName, ParamNames, ParamValues, XMLText) == false)
    {
        return false;
    }

    //cout<<endl<<"*** After Server Execute ***"<<endl<<XMLText<<endl;

    xmlDoc *xmldoc= NULL;
    try
    {
        MyXML my_xml;
        xmldoc = xmlReadMemory( XMLText.data(), XMLText.size() , NULL , NULL , 0);
        xmlNode *xmlRoot = xmlDocGetRootElement(xmldoc);

        for(int i=0;i<my_xml.CountChildNode( xmlRoot );i++)
        {
            xmlNode *xmlnode = my_xml.FindChildIndex( xmlRoot , i );

            //wstring Name = xmlNode->GetAttribute(L"name");
            string Name = (char*)my_xml.GetAttribute( xmlnode , xmlCharStrdup("name") );
            //wstring Value = xmlNode->GetAttribute(L"value");
            string Value = (char*)my_xml.GetAttribute( xmlnode , xmlCharStrdup("value") );

            if ( string( (char*)xmlnode->name )=="return" )
            {
                if ( Name=="Code" )
                {
                    Code = Value;
                }
                else if(Name == "Result")
                {

                    // 新版回傳值
                    CourseKey = Value;
                }
                else if (Name=="key")
                {
                    // 舊版回傳值
                    CourseKey = Value;
                }
            }
            else if ( string( (char*)xmlnode->name)==string("parameter") )
            //else if ( wstring(xmlNode->NodeName)==wstring("parameter") )
            {
                Params[Name] = Value;
            }
        }
    }
    catch(...)
    {
    }

    xmlFree(xmldoc);
    xmldoc = NULL;

    return true;
}
