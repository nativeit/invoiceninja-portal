import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/redux/task/task_actions.dart';
import 'package:invoiceninja_flutter/redux/task/task_selectors.dart';
import 'package:invoiceninja_flutter/redux/task_status/task_status_actions.dart';
import 'package:invoiceninja_flutter/ui/task/kanban_view.dart';
import 'package:invoiceninja_flutter/utils/completers.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';
import 'package:redux/redux.dart';

class KanbanViewBuilder extends StatefulWidget {
  const KanbanViewBuilder({Key key}) : super(key: key);

  @override
  _KanbanViewBuilderState createState() => _KanbanViewBuilderState();
}

class _KanbanViewBuilderState extends State<KanbanViewBuilder> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, KanbanVM>(
      converter: KanbanVM.fromStore,
      builder: (context, viewModel) {
        final state = viewModel.state;
        final company = state.company;
        return KanbanView(
          viewModel: viewModel,
          key: ValueKey(
              '__${company.id}_${state.userCompanyState.lastUpdated}_${viewModel.taskList.length}__'),
        );
      },
    );
  }
}

class KanbanVM {
  KanbanVM({
    @required this.state,
    @required this.taskList,
    @required this.onStatusOrderChanged,
    @required this.onTaskOrderChanged,
    @required this.onSaveTaskPressed,
  });

  static KanbanVM fromStore(Store<AppState> store) {
    final state = store.state;

    return KanbanVM(
      state: state,
      taskList: memoizedFilteredTaskList(
          state.getUISelection(EntityType.task),
          state.taskState.map,
          state.clientState.map,
          state.userState.map,
          state.projectState.map,
          state.invoiceState.map,
          state.taskState.list,
          state.taskListState),
      onStatusOrderChanged: (context, statusId, index) {
        final localization = AppLocalization.of(context);
        final taskStatus = state.taskStatusState.get(statusId);
        final completer = snackBarCompleter<TaskStatusEntity>(
            context, localization.updatedTaskStatus);
        completer.future.then((value) {
          // TODO remove this
          store.dispatch(RefreshData());
        }).catchError((Object error) {
          store.dispatch(RefreshData());
        });
        store.dispatch(SaveTaskStatusRequest(
            completer: completer,
            taskStatus: taskStatus.rebuild((b) => b.statusOrder = index)));
      },
      onTaskOrderChanged: (context, taskId, statusId, index) {
        final localization = AppLocalization.of(context);
        final task = state.taskState.get(taskId);
        final completer =
            snackBarCompleter<TaskEntity>(context, localization.updatedTask);
        completer.future.then((value) {
          // TODO remove this
          store.dispatch(RefreshData());
        }).catchError((Object error) {
          store.dispatch(RefreshData());
        });
        store.dispatch(SaveTaskRequest(
          completer: completer,
          task: task.rebuild((b) => b
            ..statusOrder = index
            ..statusId = statusId),
        ));
      },
      onSaveTaskPressed: (context, taskId, statusId, description) {
        final localization = AppLocalization.of(context);
        final task = state.taskState.get(taskId);
        final completer =
            snackBarCompleter<TaskEntity>(context, localization.updatedTask);
        store.dispatch(SaveTaskRequest(
          completer: completer,
          task: task.rebuild((b) => b
            ..description = description
            ..statusId = statusId),
        ));
      },
    );
  }

  final AppState state;
  final List<String> taskList;
  final Function(BuildContext, String, int) onStatusOrderChanged;
  final Function(BuildContext, String, String, int) onTaskOrderChanged;
  final Function(BuildContext, String, String, String) onSaveTaskPressed;
}
