<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Auto_Populate_Bundle_Name</fullName>
        <description>Field update to auto populate bundle name field with combination of values.</description>
        <field>Name</field>
        <formula>&apos;Bundle - &apos; 
&amp;
LEFT(Account__r.Name, 40)
&amp;  
&apos; - &apos;
&amp;
IF(Open_Count__c == 0, &quot;Closed&quot;, &quot;Open&quot;)
&amp; 
&apos; - &apos;
&amp;
TEXT(YEAR(DATEVALUE(CreatedDate))) 
&amp; 
&apos;.&apos;
&amp; 
TEXT(MONTH(DATEVALUE(CreatedDate))) 
&amp; 
&apos;.&apos;
&amp; 
TEXT(DAY(DATEVALUE(CreatedDate))) 
&amp; 
&apos; - &apos;
&amp;
Bundle_Number__c</formula>
        <name>FU_Auto_Populate_Bundle_Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>WF_Auto_Populate_Bundle_Name</fullName>
        <actions>
            <name>FU_Auto_Populate_Bundle_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Bundle__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Created for CR-5272 and will be responsible to populate the Bundle record name field with desired value.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
