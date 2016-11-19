<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Autopopulate_Project_Name</fullName>
        <field>Name</field>
        <formula>Institution__r.Name + &quot; - &quot; +  Institution__r.BillingCity + &quot; - &quot; +     Product__r.Program_Acronym__c</formula>
        <name>Autopopulate Project Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCC_Guidelines_Purchase_Date</fullName>
        <description>Captures Last Modified Date when Guidelines is activated</description>
        <field>CCC_Guidelines_Purchase_Date__c</field>
        <formula>$Profile.LastModifiedDate</formula>
        <name>CCC: Guidelines Purchase Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCC_OPPE_Purchase_Date</fullName>
        <description>Captures Last Modified date when OPPE purchased checkbox is checked for the first time</description>
        <field>CCC_OPPE_Purchase_Date__c</field>
        <formula>$Profile.LastModifiedDate</formula>
        <name>CCC: OPPE Purchase Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCC_Outpatient_Purchase_Date</fullName>
        <description>Captures Last Modified date when Outpatient purchased checkbox is checked for the first time</description>
        <field>CCC_Outpatient_Purchase_Date__c</field>
        <formula>$Profile.LastModifiedDate</formula>
        <name>CCC: Outpatient Purchase Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_PopulatePunctualityOfLoadsToTBD</fullName>
        <field>Punctuality_of_Loads__c</field>
        <literalValue>TBD</literalValue>
        <name>FU_PopulatePunctualityOfLoadsToTBD</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_SetPilotCounterToOne</fullName>
        <description>Created for CR-20140409-5018</description>
        <field>Pilot_Counter__c</field>
        <formula>1</formula>
        <name>FU_SetPilotCounterToOne</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Project_Name</fullName>
        <field>Project_Name_2__c</field>
        <formula>Institution__r.Name  &amp; &quot; - &quot; &amp;   Product__r.Name</formula>
        <name>Project Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_DateEnteredValueStream</fullName>
        <field>Date_Entered_Value_Stream__c</field>
        <formula>TODAY()</formula>
        <name>Update_DateEnteredValueStream</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CCC%3A Guidelines Purchase Date</fullName>
        <actions>
            <name>CCC_Guidelines_Purchase_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Project__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Crim/CRT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Project__c.Guidelines__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Project__c.CCC_Guidelines_Purchase_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Captures Last Modified date when Guidelines purchase checkbox is checked for the first time</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCC%3A OPPE Purchase Date</fullName>
        <actions>
            <name>CCC_OPPE_Purchase_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Project__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Crim/CRT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Project__c.OPPE__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Project__c.CCC_OPPE_Purchase_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Captures Last Modified date when OPPE purchase checkbox is checked for the first time</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCC%3A Outpatient Purchase Date</fullName>
        <actions>
            <name>CCC_Outpatient_Purchase_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Project__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Crim/CRT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Project__c.Outpatient__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Project__c.CCC_Outpatient_Purchase_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Captures Last Modified date when Outpatient purchase checkbox is checked for the first time</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Created Date not equal to Null</fullName>
        <actions>
            <name>Project_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Project__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Project Name to Member - Product</fullName>
        <actions>
            <name>Autopopulate_Project_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow will auto-populate the Project Number similiar to how the Project Name is populated (Member - Product)</description>
        <formula>ISNEW() ||  ( ISCHANGED(Institution__c ) || ISCHANGED( Product__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_PopulatePunctualityOfLoadsOnInsert</fullName>
        <actions>
            <name>FU_PopulatePunctualityOfLoadsToTBD</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Project__c.Punctuality_of_Loads__c</field>
            <operation>notEqual</operation>
            <value>TBD</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_UpdateDateEnteredValueStream</fullName>
        <actions>
            <name>Update_DateEnteredValueStream</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Project__c.Project_Phase__c</field>
            <operation>equals</operation>
            <value>5 - Value Stream</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_ValidatePilotCounter</fullName>
        <actions>
            <name>FU_SetPilotCounterToOne</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Project__c.Membership_Category__c</field>
            <operation>equals</operation>
            <value>Pilot</value>
        </criteriaItems>
        <criteriaItems>
            <field>Project__c.Pilot_Counter__c</field>
            <operation>notEqual</operation>
            <value>1</value>
        </criteriaItems>
        <description>Created for CR-20140409-5018</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
