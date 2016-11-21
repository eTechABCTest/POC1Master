<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Probability_to_0_on_Declined</fullName>
        <description>Sets a the Program Probability to 0 when the Program Status is set to Declined</description>
        <field>Probability__c</field>
        <formula>0</formula>
        <name>Set Probability to 0 on Declined</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Probability_to_100_on_Contract</fullName>
        <description>Sets a the Program &apos;Close Probability&apos; to 100% when the Program Status is set to &apos;Contracted&apos; OR &apos;Pending Signature&apos;</description>
        <field>Probability__c</field>
        <formula>1</formula>
        <name>&apos;Probability&apos; to 100%:Status=Con OR PS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lock_the_Record_True</fullName>
        <field>Lock_the_Record__c</field>
        <literalValue>1</literalValue>
        <name>Update Lock the Record =True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Program Contracted or Pending Sig</fullName>
        <actions>
            <name>Set_Probability_to_100_on_Contract</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Royall_Program__c.Status__c</field>
            <operation>equals</operation>
            <value>Contracted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Royall_Program__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending Signature</value>
        </criteriaItems>
        <description>Program (R) - This rule automatically updates the field &apos;PROBABILITY&apos; to = &quot;100%&quot; when &apos;STATUS&apos; = &quot;Contracted&quot; OR &quot;Pending Signature&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Program Declined</fullName>
        <actions>
            <name>Set_Probability_to_0_on_Declined</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Royall_Program__c.Status__c</field>
            <operation>equals</operation>
            <value>Declined</value>
        </criteriaItems>
        <description>Triggers updates when a program is declined</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Lock the Record when Status %3D Contracted</fullName>
        <actions>
            <name>Update_Lock_the_Record_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Royall_Program__c.Status__c</field>
            <operation>equals</operation>
            <value>Contracted</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
