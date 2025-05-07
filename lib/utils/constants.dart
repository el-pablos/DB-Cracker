class AppStrings {
  // App
  static const String appName = 'DB Cracker - Tamaengs';
  static const String appAuthor = 'Tamaengs';
  
  // Screens
  static const String homeTitle = 'DATABASE CRACKER v2.5';
  static const String detailTitle = 'SUBJECT PROFILE';
  
  // Search
  static const String searchHint = 'enter target name...';
  static const String emptySearchPrompt = 'ENTER TARGET IDENTIFIER TO INITIATE SCAN';
  static const String scanningMessage = 'SCANNING DATABASE...';
  static const String accessGranted = 'ACCESS GRANTED';
  static const String accessDenied = 'ACCESS DENIED';
  static const String noResultsFound = 'NO MATCH FOUND IN DATABASE FOR TARGET';
  static const String pleaseEnterSearchTerm = 'ERROR: NO TARGET SPECIFIED';
  static const String errorSearching = 'CONNECTION BREACH DETECTED:';
  
  // Details
  static const String personalInfoTitle = 'PERSONAL IDENTIFIERS';
  static const String academicInfoTitle = 'INSTITUTIONAL DATA';
  static const String errorLoadingData = 'DATA EXTRACTION FAILURE:';
  static const String noDataAvailable = 'SECURE DATA - ACCESS RESTRICTED';
  static const String retry = 'RETRY CONNECTION';
  
  // Student Info Labels
  static const String name = 'Subject Name';
  static const String studentId = 'ID Number';
  static const String gender = 'Biological Classification';
  static const String entryYear = 'Initial Registration';
  static const String registrationType = 'Entry Protocol';
  static const String currentStatus = 'Active Status';
  static const String university = 'Institution';
  static const String universityCode = 'Institution Code';
  static const String studyProgram = 'Program';
  static const String studyProgramCode = 'Program Code';
  static const String educationLevel = 'Educational Tier';
  
  // Hacker theme elements
  static const String initiateSearch = 'INITIATE SCAN';
  static const String connecting = 'ESTABLISHING CONNECTION...';
  static const String decrypting = 'DECRYPTING DATA...';
  static const String securingConnection = 'SECURING TUNNEL...';
  static const String bypassingFirewall = 'BYPASSING FIREWALL...';
  static const String extractingData = 'EXTRACTING DATA...';
  static const String hackingComplete = 'HACK SUCCESSFUL';
}

class HackerColors {
  static const Color primary = Color(0xFF00FF00); // Bright green
  static const Color accent = Color(0xFF00CCFF); // Cyan
  static const Color surface = Color(0xFF101820); // Very dark blue-gray
  static const Color background = Color(0xFF000000); // Black
  static const Color text = Color(0xFFCCFFCC); // Light green
  static const Color error = Color(0xFFFF0033); // Red
  static const Color warning = Color(0xFFFFCC00); // Yellow
  static const Color success = Color(0xFF00FF00); // Green
  static const Color infoBox = Color(0xFF001030); // Dark navy
  static const Color highlight = Color(0xFF00FF33); // Neon green
}

// Animation durations for hacker effects
class AnimationDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
}