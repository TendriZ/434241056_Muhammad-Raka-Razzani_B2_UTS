/// Dashboard Screen - FR-011: Menampilkan Dashboard dengan Statistik
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ticket_bloc.dart';

class DashboardScreen extends StatefulWidget {
  final String? userId;
  final String? role;

  const DashboardScreen({
    Key? key,
    this.userId,
    this.role,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late TicketBloc _ticketBloc;

  @override
  void initState() {
    super.initState();
    _ticketBloc = context.read<TicketBloc>();
    _loadStatistics();
  }

  void _loadStatistics() {
    _ticketBloc.add(
      FetchTicketStatisticsEvent(userId: widget.userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: BlocBuilder<TicketBloc, TicketState>(
        builder: (context, state) {
          if (state is TicketLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TicketStatisticsLoaded) {
            return _buildDashboard(state.statistics);
          } else if (state is TicketError) {
            return Center(
              child: Text('Error: ${state.message}'),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDashboard(Map<String, int> stats) {
    final total = stats['total'] ?? 0;
    final pending = stats['pending'] ?? 0;
    final onProgress = stats['on_progress'] ?? 0;
    final resolved = stats['resolved'] ?? 0;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(),
            const SizedBox(height: 24),

            // Statistics Cards
            _buildStatisticsCards(total, pending, onProgress, resolved),
            const SizedBox(height: 24),

            // Chart Section
            _buildChartSection(total, pending, onProgress, resolved),
            const SizedBox(height: 24),

            // Quick Actions
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selamat Datang',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pantau dan kelola tiket Anda dengan mudah',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards(
    int total,
    int pending,
    int onProgress,
    int resolved,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total',
                value: total.toString(),
                color: Colors.blue,
                icon: Icons.receipt,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Pending',
                value: pending.toString(),
                color: Colors.orange,
                icon: Icons.schedule,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Diproses',
                value: onProgress.toString(),
                color: Colors.amber,
                icon: Icons.loop,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Selesai',
                value: resolved.toString(),
                color: Colors.green,
                icon: Icons.check_circle,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(
    int total,
    int pending,
    int onProgress,
    int resolved,
  ) {
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('Belum ada data tiket'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribusi Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Bar Chart-like visualization
        _buildBarChart(total, pending, onProgress, resolved),
      ],
    );
  }

  Widget _buildBarChart(
    int total,
    int pending,
    int onProgress,
    int resolved,
  ) {
    final getPendingPercent = (pending / total * 100).toStringAsFixed(1);
    final getOnProgressPercent = (onProgress / total * 100).toStringAsFixed(1);
    final getResolvedPercent = (resolved / total * 100).toStringAsFixed(1);

    return Column(
      children: [
        _buildBarItem(
          label: 'Pending',
          value: pending,
          percent: double.parse(getPendingPercent),
          color: Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildBarItem(
          label: 'Diproses',
          value: onProgress,
          percent: double.parse(getOnProgressPercent),
          color: Colors.amber,
        ),
        const SizedBox(height: 12),
        _buildBarItem(
          label: 'Selesai',
          value: resolved,
          percent: double.parse(getResolvedPercent),
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildBarItem({
    required String label,
    required int value,
    required double percent,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            Text(
              '$value (${percent.toStringAsFixed(1)}%)',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/ticket/list'),
            icon: const Icon(Icons.list),
            label: const Text('Lihat Semua Tiket'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.blue,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (widget.role != 'helpdesk' && widget.role != 'admin')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/ticket/create'),
              icon: const Icon(Icons.add),
              label: const Text('Buat Tiket Baru'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.green,
              ),
            ),
          ),
      ],
    );
  }
}
