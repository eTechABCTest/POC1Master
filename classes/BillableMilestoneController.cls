/*
    Purpose:
       The controller for the creation of billable milestones from line item schedules
            
    Author:     William Rich
    Company:    IconATG
    Contact:    william.rich@iconatg.com
    Created:    8/6/2015
*/

public with sharing class BillableMilestoneController {

    public class LISWrapper {
        public boolean isSelected {get; set;}
        public boolean isDisabled {get; set;}
        public String color {get; set;}
        public Line_Item_Schedule__c lis {get; set;}

        public LISWrapper(Line_Item_Schedule__c liSchedule) {
            this.isSelected = false;
            this.isDisabled = false;
            this.color = 'black';
            if (fieldsAreMissing(liSchedule)) {
                this.isDisabled = true;
                this.color = 'red';
            }

            this.lis = liSchedule;
        }

        private boolean fieldsAreMissing(Line_Item_Schedule__c liSchedule) {
            boolean fieldsAreMissing = false;
            if (liSchedule.Amount__c == null ||
                liSchedule.Invoice_Date__c == null ||
                liSchedule.Invoice_Comment__c == null ||
                liSchedule.Invoice_Comment__c.equals('')) {

                fieldsAreMissing = true;
            }
            return fieldsAreMissing;
        }
    }

	private Id projectId;
    private ApexPages.StandardController stdController;
    private Set<Id> liSchedulesWithMilestone = new Set<Id>();

    public pse__Proj__c project {get; set;}
    public List<LISWrapper> lisWrappers {get; set;}
    public Integer wrapperSize {get; set;}

    public BillableMilestoneController(ApexPages.StandardController stdController) {
        this.projectId = (Id)stdController.getId();
        this.stdController = stdController;

        this.project = [
            select
                Name,
                Contract_ABC__c
            from pse__Proj__c
            where Id = :projectId
        ];

        List<pse__Milestone__c> lisMilestones = [
            select Line_Item_Schedule__c
            from pse__Milestone__c
            where 
                pse__Project__c = :projectId and
                Line_Item_Schedule__c != null
        ];

        for (pse__Milestone__c lisMilestone : lisMilestones) {
            this.liSchedulesWithMilestone.add(lisMilestone.Line_Item_Schedule__c);
        }

        List<Line_Item_Schedule__c> liSchedules = [
            select
                Id,
                Name,
                Type__c,
                Amount__c,
                Invoice_Date__c, 
                Invoice_Comment__c,
                Line_Item_Comment__c
            from Line_Item_Schedule__c
            where
                Contract__c = :project.Contract_ABC__c and
                Invoiced__c = false and
                Sales_Invoice__c = null and 
                Id NOT In :liSchedulesWithMilestone and
                (
                    Type__c = 'Member Fee' or 
                    Type__c = 'Risk Fee' or
                    Type__c = 'Travel' or
                    Type__c = 'Risk Travel'
                )
        ];

        this.wrapperSize = liSchedules.size();

        if (liSchedules.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There are no Line Item Schedules that meet the following criteria:'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '- Line Item Schedule must not be associated with a Milestone.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '- Line Item Schedule must not be associated with a Sales Invoice.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '- Type is Member Fee, Risk Fee, Travel or Risk Travel'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '- Invoiced = false (unchecked)'));
        }
        else {
            this.LISWrappers = new List<LISWrapper>();
            for (Line_Item_Schedule__c liSchedule : liSchedules) {
                this.LISWrappers.add(new LISWrapper(liSchedule));
            }

            boolean missingFields = false;
            for (LISWrapper lisw : this.LISWrappers) {
                if (lisw.isDisabled) {
                    missingFields = true;
                }
            }

            if (missingFields) {
                String msg = 'There are missing fields in the Line Item Schedules. You will not able to create milestones for the ' +
                             'Line Item Schedules in red until the missing fields are corrected';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
            }
        }
    }

    public PageReference createMilestones() {
        PageReference pageRef = stdController.cancel();
        if (noLISsHaveBeenSelected()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one Line Item Schedule.'));
            pageRef = null;
        }
        else {
            List<pse__Milestone__c> milestones = new List<pse__Milestone__c>();
            for (LISWrapper lisWrapper : this.lisWrappers) {
                if (lisWrapper.isSelected) {
                    String milestoneName = 'No Invoice Comment';
                    if (lisWrapper.lis.Invoice_Comment__c != null && !lisWrapper.lis.Invoice_Comment__c.equals('')) {
                        milestoneName = lisWrapper.lis.Invoice_Comment__c.left(80);
                    }

                    Date actualDate = null;
                    boolean approved = false;
                    String status = 'Planned';
                    if (!lisWrapper.lis.Type__c.equals('Risk Fee') && !lisWrapper.lis.Type__c.equals('Risk Travel')) {
                        actualDate = lisWrapper.lis.Invoice_Date__c;
                        approved = true;
                        status = 'Approved';
                    }

                    pse__Milestone__c milestone = new pse__Milestone__c(
                        Name = milestoneName,
                        pse__Milestone_Amount__c = lisWrapper.lis.Amount__c,
                        pse__Target_Date__c = lisWrapper.lis.Invoice_Date__c,
                        pse__Actual_Date__c = actualDate,
                        pse__Project__c = this.projectId,
                        pse__Approved__c = approved,
                        pse__Status__c = status,
                        Line_Item_Schedule__c = lisWrapper.lis.Id
                    );
                    milestones.add(milestone);
                }
            }

            if (!milestones.isEmpty()) insert milestones;
        }
        return pageRef;
    }

    public PageReference cancel() {
        return stdController.cancel();
    }

    private boolean noLISsHaveBeenSelected() {
        boolean thereAreSelections = false;
        for (LISWrapper lisWrapper : this.lisWrappers) {
            if (lisWrapper.isSelected) {
                thereAreSelections = true;
            }
        }
        return !thereAreSelections;
    }
}