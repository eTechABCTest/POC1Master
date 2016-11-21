<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Expense_Authorization_Approved</fullName>
        <description>Expense Authorization Approved</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Events_Member_Support/Expense_Authorization_Approved_Notification</template>
    </alerts>
    <alerts>
        <fullName>Expense_Authorization_Rejected</fullName>
        <description>Expense Authorization Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Events_Member_Support/Expense_Authorization_Rejected_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Autoname_Expense_Authorization</fullName>
        <field>Name</field>
        <formula>Contact__r.FirstName + &quot; &quot; + Contact__r.LastName + &quot;-&quot; + TEXT( Type__c )</formula>
        <name>Autoname - Expense Authorization</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Expense_Authorization_Status_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Expense Authorization Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Expense_Authorization_Status_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Expense Authorization Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Autoname - Expense Authorization</fullName>
        <actions>
            <name>Autoname_Expense_Authorization</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Automatically update the Name value of a Spend Authorization based on a combination of values</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
