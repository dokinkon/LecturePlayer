#include "ppteval.h"
#include "globals.h"


PPTEVAL::PPTEVAL(int SlideWidth, int SlideHeight, int ActorLeft, int ActorTop, int ActorWidth, int ActorHeight)
{
    m_SlideWidth = SlideWidth;
    m_SlideHeight = SlideHeight;
    m_ActorLeft = ActorLeft;
    m_ActorTop = ActorTop;
    m_ActorWidth = ActorWidth;
    m_ActorHeight = ActorHeight;
}

//2005/09/13, add by han
//說明：代換運算式中，非數值的部份
double PPTEVAL::eval(string input){

    char temp[1024];
    double result = -1;
    int fuc_name_index1 = -1, fuc_name_index2 = -1, fuc_name_index=-1;

    //清除函式
    string processingStr = input;

    fuc_name_index1 = input.find("max",0)+1;
    fuc_name_index2 = input.find("min",0)+1;

    if( fuc_name_index1 != 0 || fuc_name_index2 != 0 ){
        if( fuc_name_index1 < fuc_name_index2 ){
                fuc_name_index = fuc_name_index1;
        }else{
                fuc_name_index = fuc_name_index2;
        }
    }else if( fuc_name_index1 == 0 && fuc_name_index2 == 0 ){
        fuc_name_index = 0;
    }

    while(fuc_name_index!=0){

        if(fuc_name_index!=0){
                //切割
                string frontS = input.substr(1, fuc_name_index-1);
                //int tmp_front_index = processingStr.find("(",0)+1;

                processingStr = input.substr(fuc_name_index, input.length()-fuc_name_index+1);
                //ShowMessage("input");
                //ShowMessage(processingStr);
                string tmp_test = FindBrackets(processingStr);
                //ShowMessage("FindBrackets");
                //ShowMessage(tmp_test);
                string replaceStr = input.substr(input.find(tmp_test,0)-2,3+tmp_test.length());
                //ShowMessage("replaceStr");
                //ShowMessage(replaceStr);
                double report = RemoveFucs(replaceStr);
                //ShowMessage("Report");
                //ShowMessage(report);
                int tmp_f_index = input.find(replaceStr,0)+1;
                int tmp_l_index = tmp_f_index + replaceStr.length();
                string tmp_f_Str = input.substr(1, tmp_f_index-1);
                string tmp_l_Str = input.substr(tmp_l_index, input.length()-tmp_l_index+1);
                if(report>=0){
                        sprintf(temp,"%f",report);
                        input = tmp_f_Str + string(temp) + tmp_l_Str;
                }else{
                        sprintf(temp,"%f",report);
                        input = tmp_f_Str +"_"+ string(temp) + tmp_l_Str;
                }
        }
        fuc_name_index1 = input.find("max",0)+1;
        fuc_name_index2 = input.find("min",0)+1;

        if( fuc_name_index1 != 0 || fuc_name_index2 != 0 ){
                if( fuc_name_index1<fuc_name_index2 ){
                        fuc_name_index = fuc_name_index1;
                }else{
                        fuc_name_index = fuc_name_index2;
                }
        }else if( fuc_name_index1 == 0 && fuc_name_index2 == 0 ){
                fuc_name_index = 0;
        }
    }

    //清除括號
    string result_RemoveBrackets = RemoveBrackets(input);

    //計算數值
    //CActorAction *test = new CActorAction();
    /*try{
          ShowMessage("No Exception");
          result = result_RemoveBrackets.ToDouble();
    }catch(...){*/
          //ShowMessage("Exception");
          //ShowMessage(result_RemoveBrackets);
          //result = MyEval(result_RemoveBrackets,CAA);
          result = MyEval(result_RemoveBrackets,m_SlideWidth,m_SlideHeight,m_ActorLeft,m_ActorTop,m_ActorWidth,m_ActorHeight);

    //}
    //ShowMessage("Final Output");
    //ShowMessage(result);

    return result;
}
//---------------------------------------------------------------------------
//2005/09/14, add by han
//說明：
string PPTEVAL::FindBrackets(string input){

        brackets result;
        int front_index = input.find("(",0)+1;
        int front_count = 0;
        int end_index = 0;
        int tmp_front_index = -1;
        string tmp_input = input;

        while(tmp_front_index!=0){
                int test_index = tmp_input.find("(",0)+1;
                end_index = end_index + test_index;
                if( test_index != 0 ){
                        tmp_front_index = test_index;
                        tmp_input = tmp_input.substr(tmp_front_index+1, tmp_input.length()-tmp_front_index+1);
                        test_index = tmp_input.find("(",0)+1;
                        front_count++;
                }else{
                        tmp_front_index = 0;
                }
        }
        for(int back_count = 0; back_count<front_count; back_count++){
                        tmp_front_index = tmp_input.find(")",0)+1;
                        end_index = end_index + tmp_input.find(")",0)+1;
                        tmp_input = tmp_input.substr(tmp_front_index+1, tmp_input.length()-tmp_front_index+1);
        }

        result.front_index = front_index;
        result.back_index = end_index-front_index+1;

        return input.substr(result.front_index, result.back_index);
}
//---------------------------------------------------------------------------
//2005/09/13, add by han
//說明：代換運算式中，函式的部份(遞迴)
double PPTEVAL::RemoveFucs(string input){
   double result = -1;
   int fuc_name_index = -1, fuc_name_index1, fuc_name_index2;
   int fuc_type = -1;
   //int first_op_index = -1;
   //int second_op_index = -1;
   //int op_end = -1;
   //double tmp_result = -1;
   string Op1, Op2;

   //判斷所屬函式類型
   if((input.find("max",0)+1)!=0){
       fuc_name_index1 = input.find("max",0)+1;
   }
   if((input.find("min",0)+1)!=0){
       fuc_name_index2 = input.find("min",0)+1;
   }
   if( fuc_name_index1 != -1 || fuc_name_index2 != -1){
        if( fuc_name_index1<fuc_name_index2 ){
                fuc_name_index = fuc_name_index1;
                fuc_type = MAXS;
        }else{
                fuc_name_index = fuc_name_index2;
                fuc_type = MINS;
        }
   }else  if( fuc_name_index1 == -1 || fuc_name_index2 == -1 ){
        fuc_name_index = 0;
   }

   string processString ;
   processString = input.substr(fuc_name_index+3, input.length()-fuc_name_index+1);

   //取op1及op2
   ops Op_result = GetOps(processString);

   switch(fuc_type){
        case MINS:
                result = eval_MIN(Op_result.Op1, Op_result.Op2);
                break;

        case MAXS:
                result = eval_MAX(Op_result.Op1, Op_result.Op2);
                break;
   }

   return result;
}
//---------------------------------------------------------------------------
//2005/09/13, add by han
//說明：
ops PPTEVAL::GetOps(string input){
        ops result;
        char temp[1024];
        if((input.find("(",0)+1)==1){
                input = input.substr(2, input.length()-2);
        }
        //int middle_index = -1;
        //int state = 0;
        int fun_index = -1;

        if((input.find("min",0)+1)!=0){
                fun_index = MINS;
        }else if((input.find("max",0)+1)!=0){
                fun_index = MAXS;
        }
        //有函式
        if(fun_index != -1){
                string test = FindBrackets(input);
                string test_Str = input.substr(input.find(test,0)-2, 3+test.length());
                double test_Func = RemoveFucs(test_Str);
                string tmp_S1 = input.substr(input.find(test_Str,0)+1, test_Str.length());
                string tmp_S2 = input.substr(input.find(tmp_S1,0)+1+tmp_S1.length(), input.length()-input.find(tmp_S1,0)+1+tmp_S1.length());
                sprintf(temp,"%f",test_Func);
                input =  string(temp) + tmp_S2;
        }
        //取出op
        string Op1 = input.substr(1, input.find(",",0));
        string Op2 = input.substr(input.find(Op1,0)+1+Op1.length()+1, input.length()-Op1.length()+1);
        //計算數值
        //CActorAction *test = new CActorAction();
        double test1 = -1;
        double test2 = -1;
       //connie try{
              test1 = atof(Op1.c_str());
       /* }catch(...){
              test1 = MyEval(Op1,m_SlideWidth,m_SlideHeight,m_ActorLeft,m_ActorTop,m_ActorWidth,m_ActorHeight);
        }*/

       // connie try{
              test2 = atof(Op2.c_str());
        /*}catch(...){
              test2 = MyEval(Op2,m_SlideWidth,m_SlideHeight,m_ActorLeft,m_ActorTop,m_ActorWidth,m_ActorHeight);
        }*/

        //result.Op1 = test1;
        //result.Op2 = test2;
        sprintf(temp,"%f",test1);
        result.Op1=string(temp);
        sprintf(temp,"%f",test2);
        result.Op2=string(temp);

        return result;
}
//---------------------------------------------------------------------------
//2005/09/13, add by han
//說明：
double PPTEVAL::eval_MIN(string op1, string op2){
        //double result = -1;
        double Op1 = -1;
        double Op2 = -1;

//connie        try{
                Op1 = atof(op1.c_str());
        /*}catch(...){
                //CActorAction *test = new CActorAction();
                MyEval(op1,m_SlideWidth,m_SlideHeight,m_ActorLeft,m_ActorTop,m_ActorWidth,m_ActorHeight);
        }*/

       //connie try{
                Op2 = atof(op2.c_str());
        /*}catch(...){
                //CActorAction *test = new CActorAction();
                MyEval(op2,m_SlideWidth,m_SlideHeight,m_ActorLeft,m_ActorTop,m_ActorWidth,m_ActorHeight);
        }*/
        if(Op1!=Op2!=-1){
                if(Op1<=Op2){
                        return Op1;
                }else{
                        return Op2;
                }
        }
}
//---------------------------------------------------------------------------
//2005/09/13, add by han
//說明：
double PPTEVAL::eval_MAX(string op1, string op2){
       // double result = -1;
        double Op1 = -1;
        double Op2 = -1;

      //connie  try{
                Op1 = atof(op1.c_str());
     /*   }catch(...){
                //CActorAction *test = new CActorAction();
                MyEval(op1,m_SlideWidth,m_SlideHeight,m_ActorLeft,m_ActorTop,m_ActorWidth,m_ActorHeight);
        }*/

        //connie try{
                Op2 = atof(op2.c_str());
        /*}catch(...){
                //CActorAction *test = new CActorAction();
                MyEval(op2,m_SlideWidth,m_SlideHeight,m_ActorLeft,m_ActorTop,m_ActorWidth,m_ActorHeight);
        }*/

        if(Op1!=Op2!=-1){
                if(Op1>Op2){
                        return Op1;
                }else{
                        return Op2;
                }
        }

}
//---------------------------------------------------------------------------
//2005/09/13, add by han
//說明：代換運算式中，括號的部份(遞迴)
string PPTEVAL::RemoveBrackets(string input){
   string result, tmp_S1="", tmp_S2="";
    char temp[1024];

    //char test_A = input[input.length()-1];
    //test_A = input[input.length()];

   if((input.find("(",0)+1)!=0){

        string processString = FindBrackets(input);
        tmp_S1 = ""+input.substr(1,input.find(processString,0));
        tmp_S2 = ""+input.substr(input.find(processString,0)+1+processString.length(), input.length()-input.find(processString,0)+1+processString.length()+1);
        string tmp_R = RemoveBrackets(processString.substr(2,processString.length()-2));

        if( (processString.find("(",0)+1)!=0 ){
                result = tmp_S1 + tmp_R + tmp_S2;
        }else{
        }       result = tmp_S1 + tmp_R + tmp_S2;
   }else{
        //計算
        //CActorAction *test = new CActorAction();
        //connie try
       // {
              /*
              // Darcy修改
              if(input == "#ppt_w")
              {
                result = 1;
              }
              else if(input == "#ppt_h")
              {
                result = 1;
              }
              else
              {
                result = string(input.ToDouble());
              }
              */

              float value = atof(input.c_str());
              sprintf(temp,"%f",value);
              result = string(temp);
      /*  }
        catch(...)
        {
              //unsigned int tmpI=input.length();
              double tmpResult = MyEval(input,m_SlideWidth,m_SlideHeight,m_ActorLeft,m_ActorTop,m_ActorWidth,m_ActorHeight);

              sprintf(temp,"%f",tmpResult);
              if(tmpResult>=0){
                result = string(temp);
              }else{
                result = "_"+string(temp);
              }
        }*/
   }

   return result;
}
string PPTEVAL::checkopType(string input){

   opResult Result[4], ResultE;
   string newInput = "", tmpInput = "";

   int index = -1;

   if((input.find("+",0)+1)!=0){
        index = input.find("+",0)+1;
        Result[0].index = index;
        Result[0].type = add;
   }else{
        Result[0].index = 9999;
        Result[0].type = add;
   }
   if((input.find("-",0)+1)!=0){
        index = input.find("-",0)+1;
        Result[1].index = index;
        Result[1].type = sub;
   }else{
        Result[1].index = 9999;
        Result[1].type = sub;
   }
   if((input.find("*",0)+1)!=0){
        index = input.find("*",0)+1;
        Result[2].index = index;
        Result[2].type = pro;
   }else{
        Result[2].index = 9999;
        Result[2].type = pro;
   }
   if((input.find("/",0)+1)!=0){
        index = input.find("/",0)+1;
        Result[3].index = index;
        Result[3].type = div;
   }else{
        Result[3].index = 9999;
        Result[3].type = div;
   }

   int tempIndex = 9999;
   for(int i = 0; i<4; i++){
        if( Result[i].index <= tempIndex ){
                ResultE = Result[i];
                tempIndex = Result[i].index;
        }
   }

   index = ResultE.index;
   newInput = input;

   while(index!=0){
        string tmpS = newInput.substr(index+1, 1);
        if( tmpS == "-" ){
                string s1 = newInput.substr(1, index);
                string s2 = newInput.substr(index+1, newInput.length()-index+1);
                tmpInput = tmpInput+s1+"_";
                newInput = s2;
        }else{
                string s1 = newInput.substr(1, index);
                string s2 = newInput.substr(index+1, newInput.length()-index+1);
                tmpInput = tmpInput+s1;
                newInput = s2;
        }
        if((newInput.find("+",0)+1)!=0){
                index = newInput.find("+",0)+1;
                Result[0].index = index;
                Result[0].type = add;
        }else{
                Result[0].index = 9999;
                Result[0].type = add;
        }
        if((newInput.find("-",0)+1)!=0){
                index = newInput.find("-",0)+1;
                Result[1].index = index;
                Result[1].type = sub;
        }else{
                Result[1].index = 9999;
                Result[1].type = sub;
        }
        if((newInput.find("*",0)+1)!=0){
                index = newInput.find("*",0)+1;
                Result[2].index = index;
                Result[2].type = pro;
        }else{
                Result[2].index = 9999;
                Result[2].type = pro;
        }
        if((newInput.find("/",0)+1)!=0){
                index = newInput.find("/",0)+1;
                Result[3].index = index;
                  Result[3].type = div;
        }else{
                Result[3].index = 9999;
                Result[3].type = div;
        }
        tempIndex = 9999;
        for(int i = 0; i<4; i++){
                if( Result[i].index <= tempIndex ){
                        ResultE = Result[i];
                        tempIndex = ResultE.index;
                }
        }
        if( tmpInput.length()<=input.length() && index!=9999){
                index = ResultE.index;
        }else{
                index = 0;
        }
   }

   return tmpInput;
}

