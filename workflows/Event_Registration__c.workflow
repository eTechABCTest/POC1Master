<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Autoname_Registration</fullName>
        <description>Autopopulate the registration name.</description>
        <field>Name</field>
        <formula>Contact_Name__c + &quot;-&quot; +  Institution_Name__c + &quot;-&quot; +  TEXT( Status__c )</formula>
        <name>Autoname - Registration</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Registered_Now</fullName>
        <description>Set the Date Registered field to dateTime now.</description>
        <field>Date_Registered__c</field>
        <formula>NOW()</formula>
        <name>Date Registered Now</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Membership_Status_Text_Field_FU</fullName>
        <field>Membership_Status_Text__c</field>
        <formula>Membership_Status__c</formula>
        <name>Update Membership Status Text Field FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Registration%3A Update Membership Status Field</fullName>
        <actions>
            <name>Update_Membership_Status_Text_Field_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created as part of the Events Management Project</description>
        <formula>NOT(ISBLANK(Membership_Status__c)) || ISCHANGED (Membership_Status__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
