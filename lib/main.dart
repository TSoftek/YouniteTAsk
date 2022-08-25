import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
// Please review the iOS Technical Tasks for your reference.
// Please revert in same email within 2 days.
//
//
//
// Task1: Your task is to concurrently download three random images from Google and show
//
// their respective download progress bars on the screen. (Multithreading)
//
// Task2: You are required to send the images by creating a TCP connection to the other
//
// phone by providing IPV4 address and port in real time (No Server is required) and show
//
// those images on the other phone.
//
// Upload your task on Git Repository and share the repository link.
void main() {
  runApp(
    GetMaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
    )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}
enum downloadedtype{initial,download,completed,share}
class _MyAppState extends State<MyApp> {
  bool downloading = false;
  String progress = '0';
  downloadedtype dtype=downloadedtype.initial;
  bool isDownloaded = false;
  @override
  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height:height*0.1,),
            Expanded(
              flex: 8,
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20),
                  padding: EdgeInsets.all(10),
                  itemCount: 3,
                  itemBuilder: (BuildContext ctx, index) {
                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(index==0?
                          "https://previews.agefotostock.com/previewimage/medibigoff/10824b80b5baf96fdf30b672a6afaf47/esy-044847265.jpg":index==1?
                          "https://thumbs.dreamstime.com/b/landscape-alpine-mountains-nature-switzerland-nice-scenery-alps-misty-peaks-summer-beautiful-forest-low-clouds-188622668.jpg":
                          "https://previews.agefotostock.com/previewimage/medibigoff/5c7118fa4d4bb4434afe2c9e61d05537/esy-023154270.jpg")
                        ),
                          borderRadius: BorderRadius.circular(15)),
                    );
                  }),
            ),
            Spacer(),
            dtype==downloadedtype.initial?
            ElevatedButton(
              onPressed: () async {
                dtype=downloadedtype.download;
                setState(() {});
                await downloadFile("https://previews.agefotostock.com/previewimage/medibigoff/10824b80b5baf96fdf30b672a6afaf47/esy-044847265.jpg", "image1.jpg", context);
             await  downloadFile("https://thumbs.dreamstime.com/b/landscape-alpine-mountains-nature-switzerland-nice-scenery-alps-misty-peaks-summer-beautiful-forest-low-clouds-188622668.jpg", "image2.jpg", context);
              await  downloadFile("https://previews.agefotostock.com/previewimage/medibigoff/5c7118fa4d4bb4434afe2c9e61d05537/esy-023154270.jpg", "image3.jpg", context);
              dtype=downloadedtype.completed;
                setState(() {});
              }
              ,child: Text("Download",style: TextStyle(
              color: Colors.white
            )),
            )
                : dtype==downloadedtype.download?
                CircularProgressIndicator(color: Colors.blue,):
                ElevatedButton(onPressed: ()async{
                  var file1=await getFilePath("image1.jpg");
                  var file2=await getFilePath("image2.jpg");
                  var file3=await getFilePath("image3.jpg");
                  Share.shareFiles([file1,file2,file3]);}, child: Text("share"))
            ,
            Spacer(),
          ],
        ),
      ),
    );
  }

  Future<void> downloadFile(uri, fileName,context) async {
    downloading = true;

    String savePath = await getFilePath(fileName);
    Dio dio = Dio();
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(max: 100, msg: 'File Downloading...',msgColor:Colors.black,progressValueColor: Colors.black);

    dio.download(
      uri,
      savePath,
      onReceiveProgress: (rcv, total) {
        print(
            'received: ${rcv.toStringAsFixed(0)} out of total: ${total.toStringAsFixed(0)}');
        progress = ((rcv / total) * 100).toStringAsFixed(0);
        var progre = ((rcv / total) * 100).toInt();
        setState(() {});
        pd.update(value: progre);
        if (progre == 100) {
          pd.close();
          isDownloaded = true;
        } else if (double.parse(progress) < 100) {}
      },
      deleteOnError: true,
    ).then((_) {
      if (progress == '100') {
        isDownloaded = true;
      }
      downloading = false;
      setState(() {});

    });
  }

  Future<String> getFilePath(uniqueFileName) async {
    String path = '';

    Directory? dir = await getExternalStorageDirectory();

    path = '${dir!.path}/$uniqueFileName';
    return path;
  }
}

