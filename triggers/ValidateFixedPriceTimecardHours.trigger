/*
    Purpose:
        This trigger validates that, for Fixed Fee projects only, the actual hours on the assignment plus the total 
        hours of all unapproved timecards submitted against the the assignment must not be greater than the Budgeted 
        Hours on the assignment.
            
    Initiative: IconATG PSA Implementation
    Author:     William Rich
    Company:    IconATG
    Contact:    william.rich@iconatg.com
    Created:    7/10/2015
*/

trigger ValidateFixedPriceTimecardHours on pse__Timecard_Header__c (before insert, before update) {
    Set<Id> assignmentIds = new Set<Id>();
    for (pse__Timecard_Header__c timecard : Trigger.new) {
        if (timecard.pse__Assignment__c != null) {
            assignmentIds.add(timecard.pse__Assignment__c);
        }
    }

    if (!assignmentIds.isEmpty()) {
        Map<Id, pse__Assignment__c> assignments = new Map<Id, pse__Assignment__c>([
            select
                Id,
                Actual_Hours_Assignment__c,
                Budgeted_Hours_Assignment__c,
                pse__Project__c
            from pse__Assignment__c
            where 
                Id in :assignmentIds and
                pse__Project__r.pse__Billing_Type__c != null and
                pse__Project__r.pse__Billing_Type__c = 'Fixed Price' and
                pse__Project__r.Val_Act_Hours_Do_Not_Exceed_Budg_Hours__c = True
        ]);

        List<AggregateResult> aggResults = null;
        if (Trigger.isInsert) {
            aggResults = [
                select 
                    sum(pse__Total_Hours__c) totalHours, 
                    pse__Assignment__c assignmentId
                from pse__Timecard_Header__c
                where 
                    pse__Assignment__c in :assignments.keySet() 
                group by pse__Assignment__c
            ];
        }
        else {
            aggResults = [
                select 
                    sum(pse__Total_Hours__c) totalHours, 
                    pse__Assignment__c assignmentId
                from pse__Timecard_Header__c
                where 
                    pse__Assignment__c in :assignments.keySet() and
                    Id Not In :Trigger.newMap.keySet()
                group by pse__Assignment__c
            ];
        }
        
        Map<Id, Decimal> tcTotalHoursByAssignment = new Map<Id, Decimal>();
        for (AggregateResult aggResult : aggResults) {
            Id assignmentId = (Id) aggResult.get('assignmentId');
            Decimal totalHours = (Decimal) aggResult.get('totalHours');
            tcTotalHoursByAssignment.put(assignmentId, totalHours);

            System.debug('&&&&& totalHours for assignment ' + assignmentId + ' is ' + String.valueOf(totalHours));
        }


        for (pse__Timecard_Header__c timecard : Trigger.new) {
            if (timecard.pse__Assignment__c != null) {
                Decimal totalHours = timecard.pse__Total_Hours__c;
                if (tcTotalHoursByAssignment.containsKey(timecard.pse__Assignment__c)) {
                    totalHours += tcTotalHoursByAssignment.get(timecard.pse__Assignment__c);
                }
                
                tcTotalHoursByAssignment.put(timecard.pse__Assignment__c, totalHours);

                System.debug('&&&&& timecard totalHours: ' + totalHours);
            }
        }

        for (pse__Timecard_Header__c timecard : Trigger.new) {
            if (timecard.pse__Assignment__c != null && assignments.containsKey(timecard.pse__Assignment__c)) {
                pse__Assignment__c assignment = assignments.get(timecard.pse__Assignment__c);
                Decimal budgetedHours = 0.0;
                if (assignment.Budgeted_Hours_Assignment__c != null && assignment.Budgeted_Hours_Assignment__c > 0.0) {
                    budgetedHours = assignment.Budgeted_Hours_Assignment__c;
                }

                Decimal tcTotalHours = 0.0;
                if (tcTotalHoursByAssignment.containsKey(assignment.Id)) {
                    tcTotalHours = tcTotalHoursByAssignment.get(assignment.Id);
                }

                System.debug('&&&&& hours: tcTotalHours - ' + String.valueOf(tcTotalHours) +
                             '; budgeted - ' + String.valueOf(budgetedHours));

                if (tcTotalHours > budgetedHours) {
                    timecard.addError('The total hours for all timecards on this assignment have exceeded the budgeted hours.');
                }
            }
        }
    }
}