// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ojak - Open Task Management';

  @override
  String get appSubtitle => 'Efficient task tracking and collaboration';

  @override
  String get homeTitle => 'Home';

  @override
  String get projectsTitle => 'Projects';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get profileTitle => 'Profile';

  @override
  String get loginTitle => 'Login';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get signupTitle => 'Sign Up';

  @override
  String get welcome => 'Welcome';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get name => 'Name';

  @override
  String get submitButton => 'Submit';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String get deleteButton => 'Delete';

  @override
  String get editButton => 'Edit';

  @override
  String get createButton => 'Create';

  @override
  String get backButton => 'Back';

  @override
  String get nextButton => 'Next';

  @override
  String get searchPlaceholder => 'Search...';

  @override
  String get noResults => 'No results found';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Information';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get confirmDelete => 'Are you sure you want to delete?';

  @override
  String get confirmLogout => 'Are you sure you want to logout?';

  @override
  String get emptyState => 'No data available';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get pending => 'Pending';

  @override
  String get inProgress => 'In Progress';

  @override
  String get completed => 'Completed';

  @override
  String get archived => 'Archived';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectTime => 'Select Time';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageKo => '한국어';

  @override
  String get languageEn => 'English';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemTheme => 'System Theme';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get emailNotifications => 'Email Notifications';

  @override
  String get aboutApp => 'About App';

  @override
  String get version => 'Version';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get feedback => 'Feedback';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get projectName => 'Project Name';

  @override
  String get projectDescription => 'Project Description';

  @override
  String get createProject => 'Create Project';

  @override
  String get editProject => 'Edit Project';

  @override
  String get deleteProject => 'Delete Project';

  @override
  String get taskTitle => 'Task Title';

  @override
  String get taskDescription => 'Task Description';

  @override
  String get dueDate => 'Due Date';

  @override
  String get priority => 'Priority';

  @override
  String get high => 'High';

  @override
  String get medium => 'Medium';

  @override
  String get low => 'Low';

  @override
  String get assignee => 'Assignee';

  @override
  String assignedTo(String name) {
    return 'Assigned to $name';
  }

  @override
  String get createdAt => 'Created At';

  @override
  String get updatedAt => 'Updated At';

  @override
  String get completedAt => 'Completed At';

  @override
  String get members => 'Members';

  @override
  String get addMember => 'Add Member';

  @override
  String get removeMember => 'Remove Member';

  @override
  String get role => 'Role';

  @override
  String get admin => 'Admin';

  @override
  String get member => 'Member';

  @override
  String get viewer => 'Viewer';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get emailAlreadyExists => 'Email already exists';

  @override
  String get userNotFound => 'User not found';

  @override
  String get unauthorizedAccess => 'Access denied';

  @override
  String get networkError => 'Network error occurred';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get tryAgain => 'Please try again';

  @override
  String get offline => 'You are offline';

  @override
  String get online => 'You are online';
}
