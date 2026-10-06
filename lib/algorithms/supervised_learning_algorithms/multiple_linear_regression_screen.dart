import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MultipleLinearRegressionScreen extends StatefulWidget {
  const MultipleLinearRegressionScreen({super.key});
  @override
  State<MultipleLinearRegressionScreen> createState() => _MultipleLinearRegressionScreenState();
}

enum MultipleLinearRegressionEventType { initialize, mean, coefficients, predict, residual, complete }

class MultipleLinearRegressionEvent {
  final MultipleLinearRegressionEventType type;
  final List<double> x1, x2, y;
  final double meanX1, meanX2, meanY, b0, b1, b2;
  final int currentIndex;
  final double prediction, residual;
  final String title, description, operation;
  const MultipleLinearRegressionEvent({
    required this.type, required this.x1, required this.x2, required this.y,
    required this.meanX1, required this.meanX2, required this.meanY,
    required this.b0, required this.b1, required this.b2, required this.currentIndex,
    required this.prediction, required this.residual, required this.title,
    required this.description, required this.operation,
  });
}

class _MultipleLinearRegressionScreenState extends State<MultipleLinearRegressionScreen> {
  static const Color background = Color(0xFF030712);
  static const Color background2 = Color(0xFF07101F);
  static const Color cardColor = Color(0xFF0B1428);
  static const Color visualizationColor = Color(0xFF0A1020);
  static const Color cyan = Color(0xFF00E5FF);
  static const Color blue = Color(0xFF2979FF);
  static const Color purple = Color(0xFF9C27FF);
  static const Color green = Color(0xFF00E676);
  static const Color orange = Color(0xFFFFB300);
  static const Color red = Color(0xFFFF5252);

  List<double> x1Values = [1, 2, 3, 4, 5, 6];
  List<double> x2Values = [2, 1, 4, 3, 5, 6];
  List<double> yValues = [4, 5, 9, 10, 13, 16];
  final x1Controller = TextEditingController(text: '1, 2, 3, 4, 5, 6');
  final x2Controller = TextEditingController(text: '2, 1, 4, 3, 5, 6');
  final yController = TextEditingController(text: '4, 5, 9, 10, 13, 16');

  List<MultipleLinearRegressionEvent> events = [];
  List<MultipleLinearRegressionEvent> executionHistory = [];
  int currentStep = 0;
  bool isRunning = false, isCompleted = false;
  double speed = 1.0;
  Timer? timer;
  double meanX1 = 0, meanX2 = 0, meanY = 0, b0 = 0, b1 = 0, b2 = 0;
  double prediction = 0, residual = 0;
  int currentIndex = -1, activeCodeLine = 0;
  String equation = '';
  String executionMessage = 'Ready to start Multiple Linear Regression.';

  final String sourceCode = '''MultipleLinearRegression fit(X1, X2, y) {
  final meanX1 = average(X1);
  final meanX2 = average(X2);
  final meanY = average(y);

  // Solve the normal equations:
  // [n   Σx1   Σx2 ] [b0]   [Σy ]
  // [Σx1 Σx1² Σx1x2] [b1] = [Σx1y]
  // [Σx2 Σx1x2 Σx2²] [b2]   [Σx2y]
  final coefficients = solveNormalEquations(X1, X2, y);
  final b0 = coefficients[0];
  final b1 = coefficients[1];
  final b2 = coefficients[2];

  final prediction = b0 + b1 * X1[i] + b2 * X2[i];
  final residual = y[i] - prediction;
  return LinearRegression(b0, b1, b2);
}''';

  @override
  void initState() { super.initState(); _generateEvents(); }
  @override
  void dispose() { timer?.cancel(); x1Controller.dispose(); x2Controller.dispose(); yController.dispose(); super.dispose(); }

  List<double> _copy(List<double> v) => [...v];
  String _fmt(double v) => v.abs() < 0.00005 ? '0' : v.toStringAsFixed(2);

  List<double>? _solveCoefficients() {
    final n = x1Values.length.toDouble();
    double sx1 = 0, sx2 = 0, sy = 0, sx1x1 = 0, sx2x2 = 0, sx1x2 = 0, sx1y = 0, sx2y = 0;
    for (int i = 0; i < x1Values.length; i++) {
      final a = x1Values[i], b = x2Values[i], c = yValues[i];
      sx1 += a; sx2 += b; sy += c; sx1x1 += a*a; sx2x2 += b*b; sx1x2 += a*b; sx1y += a*c; sx2y += b*c;
    }
    final m = [
      [n, sx1, sx2, sy],
      [sx1, sx1x1, sx1x2, sx1y],
      [sx2, sx1x2, sx2x2, sx2y],
    ];
    for (int col = 0; col < 3; col++) {
      int pivot = col;
      for (int r = col + 1; r < 3; r++) {
        if (m[r][col].abs() > m[pivot][col].abs()) pivot = r;
      }
      if (m[pivot][col].abs() < 1e-10) return null;
      final tmp = m[col]; m[col] = m[pivot]; m[pivot] = tmp;
      final div = m[col][col];
      for (int j = col; j < 4; j++) {
        m[col][j] /= div;
      }
      for (int r = 0; r < 3; r++) {
        if (r == col) continue;
        final factor = m[r][col];
        for (int j = col; j < 4; j++) {
          m[r][j] -= factor * m[col][j];
        }
      }
    }
    return [m[0][3], m[1][3], m[2][3]];
  }

  void _generateEvents() {
    final generated = <MultipleLinearRegressionEvent>[];
    final n = x1Values.length;
    final mx1 = x1Values.reduce((a,b)=>a+b)/n, mx2 = x2Values.reduce((a,b)=>a+b)/n, my = yValues.reduce((a,b)=>a+b)/n;
    final coef = _solveCoefficients();
    final c0 = coef?[0] ?? 0, c1 = coef?[1] ?? 0, c2 = coef?[2] ?? 0;
    generated.add(MultipleLinearRegressionEvent(type: MultipleLinearRegressionEventType.initialize, x1:_copy(x1Values), x2:_copy(x2Values), y:_copy(yValues), meanX1:0, meanX2:0, meanY:0,b0:0,b1:0,b2:0,currentIndex:-1,prediction:0,residual:0,title:'Regression Initialized',description:'Load paired feature values X1, X2 and target Y.',operation:'n = $n samples'));
    generated.add(MultipleLinearRegressionEvent(type: MultipleLinearRegressionEventType.mean, x1:_copy(x1Values), x2:_copy(x2Values), y:_copy(yValues), meanX1:mx1, meanX2:mx2, meanY:my,b0:0,b1:0,b2:0,currentIndex:-1,prediction:0,residual:0,title:'Calculate Means',description:'Calculate the mean of both input features and the target.',operation:'meanX1 = ${_fmt(mx1)}, meanX2 = ${_fmt(mx2)}, meanY = ${_fmt(my)}'));
    generated.add(MultipleLinearRegressionEvent(type: MultipleLinearRegressionEventType.coefficients, x1:_copy(x1Values), x2:_copy(x2Values), y:_copy(yValues), meanX1:mx1, meanX2:mx2, meanY:my,b0:c0,b1:c1,b2:c2,currentIndex:-1,prediction:0,residual:0,title:'Solve Coefficients',description:'Solve the three normal equations to obtain intercept and feature coefficients.',operation:'b0 = ${_fmt(c0)}, b1 = ${_fmt(c1)}, b2 = ${_fmt(c2)}'));
    for (int i=0;i<n;i++) {
      final p = c0+c1*x1Values[i]+c2*x2Values[i];
      generated.add(MultipleLinearRegressionEvent(type: MultipleLinearRegressionEventType.predict,x1:_copy(x1Values),x2:_copy(x2Values),y:_copy(yValues),meanX1:mx1,meanX2:mx2,meanY:my,b0:c0,b1:c1,b2:c2,currentIndex:i,prediction:p,residual:0,title:'Predict Value',description:'Use both features to predict the target for the current sample.',operation:'ŷ = ${_fmt(c0)} + ${_fmt(c1)}×${_fmt(x1Values[i])} + ${_fmt(c2)}×${_fmt(x2Values[i])} = ${_fmt(p)}'));
      generated.add(MultipleLinearRegressionEvent(type: MultipleLinearRegressionEventType.residual,x1:_copy(x1Values),x2:_copy(x2Values),y:_copy(yValues),meanX1:mx1,meanX2:mx2,meanY:my,b0:c0,b1:c1,b2:c2,currentIndex:i,prediction:p,residual:yValues[i]-p,title:'Calculate Residual',description:'Measure the prediction error for the current training sample.',operation:'residual = ${_fmt(yValues[i])} - ${_fmt(p)} = ${_fmt(yValues[i]-p)}'));
    }
    generated.add(MultipleLinearRegressionEvent(type: MultipleLinearRegressionEventType.complete,x1:_copy(x1Values),x2:_copy(x2Values),y:_copy(yValues),meanX1:mx1,meanX2:mx2,meanY:my,b0:c0,b1:c1,b2:c2,currentIndex:-1,prediction:0,residual:0,title:'Regression Complete',description:'The multiple linear regression model has been fitted.',operation:'ŷ = ${_fmt(c0)} ${c1>=0?'+':'-'} ${_fmt(c1.abs())}x1 ${c2>=0?'+':'-'} ${_fmt(c2.abs())}x2'));
    events=generated; meanX1=0;meanX2=0;meanY=0;b0=0;b1=0;b2=0;prediction=0;residual=0;currentIndex=-1;equation='';activeCodeLine=0;
  }

  void _applyEvent(MultipleLinearRegressionEvent e,{bool updateState=true}) {
    meanX1=e.meanX1;meanX2=e.meanX2;meanY=e.meanY;b0=e.b0;b1=e.b1;b2=e.b2;currentIndex=e.currentIndex;prediction=e.prediction;residual=e.residual;
    equation=(e.b0==0&&e.b1==0&&e.b2==0)?'':'ŷ = ${_fmt(e.b0)} ${e.b1>=0?'+':'-'} ${_fmt(e.b1.abs())}x₁ ${e.b2>=0?'+':'-'} ${_fmt(e.b2.abs())}x₂';
    activeCodeLine=_codeLineForEvent(e.type); executionMessage='${e.title}: ${e.description}';
    if(e.type==MultipleLinearRegressionEventType.complete){currentIndex=-1;executionMessage='Regression Complete: $equation';}
    if(updateState)setState((){});
  }
  void _rebuildVisualState(){meanX1=0;meanX2=0;meanY=0;b0=0;b1=0;b2=0;prediction=0;residual=0;currentIndex=-1;equation='';activeCodeLine=0;executionMessage='Ready to start Multiple Linear Regression.';for(final e in executionHistory){_applyEvent(e,updateState:false);}}
  void _reset(){timer?.cancel();setState(() { executionHistory.clear(); currentStep=0; isRunning=false; isCompleted=false; });_generateEvents();}
  int _codeLineForEvent(MultipleLinearRegressionEventType t)=>switch(t){MultipleLinearRegressionEventType.initialize=>1,MultipleLinearRegressionEventType.mean=>2,MultipleLinearRegressionEventType.coefficients=>10,MultipleLinearRegressionEventType.predict=>14,MultipleLinearRegressionEventType.residual=>15,MultipleLinearRegressionEventType.complete=>17};
  Color _eventColor(MultipleLinearRegressionEventType t)=>switch(t){MultipleLinearRegressionEventType.initialize=>blue,MultipleLinearRegressionEventType.mean=>purple,MultipleLinearRegressionEventType.coefficients=>orange,MultipleLinearRegressionEventType.predict=>cyan,MultipleLinearRegressionEventType.residual=>red,MultipleLinearRegressionEventType.complete=>green};
  IconData _eventIcon(MultipleLinearRegressionEventType t)=>switch(t){MultipleLinearRegressionEventType.initialize=>Icons.play_arrow_rounded,MultipleLinearRegressionEventType.mean=>Icons.functions_rounded,MultipleLinearRegressionEventType.coefficients=>Icons.calculate_rounded,MultipleLinearRegressionEventType.predict=>Icons.auto_graph_rounded,MultipleLinearRegressionEventType.residual=>Icons.straighten_rounded,MultipleLinearRegressionEventType.complete=>Icons.check_circle_rounded};

  Future<void> _copyCode()async{await Clipboard.setData(ClipboardData(text:sourceCode));_showSnackBar('Source code copied.',cyan);}
  void _showSnackBar(String message,Color color){ScaffoldMessenger.of(context).hideCurrentSnackBar();ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(message,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w600)),backgroundColor:color.withValues(alpha:.85),behavior:SnackBarBehavior.floating));}
  List<double>? _parse(String text){final p=text.trim().split(RegExp(r'[\s,]+'));if(p.length<2||p.length>12)return null;final r=<double>[];for(final v in p){final d=double.tryParse(v);if(d==null||d.abs()>9999)return null;r.add(d);}return r;}
  void _loadData(){final a=_parse(x1Controller.text),b=_parse(x2Controller.text),c=_parse(yController.text);if(a==null||b==null||c==null||a.length!=b.length||a.length!=c.length){_showSnackBar('Enter equal X1, X2 and Y lists with 2 to 12 valid numbers.',red);return;}timer?.cancel();setState((){x1Values=a;x2Values=b;yValues=c;executionHistory.clear();currentStep=0;isRunning=false;isCompleted=false;executionMessage='Training data loaded. Ready to fit the model.';});_generateEvents();_showSnackBar('Training data loaded successfully.',green);}
  void _generateNumbers(){final data=[[[1,2,3,4,5,6],[2,1,4,3,5,6],[4,5,9,10,13,16]],[[1,2,3,4,5],[2,4,1,5,3],[5,9,7,13,11]],[[2,4,6,8,10,12],[1,3,2,5,4,7],[6,11,13,21,19,28]]];final s=data[Random().nextInt(data.length)];x1Values=s[0].map((v)=>v.toDouble()).toList();x2Values=s[1].map((v)=>v.toDouble()).toList();yValues=s[2].map((v)=>v.toDouble()).toList();x1Controller.text=x1Values.map(_fmt).join(', ');x2Controller.text=x2Values.map(_fmt).join(', ');yController.text=yValues.map(_fmt).join(', ');timer?.cancel();setState((){executionHistory.clear();currentStep=0;isRunning=false;isCompleted=false;executionMessage='New training dataset generated.';});_generateEvents();_showSnackBar('New training dataset generated.',purple);}
  void _play(){if(events.isEmpty||isCompleted)return;timer?.cancel();setState(()=>isRunning=true);final ms=(900/speed).round().clamp(100,2000);timer=Timer.periodic(Duration(milliseconds:ms),(_){if(!mounted){timer?.cancel();return;}if(currentStep>=events.length){timer?.cancel();setState(() { isRunning=false; });return;}final e=events[currentStep];executionHistory.add(e);currentStep++;_applyEvent(e);if(currentStep>=events.length){timer?.cancel();setState(() { isRunning=false; isCompleted=true; });}});}
  void _togglePlayPause(){if(isRunning){timer?.cancel();setState(() { isRunning=false; });}else{_play();}}
  void _nextStep(){if(currentStep>=events.length)return;final e=events[currentStep];executionHistory.add(e);currentStep++;_applyEvent(e);if(currentStep>=events.length)setState(()=>isCompleted=true);}
  void _previousStep(){if(executionHistory.isEmpty)return;executionHistory.removeLast();currentStep=max(0,currentStep-1);setState(()=>isCompleted=false);_rebuildVisualState();setState((){});}

  @override Widget build(BuildContext context)=>Scaffold(backgroundColor:background,body:SafeArea(child:LayoutBuilder(builder:(context,c){final w=c.maxWidth;return SingleChildScrollView(padding:EdgeInsets.symmetric(horizontal:w<700?12:22,vertical:16),child:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:1500),child:Column(children:[_buildHeader(),const SizedBox(height:14),_buildInfo(),const SizedBox(height:14),_buildInput(),const SizedBox(height:14),_buildWorkspace(w)]))));})));
  Widget _buildHeader()=>Container(padding:const EdgeInsets.symmetric(horizontal:14,vertical:12),decoration:BoxDecoration(color:background2,borderRadius:BorderRadius.circular(14),border:Border.all(color:blue.withValues(alpha:.18))),child:Row(children:[InkWell(onTap:()=>Navigator.pop(context),borderRadius:BorderRadius.circular(10),child:Container(width:40,height:40,decoration:BoxDecoration(color:cardColor,borderRadius:BorderRadius.circular(10)),child:const Icon(Icons.arrow_back_rounded,color:Colors.white,size:20))),const SizedBox(width:12),Container(width:42,height:42,decoration:BoxDecoration(gradient:const LinearGradient(colors:[blue,purple]),borderRadius:BorderRadius.circular(11)),child:const Icon(Icons.model_training_rounded,color:Colors.white,size:23)),const SizedBox(width:12),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Multiple Linear Regression Algorithm',style:TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w800)),SizedBox(height:3),Text('Supervised learning • multiple-feature best-fit model visualization',style:TextStyle(color:Colors.white54,fontSize:12))])),_statusBadge()]));
  Widget _statusBadge(){final c=isRunning?orange:isCompleted?green:cyan;return Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),decoration:BoxDecoration(color:c.withValues(alpha:.08),borderRadius:BorderRadius.circular(20),border:Border.all(color:c.withValues(alpha:.22))),child:Row(mainAxisSize:MainAxisSize.min,children:[Icon(isRunning?Icons.play_circle_rounded:isCompleted?Icons.check_circle_rounded:Icons.circle_outlined,color:c,size:14),const SizedBox(width:6),Text(isRunning?'Running':isCompleted?'Completed':'Ready',style:TextStyle(color:c,fontSize:10,fontWeight:FontWeight.w800))]));}
  Widget _card({required Widget child})=>Container(width:double.infinity,padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:cardColor,borderRadius:BorderRadius.circular(14),border:Border.all(color:Colors.white.withValues(alpha:.06)),boxShadow:[BoxShadow(color:Colors.black.withValues(alpha:.16),blurRadius:18,offset:const Offset(0,8))]),child:child);
  Widget _sectionTitle(IconData icon,String title,Color color)=>Row(children:[Icon(icon,color:color,size:18),const SizedBox(width:8),Text(title,style:const TextStyle(color:Colors.white,fontSize:14,fontWeight:FontWeight.w800))]);
  Widget _buildInfo()=>_card(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[_sectionTitle(Icons.info_outline_rounded,'Algorithm Information',cyan),const SizedBox(height:12),Text('Multiple Linear Regression fits a plane/hyperplane that predicts Y from two or more input features.',style:TextStyle(color:Colors.white.withValues(alpha:.64),height:1.5,fontSize:12.5)),const SizedBox(height:12),Wrap(spacing:8,runSpacing:8,children:[_infoBox('Time','O(n)',orange),_infoBox('Space','O(1)',blue),_infoBox('Type','Supervised Learning',purple),_infoBox('Method','Normal Equations',green),_infoBox('Features','X1 + X2',red),_infoBox('Result','Prediction Model',cyan)])]));
  Widget _infoBox(String a,String b,Color c)=>Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:8),decoration:BoxDecoration(color:c.withValues(alpha:.06),borderRadius:BorderRadius.circular(8),border:Border.all(color:c.withValues(alpha:.12))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(a,style:TextStyle(color:Colors.white.withValues(alpha:.42),fontSize:9)),const SizedBox(height:2),Text(b,style:TextStyle(color:c,fontSize:11,fontWeight:FontWeight.w800))]));
  Widget _buildInput()=>_card(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[_sectionTitle(Icons.input_rounded,'Training Data',cyan),const SizedBox(height:12),LayoutBuilder(builder:(context,c){if(c.maxWidth<900)return Column(children:[_inputField('X1 values',x1Controller,Icons.looks_one_rounded),const SizedBox(height:10),_inputField('X2 values',x2Controller,Icons.looks_two_rounded),const SizedBox(height:10),_inputField('Y values',yController,Icons.vertical_align_top_rounded),const SizedBox(height:10),Row(children:[Expanded(child:_generateButton()),const SizedBox(width:10),Expanded(child:_loadButton())])]);return Row(crossAxisAlignment:CrossAxisAlignment.end,children:[Expanded(child:_inputField('X1 values',x1Controller,Icons.looks_one_rounded)),const SizedBox(width:10),Expanded(child:_inputField('X2 values',x2Controller,Icons.looks_two_rounded)),const SizedBox(width:10),Expanded(child:_inputField('Y values',yController,Icons.vertical_align_top_rounded)),const SizedBox(width:10),SizedBox(height:46,child:_generateButton()),const SizedBox(width:10),SizedBox(height:46,child:_loadButton())]);}),const SizedBox(height:9),Row(children:[Icon(Icons.lightbulb_outline_rounded,color:orange,size:15),const SizedBox(width:7),Expanded(child:Text('Use equal-length X1, X2 and Y lists with 2 to 12 numeric samples.',style:TextStyle(color:Colors.white.withValues(alpha:.45),fontSize:11)))])]));
  Widget _inputField(String label,TextEditingController c,IconData icon)=>TextField(controller:c,style:const TextStyle(color:Colors.white,fontSize:12),decoration:InputDecoration(labelText:label,labelStyle:TextStyle(color:Colors.white.withValues(alpha:.48),fontSize:11),prefixIcon:Icon(icon,color:cyan,size:17),filled:true,fillColor:visualizationColor,border:OutlineInputBorder(borderRadius:BorderRadius.circular(10),borderSide:BorderSide(color:Colors.white.withValues(alpha:.06))),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(10),borderSide:BorderSide(color:Colors.white.withValues(alpha:.06))),focusedBorder:const OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(10)),borderSide:BorderSide(color:cyan))));
  Widget _generateButton()=>ElevatedButton.icon(onPressed:_generateNumbers,icon:const Icon(Icons.casino_rounded,size:17),label:const Text('Generate Data'),style:ElevatedButton.styleFrom(backgroundColor:purple,foregroundColor:Colors.white,minimumSize:const Size(0,46),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(10))));
  Widget _loadButton()=>ElevatedButton.icon(onPressed:_loadData,icon:const Icon(Icons.upload_rounded,size:17),label:const Text('Load Data'),style:ElevatedButton.styleFrom(backgroundColor:cyan,foregroundColor:background,minimumSize:const Size(0,46),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(10))));
  Widget _buildWorkspace(double w){if(w<950)return Column(children:[_buildVisualization(),const SizedBox(height:14),_buildControls(),const SizedBox(height:14),_buildSourceCode(),const SizedBox(height:14),_buildExecutionSteps()]);return Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(flex:3,child:Column(children:[_buildVisualization(),const SizedBox(height:14),_buildControls()])),const SizedBox(width:14),Expanded(flex:2,child:Column(children:[_buildSourceCode(),const SizedBox(height:14),_buildExecutionSteps()]))]);}
  Widget _buildVisualization()=>_card(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[_sectionTitle(Icons.auto_graph_rounded,'Multiple Linear Regression Visualization',cyan),const SizedBox(height:7),Text('Feature space, fitted model surface projection, predictions and residuals are shown step-by-step.',style:TextStyle(color:Colors.white.withValues(alpha:.48),fontSize:10.5)),const SizedBox(height:12),SizedBox(height:360,width:double.infinity,child:CustomPaint(painter:_MultipleRegressionPainter(x1:x1Values,x2:x2Values,y:yValues,b0:b0,b1:b1,b2:b2,currentIndex:currentIndex,prediction:prediction,showModel:b1!=0||b2!=0||b0!=0,cyan:cyan,green:green,orange:orange,red:red))),const SizedBox(height:10),_buildLegend(),const SizedBox(height:11),_buildEquationCard(),const SizedBox(height:11),_buildCurrentInfo(),const SizedBox(height:11),_buildStatusCard()]));
  Widget _buildLegend()=>Wrap(spacing:13,runSpacing:8,children:[_legendItem('Training Point',cyan),_legendItem('Model Surface Projection',green),_legendItem('Current Sample',orange),_legendItem('Residual',red)]);
  Widget _legendItem(String title,Color color)=>Row(mainAxisSize:MainAxisSize.min,children:[Container(width:9,height:9,decoration:BoxDecoration(color:color,borderRadius:BorderRadius.circular(3))),const SizedBox(width:6),Text(title,style:TextStyle(color:Colors.white.withValues(alpha:.58),fontSize:10,fontWeight:FontWeight.w600))]);
  Widget _buildEquationCard()=>Container(width:double.infinity,padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:visualizationColor,borderRadius:BorderRadius.circular(10),border:Border.all(color:green.withValues(alpha:.15))),child:Row(children:[const Icon(Icons.functions_rounded,color:green,size:18),const SizedBox(width:9),Expanded(child:Text(equation.isEmpty?'Model equation will appear after coefficients are calculated.':equation,style:const TextStyle(color:Colors.white,fontSize:13,fontWeight:FontWeight.w800)))]));
  // ignore: curly_braces_in_flow_control_structures
  Widget _buildCurrentInfo(){String m;if(currentIndex>=0&&prediction.isFinite){m='Sample $currentIndex: x1 = ${_fmt(x1Values[currentIndex])}, x2 = ${_fmt(x2Values[currentIndex])}, observed y = ${_fmt(yValues[currentIndex])}, predicted y = ${_fmt(prediction)}, residual = ${_fmt(residual)}';}else if(isCompleted)m='Model fitted successfully: $equation';else m='Press Next Step or Play to fit the multiple regression model.';return Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:visualizationColor,borderRadius:BorderRadius.circular(10),border:Border.all(color:cyan.withValues(alpha:.12))),child:Row(children:[const Icon(Icons.info_outline_rounded,color:cyan,size:17),const SizedBox(width:8),Expanded(child:Text(m,style:TextStyle(color:Colors.white.withValues(alpha:.72),fontSize:12)))]));}
  Widget _buildStatusCard(){final c=isRunning?orange:isCompleted?green:cyan;return Container(width:double.infinity,padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:c.withValues(alpha:.06),borderRadius:BorderRadius.circular(10),border:Border.all(color:c.withValues(alpha:.18))),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(isRunning?Icons.play_circle_rounded:isCompleted?Icons.check_circle_rounded:Icons.info_outline_rounded,color:c,size:18),const SizedBox(width:9),Expanded(child:Text(executionMessage,style:TextStyle(color:Colors.white.withValues(alpha:.72),fontSize:11,height:1.45)))]));}
  Widget _controlButton({required IconData icon,required String label,required VoidCallback? onPressed,bool primary=false})=>OutlinedButton.icon(onPressed:onPressed,icon:Icon(icon,size:17),label:Text(label),style:OutlinedButton.styleFrom(foregroundColor:primary?background:Colors.white,backgroundColor:primary?cyan:null,side:BorderSide(color:primary?cyan:Colors.white.withValues(alpha:.10)),minimumSize:const Size(0,42),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(9)),textStyle:const TextStyle(fontSize:10,fontWeight:FontWeight.w700)));
  Widget _buildControls()=>_card(child:Column(children:[Row(children:[_controlButton(icon:Icons.skip_previous_rounded,label:'Previous',onPressed:executionHistory.isEmpty?null:_previousStep),const SizedBox(width:8),Expanded(child:_controlButton(icon:isRunning?Icons.pause_rounded:Icons.play_arrow_rounded,label:isRunning?'Pause':'Play',onPressed:isCompleted?null:_togglePlayPause,primary:true)),const SizedBox(width:8),_controlButton(icon:Icons.skip_next_rounded,label:'Next Step',onPressed:currentStep>=events.length?null:_nextStep),const SizedBox(width:8),_controlButton(icon:Icons.restart_alt_rounded,label:'Reset',onPressed:_reset)]),const SizedBox(height:10),Row(children:[const Icon(Icons.speed_rounded,color:cyan,size:17),const SizedBox(width:8),Text('Speed',style:TextStyle(color:Colors.white.withValues(alpha:.55),fontSize:11,fontWeight:FontWeight.w700)),Expanded(child:Slider(value:speed,min:.5,max:3,divisions:5,activeColor:cyan,inactiveColor:Colors.white.withValues(alpha:.08),onChanged:(v){setState(()=>speed=v);if(isRunning)_play();})),SizedBox(width:48,child:Text('${speed.toStringAsFixed(1)}x',textAlign:TextAlign.center,style:const TextStyle(color:cyan,fontSize:11,fontWeight:FontWeight.w800)))]),ClipRRect(borderRadius:BorderRadius.circular(4),child:LinearProgressIndicator(value:events.isEmpty?0:currentStep/events.length,minHeight:4,backgroundColor:Colors.white.withValues(alpha:.06),valueColor:const AlwaysStoppedAnimation<Color>(cyan))),const SizedBox(height:6),Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('Step $currentStep / ${events.length}',style:TextStyle(color:Colors.white.withValues(alpha:.45),fontSize:10)),Text(isCompleted?'Execution Finished':isRunning?'Running':'Ready',style:TextStyle(color:isCompleted?green:cyan,fontSize:10,fontWeight:FontWeight.w700))])]));
  Widget _buildSourceCode(){final lines=sourceCode.trim().split('\n');return _card(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[_sectionTitle(Icons.code_rounded,'Source Code',purple),const Spacer(),IconButton(onPressed:_copyCode,icon:const Icon(Icons.copy_rounded,color:cyan,size:17))]),const SizedBox(height:8),Container(width:double.infinity,height:370,padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:visualizationColor,borderRadius:BorderRadius.circular(10)),child:SingleChildScrollView(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:List.generate(lines.length,(i){final active=activeCodeLine==i+1;return Container(width:double.infinity,padding:const EdgeInsets.symmetric(horizontal:7,vertical:2),decoration:BoxDecoration(color:active?cyan.withValues(alpha:.08):Colors.transparent,borderRadius:BorderRadius.circular(4)),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[SizedBox(width:25,child:Text('${i+1}',style:TextStyle(color:active?cyan:Colors.white.withValues(alpha:.24),fontSize:9,fontFamily:'monospace'))),Expanded(child:Text(lines[i],style:TextStyle(color:active?Colors.white:Colors.white.withValues(alpha:.58),fontSize:9.5,fontFamily:'monospace',height:1.35))) ]));}))))]));}
  Widget _buildExecutionSteps()=>_card(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[_sectionTitle(Icons.timeline_rounded,'Execution Steps',orange),const SizedBox(height:10),if(executionHistory.isEmpty)Text('No steps executed yet. Use Play or Next Step.',style:TextStyle(color:Colors.white.withValues(alpha:.42),fontSize:11))else SizedBox(height:420,child:ListView.builder(itemCount:executionHistory.length,itemBuilder:(context,i){final e=executionHistory[i],c=_eventColor(e.type);return Container(margin:const EdgeInsets.only(bottom:7),padding:const EdgeInsets.all(9),decoration:BoxDecoration(color:c.withValues(alpha:.045),borderRadius:BorderRadius.circular(9),border:Border.all(color:c.withValues(alpha:.12))),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(_eventIcon(e.type),color:c,size:16),const SizedBox(width:8),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${i+1}. ${e.title}',style:TextStyle(color:c,fontSize:10.5,fontWeight:FontWeight.w800)),const SizedBox(height:3),Text(e.description,style:TextStyle(color:Colors.white.withValues(alpha:.58),fontSize:9.5,height:1.35)),const SizedBox(height:3),Text(e.operation,style:TextStyle(color:Colors.white.withValues(alpha:.38),fontSize:9,fontFamily:'monospace'))]))]));}))]));
}

class _MultipleRegressionPainter extends CustomPainter {
  final List<double> x1, x2, y;
  final double b0, b1, b2, prediction;
  final int currentIndex;
  final bool showModel;
  final Color cyan, green, orange, red;

  _MultipleRegressionPainter({
    required this.x1,
    required this.x2,
    required this.y,
    required this.b0,
    required this.b1,
    required this.b2,
    required this.currentIndex,
    required this.prediction,
    required this.showModel,
    required this.cyan,
    required this.green,
    required this.orange,
    required this.red,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (x1.isEmpty || x2.isEmpty || y.isEmpty) return;

    const left = 55.0, right = 18.0, top = 18.0, bottom = 42.0;
    final plot = Rect.fromLTRB(left, top, size.width - right, size.height - bottom);

    final minX1 = x1.reduce(min), maxX1 = x1.reduce(max);
    final minX2 = x2.reduce(min), maxX2 = x2.reduce(max);
    final observedMinY = y.reduce(min), observedMaxY = y.reduce(max);

    final rx1 = (maxX1 - minX1).abs() < .001 ? 1.0 : maxX1 - minX1;
    final rx2 = (maxX2 - minX2).abs() < .001 ? 1.0 : maxX2 - minX2;
    final yAtCorners = <double>[
      b0 + b1 * minX1 + b2 * minX2,
      b0 + b1 * minX1 + b2 * maxX2,
      b0 + b1 * maxX1 + b2 * minX2,
      b0 + b1 * maxX1 + b2 * maxX2,
    ];
    final minModelY = yAtCorners.reduce(min);
    final maxModelY = yAtCorners.reduce(max);
    final allMinY = showModel ? min(observedMinY, minModelY) : observedMinY;
    final allMaxY = showModel ? max(observedMaxY, maxModelY) : observedMaxY;
    final ry = (allMaxY - allMinY).abs() < .001 ? 1.0 : allMaxY - allMinY;

    final loX1 = minX1 - rx1 * .12, hiX1 = maxX1 + rx1 * .12;
    final loX2 = minX2 - rx2 * .12, hiX2 = maxX2 + rx2 * .12;
    final loY = allMinY - ry * .14, hiY = allMaxY + ry * .14;

    double nx1(double v) => (v - loX1) / (hiX1 - loX1);
    double nx2(double v) => (v - loX2) / (hiX2 - loX2);
    double ny(double v) => (v - loY) / (hiY - loY);

    // Oblique/perspective projection: X1 and X2 form the floor axes, Y is vertical.
    Offset project(double a, double b, double valueY) {
      final p1 = nx1(a);
      final p2 = nx2(b);
      final py = ny(valueY);
      final baseX = plot.left + 0.10 * plot.width;
      final baseY = plot.bottom - 0.08 * plot.height;
      return Offset(
        baseX + p1 * plot.width * .72 + p2 * plot.width * .22,
        baseY - py * plot.height * .76 - p1 * plot.height * .08 + p2 * plot.height * .08,
      );
    }

    final grid = Paint()
      ..color = Colors.white.withValues(alpha: .055)
      ..strokeWidth = 1;
    final axis = Paint()
      ..color = Colors.white.withValues(alpha: .20)
      ..strokeWidth = 1.2;
    final labelStyle = TextStyle(
      color: Colors.white.withValues(alpha: .42),
      fontSize: 9,
      fontWeight: FontWeight.w600,
    );
    final tp = TextPainter(textDirection: TextDirection.ltr);

    // Floor grid for X1/X2 feature space.
    for (int i = 0; i <= 4; i++) {
      final r = i / 4;
      final a1 = loX1 + r * (hiX1 - loX1);
      final a2 = loX2 + r * (hiX2 - loX2);
      canvas.drawLine(project(a1, loX2, loY), project(a1, hiX2, loY), grid);
      canvas.drawLine(project(loX1, a2, loY), project(hiX1, a2, loY), grid);

      tp.text = TextSpan(text: _num(a1), style: labelStyle);
      tp.layout();
      final p1 = project(a1, loX2, loY);
      tp.paint(canvas, Offset(p1.dx - tp.width / 2, p1.dy + 7));

      tp.text = TextSpan(text: _num(a2), style: labelStyle);
      tp.layout();
      final p2 = project(loX1, a2, loY);
      tp.paint(canvas, Offset(p2.dx - tp.width / 2, p2.dy + 7));
    }

    final x1AxisStart = project(loX1, loX2, loY);
    final x1AxisEnd = project(hiX1, loX2, loY);
    final x2AxisEnd = project(loX1, hiX2, loY);
    final yAxisEnd = project(loX1, loX2, hiY);
    canvas.drawLine(x1AxisStart, x1AxisEnd, axis);
    canvas.drawLine(x1AxisStart, x2AxisEnd, axis);
    canvas.drawLine(x1AxisStart, yAxisEnd, axis);

    if (showModel) {
      final surfacePaint = Paint()
        ..color = green.withValues(alpha: .72)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke;

      const divisions = 5;
      for (int i = 0; i <= divisions; i++) {
        final r = i / divisions;
        final a = loX1 + r * (hiX1 - loX1);
        final b = loX2 + r * (hiX2 - loX2);
        for (int j = 0; j < divisions; j++) {
          final r2 = j / divisions;
          final r3 = (j + 1) / divisions;
          final pA = project(a, loX2 + r2 * (hiX2 - loX2), b0 + b1 * a + b2 * (loX2 + r2 * (hiX2 - loX2)));
          final pB = project(a, loX2 + r3 * (hiX2 - loX2), b0 + b1 * a + b2 * (loX2 + r3 * (hiX2 - loX2)));
          canvas.drawLine(pA, pB, surfacePaint);
        }
        for (int j = 0; j < divisions; j++) {
          final r2 = j / divisions;
          final r3 = (j + 1) / divisions;
          final pA = project(loX1 + r2 * (hiX1 - loX1), b, b0 + b1 * (loX1 + r2 * (hiX1 - loX1)) + b2 * b);
          final pB = project(loX1 + r3 * (hiX1 - loX1), b, b0 + b1 * (loX1 + r3 * (hiX1 - loX1)) + b2 * b);
          canvas.drawLine(pA, pB, surfacePaint);
        }
      }
    }

    for (int i = 0; i < x1.length; i++) {
      final observed = project(x1[i], x2[i], y[i]);
      if (i == currentIndex && prediction.isFinite) {
        final predicted = project(x1[i], x2[i], prediction);
        canvas.drawLine(
          observed,
          predicted,
          Paint()
            ..color = red.withValues(alpha: .90)
            ..strokeWidth = 2.2,
        );
        canvas.drawCircle(predicted, 4.5, Paint()..color = red);
      }
      canvas.drawCircle(observed, i == currentIndex ? 7 : 5, Paint()..color = i == currentIndex ? orange : cyan);
    }

    tp.text = TextSpan(text: 'X1', style: labelStyle);
    tp.layout();
    tp.paint(canvas, Offset(x1AxisEnd.dx - tp.width, x1AxisEnd.dy + 17));
    tp.text = TextSpan(text: 'X2', style: labelStyle);
    tp.layout();
    tp.paint(canvas, Offset(x2AxisEnd.dx - tp.width / 2, x2AxisEnd.dy + 17));
    tp.text = TextSpan(text: 'Y', style: labelStyle);
    tp.layout();
    tp.paint(canvas, Offset(yAxisEnd.dx - tp.width - 7, yAxisEnd.dy - 3));
  }

  String _num(double v) {
    if (v.abs() < .0001) return '0';
    if ((v - v.roundToDouble()).abs() < .0001) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }

  @override
  bool shouldRepaint(covariant _MultipleRegressionPainter old) =>
      old.b0 != b0 || old.b1 != b1 || old.b2 != b2 || old.currentIndex != currentIndex ||
      old.prediction != prediction || old.x1 != x1 || old.x2 != x2 || old.y != y;
}
