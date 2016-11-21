<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Dormant_Contract_Record_Notification</fullName>
        <description>Dormant Contract Record Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Dormant_Contract_Record_Notification</template>
    </alerts>
    <alerts>
        <fullName>Dormant_Rejected_Opportunity_Notification</fullName>
        <description>Dormant Rejected Opportunity Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Dormant_Rejected_Opportunity_Notfication</template>
    </alerts>
    <fieldUpdates>
        <fullName>Contract_ABC_Historical_Linker</fullName>
        <field>Historical_Linker__c</field>
        <formula>Counter_ID__c</formula>
        <name>Contract ABC Historical Linker</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contract_Active_Checkbox_Update</fullName>
        <description>Used for Account RUSFs</description>
        <field>Active__c</field>
        <literalValue>1</literalValue>
        <name>Contract Active Checkbox Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contract_Inactive_Checkbox_Update</fullName>
        <description>Used for Account RUSFs</description>
        <field>Active__c</field>
        <literalValue>0</literalValue>
        <name>Contract Inactive Checkbox Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Contract ABC Historical Linker</fullName>
        <actions>
            <name>Contract_ABC_Historical_Linker</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  DATEVALUE(CreatedDate) &gt; DATEVALUE(&quot;2011-07-13&quot;),  OR(  Historical_Linker__c=&quot;&quot; ,  Historical_Linker__c &lt;&gt; Counter_ID__c )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Contract Active Checkbox Update</fullName>
        <actions>
            <name>Contract_Active_Checkbox_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contract__c.Active_2__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <description>(inactive)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Contract Inactive Checkbox Update</fullName>
        <actions>
            <name>Contract_Inactive_Checkbox_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contract__c.Active_2__c</field>
            <operation>equals</operation>
            <value>Inactive</value>
        </criteriaItems>
        <description>(inactive)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Dormant Contract Record Notification</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Contract__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <description>(inactive) New. Notify Finance Ops that a contract is in the hold status for greater than one week.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Dormant Rejected Opportunity Notfication</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Contract__c.Opportunity_Stage__c</field>
            <operation>equals</operation>
            <value>Sent To Finance - Opp Rejected</value>
        </criteriaItems>
        <description>(inactive) New. Alert Finance Ops that an Opportunity which was rejected has sat with a &quot;Rejected&quot; status greater than 2 days</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Dormant_Rejected_Opportunity_Notification</name>
                <type>Alert</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
