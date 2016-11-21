<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EAB_WebConf_Cancel_Registration_Other_User</fullName>
        <description>EAB WebConf Cancel Registration Other User</description>
        <protected>false</protected>
        <recipients>
            <field>Advisory_com_Registered_By_User__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Attendee_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>webconferences@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Advisory_com_Templates/WebConf_Cancel_Registration_AdminTool</template>
    </alerts>
    <alerts>
        <fullName>EAB_WebConf_Cancel_Registration_Yourself</fullName>
        <description>EAB WebConf Cancel Registration Yourself</description>
        <protected>false</protected>
        <recipients>
            <field>Attendee_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>webconferences@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Advisory_com_Templates/WebConf_Cancel_Registration_Yourself</template>
    </alerts>
    <alerts>
        <fullName>EAB_WebConf_Register_Other_NonUser</fullName>
        <description>EAB WebConf Register Other NonUser</description>
        <protected>false</protected>
        <recipients>
            <field>Advisory_com_Registered_By_User__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Attendee_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>webconferences@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Advisory_com_Templates/WebConf_Register_Another_NonUser</template>
    </alerts>
    <alerts>
        <fullName>EAB_WebConf_Register_Other_User</fullName>
        <description>EAB WebConf Register Other User</description>
        <protected>false</protected>
        <recipients>
            <field>Advisory_com_Registered_By_User__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Attendee_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>webconferences@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Advisory_com_Templates/WebConf_Register_Another_User</template>
    </alerts>
    <alerts>
        <fullName>EAB_Webconf_Register_Yourself</fullName>
        <description>EAB Webconf Register Yourself</description>
        <protected>false</protected>
        <recipients>
            <field>Attendee_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>webconferences@eab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Advisory_com_Templates/WebConf_Register_Yourself</template>
    </alerts>
    <alerts>
        <fullName>EA_Webconf_Register_ABI</fullName>
        <description>EA_Webconf_Register_ABI</description>
        <protected>false</protected>
        <recipients>
            <field>Attendee_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Advisory_com_Templates/WebConf_Register_ABI</template>
    </alerts>
    <alerts>
        <fullName>WebConf_Cancel_Registration_Other_User</fullName>
        <description>WebConf Cancel Registration Other User</description>
        <protected>false</protected>
        <recipients>
            <field>Advisory_com_Registered_By_User__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Attendee_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>webconferences@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Advisory_com_Templates/WebConf_Cancel_Registration_AdminTool</template>
    </alerts>
    <alerts>
        <fullName>WebConf_Cancel_Registration_Yourself</fullName>
        <description>WebConf Cancel Registration Yourself</description>
        <protected>false</protected>
        <recipients>
            <field>Attendee_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>webconferences@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Advisory_com_Templates/WebConf_Cancel_Registration_Yourself</template>
    </alerts>
    <alerts>
        <fullName>WebConf_Register_Other_NonUser</fullName>
        <description>WebConf Register Other NonUser</description>
        <protected>false</protected>
        <recipients>
            <field>Advisory_com_Registered_By_User__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Attendee_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>webconferences@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Advisory_com_Templates/WebConf_Register_Another_NonUser</template>
    </alerts>
    <alerts>
        <fullName>WebConf_Register_Other_User</fullName>
        <description>WebConf Register Other User</description>
        <protected>false</protected>
        <recipients>
            <field>Advisory_com_Registered_By_User__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Attendee_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>webconferences@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Advisory_com_Templates/WebConf_Register_Another_User</template>
    </alerts>
    <alerts>
        <fullName>Webconf_Register_Yourself</fullName>
        <description>Webconf Register Yourself</description>
        <protected>false</protected>
        <recipients>
            <field>Attendee_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>webconferences@advisory.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Advisory_com_Templates/WebConf_Register_Yourself</template>
    </alerts>
    <rules>
        <fullName>EAB WebConf Cancel Registration Other</fullName>
        <actions>
            <name>EAB_WebConf_Cancel_Registration_Other_User</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send the webconference cancel registration email when an adv.com user cancels an event for another user.</description>
        <formula>Canceled__c == true &amp;&amp; Register_Other__c == true &amp;&amp;  ISPICKVAL( Site__c , &quot;EAB.com&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EAB WebConf Cancel Registration Yourself</fullName>
        <actions>
            <name>EAB_WebConf_Cancel_Registration_Yourself</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send the webconference cancel registration email when an adv.com user cancels an event for themselves.</description>
        <formula>Canceled__c == true &amp;&amp; Register_Other__c == false &amp;&amp;  ISPICKVAL( Site__c , &quot;EAB.com&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EAB WebConf Register Other NonUser</fullName>
        <actions>
            <name>EAB_WebConf_Register_Other_NonUser</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send the webconference registration email when an adv.com user registers another non-user.</description>
        <formula>AND(Register_Other__c == true,     Attendee_Site_Profile__c == null,     Canceled__c == false,     ISPICKVAL( Registered_By_Site_Profile__r.Type__c , &quot;EAB.com&quot;) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>EAB WebConf Register Other User</fullName>
        <actions>
            <name>EAB_WebConf_Register_Other_User</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send the webconference registration email when an adv.com user registers another adv.com user.</description>
        <formula>Register_Other__c == true &amp;&amp; Attendee_Site_Profile__c != null &amp;&amp;  Canceled__c == false &amp;&amp;  ISPICKVAL( Attendee_Site_Profile__r.Type__c , &quot;EAB.com&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>EAB WebConf Register Yourself</fullName>
        <actions>
            <name>EAB_Webconf_Register_Yourself</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send the webconference registration email when an adv.com user registers themself.</description>
        <formula>Register_Other__c == false &amp;&amp;  Canceled__c == false &amp;&amp; ISPICKVAL( Attendee_Site_Profile__r.Type__c , &quot;EAB.com&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WebConf Cancel Registration Other</fullName>
        <actions>
            <name>WebConf_Cancel_Registration_Other_User</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send the webconference cancel registration email when an adv.com user cancels an event for another user.</description>
        <formula>Canceled__c == true &amp;&amp; Register_Other__c == true &amp;&amp;  ISPICKVAL(  Site__c  , &quot;Advisory.com&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WebConf Cancel Registration Yourself</fullName>
        <actions>
            <name>WebConf_Cancel_Registration_Yourself</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send the webconference cancel registration email when an adv.com user cancels an event for themselves.</description>
        <formula>Canceled__c == true &amp;&amp; Register_Other__c == false &amp;&amp;  ISPICKVAL( Site__c , &quot;Advisory.com&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WebConf Register ABI</fullName>
        <actions>
            <name>EA_Webconf_Register_ABI</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Web_Conference__c.Canceled__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Web_Conference__c.Message_Type__c</field>
            <operation>equals</operation>
            <value>International</value>
        </criteriaItems>
        <description>Send the registration email when message type equals to &quot;international&quot; i.e. Web conference registration is of ABI type.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WebConf Register Other NonUser</fullName>
        <actions>
            <name>WebConf_Register_Other_NonUser</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send the webconference registration email when an adv.com user registers another non-user.</description>
        <formula>AND(Register_Other__c == true,     Attendee_Site_Profile__c == null,     Canceled__c == false,     ISPICKVAL( Registered_By_Site_Profile__r.Type__c , &quot;Advisory.com&quot;) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WebConf Register Other User</fullName>
        <actions>
            <name>WebConf_Register_Other_User</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send the webconference registration email when an adv.com user registers another adv.com user.</description>
        <formula>Register_Other__c == true &amp;&amp; Attendee_Site_Profile__c != null &amp;&amp;  Canceled__c == false &amp;&amp;  ISPICKVAL( Attendee_Site_Profile__r.Type__c , &quot;Advisory.com&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>WebConf Register Yourself</fullName>
        <actions>
            <name>Webconf_Register_Yourself</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send the webconference registration email when an adv.com user registers themself.</description>
        <formula>Register_Other__c == false &amp;&amp;  Canceled__c == false &amp;&amp; ISPICKVAL( Attendee_Site_Profile__r.Type__c , &quot;Advisory.com&quot;) &amp;&amp; NOT( ISPICKVAL( Message_Type__c , &quot;International&quot;) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
