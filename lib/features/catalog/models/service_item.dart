import 'package:flutter/material.dart';

@immutable
class ServiceItem {
  final String name;
  final double price;
  final double rating;
  final String variantsLabel;

  const ServiceItem({
    required this.name,
    required this.price,
    required this.rating,
    required this.variantsLabel,
  });
}
