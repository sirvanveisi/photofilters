import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imagelib;
import 'package:path_provider/path_provider.dart';
import 'package:photofilters/filters/filters.dart';
import 'package:photofilters/utils/colors.dart';
import 'package:photofilters/utils/font_Style.dart';

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

class PhotoFilterSelectorState extends State<PhotoFilterSelector>  with TickerProviderStateMixin{
  String? filename;
  Map<String, List<int>?> cachedFilters = {};
  Filter? filter;
  imagelib.Image? image;
  late bool loading;
  static const Color thickBlue = Color(0xFF525FE1);
  static const Color dark = Color(0xFF212529);
  late TabController _tabController;
  static const Color drWhite500 = Color(0xFFF7F7F8);

  @override
  void initState() {
    super.initState();
    loading = false;
    filter = widget.filters[0];
    filename = widget.filename;
    image = widget.image;
    _tabController = TabController(length: 2, vsync: this);

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              'پست جدید',
              style:TextStyle(
                  fontFamily: "Yekan",
                  color: dark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            actions: [
              CupertinoButton(
                  child: Text(
                    'ادامه',
              style:  TextStyle(
                  fontFamily: "Yekan",
                  color: thickBlue,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                  decorationColor: thickBlue,
                  decorationStyle: TextDecorationStyle.solid,
                  fontWeight: FontWeight.w500)
          )
                  ,
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  var imageFile = await saveFilteredImage();

                  // ignore: use_build_context_synchronously
                  Navigator.pop(context, {'image_filtered': imageFile});
                },
              )
            ],
          ),
          bottomNavigationBar: Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(48),
                border: Border.all(color: drWhite500)),
            child: TabBar(
                controller: _tabController,
                splashBorderRadius:
                const BorderRadius.vertical(top: Radius.circular(29)),
                overlayColor: MaterialStateProperty.all<Color>(
                    CustomColors.fireDragonBright500.withOpacity(.1)),
                labelColor: CustomColors.fireDragonBright500,
                unselectedLabelColor: CustomColors.drWhite900,
                labelStyle: CustomTextStyle.inlineSmall(fontSize: 14),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 2,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 40),
                indicatorColor: CustomColors.fireDragonBright500,
                tabs:  [Tab(text: 'فیلتر'), Tab(text: 'ویرایش')]),
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
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: loading
                ? widget.loader
                : Column(


                    children: [
                      SizedBox(
                          height: 20),
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
                          padding: const EdgeInsets.only(left: 24.0,right: 24),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.filters.length,
                            shrinkWrap: true,


                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                child: Container(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      _buildFilterThumbnail(
                                          widget.filters[index], image, filename),
                                      const SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(
                                        widget.filters[index].name,
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () => setState(() {
                                  filter = widget.filters[index];
                                }),
                              );
                            },
                          ),
                        ),
                      ),

                    ],
                  ),
          ),
        ),
      ),
    );
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
                borderRadius: BorderRadius.circular(12.0), // Adjust the borderRadius as needed
                color: Colors.white,

              ),
              child: Center(
                child: widget.loader,
              ),
            );

              return CircleAvatar(
                radius: 50.0,
                backgroundColor: Colors.white,
                child: Center(
                  child: widget.loader,
                ),
              );
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              cachedFilters[filter.name] = snapshot.data;
              return Container(
                width: 120.0, // Set your desired width
                height: 120.0, // Set your desired height
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0), // Adjust the borderRadius as needed
                  image: DecorationImage(
                    image:  MemoryImage(
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
          borderRadius: BorderRadius.circular(12.0), // Adjust the borderRadius as needed
          image: DecorationImage(
            image:  MemoryImage(
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

  Future<File> saveFilteredImage() async {
    var imageFile = await localFile;
    await imageFile.writeAsBytes(cachedFilters[filter?.name ?? "_"]!);
    return imageFile;
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
