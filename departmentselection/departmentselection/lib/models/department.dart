class Department {
  final String name;
  final String description;
  final List<String> issueTypes;

  Department({
    required this.name,
    required this.description,
    required this.issueTypes,
  });

  static List<Department> getDepartments() {
    return [
      Department(
        name: 'Road Department',
        description: 'Handles road-related issues',
        issueTypes: ['Pothole', 'Road Crack', 'Road Damage'],
      ),
      Department(
        name: 'Electrical Department',
        description: 'Manages electrical infrastructure',
        issueTypes: ['Streetlight Broken', 'Power Outage', 'Electrical Hazard'],
      ),
      Department(
        name: 'Water & Sewerage',
        description: 'Water supply and drainage issues',
        issueTypes: ['Water Leak', 'Drainage Overflow', 'No Water Supply'],
      ),
      Department(
        name: 'Sanitation Department',
        description: 'Cleanliness and waste management',
        issueTypes: ['Garbage Pile', 'Dirty Area', 'Overflowing Dustbin'],
      ),
    ];
  }
}
