<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>NBB_Name</fullName>
        <description>Updates NBB name with the correct naming convention as described in the workflow description.</description>
        <field>Name</field>
        <formula>&quot;NBB - &quot;&amp; Account__c &amp;&quot; - &quot;&amp; Program__r.Program_Acronym__c&amp;&quot; - &quot;&amp; $User.LastName&amp; &quot; - &quot; &amp; Text(ATL_Date__c)</formula>
        <name>NBB Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Populate name on Insert</fullName>
        <actions>
            <name>NBB_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>NBB__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>(inactive) New. When the NBB records are created.  The naming convention NBB - [Account Name] - [Program Acronym] - [User Last] - [ATL Date] will be populated.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
