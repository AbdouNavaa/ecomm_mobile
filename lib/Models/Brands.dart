// {
//             "_id": "6712c5b139d18e2d8caa1bcf",
//             "name": "بوما",
//             "slug": "bwma",
//             "image": "http://127.0.0.1:8000/brands/brand-a87ad9be-0097-47f6-b465-25919d8e9a0e-1729283505031.jpeg",
//             "createdAt": "2024-10-18T20:31:45.047Z",
//             "updatedAt": "2024-10-18T20:31:45.047Z"
//         },

class Brand {
  final String id;
  final String name;
  final String slug;
  final String image;

  Brand(this.id, this.name, this.slug, this.image);

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(json['_id'], json['name'], json['slug'], json['image']);
  }
}