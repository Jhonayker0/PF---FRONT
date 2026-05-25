import 'event.dart';
import 'event_review.dart';

class UserReviewEntry {
  const UserReviewEntry({
    required this.event,
    required this.review,
  });

  final Event event;
  final EventReview review;

  String get eventTitle => event.title;
  String get eventLocation => event.location;
  String get eventDate => event.date;
}