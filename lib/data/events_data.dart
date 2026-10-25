import '../models/campus_event.dart';

/// Image paths (declared in pubspec.yaml). Category images are reused.
class AppImages {
  static const technology = 'assets/images/technology.jpg';
  static const arts = 'assets/images/arts.jpg';
  static const sports = 'assets/images/sports.jpg';
  static const career = 'assets/images/career.jpg';
}

/// Fictional events. All dates are after the assignment deadline
/// (October 25, 2026). A fresh list is created on every app start,
/// so favorites/participation reset after a restart.
List<CampusEvent> createSampleEvents() => [
      CampusEvent(
        id: 'evt-001',
        title: 'Flutter Hackathon Kickoff',
        category: EventCategory.technology,
        dateTime: DateTime(2026, 11, 4, 10, 0),
        venue: 'Engineering Faculty, Hall B1',
        description:
            'Form teams, meet the mentors and get the theme for our 48-hour '
            'mobile hackathon. Bring a laptop with Flutter installed. '
            'Snacks and drinks are provided.',
        imagePath: AppImages.technology,
        totalCapacity: 40,
        initialAvailablePlaces: 0, // initially FULL
      ),
      CampusEvent(
        id: 'evt-002',
        title: 'Watercolor Workshop',
        category: EventCategory.arts,
        dateTime: DateTime(2026, 11, 6, 15, 30),
        venue: 'Fine Arts Building, Studio 3',
        description:
            'A relaxed beginner workshop on wet-on-wet techniques and color '
            'mixing. All materials are provided; no experience needed.',
        imagePath: AppImages.arts,
        totalCapacity: 12,
        initialAvailablePlaces: 1, // exactly ONE place left
      ),
      CampusEvent(
        id: 'evt-003',
        title: 'Campus 5K Fun Run',
        category: EventCategory.sports,
        dateTime: DateTime(2026, 11, 8, 9, 0),
        venue: 'Main Stadium Track',
        description:
            'A friendly 5 km run around the campus. Walkers are welcome too. '
            'Every finisher gets a medal and a free smoothie.',
        imagePath: AppImages.sports,
        totalCapacity: 150,
        initialAvailablePlaces: 63,
      ),
      CampusEvent(
        id: 'evt-004',
        title: 'Intro to Machine Learning',
        category: EventCategory.technology,
        dateTime: DateTime(2026, 11, 12, 13, 0),
        venue: 'Computer Lab 2, Library Annex',
        description:
            'A hands-on seminar covering the basics of supervised learning '
            'with simple Python notebooks. Suitable for second-year students.',
        imagePath: AppImages.technology,
        totalCapacity: 30,
        initialAvailablePlaces: 8,
      ),
      CampusEvent(
        id: 'evt-005',
        title: 'Open Mic Night',
        category: EventCategory.arts,
        dateTime: DateTime(2026, 11, 14, 19, 30),
        venue: 'Student Center Cafe',
        description:
            'Poetry, music or stand-up: the stage is yours for five minutes. '
            'Sign up at the door or just come and enjoy the show.',
        imagePath: AppImages.arts,
        totalCapacity: 60,
        initialAvailablePlaces: 25,
      ),
      CampusEvent(
        id: 'evt-006',
        title: 'Basketball Tournament Finals',
        category: EventCategory.sports,
        dateTime: DateTime(2026, 11, 21, 17, 0),
        venue: 'Sports Hall A',
        description:
            'Watch the inter-faculty basketball finals live. Seats are '
            'limited, so reserve yours early and bring your faculty colors.',
        imagePath: AppImages.sports,
        totalCapacity: 200,
        initialAvailablePlaces: 2,
      ),
      CampusEvent(
        id: 'evt-007',
        title: 'CV & LinkedIn Clinic',
        category: EventCategory.career,
        dateTime: DateTime(2026, 11, 25, 11, 0),
        venue: 'Career Center, Room 104',
        description:
            'Career advisors review your CV and LinkedIn profile one-on-one. '
            'Bring a printed or digital copy of your current CV.',
        imagePath: AppImages.career,
        totalCapacity: 20,
        initialAvailablePlaces: 11,
      ),
      CampusEvent(
        id: 'evt-008',
        title: 'Startup Pitch Day',
        category: EventCategory.career,
        dateTime: DateTime(2026, 12, 3, 14, 0),
        venue: 'Conference Hall, Rectorate Building',
        description:
            'Student teams pitch their startup ideas to a jury of alumni '
            'founders. Join as an audience member and vote for your favorite.',
        imagePath: AppImages.career,
        totalCapacity: 120,
        initialAvailablePlaces: 47,
      ),
    ];
