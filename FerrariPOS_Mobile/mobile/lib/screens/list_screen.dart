import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';

class ListScreen extends StatefulWidget{final String path,title;const ListScreen({super.key,required this.path,required this.title});@override State<ListScreen> createState()=>_ListScreenState();}
class _ListScreenState extends State<ListScreen>{List<dynamic> rows=[];bool loading=true;String? error;final money=NumberFormat.currency(locale:'es_AR',symbol:'4 ',decimalDigits:2);
 Future<void> load()async{try{final d=await api.get(widget.path);final x=d is List?d:(d['sessions']??d['movements']??[]);setState(()=>rows=List.from(x));}catch(e){setState(()=>error='$e');}finally{setState(()=>loading=false);}}
 @override void initState(){super.initState();load();}
 String moneyIf(dynamic v)=>v is num?money.format(v):'${v??''}';
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(widget.title)),body:RefreshIndicator(onRefresh:load,child:loading?const Center(child:CircularProgressIndicator()):error!=null?Center(child:Padding(padding:const EdgeInsets.all(20),child:Text(error!))):rows.isEmpty?const Center(child:Text('No hay datos')):ListView.separated(padding:const EdgeInsets.all(12),itemCount:rows.length,itemBuilder:(c,i){final r=Map<String,dynamic>.from(rows[i]);final name=r['customer']??r['name']??r['description']??r['concept']??'Registro';final amount=r['total']??r['balance']??r['amount']??r['closingAmount'];return Card(child:ListTile(title:Text('$name'),subtitle:Text(_subtitle(r)),trailing:amount!=null?Text(moneyIf(amount),style:const TextStyle(fontWeight:FontWeight.bold)):null));},separatorBuilder:(_,__)=>const SizedBox(height:6))));
 String _subtitle(Map<String,dynamic> r){final parts=<String>[];if(r['ticketNo']!=null)parts.add('Ticket #${r['ticketNo']}');if(r['paymentMethod']!=null)parts.add('${r['paymentMethod']}');if(r['stock']!=null)parts.add('Stock: ${r['stock']}');if(r['phone']!=null&&'${r['phone']}'.isNotEmpty)parts.add('${r['phone']}');if(r['createdAt']!=null)parts.add('${r['createdAt']}');if(r['status']!=null)parts.add('${r['status']}');return parts.join(' · ');}
}
