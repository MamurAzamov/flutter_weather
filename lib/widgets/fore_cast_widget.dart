import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ForeCastTileWidget extends StatelessWidget {
  String? temp;
  String? imageUrl;
  String? time;

  ForeCastTileWidget({super.key, this.temp, this.time, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  temp ?? "",
                  style: const TextStyle(color: Colors.white),
                ),
                CachedNetworkImage(
                  imageUrl: imageUrl ?? '',
                  height: 50,
                  width: 50,
                  fit: BoxFit.fill,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, err) => const Icon(
                    Icons.image,
                    color: Colors.white,
                  ),
                ),
                Text(
                  time ?? "",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          )),
    );
  }
}
