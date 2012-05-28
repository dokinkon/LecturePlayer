//---------------------------------------------------------------------------
#ifndef pptevalH
#define pptevalH

//**********UserDefine*****************
#define MAXS 1
#define MINS 2
//**********Calculate******************
#include "MyEval.h"

//Struct:
//Store Operators
struct InOPs{
        string Op1;
        string Op2;
};
typedef InOPs ops;
//Struct:
//Store the infomation of brackets
struct InBrackets{
        int front_index;
        int back_index;
};
typedef InBrackets brackets;
//Add by han, 2005/10/4
struct ReportResult{
        int index;
        int type;
};
typedef ReportResult opResult;
#define add 1
#define sub 2
#define pro 3
#define div 4
//---------------------------------------------------------------------------
//Class:
//Calculate the formula of ppt
class PPTEVAL
{
private:	// User declarations
    int m_SlideWidth;
    int m_SlideHeight;
    int m_ActorLeft;
    int m_ActorTop;
    int m_ActorWidth;
    int m_ActorHeight;

    //process the function
    double RemoveFucs(string input);
    //process the brackets
    string RemoveBrackets(string input);
    int FindFrontBrackets(string input);
    int FindEndBrackets(string input);
    string FindBrackets(string input);
    //calculate
    ops GetOps(string input);
    double eval_MIN(string op1, string op2);
    double eval_MAX(string op1, string op2);

public:		// User declarations
    //PPTEVAL(CActorAction *);
    PPTEVAL(int SlideWidth, int SlideHeight,int ActorLeft, int ActorTop, int ActorWidth, int ActorHeight);
    //double Read( string );
    double eval( string input);
    string checkopType(string input);
};


//---------------------------------------------------------------------------
#endif
