//Generated by wsdl2apex
/** 
  * Description     :   Web Service class to validate Address info for recipient and sender infor on fedEx Side.
  *
  * Created By      :   Rajeev Jain(Simplyforce)
  *
  * Created Date    :   03/18/2015
  *
  * Version         :   V1.0 Created
  * 
  **/
public without sharing class ShipItFedExAddressValidationService {
    public class AddressValidationResult {
        public String ClientReferenceId;
        public String State;
        public String Classification;
        public ShipItFedExAddressValidationService.Contact EffectiveContact;
        public ShipItFedExAddressValidationService.Address EffectiveAddress;
        public ShipItFedExAddressValidationService.ParsedAddressPartsDetail ParsedAddressPartsDetail;
        public ShipItFedExAddressValidationService.AddressAttribute[] Attributes;
        private String[] ClientReferenceId_type_info = new String[]{'ClientReferenceId','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] State_type_info = new String[]{'State','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] Classification_type_info = new String[]{'Classification','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] EffectiveContact_type_info = new String[]{'EffectiveContact','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] EffectiveAddress_type_info = new String[]{'EffectiveAddress','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] ParsedAddressPartsDetail_type_info = new String[]{'ParsedAddressPartsDetail','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] Attributes_type_info = new String[]{'Attributes','http://fedex.com/ws/addressvalidation/v3',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://fedex.com/ws/addressvalidation/v3','true','true'};
        private String[] field_order_type_info = new String[]{'ClientReferenceId','State','Classification','EffectiveContact','EffectiveAddress','ParsedAddressPartsDetail','Attributes'};
    }
    public class NotificationParameter {
        public String Id;
        public String Value;
        private String[] Id_type_info = new String[]{'Id','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] Value_type_info = new String[]{'Value','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://fedex.com/ws/addressvalidation/v3','true','true'};
        private String[] field_order_type_info = new String[]{'Id','Value'};
    }
    public class ParsedAddressPartsDetail {
        public ShipItFedExAddressValidationService.ParsedStreetLineDetail ParsedStreetLine;
        public ShipItFedExAddressValidationService.ParsedPostalCodeDetail ParsedPostalCode;
        private String[] ParsedStreetLine_type_info = new String[]{'ParsedStreetLine','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] ParsedPostalCode_type_info = new String[]{'ParsedPostalCode','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://fedex.com/ws/addressvalidation/v3','true','true'};
        private String[] field_order_type_info = new String[]{'ParsedStreetLine','ParsedPostalCode'};
    }
    public class AddressToValidate {
        public String ClientReferenceId;
        public ShipItFedExAddressValidationService.Contact Contact;
        public ShipItFedExAddressValidationService.Address Address;
        private String[] ClientReferenceId_type_info = new String[]{'ClientReferenceId','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] Contact_type_info = new String[]{'Contact','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] Address_type_info = new String[]{'Address','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://fedex.com/ws/addressvalidation/v3','true','true'};
        private String[] field_order_type_info = new String[]{'ClientReferenceId','Contact','Address'};
    }
    public class AddressValidationReply {
        public String HighestSeverity;
        public ShipItFedExAddressValidationService.Notification[] Notifications;
        public ShipItFedExAddressValidationService.TransactionDetail TransactionDetail;
        public ShipItFedExAddressValidationService.VersionId Version;
        public DateTime ReplyTimestamp;
        public ShipItFedExAddressValidationService.AddressValidationResult[] AddressResults;
        private String[] HighestSeverity_type_info = new String[]{'HighestSeverity','http://fedex.com/ws/addressvalidation/v3',null,'1','1','false'};
        private String[] Notifications_type_info = new String[]{'Notifications','http://fedex.com/ws/addressvalidation/v3',null,'1','-1','false'};
        private String[] TransactionDetail_type_info = new String[]{'TransactionDetail','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] Version_type_info = new String[]{'Version','http://fedex.com/ws/addressvalidation/v3',null,'1','1','false'};
        private String[] ReplyTimestamp_type_info = new String[]{'ReplyTimestamp','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] AddressResults_type_info = new String[]{'AddressResults','http://fedex.com/ws/addressvalidation/v3',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://fedex.com/ws/addressvalidation/v3','true','true'};
        private String[] field_order_type_info = new String[]{'HighestSeverity','Notifications','TransactionDetail','Version','ReplyTimestamp','AddressResults'};
    }
    public class Contact {
        public String ContactId;
        public String PersonName;
        public String Title;
        public String CompanyName;
        public String PhoneNumber;
        public String PhoneExtension;
        public String TollFreePhoneNumber;
        public String PagerNumber;
        public String FaxNumber;
        public String EMailAddress;
        private String[] ContactId_type_info = new String[]{'ContactId','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] PersonName_type_info = new String[]{'PersonName','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] Title_type_info = new String[]{'Title','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] CompanyName_type_info = new String[]{'CompanyName','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] PhoneNumber_type_info = new String[]{'PhoneNumber','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] PhoneExtension_type_info = new String[]{'PhoneExtension','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] TollFreePhoneNumber_type_info = new String[]{'TollFreePhoneNumber','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] PagerNumber_type_info = new String[]{'PagerNumber','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] FaxNumber_type_info = new String[]{'FaxNumber','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] EMailAddress_type_info = new String[]{'EMailAddress','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://fedex.com/ws/addressvalidation/v3','true','true'};
        private String[] field_order_type_info = new String[]{'ContactId','PersonName','Title','CompanyName','PhoneNumber','PhoneExtension','TollFreePhoneNumber','PagerNumber','FaxNumber','EMailAddress'};
    }
    public class WebAuthenticationDetail {
        public ShipItFedExAddressValidationService.WebAuthenticationCredential UserCredential;
        private String[] UserCredential_type_info = new String[]{'UserCredential','http://fedex.com/ws/addressvalidation/v3',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://fedex.com/ws/addressvalidation/v3','true','true'};
        private String[] field_order_type_info = new String[]{'UserCredential'};
    }
    public class WebAuthenticationCredential {
        public String Key;
        public String Password;
        private String[] Key_type_info = new String[]{'Key','http://fedex.com/ws/addressvalidation/v3',null,'1','1','false'};
        private String[] Password_type_info = new String[]{'Password','http://fedex.com/ws/addressvalidation/v3',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://fedex.com/ws/addressvalidation/v3','true','true'};
        private String[] field_order_type_info = new String[]{'Key','Password'};
    }
    public class Localization {
        public String LanguageCode;
        public String LocaleCode;
        private String[] LanguageCode_type_info = new String[]{'LanguageCode','http://fedex.com/ws/addressvalidation/v3',null,'1','1','false'};
        private String[] LocaleCode_type_info = new String[]{'LocaleCode','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://fedex.com/ws/addressvalidation/v3','true','true'};
        private String[] field_order_type_info = new String[]{'LanguageCode','LocaleCode'};
    }
    public class ParsedStreetLineDetail {
        public String HouseNumber;
        public String PreStreetType;
        public String LeadingDirectional;
        public String StreetName;
        public String StreetSuffix;
        public String TrailingDirectional;
        public String UnitLabel;
        public String UnitNumber;
        public String RuralRoute;
        public String POBox;
        public String Building;
        public String Organization;
        private String[] HouseNumber_type_info = new String[]{'HouseNumber','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] PreStreetType_type_info = new String[]{'PreStreetType','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] LeadingDirectional_type_info = new String[]{'LeadingDirectional','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] StreetName_type_info = new String[]{'StreetName','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] StreetSuffix_type_info = new String[]{'StreetSuffix','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] TrailingDirectional_type_info = new String[]{'TrailingDirectional','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] UnitLabel_type_info = new String[]{'UnitLabel','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] UnitNumber_type_info = new String[]{'UnitNumber','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] RuralRoute_type_info = new String[]{'RuralRoute','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] POBox_type_info = new String[]{'POBox','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] Building_type_info = new String[]{'Building','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] Organization_type_info = new String[]{'Organization','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://fedex.com/ws/addressvalidation/v3','true','true'};
        private String[] field_order_type_info = new String[]{'HouseNumber','PreStreetType','LeadingDirectional','StreetName','StreetSuffix','TrailingDirectional','UnitLabel','UnitNumber','RuralRoute','POBox','Building','Organization'};
    }
    public class Notification {
        public String Severity;
        public String Source;
        public String Code;
        public String Message;
        public String LocalizedMessage;
        public ShipItFedExAddressValidationService.NotificationParameter[] MessageParameters;
        private String[] Severity_type_info = new String[]{'Severity','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] Source_type_info = new String[]{'Source','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] Code_type_info = new String[]{'Code','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] Message_type_info = new String[]{'Message','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] LocalizedMessage_type_info = new String[]{'LocalizedMessage','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] MessageParameters_type_info = new String[]{'MessageParameters','http://fedex.com/ws/addressvalidation/v3',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://fedex.com/ws/addressvalidation/v3','true','true'};
        private String[] field_order_type_info = new String[]{'Severity','Source','Code','Message','LocalizedMessage','MessageParameters'};
    }
    public class TransactionDetail {
        public String CustomerTransactionId;
        public ShipItFedExAddressValidationService.Localization Localization;
        private String[] CustomerTransactionId_type_info = new String[]{'CustomerTransactionId','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] Localization_type_info = new String[]{'Localization','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://fedex.com/ws/addressvalidation/v3','true','true'};
        private String[] field_order_type_info = new String[]{'CustomerTransactionId','Localization'};
    }
    public class AddressValidationRequest {
        public ShipItFedExAddressValidationService.WebAuthenticationDetail WebAuthenticationDetail;
        public ShipItFedExAddressValidationService.ClientDetail ClientDetail;
        public ShipItFedExAddressValidationService.TransactionDetail TransactionDetail;
        public ShipItFedExAddressValidationService.VersionId Version;
        public DateTime InEffectAsOfTimestamp;
        public ShipItFedExAddressValidationService.AddressToValidate[] AddressesToValidate;
        private String[] WebAuthenticationDetail_type_info = new String[]{'WebAuthenticationDetail','http://fedex.com/ws/addressvalidation/v3',null,'1','1','false'};
        private String[] ClientDetail_type_info = new String[]{'ClientDetail','http://fedex.com/ws/addressvalidation/v3',null,'1','1','false'};
        private String[] TransactionDetail_type_info = new String[]{'TransactionDetail','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] Version_type_info = new String[]{'Version','http://fedex.com/ws/addressvalidation/v3',null,'1','1','false'};
        private String[] InEffectAsOfTimestamp_type_info = new String[]{'InEffectAsOfTimestamp','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] AddressesToValidate_type_info = new String[]{'AddressesToValidate','http://fedex.com/ws/addressvalidation/v3',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://fedex.com/ws/addressvalidation/v3','true','true'};
        private String[] field_order_type_info = new String[]{'WebAuthenticationDetail','ClientDetail','TransactionDetail','Version','InEffectAsOfTimestamp','AddressesToValidate'};
    }
    public class AddressAttribute {
        public String Name;
        public String Value;
        private String[] Name_type_info = new String[]{'Name','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] Value_type_info = new String[]{'Value','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://fedex.com/ws/addressvalidation/v3','true','true'};
        private String[] field_order_type_info = new String[]{'Name','Value'};
    }
    public class ParsedPostalCodeDetail {
        public String Base;
        public String AddOn;
        public String DeliveryPoint;
        private String[] Base_type_info = new String[]{'Base','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] AddOn_type_info = new String[]{'AddOn','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] DeliveryPoint_type_info = new String[]{'DeliveryPoint','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://fedex.com/ws/addressvalidation/v3','true','true'};
        private String[] field_order_type_info = new String[]{'Base','AddOn','DeliveryPoint'};
    }
    public class Address {
        public String[] StreetLines;
        public String City;
        public String StateOrProvinceCode;
        public String PostalCode;
        public String UrbanizationCode;
        public String CountryCode;
        public String CountryName;
        public Boolean Residential;
        private String[] StreetLines_type_info = new String[]{'StreetLines','http://fedex.com/ws/addressvalidation/v3',null,'0','-1','false'};
        private String[] City_type_info = new String[]{'City','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] StateOrProvinceCode_type_info = new String[]{'StateOrProvinceCode','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] PostalCode_type_info = new String[]{'PostalCode','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] UrbanizationCode_type_info = new String[]{'UrbanizationCode','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] CountryCode_type_info = new String[]{'CountryCode','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] CountryName_type_info = new String[]{'CountryName','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] Residential_type_info = new String[]{'Residential','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://fedex.com/ws/addressvalidation/v3','true','true'};
        private String[] field_order_type_info = new String[]{'StreetLines','City','StateOrProvinceCode','PostalCode','UrbanizationCode','CountryCode','CountryName','Residential'};
    }
    public class VersionId {
        public String ServiceId;
        public Integer Major;
        public Integer Intermediate;
        public Integer Minor;
        private String[] ServiceId_type_info = new String[]{'ServiceId','http://fedex.com/ws/addressvalidation/v3',null,'1','1','false'};
        private String[] Major_type_info = new String[]{'Major','http://fedex.com/ws/addressvalidation/v3',null,'1','1','false'};
        private String[] Intermediate_type_info = new String[]{'Intermediate','http://fedex.com/ws/addressvalidation/v3',null,'1','1','false'};
        private String[] Minor_type_info = new String[]{'Minor','http://fedex.com/ws/addressvalidation/v3',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://fedex.com/ws/addressvalidation/v3','true','true'};
        private String[] field_order_type_info = new String[]{'ServiceId','Major','Intermediate','Minor'};
    }
    public class ClientDetail {
        public String AccountNumber;
        public String MeterNumber;
        public String IntegratorId;
        public ShipItFedExAddressValidationService.Localization Localization;
        private String[] AccountNumber_type_info = new String[]{'AccountNumber','http://fedex.com/ws/addressvalidation/v3',null,'1','1','false'};
        private String[] MeterNumber_type_info = new String[]{'MeterNumber','http://fedex.com/ws/addressvalidation/v3',null,'1','1','false'};
        private String[] IntegratorId_type_info = new String[]{'IntegratorId','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] Localization_type_info = new String[]{'Localization','http://fedex.com/ws/addressvalidation/v3',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://fedex.com/ws/addressvalidation/v3','true','true'};
        private String[] field_order_type_info = new String[]{'AccountNumber','MeterNumber','IntegratorId','Localization'};
    }
    public class AddressValidationServicePort {
        //public String endpoint_x = 'https://wsbeta.fedex.com:443/web-services/addressvalidation';
        //public String endpoint_x = 'https://wsbeta.fedex.com:443/web-services/addressvalidation';
        public String endpoint_x = ShipItHelper.shipItSettings.get(ShipItHelper.FEDEX_USE_PRODUCTION_CREDENTIALS).value__c == 'true' ? ShipItHelper.shipItSettings.get(ShipItHelper.FEDEX_ENDPOINT_ADDRESSVALIDATION_PROD).value__c : ShipItHelper.shipItSettings.get(ShipItHelper.FEDEX_ENDPOINT_ADDRESSVALIDATION_TEST).value__c;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://fedex.com/ws/addressvalidation/v3', 'ShipItFedExAddressValidationService'};
        public ShipItFedExAddressValidationService.AddressValidationReply addressValidation(ShipItFedExAddressValidationService.WebAuthenticationDetail WebAuthenticationDetail,ShipItFedExAddressValidationService.ClientDetail ClientDetail,ShipItFedExAddressValidationService.TransactionDetail TransactionDetail,ShipItFedExAddressValidationService.VersionId Version,DateTime InEffectAsOfTimestamp,ShipItFedExAddressValidationService.AddressToValidate[] AddressesToValidate) {
            ShipItFedExAddressValidationService.AddressValidationRequest request_x = new ShipItFedExAddressValidationService.AddressValidationRequest();
            request_x.WebAuthenticationDetail = WebAuthenticationDetail;
            request_x.ClientDetail = ClientDetail;
            request_x.TransactionDetail = TransactionDetail;
            request_x.Version = Version;
            request_x.InEffectAsOfTimestamp = InEffectAsOfTimestamp;
            request_x.AddressesToValidate = AddressesToValidate;
            ShipItFedExAddressValidationService.AddressValidationReply response_x;
            Map<String, ShipItFedExAddressValidationService.AddressValidationReply> response_map_x = new Map<String, ShipItFedExAddressValidationService.AddressValidationReply>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://fedex.com/ws/addressvalidation/v3/addressValidation',
              'http://fedex.com/ws/addressvalidation/v3',
              'AddressValidationRequest',
              'http://fedex.com/ws/addressvalidation/v3',
              'AddressValidationReply',
              'ShipItFedExAddressValidationService.AddressValidationReply'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}