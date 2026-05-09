class ReadingStats {
  int totalMinutes;
  int booksOpened;
  int streakDays;
  String lastReadDate;
  String lastOpenedBookId;
  String lastOpenedTitle;
  String lastOpenedAuthor;
  double lastOpenedProgress;
  Map<String, int> dailyReading;

  ReadingStats({
    this.totalMinutes = 0,
    this.booksOpened = 0,
    this.streakDays = 0,
    this.lastReadDate = "",
    this.lastOpenedBookId = "",
    this.lastOpenedTitle = "",
    this.lastOpenedAuthor = "",
    this.lastOpenedProgress = 0,
    Map<String, int>? dailyReading,
  }) : dailyReading = dailyReading ?? {};

  Map<String, dynamic> toJson() => {
        "totalMinutes": totalMinutes,
        "booksOpened": booksOpened,
        "streakDays": streakDays,
        "lastReadDate": lastReadDate,
        "lastOpenedBookId": lastOpenedBookId,
        "lastOpenedTitle": lastOpenedTitle,
        "lastOpenedAuthor": lastOpenedAuthor,
        "lastOpenedProgress": lastOpenedProgress,
        "dailyReading": dailyReading,
      };

  factory ReadingStats.fromJson(Map<String, dynamic> json) =>
      ReadingStats(
        totalMinutes: json["totalMinutes"] ?? 0,
        booksOpened: json["booksOpened"] ?? 0,
        streakDays: json["streakDays"] ?? 0,
        lastReadDate: json["lastReadDate"] ?? "",
        lastOpenedBookId: json["lastOpenedBookId"] ?? "",
        lastOpenedTitle: json["lastOpenedTitle"] ?? "",
        lastOpenedAuthor: json["lastOpenedAuthor"] ?? "",
        lastOpenedProgress: (json["lastOpenedProgress"] ?? 0).toDouble(),
        dailyReading: Map<String, int>.from(
          json["dailyReading"] ?? {},
        ),
      );
}
