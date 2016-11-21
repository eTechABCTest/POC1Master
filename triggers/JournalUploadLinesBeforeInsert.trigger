trigger JournalUploadLinesBeforeInsert on Journal_Upload_Lines__c (before insert) {
	Set<String> glaReportingCodes = new Set<String>();
	Set<String> ccReportingCodes = new Set<String>();
	for (Journal_Upload_Lines__c jul:Trigger.new) {
		if (jul.Cost_Center__c != null && jul.Cost_Center__c != '') {
			ccReportingCodes.add(jul.Cost_Center__c);
		}
		if (jul.General_Ledger_Account__c != null && jul.General_Ledger_Account__c != '') {
			glaReportingCodes.add(jul.General_Ledger_Account__c);
		}
	}
	if (!ccReportingCodes.isEmpty() || !glaReportingCodes.isEmpty()) {
		List<c2g__codaDimension1__c> ccs = [
		    select
		    	Name,
		        c2g__ReportingCode__c
		    from
		        c2g__codaDimension1__c
		    where
		        c2g__ReportingCode__c in :ccReportingCodes
		];
		Map<String,c2g__codaDimension1__c> ccMap = new Map<String,c2g__codaDimension1__c>();
		for (c2g__codaDimension1__c cc:ccs) {
			ccMap.put(cc.c2g__ReportingCode__c,cc);
		}
		List<c2g__codaGeneralLedgerAccount__c> glas = [
		    select
		        Name,
		        c2g__ReportingCode__c
		    from
		        c2g__codaGeneralLedgerAccount__c
		    where
		        c2g__ReportingCode__c in :glaReportingCodes
		];
		Map<String,c2g__codaGeneralLedgerAccount__c> glaMap = new Map<String,c2g__codaGeneralLedgerAccount__c>();
		for (c2g__codaGeneralLedgerAccount__c gla:glas) {
			glaMap.put(gla.c2g__ReportingCode__c,gla);
		}
		for (Journal_Upload_Lines__c jul:Trigger.new) {
			c2g__codaDimension1__c cc = ccMap.get(jul.Cost_Center__c);
			if (cc != null) {
				jul.Dimension_1_Full__c = cc.Id;
			}
			c2g__codaGeneralLedgerAccount__c gla = glaMap.get(jul.General_Ledger_Account__c);
			if (gla != null) {
				jul.General_Ledger_Account_Full__c = gla.Id;
			}
		}
	}

}