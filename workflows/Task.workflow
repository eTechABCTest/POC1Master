<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_AssignTestimonialField</fullName>
        <field>OwnerId</field>
        <lookupValue>schirmes@advisory.com.abc</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>FU_AssignTestimonialField</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Task_Populate_Subject</fullName>
        <field>Subject</field>
        <formula>TEXT( CreatedDate )  &amp; &quot; - &quot; &amp; TEXT(Event_Type__c) &amp; &quot; - &quot; &amp;  CreatedBy.FirstName &amp; &quot; &quot; &amp; CreatedBy.LastName</formula>
        <name>Task: Populate Subject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Task%3A Populate Subject</fullName>
        <actions>
            <name>Task_Populate_Subject</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>equals</operation>
            <value>Will Auto-Populate</value>
        </criteriaItems>
        <description>replace the &apos;Will Auto Populate&apos; value in the subject with the &quot;ActivityDate - ActivityType - WhatName - WhoName&quot;</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_AssignTestimonial</fullName>
        <actions>
            <name>FU_AssignTestimonialField</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>equals</operation>
            <value>Member Impact Story</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.RecordTypeId</field>
            <operation>equals</operation>
            <value>Testimonials</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
