<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ARP_Contact_First_Name_FU</fullName>
        <field>First_Name__c</field>
        <formula>Contact_id__r.FirstName</formula>
        <name>ARP: Contact First Name FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ARP_Contact_Last_Name_FU</fullName>
        <field>Last_Name__c</field>
        <formula>Contact_id__r.LastName</formula>
        <name>ARP: Contact Last Name FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ARP_Finance_ID_FU</fullName>
        <field>Finance_Id__c</field>
        <formula>Contact_id__r.Employee_User_Record__r.Finance_Code__c</formula>
        <name>ARP: Finance ID FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ARP_Populate_Name</fullName>
        <field>Name</field>
        <formula>Id</formula>
        <name>ARP: Populate Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ARP_Populate_Reference_Number</fullName>
        <field>Reference_Number__c</field>
        <formula>Contact_id__r.Employee_User_Record__r.Finance_Code__c + &quot;-&quot; +  TEXT(MONTH(DATEVALUE(Expense_Date__c)))+TEXT(DAY(DATEVALUE(Expense_Date__c)))+TEXT(YEAR(DATEVALUE(Expense_Date__c)))+ MID(TEXT(Expense_Date__c - 0.2083333333333333),12,8)+&quot;-&quot;+ TEXT(Points__c)</formula>
        <name>ARP: Populate Reference Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ARP%3A Populate Finance ID</fullName>
        <actions>
            <name>ARP_Contact_First_Name_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ARP_Contact_Last_Name_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ARP_Finance_ID_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ARP_Populate_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ARP_Populate_Reference_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(ISNEW() &amp;&amp; $Profile.Name != &quot;ABC Dataloader&quot; &amp;&amp; $User.Alias != &quot;SFADMIN&quot;) ||  ( ISCHANGED( Contact_id__c ) &amp;&amp; $Profile.Name != &quot;ABC Dataloader&quot; &amp;&amp; $User.Alias != &quot;SFADMIN&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
