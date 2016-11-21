<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Rename_Goal_Template</fullName>
        <field>Name</field>
        <formula>Description__c + &apos; – &apos; +  Goal_Type__r.Name</formula>
        <name>FU_Rename_Goal_Template</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>WF_Rename_Goal_Template</fullName>
        <actions>
            <name>FU_Rename_Goal_Template</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Rename the record according to a fixed standard</description>
        <formula>True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
