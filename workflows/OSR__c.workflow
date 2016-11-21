<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_Card_Requestor_of_Card_Set_Up_Success</fullName>
        <description>Alert Card Requestor of Card Set Up Success</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Credit_Card_Set_Up_Successfully</template>
    </alerts>
    <alerts>
        <fullName>Alert_Card_Requestor_of_Deactivate_Card_Request</fullName>
        <description>Alert Card Requestor of Deactivate Card Request</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/ET_Notice_to_User_of_Card_Deactivated</template>
    </alerts>
    <alerts>
        <fullName>Alert_Finance_of_a_new_Card_Request</fullName>
        <description>Alert Finance of a new Card Request</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Notice_to_Finance_of_pending_OSR</template>
    </alerts>
    <alerts>
        <fullName>Credit_Card_Alert_notice_to_Card_Holder</fullName>
        <ccEmails>bennettj@advisory.com</ccEmails>
        <description>Credit Card Alert notice to Card Holder</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Notice_to_Card_Holder_of_a_new_Fraud_Alert</template>
    </alerts>
    <alerts>
        <fullName>Credit_Card_Alert_notice_to_Finance</fullName>
        <description>Credit Card Alert notice to Finance</description>
        <protected>false</protected>
        <recipients>
            <recipient>bennettj@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dohertym@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dowdl@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>majieda@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mandelbs@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Notice_to_Finance_Ayesha_of_a_new_Fraud_Alert</template>
    </alerts>
    <alerts>
        <fullName>Credit_Card_Decline_Alert_notice_to_Card_Holder</fullName>
        <description>Credit Card Decline Alert notice to Card Holder</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Notice_to_Card_Holder_of_Declined_transaction</template>
    </alerts>
    <alerts>
        <fullName>EA_EnhancedRiskMonitoringCardAlert</fullName>
        <description>EA_EnhancedRiskMonitoringCardAlert</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Decline_Active_Card_Enhanced_Risk_Monitoring</template>
    </alerts>
    <alerts>
        <fullName>EA_ExceededCreditLimitCardAlert</fullName>
        <description>EA_ExceededCreditLimitCardAlert</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Decline_Active_Card_Exceeded_Credit_Limit_Error</template>
    </alerts>
    <alerts>
        <fullName>EA_InvalidCVVCardAlert</fullName>
        <description>EA_InvalidCVVCardAlert</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Decline_Active_Card_Security_Code_Error</template>
    </alerts>
    <alerts>
        <fullName>EA_InvalidExpirationDateCardAlert</fullName>
        <description>EA_InvalidExpirationDateCardAlert</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Decline_Active_Card_Expiration_Date_Error</template>
    </alerts>
    <alerts>
        <fullName>EA_MerchantCodeMCCIssueCardAlert</fullName>
        <description>EA_MerchantCodeMCCIssueCardAlert</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Decline_Active_Card_MCC_Not_Available</template>
    </alerts>
    <alerts>
        <fullName>Notify_Travel_Updates_of_Card_Replacement_Deactivation_Error</fullName>
        <description>Notify Travel Updates of Card Replacement / Deactivation Error</description>
        <protected>false</protected>
        <recipients>
            <recipient>dohertym@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Notify_ABC_Travel_of_Replacement_Deactivation_Request_Failure</template>
    </alerts>
    <alerts>
        <fullName>Notify_to_Finance_Blocked_OSR_Created</fullName>
        <description>Notify to Finance Blocked OSR Created</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/ET_OverLimitOSRComplete</template>
    </alerts>
    <alerts>
        <fullName>OSR_Denied_Notification</fullName>
        <description>OSR Denied Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/OSR_Denied</template>
    </alerts>
    <fieldUpdates>
        <fullName>Assign_OSR_to_Card_Alert_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Card_Alert_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign OSR to Card Alert Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_OSR_to_Card_Request_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Card_Request_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign OSR to Card Request Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_OSRAddressUpdated</fullName>
        <field>Address_Updated__c</field>
        <literalValue>1</literalValue>
        <name>FU_OSRAddressUpdated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdateOSRSubject</fullName>
        <field>Subject__c</field>
        <formula>IF( CONTAINS(Alert_Summary__c , &apos;Fraud&apos;) , 
	&apos;Fraud Alert – ABC Credit Card&apos;,  
	IF( CONTAINS(Alert_Summary__c , &apos;Decline&apos;), 
		&apos;Decline Alert – ABC Credit Card&apos;, 
		&apos;Other Alert – ABC Credit Card&apos;
	) 
)</formula>
        <name>FU_UpdateOSRSubject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdateRequestTypeDeclineAlert</fullName>
        <field>Request_Type__c</field>
        <literalValue>Decline Alert</literalValue>
        <name>FU_UpdateRequestTypeDeclineAlert</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdateRequestTypeFraudAlert</fullName>
        <field>Request_Type__c</field>
        <literalValue>Fraud Alert</literalValue>
        <name>FU_UpdateRequestTypeFraudAlert</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdateRequestTypeOtherAlert</fullName>
        <field>Request_Type__c</field>
        <literalValue>Cancel ABC Credit Card</literalValue>
        <name>FU_UpdateRequestTypeOtherAlert</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Card Alert %E2%80%93 Decline Alert</fullName>
        <actions>
            <name>Credit_Card_Decline_Alert_notice_to_Card_Holder</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OSR__c.Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Request_Type__c</field>
            <operation>equals</operation>
            <value>Decline Alert</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Credit Card Alert</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Request_Reason__c</field>
            <operation>notEqual</operation>
            <value>Exceeded Credit Limit,Enhanced Risk Monitoring,Merchant Code / MCC Issue,Invalid Expiration Date,Invalid CVV</value>
        </criteriaItems>
        <description>Runs when a Card Alert OSR is created for a Declined Charge alert</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Card Alert %E2%80%93 Fraud</fullName>
        <actions>
            <name>Credit_Card_Alert_notice_to_Card_Holder</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Credit_Card_Alert_notice_to_Finance</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OSR__c.Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Request_Type__c</field>
            <operation>equals</operation>
            <value>Fraud Alert</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Credit Card Alert</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Card Alert to Finance - Decline</fullName>
        <active>true</active>
        <criteriaItems>
            <field>OSR__c.Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Request_Type__c</field>
            <operation>equals</operation>
            <value>Decline Alert</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Alert_Finance__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Credit Card Alert</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Request_Reason__c</field>
            <operation>notEqual</operation>
            <value>Exceeded Credit Limit,Enhanced Risk Monitoring,Merchant Code / MCC Issue,Invalid Expiration Date,Invalid CVV</value>
        </criteriaItems>
        <description>Runs when a Card Alert OSR for a Declined Charge is marked to also alert Finance</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Card Alert%2FRequest - Pending Finance</fullName>
        <actions>
            <name>Alert_Finance_of_a_new_Card_Request</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3) OR 4)</booleanFilter>
        <criteriaItems>
            <field>OSR__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Credit Card Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Request_Type__c</field>
            <operation>equals</operation>
            <value>Replacement ABC Credit Card,Replacement Meetings Payment Card,Cancel ABC Credit Card,Cancel Meetings Payment Card</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending Finance</value>
        </criteriaItems>
        <description>Runs when a Card Request OSR is updated to the Pending Finance status</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Card Deactivate Request</fullName>
        <actions>
            <name>Alert_Card_Requestor_of_Deactivate_Card_Request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OSR__c.Request_Type__c</field>
            <operation>equals</operation>
            <value>Cancel ABC Credit Card,Cancel Meetings Payment Card</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Status__c</field>
            <operation>equals</operation>
            <value>Complete</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Card Set Up Success</fullName>
        <actions>
            <name>Alert_Card_Requestor_of_Card_Set_Up_Success</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>OSR__c.Request_Type__c</field>
            <operation>equals</operation>
            <value>New ABC Credit Card,New Meetings Payment Card,Replacement ABC Credit Card,Replacement Meetings Payment Card</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Request_Type__c</field>
            <operation>equals</operation>
            <value>Replacement ABC Credit Card (Alternate Delivery)</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Status__c</field>
            <operation>equals</operation>
            <value>Complete</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>New Card Alert OSR Assignment</fullName>
        <actions>
            <name>Assign_OSR_to_Card_Alert_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OSR__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Credit Card Alert</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New Card Request OSR Assignment</fullName>
        <actions>
            <name>Assign_OSR_to_Card_Request_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OSR__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Credit Card Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>OSR Denied</fullName>
        <actions>
            <name>OSR_Denied_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OSR__c.Status__c</field>
            <operation>equals</operation>
            <value>Denied</value>
        </criteriaItems>
        <description>Created for CR-20150707-9062</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_CardAlertDecline</fullName>
        <actions>
            <name>FU_UpdateOSRSubject</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_UpdateRequestTypeDeclineAlert</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OSR__c.Alert_Summary__c</field>
            <operation>contains</operation>
            <value>Decline</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Credit Card Alert</value>
        </criteriaItems>
        <description>Update fields on OSR record when Alert_Summary__c contains &quot;Declined&quot;</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_CardAlertFraud</fullName>
        <actions>
            <name>FU_UpdateOSRSubject</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_UpdateRequestTypeFraudAlert</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OSR__c.Alert_Summary__c</field>
            <operation>contains</operation>
            <value>Fraud Alert</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Credit Card Alert</value>
        </criteriaItems>
        <description>Update fields on OSR record when Alert_Summary__c contains &quot;Fraud&quot;</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_CardAlertOther</fullName>
        <actions>
            <name>FU_UpdateOSRSubject</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_UpdateRequestTypeOtherAlert</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OSR__c.Alert_Summary__c</field>
            <operation>notContain</operation>
            <value>Decline</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Alert_Summary__c</field>
            <operation>notContain</operation>
            <value>Fraud</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Credit Card Alert</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Alert_Summary__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update fields on OSR record when Alert_Summary__c contains text, but not the words &apos;Fraud&apos; or &apos;Decline&apos;.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_EnhancedRiskMonitoringCardAlert</fullName>
        <actions>
            <name>EA_EnhancedRiskMonitoringCardAlert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OSR__c.Request_Type__c</field>
            <operation>equals</operation>
            <value>Decline Alert</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Request_Reason__c</field>
            <operation>equals</operation>
            <value>Enhanced Risk Monitoring</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Credit Card Alert</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_ExceededCreditLimitCardAlert</fullName>
        <actions>
            <name>EA_ExceededCreditLimitCardAlert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OSR__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Credit Card Alert</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Request_Reason__c</field>
            <operation>equals</operation>
            <value>Exceeded Credit Limit</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Request_Type__c</field>
            <operation>equals</operation>
            <value>Decline Alert</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_InvalidCVVCardAlert</fullName>
        <actions>
            <name>EA_InvalidCVVCardAlert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OSR__c.Request_Type__c</field>
            <operation>equals</operation>
            <value>Decline Alert</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Request_Reason__c</field>
            <operation>equals</operation>
            <value>Invalid CVV</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Credit Card Alert</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_InvalidExpirationDateCardAlert</fullName>
        <actions>
            <name>EA_InvalidExpirationDateCardAlert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OSR__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Credit Card Alert</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Request_Reason__c</field>
            <operation>equals</operation>
            <value>Invalid Expiration Date</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Request_Type__c</field>
            <operation>equals</operation>
            <value>Decline Alert</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_MerchantCodeMCCIssueCardAlert</fullName>
        <actions>
            <name>EA_MerchantCodeMCCIssueCardAlert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OSR__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Credit Card Alert</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Request_Reason__c</field>
            <operation>equals</operation>
            <value>Merchant Code / MCC Issue</value>
        </criteriaItems>
        <criteriaItems>
            <field>OSR__c.Request_Type__c</field>
            <operation>equals</operation>
            <value>Decline Alert</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_OSRAddressUpdated</fullName>
        <actions>
            <name>FU_OSRAddressUpdated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND ( 	OR ( 		ISCHANGED(Address_Line_1__c), 		ISCHANGED(Address_Line_2__c), 		ISCHANGED(Address_City__c), 		ISCHANGED(Address_State__c), 		ISCHANGED(Address_To_Name__c), 		ISCHANGED(Address_Postal_Code__c) 	), 	IF(Address_Updated__c == true, false, true) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
