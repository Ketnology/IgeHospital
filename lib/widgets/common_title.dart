import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/static_data.dart';
import 'package:ige_hospital/static_data/static_data.dart';
import 'package:provider/provider.dart';

class CommonTitle extends StatefulWidget {
  final String title;
  final String path;
  const CommonTitle({super.key, required this.title, required this.path});

  @override
  State<CommonTitle> createState() => _CommonTitleState();
}

class _CommonTitleState extends State<CommonTitle> {
  final AppConst controller = Get.put(AppConst());

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Consumer<ColourNotifier>(
        builder: (context, value, child) =>
            GetBuilder<AppConst>(builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: constraints.maxWidth < 600
                      ? mainTextStyle.copyWith(
                          fontSize: 18, color: notifier!.getMainText)
                      : mainTextStyle.copyWith(color: notifier!.getMainText),
                  overflow: TextOverflow.ellipsis,
                ),
                Flexible(
                  child: Wrap(
                    runSpacing: 5,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          controller.changePage('');
                        },
                        child: SvgPicture.asset("assets/home.svg",
                            height: constraints.maxWidth < 600 ? 14 : 16,
                            width: constraints.maxWidth < 600 ? 14 : 16,
                            color: notifier!.getMainText),
                      ),
                      Text('   /   ${widget.path}   /   ',
                          style: mediumBlackTextStyle.copyWith(
                              color: notifier!.getMainText,
                              fontSize: constraints.maxWidth < 600 ? 12 : 14),
                          overflow: TextOverflow.ellipsis),
                      Text(widget.title,
                          style: mediumGreyTextStyle.copyWith(
                              color: appMainColor,
                              fontSize: constraints.maxWidth < 600 ? 12 : 14),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
      );
    });
  }
}
