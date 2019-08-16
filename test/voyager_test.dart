import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voyager/voyager.dart';

import 'navigation_yml.dart';
import 'navigation_json.dart';
import 'mock_classes.dart';

void main() {
  test('loadPathsFromString loads paths from a yaml defined in a string',
      () async {
    final paths = await loadPathsFromString(navigation_yml);
    expect(paths.length, 2);

    expect(
        paths.map((it) => (it.path)), containsAll(["/home", "/other/:title"]));
  });

  test('loadPathsFromString loads paths from a json defined in a string',
      () async {
    final paths = await loadPathsFromJsonString(navigation_json);
    expect(paths.length, 2);

    expect(
        paths.map((it) => (it.path)), containsAll(["/home", "/other/:title"]));
  });

  test('loadRouter from a yaml defined in a string', () async {
    final paths = loadPathsFromString(navigation_yml);
    final plugins = [
      WidgetPlugin({
        "HomeWidget": (context) => MockHomeWidget(),
        "OtherWidget": (context) => MockOtherWidget(),
      })
    ];

    final router = await loadRouter(paths, plugins);

    final homeVoyager = router.find("/home");

    expect(homeVoyager[WidgetPlugin.KEY](null), isInstanceOf<MockHomeWidget>());
    expect(homeVoyager.type, "home");
  });

  test('loadRouter from a json defined in a string', () async {
    final paths = loadPathsFromJsonString(navigation_json);
    final plugins = [
      WidgetPlugin({
        "HomeWidget": (context) => MockHomeWidget(),
        "OtherWidget": (context) => MockOtherWidget(),
      })
    ];

    final router = await loadRouter(paths, plugins);

    final homeVoyager = router.find("/home");

    expect(homeVoyager[WidgetPlugin.KEY](null), isInstanceOf<MockHomeWidget>());
    expect(homeVoyager.type, "home");
  });

  testWidgets('create HomeWidget via VoyagerWidget',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final paths = loadPathsFromString(navigation_yml);
      final plugins = [
        WidgetPlugin({
          "HomeWidget": (context) => MockHomeWidget(),
          "OtherWidget": (context) => MockOtherWidget(),
        })
      ];

      final router = await loadRouter(paths, plugins);

      expect(router, isInstanceOf<RouterNG>());

      await tester.pumpWidget(
          MaterialApp(home: VoyagerWidget(path: "/home", router: router)));

      expect(find.text("Home Page"), findsOneWidget);
      expect(find.text("Home Title"), findsOneWidget);
    });
  });

  testWidgets(
      'create OtherWidget via VoyagerWidget & inject title through path parameter',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final paths = loadPathsFromString(navigation_yml);
      final plugins = [
        WidgetPlugin({
          "HomeWidget": (context) => MockHomeWidget(),
          "OtherWidget": (context) => MockOtherWidget(),
        })
      ];

      final router = await loadRouter(paths, plugins);

      expect(router, isInstanceOf<RouterNG>());

      await tester.pumpWidget(MaterialApp(
          home: VoyagerWidget(path: "/other/foobar123", router: router)));

      expect(find.text("Other Page"), findsOneWidget);
      expect(find.text("This is foobar123"), findsOneWidget);
    });
  });
}
