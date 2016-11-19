<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Rename_GTCT</fullName>
        <field>Name</field>
        <formula>Goal_Type__r.Name + &apos; : &apos; + Name</formula>
        <name>FU_Rename_GTCT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>WF_Rename_GTCT</fullName>
        <actions>
            <name>FU_Rename_GTCT</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Rename the record according to a fixed standard</description>
        <formula>True</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
