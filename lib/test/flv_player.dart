import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class FlvPlayer extends StatefulWidget {
  final String url;

  const FlvPlayer({super.key, required this.url});

  @override
  _FlvPlayerState createState() => _FlvPlayerState();
}

class _FlvPlayerState extends State<FlvPlayer> {
  final String playerId = 'flv-player-${DateTime.now().millisecondsSinceEpoch}';

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      '''
      <video id="videoElement"></video>
      <script>
          if (mpegts.getFeatureList().mseLivePlayback) {
              var videoElement = document.getElementById('videoElement');
              var player = mpegts.createPlayer({
                  type: 'mse',  // could also be mpegts, m2ts, flv
                  isLive: true,
                  url: ${widget.url}'
              });
              player.attachMediaElement(videoElement);
              player.load();
              player.play();
          }
      </script>
      ''',
      factoryBuilder: () => _FlvWidgetFactory(),
      key: ValueKey(widget.url),
    );
  }
}

class _FlvWidgetFactory extends WidgetFactory {
  @override
  bool get webViewMediaPlaybackAlwaysAllow => true;
}
