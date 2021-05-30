import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stream/core/providers/encoding_provider.dart';
import 'package:flutter_stream/core/providers/firebase_provider.dart';
import 'package:flutter_stream/core/utils/user_preferences.dart';
import 'package:flutter_stream/model/asset_data.dart';
import 'package:flutter_stream/model/video_info.dart';
import 'package:flutter_stream/res/custom_colors.dart';
import 'package:flutter_stream/utils/mux_client.dart';
import 'package:flutter_stream/widgets/player.dart';
import 'package:flutter_stream/widgets/video_tile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../res/string.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MUXClient _muxClient = MUXClient();

  TextEditingController _textControllerVideoURL;
  FocusNode _textFocusNodeVideoURL;
  bool isProcessing = false;

  final UserPreferences prefs = UserPreferences();

  //
  final thumbWidth = 100;
  final thumbHeight = 150;
  List<VideoInfo> _videos = <VideoInfo>[];
  bool _imagePickerActive = false;
  bool _processing = false;
  bool _canceled = false;
  double _progress = 0.0;
  int _videoDuration = 0;
  String _processPhase = '';
  final bool _debugMode = false;
  //

  @override
  void initState() {
    super.initState();
    _muxClient.initializeDio();
    _textControllerVideoURL = TextEditingController(text: demoVideoUrl);
    _textFocusNodeVideoURL = FocusNode();

    FirebaseProvider.listenToVideos((newVideos) {
      setState(() {
        _videos = newVideos;
      });
    });
    // Start other method *FFmpeg
    /*EncodingProvider.enableStatisticsCallback((int time,
        int size,
        double bitrate,
        double speed,
        int videoFrameNumber,
        double videoQuality,
        double videoFps) {
      if (_canceled) return;

      setState(() {
        _progress = time / _videoDuration;
      });
    });*/
  }

  Future<String> _uploadFile(filePath, folderName) async {
    final file = new File(filePath);
    final basename = p.basename(filePath);

    final Reference ref =
    FirebaseStorage.instance.ref().child(folderName).child(basename);
    UploadTask uploadTask = ref.putFile(file);
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      print('Snapshot state: ${snapshot.state}'); // paused, running, complete
      print('Progress: ${snapshot.totalBytes / snapshot.bytesTransferred}');
    }, onError: (Object e) {
      print(e); // FirebaseException
    });

// Optional
    uploadTask
        .then((TaskSnapshot snapshot) {
      print('Upload complete!');
    })
        .catchError((Object e) {
      print(e); // FirebaseException
    });
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => print("complete"));
    String videoUrl = await taskSnapshot.ref.getDownloadURL();
    return videoUrl;
  }

  void _onUploadProgress(event) {
    TaskSnapshot snapshot;
    if (event.type == snapshot.state) {
      final double progress =
          event.snapshot.bytesTransferred / event.snapshot.totalByteCount;
      setState(() {
        _progress = progress;
      });
    }
  }

  void _updatePlaylistUrls(File file, String videoName) {
    final lines = file.readAsLinesSync();
    var updatedLines = List<String>();

    for (final String line in lines) {
      var updatedLine = line;
      if (line.contains('.ts') || line.contains('.m3u8')) {
        updatedLine = '$videoName%2F$line?alt=media';
      }
      updatedLines.add(updatedLine);
    }
    final updatedContents = updatedLines.reduce((value, element) => value + '\n' + element);

    file.writeAsStringSync(updatedContents);
  }

  Future<String> _uploadHLSFiles(dirPath, videoName) async {

    final videosDir = Directory(dirPath);

    var playlistUrl = '';

    final files = videosDir.listSync();
    int i = 1;
    for (FileSystemEntity file in files) {
      final fileName = p.basename(file.path);
      final fileExtension = getFileExtension(fileName);
      if (fileExtension == 'm3u8') _updatePlaylistUrls(file, videoName);

      setState(() {
        _processPhase = 'Uploading video file $i out of ${files.length}';
        _progress = 0.0;
      });

      final downloadUrl = await _uploadFile(file.path, videoName);

      if (fileName == 'master.m3u8') {
        playlistUrl = downloadUrl;
      }
      i++;
    }

    return playlistUrl;
  }

  Future<void> _processVideo(PickedFile rawVideoFile) async {
    final String rand = '${new Random().nextInt(10000)}';
    final videoName = 'video$rand';
    final Directory extDir = await getApplicationDocumentsDirectory();
    final outDirPath = '${extDir.path}/Videos/$videoName';
    final videosDir = new Directory(outDirPath);
    videosDir.createSync(recursive: true);

    final rawVideoPath = rawVideoFile.path;
    final info = await EncodingProvider.getMediaInformation(rawVideoPath);
    //final aspectRatio = EncodingProvider.getAspectRatio(info);

    setState(() {
      _processPhase = 'Generating thumbnail';
      //_videoDuration = EncodingProvider.getDuration(info);
      _progress = 0.0;
    });

    final thumbFilePath =
    await EncodingProvider.getThumb(rawVideoPath, thumbWidth, thumbHeight);

    setState(() {
      _processPhase = 'Encoding video';
      _progress = 0.0;
    });

    final encodedFilesDir =
    await EncodingProvider.encodeHLS(rawVideoPath, outDirPath);

    setState(() {
      _processPhase = 'Uploading thumbnail to firebase storage';
      _progress = 0.0;
    });
    final thumbUrl = await _uploadFile(thumbFilePath, 'thumbnail');
    final videoUrl = await _uploadHLSFiles(encodedFilesDir, videoName);

    final videoInfo = VideoInfo(
      videoUrl: videoUrl,
      thumbUrl: thumbUrl,
      coverUrl: thumbUrl,
      aspectRatio: 1.78,
      uploadedAt: DateTime.now().millisecondsSinceEpoch,
      videoName: videoName,
    );

    setState(() {
      _processPhase = 'Saving video metadata to cloud firestore';
      _progress = 0.0;
    });

    await FirebaseProvider.saveVideo(videoInfo);

    setState(() {
      _processPhase = '';
      _progress = 0.0;
      _processing = false;
    });
  }

  String getFileExtension(String fileName) {
    final exploded = fileName.split('.');
    return exploded[exploded.length - 1];
  }

  _getProgressBar() {
    return Container(
      padding: EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 30.0),
            child: Text("En proceso . . ."),
          ),
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: CustomColors.muxPink,
          ),
        ],
      ),
    );
  }

  void _takeVideo() async {
    PickedFile videoFile;
    File file;
    if (_debugMode) {
      file = File(
          '/storage/emulated/0/Android/data/com.learningsomethingnew.fluttervideo.flutter_video_sharing/files/Pictures/ebbafabc-dcbe-433b-93dd-80e7777ee4704451355941378265171.mp4');
    } else {
      if (_imagePickerActive) return;

      _imagePickerActive = true;
      videoFile = await ImagePicker().getVideo(source: ImageSource.gallery);
      _imagePickerActive = false;

      if (videoFile == null) return;
    }
    setState(() {
      _processing = true;
    });

    try {
      await _processVideo(videoFile);
    } catch (e) {
      print('${e.toString()}');
    } finally {
      setState(() {
        _processing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _textFocusNodeVideoURL.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          brightness: Brightness.dark,
          title: Text('Project Streaming'),
          backgroundColor: CustomColors.muxPink,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {});
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  prefs.userPhotoUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        body: Center(child: _processing ? _getProgressBar() : _getListView()),
        floatingActionButton: FloatingActionButton(
            backgroundColor: CustomColors.muxPink,
            child: _processing
                ? CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
            )
                : Icon(Icons.add),
            onPressed: _takeVideo
        ),
      ),
    );
  }

  _interfaceMux(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          color: CustomColors.muxPink.withOpacity(0.06),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              bottom: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SUBIR',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 22.0,
                  ),
                ),
                TextField(
                  focusNode: _textFocusNodeVideoURL,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(
                    color: CustomColors.muxGray,
                    fontSize: 16.0,
                    letterSpacing: 1.5,
                  ),
                  controller: _textControllerVideoURL,
                  cursorColor: CustomColors.muxPinkLight,
                  autofocus: false,
                  onSubmitted: (value) {
                    _textFocusNodeVideoURL.unfocus();
                  },
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: CustomColors.muxPink,
                        width: 2,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black26,
                        width: 2,
                      ),
                    ),
                    labelText: 'Video URL',
                    labelStyle: TextStyle(
                      color: Colors.black26,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    hintText: 'Ingresa la URL del video a SUBIR',
                    hintStyle: TextStyle(
                      color: Colors.black12,
                      fontSize: 12.0,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                isProcessing
                    ? Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'En proceso . . .',
                        style: TextStyle(
                          color: CustomColors.muxPink,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                        ),
                      ),
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          CustomColors.muxPink,
                        ),
                        strokeWidth: 2,
                      )
                    ],
                  ),
                )
                    : Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Container(
                    width: double.maxFinite,
                    child: RaisedButton(
                      color: CustomColors.muxPink,
                      onPressed: () async {
                        setState(() {
                          isProcessing = true;
                        });
                        await _muxClient.storeVideo(
                            videoUrl: _textControllerVideoURL.text);
                        setState(() {
                          isProcessing = false;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 12.0,
                          bottom: 12.0,
                        ),
                        child: Text(
                          'enviar',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<AssetData>(
            future: _muxClient.getAssetList(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                AssetData assetData = snapshot.data;
                int length = assetData.data.length;

                return ListView.separated(
                  physics: BouncingScrollPhysics(),
                  itemCount: length,
                  itemBuilder: (context, index) {
                    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                        int.parse(assetData.data[index].createdAt) * 1000);
                    DateFormat formatter = DateFormat.yMd().add_jm();
                    String dateTimeString = formatter.format(dateTime);

                    String currentStatus = assetData.data[index].status;
                    bool isReady = currentStatus == 'ready';

                    String playbackId = isReady
                        ? assetData.data[index].playbackIds[0].id
                        : null;

                    String thumbnailURL = isReady
                        ? '$muxImageBaseUrl/$playbackId/$imageTypeSize'
                        : null;

                    return VideoTile(
                      assetData: assetData.data[index],
                      thumbnailUrl: thumbnailURL,
                      isReady: isReady,
                      dateTimeString: dateTimeString,
                    );
                  },
                  separatorBuilder: (_, __) => SizedBox(
                    height: 16.0,
                  ),
                );
              }
              return Container(
                child: Text(
                  'Sin videos cargados',
                  style: TextStyle(
                    color: Colors.black45,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  _getListView() {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _videos.length,
        itemBuilder: (BuildContext context, int index) {
          final video = _videos[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Player(
                      video: video,
                    );
                  },
                ),
              );
            },
            child: Card(
              child: new Container(
                padding: new EdgeInsets.all(10.0),
                child: Stack(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: new BorderRadius.circular(8.0),
                              child: FadeInImage.assetNetwork(
                                height: 150,
                                width: 150,
                                placeholder: 'assets/icon/icon.png',
                                image: video.thumbUrl,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Container(
                            margin: new EdgeInsets.only(left: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Text("${video.videoName}"),
                                Container(
                                  margin: new EdgeInsets.only(top: 12.0),
                                  child: Text(
                                      'Uploaded ${timeago.format(new DateTime.fromMillisecondsSinceEpoch(video.uploadedAt))}'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
