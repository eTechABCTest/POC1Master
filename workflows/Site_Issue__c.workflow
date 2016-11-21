<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CCC_Email_Technical_Communication_Request_to_Bruce_Corman</fullName>
        <description>CCC: Email Technical Communication Request to Bruce Corman</description>
        <protected>false</protected>
        <recipients>
            <recipient>trahana@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CCA_Email_Templates/CCA_Send_Defects_to_CCC_QA</template>
    </alerts>
    <alerts>
        <fullName>CCC_Idle_Member_Support_Ticket</fullName>
        <ccEmails>mcgloinc@advisory.com</ccEmails>
        <description>CCC: Idle Member Support Ticket</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CCA_Email_Templates/CCC_Idle_Member_Support</template>
    </alerts>
    <alerts>
        <fullName>CCC_Send_Defects_report_to_CCC_QA</fullName>
        <ccEmails>CCC.issues@advisory.com</ccEmails>
        <description>CCC: Send Defects report to CCC QA</description>
        <protected>false</protected>
        <recipients>
            <field>BA__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>DA__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CCA_Email_Templates/CCC_Send_Defects_to_CCC_QA</template>
    </alerts>
    <alerts>
        <fullName>CCC_Send_enhancements_request</fullName>
        <ccEmails>cccpmissues@advisory.com</ccEmails>
        <ccEmails>ccc-cases@advisory.com</ccEmails>
        <description>CCC: Send Enhancement Request Alerts</description>
        <protected>false</protected>
        <recipients>
            <recipient>agbekom@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CCA_Email_Templates/CCC_Send_Enhancement_Request_Alerts</template>
    </alerts>
    <alerts>
        <fullName>CCF_Case_Contact_Needs_Clarification</fullName>
        <ccEmails>contractmanagement@ccf.org</ccEmails>
        <description>CCF Case Contact - Needs Clarification</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/CCF_PIC_External_Notification_Need_Clarif</template>
    </alerts>
    <alerts>
        <fullName>CCF_Case_Contact_New</fullName>
        <ccEmails>contractmanagement@ccf.org</ccEmails>
        <description>CCF Case Contact - New</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/CCF_PIC_External_Notification_of_New_Case</template>
    </alerts>
    <alerts>
        <fullName>CCF_Case_Contact_Req_Approval</fullName>
        <ccEmails>contractmanagement@ccf.org</ccEmails>
        <description>CCF Case Contact - Req Approval</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/CCF_PIC_External_Notification_Need_Approval</template>
    </alerts>
    <alerts>
        <fullName>CCF_Case_Contact_Req_Signoff</fullName>
        <ccEmails>contractmanagement@ccf.org</ccEmails>
        <description>CCF Case Contact - Req Signoff</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/CCF_PIC_External_Notification_Need_Signoff</template>
    </alerts>
    <alerts>
        <fullName>CCF_ContractMaintenance_PendingSignoff</fullName>
        <ccEmails>contractmanagement@ccf.org</ccEmails>
        <description>CCF Case Contact - Contract Maintenance - Pending Member Sign-off</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_External_Notification_Member_Signoff_Contract_Maintenance</template>
    </alerts>
    <alerts>
        <fullName>CCF_Contract_Maintenance_Factors</fullName>
        <ccEmails>contractmanagement@ccf.org</ccEmails>
        <description>CCF Case Contact - Contract Maintenance - Awaiting Member Factors</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Assigned_To_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reported_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_External_Notification_New_Factors</template>
    </alerts>
    <alerts>
        <fullName>CCF_Contract_Maintenance_New</fullName>
        <ccEmails>contractmanagement@ccf.org</ccEmails>
        <description>CCF Case Contact - Contract Maintenance - New, Awaiting Member Clarification</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_External_Notification_New_Contract_Maintenance</template>
    </alerts>
    <alerts>
        <fullName>CCI_Data_Load_Status_Update</fullName>
        <description>CCI: Data Load Status Update</description>
        <protected>false</protected>
        <recipients>
            <field>BA__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Crimson_Data_Analyst__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>DA__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CCA_Email_Templates/CCI_Data_Load_Status_Change</template>
    </alerts>
    <alerts>
        <fullName>CCR_QA_Defect_Submission</fullName>
        <ccEmails>ccr-cases@advisory.com</ccEmails>
        <description>CCR QA Defect Submission</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CCA_Email_Templates/CCA_QA_Defect_Submission</template>
    </alerts>
    <alerts>
        <fullName>CMA_BA_Email_Alert</fullName>
        <description>CMA BA Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CCA_Email_Templates/New_Site_Issue_For_DA</template>
    </alerts>
    <alerts>
        <fullName>CMA_Data_Load_Migration_Complete</fullName>
        <description>CMA: Data Load/Migration Complete</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Dedicated_Advisor__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Production_Business_Analyst__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CMA_Email_Templates/CMA_Data_Load_Completion_Email</template>
    </alerts>
    <alerts>
        <fullName>CMA_Send_Defects_report_to_CMC_QA</fullName>
        <ccEmails>cma.issues@advisory.com</ccEmails>
        <description>CMA: Send Defects report to CMC QA</description>
        <protected>false</protected>
        <recipients>
            <field>BA__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>DA__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CMA_Email_Templates/CMA_Send_Defects_to_CMA_QA</template>
    </alerts>
    <alerts>
        <fullName>CMA_Send_Email_Update</fullName>
        <description>CMA: Send Email Update</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Assigned_To_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CMA_Email_Templates/CMA_Send_Email_Update</template>
    </alerts>
    <alerts>
        <fullName>CPM_Assigned_to_Edited</fullName>
        <description>CPM: Assigned to Edited</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/CPM_Member_Support_Updated</template>
    </alerts>
    <alerts>
        <fullName>Case_Contact_Cancelled1</fullName>
        <description>Case Contact - Cancelled1</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reported_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_External_Notification_Cancellation</template>
    </alerts>
    <alerts>
        <fullName>Case_Contact_Closed1</fullName>
        <description>Case Contact - Closed</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reported_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_External_Notification_Closed</template>
    </alerts>
    <alerts>
        <fullName>Case_Contact_New</fullName>
        <description>Case Contact - New</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Primary_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reported_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_External_Notification_of_New_Case</template>
    </alerts>
    <alerts>
        <fullName>Case_Contact_ReqApproval</fullName>
        <description>Case Contact - Req Approval</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reported_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_External_Notification_Need_Approval</template>
    </alerts>
    <alerts>
        <fullName>Case_Owner</fullName>
        <description>Internal Notification For Case Team</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reported_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Internal_Email_Templates/PIC_Internal_Notifications</template>
    </alerts>
    <alerts>
        <fullName>Case_Owner_ImpTask</fullName>
        <description>Internal Notification For Case Team - Implementation Tasks</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Internal_Email_Templates/PIC_Internal_Notifications</template>
    </alerts>
    <alerts>
        <fullName>Case_Owner_PIC_Pro</fullName>
        <description>PIC Pro Internal Notification For Case Team</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>drewryp@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_Internal_Notifications_PIC_Pro_Patrick</template>
    </alerts>
    <alerts>
        <fullName>Compass_New_Ticket_Created</fullName>
        <description>Compass: New Ticket Created</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Compass/Compass_Notify_Owner_that_record_has_been_created</template>
    </alerts>
    <alerts>
        <fullName>Contract_Maintenance_Factors</fullName>
        <description>Case Contact - Contract Maintenance - Awaiting Member Factors</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Assigned_To_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reported_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_External_Notification_New_Factors</template>
    </alerts>
    <alerts>
        <fullName>Contract_Maintenance_NewExternal</fullName>
        <description>Case Contact - Contract Maintenance - New</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Assigned_To_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Primary_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reported_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_External_Notification_New_Contract_MaintenanceExternal</template>
    </alerts>
    <alerts>
        <fullName>CrimsonForce_Auto_Confirmation</fullName>
        <description>CrimsonForce-Auto Confirmation</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Portal_CrimsonForce_Communications/CrimsonForce_Member_Support_Ticket_General</template>
    </alerts>
    <alerts>
        <fullName>Crimson_Member_Support_Uploaded</fullName>
        <description>Crimson: Member Support Uploaded</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Crimson_Data_Analyst__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Dedicated_Advisor__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Tester__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Watch_List_Contact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Member_Support_Email_Templates/Crimson_Member_Support_Updated</template>
    </alerts>
    <alerts>
        <fullName>Crimson_Member_Support_Uploaded_Record_Creator</fullName>
        <description>Crimson: Member Support Uploaded Record Creator</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Member_Support_Email_Templates/Crimson_Member_Support_Updated</template>
    </alerts>
    <alerts>
        <fullName>Crimson_Members_Support_Assigned_Email</fullName>
        <description>Crimson: Members Support Assigned Email</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Member_Support_Email_Templates/Crimson_Member_Support_Updated</template>
    </alerts>
    <alerts>
        <fullName>Defect_Support_Category_Listed</fullName>
        <description>Defect: Support Category Listed</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>muralia@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>varahram@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>BA__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>CCC_DA_BA_Pod_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Code_Reviewer__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Crimson_Data_Analyst__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>DA__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Engineer__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Tester__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Watch_List_Contact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Defect_Support_Category_Listed</template>
    </alerts>
    <alerts>
        <fullName>EA_Send_Defect_Email_To_CCR</fullName>
        <ccEmails>CCR.issues@advisory.com</ccEmails>
        <description>EA Send Defect Email To CCR</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Alert_Templates/ET_New_Defect</template>
    </alerts>
    <alerts>
        <fullName>EA_Send_Defect_Email_To_CPRM</fullName>
        <ccEmails>CPRM.issues@advisory.com</ccEmails>
        <description>EA Send Defect Email To CPRM</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Alert_Templates/ET_New_Defect</template>
    </alerts>
    <alerts>
        <fullName>EA_Send_Defect_Email_To_CRT</fullName>
        <ccEmails>crt@advisory.com</ccEmails>
        <description>EA Send Defect Email To CRT</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Alert_Templates/ET_New_Defect</template>
    </alerts>
    <alerts>
        <fullName>EA_Send_Enhancement_Request_Email_To_CCR</fullName>
        <ccEmails>CCR.issues@advisory.com</ccEmails>
        <description>EA Send Enhancement Request Email To CCR</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Alert_Templates/ET_New_Enhancement</template>
    </alerts>
    <alerts>
        <fullName>EA_Send_Enhancement_Request_Email_To_CPRM</fullName>
        <ccEmails>CPRM.issues@advisory.com</ccEmails>
        <description>EA Send Enhancement Request Email To CPRM</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Alert_Templates/ET_New_Enhancement</template>
    </alerts>
    <alerts>
        <fullName>EA_Send_Enhancement_Request_Email_To_CRT</fullName>
        <ccEmails>crt@advisory.com</ccEmails>
        <description>EA Send Enhancement Request Email To CRT</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Email_Alert_Templates/ET_New_Enhancement</template>
    </alerts>
    <alerts>
        <fullName>New_CMA_Data_Load_Migration_Record</fullName>
        <description>New CMA Data Load/Migration Record</description>
        <protected>false</protected>
        <recipients>
            <field>Dedicated_Advisor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CMA_Email_Templates/New_CMA_Data_Load_Migration_Record</template>
    </alerts>
    <alerts>
        <fullName>Ops_Critical_Case_Owner</fullName>
        <description>Internal Notification For Operations Review Critical (support ticket)</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reported_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/Ops_PIC_Internal_Notifications_Critical</template>
    </alerts>
    <alerts>
        <fullName>RMC_Case_Contact_Cancelled</fullName>
        <description>RMC Case Contact - Cancelled</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reported_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_External_Notification_Cancellation</template>
    </alerts>
    <alerts>
        <fullName>RMC_Case_Contact_Closed</fullName>
        <description>RMC Case Contact - Closed</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reported_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_External_Notification_Closed</template>
    </alerts>
    <alerts>
        <fullName>RMC_Case_Contact_Needs_Clarification</fullName>
        <description>RMC Case Contact - Needs Clarification</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reported_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_External_Notification_Need_Clarif</template>
    </alerts>
    <alerts>
        <fullName>RMC_Case_Contact_New</fullName>
        <description>RMC Case Contact - New</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reported_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_External_Notification_of_New_Case</template>
    </alerts>
    <alerts>
        <fullName>RMC_Case_Contact_Req_Approval</fullName>
        <description>RMC Case Contact - Req Approval</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reported_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_External_Notification_Need_Approval</template>
    </alerts>
    <alerts>
        <fullName>RMC_Case_Contact_Req_Signoff</fullName>
        <description>RMC Case Contact - Req Signoff</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reported_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_External_Notification_Need_Signoff</template>
    </alerts>
    <alerts>
        <fullName>RMC_Contract_Maintenance_Awaiting_New</fullName>
        <description>RMC Case Contact - Contract Maintenance - New, Awaiting Member Clarification</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Assigned_To_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reported_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_External_Notification_New_Contract_Maintenance</template>
    </alerts>
    <alerts>
        <fullName>RMC_Contract_Maintenance_Factors</fullName>
        <description>RMC Case Contact - Contract Maintenance - Awaiting Member Factors</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Assigned_To_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reported_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_External_Notification_New_Factors</template>
    </alerts>
    <alerts>
        <fullName>RMC_Contract_Maintenance_Pending_Member_Signed_off</fullName>
        <description>RMC Case Contact - Contract Maintenance - Pending Member Sign-off</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Assigned_To_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reported_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Delivery_PIC_Member_Email_Templates/PIC_External_Notification_Member_Signoff_Contract_Maintenance</template>
    </alerts>
    <alerts>
        <fullName>Send_Defects_to_CCC_QA</fullName>
        <ccEmails>cpm-cases@advisory.com</ccEmails>
        <description>Send Defects to CCC QA</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CCA_Email_Templates/CCA_QA_Defect_Submission</template>
    </alerts>
    <fieldUpdates>
        <fullName>Assigned_to_Contact_Email_Field_Update</fullName>
        <field>Assigned_To_Contact_Email__c</field>
        <formula>IF(  NOT( ISBLANK(Assigned_To_Contact__c) ),  Assigned_To_Contact__r.Email , &apos;&apos;)</formula>
        <name>Assigned to Contact Email Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCA_Status_as_Ticket_Became_Delayed</fullName>
        <description>CR-586</description>
        <field>Status_as_Ticket_Became_Delayed__c</field>
        <formula>TEXT (Status__c)</formula>
        <name>CCA: Status as Ticket Became Delayed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCC_Auto_update_Final_QA_Complete</fullName>
        <field>Final_QA_Complete__c</field>
        <formula>TODAY()</formula>
        <name>CCC: Auto-update Final QA Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCC_Auto_update_Ready_for_Testing_field</fullName>
        <field>Ready_for_Testing__c</field>
        <formula>TODAY()</formula>
        <name>CCC: Auto-update Ready for Testing field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCC_Populate_Smoke_Test_Complete_Date</fullName>
        <description>CR-498</description>
        <field>Smoke_Test_Complete__c</field>
        <formula>TODAY()</formula>
        <name>CCC: Populate Smoke Test Complete Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCC_Ready_for_Final_QA_Autopopulate</fullName>
        <description>CR-498</description>
        <field>Ready_for_Final_QA__c</field>
        <formula>TODAY()</formula>
        <name>CCC: Ready for Final QA Autopopulate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCC_Testing_Complete_Date_Autopopulate</fullName>
        <description>CR-498</description>
        <field>Testing_Complete__c</field>
        <formula>TODAY()</formula>
        <name>CCC: Testing Complete Date Autopopulate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Calculate_Cost_CSR</fullName>
        <description>Calculate Cost automatically from #Hrs</description>
        <field>Estimated_Cost__c</field>
        <formula>(Estimated_of_Hours__c) * (195.00)</formula>
        <name>Calculate Cost CSR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Compass_DateTime_Closed_Auto_Update</fullName>
        <field>Site_Issue_Close_Date__c</field>
        <formula>NOW()</formula>
        <name>Compass: Date-Time Closed Auto Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Compass_Update_FTP_ID</fullName>
        <field>FTP_ID__c</field>
        <formula>Compass_Support_Issue_Ticket__r.FTP_ID__c</formula>
        <name>Compass: Update FTP ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Compass_Update_IDN_Project_Key</fullName>
        <field>IDN_Project_Key__c</field>
        <formula>Compass_Support_Issue_Ticket__r.IDN_Project_Key__c</formula>
        <name>Compass: Update IDN Project Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Compass_Update_Member_SK</fullName>
        <field>Member_SK__c</field>
        <formula>Compass_Support_Issue_Ticket__r.Member_SK__c</formula>
        <name>Compass: Update Member SK</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Compass_Update_PCS_Project_Key</fullName>
        <description>Updates the PCS Project Key of the Implementation Ticket from the Support Issue Ticket</description>
        <field>PCS_Project_Key__c</field>
        <formula>Compass_Support_Issue_Ticket__r.PCS_Project_Key__c</formula>
        <name>Compass: Update PCS Project Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Consecutively_Delayed_Load</fullName>
        <description>Checked if load is consecutively delayed</description>
        <field>Consecutively_Delayed_Load__c</field>
        <literalValue>1</literalValue>
        <name>Consecutively Delayed Load</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Crimson_Count_of_Diagnostics_Sent</fullName>
        <field>Count_of_Diagnostics_Sent__c</field>
        <formula>Count_of_Diagnostics_Sent__c  + 1</formula>
        <name>Crimson: Count of Diagnostics Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Crimson_Diagnostics_Sent</fullName>
        <description>Records the date modified when status was changed to 6.5 - Diagnostics Sent to Member Manually (Automated) or 07- Diagnostics Sent - Awaiting Sign Off.</description>
        <field>Diagnostics_Sent__c</field>
        <formula>TODAY()</formula>
        <name>Crimson: Diagnostics Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Crimson_Diagnostics_Sign_Off_Received</fullName>
        <description>Records the date modified when status was changed to 09- Received Diagnostics Sign Off.</description>
        <field>Diagnostics_Sign_Off_Received__c</field>
        <formula>TODAY()</formula>
        <name>Crimson: Diagnostics Sign Off Received</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Crimson_Files_Received</fullName>
        <description>Records the date modified when status is changed to 04- Have All Files - Ready for Extract.</description>
        <field>Files_Received__c</field>
        <formula>TODAY()</formula>
        <name>Crimson: Files Received</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Crimson_Internal_Load_Complete</fullName>
        <description>Records the date modified when status is changed to 12- Ready for Smoke Test.</description>
        <field>Internal_Load_Complete__c</field>
        <formula>TODAY()</formula>
        <name>Crimson: Internal Load Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Crimson_Load_Review_Complete</fullName>
        <description>Records the date modified when status is changed to 17.5 - Testing Issues Addressed- Ready for Final QA.</description>
        <field>Load_Review_Complete__c</field>
        <formula>TODAY()</formula>
        <name>Crimson: Load Review Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Crimson_Moved_to_Production</fullName>
        <description>Records the date modified when status is changed to 21- Crosscheck Complete.</description>
        <field>Moved_to_Production__c</field>
        <formula>TODAY()</formula>
        <name>Crimson: Moved to Production</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Crimson_Portal_Generated_Issue_FU</fullName>
        <description>Created as part of CR-4283</description>
        <field>Portal_Generated_Issue__c</field>
        <literalValue>1</literalValue>
        <name>Crimson: Portal Generated Issue FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_IE_Team_MS_Date_Time_Closed</fullName>
        <description>Created for  CR-20151116-9383.</description>
        <field>Site_Issue_Close_Date__c</field>
        <formula>NOW()</formula>
        <name>FU_IE_Team_MS_Date_Time_Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_IE_Team_MS_Owners</fullName>
        <description>Created for CR-20151116-9383.</description>
        <field>OwnerId</field>
        <lookupValue>IE_Team_MS_Owners</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>FU_IE_Team_MS_Owners</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_MS_Update_Owner_CSupport_Issue_Que</fullName>
        <description>Created for the CR-20150728-9104.</description>
        <field>OwnerId</field>
        <lookupValue>Compass_Support_Issue_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>FU_MS_Update_ Owner_ CSupport_Issue_Que</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_PopulateOwnerWithCompassSupportIssueQ</fullName>
        <field>OwnerId</field>
        <lookupValue>Compass_Support_Issue_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>FU_PopulateOwnerWithCompassSupportIssueQ</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_PopulateRMSMemberWithTrue</fullName>
        <field>RMS_Member__c</field>
        <literalValue>1</literalValue>
        <name>FU_ PopulateRMSMemberWithTrue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdateMSOwnerToChrisSanford</fullName>
        <field>OwnerId</field>
        <lookupValue>Compass_Data_Analytics</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>UpdateMSOwnerToCompassDataAnalyticsQueue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_UpdateOwnerToRMSQueue</fullName>
        <field>OwnerId</field>
        <lookupValue>MS_Queue_7_USC_RMS</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>FU_ UpdateOwnerToRMSQueue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Update_Owner_Tier_II_Support</fullName>
        <description>Set the Member Support owner to Tier II Support</description>
        <field>OwnerId</field>
        <lookupValue>Tier_II_Support</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>FU_Update_Owner_Tier_II_Support</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Fogbugz_Date_Closed</fullName>
        <field>Site_Issue_Close_Date__c</field>
        <formula>NOW ()</formula>
        <name>Fogbugz: Date Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Fogbugz_Status_Mapping</fullName>
        <field>Status__c</field>
        <literalValue>06 - Issue Resolved - Ticket Closed</literalValue>
        <name>Fogbugz: Status Mapping</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Fogbugz_Update_Date_Time_Closed</fullName>
        <field>Site_Issue_Close_Date__c</field>
        <formula>NOW()</formula>
        <name>Fogbugz: Update Date/Time Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Internal_Initiative_Date_Closed_Autofil</fullName>
        <field>Site_Issue_Close_Date__c</field>
        <formula>NOW()</formula>
        <name>Internal Initiative: Date Closed Autofil</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Last_Data_Loaded</fullName>
        <description>Data loaded for the previous month or quarter</description>
        <field>Last_Data_Loaded__c</field>
        <formula>Project__r.Current_Data_Period_New__c</formula>
        <name>Last Data Loaded</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Load_Frequency</fullName>
        <field>Load_Frequency__c</field>
        <formula>Text(Project__r.Load_Frequency__c)</formula>
        <name>Load Frequency</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Portal_Status_Awaiting_CMS_Updat</fullName>
        <field>Member_Portal_Status__c</field>
        <literalValue>Awaiting CMS Update</literalValue>
        <name>Member Portal Status (Awaiting CMS Updat</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Portal_Status_Awaiting_Member_Ap</fullName>
        <field>Member_Portal_Status__c</field>
        <literalValue>Awaiting Member Approval</literalValue>
        <name>Member Portal Status (Awaiting Member Ap</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Portal_Status_Awaiting_Member_Cl</fullName>
        <field>Member_Portal_Status__c</field>
        <literalValue>Awaiting Member Clarification</literalValue>
        <name>Member Portal Status (Awaiting Member Cl</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Portal_Status_Cancelled</fullName>
        <field>Member_Portal_Status__c</field>
        <literalValue>Cancelled</literalValue>
        <name>Member Portal Status (Cancelled)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Portal_Status_Creation_of_Standa</fullName>
        <field>Member_Portal_Status__c</field>
        <literalValue>Creation of Standard Files in Progress</literalValue>
        <name>Member Portal Status (Creation of Standa</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Portal_Status_Duplicate_See_Par</fullName>
        <field>Member_Portal_Status__c</field>
        <literalValue>Duplicate, See Parent Case</literalValue>
        <name>Member Portal Status (Duplicate, See Par</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Portal_Status_Hold_Pending_Reso</fullName>
        <field>Member_Portal_Status__c</field>
        <literalValue>Hold: Pending Resolution to Another Case</literalValue>
        <name>Member Portal Status (Hold: Pending Reso</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Portal_Status_Pending</fullName>
        <field>Member_Portal_Status__c</field>
        <literalValue>Pending Start</literalValue>
        <name>Member Portal Status (Pending Start)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Portal_Status_Pending_Member_Sig</fullName>
        <field>Member_Portal_Status__c</field>
        <literalValue>Pending Member Signoff</literalValue>
        <name>Member Portal Status (Pending Member Sig</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Portal_Status_Progress</fullName>
        <field>Member_Portal_Status__c</field>
        <literalValue>In Progress</literalValue>
        <name>Member Portal Status (In Progress)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Portal_Status_Resolved</fullName>
        <field>Member_Portal_Status__c</field>
        <literalValue>Resolved</literalValue>
        <name>Member Portal Status (Resolved)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Portal_Status_Unresolved</fullName>
        <field>Member_Portal_Status__c</field>
        <literalValue>Unresolved</literalValue>
        <name>Member Portal Status (Unresolved)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Support_Case_IsClosed_True</fullName>
        <description>Updates Case IsClosed field to true.</description>
        <field>Case_IsClosed__c</field>
        <literalValue>1</literalValue>
        <name>Member Support Case IsClosed True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Support_Date_Time_Opened</fullName>
        <field>Site_Issue_Created_Date__c</field>
        <formula>NOW()</formula>
        <name>Member Support: Date/Time Opened</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Milliman_Sharing_Checkbox_Off</fullName>
        <field>Milliman_Sharing__c</field>
        <literalValue>0</literalValue>
        <name>Milliman Sharing - Checkbox Off</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Milliman_Sharing_Checkbox_On_FU</fullName>
        <field>Milliman_Sharing__c</field>
        <literalValue>1</literalValue>
        <name>Milliman Sharing - Checkbox On FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Next_Data_Upload_Expected_On_FU</fullName>
        <field>Next_Data_Upload_Expected_On2__c</field>
        <formula>Project__r.Next_Data_Upload_Expected_On__c</formula>
        <name>Next Data Upload Expected On FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QA_Analyst</fullName>
        <field>Tester__c</field>
        <lookupValue>thomasv@advisory.com.abc</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>QA Analyst</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Custom_SQL</fullName>
        <description>Updates Custom SQL Field in Member Support to reflect values from Project</description>
        <field>Custom_SQL__c</field>
        <formula>Project__r.Custom_SQL__c</formula>
        <name>Update Custom SQL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Notes_Implementation_and_Data</fullName>
        <field>Notes_Recurring_Data__c</field>
        <formula>Project__r.Notes_Implementation__c</formula>
        <name>Update Notes: Implementation and Data</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Owner_to_MS_Queue_1</fullName>
        <field>OwnerId</field>
        <lookupValue>MS_Queue_1_EBDI_NUBI</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Record Owner to MS Queue 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Owner_to_MS_Queue_2</fullName>
        <field>OwnerId</field>
        <lookupValue>MS_Queue_2_Intl_Spend_Surgery_ED</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Record Owner to MS Queue 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Owner_to_MS_Queue_3</fullName>
        <field>OwnerId</field>
        <lookupValue>MS_Queue_3_SP_Spend_SCI</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Record Owner to MS Queue 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Owner_to_MS_Queue_4</fullName>
        <field>OwnerId</field>
        <lookupValue>MS_Queue_4_USC</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Record Owner to MS Queue 4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Recurring_Notes_Field</fullName>
        <field>Notes_Recurring_Data__c</field>
        <formula>Project__r.CPM_Special_Considerations__c</formula>
        <name>Update Recurring Notes Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_the_Date_Time_Opened_field</fullName>
        <field>Site_Issue_Created_Date__c</field>
        <formula>NOW()</formula>
        <name>Update the “Date/Time Opened” field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Autopopulate CS Implementation off CS Support Issue</fullName>
        <actions>
            <name>Compass_Update_FTP_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Compass_Update_IDN_Project_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Compass_Update_Member_SK</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Compass_Update_PCS_Project_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This autopoulates several Implementation fields based off the Support Issue Ticket listed on the record.</description>
        <formula>( ( $RecordType.Name = &quot;Compass Implementation &amp; Support&quot; ) &amp;&amp; (NOT(ISNULL(Compass_Support_Issue_Ticket__c))) &amp;&amp; (ISPICKVAL( Compass_Support_Issue_Ticket__r.Support_Category__c , &quot;New Member Set-Up&quot;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCA- Update Status as Ticket Became Delayed</fullName>
        <actions>
            <name>CCA_Status_as_Ticket_Became_Delayed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.Total_Delay__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCC Data Load</value>
        </criteriaItems>
        <description>This workflow populates a field with the status of a record at the time when Total Delay = 1</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCC Fogbugz%3A Update Date%2FTime Closed</fullName>
        <actions>
            <name>Fogbugz_Update_Date_Time_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Defect / Enhancement Request,Product Issue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.FogBugz_Case_Closed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCC%3A Email Tech Comm Request to Bruce Corman</fullName>
        <actions>
            <name>CCC_Email_Technical_Communication_Request_to_Bruce_Corman</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Defect / Enhancement Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Support_Category__c</field>
            <operation>equals</operation>
            <value>Technical Communication Request</value>
        </criteriaItems>
        <description>When Defect/Enhancement Request, Category Technical Communication, is submitted an email will be sent to Bruce Corman.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCC%3A Final QA Complete</fullName>
        <actions>
            <name>CCC_Auto_update_Final_QA_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCC Data Load,CCC Deployment Support,Crimson Support Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>19- Final QA complete - Ready for Production,18.5 - Final QA Complete - DA Response Needed</value>
        </criteriaItems>
        <description>This workflow auto-updates this field with the current date when the Status is changed to &quot;19 – Final QA Compete – ready for production&quot; or &quot;18.5 Final QA Complete – DA Response Needed&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCC%3A Idle Member Support Ticket</fullName>
        <actions>
            <name>CCC_Idle_Member_Support_Ticket</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Site_Issue__c.Idle_Time__c</field>
            <operation>greaterOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>contains</operation>
            <value>CCC</value>
        </criteriaItems>
        <description>This workflow fires when a Member Support ticket has been idle for more than 2 days.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCC%3A Ready for Final QA</fullName>
        <actions>
            <name>CCC_Ready_for_Final_QA_Autopopulate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>08 - Ready for Migration</value>
        </criteriaItems>
        <description>CR-498</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCC%3A Send Defects to CCC QA</fullName>
        <actions>
            <name>Send_Defects_to_CCC_QA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(   Project__r.Product__r.Program_Acronym__c   = &quot;BIPM&quot;,   RecordType.Name  = &quot;Defect / Enhancement Request&quot; )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CCC%3A Testing Complete Date</fullName>
        <actions>
            <name>CCC_Testing_Complete_Date_Autopopulate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>07 - In Final QA</value>
        </criteriaItems>
        <description>CR-498</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCC%3A Update Ready for Testing</fullName>
        <actions>
            <name>CCC_Auto_update_Ready_for_Testing_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCC Data Load,CCC Deployment Support,Crimson Support Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>14- Passed to test - Smoke test complete</value>
        </criteriaItems>
        <description>This workflow auto-updates this field with the current date when the Status is changed to &quot;14 - Passed to Test - Smoke Test Complete&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCC- Email Defects to CCC QA</fullName>
        <actions>
            <name>CCC_Send_Defects_report_to_CCC_QA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR 5)</booleanFilter>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Defect / Enhancement Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Verified__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Support_Category__c</field>
            <operation>equals</operation>
            <value>Defect</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Project_Name__c</field>
            <operation>contains</operation>
            <value>BIPC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Project_Name__c</field>
            <operation>contains</operation>
            <value>CLIN</value>
        </criteriaItems>
        <description>Email Defects logged under Member Support Troubleshooting ticket to CCC QA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCC- Send Enhancement Request to CCC Product Management</fullName>
        <actions>
            <name>CCC_Send_enhancements_request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Defect / Enhancement Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Support_Category__c</field>
            <operation>equals</operation>
            <value>Enhancement Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Project_Name__c</field>
            <operation>contains</operation>
            <value>BIPC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Project_Name__c</field>
            <operation>contains</operation>
            <value>CLIN IN</value>
        </criteriaItems>
        <description>Send Enhancement request to CCC Product Management</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCC- Smoke Test Complete Autopopulate</fullName>
        <actions>
            <name>CCC_Populate_Smoke_Test_Complete_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>06 - In System Test</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCF Case Contact - Cancelled1</fullName>
        <actions>
            <name>Case_Contact_Cancelled1</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Resolution_Category__c</field>
            <operation>equals</operation>
            <value>Cancelled - No Member Response</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>equals</operation>
            <value>Cleveland Clinic Health System</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PHI_Compliant__c</field>
            <operation>equals</operation>
            <value>&quot;Yes, Content Reviewed&quot;</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case has been marked as Cancelled due to no member response.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCF Case Contact - Closed1</fullName>
        <actions>
            <name>Case_Contact_Closed1</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Resolved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Resolution_Category__c</field>
            <operation>equals</operation>
            <value>Completed - No Member Response</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>equals</operation>
            <value>Cleveland Clinic Health System</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PHI_Compliant__c</field>
            <operation>equals</operation>
            <value>&quot;Yes, Content Reviewed&quot;</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case has been marked as closed (from pending member sign-off) due to no member response.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCF Case Contact - Contract Maintenance Awaiting Factors</fullName>
        <actions>
            <name>CCF_Contract_Maintenance_Factors</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Awaiting Facility Specific Factors</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Contract Maintenance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>equals</operation>
            <value>Cleveland Clinic Health System</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case requires member clarification.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCF Case Contact - Contract Maintenance Awaiting Member Clarification</fullName>
        <actions>
            <name>CCF_Contract_Maintenance_New</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Contract Maintenance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>New,Awaiting Member Clarification</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>contains</operation>
            <value>Cleveland Clinic</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCF Case Contact - Contract Maintenance Pending Member Sign-off</fullName>
        <actions>
            <name>CCF_ContractMaintenance_PendingSignoff</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Contract Maintenance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Pending Member Sign-Off</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>equals</operation>
            <value>Cleveland Clinic Health System</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCF Case Contact - Needs Clarification</fullName>
        <actions>
            <name>CCF_Case_Contact_Needs_Clarification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Awaiting Member Clarification</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Customer Service Request,PIC Query Component,PIC Support Issue,PIC Enhancement,PIC Defect</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>contains</operation>
            <value>Cleveland Clinic Health System</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PHI_Compliant__c</field>
            <operation>equals</operation>
            <value>&quot;Yes, Content Reviewed&quot;</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case requires member clarification.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCF Case Contact - New</fullName>
        <actions>
            <name>CCF_Case_Contact_New</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Customer Service Request,PIC Query Component,PIC Support Issue,PIC Enhancement,PIC Defect</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>contains</operation>
            <value>Cleveland Clinic Health System</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PHI_Compliant__c</field>
            <operation>equals</operation>
            <value>&quot;Yes, Content Reviewed&quot;</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case is created New.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCF Case Contact - Req Approval</fullName>
        <actions>
            <name>CCF_Case_Contact_Req_Approval</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Awaiting Member Approval</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Customer Service Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>equals</operation>
            <value>Cleveland Clinic Health System</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PHI_Compliant__c</field>
            <operation>equals</operation>
            <value>&quot;Yes, Content Reviewed&quot;</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case requires approval (related to CSRs only).</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCF Case Contact - Req Signoff</fullName>
        <actions>
            <name>CCF_Case_Contact_Req_Signoff</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Pending Member Sign-Off</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Customer Service Request,PIC Query Component,PIC Support Issue,PIC Enhancement,PIC Defect</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>startsWith</operation>
            <value>Cleveland Clinic Health System</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PHI_Compliant__c</field>
            <operation>equals</operation>
            <value>&quot;Yes, Content Reviewed&quot;</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case requires member approval to close the case.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCI%3A Data Load Status Change</fullName>
        <actions>
            <name>CCI_Data_Load_Status_Update</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCI Data Load</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>12- Ready for Smoke Test,15- Testing in progress,18 - Ready for Final QA,22 - Crosscheck Complete,23 - Sent Email Update,20 - Final QA complete - Ready for Production,10- Running Internal Load</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCR QA Defect Submission</fullName>
        <actions>
            <name>CCR_QA_Defect_Submission</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(  Project__r.Product__r.Program_Acronym__c  = &quot;BICR&quot;,  RecordType.Name = &quot;Defect / Enhancement Request&quot; )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CMA Data Load%2FMigration%3A New Record</fullName>
        <actions>
            <name>New_CMA_Data_Load_Migration_Record</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CMA Data Load/Migration</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CMA Member Support BA Notification</fullName>
        <actions>
            <name>CMA_BA_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>02 - Awaiting BA response</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>18- Final QA Complete - BA Response Needed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CMA Data Load/Migration,CMA Initial Deployment Support,CMA Report Request,CMA Support Issue</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CMA%3A Data Load%2FMigration Completed</fullName>
        <actions>
            <name>CMA_Data_Load_Migration_Complete</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>22 - Production Migration Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CMA Data Load/Migration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Data_Load_Type__c</field>
            <operation>equals</operation>
            <value>Current</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Site_Issue_Created_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CMA- Email Defects to CMA QA</fullName>
        <actions>
            <name>CMA_Send_Defects_report_to_CMC_QA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email Defects logged under Member Support Troubleshooting ticket to CMA QA</description>
        <formula>AND (      $Organization.Id == &apos;00D6C0000000Yoc&apos;,      RecordType.Name == &apos;Defect / Enhancement Request&apos;,      Verified__c ,      ISPICKVAL( Support_Category__c, &apos;Defect&apos; ),      OR(           CONTAINS(Project_Name__c, &apos;BIPP&apos; ),          CONTAINS( Project_Name__c, &apos;Market Advantage&apos;  )     ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CMA- Notes- Long Text from Project to Member Support</fullName>
        <actions>
            <name>Update_Custom_SQL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Notes_Implementation_and_Data</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CMA Support Issue,CMA Data Load/Migration</value>
        </criteriaItems>
        <description>Drives the &apos;Notes: Implementation and Data&apos; field from Project to Member Support</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CMA- Send Email Update</fullName>
        <actions>
            <name>CMA_Send_Email_Update</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CMA Data Load/Migration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>20- Production Migration Complete</value>
        </criteriaItems>
        <description>Alert for BA to send email updates to the member data contacts</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CPM%3A Assigned To Edited</fullName>
        <actions>
            <name>CPM_Assigned_to_Edited</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( ($RecordType.Name = &quot;CPM Data Load&quot;  || $RecordType.Name = &quot;CPM Support Issue&quot;),  ISCHANGED( Assigned_To_Contact__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Calculate Cost CSR</fullName>
        <actions>
            <name>Calculate_Cost_CSR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Customer Service Request</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Capture Previous Data Loaded</fullName>
        <actions>
            <name>Last_Data_Loaded</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND 2 AND 3) OR (4 AND 5 AND 6) OR (7 AND 8 AND 9)</booleanFilter>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCA Data Load</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Data_Load_Type__c</field>
            <operation>equals</operation>
            <value>Current,Historical/Reload</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>&quot;10 - Closed, Member Notified&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CMA Data Load/Migration</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Data_Load_Type__c</field>
            <operation>equals</operation>
            <value>Current,Historical/Reload</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>22 - Production Migration Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CMA Initial Deployment Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Data_Load_Type__c</field>
            <operation>equals</operation>
            <value>Site Build</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>22 - Production Migration Complete,23 - Task completed</value>
        </criteriaItems>
        <description>Captures previous data loaded to displau expected completion date of previous month/quarter</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Contact - Cancelled</fullName>
        <actions>
            <name>Case_Contact_Cancelled1</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Resolution_Category__c</field>
            <operation>equals</operation>
            <value>Cancelled - Could not confirm,Cancelled - No Member Response</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>notEqual</operation>
            <value>Cleveland Clinic Health System</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PHI_Compliant__c</field>
            <operation>equals</operation>
            <value>&quot;Yes, Content Reviewed&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>notContain</operation>
            <value>Resurrection</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case has been marked as Cancelled due to no member response.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Contact - Closed</fullName>
        <actions>
            <name>Case_Contact_Closed1</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Resolved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Resolution_Category__c</field>
            <operation>equals</operation>
            <value>Completed - No Member Response</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>notEqual</operation>
            <value>Cleveland Clinic Health System</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PHI_Compliant__c</field>
            <operation>equals</operation>
            <value>&quot;Yes, Content Reviewed&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>notContain</operation>
            <value>Resurrection</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case has been marked as closed (from pending member sign-off) due to no member response.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Contact - Contract Maintenance Awaiting Factors</fullName>
        <actions>
            <name>Contract_Maintenance_Factors</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Awaiting Facility Specific Factors</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Contract Maintenance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>notEqual</operation>
            <value>Cleveland Clinic Health System</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PHI_Compliant__c</field>
            <operation>equals</operation>
            <value>&quot;Yes, Content Reviewed&quot;</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case requires member clarification.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Contact - Contract Maintenance New</fullName>
        <actions>
            <name>Contract_Maintenance_NewExternal</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Contract Maintenance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>notContain</operation>
            <value>resurrection</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>notContain</operation>
            <value>cleveland clinic</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PHI_Compliant__c</field>
            <operation>equals</operation>
            <value>&quot;Yes, Content Reviewed&quot;</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Contact - New</fullName>
        <actions>
            <name>Case_Contact_New</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Customer Service Request,PIC Query Component,PIC Support Issue,PIC Enhancement,PIC Defect</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>notEqual</operation>
            <value>Cleveland Clinic Health System</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PHI_Compliant__c</field>
            <operation>equals</operation>
            <value>&quot;Yes, Content Reviewed&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>notContain</operation>
            <value>Resurrection</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case is created New.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Contact - New PIC PRO</fullName>
        <actions>
            <name>Case_Owner_PIC_Pro</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Product_Solution__c</field>
            <operation>equals</operation>
            <value>PIC Pro</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case is created New.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Contact - Req Approval</fullName>
        <actions>
            <name>Case_Contact_ReqApproval</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Awaiting Member Approval</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Customer Service Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>notEqual</operation>
            <value>Cleveland Clinic Health System</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PHI_Compliant__c</field>
            <operation>equals</operation>
            <value>&quot;Yes, Content Reviewed&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>notContain</operation>
            <value>Resurrection</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case requires member approval to close the case.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Owner - CSR</fullName>
        <actions>
            <name>Case_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Customer Service Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Dedicated Advisor in Progress,Awaiting Member Notification,Engineering in Progress,Data Analyst In Progress,Requires Case Owner Clarification,Ops in Progress,Data Services Analyst Estimate Needed,Data Services Analyst Assignment Needed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Hold: Pending Resolution to Another Case,New,&quot;Completed, Pending Review&quot;,&quot;Member Approved, Awaiting Start&quot;,Hold: Task Owner Not in Progress,&quot;Estimate Completed, Pending Approval&quot;,Dedicated Advisor Review Requested,Data Analyst Review Requested</value>
        </criteriaItems>
        <description>Notification to Case Owner CSR is updated for review.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Owner - Contract Maintenance</fullName>
        <actions>
            <name>Case_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Contract Maintenance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>notEqual</operation>
            <value>New,Awaiting Member Clarification,Awaiting Facility Specific Factors,Pending Member Sign-Off,Cancelled,Closed</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Owner - Def%2FEnh</fullName>
        <actions>
            <name>Case_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Defect,PIC Enhancement</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Product Review Requested,Pending Member Sign-Off,Closed,Requires Case Owner Clarification,&quot;Completed, Pending Review&quot;</value>
        </criteriaItems>
        <description>Notification to Case Owner that Defect or Enhancement must be reviewed.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Owner - Ops</fullName>
        <actions>
            <name>Case_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Operations Issue</value>
        </criteriaItems>
        <description>Notification to Case Owner Ops</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Owner - Query Component</fullName>
        <actions>
            <name>Case_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Query Component</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>&quot;Completed, Pending Review&quot;,Rejected,Initial Development Complete,Requires Clarification,Approved</value>
        </criteriaItems>
        <description>Notification to Case Owner that the Query Component is updated for review.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Owner - Support Issue</fullName>
        <actions>
            <name>Case_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Support Issue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>notEqual</operation>
            <value>Ops Review Requested,New,Awaiting Member Clarification,Awaiting Member Approval,Pending Member Sign-Off,Closed,Cancelled,Resolved,Support Review in Progress</value>
        </criteriaItems>
        <description>Notification to Case Owner of Support Issue to review the case.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Owner - Support Issue %28Ops not Critical%29</fullName>
        <actions>
            <name>Case_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Support Issue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Ops Review Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Site_Issue_Priority__c</field>
            <operation>notEqual</operation>
            <value>Critical</value>
        </criteriaItems>
        <description>Notification to Case Owner of Support Issue to review the case.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Owner - Support Ops Review Requested %28Critical%29</fullName>
        <actions>
            <name>Ops_Critical_Case_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Support Issue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Ops Review Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Site_Issue_Priority__c</field>
            <operation>equals</operation>
            <value>Critical</value>
        </criteriaItems>
        <description>Notification to Case Owner Ops</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Team - Implementation Task</fullName>
        <actions>
            <name>Case_Owner_ImpTask</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Implementation Task</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Business Analyst Review Requested,Business Analyst in Progress,Contract Analyst in Progress,New,Data Analyst Review Requested,Awaiting Member Clarification,Contract Analyst Review Requested,Data Analyst In Progress,Ops Review Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>&quot;Completed, Pending QA&quot;,Hold: Pending Resolution to Another Case,Cancelled,Resolved,Ops in Progress,&quot;Completed, Pending Review&quot;,Requires Case Owner Clarification</value>
        </criteriaItems>
        <description>Email alert for all internal notifications related to Implementation tasks.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Team - Operations Issue</fullName>
        <actions>
            <name>Case_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Operations Issue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Requires Case Owner Clarification,Data Services Analyst Assignment Needed,Data Analyst Review Requested,Engineering Review Requested,Ops Review Requested,Data Analyst In Progress,Ops in Progress,Engineering in Progress,&quot;Completed, Pending Review&quot;</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Compass%3A Auto Update Date%2FTime Closed</fullName>
        <actions>
            <name>Compass_DateTime_Closed_Auto_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>06 - Issue Resolved - Ticket Closed,Completed,&quot;10 - Closed, Member Notified&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Compass Connect Ticket,Compass Data Analytics Ticket,Compass Implementation &amp; Support,CCA Data Load,Crimson Support Request</value>
        </criteriaItems>
        <description>This rule autopopulates the Date/Time Closed field on Compass records when the Ticket is marked as &quot;Complete&quot; in the &quot;Status&quot; field.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass%3A Auto Update Date%2FTime Opened</fullName>
        <actions>
            <name>Member_Support_Date_Time_Opened</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>contains</operation>
            <value>Compass</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CMA Report Request,Internal Initiative,Internal Initiative Detail,CPRM Data Load</value>
        </criteriaItems>
        <description>This rule autopopulates the Date/Time Opened field on Compass records when the Ticket is created.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Compass%3A New Ticket Created</fullName>
        <actions>
            <name>Compass_New_Ticket_Created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Compass Connect Ticket,Compass Data Analytics Ticket,Compass Implementation &amp; Support,Compass Support Issue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Support_Category__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Compass- EDBI_NUBI - Queue</fullName>
        <actions>
            <name>Update_Record_Owner_to_MS_Queue_1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.Deployment_Type__c</field>
            <operation>equals</operation>
            <value>EDBI,NUBI</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Compass Implementation &amp; Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Assign_an_Individual_Owner__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass- International Spend_International Surgery_International ED - Queue</fullName>
        <actions>
            <name>Update_Record_Owner_to_MS_Queue_2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.Deployment_Type__c</field>
            <operation>equals</operation>
            <value>International Spend,International Surgery,International ED</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Compass Implementation &amp; Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Assign_an_Individual_Owner__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass- Surgical Profitability_Spend_SCI - Queue</fullName>
        <actions>
            <name>Update_Record_Owner_to_MS_Queue_3</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.Deployment_Type__c</field>
            <operation>equals</operation>
            <value>Procedure Cost Manager Integration,Procedure Cost Manager (No SPC/CCC),Outcomes Build (existing SPC requiring CCC),Procedure Cost Manager (existing CCC requiring SPC),Surgical Profitability,Spend,SCI</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Compass Implementation &amp; Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Assign_an_Individual_Owner__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass- USC - Queue</fullName>
        <actions>
            <name>Update_Record_Owner_to_MS_Queue_4</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.Deployment_Type__c</field>
            <operation>equals</operation>
            <value>USC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Compass Implementation &amp; Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Assign_an_Individual_Owner__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A Count of Diagnostics Sent</fullName>
        <actions>
            <name>Crimson_Count_of_Diagnostics_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCC Data Load</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>07- Diagnostics Sent - Awaiting sign off</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>6.5 - Diagnostics Sent to Member Manually (Automated)</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A Diagnostics Sent</fullName>
        <actions>
            <name>Crimson_Diagnostics_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCA Data Load</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Diagnostics_Sent__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>03 - Diagnostics Created</value>
        </criteriaItems>
        <description>Records the date modified when status was changed to 6.5 - Diagnostics Sent to Member Manually (Automated) or 07- Diagnostics Sent - Awaiting Sign Off.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A Diagnostics Sign Off Received</fullName>
        <actions>
            <name>Crimson_Diagnostics_Sign_Off_Received</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCA Data Load</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Diagnostics_Sign_Off_Received__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>04 - Diagnostics Approved</value>
        </criteriaItems>
        <description>Records the date modified when status was changed to 09- Received Diagnostics Sign Off.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A Internal Load Complete</fullName>
        <actions>
            <name>Crimson_Internal_Load_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCA Data Load</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Internal_Load_Complete__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>05 - In Smoke Test</value>
        </criteriaItems>
        <description>Records the date modified when status is changed to 12- Ready for Smoke Test.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A Load Review Complete</fullName>
        <actions>
            <name>Crimson_Load_Review_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCC Data Load</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Load_Review_Complete__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>17.5 - Ready for final QA- Testing Issues Addressed</value>
        </criteriaItems>
        <description>Records the date modified when status is changed to 17.5 - Testing Issues Addressed- Ready for Final QA.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A Member Support Assigned User</fullName>
        <actions>
            <name>Crimson_Members_Support_Assigned_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Created as part of CR-1938
Update Rule criteria - CR-20160405-9735</description>
        <formula>AND( 	ISCHANGED(Assigned_To_Contact__c),  	AND(  		RecordType.DeveloperName != &apos;PIC_Contract_Maintenance&apos;, 		RecordType.DeveloperName != &apos;PIC_Customer_Service_Request&apos;, 		RecordType.DeveloperName != &apos;PIC_Defect&apos;, 		RecordType.DeveloperName != &apos;PIC_Enhancement&apos;, 		RecordType.DeveloperName != &apos;PIC_Implementation_Task&apos;, 		RecordType.DeveloperName != &apos;PIC_Operations_Issue&apos;, 		RecordType.DeveloperName != &apos;PIC_Query_Component&apos;, 		RecordType.DeveloperName != &apos;PIC_Rate_Schedule&apos;, 		RecordType.DeveloperName != &apos;PIC_Support_Issue&apos; 	) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A Member Support Deleted</fullName>
        <actions>
            <name>Crimson_Member_Support_Uploaded</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When a Member Support record is deleted the BA, DA, Watchlist User and QA get an email</description>
        <formula>AND( NOT(ISBLANK(Site_Issue_Close_Date__c)), OR(RecordType.Name = &quot;CCA Data Load&quot;, RecordType.Name = &quot;Crimson Support Request&quot;, RecordType.Name = &quot;Defect / Enhancement Request&quot;, RecordType.Name = &quot;CPM Support Issue&quot;, RecordType.Name = &quot;Internal Initiative&quot;, RecordType.Name = &quot;Internal Initiative Detail&quot;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A Member Support Updated</fullName>
        <actions>
            <name>Crimson_Member_Support_Uploaded</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When a Member Support record is created the BA, DA, Watchlist User and QA get an email</description>
        <formula>AND( DATEVALUE(CreatedDate) = TODAY (), OR(RecordType.Name = &quot;CCA Data Load&quot;, RecordType.Name = &quot;Crimson Support Request&quot;, RecordType.Name = &quot;Defect / Enhancement Request&quot;, RecordType.Name = &quot;CPM Support Issue&quot;, RecordType.Name = &quot;Internal Initiative&quot;, RecordType.Name = &quot;Internal Initiative Detail&quot;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A Member Support Updated Email Creator</fullName>
        <actions>
            <name>Crimson_Member_Support_Uploaded_Record_Creator</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCC Data Load,OPPE Measure Support,CCC Custom Query Request,Defect / Enhancement Request,CPM Support Issue,Crimson Support Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Email</field>
            <operation>notEqual</operation>
            <value>SFAdmin@advisory.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.CreatedById</field>
            <operation>notEqual</operation>
            <value>Salesforce Administrator</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.LastModifiedById</field>
            <operation>notEqual</operation>
            <value>IS Salesforce Automation</value>
        </criteriaItems>
        <description>When a Member Support record is created/edited/deleted the Record Creator gets an email as long as that user is not Salesforce Admin or IS Salesforce Automation.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A Moved to Production</fullName>
        <actions>
            <name>Crimson_Moved_to_Production</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCA Data Load</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Moved_to_Production__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>09 - Migration Complete</value>
        </criteriaItems>
        <description>Records the date modified when status is changed to 21- Crosscheck Complete.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A Notes%3A Long Text from Project to Member Support</fullName>
        <actions>
            <name>Update_Custom_SQL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Recurring_Notes_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCA Data Load</value>
        </criteriaItems>
        <description>Drives &apos;Notes: Recurring Data&apos; and &apos;Custom SQL&apos; fields from Project to Member Support</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A Portal Generated Issue</fullName>
        <actions>
            <name>Crimson_Portal_Generated_Issue_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCA Data Load,Crimson Support Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Interaction_Type__c</field>
            <operation>equals</operation>
            <value>Community,Live Agent</value>
        </criteriaItems>
        <description>Created as part of CR-4283. When Interaction Type = Community or Live Agent, set ‘Portal Generated Issue’ to TRUE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A QA Analyst</fullName>
        <actions>
            <name>QA_Analyst</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCC Data Load</value>
        </criteriaItems>
        <description>Vijay Thomas is assigned as QA analyst for all new CCA Data Load issues</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A Update Load Frequency</fullName>
        <actions>
            <name>Load_Frequency</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCC Data Load</value>
        </criteriaItems>
        <description>Captures Load Frequency from Project</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Crimson- Consecutively Delayed Load</fullName>
        <actions>
            <name>Consecutively_Delayed_Load</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCC Data Load</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Total_Delay__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Data_Load_Type__c</field>
            <operation>equals</operation>
            <value>Current</value>
        </criteriaItems>
        <description>Identify consecutively delayed loads at the member support level</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Crimson- Files Receieved</fullName>
        <actions>
            <name>Crimson_Files_Received</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.Files_Received__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>02 - Files Received</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCA Data Load</value>
        </criteriaItems>
        <description>Records the date modified when status is changed to 04- Have All Files - Ready for Extract.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CrimsonForce-Auto Confirmation</fullName>
        <actions>
            <name>CrimsonForce_Auto_Confirmation</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Site_Issue__c.Visible_In_Portal__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Data Analyst - CSR</fullName>
        <actions>
            <name>Case_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 and 2</booleanFilter>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Customer Service Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Engineering Review Requested,Data Analyst Review Requested,New,&quot;Member Approved, Awaiting Start&quot;,Data Services Analyst Assignment Needed,Ops Review Requested</value>
        </criteriaItems>
        <description>Notification to a Data Analyst of a new or updated CSR for review.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Defect%3A Support Category Listed</fullName>
        <actions>
            <name>Defect_Support_Category_Listed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Site_Issue__c.Support_Category__c</field>
            <operation>equals</operation>
            <value>AOA Defect</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Support_Category__c</field>
            <operation>equals</operation>
            <value>AOA Enhancement</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Fogbugz%3A Status Mapping</fullName>
        <actions>
            <name>Fogbugz_Date_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Fogbugz_Status_Mapping</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.FogBugz_Case_Closed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Internal Initiative- Date Closed Autofill</fullName>
        <actions>
            <name>Internal_Initiative_Date_Closed_Autofil</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>06 - Issue Resolved - Ticket Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Internal Initiative Detail</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Member Portal Status %28Awaiting CMS Update%29</fullName>
        <actions>
            <name>Member_Portal_Status_Awaiting_CMS_Updat</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Awaiting CMS Update</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Member Portal Status %28Awaiting Member Approval%29</fullName>
        <actions>
            <name>Member_Portal_Status_Awaiting_Member_Ap</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Awaiting Member Approval</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Member Portal Status %28Awaiting Member Clarification%29</fullName>
        <actions>
            <name>Member_Portal_Status_Awaiting_Member_Cl</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Awaiting Member Clarification,Pending Activation and Recalc Approval,Pending Recalc Approval</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Member Portal Status %28Cancelled%29</fullName>
        <actions>
            <name>Member_Portal_Status_Cancelled</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Rejected,Cancelled</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Member Portal Status %28Creation of Standard Files in Progress%29</fullName>
        <actions>
            <name>Member_Portal_Status_Creation_of_Standa</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Creation of Standard Files in Progress</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Member Portal Status %28Duplicate%2C See Parent Case%29</fullName>
        <actions>
            <name>Member_Portal_Status_Duplicate_See_Par</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>&quot;Duplicate, See Parent Case&quot;</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Member Portal Status %28Hold%3A Pending Resolution%29</fullName>
        <actions>
            <name>Member_Portal_Status_Hold_Pending_Reso</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Hold: Pending Resolution to Another Case</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Member Portal Status %28In Progress%29</fullName>
        <actions>
            <name>Member_Portal_Status_Progress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 or 2 or 3 or 4 or 5</booleanFilter>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Approved,Contract Analyst Assignment Needed,Data Services Analyst Assignment Needed,Batch Processing Update,Business Analyst Review Requested,Data Analyst Review Requested,Dedicated Advisor Review Requested,Engineering Review Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Requires Case Owner Clarification,Support Review in Progress,Ops Review Requested,Product Review Requested,QA Review Requested,System DBA Review Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Data Services Analyst Estimate Needed,Awaiting Member Notification,Contract Analyst in Progress,Data Analyst In Progress,Dedicated Advisor in Progress,Engineering in Progress</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Ops in Progress,Product in Progress,System DBA in Progress,Ops Start Ready,Initial Development Complete,QA in Progress,&quot;QA Completed, Waiting Deployment&quot;,&quot;QA Completed, Rejected&quot;,Scheduled for Release</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>&quot;Estimate Completed, Pending Approval&quot;,System DBA in Progress,&quot;Completed, Pending Review&quot;,Hold: Task Owner Not in Progress,Rate Schedule Updates in Progress,Contract Analyst Review Requested</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Member Portal Status %28Pending Member Sign-off%29</fullName>
        <actions>
            <name>Member_Portal_Status_Pending_Member_Sig</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Pending Member Sign-Off</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Member Portal Status %28Pending Start%29</fullName>
        <actions>
            <name>Member_Portal_Status_Pending</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>New,Resubmitted,PIC Support Assignment Needed,&quot;Member Approved, Awaiting Start&quot;,&quot;Completed, Awaiting Release Assignment&quot;</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Member Portal Status %28Resolved%29</fullName>
        <actions>
            <name>Member_Portal_Status_Resolved</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Resolved</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Member Portal Status %28Unresolved%29</fullName>
        <actions>
            <name>Member_Portal_Status_Unresolved</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Unresolved</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Member Support%3A Check if Date%2FTime Opened is null</fullName>
        <actions>
            <name>Update_the_Date_Time_Opened_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This will be only executed only at the time of record creation. Workflow will check if Date/Time Opened is null, then update the “Date/Time Opened” field with current date time(formula = NOW()) using a field update.</description>
        <formula>Site_Issue_Created_Date__c &lt; NOW ()</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Member Support%3A Next Data Upload Expected On</fullName>
        <actions>
            <name>Next_Data_Upload_Expected_On_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT( ISBLANK( Project__r.Next_Data_Upload_Expected_On__c ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Milliman Sharing - Checkbox Off</fullName>
        <actions>
            <name>Milliman_Sharing_Checkbox_Off</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Site_Issue__c.Project_Name__c</field>
            <operation>notContain</operation>
            <value>- EHBI</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Project_Name__c</field>
            <operation>notContain</operation>
            <value>- CPRM</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Milliman Sharing - Checkbox On</fullName>
        <actions>
            <name>Milliman_Sharing_Checkbox_On_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Site_Issue__c.Project_Name__c</field>
            <operation>contains</operation>
            <value>- EHBI</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Project_Name__c</field>
            <operation>contains</operation>
            <value>- CPRM</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PIC Case IsClosed</fullName>
        <actions>
            <name>FU_IE_Team_MS_Date_Time_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Member_Support_Case_IsClosed_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>For any of the PIC Support record types, check to see if the PIC Status is set to one of the closed status values.  If so, update the Case IsClosed to true and Date/Time Closed to NOW()</description>
        <formula>AND( 	ISBLANK( Site_Issue_Close_Date__c ),  	OR(  		ISPICKVAL( PIC_Status__c , &quot;Closed&quot;),  		ISPICKVAL( PIC_Status__c , &quot;Unresolved&quot;),  		ISPICKVAL( PIC_Status__c , &quot;Cancelled&quot;),  		ISPICKVAL( PIC_Status__c , &quot;Closed Without Resolution&quot;),  		ISPICKVAL( PIC_Status__c , &quot;Resolved&quot;),  		ISPICKVAL( PIC_Status__c , &quot;Rejected&quot;)  	)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMC Case Contact - Cancelled</fullName>
        <actions>
            <name>RMC_Case_Contact_Cancelled</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Resolution_Category__c</field>
            <operation>equals</operation>
            <value>Cancelled - No Member Response</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>contains</operation>
            <value>Resurrection</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PHI_Compliant__c</field>
            <operation>equals</operation>
            <value>&quot;Yes, Content Reviewed&quot;</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case has been marked as Cancelled due to no member response.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMC Case Contact - Closed</fullName>
        <actions>
            <name>RMC_Case_Contact_Closed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Resolved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Resolution_Category__c</field>
            <operation>equals</operation>
            <value>Completed - No Member Response</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>contains</operation>
            <value>resurrection</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PHI_Compliant__c</field>
            <operation>equals</operation>
            <value>&quot;Yes, Content Reviewed&quot;</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case has been marked as closed (from pending member sign-off) due to no member response.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMC Case Contact - Contract Maintenance Awaiting Factors</fullName>
        <actions>
            <name>RMC_Contract_Maintenance_Factors</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Awaiting Facility Specific Factors</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Contract Maintenance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>contains</operation>
            <value>resurrection</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case requires member clarification.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMC Case Contact - Contract Maintenance Awaiting Member Clarification</fullName>
        <actions>
            <name>RMC_Contract_Maintenance_Awaiting_New</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Contract Maintenance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>New,Awaiting Member Clarification</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>contains</operation>
            <value>resurrection</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMC Case Contact - Contract Maintenance Pending Member Sign-off</fullName>
        <actions>
            <name>RMC_Contract_Maintenance_Pending_Member_Signed_off</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Contract Maintenance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Pending Member Sign-Off</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>contains</operation>
            <value>resurrection</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMC Case Contact - Needs Clarification</fullName>
        <actions>
            <name>RMC_Case_Contact_Needs_Clarification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2  AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Awaiting Member Clarification</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Customer Service Request,PIC Query Component,PIC Support Issue,PIC Enhancement,PIC Defect</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PHI_Compliant__c</field>
            <operation>equals</operation>
            <value>&quot;Yes, Content Reviewed&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>contains</operation>
            <value>resurrection</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case requires member clarification.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMC Case Contact - New</fullName>
        <actions>
            <name>RMC_Case_Contact_New</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Customer Service Request,PIC Query Component,PIC Support Issue,PIC Enhancement,PIC Defect</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>contains</operation>
            <value>resurrection</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PHI_Compliant__c</field>
            <operation>equals</operation>
            <value>&quot;Yes, Content Reviewed&quot;</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case is created New.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>RMC Case Contact - Req Approval</fullName>
        <actions>
            <name>RMC_Case_Contact_Req_Approval</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Awaiting Member Approval</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Customer Service Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>contains</operation>
            <value>resurrection</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PHI_Compliant__c</field>
            <operation>equals</operation>
            <value>&quot;Yes, Content Reviewed&quot;</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case requires approval (related to CSRs only).</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RMC Case Contact - Req Signoff</fullName>
        <actions>
            <name>RMC_Case_Contact_Req_Signoff</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.PIC_Status__c</field>
            <operation>equals</operation>
            <value>Pending Member Sign-Off</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PIC Customer Service Request,PIC Query Component,PIC Support Issue,PIC Enhancement,PIC Defect</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Member_Name__c</field>
            <operation>contains</operation>
            <value>resurrection</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.PHI_Compliant__c</field>
            <operation>equals</operation>
            <value>&quot;Yes, Content Reviewed&quot;</value>
        </criteriaItems>
        <description>This email notification is for the case contact once a case requires member approval to close the case.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Assigned To Contact Email</fullName>
        <actions>
            <name>Assigned_to_Contact_Email_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_AssignMSToRMS</fullName>
        <actions>
            <name>FU_UpdateOwnerToRMSQueue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RMS_Member__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Deployment_Type__c</field>
            <operation>equals</operation>
            <value>USC</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_IE_Team_MS_Date_Time_Closed</fullName>
        <actions>
            <name>FU_IE_Team_MS_Date_Time_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>IE Team Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>Created for  CR-20151116-9383.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_IE_Team_MS_Owners</fullName>
        <actions>
            <name>FU_IE_Team_MS_Owners</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>IE Team Support</value>
        </criteriaItems>
        <description>Created for  CR-20151116-9383.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_MS_Defect_CCR</fullName>
        <actions>
            <name>EA_Send_Defect_Email_To_CCR</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20140811-6950</description>
        <formula>AND( 	Verified__c, TRUE, 	ISPICKVAL(Support_Category__c , &quot;Defect&quot;), 	$RecordType.DeveloperName = &quot;Defect_Enhancement_Request&quot;,  	Project__r.Program_Acronym__c = &apos;BICR&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_MS_Defect_CPRM</fullName>
        <actions>
            <name>EA_Send_Defect_Email_To_CPRM</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20140811-6950</description>
        <formula>AND( 	Verified__c, TRUE, 	ISPICKVAL(Support_Category__c , &quot;Defect&quot;), 	$RecordType.DeveloperName = &quot;Defect_Enhancement_Request&quot;, 	OR( 		Project__r.Program_Acronym__c = &apos;BIEH&apos;, 		Project__r.Program_Acronym__c = &apos;BIPR&apos;, 		Project__r.Program_Acronym__c = &apos;BIPRP&apos; 	)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_MS_Defect_CRT</fullName>
        <actions>
            <name>EA_Send_Defect_Email_To_CRT</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20140811-6950</description>
        <formula>AND(         Verified__c, TRUE, 	ISPICKVAL(Support_Category__c , &quot;Defect&quot;), 	$RecordType.DeveloperName = &quot;CCA_Support_Request&quot;, 	Project__r.Program_Acronym__c = &apos;FRPU&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_MS_Enhancement_Request_CCR</fullName>
        <actions>
            <name>EA_Send_Enhancement_Request_Email_To_CCR</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20140811-6950</description>
        <formula>AND( 	Verified__c, TRUE, 	ISPICKVAL(Support_Category__c , &quot;Enhancement Request&quot;), 	$RecordType.DeveloperName = &quot;Defect_Enhancement_Request&quot;,  	Project__r.Program_Acronym__c = &apos;BICR&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_MS_Enhancement_Request_CPRM</fullName>
        <actions>
            <name>EA_Send_Enhancement_Request_Email_To_CPRM</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20140811-6950</description>
        <formula>AND( 	Verified__c, TRUE, 	ISPICKVAL(Support_Category__c , &quot;Enhancement Request&quot;), 	$RecordType.DeveloperName = &quot;Defect_Enhancement_Request&quot;, 	OR( 		Project__r.Program_Acronym__c = &apos;BIEH&apos;, 		Project__r.Program_Acronym__c = &apos;BIPR&apos;, 		Project__r.Program_Acronym__c = &apos;BIPRP&apos; 	)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_MS_Enhancement_Request_CRT</fullName>
        <actions>
            <name>EA_Send_Enhancement_Request_Email_To_CRT</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20140811-6950</description>
        <formula>AND(         Verified__c, TRUE,  	ISPICKVAL(Support_Category__c , &quot;Enhancement Request&quot;), 	$RecordType.DeveloperName = &quot;CCA_Support_Request&quot;,  	Project__r.Program_Acronym__c = &apos;FRPU&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_PopulateRMSMemberWithTrue</fullName>
        <actions>
            <name>FU_PopulateRMSMemberWithTrue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(     Deployment__r.RMS_Member__c  = true,      Project__r.Product__r.Program_Acronym__c = &apos;BHSM&apos; )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_UpdateMSDataAnalyticsTicketOwner</fullName>
        <actions>
            <name>FU_UpdateMSOwnerToChrisSanford</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Compass Data Analytics Ticket</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_Update_Owner_Tier_II</fullName>
        <actions>
            <name>FU_Update_Owner_Tier_II_Support</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCA Data Load</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Tier__c</field>
            <operation>equals</operation>
            <value>Tier II</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>SSC RMS</value>
        </criteriaItems>
        <description>Update the Member Support record owner to Tier II when Record Type = CCA Data Load.  CR-4283</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_ValidateMemberSupportIssueOwner</fullName>
        <actions>
            <name>FU_PopulateOwnerWithCompassSupportIssueQ</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Compass Support Issue</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WR_MS_Update_ Owner_ CSupport_Issue_Que</fullName>
        <actions>
            <name>FU_MS_Update_Owner_CSupport_Issue_Que</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Site_Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Compass Implementation &amp; Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Site_Issue__c.Support_Category__c</field>
            <operation>equals</operation>
            <value>Member Support</value>
        </criteriaItems>
        <description>Created for the CR-20150728-9104</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
