<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Rename_GTBT</fullName>
        <field>Name</field>
        <formula>Goal_Type__r.Name + &apos; : &apos; +  Business_Title__r.Name</formula>
        <name>FU_Rename_GTBT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>WF_Rename_GTBT</fullName>
        <actions>
            <name>FU_Rename_GTBT</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
