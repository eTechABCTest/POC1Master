/*
    Purpose:
        This trigger validates that the sum of the Total Hours of all timecards submitted against a project 
        whose Set Max Hours Per Day checkbox is checked should never exceed the project Max Hours Per Day.
            
    Initiative: IconATG PSA Implementation
    Author:     William Rich
    Company:    IconATG
    Contact:    william.rich@iconatg.com
    Created:    7/10/2015
*/

trigger ValidateMaxTimecardHoursPerDay on pse__Timecard_Header__c (before insert, before update) {
    Set<Id> projectIds = new Set<Id>();
    Set<Date> endDates = new Set<Date>();
    for (pse__Timecard_Header__c timecard : Trigger.new) {
        if (timecard.pse__Project__c != null && timecard.pse__Resource__c != null && timecard.pse__End_Date__c != null) {
            projectIds.add(timecard.pse__Project__c);
            endDates.add(timecard.pse__End_Date__c);
        }
    }

    if (!projectIds.isEmpty()) {
        Map<Id, pse__Proj__c> projects = new Map<Id, pse__Proj__c>([
            select
                Id,
                Max_Hours_Per_Day__c
            from pse__Proj__c
            where 
                Id in :projectIds and 
                Set_Max_Hours_Per_Day__c = true
        ]);

        List<AggregateResult> aggResults = null;
        if (Trigger.isInsert) {
            aggResults = [
                select
                    sum(pse__Sunday_Hours__c) sundayHours,
                    sum(pse__Monday_Hours__c) mondayHours,
                    sum(pse__Tuesday_Hours__c) tuesdayHours,
                    sum(pse__Wednesday_Hours__c) wednesdayHours,
                    sum(pse__Thursday_Hours__c) thursdayHours,
                    sum(pse__Friday_Hours__c) fridayHours,
                    sum(pse__Saturday_Hours__c) saturdayHours,
                    pse__Project__c projectId,
                    pse__Resource__c resourceId,
                    pse__End_Date__c endDate
                from pse__Timecard_Header__c
                where 
                    pse__Project__c in :projectIds and 
                    pse__End_Date__c in :endDates
                group by pse__Project__c, pse__Resource__c, pse__End_Date__c
            ];
        }
        else {
            aggResults = [
                select
                    sum(pse__Sunday_Hours__c) sundayHours,
                    sum(pse__Monday_Hours__c) mondayHours,
                    sum(pse__Tuesday_Hours__c) tuesdayHours,
                    sum(pse__Wednesday_Hours__c) wednesdayHours,
                    sum(pse__Thursday_Hours__c) thursdayHours,
                    sum(pse__Friday_Hours__c) fridayHours,
                    sum(pse__Saturday_Hours__c) saturdayHours,
                    pse__Project__c projectId,
                    pse__Resource__c resourceId,
                    pse__End_Date__c endDate
                from pse__Timecard_Header__c
                where 
                    pse__Project__c in :projectIds and 
                    pse__End_Date__c in :endDates and
                    Id Not In :Trigger.newMap.keySet()
                group by pse__Project__c, pse__Resource__c, pse__End_Date__c
            ];
        }

        Map<String, TimecardHours> tcHoursByProjectResourceAndDate = new Map<String, TimecardHours>();
        for (AggregateResult aggResult : aggResults) {
            String projectResourceAndDate = (String) aggResult.get('projectId') + 
                                            (String) aggResult.get('resourceId') + 
                                            String.valueOf((Date) aggResult.get('endDate'));

            tcHoursByProjectResourceAndDate.put(projectResourceAndDate, new TimecardHours(aggResult));
        }

        for (pse__Timecard_Header__c timecard : Trigger.new) {
            if (timecard.pse__Project__c != null && timecard.pse__Resource__c != null && timecard.pse__End_Date__c != null) {
                String projectResourceAndDate = (String) timecard.pse__Project__c + 
                                                (String) timecard.pse__Resource__c + 
                                                String.valueOf(timecard.pse__End_Date__c);

                if (tcHoursByProjectResourceAndDate.containsKey(projectResourceAndDate)) {
                    tcHoursByProjectResourceAndDate.get(projectResourceAndDate).addHours(timecard);
                }
                else {
                    tcHoursByProjectResourceAndDate.put(projectResourceAndDate, new TimecardHours(timecard));
                }
            }
        }

        for (pse__Timecard_Header__c timecard : Trigger.new) {
            if (timecard.pse__Project__c != null && timecard.pse__Resource__c != null && timecard.pse__End_Date__c != null) {
                String projectResourceAndDate = (String) timecard.pse__Project__c + 
                                                (String) timecard.pse__Resource__c + 
                                                String.valueOf(timecard.pse__End_Date__c);

                if (tcHoursByProjectResourceAndDate.containsKey(projectResourceAndDate)) {
                    TimecardHours tcHours = tcHoursByProjectResourceAndDate.get(projectResourceAndDate);
                    if (projects.containsKey(timecard.pse__Project__c)) {
                        Decimal maxHoursPerDay = projects.get(timecard.pse__Project__c).Max_Hours_Per_Day__c;
                        if (tcHours.sundayHours > maxHoursPerDay ||
                            tcHours.mondayHours > maxHoursPerDay ||
                            tcHours.tuesdayHours > maxHoursPerDay ||
                            tcHours.wednesdayHours > maxHoursPerDay ||
                            tcHours.thursdayHours > maxHoursPerDay ||
                            tcHours.fridayHours > maxHoursPerDay ||
                            tcHours.saturdayHours > maxHoursPerDay) {

                            timecard.addError('The total daily timecard hours for the week ending ' + String.valueOf(timecard.pse__End_Date__c) + ' ' +
                                              'exceeds the project maximum of ' + String.valueOf(maxHoursPerDay));
                        }
                    }
                }
            }
        }        
    }

    private class TimecardHours {
        public Decimal sundayHours;
        public Decimal mondayHours;
        public Decimal tuesdayHours;
        public Decimal wednesdayHours;
        public Decimal thursdayHours;
        public Decimal fridayHours;
        public Decimal saturdayHours;

        public TimecardHours(AggregateResult aggResult) {
            this.sundayHours = (Decimal) aggResult.get('sundayHours');
            this.mondayHours = (Decimal) aggResult.get('mondayHours');
            this.tuesdayHours = (Decimal) aggResult.get('tuesdayHours');
            this.wednesdayHours = (Decimal) aggResult.get('wednesdayHours');
            this.thursdayHours = (Decimal) aggResult.get('thursdayHours');
            this.fridayHours = (Decimal) aggResult.get('fridayHours');
            this.saturdayHours = (Decimal) aggResult.get('saturdayHours');
        }

        public TimecardHours(pse__Timecard_Header__c timecard) {
            this.sundayHours = timecard.pse__Sunday_Hours__c;
            this.mondayHours = timecard.pse__Monday_Hours__c;
            this.tuesdayHours = timecard.pse__Tuesday_Hours__c;
            this.wednesdayHours = timecard.pse__Wednesday_Hours__c;
            this.thursdayHours = timecard.pse__Thursday_Hours__c;
            this.fridayHours = timecard.pse__Friday_Hours__c;
            this.saturdayHours = timecard.pse__Saturday_Hours__c;
        }

        public void addHOurs(pse__Timecard_Header__c timecard) {
            this.sundayHours += timecard.pse__Sunday_Hours__c;
            this.mondayHours += timecard.pse__Monday_Hours__c;
            this.tuesdayHours += timecard.pse__Tuesday_Hours__c;
            this.wednesdayHours += timecard.pse__Wednesday_Hours__c;
            this.thursdayHours += timecard.pse__Thursday_Hours__c;
            this.fridayHours += timecard.pse__Friday_Hours__c;
            this.saturdayHours += timecard.pse__Saturday_Hours__c;
        }
    }
}