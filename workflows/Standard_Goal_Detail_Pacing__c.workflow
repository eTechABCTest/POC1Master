<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Rename_GTDP</fullName>
        <field>Name</field>
        <formula>Description__c + &apos; ( &apos; +   TEXT(Period_Start__c) + &apos; - &apos; +  TEXT(Period_End__c) + &apos; ) : &apos; + TEXT(Percent_Manual__c*100) + &apos;%&apos;</formula>
        <name>FU_Rename_GTDP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>WF_Rename_GTDP</fullName>
        <actions>
            <name>FU_Rename_GTDP</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Rename the record according to a fixed standard</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
