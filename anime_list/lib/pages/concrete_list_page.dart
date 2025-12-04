import 'package:flutter/material.dart';

class ConcreteList extends StatefulWidget {
  final String text;
  final VoidCallback onBack;

  const ConcreteList({super.key, required this.text, required this.onBack});

  @override
  State<ConcreteList> createState() => _ConcreteListState();
}

class _ConcreteListState extends State<ConcreteList> {

   final List<_Item> items = [
    _Item(title: 'Берсерк!', isChecked: false),
    _Item(title: 'Огненный удар', isChecked: false)
   ];


   void _addNewItem() async {
    final result = await showDialog<_Item>(context: context, builder: (context)=>_AddItemDialog(),);


    if (result !=null) {
      setState(() {
        items.add(result);
      });
    }
   }


  @override
  Widget build(BuildContext context) {
    return Container(
         decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade100, Colors.grey.shade200],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child:  Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.text, style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold
                ),),

                    IconButton(
                    icon: const Icon(Icons.add_circle_rounded, size: 50),
                    color: Colors.lightBlue,
                    onPressed: _addNewItem,
                  )
              ],
            ),
            Expanded(child: ListView.separated(itemBuilder: (BuildContext context, int index){
              String title = items[index].title;

            return Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w500
    ),),
    SizedBox(width: 4), 
    Checkbox(
      checkColor: Colors.white,
     fillColor: MaterialStateProperty.resolveWith<Color>((states) {
    if (states.contains(MaterialState.selected)) {
      return Colors.green;  
    }
    return Colors.white;     
  }),
      value: items[index].isChecked,
      onChanged: (bool? value) {
        setState(() {
items[index].isChecked = value ?? false;
});
      },
    ),
        SizedBox(width: 10), 
    IconButton(
      color: Colors.redAccent,
      onPressed: (){
        setState(() {
items.removeAt(index);
});
      }, icon: Icon(Icons.delete))

  ],
);
            }, separatorBuilder: (_,_){
              return SizedBox(height: 10,);
            }, itemCount: items.length))
          ],
                ),
        )),
    );
  }
}


class _Item {
  final String title;
  bool isChecked; 

  _Item({required this.title, required  this.isChecked});
}


class _AddItemDialog extends StatefulWidget {
  const _AddItemDialog({super.key});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final TextEditingController _controller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(context), child: Text('Отмена')),
        ElevatedButton(onPressed: (){
          if (_controller.text.isNotEmpty ) {
            Navigator.pop(
              context,
              _Item(title: _controller.text, isChecked: false),
            );
          }
        }, child: Text('Добавить'))
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: 'Добавить новый пункт'),
          ),
          
        ],
      ),
    );
  }
}