import 'package:flutter/material.dart';
import 'app/app_strings.dart';

class AiTryOnResultScreen extends StatelessWidget {
  final ImageProvider image;

  const AiTryOnResultScreen({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final _ = AppStrings.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: () {
                // TODO: إعادة التجربة
              },
            ),
          ],
        ),
        body: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 3 / 5,
              child: Image(
                image: image,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
