import 'package:flutter/material.dart';

import '../../../utils/view_model/incident_list.dart';
import 'anomaly_detail.dart';

Drawer anomalyDrawer(String title, BuildContext context,IncidentListViewModel? entity) {
  return Drawer(
    backgroundColor: Colors.transparent,
    width: 670,
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(5),
      ),
    ),
    child: Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color.fromRGBO(208, 208, 208, 1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('異常資訊'),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close)),
            ],
          ),
          const Divider(),
           AnomalyDetail(entity),
        ],
      ),
    ),
  );
}
