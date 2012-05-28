
#include <string>
#include <vector>
#include <pthread.h>
//#include <gtk/gtk.h>

#include <netdb.h>         /* gethostbyname() */
#include <sys/types.h>     /* htons() ... */
#include "HttpDownload.h"
using namespace std;

#ifndef __DOWNLOADMANAGER__
#define __DOWNLOADMANAGER__



class TDownloadManager;

typedef enum{
  DM_DOWNLOADING = 0,
  DM_IDLE = 1,
  DM_COMPLETE = 2,
  DM_ERROR = 3
}DownloadFileStatus;

typedef struct FileInfo{
  string LocalFileName;
  string URL_String;
  long FileSize;
  long CompletedSize;
  long UnCompletedSize;
  DownloadFileStatus DM_Status;
}FileInfo;

FileInfo InitialFileInfo( string urlstring , string localfilename );

class TDownloadManager{
 
    
  public:
    vector<FileInfo> DownloadFileTable;
    int OnSelected;
    TDownloadManager();
    ~TDownloadManager();
    void SetupDownloadFileTable( string urlstring , string localfilename );
    int StartThreadDownload( unsigned int start_pos );
    void StoreHostName();
	//void* DoThreadFunction(void* thread_data);
    ConnectErrorType DownloadList(void* thread_data); //connie ­nstatic¶Ü?



    private:
		pthread_t download_thread;
		DownloadThreadHandler threadHandler;//connie
	HttpDownload  *DWN;//connie
};

/*

typedef struct{
 // GtkTreeView *treeview;
  TDownloadManager *dfmgr;
}Timer_Data;
*/
#endif
