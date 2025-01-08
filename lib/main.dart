import 'package:flutter/material.dart';

/// Flutter code sample for [SearchBar].

void main() => runApp(const SearchBarApp());

class SearchBarApp extends StatefulWidget {
  const SearchBarApp({super.key});

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

class _SearchBarAppState extends State<SearchBarApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light);

    final snackBar = SnackBar(
      content: const Text('Yay! A SnackBar!'),
      behavior: SnackBarBehavior.floating,
      elevation: 5.0,
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    return MaterialApp(
      theme: themeData,
      home: Scaffold(
          appBar: AppBar(title: const Text('Search Bar Sample')),
          body: Stack(
            children: [
              Column(
                children: [
                  SearchAnchor(
                      viewElevation: 4.0,
                      keyboardType: TextInputType.number,
                      builder:
                          (BuildContext context, SearchController controller) {
                        return SearchBar(
                          controller: controller,
                          padding: const WidgetStatePropertyAll<EdgeInsets>(
                              EdgeInsets.symmetric(horizontal: 16.0)),
                          onTap: () {
                            controller.openView();
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
                                selectedIcon:
                                    const Icon(Icons.brightness_2_outlined),
                              ),
                            )
                          ],
                        );
                      },
                      suggestionsBuilder:
                          (BuildContext context, SearchController controller) {
                        return [
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 400.0,
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: 5,
                              itemBuilder: (BuildContext context, int index) {
                                final String item = 'item: $index';
                                return ListTile(
                                  title: Text(item),
                                  onTap: () {
                                    debugPrint('Selected: $item');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Selected: $item'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    setState(() {
                                      // controller.closeView(item);
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ];
                      })
                ],
              ),
            ],
          )),
    );
  }
}
