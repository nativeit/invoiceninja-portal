import 'dart:convert';
import 'dart:core';
import 'package:built_collection/built_collection.dart';
import 'package:http/http.dart';
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/data/models/serializers.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/data/web_client.dart';

class PurchaseOrderRepository {
  const PurchaseOrderRepository({
    this.webClient = const WebClient(),
  });

  final WebClient webClient;

  Future<InvoiceEntity> loadItem(
      Credentials credentials, String entityId) async {
    final dynamic response = await webClient.get(
        '${credentials.url}/purchase_orders/$entityId', credentials.token);

    final InvoiceItemResponse purchaseOrderResponse =
        serializers.deserializeWith(InvoiceItemResponse.serializer, response);

    return purchaseOrderResponse.data;
  }

  Future<BuiltList<InvoiceEntity>> loadList(
    Credentials credentials,
    int page,
    int createdAt,
    //bool filterDeleted,
    int recordsPerPage,
  ) async {
    final url = credentials.url +
        '/purchase_orders?per_page=$recordsPerPage&page=$page&created_at=$createdAt';

    /*
    if (filterDeleted) {
      url += '&filter_deleted_clients=true';
    }
    */

    final dynamic response = await webClient.get(url, credentials.token);

    final InvoiceListResponse purchaseOrderResponse =
        serializers.deserializeWith(InvoiceListResponse.serializer, response);

    return purchaseOrderResponse.data;
  }

  Future<List<InvoiceEntity>> bulkAction(
      Credentials credentials, List<String> ids, EntityAction action) async {
    if (ids.length > kMaxEntitiesPerBulkAction) {
      ids = ids.sublist(0, kMaxEntitiesPerBulkAction);
    }

    final url = credentials.url + '/purchase_orders/bulk';
    final dynamic response = await webClient.post(url, credentials.token,
        data: json.encode({'ids': ids, 'action': action.toApiParam()}));

    print(
        '## DATA: ${json.encode({'ids': ids, 'action': action.toApiParam()})}');

    final InvoiceListResponse purchaseOrderResponse =
        serializers.deserializeWith(InvoiceListResponse.serializer, response);

    return purchaseOrderResponse.data.toList();
  }

  Future<InvoiceEntity> saveData(
    Credentials credentials,
    InvoiceEntity purchaseOrder,
    EntityAction action,
  ) async {
    purchaseOrder = purchaseOrder.rebuild((b) => b..documents.clear());
    final data =
        serializers.serializeWith(InvoiceEntity.serializer, purchaseOrder);
    String url;
    dynamic response;

    if (purchaseOrder.isNew) {
      url = credentials.url + '/purchase_orders?include=activities';
    } else {
      url =
          '${credentials.url}/purchase_orders/${purchaseOrder.id}?include=activities';
    }

    if (action == EntityAction.markSent) {
      url += '&mark_sent=true';
    } else if (action == EntityAction.accept) {
      url += '&accept=true';
    }

    if (purchaseOrder.isNew) {
      response =
          await webClient.post(url, credentials.token, data: json.encode(data));
    } else {
      response =
          await webClient.put(url, credentials.token, data: json.encode(data));
    }

    final InvoiceItemResponse purchaseOrderResponse =
        serializers.deserializeWith(InvoiceItemResponse.serializer, response);

    return purchaseOrderResponse.data;
  }

  Future<InvoiceEntity> emailPurchaseOrder(
      Credentials credentials,
      InvoiceEntity purchaseOrder,
      EmailTemplate template,
      String subject,
      String body) async {
    final data = {
      'entity': '${purchaseOrder.entityType}',
      'entity_id': purchaseOrder.id,
      'template': 'email_template_$template',
      'body': body,
      'subject': subject,
    };

    final dynamic response = await webClient.post(
        credentials.url + '/emails', credentials.token,
        data: json.encode(data));

    final InvoiceItemResponse invoiceResponse =
        serializers.deserializeWith(InvoiceItemResponse.serializer, response);

    return invoiceResponse.data;
  }

  Future<InvoiceEntity> uploadDocument(Credentials credentials,
      BaseEntity entity, MultipartFile multipartFile) async {
    final fields = <String, String>{
      '_method': 'put',
    };

    final dynamic response = await webClient.post(
        '${credentials.url}/purchase_orders/${entity.id}/upload',
        credentials.token,
        data: fields,
        multipartFiles: [multipartFile]);

    final InvoiceItemResponse invoiceResponse =
        serializers.deserializeWith(InvoiceItemResponse.serializer, response);

    return invoiceResponse.data;
  }
}
