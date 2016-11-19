<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Rename_Goal_Template_Detail</fullName>
        <field>Name</field>
        <formula>Description__c + &apos; - &apos; + Goal_Type__r.Name</formula>
        <name>FU_Rename_Goal_Template_Detail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Update_GTD_Description</fullName>
        <field>Description__c</field>
        <formula>Goal_Type__r.Description__c</formula>
        <name>FU_Update_GTD_Description</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>WF_Rename_Goal_Template_Detail</fullName>
        <actions>
            <name>FU_Rename_Goal_Template_Detail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_Update_GTD_Description</fullName>
        <actions>
            <name>FU_Update_GTD_Description</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISBLANK(Description__c), OR(ISNEW(),ISCHANGED(Description__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
