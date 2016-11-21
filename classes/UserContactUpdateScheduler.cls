global class UserContactUpdateScheduler implements Schedulable {
  global void execute(SchedulableContext sc) {
    UserContactUpdate b = new UserContactUpdate(null);
    Database.executeBatch(b);
  }
}