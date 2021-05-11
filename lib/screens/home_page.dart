import 'package:flutter/material.dart';
import 'package:flutter_stream/core/utils/user_preferences.dart';
import 'package:flutter_stream/model/asset_data.dart';
import 'package:flutter_stream/res/custom_colors.dart';
import 'package:flutter_stream/utils/mux_client.dart';
import 'package:flutter_stream/widgets/video_tile.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _muxClient.initializeDio();
    _textControllerVideoURL = TextEditingController(text: demoVideoUrl);
    _textFocusNodeVideoURL = FocusNode();
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
        body: Column(
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
        ),
      ),
    );
  }
}
