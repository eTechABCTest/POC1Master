<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Rename_PGMP</fullName>
        <field>Name</field>
        <formula>Personal_Goal__r.Name + &apos; : &apos; + TEXT(Measurement_Date__c)</formula>
        <name>FU_Rename_PGMP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>WF_Rename_Personal_Goal_Measurement_Period</fullName>
        <actions>
            <name>FU_Rename_PGMP</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
