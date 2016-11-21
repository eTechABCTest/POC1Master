<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_PopulateUniqueTransactionKey</fullName>
        <field>Unique_Transaction_Key__c</field>
        <formula>Credit_Card__r.Card_Number__c + &apos;-&apos; + MCC_Number__c + &apos;-&apos; + MCC_Group__c + &apos;-&apos; + Approval_Code__c + IF(ISNULL(Transaction_Date_Time__c ), &apos;&apos;, &apos;-&apos; + TEXT( Transaction_Date_Time__c ))</formula>
        <name>FU_PopulateUniqueTransactionKey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Cleared_TRUE</fullName>
        <field>Cleared__c</field>
        <literalValue>1</literalValue>
        <name>Set Cleared = TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Clear Transaction</fullName>
        <actions>
            <name>Set_Cleared_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear a transaction automatically if certain criteria are met</description>
        <formula>OR(   AND(Closed__c = TRUE,     OR(ISPICKVAL(Transaction_Status__c,&apos;Declined&apos;),       ISPICKVAL(Transaction_Status__c,&apos;Authorized&apos;)     )   ),   AND(ISPICKVAL(Transaction_Status__c,&apos;Posted&apos;),     VALUE(Posted_Amount__c) = 0) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_ValidateUniqueTransactionKey</fullName>
        <actions>
            <name>FU_PopulateUniqueTransactionKey</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>CR-20140414-5076.
This workflow rule is to populate the Unique Transaction Key field.</description>
        <formula>OR( 	ISNEW(), 	AND( 		ISCHANGED(Credit_Card__c), 		ISCHANGED(MCC_Number__c), 		ISCHANGED(MCC_Group__c), 		ISCHANGED(Approval_Code__c), 		ISCHANGED(Transaction_Date_Time__c) 	) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
