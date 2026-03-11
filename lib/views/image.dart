import 'package:flutter/material.dart';
import 'package:getbike_admin/APIs/apis.dart';

class ImageView extends StatelessWidget {
  final String image;
  ImageView({required this.image, super.key});

  @override
  Widget build(BuildContext context) {
    // Construct full URL if relative
    String fullImageUrl = image;
    if (!image.startsWith('http')) {
      if (image.startsWith('/')) {
        fullImageUrl = "$IMAGEBASEURL$image";
      } else {
        fullImageUrl = "$IMAGEBASEURL/$image";
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: InteractiveViewer(
            child: Image.network(
              fullImageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                print("Error loading image in ImageView: $error");
                print("Attempted URL: $fullImageUrl");
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.broken_image,
                      size: 80,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Unable to load image",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "URL returns invalid data (likely HTML)",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    SelectableText(
                      fullImageUrl,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
