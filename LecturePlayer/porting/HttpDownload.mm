#include "HttpDownload.h"
#include "BWStringTool.h"


#include <sys/types.h>     /* htons() ... */
#include <sys/socket.h>    /* socket(), bind(), listen(), accept() */

#include <sys/param.h>     /* MAXHOSTNAMELEN */
#include <netdb.h>         /* gethostbyname() */

#include <unistd.h>        /* close(), gethostname(), read() ... */
#include <stdio.h>         /* perror() */
#include <strings.h>       /* bzero(), bcopy() */
#include <errno.h>

#include <string>
#include <iostream>
#include <sstream>
#include <fstream>
#include <map>
#include <fcntl.h>

#include "PlayObject.h"
//using namespace android;
using namespace std;

ofstream fout("/sdcard/socket.txt");

	string s1 = "";
/* 將gethostbyname_r得到的資料存下來，以後執行gethostbyname時可以先查表 */
map< string , string >hlist;

ConnectErrorType HttpDownload::Socket(){
    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
        return iCreateSocketErr;
    }

    else return iSuccess;
}

ConnectErrorType HttpDownload::Connect(string address , int port){

    struct sockaddr_in serv_addr;

    bzero( (char*)&serv_addr,sizeof(serv_addr) );
    serv_addr.sin_family=AF_INET;

    //set port
    serv_addr.sin_port=htons( port );

    //set address
    struct hostent *he;
    if( (he=gethostbyname( address.c_str() ) )==NULL )
        return iAddressErr;

    serv_addr.sin_addr = *((struct in_addr *)he->h_addr);

    //connect to server
    if(connect(sockfd,(struct sockaddr *)&serv_addr,sizeof(serv_addr)) == -1)
        return iConnectErr;

    cout<<"connect success"<<endl;

    return iSuccess;

}

ConnectErrorType HttpDownload::ConnectNB(std::string address , int port , bool KeepNB)
{
    /*

    //cout<<"*** ConnectNB 1"<<endl;
    struct sockaddr_in serv_addr;

    bzero( (char*)&serv_addr,sizeof(serv_addr) );
    serv_addr.sin_family=AF_INET;

    //set port
    serv_addr.sin_port=htons( port );

    //set address

    threadHandler->pthread_testcancel();//connie改
   // if(threadHandler->isSetThreadCancel())//connie改
	//	return iThreadCancel;
	
	
	
	
	//cout<<"*** ConnectNB before gethostbyname"<<endl;

    //struct hostent *he;
    //if( (he=gethostbyname( address.c_str() ) )==NULL )
    //    return iAddressErr;

    map<string,string>::iterator itr;
    //hlist裡有資訊
    if( ( itr=hlist.find(address) )!=hlist.end() ){
      //cout<<"\t*** found in hlist"<<endl;
      //cout<<(*itr).second.h_addr<<endl;
      serv_addr.sin_addr = *((struct in_addr *)(*itr).second.c_str());
    }
    else{
      struct hostent he,*result;
      int h_err;
      char dns_buf[8192];

      if( gethostbyname_r( address.c_str() , &he , dns_buf , 8192 , &result , &h_err )!=0 || result==NULL )
        return iAddressErr;

      serv_addr.sin_addr = *((struct in_addr *)he.h_addr);

      //cout<<"\t*** not found in hlist"<<endl;
    }

    //cout<<"*** ConnectNB after gethostbyname"<<endl;

    //設成non-blocking
    int rval;
    int flags = fcntl(sockfd, F_GETFL, 0);
    fcntl(sockfd, F_SETFL, flags | O_NONBLOCK);


    //connect to server
    if( ( rval=connect(sockfd,(struct sockaddr *)&serv_addr,sizeof(serv_addr)) ) <0 ){
      //cout<<"*** error when connect"<<endl;
      if( errno!=EINPROGRESS ){
        cout<<"connect : "<<strerror(errno)<<endl;
        return iConnectErr;
      }
    }

    //連線已建立，準備返回
    if( rval==0 ){
      //改回non-blocking
      if( !KeepNB ){
        fcntl(sockfd, F_SETFL, flags);
        return iSuccess;
      }
    }

    //若connect在嚐試連線(EINPROGRESS)，用一個select來等連線建立
    int nfds,error;
    socklen_t optval;
    //fd_set afds,rfds,wfds;
    fd_set wfds;
    nfds=sockfd+1;

    //cout<<"trying connecting, enter to select while loop"<<endl;

    while(1){

     threadHandler->pthread_testcancel();//connie改
	 //
	 // if(threadHandler->isSetThreadCancel())//connie改
		//return iThreadCancel;



      //FD_ZERO(&rfds);
      //FD_SET( sockfd , &rfds );
      FD_ZERO(&wfds);
      FD_SET( sockfd , &wfds );
      //如果要讓此連線一段時間後timeout的話，可以設定struct timeval為非零
      if( (rval = select( nfds , (fd_set*)0 , &wfds , (fd_set *)0 , (struct timeval *)0 ))<0 ){
        //cout<<"select error : "<<errno<<"<br>"<<endl;
        if( errno==EINTR){
          cout<<" select EINTR : "<<strerror(errno)<<endl;
          continue;
        }
        else{
          cout<<"select OTHER : "<<strerror(errno)<<endl;
          return iConnectErr;
        }
      }
      //還沒有ready
      else if( rval == 0 ){
        continue;
      }
      else{
        if( FD_ISSET(sockfd,&wfds) ){
          optval=sizeof( error );
          getsockopt( sockfd , SOL_SOCKET, SO_ERROR , &error, &optval);
          if( error==0 )break;
          else return iConnectErr;
        }
        else continue;
      }

    }

    //cout<<"connectNB success"<<endl;

    if( !KeepNB ){
      fcntl(sockfd, F_SETFL, flags);
    }
    */
    return iSuccess;
}

void HttpDownload::FormatRequestHeader(std::string pServer , std::string pObject , long nFrom , long nTo){
    m_requestheader="";

    m_requestheader+="GET ";
    m_requestheader+=pObject;
//	m_requestheader+=pObject.substr(1,pObject.length());
    m_requestheader+=" HTTP/1.1";
    m_requestheader+="\r\n";

    m_requestheader+="Host:";
	m_requestheader+=pServer;
    m_requestheader+="\r\n";

    m_requestheader+="Accept:*/*";
    m_requestheader+="\r\n";
//Mozilla/5.0 (Linux; U; Android 1.5; en-us; sdk Build/CUPCAKE) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1
   // m_requestheader+="User-Agent:Mozilla/4.0 (compatible; MSIE 5.00; Windows 98)";
    
	m_requestheader+="User-Agent:Mozilla/5.0 (Linux; U; Android 1.5; en-us; sdk Build/CUPCAKE) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1";
	m_requestheader+="\r\n";

    m_requestheader+="Connection:Keep-Alive";
	m_requestheader+="\r\n";

    if(nFrom >= 0L){
        stringstream temp;
        temp.clear();//clear flag
        temp.str("");//clear content
        m_requestheader+="Range: bytes=";
        temp<<nFrom;
        m_requestheader+=temp.str();
        m_requestheader+="-";
        if(nTo > nFrom){
            temp.clear();
            temp.str("");
            temp<<nTo;
            m_requestheader+=temp.str();
        }
        m_requestheader+="\r\n";
    }
    m_requestheader+="\r\n";

	LOGD( m_requestheader.c_str() );

}

bool HttpDownload::SendRequest(){
    if( write( sockfd , m_requestheader.c_str(),m_requestheader.length() )<0 ){
        cerr<<"send error"<<endl;
        return false;
    }
    return true;
}

int HttpDownload::GetServerState(){
    string line;
    stringstream ss;
    int status;

    if( GetResponseLine( line ) <0 ){
        cerr<<"readline error!!"<<endl;
        return -1;
    }

    //cout<<"Get Server State : "<<line;
    ss.str(line);
    ss>>skipws>>line>>status;
    return status;
}

void HttpDownload::ParseURL( URLStruct& UStruct, string URL ){
    string::size_type start=0,end;

    end=URL.find( "://" , start );

    //沒有指定protocal
    if( end==string::npos ){
        UStruct.protocal="http";
        end=0;
    }
    //有指定protocal
    else
        UStruct.protocal=URL.substr( 0 , end );

    //沒有指定protocal，start=end=0
    if( end==0 )
        start=end;
    //有指定protocal，即前面有xxx://，從end+3開始
    else start=end+3;


    end=URL.find("/" , start );
    //後面沒有接object
    if( end==string::npos ){
        UStruct.host=URL.substr( start , URL.length()-start ) ;
        UStruct.object="";
    }
    //後面有接object
    else{
        UStruct.host=URL.substr( start , end-start );
        start=end;
        UStruct.object=URL.substr( start , URL.length()-start );
    }

    start=UStruct.host.find(":",0);
    //有指定port
    if( start!=string::npos ){
        ++start;
        UStruct.port=atoi( UStruct.host.substr(start,UStruct.host.length()-start).c_str() );
        UStruct.host=UStruct.host.substr( 0 , --start );
    }

    //cerr<<UStruct.protocal<<endl<<UStruct.host<<endl<<UStruct.object<<endl;
}

long HttpDownload::GetBlocktoMemory( char *block , std::string URL , long nFrom , long nTo ){
    data_buffer.clear();
    IsEOS=false;

    if( Socket()!=iSuccess ){
        cerr<<"socket error"<<endl;
        return -1;
    }

    URLStruct url;
    ParseURL( url , URL );

    if( url.object=="")
        return -1;

    ConnectErrorType result;
    result=Connect( url.host , 80 );

    if( result==iAddressErr || result==iConnectErr){
        cerr<<"error"<<endl;
        return -1;
    }

    FormatRequestHeader( url.host,url.object,nFrom,nTo);

    if( !SendRequest() ){
        return -1;
    }

    int serv_status=GetServerState();

    if( serv_status<200 && serv_status>400 ){
        cerr<<"server error!! server status : "<<serv_status<<endl;
        return -1;
    }

    //cerr<<"server status : "<<serv_status<<endl;

    string line;
    stringstream ss;
    long nLength=0L;
    unsigned long count=0L;

    if( serv_status>=300 ){
        string location;
        while( GetResponseLine(line)>0){
            if( line=="\r\n" ){
                close( sockfd );
                return GetBlocktoMemory(block,location,nFrom,nTo);
            }
            ss.clear();
            ss.str(line);
            ss>>skipws>>line;
            if( line=="Location:"){
                ss>>skipws>>location;
            }
        }
    }

    while( GetResponseLine( line )>0){
        if( line=="\r\n")break;

        ss.clear();
        ss.str(line);
        ss>>skipws>>line;
        if( line=="Content-Length:")
            ss>>skipws>>nLength;
    }

    //cerr<<nLength<<endl;
    count=nLength;

    if( nLength==0 )
        return -1;

    stringstream temp;
    temp.write( data_buffer.c_str() , data_buffer.length() );

    if( data_buffer.length()==count ){
        temp.read( block , count );
        return data_buffer.length();
    }

    char c[8192];

    int rc;
    while( (rc=read( sockfd , c , 8192 ) )>0 ){
        temp.write( c , rc );
        nLength-=rc;
        if( nLength==0 )break;
    }

    if( nLength!=0 ){
        cerr<<"size error"<<endl;
        return -1;
    }

    temp.read( block , count );
    return count;

    close( sockfd );
    return true;
}

ConnectErrorType HttpDownload::GetBlocktoFile( std::string URL , std::string FileName , long nFrom , long nTo , bool append ){
  return GetBlocktoFile( URL , FileName , nFrom , nTo , append , NULL );
}

ConnectErrorType HttpDownload::GetBlocktoFile( std::string URL , std::string FileName , long nFrom , long nTo , bool append , long *FileRemain){  //connie 修改: return -1 =>iError, return  0 & 1 =>  iSuccess
    data_buffer.clear();
    IsEOS=false;

    if( Socket()!=iSuccess ){
        cerr<<"socket error"<<endl;
        return iError;
    }

    cerr<<"*** GetBlocktoFile : after socket"<<endl;

      threadHandler->pthread_testcancel();//connie改
	  /*
	  if(threadHandler->isSetThreadCancel())//connie改
		return iThreadCancel;
*/
    URLStruct url;
    ParseURL( url , URL );

    if( url.object=="")
        return iError;

    if( FileName=="" ){
        FileName=url.object.substr( url.object.find_last_of( "/",url.object.length() )+1 , url.object.length() );
    }

    ConnectErrorType result;
    //result=Connect( url.host , 80 );
    result=ConnectNB( url.host , 80 , false );
	if(result == iThreadCancel ){
		return iThreadCancel;
	}

    cerr<<"*** GetBlocktoFile : after connect"<<endl;

      threadHandler->pthread_testcancel();

	 /* if(threadHandler->isSetThreadCancel())//connie改
		return iThreadCancel;
*/

    if( result==iAddressErr || result==iConnectErr){
        cerr<<"error"<<endl;
        return iError;
    }

    FormatRequestHeader( url.host,url.object,nFrom,nTo);

    if( !SendRequest() ){
        return iError;
    }

    int serv_status=GetServerState();

    if( serv_status<200 && serv_status>400 ){
        cerr<<"server error!! server status : "<<serv_status<<endl;
        return iError;
    }

    //cerr<<"server status : "<<serv_status<<endl;

    string line;
    stringstream ss;
    long nLength=0L;
    //unsigned long count=0L;

    if( serv_status>=300 ){
        string location;
        while( GetResponseLine(line)>0){
            if( line=="\r\n" ){
                close( sockfd );
                return GetBlocktoFile(location,FileName,nFrom,nTo, append, FileRemain);
            }
            ss.clear();
            ss.str(line);
            ss>>skipws>>line;
            if( line=="Location:"){
                ss>>skipws>>location;
            }
        }
    }

    while( GetResponseLine( line )>0){
        if( line=="\r\n")break;

        ss.clear();
        ss.str(line);
        ss>>skipws>>line;
        if( line=="Content-Length:"){
            ss>>skipws>>nLength;
            if( FileRemain!=NULL )
              *FileRemain=nLength;
        }
    }

    //cerr<<nLength<<endl;
    //count=nLength;

    if( nLength==0 ){
      cout<<"length==0"<<endl;
      return iSuccess;
    }

    ofstream fout;
    if( append ){
      fout.open( FileName.c_str() , ios::out | ios::binary | ios::app );
      //cout<<"getblocktofile,append"<<endl;
    }
    else
      fout.open( FileName.c_str() , ios::out | ios::binary | ios::trunc );

    if( !fout.is_open() ){
        return iError;
    }

    fout.write(data_buffer.data(),data_buffer.size());
    nLength-=data_buffer.size();
    data_buffer.clear();

    if( nLength==0 ){
        fout.close();
        close( sockfd );
        return iSuccess;
    }

    char c[8192];

    int rc;
    while( (rc=read( sockfd , c , 8192 ) )>0 ){
        fout.write( c , rc );
        nLength-=rc;
        if( FileRemain!=NULL )
          *FileRemain=nLength;

       threadHandler->pthread_testcancel();
	/*
	  if(threadHandler->isSetThreadCancel())//connie改
		return iThreadCancel;
*/
        if( nLength==0 )break;
    }

    if( nLength!=0 ){
        cerr<<"size error"<<endl;
        return iError;
    }

    fout.close();

    close( sockfd );
    return iSuccess;
}

ConnectErrorType HttpDownload::GetURLtoFile(std::string URL , std::string FileName , long* FileSize , long* FileRemain){  //connie 修改: return -1 =>iError, return  0 & 1 =>  iSuccess

    data_buffer.clear();
    IsEOS=false;

    /* 建立socket */
    if( Socket()!=iSuccess ){
        cerr<<"socket error"<<endl;
        return iError;
    }

    //cerr<<"*** GetURLtoFile : after Socket"<<endl;

     threadHandler->pthread_testcancel();

	/*connie
		  if(threadHandler->isSetThreadCancel())//connie改
			return iThreadCancel;
	*/

    /* 將url parse出可用的資料 */
    URLStruct url;
    ParseURL( url , URL );

    if( url.object=="")
        return iError;

    if( FileName=="" ){
        FileName=url.object.substr( url.object.find_last_of( "/",url.object.length() )+1 , url.object.length() );
    }

    /* 建立連線 */
    ConnectErrorType result;
    //result=Connect( url.host , 80 );
    result=ConnectNB( url.host , 80 , false );

    if( result==iAddressErr || result==iConnectErr){
        cerr<<"connect error"<<endl;
        return iError;
    }
	if(result == iThreadCancel ){
		return iThreadCancel;
	}

    //cerr<<"*** GetURLtoFile : after Connect"<<endl;

    threadHandler->pthread_testcancel();
	/*
	  if(threadHandler->isSetThreadCancel())//connie改
		return iThreadCancel;
*/

    /* 產生request字串 */
    FormatRequestHeader( url.host,url.object,-1,-1);

    if( !SendRequest() ){
        return iError;
    }

    int serv_status=GetServerState();

    if( serv_status<200 && serv_status>400 ){
        cerr<<"server error!! server status : "<<serv_status<<endl;
        return iError;
    }

    //cerr<<"server status : "<<serv_status<<endl;

    string line;
    stringstream ss;
    long nLength=0L;

    if( serv_status>=300 ){
        string location;
        while( GetResponseLine(line)>0){
            if( line=="\r\n" ){
                close( sockfd );
                return GetURLtoFile(location,"",FileSize,FileRemain);
            }
            ss.clear();
            ss.str(line);
            ss>>skipws>>line;
            if( line=="Location:"){

                ss>>skipws>>location;
            }
        }
    }

    while( GetResponseLine( line )>0){
        if( line=="\r\n")break;

        ss.clear();
        ss.str(line);
        ss>>skipws>>line;
        if( line=="Content-Length:"){
			LOGD("Content-Length: find " );

            ss>>skipws>>nLength;
            if(FileSize!=NULL)
              *FileSize=nLength;
            if( FileRemain!=NULL)
              *FileRemain=nLength;
        }
    }

    //cerr<<nLength<<endl;

    if( nLength==0 )
        return iSuccess;

    ofstream fout;
    fout.open( FileName.c_str() ,ios::out | ios::binary );

    if( !fout.is_open() ){
        return iError;
    }

    fout.write( data_buffer.data(),data_buffer.size() );
    nLength-=data_buffer.size();
    if( FileRemain!=NULL)
      *FileRemain=nLength;
    data_buffer.clear();

    if( nLength==0 ){
        fout.close();
        close( sockfd );
        return iSuccess;
    }

    char c[LINEMAX];

     threadHandler->pthread_testcancel();
/*
	  if(threadHandler->isSetThreadCancel())//connie改
		return iThreadCancel;
*/
    int rc;
    while( (rc=read( sockfd , c , LINEMAX ) )>0 ){
        fout.write( c , rc );
        nLength-=rc;

        if( FileRemain!=NULL)
          *FileRemain=nLength;

        threadHandler->pthread_testcancel();
/*
	  if(threadHandler->isSetThreadCancel())//connie改
		return iThreadCancel;
*/

        if( nLength==0 )break;
    }

    if( nLength!=0 ){
        cerr<<"size error"<<endl;
        return iError;
    }

    fout.close();

    close( sockfd );
    return iSuccess;
}

ConnectErrorType HttpDownload::GetURLtoFile( std::string URL , std::string FileName ){
  return GetURLtoFile( URL , FileName , NULL , NULL );
}

bool HttpDownload::GetURLtoMemory( std::string URL , string& buffer ){
	LOGD(URL.c_str() );
    data_buffer.clear();
    IsEOS=false;
    buffer.clear();

    /* 建立socket */
    if( Socket()!=iSuccess ){
		LOGD("socket error " );
        cerr<<"socket error"<<endl;
        return false;
    }

    /* 將url parse出可用的資料 */
    URLStruct url;
    ParseURL( url , URL );

    if( url.object=="")
        return false;

    /* 建立連線 */
    ConnectErrorType result;
    result=Connect( url.host , 80 );


	LOGD("~~~~~~~~~~~~~~GetURLtoMemory 1 " );
    if( result==iAddressErr || result==iConnectErr){
        cerr<<"error"<<endl;
        return false;
    }

    /* 產生request字串 */
    FormatRequestHeader( url.host,url.object,-1,-1);


	LOGD(url.host.c_str());
	LOGD(url.object.c_str());

	LOGD("~~~~~~~~~~~~~~GetURLtoMemory 2 " );

    if( !SendRequest() ){
        return false;
    }

	LOGD("~~~~~~~~~~~~~~GetURLtoMemory 3 " );
    int serv_status=GetServerState();

    if( serv_status<200 && serv_status>400 ){
        cerr<<"server error!! server status : "<<serv_status<<endl;
        return false;
    }


	LOGD("~~~~~~~~~~~~~~GetURLtoMemory 4 " );
    //cerr<<"server status : "<<serv_status<<endl;

    string line;
    stringstream ss;
    long nLength=0L;

LOGD( IntToStringNew(data_buffer.length(),0).c_str());

    if( serv_status>=300 ){
        string location;
        while( GetResponseLine(line)>0){
            if( line=="\r\n" ){
                close( sockfd );
                return GetURLtoMemory(location,buffer);
            }
            ss.clear();
            ss.str(line);
            ss>>skipws>>line;
            if( line=="Location:"){
                ss>>skipws>>location;
            }
        }
	}
	LOGD( IntToStringNew(data_buffer.length(),0).c_str());
	LOGD("~~~~~~~~~~~~~~GetURLtoMemory 5 " );

	LOGD("serv_status ");
	LOGD(IntToStringNew(serv_status,0 ).c_str());
    while( GetResponseLine( line )>0){

		LOGD("~~~~~~~~~~~~~~GetURLtoMemory 5-0 " );
	

        if( line=="\r\n")break;

        ss.clear();
        ss.str(line);
        ss>>skipws>>line;

		LOGD(line.substr(0,15).c_str() );
		if( line.substr(0,15)=="Content-Length:"){
            ss>>skipws>>nLength;
			LOGD("~~~~~~~~~~~~~~find Content-Length:" );
			LOGD( IntToStringNew((int)nLength,0).c_str());
		}
    }

    //cerr<<nLength<<endl;

	LOGD("~~~~~~~~~~~~~~GetURLtoMemory 6 " );
	if( nLength==0 ){
		LOGD("~~~~~~~~~~~~~~GetURLtoMemory 6-0 " );
		return false;}

	LOGD("~~~~~~~~~~~~~~GetURLtoMemory 6-1 " );

    buffer.append( data_buffer );

	

	LOGD( IntToStringNew((int)nLength,0).c_str());
	LOGD( IntToStringNew(data_buffer.length(),0).c_str());



    nLength-=data_buffer.length();

	LOGD( IntToStringNew((int)nLength,0).c_str());

    data_buffer.clear();

    if( nLength==0 ){
        //fout.close();

		LOGD("~~~~~~~~~~~~~~GetURLtoMemory 6-3 " );
        close( sockfd );
        return true;
    }


	char c[8192];

	LOGD("~~~~~~~~~~~~~~GetURLtoMemory 7 " );
    int rc;
    while( (rc=read( sockfd , c , 8192 ) )>0 ){
        //fout.write( c , rc );
        buffer.append( c , rc );
        nLength-=rc;
        if( nLength==0 )break;
    }

    if( nLength!=0 ){
        cerr<<"size error"<<endl;
        return false;
    }

    //fout.close();

	LOGD("~~~~~~~~~~~~~~GetURLtoMemory 8 " );
    close( sockfd );
    return true;
}

int HttpDownload::GetResponseLine( string& line ){
    int  rc;

	string::size_type eol=0;
	//有換行
	if( (data_buffer.length()!=0) && (eol=data_buffer.find( "\n" , 0 ))!=string::npos ){
        if(eol==data_buffer.length()-1 ){
			LOGD("~~~~~~~~~~~~~~GetResponseLine 1  " );
            /*一行*/
            line=data_buffer;
            data_buffer.clear();
			//LOGD(line.c_str() );
            return line.length();
        }
        else{
			LOGD("~~~~~~~~~~~~~~GetResponseLine 2 here " );
        line=data_buffer.substr( 0 , eol+1 );
	//	LOGD(data_buffer.c_str() );
        data_buffer=data_buffer.substr(eol+1 , data_buffer.length()-eol-1);
		//LOGD(data_buffer.c_str() );
        return line.length();
        }
    }

    //沒有換行 1.讀完：輸出buffer，清空buffer 2.還沒有讀完，接著讀
    if( IsEOS ){
		LOGD("~~~~~~~~~~~~~~GetResponseLine 3  " );
        line=data_buffer;
			//LOGD(line.c_str() );
        data_buffer.clear();
        return line.length();
    }

	char c[LINEMAX];


	memset( c , 0 , LINEMAX );

		

	if ( (rc= read(sockfd, c, LINEMAX-1)) >0){
		
		
		
		LOGD("~~~~~~~~~~~~~~GetResponseLine 4  content" );

/*
		string tempTest = "";
		
		char16_t *tpBuf = new  char16_t[rc/2];

		LOGD("~~~~~~~~~~~~~~GetResponseLine 4-0  content" );
		
		string s1 = "";
		for(int i = 0; i <rc;i++ ){
		
			s1.push_back(c[i]);
			LOGD(s1.c_str() );
		   int tempi;
		   if(i % 2 == 0){
			tempi = ((int)c[i]);	
		

			}
			else{
				tempi += ((int)c[i])*256;
				tpBuf[(i-1)/2] = (char16_t)tempi;
			   }			  
		}
		string s = Char16ToString(tpBuf,rc/2);
        tempTest.append(s);       
		fout << tempTest;
		*/



	    data_buffer.append( c , rc );
		LOGD(data_buffer.c_str() );
			//LOGD(s1.c_str() );
		//	fout << s1;


	    if( rc<LINEMAX-1 )
            IsEOS=true;
    }
    else if (rc<= 0) {
		LOGD("~~~~~~~~~~~~~~GetResponseLine 5  " );
        /* EOF */
        IsEOS=true;
    }
    //else return(-1);       /* error*/

	//delete[] c;
	return GetResponseLine(line);

}

bool DownloadThreadHandler::isSetThreadCancel(){ //connie
	bool temp ;
	pthread_mutex_lock( &mutex );

	temp = IsSetThreadCancel;

	pthread_mutex_unlock( &mutex );

	return  temp;
}
void DownloadThreadHandler::setThreadCancel(bool state){//connie
	pthread_mutex_lock( &mutex );

	IsSetThreadCancel = state;

	pthread_mutex_unlock( &mutex );
}






void DownloadThreadHandler::init(){
	setThreadCancel(false);
}


void DownloadThreadHandler::pthread_testcancel(){//connie

	

	if(isSetThreadCancel() == true){
		setThreadCancel(false);	
		LOGD("pthread_exit" );		
		pthread_exit(NULL);
		LOGD("pthread_exit why??~" );
		
	
	}
	
}
void DownloadThreadHandler::Pthread_cancel(){//connie
	
	setThreadCancel(true);


}
