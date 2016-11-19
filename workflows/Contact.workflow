<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Adv_com_New_User_Password_Config_Email</fullName>
        <description>Adv.com New User Password Config Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>webhelp@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Advisory_com_Templates/Adv_com_Welcome_Email</template>
    </alerts>
    <alerts>
        <fullName>Advisory_com_Email_Change_Notificatoin</fullName>
        <description>Advisory.com Email Change Notificatoin</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>webhelp@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Advisory_com_Templates/A_com_email_address_change</template>
    </alerts>
    <alerts>
        <fullName>Advisory_com_Password_Reset_Email</fullName>
        <description>Advisory.com Password Reset Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>webhelp@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Advisory_com_Templates/A_com_Password_Reset</template>
    </alerts>
    <fieldUpdates>
        <fullName>Contact_Change_Record_Type_for_a_com</fullName>
        <field>RecordTypeId</field>
        <lookupValue>External_Advisory_com_User</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Contact: Change Record Type for a.com</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contact_Historical_Linker</fullName>
        <field>Historical_Linker__c</field>
        <formula>Counter_ID__c</formula>
        <name>Contact Historical Linker</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contact_Set_Status_for_a_com_request</fullName>
        <field>Contact_Status__c</field>
        <literalValue>In Progress</literalValue>
        <name>Contact: Set Status for a.com request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_AdvisoryStatus_HardBounce</fullName>
        <description>Update the Advisory.com User Status field to Hard Bounce.</description>
        <field>Advisory_com_User_Status__c</field>
        <literalValue>Hard Bounce</literalValue>
        <name>FU_AdvisoryStatus_HardBounce</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_ContactPersonalAddressUpdated</fullName>
        <field>Personal_Address_Updated__c</field>
        <literalValue>1</literalValue>
        <name>FU_ContactPersonalAddressUpdated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_EloquaHardBounceEmail_Null</fullName>
        <description>Hard bounce email field is updated to null.</description>
        <field>Eloqua_Hard_Bounce_Email__c</field>
        <name>FU_EloquaHardBounceEmail_Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_EloquaStatus_HardBounce_Preferred</fullName>
        <description>Update the Contact&apos;s Eloqua Status to Hard Bounce - Preferred</description>
        <field>Eloqua_Status__c</field>
        <literalValue>Eloqua Hard Bounce - Preferred</literalValue>
        <name>FU_EloquaStatus_HardBounce_Preferred</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_EloquaStatus_HardBounce_Primary</fullName>
        <description>Update the Contact&apos;s Eloqua Status to Hard Bounce - Primary</description>
        <field>Eloqua_Status__c</field>
        <literalValue>Eloqua Hard Bounce - Primary</literalValue>
        <name>FU_EloquaStatus_HardBounce_Primary</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_EloquaStatus_Null</fullName>
        <description>Update the eloqua status to null.</description>
        <field>Eloqua_Status__c</field>
        <name>FU_EloquaStatus_Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Num_Undeliverable_Mailings_Null</fullName>
        <description>Update the # Undeliverable Mailings field on the Contact object to null.</description>
        <field>Num_Undeliverable_Mailings__c</field>
        <name>FU: Num Undeliverable Mailings Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdateEloquaEmailAddress</fullName>
        <field>Eloqua_Email_Address__c</field>
        <formula>IF( NOT( 
	ISBLANK( Advisory_com_Preferred_Email_Address__c ) 
    ) ,
    Advisory_com_Preferred_Email_Address__c ,
    Email 
)</formula>
        <name>FU_UpdateEloquaEmailAddress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Update_AdvComPreferredEmail</fullName>
        <description>Update the Advisory.com Preferred Email to null.</description>
        <field>Advisory_com_Preferred_Email_Address__c</field>
        <name>FU_Update_AdvComPreferredEmail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Next_Quarter_Start_Date_Populate</fullName>
        <field>Next_Quarter_Start_Date__c</field>
        <formula>IF( CEILING(MONTH(TODAY())/3) == 1, date(year(today()),04,01),
IF( CEILING(MONTH(TODAY())/3) == 2, date(year(today()),07,01),
IF( CEILING(MONTH(TODAY())/3) == 3, date(year(today()),10,01),
IF( CEILING(MONTH(TODAY())/3) == 4, date(year(today())+1,01,01),
null))))</formula>
        <name>Next Quarter Start Date Populate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Null_Send_Password_Notification_Picklist</fullName>
        <field>Advisory_com_Send_Password_Notification__c</field>
        <name>Null Send Password Notification Picklist</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Record_Type_Picklist</fullName>
        <field>Record_Type__c</field>
        <literalValue>US Provider</literalValue>
        <name>Record Type Picklist: US Provider</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Record_Type_Picklist_Standard</fullName>
        <field>Record_Type__c</field>
        <literalValue>HCIC</literalValue>
        <name>Record Type Picklist Standard</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reference_Availability_Reset_To_Avail</fullName>
        <description>Reset Reference Availability picklist fields to &apos;Available&apos; on each next quarter first day when its value changed to &apos;Quota Reached&apos;</description>
        <field>Reference_Availability__c</field>
        <literalValue>Available</literalValue>
        <name>Reference Availability Reset To Availabl</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Member_Verified_Date_to_Today</fullName>
        <field>Member_Verified_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Member Verified Date to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Contact Historical Linker</fullName>
        <actions>
            <name>Contact_Historical_Linker</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(   DATEVALUE(CreatedDate) &gt; DATEVALUE(&quot;2011-07-13&quot;), OR( Historical_Linker__c=&quot;&quot; , Historical_Linker__c &lt;&gt; Counter_ID__c ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Contact%3A Change Record Type for a%2Ecom</fullName>
        <actions>
            <name>Contact_Change_Record_Type_for_a_com</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Create_Advisory_com_User_Account__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.RecordTypeId</field>
            <operation>equals</operation>
            <value>External</value>
        </criteriaItems>
        <description>when Contact has an A.com user status, change record type to External - Advisory.com user.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Contact%3A Set Status for a%2Ecom request</fullName>
        <actions>
            <name>Contact_Set_Status_for_a_com_request</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.Create_Advisory_com_User_Account__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Set status to In Progress when Create Advisory.com User is checked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Function%3A HCICs</fullName>
        <actions>
            <name>Record_Type_Picklist_Standard</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>International HCIC,US HCIC</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Function%3A US Provider</fullName>
        <actions>
            <name>Record_Type_Picklist</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>US Provider</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Reference Availability Reset</fullName>
        <actions>
            <name>Next_Quarter_Start_Date_Populate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Reference_Availability__c</field>
            <operation>equals</operation>
            <value>Quota Reached</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Reference_Availability_Reset_To_Avail</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Contact.Next_Quarter_Start_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Send Email Change Notification</fullName>
        <actions>
            <name>Advisory_com_Email_Change_Notificatoin</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Null_Send_Password_Notification_Picklist</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When an existing adv.com user has their email address changed, send them a verification email.</description>
        <formula>ISPICKVAL( Advisory_com_Send_Password_Notification__c , &apos;Email Change&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send New User Password Config Email</fullName>
        <actions>
            <name>Adv_com_New_User_Password_Config_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Null_Send_Password_Notification_Picklist</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>When a new adv.com user is registered, send their new user password reset email.</description>
        <formula>ISPICKVAL( Advisory_com_Send_Password_Notification__c , &apos;New User&apos;) &amp;&amp; ( CONTAINS( &apos;Site Guest&apos;,  $User.LastName ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Password Reset Email</fullName>
        <actions>
            <name>Advisory_com_Password_Reset_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Null_Send_Password_Notification_Picklist</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>When adv.com user requests their password reset, send them an email</description>
        <formula>ISPICKVAL( Advisory_com_Send_Password_Notification__c , &apos;Password Reset&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_ContactPersonalAddressUpdated</fullName>
        <actions>
            <name>FU_ContactPersonalAddressUpdated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND ( 	RecordType.DeveloperName = &apos;Employee&apos;, 	OR ( 		ISCHANGED(Personal_Address_Line_1__c), 		ISCHANGED(Personal_Address_Line_2__c), 		ISCHANGED(Personal_Address_City__c), 		ISCHANGED(Personal_Address_State__c), 		ISCHANGED(Personal_Address_Country__c), 		ISCHANGED(Personal_Address_PostalCode__c), 		ISCHANGED(Personal_Address_Name__c) 	), 	NOT(Personal_Address_Updated__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_Eloqua_Status_Email_Update</fullName>
        <actions>
            <name>FU_EloquaHardBounceEmail_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_EloquaStatus_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Primary Email is changed and Eloqua Status = ‘Eloqua Hard Bounce - Primary’.  OR Adv.com Preferred Email is changed and Eloqua Status = ‘Eloqua Hard Bounce - Preferred’.
update the Eloqua Hard Bounce Email and Eloqua Status to null.</description>
        <formula>OR(     AND(         ISCHANGED( Email ),         ISPICKVAL(Eloqua_Status__c, &apos;Eloqua Hard Bounce - Primary&apos;)     ),     AND(         ISCHANGED(  Advisory_com_Preferred_Email_Address__c  ),         ISPICKVAL(Eloqua_Status__c, &apos;Eloqua Hard Bounce - Preferred&apos;)     ),     AND(         ISCHANGED( Eloqua_Hard_Bounce_Email__c ),         ISBLANK( Eloqua_Hard_Bounce_Email__c ),         NOT( ISPICKVAL( Eloqua_Status__c, &apos;&apos; ) )     ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_Eloqua_Status_Hard_Bounce_Preferred</fullName>
        <actions>
            <name>FU_EloquaStatus_HardBounce_Preferred</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_Update_AdvComPreferredEmail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the Eloqua Hard Bounce Email equals the Adv.com Preferred Email, update the eloqua status and remove the adv.com preferred email.</description>
        <formula>AND(     NOT( ISBLANK( Eloqua_Hard_Bounce_Email__c ) ),     Eloqua_Hard_Bounce_Email__c  == Advisory_com_Preferred_Email_Address__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_Eloqua_Status_Hard_Bounce_Primary</fullName>
        <actions>
            <name>FU_EloquaStatus_HardBounce_Primary</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the Eloqua Hard Bounce Email equals the Contact&apos;s Email, update the eloqua status to Hard Bounce - Primary.</description>
        <formula>AND(     NOT( ISBLANK( Eloqua_Hard_Bounce_Email__c ) ),     Eloqua_Hard_Bounce_Email__c  ==  Email)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_Eloqua_Status_Hard_Bounce_Primary_Adv_User</fullName>
        <actions>
            <name>FU_AdvisoryStatus_HardBounce</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_EloquaStatus_HardBounce_Primary</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the Eloqua Hard Bounce Email equals the Contact&apos;s Email, update the eloqua status to Hard Bounce - Primary and Advisory.com User Status = Hard Bounce.</description>
        <formula>AND(     NOT( ISBLANK( Eloqua_Hard_Bounce_Email__c ) ),     Eloqua_Hard_Bounce_Email__c  ==  Email ,      Create_Advisory_com_User_Account__c == true )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_Eloqua_Status_Null</fullName>
        <actions>
            <name>FU_EloquaHardBounceEmail_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Eloqua Status changes to Null, update the Eloqua Hard Bounce Email to null.</description>
        <formula>AND(     ISCHANGED( Eloqua_Status__c ),     ISPICKVAL(Eloqua_Status__c, &apos;&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_UpdateAdvUserStatus</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Contact.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Contact_Status__c</field>
            <operation>contains</operation>
            <value>Inactive</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Create_Advisory_com_User_Account__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_UpdateEloquaEmailAddress</fullName>
        <actions>
            <name>FU_UpdateEloquaEmailAddress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Advisory_com_Email_Address__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_Update_Num_Undeliverable_Mailings</fullName>
        <actions>
            <name>FU_Num_Undeliverable_Mailings_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If any of the Primary Address fields on the Contact are updated when # Undeliverable Mailings is greater than 0, set the value back to null.</description>
        <formula>OR(      ISCHANGED( Primary_Address_Line_1__c ) ,      ISCHANGED( Primary_Address_Line_2__c ) ,      ISCHANGED( Primary_Address_Line_3__c ) ,      ISCHANGED( Primary_City__c ) ,      ISCHANGED( Primary_Country__c ) ,      ISCHANGED( Primary_Postal_Code__c ) ,      ISCHANGED( Primary_State_Province__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
