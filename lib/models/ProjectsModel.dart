import 'TaskModel.dart';
import 'TeamModel.dart';

class Projects {
  late String id;
  late String title;
  late String createdAt;
  late String deadline;
  late String description; // New description parameter

  Projects({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.deadline,
    required this.description, // Include the description in the constructor
  });

  Projects.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? '',
        title = json['title'] ?? '',
        createdAt = json['created_at'] ?? '',
        deadline = json['deadline'] ?? '',
        description = json['description'] ?? ''; // Deserialize description


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt,
      'deadline': deadline,
      'description': description, // Serialize description
    };
  }
}
