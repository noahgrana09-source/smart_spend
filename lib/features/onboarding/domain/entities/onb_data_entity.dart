import 'package:equatable/equatable.dart';

/// The user's onboarding data: nationality and investor risk profile.
///
/// Both fields are required and non-nullable — the app blocks progress
/// past onboarding until they're set, so a null value here would be a
/// business-logic error, not a valid state.
class OnbDataEntity extends Equatable {
  /// The user's nationality.
  final String nationality;

  /// The user's investor risk profile (e.g. Conservative/Moderate/
  /// Aggressive).
  final String investorProfile;

  /// Creates an [OnbDataEntity] with the given [nationality] and
  /// [investorProfile].
  const OnbDataEntity({
    required this.nationality,
    required this.investorProfile,
  });

  @override
  List<Object?> get props => [nationality, investorProfile];
}
