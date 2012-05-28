//---------------------------------------------------------------------------

#ifndef BWDRMClientH
#define BWDRMClientH

#include <string>
#include <vector>
#include <map>

using namespace std;

//---------------------------------------------------------------------------


class BWDRMServer
{
public:
    BWDRMServer();
    ~BWDRMServer();

    bool Initialize(string ServerIP);
    bool Login(string UserName, string UserPassword);
    bool Logout();
    bool Exectue(string FunctionName, vector<string> ParamNames, vector<string> ParamValues, string &XMLText);
    //bool Get(string URL, string &XMLText);
private:

    bool Get(string URL, string &XMLText);
    string ExtractXMLText(string Text);/* 用libxml2時，不需要處呼此function */

    bool       m_IsInitialized;
    string m_ServerIP;
    string m_UserName;
    string m_UserPassword;

    bool       m_HttpsEnabled;
    bool       m_SecurityCommunicate;


    bool       m_ProxyCached;
    string m_ProxyServerIP;
    string m_ProxyServerPort;
    string m_ProxyUsername;
    string m_ProxyPassword;


};

//---------------------------------------------------------------------------
// 學習紀錄
//---------------------------------------------------------------------------

struct BWReadingLog
{
    string Date;
    string Topic;
    string BeginTime;
    string EndTime;
};

//---------------------------------------------------------------------------

class BWDRMClient
{
public:

    BWDRMClient();
    ~BWDRMClient();

    bool Initialize(string ServerIP, string UserName, string UserPassword);

    bool CheckSN(string CourseID, string &Code);

    bool GetObjectKey(string CourseID, string &Code, string &CourseKey, map<string, string> &Params);


private:

    bool m_IsInitialized;
    string m_ServerIP;
    string m_UserName;
    string m_UserPassword;

    BWDRMServer *m_pDRMServer;

};



//---------------------------------------------------------------------------
#endif
