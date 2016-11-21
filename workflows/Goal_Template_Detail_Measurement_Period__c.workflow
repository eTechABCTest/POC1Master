<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Rename_GTDMP</fullName>
        <description>Field update to rename the Goal Template Detail Measurement Period</description>
        <field>Name</field>
        <formula>Goal_Template_Detail__r.Description__c + &apos;:&apos; + TEXT(Measurement_Date__c)</formula>
        <name>FU_Rename_GTDMP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>WF_Rename_GTDMP</fullName>
        <actions>
            <name>FU_Rename_GTDMP</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
