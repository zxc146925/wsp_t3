import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wsp_t3/utils/api/config.dart';
import 'package:wsp_t3/utils/public/color_theme.dart';
import '../../../utils/bloc/construction_incident_list_bloc/construction_incident_list_bloc.dart';
import '../../../utils/entity/location.dart';
import '../../../utils/public/public_data.dart';
import '../../../utils/view_model/location_incident_list.dart';

class ConstructionIncidentList extends StatefulWidget {
  LocationEntity locationEntity;
  ConstructionIncidentList({super.key, required this.locationEntity});

  @override
  State<ConstructionIncidentList> createState() => _ConstructionIncidentListState();
}

class _ConstructionIncidentListState extends State<ConstructionIncidentList> {
  ConstructionIncidentListBloc constructionIncidentListBloc = ConstructionIncidentListBloc();

  @override
  void initState() {
    print('案場LocationEntity id:${widget.locationEntity.id}');
    constructionIncidentListBloc.add(ConstructionIncidentListInitEvent(skip: 0, size: 20, locationId: widget.locationEntity.id!));
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => constructionIncidentListBloc,
      child: BlocConsumer<ConstructionIncidentListBloc, ConstructionIncidentListState>(
        bloc: constructionIncidentListBloc,
        listener: (context, state) {},
        builder: (context, state) {
          if (state.locationIncidentMap.isEmpty) {
            return const Center(
              child: Text(
                '暫無異常資訊',
                style: TextStyle(color: MyColorTheme.black),
              ),
            );
          }
          return ListView.builder(
            itemCount: state.locationIncidentMap.length ?? 0,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              switch (state.runtimeType) {
                case ConstructionIncidentListInitialState:
                case ConstructionIncidentListLoadingState:
                  {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                case ConstructionIncidentListReadMaxState:
                case ConstructionIncidentListLoadMoreState:
                case ConstructionIncidentListShowState:
                  {
                    if (index > state.locationIncidentMap.length - 5 && state.runtimeType != ConstructionIncidentListLoadMoreState) {
                      constructionIncidentListBloc.add(ConstructionIncidentListLoadMoreEvent(skip: state.locationIncidentMap.length, size: 20, locationId: widget.locationEntity.id!));
                    }

                    LocationIncidentListViewModel locationIncidentListViewModel = state.locationIncidentMap.values.toList()[index];
                    return Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              // 左側紅色區塊
                              Flexible(
                                flex: 2,
                                child: Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1, color: MyColorTheme.black),
                                  ),
                                  // color: Colors.red,
                                  child: CachedNetworkImage(
                                    imageUrl: "${Config.mediaSocketUrl}/file/${locationIncidentListViewModel.imageUrl}",
                                    fit: BoxFit.cover,
                                    progressIndicatorBuilder: (context, url, downloadProgress) => Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      width: 400,
                                      child: Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      width: 400,
                                      child: const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10), // 添加間距
                              // 右側資訊區塊
                              Flexible(
                                flex: 3,
                                child: Container(
                                  height: 200,
                                  padding: const EdgeInsets.only(left: 20, bottom: 20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat('yyyy / MM / dd  HH:mm:ss').format(
                                          DateTime.fromMillisecondsSinceEpoch(locationIncidentListViewModel.createDatetime),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.grey.shade300,
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(PublicData.stateListName[locationIncidentListViewModel.state]),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(locationIncidentListViewModel.title),
                                          Text(PublicData.getArticles(locationIncidentListViewModel.type)),
                                          // const Text('一般作業人員安全裝束辨識：一般作業人員是否穿戴安全帽'),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 1,
                        ),
                      ],
                    );
                  }
                default:
                  {
                    return Container();
                  }
              }
            },
          );
        },
      ),
    );
  }
}
