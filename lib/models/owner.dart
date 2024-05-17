class Owner {
  final int ownerID, hotelID;
  final String ownerName, ownerEmail, phone, apiKey, s3url;
  Owner(this.ownerID, this.hotelID, this.ownerName, this.ownerEmail, this.phone,
      this.apiKey, this.s3url);
  factory Owner.fromMap(Map<String, dynamic> json) {
    return Owner(
      json['id'],
      json['restaurent_id'],
      json['name'],
      json['email'],
      json['mobileno'] == null || json['mobileno'] == ""
          ? (json['alternative_mobileno'] == null
              ? ""
              : json['alternative_mobileno'])
          : json['mobileno'],
      json['api_token'],
      json['s3url'],
    );
  }
  Map<String, dynamic> get json {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map['user_id'] = ownerID;
    map['name'] = ownerName;
    map['email'] = ownerEmail;
    map['mobileno'] = phone;
    map['api_key'] = apiKey;
    return map;
  }
}
