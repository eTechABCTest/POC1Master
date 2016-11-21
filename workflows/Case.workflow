<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CaseReceived_TicketCreatedNotification</fullName>
        <description>Case Received/Ticket Created Notification</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>eTech_Dev_Triage_Cases_Support/Case_Received</template>
    </alerts>
    <alerts>
        <fullName>Case_Comment_Notice_to_Contact</fullName>
        <description>Case Comment Notice to Contact</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crimson_Community/Crimson_Case_Comment_Added_with_Comment</template>
    </alerts>
    <alerts>
        <fullName>Case_Comment_Notice_to_Contact_Tier1</fullName>
        <description>Case Comment Notice to Contact Tier1</description>
        <protected>false</protected>
        <recipients>
            <field>Tier_I_Support_Analyst__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crimson_Community/Crimson_Case_Comment_Added_Tier_I_Analyst_with_Comment</template>
    </alerts>
    <alerts>
        <fullName>Case_Comment_Notice_to_Contact_Tier2</fullName>
        <description>Case Comment Notice to Contact Tier2</description>
        <protected>false</protected>
        <recipients>
            <field>Tier_II_Support_Analyst_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crimson_Community/Crimson_Case_Comment_Added_Tier_II_Analyst_with_Comment</template>
    </alerts>
    <alerts>
        <fullName>Case_Comment_Notice_to_Crimson_Support_group</fullName>
        <ccEmails>CrimsonSupport@advisory.com</ccEmails>
        <description>Case Comment Notice to Crimson Support group</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Crimson_Community/Crimson_Case_Comment_Added_with_Comment</template>
    </alerts>
    <alerts>
        <fullName>Case_Deadline_Changed_Email_Alert</fullName>
        <description>Case: Deadline Changed Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Expert_Center/Case_Deadline_has_changed</template>
    </alerts>
    <alerts>
        <fullName>Crimson_Case_Transferred_to_Tier_2_Notify_Member_EA</fullName>
        <description>zzzCrimson: Case Transferred to Tier 2 (Notify Member) EA</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crimson_Community/Crimson_Case_transferred_to_Tier_II</template>
    </alerts>
    <alerts>
        <fullName>Crimson_Case_Transferred_to_Tier_2_Notify_Tier_2_EA</fullName>
        <description>Crimson: Case Transferred to Tier 2 (Notify Tier 2) EA</description>
        <protected>false</protected>
        <recipients>
            <field>Tier_II_Support_Analyst_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crimson_Community/Crimson_Case_transferred_to_Tier_II</template>
    </alerts>
    <alerts>
        <fullName>Crimson_Case_Updated_Modified_EA</fullName>
        <description>Crimson: Case Updated/Modified EA</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crimson_Community/Crimson_Case_Status_Update</template>
    </alerts>
    <alerts>
        <fullName>Crimson_Case_Updated_to_Solution_Provided_Status_EA</fullName>
        <description>Crimson: Case Updated to Solution Provided Status EA</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crimson_Community/Crimson_Case_Closed_Solution_Provided</template>
    </alerts>
    <alerts>
        <fullName>Crimson_New_Case_Created_EA</fullName>
        <description>Crimson: New Case Created EA</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crimson_Community/Crimson_Case_Creation_Notification_1</template>
    </alerts>
    <alerts>
        <fullName>Crimson_Update_to_Closed_Status_EA</fullName>
        <description>Crimson: Update to Closed Status EA</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crimson_Community/Crimson_Case_Closed_Solution_Provided</template>
    </alerts>
    <alerts>
        <fullName>EA_NOTIFICATION_ON_CLOSE_OF_WEBHELP_CASE</fullName>
        <description>EA NOTIFICATION ON CLOSE OF WEBHELP CASE</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ET_NOTIFICATION_ON_CLOSE_OF_WEBHELP_CASE</template>
    </alerts>
    <alerts>
        <fullName>Email_Case_Details_to_Creator</fullName>
        <description>Email Case Details to Creator</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Expert_Center_Case_Details</template>
    </alerts>
    <alerts>
        <fullName>case_contact_opsnew</fullName>
        <ccEmails>picsupport@advisory.com.abc.pic</ccEmails>
        <description>Case_Contact_OpsNew</description>
        <protected>false</protected>
        <recipients>
            <recipient>Member Operations Contact</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_External_Notification_of_New_CaseOps</template>
    </alerts>
    <alerts>
        <fullName>case_contact_unresolved</fullName>
        <description>Case_Contact_Unresolved</description>
        <protected>false</protected>
        <recipients>
            <recipient>Member Operations Contact</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>Alternate_Contact_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Source_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_External_Notification_Unresolved</template>
    </alerts>
    <alerts>
        <fullName>casecommentnoticetocrimsonsupportgroup</fullName>
        <ccEmails>CrimsonSupport@advisory.com.abc.pic</ccEmails>
        <description>Case Comment Notice to Crimson Support group</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Crimson_Community/Crimson_Case_Comment_Added_with_Comment</template>
    </alerts>
    <alerts>
        <fullName>ccf_case_contact_ops</fullName>
        <description>CCF_Case_Contact_Ops</description>
        <protected>false</protected>
        <recipients>
            <recipient>Member Operations Contact</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/CCF_PIC_External_Notification_of_New_Case_OP</template>
    </alerts>
    <fieldUpdates>
        <fullName>Case_Comment_Notify_Null</fullName>
        <field>Case_Comment_Notification__c</field>
        <name>Case Comment Notify Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Comment_Notify_Null_Tier1</fullName>
        <field>Case_Comment_Notification__c</field>
        <name>Case Comment Notification to Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_ExpertCtr_set_Urgent_Priority</fullName>
        <description>&quot;If Deadline is 6 or less days in the future, set priority to ‘Urgent&apos; &quot;</description>
        <field>Priority</field>
        <literalValue>Urgent</literalValue>
        <name>Case: ExpertCtr set Urgent Priority</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Owner_Queue_Transfer_FU</fullName>
        <field>Status</field>
        <literalValue>Transferred</literalValue>
        <name>Case Owner Queue Transfer FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Set_Status_when_Assigned</fullName>
        <field>Status</field>
        <literalValue>Assigned</literalValue>
        <name>Case: Set Status when Assigned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Substatus_set_to_null</fullName>
        <description>Created as part of CR-8705</description>
        <field>Sub_Status__c</field>
        <name>Case Substatus set to null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Last_Updated</fullName>
        <field>Date_Last_Updated__c</field>
        <formula>NOW()</formula>
        <name>Date Last Updated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ExpertCtr_set_Urgent_Priority</fullName>
        <description>Created from CR 5440 for Expert Center</description>
        <field>Priority</field>
        <literalValue>Urgent</literalValue>
        <name>ExpertCtr set Urgent Priority</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Tracking_to_be_checked_when_Initiative_T</fullName>
        <description>Used by Expert Center Team, created by CR 4926</description>
        <field>Tracking__c</field>
        <literalValue>1</literalValue>
        <name>Tracking to be checked when Initiative T</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Status_90_Closed</fullName>
        <field>Status</field>
        <literalValue>90-Closed</literalValue>
        <name>Update Case Status 90-Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Type_Application_Support</fullName>
        <description>set case to type applicaiton support</description>
        <field>Type</field>
        <literalValue>Application Support</literalValue>
        <name>Update Case Type: Application Support</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Type_IS_Dev</fullName>
        <field>Type</field>
        <literalValue>eTech Dev</literalValue>
        <name>Update Case Type: IS Dev</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Type_SFHelp</fullName>
        <field>Type</field>
        <literalValue>Salesforce Help</literalValue>
        <name>Update Case Type: SF Help</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Type_Workday_Integration</fullName>
        <field>Type</field>
        <literalValue>Workday Integration</literalValue>
        <name>Update Case Type: Workday Integration</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Requested_Completion_Date_FU</fullName>
        <description>Created as part of CR-8705</description>
        <field>Requested_Completion_Date__c</field>
        <formula>TODAY() + 8</formula>
        <name>Update Requested Completion Date FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CCF Case Contact - Ops</fullName>
        <actions>
            <name>ccf_case_contact_ops</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New,Awaiting Member Clarification,Pending Member Sign-Off</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Member_Support_Record_Type__c</field>
            <operation>equals</operation>
            <value>PIC Operations Issue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>contains</operation>
            <value>Cleveland Clinic</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Contact - Unresolved</fullName>
        <actions>
            <name>case_contact_unresolved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>contains</operation>
            <value>Unresolved</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case has been marked as Cancelled due to no member response.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Received%2FTicket Created Notification</fullName>
        <actions>
            <name>CaseReceived_TicketCreatedNotification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>eTech Support</value>
        </criteriaItems>
        <description>Email Sent to Contact submitting new Case with record type of eTech Support</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case%3A Deadline has changed</fullName>
        <actions>
            <name>Case_Deadline_Changed_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(  BEGINS( OwnerId ,&quot;005&quot;) ,  LastModifiedBy.Id &lt;&gt; OwnerId ,  NOT( ISNULL( PRIORVALUE( Deadline__c ) ) ) ,  ISCHANGED( Deadline__c )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case%3A Set Status when Assigned</fullName>
        <actions>
            <name>Case_Set_Status_when_Assigned</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When Assigned To is populated the status moves to Assigned.</description>
        <formula>AND( BEGINS( OwnerId  , &quot;005&quot;) ,  ISPICKVAL( Status , &quot;New Request&quot;)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Close Case After 72 Hours</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>80-Solution Provided</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>PT Support Request,PT Data Load</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Visible_in_Portal__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>When Status is changed to Solution Provided, wait 72 hours before updating the Status to Closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Case_Status_90_Closed</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>72</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Crimson%3A Case Comment Notice to Contact</fullName>
        <actions>
            <name>Case_Comment_Notice_to_Contact</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Case_Comment_Notify_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Runs when the Case Comment Notification field is updated</description>
        <formula>AND( 	ISCHANGED(Case_Comment_Notification__c), 	OR( 		RecordType.DeveloperName = &apos;PT_Support_Request&apos;, 		RecordType.DeveloperName = &apos;PT_Data_Load&apos; 	), 	Visible_in_Portal__c = true, 	ISPICKVAL(Contact.SIAM_Portal_Status__c, &apos;Active&apos;), 	NOT(  		ISPICKVAL($User.UserType, &apos;CspLitePortal&apos;)  	) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A Case Comment Notice to Crimson Support group</fullName>
        <actions>
            <name>Case_Comment_Notice_to_Crimson_Support_group</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>casecommentnoticetocrimsonsupportgroup</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Case_Comment_Notify_Null_Tier1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Notify CrimsonSupport@advisory.com.abc.pic when a new case comment is posted on an unassigned case. Created for CR-20151002-9295.</description>
        <formula>AND ( 	OR ( 		Owner:Queue.QueueName = &apos;Tier I Unassigned&apos;, 		Owner:Queue.QueueName = &apos;Unassigned Case&apos; 	), 	ISCHANGED(Case_Comment_Notification__c), 	OR (  		RecordType.DeveloperName = &apos;PT_Support_Request&apos;,  		RecordType.DeveloperName = &apos;PT_Data_Load&apos;  	),  	Visible_in_Portal__c = true,  	ISPICKVAL(Contact.SIAM_Portal_Status__c, &apos;Active&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A Case Comment Notice to Tier I Analyst</fullName>
        <actions>
            <name>Case_Comment_Notice_to_Contact_Tier1</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Case_Comment_Notify_Null_Tier1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created for  CR-20150206-8669</description>
        <formula>AND ( 	ISCHANGED(Case_Comment_Notification__c), 	 	OR ( 		 		RecordType.DeveloperName = &apos;PT_Support_Request&apos;, 		RecordType.DeveloperName = &apos;PT_Data_Load&apos; 	 	), 	Visible_in_Portal__c = true, 	ISPICKVAL(Contact.SIAM_Portal_Status__c, &apos;Active&apos;),  	Tier_MS__c = &apos;Tier I&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A Case Comment Notice to Tier II Analyst</fullName>
        <actions>
            <name>Case_Comment_Notice_to_Contact_Tier2</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Case_Comment_Notify_Null_Tier1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20150206-8669</description>
        <formula>AND ( 	 	ISCHANGED(Case_Comment_Notification__c), 	 	OR ( 		 		RecordType.DeveloperName = &apos;PT_Support_Request&apos;,                  		RecordType.DeveloperName = &apos;PT_Data_Load&apos;  	 	), 	Visible_in_Portal__c = true, 	ISPICKVAL(Contact.SIAM_Portal_Status__c, &apos;Active&apos;), 	Tier_MS__c = &apos;Tier II&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A Case Modified%2FUpdated</fullName>
        <actions>
            <name>Crimson_Case_Updated_Modified_EA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Created as part of CR-4283. Notify Member when Case Status is updated to ‘In Progress’ or to ‘Response Needed’ on a case that is Visible in Portal</description>
        <formula>AND( RecordType.Name = &quot;PT Data Load&quot; || RecordType.Name = &quot;PT Support Request&quot;, Visible_in_Portal__c = True, ISPICKVAL(Status, &quot;10-In Progress&quot;) || ISPICKVAL(Status, &quot;20-Response Needed&quot;), ISPICKVAL(Contact.SIAM_Portal_Status__c, &quot;Active&quot;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A Case Transferred to Tier 2 %28Notify Tier 2%29</fullName>
        <actions>
            <name>Crimson_Case_Transferred_to_Tier_2_Notify_Tier_2_EA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Created as part of CR-4283. Notify internal Technical Project Manager when a case is transferred to the Tier 2 support group.</description>
        <formula>AND( RecordType.Name = &quot;PT Data Load&quot; || RecordType.Name = &quot;PT Support Request&quot;, Tier_MS__c = &quot;Tier II&quot;, ISPICKVAL(Contact.SIAM_Portal_Status__c, &quot;Active&quot;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A New Case Created</fullName>
        <actions>
            <name>Crimson_New_Case_Created_EA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Created as part of CR-4283</description>
        <formula>AND( RecordType.Name = &quot;PT Data Load&quot; || RecordType.Name = &quot;PT Support Request&quot;, Visible_in_Portal__c == True)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A Update to Closed Status</fullName>
        <actions>
            <name>Crimson_Update_to_Closed_Status_EA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Created as part of CR-4283. Notify Member when Case Status is updated to ‘Closed’ on a case that is Visible in Portal.</description>
        <formula>AND( RecordType.Name = &quot;PT Data Load&quot; || RecordType.Name = &quot;PT Support Request&quot;, Visible_in_Portal__c = True, ISPICKVAL(Status, &quot;90-Closed&quot;), ISPICKVAL(Contact.SIAM_Portal_Status__c, &quot;Active&quot;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A Update to Solution Provided Status</fullName>
        <actions>
            <name>Crimson_Case_Updated_to_Solution_Provided_Status_EA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Created as part of CR-4283. Notify Member when Case Status is updated to ‘Solution Provided’ on a case that is Visible in Portal.</description>
        <formula>AND( RecordType.Name = &quot;PT Data Load&quot; || RecordType.Name = &quot;PT Support Request&quot;, Visible_in_Portal__c = True, ISPICKVAL(Status, &quot;80-Solution Provided&quot;), ISPICKVAL(Contact.SIAM_Portal_Status__c, &quot;Active&quot;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Case Details to Creator</fullName>
        <actions>
            <name>Email_Case_Details_to_Creator</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Email_Case_Details_to_Creator__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Rule for Email Case Details to Creator</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Etech%3A Queue Transfer</fullName>
        <actions>
            <name>Case_Owner_Queue_Transfer_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Case_Substatus_set_to_null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created as part of CR-8705</description>
        <formula>AND (  	OR ( 		RecordType.DeveloperName = &quot;eTech_Support&quot;,  		RecordType.DeveloperName=&quot;WebHelp&quot; 	),  	ISCHANGED(OwnerId),  	NOT(ISBLANK(Owner:Queue.Id))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Etech%3A Update Requested Completion Date</fullName>
        <actions>
            <name>Update_Requested_Completion_Date_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>eTech Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Transferred</value>
        </criteriaItems>
        <description>Created as part of CR-8705</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Ops Contact - New</fullName>
        <actions>
            <name>case_contact_opsnew</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Member_Support_Record_Type__c</field>
            <operation>equals</operation>
            <value>PIC Operations Issue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>Cleveland Clinic Health System</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case is created New.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Status - Update field %22Date Last Updated%22</fullName>
        <actions>
            <name>Date_Last_Updated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(ISCHANGED( Status ), ISCHANGED( Sub_Status__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Tracking to be checked when Initiative Tracking contains Tracking</fullName>
        <actions>
            <name>Tracking_to_be_checked_when_Initiative_T</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Case.Initiative_Tracking__c</field>
            <operation>contains</operation>
            <value>Tracking,tracking</value>
        </criteriaItems>
        <description>Used by Expert Center Team, created by CR 4926</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Case Type%3A Application Support</fullName>
        <actions>
            <name>Update_Case_Type_Application_Support</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email to Case: Application Support,Email to Case: SF Help,Email to Case: IS Dev</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Case Type%3A IS Dev</fullName>
        <actions>
            <name>Update_Case_Type_IS_Dev</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email to Case: IS Dev</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Case Type%3A SF Help</fullName>
        <actions>
            <name>Update_Case_Type_SFHelp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email to Case: SF Help</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Case Type%3A Workday Integration</fullName>
        <actions>
            <name>Update_Case_Type_Workday_Integration</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email to Case: Workday Integration</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_NOTIFICATION_ON_CLOSE_OF_WEBHELP_CASE</fullName>
        <actions>
            <name>EA_NOTIFICATION_ON_CLOSE_OF_WEBHELP_CASE</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>WebHelp</value>
        </criteriaItems>
        <description>Whenever a WebHelp case is closed, the sender will receive an email notification confirming this.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>zzzCase%3A ExpertCtr Urgent Deadline</fullName>
        <actions>
            <name>Case_ExpertCtr_set_Urgent_Priority</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>&quot;If Deadline is 6 or less days in the future, set priority to ‘Urgent&apos; &quot;</description>
        <formula>AND(      Num_Business_Days_to_Deadline__c &lt; 6,      NOT(ISPICKVAL(Origin, &quot;Member Priority&quot;))  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>zzzCase%3A ExpertCtr Urgent Deadline for Member Priority</fullName>
        <actions>
            <name>ExpertCtr_set_Urgent_Priority</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Created from CR 5440 for Expert Center</description>
        <formula>AND(      Num_Business_Days_to_Deadline__c &lt; 8,      ISPICKVAL(Origin , &quot;Member Priority&quot;)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>zzzCrimson%3A Case Transferred to Tier 2 %28Notify Member%29</fullName>
        <actions>
            <name>Crimson_Case_Transferred_to_Tier_2_Notify_Member_EA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Created as part of CR-4283.i.	Notify Member when a case marked as Visible in Portal is transferred to the Tier 2 support group.</description>
        <formula>AND( Visible_in_Portal__c = True, RecordType.Name = &quot;PT Data Load&quot; || RecordType.Name = &quot;PT Support Request&quot;, Tier_MS__c = &quot;Tier II&quot;, ISPICKVAL(Contact.SIAM_Portal_Status__c, &quot;Active&quot;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
