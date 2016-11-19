<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Eloqua_Snapshot_EAB_FU</fullName>
        <field>Eloqua_Snapshot_Topic_EAB__c</field>
        <formula>Contact__r.Eloqua_Score_Topic_EAB__c</formula>
        <name>Eloqua Snapshot: EAB FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Eloqua_Snapshot_Patient_Engagement_FU</fullName>
        <field>Eloqua_Snapshot_Topic_3__c</field>
        <formula>Contact__r.Eloqua_Score_Topic_3__c</formula>
        <name>Eloqua Snapshot: Patient Engagement FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Eloqua_Snapshot_Rev_Cycle_FU</fullName>
        <field>Eloqua_Snapshot_Topic_2__c</field>
        <formula>Contact__r.Eloqua_Score_Topic_2__c</formula>
        <name>Eloqua Snapshot: Rev Cycle FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Eloqua_Snapshot_Topic_4_FU</fullName>
        <field>Eloqua_Snapshot_Topic_4__c</field>
        <formula>Contact__r.Eloqua_Score_Topic_4__c</formula>
        <name>Eloqua Snapshot: Topic 4 FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Eloqua_Snapshot_Topic_5_FU</fullName>
        <field>Eloqua_Snapshot_Topic_5__c</field>
        <formula>Contact__r.Eloqua_Score_Topic_5__c</formula>
        <name>Eloqua Snapshot: Topic 5 FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Eloqua_Snapshot_Topic_6_FU</fullName>
        <field>Eloqua_Snapshot_Topic_6__c</field>
        <formula>Contact__r.Eloqua_Score_Topic_6__c</formula>
        <name>Eloqua Snapshot: Topic 6 FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Eloqua_Topic_Snapshot_Pop_Health_FU</fullName>
        <field>Eloqua_Snapshot_Topic_1__c</field>
        <formula>Contact__r.Eloqua_Score_Topic_1__c</formula>
        <name>Eloqua Topic Snapshot Pop Health FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Initial_Eloqua_Rating_FU</fullName>
        <field>Initial_Eloqua_Lead_Rating__c</field>
        <formula>Contact__r.Eloqua_Lead_Rating__c</formula>
        <name>Initial Eloqua Rating FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Lead_Date_Today</fullName>
        <field>Lead_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Lead Date Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_C_suite_checkbox</fullName>
        <field>C_Suite__c</field>
        <literalValue>1</literalValue>
        <name>Update C-suite checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Warm_Lead_Status</fullName>
        <field>Status__c</field>
        <literalValue>Opportunity Identified (Moved to Opportunity)</literalValue>
        <name>Update Warm Lead Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_warm_lead_followed_up_date</fullName>
        <description>puts today in followed up date when fired by status leaving pending</description>
        <field>Followed_Up_Date__c</field>
        <formula>Today()</formula>
        <name>update warm lead followed up date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Create Product Lead %28OAB%29 as Outcome</fullName>
        <actions>
            <name>Set_Lead_Date_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Runs when a Warm Lead record is created as an Outcome for a Relationship Interaction.</description>
        <formula>AND(  NOT( ISBLANK(Source_Interaction__c ) ),  Outcome_Type__c == &quot;Product Lead (OAB)&quot; )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Eloqua Topic Snapshot Updates</fullName>
        <actions>
            <name>Eloqua_Snapshot_EAB_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Eloqua_Snapshot_Patient_Engagement_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Eloqua_Snapshot_Rev_Cycle_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Eloqua_Snapshot_Topic_4_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Eloqua_Snapshot_Topic_5_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Eloqua_Snapshot_Topic_6_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Eloqua_Topic_Snapshot_Pop_Health_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK(Contact__c) &amp;&amp; ISBLANK(Eloqua_Snapshot_Topic_1__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Initial Eloqua Lead Rating</fullName>
        <actions>
            <name>Initial_Eloqua_Rating_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(NOT(ISBLANK( Contact__c )) &amp;&amp; ISBLANK( Initial_Eloqua_Lead_Rating__c)) || ISCHANGED ( Contact__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Owner</fullName>
        <active>false</active>
        <description>(inactive) New. Updates the native owner field of the Warm Lead with the marketer assignment.</description>
        <formula>Ischanged( Marketer_Assignment__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Warm Leads Num of Opps</fullName>
        <actions>
            <name>Update_Warm_Lead_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>update_warm_lead_followed_up_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Warm_Lead__c.Number_of_Warm_Leads__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Warm_Lead__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <description>Used to initiate a field update on warm leads Status.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Updates Follow Up When Status Changes</fullName>
        <actions>
            <name>update_warm_lead_followed_up_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Warm_Lead__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Pending</value>
        </criteriaItems>
        <description>updates warm lead followed-up date when status changes from pending</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Validate C-suite checkbox</fullName>
        <actions>
            <name>Update_C_suite_checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Warm_Lead__c.Contact_level__c</field>
            <operation>equals</operation>
            <value>CXO</value>
        </criteriaItems>
        <criteriaItems>
            <field>Warm_Lead__c.C_Suite__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
