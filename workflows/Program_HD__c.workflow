<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Probability_to_100_on_Contract_HD</fullName>
        <description>Set the Program (HD) Close &apos;Probability&apos; to 100% when Program (HD) Status EQUALS &quot;Contract&quot; OR &quot;Pending Signature&quot;</description>
        <field>Probability_HD__c</field>
        <formula>1</formula>
        <name>&apos;Probability&apos; to 100%:Status=Con OR PS_h</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UPDATE_LOCK_THE_RECORD</fullName>
        <field>Lock_the_Record_HD__c</field>
        <literalValue>1</literalValue>
        <name>UPDATE_LOCK_THE_RECORD</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Program %28HD%29 Contracted OR Pending Sig</fullName>
        <actions>
            <name>Set_Probability_to_100_on_Contract_HD</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Program_HD__c.Status_HD__c</field>
            <operation>equals</operation>
            <value>Contracted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Program_HD__c.Status_HD__c</field>
            <operation>equals</operation>
            <value>Pending Signature</value>
        </criteriaItems>
        <description>Triggers updates when a (HD) Program Status EQUALS Contracted OR Pending Signature</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_UPDATE_LOCK_THE_RECORD</fullName>
        <actions>
            <name>UPDATE_LOCK_THE_RECORD</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Program_HD__c.Status_HD__c</field>
            <operation>equals</operation>
            <value>Contracted</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
