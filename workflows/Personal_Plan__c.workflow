<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Rename_Personal_Plan</fullName>
        <field>Name</field>
        <formula>Staff_Member__r.FirstName + &apos; &apos; + Staff_Member__r.LastName + &apos; - &apos; +  Description__c + &apos; : &apos;  +  TEXT(Plan_Start__c) + &apos; - &apos; +  TEXT(Plan_End__c)</formula>
        <name>FU_Rename_Personal_Plan</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>WF_Rename_Personal_Plan</fullName>
        <actions>
            <name>FU_Rename_Personal_Plan</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Rename the record according to a fixed standard</description>
        <formula>True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
