<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CT_Need_More_Information_EA</fullName>
        <description>CT: Need More Information EA</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Chairman_s_Team/CT_Need_More_Information</template>
    </alerts>
    <alerts>
        <fullName>Chairman_s_Team_Assignment_Email</fullName>
        <description>Chairman&apos;s Team Assignment Email</description>
        <protected>false</protected>
        <recipients>
            <field>CT_Assignment_s_Manager__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Owner_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>CT_Assignment__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>CT_Associate__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Chairman_s_Team/New_Chairman_s_Team_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Chairman_s_Team_Reneg_Email</fullName>
        <description>Chairman&apos;s Team Reneg Email</description>
        <protected>false</protected>
        <recipients>
            <field>Owner_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>Strat_Ops_AM_Associate_CT_Tagging</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>CT_Assignment__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>CT_Associate__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Chairman_s_Team/New_Chairman_s_Team_Reneg_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Clean_Stalled_Pipeline</fullName>
        <description>Clean Stalled Pipeline</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Marketing_Associate__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Opportunity_Needs_Updating</template>
    </alerts>
    <alerts>
        <fullName>Closed_Won_Snapshot</fullName>
        <ccEmails>emreye@advisory.com</ccEmails>
        <description>Closed Won Snapshot</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Marketing_Associate__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Closed_Won_Snapshot</template>
    </alerts>
    <alerts>
        <fullName>Email_Prompt_to_send_BAA_or_Notification</fullName>
        <description>Email Prompt to send BAA or Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Marketing_Associate__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Prompt_to_Send_BAA_and_Transition_Note</template>
    </alerts>
    <alerts>
        <fullName>Restriction_Notification</fullName>
        <description>Restriction Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>PT - Marketer</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>RI - Marketer</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Restriction_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>AM_Closed_Won_Proposal_Value_Update</fullName>
        <field>Amount</field>
        <formula>Renewal_Credit__c</formula>
        <name>AM Closed Won Proposal Value Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Allow_Opp_Edit_by_non_FinOps</fullName>
        <description>set Editable by FinOps to False when Opp is reopened.</description>
        <field>Editable_by_Finance_Ops_Only__c</field>
        <literalValue>0</literalValue>
        <name>Allow Opp Edit by non FinOps</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CT_Date_Passed_Populated_FU</fullName>
        <field>CT_Date_Passed__c</field>
        <formula>TODAY()</formula>
        <name>CT: Date Passed Populated FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Editable_by_Finance_Ops_Only</fullName>
        <description>Check the check box for editable by finance ops only</description>
        <field>Editable_by_Finance_Ops_Only__c</field>
        <literalValue>1</literalValue>
        <name>Check Editable by Finance Ops Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Current_Half_MYOO_Pool_for_AM_Group</fullName>
        <field>Current_Half_MYOO_Pool_for_AM_Group__c</field>
        <formula>0</formula>
        <name>Current Half MYOO Pool for AM Group</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Current_Half_MYOO_Pool_for_owner</fullName>
        <field>Current_Half_MYOO_Pool_for_owner__c</field>
        <formula>0</formula>
        <name>Current Half MYOO Pool for owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Current_Half_New_LOA_Pool_for_AM_Group</fullName>
        <field>Current_Half_New_LOA_Pool_for_AM_Group__c</field>
        <formula>0</formula>
        <name>Current Half New LOA Pool for AM Group</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Current_Half_New_LOA_Pool_for_owner</fullName>
        <field>Current_Half_New_LOA_Pool_for_owner__c</field>
        <formula>0</formula>
        <name>Current Half New LOA Pool for owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Current_Half_Total_Pool_for_AM_Group</fullName>
        <field>Current_Half_Total_Pool_for_AM_Group__c</field>
        <formula>0</formula>
        <name>Current Half Total Pool for AM Group</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Current_Half_Total_Pool_for_owner</fullName>
        <field>Current_Half_Total_Pool_for_owner__c</field>
        <formula>0</formula>
        <name>Current Half Total Pool for owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Current_Year_Total_Pool_for_AM_Group</fullName>
        <field>Current_Year_Total_Pool_for_AM_Group__c</field>
        <formula>0</formula>
        <name>Current Year Total Pool for AM Group</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Current_Year_Total_Pool_for_Owner</fullName>
        <field>Current_Year_Total_Pool_for_Owner__c</field>
        <formula>0</formula>
        <name>Current Year Total Pool for Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Competitive_Intel_Last_Updated</fullName>
        <field>EvalCompOrRIComp_LastModifiedDate__c</field>
        <formula>TODAY()</formula>
        <name>FU Competitive Intel Last Updated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_EngagementLetterSent</fullName>
        <field>Engagement_Letter_Sent__c</field>
        <literalValue>1</literalValue>
        <name>FU_EngagementLetterSent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Set_Projection_Likelihood_To_Null</fullName>
        <description>Field Update to set blank/null as a value for &quot;Projection Likelihood&quot; field. Created for CR-20160108-9499.</description>
        <field>Projection_Liklihood__c</field>
        <name>FU_Set_Projection_Likelihood_To_Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Set_Renewal_Health_To_Null</fullName>
        <description>Field Update to set blank/null as a value for &quot;Renewal Health&quot; field. Created for CR-20160108-9499.</description>
        <field>Program_Rate_Projections__c</field>
        <name>FU_Set_Renewal_Health_To_Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Initial_Fast_Track_Value_FU</fullName>
        <field>Initial_Fast_Track_Value__c</field>
        <formula>Amount</formula>
        <name>Initial Fast Track Value FU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Max_Opportunity_Update</fullName>
        <field>Maximum_Opportunity_Amount__c</field>
        <formula>Amount</formula>
        <name>Max Opportunity Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OPP_Update_Evaluated</fullName>
        <description>CR-20111216-283</description>
        <field>Evaluated__c</field>
        <formula>1</formula>
        <name>OPP: Update Evaluated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opp_Stage_Outreach</fullName>
        <description>if &apos;Initial Visit Date&apos; is null AND stage = &quot;Initial Visit Scheduled&quot; then set stage = &quot;Outreach&quot;</description>
        <field>StageName</field>
        <literalValue>Outreach</literalValue>
        <name>Opp Stage-Outreach</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Historical_Linker</fullName>
        <field>Historical_Linker__c</field>
        <formula>Counter_ID__c</formula>
        <name>Opportunity Historical Linker</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Active_in_Fastrack_on_SW</fullName>
        <field>Date_First_Entered_Active_in_Fastrack__c</field>
        <formula>TODAY()</formula>
        <name>Populate Active in Fastrack on SW</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Engagement_Letter_Sent_on_SW</fullName>
        <field>Engagement_Letter_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Populate Engagement Letter Sent on SW</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Owner_Manager_Email</fullName>
        <field>Owner_Manager_Email__c</field>
        <formula>Owner.Manager.Email</formula>
        <name>Populate Owner Manager Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Proposal_in_Progress_on_SW</fullName>
        <field>Date_First_Entered_Proposal_in_Progress__c</field>
        <formula>TODAY()</formula>
        <name>Populate Proposal in Progress on SW</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Probability_plus_10</fullName>
        <field>Probability</field>
        <formula>IF( Probability  &lt;&gt; 1,  Probability  + (1/10),0 
)</formula>
        <name>Probability plus 10</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Proposal_Amount_Posted_Proposal_Value</fullName>
        <field>Amount</field>
        <formula>Posted_Proposal_Value__c</formula>
        <name>Proposal Amount = Posted Proposal Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Proposal_Value_Update_AM_Pending_Opps</fullName>
        <field>Amount</field>
        <formula>Previous_Year_Negotiated_Credit__c</formula>
        <name>Proposal Value Update AM Pending Opps</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Renewal_Likelihood_to</fullName>
        <field>Probability</field>
        <formula>IF(ISPICKVAL(Renewal_Likelihood__c, &quot;0%&quot;),0, IF(ISPICKVAL(Renewal_Likelihood__c, &quot;20%&quot;),0.20, IF(ISPICKVAL(Renewal_Likelihood__c, &quot;40%&quot;),0.40, IF(ISPICKVAL(Renewal_Likelihood__c, &quot;60%&quot;),0.60,IF(ISPICKVAL(Renewal_Likelihood__c, &quot;80%&quot;),0.80, IF(ISPICKVAL(Renewal_Likelihood__c, &quot;95%&quot;),0.95,0))))))</formula>
        <name>Renewal Likelihood to %</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_AM_Opp_Close_Date</fullName>
        <field>CloseDate</field>
        <formula>Previous_Contract__r.Start__c</formula>
        <name>Set AM Opp Close Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Grade_to_Null</fullName>
        <description>Updates grade to null value for closed renewal opportunities</description>
        <field>Grade__c</field>
        <name>Set Grade to Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Timestamp</fullName>
        <field>Probability_Field_Update__c</field>
        <formula>Today()</formula>
        <name>Timestamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Trigger_Update_Checkbox</fullName>
        <field>Trigger_Update__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Trigger Update Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Calc_Close_Date</fullName>
        <description>updates calculated close date to Today().</description>
        <field>Calculated_Close_Date__c</field>
        <formula>Today()</formula>
        <name>Update Calc Close Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opp_Notes_Dedicated_Advisor</fullName>
        <description>Added as part of CR-3139</description>
        <field>Notes_Dedicated_Advisor__c</field>
        <formula>Membership__r.Notes_Dedicated_Advisor__c</formula>
        <name>Update Opp Notes: Dedicated Advisor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Proposal_Amount_to_0</fullName>
        <description>Deactivated 2/9/11.  Closed AM opps should equal renewal credit, closed/lost nbb opps should retain proposal value</description>
        <field>Amount</field>
        <formula>0</formula>
        <name>Update Proposal Amount to 0</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Proposal_Amount_to_NBB</fullName>
        <field>Amount</field>
        <formula>NBB__c</formula>
        <name>Update Proposal Amount to NBB</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_current_Date</fullName>
        <field>Stage_Change_Date__c</field>
        <formula>Today()</formula>
        <name>Update to current Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>X80_50_Forecast_Field_Update</fullName>
        <field>Forecasted__c</field>
        <literalValue>1</literalValue>
        <name>80/50 Forecast Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>X80_50_Won</fullName>
        <field>Month_80_50__c</field>
        <literalValue>Won</literalValue>
        <name>80/50 Won</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>%25 Likely To Close to Probability Update</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Likely_to_Close__c</field>
            <operation>equals</operation>
            <value>0%,20%,80%,40%,60%</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.IsWon</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>New. % likely to close will update probability</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>80%2F50 Forecast Stamp</fullName>
        <actions>
            <name>X80_50_Forecast_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>notEqual</operation>
            <value>Disqualified,Closed Lost</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Month_80_50__c</field>
            <operation>equals</operation>
            <value>Wildcard,80,Won,50</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Royall</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Active in Fastrack Updates</fullName>
        <actions>
            <name>Initial_Fast_Track_Value_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL( StageName, &quot;Active in FastTrack&quot;) &amp;&amp; ISBLANK( Initial_Fast_Track_Value__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Active in Fastrack first selected</fullName>
        <actions>
            <name>Populate_Active_in_Fastrack_on_SW</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Southwind</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Active in FastTrack</value>
        </criteriaItems>
        <description>This rule populates the field &quot;Active in Fastrack&quot; with Today&apos;s date when it is selected as a Stage value.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Budget Secured</fullName>
        <actions>
            <name>Probability_plus_10</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Budget_Secured__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Business Case Established Checkbox</fullName>
        <actions>
            <name>Probability_plus_10</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Business_Case_Established__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CT%3A Date Passed Populated</fullName>
        <actions>
            <name>CT_Date_Passed_Populated_FU</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.CT_Pass_Status__c</field>
            <operation>equals</operation>
            <value>Ready for Assignment</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Royall</value>
        </criteriaItems>
        <description>Populate CT: Date Passed with Today&apos;s date when CT: Pass Status = &quot;Ready for Assignment&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CT%3A Need More Information</fullName>
        <actions>
            <name>CT_Need_More_Information_EA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.CT_Pass_Status__c</field>
            <operation>equals</operation>
            <value>Need more info</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Royall</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Calc Close Date Update</fullName>
        <actions>
            <name>Update_Calc_Close_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Royall</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Chairman%27s Team Assignment</fullName>
        <actions>
            <name>Chairman_s_Team_Assignment_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 4 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Opportunity.CT_Pass_Status__c</field>
            <operation>equals</operation>
            <value>Assigned</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CT_Reneg_Attempt__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CT_Reneg_Attempt__c</field>
            <operation>equals</operation>
            <value>No</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Royall</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Chairman%27s Team Reneg Attempt</fullName>
        <actions>
            <name>Chairman_s_Team_Reneg_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.CT_Reneg_Attempt__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CT_Pass_Status__c</field>
            <operation>equals</operation>
            <value>Assigned</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Royall</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Changed Owner</fullName>
        <actions>
            <name>Populate_Owner_Manager_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( OwnerId ) || ISNEW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Check Engagement Letter Sent</fullName>
        <actions>
            <name>Populate_Engagement_Letter_Sent_on_SW</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule checks the field &quot;Engagament Letter Sent&quot; when First EL Sent Date is populated</description>
        <formula>AND(   RecordType.DeveloperName = &quot;Southwind&quot;,   !ISNULL( First_EL_Sent_Date__c )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Clean Stalled Opportunity</fullName>
        <actions>
            <name>Clean_Stalled_Pipeline</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Stage_Age__c</field>
            <operation>greaterThan</operation>
            <value>14</value>
        </criteriaItems>
        <description>(inactive)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Closing Call Needs to Occur</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Closing_Call_Scheduled__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won,Honorary,ATL,Contract Received - Send to Finance</value>
        </criteriaItems>
        <description>(inactive) New. Reminder that a closing call needs to occur.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Contract Close Won Snapshot</fullName>
        <actions>
            <name>Closed_Won_Snapshot</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <description>(inactive)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Contract Closing without sent BAA%2FNotification</fullName>
        <actions>
            <name>Email_Prompt_to_send_BAA_or_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Send_BAA_or_Notification__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <description>(inactive)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DA Check-in Call Notification</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Member_Checkin_Call_Completed__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>(inactive) New. Incomplete. Alert Sales Team role account manager that a DA Check in call has been scheduled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Decision Maker Enfranchised</fullName>
        <actions>
            <name>Probability_plus_10</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.No_of_Visit_Attendees__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Decision Maker Identified</fullName>
        <actions>
            <name>Probability_plus_10</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Was_Decision_Maker_Prewired__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Dormant Slow Track Reminder</fullName>
        <actions>
            <name>Dormant_Slow_Track_Reminder</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <description>(inactive) New.</description>
        <formula>LastActivityDate  &lt; Today () - 40 &amp;&amp;  CloseDate  &lt; Today ()</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Dormant Slow Track Reminder%2E</fullName>
        <actions>
            <name>Please_complete_an_activity_or_disqualify_Opportunity</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <description>(inactive) New. Reminder to the Marketers to complete an activity with an Opp or disqualify Opp</description>
        <formula>(LastModifiedDate)&lt; Now() - 30 &amp;&amp; (LastActivityDate)  &lt; Today() - 30</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Fin Ops to edit</fullName>
        <actions>
            <name>Check_Editable_by_Finance_Ops_Only</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Royall</value>
        </criteriaItems>
        <description>New.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LOA Needs to be Sent Reminder</fullName>
        <actions>
            <name>Please_Send_LOA_for_Closed_Opportunity</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Opportunity.LOA_Sent__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.LOA_Sent_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>lessThan</operation>
            <value>NEXT 120 DAYS</value>
        </criteriaItems>
        <description>(inactive) New.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Maximum Opportunity Threshold</fullName>
        <actions>
            <name>Max_Opportunity_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>New.Going to populate Maximum Opportunity Amount with the highest possible amount recorded for the opportunity</description>
        <formula>RecordType.DeveloperName != &apos;Royall&apos; &amp;&amp; ischanged(Amount) &amp;&amp; Amount  &gt;  Maximum_Opportunity_Amount__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>OPP%3A Update Evaluated</fullName>
        <actions>
            <name>OPP_Update_Evaluated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>6 AND (((1 OR 2) AND 3) OR (4 AND 5 AND (1 OR 2)))</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Evaluated__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Evaluated__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Active in FastTrack</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.IsWon</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Initial_Visit_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Royall</value>
        </criteriaItems>
        <description>CR-20111216-283:  pop Evaluated__c when:Evaluated=null or 0,Are They Evaluating=Yes,Is There a Hard Next Step=Yes,Number of Follow-Up Activities&gt;0,Stage=Active in Fast Track, CR-20120417-731 adds:Evaluated=null or 0, Initial visit Date&lt;&gt;null,Won=True</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opp-Initial Visit removed%2C Update State</fullName>
        <actions>
            <name>Opp_Stage_Outreach</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Initial Visit Scheduled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Initial_Visit_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Royall</value>
        </criteriaItems>
        <description>if &apos;Initial Visit Date&apos; is null AND stage = &quot;Initial Visit Scheduled&quot; then set stage = &quot;Outreach&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Historical Linker</fullName>
        <actions>
            <name>Opportunity_Historical_Linker</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  DATEVALUE(CreatedDate) &gt; DATEVALUE(&quot;2011-07-13&quot;),  OR(  Historical_Linker__c=&quot;&quot; ,  Historical_Linker__c &lt;&gt; Counter_ID__c )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Reopened</fullName>
        <actions>
            <name>Allow_Opp_Edit_by_non_FinOps</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Editable_by_Finance_Ops_Only__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Royall</value>
        </criteriaItems>
        <description>When an Opp is reported (no longer in a closed stage), set the Editable by FinanceOps to False so all users can edit.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Pipeline Overlap Notification</fullName>
        <actions>
            <name>Opp_Owner_Pipeline_Overlap_Notification</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.Active_NBB_Opps_on_Account__c</field>
            <operation>greaterThan</operation>
            <value>1</value>
        </criteriaItems>
        <description>(inactive) Reviewed on 12.30.10 KEEP</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Probability %3D 15</fullName>
        <actions>
            <name>Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Probability</field>
            <operation>equals</operation>
            <value>15</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Probability %3D 20</fullName>
        <actions>
            <name>Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Probability</field>
            <operation>equals</operation>
            <value>20</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Probability %3D 25</fullName>
        <actions>
            <name>Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Probability</field>
            <operation>equals</operation>
            <value>25</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Probability %3D 5</fullName>
        <actions>
            <name>Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Probability</field>
            <operation>equals</operation>
            <value>5</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Probability %3D10</fullName>
        <actions>
            <name>Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Probability</field>
            <operation>equals</operation>
            <value>10</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Probability %3D100</fullName>
        <actions>
            <name>Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Probability</field>
            <operation>equals</operation>
            <value>100</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Probability %3D30</fullName>
        <actions>
            <name>Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Probability</field>
            <operation>equals</operation>
            <value>30</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Probability %3D35</fullName>
        <actions>
            <name>Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Probability</field>
            <operation>equals</operation>
            <value>35</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Probability %3D40</fullName>
        <actions>
            <name>Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Probability</field>
            <operation>equals</operation>
            <value>40</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Probability %3D45</fullName>
        <actions>
            <name>Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Probability</field>
            <operation>equals</operation>
            <value>45</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Probability %3D50</fullName>
        <actions>
            <name>Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Probability</field>
            <operation>equals</operation>
            <value>50</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Probability %3D55</fullName>
        <actions>
            <name>Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Probability</field>
            <operation>equals</operation>
            <value>55</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Probability %3D60</fullName>
        <actions>
            <name>Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Probability</field>
            <operation>equals</operation>
            <value>60</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Probability %3D70</fullName>
        <actions>
            <name>Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Probability</field>
            <operation>equals</operation>
            <value>70</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Probability %3D80</fullName>
        <actions>
            <name>Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Probability</field>
            <operation>equals</operation>
            <value>80</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Probability %3D90</fullName>
        <actions>
            <name>Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Probability</field>
            <operation>equals</operation>
            <value>90</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Proposal Sent Checkbox</fullName>
        <actions>
            <name>Probability_plus_10</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Proposal_Sent__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Proposal Value Update AM Pending Opps</fullName>
        <actions>
            <name>Proposal_Value_Update_AM_Pending_Opps</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>PT Contract Maintenance,PT Contract Renewal,RI AM First Year Opp,RI AM Standard Opp</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Pending- Renewal Call Comp &amp; Evaluating,Pending- Renewal Call Comp &amp; Contracting,Pending- Renewal Call Not Yet Occured,Pending</value>
        </criteriaItems>
        <description>Sets proposal value equal to value of prev. neg. credit if prop value = 0, is an AM opp, and stage contains pending.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Proposal Value Updates are Open</fullName>
        <actions>
            <name>Proposal_Amount_Posted_Proposal_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>notEqual</operation>
            <value>Closed Won,Honorary,Closed Lost,Dropped,Closed,Void,Contract Received - Send to Finance,Disqualified,ATL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Royall</value>
        </criteriaItems>
        <description>New.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Proposal Value Updates when Closed Lost</fullName>
        <actions>
            <name>Update_Proposal_Amount_to_0</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Disqualified,Closed Lost,Dropped,Void</value>
        </criteriaItems>
        <description>(inactive) New [This field update should not be active]</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Proposal Value Updates when Closed Won</fullName>
        <actions>
            <name>Update_Proposal_Amount_to_NBB</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 3 AND (2 OR 4)</booleanFilter>
        <criteriaItems>
            <field>Opportunity.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>PT Marketing,RI Marketing</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.IsWon</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Program – PT Marketing,Program – RI Marketing</value>
        </criteriaItems>
        <description>New.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Proposal Value Updates when Closed Won for AM</fullName>
        <actions>
            <name>AM_Closed_Won_Proposal_Value_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Grade_to_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won,Honorary,Closed Lost,Dropped,Closed,Void,Disqualified,ATL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>PT Contract Maintenance,PT Contract Renewal,RI AM First Year Opp,RI AM Standard Opp</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Program – PT Contract Maintenance,Program – PT Contract Renewal,Program – RI AM First Year Opp,Program – RI AM Standard Opp</value>
        </criteriaItems>
        <description>New.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Proposal in Progress first selected</fullName>
        <actions>
            <name>Populate_Proposal_in_Progress_on_SW</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule populates the field &quot;Proposal in Progress&quot; with Today&apos;s date when it is selected as a Stage value.</description>
        <formula>AND(  RecordType.DeveloperName = &quot;Southwind&quot;,  ISPICKVAL( StageName ,&quot;Proposal In Progress&quot; )   )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Renewal Likelihood to %25</fullName>
        <actions>
            <name>Renewal_Likelihood_to</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Renewal_Likelihood__c</field>
            <operation>equals</operation>
            <value>0%,20%,80%,40%,60%,95%</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.IsWon</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Royall</value>
        </criteriaItems>
        <description>New. Renewal Likelihood will update probability</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Restriction Notification</fullName>
        <actions>
            <name>Restriction_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.Account_Restriction_Status__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>BI Contract Renewal</value>
        </criteriaItems>
        <description>(inactive) New.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Restriction Notification on Renewal Opp</fullName>
        <actions>
            <name>Restriction_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.Account_Restriction_Status__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>BI Contract Renewal</value>
        </criteriaItems>
        <description>(inactive) New. Same as Restriction Notification but with the added fact that its on a BI contract renewal Opportunity.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set AM Opp Close Date</fullName>
        <actions>
            <name>Set_AM_Opp_Close_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Checks if stage contains pending or decision type is opt out, if true set close date value with Start Date, else close date equals today (for AM opps)</description>
        <formula>NOT(ISBLANK(Previous_Contract__c)) &amp;&amp;  NOT(ISBLANK(Previous_Contract__r.Start__c)) &amp;&amp;  (   $RecordType.Name = &apos;PT Contract Maintenance&apos; ||    $RecordType.Name = &apos;PT Contract Renewal&apos; ||    $RecordType.Name = &apos;RI AM First Year Opp&apos; ||    $RecordType.Name = &apos;RI AM Standard Opp&apos; ||   $RecordType.Name = &apos;Program - PT Contract Maintenance&apos; ||    $RecordType.Name = &apos;Program - PT Contract Renewal&apos; ||    $RecordType.Name = &apos;Program - RI AM First Year Opp&apos; ||    $RecordType.Name = &apos;Program - RI AM Standard Opp&apos;  ) &amp;&amp;  (    (      ISPICKVAL(StageName, &apos;Pending- Renewal Call Comp &amp; Evaluating&apos;) ||      ISPICKVAL(StageName, &apos;Pending- Renewal Call Comp &amp; Contracting&apos;) ||      ISPICKVAL(StageName, &apos;Pending- Renewal Call Not Yet Occured&apos;) ||      ISPICKVAL(StageName, &apos;Pending&apos;)    ) || ISPICKVAL(Decision_Type__c, &apos;Opt Out&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stage is Active in SlowTrack</fullName>
        <actions>
            <name>Update_to_current_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Active in SlowTrack</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stage is Initial Visit</fullName>
        <actions>
            <name>Update_to_current_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Initial Visit Scheduled</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stage is Outreach</fullName>
        <actions>
            <name>Update_to_current_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Outreach</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Royall</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stage is Prewire</fullName>
        <actions>
            <name>Update_to_current_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Prewire</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stage is Verbal Yes</fullName>
        <actions>
            <name>Update_to_current_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Verbal Yes</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Uncheck Trigger Update Checkbox</fullName>
        <actions>
            <name>Uncheck_Trigger_Update_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Trigger_Update__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Notes%3A Dedicated Advisor</fullName>
        <actions>
            <name>Update_Opp_Notes_Dedicated_Advisor</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Added as per CR-3139</description>
        <formula>NOT( ISBLANK( Membership__c ) || ISCHANGED (Membership__c) || ISNEW () )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ValidatPoolFields</fullName>
        <actions>
            <name>Current_Half_MYOO_Pool_for_AM_Group</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Current_Half_MYOO_Pool_for_owner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Current_Half_New_LOA_Pool_for_AM_Group</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Current_Half_New_LOA_Pool_for_owner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Current_Half_Total_Pool_for_AM_Group</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Current_Half_Total_Pool_for_owner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Current_Year_Total_Pool_for_AM_Group</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Current_Year_Total_Pool_for_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Royall</value>
        </criteriaItems>
        <description>When the Opportunity field &apos;Closed&apos; = True,  Change the value of these fields to &apos;0&apos;.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_EngagementLetterSent</fullName>
        <actions>
            <name>FU_EngagementLetterSent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  RecordType.DeveloperName = &quot;Southwind&quot;,   !ISNULL( First_EL_Sent_Date__c )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WF_OppForecastLastModifiedDate</fullName>
        <actions>
            <name>FU_Competitive_Intel_Last_Updated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(RecordType.DeveloperName != &apos;Royall&apos;, OR (  AND (   ISNEW(),   OR (    NOT(ISPICKVAL(Is_the_Evaluation_Competitive__c ,&apos;&apos;)),    OR (        NOT(ISBLANK(R_I_Competitors__c)),     NOT(ISNULL(R_I_Competitors__c))    )   )  ),  OR (   ISCHANGED(Is_the_Evaluation_Competitive__c),   ISCHANGED(R_I_Competitors__c)  ) ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_SET_NULL_VALUE_FOR_Renewal_Health</fullName>
        <actions>
            <name>FU_Set_Renewal_Health_To_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>PT Marketing,RI Marketing,Consulting &amp; Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Program – Consulting &amp; Management,Program – PT Marketing,Program – RI Marketing</value>
        </criteriaItems>
        <description>Workflow rule to set blank/null value for the &quot;Renewal Health&quot; field. If the opportunity record type equals to (PT Marketing/RI Marketing/Consulting &amp; Management). Created for CR-20160108-9499.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WF_Set_Null_As_Value_For_Fields_OF_Closed_Opp</fullName>
        <actions>
            <name>FU_Set_Projection_Likelihood_To_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_Set_Renewal_Health_To_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Royall</value>
        </criteriaItems>
        <description>Workflow rule to set blank/null as a value for Projection Likelihood and Renewal Health
opportunity fields. When the opportunity &quot;closed&quot; = true. Created for CR-20160108-9499.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Won Opp 80%2F50 Update</fullName>
        <actions>
            <name>X80_50_Won</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Royall</value>
        </criteriaItems>
        <description>Updates 80/50 field to Won if opp is Closed Won</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Chairmans_Team_Pipeline_Overlap_Notification</fullName>
        <assignedTo>PT - Chairman&apos;s Team</assignedTo>
        <assignedToType>opportunityTeam</assignedToType>
        <description>There is another Opportunity that is &apos;active&apos; with a stage of &apos;fast track&apos; or &apos;initial visit scheduled&apos; with the same Institution.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Chairman&apos;s Team: Pipeline Overlap Notification</subject>
    </tasks>
    <tasks>
        <fullName>Cheif_of_Staff_Pipeline_Overlap_Notification</fullName>
        <assignedTo>PT - Chief of Staff</assignedTo>
        <assignedToType>opportunityTeam</assignedToType>
        <description>There is another Opportunity that is &apos;active&apos; with a stage of &apos;fast track&apos; or &apos;initial visit scheduled&apos; with the same Institution.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Cheif of Staff: Pipeline Overlap Notification</subject>
    </tasks>
    <tasks>
        <fullName>Closing_Call_Needs_to_Occur</fullName>
        <assignedToType>owner</assignedToType>
        <description>Its been 40 days since you&apos;ve closed your opportunity.  Please schedule a Closing Call.</description>
        <dueDateOffset>5</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Closing Call Needs to Occur</subject>
    </tasks>
    <tasks>
        <fullName>Dormant_Rejected_Opportunity_Notification</fullName>
        <assignedTo>sfadmin@advisory.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>The opportunity has been in the &quot;Sent to Finance - Rejected Opp&quot; for more than 2 days.  Please take the necessary action to move this opportunity out of this stage.</description>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Dormant Rejected Opportunity Notification</subject>
    </tasks>
    <tasks>
        <fullName>Dormant_Slow_Track_Reminder</fullName>
        <assignedTo>RI - Marketer</assignedTo>
        <assignedToType>opportunityTeam</assignedToType>
        <description>Please create an Activity on this Opportunity or disqualify the Opportunity.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Dormant Slow Track Reminder</subject>
    </tasks>
    <tasks>
        <fullName>Leadership_Team_Pipeline_Overlap_Notification</fullName>
        <assignedTo>PT - Leadership Team</assignedTo>
        <assignedToType>opportunityTeam</assignedToType>
        <description>There is another Opportunity that is &apos;active&apos; with a stage of &apos;fast track&apos; or &apos;initial visit scheduled&apos; with the same Institution.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Leadership Team: Pipeline Overlap Notification</subject>
    </tasks>
    <tasks>
        <fullName>Opp_Owner_Pipeline_Overlap_Notification</fullName>
        <assignedToType>owner</assignedToType>
        <description>There is another Opportunity that is &apos;active&apos; with a stage of &apos;fast track&apos; or &apos;initial visit scheduled&apos; with the same Institution.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Opp Owner: Pipeline Overlap Notification</subject>
    </tasks>
    <tasks>
        <fullName>Please_Send_LOA_for_Closed_Opportunity</fullName>
        <assignedToType>owner</assignedToType>
        <description>Please send the LOA for this closed Opportunity and fill out the corresponding LOA sent field on the Opportunity record.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Please Send LOA for Closed Opportunity</subject>
    </tasks>
    <tasks>
        <fullName>Please_complete_an_activity_or_disqualify_Opportunity</fullName>
        <assignedToType>owner</assignedToType>
        <description>It has been 30 days since you have modified or had an activity with the opportunity.  Please complete an activity or disqualify the Opp.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Please complete an activity or disqualify Opportunity</subject>
    </tasks>
    <tasks>
        <fullName>Reapproach_date_within_30_days</fullName>
        <assignedTo>PT - Marketing Associate</assignedTo>
        <assignedToType>opportunityTeam</assignedToType>
        <description>This is a reminder that the re-approach date on one of your opportunities is in 30 days or less.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.Re_approach_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Reapproach date within 30 days</subject>
    </tasks>
    <tasks>
        <fullName>core_Reapproach_date_within_30_days</fullName>
        <assignedTo>RI - Marketing Associate</assignedTo>
        <assignedToType>opportunityTeam</assignedToType>
        <description>This is a reminder that the re-approach date on one of your opportunities is in 30 days or less.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.Re_approach_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Reapproach date within 30 days</subject>
    </tasks>
</Workflow>
