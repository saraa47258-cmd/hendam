// lib/features/favorites/widgets/favorite_button.dart
import 'package:flutter/material.dart';
import '../services/favorite_service.dart';

class FavoriteButton extends StatefulWidget {
  final String productId;
  final String productType;
  final Map<String, dynamic>? productData;
  final Color? iconColor;
  final double? iconSize;

  const FavoriteButton({
    super.key,
    required this.productId,
    required this.productType,
    this.productData,
    this.iconColor,
    this.iconSize = 24,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    final isFav = await FavoriteService().isFavorite(
      productId: widget.productId,
      productType: widget.productType,
    );

    if (mounted) {
      setState(() {
        _isFavorite = isFav;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    bool success;
    if (_isFavorite) {
      success = await FavoriteService().removeFromFavorites(
        productId: widget.productId,
        productType: widget.productType,
      );
    } else {
      success = await FavoriteService().addToFavorites(
        productId: widget.productId,
        productType: widget.productType,
        productData: widget.productData,
      );
    }

    if (mounted && success) {
      setState(() {
        _isFavorite = !_isFavorite;
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isFavorite ? 'تمت الإضافة للمفضلة' : 'تمت الإزالة من المفضلة'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _isLoading ? null : _toggleFavorite,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: _isLoading
              ? SizedBox(
                  width: widget.iconSize,
                  height: widget.iconSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.iconColor ?? cs.primary,
                    ),
                  ),
                )
              : Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite
                      ? Colors.red
                      : (widget.iconColor ?? cs.onSurfaceVariant),
                  size: widget.iconSize,
                ),
        ),
      ),
    );
  }
}
