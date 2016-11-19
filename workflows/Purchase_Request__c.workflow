<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_60_Days_out_from_Auto_Renewal_Contract_End_Date</fullName>
        <description>Email 60 Days out from Auto Renewal/Contract End Date</description>
        <protected>false</protected>
        <recipients>
            <field>Submitted_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <recipient>Legal</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Process_Folder/Email_60_Days_out_of_Renewal_End_Date_EA</template>
    </alerts>
    <alerts>
        <fullName>Purchase_Request_Approved_Email_Original_Submitter_Business_Lead</fullName>
        <description>Purchase Request Approved - Original Submitter &amp; Business Lead</description>
        <protected>false</protected>
        <recipients>
            <field>Business_Leader__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Submitted_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Process_Folder/Purchase_Request_Approved_Procurement</template>
    </alerts>
    <alerts>
        <fullName>Purchase_Request_Approved_Procurement_Queue</fullName>
        <description>Purchase Request Approved - Procurement Queue</description>
        <protected>false</protected>
        <recipients>
            <recipient>Procurement</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Process_Folder/Purchase_Request_Approved_Procurement</template>
    </alerts>
    <alerts>
        <fullName>Purchase_Request_Email_Accounts_Payable_if_Term_longer_than_3_Months</fullName>
        <description>Purchase Request: Email Accounts Payable if Term longer than 3 Months</description>
        <protected>false</protected>
        <recipients>
            <recipient>Accounts_Payable</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Process_Folder/Email_Accounts_Payable_if_Contract_longer_than_3_Months</template>
    </alerts>
    <alerts>
        <fullName>Purchase_Request_Rejected_Email_Alert</fullName>
        <description>Purchase Request Rejected: Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Submitted_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Process_Folder/Purchase_Request_Rejection_Email_Alert</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_Comment_Requested_Purch_Req</fullName>
        <field>Approval_Comment_Check__c</field>
        <literalValue>Requested</literalValue>
        <name>Approval Comment Requested (Purch Req)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Comment_Required_Purchase_Req</fullName>
        <field>Approval_Comment_Check__c</field>
        <literalValue>Required</literalValue>
        <name>Approval Comment Required (Purchase Req)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdatePurchaseRequestRecordType</fullName>
        <description>Update Purchase Request record type to “Submitted Purchase Request”.
Added as part of CR-20140314-4800.</description>
        <field>RecordTypeId</field>
        <lookupValue>Submitted_Purchase_Request</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>FU_ UpdatePurchaseRequestRecordType</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Purchase_Approval_Initial_Status_Updat</fullName>
        <field>Status__c</field>
        <literalValue>Submitted for Approval</literalValue>
        <name>Purchase Approval - Initial Status Updat</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Purchase_Request_Approved</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Approved</literalValue>
        <name>Purchase Request: Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Purchase_Request_Dept_Head</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Department Head</literalValue>
        <name>Purchase Request: Dept Head</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Purchase_Request_Procurement</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Procurement</literalValue>
        <name>Purchase Request: Procurement</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Purchase_Request_Submitted</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>InfoSec</literalValue>
        <name>Purchase Request: Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Purchase_Request_View_Update</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Finance/Budget</literalValue>
        <name>Purchase Request: View Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>NextValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Purchase_Request_View_Update_Rejection</fullName>
        <field>Approval_Stage__c</field>
        <name>Purchase Request: View Update(Rejection)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Owner_to_Procurement_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Procurement</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Owner to Procurement Queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Purchase_Request_Status</fullName>
        <field>Status__c</field>
        <literalValue>Approved - Awaiting Procurement</literalValue>
        <name>Update Purchase Request Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Email 60 Days out of Contract End Date</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Purchase_Request__c.Auto_Renewal_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Purchase_Request__c.Contract_End_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Email Legal, Advisory Board Liaison (from Vendor record) and contract submitter 60 days prior to Auto Renewal Date if populated, otherwise send email to same group 60 days prior to Contract End Date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Email_60_Days_out_from_Auto_Renewal_Contract_End_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Purchase_Request__c.Contract_End_Date__c</offsetFromField>
            <timeLength>-60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Email 60 Days out of Renewal Date</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Purchase_Request__c.Auto_Renewal_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Email Legal, Advisory Board Liaison (from Vendor record) and contract submitter 60 days prior to Auto Renewal Date if populated, otherwise send email to same group 60 days prior to Contract End Date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Email_60_Days_out_from_Auto_Renewal_Contract_End_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Purchase_Request__c.Auto_Renewal_Date__c</offsetFromField>
            <timeLength>-60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Notify Accounts Payable if Contract %3E 3 Months</fullName>
        <actions>
            <name>Purchase_Request_Email_Accounts_Payable_if_Term_longer_than_3_Months</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>Term_End_Date__c - Term_Start_Date__c &gt; 90 &amp;&amp; (ISPICKVAL(Status__c, &quot;Approved - Awaiting Procurement&quot;) || ISPICKVAL(Status__c, &quot;Purchased&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Purchase Request Approval Step Dept Head</fullName>
        <actions>
            <name>Purchase_Request_Dept_Head</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Purchase_Request__c.Approval_Stage__c</field>
            <operation>equals</operation>
            <value>Accounting Manager (2)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Purchase_Request__c.CapEx__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Set the purchase request&apos;s approval stage to Department Head if the stage is &quot;Accounting Manager (2)&quot; and CapEx? is false.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Purchase Request Approval Step Procurement</fullName>
        <actions>
            <name>Purchase_Request_Procurement</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Purchase_Request__c.Approval_Stage__c</field>
            <operation>equals</operation>
            <value>Accounting Manager</value>
        </criteriaItems>
        <criteriaItems>
            <field>Purchase_Request__c.CapEx__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>set the purchase request&apos;s approval stage to procurement if the stage is &quot;Accounting Manager&quot; and CapEx? is false.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Rejection Comment Flag %28Purchase Req%29</fullName>
        <actions>
            <name>Approval_Comment_Requested_Purch_Req</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Purchase_Request__c.Approval_Comment_Check__c</field>
            <operation>equals</operation>
            <value>Required</value>
        </criteriaItems>
        <description>require comment when rejecting an approval request on a Purchase Request</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
