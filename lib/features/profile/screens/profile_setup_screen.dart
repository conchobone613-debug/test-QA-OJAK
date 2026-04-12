import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Step 1: 기본정보
  final _nameController = TextEditingController();
  String _gender = '남성';

  // Step 2: 생년월일시
  DateTime _birthDate = DateTime(1995, 1, 1);
  int _birthHour = 12;
  bool _unknownBirthTime = false;

  // Step 3: 사진
  File? _profileImage;

  // Step 4: 자기소개
  final _bioController = TextEditingController();
  String _mbti = 'INFJ';
  String _religion = '무교';
  String _job = '';

  // Step 5: 이상형
  RangeValues _ageRange = const RangeValues(25, 35);
  List<String> _preferredElements = [];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      _submitProfile();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitProfile() async {
    final notifier = ref.read(profileNotifierProvider.notifier);
    await notifier.createProfile(
      name: _nameController.text,
      gender: _gender,
      birthDate: _birthDate,
      birthHour: _unknownBirthTime ? null : _birthHour,
      profileImage: _profileImage,
      bio: _bioController.text,
      mbti: _mbti,
      religion: _religion,
      job: _job,
      preferredAgeRange: _ageRange,
      preferredElements: _preferredElements,
    );
    if (mounted) {
      context.go('/saju-loading');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: _prevStep,
              )
            : null,
        title: _StepIndicator(current: _currentStep, total: _totalSteps),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _Step1BasicInfo(
            nameController: _nameController,
            gender: _gender,
            onGenderChanged: (v) => setState(() => _gender = v),
            onNext: _nextStep,
          ),
          _Step2BirthDateTime(
            birthDate: _birthDate,
            birthHour: _birthHour,
            unknownBirthTime: _unknownBirthTime,
            onDateChanged: (d) => setState(() => _birthDate = d),
            onHourChanged: (h) => setState(() => _birthHour = h),
            onUnknownChanged: (v) => setState(() => _unknownBirthTime = v),
            onNext: _nextStep,
          ),
          _Step3Photo(
            profileImage: _profileImage,
            onImagePicked: (f) => setState(() => _profileImage = f),
            onNext: _nextStep,
          ),
          _Step4Bio(
            bioController: _bioController,
            mbti: _mbti,
            religion: _religion,
            job: _job,
            onMbtiChanged: (v) => setState(() => _mbti = v),
            onReligionChanged: (v) => setState(() => _religion = v),
            onJobChanged: (v) => setState(() => _job = v),
            onNext: _nextStep,
          ),
          _Step5IdealType(
            ageRange: _ageRange,
            preferredElements: _preferredElements,
            onAgeRangeChanged: (v) => setState(() => _ageRange = v),
            onElementsChanged: (v) => setState(() => _preferredElements = v),
            onNext: _nextStep,
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == current;
        final done = i < current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: done
                ? const Color(0xFFD4A843)
                : active
                    ? const Color(0xFFE8B84B)
                    : Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _StepContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback onNext;
  final String nextLabel;

  const _StepContainer({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onNext,
    this.nextLabel = '다음',
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(color: Colors.white60, fontSize: 14)),
            const SizedBox(height: 32),
            Expanded(child: SingleChildScrollView(child: child)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8B84B),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(nextLabel,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Step 1
class _Step1BasicInfo extends StatelessWidget {
  final TextEditingController nameController;
  final String gender;
  final ValueChanged<String> onGenderChanged;
  final VoidCallback onNext;

  const _Step1BasicInfo({
    required this.nameController,
    required this.gender,
    required this.onGenderChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _StepContainer(
      title: '안녕하세요! 👋',
      subtitle: '기본 정보를 알려주세요',
      onNext: onNext,
      child: Column(
        children: [
          _InputField(
            controller: nameController,
            label: '이름 (닉네임)',
            hint: '어떻게 불러드릴까요?',
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('성별', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['남성', '여성', '기타'].map((g) {
              final selected = gender == g;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => onGenderChanged(g),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 48,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFE8B84B)
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFFE8B84B)
                              : Colors.white24,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          g,
                          style: TextStyle(
                            color: selected ? Colors.black : Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Step 2
class _Step2BirthDateTime extends StatelessWidget {
  final DateTime birthDate;
  final int birthHour;
  final bool unknownBirthTime;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<bool> onUnknownChanged;
  final VoidCallback onNext;

  const _Step2BirthDateTime({
    required this.birthDate,
    required this.birthHour,
    required this.unknownBirthTime,
    required this.onDateChanged,
    required this.onHourChanged,
    required this.onUnknownChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _StepContainer(
      title: '생년월일시 🗓️',
      subtitle: '사주 계산에 필요한 정보예요',
      onNext: onNext,
      child: Column(
        children: [
          _SectionLabel('생년월일'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: birthDate,
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
                builder: (ctx, child) => Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: Color(0xFFE8B84B),
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) onDateChanged(picked);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${birthDate.year}년 ${birthDate.month}월 ${birthDate.day}일',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const Icon(Icons.calendar_today, color: Color(0xFFE8B84B)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionLabel('태어난 시간'),
              Row(
                children: [
                  const Text('모름', style: TextStyle(color: Colors.white60)),
                  Switch(
                    value: unknownBirthTime,
                    onChanged: onUnknownChanged,
                    activeColor: const Color(0xFFE8B84B),
                  ),
                ],
              ),
            ],
          ),
          if (!unknownBirthTime) ...[
            const SizedBox(height: 8),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CupertinoPicker(
                scrollController:
                    FixedExtentScrollController(initialItem: birthHour),
                itemExtent: 40,
                onSelectedItemChanged: onHourChanged,
                children: List.generate(24, (i) {
                  final label = _hourToKorean(i);
                  return Center(
                    child: Text(
                      '$label ($i시)',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _hourToKorean(int hour) {
    const map = {
      23: '자시', 0: '자시', 1: '축시', 2: '축시', 3: '인시', 4: '인시',
      5: '묘시', 6: '묘시', 7: '진시', 8: '진시', 9: '사시', 10: '사시',
      11: '오시', 12: '오시', 13: '미시', 14: '미시', 15: '신시', 16: '신시',
      17: '유시', 18: '유시', 19: '술시', 20: '술시', 21: '해시', 22: '해시',
    };
    return map[hour] ?? '자시';
  }
}

// Step 3
class _Step3Photo extends StatelessWidget {
  final File? profileImage;
  final ValueChanged<File?> onImagePicked;
  final VoidCallback onNext;

  const _Step3Photo({
    required this.profileImage,
    required this.onImagePicked,
    required this.onNext,
  });

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) onImagePicked(File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return _StepContainer(
      title: '프로필 사진 📸',
      subtitle: '상대방에게 보여질 첫 인상이에요',
      onNext: onNext,
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white10,
                  border: Border.all(
                      color: const Color(0xFFE8B84B), width: 2),
                  image: profileImage != null
                      ? DecorationImage(
                          image: FileImage(profileImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: profileImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo,
                              color: Color(0xFFE8B84B), size: 40),
                          SizedBox(height: 8),
                          Text('사진 추가',
                              style: TextStyle(color: Colors.white60)),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => onImagePicked(null),
              child: const Text('건너뛰기',
                  style: TextStyle(color: Colors.white38)),
            ),
          ],
        ),
      ),
    );
  }
}

// Step 4
class _Step4Bio extends StatelessWidget {
  final TextEditingController bioController;
  final String mbti;
  final String religion;
  final String job;
  final ValueChanged<String> onMbtiChanged;
  final ValueChanged<String> onReligionChanged;
  final ValueChanged<String> onJobChanged;
  final VoidCallback onNext;

  const _Step4Bio({
    required this.bioController,
    required this.mbti,
    required this.religion,
    required this.job,
    required this.onMbtiChanged,
    required this.onReligionChanged,
    required this.onJobChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    const mbtiOptions = [
      'INTJ','INTP','ENTJ','ENTP','INFJ','INFP','ENFJ','ENFP',
      'ISTJ','ISFJ','ESTJ','ESFJ','ISTP','ISFP','ESTP','ESFP',
    ];
    const religionOptions = ['무교', '불교', '기독교', '천주교', '이슬람교', '기타'];

    return _StepContainer(
      title: '자기소개 ✨',
      subtitle: '나를 더 잘 알릴 수 있게 도와드릴게요',
      onNext: onNext,
      child: Column(
        children: [
          _InputField(
            controller: bioController,
            label: '자기소개',
            hint: '간단하게 자신을 소개해 보세요',
            maxLines: 4,
          ),
          const SizedBox(height: 20),
          _InputField(
            label: '직업',
            hint: '직업을 입력해 주세요',
            onChanged: onJobChanged,
          ),
          const SizedBox(height: 20),
          _DropdownField(
            label: 'MBTI',
            value: mbti,
            items: mbtiOptions,
            onChanged: onMbtiChanged,
          ),
          const SizedBox(height: 20),
          _DropdownField(
            label: '종교',
            value: religion,
            items: religionOptions,
            onChanged: onReligionChanged,
          ),
        ],
      ),
    );
  }
}

// Step 5
class _Step5IdealType extends StatelessWidget {
  final RangeValues ageRange;
  final List<String> preferredElements;
  final ValueChanged<RangeValues> onAgeRangeChanged;
  final ValueChanged<List<String>> onElementsChanged;
  final VoidCallback onNext;

  const _Step5IdealType({
    required this.ageRange,
    required this.preferredElements,
    required this.onAgeRangeChanged,
    required this.onElementsChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    const elements = ['목(木)', '화(火)', '토(土)', '금(金)', '수(水)'];
    return _StepContainer(
      title: '이상형 💕',
      subtitle: '어떤 분을 원하시나요?',
      onNext: onNext,
      nextLabel: '완료',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('선호 나이'),
          const SizedBox(height: 8),
          Text(
            '${ageRange.start.round()}세 ~ ${ageRange.end.round()}세',
            style: const TextStyle(
                color: Color(0xFFE8B84B),
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          RangeSlider(
            values: ageRange,
            min: 20,
            max: 60,
            divisions: 40,
            activeColor: const Color(0xFFE8B84B),
            inactiveColor: Colors.white24,
            onChanged: onAgeRangeChanged,
          ),
          const SizedBox(height: 24),
          _SectionLabel('선호하는 오행'),
          const SizedBox(height: 4),
          const Text('궁합이 잘 맞는 오행을 선택하세요 (중복 가능)',
              style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: elements.map((e) {
              final selected = preferredElements.contains(e);
              return GestureDetector(
                onTap: () {
                  final updated = List<String>.from(preferredElements);
                  if (selected) {
                    updated.remove(e);
                  } else {
                    updated.add(e);
                  }
                  onElementsChanged(updated);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? _elementColor(e).withOpacity(0.3)
                        : Colors.white10,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: selected
                          ? _elementColor(e)
                          : Colors.white24,
                    ),
                  ),
                  child: Text(
                    e,
                    style: TextStyle(
                      color: selected ? _elementColor(e) : Colors.white60,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static Color _elementColor(String e) {
    if (e.contains('목')) return const Color(0xFF4CAF50);
    if (e.contains('화')) return const Color(0xFFE53935);
    if (e.contains('토')) return const Color(0xFFFF9800);
    if (e.contains('금')) return const Color(0xFFB0BEC5);
    if (e.contains('수')) return const Color(0xFF1E88E5);
    return Colors.white;
  }
}

// 공통 위젯들
class _InputField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String hint;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const _InputField({
    this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFE8B84B), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: const Color(0xFF2A2A3E),
            underline: const SizedBox(),
            style: const TextStyle(color: Colors.white),
            items: items
                .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(color: Colors.white70, fontSize: 14));
  }
}