#ifndef _PlayeObjectH_
#define _PlayeObjectH_

#include "ResourceFile2.h"
#include "globals.h"


#include "BWStringTool.h"
#include "BWFileManagerTool.h"
#include "CScriptSystem.h"
#include "CSceneGraph.h"


#include <vector>

using namespace std;


class TPlayObject
{
public:
    TPlayObject();
    ~TPlayObject();

    string *m_SrcBSAFName;
    string *m_DirBSAFName;
    string *scenexml;
    string *scriptxml;
    vector<string> audio_playlist;
    vector<string> video_playlist;
    bool Has_Video;
    int count_time;

    CTopicResource *resource;
    CScriptSystem *script;
    CScriptAction action;

    CSceneGraph *scene;

    bool LoadFile();
    bool ParseScene();
    bool ParseScript();
};

#endif
