//---------------------------------------------------------------------------
//
// 計時器，用來模擬時間
//
//---------------------------------------------------------------------------

#ifndef CTimerH
#define CTimerH

//strange error!
class CTimer
{
public:
    CTimer();
    ~CTimer();

    void  ResetTimer();
    void  UpdateTimer();
    void  EnableTimer(bool Enable);
    bool  IsEnabled();

    unsigned long GetTime();
    void  SetTime(unsigned long Time);

private:

    unsigned long m_SimulationTime;
    unsigned long m_OldTickCount;

    bool  m_Enabled;
};



//---------------------------------------------------------------------------
#endif
