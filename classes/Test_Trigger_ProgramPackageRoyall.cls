/* 
* Name          : shift_mass_update_programs_test
* Author        : Shift CRM
* Description   : Test trigger on Program Package that updates Programs status when Program Package Client status changes to Lost
*
* Maintenance History: 
* Date ------------ Name  ----  Version --- Remarks 
* 16/08/2013        Edward         1.0         Initial
* 10/07/2014        Hermes         1.1         Update of test coverage to meet VR rules
* 06/28/2016		Rajeev		   1.2		   SFDC Royall Schema Release - Code Migration from Royall Instance to Corporate Instanc
*											   - shift_mass_update_programs_test moved in this test class manually
*/
@isTest(seeAllData = false)
public class Test_Trigger_ProgramPackageRoyall {
	
    // Bulk test mass_program_package_update trigger
    static testMethod void test1() {

        integer currentFY = shift_get_fiscal_year.current();   
        
        //Create Account associated to Opportnity with a Contact set to primary in the Contact Role 
        Account acc1 = new Account ( Name = 'Shift CRM'  );
        insert acc1;
        
        
        Map <Integer, Program_Package__c> theProgPackMap = new map <Integer, Program_Package__c> ();
        
        //Create 200 Programs with Client Status In Play
        for ( Integer i=0; i < 200; i++){
            Program_Package__c ppkTemp= new Program_Package__c ( Account__c = acc1.id, Name = 'ShiftTest'+i,
                                                                Fiscal_Year__c = string.ValueOf(currentFY - 1) ,
                                                                    Client_Status_New__c = 'In Play' );
            theProgPackMap.put(i,ppkTemp);
        }
        insert theProgPackMap.values();
   
        Map <Integer, Royall_Program__c> theProgMap = new Map <Integer, Royall_Program__c> ();
        for ( Program_Package__c ppk : theProgPackMap.values()  ){
            // Create 200 Programs  per Prog Packages
            for ( Integer i=0; i < 200; i++){
                Royall_Program__c theProg = new Royall_Program__c ( Status__c = 'Opportunity', Program_Package__c = ppk.id, Name = 'TEST'+i, Probability__c = 10);
                //1.1 - updated to meet program vr rule
                theProg.Declined_Date__c = Date.Today();
                theProg.Proposal_Sent__c = Date.Today();
                theProgMap.put(i,theProg); 
            } 
        } 
        insert theProgMap.values();
        
        // Update all Prog Packages Client Status to Lost
        for ( Program_Package__c ppk2: theProgPackMap.values()){
            ppk2.Client_Status_New__c = 'Lost';
        }
        update theProgPackMap.values();
        

        List <Royall_Program__c> theProgramList = new List <Royall_Program__c>([Select Id, Status__c From Royall_Program__c where Program_Package__c in : theProgPackMap.Values()]);
        //Check that all Programs status were updated to Declined when the ProgPackage Client status was set to Lost
        for ( Royall_Program__c  p: theProgramList ){
            System.assert(p.Status__c == 'Declined' );      
        } 

    }
    
    // Bulk test mass_program_package_update trigger
    static testMethod void test2() {

        integer currentFY = shift_get_fiscal_year.current();   
        
        //Create Account associated to Opportnity with a Contact set to primary in the Contact Role 
        Account acc1 = new Account ( Name = 'Shift CRM'  );
        insert acc1;
        
        
        Map <Integer, Program_Package__c> theProgPackMap = new map <Integer, Program_Package__c> ();
        
        //Create 200 Programs with Client Status In Play
        for ( Integer i=0; i < 200; i++){
            Program_Package__c ppkTemp= new Program_Package__c ( Account__c = acc1.id, Name = 'ShiftTest'+i,
                                                                Fiscal_Year__c = string.ValueOf(currentFY - 1) ,
                                                                    Client_Status_New__c = 'In Play' );
            theProgPackMap.put(i,ppkTemp);
        }
        insert theProgPackMap.values();
   
        Map <Integer, Royall_Program__c> theProgMap = new Map <Integer, Royall_Program__c> ();
        for ( Program_Package__c ppk : theProgPackMap.values()  ){
            // Create 200 Programs  per Prog Packages
            for ( Integer i=0; i < 200; i++){
                Royall_Program__c theProg = new Royall_Program__c (Status__c = 'Opportunity', Program_Package__c = ppk.id, Name = 'TEST'+i, Probability__c = 10);
                theProgMap.put(i,theProg); 
            } 
        } 
        insert theProgMap.values();
        
        // Update all Prog Packages Client Status to Lost
        for ( Program_Package__c ppk2: theProgPackMap.values()){
            ppk2.Client_Status_New__c = 'Lost';
        }
        try{
            update theProgPackMap.values();
        }catch(Exception e){
        }

        List <Royall_Program__c> theProgramList = new List <Royall_Program__c>([Select Id, Status__c From Royall_Program__c where Program_Package__c in : theProgPackMap.Values()]);
        //Check that all Programs status were updated to Declined when the ProgPackage Client status was set to Lost
        for ( Royall_Program__c  p: theProgramList ){
            System.assert(p.Status__c == 'Opportunity' );      
        } 

    }
}