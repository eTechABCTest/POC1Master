<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Name_update_PSS_Incentive_Credit</fullName>
        <description>&quot;PSS - &quot;&amp; Account__c &amp;&quot; - &quot;&amp; Program_del__r.Program_Acronym__c&amp;&quot; - &quot;&amp; $User.LastName&amp; &quot; - &quot; &amp; Text(ATL_Date__c)</description>
        <field>Name</field>
        <formula>&quot;PSS - &quot;&amp; Account__c &amp;&quot; - &quot;&amp;  Program__r.Program_Acronym__c &amp;&quot; - &quot;&amp; $User.LastName&amp; &quot; - &quot; &amp; Text(ATL_Date__c)</formula>
        <name>Name update PSS Incentive Credit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Populate name on Insert %28PSS Incentive Credit%29</fullName>
        <actions>
            <name>Name_update_PSS_Incentive_Credit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PSS_Incentive_Credit__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>New. When the PSS records are created.  The naming convention  PSS - [Account Name] - [Program Acronym] - [User Last] - [ATL Date] will be populated.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
