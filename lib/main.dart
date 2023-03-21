
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

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

final prefs = SharedPreferences.getInstance();

class _AppState extends State<App> with WidgetsBindingObserver {
  late TextEditingController _textController;
  
  DateTime time = DateTime.now();
  
  List<Bet> _bets = <Bet>[];

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 430,
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
    _loadBets();
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
      backgroundColor: CupertinoColors.black,
      floatingActionButton: FloatingActionButton.large(
        onPressed: () async{
              final bet = await openDialog();
              if (bet != null){
                setState(() {
                  _bets.add(Bet(
                    title: bet,
                    timestamp: "${time.day}.${time.month}.${time.year}"
                    ));
                  _saveBets();
                  // bets.add(Text(bet,key: UniqueKey(),style: TextStyle(color: CupertinoColors.white),));
                  // timestamps.add(Text("${time.day}.${time.month}.${time.year}",style: TextStyle(color: CupertinoColors.white),));
                });
              }
            },
         
        child: const Icon(CupertinoIcons.add)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 25.0, top: 75),
            child: Text('Active Bets', style: TextStyle(fontSize: 32,fontWeight: FontWeight.bold,color: CupertinoColors.white),),
            ),
          Expanded(
            child: CupertinoScrollbar(
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) => Column(
                  children: [
                    Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.horizontal,
                      movementDuration: const Duration(milliseconds: 500),
                      confirmDismiss: (direction) async{
                        if (direction==DismissDirection.startToEnd){
                          setState(() {
                            _bets[index].isChecked = !_bets[index].isChecked;                            
                          });
                          _saveBets();
                          return false;
                        } else if(direction==DismissDirection.endToStart){
                          setState(() {                            
                            _bets.removeAt(index);
                          });
                          _saveBets();
                          return true;
                        }
                        return null;
                      },
                      background: Container(
                        color: _bets[index].isChecked ? CupertinoColors.activeOrange : CupertinoColors.activeGreen,
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: Icon(_bets[index].isChecked ? CupertinoIcons.clear:CupertinoIcons.check_mark, color: Colors.white),
                        )
                        ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 25.0),
                          child: Icon(CupertinoIcons.delete_simple,color: Colors.white),
                        )
                        ),
                      child: Item(
                        bet: _bets[index]
                        ),
                    ),
                    const Divider(
                      color: CupertinoColors.lightBackgroundGray,
                      height: 0,
                      thickness: 0.1,
                      indent: 50,
                      endIndent: 0,
                    )
                  ],
                ),
                itemCount: _bets.length,
                    
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
            CupertinoDialogAction(child: const Text("Add"), onPressed: () => handleSubmit(context)),
            CupertinoDialogAction(
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
  
  Future<void> _loadBets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataStr = prefs.getString('data_key');
    if (dataStr != null) {
      setState(() {
        _bets = Bet.decode(dataStr);
      });
    } else {
      _bets = [];
    }
  }
  
  Future<void> _saveBets() async {
    final prefs = await SharedPreferences.getInstance();
    final String dataStr = Bet.encode(_bets);
    await prefs.setString('data_key', dataStr);
  }

}

class Item extends StatelessWidget {
  final Bet bet;
  const Item({
    super.key, 
    required this.bet,
  });
  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Icon(CupertinoIcons.check_mark, color: bet.isChecked ? Colors.green : Colors.grey, size: 15),
              )
              ]
          ),
          title: Text(bet.title, style: const TextStyle(color: CupertinoColors.white)),
          trailing: Text(bet.timestamp, style: const TextStyle(color: CupertinoColors.white)),
        )
      ]
    );
  }
}