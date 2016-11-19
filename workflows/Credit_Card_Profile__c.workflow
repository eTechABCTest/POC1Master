<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_CCPName</fullName>
        <field>Name</field>
        <formula>Case(
	RecordType.Name,
	&apos;Staff Payment Account Profile&apos;, &apos;PP-&apos;+ Profile_Group_Number__c,
	&apos;CCP-&apos;+ Profile_Group_Number__c
)</formula>
        <name>FU_CCPName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
