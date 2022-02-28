/*
    Interface used by SME_GlobalUtilityCtrl class create and delete assignment records
*/

public interface SME_IAssignmentBehaviorCtrl {
    void loadRecords(List<SObject> objects);
    void createAssignments();
    void deleteAssignments();
}