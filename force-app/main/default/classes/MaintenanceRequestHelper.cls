public with sharing class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(List<case> oldVal,List<case> newVal) {
        
        
        
        // TODO: Complete the method to update workorders
        List<Case> casesToAdd = New List<Case>();
        Set<Id> equipmentIds = new Set<Id>();
        
        List<Case> oldCases = new list<case>(); 
        List<Case> newCases = new List<case>();
        List<Id> caseIds= new List<id>();



    for (Integer i = 0; i < newVal.size(); i++) {
        
        oldCases.add(oldVal[i]); 
        newCases.add(newVal[i]);
        
    }
        
        for(Case singleCase : oldCases){
            
            caseIds.add(singleCase.Id);
            
        }
        
                List<Equipment_Maintenance_Item__c> relatedItems =[SELECT Equipment__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c= :caseIds];
        
        		// Loop through each Equipment Maintenance Item record
                        for (Equipment_Maintenance_Item__c item : relatedItems) {
                            // Add the Equipment ID to the set
                            equipmentIds.add(item.Equipment__c);
                        }

        		List<Product2> equipments=[SELECT Maintenance_Cycle__c FROM Product2 WHERE id IN :equipmentIds];
  					//System.debug(equipments);
        		 for (Integer i = 0; i < newVal.size(); i++) {
                      Case oldCase = oldVal[i]; 
        			  Case newCase = newVal[i];
					   if(newCase.Type == 'Repair' || newCase.Type =='Routine Maintenance'){

            				if(oldCase.Status != 'closed' && newCase.Status == 'closed'){
                                	List<Integer> maintenanceCycles = new List<Integer>();
									 for (Product2 equipment : equipments) {
                           				 if (equipment.Maintenance_Cycle__c != null) {
      							 				 maintenanceCycles.add((Integer)equipment.Maintenance_Cycle__c);
                                             
    								    }
                        			}
                                		
                                
                                      maintenanceCycles.sort();
                                	  Integer shortestCycle = 0;
                                
                                if (!maintenanceCycles.isEmpty()) {
                                  	shortestCycle = maintenanceCycles[0];  // The first item is the smallest after sorting
                                }

									Date currentDate = Date.today();
               					    Date futureDate = currentDate.addDays(shortestCycle);
                               			 case caseToAdd= new Case(
                                             Type ='Routine Maintenance', 
                                    		 Subject ='this is a maintenance request created by trigger',
                                    		 Date_Reported__c = Date.today(),
                                             Vehicle__c = newCase.Vehicle__c ,
                                             //product__c = oldCase.Product__c ,
                                             ProductId = newCase.ProductId,
                                             Date_Due__c = futureDate);   
                			System.debug(casetoAdd);
            				casesToAdd.add(caseToAdd);


                                
                            }
                       }


                 }
        			insert casesToAdd;
                    //              
       				
// Fetch related items for the old cases
                List<Equipment_Maintenance_Item__c> relateItemsList = [
                    SELECT Equipment__c, Maintenance_Request__c
                    FROM Equipment_Maintenance_Item__c
                    WHERE Maintenance_Request__c IN :caseIds
                ];
        
// Map to hold the old Case IDs and their new Case IDs
                    Map<Id, Id> oldToNewCaseIdMap = new Map<Id, Id>();
                    List<Case> sqlquery=[SELECT Id FROM Case WHERE Id IN :caseIds];
                    // Populate the map with old Case IDs to new Case IDs using Case Subject or another unique identifier
                    for (Case newCase : casesToAdd) {
                        for (Case oldCase : sqlquery) {
                                oldToNewCaseIdMap.put(oldCase.Id, newCase.Id);
                        }
                    }
// List to hold new related items
			List<Equipment_Maintenance_Item__c> newRelateItemsList = new List<Equipment_Maintenance_Item__c>();

// Create new related items and associate them with the new cases
            for (Equipment_Maintenance_Item__c oldItem : relateItemsList) {
                Equipment_Maintenance_Item__c newItem = new Equipment_Maintenance_Item__c();
                newItem.Equipment__c = oldItem.Equipment__c;
                newItem.Maintenance_Request__c = oldToNewCaseIdMap.get(oldItem.Maintenance_Request__c);
                newRelateItemsList.add(newItem);
            }

// Insert new related items
			insert newRelateItemsList;
       
        
           
    }
}