<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>kickoff_batch</fullName>
        <ccEmails>contact_add_/_update@j-1tw14c4zivzfmtfmrp50ag9tjqnsmz86u0v7xmvtvkdz8co824.c-qhc4mao.c.apex.salesforce.com</ccEmails>
        <description>kickoff batch</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>IS_CRM/Contact_Update</template>
    </alerts>
    <rules>
        <fullName>Contact Add Update</fullName>
        <actions>
            <name>kickoff_batch</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact_Queue__c.Last_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
