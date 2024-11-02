class TaskModel {
  late String id;
  late String title;
  late String description;
  late String assignedTo; // TeamMember ID
  late String status; // e.g., 'pending', 'in progress', 'completed'
  late String deadline;
  late String projectId;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.status,
    required this.deadline,
    required this.projectId
  });

  TaskModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? '',
        title = json['title'] ?? '',
        description = json['description'] ?? '',
        assignedTo = json['assigned_to'] ?? '',
        status = json['status'] ?? '',
        deadline = json['deadline'] ?? '',
        projectId = json['projectId'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assigned_to': assignedTo,
      'status': status,
      'deadline': deadline,
      'projectId': projectId
    };
  }
}