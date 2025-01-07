import 'package:flutter/material.dart';

/// Flutter code sample for [SearchBar].

void main() => runApp(const SearchBarApp());

class CustomSnackBar {
  static void show(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 3)}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16.0,
        right: 16.0,
        // width: MediaQuery.of(context).size.width,
        child: _SnackBarWidget(message: message),
      ),
    );

    overlay.insert(overlayEntry);

    // 自动移除
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }
}

class _SnackBarWidget extends StatefulWidget {
  final String message;

  const _SnackBarWidget({required this.message});

  @override
  State<_SnackBarWidget> createState() => _SnackBarWidgetState();
}

class _SnackBarWidgetState extends State<_SnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final ThemeData theme = Theme.of(context);
    // final SnackBarThemeData snackBarTheme = theme.snackBarTheme;
    return FadeTransition(
      opacity: _animationController,
      child: Material(
        elevation: 6.0,
        color: Colors.black87,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Text(
            widget.message,
            style: const TextStyle(color: Colors.white, fontSize: 16.0),
          ),
        ),
      ),
    );
  }
}

class SearchBarApp extends StatefulWidget {
  const SearchBarApp({super.key});

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

class _SearchBarAppState extends State<SearchBarApp> {
  bool isDark = false;

  void showCustomSnackbar(BuildContext context) {
    OverlayEntry? overlayEntry;
    final overlayState = Overlay.of(context);
    bool isVisible = true;

    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          width: MediaQuery.of(context).size.width,
          height: 100,
          child: AnimatedOpacity(
            opacity: isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: const Material(
              color: Colors.red,
              child: SafeArea(
                child: Center(
                  child: Text(
                    'Awesome Snackbar!',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(overlayEntry);

    // 開始計時器，三秒後淡出並移除 Overlay
    Future.delayed(const Duration(seconds: 3), () {
      isVisible = false; // 設置透明度為 0
      overlayEntry?.markNeedsBuild(); // 觸發重繪

      // 再等動畫結束後移除 OverlayEntry
      Future.delayed(const Duration(milliseconds: 500), () {
        overlayEntry?.remove();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light);

    return MaterialApp(
      theme: themeData,
      home: Scaffold(
        appBar: AppBar(title: const Text('Search Bar Sample')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SearchAnchor(
              isFullScreen: false,
              keyboardType: TextInputType.number,
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0)),
                  onTap: () {
                    controller.openView();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Awesome Snackbar!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    // CustomSnackBar.show(context, '123123123');
                  },
                  onChanged: (_) {
                    controller.openView();
                  },
                  leading: const Icon(Icons.search),
                  trailing: <Widget>[
                    Tooltip(
                      message: 'Change brightness mode',
                      child: IconButton(
                        isSelected: isDark,
                        onPressed: () {
                          setState(() {
                            isDark = !isDark;
                          });
                        },
                        icon: const Icon(Icons.wb_sunny_outlined),
                        selectedIcon: const Icon(Icons.brightness_2_outlined),
                      ),
                    )
                  ],
                );
              },
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                return List<ListTile>.generate(5, (int index) {
                  final String item = 'item $index';
                  return ListTile(
                    title: Text(item),
                    onTap: () {
                      setState(() {
                        controller.closeView(item);
                      });
                    },
                  );
                });
              }),
        ),
      ),
    );
  }
}
