import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../providers/fortune_provider.dart';

class CompatibilityCheckScreen extends ConsumerStatefulWidget {
  const CompatibilityCheckScreen({super.key});

  @override
  ConsumerState<CompatibilityCheckScreen> createState() => _CompatibilityCheckScreenState();
}

class _CompatibilityCheckScreenState extends ConsumerState<CompatibilityCheckScreen> {
  DateTime _partnerBirthDate = DateTime(1995, 6, 15);
  bool _partnerIsMale = false;
  bool _hasTime = false;
  TimeOfDay _partnerBirthTime = const TimeOfDay(hour: 12, minute: 0);
  bool _showResult = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fortuneProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a0533), Color(0xFF0d1b4b), Color(0xFF0a2744)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (!_showResult) ...[
                      _buildInputSection(),
                      const SizedBox(height: 24),
                      _buildCalculateButton(state),
                    ] else ...[
                      if (state.isCompatibilityLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(60),
                            child: Column(
                              children: [
                                CircularProgressIndicator(color: Color(0xFFD4A8FF)),
                                SizedBox(height: 16),
                                Text('궁합을 분석하고 있습니다...', style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                        )
                      else if (state.compatibilityResult != null)
                        _buildResult(state.compatibilityResult!)
                      else if (state.compatibilityError != null)
                        _buildErrorView(state.compatibilityError!),
                      const SizedBox(height: 20),
                      _buildResetButton(),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Text(
              '궁합 보기',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            const Text('💑', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('상대방 정보 입력', '💝'),
        const SizedBox(height: 16),
        _buildGenderSelector(),
        const SizedBox(height: 16),
        _buildBirthDatePicker(),
        const SizedBox(height: 16),
        _buildTimeToggle(),
        if (_hasTime) ...[
          const SizedBox(height: 12),
          _buildTimePicker(),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, String emoji) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '상대방 성별',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GenderButton(
                  label: '남성 🙋‍♂️',
                  selected: _partnerIsMale,
                  onTap: () => setState(() => _partnerIsMale = true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GenderButton(
                  label: '여성 🙋‍♀️',
                  selected: !_partnerIsMale,
                  onTap: () => setState(() => _partnerIsMale = false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBirthDatePicker() {
    return _GlassCard(
      child: InkWell(
        onTap: _pickBirthDate,
        child: Row(
          children: [
            const Text('📅', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '생년월일',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_partnerBirthDate.year}년 ${_partnerBirthDate.month}월 ${_partnerBirthDate.day}일',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeToggle() {
    return _GlassCard(
      child: Row(
        children: [
          const Text('🕐', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('출생 시간 입력', style: TextStyle(color: Colors.white, fontSize: 14)),
                Text(
                  '시간을 알면 더 정확한 궁합이 가능합니다',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: _hasTime,
            onChanged: (v) => setState(() => _hasTime = v),
            activeColor: const Color(0xFF9B59B6),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker() {
    return _GlassCard(
      child: InkWell(
        onTap: _pickBirthTime,
        child: Row(
          children: [
            const Text('⏰', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '출생 시간',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_partnerBirthTime.hour.toString().padLeft(2, '0')}:${_partnerBirthTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculateButton(FortuneState state) {
    return GestureDetector(
      onTap: _calculate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF9B59B6), Color(0xFF3498DB)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9B59B6).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('💑', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              '궁합 분석하기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(CompatibilityResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildScoreCard(result),
        const SizedBox(height: 16),
        _buildAffinityDetails(result),
        const SizedBox(height: 16),
        _buildStrengthsCautions(result),
        const SizedBox(height: 16),
        _buildCompatibilityAdvice(result),
      ],
    );
  }

  Widget _buildScoreCard(CompatibilityResult result) {
    Color scoreColor;
    if (result.score >= 85) scoreColor = const Color(0xFFFFD700);
    else if (result.score >= 70) scoreColor = const Color(0xFF9B59B6);
    else scoreColor = const Color(0xFF3498DB);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                scoreColor.withOpacity(0.25),
                scoreColor.withOpacity(0.1),
              ],
            ),
            border: Border.all(color: scoreColor.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              Text('💑', style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 16),
              Text(
                '${result.score}점',
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result.grade,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                result.summary,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAffinityDetails(CompatibilityResult result) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '세부 궁합',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          _AffinityRow(label: '연애 궁합', value: result.loveAffinity, icon: '💕'),
          const SizedBox(height: 10),
          _AffinityRow(label: '업무/활동', value: result.workAffinity, icon: '💼'),
          const SizedBox(height: 10),
          _AffinityRow(label: '대화 스타일', value: result.communicationStyle, icon: '💬'),
        ],
      ),
    );
  }

  Widget _buildStrengthsCautions(CompatibilityResult result) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💚 강점', style: TextStyle(color: Color(0xFF2ECC71), fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...result.strengths.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '• $s',
                    style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12, height: 1.4),
                  ),
                )),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚠️ 주의', style: TextStyle(color: Color(0xFFF39C12), fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...result.cautions.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '• $c',
                    style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12, height: 1.4),
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompatibilityAdvice(CompatibilityResult result) {
    return _GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✨', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '궁합 조언',
                  style: TextStyle(color: Color(0xFFD4A8FF), fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  result.advice,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Text('😢', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(error, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return GestureDetector(
      onTap: () {
        ref.read(fortuneProvider.notifier).clearCompatibility();
        setState(() => _showResult = false);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh_rounded, color: Colors.white70),
            SizedBox(width: 8),
            Text('다시 입력하기', style: TextStyle(color: Colors.white70, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _partnerBirthDate,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF9B59B6),
            onPrimary: Colors.white,
            surface: Color(0xFF1a0533),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _partnerBirthDate = picked);
  }

  Future<void> _pickBirthTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _partnerBirthTime,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF9B59B6),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _partnerBirthTime = picked);
  }

  void _calculate() {
    setState(() => _showResult = true);
    ref.read(fortuneProvider.notifier).calculateCompatibility(
      myBirthDate: DateTime(1995, 3, 20),
      myIsMale: true,
      partnerBirthDate: _partnerBirthDate,
      partnerIsMale: _partnerIsMale,
      partnerBirthTime: _hasTime
          ? DateTime(
              _partnerBirthDate.year,
              _partnerBirthDate.month,
              _partnerBirthDate.day,
              _partnerBirthTime.hour,
              _partnerBirthTime.minute,
            )
          : null,
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF9B59B6).withOpacity(0.4)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF9B59B6)
                : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _AffinityRow extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _AffinityRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(color: Color(0xFFD4A8FF), fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}