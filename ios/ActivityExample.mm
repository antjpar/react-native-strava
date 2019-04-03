////////////////////////////////////////////////////////////////////////////////
// The following FIT Protocol software provided may be used with FIT protocol
// devices only and remains the copyrighted property of Garmin Canada Inc.
// The software is being provided on an "as-is" basis and as an accommodation,
// and therefore all warranties, representations, or guarantees of any kind
// (whether express, implied or statutory) including, without limitation,
// warranties of merchantability, non-infringement, or fitness for a particular
// purpose, are specifically disclaimed.
//
// Copyright 2016 Garmin Canada Inc.
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import "ActivityExample.h"

#include <list>
#include "fit_file_id_mesg.hpp"
#include "fit_file_id_mesg_listener.hpp"
#include "fit_record_mesg_listener.hpp"
#include "fit_mesg_broadcaster.hpp"
#include "fit_date_time.hpp"
#include "fit_event_mesg.hpp"
#include "fit_record_mesg.hpp"
#include "fit_lap_mesg.hpp"
#include "fit_session_mesg.hpp"
#include "fit_activity_mesg.hpp"

class ActivityListener : fit::FileIdMesgListener, fit::MesgListener
{
public:
    void OnMesg(fit::FileIdMesg& mesg)
    {
        NSLog(@"Type: %d", mesg.GetType());
        NSLog(@"Manufacturer: %d", mesg.GetManufacturer());
        NSLog(@"Product: %d", mesg.GetProduct());
        NSLog(@"SerialNumber: %d", mesg.GetSerialNumber());
    }

    void PrintValues(const fit::FieldBase& field)
    {
        for (FIT_UINT8 j=0; j< (FIT_UINT8)field.GetNumValues(); j++)
        {
            switch (field.GetType())
            {
                // Get float 64 values for numeric types to receive values that have
                // their scale and offset properly applied.
                case FIT_BASE_TYPE_ENUM:
                case FIT_BASE_TYPE_BYTE:
                case FIT_BASE_TYPE_SINT8:
                case FIT_BASE_TYPE_UINT8:
                case FIT_BASE_TYPE_SINT16:
                case FIT_BASE_TYPE_UINT16:
                case FIT_BASE_TYPE_SINT32:
                case FIT_BASE_TYPE_UINT32:
                case FIT_BASE_TYPE_SINT64:
                case FIT_BASE_TYPE_UINT64:
                case FIT_BASE_TYPE_UINT8Z:
                case FIT_BASE_TYPE_UINT16Z:
                case FIT_BASE_TYPE_UINT32Z:
                case FIT_BASE_TYPE_UINT64Z:
                case FIT_BASE_TYPE_FLOAT32:
                case FIT_BASE_TYPE_FLOAT64:
                    NSLog(@"%f", field.GetFLOAT64Value(j));
                    break;
                case FIT_BASE_TYPE_STRING:
                    NSLog(@"%@", [Example stringForWString:field.GetSTRINGValue(j)]);
                    break;
                default:
                    break;
            }
        }
    }

    void OnMesg(fit::Mesg& mesg)
    {
        NSLog(@"New Mesg: %s. It has %d field(s) and %d developer field(s).", mesg.GetName().c_str(), mesg.GetNumFields(), mesg.GetNumDevFields());

        for (FIT_UINT16 i = 0; i < (FIT_UINT16)mesg.GetNumFields(); i++)
        {
            fit::Field* field = mesg.GetFieldByIndex(i);
            NSLog(@"   Field %d (%s) has %d value(s)", i, field->GetName().c_str(), field->GetNumValues());
            PrintValues(*field);
        }

        for (auto devField : mesg.GetDeveloperFields())
        {
            NSLog(@"Developer Field(%s) has %d value(s)", devField.GetName().c_str(), devField.GetNumValues());
            PrintValues(devField);
        }
    }
};

@interface ActivityExample ()

@end

@implementation ActivityExample

- (id)init
{
    self = [super init];
    if(self)
    {
        NSString *uuid = [[NSUUID UUID] UUIDString];
        super.fileName = [uuid stringByAppendingString:@".fit"];
    }
    return self;
}

- (FIT_UINT8)encode: (NSDictionary *) session
{
  NSArray* records = [session objectForKey:@"records"];

  FILE *file;
    super.fe = [[FitEncode alloc] initWithVersion:fit::ProtocolVersion::V10];

    if( ( file = [self openFileWithParams:[super writeOnlyParam]] ) == NULL)
    {
        NSLog(@"Error opening file %@", super.fileName);
        return -1;
    }
    [super.fe Open:file];
  
    fit::DateTime timestamp([session[@"date"] longValue] - 631065600L);
    fit::DateTime startTime([session[@"date"] longValue] - 631065600L - [session[@"usetime"] longValue]);
  
    fit::FileIdMesg fileId; // Every FIT file requires a File ID message
    fileId.SetType(FIT_FILE_ACTIVITY);
    fileId.SetManufacturer(FIT_MANUFACTURER_GARMIN);
    fileId.SetProduct(9001);
    fileId.SetSerialNumber(1701L);
    fileId.SetTimeCreated(timestamp.GetTimeStamp());
  
    [super.fe WriteMesg:fileId];
  
    fit::EventMesg eventMesgStart;
    eventMesgStart.SetTimestamp(startTime.GetTimeStamp());
    eventMesgStart.SetEventType(FIT_EVENT_TYPE_START);
    [super.fe WriteMesg:eventMesgStart];

    fit::RecordMesg startRecord;
    startRecord.SetActivityType(FIT_ACTIVITY_TYPE_RUNNING);
    startRecord.SetTimestamp(startTime.GetTimeStamp());
    startRecord.SetHeartRate(0);
    startRecord.SetDistance(0.f);
    startRecord.SetSpeed(0.f);
    startRecord.SetCalories(0.f);
    startRecord.SetTime128([session[@"usetime"] floatValue]);
    [super.fe WriteMesg:startRecord];
  
    if (records != NULL) {
      for (int i = 0; i < [records count]; i ++) {
        NSDictionary* record = records[i];
        fit::DateTime timestamp = fit::DateTime(startTime);
        timestamp.add([record[@"usetime"] doubleValue]);
        
        fit::RecordMesg recordMsg;
        recordMsg.SetActivityType(FIT_ACTIVITY_TYPE_RUNNING);
        recordMsg.SetTimestamp(timestamp.GetTimeStamp());
        recordMsg.SetHeartRate([record[@"pulse"] unsignedCharValue]);
        recordMsg.SetDistance([record[@"distance"] floatValue]);
        recordMsg.SetSpeed([record[@"speed"] floatValue]);
        recordMsg.SetCalories([record[@"calories"] unsignedShortValue]);
        recordMsg.SetTime128([record[@"usetime"] floatValue]);
        [super.fe WriteMesg:recordMsg];
      }
    }
  

    fit::RecordMesg newRecord;
    newRecord.SetActivityType(FIT_ACTIVITY_TYPE_RUNNING);
    newRecord.SetTimestamp(startTime.GetTimeStamp());
    newRecord.SetHeartRate([session[@"pulse"] unsignedCharValue]);
    newRecord.SetDistance([session[@"distance"] floatValue]);
    newRecord.SetSpeed([session[@"speed"] floatValue]);
    newRecord.SetCalories([session[@"calories"] unsignedShortValue]);
    newRecord.SetTime128([session[@"usetime"] floatValue]);
    [super.fe WriteMesg:newRecord];

    fit::EventMesg eventMesgStop;
    eventMesgStop.SetTimestamp(timestamp.GetTimeStamp());
    eventMesgStop.SetEventType(FIT_EVENT_TYPE_STOP);
    [super.fe WriteMesg:eventMesgStop];

    fit::LapMesg lapMsg;
    lapMsg.SetTimestamp(timestamp.GetTimeStamp());
    lapMsg.SetTotalElapsedTime([session[@"usetime"] floatValue]);
    lapMsg.SetTotalTimerTime([session[@"usetime"] floatValue]);
    lapMsg.SetTotalDistance([session[@"distance"] floatValue]);
    [super.fe WriteMesg:lapMsg];

    fit::EventMesg eventMesgStopAll;
    eventMesgStopAll.SetTimestamp(timestamp.GetTimeStamp());
    eventMesgStopAll.SetEventType(FIT_EVENT_TYPE_STOP_DISABLE_ALL);
    [super.fe WriteMesg:eventMesgStopAll];

    fit::SessionMesg sessionMsg;
    sessionMsg.SetSport(FIT_SPORT_RUNNING);
    sessionMsg.SetStartTime(startTime.GetTimeStamp());
    sessionMsg.SetTotalElapsedTime([session[@"usetime"] floatValue]);
    sessionMsg.SetTotalTimerTime([session[@"usetime"] floatValue]);
    sessionMsg.SetTotalDistance([session[@"distance"] floatValue]);
    sessionMsg.SetTotalAscent(0);
    sessionMsg.SetTimestamp(timestamp.GetTimeStamp());
    [super.fe WriteMesg:sessionMsg];

    fit::ActivityMesg aMsg;
    aMsg.SetNumSessions(1);
    aMsg.SetTotalTimerTime([session[@"usetime"] floatValue]);
    aMsg.SetTimestamp(timestamp.GetTimeStamp());
    [super.fe WriteMesg:aMsg];

    if (![super.fe Close])
    {
        NSLog(@"Error closing file %@", super.fileName);
        return -1;
    }
    fclose(file);
    file = NULL;

    return 0;
}

- (FIT_UINT8)decode
{
    @try {
        FILE *file;
        super.fd = [[FitDecode alloc] init];
        if( ( file = [super openFileWithParams:[super readOnlyParam]] ) == NULL)
        {
            NSLog(@"Error opening file %@", super.fileName);
            return -1;
        }

        ActivityListener listener;
        fit::MesgBroadcaster mesgBroadcaster = fit::MesgBroadcaster();
        mesgBroadcaster.AddListener((fit::FileIdMesgListener &)listener);
        mesgBroadcaster.AddListener((fit::MesgListener &)listener);
        [super.fd IsFit:file];
        [super.fd CheckIntegrity:file];
        [super.fd Read:file withListener:&mesgBroadcaster andDefListener:NULL];
        fclose(file);
        file = NULL;
    }
    @catch (NSException *exception) {
        NSLog(@"%@", [exception reason]);
    }
    @finally {
        return -1;
    }
    return 0;
}

@end
