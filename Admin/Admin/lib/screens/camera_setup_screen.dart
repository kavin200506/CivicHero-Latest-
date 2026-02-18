import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data_service.dart';
import '../models/camera_model.dart';
import '../widgets/image_drawing_canvas.dart'; // To be implemented
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/location_picker_map.dart';

class CameraSetupScreen extends StatefulWidget {
  const CameraSetupScreen({super.key});

  @override
  State<CameraSetupScreen> createState() => _CameraSetupScreenState();
}

class _CameraSetupScreenState extends State<CameraSetupScreen> {
  Camera? _selectedCamera;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<DataService>(context, listen: false).fetchCameras();
    });
  }


// ... imports

  void _showAddCameraDialog() {
    final nameController = TextEditingController();
    final locationController = TextEditingController(); // Accessible Name
    final urlController = TextEditingController();
    double _latitude = 0.0;
    double _longitude = 0.0;
    
    Uint8List? _imageBytes;
    String? _imageName;
    bool _isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add New Camera'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Camera Name')),
                  const SizedBox(height: 10),
                  
                  // Location Picker
                  const Text("Location", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _latitude != 0 ? '$_latitude, $_longitude' : 'No location picked',
                          style: TextStyle(color: _latitude != 0 ? Colors.black : Colors.grey),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.map, color: Colors.blue),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LocationPickerMap(
                                initialLocation: _latitude != 0 ? LatLng(_latitude, _longitude) : null,
                                onLocationPicked: (_, __) {}, // Handled by pop
                              ),
                            ),
                          );
                          
                          if (result != null && result is Map) {
                            final LatLng point = result['point'];
                            final String? address = result['address'];
                            
                            setState(() {
                              _latitude = point.latitude;
                              _longitude = point.longitude;
                              if (address != null && address.isNotEmpty) {
                                locationController.text = address;
                              } else if (locationController.text.isEmpty) {
                                locationController.text = "${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}";
                              }
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  TextField(
                    controller: locationController, 
                    decoration: const InputDecoration(
                      labelText: 'Location Name (Address)',
                      hintText: 'e.g. Main St, Chennai'
                    )
                  ),

                  const SizedBox(height: 10),
                  const SizedBox(height: 10),
                  const Text("Snapshot", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        final bytes = await image.readAsBytes();
                        setState(() {
                          _imageBytes = bytes;
                          _imageName = image.name;
                          urlController.text = ""; // Clear URL if image is picked
                        });
                      }
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[100],
                      ),
                      child: _imageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_a_photo, size: 40, color: Colors.blue),
                                const SizedBox(height: 8),
                                Text(_imageName ?? 'Tap to pick image from gallery', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("OR", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: urlController, 
                    decoration: const InputDecoration(
                      labelText: 'Enter Snapshot URL',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                    onChanged: (val) {
                      if (val.isNotEmpty && _imageBytes != null) {
                         setState(() {
                           _imageBytes = null;
                           _imageName = null;
                         });
                      }
                    },
                  ),
                  if (_isUploading) const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: LinearProgressIndicator(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: _isUploading ? null : () async {
                  if (nameController.text.isNotEmpty) {
                    setState(() => _isUploading = true);
                    
                    String snapshotUrl = urlController.text;
                    try {
                      if (_imageBytes != null && _imageName != null) {
                        snapshotUrl = await Provider.of<DataService>(context, listen: false)
                            .uploadCameraSnapshot(_imageBytes!, DateTime.now().millisecondsSinceEpoch.toString() + '_' + _imageName!);
                      }

                      final newCamera = Camera(
                        id: '', 
                        name: nameController.text,
                        locationName: locationController.text,
                        latitude: _latitude,
                        longitude: _longitude,
                        snapshotUrl: snapshotUrl,
                      );
                      
                      await Provider.of<DataService>(context, listen: false).addCamera(newCamera);
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      print("Error adding camera: $e");
                      setState(() => _isUploading = false);
                    }
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera ROI Setup'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => Provider.of<DataService>(context, listen: false).fetchCameras(),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 300,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Consumer<DataService>(
                    builder: (_, dataService, __) {
                      if (dataService.cameras.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.videocam_off, size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No cameras found.', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: dataService.cameras.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final camera = dataService.cameras[index];
                          final isSelected = _selectedCamera?.id == camera.id;
                          return ListTile(
                            leading: Icon(
                              Icons.videocam, 
                              color: isSelected ? Colors.blue : Colors.grey[700]
                            ),
                            title: Text(
                              camera.name,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.blue[900] : Colors.black87,
                              ),
                            ),
                            subtitle: Text(camera.locationName),
                            selected: isSelected,
                            selectedTileColor: Colors.blue.withOpacity(0.1),
                            onTap: () => setState(() => _selectedCamera = camera),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.grey),
                              onPressed: () => _confirmDelete(camera.id),
                              hoverColor: Colors.red.withOpacity(0.1),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: _showAddCameraDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Camera'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: _selectedCamera == null
                ? const Center(child: Text('Select a camera to configure ROIs'))
                : ImageDrawingCanvas(camera: _selectedCamera!),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String cameraId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Camera?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
             onPressed: () {
               Provider.of<DataService>(context, listen: false).deleteCamera(cameraId);
               if (_selectedCamera?.id == cameraId) {
                 setState(() => _selectedCamera = null);
               }
               Navigator.pop(context);
             },
             child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
