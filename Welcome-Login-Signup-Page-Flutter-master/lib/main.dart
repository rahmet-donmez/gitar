/*import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:pitchupdart/instrument_type.dart';
import 'package:pitchupdart/pitch_handler.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gitar Akort',
      theme:
          ThemeData(primaryColor: Colors.brown, backgroundColor: Colors.black),
      home: const MyHomePage(title: 'Gitar Akort'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double value1 = 50;
  final _audioRecorder =
      FlutterAudioCapture(); // Bu kütüphane, bir ses örneği yakalamak için cihazın mikrofonunu kullanmamızı sağlar.
  final pitchDetectorDart = PitchDetector(44100, 2000);
  final pitchupDart = PitchHandler(InstrumentType.guitar);

  var note = "";
  var status = "Başlamak için 'Dinle' butonuna tıklayınız";
  var durum = "";
  bool start = false;
  Widget f_icon = Icon(Icons.start);

  Future<void> _startCapture() async {
    await _audioRecorder.start(listener, onError,
        sampleRate: 44100, bufferSize: 3000);

    setState(() {
      note = "";
      status = "Dinleme işlemi gerçekleşiyor..";
    });
  }

  Future<void> _stopCapture() async {
    await _audioRecorder.stop();

    setState(() {
      value1 = 50;
      durum = "";
      note = "";
      status = "Başlamak için 'Dinle' butonuna tıklayınız";
    });
  }

  void listener(dynamic obj) {
    //Gets the audio sample
    var buffer = Float64List.fromList(obj.cast<double>());

    final List<double> audioSample = buffer.toList();

    //Uses pitch_detector_dart library to detect a pitch from the audio sample
    final result = pitchDetectorDart.getPitch(audioSample);

    //audioSample değerini kullanarak pitch_detector_dart kitaplığını kullanarak bir ses tonu bulup bulamayacağımızı kontrol eder
    /* getPitch işlevinin sonucu şunları içerecektir:

pitch: Varsa ses örneğinden çıkarılan perde
probability:: Bulunan perdenin olasılığı
pitched: Verilen örnekte bir perdenin tanımlanıp tanımlanmadığını gösteren bayrak*/

    /*Perde bir notayla eşleşmese bile, perdenin belirli bir notaya ne kadar yakın olduğuna dair 
    göstergeler vererek kullanıcının enstrümanı ayarlamasına yardımcı olabiliriz. 
    Örnek: Çok düşük veya çok yüksek.*/

    //If there is a pitch - evaluate it
    if (result.pitched) {
      //Varsa ses örneğinden çıkarılan perde
      //Uses the pitchupDart library to check a given pitch for a Guitar

      final handledPitchResult = pitchupDart.handlePitch(result.pitch);

      //Updates the state with the result
      setState(() {
        note = handledPitchResult.note;
        status = handledPitchResult.tuningStatus.toString();
        switch (status) {
          case "TuningStatus.tuned":
            value1 = 50;
            durum = "Ayarlanmış";
            status = "$note başarı ile ayarlandı";
            break;
          case "TuningStatus.toolow":
            value1 = 40;
            durum = "Düşük";
            status = "'+' yönünde hareket ettiriniz";
            break;
          case "TuningStatus.toohigh":
            value1 = 70;
            durum = "Yüksek";
            status = "'-' yönünde hareket ettiriniz";
            break;
          case "TuningStatus.waytoolow":
            value1 = 20;
            durum = "Çok düşük";
            status = "'+' yönünde hareket ettiriniz";
            break;
          case "TuningStatus.waytoohigh":
            value1 = 90;
            durum = "Çok yüksek";
            status = "'-' yönünde hareket ettiriniz";
            break;
          case "TuningStatus.undefined ":
            value1 = 0;
            durum = "Tanımsız";
            break;
          default:
            durum = "Ses algılanamadı";
            break;
        }
      });
    }
  }

  void onError(Object e) {
    print(e);
  }

  floatButtonOnclick() {
    if (start == true) {
      _stopCapture();
      start = false;
    } else {
      _startCapture();
      start = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),

      //  floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            floatButtonOnclick();
          },
          child: f_icon),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/gitar.png"),
            fit: BoxFit.fitWidth,
          ),
        ),
        child: Column(children: [
          const SizedBox(
            height: 5,
          ),
          Center(
              child: Text(
            status,
            style: const TextStyle(
                color: Colors.brown,
                fontSize: 16.0,
                fontWeight: FontWeight.bold),
          )),
          /*SleekCircularSlider(
              innerWidget: (percentage) {
                return Center(child: Text(durum));
              },
              initialValue: value1,
              appearance: const CircularSliderAppearance(
                  size: 130, // Added this
                  startAngle: 100,
                  animationEnabled: true)),*/

          /*Container (
            decoration: BoxDecoration(
              borderRadius: BorderRadiusDirectional.circular(10),
              border: Border.all(color: Colors.deepPurple),
              color: Colors.white
            ),
            margin: EdgeInsets.only(top: 25),
            padding:EdgeInsets.all(10),
            
            child: SleekCircularSlider(
              innerWidget: (percentage) {
                return Center(child: Text(durum));
              },
              initialValue: value1,
              appearance: CircularSliderAppearance(
  size: 130, // Added this
  startAngle: 100,
  animationEnabled:true)
                     )

          ),
            )
*/
          Center(
              child: Text(
            note,
            style: const TextStyle(
                color: Colors.grey,
                fontSize: 25.0,
                fontWeight: FontWeight.bold),
          )),
          const Spacer(),
          Expanded(
              child: Column(children: [
            Row(
              children: [
                Expanded(
                    child: Center(
                        child: FloatingActionButton(
                            onPressed: _startCapture,
                            child: const Text("Dinle")))),
                Container(
                  decoration: BoxDecoration(color: Colors.black),
                  height:MediaQuery.of(context).size.height*0.2,
                  width: MediaQuery.of(context).size.width*0.2,

                ),
                Expanded(
                    child: Center(
                        child: FloatingActionButton(
                            onPressed: _stopCapture,
                            child: const Text("Dur")))),
              ],
            ),
            const Spacer(),
             Row(
              children: [
                Expanded(
                    child: Center(
                        child: FloatingActionButton(
                            onPressed: _startCapture,
                            child: const Text("Dinle")))),
                Expanded(
                    child: Center(
                        child: FloatingActionButton(
                            onPressed: _stopCapture,
                            child: const Text("Dur")))),
              ],
            ),
            const Spacer(),
             Row(
              children: [
                Expanded(
                    child: Center(
                        child: FloatingActionButton(
                            onPressed: _startCapture,
                            child: const Text("Dinle")))),
                Expanded(
                    child: Center(
                        child: FloatingActionButton(
                            onPressed: _stopCapture,
                            child: const Text("Dur")))),
              ],
            )
          ]))
          /* Expanded(
              child: Row(
            children: [
              Expanded(
                  child: Center(
                      child: FloatingActionButton(
                          onPressed: _startCapture,
                          child: const Text("Dinle")))),
              Expanded(
                  child: Center(
                      child: FloatingActionButton(
                          onPressed: _stopCapture, child: const Text("Dur")))),
            ],
          ))*/
        ]),
      ),
    );
  }
}
*/

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:pitchupdart/instrument_type.dart';
import 'package:pitchupdart/pitch_handler.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gitar Akort',
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'Gitar Akort'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _audioRecorder =
      FlutterAudioCapture(); // Bu kütüphane, bir ses örneği yakalamak için cihazın mikrofonunu kullanmamızı sağlar.
  final pitchDetectorDart = PitchDetector(44100, 2000);
  final pitchupDart = PitchHandler(InstrumentType.guitar);

  var note = "";
  var status = "Başlamak için 'Dinle' butonuna tıklayınız";
  var sliderStatus = "";
  var butonText = "Başla";
  bool start = false;
  double value = 50;

  Future<void> _startCapture() async {
    await _audioRecorder.start(listener, onError,
        sampleRate: 44100, bufferSize: 3000);

    setState(() {
      note = "";
      status = "Dinleme işlemi gerçekleşiyor..";
      butonText = "Dur";
    });
  }

  Future<void> _stopCapture() async {
    await _audioRecorder.stop();

    setState(() {
      value = 50;
      sliderStatus = "";
      note = "";
      status = "Başlamak için 'Dinle' butonuna tıklayınız";
      butonText = "Başla";
    });
  }

  void listener(dynamic obj) {
    //Gets the audio sample
    var buffer = Float64List.fromList(obj.cast<double>());

    final List<double> audioSample = buffer.toList();

    //Uses pitch_detector_dart library to detect a pitch from the audio sample
    final result = pitchDetectorDart.getPitch(audioSample);

    //audioSample değerini kullanarak pitch_detector_dart kitaplığını kullanarak bir ses tonu bulup bulamayacağımızı kontrol eder
    /* getPitch işlevinin sonucu şunları içerecektir:

pitch: Varsa ses örneğinden çıkarılan perde
probability:: Bulunan perdenin olasılığı
pitched: Verilen örnekte bir perdenin tanımlanıp tanımlanmadığını gösteren bayrak*/

    /*Perde bir notayla eşleşmese bile, perdenin belirli bir notaya ne kadar yakın olduğuna dair 
    göstergeler vererek kullanıcının enstrümanı ayarlamasına yardımcı olabiliriz. 
    Örnek: Çok düşük veya çok yüksek.*/

    //If there is a pitch - evaluate it
    if (result.pitched) {
      //Varsa ses örneğinden çıkarılan perde
      //Uses the pitchupDart library to check a given pitch for a Guitar

      final handledPitchResult = pitchupDart.handlePitch(result.pitch);

      //Updates the state with the result
      setState(() {
        note = handledPitchResult.note;
        status = handledPitchResult.tuningStatus.toString();
        switch (status) {
          case "TuningStatus.tuned":
            value = 50;
            sliderStatus = "Ayarlanmış";
            status = "$note başarı ile ayarlandı";
            break;
          case "TuningStatus.toolow":
            value = 40;
            sliderStatus = "Düşük";
            status = "'+' yönünde hareket ettiriniz";
            break;
          case "TuningStatus.toohigh":
            value = 70;
            sliderStatus = "Yüksek";
            status = "'-' yönünde hareket ettiriniz";
            break;
          case "TuningStatus.waytoolow":
            value = 20;
            sliderStatus = "Çok düşük";
            status = "'+' yönünde hareket ettiriniz";
            break;
          case "TuningStatus.waytoohigh":
            value = 90;
            sliderStatus = "Çok yüksek";
            status = "'-' yönünde hareket ettiriniz";
            break;
          case "TuningStatus.undefined ":
            value = 0;
            sliderStatus = "Tanımsız";
            break;
          default:
            sliderStatus = "Ses algılanamadı";
            break;
        }
      });
    }
  }

  void onError(Object e) {
    print(e);
  }

  floatButtonOnclick() {
    if (start == true) {
      _stopCapture();
      start = false;
    } else {
      _startCapture();
      start = true;
    }
  }

  @override
  initState() {
    // TODO: implement initState
    permission();

    super.initState();
  }

  permission() async {
    await Permission.microphone.request();
    if (Permission.microphone.isDenied == true) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Icon(
          Icons.queue_music,
          size: 45,
        )),
      ),

      //  floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 240, 86, 232),
          onPressed: () {
            if (start == true) {
              _stopCapture();
              start = false;
            } else {
              _startCapture();
              start = true;
            }
          },
          child: Text(butonText)),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/gitar.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(children: [
          const SizedBox(
            height: 5,
          ),
          Center(
              child: Text(
            status,
            style: const TextStyle(
                color: Color.fromARGB(255, 240, 86, 232),
                fontSize: 16.0,
                fontWeight: FontWeight.bold),
          )),
          const SizedBox(
            height: 5,
          ),
          SleekCircularSlider(
            initialValue: value,
            appearance: CircularSliderAppearance(animationEnabled: true),
            innerWidget: (percentage) {
              if (sliderStatus == "Ayarlanmış") {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline_sharp,
                      color: Colors.green,
                    ),
                    Text(
                      sliderStatus,
                      style:
                          TextStyle(color: Color.fromARGB(255, 240, 86, 232)),
                    ),
                  ],
                ));
              } else {
                return Center(
                  child: Text(
                    sliderStatus,
                    style: TextStyle(color: Color.fromARGB(255, 240, 86, 232)),
                  ),
                );
              }
            },
          ),
          Center(
              child: Text(
            note,
            style: const TextStyle(
                color: Colors.grey,
                fontSize: 25.0,
                fontWeight: FontWeight.bold),
          )),
        ]),
      ),
    );
  }
}
