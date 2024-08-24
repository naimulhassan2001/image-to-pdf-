import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_to_pdf/controller/home_controller.dart';

class Home extends StatelessWidget {
  Home({super.key});

  HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
        builder: (controller) => Scaffold(
          extendBody: true,
              appBar: AppBar(
                title: const Text("Images To Pdf"),
                centerTitle: true,
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      controller.isProgress
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: LinearProgressIndicator(
                                minHeight: 25,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.green),
                                value: HomeController.instance.progressValue,
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          itemCount:
                              HomeController.instance.imagePaths.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (controller.imagePaths.length > index) {
                              return Card(
                                child: Image(
                                  image: FileImage(
                                    File(HomeController
                                        .instance.imagePaths[index].path),
                                  ),
                                  fit: BoxFit.contain,
                                ),
                              );
                            } else {
                              return Card(
                                child: IconButton(
                                    onPressed: controller.pickGalleryImage,
                                    icon: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add),
                                        Text("Select Images"),
                                      ],
                                    )),
                              );
                            }
                          },
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.all(20),
                child: MaterialButton(
                  color: Colors.teal,
                  textColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  onPressed: controller.convertImage,
                  child: const Text("Download Pdf"),
                ),
              ),
            ));
  }
}
