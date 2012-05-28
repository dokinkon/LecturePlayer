#include "TPlayerMainForm.h"
#include "DownloadManager.h"
#include "BWDRMClient.h"
#include "BWFileManagerTool.h"
#include "BWCipherDll.h"
#include "MyXML.h"
#include "PlayObject.h"
//#include <libxml/parser.h>
//#include <libxml/tree.h>


using namespace std;

//---------------------------------------------------------------------------
TPlayerMainForm::TPlayerMainForm()
{
	track_number = 0;
	//------for download file----------------------
	iSrcFDir = "";
	iDownDir = "";
	//-------for drawing_area-----------------------
	configure_count = 0;
	//-------for button1 play or pause--------------
	show_pause = true;
	publishFile = "";
	PlayObject = NULL;
	//~~~~~~~~~~~~
	Cur_Dir = BWGetCurrentDirNew();
	DownloadMgr = new TDownloadManager();

	g_IsDRMCourse = false;
	DRMCourseKey = "";
}
//---------------------------------------------------------------------------
TPlayerMainForm::~TPlayerMainForm()
{
	SAFE_DELETE(PlayObject);
}
//---------------------------------------------------------------------------
void TPlayerMainForm::setFileInfo(const string& fileName, bool islocal)
{
    //connie改過 //先選擇要播放的檔案  java:使用者選完檔案後呼叫此function並傳送選擇的檔案info
	iSrcFName = fileName;
	iSrcFDir = BWExtractFileDirNew(iSrcFName); //in BWFileManager.cpp
	LocalFile = islocal;
	publishFile = iSrcFDir + "/publish.xml";
	setBookMarkInfo();
}
//---------------------------------------------------------------------------
void TPlayerMainForm::Check_Download(const string& DFile, const string& publishContent)
{
	LocalFile = false;
	iDownDir = BWExtractFileDirNew(DFile);
	int len = iDownDir.length();
	int pos = iDownDir.find_last_of('/', len);
	DirNumber.assign(iDownDir, pos + 1, len);
	iSrcFDir = Cur_Dir + "/soEZLecturing/.cache/sou";
	if (!BWFileExistsNew(iSrcFDir))
		BWCreateDirectory(iSrcFDir.c_str()); //connie

	iSrcFDir = Cur_Dir + "/soEZLecturing/.cache/sou/" + DirNumber;

	if (!BWFileExistsNew(iSrcFDir))
		BWCreateDirectory(iSrcFDir.c_str()); //connie
	publishFile = iSrcFDir + "/publish.xml";

	ofstream publishXmlout(publishFile.c_str());
	publishXmlout << publishContent;
	publishXmlout.close();
	setBookMarkInfo();
}
//------------------------------------------------------------------------------
void TPlayerMainForm::setBookMarkInfo()
{
	if (BWFileExistsNew(publishFile)) {
		string PublishFileMd5String = BWCipherDll::BWCipherMd5Sum(
				(char*) publishFile.c_str());

		string m_LearningInfoDir = Cur_Dir
				+ "/soEZLecturing/Player/LearningInfo/";

		if (!BWDirectoryExistsNew(Cur_Dir + "/soEZLecturing/Player/"))
			BWCreateDirectory(Cur_Dir + "/soEZLecturing/Player/");

		if (!BWDirectoryExistsNew(m_LearningInfoDir))
			BWCreateDirectory(m_LearningInfoDir);

		m_LearningInfoFileName = m_LearningInfoDir + PublishFileMd5String + ".xml";
	}
}
//------------------------------------------------------------------------------
bool TPlayerMainForm::isPublishFileExist()
{
	return BWFileExistsNew(publishFile);
}
//------------------------------------------------------------------------------
bool TPlayerMainForm::Choose_PlayWholeBST() 
{ 
    //return 成功/失敗,失敗訊息,track num,track的資訊
	vector<string> trackTitles;
	vector<int> trackTimes;
	vector<string> trackFileNames;
	map<string, string> publishInfo;
	string errorTitle = "";
	string errorMsg = "";
	string isOK = "";

	LOGD(publishFile.c_str());

	if (LoadPublishFile(publishFile.c_str(), trackTitles, trackTimes,
			trackFileNames, publishInfo, LocalFile)) {

		isOK = "true";
		int Login_Counter = 3;
		if ((publishInfo["ServerIP"] != "")
				&& (publishInfo["CourseID"] != "")) {
			HasDRM = true;
			g_IsDRMCourse = true;
			DRMServerIP = publishInfo["ServerIP"];
			DRMCourseID = publishInfo["CourseID"];
		} else {
			g_IsDRMCourse = false;
			HasDRM = false;
		}

		//--------------PUT DATA-------------------------------------------------
		FileNames.clear();
		FileTypes.clear();
		FileTitles.clear();
		int add_time = 0;
		for (unsigned int i = 0; i < trackFileNames.size(); i++)
        {
			FileNames.push_back(iSrcFDir + "/" + trackFileNames[i]);
			FileTitles.push_back(trackTitles[i]);
			FileTimes.push_back(trackTimes[i]);

			if (trackTimes[i] == 0)
				FileTypes.push_back(string("flash"));
			else
				FileTypes.push_back(string("lecture"));
			add_time += trackTimes[i] / 100 + 1; //add 1 sec to ensure finish
		}

		//-------create download manager----------------------
		// 網路上的檔案的話  //cout<<"test"<<endl;
		if (!LocalFile)
        {
			string urlstring, fstring;
			for (unsigned int i = 0; i < trackFileNames.size(); i++) {
				urlstring = iDownDir + "/" + trackFileNames[i];
				fstring = iSrcFDir + "/" + trackFileNames[i];
				LOGD(urlstring.c_str());
				LOGD(fstring.c_str());
				DownloadMgr->SetupDownloadFileTable(urlstring, fstring);
				LOGD("DownloadMgr->SetupDownloadFileTable(urlstring,fstring); ");
			}

			DownloadMgr->StoreHostName();
			if (DownloadMgr->StartThreadDownload(track_number) != 0) 
            {
				exit(1);
			}
		}
		return true;

	}
    else 
    {
		//isOK = "false";
		//errorTitle = "Publish.xml錯誤";
		//errorMsg = "嚴重錯誤：publish.xml不存在或有錯誤"";
		return false;
	}
}
//----------------------------------------------------------------------------------------
string TPlayerMainForm::GetDRMKey(const string& userName, const string& userPassword) 
{
	BWDRMClient *pDRMClient = new BWDRMClient();

	if (!pDRMClient->Initialize(DRMServerIP, userName, userPassword)) 
    {
		DRMCourseKey = "";
		return DRMCourseKey;
	}

	string code;
	map<string, string> Params;
	if (!pDRMClient->GetObjectKey(DRMCourseID, code, DRMCourseKey, Params)) 
    {
		DRMCourseKey = "";
		return DRMCourseKey;
	}

	if (code.compare("30210") != 0)
		DRMCourseKey = "";

	delete pDRMClient;
	return DRMCourseKey;
}
//----------------------------------------------------------------------------------------
bool TPlayerMainForm::LoadPublishFile(
    const string& publishFileName,
    vector<string>& trackTitles,
    vector<int>&    trackTimes,
    vector<string>& trackFileNames,
    map<string, string>& publishInfo,
    bool isLocalFile) 
{
	xmlDoc* xmldoc = NULL;
	xmlNode* RootNode = NULL;
	MyXML m_xml;

	if (isLocalFile)
    {
		if (!BWFileExistsNew(publishFileName.c_str()))
        {
			return false;
		}
		LOGD("publishFileName = ");
		LOGD(publishFileName.c_str());
		string s = xmlconvertFormfile(publishFileName);
		xmldoc = xmlReadMemory(s.c_str(), s.size(), NULL, NULL, 0);
	} 
    else
    {
		xmldoc = xmlReadFile(publishFileName.c_str(), NULL, 0);
	}

	if (xmldoc == NULL && isLocalFile && BWFileExistsNew(publishFileName.c_str()) == true) 
    { 
        //connie 避免網路上下載下來的publish.xml已經轉成utf-8存入檔案了
		xmldoc = xmlReadFile(publishFileName.c_str(), NULL, 0);
	}

	if (xmldoc == NULL)
    {
		return false;
	}
	//Get the root element node
	RootNode = xmlDocGetRootElement(xmldoc);
	//printf("root_name:%s\n",RootNode->name);
	int type = 0; //0~error,1~chinese,2~english
	if (strcmp((const char*) RootNode->name, "講解手發佈檔") == 0)
		type = 1;
	else if (strcmp((const char*) RootNode->name, "BSTPublish") == 0)
		type = 2;
	else
		return false;
	// 讀取發佈資訊
	xmlNode* InfoNode = NULL;
	if (type == 1)
		InfoNode = m_xml.FindChildNode(RootNode, xmlCharStrdup("發佈資訊"));
	else
		InfoNode = m_xml.FindChildNode(RootNode, xmlCharStrdup("CourseInfo"));
	if (InfoNode != NULL)
    {
		if (m_xml.HasAttribute(InfoNode, xmlCharStrdup("CourseName")))
        {
			publishInfo["CourseName"] = string(
					(char*)m_xml.GetAttribute(InfoNode,
							xmlCharStrdup("CourseName")));
		}
		if (m_xml.HasAttribute(InfoNode, xmlCharStrdup("Subject"))) 
        {
			publishInfo["Subject"] = string(
					(char*)m_xml.GetAttribute(InfoNode,
							xmlCharStrdup("Subject")));
		}
		if (m_xml.HasAttribute(InfoNode, xmlCharStrdup("Level"))) {
			publishInfo["Level"] = string(
					(char*) m_xml.GetAttribute(InfoNode,
							xmlCharStrdup("Level")));
		}
		if (m_xml.HasAttribute(InfoNode, xmlCharStrdup("Keyword"))) {
			publishInfo["Keyword"] = string(
					(char*) m_xml.GetAttribute(InfoNode,
							xmlCharStrdup("Keyword")));
		}
		if (m_xml.HasAttribute(InfoNode, xmlCharStrdup("Copyright"))) {
			publishInfo["Copyright"] = string(
					(char*) m_xml.GetAttribute(InfoNode,
							xmlCharStrdup("Copyright")));
		}
		if (m_xml.HasAttribute(InfoNode, xmlCharStrdup("Comment"))) {
			publishInfo["Comment"] = string(
					(char*) m_xml.GetAttribute(InfoNode,
							xmlCharStrdup("Comment")));
		}
		if (m_xml.HasAttribute(InfoNode, xmlCharStrdup("Teacher"))) {
			publishInfo["Teacher"] = string(
					(char*) m_xml.GetAttribute(InfoNode,
							xmlCharStrdup("Teacher")));
		}
		if (m_xml.HasAttribute(InfoNode, xmlCharStrdup("TeacherMail"))) {
			publishInfo["TeacherMail"] = string(
					(char*) m_xml.GetAttribute(InfoNode,
							xmlCharStrdup("TeacherMail")));
		}
		if (m_xml.HasAttribute(InfoNode, xmlCharStrdup("TeacherImage"))) {
			publishInfo["TeacherImage"] = string(
					(char*) m_xml.GetAttribute(InfoNode,
							xmlCharStrdup("TeacherImage")));
		}
	}

	// 讀取面板資訊
	xmlNode* SkinNode = NULL;
	if (type == 1)
		SkinNode = m_xml.FindChildNode(RootNode, xmlCharStrdup("面板資訊"));
	else
		SkinNode = m_xml.FindChildNode(RootNode, xmlCharStrdup("SkinInfo"));
	if (SkinNode != NULL) {
		if (m_xml.HasAttribute(SkinNode, xmlCharStrdup("SkinName"))) {
			publishInfo["SkinName"] = string(
					(char*) m_xml.GetAttribute(SkinNode,
							xmlCharStrdup("SkinName")));
		}
		if (m_xml.HasAttribute(SkinNode, xmlCharStrdup("FileName"))) {
			publishInfo["FileName"] = string(
					(char*) m_xml.GetAttribute(SkinNode,
							xmlCharStrdup("FileName")));
		}
		if (m_xml.HasAttribute(SkinNode, xmlCharStrdup("Md5"))) {
			publishInfo["Md5"] = string(
					(char*) m_xml.GetAttribute(SkinNode, xmlCharStrdup("Md5")));
		}
	}

	// 讀取播放資訊
	xmlNode* PlayNode = NULL;
	if (type == 1)
		PlayNode = m_xml.FindChildNode(RootNode, xmlCharStrdup("播放資訊"));
	else
		PlayNode = m_xml.FindChildNode(RootNode, xmlCharStrdup("PlayInfo"));
	if (PlayNode != NULL) {
		if (m_xml.HasAttribute(PlayNode, xmlCharStrdup("JumpSetting"))) {
			publishInfo["JumpSetting"] = string(
					(char*) m_xml.GetAttribute(PlayNode,
							xmlCharStrdup("JumpSetting")));
		}

		if (m_xml.HasAttribute(PlayNode, xmlCharStrdup("ShowPIPButton"))) {
			publishInfo["ShowPIPButton"] = string(
					(char*) m_xml.GetAttribute(PlayNode,
							xmlCharStrdup("ShowPIPButton")));
		}

		if (m_xml.HasAttribute(PlayNode, xmlCharStrdup("PlayMode"))) {
			publishInfo["PlayMode"] = string(
					(char*) m_xml.GetAttribute(PlayNode,
							xmlCharStrdup("PlayMode")));
		}
	}

	trackTitles.clear();
	trackTimes.clear();
	trackFileNames.clear();

	// 讀取課程主題資訊
	xmlNode* CourseNode = NULL;
	if (type == 1)
		CourseNode = m_xml.FindChildNode(RootNode, xmlCharStrdup("課程"));
	else
		CourseNode = m_xml.FindChildNode(RootNode, xmlCharStrdup("Course"));
	for (int i = 0; i < m_xml.CountChildNode(CourseNode); i++) {
		xmlNode* TopicNode = m_xml.FindChildIndex(CourseNode, i);

		string Title = string(
				(char*) m_xml.GetAttribute(TopicNode, xmlCharStrdup("Title")));
		int Time = atoi(
				(char*) m_xml.GetAttribute(TopicNode, xmlCharStrdup("Time")));
		string FileName = string(
				(char*) m_xml.GetAttribute(TopicNode,
						xmlCharStrdup("FileName")));

		trackTitles.push_back(Title);
		trackTimes.push_back(Time);
		trackFileNames.push_back(FileName);
	}
	// 讀取DRM資訊
	xmlNode* DRMNode = m_xml.FindChildNode(RootNode, xmlCharStrdup("drm"));
	if (DRMNode != NULL) {
		if (m_xml.HasAttribute(DRMNode, xmlCharStrdup("ServerIP"))) {
			publishInfo["ServerIP"] = string(
					(char*) m_xml.GetAttribute(DRMNode,
							xmlCharStrdup("ServerIP")));
		}

		if (m_xml.HasAttribute(DRMNode, xmlCharStrdup("CourseID"))) {
			publishInfo["CourseID"] = string(
					(char*) m_xml.GetAttribute(DRMNode,
							xmlCharStrdup("CourseID")));
		}
	}
	xmlFreeDoc(xmldoc); //free xml doc
	return true;
}
//---------------------------------------------------------------------------------
bool TPlayerMainForm::LoadFile(const string& i_SrcFName) 
{
	if (PlayObject != NULL) 
    {
		delete PlayObject;
	}

	PlayObject = new TPlayObject();
	*PlayObject->m_SrcBSAFName = i_SrcFName;
	string SaveDir = Cur_Dir + "/soEZLecturing/.cache/des/"
			+ BWExtractFileOnly(i_SrcFName);
    
    NSLog(@"SAVE DIR:");
    LOGD(SaveDir.c_str());

	*PlayObject->m_DirBSAFName = SaveDir;

	//-----add drm_key------------
	if (g_IsDRMCourse) {
		PlayObject->resource->SetKey(DRMCourseKey);
	} else {
		PlayObject->resource->SetKey("magical");
	}

	if (!PlayObject->LoadFile()) {
		return false;
	}

	if (!PlayObject->ParseScript()) {
		return false;
	}

	if (!PlayObject->ParseScene()) {
		return false;
	}
	return true;
}
//---------------------------------------------------------------------------------
void TPlayerMainForm::getSceneInfo(vector<string>&SceneInfo)
{
	SceneInfo.clear();
	int left, top, width, height;
	int left_f, top_f, width_f, height_f;

	for (unsigned int i = 0; i < PlayObject->scene->m_ActorList.size(); i++)
    { //先做非全螢幕的設定
		left = PlayObject->scene->m_ActorList[i]->m_X
				+ PlayObject->scene->m_ActorList[i]->m_ImageX; //connie 設定Actor(img)擺放的位置
		top = PlayObject->scene->m_ActorList[i]->m_Y
				+ PlayObject->scene->m_ActorList[i]->m_ImageY;
		width = PlayObject->scene->m_ActorList[i]->m_ImageWidth;
		height = PlayObject->scene->m_ActorList[i]->m_ImageHeight;
		string pic_path = PlayObject->scene->m_ActorList[i]->m_ImageFileName; //connie 讀Actor(img)的path+名稱

		//add by darren
		string img_path = "material";
		img_path += PlayObject->scene->m_ActorList[i]->m_ImageFileName.substr(
				pic_path.find_last_of("/"));

		if (img_path.find(".png", 0) != string::npos ||
		    img_path.find(".jpg", 0) != string::npos ||
		    img_path.find(".bmp", 0) != string::npos)
        {
			SceneInfo.push_back(img_path);
			SceneInfo.push_back(IntToStringNew(left,0));
			SceneInfo.push_back(IntToStringNew(top,0));
			SceneInfo.push_back(IntToStringNew(width,0));
			SceneInfo.push_back(IntToStringNew(height,0));
		}
	} //end for
	ElecBoard_on = false; //default
}
//-------------------------------------------------------------------------------------------
HRESULT TPlayerMainForm::Core_SaveBookmarkInfo(const string& TrackIndex, const string& StudyTime)
{
	if (m_LearningInfoFileName == "\\")
    {
		// 網芳上的課程
		return E_FAIL;
	}

	if (FileTitles.empty()) {
		// 使用者直接點擊BST檔，並且只開啟BST檔
		return E_FAIL;
	}

	if (m_LearningInfoFileName.empty()) {
		return E_FAIL;
	}

	MyXML m_xml;
	xmlDocPtr xmldoc;

	if (BWFileExistsNew(m_LearningInfoFileName.c_str())) 
    {
		xmldoc = xmlReadFile(m_LearningInfoFileName.c_str(), NULL, 0);
	}
    else 
    {
		xmldoc = xmlNewDoc(BAD_CAST "1.0");
		xmlNodePtr xmlRoot = xmlNewNode(NULL, BAD_CAST "LearningInfo");
		// 寫入學習紀錄版本資訊
		// WideString LearningInfoFileVersion = L"1.0";
		//xmlRoot->Attributes[L"version"] = LearningInfoFileVersion;
		string LearningInfoFileVersion = "1.0";
		xmlNewProp(xmlRoot, BAD_CAST "version",
				BAD_CAST (LearningInfoFileVersion.c_str()));
		xmlDocSetRootElement(xmldoc, xmlRoot);
	}

	xmlNodePtr xmlRoot = xmlDocGetRootElement(xmldoc);
	xmlNodePtr xmlBookmark = m_xml.FindChildNode(xmlRoot, BAD_CAST "Bookmark");

	if (xmlBookmark == NULL)
    {
		xmlBookmark = xmlNewNode(NULL, BAD_CAST "Bookmark");
		xmlBookmark = xmlDocCopyNode(xmlBookmark, xmldoc, 1);
		xmlAddChild(xmlRoot, xmlBookmark);
	}

	if (g_IsDRMCourse == true) 
    {
	} 
    else
    {
		xmlSetProp(xmlBookmark, BAD_CAST "TrackIndex",
				BAD_CAST (TrackIndex.c_str())); //
		xmlSetProp(xmlBookmark, BAD_CAST "StudyTime",
				BAD_CAST (StudyTime.c_str())); //
	}
	xmlSaveFile(m_LearningInfoFileName.c_str(), xmldoc);
	xmlFreeDoc(xmldoc);
	return S_OK;
}

HRESULT TPlayerMainForm::Core_GetBookmarkInfo() 
{
	BookMarkTrackIndex = 0;
	BookMarkStudyTime = 0;

	if (m_LearningInfoFileName.substr(0, 1) == "\\") {
		// 網芳上的課程
		return E_FAIL;
	}

	if (FileTitles.empty())
    {
		// 使用者直接點擊BST檔，並且只開啟BST檔
		return E_FAIL;
	}

	if (!BWFileExistsNew(m_LearningInfoFileName.c_str())) 
    {
		return E_FAIL;
	}

	MyXML m_xml;
	xmlDocPtr xmldoc;

	xmldoc = xmlReadFile(m_LearningInfoFileName.c_str(), NULL, 0);
	xmlNodePtr xmlRoot = xmlDocGetRootElement(xmldoc);

	if (xmlRoot == NULL) {
		return E_FAIL;
	}

	xmlNodePtr xmlBookmark = m_xml.FindChildNode(xmlRoot, BAD_CAST "Bookmark");

	if (xmlBookmark == NULL) 
    {
		// 無法取得書籤的Node
		return E_FAIL;
	}

	if (g_IsDRMCourse == true)
    {
        // TODO
    }
    else
    {
		if (!m_xml.HasAttribute(xmlBookmark, xmlCharStrdup("TrackIndex")))
        {
			return E_FAIL;
		}

		if (!m_xml.HasAttribute(xmlBookmark, xmlCharStrdup("StudyTime"))) {
			return E_FAIL;
		}

		BookMarkTrackIndex = atoi(
				(char*) m_xml.GetAttribute(xmlBookmark,
						xmlCharStrdup("TrackIndex")));
		BookMarkStudyTime = atoi(
				(char*) m_xml.GetAttribute(xmlBookmark,
						xmlCharStrdup("StudyTime")));
		LOGD((char*)m_xml.GetAttribute(xmlBookmark, xmlCharStrdup("TrackIndex")));
		LOGD((char*)m_xml.GetAttribute(xmlBookmark, xmlCharStrdup("StudyTime")));
	}
	xmlFreeDoc(xmldoc);
	return S_OK;
}

