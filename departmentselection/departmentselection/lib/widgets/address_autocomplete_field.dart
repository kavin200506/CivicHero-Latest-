import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Text field with Google Places Autocomplete suggestions.
/// If PLACES_API_KEY or GOOGLE_PLACES_API_KEY is not set in .env, behaves as a normal text field.
class AddressAutocompleteField extends StatefulWidget {
  const AddressAutocompleteField({
    super.key,
    required this.controller,
    this.decoration,
    this.validator,
    this.onSelected,
  });

  final TextEditingController controller;
  final InputDecoration? decoration;
  final String? Function(String?)? validator;
  final void Function(String address)? onSelected;

  @override
  State<AddressAutocompleteField> createState() => _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _predictions = [];
  bool _loading = false;
  Timer? _debounce;
  final _scrollController = ScrollController();

  String? get _apiKey {
    final key = dotenv.maybeGet('PLACES_API_KEY') ?? dotenv.maybeGet('GOOGLE_PLACES_API_KEY');
    return key?.trim().isEmpty == true ? null : key;
  }

  Future<void> _fetchPredictions(String input) async {
    final key = _apiKey;
    if (key == null || input.trim().length < 2) {
      setState(() {
        _predictions = [];
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        'maps/api/place/autocomplete/json',
        {
          'input': input.trim(),
          'key': key,
          'types': 'address',
        },
      );
      final res = await http.get(uri);
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final list = data['predictions'] as List<dynamic>?;
        final descriptions = list
            ?.map((e) => (e as Map<String, dynamic>)['description'] as String?)
            .whereType<String>()
            .toList() ?? [];
        setState(() {
          _predictions = descriptions;
          _loading = false;
        });
        _overlayEntry?.remove();
        if (descriptions.isNotEmpty) _showOverlay();
      } else {
        setState(() {
          _predictions = [];
          _loading = false;
        });
        _overlayEntry?.remove();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _predictions = [];
          _loading = false;
        });
        _overlayEntry?.remove();
      }
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (_apiKey == null) return;
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchPredictions(value);
    });
    if (value.trim().length >= 2) _showOverlay();
  }

  void _showOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) => CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: Offset(0, _decorationHeight),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _predictions.length,
                    itemBuilder: (context, index) {
                      final p = _predictions[index];
                      return ListTile(
                        dense: true,
                        title: Text(p),
                        onTap: () {
                          widget.controller.text = p;
                          widget.onSelected?.call(p);
                          _predictions = [];
                          _overlayEntry?.remove();
                          _overlayEntry = null;
                          setState(() {});
                        },
                      );
                    },
                  ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _debounce?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _predictions = [];
    });
  }

  double get _decorationHeight => 56;

  @override
  void dispose() {
    _debounce?.cancel();
    _overlayEntry?.remove();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.controller,
        decoration: (widget.decoration ?? const InputDecoration()).copyWith(
          suffixIcon: _loading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
        ),
        validator: widget.validator,
        onChanged: _onChanged,
        onTap: () {
          if (widget.controller.text.trim().length >= 2 && _predictions.isNotEmpty) {
            _showOverlay();
          }
        },
        onTapOutside: (_) => _hideOverlay(),
      ),
    );
  }
}
