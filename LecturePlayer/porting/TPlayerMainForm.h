#ifndef __TPLAYER_MAIN_FORM_H__
#define __TPLAYER_MAIN_FORM_H__




#include "globals.h"

//#include "PlayObject.h"
//#include "MyXML.h"
//#include "BWFileManagerTool.h"
//#include "BWStringTool.h"
//#include "BWCipherDll.h"
//#include "DownloadManager.h"
//
#include <string>
//#include <iostream>
#include <vector>
//#include <fstream> 
#include <map>
//using namespace std;

class TPlayerMainForm
{
public:
    /*!
     *
     */
    TPlayerMainForm();
    /*!
     *
     */
    ~TPlayerMainForm();
    /*!
     *
     */
    void Check_Download(const std::string& DFile, const std::string& publishContent);
    /*!
     *
     */
    void ImportBSTCallback(const std::string& fileName);
    /*!
     *
     */
    std::string ChooseLecture(const std::string& iSrcFName);
    /*!
     *
     */
    bool Choose_PlayWholeBST();
    /*!
     *
     */
    bool LoadPublishFile(
            const std::string&,
            std::vector<std::string>&,
            std::vector<int>&,
            std::vector<std::string>&,
            std::map<std::string, std::string>&, bool);
    /*!
     * \brief load *.bst
     * \param filePath of *.bst
     */
    bool LoadFile(const std::string& filePath);
    /*!
     *
     */
    bool hasPublishXML(const std::string& iSrcFName);
    /*!
     *
     */
    void setBookMarkInfo();
    /*!
     *
     */
    void  getSceneInfo(std::vector<std::string>&);
    TPlayObject *PlayObject;
private:
    std::string publishFile;
   
    std::string Cur_Dir;
    std::string PublishXml;
    bool LocalFile;   //check if local file or download form internet

    //connie DRM
    bool HasDRM ; 
    std::string DRMCourseKey;
    std::string DRMServerIP;
    std::string DRMCourseID;
    /*!
     *
     */
    std::string GetDRMKey(const std::string& usrName, const std::string& usrPwd);
    //connie//先選擇要播放的檔案  java:使用者選完檔案後呼叫此function並傳送選擇的檔案info
    /*!
     *
     */
    void  setFileInfo(const std::string& fileName, bool islocal); 
    /*!
     *
     */
    bool  isPublishFileExist();
    

    //connie bookmark~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    int BookMarkTrackIndex;
    int BookMarkStudyTime;
    HRESULT Core_SaveBookmarkInfo(const std::string& trackIndex, const std::string& studyTime);//儲存此次最後播放的位置
    HRESULT Core_GetBookmarkInfo();
    std::string m_LearningInfoFileName;
    bool g_IsDRMCourse;
    TDownloadManager *DownloadMgr;
    std::vector<std::string> FileTitles;
    std::vector<std::string> FileNames;
    std::vector<int>    FileTimes; //add previous time(now is not use)
    std::vector<std::string> FileTypes; //lecture or flash
    //vector<GtkWidget*> listitem;
    int track_number;
    //------for download file----------------------
    std::string iSrcFDir;
    std::string iDownDir;
    //-------for drawing_area-----------------------
    int configure_count;
    //-------for button1 play or pause--------------
    bool show_pause;
    //connie
    std::string iSrcFName;//檔案的Path/name
    std::string DirNumber;

    bool ElecBoard_on; 
    long count_time;
};

#endif
