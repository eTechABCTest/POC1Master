<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_Card_Holder_for_Activation_Request</fullName>
        <description>Alert Card Holder for Activation Request</description>
        <protected>false</protected>
        <recipients>
            <field>Card_Holder_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Credit_Card_Activated_Successfully</template>
    </alerts>
    <alerts>
        <fullName>Alert_Card_Holder_for_Activation_Request_Failed</fullName>
        <description>Alert Card Holder for Activation Request Failed</description>
        <protected>false</protected>
        <recipients>
            <field>Card_Requested_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Credit_Card_Activation_Failed</template>
    </alerts>
    <alerts>
        <fullName>Alert_Card_Owner_for_Deactivation_Request</fullName>
        <description>Alert Card Owner for Deactivation Request</description>
        <protected>false</protected>
        <recipients>
            <field>Card_Holder_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Credit_Card_Deactivated_Successfully</template>
    </alerts>
    <alerts>
        <fullName>Notify_User_Card_Re_activated_Successfully</fullName>
        <description>Notify User Card Re-activated Successfully</description>
        <protected>false</protected>
        <recipients>
            <field>Card_Holder_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Credit_Card_Re_activated_Successfully</template>
    </alerts>
    <alerts>
        <fullName>Over_Age_Deactivation</fullName>
        <description>Over Age – Deactivation</description>
        <protected>false</protected>
        <recipients>
            <field>Card_Holder_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Over_Age_Deactivation</template>
    </alerts>
    <alerts>
        <fullName>Over_Age_Reset</fullName>
        <description>Over Age – Reset</description>
        <protected>false</protected>
        <recipients>
            <field>Card_Holder_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Over_Age_Reset</template>
    </alerts>
    <alerts>
        <fullName>Over_Balance_Deactivation</fullName>
        <description>Over Balance – Deactivation</description>
        <protected>false</protected>
        <recipients>
            <field>Card_Holder_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Over_Balance_Deactivation</template>
    </alerts>
    <alerts>
        <fullName>Over_Balance_Reset</fullName>
        <description>Over Balance – Reset</description>
        <protected>false</protected>
        <recipients>
            <field>Card_Holder_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>creditcard@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Credit_Card_Admin/Over_Balance_Reset</template>
    </alerts>
    <fieldUpdates>
        <fullName>FU_CCName</fullName>
        <field>Name</field>
        <formula>&apos;Staff Card&apos; 
+ 
IF(
	NOT(ISBLANK(Payment_Account__c)),
	&apos; - &apos; + Payment_Account__r.Card_Holder_Last_Name__c + IF(NOT(ISBLANK(Payment_Account__r.Card_Holder_First_Name__c)), &apos;, &apos; + Payment_Account__r.Card_Holder_First_Name__c, &apos;&apos;),
	&apos;&apos;
)
+
IF(
	NOT(ISBLANK(Card_Counter__c)),
	&apos; - &apos; + RIGHT((&quot;0000&quot; + TEXT( Payment_Account__r.Card_Count__c + 1)), 4),
	&apos;&apos;
)</formula>
        <name>FU_CCName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdateCardEmployeeNumber</fullName>
        <field>Card_Employee_Number__c</field>
        <formula>Payment_Account__r.Portfolio_Owner_Finance_Code__c + &apos;X&apos; + IF( 
NOT(ISBLANK(Card_Counter__c)), 
RIGHT((&quot;00&quot; + TEXT(Payment_Account__r.Card_Count__c+1)), 2), 
&apos;&apos; 
) + 
IF (
    NOT(ISBLANK(Payment_Account__r.Card_Holder__r.Birthdate)),
        RIGHT((&quot;00&quot; + TEXT( DAY(Payment_Account__r.Card_Holder__r.Birthdate) )), 2) +
        CASE(MONTH( Payment_Account__r.Card_Holder__r.Birthdate ), 1, &quot;JAN&quot;, 2, &quot;FEB&quot;, 3, &quot;MAR&quot;,  4, &quot;APR&quot;,  5, &quot;MAY&quot;,  6, &quot;JUN&quot;, 7, &quot;JUL&quot;, 8, &quot;AUG&quot;, 9, &quot;SEP&quot;, 10, &quot;OCT&quot;, 11, &quot;NOV&quot;, 12, &quot;DEC&quot;, &quot;&quot;) +
        RIGHT((&quot;00&quot; + TEXT(YEAR(Payment_Account__r.Card_Holder__r.Birthdate))), 2),
        &apos;&apos;
)</formula>
        <name>FU_UpdateCardEmployeeNumber</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdateCardHolderEmail</fullName>
        <field>Card_Holder_Email__c</field>
        <formula>IF(
	NOT( ISNULL(Payment_Account__r.Card_Holder__c )) ,  
	Payment_Account__r.Card_Holder__r.Email , 
	null
)</formula>
        <name>FU_UpdateCardHolderEmail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Card_Expiration_Date</fullName>
        <field>Card_Expiration__c</field>
        <formula>DATE(YEAR(TODAY()) + 2, MONTH(TODAY()) + 1 ,1) - 1</formula>
        <name>Set Card Expiration Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Card Activation Failed</fullName>
        <actions>
            <name>Alert_Card_Holder_for_Activation_Request_Failed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( ISCHANGED(Card_Set_up_Status__c) ,  ISPICKVAL(PRIORVALUE(Card_Set_up_Status__c ), &apos;User Activated&apos;),  ISPICKVAL(Card_Set_up_Status__c ,&apos;Activation Failed&apos;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Card Activation Success</fullName>
        <actions>
            <name>Alert_Card_Holder_for_Activation_Request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(ISCHANGED(Status__c), ISPICKVAL(Status__c,&apos;Active&apos;), NOT(ISPICKVAL(PRIORVALUE(Status__c), &apos;Active&apos;)) , NOT(ISPICKVAL(PRIORVALUE(Card_Deactivation_Reason__c),&apos;Over Credit Limit&apos;)), NOT(ISPICKVAL(PRIORVALUE(Card_Deactivation_Reason__c),&apos;Over Transaction Age Limit&apos;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Card Deactivation Success</fullName>
        <actions>
            <name>Alert_Card_Owner_for_Deactivation_Request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Credit_Card__c.Status__c</field>
            <operation>equals</operation>
            <value>Deactivated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Credit_Card__c.Card_Deactivation_Status__c</field>
            <operation>equals</operation>
            <value>Deactivated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Credit_Card__c.Card_Deactivation_Reason__c</field>
            <operation>notEqual</operation>
            <value>Over Credit Limit,Over Transaction Age Limit</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Card Set Up Declined</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Credit_Card__c.Card_Set_up_Status__c</field>
            <operation>equals</operation>
            <value>Declined</value>
        </criteriaItems>
        <criteriaItems>
            <field>Credit_Card__c.Status__c</field>
            <operation>equals</operation>
            <value>Request Declined</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Over Age Deactivation</fullName>
        <actions>
            <name>Over_Age_Deactivation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Credit_Card__c.Status__c</field>
            <operation>equals</operation>
            <value>Deactivated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Credit_Card__c.Card_Deactivation_Status__c</field>
            <operation>equals</operation>
            <value>Deactivated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Credit_Card__c.Card_Deactivation_Reason__c</field>
            <operation>equals</operation>
            <value>Over Transaction Age Limit</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Over Age Reset</fullName>
        <actions>
            <name>Over_Age_Reset</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( 	ISCHANGED(Status__c),  	ISPICKVAL(Status__c,&apos;Active&apos;),  	NOT(ISPICKVAL(PRIORVALUE(Status__c), &apos;Active&apos;)) ,  	ISPICKVAL(PRIORVALUE(Card_Deactivation_Reason__c),&apos;Over Transaction Age Limit&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Over Balance Deactivation</fullName>
        <actions>
            <name>Over_Balance_Deactivation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Credit_Card__c.Status__c</field>
            <operation>equals</operation>
            <value>Deactivated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Credit_Card__c.Card_Deactivation_Status__c</field>
            <operation>equals</operation>
            <value>Deactivated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Credit_Card__c.Card_Deactivation_Reason__c</field>
            <operation>equals</operation>
            <value>Over Credit Limit</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Over Balance Reset</fullName>
        <actions>
            <name>Over_Balance_Reset</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( 	ISCHANGED(Status__c),  	ISPICKVAL(Status__c,&apos;Active&apos;),  	NOT(ISPICKVAL(PRIORVALUE(Status__c), &apos;Active&apos;)) ,  	ISPICKVAL(PRIORVALUE(Card_Deactivation_Reason__c),&apos;Over Credit Limit&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Card Employee Number</fullName>
        <actions>
            <name>FU_UpdateCardEmployeeNumber</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  	NOT( ISNULL(Payment_Account__c) ),  	ISBLANK(Card_Employee_Number__c) ) /*  &lt;&gt; Payment_Account__r.Portfolio_Owner_Finance_Code__c + &apos;X&apos; +  	IF(  		NOT(ISBLANK(Card_Counter__c)),  		RIGHT((&quot;0000&quot; + TEXT(Payment_Account__r.Card_Count__c)), 4),  		&apos;&apos;  	) )*/</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Card Holder Email Address</fullName>
        <actions>
            <name>FU_UpdateCardHolderEmail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(  	NOT( ISNULL( Payment_Account__c ) ) ,  	ISCHANGED(Payment_Account__c )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_NotifyUserCardBlocked_OverCreditLimit</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Credit_Card__c.Status__c</field>
            <operation>equals</operation>
            <value>Deactivated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Credit_Card__c.Card_Deactivation_Reason__c</field>
            <operation>equals</operation>
            <value>Over Credit Limit</value>
        </criteriaItems>
        <description>Runs when card is deactivated and deactivation reason is &apos;Over Credit Limit&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_ValidateCCName</fullName>
        <actions>
            <name>FU_CCName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
