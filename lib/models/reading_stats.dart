class ReadingStats {
  int totalMinutes;
  int booksOpened;
  int streakDays;
  String lastReadDate;
  Map<String, int> dailyReading;

  ReadingStats({
    this.totalMinutes = 0,
    this.booksOpened = 0,
    this.streakDays = 0,
    this.lastReadDate = "",
    Map<String, int>? dailyReading,
  }) : dailyReading = dailyReading ?? {};

  Map<String, dynamic> toJson() => {
        "totalMinutes": totalMinutes,
        "booksOpened": booksOpened,
        "streakDays": streakDays,
        "lastReadDate": lastReadDate,
        "dailyReading": dailyReading,
      };

  factory ReadingStats.fromJson(Map<String, dynamic> json) =>
      ReadingStats(
        totalMinutes: json["totalMinutes"] ?? 0,
        booksOpened: json["booksOpened"] ?? 0,
        streakDays: json["streakDays"] ?? 0,
        lastReadDate: json["lastReadDate"] ?? "",
        dailyReading: Map<String, int>.from(
          json["dailyReading"] ?? {},
        ),
      );
}