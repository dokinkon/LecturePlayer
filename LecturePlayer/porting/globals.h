#ifndef __GLOBALS_H___
#define __GLOBALS_H___

//#include <string.h>
//#include <string>
//#include <vector>
//#include <deque>
//#include <map>
//#include <iterator>
//#include <string>
//#include <memory>
//#include <algorithm>
//#include "MyLog.h"

typedef long HRESULT;

#define S_OK 0
#define E_FAIL 1

#ifndef SAFE_DELETE
#define SAFE_DELETE(p)       { if(p) { delete (p);     (p)=NULL; } }
#endif
#ifndef SAFE_DELETE_ARRAY
#define SAFE_DELETE_ARRAY(p) { if(p) { delete[] (p);   (p)=NULL; } }
#endif
#ifndef SAFE_RELEASE
#define SAFE_RELEASE(p)      { if(p) { (p)->Release(); (p)=NULL; } }
#endif


#ifndef GOTO_EXIT_IF_FAILED
#define GOTO_EXIT_IF_FAILED(hr) if(FAILED(hr)) goto Exit;
#endif


#ifndef SAFE_CLOSEHANDLE
    #define SAFE_CLOSEHANDLE( h )       \
        if( NULL != h )                 \
        {                               \
            CloseHandle( h );           \
            h = NULL;                   \
        }
#endif //SAFE_CLOSEHANDLE

#ifndef SAFE_ADDREF
#define SAFE_ADDREF( x )    \
    if ( x )                \
    {                       \
        x->AddRef();        \
    }
#endif

class TDownloadManager;
class TPlayObject;


void LOGD(const char*);

//---------------------------------------------------------------------------
#endif
