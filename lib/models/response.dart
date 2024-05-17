class Response {
  final bool success;
  final String message;
  Response(this.message, this.success);
  factory Response.fromMap(Map<String, dynamic> json) {
    return Response(json['message'], json['success']);
  }
}
