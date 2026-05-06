import 'package:flutter/material.dart';

import 'login_page.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override build(BuildContext context) {
    return Scaffold();
  }
}


























  /**
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pagina di prova"),
      actions: [Icon(Icons.account_box_rounded)],
      ),
      body: Column(
        children:[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [const Text("Testo dentro al corpo", style:TextStyle(color:Colors.white))],
          ),
          const SizedBox(height:10),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
            children:[
              const Text("Vai alla pagina di ", style:TextStyle(color:Colors.white)),

              TextButton(
                  child: const Text("Login", style: TextStyle(color: Colors.blue)),
                  onPressed: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                        )
                    );
                  },
                )
              ]
          ),
          const SizedBox(height:10),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //ChangingSizeBox()

            ]
          ),
        ]
        ),
    );
  }
}

class ChangingSizeBox extends StatefulWidget{
  const ChangingSizeBox({super.key});

  @override
  State<ChangingSizeBox> createState() => _ChangingSizeBoxState();
}

class _ChangingSizeBoxState extends State<ChangingSizeBox>{
  double _boxSize = 50;


  Widget build(BuildContext context){
    return Container(
            child:
                Column(
                    children:[
                      Row(
              children: [
                Slider(value: _boxSize,
                    min:0,
                    max:100,
                onChanged: (newValue){
                  setState(() {
                    _boxSize = newValue;
                  });
                })
              ],
            ),
            Row(
              children: [
                Container(
                  width: _boxSize,
                  height: _boxSize,
                  color: Colors.blue,
                ),
              ]
            )
            ]
                )
    );
          }
}
 */