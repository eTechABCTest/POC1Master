<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Event_Department_Subject</fullName>
        <field>Subject</field>
        <formula>CASE( External_LP_Id__c, 
null, TEXT(Event_Type__c) &amp; &quot; &quot; &amp; &quot;-&quot; &amp; &quot; &quot; &amp; Title__c, 
Title__c)</formula>
        <name>Event Department Subject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Event_Historical_Linker</fullName>
        <field>Historical_Linker__c</field>
        <formula>Counter_ID__c</formula>
        <name>Event Historical Linker</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Department Subject Auto-Populate</fullName>
        <actions>
            <name>Event_Department_Subject</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Event.RecordTypeId</field>
            <operation>equals</operation>
            <value>eTech Dev</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.Event_Type__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Auto-populate the subject for eTech Dev record types</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Event Historical Linker</fullName>
        <actions>
            <name>Event_Historical_Linker</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  DATEVALUE(CreatedDate) &gt; DATEVALUE(&quot;2011-07-13&quot;),  OR(  Historical_Linker__c=&quot;&quot; ,  Historical_Linker__c &lt;&gt; Counter_ID__c )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PSS Assignment Alert</fullName>
        <actions>
            <name>PSS_Assignment_Alert</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Event.PSS_Resource_Confirmed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.Event_Type__c</field>
            <operation>equals</operation>
            <value>In Person Visit</value>
        </criteriaItems>
        <description>(inactive) New. Alert OPP/PSS Team that a PSS Resource has been assigned</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Activity Type for Contact</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Event.RecordTypeId</field>
            <operation>equals</operation>
            <value>BI Marketing,CORE Marketing</value>
        </criteriaItems>
        <description>(inactive) New.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>PSS_Assignment_Alert</fullName>
        <assignedToType>owner</assignedToType>
        <description>This activity has been assigned a PSS Resource.  Please look at the Activity for the new information.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>PSS Assignment Alert</subject>
    </tasks>
</Workflow>
