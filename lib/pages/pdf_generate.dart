import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:date_format/date_format.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:restezchezvous/getit_setup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as im;

import '../utils.dart';

import 'package:pdf/widgets.dart' as pw;

enum Reason { travail, courses, sante, famille, sport, judiciaire, missions }

const String travail =
    "Déplacements entre le domicile et le lieu d’exercice de l’activité professionnelle, lorsqu’ils sont indispensables à l’exercice d’activités ne pouvant être organisées sous forme de télétravail ou déplacements professionnels ne pouvant être différés.";
const String courses =
    "Déplacements pour effectuer des achats de fournitures nécessaires à l’activité professionnelle et des achats de première nécessité dans des établissements dont les activités demeurent autorisées (liste sur gouvernement.fr).";
const String sante =
    "Consultations et soins ne pouvant être assurés à distance et ne pouvant être différés ; consultations et soins des patients atteints d'une affection de longue durée.";
const String famille =
    "Déplacements pour motif familial impérieux, pour l’assistance aux personnes vulnérables ou la garde d’enfants.";
const String sport =
    "Déplacements brefs, dans la limite d'une heure quotidienne et dans un rayon maximal d'un kilomètre autour du domicile, liés soit à l'activité physique individuelle des personnes, à l'exclusion de toute pratique sportive collective et de toute proximité avec d'autres personnes, soit à la promenade avec les seules personnes regroupées dans un même domicile, soit aux besoins des animaux de compagnie. ";
const String judiciaire = "Convocation judiciaire ou administrative.";
const String missions =
    "Participation à des missions d’intérêt général sur demande de l’autorité administrative.";

class PDFGeneratePage extends StatefulWidget {
  static const String route = '/pdfGeneration';

  @override
  _PDFGenerateState createState() {
    return new _PDFGenerateState();
  }
}

class _PDFGenerateState extends State<PDFGeneratePage> {
  SharedPreferences prefs = getIt.get<SharedPreferences>();
  Reason _reason = Reason.courses;

  @override
  void initState() {
    super.initState();
  }

  Future<void> copyBackgroundIfNeeded() async {
    Directory directory = await getApplicationDocumentsDirectory();
    var dbPath = join(directory.path, "attestation-000.png");
    if (FileSystemEntity.typeSync(dbPath) == FileSystemEntityType.notFound) {
      ByteData data = await rootBundle.load("assets/png/attestation-000.png");
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes);
    }
  }

  Future<List<int>> getAssetData(String path) async {
    ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<Uint8List> toQrImageData(String text) async {
    try {
      final image = await QrPainter(
        data: text,
        version: QrVersions.auto,
        gapless: true,
        color: Color(0xFF000000),
        emptyColor: Color(0xFFFFFFFF),
      ).toImage(512);
      final a = await image.toByteData(format: ImageByteFormat.png);
      return a.buffer.asUint8List();
    } catch (e) {
      throw e;
    }
  }

  Future<FileStat> getLastAttestationStat() async {
    final output = await getExternalStorageDirectory();
    String filePath = File("${output.path}/attestation.pdf").path;
    FileSystemEntityType file = FileSystemEntity.typeSync(filePath);
    if (file != FileSystemEntityType.notFound) {
      return FileStat.stat(filePath);
    }
    ;
    return null;
  }

  Future<void> generatePdfWithInfos() async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    final output = await getExternalStorageDirectory();

    final now = DateTime.now();

    final pdf = pw.Document();

    final dataBackground = await getAssetData("assets/png/attestation-000.png");
    final img = im.decodeImage(dataBackground);

    final image = PdfImage(
      pdf.document,
      image: img.data.buffer.asUint8List(),
      width: img.width,
      height: img.height,
    );

    final qrImage = await toQrImageData(generateStringForQRCode(
        prefs, now, _reason.toString().replaceAll("Reason.", "")));

    final fileqr = File("${directory.path}/qrcode.png");
    await fileqr.writeAsBytes(qrImage);

    final qrCode = PdfImage.file(pdf.document, bytes: fileqr.readAsBytesSync());

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat(
            21.0 * PdfPageFormat.cm, 29.7 * PdfPageFormat.cm,
            marginAll: 0.0),
        build: (pw.Context context) {
          return pw.Stack(fit: pw.StackFit.expand, children: [
            pw.Center(child: pw.Image(image)),
            pw.Container(
                margin: pw.EdgeInsets.only(
                    left: 44 * PdfPageFormat.mm, top: 51 * PdfPageFormat.mm),
                child: pw.Text(
                    prefs.get("firstName") + " " + prefs.get("lastName"))),
            pw.Container(
                margin: pw.EdgeInsets.only(
                    left: 44 * PdfPageFormat.mm, top: 59.5 * PdfPageFormat.mm),
                child: pw.Text(prefs.get("birthDate"))),
            pw.Container(
                margin: pw.EdgeInsets.only(
                    left: 34 * PdfPageFormat.mm, top: 68 * PdfPageFormat.mm),
                child: pw.Text(prefs.get("birthPlace"))),
            pw.Container(
                margin: pw.EdgeInsets.only(
                    left: 48 * PdfPageFormat.mm, top: 77 * PdfPageFormat.mm),
                child: pw.Text(
                    "${prefs.get("address")} ${prefs.get("postalCode")} ${prefs.get("city")}")),
            pw.Container(
                margin: pw.EdgeInsets.only(
                    left: 27 * PdfPageFormat.mm, top: 107 * PdfPageFormat.mm),
                child: pw.Text(_reason == Reason.travail ? "X" : "")),
            pw.Container(
                margin: pw.EdgeInsets.only(
                    left: 27 * PdfPageFormat.mm, top: 124.5 * PdfPageFormat.mm),
                child: pw.Text(_reason == Reason.courses ? "X" : "")),
            pw.Container(
                margin: pw.EdgeInsets.only(
                    left: 27 * PdfPageFormat.mm, top: 139 * PdfPageFormat.mm),
                child: pw.Text(_reason == Reason.sante ? "X" : "")),
            pw.Container(
                margin: pw.EdgeInsets.only(
                    left: 27 * PdfPageFormat.mm, top: 152 * PdfPageFormat.mm),
                child: pw.Text(_reason == Reason.famille ? "X" : "")),
            pw.Container(
                margin: pw.EdgeInsets.only(
                    left: 27 * PdfPageFormat.mm, top: 171.5 * PdfPageFormat.mm),
                child: pw.Text(_reason == Reason.sport ? "X" : "")),
            pw.Container(
                margin: pw.EdgeInsets.only(
                    left: 27 * PdfPageFormat.mm, top: 188 * PdfPageFormat.mm),
                child: pw.Text(_reason == Reason.judiciaire ? "X" : "")),
            pw.Container(
                margin: pw.EdgeInsets.only(
                    left: 27 * PdfPageFormat.mm, top: 201 * PdfPageFormat.mm),
                child: pw.Text(_reason == Reason.missions ? "X" : "")),
            pw.Container(
                margin: pw.EdgeInsets.only(
                    left: 39 * PdfPageFormat.mm, top: 213.5 * PdfPageFormat.mm),
                child: pw.Text(prefs.get("city"))),
            pw.Container(
                margin: pw.EdgeInsets.only(
                    left: 33 * PdfPageFormat.mm, top: 222 * PdfPageFormat.mm),
                child: pw.Text(formatDate(now, [dd, '/', mm, '/', yyyy]))),
            pw.Container(
                margin: pw.EdgeInsets.only(
                    left: 70 * PdfPageFormat.mm, top: 222 * PdfPageFormat.mm),
                child: pw.Text(formatDate(now, [HH, '    ', nn]))),
            pw.Container(
                margin: pw.EdgeInsets.only(
                    left: 150 * PdfPageFormat.mm,
                    top: 150 * PdfPageFormat.mm,
                    right: 25 * PdfPageFormat.mm,
                    bottom: 53 * PdfPageFormat.mm),
                child: pw.Image(qrCode)),
            pw.Container(
                margin: pw.EdgeInsets.only(
                    right: 26 * PdfPageFormat.mm, top: 244 * PdfPageFormat.mm),
                child: pw.Text(
                    "Date de création:\n" +
                        formatDate(now,
                            [dd, '/', mm, '/', yyyy, ' ä ', HH, '\\h', nn]),
                    textAlign: pw.TextAlign.right,
                    textScaleFactor: 0.5)),
          ]);
        }));

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat(
            21.0 * PdfPageFormat.cm, 29.7 * PdfPageFormat.cm,
            marginAll: 0.0),
        build: (pw.Context context) {
          return pw.Stack(fit: pw.StackFit.expand, children: [
            pw.Center(
                child: pw.Container(
                    margin: pw.EdgeInsets.only(
                        left: 10 * PdfPageFormat.mm,
                        top: 10 * PdfPageFormat.mm,
                        right: 10 * PdfPageFormat.mm),
                    child: pw.Image(qrCode)))
          ]);
        }));

    final file = File("${output.path}/attestation.pdf");
    await file.writeAsBytes(pdf.save());

    OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
            title: Center(
          child: new Text('Bonjour, ' + prefs.get("firstName")),
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: generatePdfWithInfos,
          tooltip: 'generate pdf',
          child: const Icon(Icons.sentiment_satisfied),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder(
                    future: getLastAttestationStat(),
                    builder: (_, snapshot) {
                      return snapshot.hasData
                          ? ReloadAttestation(fileStat: snapshot.data as FileStat)
                          : Container();
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    RadioListTile<Reason>(
                      title: const Text(travail),
                      value: Reason.travail,
                      groupValue: _reason,
                      onChanged: (Reason value) {
                        setState(() {
                          _reason = value;
                        });
                      },
                    ),
                    RadioListTile<Reason>(
                      title: const Text(courses),
                      value: Reason.courses,
                      groupValue: _reason,
                      onChanged: (Reason value) {
                        setState(() {
                          _reason = value;
                        });
                      },
                    ),
                    RadioListTile<Reason>(
                      title: const Text(sante),
                      value: Reason.sante,
                      groupValue: _reason,
                      onChanged: (Reason value) {
                        setState(() {
                          _reason = value;
                        });
                      },
                    ),
                    RadioListTile<Reason>(
                      title: const Text(famille),
                      value: Reason.famille,
                      groupValue: _reason,
                      onChanged: (Reason value) {
                        setState(() {
                          _reason = value;
                        });
                      },
                    ),
                    RadioListTile<Reason>(
                      title: const Text(sport),
                      value: Reason.sport,
                      groupValue: _reason,
                      onChanged: (Reason value) {
                        setState(() {
                          _reason = value;
                        });
                      },
                    ),
                    RadioListTile<Reason>(
                      title: const Text(judiciaire),
                      value: Reason.judiciaire,
                      groupValue: _reason,
                      onChanged: (Reason value) {
                        setState(() {
                          _reason = value;
                        });
                      },
                    ),
                    RadioListTile<Reason>(
                      title: const Text(missions),
                      value: Reason.missions,
                      groupValue: _reason,
                      onChanged: (Reason value) {
                        setState(() {
                          _reason = value;
                        });
                      },
                    ),
                  ],
                ),
              )
            ]),
          ),
        ));
  }
}

class ReloadAttestation extends StatelessWidget {
  final FileStat fileStat;

  const ReloadAttestation({
    Key key,
    this.fileStat,
  }) : super(key: key);

  Future<void> openLastPdf() async {
    final output = await getExternalStorageDirectory();
    final file = File("${output.path}/attestation.pdf");
    OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'La dernière attestation a été générée le ${formatDate(fileStat.modified, [
              dd,
              '/',
              mm,
              '/',
              yyyy,
              ' à ',
              HH,
              '\\h',
              nn
            ])}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(30.0),
              color: Theme.of(context).accentColor,
              child: MaterialButton(
                padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                onPressed: () {
                  openLastPdf();
                },
                child: Text("Afficher la dernière autorisation",style:  TextStyle(color: Colors.white),
                    textAlign: TextAlign.center),
              )),
        ),
      ],
    );
  }
}
