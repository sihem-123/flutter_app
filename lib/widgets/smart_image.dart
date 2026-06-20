import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget intelligent pour afficher des images - gère les images locales,
/// réseau, et les erreurs de chargement. Résout le problème des images invisibles.
class SmartImage extends StatelessWidget {
  final String? imageUrl;
  final String? localAsset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String fallbackAsset;

  const SmartImage({
    super.key,
    this.imageUrl,
    this.localAsset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackAsset = 'assets/images/placeholder.png',
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    // Priorité: image locale d'abord, puis URL réseau
    if (localAsset != null && localAsset!.isNotEmpty) {
      imageWidget = _buildLocalImage(localAsset!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty && 
               (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'))) {
      imageWidget = _buildNetworkImage(imageUrl!);
    } else {
      // Fallback vers l'image placeholder locale
      imageWidget = _buildLocalImage(fallbackAsset);
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: SizedBox(
          width: width,
          height: height,
          child: imageWidget,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: imageWidget,
    );
  }

  Widget _buildLocalImage(String asset) {
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildNetworkImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _buildLoadingPlaceholder(),
      errorWidget: (context, url, error) {
        // En cas d'erreur réseau, essaie l'asset local ou le placeholder
        if (localAsset != null && localAsset!.isNotEmpty) {
          return Image.asset(
            localAsset!,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          );
        }
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE0E0E0),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF1A237E),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE8EAF6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey[400],
            size: (height ?? 100) * 0.3,
          ),
        ],
      ),
    );
  }
}

/// Version avec ratio d'aspect pour les cartes
class SmartImageCard extends StatelessWidget {
  final String? imageUrl;
  final String? localAsset;
  final double aspectRatio;
  final BorderRadius? borderRadius;

  const SmartImageCard({
    super.key,
    this.imageUrl,
    this.localAsset,
    this.aspectRatio = 16 / 9,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: SmartImage(
        imageUrl: imageUrl,
        localAsset: localAsset,
        fit: BoxFit.cover,
        borderRadius: borderRadius,
      ),
    );
  }
}
