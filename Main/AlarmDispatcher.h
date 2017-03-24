#ifndef _ALARM_DISPATCHER_H
#define _ALARM_DISPATCHER_H
//--------------------------------------------------------------------------------------------------------------------------------------
#include <Arduino.h>
#include <WString.h>
#include "TinyVector.h"
#include "Globals.h"
#include "AlertModule.h"
//--------------------------------------------------------------------------------------------------------------------------------------
// классы и интерфейсы для управления тревогами
//--------------------------------------------------------------------------------------------------------------------------------------
typedef Vector<AlertRule*> RaisedAlarmsList;
struct AlarmDispatcherFlags
{
  byte HasAlarms : 1;
  byte pad : 6;
};
//--------------------------------------------------------------------------------------------------------------------------------------
class AlarmDispatcher
{
  private:

#ifdef USE_SMS_MODULE
    RaisedAlarmsList queueSMSAlarms;
    RaisedAlarmsList processedSMSAlarms;
#endif

  public:
    AlarmDispatcher();

    void Alarm(AlertRule* rule);

    #ifdef USE_SMS_MODULE
      // функции, специфичные для GSM-модуля
      bool HasSMSAlarm() {return queueSMSAlarms.size();}
      String GetSMSAlarmData();
      void MarkSMSAlarmDone();
    #endif
};
//--------------------------------------------------------------------------------------------------------------------------------------

#endif
