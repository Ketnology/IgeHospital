import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:ige_hospital/static_data/static_data.dart';
import 'package:ige_hospital/widgets/bottom_bar.dart';
import 'package:ige_hospital/widgets/common_title.dart';
import 'package:ige_hospital/widgets/size_box.dart';
import 'package:ige_hospital/widgets/text_field.dart';
import 'package:provider/provider.dart';

class InPatientPage extends StatefulWidget {
  const InPatientPage({super.key});

  @override
  State<InPatientPage> createState() => _InPatientPage();
}

class _InPatientPage extends State<InPatientPage> {
  TextEditingController cardNumber = TextEditingController();
  TextEditingController cardHolder = TextEditingController();
  TextEditingController cardCvc = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    cardNumber.dispose();
    cardHolder.dispose();
    cardCvc.dispose();
  }

  List countries = [
    "assets/india.png",
    "assets/argentina.png",
    "assets/brazil-.png",
    "assets/germany.png",
    "assets/united-kingdom.png",
    "assets/circle.png",
  ];

  List logo = [
    "assets/icons8-figma.svg",
    "assets/icons8-adobe-creative-cloud.svg",
    "assets/icons8-starbucks.svg",
    "assets/icons8-apple-logo.svg",
    "assets/icons8-facebook29.svg",
  ];
  List name = [
    "Figma",
    "Adobe-creative",
    "Starbucks",
    "Apple",
    "Facebook",
  ];
  List price = [
    "\$1001",
    "\$143",
    "\$213",
    "\$343",
    "\$123",
  ];
  List date = [
    "29/1/2023",
    "19/6/2023",
    "1/2/2023",
    "9/4/2023",
    "12/6/2023",
  ];
  List countriesName = [
    "India",
    "Argentina",
    "Brazil",
    "Germany",
    "United-kingdom",
    "United States",
  ];
  List subtitle = [
    "Subscription",
    "Subscription",
    "Receive",
    "Transfer",
    "Receive",
  ];
  List countriesPr = [
    "50%",
    "20%",
    "10%",
    "9%",
    "3%",
    "2%",
  ];

  List card2name = [
    "Total Earnings",
    "Total Sale",
    "Total Profit",
    "Total Order",
  ];
  List card2price = [
    "\$1,222",
    "\$4,451",
    "\$7,136",
    "\$9,233",
  ];
  List<ChartData> chartData = [
    ChartData(1, 35, 0),
    ChartData(2, 23, 0),
    ChartData(3, 34, 0),
    ChartData(4, 25, 0),
    ChartData(5, 40, 0),
    ChartData(6, 20, 0),
    ChartData(7, 70, 0),
    ChartData(8, 10, 0),
  ];
  List card2pr = [
    "12%",
    "20.2%",
    "15.6%",
    "39.3%",
  ];
  List card2value = [
    0.3,
    0.6,
    0.9,
    0.2,
  ];
  List card2price1 = [
    "\$9,233",
    "\$7,136",
    "\$1,222",
    "\$4,451",
  ];
  List cardColors = [
    const Color(0xff1a7cbc),
    const Color(0xfff07521),
    const Color(0xff4caf50),
    const Color(0xff18a0fb),
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
                    const CommonTitle(title: 'Default', path: "Dashboards"),
                    _buildComp1(
                        title: "Total Earnings",
                        iconPath: "assets/dollar-circle33.svg",
                        price: "\$ 29,955",
                        pr: "9.55%",
                        mainColour: Colors.blueAccent,
                        secondIcon: "assets/arrow-up-small.svg"),
                    _buildComp1(
                        title: "Customer",
                        iconPath: "assets/users33.svg",
                        price: "\$ 19,235",
                        pr: "2.29%",
                        mainColour: Colors.pinkAccent,
                        secondIcon: "assets/arrow-up-small.svg"),
                    _buildComp1(
                        title: "Orders",
                        iconPath: "assets/box-check33.svg",
                        price: "\$ 9,955",
                        pr: "3.23%",
                        mainColour: Colors.deepOrangeAccent,
                        secondIcon: "assets/arrow-down-small.svg"),
                    _buildComp1(
                        title: "Available Balance",
                        iconPath: "assets/wallet33.svg",
                        price: "\$ 95,295",
                        pr: "5.33%",
                        mainColour: Colors.deepPurpleAccent,
                        secondIcon: "assets/arrow-up-small.svg"),
                    _buildComp1(
                        title: "New Sales",
                        iconPath: "assets/coins29.svg",
                        price: "\$ 1,365",
                        pr: "3.53%",
                        mainColour: const Color(0xff0CAF60),
                        secondIcon: "assets/arrow-down-small.svg"),
                    _buildComp1(
                        title: "Income per lead",
                        iconPath: "assets/user29.svg",
                        price: "\$ 235",
                        pr: "1.77%",
                        mainColour: const Color(0xff0059E7),
                        secondIcon: "assets/arrow-up-small.svg"),
                    _buildComp1(
                        title: "New leads",
                        iconPath: "assets/receipt-list29.svg",
                        price: "\$ 955",
                        pr: "7.43%",
                        mainColour: const Color(0xffF7931A),
                        secondIcon: "assets/arrow-down-small.svg"),
                    _buildComp1(
                        title: "Conversion rate",
                        iconPath: "assets/ranking29.svg",
                        price: "\$ 5,295",
                        pr: "10.23%",
                        mainColour: const Color(0xff267DFF),
                        secondIcon: "assets/arrow-up-small.svg"),
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
                    const CommonTitle(title: 'Default', path: "Dashboards"),
                    Row(
                      children: [
                        Expanded(
                          child: _buildComp1(
                              title: "Total Earnings",
                              iconPath: "assets/dollar-circle33.svg",
                              price: "\$ 29,955",
                              pr: "9.55%",
                              mainColour: Colors.blueAccent,
                              secondIcon: "assets/arrow-up-small.svg"),
                        ),
                        Expanded(
                          child: _buildComp1(
                              title: "Customer",
                              iconPath: "assets/users33.svg",
                              price: "\$ 19,235",
                              pr: "2.29%",
                              mainColour: Colors.pinkAccent,
                              secondIcon: "assets/arrow-up-small.svg"),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildComp1(
                              title: "Orders",
                              iconPath: "assets/box-check33.svg",
                              price: "\$ 9,955",
                              pr: "3.23%",
                              mainColour: Colors.deepOrangeAccent,
                              secondIcon: "assets/arrow-down-small.svg"),
                        ),
                        Expanded(
                          child: _buildComp1(
                              title: "Available Balance",
                              iconPath: "assets/wallet33.svg",
                              price: "\$ 95,295",
                              pr: "5.33%",
                              mainColour: Colors.deepPurpleAccent,
                              secondIcon: "assets/arrow-up-small.svg"),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildComp1(
                              title: "New Sales",
                              iconPath: "assets/coins29.svg",
                              price: "\$ 1,365",
                              pr: "3.53%",
                              mainColour: const Color(0xff0CAF60),
                              secondIcon: "assets/arrow-down-small.svg"),
                        ),
                        Expanded(
                          child: _buildComp1(
                              title: "Income per lead",
                              iconPath: "assets/user29.svg",
                              price: "\$ 235",
                              pr: "1.77%",
                              mainColour: const Color(0xff0059E7),
                              secondIcon: "assets/arrow-up-small.svg"),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildComp1(
                              title: "New leads",
                              iconPath: "assets/receipt-list29.svg",
                              price: "\$ 955",
                              pr: "7.43%",
                              mainColour: const Color(0xffF7931A),
                              secondIcon: "assets/arrow-down-small.svg"),
                        ),
                        Expanded(
                          child: _buildComp1(
                              title: "Conversion rate",
                              iconPath: "assets/ranking29.svg",
                              price: "\$ 5,295",
                              pr: "10.23%",
                              mainColour: const Color(0xff267DFF),
                              secondIcon: "assets/arrow-up-small.svg"),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildComp4()),
                      ],
                    ),
                    _buildComp3(width: constraints.maxWidth),
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
                    const CommonTitle(title: 'Default', path: "Dashboards"),
                    Row(
                      children: [
                        Expanded(
                          child: _buildComp1(
                              title: "Total Earnings",
                              iconPath: "assets/dollar-circle33.svg",
                              price: "\$ 29,955",
                              pr: "9.55%",
                              mainColour: Colors.blueAccent,
                              secondIcon: "assets/arrow-up-small.svg"),
                        ),
                        Expanded(
                          child: _buildComp1(
                              title: "Customer",
                              iconPath: "assets/users33.svg",
                              price: "\$ 19,235",
                              pr: "2.29%",
                              mainColour: Colors.pinkAccent,
                              secondIcon: "assets/arrow-up-small.svg"),
                        ),
                        Expanded(
                          child: _buildComp1(
                              title: "Orders",
                              iconPath: "assets/box-check33.svg",
                              price: "\$ 9,955",
                              pr: "3.23%",
                              mainColour: Colors.deepOrangeAccent,
                              secondIcon: "assets/arrow-down-small.svg"),
                        ),
                        Expanded(
                          child: _buildComp1(
                              title: "Available Balance",
                              iconPath: "assets/wallet33.svg",
                              price: "\$ 95,295",
                              pr: "5.33%",
                              mainColour: Colors.deepPurpleAccent,
                              secondIcon: "assets/arrow-up-small.svg"),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildComp1(
                              title: "New Sales",
                              iconPath: "assets/coins29.svg",
                              price: "\$ 1,365",
                              pr: "3.53%",
                              mainColour: const Color(0xff0CAF60),
                              secondIcon: "assets/arrow-down-small.svg"),
                        ),
                        Expanded(
                          child: _buildComp1(
                              title: "Income per lead",
                              iconPath: "assets/user29.svg",
                              price: "\$ 235",
                              pr: "1.77%",
                              mainColour: const Color(0xff0059E7),
                              secondIcon: "assets/arrow-up-small.svg"),
                        ),
                        Expanded(
                          child: _buildComp1(
                              title: "New leads",
                              iconPath: "assets/receipt-list29.svg",
                              price: "\$ 955",
                              pr: "7.43%",
                              mainColour: const Color(0xffF7931A),
                              secondIcon: "assets/arrow-down-small.svg"),
                        ),
                        Expanded(
                          child: _buildComp1(
                              title: "Conversion rate",
                              iconPath: "assets/ranking29.svg",
                              price: "\$ 5,295",
                              pr: "10.23%",
                              mainColour: const Color(0xff267DFF),
                              secondIcon: "assets/arrow-up-small.svg"),
                        ),
                      ],
                    ),
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
        required String pr,
        required Color mainColour,
        required String secondIcon}) {
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
                    Flexible(
                        child: Text(pr,
                            style: mediumGreyTextStyle,
                            overflow: TextOverflow.ellipsis)),
                    const SizedBox(
                      width: 5,
                    ),
                    SvgPicture.asset(secondIcon,
                        height: 16, width: 16, color: notifier.getMainText),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComp2() {
    return Padding(
      padding: const EdgeInsets.all(padding),
      child: Container(
        // height: 500,
        padding: const EdgeInsets.all(padding),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          color: notifier.getContainer,
          boxShadow: boxShadow,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "Top Countries",
                  style: mainTextStyle.copyWith(
                      color: notifier.getMainText, fontSize: 18),
                ),
                const Spacer(),
                SvgPicture.asset("assets/more-vertical.svg",
                    height: 20, width: 20, color: notifier.getMainText),
              ],
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: countries.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      dense: true,
                      leading: CircleAvatar(
                          backgroundImage: AssetImage(countries[index]),
                          backgroundColor: Colors.transparent),
                      trailing: Text(countriesPr[index],
                          style: mediumGreyTextStyle.copyWith(fontSize: 14),
                          overflow: TextOverflow.ellipsis),
                      title: Text(
                        countriesName[index],
                        style: mediumBlackTextStyle.copyWith(
                            color: notifier.getMainText,
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(
              height: 14,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "See all",
                  style: mediumGreyTextStyle,
                ),
                const SizedBox(
                  width: 8,
                ),
                SvgPicture.asset(
                  "assets/angle-right-small.svg",
                  color: notifier.getMainText,
                ),
              ],
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
                      const SizedBox(
                        height: 50,
                      ),
                      Container(
                        height: 30,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xffffc107),
                        ),
                        child: Center(
                            child:
                            Text("On The Go", style: mediumBlackTextStyle)),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Download Your Buzz. App fast",
                        style: mainTextStyle.copyWith(
                            color: notifier.getTextColor1,
                            fontSize: 30,
                            fontWeight: FontWeight.w800),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                      const SizedBox(
                        height: 45,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff1e1e1e),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              fixedSize: const Size(100, 42)),
                          onPressed: () async {},
                          child: Text(
                            "Download",
                            style: mediumBlackTextStyle.copyWith(
                                color: Colors.white),
                          )),
                      const SizedBox(
                        height: 15,
                      ),
                      Text('Available for Android and ios',
                          style: mediumGreyTextStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Image.asset("assets/rocket.png",
                  height: width < 600 ? 280 : 350,
                  width: width < 600 ? 280 : 350,
                  fit: BoxFit.cover),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildComp4() {
    return Padding(
      padding: const EdgeInsets.all(padding),
      child: Container(
        // height: 450,
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
                    "Recent Activity",
                    style: mediumBlackTextStyle.copyWith(
                        color: notifier.getMainText),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
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
              const SizedBox(
                height: 16,
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: name.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: SvgPicture.asset(logo[index]),
                        ),
                        title: Text(name[index],
                            style: mediumBlackTextStyle.copyWith(
                                color: notifier.getMainText)),
                        trailing: Column(children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Text(price[index],
                              style: mediumBlackTextStyle.copyWith(
                                  color: notifier.getMainText)),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(date[index], style: mediumGreyTextStyle),
                        ]),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child:
                          Text(subtitle[index], style: mediumGreyTextStyle),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharts() {
    return Padding(
      padding: const EdgeInsets.all(padding),
      child: Container(
        padding: const EdgeInsets.all(padding),
        height: 480,
        child: Column(
          children: [
            Row(
              children: [
                Text("Selling Growth",
                    style: mainTextStyle.copyWith(
                        fontSize: 17, color: notifier.getMainText)),
                const Spacer(),
                SvgPicture.asset(
                  "assets/more-vertical.svg",
                  height: 20,
                  width: 20,
                  color: notifier.getMainText,
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayment() {
    return Padding(
      padding: const EdgeInsets.all(padding),
      child: Container(
        height: 500,
        padding: const EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Payment Method",
              style: mainTextStyle.copyWith(
                  fontSize: 17, color: notifier.getMainText),
            ),
            const SizedBox(
              height: 12,
            ),
            SizedBox(
              height: 40,
              width: 380,
              child: TabBar(
                  labelStyle: mediumBlackTextStyle.copyWith(
                      color: notifier.getMainText),
                  unselectedLabelColor: notifier.getMainText,
                  labelColor: Colors.white,
                  indicator: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12)),
                  tabs: const [
                    Text(
                      "Credit",
                    ),
                    Text(
                      "Debit Card",
                    ),
                    Text(
                      "Master Crad",
                    ),
                  ]),
            ),
            Expanded(
              child: TabBarView(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: MyTextField(
                              title: "Card Number",
                              hinttext: "Enter Number",
                              controller: cardNumber)),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: MyTextField(
                              title: "Card Holder",
                              hinttext: "Enter Name",
                              controller: cardHolder)),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Expiration Date",
                              style: mediumBlackTextStyle.copyWith(
                                  color: notifier.getMainText),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.withOpacity(0.3)),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: DropdownButtonFormField<String>(
                                style: TextStyle(color: notifier.getMainText),
                                dropdownColor: notifier.getContainer,
                                padding: const EdgeInsets.only(left: 10),
                                value: selectedOption,
                                items: dropdownOptions1.map((String option) {
                                  return DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(option),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedOption = newValue;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintStyle: mediumGreyTextStyle.copyWith(
                                      fontSize: 13),
                                  hintText: 'Select',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 25,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.withOpacity(0.3)),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: DropdownButtonFormField<String>(
                                style: TextStyle(color: notifier.getMainText),
                                dropdownColor: notifier.getContainer,
                                padding: const EdgeInsets.only(left: 10),
                                value: selectedOption1,
                                items: dropdownOptions2.map((String option) {
                                  return DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(option),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedOption1 = newValue;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintStyle: mediumGreyTextStyle.copyWith(
                                      fontSize: 13),
                                  hintText: 'Select',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 1,
                          child: MyTextField(
                              title: "Card Number",
                              hinttext: "Number",
                              controller: cardCvc)),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 25,
                              ),
                              Text(
                                  "Three or Four Digits,usually found on the back of the card",
                                  style: mediumGreyTextStyle,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2),
                            ],
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          fixedSize: const Size.fromHeight(40)),
                      onPressed: () {},
                      child: Text(
                        "Proceed",
                        style:
                        mediumBlackTextStyle.copyWith(color: Colors.white),
                      )),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: MyTextField(
                              title: "Card Number",
                              hinttext: "Enter Number",
                              controller: cardNumber)),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: MyTextField(
                              title: "Card Holder",
                              hinttext: "Enter Name",
                              controller: cardHolder)),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Expiration Date",
                              style: mediumBlackTextStyle.copyWith(
                                  color: notifier.getMainText),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.withOpacity(0.3)),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: DropdownButtonFormField<String>(
                                style: TextStyle(color: notifier.getMainText),
                                dropdownColor: notifier.getContainer,
                                padding: const EdgeInsets.only(left: 10),
                                value: selectedOption,
                                items: dropdownOptions1.map((String option) {
                                  return DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(option),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedOption = newValue;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintStyle: mediumGreyTextStyle.copyWith(
                                      fontSize: 13),
                                  hintText: 'Select an option',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 25,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.withOpacity(0.3)),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: DropdownButtonFormField<String>(
                                style: TextStyle(color: notifier.getMainText),
                                dropdownColor: notifier.getContainer,
                                padding: const EdgeInsets.only(left: 10),
                                value: selectedOption1,
                                items: dropdownOptions2.map((String option) {
                                  return DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(option),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedOption1 = newValue;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintStyle: mediumGreyTextStyle.copyWith(
                                      fontSize: 13),
                                  hintText: 'Select an option',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 1,
                          child: MyTextField(
                              title: "Card Number",
                              hinttext: "Enter Number",
                              controller: cardCvc)),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 25,
                              ),
                              Text(
                                  "Three or Four Digits,usually found on the back of the card",
                                  style: mediumGreyTextStyle),
                            ],
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          fixedSize: const Size.fromHeight(40)),
                      onPressed: () {},
                      child: Text(
                        "Proceed",
                        style:
                        mediumBlackTextStyle.copyWith(color: Colors.white),
                      )),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: MyTextField(
                              title: "Card Number",
                              hinttext: "Enter Number",
                              controller: cardNumber)),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: MyTextField(
                              title: "Card Holder",
                              hinttext: "Enter Name",
                              controller: cardHolder)),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Expiration Date",
                              style: mediumBlackTextStyle.copyWith(
                                  color: notifier.getMainText),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.withOpacity(0.3)),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: DropdownButtonFormField<String>(
                                style: TextStyle(color: notifier.getMainText),
                                dropdownColor: notifier.getContainer,
                                padding: const EdgeInsets.only(left: 10),
                                value: selectedOption,
                                items: dropdownOptions1.map((String option) {
                                  return DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(option),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedOption = newValue;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintStyle: mediumGreyTextStyle.copyWith(
                                      fontSize: 13),
                                  hintText: 'Select an option',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 25,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.withOpacity(0.3)),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: DropdownButtonFormField<String>(
                                style: TextStyle(color: notifier.getMainText),
                                dropdownColor: notifier.getContainer,
                                padding: const EdgeInsets.only(left: 10),
                                value: selectedOption1,
                                items: dropdownOptions2.map((String option) {
                                  return DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(option),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedOption1 = newValue;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintStyle: mediumGreyTextStyle.copyWith(
                                      fontSize: 13),
                                  hintText: 'Select an option',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 1,
                          child: MyTextField(
                              title: "Card Number",
                              hinttext: "Enter Number",
                              controller: cardCvc)),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 25,
                              ),
                              Text(
                                  "Three or Four Digits,usually found on the back of the card",
                                  style: mediumGreyTextStyle),
                            ],
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          fixedSize: const Size.fromHeight(40)),
                      onPressed: () {},
                      child: Text(
                        "Proceed",
                        style:
                        mediumBlackTextStyle.copyWith(color: Colors.white),
                      )),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildcompo6formobile() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration: BoxDecoration(
          color: notifier.getContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [Expanded(child: _buildCharts())],
            ),
            Row(
              children: [Expanded(child: _buildPayment())],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildcompo6() {
    return Padding(
      padding: const EdgeInsets.all(padding),
      child: Container(
        // height: 390,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          color: notifier.getContainer,
          boxShadow: boxShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildCharts(),
                ),
                Expanded(
                  child: _buildPayment(),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<String> dropdownOptions1 = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  List<String> dropdownOptions2 = [
    "2020",
    "2021",
    "2022",
    "2023",
  ];

  String? selectedOption;

  String? selectedOption1;
}

class ChartData {
  ChartData(this.x, this.y, this.y1);
  final int x;
  final double y;
  final double y1;
}
