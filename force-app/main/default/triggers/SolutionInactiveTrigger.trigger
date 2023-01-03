trigger SolutionInactiveTrigger on Solution (after insert, after update) {
    Id[] solutionsToInactivate = new Id[0];
    if(Trigger.isInsert) {
        for(Solution s : Trigger.New) {
            if (s.Status == 'Inactive') {
                solutionsToInactivate.add(s.Id);
            }
        }
    }
    else {
        for(Solution s : Trigger.New) {
            if(s.Status == 'Inactive' && Trigger.oldMap.get(s.Id).Status != 'Inactive') {
                solutionsToInactivate.add(s.Id);
            }
        }
    }
    if(solutionsToInactivate.size() > 0) {
        User admin = [Select Id from User where alias = 'kcilley' limit 1];
        Solution[] solutions = [Select Id from Solution where Id in :solutionsToInactivate];
        for(Solution s : solutions) {
            s.OwnerId = admin.Id;
        }
        update solutions;
    }
}