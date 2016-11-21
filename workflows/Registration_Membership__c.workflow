<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Autoname_Registration_Membership</fullName>
        <field>Name</field>
        <formula>Rule__r.Program__r.Name</formula>
        <name>Autoname - Registration Membership</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Autoname - Registration Membership</fullName>
        <actions>
            <name>Autoname_Registration_Membership</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Autopopulate the Registration Membership Name (CR-5562)</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
