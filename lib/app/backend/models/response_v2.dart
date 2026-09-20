class ResponseV2 {
  String? status;
  String? message;
  dynamic data;

  ResponseV2({
    this.status,
    this.message,
    this.data,
  });

  ResponseV2.fromJson(
    Map<String, dynamic> json,
  ) {
    status = json['status']?.toString();
    message = json['message']?.toString();
    final dynamic newData = json['data'];
    if (newData is Map<String, dynamic>) {
      data = newData["items"];
    } else {
      data = newData;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = <String, dynamic>{};
    result['status'] = status;
    result['message'] = message;
    result['data'] = data;

    return result;
  }
}
