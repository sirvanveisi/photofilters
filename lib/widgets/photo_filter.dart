import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imagelib;
import 'package:path_provider/path_provider.dart';
import 'package:photofilters/filters/filters.dart';
import 'package:photofilters/utils/colors.dart';
import 'package:photofilters/utils/edge.dart';
import 'package:photofilters/utils/font_Style.dart';
import 'package:photofilters/widgets/custom_button.dart';

class PhotoFilter extends StatelessWidget {
  final imagelib.Image image;
  final String filename;
  final Filter filter;
  final BoxFit fit;
  final Widget loader;

  const PhotoFilter({
    super.key,
    required this.image,
    required this.filename,
    required this.filter,
    this.fit = BoxFit.cover,
    this.loader = const Center(child: CircularProgressIndicator()),
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: compute(applyFilter, <String, dynamic>{
        "filter": filter,
        "image": image,
        "filename": filename,
      }),
      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return loader;
          case ConnectionState.active:
          case ConnectionState.waiting:
            return loader;
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            return Image.memory(
              snapshot.data as dynamic,
              fit: fit,
            );
        }
      },
    );
  }
}

///The PhotoFilterSelector Widget for apply filter from a selected set of filters
class PhotoFilterSelector extends StatefulWidget {
  final Widget title;
  final Color appBarColor;
  final List<Filter> filters;
  final imagelib.Image image;
  final Widget loader;
  final BoxFit fit;
  final String filename;
  final bool circleShape;

  const PhotoFilterSelector({
    Key? key,
    required this.title,
    required this.filters,
    required this.image,
    this.appBarColor = Colors.blue,
    this.loader = const Center(child: CircularProgressIndicator()),
    this.fit = BoxFit.cover,
    required this.filename,
    this.circleShape = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => PhotoFilterSelectorState();
}

class PhotoFilterSelectorState extends State<PhotoFilterSelector>
    with TickerProviderStateMixin {
  String? filename;
  Map<String, List<int>?> cachedFilters = {};
  Filter? filter;
  imagelib.Image? image;
  late bool loading;
  static const Color thickBlue = Color(0xFF525FE1);
  static const Color dark = Color(0xFF212529);
  late TabController _tabController;
  static const Color drWhite500 = Color(0xFFF7F7F8);
  bool filterWidget = true;
  bool sliderWidget = false;
  double _brightnessValue = 1.0; // Initial brightness value
  imagelib.Image? _originalImage; // Variable to store the original image

  @override
  void initState() {
    super.initState();
    loading = false;
    filter = widget.filters[0];
    filename = widget.filename;
    image = widget.image;
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  List tabs = [
    [0],
    [1]
  ];

  @override
  void dispose() {
    super.dispose();
  }

  int _currentIndex = 0;
  double _currentSliderValue = 1;
  var imageData;
  File? imageFile;
  imagelib.Image? modifiedImageRelease;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: true,

              backgroundColor: Colors.white,
              title: Text(
                'ویرایش تصویر',
                style: TextStyle(
                    fontFamily: "Yekan",
                    color: dark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              actions: [
                CupertinoButton(
                  child: Text('ادامه',
                      style: TextStyle(
                          fontFamily: "Yekan",
                          color: thickBlue,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          decorationColor: thickBlue,
                          decorationStyle: TextDecorationStyle.solid,
                          fontWeight: FontWeight.w500)),
                  onPressed: () async {
                    setState(() {
                      loading = true;
                    });
                    imageFile = await saveFilteredImage();

                    // ignore: use_build_context_synchronously
                    Navigator.pop(context, {'image_filtered': imageFile});
                  },
                )
              ],
            ),
            bottomNavigationBar: sliderWidget
                ? SizedBox()
                : Container(
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(48),
                        border: Border.all(color: drWhite500)),
                    child: TabBar(
                        controller: _tabController,
                        splashBorderRadius: const BorderRadius.vertical(
                            top: Radius.circular(29)),
                        overlayColor: MaterialStateProperty.all<Color>(
                            CustomColors.fireDragonBright500.withOpacity(.1)),
                        labelColor: CustomColors.fireDragonBright500,
                        unselectedLabelColor: CustomColors.drWhite900,
                        labelStyle: CustomTextStyle.inlineSmall(fontSize: 14),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorWeight: 2,
                        indicatorPadding:
                            const EdgeInsets.symmetric(horizontal: 40),
                        indicatorColor: CustomColors.fireDragonBright500,
                        tabs: List.generate(
                          tabs.length,
                          (index) => index == 0
                              ? Tab(
                                  text: "فیلتر",
                                )
                              : Tab(
                                  text: "ویرایش",
                                ),
                        )),
                  ),
            // appBar: AppBar(
            //   title: widget.title,
            //   backgroundColor: widget.appBarColor,
            //   actions: <Widget>[
            //     loading
            //         ? Container()
            //         : IconButton(
            //             icon: const Icon(Icons.check),
            //             onPressed: () async {
            //               setState(() {
            //                 loading = true;
            //               });
            //               var imageFile = await saveFilteredImage();
            //
            //               // ignore: use_build_context_synchronously
            //               Navigator.pop(context, {'image_filtered': imageFile});
            //             },
            //           )
            //   ],
            // ),
            body: _currentIndex == 0
                ? SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: loading
                        ? widget.loader
                        : Column(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 280,
                                padding: const EdgeInsets.all(0.0),
                                child: _buildFilteredImage(
                                  filter,
                                  image,
                                  filename,
                                ),
                              ),
                              Spacer(),
                              SizedBox(
                                height: 188,
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 24.0, right: 24),
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: widget.filters.length,
                                      shrinkWrap: true,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return InkWell(
                                          child: Container(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                _buildFilterThumbnail(
                                                    widget.filters[index],
                                                    image,
                                                    filename),
                                                const SizedBox(
                                                  height: 12.0,
                                                ),
                                                Text(
                                                  widget.filters[index].name,
                                                  style: TextStyle(
                                                      fontFamily: "Yekan",
                                                      color: Colors.black87,
                                                      fontSize: 16,
                                                     ),
                                                )
                                              ],
                                            ),
                                          ),
                                          onTap: () => setState(() {
                                            modifiedImageRelease = null;
                                            _brightnessValue = 0;
                                            _currentSliderValue = 0;
                                            filter = widget.filters[index];
                                          }),
                                        );
                                      },
                                    )
                                    // :Container(color: Colors.pink,),
                                    ),
                              ),
                            ],
                          ),
                  )
                : _editWidget()),
      ),
    );
  }

  Future<void> _loadImage(File imageFile) async {
    // Load the original image
    Uint8List bytes = imageFile.readAsBytesSync();

    final ByteData data = ByteData.view(bytes.buffer);
    final List<int> dataBytes = data.buffer.asUint8List();
    _originalImage = imagelib.decodeImage(Uint8List.fromList(dataBytes));

    setState(() {});
  }

  double _handleBrightnessValue(double _brightnessValue) {
    switch (_brightnessValue) {
      case -100:
        return 0.5;
      case -90:
        return 0.55;
      case -80:
        return 0.60;
      case -70:
        return 0.65;
      case -60:
        return 0.70;
      case -50:
        return 0.75;
      case -40:
        return 0.80;
      case -30:
        return 0.85;
      case -20:
        return 0.90;
      case -10:
        return 0.95;
      case 0:
        return 1;

      case 10:
        return 1.1;
      case 20:
        return 1.2;
      case 30:
        return 1.3;
      case 40:
        return 1.4;
      case 50:
        return 1.5;
      case 60:
        return 1.6;
      case 70:
        return 1.7;
      case 80:
        return 1.8;
      case 90:
        return 1.9;
      case 100:
        return 2;

      default:
        return 1;
    }
  }

  Future<void> _saveImage() async {
    if (_originalImage != null) {
      // Create a copy of the original image
      imagelib.Image modifiedImage =
          imagelib.copyResize(_originalImage!, width: _originalImage!.width);

      // Apply brightness adjustment
      modifiedImage =
          imagelib.adjustColor(modifiedImage, brightness: _brightnessValue);
      modifiedImageRelease = modifiedImage;
    }
  }

  Widget _editWidget() {
    return Column(
      children: [
        SizedBox(
          height: 280,
          width: double.infinity,
          child: Image.memory(Uint8List.fromList(
              imagelib.encodePng(modifiedImageRelease ?? _originalImage!))),
        ),
        Spacer(),
        sliderWidget
            ? Column(
                children: [
                  // Text(
                  //   '$_currentSliderValue',
                  //   style: CustomTextStyle.headingH6(),
                  // ),

                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Slider(
                      value: _currentSliderValue,
                      max: 100,
                      divisions: 20,
                      min: -100,
                      inactiveColor: Colors.black26,
                      activeColor: CustomColors.thickBlue500,
                      label: _currentSliderValue.round().toString(),
                      onChangeEnd: (double value) {
                        setState(() {
                          _brightnessValue = _handleBrightnessValue(value);
                          _saveImage();
                        });
                      },
                      onChanged: (double value) {
                        setState(() {
                          _currentSliderValue = value;
                        });
                      },
                    ),
                  ),

                  SizedBox(
                    height: 100,
                  ),

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     CustomButton(
                  //       onPressed: () {
                  //         sliderWidget = false;
                  //         modifiedImageRelease = null;
                  //         _brightnessValue = 0;
                  //         _currentSliderValue = 0;
                  //
                  //         setState(() {});
                  //       },
                  //       title: 'لغو کردن',
                  //       width: MediaQuery.of(context).size.width * 0.42,
                  //       primary: false,
                  //     ),
                  //     SizedBox(
                  //       width: 5,
                  //     ),
                  //     CustomButton(
                  //       onPressed: () {
                  //         sliderWidget = false;
                  //         setState(() {});
                  //       },
                  //       title: 'تایید',
                  //       width: MediaQuery.of(context).size.width * 0.42,
                  //     ),
                  //   ],
                  // )
                ],
              )
            : Padding(
                padding: CustomEdge.horizPrimary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 116,
                      width: MediaQuery.of(context).size.width * 0.42,
                      child: Container(
                        margin: CustomEdge.small,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: CustomColors.drWhite500),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 24,
                                  color: Colors.black.withOpacity(.2),
                                  offset: Offset(0, 8),
                                  spreadRadius: -8)
                            ]),
                        child: Padding(
                          padding: CustomEdge.small,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/adjust.png",
                                fit: BoxFit.cover,
                                width: 48,
                                height: 48,
                              ),
                              CustomEdge.vSeparator,
                              Text(
                                'Adjust',
                                style: CustomTextStyle.headingH6(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        sliderWidget = true;
                        setState(() {});
                      },
                      child: SizedBox(
                        height: 116,
                        width: MediaQuery.of(context).size.width * 0.42,
                        child: Container(
                          margin: CustomEdge.small,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: CustomColors.drWhite500),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 24,
                                    color: Colors.black.withOpacity(.2),
                                    offset: Offset(0, 8),
                                    spreadRadius: -8)
                              ]),
                          child: Padding(
                            padding: CustomEdge.small,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/sun.png",
                                  fit: BoxFit.cover,
                                  width: 48,
                                  height: 48,
                                ),
                                CustomEdge.vSeparator,
                                Text(
                                  'Brightness',
                                  style: CustomTextStyle.headingH6(
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        SizedBox(
          height: 16,
        )
      ],
    );
  }

  _handleTabSelection() async {
    if (_tabController.indexIsChanging) {
      _currentIndex = _tabController.index;
      imageFile = await saveFilteredImage();
      _loadImage(imageFile!);
      setState(() {});
    }
  }

  _buildFilterThumbnail(
      Filter filter, imagelib.Image? image, String? filename) {
    if (cachedFilters[filter.name] == null) {
      return FutureBuilder<List<int>>(
        future: compute(applyFilter, <String, dynamic>{
          "filter": filter,
          "image": image,
          "filename": filename,
        }),
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Container(
                width: 120.0, // Set your desired width
                height: 120.0, // Set your desired height

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  // Adjust the borderRadius as needed
                  color: Colors.white,
                ),
                child: Center(
                  child: widget.loader,
                ),
              );

            // return CircleAvatar(
            //   radius: 50.0,
            //   backgroundColor: Colors.white,
            //   child: Center(
            //     child: widget.loader,
            //   ),
            // );
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              // cachedFilters[filter.name] =  snapshot.data;
              cachedFilters[filter.name] =
                  modifiedImageRelease == null ? snapshot.data : null;

              return Container(
                width: 120.0, // Set your desired width
                height: 120.0, // Set your desired height
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  // Adjust the borderRadius as needed
                  image: DecorationImage(
                    image: MemoryImage(
                      snapshot.data as dynamic,
                    ),
                    fit: BoxFit.cover, // Adjust the BoxFit property as needed
                  ),
                ),
              );

            // return CircleAvatar(
            //   radius: 50.0,
            //   backgroundImage: MemoryImage(
            //     snapshot.data as dynamic,
            //   ),
            //   backgroundColor: Colors.white,
            // );
          }
          // unreachable
        },
      );
    } else {
      return Container(
        width: 120.0, // Set your desired width
        height: 120.0, // Set your desired height
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          // Adjust the borderRadius as needed
          image: DecorationImage(
            image: MemoryImage(
              cachedFilters[filter.name] as dynamic,
            ),
            fit: BoxFit.cover, // Adjust the BoxFit property as needed
          ),
        ),
      );

      // return CircleAvatar(
      //   radius: 50.0,
      //   backgroundImage: MemoryImage(
      //     cachedFilters[filter.name] as dynamic,
      //   ),
      //   backgroundColor: Colors.white,
      // );
    }
  }

  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get localFile async {
    final path = await localPath;
    return File('$path/filtered_${filter?.name ?? "_"}_$filename');
  }


  Future<File> convertImageToFIle(imagelib.Image image) async {
    // Convert the image to bytes
    List<int> imageBytes = imagelib.encodePng(image); // or encodeJpg

    // Create a temporary file
    String tempPath = Directory.systemTemp.path;
    File tempFile = File('$tempPath/temp_image.png'); // Change the file extension accordingly

    // Write the image bytes to the file
    await tempFile.writeAsBytes(imageBytes);

    return tempFile;
  }

  Future<File?> saveFilteredImage() async {
    if(modifiedImageRelease!=null){

      return convertImageToFIle(modifiedImageRelease!);
    }else{
      var imageFile = await localFile;
      await imageFile.writeAsBytes(cachedFilters[filter?.name ?? "_"]!);
      return imageFile;
    }

  }

  Widget _buildFilteredImage(
      Filter? filter, imagelib.Image? image, String? filename) {
    if (cachedFilters[filter?.name ?? "_"] == null) {
      return FutureBuilder<List<int>>(
        future: compute(applyFilter, <String, dynamic>{
          "filter": filter,
          "image": image,
          "filename": filename,
        }),
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          imageData = snapshot.data;

          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return widget.loader;
            case ConnectionState.active:
            case ConnectionState.waiting:
              return widget.loader;
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              cachedFilters[filter?.name ?? "_"] = snapshot.data;
              return widget.circleShape
                  ? SizedBox(
                      height: MediaQuery.of(context).size.width / 3,
                      width: MediaQuery.of(context).size.width / 3,
                      child: Center(
                        child: CircleAvatar(
                          radius: MediaQuery.of(context).size.width / 3,
                          backgroundImage: MemoryImage(
                            snapshot.data as dynamic,
                          ),
                        ),
                      ),
                    )
                  : modifiedImageRelease != null
                      ? Image.memory(Uint8List.fromList(imagelib
                          .encodePng(modifiedImageRelease ?? _originalImage!)))
                      : Image.memory(
                          snapshot.data as dynamic,
                          fit: BoxFit.cover,
                        );
          }

          // unreachable
        },
      );
    } else {
      return widget.circleShape
          ? SizedBox(
              height: MediaQuery.of(context).size.width / 3,
              width: MediaQuery.of(context).size.width / 3,
              child: Center(
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.width / 3,
                  backgroundImage: MemoryImage(
                    cachedFilters[filter?.name ?? "_"] as dynamic,
                  ),
                ),
              ),
            )
          : modifiedImageRelease != null
              ? Image.memory(Uint8List.fromList(
                  imagelib.encodePng(modifiedImageRelease ?? _originalImage!)))
              : Image.memory(
                  cachedFilters[filter?.name ?? "_"] as dynamic,
                  fit: widget.fit,
                );
    }
  }
}

///The global applyfilter function
FutureOr<List<int>> applyFilter(Map<String, dynamic> params) {
  Filter? filter = params["filter"];
  imagelib.Image image = params["image"];
  String filename = params["filename"];
  List<int> bytes0 = image.getBytes();
  if (filter != null) {
    filter.apply(bytes0 as dynamic, image.width, image.height);
  }

  Uint8List bytes = Uint8List.fromList(bytes0);
  imagelib.Image image0 = imagelib.Image.fromBytes(
      width: image.width, height: image.height, bytes: bytes.buffer);
  bytes0 = imagelib.encodeNamedImage(
    filename,
    image0,
  )!;

  return bytes0;
}

///The global buildThumbnail function
FutureOr<List<int>> buildThumbnail(Map<String, dynamic> params) {
  int? width = params["width"];
  params["image"] = imagelib.copyResize(params["image"], width: width);
  return applyFilter(params);
}
