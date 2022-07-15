import 'package:cake/cake.dart';
import 'package:cycle_models/cycle_models.dart';

void main() {
  TestRunner('Task Item', [
    Group('Init', [
      Test<TaskItem>(
        'should init from form - simple',
        assertions: (context) =>
            [Expect.isNotNull(TaskItem.fromForm(name: 'Name', parentId: ''))],
      ),
      TestWithContext<TaskItem, _TaskItemPropertiesContext<TaskItem>>(
        'should init from form - full',
        action: (test) {
          Tag tag1 = Tag.fromForm('Tag name');
          test.form = {
            'name': 'Full item',
            'parentId': '',
            'dueDate': DateHelper.getToday(),
            'category': TaskCategory('category', ''),
            'description': 'cool description',
            'tags': {
              tag1.id: tag1,
            },
          };
          return TaskItem.fromForm(
              name: test.form['name'],
              parentId: test.form['parentId'],
              dueDate: test.form['dueDate'],
              category: test.form['category'],
              description: test.form['description'],
              tags: test.form['tags']);
        },
        assertions: (test) {
          return [
            Expect.isNotNull(test.actual),
            Expect.equals(
                actual: test.actual!.name, expected: test.form['name']),
            Expect.equals(
                actual: test.actual!.dueDate, expected: test.form['dueDate']),
            Expect.equals(
                actual: test.actual!.category, expected: test.form['category']),
            Expect.equals(
                actual: test.actual!.tags, expected: test.form['tags']),
            Expect.isFalse(test.actual!.complete),
            Expect.isNotNull(test.actual!.createdOn),
          ];
        },
        contextBuilder: _TaskItemPropertiesContext<TaskItem>.new,
      ),
      Test<TaskItem>(
        'should convert to and from map',
        action: (test) {
          Tag tag1 = Tag.fromForm('Tag name');
          TaskItem item = TaskItem.fromForm(
            name: 'Full item',
            parentId: '',
            dueDate: DateHelper.getToday(),
            category: TaskCategory('category', ''),
            description: 'cool description',
            tags: {
              tag1.id: tag1,
            },
          );
          Map<String, dynamic> map = item.toMap();
          test.expected = item;
          return TaskItem.fromMap(map);
        },
        assertions: (test) => [
          Expect.isNotNull(test.actual),
          Expect.equals(
              actual: test.actual!.name, expected: test.expected!.name),
          Expect.equals(
              actual: test.actual!.complete, expected: test.expected!.complete),
          Expect.equals(
              actual: test.actual!.parentId, expected: test.expected!.parentId),
          Expect.equals(
              actual: test.actual!.dueDate, expected: test.expected!.dueDate),
          Expect.equals(
              actual: test.actual!.cycleId, expected: test.expected!.cycleId),
          Expect.equals(
              actual: test.actual!.createdOn,
              expected: test.expected!.createdOn),
          Expect.equals(
              actual: test.actual!.description,
              expected: test.expected!.description),
          Expect.equals(
              actual: test.actual!.category!.id,
              expected: test.expected!.category!.id),
          Expect.equals(
              actual: test.actual!.tags.length,
              expected: test.expected!.tags.length),
        ],
      ),
    ]),
    GroupWithContext<TaskHistory, _TaskItemPropertiesContext<TaskHistory>>(
      'Properties',
      [
        TestWithContext(
          'should be able to complete item',
          action: (test) {
            test.item.updateComplete(true);
          },
          assertions: (test) => [
            Expect.isNotNull(test.actual),
            Expect.isTrue(test.item.complete),
            Expect.isNotNull(test.item.completedLast),
            Expect.equals(
                expected: test.actual?.action, actual: historyActions.complete),
          ],
        ),
        TestWithContext(
          'should be able to uncomplete an item',
          action: (test) {
            test.item.updateComplete(true);
            return test.item.updateComplete(false);
          },
          assertions: (test) => [
            Expect.isNotNull(test.actual),
            Expect.isFalse(test.item.complete),
            Expect.isNull(test.item.completedLast),
            Expect.equals(
                expected: test.actual?.action,
                actual: historyActions.uncomplete),
          ],
        ),
        TestWithContext(
          'should do nothing if complete is the same',
          action: (test) => test.item.updateComplete(test.item.complete),
          assertions: (test) => [
            Expect.isNull(test.actual),
            Expect.isFalse(test.item.complete),
            Expect.isNull(test.item.completedLast),
          ],
        ),
        TestWithContext(
          'should move parent list',
          action: (test) {
            test.mockNewList = TaskListMock();
            return test.item.moveParentList(TaskListMock(), test.mockNewList);
          },
          assertions: (test) => [
            Expect.equals(
                expected: test.item.parentId, actual: test.mockNewList),
            Expect.equals(
                expected: test.actual?.action, actual: historyActions.move),
          ],
        ),
        TestWithContext(
          'should move parent category',
          action: (test) {
            test.category = TaskCategory('New Category', '');
            test.actual = test.item.moveParentCategory(test.category);
          },
          assertions: (test) => [
            Expect.equals(expected: test.category, actual: test.item.category),
            Expect.isNotNull(test.actual),
            Expect.equals(
                expected: historyActions.moveCategory,
                actual: test.actual?.action),
          ],
        ),
        TestWithContext(
          'should not do anything if parent category is the same',
          action: (test) {
            test.category = TaskCategory('New Category', '');
            test.item.moveParentCategory(test.category);
            test.actual = test.item.moveParentCategory(test.category);
          },
          assertions: (test) => [Expect.isNotNull(test.actual)],
        ),
        TestWithContext(
          'should update name',
          action: (test) {
            test['newName'] = 'Cool Name';
            test.actual = test.item.updateName(test['newName']);
          },
          assertions: (test) => [
            Expect.equals(expected: test['newName'], actual: test.item.name),
            Expect.isNotNull(test.actual),
            Expect.equals(
                expected: historyActions.edit, actual: test.actual!.action),
          ],
        ),
        TestWithContext(
          'should not update name if the same',
          action: (test) {
            String name = 'Cool Name';
            test.item.updateName(name);
            test.actual = test.item.updateName(name);
          },
          assertions: (test) => [
            Expect.isNull(test.actual),
          ],
        ),
        TestWithContext(
          'should not update name if name is empty',
          action: (test) => test.actual = test.item.updateName(''),
          assertions: (test) => [Expect.isNull(test.actual)],
        ),
        TestWithContext(
          'should update due date',
          action: (test) {
            test['dueDate'] = DateHelper.getToday();
            test.actual = test.item.updateDueDate(test['dueDate']);
          },
          assertions: (test) => [
            Expect.equals(expected: test['dueDate'], actual: test.item.dueDate),
            Expect.isNotNull(test.actual),
            Expect.equals(
                expected: historyActions.edit, actual: test.actual!.action),
          ],
        ),
        TestWithContext(
          'should not update due date if the same',
          action: (test) {
            test['dueDate'] = DateHelper.getToday();
            test.item.updateDueDate(test['dueDate']);
            test.actual = test.item.updateDueDate(test['dueDate']);
          },
          assertions: (test) => [Expect.isNull(test.actual)],
        ),
        TestWithContext(
          'should update description',
          action: (test) {
            test['description'] = 'My cool description';
            test.actual = test.item.updateDescription(test['description']);
          },
          assertions: (test) => [
            Expect.equals(
                expected: test['description'], actual: test.item.description),
            Expect.isNotNull(test.actual),
            Expect.equals(
                expected: historyActions.edit, actual: test.actual!.action),
          ],
        ),
        TestWithContext(
          'should not update description if the same',
          action: (test) {
            test['description'] = 'My cool description';
            test.item.updateDescription(test['description']);
            test.actual = test.item.updateDescription(test['description']);
          },
          assertions: (test) => [Expect.isNull(test.actual)],
        ),
        TestWithContext(
          'should add tag',
          action: (test) {
            test.actual = test.item.addTag(test.tag);
          },
          assertions: (test) => [
            Expect.equals(expected: 1, actual: test.item.tags),
            Expect.isNotNull(test.actual),
            Expect.equals(
                expected: historyActions.addTag, actual: test.actual!.action),
          ],
        ),
        TestWithContext(
          'should not add tag if already added',
          action: (test) {
            test.item.addTag(test.tag);
            test.actual = test.item.addTag(test.tag);
          },
          assertions: (test) => [
            Expect.equals(expected: 1, actual: test.item.tags),
            Expect.isNotNull(test.actual),
            Expect.equals(
                expected: historyActions.addTag, actual: test.actual!.action),
          ],
        ),
        TestWithContext(
          'should remove tag',
          action: (test) {
            test.item.addTag(test.tag);
            return test.item.removeTag(test.tag);
          },
          assertions: (test) => [
            Expect.equals(actual: test.item.tags.length, expected: 0),
            Expect.isNotNull(test.actual),
            Expect.equals(
                actual: test.actual!.action,
                expected: historyActions.removeTag),
          ],
        ),
        TestWithContext(
          'should not try to remove tag if already removed',
          action: (test) {
            test.item.addTag(test.tag);
            test.item.removeTag(test.tag);
            return test.item.removeTag(test.tag);
          },
          assertions: (test) => [
            Expect.equals(actual: test.item.tags.length, expected: 0),
            Expect.isNull(test.actual),
          ],
        ),
      ],
      contextBuilder: _TaskItemPropertiesContext.new,
      setup: (test) {
        test.item = TaskItem.fromForm(name: 'My test', parentId: '');
      },
    ),
  ]);
}

class _TaskItemPropertiesContext<T> extends Context<T> {
  late TaskItem item;
  late Map<String, dynamic> form;
  TaskListMock mockNewList = TaskListMock();
  late TaskCategory category;
  TagMock tag = TagMock();

  @override
  void copyExtraParams<C extends Context>(C contextToCopy) {
    if (contextToCopy is _TaskItemPropertiesContext) {
      item = contextToCopy.item;
    }
  }
}
