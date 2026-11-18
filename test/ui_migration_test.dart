import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('DropdownSearch', () {
    testWidgets('selects an item under the extracted MaterialApp',
        (tester) async {
      String? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownSearch<String>(
              items: (filter, loadProps) => ['Monday', 'Tuesday'],
              onSelected: (value) => selected = value,
              popupProps: const PopupProps.menu(searchDelay: Duration.zero),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownSearch<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tuesday'));
      await tester.pumpAndSettle();

      expect(selected, 'Tuesday');
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps autocomplete anchored and handles empty backspace', (
      tester,
    ) async {
      final key = GlobalKey<DropdownSearchState<String>>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: DropdownSearch<String>.multiSelection(
                key: key,
                items: (filter, loadProps) => ['Monday', 'Tuesday'],
                popupProps: MultiSelectionPopupProps.autocomplete(
                  searchDelay: Duration.zero,
                  autoCompleteProps: AutocompleteProps(
                    groupId: Object(),
                    align: MenuAlign.bottomStart,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownSearch<String>));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();

      expect(key.currentState!.getSelectedItems, isEmpty);
      expect(find.text('Monday'), findsOneWidget);
      final popup = find
          .ancestor(of: find.text('Monday'), matching: find.byType(Material))
          .first;
      final bounds = tester.getRect(popup);
      final fieldBounds = tester.getRect(find.byType(DropdownSearch<String>));
      expect(bounds.top, greaterThanOrEqualTo(fieldBounds.bottom));
      expect(bounds.height, lessThan(300));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
