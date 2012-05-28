#include <iostream>
#include <fstream>
#include "PlayObject.h"
#include "MyXML.h"

using namespace std;

TPlayObject::TPlayObject()
{
    m_SrcBSAFName=new string("");
    m_DirBSAFName=new string("");
    scenexml=new string("");
    scriptxml=new string("");
    audio_playlist.clear();
    video_playlist.clear();
    count_time=0;
    Has_Video = false;
    resource = new CTopicResource();
	scene = new CSceneGraph();
    script = new CScriptSystem();
}

bool TPlayObject::LoadFile()
{
    string path = *m_SrcBSAFName;
    string dir = *m_DirBSAFName;

    if(!resource->WriteBSTToDir(path, dir))
        return false;

    string sceneref = resource->GetPPTXMLRefName();

    *scenexml = dir + "/" + sceneref;
    string scriptref = resource->GetScriptRefName();
    *scriptxml = dir + "/" + scriptref;

    vector<string> SoundRefNames;
    resource->GetSoundRefNames(SoundRefNames);

    for(unsigned int i=0;i<SoundRefNames.size();i++){

        audio_playlist.push_back(dir + "/" + SoundRefNames[i]);
    }

    vector<string> VideoRefNames;
    resource->GetVideoRefNames(VideoRefNames);

    if(VideoRefNames.size()!=0){
        Has_Video = true;
        for(unsigned int i=0;i<VideoRefNames.size();i++){

            video_playlist.push_back(dir + "/" + VideoRefNames[i]);
        }
    }
    else{
        Has_Video = false;
    }

    return true;
}


bool TPlayObject::ParseScene()
{
    xmlDoc* doc = NULL;
    xmlNode* root_element = NULL;
    MyXML m_xml;

    string xml_path = "material";
    string xml_path_t = "/sdcard/temp.xml";
    xml_path+= scenexml->substr( scenexml->find_last_of("/") );

    //先輸出檔案看看
    string s = xmlconvert(resource->m_ImageBuffer[xml_path].buffer,resource->m_ImageBuffer[xml_path].size);
    //ofstream out("/sdcard/scene.xml");
    //out << s << endl;
    doc = xmlReadMemory( s.c_str(),
            s.size() ,
            NULL ,
            NULL ,
            0);

    if (doc == NULL)
        return false;

    //Get the root element node
    root_element = xmlDocGetRootElement(doc);
    xmlNode *xmlPPT = root_element;
    xmlNode* SlidesNodes = m_xml.FindChildNode(xmlPPT,xmlCharStrdup("Slides"));
    //--------------read SceneGraph:get slides data---------------------
    xmlNode* SlideNode = m_xml.FindChildIndex(SlidesNodes,0);    //test only one slide
    string SceneName = string((char*) m_xml.GetAttribute(SlideNode,xmlCharStrdup("Name")));
    string LoadFilePath=*m_DirBSAFName + "/material/";
    scene = new CSceneGraph();
    scene->LoadSceneGraph(SceneName, xmlPPT, LoadFilePath);
    HRESULT msg = scene->LoadSceneGraph(SceneName, xmlPPT, LoadFilePath);
    if(msg==S_OK){
    }
    else
        return false;
    xmlFreeDoc(doc);    //free xml doc
    return true;
}
//---------------------------------------------------------------------
bool TPlayObject::ParseScript()
{
	if(script->LoadFromFile(*scriptxml,resource))
        return true;
    else
        return false;
}
//---------------------------------------------------------------------
TPlayObject::~TPlayObject()
{
    SAFE_DELETE(resource);
    SAFE_DELETE(script);
    SAFE_DELETE(scene);
}

