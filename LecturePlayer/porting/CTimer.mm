//---------------------------------------------------------------------------

#include "globals.h"
//#include <vcl.h>
//#pragma hdrstop

#include "CTimer.h"

#include <sys/times.h>
//FOR tms
//---------------------------------------------------------------------------

//#pragma package(smart_init)

//---------------------------------------------------------------------------

CTimer::CTimer()
{                    
    ResetTimer();
}

//---------------------------------------------------------------------------

CTimer::~CTimer()
{
}

//---------------------------------------------------------------------------

void CTimer::ResetTimer()
{
    m_OldTickCount = 0;
    m_SimulationTime = 0;
    m_Enabled = false;
}

//---------------------------------------------------------------------------

void CTimer::UpdateTimer()
{
    if(m_Enabled == false)
    {
        return;
    }

    //unsigned long CurrentTickCount = ::GetTickCount();
    tms tm;
    unsigned long CurrentTickCount = times(&tm);

    if(CurrentTickCount < m_OldTickCount)
    {
        m_OldTickCount = CurrentTickCount;
        return;
    }

    m_SimulationTime = m_SimulationTime + CurrentTickCount - m_OldTickCount;
    m_OldTickCount = CurrentTickCount;
}

//---------------------------------------------------------------------------

void CTimer::EnableTimer(bool Enable)
{
    if(m_Enabled == true && Enable == true)
    {
        UpdateTimer();
    }
    else if(m_Enabled == true && Enable == false)
    {
        UpdateTimer();
        m_Enabled = false;
    }
    else if(m_Enabled == false && Enable == true)
    {
        //m_OldTickCount = ::GetTickCount();
        tms tm;
        m_OldTickCount = times(&tm);

        m_Enabled = true;
    }
    else
    {
    }
}

bool CTimer::IsEnabled()
{
    return m_Enabled;
}

//---------------------------------------------------------------------------

unsigned long CTimer::GetTime()
{
    return m_SimulationTime/10;
}

//---------------------------------------------------------------------------

void CTimer::SetTime(unsigned long Time)
{
    m_SimulationTime = Time*10;
}

//---------------------------------------------------------------------------


