<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>IS_Mod_Update_Change_Value</fullName>
        <field>Change_Value__c</field>
        <formula>IF(
INCLUDES(Deployed_To__c, &quot;Production&quot;),1.0, 
IF(
INCLUDES(Deployed_To__c, &quot;Rehearse&quot;), 0.1, 
IF(
INCLUDES(Deployed_To__c, &quot;UAT&quot;), 0.1, 
IF(
INCLUDES(Deployed_To__c, &quot;QA&quot;), 0.01,
0
))))</formula>
        <name>IS Mod: Update Change Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IS_Mod_Update_Record_Type_to_Deployed</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Deployed</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>IS Mod: Update Record Type to Deployed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Include_in_Change_Set</fullName>
        <field>Include_in_Change_Set__c</field>
        <literalValue>1</literalValue>
        <name>Update Include in Change Set</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Deployed To changes value</fullName>
        <actions>
            <name>IS_Mod_Update_Change_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Runs when the Deployed To field changes to any value</description>
        <formula>ISCHANGED(Deployed_To__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IS Mod Enter a Simple Mod</fullName>
        <actions>
            <name>Update_Include_in_Change_Set</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>IS_System_Modification__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Simple</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Mark IS Mod as Deployed to Production</fullName>
        <actions>
            <name>IS_Mod_Update_Record_Type_to_Deployed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Runs when the Deployed To field changes to include &apos;Production&apos; when it did not include it previously</description>
        <formula>NOT(INCLUDES(PRIORVALUE(Deployed_To__c),&apos;Production&apos;)) &amp;&amp; ISCHANGED(Deployed_To__c) &amp;&amp; INCLUDES(Deployed_To__c, &apos;Production&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
