<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Program_Fields_Edited</fullName>
        <ccEmails>rawalj@advisory.com</ccEmails>
        <description>Program Fields Edited</description>
        <protected>false</protected>
        <recipients>
            <recipient>sfadmin@advisory.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Program_Fields_Edited</template>
    </alerts>
    <fieldUpdates>
        <fullName>Program_Historical_Linker</fullName>
        <field>HiIstorical_Linker__c</field>
        <formula>Counter_ID__c</formula>
        <name>Program Historical Linker</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Program Edits</fullName>
        <actions>
            <name>Program_Fields_Edited</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify IS when changes are made to program acronym or applicable segments</description>
        <formula>OR( ISCHANGED( Program_Acronym__c ) , ISCHANGED( Applicable_Segments__c )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Program Historical Linker</fullName>
        <actions>
            <name>Program_Historical_Linker</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Program__c.HiIstorical_Linker__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
