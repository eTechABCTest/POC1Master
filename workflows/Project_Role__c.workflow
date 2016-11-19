<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CMA_Data_Load_Reminder</fullName>
        <description>CMA Data Load Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CMA_Email_Templates/CMA_Data_Load_Reminder</template>
    </alerts>
    <fieldUpdates>
        <fullName>Project_Role_Name_Field</fullName>
        <description>used to enforce naming convention for project role</description>
        <field>Name</field>
        <formula>Contact__r.FirstName &amp; &quot; &quot; &amp; Contact__r.LastName  &amp;&quot; - &quot; &amp; Text(Role__c)</formula>
        <name>Project Role Name Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CMA Data Load Reminder - Monthly</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Project__c.Load_Frequency__c</field>
            <operation>equals</operation>
            <value>Monthly</value>
        </criteriaItems>
        <criteriaItems>
            <field>Project_Role__c.Receive_Data_Load_Reminder__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Project_Role__c.Project_Type__c</field>
            <operation>equals</operation>
            <value>CMA</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CMA_Data_Load_Reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Project_Role__c.Project_Next_Data_Upload_Expected_On__c</offsetFromField>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CMA Data Load Reminder - Quarterly</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Project__c.Load_Frequency__c</field>
            <operation>equals</operation>
            <value>Quarterly</value>
        </criteriaItems>
        <criteriaItems>
            <field>Project_Role__c.Receive_Data_Load_Reminder__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Project_Role__c.Project_Type__c</field>
            <operation>equals</operation>
            <value>CMA</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CMA_Data_Load_Reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Project_Role__c.Project_Next_Data_Upload_Expected_On__c</offsetFromField>
            <timeLength>-14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Project Role Name</fullName>
        <actions>
            <name>Project_Role_Name_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Project_Role__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
