//---------------------------------------------------------------------------

#ifndef MyEvalH
#define MyEvalH

#include <stdlib.h>
#include <stack>
#include <string>

using std::string;

double MyEval(string FStr,int SlideWidth, int SlideHeight,int ActorLeft, int ActorTop, int ActorWidth, int ActorHeight);
double ConvertPPTAttr(char *FOperand, int SlideWidth, int SlideHeight, int ActorLeft, int ActorTop, int ActorWidth, int ActorHeight);
double GetNumber(char *str,int start_idx,int *rtn_count);
string setCPointValueFormat(string oldV);

bool isOprand(char symb);
bool isOperator(char symb);
int precedence(char op1,char op2);
void infix_postfix(char *infix,char *postfix);

#endif
