import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class AppSearchAnchor extends StatefulWidget {
  const AppSearchAnchor({
    required this.suggestionsBuilder,
    this.searchController,
    this.isFullScreen,
    this.isSearchLoading,
    this.viewOnChanged,
    this.viewOnSubmitted,
    this.viewOnPop,
    this.viewBuilder,
    this.viewLeading,
    this.viewTrailing,
    this.viewHintText,
    this.viewBackgroundColor,
    this.viewElevation,
    this.viewSurfaceTintColor,
    this.viewSide,
    this.viewShape,
    this.headerHeight,
    this.headerTextStyle,
    this.headerHintStyle,
    this.dividerColor,
    this.viewConstraints,
    this.textCapitalization,
    this.textInputAction,
    this.keyboardType,
    super.key,
  });

  final XwSearchController? searchController;
  final bool? isFullScreen;
  final bool? isSearchLoading;
  final ValueChanged<String>? viewOnChanged;
  final ValueChanged<String>? viewOnSubmitted;
  final ViewBuilder? viewBuilder;
  final Widget? viewLeading;
  final Iterable<Widget>? viewTrailing;
  final String? viewHintText;
  final Color? viewBackgroundColor;
  final double? viewElevation;
  final Color? viewSurfaceTintColor;
  final BorderSide? viewSide;
  final OutlinedBorder? viewShape;
  final double? headerHeight;
  final TextStyle? headerTextStyle;
  final TextStyle? headerHintStyle;
  final Color? dividerColor;
  final BoxConstraints? viewConstraints;
  final TextCapitalization? textCapitalization;
  final SuggestionsBuilder suggestionsBuilder;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final void Function(XwSearchViewRoute? result)? viewOnPop;

  @override
  State<StatefulWidget> createState() => _AppSearchAnchorState();
}

class _AppSearchAnchorState extends State<AppSearchAnchor> {
  _AppSearchAnchorState();

  bool _anchorIsVisible = true;
  bool get _viewIsOpen => !_anchorIsVisible;
  Size? _screenSize;
  final GlobalKey _anchorKey = GlobalKey();
  XwSearchController? _internalSearchController;
  XwSearchController get _searchController =>
      widget.searchController ??
      (_internalSearchController ??= XwSearchController());

  @override
  void initState() {
    super.initState();
    _searchController._attach(this);
  }

  @override
  void didUpdateWidget(AppSearchAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchController != widget.searchController) {
      oldWidget.searchController?._detach(this);
      _searchController._attach(this);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final updatedScreenSize = MediaQuery.of(context).size;
    if (_screenSize != null && _screenSize != updatedScreenSize) {
      if (_searchController.isOpen && !getShowFullScreenView()) {
        _closeView(null);
      }
    }
    _screenSize = updatedScreenSize;
  }

  @override
  void dispose() {
    super.dispose();
    widget.searchController?._detach(this);
    _internalSearchController?._detach(this);
    _internalSearchController?.dispose();
  }

  void _openView() {
    final navigator = Navigator.of(context);
    navigator.push(XwSearchViewRoute(
      viewOnChanged: widget.viewOnChanged,
      viewOnSubmitted: widget.viewOnSubmitted,
      viewOnPop: widget.viewOnPop,
      viewLeading: widget.viewLeading,
      viewTrailing: widget.viewTrailing,
      viewHintText: widget.viewHintText,
      viewBackgroundColor: widget.viewBackgroundColor,
      viewElevation: widget.viewElevation,
      viewSurfaceTintColor: widget.viewSurfaceTintColor,
      viewSide: widget.viewSide,
      viewShape: widget.viewShape,
      viewHeaderHeight: widget.headerHeight,
      viewHeaderTextStyle: widget.headerTextStyle,
      viewHeaderHintStyle: widget.headerHintStyle,
      dividerColor: widget.dividerColor,
      viewConstraints: widget.viewConstraints,
      showFullScreenView: getShowFullScreenView(),
      toggleVisibility: toggleVisibility,
      textDirection: Directionality.of(context),
      viewBuilder: widget.viewBuilder,
      anchorKey: _anchorKey,
      searchController: _searchController,
      suggestionsBuilder: widget.suggestionsBuilder,
      textCapitalization: widget.textCapitalization,
      // ignore: lines_longer_than_80_chars
      capturedThemes:
          InheritedTheme.capture(from: context, to: navigator.context),
      textInputAction: widget.textInputAction,
      keyboardType: widget.keyboardType,
      isSearchLoading: widget.isSearchLoading,
    ));
  }

  void _closeView(String? selectedText) {
    if (selectedText != null) {
      _searchController.text = selectedText;
    }
    Navigator.of(context).pop();
  }

  bool toggleVisibility() {
    setState(() {
      _anchorIsVisible = !_anchorIsVisible;
    });
    return _anchorIsVisible;
  }

  bool getShowFullScreenView() {
    return widget.isFullScreen ??
        switch (Theme.of(context).platform) {
          // ignore: lines_longer_than_80_chars
          TargetPlatform.iOS ||
          TargetPlatform.android ||
          TargetPlatform.fuchsia =>
            true,
          // ignore: lines_longer_than_80_chars
          TargetPlatform.macOS ||
          TargetPlatform.linux ||
          TargetPlatform.windows =>
            false,
        };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      key: _anchorKey,
      opacity: _anchorIsVisible ? 1.0 : 0.0,
      duration: _kAnchorFadeDuration,
      child: SearchBar(
          controller: _searchController,
          onTap: _openView,
          leading: const Icon(Icons.search),
          hintText: 'Search',
          elevation: WidgetStateProperty.all(0)),
    );
  }
}

class XwSearchController extends TextEditingController {
  _AppSearchAnchorState? _anchor;

  bool get isAttached => _anchor != null;

  bool get isOpen {
    return _anchor!._viewIsOpen;
  }

  void openView() {
    _anchor!._openView();
  }

  void closeView(String? selectedText) {
    _anchor!._closeView(selectedText);
  }

  // ignore: use_setters_to_change_properties
  void _attach(_AppSearchAnchorState anchor) {
    _anchor = anchor;
  }

  void _detach(_AppSearchAnchorState anchor) {
    if (_anchor == anchor) {
      _anchor = null;
    }
  }
}

const int _kOpenViewMilliseconds = 600;
// ignore: lines_longer_than_80_chars
const Duration _kOpenViewDuration =
    Duration(milliseconds: _kOpenViewMilliseconds);
const Duration _kAnchorFadeDuration = Duration(milliseconds: 150);
const Curve _kViewFadeOnInterval = Interval(0, 1 / 2);
const Curve _kViewIconsFadeOnInterval = Interval(1 / 6, 2 / 6);
const Curve _kViewDividerFadeOnInterval = Interval(0, 1 / 6);
// ignore: lines_longer_than_80_chars
const Curve _kViewListFadeOnInterval =
    Interval(133 / _kOpenViewMilliseconds, 233 / _kOpenViewMilliseconds);

// ignore: lines_longer_than_80_chars
typedef SearchAnchorChildBuilder = Widget Function(
    BuildContext context, XwSearchController controller);
// ignore: lines_longer_than_80_chars
typedef SuggestionsBuilder = FutureOr<Iterable<Widget>> Function(
    BuildContext context, XwSearchController controller);

class XwSearchViewRoute extends PopupRoute<XwSearchViewRoute> {
  XwSearchViewRoute({
    required this.showFullScreenView,
    required this.anchorKey,
    required this.searchController,
    required this.suggestionsBuilder,
    required this.capturedThemes,
    this.viewOnChanged,
    this.viewOnSubmitted,
    this.viewOnPop,
    this.toggleVisibility,
    this.textDirection,
    this.viewBuilder,
    this.viewLeading,
    this.viewTrailing,
    this.viewHintText,
    this.viewBackgroundColor,
    this.viewElevation,
    this.viewSurfaceTintColor,
    this.viewSide,
    this.viewShape,
    this.viewHeaderHeight,
    this.viewHeaderTextStyle,
    this.viewHeaderHintStyle,
    this.dividerColor,
    this.viewConstraints,
    this.textCapitalization,
    this.textInputAction,
    this.keyboardType,
    this.isSearchLoading,
  });

  final ValueChanged<String>? viewOnChanged;
  final ValueChanged<String>? viewOnSubmitted;
  final void Function(XwSearchViewRoute? result)? viewOnPop;
  final ValueGetter<bool>? toggleVisibility;
  final TextDirection? textDirection;
  final ViewBuilder? viewBuilder;
  final Widget? viewLeading;
  final Iterable<Widget>? viewTrailing;
  final String? viewHintText;
  final Color? viewBackgroundColor;
  final double? viewElevation;
  final Color? viewSurfaceTintColor;
  final BorderSide? viewSide;
  final OutlinedBorder? viewShape;
  final double? viewHeaderHeight;
  final TextStyle? viewHeaderTextStyle;
  final TextStyle? viewHeaderHintStyle;
  final Color? dividerColor;
  final BoxConstraints? viewConstraints;
  final TextCapitalization? textCapitalization;
  final bool showFullScreenView;
  final GlobalKey anchorKey;
  final XwSearchController searchController;
  final SuggestionsBuilder suggestionsBuilder;
  final CapturedThemes capturedThemes;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final bool? isSearchLoading;
  CurvedAnimation? curvedAnimation;
  CurvedAnimation? viewFadeOnIntervalCurve;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss';

  late final SearchViewThemeData viewDefaults;
  late final SearchViewThemeData viewTheme;
  final RectTween _rectTween = RectTween();

  Rect? getRect() {
    final context = anchorKey.currentContext;
    if (context != null) {
      final searchBarBox = context.findRenderObject()! as RenderBox;
      final boxSize = searchBarBox.size;
      final navigator = Navigator.of(context);
      // ignore: lines_longer_than_80_chars
      final boxLocation = searchBarBox.localToGlobal(Offset.zero,
          ancestor: navigator.context.findRenderObject());
      return boxLocation & boxSize;
    }
    return null;
  }

  @override
  TickerFuture didPush() {
    updateViewConfig(anchorKey.currentContext!);
    updateTweens(anchorKey.currentContext!);
    toggleVisibility?.call();
    return super.didPush();
  }

  @override
  bool didPop(XwSearchViewRoute? result) {
    updateTweens(anchorKey.currentContext!);
    toggleVisibility?.call();
    searchController.clear();
    viewOnPop?.call(result);
    return super.didPop(result);
  }

  @override
  void dispose() {
    curvedAnimation?.dispose();
    viewFadeOnIntervalCurve?.dispose();
    super.dispose();
  }

  void updateViewConfig(BuildContext context) {
    // ignore: lines_longer_than_80_chars
    viewDefaults =
        _SearchViewDefaultsM3(context, isFullScreen: showFullScreenView);
    viewTheme = SearchViewTheme.of(context);
  }

  void updateTweens(BuildContext context) {
    // ignore: lines_longer_than_80_chars
    final navigator =
        Navigator.of(context).context.findRenderObject()! as RenderBox;
    final screenSize = navigator.size;
    final anchorRect = getRect() ?? Rect.zero;

    // ignore: lines_longer_than_80_chars
    final effectiveConstraints =
        viewConstraints ?? viewTheme.constraints ?? viewDefaults.constraints!;
    _rectTween.begin = anchorRect;

    // ignore: lines_longer_than_80_chars
    final viewWidth = clampDouble(anchorRect.width,
        effectiveConstraints.minWidth, effectiveConstraints.maxWidth);
    // ignore: lines_longer_than_80_chars
    final viewHeight = clampDouble(screenSize.height * 2 / 3,
        effectiveConstraints.minHeight, effectiveConstraints.maxHeight);

    switch (textDirection ?? TextDirection.ltr) {
      case TextDirection.ltr:
        final viewLeftToScreenRight = screenSize.width - anchorRect.left;
        final viewTopToScreenBottom = screenSize.height - anchorRect.top;

        // Make sure the search view doesn't go off the screen.
        // If the search view
        // doesn't fit, move the top-left corner of the view to fit the window.
        // If the window is smaller than the view
        // , then we resize the view to fit the window.
        var topLeft = anchorRect.topLeft;
        if (viewLeftToScreenRight < viewWidth) {
          // ignore: lines_longer_than_80_chars
          topLeft = Offset(
              screenSize.width - math.min(viewWidth, screenSize.width),
              topLeft.dy);
        }
        if (viewTopToScreenBottom < viewHeight) {
          // ignore: lines_longer_than_80_chars
          topLeft = Offset(topLeft.dx,
              screenSize.height - math.min(viewHeight, screenSize.height));
        }
        final endSize = Size(viewWidth, viewHeight);
        // ignore: lines_longer_than_80_chars
        _rectTween.end =
            showFullScreenView ? Offset.zero & screenSize : (topLeft & endSize);
        return;
      case TextDirection.rtl:
        final viewRightToScreenLeft = anchorRect.right;
        final viewTopToScreenBottom = screenSize.height - anchorRect.top;

        // Make sure the search view doesn't go off the screen.
        // ignore: lines_longer_than_80_chars
        var topLeft =
            Offset(math.max(anchorRect.right - viewWidth, 0), anchorRect.top);
        if (viewRightToScreenLeft < viewWidth) {
          topLeft = Offset(0, topLeft.dy);
        }
        if (viewTopToScreenBottom < viewHeight) {
          // ignore: lines_longer_than_80_chars
          topLeft = Offset(topLeft.dx,
              screenSize.height - math.min(viewHeight, screenSize.height));
        }
        final endSize = Size(viewWidth, viewHeight);
        // ignore: lines_longer_than_80_chars
        _rectTween.end =
            showFullScreenView ? Offset.zero & screenSize : (topLeft & endSize);
    }
  }

  @override
  // ignore: lines_longer_than_80_chars
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Directionality(
      textDirection: textDirection ?? TextDirection.ltr,
      child: AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            curvedAnimation ??= CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubicEmphasized,
              reverseCurve: Curves.easeInOutCubicEmphasized.flipped,
            );

            final viewRect = _rectTween.evaluate(curvedAnimation!)!;
            final topPadding = showFullScreenView
                // ignore: lines_longer_than_80_chars
                ? lerpDouble(0.0, MediaQuery.paddingOf(context).top,
                    curvedAnimation!.value)!
                : 0.0;

            viewFadeOnIntervalCurve ??= CurvedAnimation(
              parent: animation,
              curve: _kViewFadeOnInterval,
              reverseCurve: _kViewFadeOnInterval.flipped,
            );

            return FadeTransition(
              opacity: viewFadeOnIntervalCurve!,
              child: capturedThemes.wrap(
                _ViewContent(
                  viewOnChanged: viewOnChanged,
                  viewOnSubmitted: viewOnSubmitted,
                  viewLeading: viewLeading,
                  viewTrailing: viewTrailing,
                  viewHintText: viewHintText,
                  viewBackgroundColor: viewBackgroundColor,
                  viewElevation: viewElevation,
                  viewSurfaceTintColor: viewSurfaceTintColor,
                  viewSide: viewSide,
                  viewShape: viewShape,
                  viewHeaderHeight: viewHeaderHeight,
                  viewHeaderTextStyle: viewHeaderTextStyle,
                  viewHeaderHintStyle: viewHeaderHintStyle,
                  dividerColor: dividerColor,
                  showFullScreenView: showFullScreenView,
                  animation: curvedAnimation!,
                  topPadding: topPadding,
                  viewMaxWidth: _rectTween.end!.width,
                  viewRect: viewRect,
                  viewBuilder: viewBuilder,
                  searchController: searchController,
                  suggestionsBuilder: suggestionsBuilder,
                  textCapitalization: textCapitalization,
                  textInputAction: textInputAction,
                  keyboardType: keyboardType,
                  isSearchLoading: isSearchLoading,
                ),
              ),
            );
          }),
    );
  }

  @override
  Duration get transitionDuration => _kOpenViewDuration;
}

class _SearchViewDefaultsM3 extends SearchViewThemeData {
  _SearchViewDefaultsM3(this.context, {required this.isFullScreen});

  final BuildContext context;
  final bool isFullScreen;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  static double fullScreenBarHeight = 72;

  @override
  Color? get backgroundColor => _colors.surface;

  @override
  double? get elevation => 6;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  // No default side

  @override
  OutlinedBorder? get shape => isFullScreen
      ? const RoundedRectangleBorder()
      // ignore: lines_longer_than_80_chars
      : const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)));

  @override
  // ignore: lines_longer_than_80_chars
  TextStyle? get headerTextStyle =>
      _textTheme.bodyLarge?.copyWith(color: _colors.onSurface);

  @override
  // ignore: lines_longer_than_80_chars
  TextStyle? get headerHintStyle =>
      _textTheme.bodyLarge?.copyWith(color: _colors.onSurfaceVariant);

  @override
  // ignore: lines_longer_than_80_chars
  BoxConstraints get constraints =>
      const BoxConstraints(minWidth: 360, minHeight: 240);

  @override
  Color? get dividerColor => _colors.outline;
}

class _ViewContent extends StatefulWidget {
  const _ViewContent({
    required this.showFullScreenView,
    required this.topPadding,
    required this.animation,
    required this.viewMaxWidth,
    required this.viewRect,
    required this.searchController,
    required this.suggestionsBuilder,
    this.viewOnChanged,
    this.viewOnSubmitted,
    this.viewBuilder,
    this.viewLeading,
    this.viewTrailing,
    this.viewHintText,
    this.viewBackgroundColor,
    this.viewElevation,
    this.viewSurfaceTintColor,
    this.viewSide,
    this.viewShape,
    this.viewHeaderHeight,
    this.viewHeaderTextStyle,
    this.viewHeaderHintStyle,
    this.dividerColor,
    this.textCapitalization,
    this.textInputAction,
    this.keyboardType,
    this.isSearchLoading,
  });

  final ValueChanged<String>? viewOnChanged;
  final ValueChanged<String>? viewOnSubmitted;
  final ViewBuilder? viewBuilder;
  final Widget? viewLeading;
  final Iterable<Widget>? viewTrailing;
  final String? viewHintText;
  final Color? viewBackgroundColor;
  final double? viewElevation;
  final Color? viewSurfaceTintColor;
  final BorderSide? viewSide;
  final OutlinedBorder? viewShape;
  final double? viewHeaderHeight;
  final TextStyle? viewHeaderTextStyle;
  final TextStyle? viewHeaderHintStyle;
  final Color? dividerColor;
  final TextCapitalization? textCapitalization;
  final bool showFullScreenView;
  final double topPadding;
  final Animation<double> animation;
  final double viewMaxWidth;
  final Rect viewRect;
  final XwSearchController searchController;
  final SuggestionsBuilder suggestionsBuilder;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final bool? isSearchLoading;

  @override
  State<_ViewContent> createState() => _ViewContentState();
}

class _ViewContentState extends State<_ViewContent> {
  Size? _screenSize;
  late Rect _viewRect;
  late CurvedAnimation viewIconsFadeCurve;
  late CurvedAnimation viewDividerFadeCurve;
  late CurvedAnimation viewListFadeOnIntervalCurve;
  late final XwSearchController _controller;
  Iterable<Widget> result = <Widget>[];
  String? searchValue;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _viewRect = widget.viewRect;
    _controller = widget.searchController;
    _controller.addListener(updateSuggestions);
    _setupAnimations();
  }

  @override
  void didUpdateWidget(covariant _ViewContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.viewRect != oldWidget.viewRect) {
      setState(() {
        _viewRect = widget.viewRect;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final updatedScreenSize = MediaQuery.of(context).size;

    if (_screenSize != updatedScreenSize) {
      _screenSize = updatedScreenSize;
      if (widget.showFullScreenView) {
        _viewRect = Offset.zero & _screenSize!;
      }
    }

    if (searchValue != _controller.text) {
      _timer?.cancel();
      _timer = Timer(Duration.zero, () async {
        searchValue = _controller.text;
        final suggestions =
            await widget.suggestionsBuilder(context, _controller);
        _timer?.cancel();
        _timer = null;
        if (mounted) {
          setState(() {
            result = suggestions;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(updateSuggestions);
    _disposeAnimations();
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  void _setupAnimations() {
    viewIconsFadeCurve = CurvedAnimation(
      parent: widget.animation,
      curve: _kViewIconsFadeOnInterval,
      reverseCurve: _kViewIconsFadeOnInterval.flipped,
    );
    viewDividerFadeCurve = CurvedAnimation(
      parent: widget.animation,
      curve: _kViewDividerFadeOnInterval,
      reverseCurve: _kViewFadeOnInterval.flipped,
    );
    viewListFadeOnIntervalCurve = CurvedAnimation(
      parent: widget.animation,
      curve: _kViewListFadeOnInterval,
      reverseCurve: _kViewListFadeOnInterval.flipped,
    );
  }

  void _disposeAnimations() {
    viewIconsFadeCurve.dispose();
    viewDividerFadeCurve.dispose();
    viewListFadeOnIntervalCurve.dispose();
  }

  Widget viewBuilder(Iterable<Widget> suggestions) {
    if (widget.viewBuilder == null) {
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            _controller.closeView('');
          },
          child: SafeArea(
              child: ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: Stack(
              children: [
                if (widget.isSearchLoading ?? false)
                  const LinearProgressIndicator(),
                ListView(children: suggestions.toList())
              ],
            ),
          )),
        ),
      );
    }
    return widget.viewBuilder!(suggestions);
  }

  Future<void> updateSuggestions() async {
    if (searchValue != _controller.text) {
      searchValue = _controller.text;
      final suggestions = await widget.suggestionsBuilder(context, _controller);
      if (mounted) {
        setState(() {
          result = suggestions;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget defaultLeading = IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () {
        Navigator.of(context).pop();
      },
      style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
    );

    final defaultTrailing = <Widget>[
      if (_controller.text.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.close),
          tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
          onPressed: () {
            _controller.clear();
          },
        ),
    ];

    // ignore: lines_longer_than_80_chars
    final SearchViewThemeData viewDefaults =
        _SearchViewDefaultsM3(context, isFullScreen: widget.showFullScreenView);
    final viewTheme = SearchViewTheme.of(context);
    final dividerTheme = DividerTheme.of(context);

    final effectiveBackgroundColor = widget.viewBackgroundColor ??
        viewTheme.backgroundColor ??
        viewDefaults.backgroundColor!;
    final effectiveSurfaceTint = widget.viewSurfaceTintColor ??
        viewTheme.surfaceTintColor ??
        viewDefaults.surfaceTintColor!;
    final effectiveElevation =
        widget.viewElevation ?? viewTheme.elevation ?? viewDefaults.elevation!;
    final effectiveSide =
        widget.viewSide ?? viewTheme.side ?? viewDefaults.side;
    var effectiveShape =
        widget.viewShape ?? viewTheme.shape ?? viewDefaults.shape!;
    if (effectiveSide != null) {
      effectiveShape = effectiveShape.copyWith(side: effectiveSide);
    }
    final effectiveDividerColor = widget.dividerColor ??
        viewTheme.dividerColor ??
        dividerTheme.color ??
        viewDefaults.dividerColor!;
    // ignore: lines_longer_than_80_chars
    final effectiveHeaderHeight =
        widget.viewHeaderHeight ?? viewTheme.headerHeight;
    final headerConstraints = effectiveHeaderHeight == null
        ? null
        : BoxConstraints.tightFor(height: effectiveHeaderHeight);
    final effectiveTextStyle = widget.viewHeaderTextStyle ??
        viewTheme.headerTextStyle ??
        viewDefaults.headerTextStyle;
    final effectiveHintStyle = widget.viewHeaderHintStyle ??
        viewTheme.headerHintStyle ??
        widget.viewHeaderTextStyle ??
        viewTheme.headerTextStyle ??
        viewDefaults.headerHintStyle;

    final Widget viewDivider = DividerTheme(
      data: dividerTheme.copyWith(color: effectiveDividerColor),
      child: const Divider(height: 1),
    );

    return Align(
      alignment: Alignment.topLeft,
      child: Transform.translate(
        offset: _viewRect.topLeft,
        child: SizedBox(
          width: _viewRect.width,
          height: _viewRect.height,
          child: Material(
            clipBehavior: Clip.antiAlias,
            shape: effectiveShape,
            color: effectiveBackgroundColor,
            surfaceTintColor: effectiveSurfaceTint,
            elevation: effectiveElevation,
            child: ClipRect(
              clipBehavior: Clip.antiAlias,
              child: OverflowBox(
                alignment: Alignment.topLeft,
                maxWidth: math.min(widget.viewMaxWidth, _screenSize!.width),
                minWidth: 0,
                child: FadeTransition(
                  opacity: viewIconsFadeCurve,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: widget.topPadding),
                        child: SafeArea(
                          top: false,
                          bottom: false,
                          child: SearchBar(
                            autoFocus: true,
                            // ignore: lines_longer_than_80_chars
                            constraints: headerConstraints ??
                                (widget.showFullScreenView
                                    ? BoxConstraints(
                                        minHeight: _SearchViewDefaultsM3
                                            .fullScreenBarHeight)
                                    : null),
                            leading: widget.viewLeading ?? defaultLeading,
                            trailing: widget.viewTrailing ?? defaultTrailing,
                            hintText: widget.viewHintText,
                            backgroundColor:
                                // ignore: deprecated_member_use
                                const MaterialStatePropertyAll<Color>(
                                    Colors.transparent),
                            // ignore: deprecated_member_use, lines_longer_than_80_chars
                            overlayColor: const MaterialStatePropertyAll<Color>(
                                Colors.transparent),
                            elevation:
                                // ignore: deprecated_member_use
                                const MaterialStatePropertyAll<double>(0),
                            // ignore: deprecated_member_use, lines_longer_than_80_chars
                            textStyle: MaterialStatePropertyAll<TextStyle?>(
                                effectiveTextStyle),
                            // ignore: deprecated_member_use, lines_longer_than_80_chars
                            hintStyle: MaterialStatePropertyAll<TextStyle?>(
                                effectiveHintStyle),
                            controller: _controller,
                            onChanged: (String value) {
                              widget.viewOnChanged?.call(value);
                              updateSuggestions();
                            },
                            onSubmitted: widget.viewOnSubmitted,
                            textCapitalization: widget.textCapitalization,
                            textInputAction: widget.textInputAction,
                            keyboardType: widget.keyboardType,
                            onTapOutside: (_) {
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ),
                      ),
                      FadeTransition(
                          opacity: viewDividerFadeCurve, child: viewDivider),
                      Expanded(
                        child: FadeTransition(
                          opacity: viewListFadeOnIntervalCurve,
                          child: viewBuilder(result),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
