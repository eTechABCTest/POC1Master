<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Reference_Approval_Notification_Email_Alert</fullName>
        <description>Reference Approval Notification Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Reference_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Reference_Call_Emails/Reference_Response_Notification</template>
    </alerts>
    <alerts>
        <fullName>Reference_Vetted_Notification</fullName>
        <description>Reference Vetted Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Reference_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Reference_Call_Emails/Reference_Vetted_Notification</template>
    </alerts>
    <alerts>
        <fullName>Reminder_to_setup_NASA_reference_vetting_call</fullName>
        <description>Reminder to setup NASA reference vetting call</description>
        <protected>false</protected>
        <recipients>
            <field>Reference_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crimson_360_Reference_Emails/NASA_P_AP_email_setting_up_a_reference_vetting_call</template>
    </alerts>
    <alerts>
        <fullName>Reminder_to_setup_reference_vetting_call</fullName>
        <description>Reminder to setup reference vetting call</description>
        <protected>false</protected>
        <recipients>
            <field>Reference_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crimson_360_Reference_Emails/Email_setting_up_a_reference_vetting_call</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_to_Vet_Approved</fullName>
        <field>Approval_to_Vet__c</field>
        <literalValue>Approved</literalValue>
        <name>Approval to Vet Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_to_Vet_Denied</fullName>
        <field>Approval_to_Vet__c</field>
        <literalValue>Denied</literalValue>
        <name>Approval to Vet Denied</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_to_Vet_Pending</fullName>
        <field>Approval_to_Vet__c</field>
        <literalValue>Pending</literalValue>
        <name>Approval to Vet Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reference_Level_Blank</fullName>
        <field>Reference_Level__c</field>
        <name>Reference Level Blank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reference_Status_Unqualified</fullName>
        <field>Reference_Status__c</field>
        <literalValue>Not Referenceable</literalValue>
        <name>Reference Status Unqualified</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Reference_Status_Date</fullName>
        <field>Status_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Reference Status Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status_Date</fullName>
        <field>Approval_Status_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Approval Status Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Former_Ref_Level_Ambassador</fullName>
        <field>Former_Reference_Level__c</field>
        <literalValue>Ambassador</literalValue>
        <name>Update Former Ref Level Ambassador</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Former_Ref_Level_Gold</fullName>
        <field>Former_Reference_Level__c</field>
        <literalValue>Gold Standard</literalValue>
        <name>Update Former Ref Level Gold</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Promotion_Status_Date</fullName>
        <field>Promotion_Status_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Promotion Status Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Date</fullName>
        <description>Update the status date to TODAY()</description>
        <field>Status_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Status Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Promotion Status Changed</fullName>
        <actions>
            <name>Update_Promotion_Status_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Promotion Status Date when the Promotion Status changes</description>
        <formula>ISCHANGED( Promotion_Status__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reference Approval to Vet Changed</fullName>
        <actions>
            <name>Update_Approval_Status_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Approval Status Date when the Approval to Vet field is modified.</description>
        <formula>ISCHANGED( Approval_to_Vet__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reference Level Updated Ambassador</fullName>
        <actions>
            <name>Update_Former_Ref_Level_Ambassador</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Reference Level is changed from ‘Gold Standard’ or to ‘Ambassador’ then set Former Reference Level to ‘Ambassador’.</description>
        <formula>AND(   ISCHANGED(Reference_Level__c),   ISPICKVAL(Reference_Level__c, &quot;Ambassador&quot;),   ISPICKVAL(PRIORVALUE( Reference_Level__c ), &quot;Gold Standard&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reference Level Updated Gold</fullName>
        <actions>
            <name>Update_Former_Ref_Level_Gold</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Reference Level is changed from &lt;blank&gt; to ‘Gold Standard’, then set Former Reference Level to ‘Gold Standard’.</description>
        <formula>AND(   ISCHANGED(Reference_Level__c),   ISPICKVAL(Reference_Level__c, &quot;Gold Standard&quot;),   ISPICKVAL(PRIORVALUE( Reference_Level__c ), &quot;&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reference Module Created</fullName>
        <actions>
            <name>Update_Status_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Reference__c.Status_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Executes when the reference module record is created.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Reference Status Changed</fullName>
        <actions>
            <name>Set_Reference_Status_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Reference Status Date when the Reference Status changes</description>
        <formula>ISCHANGED( Reference_Status__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reference Status Vetted or Unqualified</fullName>
        <actions>
            <name>Reference_Vetted_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Reference__c.Reference_Status__c</field>
            <operation>equals</operation>
            <value>Vetted,Not Referenceable</value>
        </criteriaItems>
        <criteriaItems>
            <field>Reference__c.Vetting_Comments__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Reference Status is changed to Vetted</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
