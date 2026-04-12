import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/community_provider.dart';

const List<String> _categories = ['자유', '사주', '운세', '연애', '직업', '건강'];

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();

  String _selectedCategory = '자유';
  final List<String> _tags = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim().replaceAll('#', '');
    if (tag.isNotEmpty && !_tags.contains(tag) && _tags.length < 5) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(communityProvider.notifier).createPost(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            category: _selectedCategory,
            tags: _tags,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('글 작성', style: TextStyle(color: Colors.white)),
        actions: [
          _isSubmitting
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFFD4AF37)),
                  ),
                )
              : TextButton(
                  onPressed: _submit,
                  child: const Text(
                    '등록',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '카테고리',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final selected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFD4AF37)
                              : Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFFD4AF37)
                                : Colors.white12,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: selected ? Colors.black : Colors.white54,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '제목',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                maxLength: 100,
                decoration: _inputDecoration('제목을 입력하세요'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return '제목을 입력하세요';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                '내용',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                style: const TextStyle(color: Colors.white, height: 1.5),
                maxLines: 10,
                maxLength: 2000,
                decoration: _inputDecoration('내용을 입력하세요'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return '내용을 입력하세요';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                '태그 (최대 5개)',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('#태그 입력').copyWith(
                        prefixText: '#',
                        prefixStyle: const TextStyle(color: Color(0xFFD4AF37)),
                      ),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addTag,
                    icon: const Icon(Icons.add_circle, color: Color(0xFFD4AF37)),
                  ),
                ],
              ),
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _tags
                      .map(
                        (tag) => Chip(
                          label: Text('#$tag',
                              style: const TextStyle(
                                  color: Color(0xFFD4AF37), fontSize: 12)),
                          backgroundColor:
                              const Color(0xFFD4AF37).withOpacity(0.1),
                          deleteIconColor: Colors.white38,
                          side: const BorderSide(
                              color: Color(0xFFD4AF37), width: 0.5),
                          onDeleted: () => setState(() => _tags.remove(tag)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD4AF37)),
      ),
      counterStyle: const TextStyle(color: Colors.white30),
    );
  }
}