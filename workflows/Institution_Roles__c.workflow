<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Institution_Role_Name_Update</fullName>
        <description>Set Institution Role Name = Contact Name - Role</description>
        <field>Name</field>
        <formula>Contact__r.FirstName + &quot; &quot; + Contact__r.LastName + &quot; - &quot; + TEXT(Role__c)</formula>
        <name>Institution Role Name Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Intl_HCIC</fullName>
        <field>Record_Type__c</field>
        <literalValue>International HCIC</literalValue>
        <name>Intl HCIC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Intl_Provider</fullName>
        <field>Record_Type__c</field>
        <literalValue>International Provider</literalValue>
        <name>Intl Provider</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Other</fullName>
        <field>Record_Type__c</field>
        <literalValue>Other</literalValue>
        <name>Other</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Recordtype_update_Intl_Ed</fullName>
        <field>Record_Type__c</field>
        <literalValue>International Education</literalValue>
        <name>Recordtype update: Intl Ed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>US_Corp</fullName>
        <field>Record_Type__c</field>
        <literalValue>US Corporate</literalValue>
        <name>US Corp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>US_Ed</fullName>
        <field>Record_Type__c</field>
        <literalValue>US Education</literalValue>
        <name>US Ed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>US_HCIC</fullName>
        <field>Record_Type__c</field>
        <literalValue>US HCIC</literalValue>
        <name>US HCIC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>US_Provider</fullName>
        <field>Record_Type__c</field>
        <literalValue>US Provider</literalValue>
        <name>US Provider</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Type_Intl_Corp</fullName>
        <field>Record_Type__c</field>
        <literalValue>International Corporate</literalValue>
        <name>Update Record Type: Intl Corp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Recordtype update%3A Intl Corp</fullName>
        <actions>
            <name>Update_Record_Type_Intl_Corp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Institution_Roles__c.Institution_Segment__c</field>
            <operation>equals</operation>
            <value>International Corporate</value>
        </criteriaItems>
        <description>New</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Recordtype update%3A Intl Ed</fullName>
        <actions>
            <name>Recordtype_update_Intl_Ed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Institution_Roles__c.Institution_Segment__c</field>
            <operation>equals</operation>
            <value>International Education</value>
        </criteriaItems>
        <description>New</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Recordtype update%3A Intl HCIC</fullName>
        <actions>
            <name>Intl_HCIC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Institution_Roles__c.Institution_Segment__c</field>
            <operation>equals</operation>
            <value>International HCIC</value>
        </criteriaItems>
        <description>New</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Recordtype update%3A Intl Provider</fullName>
        <actions>
            <name>Intl_Provider</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Institution_Roles__c.Institution_Segment__c</field>
            <operation>equals</operation>
            <value>International Provider</value>
        </criteriaItems>
        <description>New</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Recordtype update%3A Other</fullName>
        <actions>
            <name>Other</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Institution_Roles__c.Institution_Segment__c</field>
            <operation>equals</operation>
            <value>Other</value>
        </criteriaItems>
        <description>New</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Recordtype update%3A US Corporate</fullName>
        <actions>
            <name>US_Corp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Institution_Roles__c.Institution_Segment__c</field>
            <operation>equals</operation>
            <value>US Corporate</value>
        </criteriaItems>
        <description>New</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Recordtype update%3A US Ed</fullName>
        <actions>
            <name>US_Ed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Institution_Roles__c.Institution_Segment__c</field>
            <operation>equals</operation>
            <value>US Education</value>
        </criteriaItems>
        <description>New</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Recordtype update%3A US HCIC</fullName>
        <actions>
            <name>US_HCIC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Institution_Roles__c.Institution_Segment__c</field>
            <operation>equals</operation>
            <value>US HCIC</value>
        </criteriaItems>
        <description>New</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Recordtype update%3A US Provider</fullName>
        <actions>
            <name>US_Provider</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Institution_Roles__c.Institution_Segment__c</field>
            <operation>equals</operation>
            <value>US Provider</value>
        </criteriaItems>
        <description>New</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Institution Role Name</fullName>
        <actions>
            <name>Institution_Role_Name_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISNEW() || ISCHANGED(Name) || ISCHANGED(Contact__c) || ISCHANGED(Role__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
