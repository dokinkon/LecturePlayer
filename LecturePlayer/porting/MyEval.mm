//---------------------------------------------------------------------------

#include "globals.h"
#include "MyEval.h"
//---------------------------------------------------------------------------
#include <vector>

//#pragma package(smart_init)

using namespace std;


double MyEval(string FStr,int SlideWidth, int SlideHeight, int ActorLeft, int ActorTop, int ActorWidth, int ActorHeight){

    double rtn=0;
    char *tmpStr;
    char tmpChar;
    char *tmpV;
    char temp[1024];

    string numericAS;
    string postAS;
    int str_idx=0,i;

    tmpStr = (char *)calloc(FStr.length()+1,sizeof(char));
    //first step set the #ppt_h ,or .xx or to the right format
    if(tmpStr!=NULL && !FStr.empty() ){

        memcpy(tmpStr,FStr.c_str(),FStr.length());
        tmpChar = tmpStr[str_idx] ;

        while(tmpChar!='\0'){

            if(isdigit(tmpChar)){
                //numericAS.cat_sprintf("%g",GetNumber(tmpStr,str_idx,&i)) ;
                sprintf(temp,"%g",GetNumber(tmpStr,str_idx,&i));
                numericAS.append(temp);

                str_idx+=i;
            }
            else{
                if(tmpChar=='#'){
                    tmpV =(char *)calloc(strlen("#ppt_x")+1,sizeof(char));
                    memcpy(tmpV,tmpStr+str_idx,strlen("#ppt_x"));

                    //numericAS.cat_sprintf("%f",ConvertPPTAttr(tmpV,SlideWidth, SlideHeight, ActorLeft, ActorTop, ActorWidth, ActorHeight));
                    sprintf(temp,"%f",ConvertPPTAttr(tmpV,SlideWidth, SlideHeight, ActorLeft, ActorTop, ActorWidth, ActorHeight));
                    numericAS.append(temp);

                    str_idx += strlen(tmpV);
                    free(tmpV);
                }
                else if(tmpChar=='.'){
                    //numericAS.cat_sprintf("%f",GetNumber(tmpStr,str_idx,&i)) ;
                    sprintf(temp,"%f",GetNumber(tmpStr,str_idx,&i));
                    numericAS.append(temp);

                    str_idx+=i;
                }
                else if(tmpChar==' '){
                    str_idx++;
                }
                else{
                    numericAS += tmpChar;
                    str_idx++ ;
                }

            }//end if not digit
            tmpChar = tmpStr[str_idx] ;
        }//end while
        free(tmpStr);
    }

    //second step convert infix to postfix
    char top_operator='\0';
    stack<char,vector<char> > operator_stack;


    tmpStr = (char *)calloc(numericAS.length()+1,sizeof(char));

    if(tmpStr!=NULL && !numericAS.empty() ){

        memcpy(tmpStr,numericAS.c_str(),numericAS.length());
        str_idx=0;
        tmpChar=tmpStr[str_idx];
        while(tmpChar != '\0'){

            if(isdigit(tmpChar)){
                //postAS.cat_sprintf("_%f",GetNumber(tmpStr,str_idx,&i));
                sprintf(temp,"_%f",GetNumber(tmpStr,str_idx,&i));
                postAS.append(temp);

                str_idx+=i;
            }
            else if(tmpChar=='_'){
                str_idx++;
                //postAS.cat_sprintf("_%f",GetNumber(tmpStr,str_idx,&i));
                sprintf(temp,"_%f",GetNumber(tmpStr,str_idx,&i));
                postAS.append(temp);

                str_idx+=i;
            }
            else{
                switch(tmpChar){
                    case ')':
                       while(!operator_stack.empty() && (top_operator=operator_stack.top())
                                 && top_operator!='(' ){
                                postAS+=top_operator;
                                operator_stack.pop();
                            }
                            if(!operator_stack.empty() && top_operator == '(' )
                                operator_stack.pop();

                        break;

                    case '(':
                        operator_stack.push(tmpChar);
                        break;
                    default :
                            while( !operator_stack.empty() && (top_operator=operator_stack.top())
                            && precedence(top_operator,tmpChar)){
                                postAS+=top_operator;
                                operator_stack.pop();
                            }
                        operator_stack.push(tmpChar);
                        break;
                }
                str_idx++;
            }
            tmpChar=tmpStr[str_idx];
        }//end while loop

        while(!operator_stack.empty()){
            postAS+=operator_stack.top();
            operator_stack.pop();
        }
        postAS+='\0';
        free(tmpStr);
    }//end if

    //third step evaluate postfix
    stack<double ,vector<double> > op_stk;
    double op1,op2,op3;
    tmpStr=(char *)calloc(postAS.length()+1,sizeof(char));
    if(tmpStr!=NULL && !postAS.empty() ){
        memcpy(tmpStr,postAS.c_str(),postAS.length());
        str_idx=0;
        tmpChar=tmpStr[str_idx];
        while(tmpChar != '\0'){
            if(tmpChar=='_'){//number
                str_idx++;
                op_stk.push(GetNumber(tmpStr,str_idx,&i));
                str_idx+=i;

            }
            else if(isOperator(tmpChar)){
                op1=op2=0;
                if(!op_stk.empty()){
                    op2=op_stk.top();
                    op_stk.pop();
                }
                if(!op_stk.empty()){
                    op1=op_stk.top();
                    op_stk.pop();
                }
                if(tmpChar=='+'){
                    op3=op1+op2;
                }
                else if(tmpChar=='-'){
                    op3=op1-op2;
                }
                else if(tmpChar=='*'){
                    op3=op1*op2;
                }
                else if(tmpChar=='/'){
                    if(op2) op3=op1/op2;
                    else op3=0;
                }
                op_stk.push(op3);
                str_idx++;

            }
            tmpChar=tmpStr[str_idx];
        }
    }

    rtn=op_stk.top();
    op_stk.pop();
    return rtn;

}



bool isOprand(char symb)
{
        if(symb=='+'||symb=='-'||symb=='*'||symb=='/'||symb=='^'|| symb=='('
||symb==')' )
                return false;
        else
                return true;

}

bool isOperator(char symb)
{
        if(symb=='+'||symb=='-'||symb=='*'||symb=='/'||symb=='^') return true;
        else return false;

}

int precedence(char op1,char op2)
{
    char s[4][3]={"()","+-","*/","^^"};
    int i=0,j,k1,k2,r=1;
    for(i=0;i<4;i++)
        for(j=0;j<2;j++){
            if(op1==s[i][j])k1=i;
            if(op2==s[i][j])k2=i;
    }
    if(k1<k2)r=0;
    return r;
}

void infix_postfix(char *infix,char *postfix)
{

}



//return the #ppt_x,#ppt_y,#ppt_w,#ppt_h 's actual value
//double ConvertPPTAttr(char *FOperand,CActorAction *e){
double ConvertPPTAttr(char *FOperand, int SlideWidth, int SlideHeight, int ActorLeft, int ActorTop, int ActorWidth, int ActorHeight){
    double rtn=0;
    if(FOperand!=NULL && strcmp(FOperand,"#ppt_x")==0){
        rtn = ActorLeft;
    }
    else if(FOperand!=NULL && strcmp(FOperand,"#ppt_y")==0){
        rtn = ActorTop;
    }
    else if(FOperand!=NULL && strcmp(FOperand,"#ppt_w")==0){
        rtn = ( (float)ActorWidth / (float)SlideWidth );
    }
    else if(FOperand!=NULL && strcmp(FOperand,"#ppt_h")==0 ){
        rtn = ( (float)ActorHeight / (float)SlideHeight );
    }
    return rtn;
}

//get the *.*** or .***  -*.* to return , rtn_count: how many char are traversed
double GetNumber(char *str,int start_idx,int *rtn_count){
    double rtn=0;
    int i;
    char tmpC,*tmpV;
    tmpC = str[start_idx];
    if(isdigit(tmpC)){
        i=1;
        tmpC = str[start_idx+i];
        while(tmpC!='\0' && tmpC!='+' && tmpC!='-' && tmpC!='_'
                && tmpC!='*' && tmpC!='/' && tmpC!=' ' && tmpC!=')'
                && tmpC!='(' ){
            i++;
            tmpC = str[start_idx+i];
        }

        tmpV=(char *)calloc(i+1,sizeof(char));

        if(tmpV){
            memcpy(tmpV,str+start_idx,i*sizeof(char));
            rtn=atof(tmpV);
            free(tmpV);
        }

        *rtn_count=i;

    }
    else if(tmpC=='.'){
        i=1;
        tmpC = str[start_idx+i];
        while(isdigit(tmpC) ){
            i++;
            tmpC = str[start_idx+i];
        }
        tmpV=(char *)calloc(i+2,sizeof(char));
        if(tmpV){
            tmpV[0]='0';
            memcpy(tmpV+1,str+start_idx,i*sizeof(char));

            rtn = atof(tmpV);
            free(tmpV);
         }

         *rtn_count=i;

    }
    else if(tmpC=='-'){
        i=1;
        tmpC = str[start_idx+i];
        while(tmpC!='\0' && tmpC!='+' && tmpC!='-' && tmpC!='_'
                && tmpC!='*' && tmpC!='/' && tmpC!=' ' && tmpC!=')'
                && tmpC!='('){
            i++;
            tmpC = str[start_idx+i];
        }
        tmpV=(char *)calloc(i+1,sizeof(char));
        if(tmpV){
            memcpy(tmpV,str+start_idx,i*sizeof(char));

            rtn = atof(tmpV);
            free(tmpV);
         }

         *rtn_count=i;
    }
    return rtn;

}

string setCPointValueFormat(string oldV){
//add by kevin : set CPoint::value format start with #ppt_?
      char temp[1024];
      int str_idx=0,str_idx2=0;
      string tmpAS,tmpAS1=oldV;
      while(str_idx <= (int)oldV.length() ){
        if( (str_idx2=(tmpAS1.find("ppt_",0)+1))!=0 ){
            if(str_idx2 >1){
                if(tmpAS1[str_idx2-1]!='#'){
                    //tmpAS.cat_sprintf("%s#%s",tmpAS1.SubString(1,str_idx2-1),tmpAS1.SubString(str_idx2,strlen("ppt_")+1) );
                    sprintf(temp,"%s#%s",(tmpAS1.substr(1,str_idx2-1)).c_str(),(tmpAS1.substr(str_idx2,strlen("ppt_")+1)).c_str());
                    tmpAS.append(temp);

                    tmpAS1=tmpAS1.substr(str_idx2+strlen("ppt_")+1,tmpAS1.length()-(str_idx2+strlen("ppt_")+1)+1 );
                    str_idx += (str_idx2+strlen("ppt_")+1);
                }
                else{
                    //tmpAS.cat_sprintf("%s",tmpAS1.SubString(1,str_idx2+strlen("ppt_")) );
                    sprintf(temp,"%s",(tmpAS1.substr(1,str_idx2+strlen("ppt_"))).c_str() );
                    tmpAS.append(temp);

                    tmpAS1=tmpAS1.substr(str_idx2+strlen("ppt_")+1,tmpAS1.length()-(str_idx2+strlen("ppt_")+1)+1);
                    str_idx += (str_idx2+strlen("ppt_")+1);
                }
            }
            else{
                //tmpAS.cat_sprintf("#%s",tmpAS1.SubString(str_idx2,strlen("ppt_")+1) );
                sprintf(temp,"#%s",(tmpAS1.substr(str_idx2,strlen("ppt_")+1)).c_str());
                tmpAS.append(temp);

                tmpAS1=tmpAS1.substr(str_idx2+strlen("ppt_")+1 ,tmpAS1.length() -(str_idx2+strlen("ppt_")+1)+1);
                str_idx += (str_idx2+strlen("ppt_")+1);
            }
        }
        else{
            //tmpAS.cat_sprintf("%s",tmpAS1.SubString(1,tmpAS1.Length())) ;
            sprintf(temp,"%s",(tmpAS1.substr(1,tmpAS1.length())).c_str());
            tmpAS.append(temp);

            str_idx+= oldV.length()-str_idx +1;
        }

      }
      return tmpAS;
      //end add by kevin

}
