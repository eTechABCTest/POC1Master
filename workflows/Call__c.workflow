<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CCA_TR_A_Trainer_has_been_assigned_to_your_training_request</fullName>
        <ccEmails>cmrtt@advisory.com</ccEmails>
        <description>CCA TR: A Trainer has been assigned to your training request</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Assigned_Trainer__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crimson_Training_Requests/MI_CCA_TR_Trainer_has_been_assigned_to_your_training_request</template>
    </alerts>
    <alerts>
        <fullName>CCA_TR_Training_Request_Created_for_MEMBER_NAME</fullName>
        <ccEmails>cmrtt@advisory.com</ccEmails>
        <description>CCA TR: Training Request Created for &apos;MEMBER NAME&apos;</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crimson_Training_Requests/MI_CCA_TR_Training_Request_Created_for_MEMBER</template>
    </alerts>
    <alerts>
        <fullName>CMA_On_Site_E_mail_Distribution</fullName>
        <ccEmails>CMAOnsiteRecaps@advisory.com</ccEmails>
        <description>CMA On Site E-mail Distribution</description>
        <protected>false</protected>
        <recipients>
            <recipient>klingerm@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>oharat@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CMA_Email_Templates/CMA_Onsite_Details</template>
    </alerts>
    <alerts>
        <fullName>E_Mail_call_notes_to_creator</fullName>
        <description>E-Mail call notes to creator</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/E_Mail_call_notes_to_creator</template>
    </alerts>
    <alerts>
        <fullName>E_mail_Member_Interaction_Notes</fullName>
        <ccEmails>ccconsitenotes@advisory.com</ccEmails>
        <description>E-mail Member Interaction Notes</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/E_Mail_Member_Interaction_Notes</template>
    </alerts>
    <alerts>
        <fullName>Notify_requester_when_current_status_changed</fullName>
        <description>Notify requester when current status changed</description>
        <protected>false</protected>
        <recipients>
            <field>Requested_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Notify_requester_when_current_status_changed</template>
    </alerts>
    <alerts>
        <fullName>Ref_Req_Current_Status_set_as_Completed_EA</fullName>
        <description>Ref Req: Current Status set as Completed EA</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>shimpt@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Assigned_To__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Project_DA__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Reference_Call_Emails/Ref_Req_Current_Status_Completed</template>
    </alerts>
    <alerts>
        <fullName>Ref_Req_Current_Status_set_as_Scheduled_EA</fullName>
        <description>Ref Req: Current Status set as Scheduled EA</description>
        <protected>false</protected>
        <recipients>
            <recipient>shimpt@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Assigned_To__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Project_DA__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Reference_Call_Emails/Ref_Req_Current_Status_Scheduled</template>
    </alerts>
    <alerts>
        <fullName>Ref_Req_Notify_Assigned_To_of_new_Record</fullName>
        <description>Ref Req: Notify Assigned To of new Record</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Reference_Call_Emails/Ref_Req_Created_record_notify_Marketer</template>
    </alerts>
    <alerts>
        <fullName>Ref_Req_Notify_DA_of_record_creation</fullName>
        <description>Ref Req: Notify DA of record creation</description>
        <protected>false</protected>
        <recipients>
            <field>Project_DA__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Reference_Call_Emails/Ref_Req_Created_record_notify_DA</template>
    </alerts>
    <alerts>
        <fullName>Training_New</fullName>
        <description>Training New</description>
        <protected>false</protected>
        <recipients>
            <recipient>kempiakk@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mccoyn@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tembyd@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_Internal_Notifications_Training</template>
    </alerts>
    <alerts>
        <fullName>Training_Resubmitted</fullName>
        <description>Training Resubmitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>kempiakk@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mccoyn@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tembyd@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_Internal_Notifications_Training</template>
    </alerts>
    <fieldUpdates>
        <fullName>FU_CompletionDate</fullName>
        <field>Completion_Date__c</field>
        <formula>TODAY()</formula>
        <name>FU_CompletionDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Original_BA</fullName>
        <field>Original_BA__c</field>
        <formula>Member__r.Recurring_Business_Analyst__r.FirstName &amp; &apos;  &apos; &amp; Member__r.Recurring_Business_Analyst__r.LastName</formula>
        <name>Populate Original BA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Original_DA</fullName>
        <field>Original_DA__c</field>
        <formula>Member__r.Dedicated_Advisor__r.FirstName &amp; &apos; &apos; &amp;  Member__r.Dedicated_Advisor__r.LastName</formula>
        <name>Populate Original DA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ref_Req_Update_Opp_Owner_Email_FU</fullName>
        <description>Created as part of CR-3833</description>
        <field>Opportunity_Owner_Email__c</field>
        <formula>Related_Opportunity__r.Owner.Email</formula>
        <name>Ref Req: Update Opp Owner Email FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Crimson%3A E-mail CMA On Site Notes</fullName>
        <actions>
            <name>CMA_On_Site_E_mail_Distribution</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Onsite</value>
        </criteriaItems>
        <criteriaItems>
            <field>Call__c.E_mail_Notes_to_Crimson__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Call__c.Program__c</field>
            <operation>equals</operation>
            <value>BIPP - Crimson Market Advantage</value>
        </criteriaItems>
        <description>E-mail alerts sent to DAs, CMA leadership and the BA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Crimson- E-mail Member Interaction Notes</fullName>
        <actions>
            <name>E_mail_Member_Interaction_Notes</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Standard</value>
        </criteriaItems>
        <criteriaItems>
            <field>Call__c.E_mail_Notes_to_Crimson__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Call__c.Program__c</field>
            <operation>contains</operation>
            <value>BIPC</value>
        </criteriaItems>
        <description>E-mail alerts sent to DAs and the CCC on-site notes distribution list</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>E-Mail call creator when box is checked</fullName>
        <actions>
            <name>E_Mail_call_notes_to_creator</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call__c.Send_call_notes_to_my_E_Mail__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Member Interaction%3A Post Wire Documentation has been completed</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Call__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Trainer Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Call__c.Email_Pre_Wire_Documentation_Notes__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>CR-20120305-545</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Member Interaction%3A Trainer has been assigned to your training request</fullName>
        <actions>
            <name>CCA_TR_A_Trainer_has_been_assigned_to_your_training_request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Trainer Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Call__c.Assigned_Trainer__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Project__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCA</value>
        </criteriaItems>
        <description>CR-20120305-545</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Member Interaction%3A Training Request Created for %27MEMBER</fullName>
        <actions>
            <name>CCA_TR_Training_Request_Created_for_MEMBER_NAME</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Trainer Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Call__c.Submit_Training_Request__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Project__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCA,CMGA</value>
        </criteriaItems>
        <description>CR-20120305-545</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify requester when current status changed</fullName>
        <actions>
            <name>Notify_requester_when_current_status_changed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Created as part of CR 3694</description>
        <formula>AND(      Notify_Requester__c ,       AND(           NOT( ISNULL( Requested_By__c ) ) ,           NOT( ISBLANK( Requested_By__c ) )        ) ,        OR(            ISPICKVAL( Current_Status__c , &apos;2 - Additional Information Required&apos;) ,             IF( RecordType.DeveloperName  = &apos;Southwind_EL_Request&apos;,                  ISPICKVAL(Current_Status__c , &apos;10 - Completed&apos;),                   ISPICKVAL(Current_Status__c , &apos;7 - Completed&apos;)               )         ),         OR(             ISNEW() ,             ISCHANGED(Current_Status__c )          )   )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Project%3A Populate Original BA %26 DA</fullName>
        <actions>
            <name>Populate_Original_BA</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Original_DA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call__c.Project_Name__c</field>
            <operation>notEqual</operation>
            <value>NULL</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Ref Req%3A Current Status %3D Completed</fullName>
        <actions>
            <name>Ref_Req_Current_Status_set_as_Completed_EA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Reference Call</value>
        </criteriaItems>
        <criteriaItems>
            <field>Call__c.Current_Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>Created as part of CR-3833</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Ref Req%3A Current Status set as Scheduled</fullName>
        <actions>
            <name>Ref_Req_Current_Status_set_as_Scheduled_EA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Reference Call</value>
        </criteriaItems>
        <criteriaItems>
            <field>Call__c.Current_Status__c</field>
            <operation>equals</operation>
            <value>Scheduled</value>
        </criteriaItems>
        <description>Created as part of CR-3833</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Ref Req%3A Notify Assigned To</fullName>
        <actions>
            <name>Ref_Req_Notify_Assigned_To_of_new_Record</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Created as part of CR-3833</description>
        <formula>NOT(ISBLANK(Assigned_To__c)) || ISCHANGED (Assigned_To__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Ref Req%3A Notify DA</fullName>
        <actions>
            <name>Ref_Req_Notify_DA_of_record_creation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Reference Call</value>
        </criteriaItems>
        <description>Created as part of CR-3833. This email alert will notify the DA when the record is created.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Ref Req%3A Update Opp Owner Email</fullName>
        <actions>
            <name>Ref_Req_Update_Opp_Owner_Email_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created as part of CR-3833</description>
        <formula>NOT(ISBLANK(Related_Opportunity__c)) || ISCHANGED (Related_Opportunity__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Training Request - New</fullName>
        <actions>
            <name>Training_New</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call__c.Current_Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <description>CR-1223</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Training Request - Resubmitted</fullName>
        <actions>
            <name>Training_Resubmitted</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call__c.Current_Status__c</field>
            <operation>equals</operation>
            <value>Resubmitted</value>
        </criteriaItems>
        <description>CR-1223</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_CompletionDate</fullName>
        <actions>
            <name>FU_CompletionDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND 2) OR 3</booleanFilter>
        <criteriaItems>
            <field>Call__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Southwind EL Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Call__c.Current_Status__c</field>
            <operation>equals</operation>
            <value>10 - Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Call__c.Current_Status__c</field>
            <operation>equals</operation>
            <value>7 - Completed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
