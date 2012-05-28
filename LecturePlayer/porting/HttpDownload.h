/* ***** BEGIN COMMENT BLOCK *****
 * GetURLtoFile流程：
 *  1.Socket
 *  2.Connect
 *  3.FormatRequestHeader 產生要request的資料
 *  4.SendRequest 送出request資料
 *  5.GetServerState 取得回傳的http server狀態(回傳資料的第一行)
 *  6.GetResponseLine 取得回傳的資料(接著GetServerState之後以行為單位，取出header裡的資料)
 *  7.取出剩下的資料
 * ***** END COMMENT BLOCK ***** */


#include <sstream>
#include <netinet/in.h>
#include <pthread.h>

#include <fstream>
using namespace std;

#ifndef __HttpDownload__
#define __HttpDownload__


#define LINEMAX 8192


typedef enum _ConnectErrorType{
	iError, //connie加
    iThreadCancel,//connie加

	iSuccess,
    iCreateSocketErr,
    iSetSocketoptErr,
    iBindErr,
    iListenErr,
    iAcceptErr,
    iAddressErr,
    iConnectErr
}ConnectErrorType;

typedef struct _URLStruct{
    std::string host;
    std::string object;
    std::string protocal;
    int port;

    _URLStruct(){
        protocal="http";
        port=80;
    }

}URLStruct;


class DownloadThreadHandler{
   
    private:
		pthread_mutex_t mutex;
		bool IsSetThreadCancel ; 

    public:

		bool isSetThreadCancel(); //connie
		void setThreadCancel(bool); //connie
		void init();


		void pthread_testcancel();
		void Pthread_cancel();

		DownloadThreadHandler(){
	
		pthread_mutex_init(&mutex, NULL); //connie
		init();
		}


	
		
		
	   	
};



class HttpDownload;

class HttpDownload{
    public:
		
	
        ConnectErrorType Socket();
        ConnectErrorType Connect(std::string address , int port);
        ConnectErrorType ConnectNB(std::string address , int port , bool KeepNB);
        /* 只有實作get，post沒有實作 */
        void FormatRequestHeader(std::string pServer , std::string pObject , long nFrom , long nTo);
        bool SendRequest();
        int GetServerState();
        ConnectErrorType GetURLtoFile( std::string URL , std::string FileName , long *FileSize , long *FileRemain );//connie : return int => ConnectErrorType
        ConnectErrorType GetURLtoFile( std::string URL , std::string FileName );//connie : return int => ConnectErrorType
        bool GetURLtoMemory( std::string URL , std::string& buffer );
        ConnectErrorType GetBlocktoFile( std::string URL , std::string FileName , long nFrom , long nTo , bool append , long *FileRemain ); //connie : return int => ConnectErrorType
        ConnectErrorType GetBlocktoFile( std::string URL , std::string FileName , long nFrom , long nTo , bool append );  //connie : return int => ConnectErrorType
        long GetBlocktoMemory( char *block , std::string URL , long nFrom , long nTo );
        int GetResponseLine( std::string& line );
        void ParseURL( URLStruct& UStruct, std::string URL );
        HttpDownload(DownloadThreadHandler *ThreadHandler){
            threadHandler = ThreadHandler;
			
			IsEOS=false;
			
			//pthread_mutex_init(&mutex1, NULL); //connie
			
		}
		HttpDownload(){
            //threadHandler = ThreadHandler;
			
			IsEOS=false;
			
			//pthread_mutex_init(&mutex1, NULL); //connie
			
			
			

		
		}
		
		
		//void SetThreadCancelOK(bool);

		

    private:
		
        std::string m_requestheader;
        std::string data_buffer;
        bool IsEOS;
        int sockfd;
		
		DownloadThreadHandler *threadHandler;

		

	

        //unsigned long requested_data_size;

};

//--------------------------------------------------------













#endif
