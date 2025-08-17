class KeralaDistricts {
  static const List<Map<String, String>> districts = [
    {
      'id': 'thiruvananthapuram',
      'name': 'Thiruvananthapuram',
      'image': 'assets/images/thiruvananthapuram.jpg',
    },
    {
      'id': 'kollam',
      'name': 'Kollam',
      'image': 'assets/images/kollam.jpg',
    },
    {
      'id': 'pathanamthitta',
      'name': 'Pathanamthitta',
      'image': 'assets/images/pathanamthitta.jpg',
    },
    {
      'id': 'alappuzha',
      'name': 'Alappuzha',
      'image': 'assets/images/alappuzha.jpg',
    },
    {
      'id': 'kottayam',
      'name': 'Kottayam',
      'image': 'assets/images/kottayam.jpg',
    },
    {
      'id': 'idukki',
      'name': 'Idukki',
      'image': 'assets/images/idukki.jpg',
    },
    {
      'id': 'ernakulam',
      'name': 'Ernakulam',
      'image': 'assets/images/ernakulam.jpg',
    },
    {
      'id': 'thrissur',
      'name': 'Thrissur',
      'image': 'assets/images/thrissur.jpg',
    },
    {
      'id': 'palakkad',
      'name': 'Palakkad',
      'image': 'assets/images/palakkad.jpg',
    },
    {
      'id': 'malappuram',
      'name': 'Malappuram',
      'image': 'assets/images/malappuram.jpg',
    },
    {
      'id': 'kozhikode',
      'name': 'Kozhikode',
      'image': 'assets/images/kozhikode.jpg',
    },
    {
      'id': 'wayanad',
      'name': 'Wayanad',
      'image': 'assets/images/wayanad.jpg',
    },
    {
      'id': 'kannur',
      'name': 'Kannur',
      'image': 'assets/images/kannur.jpg',
    },
    {
      'id': 'kasaragod',
      'name': 'Kasaragod',
      'image': 'assets/images/kasaragod.jpg',
    },
  ];

  static String getDistrictName(String id) {
    final district = districts.firstWhere(
      (d) => d['id'] == id,
      orElse: () => {'name': 'Unknown'},
    );
    return district['name']!;
  }
}