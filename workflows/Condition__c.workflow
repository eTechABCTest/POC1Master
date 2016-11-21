<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Rename_Condition</fullName>
        <field>Name</field>
        <formula>LEFT(
TEXT(Condition_Type__c) + &apos; - &apos; +  RecordType.Name + &apos; : &apos; +
IF(
	CONTAINS(RecordType.Name, &apos;Collection Perspective&apos;),
	IF(
		ISBLANK(Collection_Perspective__c),
		Individual_Program__r.Name,
		Collection_Perspective__r.Name
	),
	IF(
		CONTAINS(RecordType.Name, &apos;Assignment Role&apos;),
		Assignment_Role__r.Name,
		IF(
			CONTAINS(RecordType.Name, &apos;Institution&apos;),
			Institution__r.Account_Formal_Name__c,
			IF(
				CONTAINS(RecordType.Name, &apos;Relationship&apos;),
				IF(
					ISBLANK(To_Relationship__c),
					From_Relationship__r.Name,
					To_Relationship__r.Name
				),
				IF(
					CONTAINS(RecordType.Name, &apos;Renewal Type&apos;),
					TEXT(Agreement_Type__c),
					IF(
						CONTAINS(RecordType.Name, &apos;Activity Date&apos;),
						TEXT(Date_Type__c) + &apos; &apos; + TEXT(Start_Date__c) + &apos; - &apos; + TEXT(End_Date__c),
						IF(
							CONTAINS(RecordType.Name, &apos;Credit Type&apos;),
							Credit_Type__r.Name,
							IF(
								CONTAINS(RecordType.Name, &apos;Staff Member&apos;),
								Staff_Member__r.FirstName + &apos; &apos; +  Staff_Member__r.LastName ,
								&apos;&apos;
							)
						)
					)
				)
			)
		)
	)
), 80)</formula>
        <name>FU_Rename_Condition</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>WF_Rename_Condition</fullName>
        <actions>
            <name>FU_Rename_Condition</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Rename the record according to a fixed standard</description>
        <formula>True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
