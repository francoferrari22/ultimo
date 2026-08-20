import 'package:flutter/material.dart';
import '../main.dart';
import 'home.dart';

class SettingsScreen extends StatefulWidget { final bool firstRun; const SettingsScreen({super.key,this.firstRun=false});
  @override State<SettingsScreen> createState()=>_SettingsScreenState(); }
class _SettingsScreenState extends State<SettingsScreen>{
  late final TextEditingController url=TextEditingController(text: api.baseUrl);
  late final TextEditingController key=TextEditingController(text: api.apiKey);
  bool saving=false;
  Future<void> save() async { setState(()=>saving=true); try { await api.save(url.text,key.text); if(mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(_)=>const HomeScreen())); } catch(e){ if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$e'))); } finally{if(mounted)setState(()=>saving=false);} }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Configuración')),body:Padding(padding:const EdgeInsets.all(20),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
    const Text("Ferrari's POS",style:TextStyle(fontSize:28,fontWeight:FontWeight.bold)),const SizedBox(height:8),
    const Text('Conectá la app al puente que corre en la PC del POS.'),const SizedBox(height:24),
    TextField(controller:url,keyboardType:TextInputType.url,decoration:const InputDecoration(labelText:'Dirección del servidor',hintText:'http://192.168.1.50:5077',border:OutlineInputBorder())),const SizedBox(height:14),
    TextField(controller:key,obscureText:true,decoration:const InputDecoration(labelText:'API Key',border:OutlineInputBorder())),const SizedBox(height:20),
    FilledButton.icon(onPressed:saving?null:save,icon:const Icon(Icons.save),label:Text(saving?'Guardando...':'Guardar y conectar')),
    if(!widget.firstRun) TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancelar'))
  ])));
}
