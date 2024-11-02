class TeamMember {
  late String id;
  late String name;
  late String email;
  late String pushToken;
  late String profilePicture; // New property for profile picture
  late bool isOnline;

  TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePicture,
    required this.pushToken, // Include in constructor
    required this.isOnline,
  });

  TeamMember.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? '',
        name = json['Name'] ?? '',
        email = json['Email'] ?? '',
        profilePicture = json['Image'] ?? '',
        pushToken = json['push_token'] ?? '',
        isOnline = json['is_Online'] ?? false; // Ensure it defaults to false if null

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Name': name,
      'Email': email,
      'Image': profilePicture,
      'push_token': pushToken,
      'is_Online': isOnline, // Include in JSON
    };
  }
}
