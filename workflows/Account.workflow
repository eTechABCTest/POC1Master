<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notification_of_Members_Joining_New_BI_Programs</fullName>
        <description>Notification of Members Joining New BI Programs</description>
        <protected>false</protected>
        <recipients>
            <recipient>PT - Chairman&apos;s Team</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>PT - Chief of Staff</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>PT - Leadership Team</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>PT - Marketer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>PT - Marketing Associate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>PT - Marketing Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>PT - Operations</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>PT - Partnership Associate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>PT - Partnership Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>PT - Product Marketing Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>PT - Team Lead</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Account Exec</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Account Management Associate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Chairman&apos;s Team</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Chief of Staff</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Dedicated Advisor</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Executive Advisor</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Growth Account Director</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Leadership Team</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Leadership Team/Cabinet</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Marketer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Marketing Associate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Marketing Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - New Member Associate</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Operations</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Product Marketing Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Relationship Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Notification_of_Members_Joining_New_BI_Programs</template>
    </alerts>
    <alerts>
        <fullName>Vendor_Approval_Approved</fullName>
        <description>Vendor Approval - Approved</description>
        <protected>false</protected>
        <recipients>
            <field>Submitted_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Process_Folder/Vendor_Approval_Email_Approved</template>
    </alerts>
    <alerts>
        <fullName>Vendor_Rejection_Email_Alert</fullName>
        <description>Vendor Rejection: Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Submitted_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Process_Folder/Vendor_Rejection_Email_Alert</template>
    </alerts>
    <fieldUpdates>
        <fullName>Account_Historical_Linker</fullName>
        <field>Historical_Linker__c</field>
        <formula>Counter_ID__c</formula>
        <name>Account Historical Linker</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Comment_Requested_Account</fullName>
        <field>Approval_Comment_Check__c</field>
        <literalValue>Requested</literalValue>
        <name>Approval Comment Requested (Account)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Comment_Required_Account</fullName>
        <field>Approval_Comment_Check__c</field>
        <literalValue>Required</literalValue>
        <name>Approval Comment Required (Account)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_PupulateAccountPlanLastUpdate</fullName>
        <description>Populate with current date</description>
        <field>Account_Plan_Last_Updated__c</field>
        <formula>TODAY()</formula>
        <name>FU_PupulateAccountPlanLastUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdateAccountOwner</fullName>
        <description>Upon account create/edit update the Account Owner to Salesforce Admin User</description>
        <field>OwnerId</field>
        <lookupValue>sfadmin@advisory.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>FU_UpdateAccountOwner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdateVendorAccountOwner</fullName>
        <description>Created for CR-20160922-10183</description>
        <field>OwnerId</field>
        <lookupValue>indigo@advisory.com.abc</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>FU_UpdateVendorAccountOwner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetStrategicAccountNameWithTopParent</fullName>
        <description>Update Strategic Account Name with Institution Top Parent</description>
        <field>Strategic_Account_Name__c</field>
        <formula>Top_Parent_Name_Text__c</formula>
        <name>SetStrategicAccountNameWithTopParent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Vendor_Approval_Status_Update</fullName>
        <field>Status__c</field>
        <literalValue>Approved - All Services</literalValue>
        <name>Vendor Approval: Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Vendor_Rejection_Status_Update</fullName>
        <field>Status__c</field>
        <literalValue>Prohibited</literalValue>
        <name>Vendor Rejection: Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Vendor_Update_Billing_City</fullName>
        <field>BillingCity</field>
        <formula>Primary_City__c</formula>
        <name>Vendor: Update Billing City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Vendor_Update_Billing_Country</fullName>
        <field>BillingCountry</field>
        <formula>TEXT(Primary_Country__c)</formula>
        <name>Vendor: Update Billing Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Vendor_Update_Billing_State_Province</fullName>
        <field>BillingState</field>
        <formula>TEXT(Primary_State_Province__c)</formula>
        <name>Vendor: Update Billing State/Province</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Vendor_Update_Billing_Street</fullName>
        <description>If Primary Address Lines 1, 2 and 3 are populated then we should add these as necessary to the Billing Street field.</description>
        <field>BillingStreet</field>
        <formula>IF(
NOT(ISBLANK(Primary_Address_Line_1__c)) &amp;&amp; NOT(ISBLANK(Primary_Address_Line_2__c)) &amp;&amp;
NOT(ISBLANK(Primary_Address_Line_3__c)),
Primary_Address_Line_1__c + &apos;, &apos; + Primary_Address_Line_2__c + &apos;, &apos; + Primary_Address_Line_3__c,
IF(
NOT(ISBLANK(Primary_Address_Line_1__c)) &amp;&amp; NOT(ISBLANK(Primary_Address_Line_2__c)),
Primary_Address_Line_1__c + &apos;, &apos; + Primary_Address_Line_2__c,
IF(
NOT(ISBLANK(Primary_Address_Line_1__c)),
Primary_Address_Line_1__c,
NULL)))</formula>
        <name>Vendor: Update Billing Street</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Vendor_Update_Billing_Zipcode</fullName>
        <field>BillingPostalCode</field>
        <formula>Primary_Postal_Code__c</formula>
        <name>Vendor: Update Billing Zipcode</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Account Historical Linker</fullName>
        <actions>
            <name>Account_Historical_Linker</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  DATEVALUE(CreatedDate) &gt; DATEVALUE(&quot;2011-07-13&quot;),  OR(  Historical_Linker__c=&quot;&quot; ,  Historical_Linker__c &lt;&gt; Counter_ID__c )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Account International Corp</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>International Corporate</value>
        </criteriaItems>
        <description>(inactive) New. Account Rec Type equals International Corp</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notification of Members Joining New BI Programs</fullName>
        <actions>
            <name>Notification_of_Members_Joining_New_BI_Programs</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>(inactive) New. Notify institution AM Team when a new BI program is joined</description>
        <formula>Ischanged(BI_Memberships__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Rejection Comment Flag %28Account%29</fullName>
        <actions>
            <name>Approval_Comment_Requested_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.Approval_Comment_Check__c</field>
            <operation>equals</operation>
            <value>Required</value>
        </criteriaItems>
        <description>require comment when rejecting an approval request on an institution</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SetStrategicAccountNameWithTopParent</fullName>
        <actions>
            <name>SetStrategicAccountNameWithTopParent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(ISNULL( Strategic_Account_Name__c), ISBLANK(Strategic_Account_Name__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Vendor%3A Populate BillingState Addresses</fullName>
        <actions>
            <name>Vendor_Update_Billing_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Vendor_Update_Billing_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Vendor_Update_Billing_State_Province</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Vendor_Update_Billing_Street</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Vendor_Update_Billing_Zipcode</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( RecordType.Name = &apos;Vendor&apos;, OR( NOT(ISBLANK(Primary_Address_Line_1__c)), NOT(ISBLANK(Primary_Address_Line_2__c)), NOT(ISBLANK(Primary_Address_Line_3__c)), NOT(ISBLANK(Primary_City__c)), NOT(ISBLANK(TEXT(Primary_State_Province__c))), NOT(ISBLANK(Primary_Postal_Code__c)), NOT(ISBLANK(TEXT(Primary_Country__c))), ISCHANGED(Primary_Address_Line_1__c), ISCHANGED(Primary_Address_Line_2__c), ISCHANGED(Primary_Address_Line_3__c), ISCHANGED(Primary_City__c), ISCHANGED(Primary_State_Province__c), ISCHANGED(Primary_Postal_Code__c), ISCHANGED(Primary_Country__c) ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_PopulateAccountPlanLastUpdated</fullName>
        <actions>
            <name>FU_PupulateAccountPlanLastUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Account plan last updated (date, populates via workflow field update to current day when the account plan detail field is updated)</description>
        <formula>AND(  	NOT(ISBLANK( Account_Plan_Detail__c )), 	NOT(ISNULL(Account_Plan_Detail__c )), 	ISCHANGED(Account_Plan_Detail__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_UpdateAccountOwner</fullName>
        <actions>
            <name>FU_UpdateAccountOwner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>User.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Vendor</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_UpdateVendorAccountOwner</fullName>
        <actions>
            <name>FU_UpdateVendorAccountOwner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Vendor</value>
        </criteriaItems>
        <description>Created for CR-20160922-10183</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
