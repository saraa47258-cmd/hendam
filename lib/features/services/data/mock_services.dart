import '../models/service.dart';
import '../models/service_category.dart';

const categories = <ServiceCategory>[
  ServiceCategory(id: 'c-men-dishdasha',   nameAr: 'دشداشة',     gender: Gender.men,    sort: 1),
  ServiceCategory(id: 'c-men-tailoring',   nameAr: 'تفصيل رجالي', gender: Gender.men,    sort: 2),
  ServiceCategory(id: 'c-women-abaya',     nameAr: 'عبايات',      gender: Gender.women,  sort: 1),
  ServiceCategory(id: 'c-women-tailoring', nameAr: 'تفصيل نسائي',  gender: Gender.women,  sort: 2),
  ServiceCategory(id: 'c-unisex-alter',    nameAr: 'تعديلات',     gender: Gender.unisex, sort: 99),
];

const services = <Service>[
  // رجالي
  Service(
    id: 's-dishdasha-basic',
    categoryId: 'c-men-dishdasha',
    nameAr: 'تفصيل دشداشة عمانية',
    basePriceOmr: 7.0,
    measurementSchema: {'length':'cm','chest':'cm','sleeve':'cm'},
  ),
  Service(
    id: 's-thobe-saudi',
    categoryId: 'c-men-tailoring',
    nameAr: 'تفصيل ثوب سعودي',
    basePriceOmr: 8.0,
    measurementSchema: {'length':'cm','shoulder':'cm','sleeve':'cm'},
  ),

  // نسائي
  Service(
    id: 's-abaya-black',
    categoryId: 'c-women-abaya',
    nameAr: 'عباية سادة سوداء',
    basePriceOmr: 10.0,
    measurementSchema: {'length':'cm','sleeve':'cm','width':'cm'},
  ),
  Service(
    id: 's-abaya-open',
    categoryId: 'c-women-tailoring',
    nameAr: 'عباية مفتوحة',
    basePriceOmr: 12.0,
    measurementSchema: {'length':'cm','sleeve':'cm','hip':'cm'},
  ),

  // تعديلات
  Service(
    id: 's-alter-pants',
    categoryId: 'c-unisex-alter',
    nameAr: 'تقصير بنطلون',
    basePriceOmr: 2.0,
    measurementSchema: {'newLength':'cm'},
  ),
  Service(
    id: 's-alter-sleeve',
    categoryId: 'c-unisex-alter',
    nameAr: 'تقصير أكمام',
    basePriceOmr: 2.5,
    measurementSchema: {'newSleeve':'cm'},
  ),
];
