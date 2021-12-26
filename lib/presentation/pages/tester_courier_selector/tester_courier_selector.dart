import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_bloc.dart';
import 'package:kncv_flutter/presentation/blocs/tester_courier/tester_courier_state.dart';

class SelectorPage extends StatefulWidget {
  static const String selectorPageRouteName = 'selector page route name';
  @override
  _SelectorPageState createState() => _SelectorPageState();
}

class _SelectorPageState extends State<SelectorPage> {
  Tester? tester;
  Courier? courier;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TesterCourierBloc, TesterCourierStates>(
        listener: (ctx, state) {
      print(state);
    }, builder: (context, state) {
      if (state is LoadedState) {
        return Column(
          children: [
            Container(
                width: double.infinity,
                child: Text(
                  'Nearby Couriers',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16,
                    color: kTextColorLight,
                  ),
                )),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(7),
              ),
              child: DropdownButtonHideUnderline(
                  child: DropdownButton<Courier>(
                      onChanged: (val) {
                        setState(() {
                          courier = val;
                          BlocProvider.of<TesterCourierBloc>(context).courier =
                              val;
                        });
                      },
                      value: courier,
                      hint: Text('Select Courier'),
                      items: state.data['couriers']!
                          .map(
                            (e) => DropdownMenuItem<Courier>(
                              value: e as Courier,
                              child: Text(
                                e.toString(),
                              ),
                            ),
                          )
                          .toList())),
            ),
            SizedBox(
              height: 40,
            ),
            Container(
                width: double.infinity,
                child: Text(
                  'Nearby Test Centers',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16,
                    color: kTextColorLight,
                  ),
                )),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(7),
              ),
              child: DropdownButtonHideUnderline(
                  child: DropdownButton<Tester>(
                      onChanged: (val) {
                        setState(() {
                          tester = val;
                          BlocProvider.of<TesterCourierBloc>(context).tester =
                              tester;
                        });
                      },
                      value: tester,
                      hint: Text('Select Tester'),
                      items: state.data['testers']!
                          .map(
                            (e) => DropdownMenuItem<Tester>(
                              value: e as Tester,
                              child: Text(
                                e.toString(),
                              ),
                            ),
                          )
                          .toList())),
            ),
            SizedBox(
              height: 45,
            ),
            InkWell(
              onTap: () {
                if (BlocProvider.of<TesterCourierBloc>(context).tester !=
                        null &&
                    BlocProvider.of<TesterCourierBloc>(context).courier !=
                        null) {
                  Navigator.pop(context, true);
                }
              },
              borderRadius: BorderRadius.circular(37),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: kColorsOrangeDark,
                ),
                height: 62,
                // margin: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'Create Order',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        );
      }
      return Center(child: CircularProgressIndicator());
    });
  }
}