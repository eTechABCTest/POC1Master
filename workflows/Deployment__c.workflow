<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CCC_Diag_Sign_Off_Recd_UAT_Onsite</fullName>
        <description>CCC: Diag Sign Off Recd UAT Onsite</description>
        <protected>false</protected>
        <recipients>
            <field>Business_Analyst__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Dedicated_Advisor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CCA_Email_Templates/CCC_Diag_Sign_Off_Recd</template>
    </alerts>
    <alerts>
        <fullName>Compass_Business_Analyst_is_entered_on_Deployment</fullName>
        <description>Compass: Business Analyst is entered on Deployment</description>
        <protected>false</protected>
        <recipients>
            <field>Business_Analyst__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Compass/Compass_Business_Analyst_is_Entered</template>
    </alerts>
    <alerts>
        <fullName>Compass_Complete_Data_In_Actual_is_entered</fullName>
        <description>Compass: Complete Data In (Actual) is entered</description>
        <protected>false</protected>
        <recipients>
            <field>Business_Analyst__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Compass/Compass_Complete_Data_In_Actual_is_entered</template>
    </alerts>
    <alerts>
        <fullName>Compass_Initial_Site_Build_Complete_Actual_is_entered</fullName>
        <description>Compass: Initial Site Build Complete (Actual) is entered</description>
        <protected>false</protected>
        <recipients>
            <field>Business_Analyst__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Compass/Compass_Initial_Site_Build_Complete_Actual_is_entered</template>
    </alerts>
    <alerts>
        <fullName>Compass_Internal_Validation_Complete_Actual_is_entered</fullName>
        <description>Compass: Internal Validation Complete (Actual) is entered</description>
        <protected>false</protected>
        <recipients>
            <field>Business_Analyst__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Compass/Compass_Internal_Validation_Complete_Actual_is_entered</template>
    </alerts>
    <alerts>
        <fullName>Guidelines_Site_Live_Complete</fullName>
        <description>Guidelines Site Live Complete</description>
        <protected>false</protected>
        <recipients>
            <recipient>willougm@advisory.com.abc</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CCA_Email_Templates/Crimson_Guidelines_Deployment_Complete</template>
    </alerts>
    <fieldUpdates>
        <fullName>Autopopulate_Deployment_Name_All_Types</fullName>
        <description>This autopopulates the Deployment Name on all Records as per CR-20120208-384</description>
        <field>Name</field>
        <formula>Project__r.Institution__r.Name  + &quot; - &quot; +   Deployment_Type__r.Name</formula>
        <name>Autopopulate Deployment Name - All Types</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCC_Complete_Data_In_Expected</fullName>
        <field>C_E_CDI__c</field>
        <formula>if(!(isblank(C_A_DS__c)),  Feedback_on_Initial_Data_Expected__c + 14 , NULL)</formula>
        <name>CCC: Complete Data In (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCC_Data_Diagnostics_Complete_Exp</fullName>
        <field>C_E_DDC__c</field>
        <formula>if(!(isblank(C_A_DS__c)), Expected_Data_Diagnostics_Sent__c  + 14, NULL)</formula>
        <name>CCC: Data Diagnostics Complete (Exp)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCC_Deployment_Sign_Off_Exp</fullName>
        <field>C_E_DC__c</field>
        <formula>if(!(isblank(C_A_DS__c)), C_E_ISBC__c + 63 , NULL)</formula>
        <name>CCC: Deployment Sign Off (Exp)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCC_Initial_Site_Build_Complete_Exp</fullName>
        <field>C_E_ISBC__c</field>
        <formula>if(!(isblank(C_A_DS__c)),  C_E_DDC__c + 14 , NULL)</formula>
        <name>CCC:Initial Site Build Complete (Exp)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCC_Internal_Validation_Complete_Exp</fullName>
        <field>C_E_IVC__c</field>
        <formula>if(!(isblank(C_A_DS__c)), C_E_ISBC__c + 7 , NULL)</formula>
        <name>CCC: Internal Validation Complete (Exp)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCC_Update_Initial_Data_In_Exp</fullName>
        <field>C_E_IDI__c</field>
        <formula>if(!(isblank(C_A_DS__c)), C_E_TPC__c + 14 , NULL)</formula>
        <name>CCC: Update Initial Data In (Exp)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCC_Update_Tech_Planning_Complete_Exp</fullName>
        <field>C_E_TPC__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + 7 , NULL)</formula>
        <name>CCC: Update Tech Planning Complete (Exp)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CC_Site_Build_Complete_Expected</fullName>
        <field>C_E_ISBC__c</field>
        <formula>if(!(isblank(PT_Access_Granted_Date__c)),PT_Access_Granted_Date__c + Deployment_Type__r.Expected_CC_Complete_Data_In__c , NULL)</formula>
        <name>CC: Site Build Complete (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CMA_Deployment_Statuss_Future</fullName>
        <field>CPM_Deployment_Status__c</field>
        <literalValue>Future/On Hold</literalValue>
        <name>CMA Deployment Status Future</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CMA_Deployment_Statuss_Green</fullName>
        <field>CPM_Deployment_Status__c</field>
        <literalValue>Green</literalValue>
        <name>CMA Deployment Status Green</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CMA_Deployment_Statuss_Red</fullName>
        <field>CPM_Deployment_Status__c</field>
        <literalValue>Red</literalValue>
        <name>CMA Deployment Status Red</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CMA_Deployment_Statuss_Yellow</fullName>
        <field>CPM_Deployment_Status__c</field>
        <literalValue>Yellow</literalValue>
        <name>CMA Deployment Status Yellow</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Compass_Update_Engineer_Lead</fullName>
        <description>This updates the Engineer Lead field with the user &quot;Nandini Parvathareddygari&quot; for Deployment Types: Surgical Profitability, Spend, SCI</description>
        <field>Engineer_Lead__c</field>
        <lookupValue>sfadmin@advisory.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Compass: Update Engineer Lead - 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Compass_Update_Engineer_Lead_2</fullName>
        <description>This updates the Engineer Lead field with the user &quot;Krithika Ramachandran&quot; for Deployment Types: USC</description>
        <field>Engineer_Lead__c</field>
        <lookupValue>sfadmin@advisory.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Compass: Update Engineer Lead - 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Compass_Update_Engineer_Lead_3</fullName>
        <description>This updates the Engineer Lead field with the user &quot;Sandhya Naradasu&quot; for Deployment Types: EDBI, NUBI</description>
        <field>Engineer_Lead__c</field>
        <lookupValue>sfadmin@advisory.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Compass: Update Engineer Lead - 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Compass_Update_Engineer_Lead_4</fullName>
        <description>This updates the Engineer Lead field with the user &quot;Bhavani Dandu&quot; for Deployment Types: International Spend, International Surgery, International ED</description>
        <field>Engineer_Lead__c</field>
        <lookupValue>sfadmin@advisory.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Compass: Update Engineer Lead - 4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DAS_Approved_Expected</fullName>
        <field>DAS_Approved_Expected__c</field>
        <formula>IF( NOT( ISBLANK( C_A_DS__c ) ) , C_A_DS__c +  Deployment_Type__r.Expected_DAS_Approved__c  , NULL)</formula>
        <name>DAS Approved (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_PopulateIntegrationEngineerClient</fullName>
        <field>Integration_Engineer_Client__c</field>
        <formula>Project__r.Integration_Engineer_Client__c</formula>
        <name>FU_PopulateIntegrationEngineerClient</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_PopulateIntegrationEngineerDelivery</fullName>
        <field>Integration_Engineer_Delivery__c</field>
        <formula>Project__r.Integration_Engineer_Delivery__c</formula>
        <name>FU_PopulateIntegrationEngineerDelivery</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Validation_Complete_Expected</fullName>
        <field>Member_Validation_Complete_Expected__c</field>
        <formula>IF( NOT( ISBLANK( C_A_DS__c ) ) , C_A_DS__c + Deployment_Type__r.Expected_Member_Validation_Comp__c , NULL)</formula>
        <name>Member Validation Complete (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PT_Access_Granted_Date_Expected</fullName>
        <field>PT_Access_Granted_Date_Expected__c</field>
        <formula>IF( NOT( ISBLANK( C_A_DS__c ) ) , C_A_DS__c + Deployment_Type__r.Expected_CC_Access_Date__c , NULL)</formula>
        <name>PT: Access Granted Date (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Original_Milliman_Analyst</fullName>
        <field>Milliman_Analyst__c</field>
        <formula>Project__r.Milliman_Analyst__c</formula>
        <name>Populate Original Milliman Analyst</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Project_Planning_Expected</fullName>
        <field>Project_Planning_Expected__c</field>
        <formula>IF( NOT( ISBLANK( C_A_DS__c ) ) , C_A_DS__c + Deployment_Type__r.Expected_Project_Planning__c , NULL)</formula>
        <name>Project Planning (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Success_Markers_Complete_Expected</fullName>
        <field>Success_Markers_Submitted_Expected__c</field>
        <formula>IF( NOT( ISBLANK( C_A_DS__c ) ) , C_A_DS__c + Deployment_Type__r.Expected_Success_Marketers_Submitted__c , NULL)</formula>
        <name>Success Markers Complete (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Analysis_Target</fullName>
        <field>Analysis_Target__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c+ Deployment_Type__r.Analysis__c , NULL)</formula>
        <name>Update Analysis (Target)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Bid_Management_Target</fullName>
        <field>Bid_Management_Target__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c+ Deployment_Type__r.Bid_Management__c , NULL)</formula>
        <name>Update Bid Management (Target)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CC_Complete_Data_In_Expected</fullName>
        <field>C_E_CDI__c</field>
        <formula>if(!(isblank(PT_Access_Granted_Date__c)),PT_Access_Granted_Date__c + Deployment_Type__r.Expected_CC_Complete_Data_In__c , NULL)</formula>
        <name>Update CC: Complete Data In (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CC_Initial_Data_In_Expected</fullName>
        <field>C_E_IDI__c</field>
        <formula>if(!(isblank(PT_Access_Granted_Date__c)),PT_Access_Granted_Date__c + Deployment_Type__r.Expected_CC_Initial_Data_In__c , NULL)</formula>
        <name>Update CC: Initial Data In (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Complete_Data_In_Expected</fullName>
        <description>Updates complete data in (expected) with standard timing when &apos;use standard milestone goals&apos; is checked</description>
        <field>C_E_CDI__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_Complete_Data_In__c,NULL)</formula>
        <name>Update Complete Data In Expected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Controlled_Mrkt_Build_Cmplt_Proj</fullName>
        <description>Created as part of CR-20140724-6621.</description>
        <field>Controlled_Mrkt_Build_Cmplt_Projected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Controlled_Mrkt_Build_Cmplt__c, NULL)</formula>
        <name>Update Controlled Mrkt Build Cmplt(Proj)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_DAS_Received_Expected</fullName>
        <field>DAS_Received_Expected__c</field>
        <formula>IF( NOT( ISBLANK( C_A_DS__c ) ) , C_A_DS__c +  Deployment_Type__r.Expected_DAS_Received__c  , NULL)</formula>
        <name>Update DAS Received (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Data_Acquisition_Call_Expected</fullName>
        <description>CR-595</description>
        <field>Data_Acquisition_Call_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c +  Deployment_Type__r.Expected_Data_Acquisition_Call__c , NULL)</formula>
        <name>Update Data Acquisition Call (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Data_Audit_Received_Expected</fullName>
        <field>Data_Audit_Received_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c +  Deployment_Type__r.Expected_Data_Audit_Received__c , NULL)</formula>
        <name>Update Data Audit Received (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Data_Audit_Sign_Off_Expected</fullName>
        <field>Data_Audit_Sign_Off_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c +  Deployment_Type__r.Expected_Data_Audit_Sign_Off__c  , NULL)</formula>
        <name>Update Data Audit Sign Off (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Data_Collection_Target</fullName>
        <field>Data_Collection_Target__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c+ Deployment_Type__r.Data_Collection__c , NULL)</formula>
        <name>Update Data Collection (Target)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Data_Diag_Comp_Expected</fullName>
        <description>updates Data Diagnostics Complete (Expected) with standard timing when Use Standard Milestone Goals is checked</description>
        <field>C_E_DDC__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_Diagnostic_Sign_Off_Received__c, NULL)</formula>
        <name>Update Data Diag Comp Expected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Data_Diagnostics_Sent_Expected</fullName>
        <description>Created as part of CR-3570</description>
        <field>Data_Diagnostics_Sent_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_Data_Diagnostics_Sent__c , NULL)</formula>
        <name>Update Data Diagnostics Sent (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Deployment_Start_Expected</fullName>
        <description>Created as part of CR-3570</description>
        <field>Deployment_Start_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_Deployment_Start__c , NULL)</formula>
        <name>Update Deployment Start (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Establish_VPN_Connectivity_Expec</fullName>
        <description>Created as part of CR-3570</description>
        <field>Establish_VPN_Connectivity_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_VPN_Connectivity__c, NULL)</formula>
        <name>Update Establish VPN Connectivity (Expec</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Expected_Recurring_Update_Sign_Of</fullName>
        <field>Expected_Recurring_Update_Sign_Off2__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c +  Deployment_Type__r.Expected_Recurring_Update_Sign_Off__c , NULL)</formula>
        <name>Update Expected Recurring Update Sign-Of</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Feedback_on_Initial_Data_Expect</fullName>
        <field>Feedback_on_Initial_Data_Expected__c</field>
        <formula>IF( NOT( ISBLANK( C_A_DS__c ) ) , C_A_DS__c +  Deployment_Type__r.Expected_Feedback_on_Initial_Data__c , NULL)</formula>
        <name>Update Feedback on Initial Data (Expect)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Historical_Data_Received_Expecte</fullName>
        <description>Created as part of CR-3570</description>
        <field>Historical_Data_Received_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_Historical_Data_Received__c , NULL)</formula>
        <name>Update Historical Data Received (Expecte</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Implementation_Plan_Complete_Exp</fullName>
        <description>CR-595</description>
        <field>Implementation_Plan_Complete_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c +  Deployment_Type__r.Expected_Implementation_Plan_Complete__c , NULL)</formula>
        <name>Update Implementation Plan Complete Exp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Initial_Data_In_Expected</fullName>
        <description>Updates initial data in (expected) with standard timing when &apos;use standard milestone goals&apos; is checked</description>
        <field>C_E_IDI__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_Initial_Data_In__c, NULL)</formula>
        <name>Update Initial Data In Expected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Initial_Site_Build_Complete_Exp</fullName>
        <description>updates Initial Site Build Complete (Expected) with standard timing when Use Standard Milestone Goals is checked</description>
        <field>C_E_ISBC__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_Site_Live__c, NULL)</formula>
        <name>Update Initial Site Build Complete Exp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Initial_Site_Build_Submitted_Exp</fullName>
        <field>Initial_Site_Build_Submitted_Expected__c</field>
        <formula>if(NOT(ISBLANK(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_Initial_Site_Build_Submitted__c, NULL)</formula>
        <name>Update Initial Site Build Submitted (Exp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Initial_Site_Demo_Expected</fullName>
        <field>Initial_Site_Demo_Exp__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c +  Deployment_Type__r.Expected_Initial_Site_Demo__c , NULL)</formula>
        <name>Update Initial Site Demo (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Integration_Config_Comp_Exp</fullName>
        <description>Updates &quot;Integration Configuration Completed (Expected&quot; with standard timing when &apos;use standard milestone goals&apos; is checked</description>
        <field>Integration_Configuration_Completed_Exp__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_Integration_Config_Completed__c,NULL)</formula>
        <name>Update Integration Config Comp (Exp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Integration_Planning_Expected</fullName>
        <description>CR4062</description>
        <field>Integration_Planning_Complete_Expected__c</field>
        <formula>IF( NOT( ISBLANK( C_A_DS__c ) ) , C_A_DS__c + Deployment_Type__r.Expected_Integration_Planning_Complete__c , NULL)</formula>
        <name>Update Integration Planning (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Integration_Testing_Expected</fullName>
        <description>CR4062</description>
        <field>Integration_Testing_Complete_Expected__c</field>
        <formula>IF( NOT( ISBLANK( C_A_DS__c ) ) , C_A_DS__c + Deployment_Type__r.Expected_Integration_Testing_Complete__c , NULL)</formula>
        <name>Update Integration Testing (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Internal_Validation_Comp_Expected</fullName>
        <description>updates Initial Validation Complete (Expected) with standard timing when Use Standard Milestone Goals is checked</description>
        <field>C_E_IVC__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c+ Deployment_Type__r.Expected_Internal_Validation_Complete__c, NULL)</formula>
        <name>Update Internal Validation Comp Expected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Legal_Complete_Expected</fullName>
        <field>Legal_Complete_Expected__c</field>
        <formula>IF( NOT( ISBLANK( C_A_DS__c ) ) , C_A_DS__c +  Deployment_Type__r.Expected_Legal_Complete__c  , NULL)</formula>
        <name>Update Legal Complete (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Measure_Mapping_Complete_Exp</fullName>
        <description>CR-595</description>
        <field>Measure_Mapping_Complete_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c +  Deployment_Type__r.Expected_Measure_Mapping_Complete__c , NULL)</formula>
        <name>Update Measure Mapping Complete (Exp)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Open_Market_Build_Complete_Proj</fullName>
        <description>Created as part of CR-20140724-6621</description>
        <field>Open_Market_Build_Complete_Projected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Open_Market_Build_Complete__c, NULL)</formula>
        <name>Update Open Market Build Complete (Proj)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Open_Market_Cleanup_Complte_Proj</fullName>
        <description>Created as part of CR-20140724-6621</description>
        <field>Open_Market_Cleanup_Complete_Projected__c</field>
        <formula>if(!(isblank(C_A_DS__c)), C_A_DS__c + Deployment_Type__r.Open_Market_Cleanup_Complete__c, NULL)</formula>
        <name>Update Open Market Cleanup Complte(Proj)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Physician_Roster_Complete_Exp</fullName>
        <description>CR-595</description>
        <field>Physician_Roster_Complete_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c +  Deployment_Type__r.Expected_Physician_Roster_Complete__c , NULL)</formula>
        <name>Update Physician Roster Complete (Exp)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Postload_Complete_Expected</fullName>
        <description>Created as part of CR-3570</description>
        <field>Postload_Complete_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_Postload_Complete__c , NULL)</formula>
        <name>Update Postload Complete (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Practice_Survey_Complete_Exp</fullName>
        <description>CR-595</description>
        <field>Practice_Survey_Complete_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c +  Deployment_Type__r.Expected_Practice_Survey_Complete__c , NULL)</formula>
        <name>Update Practice Survey Complete (Exp)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Predictive_Model_Review_Expected</fullName>
        <description>Created as part of CR-3570</description>
        <field>Predictive_Model_Review_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_Predictive_Model_Review__c, NULL)</formula>
        <name>Update Predictive Model Review (Expected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Receive_Test_Data_Expected</fullName>
        <description>Created as part of CR-3570</description>
        <field>Receive_Test_Data_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_Receive_Test_Data__c, NULL)</formula>
        <name>Update Receive Test Data (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Redlining_Complete_Expected</fullName>
        <field>Redlining_Complete_Expected__c</field>
        <formula>IF( NOT( ISBLANK( C_A_DS__c ) ) , C_A_DS__c +  Deployment_Type__r.Expected_Redlining_Complete__c , NULL)</formula>
        <name>Update Redlining Complete (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Requirements_Development_Target</fullName>
        <field>Requirements_Development_Target__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c+ Deployment_Type__r.Requirements_Development__c, NULL)</formula>
        <name>Update Requirements Development (Target)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Scheduled_Site_Demo_Expected</fullName>
        <description>Created as part of CR-3570</description>
        <field>Scheduled_Site_Demo_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_Scheduled_Site_Demo__c , NULL)</formula>
        <name>Update Scheduled Site Demo (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Security_Clearance_Expected</fullName>
        <description>Created as part of CR-3570</description>
        <field>Security_Clearance_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_Security_Clearance__c , NULL)</formula>
        <name>Update Security Clearance (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Site_Live_Expected</fullName>
        <description>Created as part of CR-3570</description>
        <field>Site_Live_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_Site_Live_new__c, NULL)</formula>
        <name>Update Site Live (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Supplier_Engagement_Target</fullName>
        <field>Supplier_Engagement_Target__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c+ Deployment_Type__r.Supplier_Engagement__c , NULL)</formula>
        <name>Update Supplier Engagement (Target)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Technical_Planning_Call_Expected</fullName>
        <field>Technical_Planning_Call_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c +  Deployment_Type__r.Expected_Technical_Planning_Call__c , NULL)</formula>
        <name>Update Technical Planning Call (Expected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Template_Sent_Expected</fullName>
        <field>Template_Sent_Expected__c</field>
        <formula>IF( NOT( ISNULL( C_A_DS__c ) ) , C_A_DS__c  +  Deployment_Type__r.Expected_Template_Sent__c , NULL)</formula>
        <name>Update Template Sent (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Test_Site_Up_Expected</fullName>
        <description>Created as part of CR-3570</description>
        <field>Test_Site_Up_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_Test_Site_Up__c , NULL)</formula>
        <name>Update Test Site Up (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Training_Intensive_Onsite_Expect</fullName>
        <description>Created as part of CR-3570</description>
        <field>Training_Intensive_Onsite_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c + Deployment_Type__r.Expected_Training_Intensive_Onsite__c , NULL)</formula>
        <name>Update Training Intensive Onsite (Expect</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_UAT_Onsite_Expected</fullName>
        <description>CR-595</description>
        <field>UAT_Onsite_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c +  Deployment_Type__r.Expected_UAT_Onsite__c , NULL)</formula>
        <name>Update UAT Onsite (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Welcome_Call_Expected</fullName>
        <description>Created as part of CR-3570</description>
        <field>Welcome_Call_Expected__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c +  Deployment_Type__r.Expected_Welcome_Call__c , NULL)</formula>
        <name>Update Welcome Call (Expected)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>pdate_Expected_TechU_Planning_Complete</fullName>
        <description>updates C_E_TPC: Technical Planning Complete (Expected) to equal Actual_Deployment_Start__c + Deployment_Type__r.Expected_Technical_Kick_Off__c</description>
        <field>C_E_TPC__c</field>
        <formula>if( !(ISBLANK(C_A_DS__c) ), C_A_DS__c+ Deployment_Type__r.Expected_Technical_Planning_Complete__c,NULL)</formula>
        <name>pdate Expected TechU Planning Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_deployment_sign_off_expected</fullName>
        <description>updates Deployment Sign Off Complete (Expected) with standard timing when Use Standard Milestone Goals is checked</description>
        <field>C_E_DC__c</field>
        <formula>if(!(isblank(C_A_DS__c)),C_A_DS__c+Deployment_Type__r.Expected_Member_Validation_Complete__c,NULL)</formula>
        <name>update deployment sign off expected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CCC%3A Update Milestones</fullName>
        <actions>
            <name>CCC_Complete_Data_In_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CCC_Data_Diagnostics_Complete_Exp</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CCC_Deployment_Sign_Off_Exp</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CCC_Update_Initial_Data_In_Exp</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CCC_Update_Tech_Planning_Complete_Exp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCC Deployment</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.Use_Standard_Milestone_Goals__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This rule works out the CCC rules independent of the traditional Deployment Type updates facilitated by &quot;Updated Expected Milestone Dates&quot;</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CCC- E-mail BA_DA when Diag Sign off Recd</fullName>
        <actions>
            <name>CCC_Diag_Sign_Off_Recd_UAT_Onsite</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCC Deployment</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.C_A_DDC__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>E-mail BA, DA when Diagnostic Sign Off is received</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CCC- Update Milestones_2</fullName>
        <actions>
            <name>CCC_Initial_Site_Build_Complete_Exp</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CCC_Internal_Validation_Complete_Exp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CCC Deployment</value>
        </criteriaItems>
        <description>This rule works out the CCC rules independent of the traditional Deployment Type updates facilitated by &quot;Updated Expected Milestone Dates&quot;</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CMA Deployment Status Future</fullName>
        <actions>
            <name>CMA_Deployment_Statuss_Future</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.CMA_Status_Formula__c</field>
            <operation>equals</operation>
            <value>Future/On hold</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CMA Deployment</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CMA Deployment Status Green</fullName>
        <actions>
            <name>CMA_Deployment_Statuss_Green</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.CMA_Status_Formula__c</field>
            <operation>equals</operation>
            <value>Green</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CMA Deployment</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CMA Deployment Status Red</fullName>
        <actions>
            <name>CMA_Deployment_Statuss_Red</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.CMA_Status_Formula__c</field>
            <operation>equals</operation>
            <value>Red</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CMA Deployment</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CMA Deployment Status Yellow</fullName>
        <actions>
            <name>CMA_Deployment_Statuss_Yellow</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.CMA_Status_Formula__c</field>
            <operation>equals</operation>
            <value>Yellow</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CMA Deployment</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Compass%3A Business Analyst is entered</fullName>
        <actions>
            <name>Compass_Business_Analyst_is_entered_on_Deployment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>USC Deployment,INT Deployment,NUBI Deployment,QUBI Deployment,SP Deployment</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.Business_Analyst__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This sends an email to the BA when the Business Analyst is assigned on Compass Deployment record types.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass%3A Complete Data In %28Actual%29 is entered</fullName>
        <actions>
            <name>Compass_Complete_Data_In_Actual_is_entered</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>USC Deployment,INT Deployment,NUBI Deployment,QUBI Deployment,SP Deployment</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.C_A_CDI__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This sends an email to the BA when the Complete Data In (Actual) is assigned on Compass Deployment record types.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass- Auto Populate Engineer Lead - EDBI_NUBI</fullName>
        <actions>
            <name>Compass_Update_Engineer_Lead_3</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>The field &quot;Engineer Lead&quot; will be auto-populated based off the Deployment Type - EDBI, NUBI</description>
        <formula>( Deployment_Type__r.Name = &quot;EDBI&quot;)  ||  (Deployment_Type__r.Name = &quot;NUBI&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass- Auto Populate Engineer Lead - International Spend_Surgery and ED</fullName>
        <actions>
            <name>Compass_Update_Engineer_Lead_4</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>The field &quot;Engineer Lead&quot; will be auto-populated based off the Deployment Type - International Spend, International Surgery, International ED</description>
        <formula>( Deployment_Type__r.Name = &quot;International Spend&quot;)  ||  (Deployment_Type__r.Name = &quot;International Surgery&quot;)  ||  (Deployment_Type__r.Name =&quot;International ED&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass- Auto Populate Engineer Lead - SP_SCI_Spend</fullName>
        <actions>
            <name>Compass_Update_Engineer_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>The field &quot;Engineer Lead&quot; will be auto-populated based off the Deployment Type - SCI, Surgical Probability or Spend.</description>
        <formula>( Deployment_Type__r.Name = &quot;Surgical Profitability&quot;)  ||  (Deployment_Type__r.Name = &quot;Spend&quot;)  ||  (Deployment_Type__r.Name =&quot;SCI&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass- Auto Populate Engineer Lead - USC</fullName>
        <actions>
            <name>Compass_Update_Engineer_Lead_2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>The field &quot;Engineer Lead&quot; will be auto-populated based off the Deployment Type - USC</description>
        <formula>( Deployment_Type__r.Name = &quot;USC&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass- Initial Site Build Complete Actual is entered</fullName>
        <actions>
            <name>Compass_Initial_Site_Build_Complete_Actual_is_entered</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>USC Deployment,INT Deployment,NUBI Deployment,QUBI Deployment,SP Deployment</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.C_A_ISBC__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This sends an email to the BA when the Initial Site Build Complete (Actual) is entered on Compass Deployment record types.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compass- Internal Validation Complete Actual is entered</fullName>
        <actions>
            <name>Compass_Internal_Validation_Complete_Actual_is_entered</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>USC Deployment,INT Deployment,NUBI Deployment,QUBI Deployment,SP Deployment</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.C_A_IVC__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This sends an email to the BA when the Internal Validation Complete (Actual) is entered on Compass Deployment record types.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Crimson%3A Alert Mike W when Deployment Complete %28Guidelines%29</fullName>
        <actions>
            <name>Guidelines_Site_Live_Complete</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Workflow to alert Mike Willoughby when Site Live is complete in the Deployment record, and the Project shows Guidelines as a purchased module</description>
        <formula>AND( Project__r.Guidelines_Counter__c = 1,  NOT(Isblank(C_A_ISBC__c)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Deployment Name Auto-Populate</fullName>
        <actions>
            <name>Autopopulate_Deployment_Name_All_Types</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow auto-populates the Deployment Name - as per CR-20120208-384</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Populate Project Data</fullName>
        <actions>
            <name>Populate_Original_Milliman_Analyst</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.Project_Name__c</field>
            <operation>notEqual</operation>
            <value>NULL</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Expected Milestone Dates</fullName>
        <actions>
            <name>Update_Data_Audit_Received_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Data_Audit_Sign_Off_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Data_Diag_Comp_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Expected_Recurring_Update_Sign_Of</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Feedback_on_Initial_Data_Expect</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Internal_Validation_Comp_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Practice_Survey_Complete_Exp</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>pdate_Expected_TechU_Planning_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>update_deployment_sign_off_expected</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.Use_Standard_Milestone_Goals__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>CCC Deployment,CRT Deployment</value>
        </criteriaItems>
        <description>This workflow rule fires field updates to update the &apos;expected&apos; milestones based on standard timing when the &apos;Use Standard Milestone Goals&apos; field is checked</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Expected Milestone Dates_2</fullName>
        <actions>
            <name>Update_Complete_Data_In_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Data_Acquisition_Call_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Implementation_Plan_Complete_Exp</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Initial_Data_In_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Initial_Site_Build_Complete_Exp</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Initial_Site_Demo_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Measure_Mapping_Complete_Exp</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Physician_Roster_Complete_Exp</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Technical_Planning_Call_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_UAT_Onsite_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.Use_Standard_Milestone_Goals__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>CCC Deployment,CRT Deployment,Compass Connect Deployment</value>
        </criteriaItems>
        <description>This workflow rule fires field updates to update the &apos;expected&apos; milestones based on standard timing when the &apos;Use Standard Milestone Goals&apos; field is checked</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Expected Milestone Dates_3</fullName>
        <actions>
            <name>CC_Site_Build_Complete_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>DAS_Approved_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_CC_Complete_Data_In_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_CC_Initial_Data_In_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_DAS_Received_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Feedback_on_Initial_Data_Expect</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Legal_Complete_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Redlining_Complete_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Template_Sent_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.Use_Standard_Milestone_Goals__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>CCC Deployment,CRT Deployment,CMA Deployment</value>
        </criteriaItems>
        <description>This workflow rule fires field updates to update the &apos;expected&apos; milestones based on standard timing when the &apos;Use Standard Milestone Goals&apos; field is checked</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Expected Milestone Dates_4</fullName>
        <actions>
            <name>Member_Validation_Complete_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PT_Access_Granted_Date_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Project_Planning_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Success_Markers_Complete_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Initial_Site_Build_Submitted_Exp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.Use_Standard_Milestone_Goals__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>CCC Deployment,CRT Deployment</value>
        </criteriaItems>
        <description>This workflow rule fires field updates to update the &apos;expected&apos; milestones based on standard timing when the &apos;Use Standard Milestone Goals&apos; field is checked. Added as part of CR-3241</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Expected Milestone Dates_5</fullName>
        <actions>
            <name>Update_Establish_VPN_Connectivity_Expec</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Postload_Complete_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Predictive_Model_Review_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Receive_Test_Data_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Security_Clearance_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Site_Live_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Test_Site_Up_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Welcome_Call_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>update_deployment_sign_off_expected</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.Use_Standard_Milestone_Goals__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CRT Deployment</value>
        </criteriaItems>
        <description>This workflow rule fires field updates to update the &apos;expected&apos; milestones based on standard timing when the &apos;Use Standard Milestone Goals&apos; field is checked.  Created as part of CR-3570.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Expected Milestone Dates_6</fullName>
        <actions>
            <name>Update_Analysis_Target</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Bid_Management_Target</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Data_Collection_Target</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Requirements_Development_Target</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Supplier_Engagement_Target</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Welcome_Call_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.Use_Standard_Milestone_Goals__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>SSM Deployment</value>
        </criteriaItems>
        <description>This workflow rule fires field updates to update the &apos;expected&apos; milestones based on standard timing when the &apos;Use Standard Milestone Goals&apos; field is checked.  Created as part of CR-3570</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Expected Milestone Dates_7</fullName>
        <actions>
            <name>Update_Complete_Data_In_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Controlled_Mrkt_Build_Cmplt_Proj</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Deployment_Start_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Initial_Data_In_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Integration_Config_Comp_Exp</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Integration_Planning_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Integration_Testing_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Open_Market_Build_Complete_Proj</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Open_Market_Cleanup_Complte_Proj</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>update_deployment_sign_off_expected</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.Use_Standard_Milestone_Goals__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CMR Deployment</value>
        </criteriaItems>
        <description>This workflow rule fires field updates to update the &apos;expected&apos; milestones based on standard timing when the &apos;Use Standard Milestone Goals&apos; field is checked.  Created as part of CR-4062</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Expected Milestone Dates_8</fullName>
        <actions>
            <name>Update_Data_Diag_Comp_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Data_Diagnostics_Sent_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Deployment_Start_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Historical_Data_Received_Expecte</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Initial_Data_In_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Internal_Validation_Comp_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Scheduled_Site_Demo_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Technical_Planning_Call_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Training_Intensive_Onsite_Expect</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_UAT_Onsite_Expected</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deployment__c.Use_Standard_Milestone_Goals__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Deployment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CRT Deployment</value>
        </criteriaItems>
        <description>This workflow rule fires field updates to update the &apos;expected&apos; milestones based on standard timing when the &apos;Use Standard Milestone Goals&apos; field is checked.  Created as part of CR-3570.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_PopulateIntegrationFieldsFromProject</fullName>
        <actions>
            <name>FU_PopulateIntegrationEngineerClient</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_PopulateIntegrationEngineerDelivery</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Project__c != null</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
