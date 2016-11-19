<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FU_Email_Re_Open_Case_Status</fullName>
        <description>Created for CR-20140827-7164. Will be applicable for re-opening of already closed cases.</description>
        <field>Status</field>
        <literalValue>In Progress</literalValue>
        <name>FU_Email_Re_Open_Case_Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New_Mail_update</fullName>
        <field>New_Mail__c</field>
        <literalValue>1</literalValue>
        <name>New Mail update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>New Case Mail</fullName>
        <actions>
            <name>New_Mail_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>eTech Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>New</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WF_Email_Re_Opens_Support_Case</fullName>
        <actions>
            <name>FU_Email_Re_Open_Case_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Created for CR-20140827-7164.</description>
        <formula>AND ( Incoming = true,  Parent.IsClosed = true,  Parent.RecordType.DeveloperName = &quot;Member_Employee_Support&quot;, Parent.Owner:Queue.DeveloperName = &quot;Events_Member_Support&quot; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
