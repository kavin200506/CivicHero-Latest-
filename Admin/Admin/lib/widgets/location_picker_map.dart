import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/nominatim_service.dart';


class LocationPickerMap extends StatefulWidget {
  final LatLng? initialLocation;
  final Function(LatLng, String?) onLocationPicked; // Updated callback signature to include address

  const LocationPickerMap({
    super.key,
    this.initialLocation,
    required this.onLocationPicked,
  });

  @override
  State<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  LatLng? _pickedLocation;
  final MapController _mapController = MapController();
  final NominatimService _nominatimService = NominatimService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String? _pickedAddress;

  // Tamil Nadu Center (Approx)
  final LatLng _tamilNaduCenter = const LatLng(11.1271, 78.6569);

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
  }

  Future<void> _handleTap(TapPosition tapPosition, LatLng point) async {
    setState(() {
      _pickedLocation = point;
      _pickedAddress = "Fetching address...";
    });

    final addressData = await _nominatimService.reverse(point.latitude, point.longitude);
    String? addressName;
    if (addressData != null) {
      addressName = addressData['display_name'];
    }

    setState(() {
      _pickedAddress = addressName ?? "Unknown Location";
    });

    widget.onLocationPicked(point, addressName);
  }

  Future<void> _performSearch() async {
    if (_searchController.text.isEmpty) return;
    setState(() => _isSearching = true);
    
    final results = await _nominatimService.search(_searchController.text);
    
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _selectSearchResult(Map<String, dynamic> result) {
    final lat = double.parse(result['lat']);
    final lon = double.parse(result['lon']);
    final point = LatLng(lat, lon);
    
    setState(() {
      _pickedLocation = point;
      _pickedAddress = result['display_name'];
      _searchResults = [];
      _searchController.clear();
    });

    _mapController.move(point, 15.0);
    // Don't auto-confirm, let user confirm with check button
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick Location")),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _pickedLocation ?? _tamilNaduCenter,
          initialZoom: 7.0,
          onTap: _handleTap,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.civichero.admin',
          ),
          if (_pickedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _pickedLocation!,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          
          // Search Bar Overlay
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search for a place...',
                              border: InputBorder.none,
                              icon: Icon(Icons.search),
                            ),
                            onSubmitted: (_) => _performSearch(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _performSearch,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isSearching)
                  const LinearProgressIndicator(),
                if (_searchResults.isNotEmpty)
                  Container(
                    color: Colors.white,
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return ListTile(
                          title: Text(result['display_name'] ?? ''),
                          onTap: () => _selectSearchResult(result),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Address Display Overlay
          if (_pickedAddress != null)
            Positioned(
              bottom: 80,
              left: 10,
              right: 10,
              child: Card(
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    _pickedAddress!,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           if (_pickedLocation != null) {
             Navigator.pop(context, {'point': _pickedLocation, 'address': _pickedAddress});
           } else {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text("Please tap on the map to pick a location"))
             );
           }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
