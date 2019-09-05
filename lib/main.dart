import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:licham/main_bloc.dart';
import 'package:licham/main_event.dart';
import 'package:licham/main_view.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(
    BlocProvider<MainBloc>(
      builder: (context) {
        return MainBloc()..dispatch(AppStarted());
      },
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  Widget build(ct) {
    return MaterialApp(
      theme: ThemeData(
          brightness: Brightness.light,
          accentColor: Colors.red,
          iconTheme: IconThemeData(color: Colors.red)),
      title: "Âm Lịch",
      home: MainView(),
    );
  }
}

//class HState extends State<Home> {
//  List fd;
//  Map fi;
//
//  void initState() {
//    super.initState();
//    getData();
//  }
//
//  getData() async {
//    http.Response r =
//        await http.get('https://filipino-cuisine-app.firebaseio.com/data.json');
//    fd = json.decode(r.body);
//    setState(() => fi = fd[0]);
//  }
//
//  Widget build(ct) {
//    if (fd == null)
//      return Container(
//          color: Colors.white,
//          child: Center(
//            child: CircularProgressIndicator(),
//          ));
//    var t = Theme.of(ct).textTheme;
//    return Scaffold(
//      body: Column(
//        children: <Widget>[
////          Expanded(
////              flex: 5,
////              child: Swiper(
////                  onIndexChanged: (n) => setState(() => fi = fd[n]),
////                  itemCount: fd.length,
////                  itemBuilder: (cx, i) {
////                    return Container(
////                        margin: EdgeInsets.only(top: 40, bottom: 24),
////                        child: ClipRRect(
////                          borderRadius: BorderRadius.circular(20),
////                          child: Hero(
////                              tag: fd[i]['fn'],
////                              child:
////                                  Image.asset(fd[i]['pf'], fit: BoxFit.cover)),
////                        ));
////                  },
////                  viewportFraction: .85,
////                  scale: .9)),
//          Text(fi['fn'],
//              style:
//                  t.display3.copyWith(fontFamily: 'ark', color: Colors.black)),
//          Container(
//            child: Text(fi['cn'],
//                style: t.subhead.apply(color: Colors.red, fontFamily: 'opb')),
//            margin: EdgeInsets.only(top: 10, bottom: 30),
//          ),
//          Container(
//              child: Text(fi['dc'],
//                  textAlign: TextAlign.center,
//                  style: t.subhead.copyWith(fontFamily: 'opr')),
//              margin: EdgeInsets.only(left: 10, right: 10)),
//          Expanded(
//              flex: 2,
//              child: ListView.builder(
//                  scrollDirection: Axis.horizontal,
//                  itemCount: fi['ig'].length,
//                  itemBuilder: (cx, i) {
//                    return Row(children: <Widget>[
//                      Container(
//                          margin: EdgeInsets.only(left: 10),
//                          height: 60,
//                          child: Image.asset(fi['ig'][i]['p'],
//                              fit: BoxFit.contain)),
//                      Container(
//                          margin: EdgeInsets.only(left: 5, right: 10),
//                          child: Column(
//                              mainAxisAlignment: MainAxisAlignment.center,
//                              children: <Widget>[
//                                Text(fi['ig'][i]['n'],
//                                    style:
//                                        t.subtitle.copyWith(fontFamily: 'opb')),
//                                Text(fi['ig'][i]['c'],
//                                    style:
//                                        t.caption.copyWith(fontFamily: 'opr'))
//                              ]))
//                    ]);
//                  }))
//        ],
//      ),
//      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
////      floatingActionButton: FloatingActionButton(
////        child: Icon(Icons.restaurant_menu),
////        onPressed: () => Navigator.push(
////            ct,
////            MaterialPageRoute(
////                builder: (cx) => Cook(fi['in'], fi['pf'], fi['fn']))),
////      ),
//      bottomNavigationBar: BottomAppBar(
//          shape: CircularNotchedRectangle(),
//          notchMargin: 4.0,
//          child: Row(
//              mainAxisAlignment: MainAxisAlignment.spaceAround,
//              children: <Widget>[
//                IconButton(
//                    icon:
//                        Icon(fi['fv'] ? Icons.favorite : Icons.favorite_border),
//                    onPressed: () => setState(() => fi['fv'] = !fi['fv'])),
//                IconButton(icon: Icon(Icons.share), onPressed: () {})
//              ])),
//    );
//  }
//}
