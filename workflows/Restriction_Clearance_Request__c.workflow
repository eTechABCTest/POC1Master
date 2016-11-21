<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EA_Notify_Creator_of_Response</fullName>
        <description>EA_Notify_Creator_of_Response</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ET_Notify_Creator_of_Response</template>
    </alerts>
    <alerts>
        <fullName>Restriction_Clearance_Request_Decision_Notification</fullName>
        <description>Restriction Clearance Request Decision Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Edit_to_Restriction_Clearance_Request</template>
    </alerts>
    <alerts>
        <fullName>Restriction_Clearance_Request_Notification</fullName>
        <description>Restriction Clearance Request Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Restriction_Owner_2__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Clearance_Restriction_Request</template>
    </alerts>
    <fieldUpdates>
        <fullName>FU_Reason_for_Clearance_Request</fullName>
        <field>Reason_for_Clearance_Request__c</field>
        <literalValue>Warm Lead - Member Requested Follow Up</literalValue>
        <name>FU_Reason_for_Clearance_Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RestrictionClearanceRequest_PopulateName</fullName>
        <description>Populate the name field with
Contact_Instituion + Program Acronym + Type + Marketer
Concatenate the Type - limit to 18 characters
 Truncate the Contact_Institution__c to display only the characters in front of the first dash.</description>
        <field>Name</field>
        <formula>IF(
CONTAINS(Contact_Institution__c , &quot;-&quot;),
TRIM(LEFT( Contact_Institution__c ,  FIND(&quot;-&quot;, Contact_Institution__c , 0)-1 )),
Contact_Institution__c
)
+ &quot;-&quot; +  Program__r.Program_Acronym__c + &quot;-&quot; + 
IF(
LEN(TEXT( Type_of_Interaction_Requested__c )) &gt; 18,
LEFT( TEXT( Type_of_Interaction_Requested__c) , 18),
TEXT(Type_of_Interaction_Requested__c))
+ &quot;-&quot; +  Marketer__r.FirstName + &quot; &quot; +  Marketer__r.LastName</formula>
        <name>RestrictionClearanceRequest_PopulateName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Response_Approved</fullName>
        <description>Update Clearance Approval Response upon approval.</description>
        <field>Clearance_Approval_Response__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Approval Response (Approved)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Response_Denied</fullName>
        <description>Update Clearance Approval Response upon denial.</description>
        <field>Clearance_Approval_Response__c</field>
        <literalValue>Denied</literalValue>
        <name>Update Approval Response (Denied)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Clearance_Response_Date</fullName>
        <description>Updates clearance respones date to today when status leaves submitted</description>
        <field>Response_Date__c</field>
        <formula>Today()</formula>
        <name>Update Clearance Response Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Response_Date</fullName>
        <description>to Today()</description>
        <field>Response_Date__c</field>
        <formula>Today()</formula>
        <name>Update Response Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Request Leaves Pending</fullName>
        <actions>
            <name>Update_Clearance_Response_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Restriction_Clearance_Request__c.Clearance_Approval_Response__c</field>
            <operation>notEqual</operation>
            <value>&quot;Submitted, Response Pending&quot;</value>
        </criteriaItems>
        <description>Used to fire update to restriction clearance response date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Response Date Change</fullName>
        <actions>
            <name>Update_Response_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>New.Updates the response date when the clearance approval response changes.</description>
        <formula>ISCHANGED( Clearance_Approval_Response_text__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RestrictionClearanceRequest_PopulateName</fullName>
        <actions>
            <name>RestrictionClearanceRequest_PopulateName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Restriction_Clearance_Request__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Populate the name field with 
Contact_Instituion + Program Acronym + Type + Marketer 
Concatenate the Type - limit to 18 characters 
Truncate the Contact_Institution__c to display only the characters in front of the first dash.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_Notify_Creator_Of_Response</fullName>
        <actions>
            <name>EA_Notify_Creator_of_Response</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(                 ISCHANGED(Clearance_Approval_Response__c),                 Notify_Creator_of_Response__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_Update_Reason_for_Clearance_Request</fullName>
        <actions>
            <name>FU_Reason_for_Clearance_Request</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(                 NOT(ISBLANK(Warm_Lead__c)) ,                 Warm_Lead__r.Request_to_be_contacted__c,                 NOT(ISPICKVAL(Reason_for_Clearance_Request__c, &quot;Warm Lead – Member Requested Follow Up&quot;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
