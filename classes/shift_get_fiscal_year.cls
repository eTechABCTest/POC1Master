/* 
* Name          : shift_get_fiscal_year
* Author        : Edward Chow
* Description   : Class to calculate the current Fiscal Year
*            
* Maintenance History: 
* Date --------- Name -------- Version -- Remarks 
* 05/06/2013    Edward Chow    1.0        Initial
@Modified By - Rajeev Jain - 06/28/2016 - SFDC Royall Migration - Migrated from Royall Enviournment to Corporate Instance
*/
public class shift_get_fiscal_year{

    //Return the current fiscal year
    public static integer current(){
    
    integer currentFY;
    date currentDate = date.today();
    integer currentMonth = currentDate.month();
    integer currentYear = currentDate.year(); 
        
        // Query to get the Org FY month and the Starting or Ending month flag                                         
        Organization org = [select Name, FiscalYearStartMonth, UsesStartDateAsFiscalYearName  
                                from Organization 
                                    where id =: Userinfo.getOrganizationId()];
                              
    integer fiscalYearMonth = org.FiscalYearStartMonth;
    boolean isStartMonth = org.UsesStartDateAsFiscalYearName;                                                
                                                                                 
     
        //Determine the current Fiscal Year given the month and isStartMonth flag 
        if( currentMonth >= fiscalYearMonth){
            if( isStartMonth ) currentFY = currentYear;
                else currentFY = currentYear + 1;
        }
        else if (currentMonth < fiscalYearMonth){
            if( isStartMonth ) currentFY = currentYear - 1;
                else currentFY = currentYear;
        }

    return currentFY;
    }
}