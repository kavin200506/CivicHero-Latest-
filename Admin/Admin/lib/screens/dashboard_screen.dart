import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../auth_service.dart';
import '../data_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String sortType = "Priority"; // default sorting set to Priority
  int agingDays = 0; // 0 = no filter
  String searchQuery = ''; // Search widget state
  bool _showHeatmap = true; // ✅ new state to control heatmap visibility

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final dataService = Provider.of<DataService>(context, listen: false);
      dataService.fetchData().then((_) {
        dataService.sortData("Priority");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Consumer<AuthService>(
            builder: (_, auth, __) => IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
              onPressed: () async => await auth.signOut(),
            ),
          ),
        ],
      ),
      body: Consumer<DataService>(
        builder: (_, ds, __) {
          if (ds.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ds.error != null) {
            return Center(child: Text('Error: ${ds.error}'));
          }
          if (ds.data.isEmpty) {
            return const Center(child: Text('No issues found'));
          }

          // Sidebar counts
          final urgencyCounts = <String, int>{};
          int totalReports = ds.data.length;
          for (final issue in ds.data) {
            final u = (issue['urgency'] ?? 'Medium').toString();
            urgencyCounts[u] = (urgencyCounts[u] ?? 0) + 1;
          }

          // Apply aging filter + search
          final now = DateTime.now();
          final filteredIssues = ds.data.where((issue) {
            if (agingDays != 0) {
              final reported = DateTime.tryParse(issue['reported_date'] ?? '');
              if (reported == null ||
                  now.difference(reported).inDays > agingDays) return false;
            }
            if (searchQuery.isNotEmpty) {
              final q = searchQuery.toLowerCase();
              final type = (issue['issue_type'] ?? '').toString().toLowerCase();
              final addr = (issue['address'] ?? '').toString().toLowerCase();
              if (!type.contains(q) && !addr.contains(q)) return false;
            }
            return true;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Sidebar =====
                Container(
                  width: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(2, 2))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search widget
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search issues...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (val) => setState(() => searchQuery = val),
                      ),
                      const SizedBox(height: 12),
                      _buildCountCard(
                          'Total Reports', totalReports, Colors.blue.shade100),
                      _buildCountCard('Filtered Issues', filteredIssues.length,
                          Colors.orange.shade100),
                      _buildCountCard(
                        'Resolved Issues',
                        ds.data
                            .where((i) =>
                                (i['status'] ?? '').toLowerCase() == 'resolved')
                            .length,
                        Colors.green.shade100,
                      ),
                      const SizedBox(height: 16),
                      const Text('Urgency Levels',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...['Critical', 'High', 'Medium', 'Low'].map((lvl) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: _urgencyColor(lvl),
                                child: Text(
                                  (urgencyCounts[lvl] ?? 0).toString(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                  child: Text(lvl,
                                      style: const TextStyle(fontSize: 14))),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 20),

                      // ✅ Toggle Heatmap Button (below urgency level)
                      ElevatedButton.icon(
                        icon: Icon(
                          _showHeatmap
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        label: Text(_showHeatmap
                            ? 'Hide Heatmap'
                            : 'Show Heatmap'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        onPressed: () {
                          setState(() => _showHeatmap = !_showHeatmap);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // ===== Main Content =====
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: cluster count + refresh + sort + filter
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Total Issues: ${filteredIssues.length}',
                              style: const TextStyle(
                                  fontSize: 20, fontStyle: FontStyle.italic),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.blue),
                            tooltip: 'Refresh Data',
                            onPressed: () async {
                              await Provider.of<DataService>(context,
                                      listen: false)
                                  .fetchData();
                              Provider.of<DataService>(context, listen: false)
                                  .sortData("Priority");
                            },
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              setState(() => sortType = value);
                              _sortData(ds, value);
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                  value: 'Latest', child: Text('Latest')),
                              PopupMenuItem(
                                  value: 'Oldest', child: Text('Oldest')),
                              PopupMenuItem(
                                  value: 'Priority', child: Text('Priority')),
                              PopupMenuItem(
                                  value: 'Priority Descending',
                                  child: Text('Priority Descending')),
                              PopupMenuItem(
                                  value: 'Priority Ascending',
                                  child: Text('Priority Ascending')),
                            ],
                            child: Row(
                              children: [
                                const Icon(Icons.sort, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(sortType,
                                    style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(width: 12),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.filter_list),
                            label: const Text('Filters'),
                            onPressed: () => _openFilterDialog(context, ds),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ===== Heatmap (conditionally rendered) =====
                      if (_showHeatmap) ...[
                        SizedBox(
                          height: 300,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(20.5937, 78.9629),
                              initialZoom: 5,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                subdomains: const ['a', 'b', 'c'],
                              ),
                              MarkerLayer(
                                markers: filteredIssues
                                    .map((issue) => Marker(
                                          point: LatLng(
                                            (issue['latitude'] as double?) ??
                                                0,
                                            (issue['longitude'] as double?) ??
                                                0,
                                          ),
                                          width: 20,
                                          height: 20,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: _urgencyColor(
                                                      issue['urgency'])
                                                  .withOpacity(0.6),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ===== Issue List =====
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredIssues.length,
                          itemBuilder: (_, i) {
                            final issue = filteredIssues[i];
                            final priorityScore =
                                _calculatePriorityScore(issue);

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Image thumbnail
                                    if (issue['image_url'] != null && 
                                        (issue['image_url'] as String).isNotEmpty)
                                      Container(
                                        width: 100,
                                        height: 100,
                                        margin: const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            issue['image_url'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey.shade200,
                                                child: const Icon(Icons.broken_image),
                                              );
                                            },
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded /
                                                          loadingProgress.expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    // Priority indicator
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: _urgencyColor(issue['urgency']),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              issue['urgency']?.toString().substring(0, 1).toUpperCase() ?? 'M',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        SizedBox(
                                          width: 50,
                                          height: 6,
                                          child: LinearProgressIndicator(
                                            value: priorityScore / 100,
                                            backgroundColor:
                                                Colors.grey.shade300,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  issue['issue_type'] ?? 'Unknown Issue',
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: _urgencyColor(issue['urgency'])
                                                      .withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  issue['urgency'] ?? 'Medium',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: _urgencyColor(issue['urgency']),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          _issueDetailsWidget(issue),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        DropdownButton<String>(
                                          value: const [
                                            'Reported',
                                            'Assigned',
                                            'In Progress',
                                            'Resolved'
                                          ].contains(issue['status'])
                                              ? issue['status']
                                              : 'Reported',
                                          underline: const SizedBox(),
                                          items: const [
                                            DropdownMenuItem(
                                                value: 'Reported',
                                                child: Text('Reported')),
                                            DropdownMenuItem(
                                                value: 'Assigned',
                                                child: Text('Assigned')),
                                            DropdownMenuItem(
                                                value: 'In Progress',
                                                child: Text('In Progress')),
                                            DropdownMenuItem(
                                                value: 'Resolved',
                                                child: Text('Resolved')),
                                          ],
                                          onChanged: (val) async {
                                            if (val == null) return;
                                            setState(
                                                () => issue['status'] = val);
                                            await Provider.of<DataService>(
                                                    context,
                                                    listen: false)
                                                .updateIssueStatus(
                                                    issue['id'],
                                                    val);
                                          },
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${priorityScore.toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.redAccent),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _calculatePriorityScore(Map<String, dynamic> issue) {
    final baseScores = {
      'low': 10.0,
      'medium': 15.0,
      'high': 25.0,
      'critical': 40.0
    };
    final urgency = (issue['urgency'] ?? 'medium').toString().toLowerCase();
    double score = baseScores[urgency] ?? 15.0;

    try {
      final reported = DateTime.tryParse(issue['reported_date'] ?? '');
      if (reported != null) {
        final daysOld = DateTime.now().difference(reported).inDays;
        double ageFactor = (daysOld / 7) * 2.5;
        if (ageFactor > 30) ageFactor = 30;
        score += ageFactor;
      }
    } catch (_) {}

    if ((issue['status'] ?? '').toString().toLowerCase() == 'reported') {
      score += 10.0;
    }

    return score.clamp(0, 100);
  }

  void _sortData(DataService ds, String value) {
    if (value == 'Priority Descending') {
      ds.data.sort((a, b) =>
          _calculatePriorityScore(b).compareTo(_calculatePriorityScore(a)));
    } else if (value == 'Priority Ascending') {
      ds.data.sort((a, b) =>
          _calculatePriorityScore(a).compareTo(_calculatePriorityScore(b)));
    } else if (value == 'Priority') {
      ds.data.sort((a, b) {
        const baseScores = {
          'low': 10,
          'medium': 15,
          'high': 25,
          'critical': 40
        };
        final aScore =
            baseScores[(a['urgency'] ?? 'medium').toString().toLowerCase()] ??
                0;
        final bScore =
            baseScores[(b['urgency'] ?? 'medium').toString().toLowerCase()] ??
                0;
        return bScore.compareTo(aScore);
      });
    } else if (value == 'Latest') {
      ds.data.sort((a, b) {
        final da =
            DateTime.tryParse(a['reported_date'] ?? '') ?? DateTime.now();
        final db =
            DateTime.tryParse(b['reported_date'] ?? '') ?? DateTime.now();
        return db.compareTo(da);
      });
    } else if (value == 'Oldest') {
      ds.data.sort((a, b) {
        final da =
            DateTime.tryParse(a['reported_date'] ?? '') ?? DateTime.now();
        final db =
            DateTime.tryParse(b['reported_date'] ?? '') ?? DateTime.now();
        return da.compareTo(db);
      });
    }
  }

  Widget _issueDetailsWidget(Map<String, dynamic> issue) {
    final reported = DateTime.tryParse(issue['reported_date'] ?? '');
    final dateStr =
        reported != null ? DateFormat('dd MMM yyyy').format(reported) : '';
    final timeStr =
        reported != null ? DateFormat('hh:mm a').format(reported) : '';
    final lat = issue['latitude'] ?? 0.0;
    final lng = issue['longitude'] ?? 0.0;
    final description = issue['description'] ?? '';
    final department = issue['department'] ?? '';
    final userId = issue['user_id'] ?? '';
    final complainId = issue['complain_id'] ?? issue['id'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (description.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.description, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        Row(
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                "${issue['address'] ?? 'Unknown location'}",
                style: const TextStyle(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(dateStr, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 12),
            const Icon(Icons.access_time, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(timeStr, style: const TextStyle(fontSize: 14)),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.business, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text('Dept: $department', style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 12),
            const Icon(Icons.person, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'User: ${userId.length > 8 ? userId.substring(0, 8) + '...' : userId}',
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (complainId.isNotEmpty) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.tag, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'ID: $complainId',
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCountCard(String title, int count, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Text(
        '$title: $count',
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Color _urgencyColor(String? u) {
    switch ((u ?? '').toLowerCase()) {
      case 'critical':
        return Colors.purple;
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _openFilterDialog(BuildContext context, DataService ds) async {
    String fmt(DateTime? d) =>
        d != null ? DateFormat('dd MMM yyyy').format(d) : '';
    List<String> types = List.from(ds.selectedTypes);
    List<String> depts = List.from(ds.selectedDepartments);
    List<String> users = List.from(ds.selectedUserIds);
    List<String> locs = List.from(ds.selectedLocations);
    List<String> urgencies = List.from(ds.selectedUrgencies);
    DateTime? start = ds.startDate;
    DateTime? end = ds.endDate;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setDialog) => AlertDialog(
          title: const Text('Filters'),
          content: SizedBox(
            width: 300,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _multiSelect('Type', ds.allTypes, types,
                      (v) => setDialog(() => types = v)),
                  _multiSelect('Department', ds.allDepartments, depts,
                      (v) => setDialog(() => depts = v)),
                  _multiSelect('User ID', ds.allUsers, users,
                      (v) => setDialog(() => users = v)),
                  _multiSelect('Location', ds.allLocations, locs,
                      (v) => setDialog(() => locs = v)),
                  _multiSelect('Urgency', ['Critical', 'High', 'Medium', 'Low'],
                      urgencies, (v) => setDialog(() => urgencies = v)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(start != null && end != null
                        ? '${fmt(start)} - ${fmt(end)}'
                        : 'Filter by Date'),
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDateRange: start != null && end != null
                            ? DateTimeRange(start: start!, end: end!)
                            : null,
                      );
                      if (picked != null) {
                        setDialog(() {
                          start = picked.start;
                          end = picked.end;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialog(() {
                  types.clear();
                  depts.clear();
                  users.clear();
                  locs.clear();
                  urgencies.clear();
                  start = null;
                  end = null;
                });
                setState(() => ds.resetFilters());
              },
              child: const Text('Reset Filters',
                  style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => ds.updateFilters(
                    types, depts, users, locs, start, end, urgencies));
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _multiSelect(String title, List<String> opts, List<String> selected,
      void Function(List<String>) onChange) {
    return ExpansionTile(
      title: Text('$title (${selected.length})'),
      children: opts.map((o) {
        final checked = selected.contains(o);
        return CheckboxListTile(
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(o),
          value: checked,
          onChanged: (v) {
            if (v == true) {
              selected.add(o);
            } else {
              selected.remove(o);
            }
            onChange(List.from(selected));
          },
        );
      }).toList(),
    );
  }
}
