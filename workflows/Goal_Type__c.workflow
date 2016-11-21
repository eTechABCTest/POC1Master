<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Rename_Goal_Type</fullName>
        <field>Name</field>
        <formula>Description__c + &apos; - &apos; +  TEXT(Base_Process__c)</formula>
        <name>FU_Rename_Goal_Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>WF_Rename_Goal_Type</fullName>
        <actions>
            <name>FU_Rename_Goal_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Rename the record according to a fixed standard</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
