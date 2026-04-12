import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _bioController = TextEditingController();

  File? _selectedImage;
  List<String> _selectedInterests = [];
  Map<String, String> _idealType = {};
  bool _isSaving = false;

  static const List<String> _availableInterests = [
    '여행', '독서', '운동', '요리', '음악', '영화', '게임', '미술',
    '사진', '등산', '반려동물', '카페', '쇼핑', '요가', '명상',
  ];

  static const List<String> _idealTypeKeys = [
    '성격', '외모', '가치관', '취미', '연령대',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  void _loadCurrentProfile() {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    _nicknameController.text = user.nickname ?? '';
    _bioController.text = user.bio ?? '';
    _selectedInterests = List<String>.from(user.interests ?? []);
    _idealType = Map<String, String>.from(user.idealType ?? {});
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      // TODO: upload image if _selectedImage != null
      // TODO: call ref.read(authProvider.notifier).updateProfile(...)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 저장되었습니다.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('프로필 편집'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('저장', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PhotoSection(
              selectedImage: _selectedImage,
              existingPhotoUrl: ref.watch(authProvider).user?.photoUrl,
              onPickImage: _pickImage,
            ),
            const SizedBox(height: 24),
            _SectionTitle('기본 정보'),
            const SizedBox(height: 12),
            _NicknameField(controller: _nicknameController),
            const SizedBox(height: 12),
            _BioField(controller: _bioController),
            const SizedBox(height: 24),
            _SectionTitle('관심사'),
            const SizedBox(height: 12),
            _InterestsSelector(
              available: _availableInterests,
              selected: _selectedInterests,
              onChanged: (interests) =>
                  setState(() => _selectedInterests = interests),
            ),
            const SizedBox(height: 24),
            _SectionTitle('이상형'),
            const SizedBox(height: 12),
            _IdealTypeEditor(
              keys: _idealTypeKeys,
              values: _idealType,
              onChanged: (key, value) =>
                  setState(() => _idealType[key] = value),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  final File? selectedImage;
  final String? existingPhotoUrl;
  final VoidCallback onPickImage;

  const _PhotoSection({
    required this.selectedImage,
    required this.existingPhotoUrl,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 56,
            backgroundColor: Colors.grey[200],
            backgroundImage: selectedImage != null
                ? FileImage(selectedImage!)
                : (existingPhotoUrl != null
                    ? NetworkImage(existingPhotoUrl!) as ImageProvider
                    : null),
            child: (selectedImage == null && existingPhotoUrl == null)
                ? const Icon(Icons.person, size: 56, color: Colors.grey)
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onPickImage,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }
}

class _NicknameField extends StatelessWidget {
  final TextEditingController controller;
  const _NicknameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: '닉네임',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person_outline),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return '닉네임을 입력해주세요';
        if (v.trim().length < 2) return '닉네임은 2자 이상이어야 합니다';
        if (v.trim().length > 10) return '닉네임은 10자 이하여야 합니다';
        return null;
      },
    );
  }
}

class _BioField extends StatelessWidget {
  final TextEditingController controller;
  const _BioField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      maxLength: 150,
      decoration: const InputDecoration(
        labelText: '자기소개',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: 48),
          child: Icon(Icons.edit_note),
        ),
      ),
    );
  }
}

class _InterestsSelector extends StatelessWidget {
  final List<String> available;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const _InterestsSelector({
    required this.available,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: available.map((interest) {
        final isSelected = selected.contains(interest);
        return FilterChip(
          label: Text(interest),
          selected: isSelected,
          onSelected: (val) {
            final newList = List<String>.from(selected);
            if (val) {
              if (newList.length < 5) newList.add(interest);
            } else {
              newList.remove(interest);
            }
            onChanged(newList);
          },
          selectedColor: AppColors.primary.withOpacity(0.2),
          checkmarkColor: AppColors.primary,
        );
      }).toList(),
    );
  }
}

class _IdealTypeEditor extends StatelessWidget {
  final List<String> keys;
  final Map<String, String> values;
  final void Function(String key, String value) onChanged;

  const _IdealTypeEditor({
    required this.keys,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: keys.map((key) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            initialValue: values[key] ?? '',
            decoration: InputDecoration(
              labelText: key,
              border: const OutlineInputBorder(),
              hintText: '이상형의 $key를 입력해주세요',
            ),
            onChanged: (value) => onChanged(key, value),
          ),
        );
      }).toList(),
    );
  }
}