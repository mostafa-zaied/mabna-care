import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/contact_picker.dart';
import '../core/utils/image_compressor.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import '../models/building_models.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_card.dart';
import '../widgets/dialogs/confirm_delete_dialog.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  /// 0 = Phone numbers only, 1 = Cards & photos only
  int _selectedTab = 0;

  /// 'all' | 'plumbing' | 'electric' | 'elevator' | 'ac' | 'carpentry' | 'other'
  String _selectedCategory = 'all';

  static const _categoryKeys = [
    'plumbing',
    'electric',
    'elevator',
    'ac',
    'carpentry',
    'other',
  ];

  String _categoryLabel(dynamic s, String key) {
    return switch (key) {
      'plumbing' => '${s.catPlumbing}',
      'electric' => '${s.catElectric}',
      'elevator' => '${s.catElevator}',
      'ac' => '${s.catAc}',
      'carpentry' => '${s.catCarpentry}',
      'other' => '${s.catOther}',
      _ => '${s.catAll}',
    };
  }

  IconData _categoryIcon(String key) {
    return switch (key) {
      'plumbing' => Icons.plumbing_rounded,
      'electric' => Icons.bolt_rounded,
      'elevator' => Icons.elevator_outlined,
      'ac' => Icons.ac_unit_rounded,
      'carpentry' => Icons.carpenter_outlined,
      'other' => Icons.build_outlined,
      _ => Icons.apps_rounded,
    };
  }

  static String _normalizeForSort(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[أإآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }

  static int _compareByTitle(BuildingContact a, BuildingContact b) {
    return _normalizeForSort(a.name).compareTo(_normalizeForSort(b.name));
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.trim());
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchWhatsApp(String waNumber) async {
    final uri = Uri.parse('https://wa.me/$waNumber');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showFullCardViewer(BuildContext context, BuildingContact contact) {
    if (!contact.hasCardImage) return;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.90),
      builder: (ctx) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.5,
                  child: Center(
                    child: contact.localCardBytes != null
                        ? Image.memory(
                            contact.localCardBytes!,
                            fit: BoxFit.contain,
                          )
                        : Image.network(
                            contact.cardImageUrl!,
                            fit: BoxFit.contain,
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: AppSpacing.md,
                start: AppSpacing.md,
                end: AppSpacing.md,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          contact.roleDesc.trim().isNotEmpty
                              ? '${contact.name} • ${contact.roleDesc}'
                              : contact.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showContactFormDialog(
    BuildContext context,
    BuildingCubit cubit,
    BuildingState state, {
    BuildingContact? existing,
  }) async {
    final isEdit = existing != null;
    final s = state.s;
    final isDark = state.isDarkMode;
    final picker = ImagePicker();
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final roleCtrl = TextEditingController(text: existing?.roleDesc ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    String selectedCategory = existing?.category ?? 'other';
    final aptsCount = state.currentMonth?.aptsCount ?? 13;
    int? selectedApt = state.myAptNum;
    if (selectedApt != null && (selectedApt < 1 || selectedApt > aptsCount)) {
      selectedApt = null;
    }
    final showAptDropdown =
        !isEdit && !state.isAdminAuthenticated && state.myAptNum == null;
    Uint8List? cardBytes;
    bool removeExistingCard = false;
    String? errMsg;
    bool saving = false;

    Future<void> pickCard(
      ImageSource source,
      void Function(VoidCallback) setModalState,
    ) async {
      try {
        final XFile? file = await picker.pickImage(
          source: source,
          maxWidth: 1600,
          maxHeight: 1600,
          imageQuality: 78,
        );
        if (file == null) return;
        final raw = await file.readAsBytes();
        final compressed = await compressReceiptImage(raw);
        setModalState(() {
          cardBytes = compressed;
          removeExistingCard = false;
          if (errMsg != null) errMsg = null;
        });
      } catch (_) {}
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final hasExistingCard =
              isEdit && existing.hasCardImage && !removeExistingCard;
          final hasAnyCard = cardBytes != null || hasExistingCard;

          return AlertDialog(
            backgroundColor: AppColors.card(isDark),
            title: Text(
              isEdit ? s.editContactTitle : s.addContactTitle,
              style: AppTypography.headline.copyWith(fontSize: 15),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showAptDropdown) ...[
                      DropdownButtonFormField<int>(
                        initialValue: selectedApt,
                        dropdownColor: AppColors.cardElevated(isDark),
                        decoration: InputDecoration(
                          labelText: s.contactSelectYourAptLabel,
                          hintText: s.contactSelectYourAptHint,
                        ),
                        items: List.generate(aptsCount, (i) {
                          final aptNum = i + 1;
                          final label = state.aptLabel(aptNum);
                          final def = s.defaultAptName(aptNum);
                          final text = label == def ? label : '$def — $label';
                          return DropdownMenuItem<int>(
                            value: aptNum,
                            child: Text(text, overflow: TextOverflow.ellipsis),
                          );
                        }),
                        onChanged: saving
                            ? null
                            : (v) => setModalState(() {
                                  selectedApt = v;
                                  if (errMsg != null) errMsg = null;
                                }),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    TextField(
                      controller: nameCtrl,
                      enabled: !saving,
                      decoration: InputDecoration(
                        labelText: s.contactNameLabel,
                        hintText: s.contactNameHint,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: roleCtrl,
                      enabled: !saving,
                      decoration: InputDecoration(
                        labelText: s.contactRoleLabel,
                        hintText: s.contactRoleHint,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      dropdownColor: AppColors.cardElevated(isDark),
                      decoration: InputDecoration(
                        labelText: s.contactCategoryLabel,
                      ),
                      items: _categoryKeys
                          .map(
                            (k) => DropdownMenuItem<String>(
                              value: k,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _categoryIcon(k),
                                    size: 16,
                                    color: AppColors.primaryText(isDark),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(_categoryLabel(s, k)),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: saving
                          ? null
                          : (v) {
                              if (v != null) {
                                setModalState(() => selectedCategory = v);
                              }
                            },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: phoneCtrl,
                      enabled: !saving,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      decoration: InputDecoration(
                        labelText: s.contactPhoneLabel,
                        hintText: hasAnyCard
                            ? s.contactPhoneOptionalHint
                            : s.contactPhoneHint,
                        suffixIcon: IconButton(
                          tooltip: s.contactPickFromDeviceTooltip,
                          onPressed: saving
                              ? null
                              : () async {
                                  if (!isContactPickerSupported()) {
                                    setModalState(
                                      () => errMsg =
                                          s.contactPickerUnsupportedHint,
                                    );
                                    return;
                                  }
                                  final picked = await pickDeviceContact();
                                  if (picked == null) return;
                                  setModalState(() {
                                    if (picked.phone.isNotEmpty) {
                                      phoneCtrl.text = picked.phone;
                                    }
                                    if (nameCtrl.text.trim().isEmpty &&
                                        picked.name.isNotEmpty) {
                                      nameCtrl.text = picked.name;
                                    }
                                    if (errMsg != null) errMsg = null;
                                  });
                                },
                          icon: Icon(
                            Icons.contacts_outlined,
                            size: 20,
                            color: AppColors.primaryText(isDark),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      s.contactCardPhotoLabel,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: saving
                                ? null
                                : () => pickCard(ImageSource.camera, setModalState),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              side: BorderSide(color: AppColors.border(isDark)),
                            ),
                            icon: const Icon(Icons.photo_camera_rounded, size: 17),
                            label: Text(
                              s.contactTakePhotoBtn,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary(isDark),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: saving
                                ? null
                                : () => pickCard(ImageSource.gallery, setModalState),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              side: BorderSide(color: AppColors.border(isDark)),
                            ),
                            icon: const Icon(Icons.photo_library_outlined, size: 17),
                            label: Text(
                              s.contactPickGalleryBtn,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary(isDark),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (hasAnyCard) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: Container(
                              width: double.infinity,
                              height: 130,
                              color: AppColors.surface(isDark),
                              child: cardBytes != null
                                  ? Image.memory(
                                      cardBytes!,
                                      fit: BoxFit.cover,
                                    )
                                  : (existing!.localCardBytes != null
                                      ? Image.memory(
                                          existing.localCardBytes!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          existing.cardImageUrl!,
                                          fit: BoxFit.cover,
                                        )),
                            ),
                          ),
                          PositionedDirectional(
                            top: 6,
                            end: 6,
                            child: InkWell(
                              onTap: saving
                                  ? null
                                  : () => setModalState(() {
                                        cardBytes = null;
                                        if (isEdit) removeExistingCard = true;
                                      }),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (errMsg != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        errMsg!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(ctx),
                child: Text(s.cancel),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryActionBg(isDark),
                  foregroundColor: AppColors.onPrimaryAction(isDark),
                ),
                onPressed: saving
                    ? null
                    : () async {
                        if (!isEdit &&
                            !state.isAdminAuthenticated &&
                            selectedApt == null) {
                          setModalState(() => errMsg = s.errContactSelectApt);
                          return;
                        }
                        final hasName = nameCtrl.text.trim().isNotEmpty;
                        final hasPhone = phoneCtrl.text.trim().isNotEmpty;
                        if (!hasName || (!hasPhone && !hasAnyCard)) {
                          setModalState(
                            () => errMsg = s.errContactNameOrCardRequired,
                          );
                          return;
                        }
                        setModalState(() {
                          saving = true;
                          errMsg = null;
                        });
                        final bool ok;
                        if (isEdit) {
                          ok = await cubit.updateBuildingContact(
                            id: existing.id,
                            name: nameCtrl.text,
                            roleDesc: roleCtrl.text,
                            phone: phoneCtrl.text,
                            category: selectedCategory,
                            newCardImageBytes: cardBytes,
                            removeCardImage: removeExistingCard,
                          );
                        } else {
                          ok = await cubit.addBuildingContact(
                            name: nameCtrl.text,
                            roleDesc: roleCtrl.text,
                            phone: phoneCtrl.text,
                            category: selectedCategory,
                            addedByApt:
                                state.isAdminAuthenticated ? null : selectedApt,
                            addedByLabel: state.isAdminAuthenticated
                                ? 'admin'
                                : (selectedApt != null
                                    ? state.aptLabel(selectedApt!)
                                    : null),
                            cardImageBytes: cardBytes,
                          );
                        }
                        if (ok && ctx.mounted) {
                          Navigator.pop(ctx);
                        } else if (ctx.mounted) {
                          setModalState(() => saving = false);
                        }
                      },
                child: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(s.saveAll),
              ),
            ],
          );
        },
      ),
    );

    Future.delayed(const Duration(milliseconds: 350), () {
      nameCtrl.dispose();
      roleCtrl.dispose();
      phoneCtrl.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        final cubit = context.read<BuildingCubit>();
        final s = state.s;
        final isDark = state.isDarkMode;
        final allContacts = state.buildingContacts;
        final numberContacts = allContacts.where((c) => c.hasPhone).toList()
          ..sort(_compareByTitle);
        final cardContacts = allContacts.where((c) => c.hasCardImage).toList()
          ..sort(_compareByTitle);
        final tabContacts =
            _selectedTab == 0 ? numberContacts : cardContacts;
        final visibleContacts = _selectedCategory == 'all'
            ? tabContacts
            : tabContacts
                .where((c) => c.category == _selectedCategory)
                .toList();

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(
                            Icons.contact_phone_outlined,
                            size: 20,
                            color: AppColors.primaryText(isDark),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.contactsTitle,
                                style: AppTypography.headline.copyWith(fontSize: 15),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s.contactsSubtitle,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (state.canResidentMutate) ...[
                          const SizedBox(width: AppSpacing.sm),
                          AppPrimaryButton(
                            label: s.addContactBtn,
                            icon: Icons.add_rounded,
                            backgroundColor: AppColors.primaryActionBg(isDark),
                            foregroundColor: AppColors.onPrimaryAction(isDark),
                            onPressed: () =>
                                _showContactFormDialog(context, cubit, state),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // 2-Tab Segmented Switcher: Numbers vs Cards & Photos
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.card(isDark),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border(isDark)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ContactsTabPill(
                            icon: Icons.phone_in_talk_rounded,
                            label: s.contactsTabNumbers,
                            count: numberContacts.length,
                            selected: _selectedTab == 0,
                            isDark: isDark,
                            onTap: () => setState(() => _selectedTab = 0),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _ContactsTabPill(
                            icon: Icons.badge_outlined,
                            label: s.contactsTabCards,
                            count: cardContacts.length,
                            selected: _selectedTab == 1,
                            isDark: isDark,
                            onTap: () => setState(() => _selectedTab = 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Category Classification Filter Strip
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final cat in ['all', ..._categoryKeys]) ...[
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 6),
                            child: ChoiceChip(
                              avatar: Icon(
                                _categoryIcon(cat),
                                size: 15,
                                color: _selectedCategory == cat
                                    ? AppColors.onPrimaryAction(isDark)
                                    : AppColors.primaryText(isDark),
                              ),
                              label: Text(
                                cat == 'all'
                                    ? '${s.catAll} (${tabContacts.length})'
                                    : _categoryLabel(s, cat),
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: _selectedCategory == cat
                                      ? AppColors.onPrimaryAction(isDark)
                                      : AppColors.textSecondary(isDark),
                                ),
                              ),
                              selected: _selectedCategory == cat,
                              selectedColor: AppColors.primaryActionBg(isDark),
                              backgroundColor: AppColors.card(isDark),
                              side: BorderSide(
                                color: _selectedCategory == cat
                                    ? AppColors.primary
                                    : AppColors.border(isDark),
                              ),
                              showCheckmark: false,
                              onSelected: (_) =>
                                  setState(() => _selectedCategory = cat),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: cubit.refreshData,
                      color: AppColors.primary,
                      child: visibleContacts.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                const SizedBox(height: 80),
                                Center(
                                  child: AppCard(
                                    padding: const EdgeInsetsDirectional.all(AppSpacing.xxxl),
                                    child: Text(
                                      _selectedTab == 0
                                          ? s.noContactsYet
                                          : s.noContactCardsYet,
                                      style: AppTypography.body.copyWith(
                                        color: AppColors.textSecondary(isDark),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsetsDirectional.only(bottom: 90),
                              itemCount: visibleContacts.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, index) {
                                final c = visibleContacts[index];
                                String? adminAddedByText;
                                if (state.isAdminAuthenticated) {
                                  if (c.addedByApt != null) {
                                    final aptLabel = state.aptLabel(c.addedByApt!);
                                    final defApt = s.defaultAptName(c.addedByApt!);
                                    final fullLabel = aptLabel == defApt
                                        ? aptLabel
                                        : '$aptLabel ($defApt)';
                                    adminAddedByText =
                                        s.contactAddedByAptLabel(fullLabel);
                                  } else if (c.addedByLabel == 'admin') {
                                    adminAddedByText = s.contactAddedByAptLabel(
                                      s.contactAddedByAdmin,
                                    );
                                  } else if ((c.addedByLabel ?? '').isNotEmpty) {
                                    adminAddedByText =
                                        s.contactAddedByAptLabel(c.addedByLabel!);
                                  }
                                }
                                return _ContactCard(
                                  contact: c,
                                  isDark: isDark,
                                  isAdmin: state.isAdminAuthenticated,
                                  showCardPreview: _selectedTab == 1,
                                  showPhoneActions: _selectedTab == 0,
                                  addedByText: adminAddedByText,
                                  callLabel: s.callBtn,
                                  waLabel: s.whatsappBtn,
                                  tapToZoomLabel: s.contactTapToZoomHint,
                                  viewCardLabel: s.contactViewCardBtn,
                                  onCall: c.hasPhone
                                      ? () => _launchPhone(c.phone)
                                      : null,
                                  onWhatsApp: c.supportsWhatsApp
                                      ? () => _launchWhatsApp(c.whatsappNumber)
                                      : null,
                                  onViewCard: c.hasCardImage
                                      ? () => _showFullCardViewer(context, c)
                                      : null,
                                  onEdit: state.isAdminAuthenticated
                                      ? () => _showContactFormDialog(
                                            context,
                                            cubit,
                                            state,
                                            existing: c,
                                          )
                                      : null,
                                  onDelete: state.isAdminAuthenticated
                                      ? () async {
                                          await showConfirmDeleteDialog(
                                            context: context,
                                            s: s,
                                            isDark: isDark,
                                            message: s.confirmDeleteContactBody(c.name),
                                            onConfirm: () => cubit.deleteBuildingContact(c.id),
                                          );
                                        }
                                      : null,
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ContactsTabPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _ContactsTabPill({
    required this.icon,
    required this.label,
    required this.count,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected
        ? AppColors.onPrimaryAction(isDark)
        : AppColors.textSecondary(isDark);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryActionBg(isDark)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? fg.withValues(alpha: 0.18)
                      : AppColors.surface(isDark),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '$count',
                  style: AppTypography.caption.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final BuildingContact contact;
  final bool isDark;
  final bool isAdmin;
  final bool showCardPreview;
  final bool showPhoneActions;
  final String? addedByText;
  final String callLabel;
  final String waLabel;
  final String tapToZoomLabel;
  final String viewCardLabel;
  final VoidCallback? onCall;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onViewCard;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ContactCard({
    required this.contact,
    required this.isDark,
    required this.isAdmin,
    this.showCardPreview = true,
    this.showPhoneActions = true,
    this.addedByText,
    required this.callLabel,
    required this.waLabel,
    required this.tapToZoomLabel,
    required this.viewCardLabel,
    this.onCall,
    this.onWhatsApp,
    this.onViewCard,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surface(isDark),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border(isDark)),
                ),
                child: Icon(
                  contact.hasCardImage && !contact.hasPhone
                      ? Icons.badge_outlined
                      : Icons.phone_in_talk_outlined,
                  size: 18,
                  color: AppColors.primaryText(isDark),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: AppTypography.title.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    if (contact.roleDesc.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        contact.roleDesc,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                    ],
                    if (addedByText != null) ...[
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.30),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 12,
                              color: AppColors.primaryText(isDark),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                addedByText!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryText(isDark),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isAdmin && onEdit != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.primaryText(isDark),
                  ),
                ),
              if (isAdmin && onDelete != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: AppColors.dangerText(isDark),
                  ),
                ),
            ],
          ),
          if (showCardPreview && contact.hasCardImage) ...[
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: onViewCard,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  height: 175,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface(isDark),
                    border: Border.all(color: AppColors.border(isDark)),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (contact.localCardBytes != null)
                        Image.memory(
                          contact.localCardBytes!,
                          fit: BoxFit.cover,
                        )
                      else
                        Image.network(
                          contact.cardImageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                        ),
                      PositionedDirectional(
                        bottom: 8,
                        end: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.68),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.zoom_in_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tapToZoomLabel,
                                style: AppTypography.caption.copyWith(
                                  fontSize: 10.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          if (showPhoneActions && onCall != null)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCall,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryActionBg(isDark),
                      foregroundColor: AppColors.onPrimaryAction(isDark),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    icon: const Icon(Icons.call_rounded, size: 16),
                    label: Text(
                      '$callLabel: ${contact.phone}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimaryAction(isDark),
                      ),
                    ),
                  ),
                ),
                if (onWhatsApp != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton.icon(
                    onPressed: onWhatsApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    icon: const Icon(Icons.chat_rounded, size: 16),
                    label: Text(
                      waLabel,
                      style: AppTypography.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            )
          else if (showCardPreview && onViewCard != null)
            OutlinedButton.icon(
              onPressed: onViewCard,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              icon: Icon(
                Icons.zoom_in_rounded,
                size: 16,
                color: AppColors.primaryText(isDark),
              ),
              label: Text(
                viewCardLabel,
                style: AppTypography.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText(isDark),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
