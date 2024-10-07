import 'dart:developer';
import 'dart:io';

import 'package:assignment_1/display_image_screen.dart';
import 'package:camera/camera.dart';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isCameraPermissiongranted = false;

  OverlayEntry? _notificationOverlay;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();

    setState(() {
      _isCameraPermissiongranted = status.isGranted;
    });

    if (_isCameraPermissiongranted) {
      _initalizeCamera();
    }
  }

  Future<void> _initalizeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(firstCamera, ResolutionPreset.high);

    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Camera app",
        ),
      ),
      body: _isCameraPermissiongranted
          ? _cameraPreview()
          : _permissionDeniedWidget(),
      floatingActionButton: _isCameraPermissiongranted
          ? FloatingActionButton(
              onPressed: () {
                _takePhoto();
              },
              child: const Icon(
                Icons.camera,
              ),
            )
          : null,
    );
  }

  Widget _cameraPreview() {
    return FutureBuilder(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CameraPreview(_controller!);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _permissionDeniedWidget() {
    return Center(
      child: Column(
        children: [
          const Text(
            "Camera permission denied",
          ),
          ElevatedButton(
            onPressed: _requestCameraPermission,
            child: const Text(
              "Request Permission",
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _takePhoto() async {
    try {
      await _initializeControllerFuture;
      // WIll be XFile which we will have to use it to display to the user.
      final XFile image = await _controller!.takePicture();

      final saveImageResult = await ImageGallerySaver.saveFile(image.path);

      if (saveImageResult['isSuccess']) {
        log("Image saved successfully");
        _showNotification(image.path);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to save photo to gallery',
              ),
            ),
          );
        }
      }

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DisplayImageScreen(
              imagePath: image.path,
            ),
          ),
        );
      }
    } catch (e) {
      log(
        "Error is $e",
      );
    }
  }

  // Shows an in-app notification with the saved image
  void _showNotification(String imagePath) {
    log("Inside notification");

    log("Image path is $imagePath");

    _notificationOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 50,
          // left: 20,
          // width: 20,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(
                8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  10,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                    child: Image.file(
                      File(
                        imagePath,
                      ),
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    "Image is Uploaded",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_notificationOverlay!);

    // Remove the notification after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _notificationOverlay?.remove();
      _notificationOverlay = null;
    });
  }

  @override
  void dispose() {
    _controller?.dispose(); // Dispose of the camera controller
    _notificationOverlay?.dispose(); // Dispose of any active notification
    super.dispose();
  }
}
