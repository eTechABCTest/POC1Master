<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Credit_Card_Transaction_Age_Warning_Limit</fullName>
        <description>Credit Card Transaction Age Warning Limit</description>
        <protected>false</protected>
        <recipients>
            <field>Portfolio_Owner__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Notice_to_Card_Holder_Approaching_Transaction_Age_Limit</template>
    </alerts>
    <alerts>
        <fullName>Nearing_Balance</fullName>
        <description>Nearing Balance</description>
        <protected>false</protected>
        <recipients>
            <field>Card_Holder__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Nearing_Balance</template>
    </alerts>
    <alerts>
        <fullName>Notice_Threshold_Amount_Warning_Limit</fullName>
        <description>Notice Threshold Amount Warning Limit</description>
        <protected>false</protected>
        <recipients>
            <field>Portfolio_Owner__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Notice_to_Card_Holder_Approaching_Credit_Limit</template>
    </alerts>
    <alerts>
        <fullName>Over_Age_Warning</fullName>
        <description>Over Age – Warning</description>
        <protected>false</protected>
        <recipients>
            <field>Card_Holder__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Over_Age_Warning</template>
    </alerts>
    <alerts>
        <fullName>Over_Balance_Warning_1</fullName>
        <description>Over Balance – Warning 1</description>
        <protected>false</protected>
        <recipients>
            <field>Card_Holder__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Over_Balance_Warning_1</template>
    </alerts>
    <alerts>
        <fullName>Over_Balance_Warning_2</fullName>
        <description>Over Balance – Warning 2</description>
        <protected>false</protected>
        <recipients>
            <field>Card_Holder__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Over_Balance_Warning_2</template>
    </alerts>
    <alerts>
        <fullName>Over_Balance_Warning_3</fullName>
        <description>Over Balance – Warning 3</description>
        <protected>false</protected>
        <recipients>
            <field>Card_Holder__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Over_Balance_Warning_3</template>
    </alerts>
    <fieldUpdates>
        <fullName>Deactivation_Reason_Over_Age</fullName>
        <field>Deactivation_Reason__c</field>
        <literalValue>Over Age Limit</literalValue>
        <name>Deactivation Reason Over Age</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Deactivation_Reason_Over_Balance</fullName>
        <field>Deactivation_Reason__c</field>
        <literalValue>Over Credit Balance Limit</literalValue>
        <name>Deactivation Reason Over Balance</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_PAName</fullName>
        <field>Name</field>
        <formula>&apos;Portfolio&apos; 
+ 
IF(
	NOT(ISBLANK(Card_Holder__c)),
	&apos; - &apos; + Card_Holder_Last_Name__c + IF(NOT(ISBLANK(Card_Holder_First_Name__c)), &apos;, &apos; + Card_Holder_First_Name__c, &apos;&apos;),
	&apos;&apos;
)</formula>
        <name>FU_PAName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_PortfolioBillingAddressUpdated</fullName>
        <field>Billing_Address_Updated__c</field>
        <literalValue>1</literalValue>
        <name>FU_PortfolioBillingAddressUpdated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Final_Warning_Balance</fullName>
        <field>Final_warning_Balance__c</field>
        <formula>TODAY() +  Advisory_Profile__r.Over_balance_Countdown_days__c</formula>
        <name>Populate Final Warning - Balance</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Nullify_Final_Warning_Aging</fullName>
        <field>Final_warning_Aging__c</field>
        <name>Nullify Final Warning Aging</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Nullify_Final_Warning_Balance</fullName>
        <field>Final_warning_Balance__c</field>
        <name>Nullify Final Warning Balance</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Nullify_Warning_Email_Status</fullName>
        <field>Warning_Email_Status__c</field>
        <name>Nullify Warning Email Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Portfolio_Status_Activated</fullName>
        <field>Status__c</field>
        <literalValue>Activated</literalValue>
        <name>Portfolio Status Activated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Deactivated</fullName>
        <field>Status__c</field>
        <literalValue>Deactivated</literalValue>
        <name>Status Deactivated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Warning_Email_Status_First_Warning_Sent</fullName>
        <field>Warning_Email_Status__c</field>
        <literalValue>First Warning Sent</literalValue>
        <name>Warning Email Status-First Warning Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Warning_Email_Status_Second_Warning_Sent</fullName>
        <field>Warning_Email_Status__c</field>
        <literalValue>Second Warning Sent</literalValue>
        <name>Warning Email Status-Second Warning Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Warning_Email_Status_Third_Warning_Sent</fullName>
        <field>Warning_Email_Status__c</field>
        <literalValue>Third Warning Sent</literalValue>
        <name>Warning Email Status-Third Warning Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Card Under Balance</fullName>
        <actions>
            <name>Portfolio_Status_Activated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( 	ISPICKVAL(Status__c, &apos;Deactivated&apos;),  	NOT(ISBLANK(Final_warning_Balance__c)),  	Utilized_Balance__c &lt;= 1 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Nearing Balance Warning 1</fullName>
        <actions>
            <name>Nearing_Balance</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify the card holder that they’re approaching the first warning threshold for balance utilization</description>
        <formula>AND( 	ISPICKVAL(Status__c, &apos;Activated&apos;), 	ISBLANK(Final_warning_Balance__c), 	Utilized_Balance__c &gt; Advisory_Profile__r.Over_balance_Warning_threshold_1__c, 	Utilized_Balance__c &lt;= Advisory_Profile__r.Over_balance_Warning_threshold_2__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Nearing Balance Warning 2</fullName>
        <actions>
            <name>Nearing_Balance</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify the card holder that they’re approaching the second warning threshold for balance utilization.</description>
        <formula>AND( 	ISPICKVAL(Status__c, &apos;Activated&apos;), 	ISBLANK(Final_warning_Balance__c), 	Utilized_Balance__c &gt; Advisory_Profile__r.Over_balance_Warning_threshold_2__c, 	Utilized_Balance__c &lt;= Advisory_Profile__r.Over_balance_Warning_threshold_3__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Nearing Balance Warning 3</fullName>
        <actions>
            <name>Nearing_Balance</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify the card holder that they’re approaching the third warning threshold for balance utilization.</description>
        <formula>AND( 	ISPICKVAL(Status__c, &apos;Activated&apos;), 	ISBLANK(Final_warning_Balance__c), 	Utilized_Balance__c &gt; Advisory_Profile__r.Over_balance_Warning_threshold_3__c, 	Utilized_Balance__c &lt;= 1 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Over Age Warning1</fullName>
        <actions>
            <name>Over_Age_Warning</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Warning_Email_Status_First_Warning_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Portfolio__c.Warning_Email_Status__c</field>
            <operation>equals</operation>
            <value>Send First Warning</value>
        </criteriaItems>
        <criteriaItems>
            <field>Portfolio__c.Status__c</field>
            <operation>equals</operation>
            <value>Activated</value>
        </criteriaItems>
        <description>This workflow rule is to check if the Email Warning Status is just updated to Send First Warning, send an email to Card Holder and update the Warning Status to email sent.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Over Age Warning2</fullName>
        <actions>
            <name>Over_Age_Warning</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Warning_Email_Status_Second_Warning_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Portfolio__c.Warning_Email_Status__c</field>
            <operation>equals</operation>
            <value>Send Second Warning</value>
        </criteriaItems>
        <criteriaItems>
            <field>Portfolio__c.Status__c</field>
            <operation>equals</operation>
            <value>Activated</value>
        </criteriaItems>
        <description>This workflow rule is to check if the Email Warning Status is just updated to Send Second Warning, send an email to Card Holder and update the Warning Status to email sent.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Over Age Warning3</fullName>
        <actions>
            <name>Over_Age_Warning</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Warning_Email_Status_Third_Warning_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Portfolio__c.Warning_Email_Status__c</field>
            <operation>equals</operation>
            <value>Send Third Warning</value>
        </criteriaItems>
        <criteriaItems>
            <field>Portfolio__c.Status__c</field>
            <operation>equals</operation>
            <value>Activated</value>
        </criteriaItems>
        <description>This workflow rule is to check if the Email Warning Status is just updated to Send Third Warning, send an email to Card Holder and update the Warning Status to email sent.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Over Balance Warning 1</fullName>
        <actions>
            <name>Over_Balance_Warning_1</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( 	ISPICKVAL(Status__c, &apos;Activated&apos;), 	NOT(ISNULL(Last_Over_Balance_Warning_Sent_On__c)), 	ISCHANGED(Last_Over_Balance_Warning_Sent_On__c), 	NOT(ISNULL(Over_balance_Countdown_days__c)), 	Over_balance_Countdown_days__c &gt; 1, 	Utilized_Balance__c &gt; 1 )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Over Balance Warning 2 and 3</fullName>
        <active>false</active>
        <formula>AND( 	ISPICKVAL(Status__c, &apos;Activated&apos;), 	NOT(ISBLANK(Final_warning_Balance__c)), 	Utilized_Balance__c &gt; 1 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Over_Balance_Warning_2</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Portfolio__c.Final_warning_Balance__c</offsetFromField>
            <timeLength>-41</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Over_Balance_Warning_3</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Portfolio__c.Final_warning_Balance__c</offsetFromField>
            <timeLength>-17</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Deactivation_Reason_Over_Balance</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Status_Deactivated</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Portfolio__c.Final_warning_Balance__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Over Balance Warning Final</fullName>
        <actions>
            <name>Over_Balance_Warning_3</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( 	ISPICKVAL(Status__c, &apos;Activated&apos;), 	NOT(ISNULL(Last_Over_Balance_Warning_Sent_On__c)), 	ISCHANGED(Last_Over_Balance_Warning_Sent_On__c), 	NOT(ISNULL(Over_balance_Countdown_days__c)), 	Over_balance_Countdown_days__c = 1, 	Utilized_Balance__c &gt; 1 )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reset Final warning %E2%80%93 Aging</fullName>
        <actions>
            <name>Nullify_Final_Warning_Aging</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Nullify_Warning_Email_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow is to reset the Final warning - Aging field when the Oldest transaction is under limit</description>
        <formula>AND( 	OR( 		NOT(ISBLANK(Final_warning_Aging__c)), 		NOT(ISPICKVAL(Warning_Email_Status__c, &apos;&apos;)) 	), 	ISCHANGED( Oldest_transaction__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reset Final warning %E2%80%93 Balance</fullName>
        <actions>
            <name>Nullify_Final_Warning_Balance</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow rule is to reset the Final warning – Balance field to null whenever the portfolio in under transaction limit</description>
        <formula>AND(NOT(ISBLANK(Final_warning_Balance__c)), Utilized_Balance__c &lt;= 1 )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_PortfolioBillingAddressUpdated</fullName>
        <actions>
            <name>FU_PortfolioBillingAddressUpdated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND ( 	OR ( 		ISCHANGED(Billing_Address_Line_1__c), 		ISCHANGED(Billing_Address_Line_2__c), 		ISCHANGED(Billing_Address_City__c), 		ISCHANGED(Billing_Address_State__c), 		ISCHANGED(Billing_Address_PostalCode__c) 	), 	IF(Billing_Address_Updated__c == true, false, true) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_ValidatePAName</fullName>
        <actions>
            <name>FU_PAName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(ISNEW(),ISCHANGED(Card_Holder__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
