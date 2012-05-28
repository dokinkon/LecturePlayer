#include <iostream>
#include <fstream>
#include <map>
#include "DownloadManager.h"
#include "PlayObject.h"


using namespace std;

extern map< string , string >hlist;



void* DoThreadFunction( void* thread_data );


FileInfo InitialFileInfo(string urlstring , string localfilename,FileInfo &fileinfo ){

 
  fileinfo.LocalFileName=localfilename;
  fileinfo.URL_String=urlstring;
  fileinfo.FileSize=-1;
  fileinfo.CompletedSize=-1;
  fileinfo.UnCompletedSize=-1;
  fileinfo.DM_Status=DM_IDLE;
  return fileinfo;
}

TDownloadManager::TDownloadManager(){

  this->download_thread=0L;
  OnSelected=0;
  DownloadFileTable.clear();
}

TDownloadManager::~TDownloadManager(){

}

void TDownloadManager::SetupDownloadFileTable(string urlstring , string localfilename){
	LOGD("start DownloadMgr->SetupDownloadFileTable(urlstring,fstring); " );

    FileInfo fileinfo;

	InitialFileInfo(urlstring , localfilename, fileinfo );
	LOGD(" mid DownloadMgr->SetupDownloadFileTable(urlstring,fstring); " );

	LOGD( fileinfo.URL_String.c_str() );
	LOGD( fileinfo.LocalFileName.c_str() );

	DownloadFileTable.push_back( fileinfo );
	//DownloadFileTable[urlstring]=fileinfo;
	
	LOGD(" end DownloadMgr->SetupDownloadFileTable(urlstring,fstring); " );


}

int TDownloadManager::StartThreadDownload( unsigned int start_pos ){

	LOGD("StartThreadDownload; " );

  //先把正在執行的thread中斷掉，設定OnSelected，再重新開始thread
  if( download_thread!=0 ){
	   
	  threadHandler.Pthread_cancel();
	  //connie pthread_cancel( download_thread );
	  
	  LOGD("StartThreadDownload kill " );
	//  threadHandler.setThreadCancel(true);//connie
		
	   
	    LOGD("join " );
	  
       pthread_join( download_thread , NULL);


	    LOGD("after join " );


	   //threadHandler.init();
  }

   LOGD("StartThreadDownload; 1" );
  
   if( start_pos>=DownloadFileTable.size() || start_pos<0 )
    return -1;

      LOGD("StartThreadDownload; 2" );
  OnSelected=start_pos;

  int err;
 
  err=pthread_create( &download_thread,NULL, DoThreadFunction , this );
    
  if( err!=0 ){cout<<strerror( err )<<endl;
	  LOGD("StartThreadDownload err" );
  }
   LOGD("StartThreadDownload end" );
  return err;
}

void* DoThreadFunction( void* thread_data ){ //connie
	
	 LOGD("DoThreadFunction" );

	TDownloadManager *dfmgr=(TDownloadManager*)thread_data;

	ConnectErrorType retval;

	//retval =
	dfmgr->DownloadList(thread_data );
	 /*
	if(retval == iThreadCancel ){

	    pthread_join( download_thread , NULL);
		threadHandler.init();
	}
*/



}



ConnectErrorType TDownloadManager::DownloadList( void* thread_data ){ //return void* = > ConnectErrorType

	 LOGD("DownloadList" );
//connie  pthread_setcancelstate(PTHREAD_CANCEL_ENABLE,NULL);
  TDownloadManager *dfmgr=(TDownloadManager*)thread_data;

 ConnectErrorType retval;
  

  cout<<"\t*** Child thread : "<<pthread_self()<<endl;

  vector<FileInfo>::iterator itr;

  size_t counter=0;
  size_t table_size=dfmgr->DownloadFileTable.size();

  /* 把狀態設成idle，再下載一次看看 */
  if( dfmgr->DownloadFileTable[dfmgr->OnSelected].DM_Status==DM_ERROR )
    dfmgr->DownloadFileTable[dfmgr->OnSelected].DM_Status=DM_IDLE;

  for( int i=dfmgr->OnSelected ; counter<table_size ; ++i, ++counter ){
	LOGD("dfor~~~~~~~ " );
	
	if( i == 0)
	LOGD("dfor~~~~~~~                              i = 0 " );

	if( i == 1)
	LOGD("dfor~~~~~~~                               i = 1 " );


	
	if( i == 2)
	LOGD("dfor~~~~~~~                              i = 2 " );

	if( i == 3)
	LOGD("dfor~~~~~~~                               i = 3 " );


	if( i == 4)
	LOGD("dfor~~~~~~~                              i = 4 " );

	if( i == 5)
	LOGD("dfor~~~~~~~                               i = 5 " );


	if( i == 6)
	LOGD("dfor~~~~~~~                              i = 6 " );

	if( i == 7)
	LOGD("dfor~~~~~~~                               i = 7 " );





   // for( int i=dfmgr->OnSelected ; counter<1 ; ++i, ++counter ){
		  LOGD("in for~~~~" );

     threadHandler.pthread_testcancel();
/*
	 if(threadHandler.isSetThreadCancel())//connie改
		return iThreadCancel;
*/
	 LOGD("in for~~~~0" );
    //cout<<dfmgr->DownloadFileTable[i%table_size].LocalFileName<<endl;

    if( dfmgr->DownloadFileTable[i%table_size].DM_Status==DM_COMPLETE
		|| dfmgr->DownloadFileTable[i%table_size].DM_Status==DM_ERROR ){
			 LOGD("DM_COMPLETE || DM_ERROR" );
			 continue;
		
	}
	 LOGD("in for~~~~1" );

    HttpDownload dwn(&threadHandler);
	DWN = &dwn;
    //已經有先下載一部分了
    if( dfmgr->DownloadFileTable[i%table_size].FileSize>0 ){
		  LOGD("file has download but not finish ,continue download~ " );

      //先算檔案size
      //cout<<"===== getblock ====="<<endl;

      long length;
      fstream fout;
      //string filename=dfmgr->DownloadFileTable[i%table_size].FileName.substr(dfmgr->DownloadFileTable[i%table_size].FileName.find_last_of("/")+1);

      fout.open( dfmgr->DownloadFileTable[i%table_size].LocalFileName.c_str() );
      //cout<<"File Name = "<<dfmgr->DownloadFileTable[i%table_size].LocalFileName<<endl;

      if( !fout.is_open() ){
        cout<<"open failed"<<endl;
        fout.close();

		LOGD("open failed~" );
        retval=dwn.GetURLtoFile( dfmgr->DownloadFileTable[i%table_size].URL_String ,
                         dfmgr->DownloadFileTable[i%table_size].LocalFileName,
                         &(dfmgr->DownloadFileTable[i%table_size].FileSize),
                         &(dfmgr->DownloadFileTable[i%table_size].UnCompletedSize) );

		
      }

      else{
        cout<<"open success"<<endl;
		LOGD("open success~" );
        fout.seekg (0, ios::end);
        length = fout.tellg();
        fout.close();
		ConnectErrorType retval;


		LOGD("GetBlocktoFile~" );


        retval=dwn.GetBlocktoFile( dfmgr->DownloadFileTable[i%table_size].URL_String ,
                                     dfmgr->DownloadFileTable[i%table_size].LocalFileName ,
                                     length ,
                                     dfmgr->DownloadFileTable[i%table_size].FileSize ,
                                     true ,
                                     &(dfmgr->DownloadFileTable[i%table_size].UnCompletedSize) );
		
        if( retval== iError){
          dfmgr->DownloadFileTable[i%table_size].DM_Status=DM_ERROR;
          continue;
        }
      }
    }

    else{

		 LOGD("file download from begin " );
      //應該也要改成跟GetBlocktoFile一樣
      int retval=dwn.GetURLtoFile( dfmgr->DownloadFileTable[i%table_size].URL_String ,
                        dfmgr->DownloadFileTable[i%table_size].LocalFileName,
                        &(dfmgr->DownloadFileTable[i%table_size].FileSize),
                        &(dfmgr->DownloadFileTable[i%table_size].UnCompletedSize) );
    
	  if( retval==-1){
        dfmgr->DownloadFileTable[i%table_size].DM_Status=DM_ERROR;
          continue;
      }
    }

    dfmgr->DownloadFileTable[i%table_size].DM_Status=DM_COMPLETE;

  }
	
	 LOGD("DownloadList end" );
return iSuccess;
  
}

void TDownloadManager::StoreHostName()
{
    /*

  for( size_t i=0 ; i<DownloadFileTable.size() ; ++i ){
    size_t start,end;
    start=DownloadFileTable[i].URL_String.find("://");

    if( start==string::npos )continue;

    start+=3;
    end=DownloadFileTable[i].URL_String.find( "/", start );

    if( end==string::npos )continue;

    string host=DownloadFileTable[i].URL_String.substr( start , end-start );

    //先看hlist有沒有資料
    map<string,string>::iterator itr;
    if( ( itr=hlist.find( host ) )!=hlist.end() )continue;

    // 沒有，先取得資料
    struct hostent he,*result;
    int h_err;
    char dns_buf[8192];

    if( gethostbyname_r( host.c_str() , &he , dns_buf , 8192 , &result , &h_err )!=0 || result==NULL )
      continue;

    hlist[host]=he.h_addr;
    //cout<<he.h_addr<<endl;

    cout<<"\t*** host name : "<<"start: "<<start<<" end: "<<end<<" "<<host<<endl;
  }
     */
}





