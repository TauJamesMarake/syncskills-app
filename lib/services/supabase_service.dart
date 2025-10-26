// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class SupabaseService {
//   final supabase = Supabase.instance.client;
//   // Create / upsert profile (store auth uid)
//   Future<void> upsertProfile(
//     String authUid,
//     Map<String, dynamic> profileData,
//   ) async {
//     final response = await supabase.from('profiles').upsert({
//       'auth_uid': authUid,
//       ...profileData,
//     }).execute();
//     if (response.error != null) throw response.error!;
//   }

//   // Insert skill
//   Future<void> addSkill(
//     String userId,
//     String title, {
//     String? proficiency,
//   }) async {
//     final res = await supabase.from('skills').insert({
//       'user_id': userId,
//       'title': title,
//       'proficiency': proficiency,
//     }).execute();
//     if (res.error != null) throw res.error!;
//   }

//   // Update skill
//   Future<void> updateSkill(String id, Map<String, dynamic> values) async {
//     final res = await supabase
//         .from('skills')
//         .update(values)
//         .eq('id', id)
//         .execute();
//     if (res.error != null) throw res.error!;
//   }

//   // Fetch skills for current user
//   Future<List<Map<String, dynamic>>> fetchSkills(String userId) async {
//     final res = await supabase
//         .from('skills')
//         .select()
//         .eq('user_id', userId)
//         .order('updated_at', ascending: false)
//         .execute();
//     if (res.error != null) throw res.error!;
//     return List<Map<String, dynamic>>.from(res.data as List);
//   }

//   // Planned courses: insert many
//   Future<void> addPlannedCourses(
//     String userId,
//     List<Map<String, dynamic>> courses,
//   ) async {
//     final payload = courses
//         .map(
//           (c) => {
//             'user_id': userId,
//             'title': c['title'],
//             'expected_completion_date': c['date'],
//           },
//         )
//         .toList();
//     final res = await supabase
//         .from('planned_courses')
//         .insert(payload)
//         .execute();
//     if (res.error != null) throw res.error!;
//   }

//   // Upload certificate to storage
//   Future<String?> uploadCertificate(
//     String userId,
//     String filename,
//     List<int> bytes,
//   ) async {
//     final path = '$userId/$filename';
//     final res = await supabase.storage
//         .from('certificates')
//         .uploadBinary(path, bytes);
//     if (res.error != null) throw res.error!;
//     final publicUrl = supabase.storage
//         .from('certificates')
//         .getPublicUrl(path)
//         .data;
//     return publicUrl;
//   }
// }
