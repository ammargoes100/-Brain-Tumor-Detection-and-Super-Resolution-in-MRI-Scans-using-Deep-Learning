import 'package:flutter/material.dart';
import 'package:fyp_mobileapp/Views/DetectBrainTumor/TfliteModel.dart';
import 'package:fyp_mobileapp/Views/EnhanceMRIScan/enhancemri.dart';
import 'package:fyp_mobileapp/Views/OnboardingScreen/onboarding_screen.dart';
import 'package:fyp_mobileapp/Views/UserHome/style.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        leading: Icon(
          Icons.menu,
          color: greenColor,
        ),
        title: Text(
          "TumorTool",
          style: titleGreenStyle(),
        ),
        actions: [
          CircleAvatar(
            backgroundColor: blueColor,
            backgroundImage: const AssetImage(
              "Assets/MRIBRAIN.png",
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * .07),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                  padding: EdgeInsets.only(bottom: height * .01),
                  child: Center(
                    child: Image(
                      image: const AssetImage('Assets/ct-scan.png'),
                      width: width * .2,
                    ),
                  )),
              LastReadWidget(height: height, width: width),
              SizedBox(height: 15.0),
              LastReadWidget2(height: height, width: width),
              SizedBox(height: 15.0),
              LastReadWidget3(height: height, width: width),
              SizedBox(height: 15.0),
              Container(
                child: Text(
                  "Our Services",
                  style: GoogleFonts.exo(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Dashboard(height: height)
            ],
          ),
        ),
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({
    Key? key,
    required this.height,
  }) : super(key: key);

  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          child: Column(
            children: [
              CustomContainer(
                  height1: height * .42,
                  image: 'Assets/MRIBRAIN.png',
                  title: "Detect Brain Tumor",
                  color: Colors.black45,
                  onpressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => TfliteModel()));
                  })
            ],
          ),
        ),
        Spacer(),
        SizedBox(
          child: Column(
            children: [
              CustomContainer(
                  height1: height * .4,
                  image: 'Assets/compare.png',
                  title: "Enhance MRI Scan",
                  color: Colors.black45,
                  onpressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => EnhanceMri()));
                  }),
              //CustomContainer(height1: height*.28, width1: width*.4)
            ],
          ),
        )
      ],
    );
  }
}

class CustomContainer extends StatelessWidget {
  const CustomContainer(
      {Key? key,
      required this.height1,
      required this.image,
      required this.title,
      required this.color,
      this.onpressed})
      : super(key: key);

  final double height1;
  final String image;
  final String title;
  final Function()? onpressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(top: width * .06),
      child: InkWell(
        onTap: onpressed,
        child: Container(
          height: height1,
          width: width * .4,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(1.5, 3), // changes position of shadow
                ),
              ],
              image: const DecorationImage(
                  image: AssetImage('Assets/dashboard.png'), fit: BoxFit.fill),
              borderRadius: BorderRadius.circular(25)),
          child: Container(
            decoration: BoxDecoration(
                color: color.withOpacity(0.8),
                borderRadius: BorderRadius.circular(25)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: height * .02,
                horizontal: width * .02,
              ),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image(
                    image: AssetImage(image),
                    width: width * .35,
                    height: height * .24,
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(left: width * .02),
                    child: Text(title, style: titleStyle()),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: width * .02),
                    child: GotoWidget(),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LastReadWidget extends StatelessWidget {
  const LastReadWidget({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () => Fluttertoast.showToast(msg: "This feature will be available in next release"),
      onTap: () {},
      child: Container(
        height: height * .15,
        width: width,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(1.5, 3), // changes position of shadow
              ),
            ],
            image: DecorationImage(
                image: AssetImage('Assets/dashboard.png'), fit: BoxFit.fill),
            borderRadius: BorderRadius.circular(25)),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                primaryColor.withOpacity(0.7),
                secondaryColor.withOpacity(0.7)
              ]),
              borderRadius: BorderRadius.circular(25)),
          child: Row(children: [
            Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width * .03, vertical: height * .02),
                child: SizedBox(
                  width: width * .4,
                  child: ListTile(
                    title: Text(
                      "Deep Learning neural networks",
                      style: titleStyle(),
                    ),
                    subtitle: Text(
                      'AI models trained on MRI Dataset over 3000 images',
                      style: subtitleStyle(),
                    ),
                  ),
                )),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(right: width * .04),
              child: SizedBox(
                height: height * .12,
                width: width * .3,
                child: Image.asset(
                  'Assets/aibox.jpg',
                  fit: BoxFit.fill,
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}

class LastReadWidget2 extends StatelessWidget {
  const LastReadWidget2({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: height * .15,
        width: width,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(1.5, 3), // changes position of shadow
              ),
            ],
            image: DecorationImage(
                image: AssetImage('Assets/dashboard.png'), fit: BoxFit.fill),
            borderRadius: BorderRadius.circular(25)),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                primaryColor.withOpacity(0.7),
                secondaryColor.withOpacity(0.7)
              ]),
              borderRadius: BorderRadius.circular(25)),
          child: Row(children: [
            Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width * .03, vertical: height * .02),
                child: SizedBox(
                  width: width * .4,
                  child: ListTile(
                    title: Text(
                      "Quick & Accurate Results",
                      style: titleStyle(),
                    ),
                  ),
                )),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(right: width * .04),
              child: SizedBox(
                height: height * .12,
                width: width * .3,
                child: Image.asset(
                  'Assets/searchres.png',
                  fit: BoxFit.fill,
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}

class LastReadWidget3 extends StatelessWidget {
  const LastReadWidget3({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: height * .15,
        width: width,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(1.5, 3), // changes position of shadow
              ),
            ],
            image: DecorationImage(
                image: AssetImage('Assets/dashboard.png'), fit: BoxFit.fill),
            borderRadius: BorderRadius.circular(25)),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                primaryColor.withOpacity(0.7),
                secondaryColor.withOpacity(0.7)
              ]),
              borderRadius: BorderRadius.circular(25)),
          child: Row(children: [
            Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width * .03, vertical: height * .02),
                child: SizedBox(
                  width: width * .4,
                  child: ListTile(
                    title: Text(
                      "MRI Dataset > 4000",
                      style: titleStyle(),
                    ),
                  ),
                )),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(right: width * .04),
              child: SizedBox(
                height: height * .12,
                width: width * .3,
                child: Image.asset(
                  'Assets/ds.jpeg',
                  fit: BoxFit.fill,
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}

class GotoWidget extends StatelessWidget {
  final VoidCallback? onpressed;

  const GotoWidget({Key? key, this.onpressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.start,
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Go to', style: miniStyle()),
        SizedBox(
          width: 7,
        ),
        Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
          size: 17,
        )
      ],
    );
  }
}
