class Book {
  String id;
  String titulo;
  String autor;
  String conteudo;
  int position;
  String? resumo;

  Book({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.conteudo,
    this.position = 0,
    this.resumo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'autor': autor,
      'conteudo': conteudo,
      'position': position,
      
    };
  }

  factory Book.fromJson(Map<String, dynamic> json, String id) {
    return Book(
      id: id,
      titulo: json['titulo'] ?? '',
      autor: json['autor'] ?? '',
      conteudo: json['conteudo'] ?? '',
      position: json['position'] ?? 0,
      resumo: json['resumo'],
    );
  }
}