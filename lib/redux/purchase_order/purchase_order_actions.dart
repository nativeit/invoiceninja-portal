import 'dart:async';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:http/http.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/redux/design/design_selectors.dart';
import 'package:invoiceninja_flutter/utils/completers.dart';
import 'package:invoiceninja_flutter/utils/dialogs.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';
import 'package:invoiceninja_flutter/ui/app/entities/entity_actions_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewPurchaseOrderList implements PersistUI {
  ViewPurchaseOrderList({this.force = false});

  final bool force;
}

class ViewPurchaseOrder implements PersistUI, PersistPrefs {
  ViewPurchaseOrder({
    @required this.purchaseOrderId,
    this.force = false,
  });

  final String purchaseOrderId;
  final bool force;
}

class EditPurchaseOrder implements PersistUI, PersistPrefs {
  EditPurchaseOrder(
      {@required this.purchaseOrder,
      this.completer,
      this.purchaseOrderItemIndex,
      this.cancelCompleter,
      this.force = false});

  final InvoiceEntity purchaseOrder;
  final Completer completer;
  final int purchaseOrderItemIndex;
  final Completer cancelCompleter;
  final bool force;
}

class ShowEmailPurchaseOrder {
  ShowEmailPurchaseOrder({this.purchaseOrder, this.context, this.completer});

  final InvoiceEntity purchaseOrder;
  final BuildContext context;
  final Completer completer;
}

class ShowPdfPurchaseOrder {
  ShowPdfPurchaseOrder({this.purchaseOrder, this.context, this.activityId});

  final InvoiceEntity purchaseOrder;
  final BuildContext context;
  final String activityId;
}

class EditPurchaseOrderItem implements PersistUI {
  EditPurchaseOrderItem([this.itemIndex]);

  final int itemIndex;
}

class UpdatePurchaseOrder implements PersistUI {
  UpdatePurchaseOrder(this.purchaseOrder);

  final InvoiceEntity purchaseOrder;
}

class UpdatePurchaseOrderVendor implements PersistUI {
  UpdatePurchaseOrderVendor({this.vendor});

  final VendorEntity vendor;
}

class LoadPurchaseOrder {
  LoadPurchaseOrder({this.completer, this.purchaseOrderId});

  final Completer completer;
  final String purchaseOrderId;
}

class LoadPurchaseOrderActivity {
  LoadPurchaseOrderActivity({this.completer, this.purchaseOrderId});

  final Completer completer;
  final String purchaseOrderId;
}

class LoadPurchaseOrders {
  LoadPurchaseOrders({this.completer, this.page = 1});

  final Completer completer;
  final int page;
}

class LoadPurchaseOrderRequest implements StartLoading {}

class LoadPurchaseOrderFailure implements StopLoading {
  LoadPurchaseOrderFailure(this.error);

  final dynamic error;

  @override
  String toString() {
    return 'LoadPurchaseOrderFailure{error: $error}';
  }
}

class LoadPurchaseOrderSuccess implements StopLoading, PersistData {
  LoadPurchaseOrderSuccess(this.purchaseOrder);

  final InvoiceEntity purchaseOrder;

  @override
  String toString() {
    return 'LoadPurchaseOrderSuccess{purchaseOrder: $purchaseOrder}';
  }
}

class LoadPurchaseOrdersRequest implements StartLoading {}

class LoadPurchaseOrdersFailure implements StopLoading {
  LoadPurchaseOrdersFailure(this.error);

  final dynamic error;

  @override
  String toString() {
    return 'LoadPurchaseOrdersFailure{error: $error}';
  }
}

class LoadPurchaseOrdersSuccess implements StopLoading {
  LoadPurchaseOrdersSuccess(this.purchaseOrders);

  final BuiltList<InvoiceEntity> purchaseOrders;

  @override
  String toString() {
    return 'LoadPurchaseOrdersSuccess{purchaseOrders: $purchaseOrders}';
  }
}

class SavePurchaseOrderDocumentRequest implements StartSaving {
  SavePurchaseOrderDocumentRequest({
    @required this.completer,
    @required this.multipartFile,
    @required this.purchaseOrder,
  });

  final Completer completer;
  final MultipartFile multipartFile;
  final InvoiceEntity purchaseOrder;
}

class SavePurchaseOrderDocumentSuccess
    implements StopSaving, PersistData, PersistUI {
  SavePurchaseOrderDocumentSuccess(this.document);

  final DocumentEntity document;
}

class SavePurchaseOrderDocumentFailure implements StopSaving {
  SavePurchaseOrderDocumentFailure(this.error);

  final Object error;
}

class SavePurchaseOrderRequest implements StartSaving {
  SavePurchaseOrderRequest({
    this.completer,
    this.purchaseOrder,
    this.action,
  });

  final Completer completer;
  final InvoiceEntity purchaseOrder;
  final EntityAction action;
}

class SavePurchaseOrderSuccess implements StopSaving, PersistData, PersistUI {
  SavePurchaseOrderSuccess(this.purchaseOrder);

  final InvoiceEntity purchaseOrder;
}

class AddPurchaseOrderSuccess implements StopSaving, PersistData, PersistUI {
  AddPurchaseOrderSuccess(this.purchaseOrder);

  final InvoiceEntity purchaseOrder;
}

class SavePurchaseOrderFailure implements StopSaving {
  SavePurchaseOrderFailure(this.error);

  final Object error;
}

class BulkEmailPurchaseOrdersRequest implements StartSaving {
  BulkEmailPurchaseOrdersRequest(this.completer, this.purchaseOrderIds);

  final Completer completer;
  final List<String> purchaseOrderIds;
}

class BulkEmailPurchaseOrdersSuccess implements StopSaving, PersistData {
  BulkEmailPurchaseOrdersSuccess(this.purchaseOrders);

  final List<InvoiceEntity> purchaseOrders;
}

class BulkEmailPurchaseOrdersFailure implements StopSaving {
  BulkEmailPurchaseOrdersFailure(this.error);

  final dynamic error;
}

class ArchivePurchaseOrdersRequest implements StartSaving {
  ArchivePurchaseOrdersRequest(this.completer, this.purchaseOrderIds);

  final Completer completer;
  final List<String> purchaseOrderIds;
}

class ArchivePurchaseOrdersSuccess implements StopSaving, PersistData {
  ArchivePurchaseOrdersSuccess(this.purchaseOrders);

  final List<InvoiceEntity> purchaseOrders;
}

class ArchivePurchaseOrdersFailure implements StopSaving {
  ArchivePurchaseOrdersFailure(this.purchaseOrders);

  final List<InvoiceEntity> purchaseOrders;
}

class DeletePurchaseOrdersRequest implements StartSaving {
  DeletePurchaseOrdersRequest(this.completer, this.purchaseOrderIds);

  final Completer completer;
  final List<String> purchaseOrderIds;
}

class DeletePurchaseOrdersSuccess implements StopSaving, PersistData {
  DeletePurchaseOrdersSuccess(this.purchaseOrders);

  final List<InvoiceEntity> purchaseOrders;
}

class DeletePurchaseOrdersFailure implements StopSaving {
  DeletePurchaseOrdersFailure(this.purchaseOrders);

  final List<InvoiceEntity> purchaseOrders;
}

class DownloadPurchaseOrdersRequest implements StartSaving {
  DownloadPurchaseOrdersRequest(this.completer, this.invoiceIds);

  final Completer completer;
  final List<String> invoiceIds;
}

class DownloadPurchaseOrdersSuccess implements StopSaving {}

class DownloadPurchaseOrdersFailure implements StopSaving {
  DownloadPurchaseOrdersFailure(this.error);

  final Object error;
}

class AcceptPurchaseOrdersRequest implements StartSaving {
  AcceptPurchaseOrdersRequest(this.completer, this.purchaseOrderIds);

  final List<String> purchaseOrderIds;
  final Completer completer;
}

class AcceptPurchaseOrderSuccess implements StopSaving {
  AcceptPurchaseOrderSuccess(this.purchaseOrders);

  final List<InvoiceEntity> purchaseOrders;
}

class AcceptPurchaseOrderFailure implements StopSaving {
  AcceptPurchaseOrderFailure(this.error);

  final dynamic error;
}

class CancelPurchaseOrdersRequest implements StartSaving {
  CancelPurchaseOrdersRequest(this.completer, this.purchaseOrderIds);

  final List<String> purchaseOrderIds;
  final Completer completer;
}

class CancelPurchaseOrderSuccess implements StopSaving {
  CancelPurchaseOrderSuccess(this.purchaseOrders);

  final List<InvoiceEntity> purchaseOrders;
}

class CancelPurchaseOrderFailure implements StopSaving {
  CancelPurchaseOrderFailure(this.error);

  final dynamic error;
}

class RestorePurchaseOrdersRequest implements StartSaving {
  RestorePurchaseOrdersRequest(this.completer, this.purchaseOrderIds);

  final Completer completer;
  final List<String> purchaseOrderIds;
}

class RestorePurchaseOrdersSuccess implements StopSaving, PersistData {
  RestorePurchaseOrdersSuccess(this.purchaseOrders);

  final List<InvoiceEntity> purchaseOrders;
}

class RestorePurchaseOrdersFailure implements StopSaving {
  RestorePurchaseOrdersFailure(this.purchaseOrders);

  final List<InvoiceEntity> purchaseOrders;
}

class EmailPurchaseOrderRequest implements StartSaving {
  EmailPurchaseOrderRequest(
      {this.completer,
      this.purchaseOrderId,
      this.template,
      this.subject,
      this.body});

  final Completer completer;
  final String purchaseOrderId;
  final EmailTemplate template;
  final String subject;
  final String body;
}

class EmailPurchaseOrderSuccess implements StopSaving, PersistData {
  EmailPurchaseOrderSuccess(this.purchaseOrder);

  final InvoiceEntity purchaseOrder;
}

class EmailPurchaseOrderFailure implements StopSaving {
  EmailPurchaseOrderFailure(this.error);

  final dynamic error;
}

class MarkPurchaseOrdersSentRequest implements StartSaving {
  MarkPurchaseOrdersSentRequest(this.completer, this.purchaseOrderIds);

  final Completer completer;
  final List<String> purchaseOrderIds;
}

class MarkPurchaseOrderSentSuccess implements StopSaving, PersistData {
  MarkPurchaseOrderSentSuccess(this.purchaseOrders);

  final List<InvoiceEntity> purchaseOrders;
}

class MarkPurchaseOrderSentFailure implements StopSaving {
  MarkPurchaseOrderSentFailure(this.error);

  final Object error;
}

class ConvertPurchaseOrdersToExpensesRequest implements StartSaving {
  ConvertPurchaseOrdersToExpensesRequest(this.completer, this.purchaseOrderIds);

  final Completer completer;
  final List<String> purchaseOrderIds;
}

class ConvertPurchaseOrdersToExpensesSuccess
    implements StopSaving, PersistData {
  ConvertPurchaseOrdersToExpensesSuccess(this.purchaseOrders);

  final List<InvoiceEntity> purchaseOrders;
}

class ConvertPurchaseOrdersToExpensesFailure implements StopSaving {
  ConvertPurchaseOrdersToExpensesFailure(this.error);

  final Object error;
}

class AddPurchaseOrdersToInventoryRequest implements StartSaving {
  AddPurchaseOrdersToInventoryRequest(this.completer, this.purchaseOrderIds);

  final Completer completer;
  final List<String> purchaseOrderIds;
}

class AddPurchaseOrdersToInventorySuccess implements StopSaving, PersistData {
  AddPurchaseOrdersToInventorySuccess(this.purchaseOrders);

  final List<InvoiceEntity> purchaseOrders;
}

class AddPurchaseOrdersToInventoryFailure implements StopSaving {
  AddPurchaseOrdersToInventoryFailure(this.error);

  final Object error;
}

class ApprovePurchaseOrders implements StartSaving {
  ApprovePurchaseOrders(this.completer, this.purchaseOrderIds);

  final List<String> purchaseOrderIds;
  final Completer completer;
}

class ApprovePurchaseOrderSuccess implements StopSaving {
  ApprovePurchaseOrderSuccess({this.purchaseOrders});

  final List<InvoiceEntity> purchaseOrders;
}

class ApprovePurchaseOrderFailure implements StopSaving {
  ApprovePurchaseOrderFailure(this.error);

  final dynamic error;
}

class AddPurchaseOrderContact implements PersistUI {
  AddPurchaseOrderContact({this.contact, this.invitation});

  final VendorContactEntity contact;
  final InvitationEntity invitation;
}

class RemovePurchaseOrderContact implements PersistUI {
  RemovePurchaseOrderContact({this.invitation});

  final InvitationEntity invitation;
}

class AddPurchaseOrderItem implements PersistUI {
  AddPurchaseOrderItem({this.purchaseOrderItem});

  final InvoiceItemEntity purchaseOrderItem;
}

class MovePurchaseOrderItem implements PersistUI {
  MovePurchaseOrderItem({
    this.oldIndex,
    this.newIndex,
  });

  final int oldIndex;
  final int newIndex;
}

class AddPurchaseOrderItems implements PersistUI {
  AddPurchaseOrderItems(this.lineItems);

  final List<InvoiceItemEntity> lineItems;
}

class UpdatePurchaseOrderItem implements PersistUI {
  UpdatePurchaseOrderItem({this.index, this.purchaseOrderItem});

  final int index;
  final InvoiceItemEntity purchaseOrderItem;
}

class DeletePurchaseOrderItem implements PersistUI {
  DeletePurchaseOrderItem(this.index);

  final int index;
}

class FilterPurchaseOrders implements PersistUI {
  FilterPurchaseOrders(this.filter);

  final String filter;
}

class SortPurchaseOrders implements PersistUI, PersistPrefs {
  SortPurchaseOrders(this.field);

  final String field;
}

class FilterPurchaseOrdersByState implements PersistUI {
  FilterPurchaseOrdersByState(this.state);

  final EntityState state;
}

class FilterPurchaseOrdersByStatus implements PersistUI {
  FilterPurchaseOrdersByStatus(this.status);

  final EntityStatus status;
}

class FilterPurchaseOrderDropdown {
  FilterPurchaseOrderDropdown(this.filter);

  final String filter;
}

class FilterPurchaseOrdersByCustom1 implements PersistUI {
  FilterPurchaseOrdersByCustom1(this.value);

  final String value;
}

class FilterPurchaseOrdersByCustom2 implements PersistUI {
  FilterPurchaseOrdersByCustom2(this.value);

  final String value;
}

class FilterPurchaseOrdersByCustom3 implements PersistUI {
  FilterPurchaseOrdersByCustom3(this.value);

  final String value;
}

class FilterPurchaseOrdersByCustom4 implements PersistUI {
  FilterPurchaseOrdersByCustom4(this.value);

  final String value;
}

class StartPurchaseOrderMultiselect {
  StartPurchaseOrderMultiselect();
}

class AddToPurchaseOrderMultiselect {
  AddToPurchaseOrderMultiselect({@required this.entity});

  final BaseEntity entity;
}

class RemoveFromPurchaseOrderMultiselect {
  RemoveFromPurchaseOrderMultiselect({@required this.entity});

  final BaseEntity entity;
}

class ClearPurchaseOrderMultiselect {
  ClearPurchaseOrderMultiselect();
}

class UpdatePurchaseOrderTab implements PersistUI {
  UpdatePurchaseOrderTab({this.tabIndex});

  final int tabIndex;
}

void handlePurchaseOrderAction(BuildContext context,
    List<BaseEntity> purchaseOrders, EntityAction action) {
  if (purchaseOrders.isEmpty) {
    return;
  }

  final store = StoreProvider.of<AppState>(context);
  final state = store.state;
  final localization = AppLocalization.of(context);
  final purchaseOrder = purchaseOrders.first as InvoiceEntity;
  final purchaseOrderIds =
      purchaseOrders.map((purchaseOrder) => purchaseOrder.id).toList();

  switch (action) {
    case EntityAction.edit:
      editEntity(entity: purchaseOrder);
      break;
    case EntityAction.viewPdf:
      store.dispatch(
          ShowPdfPurchaseOrder(purchaseOrder: purchaseOrder, context: context));
      break;
    case EntityAction.restore:
      store.dispatch(RestorePurchaseOrdersRequest(
          snackBarCompleter<Null>(context, localization.restoredPurchaseOrder),
          purchaseOrderIds));
      break;
    case EntityAction.archive:
      store.dispatch(ArchivePurchaseOrdersRequest(
          snackBarCompleter<Null>(context, localization.archivedPurchaseOrder),
          purchaseOrderIds));
      break;
    case EntityAction.delete:
      store.dispatch(DeletePurchaseOrdersRequest(
          snackBarCompleter<Null>(context, localization.deletedPurchaseOrder),
          purchaseOrderIds));
      break;
    case EntityAction.addToInventory:
      store.dispatch(AddPurchaseOrdersToInventoryRequest(
          snackBarCompleter<Null>(
              context,
              purchaseOrders.length == 1
                  ? localization.addedPurchaseOrderToInventory
                  : localization.addedPurchaseOrdersToInventory),
          purchaseOrderIds));
      break;
    case EntityAction.convertToExpense:
      store.dispatch(ConvertPurchaseOrdersToExpensesRequest(
          snackBarCompleter<Null>(
              context,
              purchaseOrders.length == 1
                  ? localization.convertedToExpense
                  : localization.convertedToExpenses),
          purchaseOrderIds));
      break;
    case EntityAction.viewExpense:
      viewEntityById(
          entityId: purchaseOrder.expenseId, entityType: EntityType.expense);
      break;
    case EntityAction.markSent:
      store.dispatch(MarkPurchaseOrdersSentRequest(
          snackBarCompleter<Null>(
              context,
              purchaseOrders.length == 1
                  ? localization.markedPurchaseOrderAsSent
                  : localization.markedPurchaseOrdersAsSent),
          purchaseOrderIds));
      break;
    case EntityAction.cancelInvoice:
      store.dispatch(CancelPurchaseOrdersRequest(
          snackBarCompleter<Null>(
              context,
              purchaseOrders.length == 1
                  ? localization.cancelledPurchaseOrder
                  : localization.cancelledPurchaseOrders),
          purchaseOrderIds));
      break;
    case EntityAction.accept:
      store.dispatch(AcceptPurchaseOrdersRequest(
          snackBarCompleter<Null>(
              context,
              purchaseOrders.length == 1
                  ? localization.acceptedPurchaseOrder
                  : localization.acceptedPurchaseOrders),
          purchaseOrderIds));
      break;
    case EntityAction.toggleMultiselect:
      if (!store.state.purchaseOrderListState.isInMultiselect()) {
        store.dispatch(StartPurchaseOrderMultiselect());
      }

      if (purchaseOrders.isEmpty) {
        break;
      }

      for (final purchaseOrder in purchaseOrders) {
        if (!store.state.purchaseOrderListState.isSelected(purchaseOrder.id)) {
          store.dispatch(AddToPurchaseOrderMultiselect(entity: purchaseOrder));
        } else {
          store.dispatch(
              RemoveFromPurchaseOrderMultiselect(entity: purchaseOrder));
        }
      }
      break;
    case EntityAction.clientPortal:
      launch(purchaseOrder.invitationSilentLink);
      break;
    case EntityAction.sendEmail:
    case EntityAction.bulkSendEmail:
      bool emailValid = true;
      purchaseOrders.forEach((purchaseOrder) {
        final vendor = state.vendorState.get(
          (purchaseOrder as InvoiceEntity).vendorId,
        );
        if (!vendor.hasEmailAddress) {
          emailValid = false;
        }
      });
      if (!emailValid) {
        showMessageDialog(
            context: context,
            message: localization.vendorEmailNotSet,
            secondaryActions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    editEntity(
                        entity: state.vendorState.get(purchaseOrder.vendorId));
                  },
                  child: Text(localization.editVendor.toUpperCase()))
            ]);
        return;
      }
      if (action == EntityAction.sendEmail) {
        store.dispatch(ShowEmailPurchaseOrder(
            completer: snackBarCompleter<Null>(
                context, localization.emailedPurchaseOrder),
            purchaseOrder: purchaseOrder,
            context: context));
      } else {
        confirmCallback(
            context: context,
            message: localization.bulkEmailQuote,
            callback: (_) {
              store.dispatch(BulkEmailPurchaseOrdersRequest(
                  snackBarCompleter<Null>(
                      context,
                      purchaseOrderIds.length == 1
                          ? localization.emailedPurchaseOrder
                          : localization.emailedPurchaseOrders),
                  purchaseOrderIds));
            });
      }
      break;
    case EntityAction.cloneToQuote:
      final designId = getDesignIdForClientByEntity(
          state: state,
          clientId: purchaseOrder.clientId,
          entityType: EntityType.purchaseOrder);
      createEntity(
          context: context,
          entity: purchaseOrder.clone
              .rebuild((b) => b
                ..entityType = EntityType.quote
                ..designId = designId)
              .recreateInvitations(state));
      break;
    case EntityAction.cloneToOther:
      cloneToDialog(context: context, invoice: purchaseOrder);
      break;
    case EntityAction.cloneToInvoice:
      final designId = getDesignIdForClientByEntity(
          state: state,
          clientId: purchaseOrder.clientId,
          entityType: EntityType.invoice);
      createEntity(
          context: context,
          entity: purchaseOrder.clone
              .rebuild((b) => b
                ..entityType = EntityType.invoice
                ..designId = designId)
              .recreateInvitations(state));
      break;
    case EntityAction.clone:
    case EntityAction.cloneToPurchaseOrder:
      createEntity(context: context, entity: purchaseOrder.clone);
      break;
    case EntityAction.cloneToCredit:
      final designId = getDesignIdForClientByEntity(
          state: state,
          clientId: purchaseOrder.clientId,
          entityType: EntityType.credit);
      createEntity(
          context: context,
          entity: purchaseOrder.clone
              .rebuild((b) => b
                ..entityType = EntityType.credit
                ..designId = designId)
              .recreateInvitations(state));
      break;
    case EntityAction.cloneToRecurring:
      final designId = getDesignIdForClientByEntity(
          state: state,
          clientId: purchaseOrder.clientId,
          entityType: EntityType.invoice);
      createEntity(
          context: context,
          entity: purchaseOrder.clone
              .rebuild((b) => b
                ..entityType = EntityType.recurringInvoice
                ..designId = designId)
              .recreateInvitations(state));
      break;
    case EntityAction.download:
      launch(purchaseOrder.invitationDownloadLink);
      break;
    case EntityAction.bulkDownload:
      store.dispatch(DownloadPurchaseOrdersRequest(
          snackBarCompleter<Null>(context, localization.exportedData),
          purchaseOrderIds));
      break;
    case EntityAction.more:
      showEntityActionsDialog(
        entities: [purchaseOrder],
      );
      break;
    default:
      print('## ERROR: unhandled action $action in purchase_order_actions');
      break;
  }
}
