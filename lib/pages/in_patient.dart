import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/constants/static_data.dart';
import 'package:ige_hospital/widgets/bottom_bar.dart';
import 'package:ige_hospital/widgets/common_title.dart';
import 'package:ige_hospital/widgets/size_box.dart';
import 'package:provider/provider.dart';

class InPatientPage extends StatefulWidget {
  const InPatientPage({super.key});

  @override
  State<InPatientPage> createState() => _DefaultPage();
}

class _DefaultPage extends State<InPatientPage> {
  @override
  void dispose() {
    super.dispose();
  }

  final List<Map<String, String>> recentAppointments = [
    {
      "doctor": "Dr. James Smith",
      "patient": "Emily Johnson",
      "date": "29/1/2023",
      "time": "10:30 AM",
      "doctorImage": "assets/icons8-figma.svg",
    },
    {
      "doctor": "Dr. Sarah Williams",
      "patient": "Michael Brown",
      "date": "19/6/2023",
      "time": "2:15 PM",
      "doctorImage": "assets/icons8-adobe-creative-cloud.svg",
    },
    {
      "doctor": "Dr. David Martinez",
      "patient": "Sophia Davis",
      "date": "1/2/2023",
      "time": "9:00 AM",
      "doctorImage": "assets/icons8-starbucks.svg",
    },
    {
      "doctor": "Dr. Olivia Taylor",
      "patient": "James Wilson",
      "date": "9/4/2023",
      "time": "11:45 AM",
      "doctorImage": "assets/icons8-apple-logo.svg",
    },
    {
      "doctor": "Dr. William Anderson",
      "patient": "Isabella Thomas",
      "date": "12/6/2023",
      "time": "4:30 PM",
      "doctorImage": "assets/icons8-facebook29.svg",
    },
  ];

  ColourNotifier notifier = ColourNotifier();

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColourNotifier>(context, listen: true);
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: notifier.getBgColor,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    const CommonTitle(title: 'Overview', path: "Dashboards"),
                    _buildComp3(width: constraints.maxWidth),
                    _buildComp4(),
                    const MySizeBox(),
                    const BottomBar(),
                  ],
                ),
              );
            } else if (constraints.maxWidth < 1000) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                    children: [
                      const CommonTitle(title: 'Overview', path: "Dashboards"),
                      _buildComp3(width: constraints.maxWidth),
                      _buildComp4(),
                      const MySizeBox(),
                      const BottomBar(),
                    ],
                ),
              );
            } else {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    const CommonTitle(title: 'Overview', path: "Dashboards"),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildComp3(width: constraints.maxWidth),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildComp4(),
                        ),
                      ],
                    ),
                    const MySizeBox(),
                    const BottomBar(),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildComp1(
      {required String title,
        required String iconPath,
        required String price,
        required Color mainColour}) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        height: 100,
        // width: 200,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          color: notifier.getContainer,
          boxShadow: boxShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              dense: true,
              leading: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mainColour.withOpacity(0.2),
                ),
                child: Center(
                    child: SvgPicture.asset(
                      iconPath,
                      height: 25,
                      width: 25,
                    )),
              ),
              title: Text(
                title,
                style: mediumGreyTextStyle,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      price,
                      style:
                      mainTextStyle.copyWith(color: notifier.getMainText),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComp3({required double width}) {
    return Padding(
      padding: const EdgeInsets.all(padding),
      child: Container(
        // height: 400,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          color: Colors.blueAccent.withOpacity(0.2),
          boxShadow: boxShadow,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 450,
                child: Padding(
                  padding: const EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 30,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xffffc107),
                        ),
                        child: Center(
                            child:
                            Text("Chart box", style: mediumBlackTextStyle)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComp4() {
    return Padding(
      padding: const EdgeInsets.all(padding),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          color: notifier.getContainer,
          boxShadow: boxShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "Recent Appointments",
                    style: mediumBlackTextStyle.copyWith(
                        color: notifier.getMainText),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    "assets/info-circle.svg",
                    height: 22,
                    width: 22,
                    color: notifier.getMainText,
                  ),
                  const Spacer(),
                  Text(
                    "See more",
                    style: mediumGreyTextStyle,
                  ),
                  SvgPicture.asset(
                    "assets/angle-right-small.svg",
                    height: 22,
                    width: 22,
                    color: notifier.getMainText,
                  )
                ],
              ),
              const SizedBox(height: 16),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: recentAppointments.length,
                itemBuilder: (context, index) {
                  final appointment = recentAppointments[index];
                  return Column(
                    children: [
                      const SizedBox(height: 10),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: SvgPicture.asset(appointment["doctorImage"]!),
                        ),
                        title: Text(
                          appointment["doctor"]!,
                          style: mediumBlackTextStyle.copyWith(
                              color: notifier.getMainText),
                        ),
                        trailing: Column(
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              appointment["time"]!,
                              style: mediumBlackTextStyle.copyWith(
                                  color: notifier.getMainText),
                            ),
                            const SizedBox(height: 5),
                            Text(appointment["date"]!, style: mediumGreyTextStyle),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "Patient: ${appointment["patient"]!}",
                            style: mediumGreyTextStyle,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
