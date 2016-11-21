/*
    Purpose:    This class is to search the case categories and add those to Case record.(CR-20111208-267)
                
    Create By:  Simplyforce Technology
    
    Created Date:   12/13/2011
    
    Current Version:    v1.0
    
    Revision Log:       
*/
public with sharing class AddCaseCategoriesToCase {
	
	//property to hold the search parameter
	public String searchText{get; set;}
	public Id caseId{get; set;}
	
	//Property to hold the result to display on to the UI
	public List<CaseCategoryWrapper> listCaseCategoryWrapper{get; set;}
	
	//create a collction of categories already added with case
	Set<Id> existingCategories;
		
	
	//default constructor
	public AddCaseCategoriesToCase() {
		
		//get caseId parameter from URL
		if(ApexPages.currentPage().getParameters().get('caseId') != null && ApexPages.currentPage().getParameters().get('caseId') != '') {
			caseId = Id.valueOf(ApexPages.currentPage().getParameters().get('caseId'));
			
			//call method to initialize properties
			inIt();
		}
		
	}
	
	//method to set the initial properties
	private void inIt() {
		
		//create a collction of categories already added with case
		existingCategories = new Set<Id>();
		
		//query the existing category records
		for(Case_Category_MTM__c caseCategoryMTM : [Select Id, Case_Category__c from Case_Category_MTM__c where Case__c =: caseId]) {
			existingCategories.add(caseCategoryMTM.Case_Category__c);
		}
	}
	
	//search Case categories records
	public void searchCaseCategoriesByName() {
		
		//check if seacrch parameter string is not null
		if(searchText != null) {
			
			//replace the wild car
			searchText = searchText.replaceAll('\\*', '%') + '%';
			
			//instantiate the result set list
			listCaseCategoryWrapper = new List<CaseCategoryWrapper>();
			
			//search result and create result set
			for(Case_Category__c caseCategory : [Select Id, Name, Content_Tag_Name__c from Case_Category__c where (Name Like: searchText OR Content_Tag_Name__c Like: searchText) AND ID NOT IN: existingCategories order by  Content_Tag_Name__c]) {
				
				//add records in the search results
				listCaseCategoryWrapper.add(new CaseCategoryWrapper(caseCategory, false));
			}
		}
	}
	
	//add case categories to case
	public void createCaseCategoriesMTM() {
		
		//create a savepoint to rollback the transaction in case of exception
		SavePoint sp = Database.setSavePoint();
		
		try {
		
			//Create list of Case Category MTM records
			List<Case_Category_MTM__c> caseCategoriesMTM = new List<Case_Category_MTM__c>();
			
			//loop through the results and add the selected records with case
			for(CaseCategoryWrapper wrapper : listCaseCategoryWrapper) {
				
				//add the selected record in the list to be inserted
				if(wrapper.selected) {
					
					caseCategoriesMTM.add(new Case_Category_MTM__c(Case__c = caseId, Case_Category__c = wrapper.caseCategory.Id));
				}
			}
			
			//check for the list size
			if(caseCategoriesMTM.size() > 0)
				insert caseCategoriesMTM;
		} catch(Exception e) {
			
			//rollback the transaction
			database.rollback(sp);
			
			//add error on page
			ApexPages.addMessages(e);
		}
	}
	
	//Wrapper class to hold the Case Category record and selected property
	public class CaseCategoryWrapper {
		
		//property to hold the case category record
		public Case_Category__c caseCategory{get; set;}
		public Boolean selected{get; set;}
		
		//constructor
		public CaseCategoryWrapper(Case_Category__c caseCategory, Boolean selected) {
			this.caseCategory = caseCategory;
			this.selected = selected;
		}
	}
}