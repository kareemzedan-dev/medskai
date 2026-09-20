class InvalidField {
  String? field;
  String? message;

  InvalidField({this.field, this.message});

  InvalidField.fromJson(Map<String, dynamic> json) {
    field = json['field']?.toString();
    message = json['message']?.toString();
  }
}

class ContactFormResponse {
  String? status;
  String? message;
  List<InvalidField> invalidFields = [];

  ContactFormResponse({this.status, this.message});

  ContactFormResponse.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toString();
    message = json['message']?.toString();

    if (json['invalid_fields'] != null && json['invalid_fields'] is List) {
      invalidFields = (json['invalid_fields'] as List)
          .map((e) => InvalidField.fromJson(e))
          .toList();
    }
  }

  bool get isSuccess => status == 'mail_sent';
  bool get isValidationError => status == 'validation_failed';
  bool get isFailed => status == 'mail_failed';
}
