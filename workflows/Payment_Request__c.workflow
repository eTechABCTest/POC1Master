<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Payment_Request_Amount_greater_than_Purchase_Req_Amount</fullName>
        <description>Payment Request: Amount greater than Purchase Req Amount</description>
        <protected>false</protected>
        <recipients>
            <recipient>Finance</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Process_Folder/Payment_Request_greater_than_Budget_Allocation</template>
    </alerts>
    <alerts>
        <fullName>Payment_Request_Approved_EA</fullName>
        <description>Payment Request Approved: EA</description>
        <protected>false</protected>
        <recipients>
            <field>Submitted_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Process_Folder/Payment_Request_Approved</template>
    </alerts>
    <alerts>
        <fullName>Payment_Request_Rejected_EA</fullName>
        <description>Payment Request Rejected: EA</description>
        <protected>false</protected>
        <recipients>
            <field>Submitted_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Process_Folder/Payment_Request_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_Comment_Requested_Payment_Req</fullName>
        <field>Approval_Comment_Check__c</field>
        <literalValue>Requested</literalValue>
        <name>Approval Comment Requested (Payment Req)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Comment_Required_Payment_Req</fullName>
        <field>Approval_Comment_Check__c</field>
        <literalValue>Required</literalValue>
        <name>Approval Comment Required (Payment Req)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Payment_Request_Accounting_Manager</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Accounting Manager</literalValue>
        <name>Payment Request: Accounting Manager</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Payment_Request_Advisory_Board_Liaison</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Advisory Board Liaison</literalValue>
        <name>Payment Request: Advisory Board Liaison</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Payment_Request_Approved_Remove_View</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Approved</literalValue>
        <name>Payment Request: Approved (Remove View)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Payment_Request_Approved_Update_Status</fullName>
        <field>Status__c</field>
        <literalValue>Approved - Awaiting Payment</literalValue>
        <name>Payment Request:Approved &amp; Update Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Payment_Request_Mark_Denied</fullName>
        <field>Status__c</field>
        <literalValue>Denied</literalValue>
        <name>Payment Request: Mark Denied</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Payment_Request_Rejection_Update_View</fullName>
        <field>Approval_Stage__c</field>
        <name>Payment Request: Rejection (Update View)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Payment_Request_Submitted</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Department Head</literalValue>
        <name>Payment Request: Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Purchase_Request_Update_Status</fullName>
        <field>Status__c</field>
        <literalValue>Submitted for Approval</literalValue>
        <name>Purchase Request: Update Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Payment Request%3A Amount greater than associated Total Budget Allocation</fullName>
        <actions>
            <name>Payment_Request_Amount_greater_than_Purchase_Req_Amount</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Payment_Request__c.Approval_Stage__c</field>
            <operation>equals</operation>
            <value>Department Head</value>
        </criteriaItems>
        <criteriaItems>
            <field>Payment_Request__c.Pmt_Amt_greater_than_Purchase_Amt__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Created as part of CR-2083. This workflow fires to the Finance team when a submitter submits a Payment Request where payment amount  is greater than the associated Purchase Request&apos;s total Budget Allocation Amounts.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Rejection Comment Flag %28Payment Req%29</fullName>
        <actions>
            <name>Approval_Comment_Requested_Payment_Req</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Payment_Request__c.Approval_Comment_Check__c</field>
            <operation>equals</operation>
            <value>Required</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
