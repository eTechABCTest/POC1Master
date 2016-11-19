<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>IS_CR_Accomplishments</fullName>
        <field>Accomplishments__c</field>
        <formula>TEXT(Date__c) &amp;&quot;: &quot;&amp;Summary__c</formula>
        <name>IS CR Accomplishments</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Change_Request__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IS_CR_Blocking_Risk_Areas_Concerns</fullName>
        <field>Blocking_Issues_Challenges__c</field>
        <formula>TEXT(Date__c) &amp;&quot;: &quot;&amp;Summary__c</formula>
        <name>IS CR Blocking Risk Areas/Concerns</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Change_Request__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IS_CR_Changes_in_Scope</fullName>
        <field>Changes_in_Scope__c</field>
        <formula>TEXT(Date__c) &amp;&quot;: &quot;&amp;Summary__c</formula>
        <name>IS CR Changes in Scope</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Change_Request__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IS_CR_Next_Steps</fullName>
        <field>Next_Steps__c</field>
        <formula>TEXT(Date__c) &amp;&quot;: &quot;&amp;Summary__c</formula>
        <name>IS CR Next Steps</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Change_Request__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IS_CR_Risk_Areas_Concerns</fullName>
        <field>Risk_Areas_Concerns__c</field>
        <formula>TEXT(Date__c) &amp;&quot;: &quot;&amp;Summary__c</formula>
        <name>IS CR Risk Areas/Concerns</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Change_Request__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>IS CR Accomplishments</fullName>
        <actions>
            <name>IS_CR_Accomplishments</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>IS_Project_Checkin__c.Checkin_Type__c</field>
            <operation>equals</operation>
            <value>Accomplishments</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IS CR Blocking Issues%2FChallenges</fullName>
        <actions>
            <name>IS_CR_Blocking_Risk_Areas_Concerns</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>IS_Project_Checkin__c.Checkin_Type__c</field>
            <operation>equals</operation>
            <value>Blocking Issues/Challenges</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IS CR Changes in Scope</fullName>
        <actions>
            <name>IS_CR_Changes_in_Scope</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>IS_Project_Checkin__c.Checkin_Type__c</field>
            <operation>equals</operation>
            <value>Changes in Scope</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IS CR Next Steps</fullName>
        <actions>
            <name>IS_CR_Next_Steps</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>IS_Project_Checkin__c.Checkin_Type__c</field>
            <operation>equals</operation>
            <value>Next Steps</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IS CR Risk Areas%2FConcerns</fullName>
        <actions>
            <name>IS_CR_Risk_Areas_Concerns</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>IS_Project_Checkin__c.Checkin_Type__c</field>
            <operation>equals</operation>
            <value>Risk Areas/Concerns</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
