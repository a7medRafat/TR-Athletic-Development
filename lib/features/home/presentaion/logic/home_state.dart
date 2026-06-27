import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final bool hasPreToday;
  final bool hasPostToday;

  const HomeState({
    this.isLoading = false,
    this.hasPreToday = false,
    this.hasPostToday = false,
  });

  HomeState copyWith({
    bool? isLoading,
    bool? hasPreToday,
    bool? hasPostToday,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      hasPreToday: hasPreToday ?? this.hasPreToday,
      hasPostToday: hasPostToday ?? this.hasPostToday,
    );
  }

  @override
  List<Object?> get props => [isLoading, hasPreToday, hasPostToday];
}
