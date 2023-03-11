
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  // ignore: prefer_const_constructors
  runApp(CupertinoApp(
    home: const SafeArea(child: App()),
    theme: const CupertinoThemeData(brightness: Brightness.light),
  ));
}

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<StatefulWidget> createState() => _AppState();
}
List<Text> bets = [];
List<Text> timestamps = [];
class _AppState extends State<App> {
  late TextEditingController _textController;
  
  DateTime time = DateTime.now();
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ));
  }
  
  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // Scaffold is a layout for
    // the major Material Components.
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      floatingActionButton: FloatingActionButton(onPressed: () async{
              final bet = await openDialog();
              if (bet != null){
                setState(() {
                  bets.add(Text(bet,key: UniqueKey(),));
                  timestamps.add(Text("${time.day}.${time.month}.${time.year}"));
                });
              }
            }, child: const Icon(CupertinoIcons.add)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 25.0, top: 75),
            child: Text('Active Bets', style: TextStyle(fontSize: 32,fontWeight: FontWeight.bold),),
            ),
          Expanded(
            child: CupertinoScrollbar(
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) => Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => {
                    bets.removeAt(index),
                    timestamps.removeAt(index)
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 25.0),
                      child: Icon(CupertinoIcons.delete_simple,color: Colors.white),
                    )
                    ),
                  child: Item(
                    bet: bets[index],timestamp: timestamps[index],
                    ),
                ),
                itemCount: bets.length,
                    
                ),
            ),
          )
        ],
      )
    );
  }
  
  Future<String?> openDialog() => showCupertinoDialog<String>(
    context: context,
     builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return CupertinoAlertDialog(
          title: const Text("Enter Description"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoTextField(
                controller: _textController,
              ),
              CupertinoButton(
                onPressed: () => _showDialog(
                  CupertinoDatePicker(
                    initialDateTime: time,
                    mode: CupertinoDatePickerMode.date,
                    onDateTimeChanged: (DateTime date) => {
                      setState(() => time = date,)
                    },
                  )
                ),
                child: Text('${time.day}.${time.month}.${time.year}'),
              )
            ],
          ),
          actions: [
            CupertinoButton(child: const Text("Add"), onPressed: () => handleSubmit(context)),
            CupertinoButton(
              child: const Text(style: TextStyle(color: Colors.red),"Cancel"),
              onPressed: () => { Navigator.of(context).pop(), _textController.clear()},
            )
          ]
        );
      }
      )
     );

  void handleSubmit(BuildContext context) => {
    if (_textController.text != ""){
      Navigator.of(context).pop(_textController.text),
      _textController.clear()
    } 
  };

}

class Item extends StatelessWidget {
  final Text bet;
  
  final Text timestamp;

  const Item({super.key, 
    required this.bet,
    required this.timestamp
  });
  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        ListTile(
          title: bet,
          trailing: timestamp,
        ),
        const Divider()
      ]
    );
  }
}

class Bets extends StatelessWidget {
  const Bets({super.key, betsList});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: UniqueKey(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      itemCount: bets.length,
      itemBuilder: (BuildContext context, int index){
        return Container(
          height: 50,
          margin: const EdgeInsets.all(2),
          child: Center(
            child: bets[index]
          ),
        );
      },
    );
  }
}