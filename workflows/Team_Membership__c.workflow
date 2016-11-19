<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Change_Record_Type_On_Creation</fullName>
        <description>Change the record type to “Assigned”</description>
        <field>RecordTypeId</field>
        <lookupValue>Assigned</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>FU Change Record Type On Creation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_PopulateName</fullName>
        <field>Name</field>
        <formula>Staff_member__r.FirstName + &quot; &quot; + Staff_member__r.LastName + &quot;-&quot; +  Role__r.Name</formula>
        <name>FU_PopulateName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>WF_Change_Record_Type_On_Creation</fullName>
        <actions>
            <name>FU_Change_Record_Type_On_Creation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Team_Membership__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Default</value>
        </criteriaItems>
        <description>Change the record type of an SA record upon creation.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_PopulateName</fullName>
        <actions>
            <name>FU_PopulateName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Name &lt;&gt; Staff_member__r.FirstName + &quot; &quot; + Staff_member__r.LastName + &quot;-&quot; + Role__r.Name</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
