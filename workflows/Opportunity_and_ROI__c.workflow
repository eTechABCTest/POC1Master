<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Member_Approved_Results_equals_True</fullName>
        <field>Member_Approved_Results__c</field>
        <literalValue>1</literalValue>
        <name>Member Approved Results equals True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Autoopulate Member Approved Results as true</fullName>
        <actions>
            <name>Member_Approved_Results_equals_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity_and_ROI__c.ROI_Member_Sign_Off_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>The field &quot;Member Approved Date&quot; will be set as true if the &quot;Value Opportunity Member Sign Off Date&quot; field is not null.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
