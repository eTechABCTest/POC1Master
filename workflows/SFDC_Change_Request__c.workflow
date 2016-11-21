<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Integration_Teams_of_Upcoming_Salesforce_Change_Request</fullName>
        <ccEmails>ETLSupport@advisory.com</ccEmails>
        <description>Notify Integration Teams of Upcoming Salesforce Change Request</description>
        <protected>false</protected>
        <recipients>
            <recipient>kadakiar@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>narayana@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>thyagarr@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IS_CRM/Notify_Integration_Teams_of_Upcoming_Salesforce_Changes</template>
    </alerts>
    <alerts>
        <fullName>SFDC_CRITICAL_Change_Request_Email_Alert</fullName>
        <description>SFDC CRITICAL Change Request Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Dev_COE_Managers</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>sfadmin@advisory.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IS_CRM/SFDC_CRITICAL_Change_Request</template>
    </alerts>
    <alerts>
        <fullName>SFDC_Change_Request_Status_Change</fullName>
        <description>SFDC Change Request Status Change</description>
        <protected>false</protected>
        <recipients>
            <field>Business_Operations_Contact2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Requested_By2__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SFDC_Change_Request_Status_Change</template>
    </alerts>
    <alerts>
        <fullName>SFDC_Change_Request_stage_change_notification</fullName>
        <description>SFDC Change Request stage change notification</description>
        <protected>false</protected>
        <recipients>
            <field>Business_Operations_Contact2__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IS_CRM/SFDC_Change_Request_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>CR_Update_Close_Date</fullName>
        <field>Closed_Date__c</field>
        <formula>Today()</formula>
        <name>CR-Update Close Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CR_Update_Release_Assignment_Date</fullName>
        <field>Release_Assigned_Date__c</field>
        <formula>Today()</formula>
        <name>CR-Update Release Assignment Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_ReleaseChangeCounter</fullName>
        <field>Release_Change_Counter__c</field>
        <formula>IF(ISNULL(Release_Change_Counter__c ), 1, Release_Change_Counter__c + 1)</formula>
        <name>FU_ReleaseChangeCounter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdateStageToCrossCheck</fullName>
        <description>Created for CR-20141204-8244.</description>
        <field>Stage__c</field>
        <literalValue>Ready for Cross Check</literalValue>
        <name>FU_UpdateStageToCrossCheck</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdateStageToDevInProgress</fullName>
        <field>Stage__c</field>
        <literalValue>Dev In Progress</literalValue>
        <name>FU_UpdateStageToDevInProgress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdateStageToDevQAAnalysis</fullName>
        <field>Stage__c</field>
        <literalValue>Dev QA Analysis</literalValue>
        <name>FU_UpdateStageToDevQAAnalysis</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdateStageToISQAInProgress</fullName>
        <field>Stage__c</field>
        <literalValue>Test Sandbox In Progress</literalValue>
        <name>FU_UpdateStageToISQAInProgress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rank_Department_Last_Updated_Update</fullName>
        <field>Rank_Department_Last_Updated__c</field>
        <formula>TODAY ()</formula>
        <name>Rank-Department Last Updated Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SFDC_CR_Estimate_IS_QA</fullName>
        <field>IS_QA_Estimated_Hrs__c</field>
        <formula>(Coding_Estimated_Hrs__c +  Config_Estimated_Hrs__c )/2</formula>
        <name>SFDC CR Estimate IS QA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SF_CR_Approved_Date</fullName>
        <field>Approved_Date__c</field>
        <formula>TODAY()</formula>
        <name>SF CR Approved Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Salesforce_Help_Actual_Completion_Date</fullName>
        <field>Actual_Completion_Date__c</field>
        <formula>TODAY()</formula>
        <name>Salesforce Help Actual Completion Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_L2_CR_Owner_to_IS_CRM</fullName>
        <field>OwnerId</field>
        <lookupValue>ISCRM</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update L2 CR Owner to IS CRM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CR Salesforce Help Actual Completion Date</fullName>
        <actions>
            <name>Salesforce_Help_Actual_Completion_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>SFDC_Change_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Salesforce Help</value>
        </criteriaItems>
        <criteriaItems>
            <field>SFDC_Change_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Cancelled,Duplicate,Resolved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CR-Update Close Date</fullName>
        <actions>
            <name>CR_Update_Close_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SFDC_Change_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Cancelled,12-Deployed</value>
        </criteriaItems>
        <description>update the Close Date field when Deployed or cancelled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CR-Update Release Assignment Date</fullName>
        <actions>
            <name>CR_Update_Release_Assignment_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>update the Release Assignment Date field when Release is associated.</description>
        <formula>AND( ISCHANGED(   Release__c   ), NOT(ISNULL( Release__c ) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Change Request Status - In UAT for LIII</fullName>
        <actions>
            <name>Notify_Integration_Teams_of_Upcoming_Salesforce_Change_Request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SFDC_Change_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>10-In UAT</value>
        </criteriaItems>
        <criteriaItems>
            <field>SFDC_Change_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Level III</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Default Owner for L2 Requests</fullName>
        <actions>
            <name>Update_L2_CR_Owner_to_IS_CRM</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SFDC_Change_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Level II</value>
        </criteriaItems>
        <description>This rule will default the owner of L2 Change Requests to the IS CRM queue.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Rank-Department Last Updated</fullName>
        <actions>
            <name>Rank_Department_Last_Updated_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow is used to be update the field &quot;Rank-Department Last Updated&quot; with the date it was last updated on.</description>
        <formula>OR( ISCHANGED( Rank_Department_Planning__c), AND( NOT( ISNULL( Rank_Department_Planning__c)),  ISNEW() ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SFDC CR Approved Date</fullName>
        <actions>
            <name>SF_CR_Approved_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SFDC_Change_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>03-Approved</value>
        </criteriaItems>
        <description>captures when a change request moves to Approved.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SFDC CR Estimate IS QA</fullName>
        <actions>
            <name>SFDC_CR_Estimate_IS_QA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  ISBLANK( IS_QA_Estimated_Hrs__c ) , OR(   Coding_Estimated_Hrs__c &gt;0 ,   Config_Estimated_Hrs__c &gt; 0 ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SFDC Change Request Stage Notification</fullName>
        <actions>
            <name>SFDC_Change_Request_stage_change_notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SFDC_Change_Request__c.Stage__c</field>
            <operation>equals</operation>
            <value>Additional Info Required,Ready for Testing</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SFDC Change Request Status Change</fullName>
        <actions>
            <name>SFDC_Change_Request_Status_Change</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( 	ISCHANGED( Status__c ) , 	Notification_Status_Change__c = true )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SFDC_CRITICAL_Change_Request</fullName>
        <actions>
            <name>SFDC_CRITICAL_Change_Request_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SFDC_Change_Request__c.Priority__c</field>
            <operation>equals</operation>
            <value>A - Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>SFDC_Change_Request__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>App Update</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_ReleaseChangeCounter</fullName>
        <actions>
            <name>FU_ReleaseChangeCounter</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Release__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_UpdateStageToCrossCheck</fullName>
        <actions>
            <name>FU_UpdateStageToCrossCheck</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow rule to default Stage to Ready for Cross Check when 08 status is selected. Created for CR-20141204-8244.</description>
        <formula>AND( ISPICKVAL(PRIORVALUE(Status__c), &quot;07-In Dev QA&quot;), ISPICKVAL(Status__c, &quot;08-To Test Sandbox&quot;), OR(RecordType.DeveloperName = &apos;Level_I&apos;, RecordType.DeveloperName = &apos;Level_II&apos;, RecordType.DeveloperName = &apos;Level_III&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_UpdatesStageToDevInProgress</fullName>
        <actions>
            <name>FU_UpdateStageToDevInProgress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>ISPICKVAL(Status__c, &quot;06-In Development&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_UpdatesStageToDevQAAnalysis</fullName>
        <actions>
            <name>FU_UpdateStageToDevQAAnalysis</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>ISPICKVAL(Status__c, &quot;07-In Dev QA&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_UpdatesStageToISQAInProgress</fullName>
        <actions>
            <name>FU_UpdateStageToISQAInProgress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>ISPICKVAL(Status__c, &quot;09-In IS QA&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
