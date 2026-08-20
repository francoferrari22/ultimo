import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import 'list_screen.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget{const HomeScreen({super.key}); @override State<HomeScreen> createState()=>_HomeScreenState();}
class _HomeScreenState extends State<HomeScreen>{Map<String,dynamic>? data; bool loading=true; String? error; final money=NumberFormat.currency(locale:'es_AR',symbol:'4 ',decimalDigits:2);
 Future<void> load() async{try{final d=await api.get('/api/dashboard');setState(()=>data=Map<String,dynamic>.from(d));}catch(e){setState(()=>error='$e');}finally{setState(()=>loading=false);}}
 @override void initState(){super.initState();load();}
 Widget card(String title,String value,IconData icon){return Card(child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[CircleAvatar(child:Icon(icon)),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(color:Colors.white70)),const SizedBox(height:5),Text(value,style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold))]))])));}
 @override Widget build(BuildContext context){final d=data;return Scaffold(appBar:AppBar(title:const Text("Ferrari's POS"),actions:[IconButton(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const SettingsScreen())),icon:const Icon(Icons.settings))]),body:RefreshIndicator(onRefresh:load,child:ListView(padding:const EdgeInsets.all(14),children:[
   const Text('Resumen',style:TextStyle(fontSize:28,fontWeight:FontWeight.bold)),const SizedBox(height:14),
   if(loading) const LinearProgressIndicator(), if(error!=null) Card(child:Padding(padding:const EdgeInsets.all(14),child:Text(error!))),
   if(d!=null)...[card('Ventas de hoy',money.format((d['salesToday']??0)),Icons.point_of_sale),const SizedBox(height:10),card('Tickets de hoy','${d['ticketsToday']??0}',Icons.receipt_long),const SizedBox(height:10),card('Crédito pendiente',money.format((d['totalCredit']??0)),Icons.credit_card),const SizedBox(height:10),card('Stock bajo','${d['lowStock']??0}',Icons.inventory_2)],
   const SizedBox(height:20),
   _menu(context,'Ventas','Consultar ventas y tickets',Icons.receipt_long,'/api/sales','Ventas'),_menu(context,'Créditos','Clientes con saldo pendiente',Icons.account_balance_wallet,'/api/credits','Créditos'),_menu(context,'Clientes','Clientes y cuentas corrientes',Icons.people,'/api/customers','Clientes'),_menu(context,'Inventario','Productos y existencias',Icons.inventory,'/api/products','Inventario'),_menu(context,'Caja','Sesiones y movimientos',Icons.account_balance,'/api/cash','Caja')
 ]));}
 Widget _menu(BuildContext c,String t,String s,IconData i,String path,String title)=>Card(child:ListTile(leading:CircleAvatar(child:Icon(i)),title:Text(t,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text(s),trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>ListScreen(path:path,title:title))));
}
