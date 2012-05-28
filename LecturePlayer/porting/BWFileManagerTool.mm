#include "BWFileManagerTool.h"
#include "BWStringTool.h"

#include <fstream>
#define NO_WIN32_LEAN_AND_MEAN
#ifndef MAX_PATH
#define MAX_PATH 255
#endif

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <dirent.h>
#include <vector>

using std::vector;

namespace BW
{
//---------------------------------------------------------------------------
string BWGetCurrentDirNew()
{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return string([documentsDirectory cStringUsingEncoding:NSUTF8StringEncoding]);
    

    
    //string CurrentDirectory = "/sdcard";
    //CurrentDirectory+="/.bestwise";
    //return CurrentDirectory;
}
//---------------------------------------------------------------------------
bool BWCreateDirectory(string Dir)
{
    if (Dir == "")
        return false;

    int re = mkdir(Dir.c_str(),0777);

    if (re == 0)
        return 1;
    else
        return 0;
}
//---------------------------------------------------------------------------
bool BWSearchFileNew(string SrcDir, vector<string> &FileNames)
{
    //LOGD("BWSearchFileNew");
    if (BWDirectoryExistsNew(SrcDir) == false)
    {
        return false;
    }
    // 先清空資料
    FileNames.clear();

    //string Name = SrcDir + "/" + KeyWord;
    char* Name = (char*)SrcDir.c_str();

    DIR* dir;
    dirent* ptr;
    struct stat stStatBuf;

    chdir(Name);
    dir = opendir(Name);

    while ((ptr=readdir(dir))!=NULL)
    {
        if(stat(ptr->d_name, &stStatBuf)==-1)
        {
            continue;
        }
        if(stStatBuf.st_mode & S_IFREG)
        {
            //printf("  %s\n",ptr->d_name);
            string SrcFileName = SrcDir + "/" + string(ptr->d_name);
            if(BWFileExistsNew(SrcFileName))
            {
                FileNames.push_back(SrcFileName);
            }
        }
        chdir(Name);
    }
    closedir(dir);
    // 將所有檔案的名稱排序
    sort(FileNames.begin(), FileNames.end());
    return true;
}
//---------------------------------------------------------------------------
void splitpath(string FileName,string& dir,string& fname,string& ext)
{
    //LOGD("*************in splitpath ");//sss
    int pos1;
    int pos2;
    int len = FileName.length();
    pos1=FileName.find_last_of('/',len);
    if(pos1==-1)
        pos1=len;
    //cout << "pos1: " << pos1 << endl;
    pos2=FileName.find_first_of('.',pos1+1);
    if(pos2==-1)
        pos2=len;
    //cout << "pos2: " << pos2 << endl;
    dir.assign(FileName,0,pos1);
    fname.assign(FileName,pos1+1,pos2-pos1-1);
    ext.assign(FileName,pos2,len-pos2);
}

//最後沒有包含/
string BWExtractFileDirNew(string FileName)
{
    //LOGD("BWExtractFileDirNew ");//sss
    if(FileName == "")
    {
        return "";
    }

    string dir;      //directory
    string fname;    //filename
    string ext;      //副檔名

    splitpath(FileName,dir,fname,ext);
    return dir;
}
string BWExtractFilePathNew(string FileName)
{
	//LOGD(" BWExtractFilePathNew ");//sss
    if(FileName == "")
    {
        return "";
    }

    string dir;      //directory
    string fname;    //filename
    string ext;      //副檔名

    splitpath(FileName,dir,fname,ext);
    string FileDir = dir+"/";
    return FileDir;
}
string BWExtractFileNameNew(string FileName)
{
    //LOGD(" BWExtractFileNameNew ");//sss
    if(FileName == "")
    {
        return "";
    }

    string dir;      //directory
    string fname;    //filename
    string ext;      //副檔名

    splitpath(FileName,dir,fname,ext);
    string File_Name = fname+ext;
    return File_Name;
}

string BWExtractFileExtNew(string FileName)
{
    //LOGD("*************in BWExtractFileExtNew");//sss
    if(FileName == "")
    {
        return "";
    }

    string dir;      //directory
    string fname;    //filename
    string ext;      //副檔名

    if(FileName.find("/")!=string::npos)
    {
        splitpath(FileName,dir,fname,ext);	
    }
    else 
    {
        ext = FileName;
    }
    return ext;
}
string  BWExtractFileOnly(string FileName)
{
    //LOGD("BWExtractFileOnly");
    if(FileName == "")
    {
        return "";
    }
    string dir;      //directory
    string fname;    //filename
    string ext;      //副檔名

    splitpath(FileName,dir,fname,ext);
    string File_Name = fname;
    return File_Name;
}
//--------------------------------------------------------------------------
void ChangeSlash(string& refname)
{
    unsigned int start = 0;
    while ((start=refname.find("\\",start))!=string::npos)
    {
        refname.replace( start , 1 , "/" );
        start++;
    }
}
string BWChangeFileExtNew(string FileName, string Ext)
{
    //LOGD("BWChangeFileExtNew");//sss
    if(FileName == "")
    {
        return "";
    }

    string dir;      //directory
    string fname;    //filename
    string ext;      //副檔名

    splitpath(FileName,dir,fname,ext);
    string FileExt = dir+fname+ext;
    return FileExt;
}
//---------------------------------------------------------------------------
bool FileExists(string filename)
{  //using access
    //LOGD(" FileExists");//sss
    if (access(filename.c_str(),F_OK)==0)
        return true;
    else
        return false;
}
//--------------------------------------------------------------------
bool BWFileExistsNew(string FileName)
{
	//LOGD(" BWFileExistsNew");//sss
    string sz = BWExtractFileNameNew(FileName);
    if( sz == "" )
      return false;
    bool result =  FileExists(FileName);
    return result;
}

bool BWDirectoryExistsNew(string DirName)
{
    //LOGD(" BWDirectoryExistsNew");//sss
    bool result =  FileExists(DirName);
    return result;
}
void writeXMLTofile( string DestFileName,  unsigned char *buffer, int buffer_size )
{
    FILE *stream = fopen(DestFileName.c_str(), "wb");
    fwrite(buffer, buffer_size, 1, stream);
    fclose(stream);
}

void convertutf_16to8(string xml_path_t, int buffer_size)
{
	string result = "";
	FILE *stream = fopen(xml_path_t.c_str(), "rb");
	int headerSize = 120;
	char16_t *header = new char16_t[headerSize];	
    fread(header, headerSize, 1, stream); 
    string m_header = Char16ToString(header,headerSize/2 );	
	result = "<?xml version= \"1.0\" encoding=\"utf-8\" standalone=\"yes\" ?>\n";

	char16_t *content = new char16_t[buffer_size-120];	
    fread(content,buffer_size-120, 1, stream); 
    string m_content = Char16ToString(content,(buffer_size-120)/2 );
	result += m_content;
	fclose(stream);

	std::ofstream fout(xml_path_t.c_str()); 
	fout << result;
	fout.close();

	SAFE_DELETE_ARRAY(header);
	SAFE_DELETE_ARRAY(content);
}
} // namelist BW


