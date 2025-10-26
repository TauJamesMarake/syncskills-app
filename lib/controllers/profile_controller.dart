// import 'package:get/get.dart';
// import 'package:syncskills/models/user.dart';
// import 'package:syncskills/models/userInfo_model.dart';
// import 'package:syncskills/services/user_service.txt';

// /// Controller responsible for the currently loaded user/profile
// class ProfileController extends GetxController {
//   final UserService _userService = Get.find<UserService>();

//   /// Currently loaded user (nullable until loaded)
//   final Rxn<User> user = Rxn<User>();
//   final loading = false.obs;

//   bool get hasUser => user.value != null;

//   /// Loads a user by id and sets the reactive [user]
//   Future<void> loadUser(String id) async {
//     loading.value = true;
//     try {
//       final u = await _userService.getUser(id);
//       user.value = u;
//     } finally {
//       loading.value = false;
//     }
//   }

//   /// Saves the current user to the backend
//   Future<void> saveUser() async {
//     final u = user.value;
//     if (u == null) return;
//     loading.value = true;
//     try {
//       await _userService.saveUser(u);
//     } finally {
//       loading.value = false;
//     }
//   }

//   /// Update the user's personal info (creates a new User instance preserving other fields)
//   void updatePersonalInfo(UserPersonalInfo info) {
//     final u = user.value;
//     if (u == null) return;

//     user.value = User(
//       id: u.id,
//       personalInfo: info,
//       qualifications: u.qualifications,
//       skills: u.skills,
//       plannedTrainings: u.plannedTrainings,
//       completedTrainings: u.completedTrainings,
//       privacy: u.privacy,
//     );
//   }

//   /// Convenience: mark profile as complete by saving (UI can call this after setup)
//   Future<void> completeProfile() async {
//     await saveUser();
//   }
// }
