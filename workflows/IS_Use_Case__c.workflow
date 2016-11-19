<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>IS_Use_Case_Update_Type_Blank</fullName>
        <description>Set the Update Type field to blank.</description>
        <field>Update_Type__c</field>
        <name>IS Use Case Update Type Blank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>IS Use Case Update Type</fullName>
        <actions>
            <name>IS_Use_Case_Update_Type_Blank</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set the Update Type back to null after insert/update.</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
